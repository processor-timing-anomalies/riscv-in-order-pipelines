# A writeback-raised trap enters its handler a cycle after an ID/EX one

- Title: pmp-fault-wb-entry-four-cycles
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle more on the entry of every handler of a load or store fault than of an ID/EX exception
- Core: ibex
- Found while running: ibex-pmp

## Issue

the handler's first instruction retires 4 cycles after the trap entry of a load or store the PMP refused (the exception raised from WB by exc_req_lsu), where an ecall's or an illegal instruction's handler (raised from ID/EX) retires 3 cycles after its trap entry: the response reaches WB, the controller goes to FLUSH the cycle after, the handler is fetched from it.  The manual names the WB path for load and store errors but gives no cycles for either path.

## What the documentation says

exception_interrupts.rst, 'Exceptions': the load and store access faults with their mcause; pipeline_details.rst: no row for a trap's entry; ibex_controller.sv's own comment (276-277): exceptions from the Writeback stage take priority over those from the ID/EX stage

## What the RTL does

21 of 21 refused loads and stores of hzpmp-pmp-00 on the first run (31 Oct 2026, 01:08): RTL +4 from the trap entry to the handler's jal, our model's ID/EX rule +3; the one fetch fault of the file (raised at issue in ID/EX) +3 on both

## From the RTL source (read, not measured)

`rtl/ibex_controller.sv`, lines 276-277, 283-294, 315-322, 819-836 (`exc_req_lsu`): exc_req_lsu = store_err_i | load_err_i, 'from the Writeback stage with no instruction valid': it takes the controller to FLUSH in the cycle after the response, where an ID/EX exception (exc_req_d) does so in the instruction's own cycle; the handler's fetch follows FLUSH in both

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

- order 25 lw s0, 0(t2): RTL 2 cycles; the documentation, read as written, gives 1
- order 26 jal zero, 128: RTL 4 cycles; the documentation, read as written, gives 5
- order 26 jal zero, 128: RTL 4 cycles; the documentation, read as written, gives 5

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/lowRISC/ibex.git at c0c07085791e4d16a0f2d9a753b2fb79d72e5ffa; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-11-01

---

© 2026 processor-timing-anomalies, Apache License 2.0
