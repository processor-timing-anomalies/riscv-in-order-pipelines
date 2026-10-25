# A counter read costs one cycle more while an instruction is in WB

- Title: counter-read-stall
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle on every read of a counter while an instruction is in WB
- Core: cv32e40x

## Issue

a read of a counter (mcycle, minstret, their high halves, mhpmcounter3) costs one more cycle than the cycle table's 1, when an instruction is in WB.

## What the documentation says

pipeline.rst, 'Cycle counts per instruction type': CSR Access 1 cycle for every CSR but jvt (lines 44-46); the Hazards list (lines 114-126) names no stall on a read of a counter

## What the RTL does

csrrs of mcycle or minstret retires 2 cycles after the instruction before it, straight-line or 2-3 behind a taken jalr; of mscratch, 1; one right behind a jump shows nothing, the jump's bubble having emptied WB

## From the RTL source (read, not measured)

`rtl/cv32e40x_controller_bypass.sv`, lines 269-273 (`minstret_stall`): the stall has a signal and a comment of its own ('Stall (EX) due to performance counter read'), outside the three CSR stall cases the file lists at lines 241-246: it is not the implicit CSR write of the Hazards list's line 120

## To reproduce

The programs in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro-probe-csr-read.S`
- `repro-probe-csrs.S`
- `repro.S`

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- order 22 csrrs a2, mcycle, zero: RTL 2 cycles; the documentation, read as written, gives 1

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/openhwgroup/cv32e40x.git at d952cd63bc1b4eb58cd893c28ef8283c781e345e; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-10-01

---

© 2026 processor-timing-anomalies, Apache License 2.0
