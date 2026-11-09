# An empty ID stage takes no instruction while a multi-cycle instruction holds EX

- Title: occupancy-freezes-empty-id
- Class: over-wide -- the stall fires in cases that have no cause for it: an interlock wider than needed, a performance flaw. The cause is a resource held: the divider (or the multiplier for mulh) occupies EX, so the instruction behind cannot enter EX until it is free.  Nothing in that cause keeps ID empty: with the cause removed for ID (ID empty, the next instruction waiting in IF) the move into ID is still refused, and the next instruction makes the IF-to-ID move after EX frees instead of during the stall, one cycle later.  The same instruction pair with the next instruction already in ID when the stall began pays nothing.  The same shape as the freeze while a load or store in WB waits for its response, which also holds an empty stage
- Cost: one cycle on the instruction behind a divide, remainder or mulh whose instruction word arrives only in the multi-cycle instruction's last cycle in ID or later (an instruction-side wait state before it); nothing on a zero-wait instruction bus, where it is already in ID when the stall begins
- Core: cv32e40x
- Found while running: cv32e40x (the base build)

## Issue

when the instruction behind a divide (or a remainder, or mulh) reaches the IF stage only after the divide has entered EX, it is not moved into the empty ID stage during the divide: it waits in IF until EX is free, enters ID then, and retires 2 cycles after the divide instead of the 1 the cycle table gives a single-cycle instruction; the same instruction already in ID when the divide entered EX retires 1 cycle after it.

## What the documentation says

pipeline.rst 21 (Execute): 'Multi-cycle instructions will stall this stage until they are complete'; pipeline.rst 30-31: 'The cycle counts assume zero stall on the instruction-side interface and zero stall on the data-side memory interface'; instruction_fetch.rst 6-8: IF 'is able to supply one instruction to the Instruction Decode (ID ) stage per cycle if the external bus interface is able to serve one instruction per cycle'.  The cycle table (Division, Remainder '3 - 35'; Multiplication '4 (mulh, mulhsu, mulhu)') and the Hazards list (pipeline.rst 111-126) say nothing about whether an empty ID takes an instruction from IF while EX is stalled

## What the RTL does

the instruction bus granting every fetch one cycle after its request: div a2, a0, a1 at 0x80000140 (a1 = 7) retires 32 cycles after the instruction before it (3 + 29 leading zeros, as the table gives); the word holding c.li t5, 15 (0x80000144) arrives in the div's last cycle in ID; no instruction fetch is issued during the divide and the next is issued as it ends; c.li t5, 15 retires 2 cycles after the div.  In the same run div a2, a0, a1 at 0x80000152 (a1 = 0) has c.li t5, 16 in the same word as its upper half, so it is in ID when the divide begins: it retires 1 cycle after the div; mulh a2, a0, a1 at 0x8000012e with c.li t5, 14 in its second word likewise, 1 cycle.  A second program under an instruction bus with single wait cycles on some grants: lui t3, 0x8 behind div gp, s0, s1 retires 2 cycles after the div in 8 of 48 such pairs and 1 in the other 40; in the one read (div at 0x80000034, 33 cycles) the lui's word (0x80000038) was granted a cycle after its request and arrived in the div's last cycle in ID, and the next fetch was issued only as the divide ended

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

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- order 99 c.li t5, 15: RTL 2 cycles; the documentation, read as written, gives 1

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/openhwgroup/cv32e40x.git at d952cd63bc1b4eb58cd893c28ef8283c781e345e; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-11-06

---

© 2026 processor-timing-anomalies, Apache License 2.0
