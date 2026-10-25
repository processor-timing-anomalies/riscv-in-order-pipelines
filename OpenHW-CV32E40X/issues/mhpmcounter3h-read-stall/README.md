# A read of mhpmcounter3h costs one cycle more while an instruction is in WB

- Title: mhpmcounter3h-read-stall
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle on every read of mhpmcounter3h while an instruction is in WB
- Core: cv32e40x

## Issue

a read of mhpmcounter3h costs one more cycle than the cycle table's 1 when an instruction is in WB, as a read of the other counters does.

## What the documentation says

pipeline.rst, 'Cycle counts per instruction type': CSR Access 1 cycle for every CSR but jvt (lines 44-46); the Hazards list names no stall on a counter read (lines 114-126); perf_counters.rst lists mhpmcounter3(h) among the counters and gives no timing

## What the RTL does

csrrs of mhpmcounter3h retires 2 cycles after the instruction before it in 20 of 21 reads, behind an ALU instruction, a load, a store, a multiply or a divide; the one read that retires as predicted is behind a write of the same counter, where the read waits for the write already

## From the RTL source (read, not measured)

`rtl/cv32e40x_cs_registers.sv`, lines 632-644 (`csr_counter_read_o`): the flag that holds a counter access in EX is set for mhpmcounter3h to mhpmcounter31h as it is for mcycleh and minstreth

## To reproduce

The program in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro.S`

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- order 1522 csrrs a6, mhpmcounter3h, zero: RTL 2 cycles; the documentation, read as written, gives 1

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/openhwgroup/cv32e40x.git at d952cd63bc1b4eb58cd893c28ef8283c781e345e; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-10-04

---

© 2026 processor-timing-anomalies, Apache License 2.0
