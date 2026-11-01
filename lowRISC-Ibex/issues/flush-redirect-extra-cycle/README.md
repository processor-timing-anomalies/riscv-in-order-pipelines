# A trap entry and an mret cost a cycle more than a jump; no row says so

- Title: flush-redirect-extra-cycle
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle more than a jump on every trap entry and every mret, the FLUSH state's own; the document gives no count for either
- Core: ibex
- Found while running: ibex (the base build)

## Issue

an exception's handler and an mret's return start executing 3 cycles after the trapping instruction or the mret, one cycle later than a jump's target, because the redirect is made in a flush state the cycle after the instruction's own; the documentation gives no cycle count for traps or mret.

## What the documentation says

pipeline_details.rst's table has no row for a trap entry or mret; exceptions_interrupts.rst lines 9-13 describe the jump to the vector and the return through mepc without cycles

## What the RTL does

an ecall's handler's first instruction retires 4 cycles after the ecall's record and an mret's target 3 cycles after the mret (hz-I-add-zicsr-00, the jal subjects' trap blocks: +4 against our model's +3, six of six); a jump's target follows in 2

## From the RTL source (read, not measured)

`rtl/ibex_controller.sv`, lines 667-681, 818-836, 955-961 (`special_req`): an exception request or an mret is a special request: DECODE retains ID and enters FLUSH, which sets the pc (the exception vector with csr_save_cause, mepc with csr_restore_mret) and flushes ID; the target is fetched from FLUSH, a cycle after a jump's would be

## To reproduce

The program in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro.S`

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- orders 8..22 (addi t1, t1, 1: 3 cycles after the previous retirement): order 8 ecall at cycle 25; order 9, the handler's first instruction (the vector table's jal), at 29: 4 cycles after the ecall's record; the handler's mret (order 21) at 42 and its target (order 22) at 45: 3 cycles after the mret; the jal of order 23 retires 2 cycles after its predecessor and its target 1 after it: a jump costs 2 where the trap entry costs 4 and the return 3, the FLUSH state's cycle on each

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/lowRISC/ibex.git at c0c07085791e4d16a0f2d9a753b2fb79d72e5ffa; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-10-29

---

© 2026 processor-timing-anomalies, Apache License 2.0
