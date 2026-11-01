# Our accurate, complete timing specification for the Ibex

Generated from our records of the Ibex on 1 November 2026, for the RTL at commit `c0c07085791e4d16a0f2d9a753b2fb79d72e5ffa`; the configurations measured: none.  The timing is as measured on that commit; the document is regenerated after every run we record.

This document states what the ibex core promises in time: the pipeline as a structure, the cycle each instruction class takes, the stalls and bubbles between instructions, the memory side under a stated bus, the CSR accesses that wait, the interrupts and other events, what real programs pay on it, and where the RTL and the user manual disagree.  It is the rendering of our internal machine-readable version of the RISC-V ISA, this core's layer distilled from its user manual with a citation or a graded reading on every field, a configuration layer for each variant, and the RTL read only to answer what the manual leaves open.  It describes the implementation as measured; a row graded inferred or read is not design intent until the core's authors take it as theirs (the grade authored).

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
| stages | IF IDEX | pipeline_details.rst 11-18 | stated |
| register ports read in | rs1: IDEX, rs2: IDEX, store_data: IDEX, branch_cmp: IDEX, jalr_target: IDEX, mem_base: IDEX, csr: IDEX | pipeline_details.rst 16-18 | stated |
| results written | rd: IDEX | pipeline_details.rst 16-18 | stated |
| result available, per class | alu_rr: IDEX, alu_ri: IDEX, alu_nosrc: IDEX, load: IDEX, store: IDEX, branch: IDEX, jal: IDEX, jalr: IDEX, csr_r: IDEX, csr_i: IDEX, mul: IDEX, mulh: IDEX, div: IDEX, system: IDEX, trap: IDEX | pipeline_details.rst 20-24 | stated |
| occupancy, per class (cycles beyond the first in the stage named) | mul: 3; mulh: 4; div: default 2 to 37; rule 2 if rs2 == 0 else 37; load: default 2; misaligned 3; store: default 2; misaligned 3; jal: default 2; redirect first; jalr: default 2; redirect first; branch: default 1; taken 2; fence.i: default 2; redirect first | pipeline_details.rst 33-100 Multi- and Single-Cycle Instructions | stated |
| forwarding paths | none | the document lists no bypass and needs none: the register file is read and written in the one stage that executes (pipeline_details.rst 16-18), so a result is i | inferred |
| control transfers resolved in | jump IDEX, branch IDEX, trap IDEX; flushes: fence.i from IDEX, mret from IDEX+1, trap from IDEX+1, csr_write_of * except mscratch mepc from IDEX+1 prefetched | pipeline_details.rst 72-100 | stated |
| register file | write before read | whether a write and a read of the same register in one cycle see the new value never arises: the two are the same instruction's, in order | inferred |
| penalty: misaligned_target | 1 | instruction_fetch.rst 76-80 | stated |

## 2. Cycle counts per instruction class: the base cost of every instruction

The cycles an instruction of each class takes in its result stage beyond the one every instruction takes (its occupancy), with no hazard and no bus wait; the manual's table "Cycle counts per instruction type" is the source where one is given.

| class | occupancy | instructions | members |
|---|---:|---:|---|
| mul | 3 | 1 | mul |
| mulh | 4 | 3 | mulh, mulhsu, mulhu |
| div | default 2 to 37; rule 2 if rs2 == 0 else 37 | 4 | div, divu, rem, remu |
| load | default 2; misaligned 3 | 7 | c.lw, c.lwsp, lb, lbu, lh, lhu, lw |
| store | default 2; misaligned 3 | 5 | c.sw, c.swsp, sb, sh, sw |
| branch | default 1; taken 2 | 8 | beq, bge, bgeu, blt, bltu, bne, c.beqz, c.bnez |
| jalr | default 2; redirect first | 3 | c.jalr, c.jr, jalr |
| jal | default 2; redirect first | 3 | c.j, c.jal, jal |
| csr_r | 0 | 3 | csrrc, csrrs, csrrw |
| csr_i | 0 | 3 | csrrci, csrrsi, csrrwi |
| alu_rr | 0 | 16 | add, and, c.add, c.and, c.mv, c.or, c.sub, c.xor ... |
| alu_ri | 0 | 16 | addi, andi, c.addi, c.addi16sp, c.addi4spn, c.andi, c.slli, c.srai ... |
| alu_nosrc | 0 | 4 | auipc, c.li, c.lui, lui |
| trap | 0 | 4 | c.ebreak, ebreak, ecall, mret |
| system | 0 | 5 | c.nop, fence, fence.i, fence.tso, wfi |

## 3. Three facts of the pipeline the rules below assume

| fact | this core | source | grade |
|---|---|---|---|
| two statements that hold one instruction in one stage | - |  | read |
| a jump held in its resolution stage by a statement of the core (not by its own operand) | - |  | read |
| an instruction that traps as illegal | - |  | read |

## 4. Hazards: the stalls between instructions, derived and documented

A hazard is two instructions within the pipeline's depth that touch the same register, CSR or control.  The rows derived from the structure (section 1) are the manual's rules read through the ISA layer: a dependent instruction at distance d waits until the producer's result is where the reader reads it, the forwarding paths shortening the wait.  The rows the core states on its own are those the structure does not derive; each carries its cause in ISA terms and the width of its trigger against that cause.  Conditions: the zero-wait bus of the manual's cycle table.

### 4.1 Derived from the structure

| kind | subject classes | port | producer class | variant | d=1 | no distance |
|---|---|---|---|---|---|---|
| ctrl | any, trap | - | - | - | - | none |
| ctrl | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, trap | - | branch | - | bubble 1 / squash 0 | - |
| ctrl | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, trap | - | jal | - | bubble 1 / squash 0 | - |
| ctrl | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, trap | - | jalr | - | bubble 1 / squash 0 | - |
| ctrl | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, trap | - | trap | - | bubble 2 / squash 0 | - |
| raw | load, store | addr | alu_nosrc | - | none | - |
| raw | load | addr | alu_nosrc | same_reg | none | - |
| raw | load, store | addr | alu_nosrc | x0 | none | - |
| raw | load, store | addr | alu_ri | - | none | - |
| raw | load | addr | alu_ri | same_reg | none | - |
| raw | load, store | addr | alu_ri | x0 | none | - |
| raw | load, store | addr | alu_rr | - | none | - |
| raw | load | addr | alu_rr | same_reg | none | - |
| raw | load, store | addr | alu_rr | x0 | none | - |
| raw | load, store | addr | csr_i | - | none | - |
| raw | load | addr | csr_i | same_reg | none | - |
| raw | load, store | addr | csr_i | x0 | none | - |
| raw | load, store | addr | csr_r | - | none | - |
| raw | load | addr | csr_r | same_reg | none | - |
| raw | load, store | addr | csr_r | x0 | none | - |
| raw | load, store | addr | div | - | none | - |
| raw | load | addr | div | same_reg | none | - |
| raw | load, store | addr | div | x0 | none | - |
| raw | load, store | addr | jal | - | none | - |
| raw | load | addr | jal | same_reg | none | - |
| raw | load, store | addr | jal | x0 | none | - |
| raw | load, store | addr | jalr | - | none | - |
| raw | load | addr | jalr | same_reg | none | - |
| raw | load, store | addr | jalr | x0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store | addr | load | - | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store | addr | load | x0 | none | - |
| raw | load | addr | load | same_reg | none | - |
| raw | load, store | addr | mul | - | none | - |
| raw | load | addr | mul | same_reg | none | - |
| raw | load, store | addr | mul | x0 | none | - |
| raw | load, store | addr | mulh | - | none | - |
| raw | load | addr | mulh | same_reg | none | - |
| raw | load, store | addr | mulh | x0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | addr | store | - | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | addr | store | x0 | none | - |
| raw | branch | cmp1 | alu_nosrc | - | none | - |
| raw | branch | cmp1 | alu_nosrc | x0 | none | - |
| raw | branch | cmp1 | alu_ri | - | none | - |
| raw | branch | cmp1 | alu_ri | x0 | none | - |
| raw | branch | cmp1 | alu_rr | - | none | - |
| raw | branch | cmp1 | alu_rr | x0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | cmp1 | branch | - | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | cmp1 | branch | x0 | none | - |
| raw | branch | cmp1 | csr_i | - | none | - |
| raw | branch | cmp1 | csr_i | x0 | none | - |
| raw | branch | cmp1 | csr_r | - | none | - |
| raw | branch | cmp1 | csr_r | x0 | none | - |
| raw | branch | cmp1 | div | - | none | - |
| raw | branch | cmp1 | div | x0 | none | - |
| raw | branch | cmp1 | jal | - | none | - |
| raw | branch | cmp1 | jal | x0 | none | - |
| raw | branch | cmp1 | jalr | - | none | - |
| raw | branch | cmp1 | jalr | x0 | none | - |
| raw | branch | cmp1 | load | - | none | - |
| raw | branch | cmp1 | load | x0 | none | - |
| raw | branch | cmp1 | mul | - | none | - |
| raw | branch | cmp1 | mul | x0 | none | - |
| raw | branch | cmp1 | mulh | - | none | - |
| raw | branch | cmp1 | mulh | x0 | none | - |
| raw | branch | cmp2 | alu_nosrc | - | none | - |
| raw | branch | cmp2 | alu_nosrc | x0 | none | - |
| raw | branch | cmp2 | alu_ri | - | none | - |
| raw | branch | cmp2 | alu_ri | x0 | none | - |
| raw | branch | cmp2 | alu_rr | - | none | - |
| raw | branch | cmp2 | alu_rr | x0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | cmp2 | branch | - | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | cmp2 | branch | x0 | none | - |
| raw | branch | cmp2 | csr_i | - | none | - |
| raw | branch | cmp2 | csr_i | x0 | none | - |
| raw | branch | cmp2 | csr_r | - | none | - |
| raw | branch | cmp2 | csr_r | x0 | none | - |
| raw | branch | cmp2 | div | - | none | - |
| raw | branch | cmp2 | div | x0 | none | - |
| raw | branch | cmp2 | jal | - | none | - |
| raw | branch | cmp2 | jal | x0 | none | - |
| raw | branch | cmp2 | jalr | - | none | - |
| raw | branch | cmp2 | jalr | x0 | none | - |
| raw | branch | cmp2 | load | - | none | - |
| raw | branch | cmp2 | load | x0 | none | - |
| raw | branch | cmp2 | mul | - | none | - |
| raw | branch | cmp2 | mul | x0 | none | - |
| raw | branch | cmp2 | mulh | - | none | - |
| raw | branch | cmp2 | mulh | x0 | none | - |
| raw | csr_i, csr_r, trap | csr | csr_i | - | none | - |
| raw | csr_i, csr_r, trap | csr | csr_r | - | none | - |
| raw | csr_i, csr_r, trap | csr | trap | - | none | - |
| raw | store | data | alu_nosrc | - | none | - |
| raw | store | data | alu_nosrc | x0 | none | - |
| raw | store | data | alu_ri | - | none | - |
| raw | store | data | alu_ri | x0 | none | - |
| raw | store | data | alu_rr | - | none | - |
| raw | store | data | alu_rr | x0 | none | - |
| raw | store | data | csr_i | - | none | - |
| raw | store | data | csr_i | x0 | none | - |
| raw | store | data | csr_r | - | none | - |
| raw | store | data | csr_r | x0 | none | - |
| raw | store | data | div | - | none | - |
| raw | store | data | div | x0 | none | - |
| raw | store | data | jal | - | none | - |
| raw | store | data | jal | x0 | none | - |
| raw | store | data | jalr | - | none | - |
| raw | store | data | jalr | x0 | none | - |
| raw | store | data | load | - | none | - |
| raw | store | data | load | x0 | none | - |
| raw | store | data | mul | - | none | - |
| raw | store | data | mul | x0 | none | - |
| raw | store | data | mulh | - | none | - |
| raw | store | data | mulh | x0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | data | store | - | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | data | store | x0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | alu_nosrc | - | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | alu_nosrc | same_reg | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | alu_nosrc | x0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs1 | alu_ri | - | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs1 | alu_ri | x0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | alu_ri | same_reg | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs1 | alu_rr | - | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs1 | alu_rr | x0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | alu_rr | same_reg | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | csr_i | - | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | csr_i | same_reg | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | csr_i | x0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs1 | csr_r | - | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs1 | csr_r | x0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | csr_r | same_reg | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs1 | div | - | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs1 | div | x0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | div | same_reg | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | jal | - | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | jal | same_reg | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | jal | x0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | jalr | - | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | jalr | same_reg | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | jalr | x0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | load | - | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | load | same_reg | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | load | x0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs1 | mul | - | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs1 | mul | x0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | mul | same_reg | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs1 | mulh | - | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs1 | mulh | x0 | none | - |
| raw | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | mulh | same_reg | none | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | alu_nosrc | - | none | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | alu_ri | - | none | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | alu_rr | - | none | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | csr_i | - | none | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | csr_r | - | none | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | div | - | none | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | jal | - | none | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | jalr | - | none | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | load | - | none | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | mul | - | none | - |
| raw | alu_rr, div, mul, mulh | rs1rs2 | mulh | - | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | alu_nosrc | - | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | alu_nosrc | same_reg | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | alu_nosrc | x0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | alu_ri | - | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | alu_ri | same_reg | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | alu_ri | x0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs2 | alu_rr | - | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs2 | alu_rr | x0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | alu_rr | same_reg | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | csr_i | - | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | csr_i | same_reg | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | csr_i | x0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | csr_r | - | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | csr_r | same_reg | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | csr_r | x0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs2 | div | - | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs2 | div | x0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | div | same_reg | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | jal | - | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | jal | same_reg | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | jal | x0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | jalr | - | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | jalr | same_reg | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | jalr | x0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | load | - | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | load | same_reg | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | load | x0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs2 | mul | - | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs2 | mul | x0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | mul | same_reg | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs2 | mulh | - | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rs2 | mulh | x0 | none | - |
| raw | alu_rr, div, mul, mulh | rs2 | mulh | same_reg | none | - |
| raw | jalr | target | alu_nosrc | - | none | - |
| raw | jalr | target | alu_nosrc | same_reg | none | - |
| raw | jalr | target | alu_nosrc | x0 | none | - |
| raw | jalr | target | alu_ri | - | none | - |
| raw | jalr | target | alu_ri | same_reg | none | - |
| raw | jalr | target | alu_ri | x0 | none | - |
| raw | jalr | target | alu_rr | - | none | - |
| raw | jalr | target | alu_rr | same_reg | none | - |
| raw | jalr | target | alu_rr | x0 | none | - |
| raw | jalr | target | csr_i | - | none | - |
| raw | jalr | target | csr_i | same_reg | none | - |
| raw | jalr | target | csr_i | x0 | none | - |
| raw | jalr | target | csr_r | - | none | - |
| raw | jalr | target | csr_r | same_reg | none | - |
| raw | jalr | target | csr_r | x0 | none | - |
| raw | jalr | target | div | - | none | - |
| raw | jalr | target | div | same_reg | none | - |
| raw | jalr | target | div | x0 | none | - |
| raw | jalr | target | jal | - | none | - |
| raw | jalr | target | jal | same_reg | none | - |
| raw | jalr | target | jal | x0 | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | target | jalr | - | none | - |
| raw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | target | jalr | x0 | none | - |
| raw | jalr | target | jalr | same_reg | none | - |
| raw | jalr | target | load | - | none | - |
| raw | jalr | target | load | same_reg | none | - |
| raw | jalr | target | load | x0 | none | - |
| raw | jalr | target | mul | - | none | - |
| raw | jalr | target | mul | same_reg | none | - |
| raw | jalr | target | mul | x0 | none | - |
| raw | jalr | target | mulh | - | none | - |
| raw | jalr | target | mulh | same_reg | none | - |
| raw | jalr | target | mulh | x0 | none | - |
| struct | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, trap | - | div | - | occupied 37 | - |
| struct | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, trap | - | jal | - | occupied 2 | - |
| struct | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, trap | - | jalr | - | occupied 2 | - |
| struct | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, trap | - | load | - | occupied 2 | - |
| struct | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, trap | - | mul | - | occupied 3 | - |
| struct | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, trap | - | mulh | - | occupied 4 | - |
| struct | alu_nosrc, alu_ri, alu_rr, branch, csr_i, csr_r, div, jal, jalr, load, mul, mulh, store, system, trap | - | store | - | occupied 2 | - |
| war | load, store | addr | alu_nosrc | - | none | - |
| war | load, store | addr | alu_ri | - | none | - |
| war | load, store | addr | alu_rr | - | none | - |
| war | load, store | addr | csr_i | - | none | - |
| war | load, store | addr | csr_r | - | none | - |
| war | load, store | addr | div | - | none | - |
| war | load, store | addr | jal | - | none | - |
| war | load, store | addr | jalr | - | none | - |
| war | load, store | addr | load | - | none | - |
| war | load, store | addr | mul | - | none | - |
| war | load, store | addr | mulh | - | none | - |
| war | branch | cmp1 | alu_nosrc | - | none | - |
| war | branch | cmp1 | alu_ri | - | none | - |
| war | branch | cmp1 | alu_rr | - | none | - |
| war | branch | cmp1 | csr_i | - | none | - |
| war | branch | cmp1 | csr_r | - | none | - |
| war | branch | cmp1 | div | - | none | - |
| war | branch | cmp1 | jal | - | none | - |
| war | branch | cmp1 | jalr | - | none | - |
| war | branch | cmp1 | load | - | none | - |
| war | branch | cmp1 | mul | - | none | - |
| war | branch | cmp1 | mulh | - | none | - |
| war | branch | cmp2 | alu_nosrc | - | none | - |
| war | branch | cmp2 | alu_ri | - | none | - |
| war | branch | cmp2 | alu_rr | - | none | - |
| war | branch | cmp2 | csr_i | - | none | - |
| war | branch | cmp2 | csr_r | - | none | - |
| war | branch | cmp2 | div | - | none | - |
| war | branch | cmp2 | jal | - | none | - |
| war | branch | cmp2 | jalr | - | none | - |
| war | branch | cmp2 | load | - | none | - |
| war | branch | cmp2 | mul | - | none | - |
| war | branch | cmp2 | mulh | - | none | - |
| war | store | data | alu_nosrc | - | none | - |
| war | store | data | alu_ri | - | none | - |
| war | store | data | alu_rr | - | none | - |
| war | store | data | csr_i | - | none | - |
| war | store | data | csr_r | - | none | - |
| war | store | data | div | - | none | - |
| war | store | data | jal | - | none | - |
| war | store | data | jalr | - | none | - |
| war | store | data | load | - | none | - |
| war | store | data | mul | - | none | - |
| war | store | data | mulh | - | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rd | alu_ri | - | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rd | alu_rr | - | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rd | branch | - | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rd | csr_r | - | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rd | div | - | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rd | jalr | - | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rd | load | - | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rd | mul | - | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rd | mulh | - | none | - |
| war | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | rd | store | - | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | alu_nosrc | - | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | alu_ri | - | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | alu_rr | - | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | csr_i | - | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | csr_r | - | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | div | - | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | jal | - | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | jalr | - | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | load | - | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | mul | - | none | - |
| war | alu_ri, alu_rr, csr_r, div, mul, mulh | rs1 | mulh | - | none | - |
| war | alu_rr, div, mul, mulh | rs2 | alu_nosrc | - | none | - |
| war | alu_rr, div, mul, mulh | rs2 | alu_ri | - | none | - |
| war | alu_rr, div, mul, mulh | rs2 | alu_rr | - | none | - |
| war | alu_rr, div, mul, mulh | rs2 | csr_i | - | none | - |
| war | alu_rr, div, mul, mulh | rs2 | csr_r | - | none | - |
| war | alu_rr, div, mul, mulh | rs2 | div | - | none | - |
| war | alu_rr, div, mul, mulh | rs2 | jal | - | none | - |
| war | alu_rr, div, mul, mulh | rs2 | jalr | - | none | - |
| war | alu_rr, div, mul, mulh | rs2 | load | - | none | - |
| war | alu_rr, div, mul, mulh | rs2 | mul | - | none | - |
| war | alu_rr, div, mul, mulh | rs2 | mulh | - | none | - |
| war | jalr | target | alu_nosrc | - | none | - |
| war | jalr | target | alu_ri | - | none | - |
| war | jalr | target | alu_rr | - | none | - |
| war | jalr | target | csr_i | - | none | - |
| war | jalr | target | csr_r | - | none | - |
| war | jalr | target | div | - | none | - |
| war | jalr | target | jal | - | none | - |
| war | jalr | target | jalr | - | none | - |
| war | jalr | target | load | - | none | - |
| war | jalr | target | mul | - | none | - |
| war | jalr | target | mulh | - | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | first | alu_nosrc | - | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | first | alu_ri | - | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | first | alu_rr | - | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | first | csr_i | - | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | first | csr_r | - | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | first | div | - | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | first | jal | - | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | first | jalr | - | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | first | load | - | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | first | mul | - | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | first | mulh | - | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | alu_nosrc | - | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | alu_nosrc | x0 | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | alu_ri | - | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | alu_ri | x0 | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | alu_rr | - | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | alu_rr | x0 | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | csr_i | - | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | csr_i | x0 | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | csr_r | - | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | csr_r | x0 | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | div | - | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | div | x0 | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | jal | - | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | jal | x0 | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | jalr | - | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | jalr | x0 | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | load | - | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | load | x0 | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | mul | - | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | mul | x0 | none | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | mulh | - | ordered 0 | - |
| waw | alu_nosrc, alu_ri, alu_rr, csr_i, csr_r, div, jal, jalr, load, mul, mulh | last | mulh | x0 | none | - |

1,782 cases in all, one per subject class, port, producer class and distance; rows identical across subject classes are shown once.  Kinds: raw (a read after a write), war, waw, ctrl (a control transfer ahead), struct (a resource).  Words: "stall n", the reader waits n cycles; "forward 0", the value is forwarded and nothing waits; "bubble n", the fetch after a taken control transfer; "squash 0", an instruction on the wrong path, killed; two words in one cell are the two outcomes (taken / not taken); "none", no cost.

### 4.2 The manual's hazard statements, checked against the structure

| statement (rows) | the manual says | source | grade |
|---|---|---|---|
| raw_rs1_*_d1,, raw_rs2_*_d1,, raw_addr_*_d1,, raw_data_*_d1,, raw_cmp1_*_d1,, raw_cmp2_*_d1,, raw_target_*_d1 | none | pipeline_details.rst 16-18 | stated |
| struct_busy_mul_d1 | occupied 3 | pipeline_details.rst 61-67 | stated |
| struct_busy_mulh_d1 | occupied 4 | pipeline_details.rst 61-67 | stated |
| struct_busy_div_d1 | occupied 37 | pipeline_details.rst 68-71 | stated |
| struct_busy_load_d1,, struct_busy_store_d1 | occupied 2 | pipeline_details.rst 53-60 | stated |
| struct_busy_jal_d1,, struct_busy_jalr_d1 | occupied 2 | pipeline_details.rst 72-78 | stated |
| ctrl_taken_jal_d1,, ctrl_taken_jalr_d1 | bubble 1 | pipeline_details.rst 72-78 | stated |
| ctrl_taken_branch_d1 | bubble 1 | pipeline_details.rst 82-95 | stated |
| ctrl_taken_trap_d1 | bubble 2 | exceptions_interrupts.rst 9-10 | inferred |

### 4.3 Statements of the core's own

What the structure does not derive: each row fires on the trace by its match rule and is applied as a hold.  Width: equal (the trigger is its cause: intent), wider (an interlock firing without its cause: a performance finding), narrower (a cause with no stall), unexplained.

*(none)*

## 5. The memory side: the bus, the write buffer, misaligned and atomic accesses

Conditions: the bus schedule a test names.  The manual's cycle table is the special case of every request accepted at once and answered the next cycle.

| the memory side | this core | source | grade |
|---|---|---|---|
| bus | ibex-mem | bus/ibex-mem.json | stated |
| data: outstanding | 2 | load_store_unit.rst 8-10 | stated |
| data: write_buffer | 0 | load_store_unit.rst 8-10 | stated |
| data: wait_stage | IDEX | load_store_unit.rst 8-10 | stated |
| data: response_stage | IDEX | load_store_unit.rst 8-10 | stated |
| fetch | outstanding 2; buffer_words 3 | instruction_fetch.rst 15-20 | stated |
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
| sleep.stage_note | the wfi executes in the one execute stage and leaves it at once (its RVFI retirement the cycle after); the sleep comes after it: see retires_before_sleep_note (the RTL pass of 29 Oct 2026; the document does not say) | exceptions_interrupts.rst 28-62 | stated |
| sleep.retires_before_sleep | yes | exceptions_interrupts.rst 28-62 | stated |
| sleep.states_after | 3 | exceptions_interrupts.rst 28-62 | stated |
| sleep.wake_latency | 1 | exceptions_interrupts.rst 28-62 | stated |
| sleep.retires_before_sleep_note | the wfi is a special_req_flush_only (line 288): DECODE goes to FLUSH the cycle after the wfi's ID/EX cycle, FLUSH to WAIT_SLEEP (969-970), WAIT_SLEEP to SLEEP (601-607): the third cycle after the wfi's is the first asleep (states_after 3); halt_if holds the instruction already in IF through all of them.  SLEEP leaves to FIRST_FETCH the cycle after a line is pending (irq_pending_i: a line enabled in mie whatever mstatus.MIE, or irq_nm, or a debug request: 618-619), and in FIRST_FETCH the instruction in IF enters ID/EX (id_in_ready: 631-634), so the stream resumes 1 cycle after the first sleep cycle with the line up (wake_latency 1): the instruction behind the wfi is in ID/EX 5 cycles after the wfi when the line was up before the sleep, 2 cycles after the rise else.  An enabled line is taken from FIRST_FETCH as from DECODE (handle_irq: IRQ_TAKEN, 637-645), the entry counting from the first sleep cycle with the line up | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.rule | the lines are not registered: mip is the irq inputs themselves (cs_registers: mip.irq_* = irq_*_i) and irq_pending_o = \|(mip & mie); the controller's handle_irq = ~debug_mode & ~single_step & ~nmi_mode & (irq_nm \| (irq_pending & irq_enabled)) with irq_enabled = mstatus.MIE \| (priv == U).  In DECODE a pending request halts IF while the instruction in ID/EX is stalled or valid (stall \|\| id_wb_pending) and, once ID/EX is empty with no special request pending, the FSM enters IRQ_TAKEN for one cycle: pc_set to the vector (mtvec base + 4 * id), csr_save_if (mepc = the IF stage's pc, the next instruction to execute), csr_save_cause; then DECODE fetches the handler.  The same from FIRST_FETCH (after sleep or boot) | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.abandoned | nothing in flight is killed: the instruction in ID/EX completes first; the instruction in IF (fetched, not yet in ID/EX) is the one abandoned, its pc the mepc; what retires between the line's rise and the taking is the instruction in ID/EX at the rise and nothing more when it is single-cycle | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.registered | 0 | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.registered_note | no register on the line inside the core: mip is combinational from the inputs (cs_registers) and handle_irq from mip & mie, so the request is seen in the cycle the line is up at the core's input; the harness's test device registers its line (ibex1/tb/tb_ibex.sv), so that cycle is the raise record + 1, which our model's definition already counts (the 40X's 1 is its irq_q on top of it).  Read on the event suite, 29 Oct 2026: hze-alu_nosrc-00 raise 96 with the store's last cycle 96 and the auipc behind it entering ID/EX at 97 (its handover decided at 96, before the request was visible), the taking decided at 98; hze-nested-00's ARM raise at 92, the csrrsi's FLUSH at 92, the taking decided at 93 | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.blanking.after |  | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.blanking.cycles | 0 | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.blanking.note | no blanking term: a load or store in ID/EX holds the taking by its own stall (stall_mem) until its response, as any multi-cycle instruction does | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.blocked_by | flush_in_progress, sleep | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.blocked_by_note | the conditions that defer the taking while they hold: the instruction in ID/EX not done (stall: a multi-cycle unit, a memory response awaited: generic in-order completion, not a separate term), a special request in flight (special_req: an exception, mret, wfi or a flushing CSR write goes through FLUSH first), nmi_mode (no nested NMI while an NMI's handler runs, until its mret), debug mode and single-stepping, the committing micro-ops of a Zcmp sequence (not built: no Zcmp); sleep is the SLEEP state, left to FIRST_FETCH on a pending line (irq_pending_i, enabled by mie whatever mstatus.MIE, or irq_nm).  Read again 29 Oct 2026 (the event suite's first loop round: every taking 2 cycles late in our model, 3 after a flushing CSR write): flush_in_progress is the special request's FLUSH state and the fetch it makes (DECODE's !special_req: an mret, a wfi, a flushing CSR write or an exception goes through FLUSH, the taking waits for the refetched instruction's cycle); the instruction in ID/EX not done is the kills rule (IF alone killed: our model holds IF and counts the taking from the last cycle of the instruction in ID/EX) | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.kills | IF | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.kills_note | IRQ_TAKEN's pc_set drops the instruction in the IF/ID register (instr_valid_id_d & ~pc_set_i) and the prefetch buffer's contents (branch_i); ID/EX is empty by construction; a stage not killed completes first and the taking is decided the cycle after its last cycle (DECODE's !stall && !id_wb_pending, halt_if meanwhile: lines 702-724), so the entry's cycles count from that last cycle (29 Oct 2026) | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.confirm | 1 | exceptions_interrupts.rst 28-62 | stated |
| taking.interrupt.confirm_note | IRQ_TAKEN evaluates handle_irq again (lines 728-734: pc_set, csr_save_if and csr_save_cause only if handle_irq): a request withdrawn between DECODE's decision and that cycle is dropped, and the two cycles (DECODE's halt, IRQ_TAKEN) are lost, the instruction in IF entering ID/EX the cycle after (hze-withdrawn-00 koff 1, 29 Oct 2026: the line up for its store's cycle and one more, the RTL and Spike both without the handler, the next instruction 3 cycles after the store) | exceptions_interrupts.rst 28-62 | stated |
| taking.nmi.rule | irq_nm_i (irq_nm, with the internal integrity NMI not built) is taken as an interrupt by the same path, outside mstatus.MIE and mie, unless nmi_mode_q (an NMI's handler running) or debug; IRQ_TAKEN sets exc_cause ExcCauseIrqNm (mcause 0x8000001F), enters nmi_mode, and the vector is mtvec base + 0x7C; nmi_mode ends at the handler's mret (FLUSH: nmi_mode_d = 0) | exceptions_interrupts.rst 28-62 | stated |
| taking.nmi.abandoned | as an interrupt: the instruction in IF | exceptions_interrupts.rst 28-62 | stated |
| taking.nmi.registered | 0 | exceptions_interrupts.rst 28-62 | stated |
| taking.nmi.kills | IF | exceptions_interrupts.rst 28-62 | stated |
| latency.interrupt_entry.fetch | 3 | exceptions_interrupts.rst 28-62 | stated |
| latency.interrupt_entry.fetch_note | the handler's first instruction answered by the memory 3 cycles after the last cycle of the instruction in ID/EX: DECODE sees ID/EX empty and no special request (1), IRQ_TAKEN sets the pc and the prefetch buffer requests in that same cycle (2), the zero-wait memory answers and the fetch FIFO passes it through (3); it is in ID/EX the cycle after.  Its retirement adds its own occupancy: the vector table's jal takes 2 cycles, so the handler's first retirement is 5 cycles after the previous retirement on a single-cycle subject, 5 after a store's (the store's response cycle is its last), 6 after a flushing CSR write (its FLUSH cycle comes first), 8 after a wfi whose line was already up (FLUSH, WAIT_SLEEP, SLEEP, FIRST_FETCH, then the same path) | exceptions_interrupts.rst 28-62 | stated |
| latency.interrupt_entry.cycles | 7 | exceptions_interrupts.rst 28-62 | stated |
| latency.interrupt_entry.from | the cycle the harness raises the line (a SET store's request cycle, the line registered in the harness) to the handler's first retirement, the subject single-cycle and retiring the cycle after the store: 7 (hze-alu_nosrc-00 of 29 Oct 2026: raise 59, the store's RVFI 61, the handler's jal's RVFI 66) | exceptions_interrupts.rst 28-62 | stated |
| latency.interrupt_entry.state | the small configuration, zero-wait memory (gnt with the request, the response the cycle after), every interrupt vectored | exceptions_interrupts.rst 28-62 | stated |

## 8. What real programs pay on this core: the cycles lost to stalls, by cause

Measured by the timing survey: every retirement of every trace read as a timing skeleton (our timing-skeleton definition; the window 2 retirements before the subject) over 53,126,158 retirements of the generated suites, the certification tests and the benchmarks.  The manual has no equivalent.

| measure | value |
|---|---|
| cycles per retirement, the programs' single-cost skeletons (44,433,834 of the 48,141,362 retirements of the certification tests and the benchmarks, 92%) | 44,433,834 retirements, 65,521,179 cycles: CPI 1.475 (IPC 0.68) |
| real code's shapes no generated suite makes | 21.7% of the programs' retirements (by class) |

The cycles-per-retirement row covers the architecture certification tests and the benchmarks, over the retirements whose timing skeleton has a single cost; the whole-program CPI and IPC per benchmark suite are in the README beside this document.

What an ideal mechanism would save, as a ceiling and not a design (the profile summary carries the caveats):

| mechanism (the ideal, not a design) | retirements affected | upper bound on cycles saved | of the 65,521,179 single-cost cycles |
|---|---:|---:|---:|
| a perfect branch prediction: the follower of a taken branch at 1 cycle | 2,849,978 | 3,998,029 | 6.1% |
| no extra cycle at a pc+2 target | 757,994 | 757,994 | 1.2% |
| jump targets resolved in IF: the follower of a jal or jalr at 1 cycle | 1,977,946 | 452,532 | 0.7% |
| no load-use bubble | 252,411 | 252,411 | 0.4% |
| `c.lwsp` at one cycle | 211,087 | 211,087 | 0.3% |
| `c.swsp` at one cycle | 182,111 | 182,111 | 0.3% |
| `mul` at one cycle | 10,909 | 21,818 | 0.0% |
| `mulhu` at one cycle | 1 | 3 | 0.0% |

## 9. Where the RTL and the manual differ: the anomalies we found

Each row is a finding: what the manual says, what the RTL measured, the class (intent: the trigger is its cause and the manual is behind; over-wide: an interlock firing without its cause; narrower; function), its cost, and whose it is to act on (the documentation, the RTL, or the core's performance).  The reproducer, the two traces and the run's facts are in the issue directory named.

| finding | for | class | cost | found on | status | issue directory |
|---|---|---|---|---|---|---|
| A CSR write's flush costs two cycles; the manual gives no count | document | intent | two cycles on the instruction after a CSR write (csrrw, csrrs, csrrc and the immediate forms) of any CSR but mscratch and mepc, where the table's wording sugges | ibex | clarified; to file | [issues/csr-write-flush-two-cycles/](issues/csr-write-flush-two-cycles/) |
| The division row's '1 or 37' counts cycles, not the stalls its rule means | document | intent | none: one cycle on every division and remainder with a non-zero divisor, as a count the two pages disagree on (37 against 38), not a stall the core pays or save | ibex | clarified; to file | [issues/divider-37-cycles/](issues/divider-37-cycles/) |
| A trap entry and an mret cost a cycle more than a jump; no row says so | document | intent | one cycle more than a jump on every trap entry and every mret, the FLUSH state's own; the document gives no count for either | ibex | clarified; to file | [issues/flush-redirect-extra-cycle/](issues/flush-redirect-extra-cycle/) |
| No cycle count for an interrupt's entry or a wake from wfi | document | intent | an interrupt's entry costs 3 cycles beyond the pipeline's own (DECODE's decision, IRQ_TAKEN, the fetch) plus the vector table's jal; a wfi costs 4 cycles with t | ibex | clarified; to file | [issues/interrupt-and-wake-latency-unstated/](issues/interrupt-and-wake-latency-unstated/) |
| The RVFI's pc_wdata of an odd jalr target keeps bit 0 under the branch target ALU | rtl | function | none in execution; a trace consumer that trusts rvfi_pc_wdata (a cosimulation comparing the next pc, as ours) sees a mismatch on every odd-target jalr under Bra | ibex-maxperf | open; to file | [issues/rvfi-jalr-target-bit0-btalu/](issues/rvfi-jalr-target-bit0-btalu/) |
| A PMP-refused load or store faults after two cycles, no bus request | document | intent | two cycles on every load or store the PMP refuses, before the trap's own entry; a zero-wait memory's permitted access pays one | ibex-pmp | clarified; to file | [issues/pmp-fault-two-cycles/](issues/pmp-fault-two-cycles/) |
| A writeback-raised trap enters its handler a cycle after an ID/EX one | document | intent | one cycle more on the entry of every handler of a load or store fault than of an ID/EX exception | ibex-pmp | clarified; to file | [issues/pmp-fault-wb-entry-four-cycles/](issues/pmp-fault-wb-entry-four-cycles/) |
| A misaligned store the PMP refuses still writes its second half | rtl | function | none in cycles; a store that faults leaves half its data in memory, which software handling the fault may not expect | ibex-pmp | clarified; to file | [issues/pmp-misaligned-store-second-half-written/](issues/pmp-misaligned-store-second-half-written/) |
| With PMPEnable 0 the PMP CSRs trap as illegal, not read as zero | document | intent | none in cycles; an illegal-instruction trap where software expects a zero | ibex | clarified; to file | [issues/pmp-disabled-csrs-illegal/](issues/pmp-disabled-csrs-illegal/) |
| The manual's W=1 R=0 rule holds only while mseccfg.MML is clear | document | intent | none in cycles; a permission reading software would get wrong from the manual under MML | ibex-pmp | clarified; to file | [issues/pmp-w-without-r-under-mml/](issues/pmp-w-without-r-under-mml/) |
| Two inherited layer reasons say 'no PMP' on the PMP build | document | intent | none; a reason in our own layer | ibex-pmp | open; not needed | - |
| In U-mode an interrupt is taken with mstatus.MIE clear; the manual's enable rule omits it | document | intent | none in cycles; software reading the manual would expect MIE to mask interrupts in U, which it does not | ibex | confirmed; to file | [issues/interrupts-in-user-whatever-mie/](issues/interrupts-in-user-whatever-mie/) |
| Instructions cost the same cycles in U-mode as in M-mode, unstated | document | intent | none; a statement the manual lacks | ibex | confirmed; to file | [issues/user-mode-costs-as-machine-mode/](issues/user-mode-costs-as-machine-mode/) |
| Any CSR write but mscratch and mepc flushes the pipeline, harmless ones too | performance | over-wide | two cycles on every write of a CSR that changes nothing in flight: the counters and their inhibit, the event selectors, mtval, mcause, mcounteren; a trap handle | ibex | clarified; to file | [issues/csr-write-flush-any-csr/](issues/csr-write-flush-any-csr/) |

## 10. What the base build's rows leave to a configuration, and what no test reaches

Every stall and flush term in the RTL source that the base build's own rows do not state is listed here, with where it is handled.  Of the 15 terms: 6 are stated and tested under a configuration of the core (its part of section 12) or became rows of this specification after the source was read -- not gaps, pointers; 4 no test of ours will reach, each with its reason; 5 await a feature we have not built.  Beside the terms, our reading of the RTL source raised 6 questions the manual does not answer (6 on the base build): 2 are answered by a measurement and stated above; 4 are still open (4 on the base build) and head the table in 10.2.  A row in 10.2 is a hole in the specification, named rather than hidden.

### 10.1 Specified under a configuration

| term | what it is | where it is stated |
|---|---|---|
| `stall_ld_hz` | the load-use hazard stall exists only with the writeback stage (gen_stall_mem, lines 991-1124: rf_rd_a_hz, rf_rd_b_hz against the load in WB); the two-stage build assigns it 0 | covered on ibex-maxperf: WritebackStage = 1 there: its specification's raw_*_load_d1 hold and its question load_use_late_response (ibex-maxperf/the RTL questions) |
| `outstanding_memory_access` | gen_stall_mem: with the writeback stage a memory instruction leaves ID/EX before its response and the next instruction waits on outstanding_memory_access, stall_wb and the exception pending in WB; none of it is elaborated here | covered on ibex-maxperf: memory.data.response_wait_freeze and the question wb_response_freeze there |
| `wb_exception_o` | g_wb_exceptions: the exception priority with a load or store error from WB first (store_err_q, load_err_q), wb_exception_o keeping the instruction in ID/EX from executing, and DECODE's wait for ready_wb_i \| wb_exception_o before FLUSH (673-681: 'without a writeback stage ready_wb_i == 1 so the FSM will always go directly to FLUSH'); g_no_wb_exceptions (339-372) ties wb_exception_o to 0 here, and the mepc save of a WB exception (g_writeback_mepc_save, 836-843) is not elaborated | covered on ibex-maxperf: the controller's stall = stall_id_i \| stall_wb_i there (its stated entry stall_wb) and its question data_err_fault raised from WB; ibex-pmp's trap_lsu 'WB+2' (the finding pmp-fault-wb-entry-four-cycles) |
| `BranchTargetALU` | with the branch target ALU a jump needs one cycle (stall_jump = 0) and a taken branch's target comes with its condition (branch_set_raw from the unregistered path, one cycle less); this build has neither | covered on ibex-maxperf: BranchTargetALU = 1 there: its stated entries stall_jump, stall_branch and branch_target_o (occupancy.jal 1, occupancy.branch 1 with the redirect first) |
| `pmp_err_q` | a PMP refusal of a data access is registered in the address phase and consumed as an error without a bus transaction (data_pmp_err_i); without PMP the input is tied low inside ibex_core; the fetch side's pmp_err_if_i (ibex_if_stage.sv 427-431) likewise | covered on ibex-pmp: PMPEnable = 1 with 16 regions there: its questions pmp_fault_lsu_aligned, pmp_fault_lsu_misaligned_first, pmp_fault_lsu_misaligned_second and pmp_fault_fetch, its specification's memory.pmp.fault_cycles 2 and control.flush trap_lsu 'WB+2' (the findings pmp-fault-two-cycles, pmp-fault-wb-entry-four-cycles, 31 Oct 2026) |
| `RV32MSingleCycle` | gen_mult_single_cycle (lines 140-260): three 17-bit multipliers, a mul valid in its first cycle (mult_valid = mult_en_i in MULL) and a mulh in two (the MULH state after it), with mult_hold on ~multdiv_ready_id_i; this build elaborates gen_mult_fast (the stated entry mult_state_q).  RV32MSlow's ibex_multdiv_slow.sv and RV32MNone are not instantiated on any configuration here | covered on ibex-maxperf: RV32M = RV32MSingleCycle there: its stated entries stall_multdiv and mult_state_q (occupancy.mul 1, occupancy.mulh 2) |

### 10.2 Not reached, and why

| core | what | why | reach | RTL |
|---|---|---|---|---|
| ibex | open question `data_err_fault` | data_err_i with data_rvalid_i (ibex_load_store_unit.sv 703-709: data_or_pmp_err, lsu_err_q) raises load_err_i or store_err_i, exc_req_lsu, a special_req_pc_change: FLUSH sets the pc to the exception vector with ExcCauseLoadAccessFault or ExcCauseStoreAccessFault and mtval = lsu_addr_last_i (the faulting part's address); without the writeback stage the error arrives in the instruction's own ID/EX cycles (stall_mem holds it to the response), so it ranks after the ID/EX exceptions in g_no_wb_exceptions (361-364) and the redirect follows the trap row's path | open | rtl/ibex_controller.sv:276-277, 291, 828-836, 905-930 |
| ibex | open question `fetch_err_trap` | instr_err_i with the fetched word (ibex_if_stage.sv 282, carried in the IF/ID register as instr_fetch_err_o) makes the instruction an exception request (ExcCauseInstrAccessFault, mtval the faulting pc or pc + 2 for the second half of an unaligned instruction) and keeps it from executing (instr_executing_spec, ibex_id_stage.sv 1149) | open | rtl/ibex_controller.sv:232, 269-273, 828-852 |
| ibex | open question `ebreak_debug_entry` | an ebreak with dcsr.ebreakm set in M-mode or dcsr.ebreaku set in U-mode (ebreak_into_debug, from the dcsr fields by priv_mode_i) enters debug mode through DBG_TAKEN_ID rather than taking the breakpoint exception; a test could set it with a write of dcsr | open | rtl/ibex_controller.sv:484-486, 869-893 |
| ibex | open question `debug_req_entry` | a debug request (debug_req_i) or a single step enters DBG_TAKEN_IF once the instruction in ID has finished, saving the IF pc to dpc | open | rtl/ibex_controller.sv:702-714, 767-785 |
| ibex | not built: `data_ind_timing_i` | cpuctrlsts.data_ind_timing reads as zero without SecureIbex (cs_registers.rst): the branch's fixed two cycles whatever its condition, and the divider's full sequence on a zero divisor (ibex_multdiv_fast.sv 434, 445), never fire on this build | awaiting a feature: our records and our records: the data-independent-timing promise on the ibex-opentitan configuration, SecureIbex = 1 | rtl/ibex_id_stage.sv:918-926 |
| ibex | not built: `INSTR_EXPANDED_COMMIT` | handle_irq is held off while a Zcmp pop's commit sequence or a move executes (instr_gets_expanded_i == INSTR_EXPANDED_COMMIT; pipeline_details.rst's Zcmp note), and a debug entry while any expanded micro-op runs (477-480); RV32ZC = RV32Zca builds no Zcmp expansion | awaiting a feature: our records: Zcmp with the shared ISA-layer work (cores-PLAN's cv32e40s round step 1); ibex-maxperf builds the expansion (RV32ZcaZcbZcmp) and no suite yet makes a Zcmp instruction (its own not-built entry) | rtl/ibex_controller.sv:477-480, 501-503 |
| ibex | not built: `icache_enable_i` | gen_icache: the instruction cache in place of the prefetch buffer, with its hit and miss timing and the fence.i invalidation; the prefetch buffer is built here (gen_prefetch_buffer) | awaiting a feature: our records, the cores table and step 10: ibex-icache (ICache = 1, ICacheECC = 1) from ibex-pmp, then ibex-opentitan | rtl/ibex_if_stage.sv:299-398 |
| ibex | not built: `instr_intg_err` | the integrity check of fetched words (MemECC = SecureIbex) and of data responses (ibex_load_store_unit.sv 393-397): an integrity error is a fetch error or an internal NMI; not built, the harness's intg inputs tied 0 | awaiting a feature: our records (ibex-PLAN step 7's remainder): the ibex-opentitan configuration, the harness producing the integrity bits | rtl/ibex_if_stage.sv:275-283 |
| ibex | not built: `irq_nm_int` | g_intg_irq_int (MemECC = SecureIbex): a load or store response with an integrity error sets mem_resp_intg_err_irq_pending_q, the internal NMI (irq_nm = irq_nm_ext_i \| irq_nm_int, 490), taken by IRQ_TAKEN's NMI branch with the cause NMI_INT_CAUSE_ECC and mtval the access's address (739-746), cleared on entering its handler unless the external NMI is also up; g_no_intg_irq_int (440-449) ties irq_nm_int to 0 here, so the NMI is the external line alone (events.nmi.trigger) | awaiting a feature: our records: the ibex-opentitan configuration with SecureIbex = 1 | rtl/ibex_controller.sv:394-449 |
| ibex | not built: `nt_branch_mispredict_o` | the static predictor's taken-by-default and its mispredict (ibex_if_stage.sv 238-239, 285-293): the predictor is experimental and off in every configuration run here | out: our records, the configurations table: the experimental branch predictor is not run; our records waits for a core that predicts | rtl/ibex_controller.sv:684-698 |
| ibex | not built: `stall_dummy_instr` | gen_dummy_instr: dummy instructions inserted between real ones (DummyInstructions = SecureIbex); off here, and left off by cpuctrlsts.dummy_instr_en on the secure configuration too | out: our records and the configurations table: dummy instructions stay off on every configuration (timing noise by design) | rtl/ibex_if_stage.sv:544-590 |
| ibex | not built: `cheriot_enable_i` | the CHERIoT capability accesses (CTX_WAIT_GNT1, CTX_WAIT_GNT2, CTX_WAIT_RESP; the cheriot_* exception terms of ibex_controller.sv 209-220, 269-273) exist only with BaseIsa = BaseIsaRV32IorCHERIoT and cheriot_enable_i On; the opentitan configuration builds them and ties the enable Off | out: our records, the other lowRISC cores: a CHERIoT round needs the CHERIoT Sail model as its reference and is not planned | rtl/ibex_load_store_unit.sv:436-473, 573-616 |
| ibex | not built: `trigger_match_i` | a hardware breakpoint's trigger match enters debug mode (DBG_CAUSE_TRIGGER); no trigger is built, and the trigger CSRs are illegal (the stated entry illegal_csr_insn_o) | out: debug is deferred by the user; the harness ties debug_req_i off | rtl/ibex_controller.sv:515-519 |

## 11. How far this specification has been checked: the evidence behind it

| measure | value |
|---|---|
| findings in the record | 14 (11 document, 2 rtl, 1 performance) |

Our generated test suites run against this specification's prediction at every retirement on every regression; their counts and coverage are in the README beside this document.  Deliberate faults injected into the RTL (the timing and functional mutation campaign) prove the suites see what they claim.

## 12. The configurations: what each build adds or changes

None.

© 2026 processor-timing-anomalies, Apache License 2.0
