# A misaligned atomic raises an access fault (5, 7), not a misaligned one (4, 6)

- Title: mem-atomic-misaligned-cause
- Class: function -- not a timing finding: a value, a fault or a sequence
- Core: cv32e40x
- Found while running: cv32e40x-pma-a

## Issue

on cv32e40x-pma-a (A_EXT=A), an lr.w, sc.w or amoadd.w whose address is not word-aligned (tdata + 2, main memory) traps with mcause 5 (lr.w) or 7 (sc.w, the AMO): the access faults; the exception table (exceptions_interrupts.rst) says a non-naturally aligned Load-Reserved address raises 'Load address misaligned' (4) and a non-naturally aligned Store-Conditional / AMO address 'Store/AMO address misaligned' (6).  No request goes on the bus; Spike raises the same access faults, so the two references agree and only the document differs.

## What the documentation says

exceptions_interrupts.rst 30 and 36 (the exception table): code 4 'Load address misaligned' for a 'Non-naturally aligned Load-Reserved address', code 6 'Store/AMO address misaligned' for a 'Non-naturally aligned Store-Conditional / AMO address'; codes 5 and 7 list only the I/O-region and no-atomic-support cases.  load_store_unit.rst 56: 'Misaligned transactions (by non-atomics instructions) are supported in hardware for Main memory regions'; pma.rst 60-65 says nothing on alignment

## What the RTL does

the probe's run, 13 Oct 2026: lr.w s7, (s5) at tdata + 2 traps with mcause 5, sc.w s10, s6, (s5) and amoadd.w s0, s6, (s5) with mcause 7; mepc the atomic's pc; no data request on the bus for any of the three; the aligned control amoadd.w completes

## From the RTL source (read, not measured)

`rtl/cv32e40x_controller_fsm.sv`, lines 343, 356-357 (`exception_cause_wb`): an atomic's alignment error reaching WB (align_status_wb_i != ALIGN_OK, from cv32e40x_align_check.sv: the check runs when atop[5] is set, cv32e40x_load_store_unit.sv 833) is an exception whose cause is EXC_CAUSE_STORE_FAULT for ALIGN_WR_ERR and EXC_CAUSE_LOAD_FAULT otherwise; no EXC_CAUSE_*_MISALIGNED is ever selected by that chain

## To reproduce

The program in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro.S`

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- orders 13..58 (csrrs t5, mcause, zero: 1 cycles after the previous retirement): a misaligned lr.w (order 13), sc.w (34) and amoadd.w (55) at tdata + 2 in main memory: the RTL raises a load access fault (5) and store/AMO access faults (7), as Spike does; the exception table gives the address-misaligned causes 4 and 6 for them

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/openhwgroup/cv32e40x.git at d952cd63bc1b4eb58cd893c28ef8283c781e345e; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-10-13

---

© 2026 processor-timing-anomalies, Apache License 2.0
