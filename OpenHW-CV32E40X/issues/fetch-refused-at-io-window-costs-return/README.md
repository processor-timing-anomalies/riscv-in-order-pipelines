# A jump in the last word before an I/O region puts its target's fetch a cycle late

- Title: fetch-refused-at-io-window-costs-return
- Class: over-wide -- the stall fires in cases that have no cause for it: an interlock wider than needed, a performance flaw. The cause a jump's target request could wait for is an instruction transaction still outstanding (the fetch interface allows two, instruction_fetch.rst 69-70).  Here there is none: the word after the jump lies in the I/O region, the PMA prevents that speculative fetch and nothing goes on the bus, and the jump's flush would discard the word anyway.  With the cause absent the target's request is still a cycle late; the same two instructions 256 bytes below the region (the next word fetched, answered and flushed: the case with a transaction to discard) put the target's request on the bus in the jump's ID cycle.  A prevented fetch costs the redirect more than an issued one
- Cost: one cycle on a jump in the last word of main memory before an I/O region (measured on jalr; other distances from the region, and branches, not measured); nothing on the same jump 256 bytes below the region
- Core: cv32e40x
- Found while running: cv32e40x-pma

## Issue

jalr zero, 0(ra) in the last word of main memory before an I/O region (at 0x803efffc, the region from 0x803f0000) puts its target's fetch on the instruction bus one cycle after the cycle it is in ID, where the cycle table says the request appears the same cycle, so the instruction at the target retires 3 cycles after the jump instead of the 2 the table gives a jump; the prefetch of the word after it, in the I/O region, is not issued, as the PMA chapter says, and the same jump 256 bytes below the region costs 2.

## What the documentation says

pipeline.rst 66-70 (Cycle counts per instruction type, row Jump): 'Jumps are performed in the ID stage' (the row's cycles 2, and its text: the IF stage and the prefetch buffer are flushed and the new PC request appears on the instruction-side interface the same cycle the jump is in ID); pma.rst 38: 'I/O regions are considered to be non-idempotent and therefore the PMA will prevent speculative accesses to such regions.'; instruction_fetch.rst 16-20: the prefetcher 'can fetch up to three words outside of the code region'.  Nothing says that a speculative fetch the PMA prevents delays a following jump

## What the RTL does

PMA regions: I/O 0x803f0000-0x803f7fff (main 0), main 0x80000000-0x803fffff; the instruction bus granting every request in its own cycle and answering it the next.  The program writes addi t4, zero, 7 and jalr zero, 0(ra) at 0x803efff8 and 0x803efffc, runs fence.i and jalr ra, 0(gp) to them: jalr ra retires 4 cycles after the fence.i, addi t4 2 after it, jalr zero 1 after that, and addi s1, zero, 1 at the target 0x80000070 3 after the jalr zero.  On the instruction bus: 0x803efff8 requested at cycle 45, 0x803efffc at 46 (answered at 47), no request at 47 or 48 (none at or above 0x803f0000 in the whole run), 0x80000070 at 49.  The same program with the two words at 0x803eff00 and 0x803eff04: 0x803eff04 answered at 47 as well, the prefetch of 0x803eff08 requested at 47, 0x80000070 at 48, and addi s1 retires 2 cycles after the jalr zero; the three retirements before it take 4, 2 and 1 cycles in both runs

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
| `PMA_NUM_REGIONS` | `0` |

The instruction and data buses granted every request in its own cycle and answered it in the next: no wait states.

## To reproduce

The programs in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `probe-far-from-window.S` (a probe program of this finding; the traces are not of it)
- `repro.S`

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- order 30 addi s1, zero, 1: RTL 3 cycles; the documentation, read as written, gives 2

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/openhwgroup/cv32e40x.git at d952cd63bc1b4eb58cd893c28ef8283c781e345e; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-11-06

---

© 2026 processor-timing-anomalies, Apache License 2.0
