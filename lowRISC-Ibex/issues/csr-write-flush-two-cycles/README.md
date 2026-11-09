# A CSR write's flush costs two cycles; the manual gives no count

- Title: csr-write-flush-two-cycles
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: two cycles on the instruction after a CSR write (csrrw, csrrs, csrrc and the immediate forms) of any CSR but mscratch and mepc, where the table's wording suggests one
- Core: ibex
- Found while running: ibex (the base build)

## Issue

the instruction after a CSR write of any CSR but mscratch and mepc retires 3 cycles after it, two more than after a one-cycle instruction: the pipeline table (pipeline_details.rst 46-48) says of such a write 'Note that most CSR *writes* flush the pipeline, so the instruction immediately following a CSR write incurs an additional fetch-latency' without the count, and the count is two (the controller's FLUSH cycle, then the reload of the IF/ID register; no new fetch address is set for a CSR flush, ibex_controller.sv 819-823, 955-971), not the one that 'an additional fetch-latency' suggests; it is also every CSR but the two named, the counters included; a write to a read-only CSR (address bits 11:10 = 11) is an illegal instruction instead (ibex_cs_registers.sv 402).

## What the documentation says

pipeline_details.rst, the table row 'CSR Access | 0 | ... Note that most CSR writes flush the pipeline, so the instruction immediately following a CSR write incurs an additional fetch-latency.  This is mainly to ensure ePMP updates are taken into account for the next instruction fetch check.  Writes to mscratch and mepc are exempt and do not flush the pipeline'

## What the RTL does

a csrrw of mtvec, mie, mcause or mtval, or a csrrs/csrrc/csrrwi/csrrsi/csrrci of them, retires 1 cycle after the instruction before it, and the instruction after it 3 cycles later (after a one-cycle FLUSH and the IF/ID reload); our model written from the table predicted 2

## From the RTL source (read, not measured)

`rtl/ibex_id_stage.sv`, lines 586-593 (`csr_pipe_flush`): every CSR write except of mscratch and mepc (no_flush_csr_addr) raises csr_pipe_flush, a special request the controller answers with its FLUSH state (one cycle: IF halted, ID flushed) before DECODE reloads the IF/ID register: two cycles before the next instruction executes

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

The programs in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro-1.S`
- `repro.S`

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- order 389 csrrw a2, mscratch, a0: RTL 3 cycles; the documentation, read as written, gives 2
- order 6 lui zero, 0x1: RTL 3 cycles; the documentation, read as written, gives 2
- order 376 auipc a1, 0x0: RTL 3 cycles; the documentation, read as written, gives 2
- order 376 auipc a1, 0x0: RTL 3 cycles; the documentation, read as written, gives 2
- order 13086 jal zero, 128: RTL 4 cycles; the documentation, read as written, gives 3
- order 13086 jal zero, 128: RTL 4 cycles; the documentation, read as written, gives 3
- order 13099 csrrw gp, mscratch, s0: RTL 3 cycles; the documentation, read as written, gives 2
- order 13155 lui t3, 0x3a0: RTL 3 cycles; the documentation, read as written, gives 2

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/lowRISC/ibex.git at c0c07085791e4d16a0f2d9a753b2fb79d72e5ffa; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-10-28

---

© 2026 processor-timing-anomalies, Apache License 2.0
