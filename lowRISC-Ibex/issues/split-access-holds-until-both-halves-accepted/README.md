# A misaligned access holds ID/EX until both halves are accepted and its first response

- Title: split-access-holds-until-both-halves-accepted
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: under data-side wait states, the cycles of the second half's grant and the first half's response, on every misaligned access
- Core: ibex
- Found while running: ibex-icache

## Issue

load_store_unit.rst says a misaligned access is split into two and needs at least two cycles.  Under a bus schedule that withholds a grant or a response, the hold is longer and has a shape: ID/EX is held until the second half's request is accepted and the first half's response is on the wire (the LSU's WAIT_RVALID_MIS and GNTS_DONE states), so the fixed misaligned occupancy the specification carried is wrong under waits.  On every Ibex build.

## What the documentation says

load_store_unit.rst 81-86 (Misaligned Accesses: at least two cycles)

## What the RTL does

the scheduled suites of the three Ibex builds on 4 Nov 2026 at 0 differ with the hold

## The bus timing of the run

The run delayed the data bus: every request's grant was withheld one cycle.  The issue shows only under such waits; a testbench that answers every request in the next cycle will not see it.

## From the RTL source (read, not measured)

`rtl/ibex_load_store_unit.sv`, lines WAIT_RVALID_MIS, GNTS_DONE (`ls_fsm_cs, addr_incr_req_o`): the LSU holds the stage through the second half's request and the first half's response

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

- orders 9..10 (lw t3, 2(t2): 4 cycles after the previous retirement): the misaligned store (order 9) and the misaligned load (order 10) each take 4 cycles under a data bus that withholds every grant one cycle, where the manual gives a misaligned access at least two: each holds ID/EX until its second half is accepted and its first half's response is on the wire

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/lowRISC/ibex.git at c0c07085791e4d16a0f2d9a753b2fb79d72e5ffa; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-11-04

---

© 2026 processor-timing-anomalies, Apache License 2.0
