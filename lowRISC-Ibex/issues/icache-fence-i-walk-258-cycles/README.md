# A fence.i on the cached build costs a 258-cycle walk of bus fetches; the table says 1 - N

- Title: icache-fence-i-walk-258-cycles
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: 258 cycles of fetch at the bus's miss cost after every fence.i on a cached build, against the table's '1 - N'
- Core: ibex
- Found while running: ibex-icache

## Issue

pipeline_details.rst's cycle table gives the instruction fence as '1 - N' and icache.rst says lookups miss until the invalidation completes, without a count.  The walk writes one set a cycle, 256 sets plus about two, and from the fence.i's own cycle every fetch is a bus request answered at T+2 with nothing allocated; a second fence.i during the walk restarts it.

## What the documentation says

pipeline_details.rst 96 (Instruction Fence, 1 - N); icache.rst 26-27, 117-119 (the invalidation, lookups miss until it completes)

## What the RTL does

the cache file and the smoke tests with the cache on, 4 Nov 2026, 0 differ

## The bus timing of the run

The run delayed the instruction bus: every word's grant was withheld one cycle.  The issue shows only under such waits; a testbench that answers every request in the next cycle will not see it.

## From the RTL source (read, not measured)

`rtl/ibex_icache.sv`, lines 1215-1287 (`inval_block_cache, inval_index_q`): the invalidation writes one set per cycle from the fence.i's cycle; lookups cannot hit and nothing allocates while it runs

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

- orders 360..363 (addi t1, t1, -1: 2 cycles after the previous retirement): the end of the walk: the fence.i retired at cycle 547 (order 260); from it every iteration of the three-word loop fetched its words from the bus, 8 cycles each under a grant withheld one cycle per word, where the same loop ran cached at 3 cycles before the fence.i (orders 254-257); the iteration at orders 360-362 is the first whose lookups hit again and allocate, and from order 363 (cycle 829) the loop is cached once more: 258 cycles of invalidation walk from the fence.i, against the cycle table's 1 - N

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/lowRISC/ibex.git at c0c07085791e4d16a0f2d9a753b2fb79d72e5ffa; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-11-04

---

© 2026 processor-timing-anomalies, Apache License 2.0
