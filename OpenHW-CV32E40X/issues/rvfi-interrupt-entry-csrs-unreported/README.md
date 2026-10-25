# An interrupt entry's CSR writes (mstatus, mepc, mcause) are not reported on RVFI

- Title: rvfi-interrupt-entry-csrs-unreported
- Class: function -- not a timing finding: a value, a fault or a sequence
- Core: cv32e40x
- Found while running: cv32e40x

## Issue

an interrupt's (or NMI's) entry writes mstatus, mepc and mcause in a cycle no instruction retires in, and cv32e40x_rvfi samples its CSR write masks with retirements only (rvfi_csr_wmask <= rvfi_csr_wmask_d on a WB retirement), so the trace reports no CSR write for the entry: the handler's first retirement carries rvfi_intr but an empty CSR mask, while an exception's writes are reported on the trapping instruction.  A reference ISS reports mcause, mepc and mstatus at the entry, so a wrong interrupt cause or mepc would be invisible to a consumer comparing CSR writes.

## What the documentation says

the RVFI specification (riscv-formal) has no interrupt entry of its own: rvfi_intr marks the first instruction of a handler; cv32e40x's rvfi_intr_t adds cause, interrupt and exception fields but no CSR writes for the entry

## To reproduce

The program in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro.S`

This program uses a memory-mapped test device of ours: an upstream Spike or a plain RTL simulation will not run it as it is.  Contact us for a set-up that does.

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- orders 24..25 (csrrs s2, mcause, zero: 3 cycles after the previous retirement): the first interrupt entry: order 24 is the last retirement before it, order 25 the handler's first (csrrs s2, mcause; rvfi_intr set, mcause 0x80000011); the RTL's RVFI reports no CSR write for the entry's mstatus, mepc and mcause, while a reference ISS reports all three

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/openhwgroup/cv32e40x.git at d952cd63bc1b4eb58cd893c28ef8283c781e345e; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-10-18

---

© 2026 processor-timing-anomalies, Apache License 2.0
