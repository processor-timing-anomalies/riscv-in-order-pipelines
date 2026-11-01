# No cycle count for an interrupt's entry or a wake from wfi

- Title: interrupt-and-wake-latency-unstated
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: an interrupt's entry costs 3 cycles beyond the pipeline's own (DECODE's decision, IRQ_TAKEN, the fetch) plus the vector table's jal; a wfi costs 4 cycles with the line already up; a request withdrawn in the IRQ_TAKEN cycle costs 2 and is dropped; none of it is in the document
- Core: ibex
- Found while running: ibex (the base build)

## Issue

the documentation gives no cycle count for an interrupt's entry nor for a wfi's wake, where the cv32e40x manual gives both: on the small configuration the handler's first instruction retires 5 cycles after the instruction that was in ID/EX when the request arrived (its own 2-cycle vector jal included), 6 after a flushing CSR write, and a wfi costs the instruction behind it 4 cycles when the line is already up (FLUSH, WAIT_SLEEP, SLEEP, FIRST_FETCH), the stream resuming 2 cycles after a later rise.

## What the documentation says

exceptions_interrupts.rst describes the vector jump (lines 9-13, 28-62) and the enables without cycles; integration.rst 483-487 describes core_sleep_o without the states or their count; pipeline_details.rst's table has no row for an interrupt or a wfi

## What the RTL does

hze-alu_nosrc-00 (29 Oct 2026, the event suite): the SET store's RVFI at 61, the vector table's jal at 66 (+5), on every subject class alike; hze-wfi-00: wfi +1 after the store, the csrrsi behind it +5, the handler's jal +6 after the csrrsi (its flush first); the withdrawn file's koff 1: the next instruction 3 cycles after the store, no handler, Spike alike

## From the RTL source (read, not measured)

`rtl/ibex_controller.sv`, lines 601-650, 702-724, 728-764 (`handle_irq`): DECODE halts IF while handle_irq and (stall or id_wb_pending) and enters IRQ_TAKEN once ID/EX is empty with no special request; IRQ_TAKEN sets the pc (the prefetch buffer requests in that cycle) and checks handle_irq again; a wfi goes FLUSH, WAIT_SLEEP, SLEEP, and SLEEP leaves to FIRST_FETCH the cycle after irq_pending_i, where the instruction in IF enters ID/EX

## To reproduce

The program in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro.S`

This program uses a memory-mapped test device of ours: an upstream Spike or a plain RTL simulation will not run it as it is.  Contact us for a set-up that does.

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- order 175 csrrsi zero, mstatus, 8: RTL 6 cycles; the documentation, read as written, gives 5

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/lowRISC/ibex.git at c0c07085791e4d16a0f2d9a753b2fb79d72e5ffa; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-10-29

---

© 2026 processor-timing-anomalies, Apache License 2.0
