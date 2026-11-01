# Instructions cost the same cycles in U-mode as in M-mode, unstated

- Title: user-mode-costs-as-machine-mode
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: none; a statement the manual lacks
- Core: ibex
- Found while running: ibex (the base build)

## Issue

pipeline_details.rst gives every instruction's cycles with no word on the privilege mode; nothing says a U-mode stream is timed as an M-mode one.  Measured: it is.  What differs in U is rules, not cycles: which instructions trap (the M-level CSRs, mret, wfi under mstatus.TW, a counter alias gated by mcounteren), the taking of interrupts (whatever MIE), the PMP's judgment of an access.

## What the documentation says

pipeline_details.rst (every instruction's cycles, no mode named); cs_registers.rst mstatus MPP, TW, MPRV

## What the RTL does

the U-mode event files and the PMP U files on ibex, ibex-maxperf and ibex-pmp, 1 Nov 2026: our model's M-mode rules predict every U retirement

## From the RTL source (read, not measured)

`rtl/ibex_core.sv`, lines the privilege is a CSR state (ibex_cs_registers.sv priv_lvl_q), no timing path reads it but the PMP's and the controller's irq_enabled (`priv_mode_id_o`): the pipeline's stalls and bubbles take no privilege input

## To reproduce

The program in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro.S`

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- orders 9..21 (addi t4, t3, 1: 1 cycles after the previous retirement): orders 9-10 in M and 20-21 in U: an add then its dependent addi, 1 cycle each in both modes; order 17 the mret into U

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/lowRISC/ibex.git at c0c07085791e4d16a0f2d9a753b2fb79d72e5ffa; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-11-01

---

© 2026 processor-timing-anomalies, Apache License 2.0
