# A misaligned store the PMP refuses still writes its second half

- Title: pmp-misaligned-store-second-half-written
- Class: function -- not a timing finding: a value, a fault or a sequence
- Cost: none in cycles; a store that faults leaves half its data in memory, which software handling the fault may not expect
- Core: ibex
- Found while running: ibex-pmp

## Issue

a misaligned store splits into two word-aligned transactions, each checked by the PMP on its own; when the first is refused the LSU goes WAIT_GNT_MIS to WAIT_RVALID_MIS without a transaction and then requests the second half when that half's own check passes, so the store faults (mcause 7) and the memory holds the second half's bytes.  The manual states the bus side of it ('the second part is still issued and its response ignored', for a first part the bus answered with an error); for a PMP refusal the same path writes memory under a faulting store.  Spike faults the whole access and writes nothing, so the two engines differ in memory, visible to the comparison only through a later load of that word.

## What the documentation says

load_store_unit.rst, 'Misaligned Accesses': if the first part of a misaligned access receives an error response, the second part is still issued and its response ignored; pmp.rst says nothing of misaligned accesses

## What the RTL does

ibex_load_store_unit.sv: the second half's request is gated by its own pmp_err, not the first's

## From the RTL source (read, not measured)

`rtl/ibex_load_store_unit.sv`, lines 495-530 (`pmp_err_d`): WAIT_GNT_MIS with pmp_err_q: no request, WAIT_RVALID_MIS; there the second half's request goes out (data_req_o with addr_incr_req_o) unless its own check (pmp_err) refuses it; the first half's error is kept in pmp_err_q and the access faults when both halves are done

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

- order 16 sw t4, 2(t2): RTL 3 cycles; the documentation, read as written, gives 2
- order 16 sw t4, 2(t2): RTL 3 cycles; the documentation, read as written, gives 2
- order 17 jal zero, 128: RTL 4 cycles; the documentation, read as written, gives 5
- order 17 jal zero, 128: RTL 4 cycles; the documentation, read as written, gives 5

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/lowRISC/ibex.git at c0c07085791e4d16a0f2d9a753b2fb79d72e5ffa; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-11-01

---

© 2026 processor-timing-anomalies, Apache License 2.0
