# An atomic transaction overlaps no other: a cycle lost on each side of an lr, sc or AMO

- Title: mem-atomic-serial
- Class: over-wide -- the stall fires in cases that have no cause for it: an interlock wider than needed, a performance flaw. A plain load or store behind an atomic waits whether or not the atomic carries aq or rl, and an ALU instruction does not: wider than any architectural cause; whether the bus adapter requires an atomic transaction to be alone on the bus is the question for the authors
- Cost: one cycle on every load, store, sc.w or AMO right behind an sc.w or an AMO, and on an atomic right behind a load or store
- Core: cv32e40x
- Found while running: cv32e40x-pma-a

## Issue

on cv32e40x-pma-a (A_EXT=A), every load, store, sc.w or AMO right behind an sc.w or an AMO retires a cycle later than the rows give (+2 for +1), and every atomic right behind a load or store likewise; an ALU instruction behind an atomic is not delayed, and an atomic's rd reaches its consumer as a load's does (no extra cycle).

## What the documentation says

load_store_unit.rst 164-170 (Atomic Operations): the core supports exclusive and atomic transactions with an external adapter, lr.w / sc.w / the AMOs as single-copy atomic word transactions; nothing on their timing against the transactions before and after them, and the cycle table has no atomic row

## What the RTL does

the single suite's A files on cv32e40x-pma-a, 12 Oct 2026, every disagreement a pair at distance 1: an lb / sb / sc.w / AMO right after an sc.w or an AMO retires +2 (the rows: +1), and an AMO right after an sb likewise (hz-Zaamo-amoadd.w-zaamo-00 order 8856: sb a5, 0(a4); amoadd.w a7, a6, (a4): +2); no disagreement at distance 2 or more, none for an ALU, branch or jump behind an atomic, none for a consumer of an atomic's rd (the load-use rule holds for it)

## From the RTL source (read, not measured)

`rtl/cv32e40x_controller_bypass.sv`, lines 282-293 (`ctrl_byp_o.atomic_stall`): with A_EXT != A_NONE, EX is stalled while lsu_bus_busy_i (the response filter's bus-side count, a transfer accepted and not yet answered) in two cases: an atomic instruction in EX (1: it waits for every outstanding transaction), and any LSU instruction in EX while an atomic is in WB (2: it waits for the atomic's response); the stall is one of the bypass stalls that halt EX (controller_fsm.sv 666) -- on the zero-wait bus a response follows its grant by one cycle, so each case costs exactly one cycle

## To reproduce

The programs in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro-1.S`
- `repro-2.S`
- `repro-3.S`
- `repro.S`

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- order 6348 sc.w s3, s6, (s5): RTL 2 cycles; the documentation, read as written, gives 1
- order 4351 sb zero, 0(a1): RTL 2 cycles; the documentation, read as written, gives 1
- order 4898 lb a3, 0(a6): RTL 2 cycles; the documentation, read as written, gives 1
- order 4974 sc.w s9, s0, (gp): RTL 2 cycles; the documentation, read as written, gives 1

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/openhwgroup/cv32e40x.git at d952cd63bc1b4eb58cd893c28ef8283c781e345e; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-10-12

---

© 2026 processor-timing-anomalies, Apache License 2.0
