# CLIC: an access of mnxti or mscratchcswl behind any CSR instruction waits a cycle

- Title: clic-implicit-csr-read-stall
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle on every access of mnxti or mscratchcswl one behind any CSR instruction, in CLIC mode
- Core: cv32e40x
- Found while running: cv32e40x-clic

## Issue

in CLIC mode an access of mnxti (csrrs rd, mnxti, x0) or of mscratchcswl (csrrw rd, mscratchcswl, rs1) one behind any CSR instruction retires a cycle late: the core reads another CSR implicitly for these two (mstatus for mnxti; mscratch, mcause and mintstatus for mscratchcswl) and holds the access in EX while a CSR instruction is in the write stage; the Hazards list's implicit-read row names no instruction, so a reader cannot know these are the two.

## What the documentation says

pipeline.rst, Hazards, line 119: 'an instruction causing an implicit CSR read in EX while a CSR access instruction or an instruction causing an implicit CSR access is in the WB stage' -- no instruction named; the CLIC chapter of control_status_registers.rst describes mnxti and mscratchcswl without a cycle

## What the RTL does

csrrs rd, mnxti, x0 and csrrw rd, mscratchcswl, rs1, each one behind csrrs/csrrc/csrrci of mscratch: 2 cycles where any other CSR instruction in that position takes 1 (own-cv32e40x-clic-00 on cv32e40x-clic: 4 of 4 blocks, RTL +1 each)

## From the RTL source (read, not measured)

`rtl/cv32e40x_controller_bypass.sv`, lines 256-267 (`csr_hz_i.impl_re_ex`): csr_stall_ex's first term (line 262): an implicit CSR read in EX -- an access of mnxti (cv32e40x_cs_registers.sv 426-439) or of mscratchcswl (462-482) -- while csr_write_in_wb (lines 143-144): any CSR instruction in WB, a pure read included; EX is halted for that cycle

## To reproduce

The program in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro.S`

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- orders 4905..4908 (csrrs a6, 0x345, zero: 2 cycles after the previous retirement): the mnxti read one behind a CSR instruction: 2 cycles where any other CSR instruction takes 1

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/openhwgroup/cv32e40x.git at d952cd63bc1b4eb58cd893c28ef8283c781e345e; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-10-19

---

© 2026 processor-timing-anomalies, Apache License 2.0
