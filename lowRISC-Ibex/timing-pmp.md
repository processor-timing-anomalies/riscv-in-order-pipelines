# Our accurate, complete timing specification for the Ibex maxperf build with B full and PMP

Generated from our records of the Ibex maxperf build with B full and PMP on 1 November 2026, for the RTL at commit `c0c07085791e4d16a0f2d9a753b2fb79d72e5ffa`; the configurations measured: none.  The timing is as measured on that commit; the document is regenerated after every run we record.

This document states what the ibex-pmp core promises in time: the pipeline as a structure, the cycle each instruction class takes, the stalls and bubbles between instructions, the memory side under a stated bus, the CSR accesses that wait, the interrupts and other events, what real programs pay on it, and where the RTL and the user manual disagree.  It is the rendering of our internal machine-readable version of the RISC-V ISA, this core's layer distilled from its user manual with a citation or a graded reading on every field, a configuration layer for each variant, and the RTL read only to answer what the manual leaves open.  It describes the implementation as measured; a row graded inferred or read is not design intent until the core's authors take it as theirs (the grade authored).

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
| stages | IF IDEX WB | - | - |
| register ports read in | rs1: IDEX, rs2: IDEX, store_data: IDEX, branch_cmp: IDEX, jalr_target: IDEX, mem_base: IDEX, csr: IDEX | - | - |
| results written | rd: WB | - | - |
| result available, per class | alu_rr: IDEX, alu_ri: IDEX, alu_nosrc: IDEX, load: WB, store: WB, branch: IDEX, jal: IDEX, jalr: IDEX, csr_r: IDEX, csr_i: IDEX, mul: IDEX, mulh: IDEX, div: IDEX, system: IDEX, trap: IDEX | - | - |
| occupancy, per class (cycles beyond the first in the stage named) | mul: 1; mulh: 2; div: default 2 to 37; rule 2 if rs2 == 0 else 37; load: default 1; misaligned 2; store: default 1; misaligned 2; jal: default 1; redirect first; jalr: default 1; redirect first; branch: default 1; taken 1; redirect first; fence.i: default 1; redirect first | - | - |
| forwarding paths | none | - | - |
| control transfers resolved in | jump IDEX, branch IDEX, trap IDEX; flushes: fence.i from IDEX, mret from IDEX+1, trap from IDEX+1, csr_write_of * except mscratch mepc from IDEX+1 prefetched, trap_lsu from WB+2 | - | - |
| register file | write before read | - | - |

## 2. Cycle counts per instruction class: the base cost of every instruction

The cycles an instruction of each class takes in its result stage beyond the one every instruction takes (its occupancy), with no hazard and no bus wait; the manual's table "Cycle counts per instruction type" is the source where one is given.

| class | occupancy | instructions | members |
|---|---:|---:|---|
| mul | 1 | 2 | c.mul, mul |
| mulh | 2 | 3 | mulh, mulhsu, mulhu |
| div | default 2 to 37; rule 2 if rs2 == 0 else 37 | 4 | div, divu, rem, remu |
| load | default 1; misaligned 2 | 10 | c.lbu, c.lh, c.lhu, c.lw, c.lwsp, lb, lbu, lh ... |
| store | default 1; misaligned 2 | 7 | c.sb, c.sh, c.sw, c.swsp, sb, sh, sw |
| branch | default 1; taken 1; redirect first | 8 | beq, bge, bgeu, blt, bltu, bne, c.beqz, c.bnez |
| jalr | default 1; redirect first | 3 | c.jalr, c.jr, jalr |
| jal | default 1; redirect first | 3 | c.j, c.jal, jal |
| csr_r | 0 | 3 | csrrc, csrrs, csrrw |
| csr_i | 0 | 3 | csrrci, csrrsi, csrrwi |
| alu_rr | 0 | 39 | add, and, andn, bclr, bext, binv, bset, c.add ... |
| alu_ri | 0 | 36 | addi, andi, bclri, bexti, binvi, brev8, bseti, c.addi ... |
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
| ctrl | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, trap | - | branch | - | bubble 1 / squash 0 | - | - |
| ctrl | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, trap | - | jal | - | bubble 1 / squash 0 | - | - |
| ctrl | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, trap | - | jalr | - | bubble 1 / squash 0 | - | - |
| ctrl | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, trap | - | trap | - | bubble 2 / squash 0 | - | - |
| raw | load, store | addr | alu_nosrc | - | forward 0 | none | - |
| raw | load | addr | alu_nosrc | same_reg | forward 0 | none | - |
| raw | load, store | addr | alu_nosrc | x0 | none | none | - |
| raw | load, store | addr | alu_ri | - | forward 0 | none | - |
| raw | load | addr | alu_ri | same_reg | forward 0 | none | - |
| raw | load, store | addr | alu_ri | x0 | none | none | - |
| raw | load, store | addr | alu_rr | - | forward 0 | none | - |
| raw | load | addr | alu_rr | same_reg | forward 0 | none | - |
| raw | load, store | addr | alu_rr | x0 | none | none | - |
| raw | load, store | addr | csr_i | - | forward 0 | none | - |
| raw | load | addr | csr_i | same_reg | forward 0 | none | - |
| raw | load, store | addr | csr_i | x0 | none | none | - |
| raw | load, store | addr | csr_r | - | forward 0 | none | - |
| raw | load | addr | csr_r | same_reg | forward 0 | none | - |
| raw | load, store | addr | csr_r | x0 | none | none | - |
| raw | load, store | addr | div | - | forward 0 | none | - |
| raw | load | addr | div | same_reg | forward 0 | none | - |
| raw | load, store | addr | div | x0 | none | none | - |
| raw | load, store | addr | jal | - | forward 0 | none | - |
| raw | load | addr | jal | same_reg | forward 0 | none | - |
| raw | load, store | addr | jal | x0 | none | none | - |
| raw | load, store | addr | jalr | - | forward 0 | none | - |
| raw | load | addr | jalr | same_reg | forward 0 | none | - |
| raw | load, store | addr | jalr | x0 | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, mul, mulh | addr | load | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store | addr | load | x0 | none | none | - |
| raw | load | addr | load | - | forward 0 / stall 1 | none | - |
| raw | load | addr | load | same_reg | forward 0 | none | - |
| raw | store | addr | load | - | stall 1 | none | - |
| raw | load, store | addr | mul | - | forward 0 | none | - |
| raw | load | addr | mul | same_reg | forward 0 | none | - |
| raw | load, store | addr | mul | x0 | none | none | - |
| raw | load, store | addr | mulh | - | forward 0 | none | - |
| raw | load | addr | mulh | same_reg | forward 0 | none | - |
| raw | load, store | addr | mulh | x0 | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | addr | store | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | addr | store | x0 | none | none | - |
| raw | branch | cmp1 | alu_nosrc | - | forward 0 | none | - |
| raw | branch | cmp1 | alu_nosrc | x0 | none | none | - |
| raw | branch | cmp1 | alu_ri | - | forward 0 | none | - |
| raw | branch | cmp1 | alu_ri | x0 | none | none | - |
| raw | branch | cmp1 | alu_rr | - | forward 0 | none | - |
| raw | branch | cmp1 | alu_rr | x0 | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | cmp1 | branch | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | cmp1 | branch | x0 | none | none | - |
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
| raw | branch | cmp2 | alu_nosrc | - | forward 0 | none | - |
| raw | branch | cmp2 | alu_nosrc | x0 | none | none | - |
| raw | branch | cmp2 | alu_ri | - | forward 0 | none | - |
| raw | branch | cmp2 | alu_ri | x0 | none | none | - |
| raw | branch | cmp2 | alu_rr | - | forward 0 | none | - |
| raw | branch | cmp2 | alu_rr | x0 | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | cmp2 | branch | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | cmp2 | branch | x0 | none | none | - |
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
| raw | csr_i, csr_r, trap | csr | csr_i | - | forward 0 | none | - |
| raw | csr_i, csr_r, trap | csr | csr_r | - | forward 0 | none | - |
| raw | csr_i, csr_r, trap | csr | trap | - | forward 0 | none | - |
| raw | store | data | alu_nosrc | - | forward 0 | none | - |
| raw | store | data | alu_nosrc | x0 | none | none | - |
| raw | store | data | alu_ri | - | forward 0 | none | - |
| raw | store | data | alu_ri | x0 | none | none | - |
| raw | store | data | alu_rr | - | forward 0 | none | - |
| raw | store | data | alu_rr | x0 | none | none | - |
| raw | store | data | csr_i | - | forward 0 | none | - |
| raw | store | data | csr_i | x0 | none | none | - |
| raw | store | data | csr_r | - | forward 0 | none | - |
| raw | store | data | csr_r | x0 | none | none | - |
| raw | store | data | div | - | forward 0 | none | - |
| raw | store | data | div | x0 | none | none | - |
| raw | store | data | jal | - | forward 0 | none | - |
| raw | store | data | jal | x0 | none | none | - |
| raw | store | data | jalr | - | forward 0 | none | - |
| raw | store | data | jalr | x0 | none | none | - |
| raw | store | data | load | - | stall 1 | none | - |
| raw | store | data | load | x0 | none | none | - |
| raw | store | data | mul | - | forward 0 | none | - |
| raw | store | data | mul | x0 | none | none | - |
| raw | store | data | mulh | - | forward 0 | none | - |
| raw | store | data | mulh | x0 | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | data | store | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | data | store | x0 | none | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | alu_nosrc | - | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | alu_nosrc | same_reg | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | alu_nosrc | x0 | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs1 | alu_ri | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs1 | alu_ri | x0 | none | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | alu_ri | same_reg | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs1 | alu_rr | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs1 | alu_rr | x0 | none | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | alu_rr | same_reg | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | csr_i | - | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | csr_i | same_reg | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | csr_i | x0 | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs1 | csr_r | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs1 | csr_r | x0 | none | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | csr_r | same_reg | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs1 | div | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs1 | div | x0 | none | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | div | same_reg | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | jal | - | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | jal | same_reg | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | jal | x0 | none | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | jalr | - | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | jalr | same_reg | forward 0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | jalr | x0 | none | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | load | - | stall 1 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | load | same_reg | stall 1 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | load | x0 | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs1 | mul | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs1 | mul | x0 | none | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | mul | same_reg | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs1 | mulh | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs1 | mulh | x0 | none | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | mulh | same_reg | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | alu_nosrc | - | forward 0 | forward 0 / none | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | alu_ri | - | forward 0 | forward 0 / none | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | alu_rr | - | forward 0 | forward 0 / none | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | csr_i | - | forward 0 | forward 0 / none | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | csr_r | - | forward 0 | forward 0 / none | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | div | - | forward 0 | forward 0 / none | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | jal | - | forward 0 | forward 0 / none | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | jalr | - | forward 0 | forward 0 / none | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | load | - | forward 0 / stall 1 | forward 0 / none | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | mul | - | forward 0 | forward 0 / none | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | mulh | - | forward 0 | forward 0 / none | - |
| raw | alu_rr, div, mul, mulh | rs2 | alu_nosrc | - | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | alu_nosrc | same_reg | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | alu_nosrc | x0 | none | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | alu_ri | - | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | alu_ri | same_reg | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | alu_ri | x0 | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs2 | alu_rr | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs2 | alu_rr | x0 | none | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | alu_rr | same_reg | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | csr_i | - | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | csr_i | same_reg | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | csr_i | x0 | none | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | csr_r | - | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | csr_r | same_reg | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | csr_r | x0 | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs2 | div | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs2 | div | x0 | none | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | div | same_reg | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | jal | - | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | jal | same_reg | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | jal | x0 | none | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | jalr | - | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | jalr | same_reg | forward 0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | jalr | x0 | none | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | load | - | stall 1 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | load | same_reg | stall 1 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | load | x0 | none | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs2 | mul | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs2 | mul | x0 | none | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | mul | same_reg | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs2 | mulh | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs2 | mulh | x0 | none | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | mulh | same_reg | forward 0 | none | - |
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
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | target | jalr | - | forward 0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | target | jalr | x0 | none | none | - |
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
| raw | any | use | - | - | - | - | none |
| struct | any, system | - | - | - | - | - | none |
| struct | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, trap | - | div | - | occupied 37 | occupied 37 | - |
| struct | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, trap | - | mulh | - | occupied 2 | occupied 2 | - |
| war | load, store | addr | alu_nosrc | - | none | none | - |
| war | load, store | addr | alu_ri | - | none | none | - |
| war | load, store | addr | alu_rr | - | none | none | - |
| war | load, store | addr | csr_i | - | none | none | - |
| war | load, store | addr | csr_r | - | none | none | - |
| war | load, store | addr | div | - | none | none | - |
| war | load, store | addr | jal | - | none | none | - |
| war | load, store | addr | jalr | - | none | none | - |
| war | load, store | addr | load | - | none | none | - |
| war | load, store | addr | mul | - | none | none | - |
| war | load, store | addr | mulh | - | none | none | - |
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
| war | store | data | alu_nosrc | - | none | none | - |
| war | store | data | alu_ri | - | none | none | - |
| war | store | data | alu_rr | - | none | none | - |
| war | store | data | csr_i | - | none | none | - |
| war | store | data | csr_r | - | none | none | - |
| war | store | data | div | - | none | none | - |
| war | store | data | jal | - | none | none | - |
| war | store | data | jalr | - | none | none | - |
| war | store | data | load | - | none | none | - |
| war | store | data | mul | - | none | none | - |
| war | store | data | mulh | - | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rd | alu_ri | - | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rd | alu_rr | - | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rd | branch | - | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rd | csr_r | - | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rd | div | - | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rd | jalr | - | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rd | load | - | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rd | mul | - | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rd | mulh | - | none | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rd | store | - | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | alu_nosrc | - | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | alu_ri | - | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | alu_rr | - | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | csr_i | - | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | csr_r | - | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | div | - | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | jal | - | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | jalr | - | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | load | - | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | mul | - | none | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | mulh | - | none | none | - |
| war | alu_rr, div, mul, mulh | rs2 | alu_nosrc | - | none | none | - |
| war | alu_rr, div, mul, mulh | rs2 | alu_ri | - | none | none | - |
| war | alu_rr, div, mul, mulh | rs2 | alu_rr | - | none | none | - |
| war | alu_rr, div, mul, mulh | rs2 | csr_i | - | none | none | - |
| war | alu_rr, div, mul, mulh | rs2 | csr_r | - | none | none | - |
| war | alu_rr, div, mul, mulh | rs2 | div | - | none | none | - |
| war | alu_rr, div, mul, mulh | rs2 | jal | - | none | none | - |
| war | alu_rr, div, mul, mulh | rs2 | jalr | - | none | none | - |
| war | alu_rr, div, mul, mulh | rs2 | load | - | none | none | - |
| war | alu_rr, div, mul, mulh | rs2 | mul | - | none | none | - |
| war | alu_rr, div, mul, mulh | rs2 | mulh | - | none | none | - |
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
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | first | alu_nosrc | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | first | alu_ri | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | first | alu_rr | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | first | csr_i | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | first | csr_r | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | first | div | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | first | jal | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | first | jalr | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | first | load | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | first | mul | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | first | mulh | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | alu_nosrc | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | alu_nosrc | x0 | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | alu_ri | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | alu_ri | x0 | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | alu_rr | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | alu_rr | x0 | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | csr_i | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | csr_i | x0 | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | csr_r | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | csr_r | x0 | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | div | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | div | x0 | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | jal | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | jal | x0 | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | jalr | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | jalr | x0 | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | load | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | load | x0 | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | mul | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | mul | x0 | none | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | mulh | - | ordered 0 | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | mulh | x0 | none | none | - |

4,251 cases in all, one per subject class, port, producer class and distance; rows identical across subject classes are shown once.  Kinds: raw (a read after a write), war, waw, ctrl (a control transfer ahead), struct (a resource).  Words: "stall n", the reader waits n cycles; "forward 0", the value is forwarded and nothing waits; "bubble n", the fetch after a taken control transfer; "squash 0", an instruction on the wrong path, killed; two words in one cell are the two outcomes (taken / not taken); "none", no cost.

### 4.2 The manual's hazard statements, checked against the structure

*(none)*

### 4.3 Statements of the core's own

What the structure does not derive: each row fires on the trace by its match rule and is applied as a hold.  Width: equal (the trigger is its cause: intent), wider (an interlock firing without its cause: a performance finding), narrower (a cause with no stall), unexplained.

*(none)*

## 5. The memory side: the bus, the write buffer, misaligned and atomic accesses

Conditions: the bus schedule a test names.  The manual's cycle table is the special case of every request accepted at once and answered the next cycle.

| the memory side | this core | source | grade |
|---|---|---|---|
| bus | - | bus/.json | stated |
| pmp | regions 16; granularity 4; smepmp yes; fault_cycles 2; second_half_after_fault yes | pmp.rst 6-50 | stated |

## 6. CSRs and counters: the accesses that wait

Which CSR accesses wait, on what, and for how long.  A CSR instruction reads and writes its CSR in the stages the structure names; the rows here are the core's own statements about CSR order, the counters every retirement updates, and the CSRs with implicit accesses.

*(none)*

## 7. Interrupts and other events: when they are taken and what they cost

No events section in this specification.

## 8. What real programs pay on this core: the cycles lost to stalls, by cause

No profile yet (make -C hazards profiles CORE=ibex-pmp).

## 9. Where the RTL and the manual differ: the anomalies we found

Each row is a finding: what the manual says, what the RTL measured, the class (intent: the trigger is its cause and the manual is behind; over-wide: an interlock firing without its cause; narrower; function), its cost, and whose it is to act on (the documentation, the RTL, or the core's performance).  The reproducer, the two traces and the run's facts are in the issue directory named.

| finding | for | class | cost | found on | status | issue directory |
|---|---|---|---|---|---|---|
| A PMP-refused load or store faults after two cycles, no bus request | document | intent | two cycles on every load or store the PMP refuses, before the trap's own entry; a zero-wait memory's permitted access pays one | ibex-pmp | clarified; to file | [issues/pmp-fault-two-cycles/](issues/pmp-fault-two-cycles/) |
| A writeback-raised trap enters its handler a cycle after an ID/EX one | document | intent | one cycle more on the entry of every handler of a load or store fault than of an ID/EX exception | ibex-pmp | clarified; to file | [issues/pmp-fault-wb-entry-four-cycles/](issues/pmp-fault-wb-entry-four-cycles/) |
| A misaligned store the PMP refuses still writes its second half | rtl | function | none in cycles; a store that faults leaves half its data in memory, which software handling the fault may not expect | ibex-pmp | clarified; to file | [issues/pmp-misaligned-store-second-half-written/](issues/pmp-misaligned-store-second-half-written/) |
| The manual's W=1 R=0 rule holds only while mseccfg.MML is clear | document | intent | none in cycles; a permission reading software would get wrong from the manual under MML | ibex-pmp | clarified; to file | [issues/pmp-w-without-r-under-mml/](issues/pmp-w-without-r-under-mml/) |
| Two inherited layer reasons say 'no PMP' on the PMP build | document | intent | none; a reason in our own layer | ibex-pmp | open; not needed | - |

## 10. What the base build's rows leave to a configuration, and what no test reaches

Every stall and flush term in the RTL source that the base build's own rows do not state is listed here, with where it is handled.  Of the 9 terms: 0 are stated and tested under a configuration of the core (its part of section 12) or became rows of this specification after the source was read -- not gaps, pointers; 4 no test of ours will reach, each with its reason; 5 await a feature we have not built.  Beside the terms, our reading of the RTL source raised 4 questions the manual does not answer (4 on the base build): 0 are answered by a measurement and stated above; 4 are still open (4 on the base build) and head the table in 10.2.  A row in 10.2 is a hole in the specification, named rather than hidden.

### 10.1 Specified under a configuration

*(none)*

### 10.2 Not reached, and why

| core | what | why | reach | RTL |
|---|---|---|---|---|
| ibex-pmp | open question `pmp_fault_lsu_aligned` | pmp_err_d = data_pmp_err_i in IDLE's address phase, WAIT_GNT leaving on data_gnt_i \|\| pmp_err_q, lsu_resp_valid_o = all_resp & (ls_fsm_cs == IDLE) with all_resp = data_rvalid_i \| pmp_err_q, load_err_o / store_err_o = data_or_pmp_err & lsu_resp_valid_o | open | rtl/ibex_load_store_unit.sv:473-492, 540-551, 645, 703-709, 762-763 |
| ibex-pmp | open question `pmp_fault_lsu_misaligned_first` | WAIT_GNT_MIS leaving on data_gnt_i \|\| pmp_err_q; WAIT_RVALID_MIS's data_rvalid_i \|\| pmp_err_q branch with lsu_err_d = data_bus_err_i \| pmp_err_q and pmp_err_d = data_pmp_err_i for the second part | open | rtl/ibex_load_store_unit.sv:495-507, 509-538 |
| ibex-pmp | open question `pmp_fault_lsu_misaligned_second` | pmp_err_d = data_pmp_err_i for the second part in WAIT_RVALID_MIS (518) and WAIT_RVALID_MIS_GNTS_DONE (560); WAIT_GNT leaving on pmp_err_q | open | rtl/ibex_load_store_unit.sv:509-538, 540-551, 553-571 |
| ibex-pmp | open question `pmp_fault_fetch` | if_instr_pmp_err = pmp_err_if_i \| (if_instr_addr[1] & ~instr_is_compressed & pmp_err_if_plus2_i); if_instr_err into instr_fetch_err_o with the instruction | open | rtl/ibex_if_stage.sv:424-436, 644-649 |
| ibex-pmp | not built: `data_ind_timing_i` | cpuctrlsts.data_ind_timing reads as zero without SecureIbex: a branch's fixed two cycles whatever its condition and the divider's full sequence on a zero divisor are not built here | awaiting a feature: our records on the ibex-opentitan configuration (SecureIbex = 1): the data-independent-timing promise | rtl/ibex_id_stage.sv:918-926 |
| ibex-pmp | not built: `INSTR_EXPANDED_COMMIT` | handle_irq is held off while a Zcmp pop's commit sequence or a move executes (instr_gets_expanded_i == INSTR_EXPANDED_COMMIT); RV32ZC = RV32ZcaZcbZcmp builds the expansion here, and no suite makes a Zcmp instruction (gas 2.42 does not assemble them: our records), so the term never fires | awaiting a feature: our records: Zcmp with the ISA-layer round (cores-PLAN's cv32e40s step 1), the toolchain question settled there | rtl/ibex_controller.sv:501-503 |
| ibex-pmp | not built: `icache_enable_i` | gen_icache: the instruction cache in place of the prefetch buffer, with its hit and miss timing and the fence.i invalidation; the prefetch buffer is built here | awaiting a feature: our records part C: the ibex-icache configuration (ICache = 1) | rtl/ibex_if_stage.sv:299-398 |
| ibex-pmp | not built: `instr_intg_err` | the integrity check of fetched words (MemECC = SecureIbex) and of data responses (ibex_load_store_unit.sv 393-397): an integrity error is a fetch error or an internal NMI; not built, the harness's intg inputs tied off | awaiting a feature: our records: the ibex-opentitan configuration (the harness producing the integrity bits) | rtl/ibex_if_stage.sv:275-283 |
| ibex-pmp | not built: `illegal_csr` | without PMP every access to pmpcfg0-3 and pmpaddr0-15 (and mseccfg, 502-518) is an illegal instruction, where pmp.rst 19 says the registers read as zero: the plan's undocumented item 1, a finding to make on the PMP-less builds (ibex, ibex-maxperf); here PMPEnable = 1 and the branch is dead, the registers are read and written (1360-1528) | awaiting a feature: our records part B findings and decision 7 (a): PMPEnable=0's illegal CSR accesses against 'read as zero', with Spike at 0 regions trapping alike on ibex and ibex-maxperf; an entry of ibex/the record with found_on when a test writes a PMP CSR there | rtl/ibex_cs_registers.sv:705-714 |
| ibex-pmp | not built: `nt_branch_mispredict_o` | the static predictor's taken-by-default and its mispredict (ibex_if_stage.sv 238-239, 285-293): the predictor is experimental and off in every configuration run here | out: our records, the configurations table: experimental-branch-predictor is not run | rtl/ibex_controller.sv:684-698 |
| ibex-pmp | not built: `stall_dummy_instr` | gen_dummy_instr: dummy instructions inserted between real ones (DummyInstructions = SecureIbex); off here | out: our records: left off (cpuctrlsts.dummy_instr_en) on the secure configuration too | rtl/ibex_if_stage.sv:544-590 |
| ibex-pmp | not built: `cheriot_enable_i` | the CHERIoT capability accesses and the cheriot_* exception terms (ibex_controller.sv 209-220, 269-273) exist only with BaseIsa = BaseIsaRV32IorCHERIoT and cheriot_enable_i high; the writeback stage's cheriot terms (ibex_wb_stage.sv 115-116, 190-196) and the PMP's CHERIoT gates (ibex_core.sv 1598-1602, 1635-1639: the check off and its CSRs illegal, ibex_cs_registers.sv 705-706, when CHERIoT is on) are tied off with them | out: our records, the other lowRISC cores: a CHERIoT round needs the CHERIoT Sail model as its reference; the opentitan build carries the logic with cheriot_enable_i tied off | rtl/ibex_load_store_unit.sv:436-473, 573-616 |
| ibex-pmp | not built: `trigger_match_i` | a hardware breakpoint's trigger match enters debug mode (DBG_CAUSE_TRIGGER); no trigger is built | out: debug is deferred by the user; the harness ties debug_req_i off | rtl/ibex_controller.sv:515-519 |

## 11. How far this specification has been checked: the evidence behind it

| measure | value |
|---|---|
| findings in the record | 5 (4 document, 1 rtl) |

Our generated test suites run against this specification's prediction at every retirement on every regression; their counts and coverage are in the README beside this document.  Deliberate faults injected into the RTL (the timing and functional mutation campaign) prove the suites see what they claim.

## 12. The configurations: what each build adds or changes

None.

© 2026 processor-timing-anomalies, Apache License 2.0
