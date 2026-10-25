# fence.i costs 6 cycles, not the cycle table's 5

- Title: fencei-six-cycles
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle on every fence.i beyond the cycle table's five
- Core: cv32e40x

## Issue

fence.i costs 6 cycles, not the 5 of the cycle table.

## What the documentation says

pipeline.rst, 'Cycle counts per instruction type': fence.i 5 (6 when the target is a non-word-aligned non-RVC instruction), 'implemented as a jump to the instruction following'; its description adds that it 'will not complete until the external handshake has been completed', and fencei.rst:8-11 describes that handshake as one cycle with fencei_flush_req_o high

## What the RTL does

a fence.i retires 3 cycles after the instruction before it and the instruction after it retires 4 cycles after the fence.i: 7 cycles from the one before to the one after, 6 beyond back-to-back, where the table's 5 gives 6 in all; measured on three fence.i's in straight-line code, with fencei_flush_ack_i tied high

## To reproduce

The program in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro.S`

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- order 4 fence.i: retires 3 cycles after the nop before it
- order 5 the instruction after the fence.i: retires 4 cycles after it -- 7 cycles from the nop before the fence.i to this one, 6 beyond back-to-back; the cycle table's 'fence.i 5' gives 6, so the pair costs one cycle more than the table says (the handshake cycle of fencei.rst)

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/openhwgroup/cv32e40x.git at d952cd63bc1b4eb58cd893c28ef8283c781e345e; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-10-01

---

© 2026 processor-timing-anomalies, Apache License 2.0
