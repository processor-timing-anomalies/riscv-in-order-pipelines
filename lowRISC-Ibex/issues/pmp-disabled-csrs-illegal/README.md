# With PMPEnable 0 the PMP CSRs trap as illegal, not read as zero

- Title: pmp-disabled-csrs-illegal
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: none in cycles; an illegal-instruction trap where software expects a zero
- Core: ibex
- Found while running: ibex (the base build)

## Issue

pmp.rst says that with PMPEnable = 0 'all PMP registers read as zero (regardless of PMP CSR writes)'; the RTL makes every access to pmpcfg0-3, pmpaddr0-15, mseccfg and mseccfgh an illegal instruction on such a build (ibex and ibex-maxperf here).  The two differ for software that probes the registers: a read traps instead of returning 0.

## What the documentation says

pmp.rst, line 19: 'If PMPEnable is set to 0, all PMP registers read as zero (regardless of PMP CSR writes)'  The sentence the manual should carry: with PMPEnable = 0 the PMP CSRs are not implemented and any access of them raises an illegal-instruction exception.

## What the RTL does

ibex_cs_registers.sv: the PMP CSR addresses are legal only with PMPEnable; without it illegal_csr is set for them

## From the RTL source (read, not measured)

`rtl/ibex_cs_registers.sv`, lines 501-517, 705-713 (`illegal_csr`): the pmpcfg / pmpaddr / mseccfg cases of the CSR address decode are under `if (PMPEnable)`; the else branch sets illegal_csr for them, and illegal_csr_insn_o raises the illegal instruction exception

## To reproduce

The program in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro.S`

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- orders 7..39 (csrrw zero, mepc, t0: 1 cycles after the previous retirement): orders 8 and 24: a csrr of pmpcfg0 and of pmpaddr0 on a build with PMPEnable = 0 each raise an illegal-instruction exception (mcause 2), the handler resuming behind them; the manual says the registers read as zero

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/lowRISC/ibex.git at c0c07085791e4d16a0f2d9a753b2fb79d72e5ffa; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-11-01

---

© 2026 processor-timing-anomalies, Apache License 2.0
