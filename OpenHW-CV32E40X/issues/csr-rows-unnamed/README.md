# the Hazards rows of pipeline.rst 119-126, 'an instruction causing an implicit CSR read in EX' (119) and 'an instruction causing an implicit CSR write' (120) name no instruction; on the RTL an ecall 1 after a CSR write, and a CSR read of mstatus 1 after an mret, cost the flush alone, so neither is the row's instruction; an mret 1 after any CSR instruction is held in ID by another row, line 126's ('an instruction causing an implicit CSR read in ID (mret or table jump) while a CSR access instruction ... is in the EX stage'; controller_bypass.sv 252), measured at 3 cycles (the issue csr-mret-rows-class-based) (a trap or an mret resolves before the next instruction reads)

- Title: csr-rows-unnamed
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: none observed: the rows name no instruction this core has; an ecall or mret behind a CSR write pays the flush alone
- Core: cv32e40x
- Found while running: cv32e40x (the base build)

## Issue

the Hazards rows of pipeline.rst 119-126, 'an instruction causing an implicit CSR read in EX' (119) and 'an instruction causing an implicit CSR write' (120) name no instruction; on the RTL an ecall 1 after a CSR write, and a CSR read of mstatus 1 after an mret, cost the flush alone, so neither is the row's instruction; an mret 1 after any CSR instruction is held in ID by another row, line 126's ('an instruction causing an implicit CSR read in ID (mret or table jump) while a CSR access instruction ... is in the EX stage'; controller_bypass.sv 252), measured at 3 cycles (the issue csr-mret-rows-class-based) (a trap or an mret resolves before the next instruction reads).

## What the documentation says

pipeline.rst, Hazards: line 119, 'an instruction causing an implicit CSR read in EX while a CSR access instruction or an instruction causing an implicit CSR access is in the WB stage'; line 120, 'an instruction causing an explicit CSR read in EX while an instruction causing an implicit CSR write is in the WB stage'; the note at line 129 defines an implicit read as one 'performed by non-CSR instructions or CSR instructions reading CSR values from another CSR'.  No instruction is named for either row

## What the RTL does

an ecall one after a CSR write, and a CSR read of mstatus one after an mret, retire with the flush's cycles alone (an mret one after a CSR instruction is line 126's stall in ID, 3 cycles): neither pair overlaps in EX and WB, so neither is what the rows mean

## From the RTL source (read, not measured)

`rtl/cv32e40x_controller_bypass.sv`, lines 256-267 (`csr_stall_ex`): line 119's reader is a CSR instruction that names mnxti or mscratchcswl (cv32e40x_cs_registers.sv:432, 469), both built only with CLIC = 1; line 120's implicit writers (lines 126-138) are an mret, the CLIC and mret pointers and a CSR instruction that writes another CSR, which without CLIC is an access of tselect.  The manual could name them; with CLIC = 0 the first row cannot occur

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

- orders 9..15 (csrrs t2, mstatus, zero: 2 cycles after the previous retirement): the CSR pairs the Hazards rows 119-120 might mean: an ecall one after csrw mscratch, the handler's csrw mepc then mret (line 126's stall in ID), and a csrr of mstatus at the mret's target; the ecall and the csrr cost the flush alone, so neither is a row's case

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/openhwgroup/cv32e40x.git at d952cd63bc1b4eb58cd893c28ef8283c781e345e; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-11-07

---

© 2026 processor-timing-anomalies, Apache License 2.0
