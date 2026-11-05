# The first 258 cycles after reset are an invalidation walk: every fetch a bus request

- Title: icache-reset-walk
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: 258 cycles at the start of every run at the bus's miss cost; a short program's cycles per instruction on the cached build say more about the walk than the cache (caches-PLAN decision 17)
- Core: ibex
- Found while running: ibex-icache

## Issue

icache.rst describes reset only for the scrambling key (RndCnstIbexKey, ic_scr_key_valid reads 1).  The cache also invalidates itself after reset, the same 256-set walk plus about two cycles, so the first 258 cycles of every program fetch through the bus with nothing allocated, cache enabled or not.

## What the documentation says

icache.rst 105 (out of reset the key holds RndCnstIbexKey); nothing on the invalidation at reset

## What the RTL does

the cached build's runs of 4 Nov 2026: the first 258 cycles blocked on every one

## The bus timing of the run

The run delayed the instruction bus: every word's grant was withheld one cycle.  The issue shows only under such waits; a testbench that answers every request in the next cycle will not see it.

## From the RTL source (read, not measured)

`rtl/ibex_icache.sv`, lines 1215-1287 (`inval_block_cache`): the invalidation state machine runs from reset as it does after icache_inval_i

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

- orders 98..103 (bne t1, zero, -8: 1 cycles after the previous retirement): the end of the walk after reset: the three-word loop ran from the bus since its first iteration (order 8, cycle 34), 8 cycles each under a grant withheld one cycle per word, the cache enabled since order 3 and never hitting; orders 98-100 are its last bus-fetched iteration and orders 101-103 (cycle 282 to 286) the first cached one at 4 cycles: the 258-cycle invalidation walk the cache runs after reset, which the document does not mention

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/lowRISC/ibex.git at c0c07085791e4d16a0f2d9a753b2fb79d72e5ffa; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-11-04

---

© 2026 processor-timing-anomalies, Apache License 2.0
