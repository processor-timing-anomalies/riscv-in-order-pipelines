# CLIC: a load or store one behind an mcause write waits a cycle

- Title: clic-mcause-write-irq-enable-stall
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle on every load or store one behind an mcause write, in CLIC mode (an interrupt handler that rewrites mcause before saving state pays it)
- Core: cv32e40x
- Found while running: cv32e40x-clic

## Issue

in CLIC mode a load or a store one behind a write of mcause retires a cycle late: the core treats an mcause write as a write that may enable an interrupt, as it treats a write of mstatus or mintthresh, because in CLIC mode the mpp and mpie fields of mcause are the same bits as mstatus's; the manual's hazard list names no stall behind a write of mcause.

## What the documentation says

pipeline.rst, Hazards: no entry for a load or store behind a write that may enable an interrupt, and none for mcause; control_status_registers.rst's CLIC section says mcause.mpp and mcause.mpie are aliases of mstatus's fields and says nothing of timing

## What the RTL does

csrrw x0, mcause, s2 then lw s4, 0(a5): the load retires 2 cycles after the write (1 behind any other CSR write of the base set); the same for sw, lbu, sh; two to four behind, 1 (the row cross cross2 of 22 Oct 2026 on cv32e40x-clic, files 259 and 260; on cv32e40x, where mcause is not aliased, the same load pays nothing, cross2 there)

## From the RTL source (read, not measured)

`rtl/cv32e40x_cs_registers.sv`, lines 912-920, 1028-1037 (`mstatus_alias_we`): read 22 Oct 2026 (ours, not the RTL pass's): in CLIC mode a write to mcause.mpp or mcause.mpie is aliased to mstatus (mstatus_alias_we, 912-920) and the alias branch sets mstatus_we (1028-1037), so csr_irq_enable_write_o (1550-1557) fires for it and irq_enable_stall (controller_bypass.sv 275-278) holds the load or store in EX while the write is in WB

## To reproduce

The program in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro.S`

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- order 27 lw s4, 0(a5): RTL 2 cycles; the documentation, read as written, gives 1

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/openhwgroup/cv32e40x.git at d952cd63bc1b4eb58cd893c28ef8283c781e345e; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-10-22

---

© 2026 processor-timing-anomalies, Apache License 2.0
