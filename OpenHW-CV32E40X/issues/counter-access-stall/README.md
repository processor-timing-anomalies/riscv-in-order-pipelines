# Any CSR instruction naming a counter costs one cycle more while an instruction is in WB

- Title: counter-access-stall
- Class: over-wide -- the stall fires in cases that have no cause for it: an interlock wider than needed, a performance flaw. The stall fires for csrrw with rd = x0, a write that reads nothing, and for mhpmcounter4-31, counters this configuration does not implement: an interlock on the counter address rather than on the read, wider than its cause (a read racing the counter's update); the user-level aliases, hpmcounter4-31 among them, stall the same (15 Oct 2026)
- Cost: one cycle on every CSR instruction that names any counter, machine-level or user alias, implemented or not, reading it or not, while an instruction is in WB
- Core: cv32e40x

## Issue

a CSR instruction that names a counter costs one more cycle than the cycle table's 1 when an instruction is in WB, whether or not it reads the counter, and for the event counters this configuration does not implement as well; the user-level aliases (cycle, instret, hpmcounter3-31 and their halves) stall the same way.

## What the documentation says

pipeline.rst, 'Cycle counts per instruction type': CSR Access 1 cycle for every CSR but jvt (lines 44-46); the Hazards list names no stall on an access of a counter (lines 114-126)

## What the RTL does

csrrw with rd = x0 -- a write that reads nothing -- of mcycle, mcycleh, minstret, minstreth, mhpmcounter3, mhpmcounter3h, mhpmcounter4, mhpmcounter4h, mhpmcounter31 or mhpmcounter31h retires 2 cycles after the instruction before it, behind an ALU instruction, a load, a store, a CSR instruction, a multiply or a divide (116 of 116).  csrrs reading mhpmcounter4, mhpmcounter31 or their high halves, which read 0 with NUM_MHPMCOUNTERS = 1, does the same (80 of 84; the four that retire after the cycles expected are behind a write of the same counter, where the read waits for that write already).  15 Oct 2026, two generated tests on cv32e40x reading every user-level counter with csrrs and with csrrc: every csrrs or csrrc of cycle, instret, hpmcounter3 to hpmcounter31 or their high halves behind an instruction in WB retires 2 cycles after it, 61 reads in each file, hpmcounter4 to 31 reading zero (not implemented) and stalling all the same

## From the RTL source (read, not measured)

`rtl/cv32e40x_cs_registers.sv`, lines 302-304 (`csr_raddr`): the flag that holds a counter access in EX (csr_counter_read_o) is decoded from the address field of the CSR instruction alone, for mcycle, minstret, mhpmcounter3 to 31 and their high halves (lines 580-592, 632-644): it does not depend on the instruction reading, nor on NUM_MHPMCOUNTERS

## To reproduce

The programs in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro-1.S`
- `repro.S`

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- order 4041 csrrs s9, mhpmcounter4, zero: RTL 2 cycles; the documentation, read as written, gives 1
- order 227 csrrw zero, mcycle, a7: RTL 2 cycles; the documentation, read as written, gives 1

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/openhwgroup/cv32e40x.git at d952cd63bc1b4eb58cd893c28ef8283c781e345e; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-10-04

---

© 2026 processor-timing-anomalies, Apache License 2.0
