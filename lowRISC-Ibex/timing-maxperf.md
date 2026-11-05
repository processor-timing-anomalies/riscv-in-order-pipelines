# Our accurate, complete timing specification for the Ibex maxperf build

Generated from our records of the Ibex maxperf build on 5 November 2026, for the RTL at commit `c0c07085791e4d16a0f2d9a753b2fb79d72e5ffa`; the configurations measured: ibex-icache (the maxperf build with B full, PMP and the instruction cache), ibex-pmp (the maxperf build with B full and PMP).  The timing is as measured on that commit; the document is regenerated after every run we record.

This document states what the ibex-maxperf core promises in time: the pipeline as a structure, the cycle each instruction class takes, the stalls and bubbles between instructions, the memory side under a stated bus, the CSR accesses that wait, the interrupts and other events, what real programs pay on it, and where the RTL and the user manual disagree.  It is the rendering of our internal machine-readable version of the RISC-V ISA, this core's layer distilled from its user manual with a citation or a graded reading on every field, a configuration layer for each variant, and the RTL read only to answer what the manual leaves open.  It describes the implementation as measured; a row graded inferred or read is not design intent until the core's authors take it as theirs (the grade authored).

| grade | meaning |
|---|---|
| stated | the manual says it |
| confirmed | the manual says it and the RTL agreed under the suites |
| inferred | the manual is silent; a run showed it and the suites confirmed it |
| read | read in the RTL source, cited by file and line; not a statement of the manual |
| open | a question no run has answered |
| authored | the core's authors have taken the row as their statement (reserved) |

**Conditions.**  Every row states what it assumes.  The manual's cycle table assumes zero stall on both interfaces, and the hazard rows are compared under that; the memory rows hold under any bus schedule a test names (the waits, the write buffer, the outstanding requests, the PMA regions), so their condition is the schedule; a configuration's rows assume its parameters.  No row claims zero-wait as a general condition of the core.

**Sources.**  Where the manual is cited: the core's own documentation, by file and line at the pinned RTL commit; where the RTL is cited: its files and lines at the same commit (`c0c07085791e4d16a0f2d9a753b2fb79d72e5ffa`).

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
| stages | IF IDEX WB | rtl/ibex_wb_stage.sv 60-76, 107, 115-116, 185 | read |
| register ports read in | rs1: IDEX, rs2: IDEX, store_data: IDEX, branch_cmp: IDEX, jalr_target: IDEX, mem_base: IDEX, csr: IDEX | rtl/ibex_id_stage.sv 292-295, 1094-1109 | read |
| results written | rd: WB | rtl/ibex_wb_stage.sv 102-116, 183-190, 305-307 | read |
| result available, per class | alu_rr: IDEX, alu_ri: IDEX, alu_nosrc: IDEX, load: WB, store: WB, branch: IDEX, jal: IDEX, jalr: IDEX, csr_r: IDEX, csr_i: IDEX, mul: IDEX, mulh: IDEX, div: IDEX, system: IDEX, trap: IDEX, zcpush: IDEX, zcpop: IDEX, zcpopret: IDEX, zcmv: IDEX | rtl/ibex_id_stage.sv 869-968, 1002, 1215 | read |
| occupancy, per class (cycles beyond the first in the stage named) | mul: 1; mulh: 2; div: default 2 to 37; rule 2 if rs2 == 0 else 37; load: default 1; misaligned 2; store: default 1; misaligned 2; jal: default 1; redirect first; jalr: default 1; redirect first; branch: default 1; taken 1; redirect first; fence.i: default 1; redirect first; zcpush: default 2 to 14; rule nreg + 1; zcpop: default 2 to 14; rule nreg + 1; zcpopret: default 3 to 16; rule nreg + 2 + popretz; zcmv: 2 | rtl/ibex_id_stage.sv 887-942, 1086-1087, 1137 | read |
| forwarding paths | WB -> IDEX | rtl/ibex_id_stage.sv 1094-1111 | read |
| control transfers resolved in | jump IDEX, branch IDEX, trap IDEX; flushes: fence.i from IDEX, mret from IDEX+1, trap from IDEX+1, csr_write_of * except mscratch mepc from IDEX+1 prefetched | rtl/ibex_id_stage.sv 811-812, 921-937 | read |
| register file | write before read | rtl/ibex_id_stage.sv 1108-1111 | read |
| penalty: misaligned_target | 1 | instruction_fetch.rst 76-80 | stated |

## 2. Cycle counts per instruction class: the base cost of every instruction

The cycles an instruction of each class takes in its result stage beyond the one every instruction takes (its occupancy), with no hazard and no bus wait; the manual's table "Cycle counts per instruction type" is the source where one is given.

| class | occupancy | instructions | members |
|---|---:|---:|---|
| mul | 1 | 2 | c.mul, mul |
| mulh | 2 | 3 | mulh, mulhsu, mulhu |
| div | default 2 to 37; rule 2 if rs2 == 0 else 37 | 4 | div, divu, rem, remu |
| zcpush | default 2 to 14; rule nreg + 1 | 1 | cm.push |
| zcpop | default 2 to 14; rule nreg + 1 | 1 | cm.pop |
| zcpopret | default 3 to 16; rule nreg + 2 + popretz | 2 | cm.popret, cm.popretz |
| zcmv | 2 | 2 | cm.mva01s, cm.mvsa01 |
| load | default 1; misaligned 2 | 10 | c.lbu, c.lh, c.lhu, c.lw, c.lwsp, lb, lbu, lh ... |
| store | default 1; misaligned 2 | 7 | c.sb, c.sh, c.sw, c.swsp, sb, sh, sw |
| branch | default 1; taken 1; redirect first | 8 | beq, bge, bgeu, blt, bltu, bne, c.beqz, c.bnez |
| jalr | default 1; redirect first | 3 | c.jalr, c.jr, jalr |
| jal | default 1; redirect first | 3 | c.j, c.jal, jal |
| csr_r | 0 | 3 | csrrc, csrrs, csrrw |
| csr_i | 0 | 3 | csrrci, csrrsi, csrrwi |
| alu_rr | 0 | 16 | add, and, c.add, c.and, c.mv, c.or, c.sub, c.xor ... |
| alu_ri | 0 | 18 | addi, andi, c.addi, c.addi16sp, c.addi4spn, c.andi, c.not, c.slli ... |
| alu_nosrc | 0 | 4 | auipc, c.li, c.lui, lui |
| trap | 0 | 4 | c.ebreak, ebreak, ecall, mret |
| system | 0 | 5 | c.nop, fence, fence.i, fence.tso, wfi |

## 3. Three facts of the pipeline the rules below assume

| fact | this core | source | grade |
|---|---|---|---|
| two statements that hold one instruction in one stage | - |  | read |
| a jump held in its resolution stage by a statement of the core (not by its own operand) | waits: the fetch starts after the hold |  | read |
| an instruction that traps as illegal | - |  | read |

## 4. Hazards: the stalls between instructions, derived and documented

A hazard is two instructions within the pipeline's depth that touch the same register, CSR or control.  The rows derived from the structure (section 1) are the manual's rules read through the ISA layer: a dependent instruction at distance d waits until the producer's result is where the reader reads it, the forwarding paths shortening the wait.  The rows the core states on its own are those the structure does not derive; each carries its cause in ISA terms and the width of its trigger against that cause.  Conditions: the zero-wait bus of the manual's cycle table.

### 4.1 Derived from the structure

| kind | subject classes | port | producer class | variant | d=1 | d=2 | no distance |
|---|---|---|---|---|---|---|---|
| ctrl | any, trap | - | - | - | - | - | none |
| ctrl | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, trap, zcmv, zcpop, zcpopret, zcpush | - | branch | - | bubble 1 / squash 0 | - | - |
| ctrl | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, trap, zcmv, zcpop, zcpopret, zcpush | - | jal | - | bubble 1 / squash 0 | - | - |
| ctrl | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, trap, zcmv, zcpop, zcpopret, zcpush | - | jalr | - | bubble 1 / squash 0 | - | - |
| ctrl | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, trap, zcmv, zcpop, zcpopret, zcpush | - | trap | - | bubble 2 / squash 0 | - | - |
| raw | load, store, zcpop, zcpopret, zcpush | addr | alu_nosrc | - | forward 0 | none | - |
| raw | load, zcpop, zcpopret, zcpush | addr | alu_nosrc | same_reg | forward 0 | none | - |
| raw | load, store, zcpop, zcpopret, zcpush | addr | alu_nosrc | x0 | none | none | - |
| raw | load, store, zcpop, zcpopret, zcpush | addr | alu_ri | - | forward 0 | none | - |
| raw | load, zcpop, zcpopret, zcpush | addr | alu_ri | same_reg | forward 0 | none | - |
| raw | load, store, zcpop, zcpopret, zcpush | addr | alu_ri | x0 | none | none | - |
| raw | load, store, zcpop, zcpopret, zcpush | addr | alu_rr | - | forward 0 | none | - |
| raw | load, zcpop, zcpopret, zcpush | addr | alu_rr | same_reg | forward 0 | none | - |
| raw | load, store, zcpop, zcpopret, zcpush | addr | alu_rr | x0 | none | none | - |
| raw | load, store, zcpop, zcpopret, zcpush | addr | csr_i | - | forward 0 | none | - |
| raw | load, zcpop, zcpopret, zcpush | addr | csr_i | same_reg | forward 0 | none | - |
| raw | load, store, zcpop, zcpopret, zcpush | addr | csr_i | x0 | none | none | - |
| raw | load, store, zcpop, zcpopret, zcpush | addr | csr_r | - | forward 0 | none | - |
| raw | load, zcpop, zcpopret, zcpush | addr | csr_r | same_reg | forward 0 | none | - |
| raw | load, store, zcpop, zcpopret, zcpush | addr | csr_r | x0 | none | none | - |
| raw | load, store, zcpop, zcpopret, zcpush | addr | div | - | forward 0 | none | - |
| raw | load, zcpop, zcpopret, zcpush | addr | div | same_reg | forward 0 | none | - |
| raw | load, store, zcpop, zcpopret, zcpush | addr | div | x0 | none | none | - |
| raw | load, store, zcpop, zcpopret, zcpush | addr | jal | - | forward 0 | none | - |
| raw | load, zcpop, zcpopret, zcpush | addr | jal | same_reg | forward 0 | none | - |
| raw | load, store, zcpop, zcpopret, zcpush | addr | jal | x0 | none | none | - |
| raw | load, store, zcpop, zcpopret, zcpush | addr | jalr | - | forward 0 | none | - |
| raw | load, zcpop, zcpopret, zcpush | addr | jalr | same_reg | forward 0 | none | - |
| raw | load, store, zcpop, zcpopret, zcpush | addr | jalr | x0 | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, mul, mulh, zcmv | addr | load | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, zcmv, zcpop, zcpopret, zcpush | addr | load | x0 | none | none | - |
| raw | load, zcpop, zcpopret, zcpush | addr | load | - | forward 0 / stall 1 | none | - |
| raw | load, zcpop, zcpopret, zcpush | addr | load | same_reg | forward 0 | none | - |
| raw | store | addr | load | - | stall 1 | none | - |
| raw | load, store, zcpop, zcpopret, zcpush | addr | mul | - | forward 0 | none | - |
| raw | load, zcpop, zcpopret, zcpush | addr | mul | same_reg | forward 0 | none | - |
| raw | load, store, zcpop, zcpopret, zcpush | addr | mul | x0 | none | none | - |
| raw | load, store, zcpop, zcpopret, zcpush | addr | mulh | - | forward 0 | none | - |
| raw | load, zcpop, zcpopret, zcpush | addr | mulh | same_reg | forward 0 | none | - |
| raw | load, store, zcpop, zcpopret, zcpush | addr | mulh | x0 | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | addr | store | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | addr | store | x0 | none | none | - |
| raw | load, store, zcpop, zcpopret, zcpush | addr | zcmv | - | forward 0 | none | - |
| raw | load, zcpop, zcpopret, zcpush | addr | zcmv | same_reg | forward 0 | none | - |
| raw | load, store, zcpop, zcpopret, zcpush | addr | zcmv | x0 | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, zcmv, zcpop, zcpopret, zcpush | addr | zcpop | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, zcmv, zcpop, zcpopret, zcpush | addr | zcpop | x0 | none | none | - |
| raw | load, zcpop, zcpopret, zcpush | addr | zcpop | same_reg | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, zcmv, zcpop, zcpopret, zcpush | addr | zcpopret | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, zcmv, zcpop, zcpopret, zcpush | addr | zcpopret | x0 | none | none | - |
| raw | load, zcpop, zcpopret, zcpush | addr | zcpopret | same_reg | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, zcmv, zcpop, zcpopret, zcpush | addr | zcpush | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, zcmv, zcpop, zcpopret, zcpush | addr | zcpush | x0 | none | none | - |
| raw | load, zcpop, zcpopret, zcpush | addr | zcpush | same_reg | forward 0 | none | - |
| raw | branch | cmp1 | alu_nosrc | - | forward 0 | none | - |
| raw | branch | cmp1 | alu_nosrc | x0 | none | none | - |
| raw | branch | cmp1 | alu_ri | - | forward 0 | none | - |
| raw | branch | cmp1 | alu_ri | x0 | none | none | - |
| raw | branch | cmp1 | alu_rr | - | forward 0 | none | - |
| raw | branch | cmp1 | alu_rr | x0 | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | cmp1 | branch | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | cmp1 | branch | x0 | none | none | - |
| raw | branch | cmp1 | csr_i | - | forward 0 | none | - |
| raw | branch | cmp1 | csr_i | x0 | none | none | - |
| raw | branch | cmp1 | csr_r | - | forward 0 | none | - |
| raw | branch | cmp1 | csr_r | x0 | none | none | - |
| raw | branch | cmp1 | div | - | forward 0 | none | - |
| raw | branch | cmp1 | div | x0 | none | none | - |
| raw | branch | cmp1 | jal | - | forward 0 | none | - |
| raw | branch | cmp1 | jal | x0 | none | none | - |
| raw | branch | cmp1 | jalr | - | forward 0 | none | - |
| raw | branch | cmp1 | jalr | x0 | none | none | - |
| raw | branch | cmp1 | load | - | stall 1 | none | - |
| raw | branch | cmp1 | load | x0 | none | none | - |
| raw | branch | cmp1 | mul | - | forward 0 | none | - |
| raw | branch | cmp1 | mul | x0 | none | none | - |
| raw | branch | cmp1 | mulh | - | forward 0 | none | - |
| raw | branch | cmp1 | mulh | x0 | none | none | - |
| raw | branch | cmp1 | zcmv | - | forward 0 | none | - |
| raw | branch | cmp1 | zcmv | x0 | none | none | - |
| raw | branch | cmp1 | zcpop | - | forward 0 | none | - |
| raw | branch | cmp1 | zcpop | x0 | none | none | - |
| raw | branch | cmp1 | zcpopret | - | forward 0 | none | - |
| raw | branch | cmp1 | zcpopret | x0 | none | none | - |
| raw | branch | cmp1 | zcpush | - | forward 0 | none | - |
| raw | branch | cmp1 | zcpush | x0 | none | none | - |
| raw | branch | cmp2 | alu_nosrc | - | forward 0 | none | - |
| raw | branch | cmp2 | alu_nosrc | x0 | none | none | - |
| raw | branch | cmp2 | alu_ri | - | forward 0 | none | - |
| raw | branch | cmp2 | alu_ri | x0 | none | none | - |
| raw | branch | cmp2 | alu_rr | - | forward 0 | none | - |
| raw | branch | cmp2 | alu_rr | x0 | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | cmp2 | branch | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | cmp2 | branch | x0 | none | none | - |
| raw | branch | cmp2 | csr_i | - | forward 0 | none | - |
| raw | branch | cmp2 | csr_i | x0 | none | none | - |
| raw | branch | cmp2 | csr_r | - | forward 0 | none | - |
| raw | branch | cmp2 | csr_r | x0 | none | none | - |
| raw | branch | cmp2 | div | - | forward 0 | none | - |
| raw | branch | cmp2 | div | x0 | none | none | - |
| raw | branch | cmp2 | jal | - | forward 0 | none | - |
| raw | branch | cmp2 | jal | x0 | none | none | - |
| raw | branch | cmp2 | jalr | - | forward 0 | none | - |
| raw | branch | cmp2 | jalr | x0 | none | none | - |
| raw | branch | cmp2 | load | - | stall 1 | none | - |
| raw | branch | cmp2 | load | x0 | none | none | - |
| raw | branch | cmp2 | mul | - | forward 0 | none | - |
| raw | branch | cmp2 | mul | x0 | none | none | - |
| raw | branch | cmp2 | mulh | - | forward 0 | none | - |
| raw | branch | cmp2 | mulh | x0 | none | none | - |
| raw | branch | cmp2 | zcmv | - | forward 0 | none | - |
| raw | branch | cmp2 | zcmv | x0 | none | none | - |
| raw | branch | cmp2 | zcpop | - | forward 0 | none | - |
| raw | branch | cmp2 | zcpop | x0 | none | none | - |
| raw | branch | cmp2 | zcpopret | - | forward 0 | none | - |
| raw | branch | cmp2 | zcpopret | x0 | none | none | - |
| raw | branch | cmp2 | zcpush | - | forward 0 | none | - |
| raw | branch | cmp2 | zcpush | x0 | none | none | - |
| raw | csr_i, csr_r, trap | csr | csr_i | - | forward 0 | none | - |
| raw | csr_i, csr_r, trap | csr | csr_r | - | forward 0 | none | - |
| raw | csr_i, csr_r, trap | csr | trap | - | forward 0 | none | - |
| raw | store, zcpush | data | alu_nosrc | - | forward 0 | none | - |
| raw | store, zcpush | data | alu_nosrc | x0 | none | none | - |
| raw | zcpush | data | alu_nosrc | same_reg | forward 0 | none | - |
| raw | store, zcpush | data | alu_ri | - | forward 0 | none | - |
| raw | store, zcpush | data | alu_ri | x0 | none | none | - |
| raw | zcpush | data | alu_ri | same_reg | forward 0 | none | - |
| raw | store, zcpush | data | alu_rr | - | forward 0 | none | - |
| raw | store, zcpush | data | alu_rr | x0 | none | none | - |
| raw | zcpush | data | alu_rr | same_reg | forward 0 | none | - |
| raw | store, zcpush | data | csr_i | - | forward 0 | none | - |
| raw | store, zcpush | data | csr_i | x0 | none | none | - |
| raw | zcpush | data | csr_i | same_reg | forward 0 | none | - |
| raw | store, zcpush | data | csr_r | - | forward 0 | none | - |
| raw | store, zcpush | data | csr_r | x0 | none | none | - |
| raw | zcpush | data | csr_r | same_reg | forward 0 | none | - |
| raw | store, zcpush | data | div | - | forward 0 | none | - |
| raw | store, zcpush | data | div | x0 | none | none | - |
| raw | zcpush | data | div | same_reg | forward 0 | none | - |
| raw | store, zcpush | data | jal | - | forward 0 | none | - |
| raw | store, zcpush | data | jal | x0 | none | none | - |
| raw | zcpush | data | jal | same_reg | forward 0 | none | - |
| raw | store, zcpush | data | jalr | - | forward 0 | none | - |
| raw | store, zcpush | data | jalr | x0 | none | none | - |
| raw | zcpush | data | jalr | same_reg | forward 0 | none | - |
| raw | store, zcpush | data | load | - | stall 1 | none | - |
| raw | store, zcpush | data | load | x0 | none | none | - |
| raw | zcpush | data | load | same_reg | forward 0 | none | - |
| raw | store, zcpush | data | mul | - | forward 0 | none | - |
| raw | store, zcpush | data | mul | x0 | none | none | - |
| raw | zcpush | data | mul | same_reg | forward 0 | none | - |
| raw | store, zcpush | data | mulh | - | forward 0 | none | - |
| raw | store, zcpush | data | mulh | x0 | none | none | - |
| raw | zcpush | data | mulh | same_reg | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | data | store | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | data | store | x0 | none | none | - |
| raw | store, zcpush | data | zcmv | - | forward 0 | none | - |
| raw | store, zcpush | data | zcmv | x0 | none | none | - |
| raw | zcpush | data | zcmv | same_reg | forward 0 | none | - |
| raw | store, zcpush | data | zcpop | - | forward 0 | none | - |
| raw | store, zcpush | data | zcpop | x0 | none | none | - |
| raw | zcpush | data | zcpop | same_reg | forward 0 | none | - |
| raw | store, zcpush | data | zcpopret | - | forward 0 | none | - |
| raw | store, zcpush | data | zcpopret | x0 | none | none | - |
| raw | zcpush | data | zcpopret | same_reg | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, zcmv, zcpop, zcpopret, zcpush | data | zcpush | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, zcmv, zcpop, zcpopret, zcpush | data | zcpush | x0 | none | none | - |
| raw | zcpush | data | zcpush | same_reg | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | alu_nosrc | - | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | alu_nosrc | same_reg | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | alu_nosrc | x0 | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rs1 | alu_ri | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rs1 | alu_ri | x0 | none | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | alu_ri | same_reg | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rs1 | alu_rr | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rs1 | alu_rr | x0 | none | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | alu_rr | same_reg | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | csr_i | - | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | csr_i | same_reg | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | csr_i | x0 | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rs1 | csr_r | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rs1 | csr_r | x0 | none | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | csr_r | same_reg | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rs1 | div | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rs1 | div | x0 | none | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | div | same_reg | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | jal | - | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | jal | same_reg | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | jal | x0 | none | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | jalr | - | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | jalr | same_reg | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | jalr | x0 | none | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | load | - | stall 1 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | load | same_reg | stall 1 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | load | x0 | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rs1 | mul | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rs1 | mul | x0 | none | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | mul | same_reg | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rs1 | mulh | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rs1 | mulh | x0 | none | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | mulh | same_reg | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rs1 | zcmv | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rs1 | zcmv | x0 | none | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | zcmv | same_reg | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | zcpop | - | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | zcpop | same_reg | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | zcpop | x0 | none | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | zcpopret | - | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | zcpopret | same_reg | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | zcpopret | x0 | none | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | zcpush | - | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | zcpush | same_reg | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | zcpush | x0 | none | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs1rs2 | alu_nosrc | - | forward 0 | forward 0 / none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs1rs2 | alu_ri | - | forward 0 | forward 0 / none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs1rs2 | alu_rr | - | forward 0 | forward 0 / none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs1rs2 | csr_i | - | forward 0 | forward 0 / none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs1rs2 | csr_r | - | forward 0 | forward 0 / none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs1rs2 | div | - | forward 0 | forward 0 / none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs1rs2 | jal | - | forward 0 | forward 0 / none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs1rs2 | jalr | - | forward 0 | forward 0 / none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs1rs2 | load | - | forward 0 / stall 1 | forward 0 / none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs1rs2 | mul | - | forward 0 | forward 0 / none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs1rs2 | mulh | - | forward 0 | forward 0 / none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs1rs2 | zcmv | - | forward 0 | forward 0 / none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs1rs2 | zcpop | - | forward 0 | forward 0 / none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs1rs2 | zcpopret | - | forward 0 | forward 0 / none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs1rs2 | zcpush | - | forward 0 | forward 0 / none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | alu_nosrc | - | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | alu_nosrc | same_reg | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | alu_nosrc | x0 | none | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | alu_ri | - | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | alu_ri | same_reg | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | alu_ri | x0 | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rs2 | alu_rr | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rs2 | alu_rr | x0 | none | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | alu_rr | same_reg | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | csr_i | - | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | csr_i | same_reg | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | csr_i | x0 | none | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | csr_r | - | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | csr_r | same_reg | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | csr_r | x0 | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rs2 | div | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rs2 | div | x0 | none | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | div | same_reg | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | jal | - | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | jal | same_reg | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | jal | x0 | none | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | jalr | - | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | jalr | same_reg | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | jalr | x0 | none | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | load | - | stall 1 | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | load | same_reg | stall 1 | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | load | x0 | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rs2 | mul | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rs2 | mul | x0 | none | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | mul | same_reg | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rs2 | mulh | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rs2 | mulh | x0 | none | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | mulh | same_reg | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rs2 | zcmv | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rs2 | zcmv | x0 | none | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | zcmv | same_reg | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | zcpop | - | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | zcpop | same_reg | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | zcpop | x0 | none | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | zcpopret | - | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | zcpopret | same_reg | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | zcpopret | x0 | none | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | zcpush | - | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | zcpush | same_reg | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh, zcmv | rs2 | zcpush | x0 | none | none | - |
| raw | jalr | target | alu_nosrc | - | forward 0 | none | - |
| raw | jalr | target | alu_nosrc | same_reg | forward 0 | none | - |
| raw | jalr | target | alu_nosrc | x0 | none | none | - |
| raw | jalr | target | alu_ri | - | forward 0 | none | - |
| raw | jalr | target | alu_ri | same_reg | forward 0 | none | - |
| raw | jalr | target | alu_ri | x0 | none | none | - |
| raw | jalr | target | alu_rr | - | forward 0 | none | - |
| raw | jalr | target | alu_rr | same_reg | forward 0 | none | - |
| raw | jalr | target | alu_rr | x0 | none | none | - |
| raw | jalr | target | csr_i | - | forward 0 | none | - |
| raw | jalr | target | csr_i | same_reg | forward 0 | none | - |
| raw | jalr | target | csr_i | x0 | none | none | - |
| raw | jalr | target | csr_r | - | forward 0 | none | - |
| raw | jalr | target | csr_r | same_reg | forward 0 | none | - |
| raw | jalr | target | csr_r | x0 | none | none | - |
| raw | jalr | target | div | - | forward 0 | none | - |
| raw | jalr | target | div | same_reg | forward 0 | none | - |
| raw | jalr | target | div | x0 | none | none | - |
| raw | jalr | target | jal | - | forward 0 | none | - |
| raw | jalr | target | jal | same_reg | forward 0 | none | - |
| raw | jalr | target | jal | x0 | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | target | jalr | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | target | jalr | x0 | none | none | - |
| raw | jalr | target | jalr | same_reg | forward 0 | none | - |
| raw | jalr | target | load | - | stall 1 | none | - |
| raw | jalr | target | load | same_reg | forward 0 | none | - |
| raw | jalr | target | load | x0 | none | none | - |
| raw | jalr | target | mul | - | forward 0 | none | - |
| raw | jalr | target | mul | same_reg | forward 0 | none | - |
| raw | jalr | target | mul | x0 | none | none | - |
| raw | jalr | target | mulh | - | forward 0 | none | - |
| raw | jalr | target | mulh | same_reg | forward 0 | none | - |
| raw | jalr | target | mulh | x0 | none | none | - |
| raw | jalr | target | zcmv | - | forward 0 | none | - |
| raw | jalr | target | zcmv | same_reg | forward 0 | none | - |
| raw | jalr | target | zcmv | x0 | none | none | - |
| raw | jalr | target | zcpop | - | forward 0 | none | - |
| raw | jalr | target | zcpop | same_reg | forward 0 | none | - |
| raw | jalr | target | zcpop | x0 | none | none | - |
| raw | jalr | target | zcpopret | - | forward 0 | none | - |
| raw | jalr | target | zcpopret | same_reg | forward 0 | none | - |
| raw | jalr | target | zcpopret | x0 | none | none | - |
| raw | jalr | target | zcpush | - | forward 0 | none | - |
| raw | jalr | target | zcpush | same_reg | forward 0 | none | - |
| raw | jalr | target | zcpush | x0 | none | none | - |
| raw | any | use | - | - | - | - | none |
| struct | any, system | - | - | - | - | - | none |
| struct | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, trap, zcmv, zcpop, zcpopret, zcpush | - | div | - | occupied 37 | occupied 37 | - |
| struct | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, trap, zcmv, zcpop, zcpopret, zcpush | - | mulh | - | occupied 2 | occupied 2 | - |
| struct | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, trap, zcmv, zcpop, zcpopret, zcpush | - | zcmv | - | occupied 2 | occupied 2 | - |
| struct | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, trap, zcmv, zcpop, zcpopret, zcpush | - | zcpop | - | occupied 14 | occupied 14 | - |
| struct | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, trap, zcmv, zcpop, zcpopret, zcpush | - | zcpopret | - | occupied 16 | occupied 16 | - |
| struct | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, trap, zcmv, zcpop, zcpopret, zcpush | - | zcpush | - | occupied 14 | occupied 14 | - |
| war | load, store, zcpop, zcpopret, zcpush | addr | alu_nosrc | - | none | none | - |
| war | load, store, zcpop, zcpopret, zcpush | addr | alu_ri | - | none | none | - |
| war | load, store, zcpop, zcpopret, zcpush | addr | alu_rr | - | none | none | - |
| war | load, store, zcpop, zcpopret, zcpush | addr | csr_i | - | none | none | - |
| war | load, store, zcpop, zcpopret, zcpush | addr | csr_r | - | none | none | - |
| war | load, store, zcpop, zcpopret, zcpush | addr | div | - | none | none | - |
| war | load, store, zcpop, zcpopret, zcpush | addr | jal | - | none | none | - |
| war | load, store, zcpop, zcpopret, zcpush | addr | jalr | - | none | none | - |
| war | load, store, zcpop, zcpopret, zcpush | addr | load | - | none | none | - |
| war | load, store, zcpop, zcpopret, zcpush | addr | mul | - | none | none | - |
| war | load, store, zcpop, zcpopret, zcpush | addr | mulh | - | none | none | - |
| war | load, store, zcpop, zcpopret, zcpush | addr | zcmv | - | none | none | - |
| war | load, store, zcpop, zcpopret, zcpush | addr | zcpop | - | none | none | - |
| war | load, store, zcpop, zcpopret, zcpush | addr | zcpopret | - | none | none | - |
| war | load, store, zcpop, zcpopret, zcpush | addr | zcpush | - | none | none | - |
| war | branch | cmp1 | alu_nosrc | - | none | none | - |
| war | branch | cmp1 | alu_ri | - | none | none | - |
| war | branch | cmp1 | alu_rr | - | none | none | - |
| war | branch | cmp1 | csr_i | - | none | none | - |
| war | branch | cmp1 | csr_r | - | none | none | - |
| war | branch | cmp1 | div | - | none | none | - |
| war | branch | cmp1 | jal | - | none | none | - |
| war | branch | cmp1 | jalr | - | none | none | - |
| war | branch | cmp1 | load | - | none | none | - |
| war | branch | cmp1 | mul | - | none | none | - |
| war | branch | cmp1 | mulh | - | none | none | - |
| war | branch | cmp1 | zcmv | - | none | none | - |
| war | branch | cmp1 | zcpop | - | none | none | - |
| war | branch | cmp1 | zcpopret | - | none | none | - |
| war | branch | cmp1 | zcpush | - | none | none | - |
| war | branch | cmp2 | alu_nosrc | - | none | none | - |
| war | branch | cmp2 | alu_ri | - | none | none | - |
| war | branch | cmp2 | alu_rr | - | none | none | - |
| war | branch | cmp2 | csr_i | - | none | none | - |
| war | branch | cmp2 | csr_r | - | none | none | - |
| war | branch | cmp2 | div | - | none | none | - |
| war | branch | cmp2 | jal | - | none | none | - |
| war | branch | cmp2 | jalr | - | none | none | - |
| war | branch | cmp2 | load | - | none | none | - |
| war | branch | cmp2 | mul | - | none | none | - |
| war | branch | cmp2 | mulh | - | none | none | - |
| war | branch | cmp2 | zcmv | - | none | none | - |
| war | branch | cmp2 | zcpop | - | none | none | - |
| war | branch | cmp2 | zcpopret | - | none | none | - |
| war | branch | cmp2 | zcpush | - | none | none | - |
| war | store, zcpush | data | alu_nosrc | - | none | none | - |
| war | store, zcpush | data | alu_ri | - | none | none | - |
| war | store, zcpush | data | alu_rr | - | none | none | - |
| war | store, zcpush | data | csr_i | - | none | none | - |
| war | store, zcpush | data | csr_r | - | none | none | - |
| war | store, zcpush | data | div | - | none | none | - |
| war | store, zcpush | data | jal | - | none | none | - |
| war | store, zcpush | data | jalr | - | none | none | - |
| war | store, zcpush | data | load | - | none | none | - |
| war | store, zcpush | data | mul | - | none | none | - |
| war | store, zcpush | data | mulh | - | none | none | - |
| war | store, zcpush | data | zcmv | - | none | none | - |
| war | store, zcpush | data | zcpop | - | none | none | - |
| war | store, zcpush | data | zcpopret | - | none | none | - |
| war | store, zcpush | data | zcpush | - | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rd | alu_ri | - | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rd | alu_rr | - | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rd | branch | - | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rd | csr_r | - | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rd | div | - | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rd | jalr | - | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rd | load | - | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rd | mul | - | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rd | mulh | - | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rd | store | - | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rd | zcmv | - | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rd | zcpop | - | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rd | zcpopret | - | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | rd | zcpush | - | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | alu_nosrc | - | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | alu_ri | - | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | alu_rr | - | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | csr_i | - | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | csr_r | - | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | div | - | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | jal | - | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | jalr | - | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | load | - | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | mul | - | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | mulh | - | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | zcmv | - | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | zcpop | - | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | zcpopret | - | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh, zcmv | rs1 | zcpush | - | none | none | - |
| war | alu_rr, div, mul, mulh, zcmv | rs2 | alu_nosrc | - | none | none | - |
| war | alu_rr, div, mul, mulh, zcmv | rs2 | alu_ri | - | none | none | - |
| war | alu_rr, div, mul, mulh, zcmv | rs2 | alu_rr | - | none | none | - |
| war | alu_rr, div, mul, mulh, zcmv | rs2 | csr_i | - | none | none | - |
| war | alu_rr, div, mul, mulh, zcmv | rs2 | csr_r | - | none | none | - |
| war | alu_rr, div, mul, mulh, zcmv | rs2 | div | - | none | none | - |
| war | alu_rr, div, mul, mulh, zcmv | rs2 | jal | - | none | none | - |
| war | alu_rr, div, mul, mulh, zcmv | rs2 | jalr | - | none | none | - |
| war | alu_rr, div, mul, mulh, zcmv | rs2 | load | - | none | none | - |
| war | alu_rr, div, mul, mulh, zcmv | rs2 | mul | - | none | none | - |
| war | alu_rr, div, mul, mulh, zcmv | rs2 | mulh | - | none | none | - |
| war | alu_rr, div, mul, mulh, zcmv | rs2 | zcmv | - | none | none | - |
| war | alu_rr, div, mul, mulh, zcmv | rs2 | zcpop | - | none | none | - |
| war | alu_rr, div, mul, mulh, zcmv | rs2 | zcpopret | - | none | none | - |
| war | alu_rr, div, mul, mulh, zcmv | rs2 | zcpush | - | none | none | - |
| war | jalr | target | alu_nosrc | - | none | none | - |
| war | jalr | target | alu_ri | - | none | none | - |
| war | jalr | target | alu_rr | - | none | none | - |
| war | jalr | target | csr_i | - | none | none | - |
| war | jalr | target | csr_r | - | none | none | - |
| war | jalr | target | div | - | none | none | - |
| war | jalr | target | jal | - | none | none | - |
| war | jalr | target | jalr | - | none | none | - |
| war | jalr | target | load | - | none | none | - |
| war | jalr | target | mul | - | none | none | - |
| war | jalr | target | mulh | - | none | none | - |
| war | jalr | target | zcmv | - | none | none | - |
| war | jalr | target | zcpop | - | none | none | - |
| war | jalr | target | zcpopret | - | none | none | - |
| war | jalr | target | zcpush | - | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | first | alu_nosrc | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | first | alu_ri | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | first | alu_rr | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | first | csr_i | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | first | csr_r | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | first | div | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | first | jal | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | first | jalr | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | first | load | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | first | mul | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | first | mulh | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | first | zcmv | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | first | zcpop | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | first | zcpopret | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | first | zcpush | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | last | alu_nosrc | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | last | alu_nosrc | x0 | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | last | alu_ri | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | last | alu_ri | x0 | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | last | alu_rr | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | last | alu_rr | x0 | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | last | csr_i | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | last | csr_i | x0 | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | last | csr_r | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | last | csr_r | x0 | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | last | div | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | last | div | x0 | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | last | jal | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | last | jal | x0 | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | last | jalr | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | last | jalr | x0 | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | last | load | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | last | load | x0 | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | last | mul | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | last | mul | x0 | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | last | mulh | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | last | mulh | x0 | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | last | zcmv | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | last | zcmv | x0 | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | last | zcpop | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | last | zcpop | x0 | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | last | zcpopret | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | last | zcpopret | x0 | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | last | zcpush | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, zcmv, zcpop, zcpopret, zcpush | last | zcpush | x0 | none | none | - |

8,436 cases in all, one per subject class, port, producer class and distance; rows identical across subject classes are shown once.  Kinds: raw (a read after a write), war, waw, ctrl (a control transfer ahead), struct (a resource).  Words: "stall n", the reader waits n cycles; "forward 0", the value is forwarded and nothing waits; "bubble n", the fetch after a taken control transfer; "squash 0", an instruction on the wrong path, killed; two words in one cell are the two outcomes (taken / not taken); "none", no cost.

### 4.2 The manual's hazard statements, checked against the structure

| statement (rows) | the manual says | source | grade |
|---|---|---|---|
| raw_*_d1,, raw_*_d2_d1 | forward 0 | rtl/ibex_id_stage.sv 1094-1109 | read |
| raw_rs1_load_d1,, raw_rs2_load_d1,, raw_rs1rs2_load_d1,, raw_addr_load_d1,, raw_data_load_d1,, raw_cmp1_load_d1,, raw_cmp2_load_d1,, raw_target_load_d1,, raw_rs1_load_d1_same_reg,, raw_rs2_load_d1_same_reg,, raw_rs1rs2_load_d1_same_reg | stall 1 | rtl/ibex_id_stage.sv 1102-1111 | read |
| struct_busy_mulh_d1,, struct_busy_mulh_d2 | occupied 2 | rtl/ibex_multdiv_fast.sv 139-140, 200-235 | read |
| struct_busy_div_d1,, struct_busy_div_d2 | occupied 37 | rtl/ibex_multdiv_fast.sv 391-520 | read |
| ctrl_taken_jal_d1,, ctrl_taken_jalr_d1 | bubble 1 | rtl/ibex_id_stage.sv 933-937, 811 | read |
| ctrl_taken_branch_d1 | bubble 1 | rtl/ibex_id_stage.sv 919-930 | read |
| ctrl_taken_trap_d1 | bubble 2 | rtl/ibex_controller.sv 288-294, 819-836, 955-961 | read |
| waw_last_*_d1,, waw_last_*_d2 | ordered 0 | rtl/ibex_wb_stage.sv 102-116, 305-307 | read |
| raw_rs2_load_d1 | forward 0 | rtl/ibex_compressed_decoder.sv 621-760 | read |

### 4.3 Statements of the core's own

What the structure does not derive: each row fires on the trace by its match rule and is applied as a hold.  Width: equal (the trigger is its cause: intent), wider (an interlock firing without its cause: a performance finding), narrower (a cause with no stall), unexplained.

| id | fires when | cost | held in | grade | cause | width | source | evidence |
|---|---|---|---|---|---|---|---|---|
| raw_rs1_load_d1, raw_rs2_load_d1, raw_rs1rs2_load_d1, raw_addr_load_d1, raw_data_load_d1, raw_cmp1_load_d1, raw_cmp2_load_d1, raw_target_load_d1, raw_rs1_load_d1_same_reg, raw_rs2_load_d1_same_reg, raw_rs1rs2_load_d1_same_reg | the expanded cases raw_rs1_load_d1, raw_rs2_load_d1, raw_rs1rs2_load_d1, raw_addr_load_d1, raw_data_load_d1, raw_cmp1_load_d1, raw_cmp2_load_d1, raw_target_load_d1, raw_rs1_load_d1_same_reg, raw_rs2_load_d1_same_reg, raw_rs1rs2_load_d1_same_reg | stall 1 | IDEX | read | - | - | rtl/ibex_id_stage.sv 1102-1111 | stall_ld_hz = outstanding_load_wb_i & (rf_rd_a_hz \| rf_rd_b_hz): a reader of a load's rd at distance 1 waits in ID/EX while the load is in WB, its data included in the response cycle ('this doesn't factor in load data as it arrives too late, such hazards are resolved via a stall', 1105-1106), and reads the register file the cycle after: one cycle on the zero-wait bus, the response's wait on top... |

## 5. The memory side: the bus, the write buffer, misaligned and atomic accesses

Conditions: the bus schedule a test names.  The manual's cycle table is the special case of every request accepted at once and answered the next cycle.

| the memory side | this core | source | grade |
|---|---|---|---|
| bus | ibex-mem | bus/ibex-mem.json | stated |
| data: outstanding | 2 | rtl/ibex_id_stage.sv 1002-1010, 1050-1053, 1086-1087, 1111 | read |
| data: write_buffer | 0 | rtl/ibex_id_stage.sv 1002-1010, 1050-1053, 1086-1087, 1111 | read |
| data: wait_stage | IDEX | rtl/ibex_id_stage.sv 1002-1010, 1050-1053, 1086-1087, 1111 | read |
| data: response_stage | WB | rtl/ibex_id_stage.sv 1002-1010, 1050-1053, 1086-1087, 1111 | read |
| data: split_hold | first_response | rtl/ibex_id_stage.sv 1002-1010, 1050-1053, 1086-1087, 1111 | read |
| data: forward_lag | 0 | rtl/ibex_id_stage.sv 1002-1010, 1050-1053, 1086-1087, 1111 | read |
| data: response_wait_freeze | yes | rtl/ibex_id_stage.sv 1002-1010, 1050-1053, 1086-1087, 1111 | read |
| data: freeze_scope | stage | rtl/ibex_id_stage.sv 1002-1010, 1050-1053, 1086-1087, 1111 | read |
| data: freeze_empty_stage | no | rtl/ibex_id_stage.sv 1004-1006, 1086-1087 | read |
| fetch | model prefetch-buffer; outstanding 2; buffer_words 3 | rtl/ibex_prefetch_buffer.sv, rtl/ibex_fetch_fifo.sv 44, 78, 88, 119-128, 147, 173-175, 194-198, 209-238; fifo 44, 71-73, 87-88, 105-106, 212, 219 | read |
| regions |  | this configuration has no PMP and Ibex has no PMA: one attribution for the whole address space | inferred |
| misaligned | split | load_store_unit.rst 83-90 | stated |

## 6. CSRs and counters: the accesses that wait

Which CSR accesses wait, on what, and for how long.  A CSR instruction reads and writes its CSR in the stages the structure names; the rows here are the core's own statements about CSR order, the counters every retirement updates, and the CSRs with implicit accesses.

*(none)*

## 7. Interrupts and other events: when they are taken and what they cost

The manual states no latency and no taking stage for interrupts; every row here is read from the RTL or measured by the event suites (an test device both the reference and the RTL harness implement raises a line at a counted retirement; the phase sweep crosses every instruction's abandonment boundary one cycle at a time).  Grades are read or inferred until authored.

| field | this core | source | grade |
|---|---|---|---|
| device_base | 0x02010000 | exceptions_interrupts.rst 28-62 | stated |
| priority | 31, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 11, 3, 7 | exceptions_interrupts.rst 28-62 | stated |
| lines.bits | 3, 7, 11, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31 | exceptions_interrupts.rst 28-45 (the table), 56, 61-62 | stated |
| lines.level | yes | exceptions_interrupts.rst 28-45 (the table), 56, 61-62 | stated |
| lines.mip | irq_software_i, irq_timer_i, irq_external_i and irq_fast_i[14:0] reflected in mip bits 3, 7, 11 and 30:16, mie writable for them (cs_registers.rst mie, mip); irq_nm_i, id 31, 'is not visible through the mip CSR' | exceptions_interrupts.rst 28-45 (the table), 56, 61-62 | stated |
| lines.cleared | by the handler at the source: 'it is assumed that the interrupt handler signals completion of the handling routine to the interrupt source, e.g., through a memory-mapped register, which then deasserts the corresponding interrupt line' (a CLEAR at the test device); the core drops nothing | exceptions_interrupts.rst 28-45 (the table), 56, 61-62 | stated |
| gating.rule | a line is taken only with mstatus.MIE set and its mie bit set ('to enable interrupts, both the global interrupt enable (MIE) bit in the mstatus CSR and the corresponding individual interrupt enable bit in the mie CSR need to be set'); 'after reset, all interrupts are disabled'; the NMI 'is enabled independent of the values in the mstatus and mie CSRs'; while an NMI is handled 'all interrupts including the NMI are ignored' and 'nested NMIs are not supported'; 'in Debug Mode, all interrupts including the NMI are ignored' | exceptions_interrupts.rst 47-50, 56-59, 64 | stated |
| nmi.causes.31 | the external NMI, irq_nm_i: mcause 0x8000001F | exceptions_interrupts.rst 56-59, 68-90, 96-101 | stated |
| nmi.trigger | the irq_nm_i line, level-sensitive like every interrupt line; an internal interrupt (a load integrity error, mcause 0xFFFFFFE0) exists only with SecureIbex and is not built here | exceptions_interrupts.rst 56-59, 68-90, 96-101 | stated |
| nmi.imprecise | not stated for the external NMI: it is an interrupt, taken between instructions; the internal one 'will be taken at most one instruction after the faulting load' | exceptions_interrupts.rst 56-59, 68-90, 96-101 | stated |
| nmi.latch | not stated; 'the external NMI takes priority over all internal interrupts', 'entering the handler for an internal interrupt automatically clears the internal interrupt' | exceptions_interrupts.rst 56-59, 68-90, 96-101 | stated |
| nmi.vector | mtvec's base + 0x7C, the 32nd entry of the vector table ('the core jumps to the trap-handler base address (in mtvec) plus 0x7C to handle the NMI'); every interrupt is vectored on this core | exceptions_interrupts.rst 56-59, 68-90, 96-101 | stated |
| nmi.csrs | mepc, mcause (0x8000001F) and mstatus as for a regular interrupt; the previous mstatus.MPP, mstatus.MPIE, mepc and mcause backed up in CSRs software cannot read, for a recoverable NMI ('Recoverable Non-Maskable Interrupt') | exceptions_interrupts.rst 56-59, 68-90, 96-101 | stated |
| sleep.wfi | the core sleeps: core_sleep_o is 'Core in WFI with no outstanding data or instruction accesses'; the conditions beyond that (the enables, debug) are not stated on these pages | exceptions_interrupts.rst 28-62 | stated |
| sleep.wake | 'deasserts if an external event (interrupt or debug req) wakes the core up' | exceptions_interrupts.rst 28-62 | stated |
| sleep.stage | IDEX | exceptions_interrupts.rst 28-62 | stated |
| sleep.stage_note | the wfi executes in ID/EX and leaves it at once; with the writeback stage it passes through WB (one cycle, WB_INSTR_OTHER) and its RVFI retirement is the cycle after that; the sleep states come after: see retires_before_sleep_note (the RTL pass of 29 Oct 2026, ibex-maxperf) | exceptions_interrupts.rst 28-62 | stated |
| sleep.retires_before_sleep | yes | exceptions_interrupts.rst 28-62 | stated |
| sleep.states_after | 2 | exceptions_interrupts.rst 28-62 | stated |
| sleep.wake_latency | 1 | exceptions_interrupts.rst 28-62 | stated |
| sleep.retires_before_sleep_note | the wfi is a special_req_flush_only (ibex_controller.sv 288): DECODE goes to FLUSH the cycle after the wfi's ID/EX cycle, FLUSH to WAIT_SLEEP (969-970), WAIT_SLEEP to SLEEP (601-607).  Counted from the wfi's last stage cycle, its WB cycle (our model's retirement cycle on this build, one after ID/EX), the first asleep cycle is 2 later (states_after 2: FLUSH is the WB cycle's successor... the wfi's ID/EX cycle w, WB w+1, FLUSH w+1 in the controller, WAIT_SLEEP w+2, SLEEP w+3 = (w+1) + 2); halt_if holds the instruction already in IF through all of them.  SLEEP leaves to FIRST_FETCH the cycle after a line is pending (618-619) and in FIRST_FETCH the instruction in IF enters ID/EX (631-634): wake_latency 1 as the base's.  To be checked by the event suite on this build; the base's reading of 29 Oct 2026 is the source of the counts | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.rule | as the base's (ibex_controller.sv 501-503 handle_irq; 702-724 DECODE): a pending request halts IF while `stall \|\| id_wb_pending`, where stall = stall_id_i \| stall_wb_i (1020) and id_wb_pending = instr_valid_i \| ~ready_wb_i (297): with the writeback stage the taking waits for the instruction in ID/EX and for WB to be ready, that is for an outstanding load or store in WB to have its response (ibex_wb_stage.sv 185 ready_wb_o = ~wb_valid_q \| wb_done); then IRQ_TAKEN for one cycle (pc_set to the vector, csr_save_if, csr_save_cause), then DECODE fetches the handler | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.abandoned | nothing in flight is killed: the instruction in ID/EX completes and the one in WB finishes first; the instruction in IF (fetched, not yet in ID/EX) is the one abandoned, its pc the mepc | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.registered | 0 | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.registered_note | as the base's: no register on the line inside the core (mip from the inputs); the harness's test device registers its line, which our model's definition already counts.  To be read on this build's event suite (29 Oct 2026: the base's reading) | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.blanking.after |  | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.blanking.cycles | 0 | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.blanking.note | no blanking term: a load or store in ID/EX holds the taking by its own stall (stall_mem) until its response, as any multi-cycle instruction does | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.blocked_by | flush_in_progress, sleep | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.blocked_by_note | the conditions that defer the taking while they hold: the instruction in ID/EX not done (stall: a multi-cycle unit, a memory response awaited: generic in-order completion, not a separate term), a special request in flight (special_req: an exception, mret, wfi or a flushing CSR write goes through FLUSH first), nmi_mode (no nested NMI while an NMI's handler runs, until its mret), debug mode and single-stepping, the committing micro-ops of a Zcmp sequence (not built: no Zcmp); sleep is the SLEEP state, left to FIRST_FETCH on a pending line (irq_pending_i, enabled by mie whatever mstatus.MIE, or irq_nm).  Read again 29 Oct 2026 (the event suite's first loop round: every taking 2 cycles late in our model, 3 after a flushing CSR write): flush_in_progress is the special request's FLUSH state and the fetch it makes (DECODE's !special_req: an mret, a wfi, a flushing CSR write or an exception goes through FLUSH, the taking waits for the refetched instruction's cycle); the instruction in ID/EX not done is the kills rule (IF alone killed: our model holds IF and counts the taking from the last cycle of the instruction in ID/EX) | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.kills | IF | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.kills_note | IRQ_TAKEN's pc_set drops the instruction in the IF/ID register and the prefetch buffer's contents; ID/EX and WB are not killed: both complete first (our model's kept-stage rule holds IF and counts the taking from the last cycle of the last kept instruction, here the one in WB: with a load or store there, its response cycle; with an ALU instruction, its WB cycle), the decision the cycle after (DECODE's !stall && !id_wb_pending) | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.confirm | 1 | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.confirm_note | IRQ_TAKEN evaluates handle_irq again (lines 728-734: pc_set, csr_save_if and csr_save_cause only if handle_irq): a request withdrawn between DECODE's decision and that cycle is dropped, and the two cycles (DECODE's halt, IRQ_TAKEN) are lost, the instruction in IF entering ID/EX the cycle after (hze-withdrawn-00 koff 1, 29 Oct 2026: the line up for its store's cycle and one more, the RTL and Spike both without the handler, the next instruction 3 cycles after the store) | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.waits_for.IDEX | always | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.waits_for.WB | response | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.waits_for_note | DECODE's wait is stall \|\| id_wb_pending, with id_wb_pending = instr_valid_i \| ~ready_wb_i (ibex_controller.sv 297, 702-724) and ready_wb_o = ~wb_valid_q \| wb_done (ibex_wb_stage.sv): the instruction in ID/EX always completes first, the one in WB only while it is a load or store awaiting its response (wb_done at once for every other class), so the handler's first instruction retires 4 cycles after the ID/EX instruction's last on a non-memory subject, not 5 (the first loop round of 29 Oct 2026: every entry RTL +4, our model +5 with the kept-stage rule counting WB's cycle) | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.zcmp.abandon.zcpush | always | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.zcmp.abandon.zcpop | always | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.zcmp.abandon.zcpopret | loads | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.zcmp.atomic | zcmv | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.zcmp.rule | Zcmp.  An interrupt signaled while a push expands, or while a pop's loads are in flight (before its commit sequence, the sp update), flushes the Zcmp state machine: the partial sequence is abandoned, the handler runs, and the sequence restarts from its first micro-op after the mret (the micro-ops already executed are paid again; restarting is safe, the memory is idempotent and sp is adjusted last).  From a pop's sp update to its return jump (cm.pop: the addi alone; cm.popret / cm.popretz: the addi, the a0 clear, the jalr) and for the whole of a move, interrupts are suppressed: the taking waits for the sequence's end.  The model: a sequence of an `abandon` class is killed by the taking while it is in its abandonable part (`always`: every micro-op; `loads`: the first nreg micro-ops) and fetched again behind the handler, so the taking waits only for the stage's other instructions; an `atomic` class, and a sequence past its abandonable part, holds the taking as any multi-cycle instruction in ID/EX does (waits_for IDEX always) | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.zcmp.status | read on the event suite, 3 Nov 2026 (hze- and hzeu-zc*-00 on ibex-maxperf and ibex-pmp).  A push and a pop: flushed and re-run after the handler at every phase of the sweep, with a device store ahead (the SET blocks: the handler's first instruction 5 + phase cycles after the store) and without (the ARM blocks): `always`, our model's one-cycle wait then the kill, 0 differ on hze-zcpush-00, hze-zcpop-00 and the U forms.  A popret or popretz: the SET blocks agree with the same rule; the ARM blocks do not: the RTL completes the sequence (a popretz {ra, s0-s2} +7) and takes the interrupt 4 cycles after it whatever the phase, where our model kills it (12 ARM blocks per file differ, 36 intervals).  Left as read: the term that keeps a popret from being flushed once under way with no store ahead of it (its return jump, or the LSU's state) is a question for the RTL pass; `unissued` (abandon only before the first grant) was tried and fits the ARM blocks but not the SET ones, where our model grants the first load while the RTL holds it behind the device store  CORRECTED 3 Nov 2026, 18:55, from the RTL pass of that evening (the RTL questions zcmp_commit_irq_hold; ibex_controller.sv 495-503 handle_irq's `!(instr_gets_expanded_i == INSTR_EXPANDED_COMMIT)`, ibex_compressed_decoder.sv 746, 762): a popret's or popretz's sp addi and a0 clear are INSTR_EXPANDED_COMMIT, the jalr INSTR_EXPANDED_LAST, so a line that rises while any of them is in ID/EX is taken after the sequence and only a line that rises on a load micro-op abandons: the field should become `loads` for zcpopret; TRIED 18:44 and reverted to `always` 18:50: our model's `loads` mode tests the micro-op index at our model's check cycle, not at the cycle the RTL's controller sees the line, so the SET blocks (the rise on a load) went wrong too (33 differ against 36 on hze-zcpopret-00): the exact rule, abandon when a load micro-op is in ID/EX at the RTL's decision cycle and hold through the commit micro-ops, BUILT 3 Nov 2026 evening: our model records a sequence's micro-op index per cycle (uop_at) and `loads` reads it at the decision cycle R + registered + 1 (decision_cycle: the harness device raises the line at R, the core's controller sees it the cycle after; the ARM p11 block, 13 loads at phase 11, put the 13th load at R and the sp addi at R + 1, and the RTL held), so the SET blocks (the rise on the last load) abandon and the ARM blocks (the rise on the sp addi) hold; zcpopret `loads` from then.  A pop and a push stay `always`: their sp addi is INSTR_EXPANDED_LAST (ibex_compressed_decoder.sv 751-755), so a rise on it completes the sequence either way.  The armed popretz blocks differed because the sweep pairs phase p with an rlist of p + 1 registers, which lands the rise on the sp addi in every block. | exceptions_interrupts.rst 28-62 | stated |
| taking.nmi.rule | irq_nm_i (irq_nm, with the internal integrity NMI not built) is taken as an interrupt by the same path, outside mstatus.MIE and mie, unless nmi_mode_q (an NMI's handler running) or debug; IRQ_TAKEN sets exc_cause ExcCauseIrqNm (mcause 0x8000001F), enters nmi_mode, and the vector is mtvec base + 0x7C; nmi_mode ends at the handler's mret (FLUSH: nmi_mode_d = 0) | exceptions_interrupts.rst 28-62 | stated |
| taking.nmi.abandoned | as an interrupt: the instruction in IF | exceptions_interrupts.rst 28-62 | stated |
| taking.nmi.registered | 0 | exceptions_interrupts.rst 28-62 | stated |
| taking.nmi.kills | IF | exceptions_interrupts.rst 28-62 | stated |
| latency.interrupt_entry.fetch | 3 | exceptions_interrupts.rst 28-62 | stated |
| latency.interrupt_entry.fetch_note | the handler's first instruction answered by the memory 3 cycles after the last cycle of the last kept instruction (the one in WB): DECODE sees ID/EX empty and WB ready (1), IRQ_TAKEN sets the pc and the prefetch buffer requests in that cycle (2), the zero-wait memory answers (3); it is in ID/EX the cycle after, in WB the cycle after that.  With the branch target ALU the vector table's jal holds ID/EX one cycle (the base's two), then WB: the handler's first retirement is 5 cycles after the previous retirement on a single-cycle subject as on the base, by a different sum (3 + 1 + 1 against 3 + 2).  To be checked by the event suite on this build | exceptions_interrupts.rst 28-62 | stated |
| latency.interrupt_entry.cycles | 7 | exceptions_interrupts.rst 28-62 | stated |
| latency.interrupt_entry.from | the base's reading (hze-alu_nosrc-00 of 29 Oct 2026: raise 59, the store's RVFI 61, the handler's jal's RVFI 66); the same count expected here by the sum above, to be measured by the event suite on this build | exceptions_interrupts.rst 28-62 | stated |
| latency.interrupt_entry.state | the maxperf configuration, zero-wait memory, every interrupt vectored | exceptions_interrupts.rst 28-62 | stated |

## 8. What real programs pay on this core: the cycles lost to stalls, by cause

Measured by the timing survey: every retirement of every trace read as a timing skeleton (our timing-skeleton definition; the window 3 retirements before the subject) over 53,323,676 retirements of the generated suites, the certification tests and the benchmarks.  The manual has no equivalent.

| measure | value |
|---|---|
| cycles per retirement, the programs' single-cost skeletons (43,560,978 of the 48,148,382 retirements of the certification tests and the benchmarks, 90%) | 43,560,978 retirements, 52,372,837 cycles: CPI 1.202 (IPC 0.83) |
| real code's shapes no generated suite makes | 18.2% of the programs' retirements (by class) |

The cycles-per-retirement row covers the architecture certification tests and the benchmarks, over the retirements whose timing skeleton has a single cost; the whole-program CPI and IPC per benchmark suite are in the README beside this document.

What an ideal mechanism would save, as a ceiling and not a design (the profile summary carries the caveats):

| mechanism (the ideal, not a design) | retirements affected | upper bound on cycles saved | of the 52,372,837 single-cost cycles |
|---|---:|---:|---:|
| a perfect branch prediction: the follower of a taken branch at 1 cycle | 2,529,107 | 2,560,355 | 4.9% |
| jump targets resolved in IF: the follower of a jal or jalr at 1 cycle | 1,750,295 | 1,862,399 | 3.6% |
| no load-use bubble | 758,470 | 758,470 | 1.4% |
| no extra cycle at a pc+2 target | 716,087 | 716,087 | 1.4% |
| `mulhu` at one cycle | 2 | 2 | 0.0% |

## 9. Where the RTL and the manual differ: the anomalies we found

Each row is a finding: what the manual says, what the RTL measured, the class (intent: the trigger is its cause and the manual is behind; over-wide: an interlock firing without its cause; narrower; function), its cost, and whose it is to act on (the documentation, the RTL, or the core's performance).  The reproducer, the two traces and the run's facts are in the issue directory named.

| finding | for | class | cost | found on | status | issue directory |
|---|---|---|---|---|---|---|
| The RVFI's pc_wdata of an odd jalr target keeps bit 0 under the branch target ALU | rtl | function | none in execution; a trace consumer that trusts rvfi_pc_wdata (a cosimulation comparing the next pc, as ours) sees a mismatch on every odd-target jalr under Bra | ibex-maxperf | open; to file | [issues/rvfi-jalr-target-bit0-btalu/](issues/rvfi-jalr-target-bit0-btalu/) |

## 10. What the base build's rows leave to a configuration, and what no test reaches

Every stall and flush term in the RTL source that the base build's own rows do not state is listed here, with where it is handled.  Of the 25 terms: 7 are stated and tested under a configuration of the core (its part of section 12) or became rows of this specification after the source was read -- not gaps, pointers; 9 no test of ours will reach, each with its reason; 9 await a feature we have not built.  Beside the terms, our reading of the RTL source raised 22 questions the manual does not answer (9 on the base build, 8 on the maxperf build with B full, PMP and the instruction cache, 5 on the maxperf build with B full and PMP): 13 are answered by a measurement and stated above; 9 are still open (5 on the base build, 1 on the maxperf build with B full, PMP and the instruction cache, 3 on the maxperf build with B full and PMP) and head the table in 10.2.  A row in 10.2 is a hole in the specification, named rather than hidden.

### 10.1 Specified under a configuration

| term | what it is | where it is stated |
|---|---|---|
| `valid_new_req` | the prefetch buffer's request rule (NUM_REQS 2 outstanding, a new request with room in the FIFO or on a branch, the request held until granted) and its fifo_clear on every redirect are not elaborated on this build: gen_icache replaces the module, and the cache's own request stream (lookup_req_ic0, fill_ext_req, instr_req) takes its place -- the questions fetch_disabled_stream and fetch_miss_* (answered) and the correction memory.fetch.model (taken).  RTL_CTRL lists the file; the check requires it in rtl.files | covered on ibex-pmp: ICache = 0 there: its stated entry valid_new_req (memory.fetch.outstanding 2), inherited from ibex-maxperf's, and the fetch model fetchmodel.py checked under the fetch rotation on 3-4 Nov 2026 |
| `DEPTH` | the three-entry FIFO (DEPTH = NUM_REQS + 1) and its valid_unaligned rule for an uncompressed instruction at a half-word address are not elaborated on this build; the cache's fill buffers hold the words (two beats per line, up to four lines) and its 16-bit skid buffer takes the misaligned case (the stated entry skid_ready).  RTL_CTRL lists the file; the check requires it in rtl.files | covered on ibex-pmp: ICache = 0 there: its stated entry DEPTH (memory.fetch.buffer_words 3, penalties.misaligned_target 1), inherited from ibex-maxperf's |
| `gen_no_stall_mem` | the two-stage branch: a load or store held in ID/EX to its response (stall_mem with ~lsu_resp_valid_i \| instr_first_cycle), no load-use hazard, no forwarding, stall_wb tied 0, instr_executing = instr_executing_spec; this build elaborates gen_stall_mem (the stated entries stall_mem, stall_ld_hz, outstanding_memory_access, stall_wb) | covered on ibex: WritebackStage = 0 there: its stated entry stall_mem (occupancy.load 2 on the zero-wait bus, wait and response both in IDEX) |
| `g_no_wb_exceptions` | the exception priority without the writeback stage (the fetch error first, the LSU's errors after the ID/EX exceptions) and wb_exception_o tied 0; this build elaborates g_wb_exceptions (300-338: WB's store and load errors first, wb_exception_o killing the instruction in ID/EX) and g_writeback_mepc_save (836-843) | covered on ibex: WritebackStage = 0 there: its stated entry special_req_pc_change names the g_no_wb_exceptions order |
| `g_branch_set_flop` | the registered branch_set_raw_q of a core without the branch target ALU (or in fixed-time mode): the taken branch's redirect in its second cycle; this build elaborates g_branch_set_direct (764-767), the stated entries stall_branch and stall_jump; g_nobtalu's full immediate mux (406-436) likewise | covered on ibex: BranchTargetALU = 0 there: its stated entries stall_branch (occupancy.branch taken 2, redirect last) and stall_jump (occupancy.jal 2, redirect first) |
| `gen_mult_fast` | the fast multiplier's ALBL, ALBH, AHBL, AHBH sequence (a mul in 3 cycles, a mulh in 4); this build elaborates gen_mult_single_cycle (the stated entry mult_state_q: mul 1, mulh 2).  RV32MSlow's ibex_multdiv_slow.sv and RV32MNone are not instantiated on any configuration here | covered on ibex: RV32M = RV32MFast there: its stated entry mult_state_q (occupancy.mul 3, occupancy.mulh 4) |
| `pmp_err_q` | a PMP refusal of a data access is registered in the address phase and consumed as an error without a bus transaction (data_pmp_err_i); without PMP the input is tied low inside ibex_core; the fetch side's pmp_err_if_i (ibex_if_stage.sv 427-431) likewise. | covered on ibex-pmp: PMPEnable = 1 with 16 regions there: its questions pmp_fault_lsu_aligned, pmp_fault_lsu_misaligned_first, pmp_fault_lsu_misaligned_second and pmp_fault_fetch, its specification's memory.pmp.fault_cycles 2 and control.flush trap_lsu 'WB+2' (the findings pmp-fault-two-cycles, pmp-fault-wb-entry-four-cycles, 31 Oct 2026) |

### 10.2 Not reached, and why

| core | what | why | reach | RTL |
|---|---|---|---|---|
| ibex-maxperf | open question `data_err_fault` | data_err_i with data_rvalid_i (ibex_load_store_unit.sv 703-709: data_or_pmp_err, lsu_err_q for the first half of a split access) raises load_err_i or store_err_i, exc_req_lsu, a special_req_pc_change with no instr_valid_i needed; store_err_q / load_err_q take the priority over every ID/EX exception (315-318); FLUSH sets the pc to the exception vector with ExcCauseLoadAccessFault or ExcCauseStoreAccessFault and mtval = lsu_addr_last_i (the faulting part's address), mepc from pc_wb_i (csr_save_wb_o) | open | rtl/ibex_controller.sv:276-277, 283-294, 300-338, 819-843 |
| ibex-maxperf | open question `fetch_err_trap` | instr_err_i with the fetched word (ibex_if_stage.sv 282, through the FIFO's err entries, carried in the IF/ID register as instr_fetch_err_o) makes the instruction an exception request (ExcCauseInstrAccessFault, mtval the faulting pc or pc + 2 for the second half of an unaligned instruction) and keeps it from executing (instr_executing_spec's ~instr_fetch_err_i, ibex_id_stage.sv 1046; instr_kill, 1024) | open | rtl/ibex_controller.sv:234, 269-273, 852-866 |
| ibex-maxperf | open question `ebreak_debug_entry` | an ebreak with dcsr.ebreakm set in M-mode or dcsr.ebreaku set in U-mode (ebreak_into_debug, from the dcsr fields by priv_mode_i) enters debug mode through DBG_TAKEN_ID rather than taking the breakpoint exception | open | rtl/ibex_controller.sv:484-486, 522-523, 877-886 |
| ibex-maxperf | open question `debug_req_entry` | a debug request (debug_req_i) or a single step (do_single_step_d) enters DBG_TAKEN_IF once the instruction in ID/EX has finished and WB is ready, saving the IF pc to dpc; it takes priority over an interrupt in the same cycle (708-714) | open | rtl/ibex_controller.sv:459-480, 702-713, 767-786 |
| ibex-maxperf | open question `zcmp_commit_irq_hold` | handle_irq = ~debug_mode_q & ~debug_single_step_i & ~nmi_mode_q & (irq_nm \| (irq_pending_i & irq_enabled)) & !(instr_gets_expanded_i == INSTR_EXPANDED_COMMIT): the NMI is held by the same term; with handle_irq low DECODE's halt_if (703-705) and its IRQ_TAKEN entry (714-723) are not taken and the IF stage hands the next micro-op to ID | open | rtl/ibex_controller.sv:495-503, 701-724 |
| ibex-icache | open question `fetch_ecc_error_refetch` | ecc_err_ic1 = lookup_valid_ic1 & (((\|data_err_ic1) & tag_hit_ic1) \| (\|tag_err_ic1)); ecc_correction_ways_d, ecc_correction_write_d = ecc_err_ic1 registered into ecc_write_req, ecc_write_ways, ecc_write_index; ecc_error_o = ecc_err_ic1 | open | rtl/ibex_icache.sv:546-600, 645-651 |
| ibex-pmp | open question `pmp_fault_lsu_misaligned_first` | WAIT_GNT_MIS leaving on data_gnt_i \|\| pmp_err_q; WAIT_RVALID_MIS's data_rvalid_i \|\| pmp_err_q branch with lsu_err_d = data_bus_err_i \| pmp_err_q and pmp_err_d = data_pmp_err_i for the second part | open | rtl/ibex_load_store_unit.sv:495-507, 509-538 |
| ibex-pmp | open question `pmp_fault_lsu_misaligned_second` | pmp_err_d = data_pmp_err_i for the second part in WAIT_RVALID_MIS (518) and WAIT_RVALID_MIS_GNTS_DONE (560); WAIT_GNT leaving on pmp_err_q | open | rtl/ibex_load_store_unit.sv:509-538, 540-551, 553-571 |
| ibex-pmp | open question `pmp_fault_zcmp_uop` | the FSM's arms CmIdle, CmPushStoreReg, CmPushDecrSp, CmPopLoadReg, CmPopIncrSp, CmPopZeroA0, CmPopRetRa advance on id_in_ready_i; cm_state_q <= flush_expanded_i ? CmIdle : cm_state_d, flush_expanded being the IF stage's pc_set_i & (pc_mux_i == PC_EXC) (ibex_if_stage.sv 483-484), which a PMP data fault's trap raises from FLUSH (ibex_controller.sv 819-836) after the LSU's pmp_err_q response (ibex_load_store_unit.sv 473-492, 540-551, 703-709) | open | rtl/ibex_compressed_decoder.sv:621-760, 893-898 |
| ibex-icache | not built: `ic_scr_key_valid_i` | AWAIT_SCRAMBLE_KEY waits for the key provider: OUT_OF_RESET and every invalidation request raise ic_scr_key_req_o when the key is not valid and the walk starts only when it is. | awaiting a feature: our records Ibex step 5: ibex-opentitan (ICacheScramble 1) with the key handshake in the harness answering scramble_req_o after a programmable number of cycles | rtl/ibex_icache.sv:1228-1247 |
| ibex-maxperf | not built: `data_ind_timing_i` | cpuctrlsts.data_ind_timing reads as zero without SecureIbex (ibex_cs_registers.sv 1900-1903): a branch's fixed two cycles whatever its condition (the g_branch_set_flop arm, 787) and the divider's full sequence on a zero divisor (ibex_multdiv_fast.sv 434, 445) are not built here | awaiting a feature: our records and our records: the data-independent-timing promise on the ibex-opentitan configuration (SecureIbex = 1) | rtl/ibex_id_stage.sv:918-926 |
| ibex-maxperf | not built: `icache_enable_i` | gen_icache: the instruction cache in place of the prefetch buffer, with its hit and miss timing and the fence.i invalidation (icache_inval_i); the prefetch buffer is built here (gen_prefetch_buffer) | awaiting a feature: our records, the cores table and step 10: ibex-icache (ICache = 1, ICacheECC = 1) from ibex-pmp, then ibex-opentitan | rtl/ibex_if_stage.sv:299-398 |
| ibex-maxperf | not built: `instr_intg_err` | the integrity check of fetched words (MemECC = SecureIbex) and of data responses (ibex_load_store_unit.sv 378-398): an integrity error is a fetch error or an internal NMI; not built, the harness's intg inputs tied 0 | awaiting a feature: our records: the ibex-opentitan configuration, the harness producing the integrity bits | rtl/ibex_if_stage.sv:275-283 |
| ibex-maxperf | not built: `irq_nm_int` | g_intg_irq_int (MemECC = SecureIbex): a load or store response with an integrity error sets mem_resp_intg_err_irq_pending_q, the internal NMI (irq_nm = irq_nm_ext_i \| irq_nm_int, 490), taken by IRQ_TAKEN's NMI branch with the cause NMI_INT_CAUSE_ECC and mtval the access's address (739-746), cleared on entering its handler unless the external NMI is also up; g_no_intg_irq_int (440-449) ties irq_nm_int to 0 here, so the NMI is the external line alone (events.nmi.trigger) | awaiting a feature: our records: the ibex-opentitan configuration with SecureIbex = 1 | rtl/ibex_controller.sv:394-449, 490 |
| ibex-pmp | not built: `data_ind_timing_i` | cpuctrlsts.data_ind_timing reads as zero without SecureIbex: a branch's fixed two cycles whatever its condition and the divider's full sequence on a zero divisor are not built here | awaiting a feature: our records on the ibex-opentitan configuration (SecureIbex = 1): the data-independent-timing promise | rtl/ibex_id_stage.sv:918-926 |
| ibex-pmp | not built: `icache_enable_i` | gen_icache: the instruction cache in place of the prefetch buffer, with its hit and miss timing and the fence.i invalidation; the prefetch buffer is built here | awaiting a feature: our records (the cache round moved there 3 Nov 2026 from ibex-opentitan-PLAN part C): the ibex-icache configuration (ICache = 1) | rtl/ibex_if_stage.sv:299-398 |
| ibex-pmp | not built: `instr_intg_err` | the integrity check of fetched words (MemECC = SecureIbex) and of data responses (ibex_load_store_unit.sv 393-397): an integrity error is a fetch error or an internal NMI; not built, the harness's intg inputs tied off | awaiting a feature: our records: the ibex-opentitan configuration (the harness producing the integrity bits) | rtl/ibex_if_stage.sv:275-283 |
| ibex-pmp | not built: `illegal_csr` | without PMP every access to pmpcfg0-3 and pmpaddr0-15 (and mseccfg, 502-518) is an illegal instruction, where pmp.rst 19 says the registers read as zero: the plan's undocumented item 1, read on the PMP-less build as the record's pmp-disabled-csrs-illegal (ibex/the record, found_on ibex, 31 Oct 2026); here PMPEnable = 1 and the branch is dead, the registers are read and written (1360-1528) | awaiting a feature: our records part B findings and decision 7 (a): PMPEnable=0's illegal CSR accesses against 'read as zero', with Spike at 0 regions trapping alike on ibex and ibex-maxperf; the record's entry pmp-disabled-csrs-illegal (found_on ibex) carries the reading | rtl/ibex_cs_registers.sv:705-714 |
| ibex-icache | not built: `cache_cnt_q` | gen_caching_logic: allocate only a redirect's target line and CACHE_AHEAD = 2 lines after it (fill_cache_new gated by branch_i \| cache_cnt_q); this build elaborates gen_cache_all (687-691: every miss allocates, the stated entry lookup_actual_ic0). | out: no build of Ibex reaches it: the parameter is the module's alone, not passed by ibex_if_stage.sv 301-307 or ibex_top.sv; the specification's replacement and fill rules are the allocate-everything ones | rtl/ibex_icache.sv:666-686 |
| ibex-maxperf | not built: `nt_branch_mispredict_o` | the static predictor's taken-by-default and its mispredict (ibex_if_stage.sv 238-239, 285-293, the skid buffer 736-840): the predictor is experimental and off in every configuration run here | out: our records, the configurations table: experimental-branch-predictor is not run | rtl/ibex_controller.sv:684-698 |
| ibex-maxperf | not built: `stall_dummy_instr` | gen_dummy_instr: dummy instructions inserted between real ones (DummyInstructions = SecureIbex), the IF stage stalled for each; off here, and left off by cpuctrlsts.dummy_instr_en on the secure configuration too | out: our records and the configurations table: dummy instructions stay off on every configuration (timing noise by design) | rtl/ibex_if_stage.sv:544-590 |
| ibex-maxperf | not built: `cheriot_enable_i` | the CHERIoT capability accesses (CTX_WAIT_GNT1, CTX_WAIT_GNT2, CTX_WAIT_RESP) and the cheriot_* exception terms (ibex_controller.sv 209-220, 237-249, 269-273) exist only with BaseIsa = BaseIsaRV32IorCHERIoT and cheriot_enable_i On; the writeback stage's cheriot terms (ibex_wb_stage.sv 115-116, 190-196) are tied off with them, as is the compressed decoder's refusal of every Zcmp instruction in CHERIoT mode (ibex_compressed_decoder.sv 614-620); the harness ties cheriot_enable_i Off | out: our records, the other lowRISC cores: a CHERIoT round needs the CHERIoT Sail model as its reference and is not planned; the opentitan build carries the logic with cheriot_enable_i tied off | rtl/ibex_load_store_unit.sv:436-473, 573-616 |
| ibex-maxperf | not built: `trigger_match_i` | a hardware breakpoint's trigger match enters debug mode (DBG_CAUSE_TRIGGER, enter_debug_mode's second term 479-480); no trigger is built (ibex_cs_registers.sv 1874-1879: trigger_match_o = 0) and the trigger CSRs are illegal (the stated entry illegal_csr_insn_o) | out: debug is deferred by the user; the harness ties debug_req_i off | rtl/ibex_controller.sv:515-519 |
| ibex-pmp | not built: `nt_branch_mispredict_o` | the static predictor's taken-by-default and its mispredict (ibex_if_stage.sv 238-239, 285-293): the predictor is experimental and off in every configuration run here | out: our records, the configurations table: experimental-branch-predictor is not run | rtl/ibex_controller.sv:684-698 |
| ibex-pmp | not built: `stall_dummy_instr` | gen_dummy_instr: dummy instructions inserted between real ones (DummyInstructions = SecureIbex); off here | out: our records: left off (cpuctrlsts.dummy_instr_en) on the secure configuration too | rtl/ibex_if_stage.sv:544-590 |
| ibex-pmp | not built: `cheriot_enable_i` | the CHERIoT capability accesses and the cheriot_* exception terms (ibex_controller.sv 209-220, 269-273) exist only with BaseIsa = BaseIsaRV32IorCHERIoT and cheriot_enable_i high; the writeback stage's cheriot terms (ibex_wb_stage.sv 115-116, 190-196), the PMP's CHERIoT gates (ibex_core.sv 1598-1602, 1635-1639: the check off and its CSRs illegal, ibex_cs_registers.sv 705-706, when CHERIoT is on) and the compressed decoder's refusal of every Zcmp instruction in CHERIoT mode (ibex_compressed_decoder.sv 614-620) are tied off with them | out: our records, the other lowRISC cores: a CHERIoT round needs the CHERIoT Sail model as its reference; the opentitan build carries the logic with cheriot_enable_i tied off | rtl/ibex_load_store_unit.sv:436-473, 573-616 |
| ibex-pmp | not built: `trigger_match_i` | a hardware breakpoint's trigger match enters debug mode (DBG_CAUSE_TRIGGER); no trigger is built | out: debug is deferred by the user; the harness ties debug_req_i off | rtl/ibex_controller.sv:515-519 |

## 11. How far this specification has been checked: the evidence behind it

| measure | value |
|---|---|
| timing skeletons measured by the search beyond the generated suites, by class | 3,383 |
| learner runs / blocks | 1 / 116 |
| direct crosses / blocks | 0 / 0 |
| blocks whose interval differed from this specification's prediction | 0 |
| findings in the record | 1 (1 rtl) |

Our generated test suites run against this specification's prediction at every retirement on every regression; their counts and coverage are in the README beside this document.  Deliberate faults injected into the RTL (the timing and functional mutation campaign) prove the suites see what they claim.

## 12. The configurations: what each build adds or changes

A configuration, or build, is one setting of the RTL's own parameters: the interrupt controller mode, the memory attribute regions, which ISA extensions are present.  For each one we build the RTL afresh under Verilator with those parameters, configure the reference simulator to the matching ISA and memory map, and run the same generated suites and benchmarks that apply to it, through the same testbench, comparing every retirement as for the base build.  Each configuration's part of this specification holds only what differs from the base: a statement it adds or overrides, a change to the interrupt or pipeline model, the anomalies found on it.  What is not listed is the base core's, and holds for the configuration too.

### ibex-icache: the maxperf build with B full, PMP and the instruction cache

Its pipeline model changes: the memory side (the regions: the hole past the memory, the I/O window, what is bufferable); the control side (flushes and redirects); code_writable.

### ibex-pmp: the maxperf build with B full and PMP

Its pipeline model changes: the memory side (the regions: the hole past the memory, the I/O window, what is bufferable); the control side (flushes and redirects).

© 2026 processor-timing-anomalies, Apache License 2.0
