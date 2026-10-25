# Division by a negative divisor: the cycle count is not the divisor's leading zeros

- Title: divisor-leading-ones
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: none beyond the document's rule read right: a signed divide by a negative divisor costs 3 plus its leading ones less one
- Core: cv32e40x

## Issue

a signed division by a negative divisor does not take 'the number of leading bits at 0' of the divisor.

## What the documentation says

pipeline.rst, the div/rem row: 3 to 35 cycles, 'depends on the divider operand value (operand b), i.e. in the number of leading bits at 0'; read literally, a negative divisor has no leading zero and would cost 3

## What the RTL does

3 + (leading ones of the divisor - 1) cycles for a negative divisor of div or rem: -1 costs 34, -2 costs 33, 0x80000000 costs 3; 3 + leading zeros otherwise: 0 costs 35, 1 costs 34, 7 costs 32 (divu, remu and a non-negative divisor); measured on the seven divides of the reproducer

## To reproduce

The program in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro.S`

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- order 4 div by 0: 35 cycles -- 32 leading zeros, the table's 3 + 32
- order 8 div by 1: 34 cycles -- 31 leading zeros
- order 12 div by 7: 32 cycles -- 29 leading zeros
- order 16 div by -1 (0xffffffff): 34 cycles -- no leading zero, so 'leading bits at 0' read literally gives 3; the RTL counts the 32 leading ones less one
- order 20 div by -2 (0xfffffffe): 33 cycles -- 31 leading ones less one
- order 24 div by 0x80000000: 3 cycles -- one leading one, less one: nothing beyond the base 3
- order 28 divu by 0xffffffff: 3 cycles -- unsigned, 0 leading zeros: the table's rule as written

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/openhwgroup/cv32e40x.git at d952cd63bc1b4eb58cd893c28ef8283c781e345e; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-10-01

---

© 2026 processor-timing-anomalies, Apache License 2.0
