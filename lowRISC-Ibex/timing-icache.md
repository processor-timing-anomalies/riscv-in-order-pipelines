# Our accurate, complete timing specification for the Ibex maxperf build with B full, PMP and the instruction cache

Generated from our records of the Ibex maxperf build with B full, PMP and the instruction cache on 5 November 2026, for the RTL at commit `c0c07085791e4d16a0f2d9a753b2fb79d72e5ffa`; the configurations measured: none.  The timing is as measured on that commit; the document is regenerated after every run we record.

This document states what the ibex-icache core promises in time: the pipeline as a structure, the cycle each instruction class takes, the stalls and bubbles between instructions, the memory side under a stated bus, the CSR accesses that wait, the interrupts and other events, what real programs pay on it, and where the RTL and the user manual disagree.  It is the rendering of our internal machine-readable version of the RISC-V ISA, this core's layer distilled from its user manual with a citation or a graded reading on every field, a configuration layer for each variant, and the RTL read only to answer what the manual leaves open.  It describes the implementation as measured; a row graded inferred or read is not design intent until the core's authors take it as theirs (the grade authored).

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
| result available, per class | alu_rr: IDEX, alu_ri: IDEX, alu_nosrc: IDEX, load: WB, store: WB, branch: IDEX, jal: IDEX, jalr: IDEX, csr_r: IDEX, csr_i: IDEX, mul: IDEX, mulh: IDEX, div: IDEX, system: IDEX, trap: IDEX, zcpush: IDEX, zcpop: IDEX, zcpopret: IDEX, zcmv: IDEX | - | - |
| occupancy, per class (cycles beyond the first in the stage named) | mul: 1; mulh: 2; div: default 2 to 37; rule 2 if rs2 == 0 else 37; load: default 1; misaligned 2; store: default 1; misaligned 2; jal: default 1; redirect first; jalr: default 1; redirect first; branch: default 1; taken 1; redirect first; fence.i: default 1; redirect first; zcpush: default 2 to 14; rule nreg + 1; zcpop: default 2 to 14; rule nreg + 1; zcpopret: default 3 to 16; rule nreg + 2 + popretz; zcmv: 2 | - | - |
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

8,449 cases in all, one per subject class, port, producer class and distance; rows identical across subject classes are shown once.  Kinds: raw (a read after a write), war, waw, ctrl (a control transfer ahead), struct (a resource).  Words: "stall n", the reader waits n cycles; "forward 0", the value is forwarded and nothing waits; "bubble n", the fetch after a taken control transfer; "squash 0", an instruction on the wrong path, killed; two words in one cell are the two outcomes (taken / not taken); "none", no cost.

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
| fetch | model icache; outstanding 2; buffer_words 3; cache ways 2; sets 256; line_bytes 8; fill_buffers 4; replacement round_robin_global; inval_on fence.i, reset; inval_cycles 256; enable cpuctrlsts.0; enabl | rtl/ibex_icache.sv, rtl/ibex_if_stage.sv 222-231, 248-253, 267, 690, 699-704, 709-711, 714-721, 727, 731-737, 744, 764-782, 788-789, 798-813, 832-835, 846-859, 1033-1036, 1051, 1063-1083, 1134-1138; if_stage 299-349, 850 | read |

## 6. CSRs and counters: the accesses that wait

Which CSR accesses wait, on what, and for how long.  A CSR instruction reads and writes its CSR in the stages the structure names; the rows here are the core's own statements about CSR order, the counters every retirement updates, and the CSRs with implicit accesses.

*(none)*

## 7. Interrupts and other events: when they are taken and what they cost

No events section in this specification.

## 8. What real programs pay on this core: the cycles lost to stalls, by cause

Measured by the timing survey: every retirement of every trace read as a timing skeleton (our timing-skeleton definition; the window 3 retirements before the subject) over 11,769,828 retirements of the generated suites, the certification tests and the benchmarks.  The manual has no equivalent.

| measure | value |
|---|---|
| cycles per retirement, the programs' single-cost skeletons (145,896 of the 370,350 retirements of the certification tests and the benchmarks, 39%) | 145,896 retirements, 264,779 cycles: CPI 1.815 (IPC 0.55) |
| real code's shapes no generated suite makes | 9.2% of the programs' retirements (by class) |

The cycles-per-retirement row covers the architecture certification tests and the benchmarks, over the retirements whose timing skeleton has a single cost; the whole-program CPI and IPC per benchmark suite are in the README beside this document.

What an ideal mechanism would save, as a ceiling and not a design (the profile summary carries the caveats):

| mechanism (the ideal, not a design) | retirements affected | upper bound on cycles saved | of the 264,779 single-cost cycles |
|---|---:|---:|---:|
| no load-use bubble | 34,695 | 34,695 | 13.1% |
| a perfect branch prediction: the follower of a taken branch at 1 cycle | 7,887 | 8,709 | 3.3% |
| jump targets resolved in IF: the follower of a jal or jalr at 1 cycle | 1,924 | 3,285 | 1.2% |
| no extra cycle at a pc+2 target | 12 | 12 | 0.0% |

## 9. Where the RTL and the manual differ: the anomalies we found

Each row is a finding: what the manual says, what the RTL measured, the class (intent: the trigger is its cause and the manual is behind; over-wide: an interlock firing without its cause; narrower; function), its cost, and whose it is to act on (the documentation, the RTL, or the core's performance).  The reproducer, the two traces and the run's facts are in the issue directory named.

| finding | for | class | cost | found on | status | issue directory |
|---|---|---|---|---|---|---|
| With the cache disabled the fetch stream is the cache's own, not the prefetch buffer's | document | intent | under instruction-side wait states, a different cycle on most redirects and sequential fetches than the uncached build's: a user who turns the cache off to get  | ibex-icache | confirmed; to file | [issues/icache-disabled-is-not-the-prefetch-buffer/](issues/icache-disabled-is-not-the-prefetch-buffer/) |
| A fence.i on the cached build costs a 258-cycle walk of bus fetches; the table says 1 - N | document | intent | 258 cycles of fetch at the bus's miss cost after every fence.i on a cached build, against the table's '1 - N' | ibex-icache | confirmed; to file | [issues/icache-fence-i-walk-258-cycles/](issues/icache-fence-i-walk-258-cycles/) |
| The first 258 cycles after reset are an invalidation walk: every fetch a bus request | document | intent | 258 cycles at the start of every run at the bus's miss cost; a short program's cycles per instruction on the cached build say more about the walk than the cache | ibex-icache | confirmed; to file | [issues/icache-reset-walk/](issues/icache-reset-walk/) |
| A fill buffer frees the cycle after its last word, so the next lookup waits a cycle | document | intent | one cycle on a lookup that waits for a buffer to free, under instruction-side wait states | ibex-icache | confirmed; to file | [issues/icache-fill-buffer-frees-a-cycle-late/](issues/icache-fill-buffer-frees-a-cycle-late/) |
| A misaligned access holds ID/EX until both halves are accepted and its first response | document | intent | under data-side wait states, the cycles of the second half's grant and the first half's response, on every misaligned access | ibex-icache | confirmed; to file | [issues/split-access-holds-until-both-halves-accepted/](issues/split-access-holds-until-both-halves-accepted/) |

## 10. What the base build's rows leave to a configuration, and what no test reaches

Every stall and flush term in the RTL source that the base build's own rows do not state is listed here, with where it is handled.  Of the 4 terms: 2 are stated and tested under a configuration of the core (its part of section 12) or became rows of this specification after the source was read -- not gaps, pointers; 1 no test of ours will reach, each with its reason; 1 await a feature we have not built.  Beside the terms, our reading of the RTL source raised 8 questions the manual does not answer (8 on the base build): 7 are answered by a measurement and stated above; 1 are still open (1 on the base build) and head the table in 10.2.  A row in 10.2 is a hole in the specification, named rather than hidden.

### 10.1 Specified under a configuration

| term | what it is | where it is stated |
|---|---|---|
| `valid_new_req` | the prefetch buffer's request rule (NUM_REQS 2 outstanding, a new request with room in the FIFO or on a branch, the request held until granted) and its fifo_clear on every redirect are not elaborated on this build: gen_icache replaces the module, and the cache's own request stream (lookup_req_ic0, fill_ext_req, instr_req) takes its place -- the questions fetch_disabled_stream and fetch_miss_* (answered) and the correction memory.fetch.model (taken).  RTL_CTRL lists the file; the check requires it in rtl.files | covered on ibex-pmp: ICache = 0 there: its stated entry valid_new_req (memory.fetch.outstanding 2), inherited from ibex-maxperf's, and the fetch model fetchmodel.py checked under the fetch rotation on 3-4 Nov 2026 |
| `DEPTH` | the three-entry FIFO (DEPTH = NUM_REQS + 1) and its valid_unaligned rule for an uncompressed instruction at a half-word address are not elaborated on this build; the cache's fill buffers hold the words (two beats per line, up to four lines) and its 16-bit skid buffer takes the misaligned case (the stated entry skid_ready).  RTL_CTRL lists the file; the check requires it in rtl.files | covered on ibex-pmp: ICache = 0 there: its stated entry DEPTH (memory.fetch.buffer_words 3, penalties.misaligned_target 1), inherited from ibex-maxperf's |

### 10.2 Not reached, and why

| core | what | why | reach | RTL |
|---|---|---|---|---|
| ibex-icache | open question `fetch_ecc_error_refetch` | ecc_err_ic1 = lookup_valid_ic1 & (((\|data_err_ic1) & tag_hit_ic1) \| (\|tag_err_ic1)); ecc_correction_ways_d, ecc_correction_write_d = ecc_err_ic1 registered into ecc_write_req, ecc_write_ways, ecc_write_index; ecc_error_o = ecc_err_ic1 | open | rtl/ibex_icache.sv:546-600, 645-651 |
| ibex-icache | not built: `ic_scr_key_valid_i` | AWAIT_SCRAMBLE_KEY waits for the key provider: OUT_OF_RESET and every invalidation request raise ic_scr_key_req_o when the key is not valid and the walk starts only when it is. | awaiting a feature: our records Ibex step 5: ibex-opentitan (ICacheScramble 1) with the key handshake in the harness answering scramble_req_o after a programmable number of cycles | rtl/ibex_icache.sv:1228-1247 |
| ibex-icache | not built: `cache_cnt_q` | gen_caching_logic: allocate only a redirect's target line and CACHE_AHEAD = 2 lines after it (fill_cache_new gated by branch_i \| cache_cnt_q); this build elaborates gen_cache_all (687-691: every miss allocates, the stated entry lookup_actual_ic0). | out: no build of Ibex reaches it: the parameter is the module's alone, not passed by ibex_if_stage.sv 301-307 or ibex_top.sv; the specification's replacement and fill rules are the allocate-everything ones | rtl/ibex_icache.sv:666-686 |

## 11. How far this specification has been checked: the evidence behind it

| measure | value |
|---|---|
| findings in the record | 5 (5 document) |

Our generated test suites run against this specification's prediction at every retirement on every regression; their counts and coverage are in the README beside this document.  Deliberate faults injected into the RTL (the timing and functional mutation campaign) prove the suites see what they claim.

## 12. The configurations: what each build adds or changes

None.

© 2026 processor-timing-anomalies, Apache License 2.0
