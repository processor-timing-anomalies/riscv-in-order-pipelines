# A jump behind a busy divider resolves at once, its bubble hidden

- Title: jump-behind-divider
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: a saving: a jump behind a busy divider pays no bubble of its own, one cycle fewer than the table
- Core: cv32e40x

## Issue

a jump behind a busy divider resolves at once; its bubble is hidden by the wait.

## What the documentation says

pipeline.rst line 18, 'Jumps are taken from the ID stage', and line 21, 'Multi-cycle instructions will stall this stage [EX] until they are complete': nothing about a jump held in ID behind a divider

## What the RTL does

the jump redirects fetch in the first cycle it sits in ID, whether or not EX lets it advance; the instruction at its target is fetched while the divider still holds EX, so no bubble appears beyond the wait the divider already causes

## To reproduce

The program in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro.S`

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- orders 4..6 (addi a5, zero, 1: 1 cycles after the previous retirement): a jal right behind a 35-cycle divide: its target (addi a5, zero, 1) retires 1 cycle after the jal, no bubble, where a jal on its own costs its target 2 cycles (orders 12-13); the divider wait hides the jump bubble

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/openhwgroup/cv32e40x.git at d952cd63bc1b4eb58cd893c28ef8283c781e345e; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-10-01

---

© 2026 processor-timing-anomalies, Apache License 2.0
