# In U-mode an interrupt is taken with mstatus.MIE clear; the manual's enable rule omits it

- Title: interrupts-in-user-whatever-mie
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: none in cycles; software reading the manual would expect MIE to mask interrupts in U, which it does not
- Core: ibex
- Found while running: ibex (the base build)

## Issue

exception_interrupts.rst states the enable rule as 'both the global interrupt enable (MIE) bit in the mstatus CSR and the corresponding individual interrupt enable bit in the mie CSR need to be set', with no word on the privilege mode.  The RTL follows the privileged specification: in U-mode an enabled line is taken whatever mstatus.MIE says (irq_enabled = mstatus.MIE | (priv == U)), and MIE only gates M-mode.

## What the documentation says

exception_interrupts.rst 47-49 (the enable rule), 23 (M-mode and U-mode supported); cs_registers.rst mstatus (MIE)

## What the RTL does

the U-mode event files on the three Ibex builds, 1 Nov 2026: every line raised with MIE clear in U is taken, at the M-mode taking latency

## From the RTL source (read, not measured)

`rtl/ibex_controller.sv`, lines handle_irq (`irq_enabled`): irq_enabled = csr_mstatus_mie_i | (priv_mode_i == PRIV_LVL_U): the global enable gates M-mode alone

## The core's configuration

The RTL was built with these parameters of its top module (the names and values are the RTL's own; the build named under "Found while running" is what they define):

| parameter | value |
|---|---|
| `RV32E` | `0` |
| `RV32M` | `RV32MFast` |
| `RV32B` | `RV32BNone` |
| `RV32ZC` | `RV32Zca` |
| `BranchTargetALU` | `0` |
| `WritebackStage` | `0` |
| `ICache` | `0` |
| `ICacheECC` | `0` |
| `ICacheScramble` | `0` |
| `BranchPredictor` | `0` |
| `DbgTriggerEn` | `0` |
| `SecureIbex` | `0` |
| `PMPEnable` | `0` |
| `PMPGranularity` | `0` |
| `PMPNumRegions` | `4` |
| `MHPMCounterNum` | `10` |
| `MHPMCounterWidth` | `40` |

The instruction and data buses granted every request in its own cycle and answered it in the next: no wait states.

## To reproduce

The program in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro.S`

This program uses a memory-mapped test device of ours: an upstream Spike or a plain RTL simulation will not run it as it is.  Contact us for a set-up that does.

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- order 31 addi t4, t4, 1: RTL 3 cycles; the documentation, read as written, gives 1
- order 31 addi t4, t4, 1: RTL 3 cycles; the documentation, read as written, gives 1
- order 32 addi t4, t4, 1: RTL 1 cycles; the documentation, read as written, gives 3
- order 32 addi t4, t4, 1: RTL 1 cycles; the documentation, read as written, gives 3
- order 32 addi t4, t4, 1: RTL 1 cycles; the documentation, read as written, gives 3
- order 32 addi t4, t4, 1: RTL 1 cycles; the documentation, read as written, gives 3
- order 32 addi t4, t4, 1: RTL 1 cycles; the documentation, read as written, gives 3
- order 32 addi t4, t4, 1: RTL 1 cycles; the documentation, read as written, gives 3
- order 32 addi t4, t4, 1: RTL 1 cycles; the documentation, read as written, gives 3

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/lowRISC/ibex.git at c0c07085791e4d16a0f2d9a753b2fb79d72e5ffa; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-11-01

---

© 2026 processor-timing-anomalies, Apache License 2.0
