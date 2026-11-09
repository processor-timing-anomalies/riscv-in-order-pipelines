# A withdrawn interrupt costs the instruction behind the clearing write a cycle

- Title: irq-withdrawn-by-mie-clear-one-cycle
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle on the second instruction behind a csrrci of mstatus.MIE when an enabled interrupt line rises in the data cycle of a store right before the write, and the interrupt itself deferred until MIE is set again; a race one cycle wide, no cost at any other alignment of the line and the write
- Core: cv32e40x
- Found while running: cv32e40x (the base build)

## Issue

an enabled interrupt line that rises in the data cycle of a store, with a csrrci clearing mstatus.MIE right behind the store, is not taken (MIE is clear before it could be) and costs one cycle on the second instruction after the csrrci, which retires 2 cycles after its predecessor where the cycle table gives 1; the same line rising one cycle later costs nothing, and with the clearing write one instruction further from the store the interrupt is taken before the write; the interrupt chapter gives no timing for a line's recognition against a write that disables it, and names no cycle an instruction pays while an interrupt is pending and not taken.

## What the documentation says

exceptions_interrupts.rst line 186 ('To enable any of the irq_i[31:0] interrupts, both the global interrupt enable (MIE) bit in the mstatus CSR and the corresponding individual interrupt enable bit in the mie CSR need to be set') and line 202 ('The irq_i[31:0] interrupt lines are level-sensitive'): nothing on when a rising line is recognized against a write that clears MIE, nor on a cycle an instruction pays while an interrupt is pending and not taken; pipeline.rst's cycle table gives an integer computational instruction 1 cycle (line 41) and a CSR access 1 (line 46), and its Hazards list (lines 114-126) names no hazard behind a write of mstatus

## What the RTL does

the reproducer (78 retirements): the line is raised in the cycle of the store's bus request (the testbench's record) and the store retires with its response; the csrrci retires one cycle after the store, the first lui one cycle after the csrrci and the second lui two cycles after the first, with no interrupt taken; the csrrsi that restores MIE twelve instructions later retires at one-cycle spacing and the handler's first retirement (mcause 0x80000011, line 17) comes 5 cycles after it.  In the sweep's file the same block with the line one to eight cycles later (phases 1 to 8) retires every instruction one cycle apart and takes the interrupt after the restoring write; the mie.MSIE form at phase 0, whose csrrc stands two behind the store (an addi supplies its mask), takes the interrupt before the csrrc: the handler's jal 5 cycles after the addi, the mret returning to the csrrc

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

The instruction and data buses granted every request in its own cycle and answered it in the next: no wait states.

## To reproduce

The program in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro.S`

This program uses a memory-mapped test device of ours: an upstream Spike or a plain RTL simulation will not run it as it is.  Contact us for a set-up that does.

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- order 39 lui t2, 0xf: RTL 2 cycles; the documentation, read as written, gives 1

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/openhwgroup/cv32e40x.git at d952cd63bc1b4eb58cd893c28ef8283c781e345e; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-11-06

---

© 2026 processor-timing-anomalies, Apache License 2.0
