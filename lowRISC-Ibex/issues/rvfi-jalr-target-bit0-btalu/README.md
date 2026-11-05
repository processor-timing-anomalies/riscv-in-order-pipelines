# The RVFI's pc_wdata of an odd jalr target keeps bit 0 under the branch target ALU

- Title: rvfi-jalr-target-bit0-btalu
- Class: function -- not a timing finding: a value, a fault or a sequence
- Cost: none in execution; a trace consumer that trusts rvfi_pc_wdata (a cosimulation comparing the next pc, as ours) sees a mismatch on every odd-target jalr under BranchTargetALU = 1
- Core: ibex
- Found while running: ibex-maxperf

## Issue

with BranchTargetALU = 1 the RVFI's rvfi_pc_wdata of a jalr (and c.jalr, c.jr) whose rs1 + imm is odd carries bit 0 set: it is the branch target ALU's raw sum, where the fetch clears bit 0 as the ISA requires and the reference model reports the cleared address; the instruction executes correctly, the trace misreports its next pc.  With BranchTargetALU = 0 (the small configuration) the reported target is cleared.

## What the documentation says

the RVFI specification: pc_wdata is the pc of the next instruction architecturally; no Ibex page states the branch target ALU's output is reported raw

## What the RTL does

act4 I-jalr-00 on ibex-maxperf: 2 of 3,506 retirements differ from Spike in pc_wdata by bit 0, both jalr with an odd rs1 + imm; on ibex (small) 0 differ

## From the RTL source (read, not measured)

`rtl/ibex_ex_block.sv`, lines 88-95, 103 (`branch_target_o`): with BranchTargetALU the target is bt_alu_result[31:0] = bt_a_operand_i + bt_b_operand_i, raw; without it alu_adder_result_ex_o.  ibex_core.sv 2093: rvfi_stage_pc_wdata <= pc_set ? branch_target_ex : pc_if; ibex_if_stage.sv 289: prefetch_addr = {fetch_addr_n[31:1], 1'b0} clears it for the fetch

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

- orders 7..7 (jalr t5, 1(t0): 1 cycles after the previous retirement): order 7, jalr t5, 1(t0) with t0 = the even address of target: the core jumps to target (order 8 retires there, rvfi_pc_rdata even); before the harness mask of 29 Oct 2026 the RTL's rvfi_pc_wdata on this jalr read the odd sum target + 1 against the reference's even address (the compare of act4's I-jalr-00, Zca-c.jalr-00 and Zca-c.jr-00 on ibex-maxperf, 3 FAIL); these traces are after the mask, both even

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/lowRISC/ibex.git at c0c07085791e4d16a0f2d9a753b2fb79d72e5ffa; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-10-29

---

© 2026 processor-timing-anomalies, Apache License 2.0
