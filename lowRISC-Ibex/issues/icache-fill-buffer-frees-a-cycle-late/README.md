# A fill buffer frees the cycle after its last word, so the next lookup waits a cycle

- Title: icache-fill-buffer-frees-a-cycle-late
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle on a lookup that waits for a buffer to free, under instruction-side wait states
- Core: ibex
- Found while running: ibex-icache

## Issue

a fill buffer's done state is registered: a word arriving or a beat popped in cycle c makes the buffer done in c + 1 and free from c + 2, so a lookup that needs that buffer is granted one cycle later than a buffer freed at once would allow.  Nothing in icache.rst describes when a buffer frees.

## What the documentation says

icache.rst 60-75 (the fill buffers), no word on when a buffer frees

## What the RTL does

the VCD of firstTest-imc under FSCHED=all, 4 Nov 2026; the scheduled suite at 0 differ with the rule

## The bus timing of the run

The run delayed the instruction bus: every word's grant was withheld one cycle.  The issue shows only under such waits; a testbench that answers every request in the next cycle will not see it.

## From the RTL source (read, not measured)

`rtl/ibex_icache.sv`, lines 731-737 (`fill_done, fill_out_done, fill_rvd_done`): fill_done is registered from the done conditions, so the buffer is busy for the cycle after its last pop or arrival

## The core's configuration

The RTL was built with these parameters of its top module (the names and values are the RTL's own; the build named under "Found while running" is what they define):

| parameter | value |
|---|---|
| `RV32E` | `0` |
| `RV32M` | `RV32MSingleCycle` |
| `RV32B` | `RV32BFull` |
| `RV32ZC` | `RV32ZcaZcbZcmp` |
| `BranchTargetALU` | `1` |
| `WritebackStage` | `1` |
| `ICache` | `1` |
| `ICacheECC` | `1` |
| `ICacheScramble` | `0` |
| `BranchPredictor` | `0` |
| `DbgTriggerEn` | `0` |
| `SecureIbex` | `0` |
| `PMPEnable` | `1` |
| `PMPGranularity` | `0` |
| `PMPNumRegions` | `16` |
| `MHPMCounterNum` | `10` |
| `MHPMCounterWidth` | `40` |

The program enables the instruction cache at its start: a write of 1 to bit 0 of `cpuctrlsts` (CSR 0x7C0), in `env/test.h`.  The cache is otherwise off out of reset.

## To reproduce

The program in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro.S`

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- orders 13..14 (addi a6, zero, 7: 2 cycles after the previous retirement): the words after the divide drain the fill buffers filled during its 37 cycles: addi a6 (order 14) retires 2 cycles after addi a5 where the five words before it took 1 each; its lookup needed a buffer whose last word was taken in the cycle before, and the buffer frees a cycle after that (the done state is registered), so the lookup is granted a cycle later than a buffer freed at once would allow; a model of the cache with the buffer freed at once gives this word 1 cycle, the registered one 2 as the RTL

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/lowRISC/ibex.git at c0c07085791e4d16a0f2d9a753b2fb79d72e5ffa; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-11-04

---

© 2026 processor-timing-anomalies, Apache License 2.0
