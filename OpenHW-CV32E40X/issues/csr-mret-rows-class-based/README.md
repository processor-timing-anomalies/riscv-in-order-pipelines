# An mret stalls behind any CSR access, including the CSRs it does not read

- Title: csr-mret-rows-class-based
- Class: over-wide -- the stall fires in cases that have no cause for it: an interlock wider than needed, a performance flaw. The mret interlock fires on any CSR access, mscratch included, which mret does not read: the trigger is wider than its cause (mret's implicit reads of mstatus and mepc), as the manual words it
- Cost: two cycles on an mret one behind any CSR access and one cycle two behind, mscratch and the other CSRs mret does not read included
- Core: cv32e40x

## Issue

the Hazards rows for mret (126: 2 cycles behind a CSR access in EX; 118: 1 cycle behind one in WB) are exact as worded, 'a CSR access instruction', any CSR: the RTL stalled an mret 2 cycles behind a csrrc of mscratch, which mret does not read.

## To reproduce

The program in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro.S`

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- orders 53..54 (mret: 3 cycles after the previous retirement): an mret one behind a csrrc of mscratch, a CSR it does not read, retires +2 (the manual's rows 126 and 118 say any CSR access; the second window, orders 110-112, is the same two behind at +1)

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/openhwgroup/cv32e40x.git at d952cd63bc1b4eb58cd893c28ef8283c781e345e; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-10-15

---

© 2026 processor-timing-anomalies, Apache License 2.0
