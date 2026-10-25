# IF and ID freeze while a load or store in WB waits for its response

- Title: mem-response-wait-freeze
- Class: over-wide -- the stall fires in cases that have no cause for it: an interlock wider than needed, a performance flaw. The freeze holds IF to ID and ID to EX whether the next stage is occupied or empty: a stage with room ahead of it waits without a cause, because the late rvalid-based ready fans into every stage; a timing-closure choice by the RTL comment, an interlock wider than its cause by the test
- Cost: every cycle a load or store in WB waits for its response stalls the whole front: nothing enters EX or ID, occupied or empty
- Core: cv32e40x

## Issue

from the cycle after a load or store enters WB until the cycle its response is on the wire, no instruction enters EX from ID and none enters ID from IF, occupied or empty: a jump target already fetched waits in IF, a jalr whose operand has just arrived waits in ID; at zero wait the window never opens.

## What the documentation says

pipeline.rst 30-31: the cycle table assumes zero stall on the data-side interface; the Hazards list (114-126) and the stage descriptions (12-26) say nothing about what the pipeline's other stages do while WB waits for a response

## What the RTL does

a generated store test under a bus answering every request two cycles after its grant: jal zero, 8 (order 161) behind sw gp, 8(ra) with a late response: the jal retires +1 as always, its target lui +2 instead of +1 (the target fetched in the jal's ID cycle sat in IF); under a schedule that delays every second response by one cycle, the single-hazard suite shows 377 intervals a cycle longer than the cycle table and the Hazards list give, in 61 tests, 217 of them the targets of taken jumps, all RTL +2 against the table's +1; all 377 are this rule.  hzc-interleave-00 random:0-3: jalr s4, 0(a6) (order 663) behind lw a6 and lb s2 with late responses retires two cycles after the lb, not one: the waveform shows id_ready and ex_ready low in the two cycles the lb waits in WB.  Waveforms from a tracing build read with a VCD script, 9 Oct 2026

## The data bus timing of the run

The run answered every data request two cycles after its grant, every grant in the request cycle.  The issue shows only under such waits; a testbench that answers every request in the next cycle will not see it.

## From the RTL source (read, not measured)

`rtl/cv32e40x_ex_stage.sv`, lines 469-472 (`ex_ready_o`): 'The late (data_rvalid_i based) downstream wb_ready_i signal fans into the ready signals of all functional units': ex_ready_o includes lsu_ready_i; id_stage.sv 674: id_ready_o = ex_ready_i && !halt_id; wb_stage.sv 157: wb_ready_o includes lsu_ready_i -- the chain is low while the LSU in WB waits for data_rvalid_i

## To reproduce

The program in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro.S`

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- orders 137..139 (lui t4, 0x59: 2 cycles after the previous retirement): under a data bus that answers every request two cycles after its grant: the sw's response is late, the jal behind it retires +1 as always, but its target, the lui already fetched, retires +2 instead of +1: it sat in IF while the store in WB waited, although ID and EX had room (run.json's bus_schedule, respond:2, is the run's bus timing)

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/openhwgroup/cv32e40x.git at d952cd63bc1b4eb58cd893c28ef8283c781e345e; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-10-15

---

© 2026 processor-timing-anomalies, Apache License 2.0
