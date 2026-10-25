# CLIC: a CSR instruction one behind an mscratchcswl access waits a cycle

- Title: clic-csr-after-implicit-write-stall
- Class: over-wide -- the stall fires in cases that have no cause for it: an interlock wider than needed, a performance flaw. The cause is an explicit read racing the implicit write of mscratch (and mcause, mintstatus); the trigger fires on a mintthresh access, which reads none of them, so the interlock is wider than its cause; the mscratch access behind it is the cause case
- Cost: one cycle on every CSR instruction one behind an mscratchcswl access, in CLIC mode (an interrupt handler prologue does an mscratchcswl and then a CSR access as a matter of course)
- Core: cv32e40x
- Found while running: cv32e40x-clic

## Issue

in CLIC mode a CSR instruction (read or write form, of any CSR: mintthresh, mscratch, mscratchcswl itself) one behind csrrw rd, mscratchcswl, rs1 retires a cycle late; the mscratchcswl access writes mscratch implicitly and the core holds every explicit CSR access in the execute stage while that implicit write is in the write stage, whether or not the access names a register the swap touches.

## What the documentation says

pipeline.rst, Hazards: the list names the implicit CSR read in EX behind a CSR access in WB (line 119, the known finding clic-implicit-csr-read-stall) and no stall of an explicit CSR access behind an implicit CSR write; the CLIC chapter of control_status_registers.rst describes mscratchcswl's swap of mscratch and says nothing of timing

## What the RTL does

csrrw s4, mscratchcswl, s3 then csrrw s5, mintthresh, s2: the second retires 2 cycles after the first (1 behind any other CSR write); the same for csrrw s5, mscratch, s2 and for csrrs s5, mintthresh, x0 (cross clic5 of 21 Oct 2026, files 002 and 003; under bus waits the same, clic6); two back it costs 1

## From the RTL source (read, not measured)

`rtl/cv32e40x_controller_bypass.sv`, lines 259-266 (`csr_impl_write_in_wb (csr_stall_ex, rule 2)`): read 21 Oct 2026 (ours, not the RTL pass's): 'an explicit CSR read is in EX while any implicit write is in WB (conservative stall)' -- the stall is keyed on any implicit write in WB, not on the CSR the read names; mscratchcswl sets csr_impl_wr for the mscratch swap

## To reproduce

The program in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro.S`

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- order 323 csrrw s5, 0x347, s2: RTL 2 cycles; the documentation, read as written, gives 1

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/openhwgroup/cv32e40x.git at d952cd63bc1b4eb58cd893c28ef8283c781e345e; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-10-22

---

© 2026 processor-timing-anomalies, Apache License 2.0
