# A bus error's NMI is taken the cycle after the faulting access retires, every stage killed

- Title: nmi-taken-kill
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: the NMI handler's first retirement 5 cycles after the carrier's (the faulting load or store); the instruction behind the carrier retires before the handler only when its data request was outstanding when the error was seen, otherwise it is killed and runs again after the handler's mret
- Core: cv32e40x

## Issue

a bus error on a load or store is taken as an NMI the cycle after the faulting access retires: every stage is killed and the pc set to the NMI vector; one more load or store retires first when its request was already outstanding (two retirements after the error at most, as the exceptions chapter says), and a pending interrupt is taken after the NMI handler's mret, not before the NMI.

## What the documentation says

exceptions_interrupts.rst line 103 ('the instruction that causes the fault is allowed to retire and the associated NMI is taken afterwards') and line 105 ('Once the NMI is visible to the core, at most two instructions will retire before the NMI is taken'); pipeline.rst says nothing of an NMI's taking, its kills or what is abandoned

## What the RTL does

hze-nmi-00: the carrier retires with the error response, the handler's first retirement (the NMI vector's jump, rvfi_intr) comes 5 cycles later, the instructions behind the carrier abandoned and re-executed after the mret; with a lw or sw right behind the carrier that one retires too (its request was outstanding), the handler then 5 cycles after it; with line 17 pending at the same time the NMI's handler runs first and the interrupt's right after its mret

## From the RTL source (read, not measured)

`rtl/cv32e40x_controller_fsm.sv`, lines 729-742 (`nmi_allowed`): a pending NMI (nmi_pending_q, set at lines 1214-1230 by a bus error on a data response in WB) that is allowed (lines 562-563: the interrupt's conditions without the blanking, and not the cycle after waking to a debug request or an interrupt) kills IF, ID, EX and WB, sets the pc to PC_TRAP_NMI and saves the cause 1024 (load) or 1025 (store)

## To reproduce

The program in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro.S`

This program uses a memory-mapped test device of ours: an upstream Spike or a plain RTL simulation will not run it as it is.  Contact us for a set-up that does.

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- orders 41..44 (csrrs t0, mcause, zero: 2 cycles after the previous retirement): the NMI's taking: the load at order 41 is answered with a bus error; orders 42 and 43 retire while the NMI is pending; order 44 is the handler's first retirement, mcause 0x80000400; the instructions in flight behind 43 are killed and run again after the handler's mret

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/openhwgroup/cv32e40x.git at d952cd63bc1b4eb58cd893c28ef8283c781e345e; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-10-18

---

© 2026 processor-timing-anomalies, Apache License 2.0
