# CLIC: a load or store behind a write of mintthresh waits a cycle

- Title: clic-mintthresh-write-stall
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle on every load or store one behind a write of mintthresh, in CLIC mode
- Core: cv32e40x
- Found while running: cv32e40x-clic

## Issue

in CLIC mode a load or store one behind a write of mintthresh retires a cycle late: the write may enable an interrupt (it lowers the threshold) and the core holds the load or store in EX while the writer is in the write stage, as it does behind a write of mstatus; a write through mnxti (csrrsi x0, mnxti, 8), which the RTL source reads as a write of mstatus, does not hold it; the Hazards list has no row for any of this.

## What the documentation says

pipeline.rst, Hazards (lines 114-126): no row for a load or store behind a write that may enable an interrupt; control_status_registers.rst's mintthresh section gives no cycle

## What the RTL does

c.lbu and c.sb each one behind csrrs x0, mintthresh, rs1: 2 cycles (own-cv32e40x-clic-00: 2 of 2 blocks, RTL +1); c.lh and c.sh each one behind csrrsi x0, mnxti, 8: 1 cycle (2 of 2 blocks, no stall); the published traces, from the confirming run of the same test, show it on c.lhu a2, 0(a3) one behind csrrs zero, mintthresh, s5 (order 5051: 2 cycles)

## From the RTL source (read, not measured)

`rtl/cv32e40x_cs_registers.sv`, lines 1550-1557 (`csr_irq_enable_write_o`): the clic_irq_en branch (line 1553): csr_irq_enable_write_o includes mintthresh_we; the pass also read an mnxti write as writing mstatus (lines 936-938) and so expected the stall behind it, which the measurement does not show: the write enable it sets is not one of the four the branch names

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

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- orders 11..12 (lhu a2, 0(a3): 2 cycles after the previous retirement): in CLIC mode a load one behind a write of mintthresh (csrrs x0, mintthresh, rs1) retires in 2 cycles where a load takes 1: the write may enable an interrupt and the core holds the load in EX while the writer is in WB; a store one behind the same write (orders 17-18) likewise 2; one behind a write of mscratch (orders 23-24) the load takes 1

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/openhwgroup/cv32e40x.git at d952cd63bc1b4eb58cd893c28ef8283c781e345e; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-10-29

---

© 2026 processor-timing-anomalies, Apache License 2.0
