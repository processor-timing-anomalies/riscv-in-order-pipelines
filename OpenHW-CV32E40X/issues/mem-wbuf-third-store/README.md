# A bufferable store whose grant is withheld, third behind a mulh, stalls one cycle

- Title: mem-wbuf-third-store
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle on a bufferable store when the buffer's transfer holds the last outstanding slot
- Core: cv32e40x
- Found while running: cv32e40x-pma

## Issue

on cv32e40x-pma, three bufferable stores in a row behind a 4-cycle mulh -- the first with its grant withheld one cycle, the second granted at once, the third (sb) with its grant withheld two cycles -- the third retires one cycle later than a store the write buffer absorbs (+2 against the +1 of the write-buffer rule), and the load behind it one cycle earlier than predicted (+6 against +7); the same block on cv32e40x, where no store is bufferable, is at 0 differ.

## What the documentation says

load_store_unit.rst Write buffer (142-160): the buffer, when not full, lets the core proceed without waiting for data_gnt_i and data_rvalid_i of a bufferable transfer; nothing on what happens to the third of three stores when the buffer has just emptied, nor on the early response's timing (the response filter, rtl/cv32e40x_lsu_response_filter.sv, is not in the manual)

## What the RTL does

hzs-shape-01-zmmul-00 on cv32e40x-pma, 12 Oct 2026, block 60 (shape s3_mem14_mem25_struct03: mulh, sw accept 1, sw, sb accept 2, lb accept 3, lb): the harness log k71 sw req 2177 gnt 2178 rsp 2179, k72 sw req 2179 gnt 2179 rsp 2180, k73 sb req 2180 gnt 2182 rsp 2183, k74 lb req 2183 gnt 2186 rsp 2187; retirements mulh 2178, sw 2179, sw 2180, sb 2182, lb 2188: the sb takes two cycles where the rule gives one; the memory-kind blocks with a single absorbed store (cp_f3_wbuf absorbed_a2) are at 0 differ, so it is the sequence, not the absorption; traced with the harness's VCD, cycles as the harness log counts them: 2177 the first sw at the filter, its bus-side count 0 and the buffer empty -- taken (count 1); 2178 the first sw granted, the second sw taken by the buffer as it frees (count 2), the first's response given to the core the same cycle; 2179 the sb in EX with the count at 2 (the first sw's response on the wire this cycle, the second sw granted this cycle) -- the filter's ready_o low, the sb held one cycle; 2180 count 1, the buffer empty -- the sb taken, on the bus; 2181 its response given to the core (the oldest open transfer is bufferable), retired 2182; the lb behind it held by the full buffer (2181) and the sb's grant cycle (2182), on the bus 2183, granted 2186, retired 2188 -- the same cycle the rule gave it, so only the sb moves

## From the RTL source (read, not measured)

`rtl/cv32e40x_lsu_response_filter.sv`, lines 109-110, 158-160 (`bus_cnt_q, ready_o, resp_valid_o`): the filter sits between the MPU and the write buffer (cv32e40x_load_store_unit.sv 873-899); bus_cnt_q counts a transfer from the buffer taking it (bus_trans_accepted = ready_i && valid_o, ready_i the buffer's ready) to its response (resp_valid_i), so a transfer the buffer holds counts as outstanding; ready_o = ready_i && bus_cnt_q < DEPTH (2) holds the core's next transfer, bufferable or not, while two are open; resp_valid_o = bus_resp_is_bufferable ? core_resp_is_bufferable : resp_valid_i gives a bufferable store its response the cycle the buffer takes it when the oldest open transfer is bufferable -- traced cycle by cycle (the rtl field)

## To reproduce

The program in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro.S`

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- order 1856 sb a0, 0(s1): RTL 2 cycles; the documentation, read as written, gives 1

## Found by

RTL https://github.com/openhwgroup/cv32e40x.git at d952cd63bc1b4eb58cd893c28ef8283c781e345e; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-10-12

---

© 2026 processor-timing-anomalies, Apache License 2.0
