# With the cache disabled the fetch stream is the cache's own, not the prefetch buffer's

- Title: icache-disabled-is-not-the-prefetch-buffer
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: under instruction-side wait states, a different cycle on most redirects and sequential fetches than the uncached build's: a user who turns the cache off to get the documented uncached timing does not get it
- Core: ibex
- Found while running: ibex-icache

## Issue

icache.rst says the cache 'integrates into the CPU by replacing the prefetch buffer' (line 10) and that with icache_enable_i low it 'operates in pass-through mode, where every requested instruction is fetched from memory and no results are cached' (line 24).  It does not say what the fetch timing is in pass-through mode: the request stream stays the cache's own (its fill buffers, and with the enable low a speculative request on every lookup, not only after a branch), so a build with the cache off does not have the prefetch-buffer build's timing under instruction-side wait states; it differs from the first redirect.

## What the documentation says

icache.rst 10 ('The I$ integrates into the CPU by replacing the prefetch buffer'), 24 (pass-through mode with icache_enable_i low), 20 (the interface matches the IF stage); ibex_if_stage.sv 299-349: gen_icache or gen_prefetch_buffer, one or the other

## What the RTL does

the scheduled suite with the cache off, 4 Nov 2026: 0 differ with the cache's request rules, 175,077 differ with the prefetch buffer's

## The bus timing of the run

The run delayed the instruction bus: every other word (by word address) was answered a cycle after its grant, the others in the next cycle.  The issue shows only under such waits; a testbench that answers every request in the next cycle will not see it.

## From the RTL source (read, not measured)

`rtl/ibex_icache.sv`, lines 222-231, 248-253, 699-711, 764-782, 805-808, 846, 1033-1036 (`fill_alloc_cnt, fill_ext_req, branch_or_lookup`): the lookup is granted while a buffer is free; the speculative request goes out in the lookup's own cycle unless an older buffer still requests; each buffer requests beat by beat to the line's end; the speculative request depends on the enable: 'Speculative requests are only made for branches, or if the cache is disabled' (709-710: fill_spec_req = (~icache_enable_i | branch_i) & ~|fill_ext_req), and fill_cache_new reads it too (690)

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

- orders 8..14 (lui zero, 0x2: 1 cycles after the previous retirement): the cache disabled since order 5; after the jump (order 7) its target and the six words after it retire a cycle apart under a bus that answers every other word a cycle late (orders 8-14: 3, 1, 1, 1, 1, 1, 1 cycles), because the cache's fill buffers request the lines ahead; the same program on the build without the cache (ICache = 0, the prefetch buffer with two words outstanding) under the same bus retires them at 3, 1, 2, 1, 2, 1, 2: disabling the cache does not give the uncached build's timing

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/lowRISC/ibex.git at c0c07085791e4d16a0f2d9a753b2fb79d72e5ffa; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-11-04

---

© 2026 processor-timing-anomalies, Apache License 2.0
