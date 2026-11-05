# A PMP-refused load or store faults after two cycles, no bus request

- Title: pmp-fault-two-cycles
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: two cycles on every load or store the PMP refuses, before the trap's own entry; a zero-wait memory's permitted access pays one
- Core: ibex
- Found while running: ibex-pmp

## Issue

a load or store whose word-aligned address the PMP denies is held two cycles in the LSU and then faults from the writeback stage, without any bus request: cycle 0 the request is suppressed and pmp_err_q set, cycle 1 the error stands in for the grant, cycle 2 the response with load_err_o / store_err_o.  The manual says the request proceeds 'as if it was granted externally' and the error is 'consumed by the core when the data would have been consumed', which on a zero-wait memory suggests one cycle, the response's; it is two, one more than the memory's own response would have taken.

## What the documentation says

pmp.rst, 'PMP Integration': the check gates the LSU's external request; 'the request proceeds as if it was granted externally; the error is consumed by the core when the data would have been consumed'; no cycle count anywhere in the manual

## What the RTL does

with memory.pmp.fault_cycles 2 every refused load and store of the four PMP files retires where the RTL does (0 differ); with the memory's one cycle our model was one short on each (the first run of 31 Oct 2026, 01:08: 21 of 21 refused accesses)

## From the RTL source (read, not measured)

`rtl/ibex_load_store_unit.sv`, lines 436-490, 540-550, 703-709, 762-763 (`pmp_err_q`): IDLE: data_req_o is data_req_out & ~pmp_req_err[PMP_D] (ibex_core.sv 1062), pmp_err_q <= pmp_err; WAIT_GNT: the error counts as the grant (pmp_err_q | data_gnt_i) and the FSM returns to IDLE; the next cycle lsu_resp_valid_o with load_err_o / store_err_o: two cycles from the suppressed request to the error response

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
