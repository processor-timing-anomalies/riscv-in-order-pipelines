# A load or store behind a CSR write of mstatus or mie costs one cycle more

- Title: irq-enable-stall
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle on every load or store right behind a write of mstatus or mie, whatever value the write carries
- Core: cv32e40x

## Issue

a load or store costs one more cycle than the cycle table's 1 when the instruction before it is a CSR instruction that writes mstatus or mie.

## What the documentation says

pipeline.rst, 'Cycle counts per instruction type': Load/Store 1 cycle (lines 48-49); the Hazards list (lines 114-126) names no hazard between a CSR write and a load or store; exceptions_interrupts.rst says interrupts are enabled through mstatus.MIE and mie (line 186) and gives no timing for the write

## What the RTL does

a load or store retires 2 cycles after a csrrs that writes mstatus (c.lbu, c.sb) or mie (c.lh, c.sh), the written value unchanged in all four (rs1 holds 0); the loads and stores elsewhere in the same test, not behind such a write, retire after 1

## From the RTL source (read, not measured)

`rtl/cv32e40x_controller_bypass.sv`, lines 275-278 (`irq_enable_stall`): EX is stalled while a load or store is in it and a write that may enable an interrupt is in WB ('Stall EX when an interrupt may be enabled from WB while there is a LSU instruction in EX'); without CLIC those writes are of mie and mstatus (cv32e40x_cs_registers.sv:1555)

## To reproduce

The programs in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro-1.S`
- `repro.S`

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- order 1449 c.lbu a0, 0(a1): RTL 2 cycles; the documentation, read as written, gives 1
- order 1468 c.sb a4, 0(a3): RTL 2 cycles; the documentation, read as written, gives 1
- order 1487 c.lh s0, 0(s1): RTL 2 cycles; the documentation, read as written, gives 1
- order 1506 c.sh a2, 0(a1): RTL 2 cycles; the documentation, read as written, gives 1

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/openhwgroup/cv32e40x.git at d952cd63bc1b4eb58cd893c28ef8283c781e345e; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-10-04

---

© 2026 processor-timing-anomalies, Apache License 2.0
