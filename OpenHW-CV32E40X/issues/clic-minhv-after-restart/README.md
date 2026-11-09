# mcause.minhv stays set after an mret restarts a faulted CLIC pointer fetch successfully

- Title: clic-minhv-after-restart
- Class: function -- not a timing finding: a value, a fault or a sequence
- Core: cv32e40x
- Found while running: cv32e40x-clic

## Issue

in CLIC mode a vectored interrupt whose table entry fetch faults traps with mcause.minhv set and mepc the entry's address; an mret with minhv set fetches the pointer again (the restart) and, when that fetch succeeds, enters the handler with minhv still set: the handler reads mcause with bit 30 up, and its own mret restarts a pointer fetch from mepc instead of returning, unless software clears the bit.  The manual (control_status_registers.rst, mcause in CLIC mode) says minhv is "cleared by hardware at end of successful hardware vectoring".

## What the documentation says

control_status_registers.rst, Machine Cause (mcause) - CLIC == 1, bit 30: "MINHV. Set by hardware at start of hardware vectoring, cleared by hardware at end of successful hardware vectoring"; the taking of a vectored interrupt reads minhv 0 in the handler (the clearing at the start is not observable either)

## From the RTL source (read, not measured)

`rtl/cv32e40x_controller_fsm.sv`, lines 743-744, 793-794, 856-857, 979-1000 (`ctrl_fsm_o.csr_cause.minhv`): minhv is written only with a trap's cause: 0 at an interrupt's or NMI's taking, clic_ptr_in_wb || mret_ptr_in_wb at an exception; the mret with minhv restarts the pointer fetch (pc_set_clicv) and nothing clears the bit when that fetch completes

## The core's configuration

The RTL was built with these parameters of its top module (the names and values are the RTL's own; the build named under "Found while running" is what they define):

| parameter | value |
|---|---|
| `RV32` | `RV32I` |
| `A_EXT` | `A_NONE` |
| `B_EXT` | `ZBA_ZBB_ZBS` |
| `M_EXT` | `M` |
| `X_EXT` | `0` |
| `NUM_MHPMCOUNTERS` | `1` |
| `CLIC` | `1` |
| `CLIC_ID_WIDTH` | `5` |

The instruction and data buses granted every request in its own cycle and answered it in the next: no wait states.

## To reproduce

The program in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro.S`

This program uses a memory-mapped test device of ours: an upstream Spike or a plain RTL simulation will not run it as it is.  Contact us for a set-up that does.

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- order 15 illegal 0x00000000: RTL 5 cycles; the documentation, read as written, gives 4
- order 28 csrrs s2, mcause, zero: RTL 2 cycles; the documentation, read as written, gives 1
- order 28 csrrs s2, mcause, zero: RTL 2 cycles; the documentation, read as written, gives 1
- order 28 csrrs s2, mcause, zero: RTL 2 cycles; the documentation, read as written, gives 1
- order 28 csrrs s2, mcause, zero: RTL 2 cycles; the documentation, read as written, gives 1

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/openhwgroup/cv32e40x.git at d952cd63bc1b4eb58cd893c28ef8283c781e345e; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-11-07

---

© 2026 processor-timing-anomalies, Apache License 2.0
