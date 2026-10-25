# jvt write: the table's 4 cycles are a flush of the next instruction

- Title: jvt-write-flush
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: five cycles on the instruction after every write of jvt (the write itself retires in one), and the interrupt taking blocked for the cycle after the write's retirement
- Core: cv32e40x

## Issue

the cycle-count table gives a CSR access 4 cycles for jvt; on the RTL a write of jvt retires in one cycle and the instructions behind it are flushed and refetched, so the next instruction retires 5 cycles after the write (1 + 4 is the table's 4 over the pair), and an interrupt pending in the cycle after the write's retirement is taken one cycle later than after any other CSR write; the document states neither the flush nor the interrupt's cycle, and a read of jvt costs 1.

## What the documentation says

pipeline.rst, 'Cycle counts per instruction type', the CSR Access row (line 44): '4 (jvt)' against 1 for every other CSR; nothing in the table or in the Hazards list says the cycles are a flush of the following instructions, nor that an interrupt is blocked for a cycle

## What the RTL does

the jvt write retires one cycle after the instruction before it; the instruction behind it retires 5 cycles after the write (a plain CSR write: 1); with the interrupt line up before the write, the handler's first instruction retires 6 cycles after the write against 5 after any other CSR write (hze-jvt-00, phases 0-10, 44 blocks: the swept line at every phase across the flush and the refetch)

## From the RTL source (read, not measured)

`rtl/cv32e40x_cs_registers.sv`, lines 1545-1548 (`csr_wr_in_wb_flush_o`): csr_wr_in_wb_flush_o = jvt_wr_in_wb: a write of jvt in WB is the one CSR write that asks the controller for a flush; the controller (rtl/cv32e40x_controller_fsm.sv 933-950) halts IF, ID and EX in that cycle, kills them in the next (csr_flush_ack_q) and restarts fetch from the oldest killed instruction, and interrupt_allowed (line 557) is low in that acknowledge cycle

## To reproduce

The program in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro.S`

This program uses a memory-mapped test device of ours: an upstream Spike or a plain RTL simulation will not run it as it is.  Contact us for a set-up that does.

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- order 268 lui t1, 0x82: RTL 1 cycles; the documentation, read as written, gives 2
- order 39 csrrw zero, jvt, s2: RTL 1 cycles; the documentation, read as written, gives 5
- order 112 jal zero, 128: RTL 6 cycles; the documentation, read as written, gives 7
- order 50 lui t1, 0xe: RTL 2 cycles; the documentation, read as written, gives 1
- order 195 lui t2, 0x5b: RTL 1 cycles; the documentation, read as written, gives 2
- order 112 jal zero, 128: RTL 6 cycles; the documentation, read as written, gives 7
- order 148 jal zero, 128: RTL 7 cycles; the documentation, read as written, gives 8
- order 184 jal zero, 128: RTL 8 cycles; the documentation, read as written, gives 5
- order 220 jal zero, 128: RTL 9 cycles; the documentation, read as written, gives 5
- order 435 csrrs zero, jvt, s4: RTL 1 cycles; the documentation, read as written, gives 5
- order 833 csrrw zero, jvt, s6: RTL 1 cycles; the documentation, read as written, gives 5
- order 834 jal zero, 128: RTL 6 cycles; the documentation, read as written, gives 7
- order 844 lui t1, 0x1b2: RTL 2 cycles; the documentation, read as written, gives 1
- order 921 lui t4, 0x1dd: RTL 1 cycles; the documentation, read as written, gives 2
- order 872 jal zero, 128: RTL 7 cycles; the documentation, read as written, gives 8
- order 910 jal zero, 128: RTL 8 cycles; the documentation, read as written, gives 5
- order 948 jal zero, 128: RTL 9 cycles; the documentation, read as written, gives 5
- order 1251 csrrs zero, jvt, s8: RTL 1 cycles; the documentation, read as written, gives 5

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/openhwgroup/cv32e40x.git at d952cd63bc1b4eb58cd893c28ef8283c781e345e; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-10-19

---

© 2026 processor-timing-anomalies, Apache License 2.0
