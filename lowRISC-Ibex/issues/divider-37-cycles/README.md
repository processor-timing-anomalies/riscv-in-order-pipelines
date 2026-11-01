# The division row's '1 or 37' counts cycles, not the stalls its rule means

- Title: divider-37-cycles
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: none: one cycle on every division and remainder with a non-zero divisor, as a count the two pages disagree on (37 against 38), not a stall the core pays or saves
- Core: ibex
- Found while running: ibex (the base build)

## Issue

a div, divu, rem or remu with a non-zero divisor holds the pipeline 37 cycles; the pipeline table's row 'Division, Remainder: 1 or 37' is a count of cycles, not of the stall cycles its rule 'when an instruction stalls for X cycles X + 1 cycles pass' would make it, while the decode-execute page says 37 cycles outright: the two pages read together give 38, the core takes 37.

## What the documentation says

pipeline_details.rst, the table 'Multi- and Single-Cycle Instructions': 'Division / Remainder | 1 or 37 | 1 stall cycle if divide by 0, otherwise full long division', under the rule at line 35, 'when an instruction stalls for X cycles X + 1 cycles pass before a new instruction enters the ID/EX stage'; instruction_decode_execute.rst line 137: 'it takes 37 cycles to compute (though only requires 2 cycles when there is a divide by 0)'

## What the RTL does

the instruction behind a div with a non-zero divisor retires 37 cycles after it (380 of 412 such pairs in the add blocks, every mnemonic alike), 2 after a divide by zero; our model written from the table's rule predicted 38

## From the RTL source (read, not measured)

`rtl/ibex_multdiv_fast.sv`, lines 391-520 (`md_state_q`): the divider's sequence is MD_IDLE, MD_ABS_A, MD_ABS_B, 31 cycles of MD_COMP (the counter from 31 to 1), MD_LAST, MD_CHANGE_SIGN and MD_FINISH: 37 states, 2 for a zero divisor (MD_IDLE to MD_FINISH); the table's 37 is this count

## To reproduce

The program in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro.S`

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- order 8392 div a4, a3, a5: RTL 37 cycles; the documentation, read as written, gives 38

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/lowRISC/ibex.git at c0c07085791e4d16a0f2d9a753b2fb79d72e5ffa; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-10-28

---

© 2026 processor-timing-anomalies, Apache License 2.0
