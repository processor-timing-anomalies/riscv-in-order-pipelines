# Our accurate, complete timing specification for the CV32E40X

Generated from our records of the CV32E40X on 25 October 2026, for the RTL at commit `d952cd63bc1b4eb58cd893c28ef8283c781e345e`; the configurations measured: cv32e40x-clic (the CLIC build), cv32e40x-pma-a (the PMA with A build), cv32e40x-pma (the PMA build), cv32e40x-zbc (the Zbc build).  The timing is as measured on that commit; the document is regenerated after every run we record.

This document states what the cv32e40x core promises in time: the pipeline as a structure, the cycle each instruction class takes, the stalls and bubbles between instructions, the memory side under a stated bus, the CSR accesses that wait, the interrupts and other events, what real programs pay on it, and where the RTL and the user manual disagree.  It is the rendering of our internal machine-readable version of the RISC-V ISA, this core's layer distilled from its user manual with a citation or a graded reading on every field, a configuration layer for each variant, and the RTL read only to answer what the manual leaves open.  It describes the implementation as measured; a row graded inferred or read is not design intent until the core's authors take it as theirs (the grade authored).

| grade | meaning |
|---|---|
| stated | the manual says it |
| confirmed | the manual says it and the RTL agreed under the suites |
| inferred | the manual is silent; a run showed it and the suites confirmed it |
| read | read in the RTL source, cited by file and line; not a statement of the manual |
| open | a question no run has answered |
| authored | the core's authors have taken the row as their statement (reserved) |

**Conditions.**  Every row states what it assumes.  The manual's cycle table assumes zero stall on both interfaces (pipeline.rst 30-31), and the hazard rows are compared under that; the memory rows hold under any bus schedule a test names (the waits, the write buffer, the outstanding requests, the PMA regions), so their condition is the schedule; a configuration's rows assume its parameters.  No row claims zero-wait as a general condition of the core.

**Sources.**  Where the manual is cited: the OpenHW CV32E40X user manual at the pinned RTL commit (pipeline.rst, control_status_registers.rst, exceptions_interrupts.rst); where the RTL is cited: its files and lines at the same commit (`d952cd63bc1b4eb58cd893c28ef8283c781e345e`).

**Contents**

- [1. The pipeline as a structure: stages, read and write points](#1-the-pipeline-as-a-structure-stages-read-and-write-points)
- [2. Cycle counts per instruction class: the base cost of every instruction](#2-cycle-counts-per-instruction-class-the-base-cost-of-every-instruction)
- [3. Three facts of the pipeline the rules below assume](#3-three-facts-of-the-pipeline-the-rules-below-assume)
- [4. Hazards: the stalls between instructions, derived and documented](#4-hazards-the-stalls-between-instructions-derived-and-documented)
- [5. The memory side: the bus, the write buffer, misaligned and atomic accesses](#5-the-memory-side-the-bus-the-write-buffer-misaligned-and-atomic-accesses)
- [6. CSRs and counters: the accesses that wait](#6-csrs-and-counters-the-accesses-that-wait)
- [7. Interrupts and other events: when they are taken and what they cost](#7-interrupts-and-other-events-when-they-are-taken-and-what-they-cost)
- [8. What real programs pay on this core: the cycles lost to stalls, by cause](#8-what-real-programs-pay-on-this-core-the-cycles-lost-to-stalls-by-cause)
- [9. Where the RTL and the manual differ: the anomalies we found](#9-where-the-rtl-and-the-manual-differ-the-anomalies-we-found)
- [10. What the base build's rows leave to a configuration, and what no test reaches](#10-what-the-base-builds-rows-leave-to-a-configuration-and-what-no-test-reaches)
- [11. How far this specification has been checked: the evidence behind it](#11-how-far-this-specification-has-been-checked-the-evidence-behind-it)
- [12. The configurations: what each build adds or changes](#12-the-configurations-what-each-build-adds-or-changes)

## 1. The pipeline as a structure: stages, read and write points

| the machine | this core | source | grade |
|---|---|---|---|
| stages | IF ID EX WB | pipeline.rst 12-24 | stated |
| register ports read in | rs1: ID, rs2: ID, store_data: ID, branch_cmp: ID, jalr_target: ID, mem_base: ID, csr: EX | pipeline.rst 18, 116 | stated |
| read a stage early | jalr_target: 1 | pipeline.rst 18, 117, 125 | stated |
| results written | rd: WB | pipeline.rst 24 | stated |
| result available, per class | alu_rr: EX, alu_ri: EX, alu_nosrc: EX, load: WB, store: WB, branch: EX, jal: EX, jalr: EX, tbljmp: EX, csr_r: EX, csr_i: EX, mul: EX, mulh: EX, div: EX, system: WB, trap: WB | pipeline.rst 21, 48-49, 81, 118-121 | stated |
| occupancy, per class (cycles beyond the first in the stage named) | mulh: 4; div: default 3 to 35; rule 3 + (clz(rs2) if unsigned or rs2 < 2**31 else clo(rs2) - 1); csr_r: default 1; csr_i: default 1; tbljmp: default 3; stage ID; load: default 1; misaligned 2; store: default 1; misaligned 2; fence: default 2; stage WB; fence.tso: default 2; stage WB; fence.i: default 3; stage WB | pipeline.rst Cycle counts per instruction type | stated |
| forwarding paths | EX -> ID, WB -> ID | the Hazards list charges nothing for an ALU-type producer at distance 1 (only a jalr consumer pays) and nothing for any producer at distance 2, a load included; | inferred |
| control transfers resolved in | jump ID, branch EX, trap WB; flushes: mret from ID, fence from WB, fence.tso from WB, fence.i from WB, csr_write_of jvt from WB+1 | pipeline.rst 18-21, 66-96 | stated |
| register file | write before read | no penalty is listed at distance 2 for a load: its value, written in WB, reaches a reader in ID the same cycle, which the WB-to-ID forwarding path or a write-be | inferred |
| penalty: misaligned_target | 1 | pipeline.rst Cycle counts per instruction type | stated |

## 2. Cycle counts per instruction class: the base cost of every instruction

The cycles an instruction of each class takes in its result stage beyond the one every instruction takes (its occupancy), with no hazard and no bus wait; the manual's table "Cycle counts per instruction type" is the source where one is given.

| class | occupancy | instructions | members |
|---|---:|---:|---|
| mul | 0 | 2 | c.mul, mul |
| mulh | 4 | 3 | mulh, mulhsu, mulhu |
| div | default 3 to 35; rule 3 + (clz(rs2) if unsigned or rs2 < 2**31 else clo(rs2) - 1) | 4 | div, divu, rem, remu |
| load | default 1; misaligned 2 | 10 | c.lbu, c.lh, c.lhu, c.lw, c.lwsp, lb, lbu, lh ... |
| store | default 1; misaligned 2 | 7 | c.sb, c.sh, c.sw, c.swsp, sb, sh, sw |
| branch | 0 | 8 | beq, bge, bgeu, blt, bltu, bne, c.beqz, c.bnez |
| tbljmp | default 3; stage ID | 2 | cm.jalt, cm.jt |
| jalr | 0 | 3 | c.jalr, c.jr, jalr |
| jal | 0 | 3 | c.j, c.jal, jal |
| csr_r | default 1 | 3 | csrrc, csrrs, csrrw |
| csr_i | default 1 | 3 | csrrci, csrrsi, csrrwi |
| alu_rr | 0 | 32 | add, and, andn, bclr, bext, binv, bset, c.add ... |
| alu_ri | 0 | 34 | addi, andi, bclri, bexti, binvi, bseti, c.addi, c.addi16sp ... |
| alu_nosrc | 0 | 4 | auipc, c.li, c.lui, lui |
| trap | 0 | 4 | c.ebreak, ebreak, ecall, mret |
| system | 0 | 5 | c.nop, fence, fence.i, fence.tso, wfi |

## 3. Three facts of the pipeline the rules below assume

| fact | this core | source | grade |
|---|---|---|---|
| two statements that hold one instruction in one stage | cost the longer of the two, not the sum: one interlock per stage | pipeline.rst's Hazards list gives each stall on its own and says nothing of two holding one instruction; the RTL has one | read |
| a jump held in its resolution stage by a statement of the core (not by its own operand) | still redirects: its target is fetched during the hold and the instruction behind it pays no bubble; an mret or a table jump waits for its CSR read | 'Jumps are taken from the ID stage' (pipeline.rst line 18) says nothing of a jump held there; controller_fsm.sv 301-306: | read |
| an instruction that traps as illegal | reads no register and no CSR before its trap, so no dependency or CSR-order rule holds it | an illegal instruction has no architectural effect but its trap (the privileged specification); cv32e40x_i_decoder.sv 39 | read |

## 4. Hazards: the stalls between instructions, derived and documented

A hazard is two instructions within the pipeline's depth that touch the same register, CSR or control.  The rows derived from the structure (section 1) are the manual's rules read through the ISA layer: a dependent instruction at distance d waits until the producer's result is where the reader reads it, the forwarding paths shortening the wait.  The rows the core states on its own are those the structure does not derive; each carries its cause in ISA terms and the width of its trigger against that cause.  Conditions: the zero-wait bus of the manual's cycle table (pipeline.rst 30-31).

### 4.1 Derived from the structure

| kind | subject classes | port | producer class | variant | d=1 | d=2 | d=3 | no distance |
|---|---|---|---|---|---|---|---|---|
| ctrl | any, cm.jt | - | - | - | - | - | - | none |
| ctrl | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, tbljmp, trap | - | branch | - | bubble 2 / squash 0 | bubble 0 / squash 0 | bubble 0 / squash 0 | - |
| ctrl | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, tbljmp, trap | - | jal | - | bubble 1 / squash 0 | bubble 0 / squash 0 | bubble 0 / squash 0 | - |
| ctrl | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, tbljmp, trap | - | jalr | - | bubble 1 / squash 0 | bubble 0 / squash 0 | bubble 0 / squash 0 | - |
| ctrl | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, tbljmp, trap | - | tbljmp | - | bubble 1 / squash 0 | bubble 0 / squash 0 | bubble 0 / squash 0 | - |
| ctrl | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, tbljmp, trap | - | trap | - | bubble 3 / squash 0 | bubble 0 / squash 0 | bubble 0 / squash 0 | - |
| raw | load, store | addr | alu_nosrc | - | forward 0 | forward 0 | none | - |
| raw | load | addr | alu_nosrc | same_reg | forward 0 | forward 0 | none | - |
| raw | load, store | addr | alu_nosrc | x0 | none | none | none | - |
| raw | load, store | addr | alu_ri | - | forward 0 | forward 0 | none | - |
| raw | load | addr | alu_ri | same_reg | forward 0 | forward 0 | none | - |
| raw | load, store | addr | alu_ri | x0 | none | none | none | - |
| raw | load, store | addr | alu_rr | - | forward 0 | forward 0 | none | - |
| raw | load | addr | alu_rr | same_reg | forward 0 | forward 0 | none | - |
| raw | load, store | addr | alu_rr | x0 | none | none | none | - |
| raw | load, store | addr | csr_i | - | forward 0 | forward 0 | none | - |
| raw | load | addr | csr_i | same_reg | forward 0 | forward 0 | none | - |
| raw | load, store | addr | csr_i | x0 | none | none | none | - |
| raw | load, store | addr | csr_r | - | forward 0 | forward 0 | none | - |
| raw | load | addr | csr_r | same_reg | forward 0 | forward 0 | none | - |
| raw | load, store | addr | csr_r | x0 | none | none | none | - |
| raw | load, store | addr | div | - | forward 0 | forward 0 | none | - |
| raw | load | addr | div | same_reg | forward 0 | forward 0 | none | - |
| raw | load, store | addr | div | x0 | none | none | none | - |
| raw | load, store | addr | jal | - | forward 0 | forward 0 | none | - |
| raw | load | addr | jal | same_reg | forward 0 | forward 0 | none | - |
| raw | load, store | addr | jal | x0 | none | none | none | - |
| raw | load, store | addr | jalr | - | forward 0 | forward 0 | none | - |
| raw | load | addr | jalr | same_reg | forward 0 | forward 0 | none | - |
| raw | load, store | addr | jalr | x0 | none | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, mul, mulh, tbljmp | addr | load | - | forward 0 | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, tbljmp | addr | load | x0 | none | none | none | - |
| raw | load, store | addr | load | - | stall 1 | forward 0 | none | - |
| raw | load | addr | load | same_reg | stall 1 | forward 0 | none | - |
| raw | load, store | addr | mul | - | forward 0 | forward 0 | none | - |
| raw | load | addr | mul | same_reg | forward 0 | forward 0 | none | - |
| raw | load, store | addr | mul | x0 | none | none | none | - |
| raw | load, store | addr | mulh | - | forward 0 | forward 0 | none | - |
| raw | load | addr | mulh | same_reg | forward 0 | forward 0 | none | - |
| raw | load, store | addr | mulh | x0 | none | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, mul, mulh, tbljmp | addr | store | - | forward 0 | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | addr | store | x0 | none | none | none | - |
| raw | load | addr | store | - | stall 1 | forward 0 | none | - |
| raw | load, store | addr | tbljmp | - | forward 0 | forward 0 | none | - |
| raw | load | addr | tbljmp | same_reg | forward 0 | forward 0 | none | - |
| raw | load, store | addr | tbljmp | x0 | none | none | none | - |
| raw | csr | after | - | - | stall 1 | - | - | - |
| raw | cm.jt | behind | - | - | - | - | - | none |
| raw | branch | cmp1 | alu_nosrc | - | forward 0 | forward 0 | none | - |
| raw | branch | cmp1 | alu_nosrc | x0 | none | none | none | - |
| raw | branch | cmp1 | alu_ri | - | forward 0 | forward 0 | none | - |
| raw | branch | cmp1 | alu_ri | x0 | none | none | none | - |
| raw | branch | cmp1 | alu_rr | - | forward 0 | forward 0 | none | - |
| raw | branch | cmp1 | alu_rr | x0 | none | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, mul, mulh, tbljmp | cmp1 | branch | - | forward 0 | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | cmp1 | branch | x0 | none | none | none | - |
| raw | load | cmp1 | branch | - | stall 1 | forward 0 | none | - |
| raw | branch | cmp1 | csr_i | - | forward 0 | forward 0 | none | - |
| raw | branch | cmp1 | csr_i | x0 | none | none | none | - |
| raw | branch | cmp1 | csr_r | - | forward 0 | forward 0 | none | - |
| raw | branch | cmp1 | csr_r | x0 | none | none | none | - |
| raw | branch | cmp1 | div | - | forward 0 | forward 0 | none | - |
| raw | branch | cmp1 | div | x0 | none | none | none | - |
| raw | branch | cmp1 | jal | - | forward 0 | forward 0 | none | - |
| raw | branch | cmp1 | jal | x0 | none | none | none | - |
| raw | branch | cmp1 | jalr | - | forward 0 | forward 0 | none | - |
| raw | branch | cmp1 | jalr | x0 | none | none | none | - |
| raw | branch | cmp1 | load | - | stall 1 | forward 0 | none | - |
| raw | branch | cmp1 | load | x0 | none | none | none | - |
| raw | branch | cmp1 | mul | - | forward 0 | forward 0 | none | - |
| raw | branch | cmp1 | mul | x0 | none | none | none | - |
| raw | branch | cmp1 | mulh | - | forward 0 | forward 0 | none | - |
| raw | branch | cmp1 | mulh | x0 | none | none | none | - |
| raw | branch | cmp1 | tbljmp | - | forward 0 | forward 0 | none | - |
| raw | branch | cmp1 | tbljmp | x0 | none | none | none | - |
| raw | branch | cmp2 | alu_nosrc | - | forward 0 | forward 0 | none | - |
| raw | branch | cmp2 | alu_nosrc | x0 | none | none | none | - |
| raw | branch | cmp2 | alu_ri | - | forward 0 | forward 0 | none | - |
| raw | branch | cmp2 | alu_ri | x0 | none | none | none | - |
| raw | branch | cmp2 | alu_rr | - | forward 0 | forward 0 | none | - |
| raw | branch | cmp2 | alu_rr | x0 | none | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, mul, mulh, tbljmp | cmp2 | branch | - | forward 0 | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | cmp2 | branch | x0 | none | none | none | - |
| raw | load | cmp2 | branch | - | stall 1 | forward 0 | none | - |
| raw | branch | cmp2 | csr_i | - | forward 0 | forward 0 | none | - |
| raw | branch | cmp2 | csr_i | x0 | none | none | none | - |
| raw | branch | cmp2 | csr_r | - | forward 0 | forward 0 | none | - |
| raw | branch | cmp2 | csr_r | x0 | none | none | none | - |
| raw | branch | cmp2 | div | - | forward 0 | forward 0 | none | - |
| raw | branch | cmp2 | div | x0 | none | none | none | - |
| raw | branch | cmp2 | jal | - | forward 0 | forward 0 | none | - |
| raw | branch | cmp2 | jal | x0 | none | none | none | - |
| raw | branch | cmp2 | jalr | - | forward 0 | forward 0 | none | - |
| raw | branch | cmp2 | jalr | x0 | none | none | none | - |
| raw | branch | cmp2 | load | - | stall 1 | forward 0 | none | - |
| raw | branch | cmp2 | load | x0 | none | none | none | - |
| raw | branch | cmp2 | mul | - | forward 0 | forward 0 | none | - |
| raw | branch | cmp2 | mul | x0 | none | none | none | - |
| raw | branch | cmp2 | mulh | - | forward 0 | forward 0 | none | - |
| raw | branch | cmp2 | mulh | x0 | none | none | none | - |
| raw | branch | cmp2 | tbljmp | - | forward 0 | forward 0 | none | - |
| raw | branch | cmp2 | tbljmp | x0 | none | none | none | - |
| raw | csr | counter | - | - | stall 1 | - | - | - |
| raw | csr_i, csr_r | csr | csr_i | - | stall 1 | none | none | - |
| raw | trap | csr | csr_i | - | none | none | none | - |
| raw | csr_i, csr_r | csr | csr_r | - | stall 1 | none | none | - |
| raw | trap | csr | csr_r | - | none | none | none | - |
| raw | csr_i, csr_r, trap | csr | trap | - | none | none | none | - |
| raw | store | data | alu_nosrc | - | forward 0 | forward 0 | none | - |
| raw | store | data | alu_nosrc | x0 | none | none | none | - |
| raw | store | data | alu_ri | - | forward 0 | forward 0 | none | - |
| raw | store | data | alu_ri | x0 | none | none | none | - |
| raw | store | data | alu_rr | - | forward 0 | forward 0 | none | - |
| raw | store | data | alu_rr | x0 | none | none | none | - |
| raw | store | data | csr_i | - | forward 0 | forward 0 | none | - |
| raw | store | data | csr_i | x0 | none | none | none | - |
| raw | store | data | csr_r | - | forward 0 | forward 0 | none | - |
| raw | store | data | csr_r | x0 | none | none | none | - |
| raw | store | data | div | - | forward 0 | forward 0 | none | - |
| raw | store | data | div | x0 | none | none | none | - |
| raw | store | data | jal | - | forward 0 | forward 0 | none | - |
| raw | store | data | jal | x0 | none | none | none | - |
| raw | store | data | jalr | - | forward 0 | forward 0 | none | - |
| raw | store | data | jalr | x0 | none | none | none | - |
| raw | store | data | load | - | stall 1 | forward 0 | none | - |
| raw | store | data | load | x0 | none | none | none | - |
| raw | store | data | mul | - | forward 0 | forward 0 | none | - |
| raw | store | data | mul | x0 | none | none | none | - |
| raw | store | data | mulh | - | forward 0 | forward 0 | none | - |
| raw | store | data | mulh | x0 | none | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, mul, mulh, tbljmp | data | store | - | forward 0 | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | data | store | x0 | none | none | none | - |
| raw | load | data | store | - | stall 1 | forward 0 | none | - |
| raw | store | data | tbljmp | - | forward 0 | forward 0 | none | - |
| raw | store | data | tbljmp | x0 | none | none | none | - |
| raw | any | enable | - | - | stall 1 | - | - | - |
| raw | mret | implicit | - | - | stall 2 | stall 1 | - | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | alu_nosrc | - | forward 0 | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | alu_nosrc | same_reg | forward 0 | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | alu_nosrc | x0 | none | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, mul, mulh, tbljmp | rs1 | alu_ri | - | forward 0 | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | rs1 | alu_ri | x0 | none | none | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | alu_ri | same_reg | forward 0 | forward 0 | none | - |
| raw | load | rs1 | alu_ri | - | stall 1 | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, mul, mulh, tbljmp | rs1 | alu_rr | - | forward 0 | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | rs1 | alu_rr | x0 | none | none | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | alu_rr | same_reg | forward 0 | forward 0 | none | - |
| raw | load | rs1 | alu_rr | - | stall 1 | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | csr_i | - | forward 0 | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | csr_i | same_reg | forward 0 | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | csr_i | x0 | none | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, mul, mulh, tbljmp | rs1 | csr_r | - | forward 0 | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | rs1 | csr_r | x0 | none | none | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | csr_r | same_reg | forward 0 | forward 0 | none | - |
| raw | load | rs1 | csr_r | - | stall 1 | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, mul, mulh, tbljmp | rs1 | div | - | forward 0 | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | rs1 | div | x0 | none | none | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | div | same_reg | forward 0 | forward 0 | none | - |
| raw | load | rs1 | div | - | stall 1 | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | jal | - | forward 0 | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | jal | same_reg | forward 0 | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | jal | x0 | none | none | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | jalr | - | forward 0 | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | jalr | same_reg | forward 0 | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | jalr | x0 | none | none | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | load | - | stall 1 | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | load | same_reg | stall 1 | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | load | x0 | none | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, mul, mulh, tbljmp | rs1 | mul | - | forward 0 | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | rs1 | mul | x0 | none | none | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | mul | same_reg | forward 0 | forward 0 | none | - |
| raw | load | rs1 | mul | - | stall 1 | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, mul, mulh, tbljmp | rs1 | mulh | - | forward 0 | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | rs1 | mulh | x0 | none | none | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | mulh | same_reg | forward 0 | forward 0 | none | - |
| raw | load | rs1 | mulh | - | stall 1 | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | tbljmp | - | forward 0 | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | tbljmp | same_reg | forward 0 | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | tbljmp | x0 | none | none | none | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | alu_nosrc | - | forward 0 | forward 0 / stall 1 | forward 0 / none / stall 1 | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | alu_ri | - | forward 0 | forward 0 / stall 1 | forward 0 / none / stall 1 | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | alu_rr | - | forward 0 | forward 0 / stall 1 | forward 0 / none / stall 1 | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | csr_i | - | forward 0 | forward 0 / stall 1 | forward 0 / none / stall 1 | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | csr_r | - | forward 0 | forward 0 / stall 1 | forward 0 / none / stall 1 | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | div | - | forward 0 | forward 0 / stall 1 | forward 0 / none / stall 1 | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | jal | - | forward 0 | forward 0 / stall 1 | forward 0 / none / stall 1 | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | jalr | - | forward 0 | forward 0 / stall 1 | forward 0 / none / stall 1 | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | load | - | stall 1 | forward 0 / stall 1 | forward 0 / none / stall 1 | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | mul | - | forward 0 | forward 0 / stall 1 | forward 0 / none / stall 1 | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | mulh | - | forward 0 | forward 0 / stall 1 | forward 0 / none / stall 1 | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | tbljmp | - | forward 0 | forward 0 / stall 1 | forward 0 / none / stall 1 | - |
| raw | alu_rr, div, mul, mulh | rs2 | alu_nosrc | - | forward 0 | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | alu_nosrc | same_reg | forward 0 | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | alu_nosrc | x0 | none | none | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | alu_ri | - | forward 0 | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | alu_ri | same_reg | forward 0 | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | alu_ri | x0 | none | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, mul, mulh, tbljmp | rs2 | alu_rr | - | forward 0 | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | rs2 | alu_rr | x0 | none | none | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | alu_rr | same_reg | forward 0 | forward 0 | none | - |
| raw | load | rs2 | alu_rr | - | stall 1 | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | csr_i | - | forward 0 | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | csr_i | same_reg | forward 0 | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | csr_i | x0 | none | none | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | csr_r | - | forward 0 | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | csr_r | same_reg | forward 0 | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | csr_r | x0 | none | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, mul, mulh, tbljmp | rs2 | div | - | forward 0 | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | rs2 | div | x0 | none | none | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | div | same_reg | forward 0 | forward 0 | none | - |
| raw | load | rs2 | div | - | stall 1 | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | jal | - | forward 0 | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | jal | same_reg | forward 0 | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | jal | x0 | none | none | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | jalr | - | forward 0 | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | jalr | same_reg | forward 0 | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | jalr | x0 | none | none | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | load | - | stall 1 | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | load | same_reg | stall 1 | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | load | x0 | none | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, mul, mulh, tbljmp | rs2 | mul | - | forward 0 | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | rs2 | mul | x0 | none | none | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | mul | same_reg | forward 0 | forward 0 | none | - |
| raw | load | rs2 | mul | - | stall 1 | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, mul, mulh, tbljmp | rs2 | mulh | - | forward 0 | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | rs2 | mulh | x0 | none | none | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | mulh | same_reg | forward 0 | forward 0 | none | - |
| raw | load | rs2 | mulh | - | stall 1 | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | tbljmp | - | forward 0 | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | tbljmp | same_reg | forward 0 | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | tbljmp | x0 | none | none | none | - |
| raw | jalr | target | alu_nosrc | - | stall 1 | forward 0 | none | - |
| raw | jalr | target | alu_nosrc | same_reg | stall 1 | forward 0 | none | - |
| raw | jalr | target | alu_nosrc | x0 | none | none | none | - |
| raw | jalr | target | alu_ri | - | stall 1 | forward 0 | none | - |
| raw | jalr | target | alu_ri | same_reg | stall 1 | forward 0 | none | - |
| raw | jalr | target | alu_ri | x0 | none | none | none | - |
| raw | jalr | target | alu_rr | - | stall 1 | forward 0 | none | - |
| raw | jalr | target | alu_rr | same_reg | stall 1 | forward 0 | none | - |
| raw | jalr | target | alu_rr | x0 | none | none | none | - |
| raw | jalr | target | csr_i | - | stall 1 | forward 0 | none | - |
| raw | jalr | target | csr_i | same_reg | stall 1 | forward 0 | none | - |
| raw | jalr | target | csr_i | x0 | none | none | none | - |
| raw | jalr | target | csr_r | - | stall 1 | forward 0 | none | - |
| raw | jalr | target | csr_r | same_reg | stall 1 | forward 0 | none | - |
| raw | jalr | target | csr_r | x0 | none | none | none | - |
| raw | jalr | target | div | - | stall 1 | forward 0 | none | - |
| raw | jalr | target | div | same_reg | stall 1 | forward 0 | none | - |
| raw | jalr | target | div | x0 | none | none | none | - |
| raw | jalr | target | jal | - | stall 1 | forward 0 | none | - |
| raw | jalr | target | jal | same_reg | stall 1 | forward 0 | none | - |
| raw | jalr | target | jal | x0 | none | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, mul, mulh, tbljmp | target | jalr | - | stall 1 | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | target | jalr | x0 | none | none | none | - |
| raw | jalr | target | jalr | same_reg | stall 1 | forward 0 | none | - |
| raw | load | target | jalr | - | stall 2 | stall 1 | none | - |
| raw | jalr | target | load | - | stall 2 | stall 1 | none | - |
| raw | jalr | target | load | same_reg | stall 2 | stall 1 | none | - |
| raw | jalr | target | load | x0 | none | none | none | - |
| raw | jalr | target | mul | - | stall 1 | forward 0 | none | - |
| raw | jalr | target | mul | same_reg | stall 1 | forward 0 | none | - |
| raw | jalr | target | mul | x0 | none | none | none | - |
| raw | jalr | target | mulh | - | stall 1 | forward 0 | none | - |
| raw | jalr | target | mulh | same_reg | stall 1 | forward 0 | none | - |
| raw | jalr | target | mulh | x0 | none | none | none | - |
| raw | jalr | target | tbljmp | - | stall 1 | forward 0 | none | - |
| raw | jalr | target | tbljmp | same_reg | stall 1 | forward 0 | none | - |
| raw | jalr | target | tbljmp | x0 | none | none | none | - |
| raw | any | use | - | - | - | - | - | none |
| struct | any | - | - | - | - | - | - | none |
| struct | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, tbljmp, trap | - | div | - | occupied 35 | occupied 35 | occupied 35 | - |
| struct | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, tbljmp, trap | - | mulh | - | occupied 4 | occupied 4 | occupied 4 | - |
| war | load, store | addr | alu_nosrc | - | none | none | none | - |
| war | load, store | addr | alu_ri | - | none | none | none | - |
| war | load, store | addr | alu_rr | - | none | none | none | - |
| war | load, store | addr | csr_i | - | none | none | none | - |
| war | load, store | addr | csr_r | - | none | none | none | - |
| war | load, store | addr | div | - | none | none | none | - |
| war | load, store | addr | jal | - | none | none | none | - |
| war | load, store | addr | jalr | - | none | none | none | - |
| war | load, store | addr | load | - | none | none | none | - |
| war | load, store | addr | mul | - | none | none | none | - |
| war | load, store | addr | mulh | - | none | none | none | - |
| war | load, store | addr | tbljmp | - | none | none | none | - |
| war | branch | cmp1 | alu_nosrc | - | none | none | none | - |
| war | branch | cmp1 | alu_ri | - | none | none | none | - |
| war | branch | cmp1 | alu_rr | - | none | none | none | - |
| war | branch | cmp1 | csr_i | - | none | none | none | - |
| war | branch | cmp1 | csr_r | - | none | none | none | - |
| war | branch | cmp1 | div | - | none | none | none | - |
| war | branch | cmp1 | jal | - | none | none | none | - |
| war | branch | cmp1 | jalr | - | none | none | none | - |
| war | branch | cmp1 | load | - | none | none | none | - |
| war | branch | cmp1 | mul | - | none | none | none | - |
| war | branch | cmp1 | mulh | - | none | none | none | - |
| war | branch | cmp1 | tbljmp | - | none | none | none | - |
| war | branch | cmp2 | alu_nosrc | - | none | none | none | - |
| war | branch | cmp2 | alu_ri | - | none | none | none | - |
| war | branch | cmp2 | alu_rr | - | none | none | none | - |
| war | branch | cmp2 | csr_i | - | none | none | none | - |
| war | branch | cmp2 | csr_r | - | none | none | none | - |
| war | branch | cmp2 | div | - | none | none | none | - |
| war | branch | cmp2 | jal | - | none | none | none | - |
| war | branch | cmp2 | jalr | - | none | none | none | - |
| war | branch | cmp2 | load | - | none | none | none | - |
| war | branch | cmp2 | mul | - | none | none | none | - |
| war | branch | cmp2 | mulh | - | none | none | none | - |
| war | branch | cmp2 | tbljmp | - | none | none | none | - |
| war | store | data | alu_nosrc | - | none | none | none | - |
| war | store | data | alu_ri | - | none | none | none | - |
| war | store | data | alu_rr | - | none | none | none | - |
| war | store | data | csr_i | - | none | none | none | - |
| war | store | data | csr_r | - | none | none | none | - |
| war | store | data | div | - | none | none | none | - |
| war | store | data | jal | - | none | none | none | - |
| war | store | data | jalr | - | none | none | none | - |
| war | store | data | load | - | none | none | none | - |
| war | store | data | mul | - | none | none | none | - |
| war | store | data | mulh | - | none | none | none | - |
| war | store | data | tbljmp | - | none | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | rd | alu_ri | - | none | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | rd | alu_rr | - | none | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | rd | branch | - | none | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | rd | csr_r | - | none | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | rd | div | - | none | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | rd | jalr | - | none | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | rd | load | - | none | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | rd | mul | - | none | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | rd | mulh | - | none | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | rd | store | - | none | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | alu_nosrc | - | none | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | alu_ri | - | none | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | alu_rr | - | none | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | csr_i | - | none | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | csr_r | - | none | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | div | - | none | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | jal | - | none | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | jalr | - | none | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | load | - | none | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | mul | - | none | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | mulh | - | none | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | tbljmp | - | none | none | none | - |
| war | alu_rr, div, mul, mulh | rs2 | alu_nosrc | - | none | none | none | - |
| war | alu_rr, div, mul, mulh | rs2 | alu_ri | - | none | none | none | - |
| war | alu_rr, div, mul, mulh | rs2 | alu_rr | - | none | none | none | - |
| war | alu_rr, div, mul, mulh | rs2 | csr_i | - | none | none | none | - |
| war | alu_rr, div, mul, mulh | rs2 | csr_r | - | none | none | none | - |
| war | alu_rr, div, mul, mulh | rs2 | div | - | none | none | none | - |
| war | alu_rr, div, mul, mulh | rs2 | jal | - | none | none | none | - |
| war | alu_rr, div, mul, mulh | rs2 | jalr | - | none | none | none | - |
| war | alu_rr, div, mul, mulh | rs2 | load | - | none | none | none | - |
| war | alu_rr, div, mul, mulh | rs2 | mul | - | none | none | none | - |
| war | alu_rr, div, mul, mulh | rs2 | mulh | - | none | none | none | - |
| war | alu_rr, div, mul, mulh | rs2 | tbljmp | - | none | none | none | - |
| war | jalr | target | alu_nosrc | - | none | none | none | - |
| war | jalr | target | alu_ri | - | none | none | none | - |
| war | jalr | target | alu_rr | - | none | none | none | - |
| war | jalr | target | csr_i | - | none | none | none | - |
| war | jalr | target | csr_r | - | none | none | none | - |
| war | jalr | target | div | - | none | none | none | - |
| war | jalr | target | jal | - | none | none | none | - |
| war | jalr | target | jalr | - | none | none | none | - |
| war | jalr | target | load | - | none | none | none | - |
| war | jalr | target | mul | - | none | none | none | - |
| war | jalr | target | mulh | - | none | none | none | - |
| war | jalr | target | tbljmp | - | none | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | first | alu_nosrc | - | ordered 0 | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | first | alu_ri | - | ordered 0 | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | first | alu_rr | - | ordered 0 | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | first | csr_i | - | ordered 0 | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | first | csr_r | - | ordered 0 | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | first | div | - | ordered 0 | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | first | jal | - | ordered 0 | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | first | jalr | - | ordered 0 | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | first | load | - | ordered 0 | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | first | mul | - | ordered 0 | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | first | mulh | - | ordered 0 | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | first | tbljmp | - | ordered 0 | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | last | alu_nosrc | - | ordered 0 | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | last | alu_nosrc | x0 | none | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | last | alu_ri | - | ordered 0 | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | last | alu_ri | x0 | none | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | last | alu_rr | - | ordered 0 | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | last | alu_rr | x0 | none | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | last | csr_i | - | ordered 0 | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | last | csr_i | x0 | none | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | last | csr_r | - | ordered 0 | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | last | csr_r | x0 | none | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | last | div | - | ordered 0 | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | last | div | x0 | none | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | last | jal | - | ordered 0 | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | last | jal | x0 | none | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | last | jalr | - | ordered 0 | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | last | jalr | x0 | none | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | last | load | - | ordered 0 | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | last | load | x0 | none | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | last | mul | - | ordered 0 | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | last | mul | x0 | none | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | last | mulh | - | ordered 0 | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | last | mulh | x0 | none | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | last | tbljmp | - | ordered 0 | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, tbljmp | last | tbljmp | x0 | none | none | none | - |

9,395 cases in all, one per subject class, port, producer class and distance; rows identical across subject classes are shown once.  Kinds: raw (a read after a write), war, waw, ctrl (a control transfer ahead), struct (a resource).  Words: "stall n", the reader waits n cycles; "forward 0", the value is forwarded and nothing waits; "bubble n", the fetch after a taken control transfer; "squash 0", an instruction on the wrong path, killed; two words in one cell are the two outcomes (taken / not taken); "none", no cost.

### 4.2 The manual's hazard statements, checked against the structure

| statement (rows) | the manual says | source | grade |
|---|---|---|---|
| raw_rs1_load_d1,, raw_rs2_load_d1,, raw_addr_load_d1,, raw_data_load_d1,, raw_cmp1_load_d1,, raw_cmp2_load_d1 | stall 1 | pipeline.rst Hazards 116 | stated |
| raw_target_load_d1 | stall 2 | pipeline.rst Hazards 125 | stated |
| raw_target_alu_*_d1 | stall 1 | pipeline.rst Hazards 117 | stated |
| raw_target_csr_*_d1 | stall 1 | pipeline.rst Hazards 117 | stated |
| raw_target_mul*_d1 | stall 1 | pipeline.rst Hazards 117 | stated |
| raw_target_div_d1 | stall 1 | pipeline.rst Hazards 117 | stated |
| raw_target_jal*_d1 | stall 1 | pipeline.rst Hazards 117 | confirmed |
| raw_rs1_*_d2,, raw_rs2_*_d2,, raw_addr_*_d2,, raw_data_*_d2,, raw_cmp1_*_d2,, raw_cmp2_*_d2 | forward | pipeline.rst Hazards 114-126 | confirmed |
| ctrl_taken_branch_d1 | bubble 2 | pipeline.rst 81-84 Cycle counts per instruction type | stated |
| ctrl_taken_jal_d1 | bubble 1 | pipeline.rst 66-70 Cycle counts per instruction type | stated |
| ctrl_taken_jalr_d1 | bubble 1 | pipeline.rst 66-70 Cycle counts per instruction type | stated |

### 4.3 Statements of the core's own

What the structure does not derive: each row fires on the trace by its match rule and is applied as a hold.  Width: equal (the trigger is its cause: intent), wider (an interlock firing without its cause: a performance finding), narrower (a cause with no stall), unexplained.

| id | fires when | cost | held in | grade | cause | width | source | evidence |
|---|---|---|---|---|---|---|---|---|
| csr_r/raw_csr_csr_*_d1, csr_i/raw_csr_csr_*_d1 | the expanded cases csr_r/raw_csr_csr_*_d1, csr_i/raw_csr_csr_*_d1 | stall 1 | EX | confirmed | - | - | pipeline.rst Hazards 121 | the single-hazard suite on cv32e40x, 24 Sep 2026 (run, 244 tests, 2,268,792 intervals): 118 fired, 0 disagree |
| trap/raw_csr_*_d1 | the expanded cases trap/raw_csr_*_d1 | none | EX | inferred | - | - | pipeline.rst Hazards 119 | the manual names neither the instructions that read a CSR implicitly in EX nor those with an implicit CSR access in WB; on the RTL (the single-hazard suite on cv32e40x, 24 Sep 2026 (run, 244 tests, 2,268,792 intervals)) an ecall or an mret 1 after a CSR write, and an ecall 1 after an mret, cost the flush alone -- a trap or an mret resolves before the next instruction reads, so the pair cannot overlap; t... |
| csr_r/raw_csr_trap_d1, csr_i/raw_csr_trap_d1 | the expanded cases csr_r/raw_csr_trap_d1, csr_i/raw_csr_trap_d1 | none | EX | inferred | - | - | pipeline.rst Hazards 120 | the manual does not name the instructions causing an implicit CSR write; on the RTL (the single-hazard suite on cv32e40x, 24 Sep 2026 (run, 244 tests, 2,268,792 intervals)) a CSR read of mstatus 1 after an mret (4 tests) cost the mret's flush alone (RTL +2, the row's stall would make +3): mret resolves in ID, so the CSR read cannot be in EX while the mret is in WB.  The row's writer is not mret nor a tr... |
| csr_counter_read_d1 | an access of mcycle, mcycleh, minstret, minstreth, mhpmcounter3, mhpmcounter3h, mhpmcounter4, mhpmcounter4h, mhpmcounter31, mhpmcounter31h, cycle, cycleh, instret, instreth, hpmcounter3, hpmcounter3h, hpmcounter4, hpmcounter31 1 behind alu_rr or alu_ri or alu_nosrc or mul or mulh or div or load or store or csr_r or csr_i | stall 1 | - | confirmed | a counter read racing the update every retiring instruction makes in WB | wider | pipeline.rst Hazards 114-126 | found by the Dhrystone work: a scratch program timed with csrrs mcycle showed RTL 2 against our model's 1; the hazard suites never read a counter (its value differs between Spike and the RTL), so they never saw it; the finding is in the pipeline model |
| csr_implicit_mret_d1 | mret or cm.jt or cm.jalt 1 behind csr_r or csr_i | stall 2 | ID | confirmed | mret's implicit read of mstatus and mepc in ID racing a CSR write in EX | wider | pipeline.rst Hazards 126 | the single-hazard suite on cv32e40x, 24 Sep 2026 (run, 244 tests, 2,268,792 intervals): 2 mret tests behind a CSR write of mscratch at d1, RTL +2 as stated; the mstatus ones fired the pattern id and agreed |
| csr_implicit_mret_d2 | mret or cm.jt or cm.jalt 2 behind csr_r or csr_i | stall 1 | ID | confirmed | mret's implicit read of mstatus and mepc in ID racing a CSR write in WB | wider | pipeline.rst Hazards 118 | the single-hazard suite on cv32e40x, 24 Sep 2026 (run, 244 tests, 2,268,792 intervals): RTL +1 behind a CSR write of mscratch at d2, as stated |
| irq_enable_lsu_d1 | load or store 1 behind a write of mstatus, mie | stall 1 | EX | confirmed | an interrupt the write may enable must be taken before the LSU issues a request it cannot abandon | wider | pipeline.rst Hazards 114-126 | found by the RTL pass (the RTL questions: irq_enable_stall), measured by the blocks generated from the question's match rule; the finding irq-enable-stall |
| csr_after_tselect_d1 | csr_r or csr_i 1 behind an access of tselect | stall 1 | EX | inferred | an implicit CSR write by the earlier instruction, still in WB, that the CSR instruction in EX could read stale | wider | rtl/cv32e40x_controller_bypass.sv 256-267 `csr_impl_write_in_wb` | found by the RTL pass (the RTL questions csr_after_tselect_d1, 4 Oct 2026), matchable since tselect is a CSR a rule may name (19 Oct 2026), measured by the blocks generated from the question's match rule (own-cv32e40x-00: 2 of 2 differ, RTL +1 each); the finding tselect-access-stall: a read pays, so the trigger is the address, wider than its cause |

## 5. The memory side: the bus, the write buffer, misaligned and atomic accesses

Conditions: the bus schedule a test names.  The manual's cycle table is the special case of every request accepted at once and answered the next cycle.

| the memory side | this core | source | grade |
|---|---|---|---|
| bus | obi-1.2 | OBI 1.2 | stated |
| data: outstanding | 2 | load_store_unit.rst 74-75, 142-160 | stated |
| data: write_buffer | 1 | load_store_unit.rst 74-75, 142-160 | stated |
| data: wait_stage | EX | load_store_unit.rst 74-75, 142-160 | stated |
| data: response_stage | WB | load_store_unit.rst 74-75, 142-160 | stated |
| data: address_phase | 1 | not stated: the manual's protocol section says when a grant may come and when a response may, not when the next request may be presented; th | inferred |
| data: slot_free_lag | 1 | not stated: 'up to two outstanding transactions', nothing about the cycle a completed one stops counting; the RTL's counter (cnt_q) is a reg | inferred |
| data: response_spacing | 1 | the protocol's in-order rule (load_store_unit.rst 93-95) with one response phase per cycle: a response due no later than the previous one wa | inferred |
| data: forward_lag | 0 | not stated: the load data hazard row charges the instruction immediately behind a load only; the RTL forwards a load's data from the cycle i | inferred |
| data: response_wait_freeze | yes | not stated: the RTL's ready chain (ex_stage.sv 469-472: 'The late (data_rvalid_i based) downstream wb_ready_i signal fans into the ready sig | inferred |
| data: fence_drain | response | load_store_unit.rst 155-158 says the write buffer's transactions must be completed before a fence or fence.i retires, not whether completed  | inferred |
| data: wbuf_needs_slot | yes | load_store_unit.rst 142-160 says the write buffer, when not full, lets the core proceed without waiting for a bufferable transfer's grant or | inferred |
| data: atomic_serial | yes | load_store_unit.rst 164-170 says only that the core supports exclusive and atomic transactions with an external adapter, nothing on their ti | inferred |
| fetch | outstanding 2; buffer_words 3 | instruction_fetch.rst 16-18, 70 | stated |
| regions |  | pma.rst 68-70 | stated |
| misaligned | split | load_store_unit.rst 51-66 | stated |

## 6. CSRs and counters: the accesses that wait

Which CSR accesses wait, on what, and for how long.  A CSR instruction reads and writes its CSR in the stages the structure names; the rows here are the core's own statements about CSR order, the counters every retirement updates, and the CSRs with implicit accesses.

| rule | fires when | cost | grade |
|---|---|---|---|
| the counters every retirement writes implicitly | cycle, cycleh, hpmcounter10, hpmcounter10h, hpmcounter11, hpmcounter11h, hpmcounter12, hpmcounter12h, hpmcounter13, hpmcounter13h, hpmcounter14, hpmcounter14h, hpmcounter15, hpmcounter15h, hpmcounter16, hpmcounter16h, hpmcounter17, hpmcounter17h, hpmcounter18, hpmcounter18h, hpmcounter19, hpmcounter19h, hpmcounter20, hpmcounter20h, hpmcounter21, hpmcounter21h, hpmcounter22, hpmcounter22h, hpmcounter23, hpmcounter23h, hpmcounter24, hpmcounter24h, hpmcounter25, hpmcounter25h, hpmcounter26, hpmcounter26h, hpmcounter27, hpmcounter27h, hpmcounter28, hpmcounter28h, hpmcounter29, hpmcounter29h, hpmcounter3, hpmcounter30, hpmcounter30h, hpmcounter31, hpmcounter31h, hpmcounter3h, hpmcounter4, hpmcounter4h, hpmcounter5, hpmcounter5h, hpmcounter6, hpmcounter6h, hpmcounter7, hpmcounter7h, hpmcounter8, hpmcounter8h, hpmcounter9, hpmcounter9h, instret, instreth, mcycle, mcycleh, mhpmcounter10, mhpmcounter10h, mhpmcounter11, mhpmcounter11h, mhpmcounter12, mhpmcounter12h, mhpmcounter13, mhpmcounter13h, mhpmcounter14, mhpmcounter14h, mhpmcounter15, mhpmcounter15h, mhpmcounter16, mhpmcounter16h, mhpmcounter17, mhpmcounter17h, mhpmcounter18, mhpmcounter18h, mhpmcounter19, mhpmcounter19h, mhpmcounter20, mhpmcounter20h, mhpmcounter21, mhpmcounter21h, mhpmcounter22, mhpmcounter22h, mhpmcounter23, mhpmcounter23h, mhpmcounter24, mhpmcounter24h, mhpmcounter25, mhpmcounter25h, mhpmcounter26, mhpmcounter26h, mhpmcounter27, mhpmcounter27h, mhpmcounter28, mhpmcounter28h, mhpmcounter29, mhpmcounter29h, mhpmcounter3, mhpmcounter30, mhpmcounter30h, mhpmcounter31, mhpmcounter31h, mhpmcounter3h, mhpmcounter4, mhpmcounter4h, mhpmcounter5, mhpmcounter5h, mhpmcounter6, mhpmcounter6h, mhpmcounter7, mhpmcounter7h, mhpmcounter8, mhpmcounter8h, mhpmcounter9, mhpmcounter9h, minstret, minstreth, time, timeh | a CSR instruction that names one waits while any instruction is in the write stage | stated |
| raw_target_csr_*_d1 | raw_target_csr_*_d1 | -, held in - | stated |
| csr_r/raw_csr_csr_*_d1, csr_i/raw_csr_csr_*_d1 | csr_r/raw_csr_csr_*_d1, csr_i/raw_csr_csr_*_d1 | stall 1, held in EX | confirmed |
| trap/raw_csr_*_d1 | trap/raw_csr_*_d1 | none, held in EX | inferred |
| csr_r/raw_csr_trap_d1, csr_i/raw_csr_trap_d1 | csr_r/raw_csr_trap_d1, csr_i/raw_csr_trap_d1 | none, held in EX | inferred |
| csr_counter_read_d1 | an access of mcycle, mcycleh, minstret, minstreth, mhpmcounter3, mhpmcounter3h, mhpmcounter4, mhpmcounter4h, mhpmcounter31, mhpmcounter31h, cycle, cycleh, instret, instreth, hpmcounter3, hpmcounter3h, hpmcounter4, hpmcounter31 1 behind alu_rr or alu_ri or alu_nosrc or mul or mulh or div or load or store or csr_r or csr_i | stall 1, held in - | confirmed |
| csr_implicit_mret_d1 | mret or cm.jt or cm.jalt 1 behind csr_r or csr_i | stall 2, held in ID | confirmed |
| csr_implicit_mret_d2 | mret or cm.jt or cm.jalt 2 behind csr_r or csr_i | stall 1, held in ID | confirmed |
| irq_enable_lsu_d1 | load or store 1 behind a write of mstatus, mie | stall 1, held in EX | confirmed |
| csr_after_tselect_d1 | csr_r or csr_i 1 behind an access of tselect | stall 1, held in EX | inferred |

## 7. Interrupts and other events: when they are taken and what they cost

The manual states no latency and no taking stage for interrupts; every row here is read from the RTL or measured by the event suites (an test device both the reference and the RTL harness implement raises a line at a counted retirement; the phase sweep crosses every instruction's abandonment boundary one cycle at a time).  Grades are read or inferred until authored.

| field | this core | source | grade |
|---|---|---|---|
| device_base | 0x02010000 | exceptions_interrupts.rst 188-200 | stated |
| priority | 1025, 1024, 31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 11, 3, 7 | exceptions_interrupts.rst 188-200 | stated |
| lines.bits | 3, 7, 11, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31 | exceptions_interrupts.rst 149-173 (the pin table), 183-184, 202-203 | stated |
| lines.level | yes | exceptions_interrupts.rst 149-173 (the pin table), 183-184, 202-203 | stated |
| lines.mip | irq_i reflected in mip (bits 16-31 the custom fast interrupts), mie writable for them | exceptions_interrupts.rst 149-173 (the pin table), 183-184, 202-203 | stated |
| lines.cleared | by the handler at the source, a software mechanism (a memory-mapped device write); the core drops nothing | exceptions_interrupts.rst 149-173 (the pin table), 183-184, 202-203 | stated |
| gating.rule | an irq_i line is taken only with mstatus.MIE set and its mie bit set; after reset every interrupt but the NMIs is disabled; in debug mode every interrupt is ignored whatever MIE and mie; the NMIs are never masked by MIE, only by debug mode or single-stepping with dcsr.stepie 0 | exceptions_interrupts.rst 185-187, 104, 205 | stated |
| nmi.causes.1024 | load bus fault | exceptions_interrupts.rst 78-115, 216-232 | stated |
| nmi.causes.1025 | store bus fault | exceptions_interrupts.rst 78-115, 216-232 | stated |
| nmi.trigger | data_err_i with data_rvalid_i on a load (1024) or a store (1025); imprecise | exceptions_interrupts.rst 78-115, 216-232 | stated |
| nmi.imprecise | the faulting access retires; once the NMI is visible at most two more instructions retire before it is taken; a bufferable store's error may become visible an arbitrary time after the store retired; under debugging many instructions may retire first | exceptions_interrupts.rst 78-115, 216-232 | stated |
| nmi.latch | the first fault's cause is latched for mcause; a later fault while an NMI is pending is discarded; new faults may be latched once the handler is entered | exceptions_interrupts.rst 78-115, 216-232 | stated |
| nmi.vector | mtvec's base in non-vectored mode; index 15 ({mtvec[31:7], 5'hF, 2'b00}) in vectored mode, not the code | exceptions_interrupts.rst 78-115, 216-232 | stated |
| nmi.csrs | mepc, mcause and mstatus as for a regular interrupt (mstatus.MIE cleared), mepc not guaranteed to point after the faulting access | exceptions_interrupts.rst 78-115, 216-232 | stated |
| sleep.wfi | enters sleep awaiting a locally enabled interrupt (mie bit set) to become pending, mstatus.MIE ignored; a nop under a debug request, in debug mode, single-stepping or on a trigger match; a wake-up condition coinciding with the wfi: no sleep | sleep.rst | stated |
| sleep.wake | a locally enabled interrupt pending, a debug request pending, debug mode; core_sleep_o drops and execution resumes | sleep.rst | stated |
| sleep.stage | WB | sleep.rst | stated |
| sleep.stage_note | wfi_in_wb: the FSM enters SLEEP with the wfi held in WB (halt_limited_wb) and leaves it on wake_from_sleep (irq_wu_ctrl_i: irq_i & mie, the unregistered line; or a pending NMI or debug request), unhalting WB so the wfi retires (controller_fsm.sv 860-865, 1075-1097; int_controller.sv 70) | sleep.rst | stated |
| sleep.min_cycles | 2 | sleep.rst | stated |
| sleep.min_cycles_note | the wfi spends two cycles in WB even when the line is already up: the SLEEP state is entered and left (pipeline.rst's '2 -' for wfi) | sleep.rst | stated |
| sleep.wake_latency | 1 | sleep.rst | stated |
| sleep.wake_latency_note | the wfi retires 1 cycle after the first cycle irq_i is high (2 after the harness's raise record, which is the cycle the raise is scheduled at), when the rise comes after the wfi reached WB; over the sweep the wfi's interval is max(2, rise + 2 - the SET store's retirement); the csrrsi behind it retires 3 cycles after the wfi (holds_behind) and an interrupt it enables is taken at once (its handler's first retirement 5 cycles after the csrrsi, j = 0) | sleep.rst | stated |
| sleep.holds_behind | ID | sleep.rst | stated |
| sleep.holds_behind_from | EX | sleep.rst | stated |
| sleep.holds_behind_note | while the FSM is in SLEEP, the wake cycle included (halt_id while waking up, EX a bubble), the instruction behind the wfi stays in ID: it retires 3 cycles after the wfi | sleep.rst | stated |
| sleep.wake_latency_source.grade | reading | sleep.rst | stated |
| sleep.wake_latency_source.note | the test hze-wfi-00 (the event suite generator, cp_event_wfi) on the RTL with the event record, 17 Oct 2026: phases 0..8, the wfi's interval 2 2 2 3 4 5 6 7 8 cycles after the SET store's retirement; the manual's 'not stated' kept above | sleep.rst | stated |
| sleep.wake_latency_manual | not stated | sleep.rst | stated |
| taking.interrupt.rule | irq_i is registered once (irq_q, int_controller); the request is any bit of irq_q & mie with mstatus.MIE (or a privilege below M, not built here); the controller takes it in the cycle it sees the request when allowed: no data request in WB (lsu_interruptible), not the cycle after a load or store was in WB (interrupt_blanking_q), no fence.i handshake, not in debug mode nor single-stepping without stepie, no offloaded instruction in WB, not the cycle after a CSR flush (csr_flush_ack_q: a write of jvt in WB, the only CSR write that flushes), not while a multi-operation instruction's first operation has retired and its last has not (sequence_interruptible: a table jump's pointer fetch), not in SLEEP; then IF, ID, EX and WB are all killed, the pc set to the vector, mcause the id, mepc the oldest valid stage's pc (WB, else EX, else ID, else IF): that instruction is the abandoned one | exceptions_interrupts.rst 188-200 | stated |
| taking.interrupt.abandoned | the oldest in-flight instruction at the taking cycle; what retired in the cycles between the line's rise and the taking (the registered line costs one) is the shift j the comparison tolerates | exceptions_interrupts.rst 188-200 | stated |
| taking.interrupt.registered | 1 | exceptions_interrupts.rst 188-200 | stated |
| taking.interrupt.registered_note | the cycles the registered line costs: the last cycle that retires is the rise + 1, the first that retires nothing the rise + 2, when allowed (our records, 16 Oct 2026: j = max(1, phase) on single-cycle subjects); our model's ev_taking | exceptions_interrupts.rst 188-200 | stated |
| taking.interrupt.blanking.after | load, store | exceptions_interrupts.rst 188-200 | stated |
| taking.interrupt.blanking.cycles | 1 | exceptions_interrupts.rst 188-200 | stated |
| taking.interrupt.blanking.note | interrupt_blanking_q: no taking in the cycle after a load or store was in WB | exceptions_interrupts.rst 188-200 | stated |
| taking.interrupt.blocked_by | data_request_outstanding, fencei_handshake, csr_flush_ack, sequence_in_progress, debug, sleep | exceptions_interrupts.rst 188-200 | stated |
| taking.interrupt.blocked_by_note | the conditions that defer the taking while they hold, in the FSM's terms: data_request_outstanding (lsu_interruptible: a load or store past the wait stage whose response is to come), fencei_handshake (fence.i in progress), csr_flush_ack (the cycle after a write of jvt, the one CSR write that flushes: csr_wr_in_wb_flush = jvt_wr_in_wb, cv32e40x_cs_registers.sv 1545-1548; the finding jvt-write-flush, 19 Oct 2026), debug (debug mode, single-stepping without stepie), sleep (the SLEEP state); our model models data_request_outstanding, sleep and csr_flush_ack and notes the rest; sequence_in_progress | exceptions_interrupts.rst 188-200 | stated |
| taking.interrupt.kills | IF, ID, EX, WB | exceptions_interrupts.rst 188-200 | stated |
| taking.interrupt.kills_note | every stage is killed; mepc is the oldest valid stage's pc (the abandoned one) | exceptions_interrupts.rst 188-200 | stated |
| taking.nmi.rule | nmi_pending_q is set by a bus error on a data response seen in WB (lsu_err_wb) and the NMI taken the next cycle under the same conditions as an interrupt without the blanking, and not in the cycle after waking from sleep to a debug request or an interrupt; the same four kills, the pc set to the NMI vector, mepc the oldest valid stage's pc | rtl/cv32e40x_controller_fsm.sv 418-429, 561-566, 729-745, 1217-1227, 1389-1394, 249-268, 1304-1320 | read |
| taking.nmi.abandoned | the oldest in-flight instruction at the taking cycle, as for an interrupt; the faulting access itself retired (its response carried the error), and up to two more may retire before the taking when their requests are outstanding | rtl/cv32e40x_controller_fsm.sv 418-429, 561-566, 729-745, 1217-1227, 1389-1394, 249-268, 1304-1320 | read |
| taking.nmi.registered | 0 | rtl/cv32e40x_controller_fsm.sv 418-429, 561-566, 729-745, 1217-1227, 1389-1394, 249-268, 1304-1320 | read |
| taking.nmi.registered_note | the error is seen in WB in the cycle the response arrives (the carrier's last cycle, it retires) and nmi_pending_q is set at that edge; the FSM takes it the next cycle when allowed: the last retiring cycle is the carrier's own; our model's ev_taking_nmi  A store the write buffer took retired before its response, so its error comes with the response (the manual's "arbitrary time"): the NMI rises at the response's cycle and is taken the next one | rtl/cv32e40x_controller_fsm.sv 418-429, 561-566, 729-745, 1217-1227, 1389-1394, 249-268, 1304-1320 | read |
| taking.nmi.blanking.after |  | rtl/cv32e40x_controller_fsm.sv 418-429, 561-566, 729-745, 1217-1227, 1389-1394, 249-268, 1304-1320 | read |
| taking.nmi.blanking.cycles | 0 | rtl/cv32e40x_controller_fsm.sv 418-429, 561-566, 729-745, 1217-1227, 1389-1394, 249-268, 1304-1320 | read |
| taking.nmi.blanking.note | interrupt_blanking_q is not in nmi_allowed: no blanked cycle after a load or store | rtl/cv32e40x_controller_fsm.sv 418-429, 561-566, 729-745, 1217-1227, 1389-1394, 249-268, 1304-1320 | read |
| taking.nmi.blocked_by | data_request_outstanding, fencei_handshake, csr_flush_ack, sequence_in_progress, debug, sleep, woke_to_interrupt | rtl/cv32e40x_controller_fsm.sv 418-429, 561-566, 729-745, 1217-1227, 1389-1394, 249-268, 1304-1320 | read |
| taking.nmi.blocked_by_note | the same conditions as an interrupt's (lsu_interruptible, the fence.i handshake, the CSR flush, debug, SLEEP) and woke_to_interrupt (the cycle after waking from sleep to a debug request or an interrupt, woke_to_interrupt_q); our model models the first and sleep (the taking waits for the wake: the wfi retires first) and notes the rest; sequence_in_progress | rtl/cv32e40x_controller_fsm.sv 418-429, 561-566, 729-745, 1217-1227, 1389-1394, 249-268, 1304-1320 | read |
| taking.nmi.kills | IF, ID, EX, WB | rtl/cv32e40x_controller_fsm.sv 418-429, 561-566, 729-745, 1217-1227, 1389-1394, 249-268, 1304-1320 | read |
| taking.nmi.kills_note | every stage is killed; mepc is the oldest valid stage's pc; the NMI vector, not mtvec's base or the cause's slot (index 15 in vectored mode) | rtl/cv32e40x_controller_fsm.sv 418-429, 561-566, 729-745, 1217-1227, 1389-1394, 249-268, 1304-1320 | read |
| latency.interrupt_entry.cycles | 8 |  | read |
| latency.interrupt_entry.from | the cycle irq_i rises to the handler's first retirement; 7 for an armed event, whose rise is on a retirement edge |  | read |
| latency.interrupt_entry.refill | 5 |  | read |
| latency.interrupt_entry.state | the pipeline on nops (the smoke's one state), direct mode, zero-wait memory |  | read |
| latency.interrupt_entry.sweep.what | the SET store the instruction before the subject, the line rising `phase` cycles after the SET's grant; j = main-stream retirements after the SET store before the handler's first; entry = cycles from the SET store's retirement to the handler's first retirement; phases 0..5 (mul, mulh, div 0..11); RTL and our model equal on every cell (the survey 0 differ over 192 blocks) |  | read |
| latency.interrupt_entry.sweep.j.alu_rr alu_ri alu_nosrc branch csr_i csr_r | 1 1 2 3 4 5 |  | read |
| latency.interrupt_entry.sweep.j.load store | 2 2 2 3 4 5 |  | read |
| latency.interrupt_entry.sweep.j.jal jalr | 1 1 1 2 2 4 |  | read |
| latency.interrupt_entry.sweep.j.mulh (9 phases since 16 Oct evening) | 0 0 0 0 1 2 3 4 5 |  | read |
| latency.interrupt_entry.sweep.j.div (40 phases; these operands occupy EX about 24 cycles) | 0 x 25, then 1 2 3 4 5 6 7 8 10 11 12 13 14 15 16 |  | read |
| latency.interrupt_entry.sweep.j_arm._comment | cp_event_arm: the line raised by an ARM acting at the retirement of the instruction before the subject (counted on RVFI, one cycle after WB), no device store ahead of the subject; j counts the subject and what retired behind it before the handler |  | read |
| latency.interrupt_entry.sweep.j_arm.alu_rr alu_ri alu_nosrc branch csr_i csr_r mul | 2 3 4 5 6 7 |  | read |
| latency.interrupt_entry.sweep.j_arm.load store | 2 3 4 5 6 7 |  | read |
| latency.interrupt_entry.sweep.j_arm.jal jalr | 1 2 2 4 4 6 |  | read |
| latency.interrupt_entry.sweep.j_arm.mulh | 0 0 1 2 3 4 5 6 7 |  | read |
| latency.interrupt_entry.sweep.j_arm.div | 0 x 23, then 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 17 18 |  | read |
| latency.interrupt_entry.sweep.entry.every class but load and store | 6 6 7 8 9 10 (mul, mulh, div: on to 16) |  | read |
| latency.interrupt_entry.sweep.entry.load store | 7 7 7 8 9 10 |  | read |
| latency.interrupt_entry.sweep.entry_from_raise | SET: the handler's first retirement 7 cycles after the line's rise counted from the SET store's grant; ARM: 6 after the rise counted from the RVFI retirement the ARM acts at (the same cycle in the core: RVFI retires one cycle after WB) |  | read |
| latency.interrupt_entry.sweep.rule | entry = max(floor, 5 + phase) with floor 6, or 7 behind a load or store subject (its blanking cycle); j = the retirements those cycles allow: max(1, phase) single-cycle, max(2, phase) load or store, fewer behind a jump's bubbles, 0 while a multi-cycle unit holds the subject (it is killed and fetched again) |  | read |
| latency.nmi_entry.cycles | 7 |  | read |
| latency.nmi_entry.from | the erroring request's grant to the handler's first retirement |  | read |
| latency.nmi_entry.refill | 5 |  | read |
| latency.nmi_entry.state | the same |  | read |

## 8. What real programs pay on this core: the cycles lost to stalls, by cause

Measured by the timing survey: every retirement of every trace read as a timing skeleton (our timing-skeleton definition; the window 4 retirements before the subject) over 54,208,445 retirements of the generated suites, the certification tests and the benchmarks.  The manual has no equivalent.

| measure | value |
|---|---|
| cycles per retirement, the programs' single-cost skeletons (90% of their retirements) | 42,356,492 retirements, 52,194,991 cycles: CPI 1.232 (IPC 0.81) |
| real code's shapes no generated suite makes | 2.2% of the programs' retirements (by class) |

The cycles-per-retirement row covers the architecture certification tests and the benchmarks, over the retirements whose timing skeleton has a single cost; the whole-program CPI and IPC per benchmark suite are in the results page beside this document.

What an ideal mechanism would save, as a ceiling and not a design (the profile summary carries the caveats):

| mechanism (the ideal, not a design) | retirements affected | upper bound on cycles saved | of all cycles |
|---|---:|---:|---:|
| a perfect branch prediction: the follower of a taken branch at 1 cycle | 2,633,287 | 5,292,469 | 10.1% |
| jump targets resolved in IF: the follower of a jal or jalr at 1 cycle | 1,514,798 | 1,601,210 | 3.1% |
| no load-use bubble | 777,102 | 777,102 | 1.5% |
| no extra cycle at a pc+2 target | 743,147 | 743,147 | 1.4% |
| a divider with half the steps | 84,687 | 667,450 | 1.3% |

## 9. Where the RTL and the manual differ: the anomalies we found

Each row is a finding: what the manual says, what the RTL measured, the class (intent: the trigger is its cause and the manual is behind; over-wide: an interlock firing without its cause; narrower; function), its cost, and whose it is to act on (the documentation, the RTL, or the core's performance).  The reproducer, the two traces and the run's facts are in the issue directory named.

| finding | for | class | cost | found on | status | issue directory |
|---|---|---|---|---|---|---|
| csr-rows-unnamed | document | intent | none observed: the rows name no instruction this core has; an ecall or mret behind a CSR write pays the flush alone | cv32e40x | clarified; to file | - |
| An mret stalls behind any CSR access, including the CSRs it does not read | performance | over-wide | two cycles on an mret one behind any CSR access and one cycle two behind, mscratch and the other CSRs mret does not read included | cv32e40x | clarified; to file | [issues/csr-mret-rows-class-based/](issues/csr-mret-rows-class-based/) |
| fence.i costs 6 cycles, not the cycle table's 5 | document | intent | one cycle on every fence.i beyond the cycle table's five | cv32e40x | clarified; to file | [issues/fencei-six-cycles/](issues/fencei-six-cycles/) |
| Division by a negative divisor: the cycle count is not the divisor's leading zeros | document | intent | none beyond the document's rule read right: a signed divide by a negative divisor costs 3 plus its leading ones less one | cv32e40x | clarified; to file | [issues/divisor-leading-ones/](issues/divisor-leading-ones/) |
| A jump behind a busy divider resolves at once, its bubble hidden | document | intent | a saving: a jump behind a busy divider pays no bubble of its own, one cycle fewer than the table | cv32e40x | clarified; to file | [issues/jump-behind-divider/](issues/jump-behind-divider/) |
| A counter read costs one cycle more while an instruction is in WB | document | intent | one cycle on every read of a counter while an instruction is in WB | cv32e40x | clarified; to file | [issues/counter-read-stall/](issues/counter-read-stall/) |
| A load or store behind a CSR write of mstatus or mie costs one cycle more | document | intent | one cycle on every load or store right behind a write of mstatus or mie, whatever value the write carries | cv32e40x | clarified; to file | [issues/irq-enable-stall/](issues/irq-enable-stall/) |
| A read of mhpmcounter3h costs one cycle more while an instruction is in WB | document | intent | one cycle on every read of mhpmcounter3h while an instruction is in WB | cv32e40x | clarified; to file | [issues/mhpmcounter3h-read-stall/](issues/mhpmcounter3h-read-stall/) |
| Any CSR instruction naming a counter costs one cycle more while an instruction is in WB | performance | over-wide | one cycle on every CSR instruction that names any counter, machine-level or user alias, implemented or not, reading it or not, while an instruction is in WB | cv32e40x | clarified; to file | [issues/counter-access-stall/](issues/counter-access-stall/) |
| The data bus accepts the next request only the cycle after the previous grant | document | intent | one cycle between consecutive data requests: the next issues the cycle after the previous grant | cv32e40x | clarified; to file | [issues/mem-address-phase/](issues/mem-address-phase/) |
| A response frees its outstanding slot the cycle after it is on the wire | document | intent | one cycle before a third request may issue once two are outstanding: the slot frees the cycle after the response | cv32e40x | clarified; to file | [issues/mem-response-frees-slot/](issues/mem-response-frees-slot/) |
| Responses return in order, at most one per cycle | document | intent | one cycle on a response due with or before the previous one | cv32e40x | clarified; to file | [issues/mem-responses-in-order/](issues/mem-responses-in-order/) |
| A split access requests its second half from WB, the cycle after the first grant | document | intent | a misaligned access pays its second half's grant and response wait from WB, one cycle more than a single access | cv32e40x | clarified; to file | [issues/mem-split-second-half/](issues/mem-split-second-half/) |
| A load's result is not forwarded before its response is on the wire | document | intent | a consumer two or more behind a load waits until the data is on the wire, a jalr one cycle more, instead of the free forward the list gives | cv32e40x | clarified; to file | [issues/mem-late-data-forward/](issues/mem-late-data-forward/) |
| IF and ID freeze while a load or store in WB waits for its response | performance | over-wide | every cycle a load or store in WB waits for its response stalls the whole front: nothing enters EX or ID, occupied or empty | cv32e40x | clarified; to file | [issues/mem-response-wait-freeze/](issues/mem-response-wait-freeze/) |
| A fence behind a buffered store waits for the store's response, then runs its own cycles | document | intent | a fence behind a store the write buffer took waits for the store's response, not its grant, before its own cycles | cv32e40x-pma | clarified; to file | [issues/mem-wbuf-fence-drain/](issues/mem-wbuf-fence-drain/) |
| A split access into I/O issues its legal first half, then faults a cycle later | document | function | - | cv32e40x-pma | clarified; to file | [issues/mem-pma-split-first-half/](issues/mem-pma-split-first-half/) |
| A bufferable store whose grant is withheld, third behind a mulh, stalls one cycle | document | intent | one cycle on a bufferable store when the buffer's transfer holds the last outstanding slot | cv32e40x-pma | clarified; to file | [issues/mem-wbuf-third-store/](issues/mem-wbuf-third-store/) |
| An atomic transaction overlaps no other: a cycle lost on each side of an lr, sc or AMO | performance | over-wide | one cycle on every load, store, sc.w or AMO right behind an sc.w or an AMO, and on an atomic right behind a load or store | cv32e40x-pma-a | clarified; to file | [issues/mem-atomic-serial/](issues/mem-atomic-serial/) |
| A misaligned atomic raises an access fault (5, 7), not a misaligned one (4, 6) | document | function | - | cv32e40x-pma-a | clarified; to file | [issues/mem-atomic-misaligned-cause/](issues/mem-atomic-misaligned-cause/) |
| An interrupt entry's CSR writes (mstatus, mepc, mcause) are not reported on RVFI | rtl | function | - | cv32e40x | open; to file | [issues/rvfi-interrupt-entry-csrs-unreported/](issues/rvfi-interrupt-entry-csrs-unreported/) |
| A bus error's NMI is taken the cycle after the faulting access retires, every stage killed | document | intent | the NMI handler's first retirement 5 cycles after the carrier's (the faulting load or store); the instruction behind the carrier retires before the handler only | cv32e40x | clarified; to file | [issues/nmi-taken-kill/](issues/nmi-taken-kill/) |
| mcause.minhv stays set after an mret restarts a faulted CLIC pointer fetch successfully | rtl | function | - | cv32e40x-clic | open; to file | - |
| jvt write: the table's 4 cycles are a flush of the next instruction | document | intent | five cycles on the instruction after every write of jvt (the write itself retires in one), and the interrupt taking blocked for the cycle after the write's reti | cv32e40x | clarified; to file | [issues/jvt-write-flush/](issues/jvt-write-flush/) |
| a CSR instruction behind any access of tselect waits a cycle | performance | over-wide | one cycle on every CSR instruction one behind any access of tselect, a read included | cv32e40x | clarified; to file | [issues/tselect-access-stall/](issues/tselect-access-stall/) |
| CLIC: an access of mnxti or mscratchcswl behind any CSR instruction waits a cycle | document | intent | one cycle on every access of mnxti or mscratchcswl one behind any CSR instruction, in CLIC mode | cv32e40x-clic | clarified; to file | [issues/clic-implicit-csr-read-stall/](issues/clic-implicit-csr-read-stall/) |
| CLIC: a load or store behind a write of mie does not wait, unlike the CLINT core | document | intent | none: a saving of the cycle the core pays in CLINT mode on a load or store one behind a write of mie | cv32e40x-clic | clarified; to file | [issues/clic-mie-write-no-stall/](issues/clic-mie-write-no-stall/) |
| CLIC: a load or store behind a write of mintthresh waits a cycle | document | intent | one cycle on every load or store one behind a write of mintthresh, in CLIC mode | cv32e40x-clic | clarified; to file | [issues/clic-mintthresh-write-stall/](issues/clic-mintthresh-write-stall/) |
| CLIC: a CSR instruction one behind an mscratchcswl access waits a cycle | performance | over-wide | one cycle on every CSR instruction one behind an mscratchcswl access, in CLIC mode (an interrupt handler prologue does an mscratchcswl and then a CSR access as  | cv32e40x-clic | clarified; to file | [issues/clic-csr-after-implicit-write-stall/](issues/clic-csr-after-implicit-write-stall/) |
| CLIC: a load or store one behind an mcause write waits a cycle | document | intent | one cycle on every load or store one behind an mcause write, in CLIC mode (an interrupt handler that rewrites mcause before saving state pays it) | cv32e40x-clic | clarified; to file | [issues/clic-mcause-write-irq-enable-stall/](issues/clic-mcause-write-irq-enable-stall/) |

## 10. What the base build's rows leave to a configuration, and what no test reaches

Every stall and flush term in the RTL source that the base build's own rows do not state is listed here, with where it is handled.  Of the 28: 16 are stated and tested under a configuration of the core (its part of section 12) or became rows of this specification after the source was read -- not gaps, pointers; 9 no test of ours will reach, each with its reason; 3 await a feature we have not built; and 4 questions the manual leaves open are still open.  A row in 10.2 is a hole in the specification, named rather than hidden.

### 10.1 Specified under a configuration

| term | what it is | where it is stated |
|---|---|---|
| `tbljmp_unqual_id` | csr_stall_id, the table-jump half: a table jump (cm.jt, cm.jalt) in ID reads jvt and waits behind any CSR access in EX or WB, as the mret does.  Built: Zc is a localparam (cv32e40x_core.sv:147, ZC_EXT = 1); the core's ISA has Zca and Zcb only | a key of this specification: control.occupancy_before_result: the table jump's CSR-order stall (the own rows csr_implicit_mret_d1/d2, which name cm.jt and cm.jalt as subjects) composes additively with its pointer fetch: the pipeline model control.occupancy_before_result = after_holds; the questions tbljmp_behind_csr and tbljmp_behind_multicycle hold the readings, answered) |
| `instr_meta.tbljmp` | the table-jump term of jump_in_id (line 302) and its two redirects (lines 1011-1018: the pointer fetch from jvt, then the jump to the pointer), each killing IF | a key of this specification: occupancy.tbljmp: the two redirects are the table jump's own occupancy of 3 in ID (the pointer fetch), the pipeline model occupancy.tbljmp; the jump bubble behind it is the ISA case ctrl_taken_tbljmp_d1) |
| `csr_wr_in_wb_flush_i` | a CSR write of jvt in WB (cv32e40x_cs_registers.sv:1537-1548: csrrw/csrrwi, or a set or clear with a non-zero rs1 field; a pure read does not flush) halts IF, ID and EX for a cycle.  jvt is built (cs_registers.sv:352-354 under ZC_EXT, a localparam at 1) and belongs to Zcmt; the specification carries the document's figure as occupancy.csr_r.jvt and occupancy.csr_i.jvt (see corrections) | a key of this specification: control.flush (the jvt write flush and its acknowledge cycle: the pipeline model control.flush "csr_write_of jvt": "WB+1", exercised by the event sweep and by every generated block with a table jump, whose set-up writes jvt) |
| `csr_flush_ack_q` | the cycle after a jvt write: IF, ID and EX killed, fetch restarted at the instruction after the write (PC_WB_PLUS4) | a key of this specification: control.flush (the jvt write flush and its acknowledge cycle: the pipeline model control.flush "csr_write_of jvt": "WB+1", exercised by the event sweep and by every generated block with a table jump, whose set-up writes jvt) |
| `mnxti_id_stall` | csr_mnxti_read_i is set only under `if (CLIC)` (cv32e40x_cs_registers.sv:426-434); without CLIC an access of mnxti is an illegal instruction | covered on cv32e40x-clic |
| `mnxti_ex_stall` | as mnxti_id_stall: csr_mnxti_read_i is never set | covered on cv32e40x-clic |
| `csr_mnxti_access` | jalr_stall, the mnxti term (line 230): a jalr whose rs1 is the rd of an mnxti access in WB.  csr_mnxti_access is the flopped csr_mnxti_read_i (cv32e40x_ex_stage.sv:407) | covered on cv32e40x-clic |
| `csr_hz_i.impl_re_ex` | csr_stall_ex, term 1 (line 262): an implicit CSR read in EX while any CSR write is in WB -- Hazards 119.  impl_re_ex is set only for mnxti and mscratchcswl, both under `if (CLIC)` (cv32e40x_cs_registers.sv:432, 469).  What this means for the specification's open row is in corrections | covered on cv32e40x-clic |
| `instr_meta.clic_ptr` | the pointer terms of csr_impl_write_in_ex and csr_impl_write_in_wb (clic_ptr, mret_ptr): a CLIC or mret pointer in EX or WB counts as an implicit CSR write for csr_stall_id and csr_stall_ex.  Pointers are fetched only for a CLIC hardware-vectored interrupt or an mret with mcause.minhv set | covered on cv32e40x-clic |
| `csr_hz_o.impl_wr_ex` | the CSR instructions flagged as implicit writers under `if (CLIC)`: an access of mstatus (line 365), mcause (415), mnxti (433), mscratchcswl (470); each would hold a CSR instruction 1 behind it through csr_stall_ex term 2.  The tselect flag (line 487) is not under CLIC: the question csr_after_tselect_d1 | covered on cv32e40x-clic: the implicit writers flagged here are what csr_impl_write_in_wb holds the next CSR access behind: the rows csr_after_mstatus_mcause_access_d1 and csr_after_implicit_write_d1 of the CLIC layer |
| `atomic_stall` | the generate branch no_atomic_stall ties it to 0 | covered on cv32e40x-pma-a: the A configuration: the atomic forms are subjects of the single and scheduled suites there |
| `csr_irq_enable_write_o` | the clic_irq_en branch (line 1553): mintthresh_we and mintstatus_we as sources of irq_enable_stall.  The basic_irq_en branch (line 1555) is built: the questions irq_enable_load_d1, irq_enable_store_d1 | covered on cv32e40x-clic |
| `clic_ptr_in_id` | a CLIC or mret pointer in ID redirects to the fetched pointer and kills IF | covered on cv32e40x-clic |
| `mcause_i.minhv` | an mret with mcause.minhv set restarts a pointer fetch instead of jumping to mepc; mcause has no minhv bit without CLIC (cv32e40x_cs_registers.sv:826-831) | covered on cv32e40x-clic |
| `mpu_status_wb_i` | the two MPU terms of exception_in_wb (an instruction fetched from, or a load or store to, a region the PMA forbids): with no PMA regions (the RTL's default; not in RTL_PARAMS) the whole address space has the default attributes (cv32e40x_pma.sv:63-67) and no access faults.  our records has the regions | covered on cv32e40x-pma: the PMA blocks of the scheduled suite (hzp-pma-00) and the NMI file: a refused fetch, load or store traps as the regions say |
| `align_status_wb_i` | the alignment term of exception_in_wb: the check is enabled only for atomic transfers (cv32e40x_load_store_unit.sv:833) | covered on cv32e40x-pma-a: the alignment check is enabled for atomic transfers only: the A configuration's misaligned atomics trap |

### 10.2 Not reached, and why

| core | what | why | reach | RTL |
|---|---|---|---|---|
| cv32e40x | open question `fencei_ack_wait` | a fence.i in WB raises fencei_flush_req_o and stays halted, with IF, ID and EX, until the request and the acknowledge have been sampled together (fencei_req_and_ack_q, tested at line 895) | open | rtl/cv32e40x_controller_fsm.sv:1258-1280 |
| cv32e40x | open question `tbljmp_behind_mret` | csr_stall_id's second term: an implicit CSR read in ID (mret or table jump) while an instruction causing an implicit CSR write (an mret, a pointer, a flagged CSR instruction) is in WB | open | rtl/cv32e40x_controller_bypass.sv:117-138 |
| cv32e40x-clic | open question `jalr_after_mnxti_d1` | jalr_stall's second term (line 230): a jalr in ID whose rs1 is the rd of an mnxti access in WB (ex_wb_pipe_i.csr_mnxti_access, the flopped csr_mnxti_read_i, ex_stage.sv 407) is held: the jalr's forward takes ex_wb_pipe.rf_wdata, which for mnxti is not the table entry's address.  With the access in EX the third term (line 231) holds it first, as for any rd-writer | open | rtl/cv32e40x_controller_bypass.sv:223-235 |
| cv32e40x-clic | open question `clic_ptr_csr_impl_write` | the pointer terms of csr_impl_write_in_ex and csr_impl_write_in_wb (lines 130, 137): a CLIC pointer or an mret pointer in EX or WB counts as an implicit CSR write, so csr_stall_id (line 252) holds an mret in ID behind it and csr_stall_ex's second term (263) would hold a CSR instruction in EX behind it. | open | rtl/cv32e40x_controller_bypass.sv:126-138 |
| cv32e40x | not built: `sys_wfe_insn` | the wfe term of sleep_stall.  wfe (0x8c000073) is the core's custom instruction, built by a localparam (cv32e40x_i_decoder.sv:42, CUSTOM_EXT = 1; decoded at lines 339-347); no ISA string of the core has it and Spike does not decode it.  The wfi term is the question wfi_sleep_stall_id | awaiting a feature: our records 51 (a): wfe, a wake-up line on the test device | rtl/cv32e40x_controller_bypass.sv:162-164 |
| cv32e40x | not built: `wfe_in_wb` | the wfe term of the halt of WB before SLEEP; the wfi term is the question wfi_halt_wb | awaiting a feature: our records 51 (a): wfe, a wake-up line on the test device | rtl/cv32e40x_controller_fsm.sv:860-865 |
| cv32e40x-clic | not built: `mintthresh_we` | an mret returning to a lower privilege level clears mintthresh (mintthresh_we), which would raise csr_irq_enable_write_o (line 1553) and so irq_enable_stall for a load or store in EX; the core is machine-mode only, so the branch cannot be taken | awaiting a feature: our records 12-14: user mode, on the cv32e40s round (the CV32E40X has no user mode) | rtl/cv32e40x_cs_registers.sv:1152-1156 |
| cv32e40x | not built: `id_ex_pipe_i.xif_en` | the xif_en half of load_stall's first term (line 216): an offloaded instruction in EX whose result ID reads.  xif_en is tied to 0 in the ID stage when X_EXT = 0 (cv32e40x_id_stage.sv:767) | out: the eXtension interface: a coprocessor on it would be needed, and X_EXT = 0 is the build; outside the claim | rtl/cv32e40x_controller_bypass.sv:214-221 |
| cv32e40x | not built: `xif_exception_stall` | ex_wb_pipe_i.xif_en is never set: xif_en is tied to 0 in the ID stage when X_EXT = 0 (cv32e40x_id_stage.sv:767) | out: the eXtension interface: a coprocessor on it would be needed, and X_EXT = 0 is the build; outside the claim | rtl/cv32e40x_controller_bypass.sv:339-340 |
| cv32e40x | not built: `single_step_halt_if_q` | halt_if after one instruction in single step: set only with dcsr.step (lines 1172-1177), and dcsr reads 0 when DEBUG = 0 (cv32e40x_cs_registers.sv:1529).  DEBUG = 0 is the harness's (our testbench P_DEBUG); the RTL's default is 1 | out: debug: a debug-request line and dcsr the harness has not got, and debug entry is not a timing claim anyone makes of this core (Simon, 23 Oct 2026: no debug) | rtl/cv32e40x_controller_fsm.sv:631-633 |
| cv32e40x | not built: `pending_async_debug` | halt_id, the debug term (line 655): a debug request or a synchronous debug cause pending.  debug_req_i is gated by DEBUG (cv32e40x_core.sv:407) and tied to 0 by the harness; pending_sync_debug needs dcsr.ebreakm, debug mode or a trigger match, and tdata1 is writable only in debug mode (cv32e40x_cs_registers.sv:972-975). | out: debug: a debug-request line and dcsr the harness has not got, and debug entry is not a timing claim anyone makes of this core (Simon, 23 Oct 2026: no debug) | rtl/cv32e40x_controller_fsm.sv:653-655 |
| cv32e40x | not built: `async_debug_allowed` | external debug entry: IF, ID, EX and WB halted, then DEBUG_TAKEN | out: debug: a debug-request line and dcsr the harness has not got, and debug entry is not a timing claim anyone makes of this core (Simon, 23 Oct 2026: no debug) | rtl/cv32e40x_controller_fsm.sv:764-775 |
| cv32e40x | not built: `sync_debug_allowed` | synchronous debug entry (ebreak with dcsr.ebreakm, a trigger match): IF, ID, EX and WB halted, then DEBUG_TAKEN | out: debug: a debug-request line and dcsr the harness has not got, and debug entry is not a timing claim anyone makes of this core (Simon, 23 Oct 2026: no debug) | rtl/cv32e40x_controller_fsm.sv:825-836 |
| cv32e40x | not built: `dret_in_wb` | a dret in WB kills IF, ID and EX; dret decodes only in debug mode (cv32e40x_i_decoder.sv:319-327), which is never entered | out: debug: a debug-request line and dcsr the harness has not got, and debug entry is not a timing claim anyone makes of this core (Simon, 23 Oct 2026: no debug) | rtl/cv32e40x_controller_fsm.sv:919-932 |
| cv32e40x | not built: `debug_cause_q` | the DEBUG_TAKEN state: IF, ID, EX (and WB unless the cause is an ebreak or a trigger) killed, or IF alone for a single step; the state is reached only through the three entries above, the debug request at reset (line 713) or single step and the exception trigger (lines 1059-1073) | out: debug: a debug-request line and dcsr the harness has not got, and debug entry is not a timing claim anyone makes of this core (Simon, 23 Oct 2026: no debug) | rtl/cv32e40x_controller_fsm.sv:1099-1163 |
| cv32e40x | not built: `kill_xif` | the generate branch no_x_ext ties kill_xif and the commit interface to 0 | out: the eXtension interface: a coprocessor on it would be needed, and X_EXT = 0 is the build; outside the claim | rtl/cv32e40x_controller_fsm.sv:1451-1504 |

## 11. How far this specification has been checked: the evidence behind it

| measure | value |
|---|---|
| timing skeletons measured by the search beyond the generated suites, by class | 463,409 |
| learner runs / blocks | 8 / 56,592 |
| direct crosses / blocks | 19 / 41,918 |
| blocks whose interval differed from this specification's prediction | 0 |
| findings in the record | 30 (22 document, 6 performance, 2 rtl) |

Our generated test suites run against this specification's prediction at every retirement on every regression; their counts and coverage are in the README and the results pages beside this document.  Deliberate faults injected into the RTL (the timing and functional mutation campaign) prove the suites see what they claim.

## 12. The configurations: what each build adds or changes

A configuration, or build, is one setting of the RTL's own parameters: the interrupt controller mode, the memory attribute regions, which ISA extensions are present.  For each one we build the RTL afresh under Verilator with those parameters, configure the reference simulator to the matching ISA and memory map, and run the same generated suites and benchmarks that apply to it, through the same testbench, comparing every retirement as for the base build.  Each configuration's part of this specification holds only what differs from the base: a statement it adds or overrides, a change to the interrupt or pipeline model, the anomalies found on it.  What is not listed is the base core's, and holds for the configuration too.

### cv32e40x-clic: the CLIC build

Statements of its own:

| id | fires when | cost | grade | cause | width | source |
|---|---|---|---|---|---|---|
| csr_after_mstatus_mcause_access_d1 | csr_r or csr_i 1 behind an access of mstatus, mcause | stall 1, held in EX | inferred | the aliasing write: a CSR instruction naming mstatus or mcause writes both in WB (mpp and mpie are one register), and a CSR instruction in EX reads before that write lands | narrower | rtl/cv32e40x_controller_bypass.sv 256-267 `csr_impl_write_in_wb` |
| csr_mnxti_mscratchcswl_after_csr_d1 | an access of mnxti, mscratchcswl 1 behind csr_r or csr_i | stall 1, held in EX | inferred | an implicit CSR read in EX racing a CSR instruction still in WB that could write what it reads | equal | rtl/cv32e40x_controller_bypass.sv 256-267 `csr_hz_i.impl_re_ex` |
| irq_enable_lsu_d1 | load or store 1 behind a write of mstatus, mintthresh, mcause | stall 1, held in EX | inferred | a write that may enable an interrupt still in WB while a load or store is in EX | equal | rtl/cv32e40x_cs_registers.sv 1550-1557, 912-920, 1028-1037 `csr_irq_enable_write_o` |
| csr_after_implicit_write_d1 | csr_r or csr_i 1 behind an access of mscratchcswl, mnxti | stall 1, held in EX | read | an explicit CSR read in EX racing an implicit CSR write still in WB of the same CSR | wider | rtl/cv32e40x_controller_bypass.sv 256-267 `csr_impl_write_in_wb` |

Its interrupt model changes: the interrupt mode, the number of interrupt lines, the priorities, the priority rule, the lines, the gating of interrupts, the vectoring, the nesting, when an interrupt is taken.

Findings made on it: mcause.minhv stays set after an mret restarts a faulted CLIC pointer fetch successfully (rtl, function); CLIC: an access of mnxti or mscratchcswl behind any CSR instruction waits a cycle (document, intent); CLIC: a load or store behind a write of mie does not wait, unlike the CLINT core (document, intent); CLIC: a load or store behind a write of mintthresh waits a cycle (document, intent); CLIC: a CSR instruction one behind an mscratchcswl access waits a cycle (performance, over-wide); CLIC: a load or store one behind an mcause write waits a cycle (document, intent).

### cv32e40x-pma-a: the PMA with A build

Its pipeline model changes: the cycle counts of the instruction classes it adds (`sc`, `amo`).

Findings made on it: An atomic transaction overlaps no other: a cycle lost on each side of an lr, sc or AMO (performance, over-wide); A misaligned atomic raises an access fault (5, 7), not a misaligned one (4, 6) (document, function).

### cv32e40x-pma: the PMA build

Its pipeline model changes: the memory side (the regions: the hole past the memory, the I/O window, what is bufferable).

Findings made on it: A fence behind a buffered store waits for the store's response, then runs its own cycles (document, intent); A split access into I/O issues its legal first half, then faults a cycle later (document, function); A bufferable store whose grant is withheld, third behind a mulh, stalls one cycle (document, intent).

### cv32e40x-zbc: the Zbc build

Nothing beyond the base build: its instructions fall into the base's classes with the base's timing, it has no statement of its own, and no anomaly was found on it; its runs are counted with the base's in the README.

© 2026 processor-timing-anomalies, Apache License 2.0
