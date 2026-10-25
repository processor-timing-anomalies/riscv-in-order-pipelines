# a CSR instruction behind any access of tselect waits a cycle

- Title: tselect-access-stall
- Class: over-wide -- the stall fires in cases that have no cause for it: an interlock wider than needed, a performance flaw. The cause would be an implicit CSR write by the tselect access; the trigger is the address alone: a pure read of tselect (csrrs rd, tselect, x0, which writes nothing) makes the next CSR instruction wait, measured; the write form is expected to pay the same and is not yet in a block
- Cost: one cycle on every CSR instruction one behind any access of tselect, a read included
- Core: cv32e40x

## Issue

a CSR instruction one behind a read of tselect retires a cycle late: the core treats any access of tselect as an implicit CSR write still in the write stage and holds the next CSR instruction in EX for that cycle, though a read of tselect writes nothing; the cycle-count table gives a CSR access 1 cycle and the Hazards list names no instruction for its implicit-write row.

## What the documentation says

pipeline.rst, 'Cycle counts per instruction type': CSR Access 1 cycle for every CSR but jvt (line 44); the Hazards list, line 120: 'an instruction causing an explicit CSR read in EX while an instruction causing an implicit CSR write is in the WB stage' -- no instruction is named, and nothing says a read of tselect is one

## What the RTL does

csrrc rd, mscratch, rs1 and csrrci rd, mscratch, 7 each one behind csrrs rd, tselect, x0: 2 cycles where every other CSR instruction in that position takes 1 (own-cv32e40x-00 blocks 289 and 290, the only 2 of 5,011 intervals that differ)

## From the RTL source (read, not measured)

`rtl/cv32e40x_controller_bypass.sv`, lines 256-267 (`csr_impl_write_in_wb`): csr_stall_ex's second term (line 263): a CSR instruction in EX waits while WB holds a CSR instruction flagged csr_impl_wr; cv32e40x_cs_registers.sv 484-487 sets the flag (impl_wr_ex) for any CSR instruction whose address is tselect when DBG_NUM_TRIGGERS > 0 (1 on this build, the RTL's default), whatever the instruction's form

## To reproduce

The programs in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro-1.S`
- `repro.S`

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- order 4995 csrrc s9, mscratch, s10: RTL 2 cycles; the documentation, read as written, gives 1
- order 5006 csrrci gp, mscratch, 7: RTL 2 cycles; the documentation, read as written, gives 1

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/openhwgroup/cv32e40x.git at d952cd63bc1b4eb58cd893c28ef8283c781e345e; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-10-19

---

© 2026 processor-timing-anomalies, Apache License 2.0
