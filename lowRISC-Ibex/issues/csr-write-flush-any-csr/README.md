# Any CSR write but mscratch and mepc flushes the pipeline, harmless ones too

- Title: csr-write-flush-any-csr
- Class: over-wide -- the stall fires in cases that have no cause for it: an interlock wider than needed, a performance flaw. The flush fires on a write of mcycle, minstret, mcountinhibit, mhpmevent3, mtval, mcause or mcounteren, none of which changes anything an instruction already fetched depends on (the probe of 1 Nov 2026: the addi behind each retires 3 cycles after it, as behind a write of mstatus); the trigger is the CSR address class, every CSR but mscratch and mepc, where the cause is a write that changes fetch, decode or privilege state (mstatus, mie, mtvec, the PMP and mseccfg, cpuctrlsts, the debug CSRs).  A read with no write (csrrs x0, csrrsi 0, csrrc x0, csrr) flushes nothing, so the trigger is the write and the over-width is its address set
- Cost: two cycles on every write of a CSR that changes nothing in flight: the counters and their inhibit, the event selectors, mtval, mcause, mcounteren; a trap handler that writes mcause or mtval pays it, and a counter-reading loop that resets a counter
- Core: ibex
- Found while running: ibex (the base build)

## Issue

a CSR write of any CSR but mscratch and mepc flushes the pipeline, two cycles on the instruction behind it, whatever the CSR: a write of mcycle, minstret, mcountinhibit, mhpmevent3, mtval, mcause or mcounteren costs the same two cycles as a write of mstatus or mtvec, though it changes nothing an instruction already in flight could depend on.  The exemption list is two CSRs; a list of the CSRs whose write must flush would be the smaller set.

## What the documentation says

pipeline_details.rst, the pipeline table: a CSR write 'flushes the pipeline, so the instruction immediately following a CSR write incurs an additional fetch-latency' (the count and the CSR set unsaid: the entry csr-write-flush-two-cycles, for the documentation)

## What the RTL does

the probe csr-write-flush-any-csr.S on ibex, 1 Nov 2026: one CSR access per block with three independent addi behind it; behind csrrw x0, mscratch the first addi retires 1 cycle after the write; behind csrrw x0 of mcycle, minstret, mcountinhibit, mhpmevent3, mtval, mcause or mcounteren it retires 3 cycles after it, every one; behind csrrs x0, csrrsi 0 and csrrc x0 of mstatus or mie, and a csrr of mscratch, 1 cycle.  Spike and the RTL agree on every compared value; the same on the three-stage builds ibex-maxperf and ibex-pmp, whose generated CSR-write tests pay the same two cycles

## From the RTL source (read, not measured)

`rtl/ibex_id_stage.sv`, lines 586-593 (`csr_pipe_flush`): csr_pipe_flush is raised for a CSR instruction with a write (csr_op_en_o and CSR_OP_WRITE, SET or CLEAR) of any address but the two of no_flush_csr_addr (mscratch, mepc): the address alone decides, and the controller's special_req_flush_only takes DECODE through FLUSH

## To reproduce

The program in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro.S`

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- orders 4..41 (addi t2, zero, 1: 3 cycles after the previous retirement): one CSR access per block, three addi behind it: csrrw of mscratch (orders 4-6) leaves the addi at 1 cycle; csrrw of mcycle, minstret, mcountinhibit, mhpmevent3, mtval, mcause and mcounteren (orders 9-41) each put the addi behind at 3 cycles, the two bubble cycles of the flush, though none of them changes anything an instruction in flight depends on; the reads behind (orders 44-61: csrrs x0, csrrsi 0, csrrc x0, csrr) flush nothing

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/lowRISC/ibex.git at c0c07085791e4d16a0f2d9a753b2fb79d72e5ffa; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-11-01

---

© 2026 processor-timing-anomalies, Apache License 2.0
