# The manual's W=1 R=0 rule holds only while mseccfg.MML is clear

- Title: pmp-w-without-r-under-mml
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: none in cycles; a permission reading software would get wrong from the manual under MML
- Core: ibex
- Found while running: ibex-pmp

## Issue

cs_registers.rst says a pmpcfg byte with W = 1 and R = 0 'will be treated by the core as Read/Write permission = 0'; the RTL stores W = 0 in that case (R stays as written) while MML is clear, and with MML set stores the byte as written, since Smepmp gives W = 1, R = 0 the shared-region meanings (a locked region executable by both modes, an unlocked one readable by U and writable by M).  The sentence is the pre-Smepmp rule and says nothing of MML.

## What the documentation says

cs_registers.rst, pmpcfgx: 'W = 1, R = 0 ... will be treated by the core as Read/Write permission = 0'; pmp.rst 'PMP Enhancements': Smepmp always included

## What the RTL does

the four PMP files on ibex-pmp, 31 Oct 2026: under MML a region written W = 1, R = 0 reads back as written and decides as a shared region, as the model predicts; under MML clear it reads back W = 0

## From the RTL source (read, not measured)

`rtl/ibex_cs_registers.sv`, lines 1442 (`pmp_cfg_wdata`): the W bit is kept only with R set or mseccfg.mml set; R is stored as written

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
| `ICache` | `0` |
| `ICacheECC` | `0` |
| `ICacheScramble` | `0` |
| `BranchPredictor` | `0` |
| `DbgTriggerEn` | `0` |
| `SecureIbex` | `0` |
| `PMPEnable` | `1` |
| `PMPGranularity` | `0` |
| `PMPNumRegions` | `16` |
| `MHPMCounterNum` | `10` |
| `MHPMCounterWidth` | `40` |

The instruction and data buses granted every request in its own cycle and answered it in the next: no wait states.

## To reproduce

The program in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro.S`

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- orders 11..25 (csrrs s1, pmpcfg0, zero: 3 cycles after the previous retirement): orders 11-12: pmpcfg0 written 0x12 (NA4, W = 1, R = 0) with MML clear reads back 0x10, W cleared; orders 24-25: the same write with MML set reads back 0x12, the shared-region encoding kept

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/lowRISC/ibex.git at c0c07085791e4d16a0f2d9a753b2fb79d72e5ffa; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-11-01

---

© 2026 processor-timing-anomalies, Apache License 2.0
