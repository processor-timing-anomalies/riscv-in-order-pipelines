# CLIC: a load or store behind a write of mie does not wait, unlike the CLINT core

- Title: clic-mie-write-no-stall
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: none: a saving of the cycle the core pays in CLINT mode on a load or store one behind a write of mie
- Core: cv32e40x
- Found while running: cv32e40x-clic

## Issue

in CLIC mode a load or store one behind a write of mie retires in its normal cycle, where the same core in CLINT mode holds it one cycle (the write may enable an interrupt there); in CLIC mode mie has no part in enabling an interrupt and the interlock does not fire; neither the Hazards list nor the CLIC chapter says which writes hold a load or store in either mode.

## What the documentation says

pipeline.rst, Hazards (lines 114-126): no row for a load or store behind a write that may enable an interrupt, in either mode; control_status_registers.rst's CLIC section: mie 'reads as zero' in CLIC mode with no word on the interlock

## What the RTL does

c.lbu, c.lh, c.lhu, c.lw, c.sb, c.sh, c.sw, c.swsp each one behind csrrs x0, mie, rs1: 1 cycle on cv32e40x-clic (own-cv32e40x-clic-00: 8 of 8 blocks) against the 2 the core's statement irq_enable_lsu_d1 gives, measured on cv32e40x (own-cv32e40x-00, 4 Oct 2026)

## From the RTL source (read, not measured)

`rtl/cv32e40x_cs_registers.sv`, lines 1550-1557 (`csr_irq_enable_write_o`): the clic_irq_en branch (line 1553): csr_irq_enable_write_o is mstatus_we, priv_lvl_we, mintthresh_we or mintstatus_we -- mie_we is in the CLINT branch only; irq_enable_stall (controller_bypass.sv 275-278) holds a load or store in EX for the cycle the writer is in WB

## To reproduce

The programs in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro-1.S`
- `repro-2.S`
- `repro-3.S`
- `repro-4.S`
- `repro-5.S`
- `repro-6.S`
- `repro-7.S`
- `repro.S`

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- order 4922 c.lhu a5, 0(s0): RTL 1 cycles; the documentation, read as written, gives 2
- order 4941 c.lw a0, 0(a1): RTL 1 cycles; the documentation, read as written, gives 2
- order 4961 c.sw a4, 0(a3): RTL 1 cycles; the documentation, read as written, gives 2
- order 4980 c.swsp s7, 0(sp): RTL 1 cycles; the documentation, read as written, gives 2
- order 5205 c.lbu s1, 0(a0): RTL 1 cycles; the documentation, read as written, gives 2
- order 5224 c.lh a2, 0(a3): RTL 1 cycles; the documentation, read as written, gives 2
- order 5244 c.sb s0, 0(a5): RTL 1 cycles; the documentation, read as written, gives 2
- order 5263 c.sh a1, 0(a0): RTL 1 cycles; the documentation, read as written, gives 2

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/openhwgroup/cv32e40x.git at d952cd63bc1b4eb58cd893c28ef8283c781e345e; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-10-19

---

© 2026 processor-timing-anomalies, Apache License 2.0
