# An unsupported MPP value is kept as User mode, not Machine mode

- Title: mpp-unsupported-reads-user
- Class: function -- not a timing finding: a value, a fault or a sequence
- Cost: no cycles; software that writes an unsupported value to mstatus.MPP and then executes mret would continue in User mode, without access to the machine-mode CSRs, where the manual promises Machine mode (the mret itself not run)
- Core: ibex
- Found while running: ibex-maxperf

## Issue

a write of the reserved value 2 to mstatus.MPP reads back 0 (User mode), where cs_registers.rst says 'Any write to mstatus.MPP of an unsupported value will be interpreted as Machine Mode' and no other part of the manual says otherwise: the core keeps an unsupported MPP value as User mode, the opposite of the manual's sentence, so an mret after such a write would return to User mode where the manual says Machine mode.

## What the documentation says

cs_registers.rst 168-169: 'Only Machine Mode and User Mode are supported. Any write to ``mstatus``.MPP of an unsupported value will be interpreted as Machine Mode.'; the CSR table marks mstatus WARL (15) without naming the legal value, and exception_interrupts.rst 25: 'On execution of an MRET instruction, the core will return to the Privilege Mode stored in ``mstatus``.MPP.'

## What the RTL does

repro.S on ibex-maxperf, 6 Nov 2026: MPP cleared (csrc mstatus, 0x1800), then csrrs mstatus with 0x1000 (MPP = 2), then csrr mstatus 3 cycles later: mstatus reads 0x00000080, MPP = 0 (User mode), and Spike reads the same; the write itself leaves mstatus 0x00000080 in the trace, and the restoring write of MPP = 3 leaves it 0x00001880

## From the RTL source (read, not measured)

`rtl/ibex_cs_registers.sv`, lines 781-784 (`mstatus_d.mpp`): '// Convert illegal values to U-mode': if ((mstatus_d.mpp != PRIV_LVL_M) && (mstatus_d.mpp != PRIV_LVL_U)) mstatus_d.mpp = PRIV_LVL_U

## The core's configuration

The RTL was built with these parameters of its top module (the names and values are the RTL's own; the build named under "Found while running" is what they define):

| parameter | value |
|---|---|
| `RV32E` | `0` |
| `RV32M` | `RV32MSingleCycle` |
| `RV32B` | `RV32BNone` |
| `RV32ZC` | `RV32ZcaZcbZcmp` |
| `BranchTargetALU` | `1` |
| `WritebackStage` | `1` |
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

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- orders 8..9 (csrrs t2, mstatus, zero: 3 cycles after the previous retirement): a write of the reserved value 2 to mstatus.MPP reads back 0 (User mode) where the manual says an unsupported MPP value is interpreted as Machine mode

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/lowRISC/ibex.git at c0c07085791e4d16a0f2d9a753b2fb79d72e5ffa; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-11-06

---

© 2026 processor-timing-anomalies, Apache License 2.0
