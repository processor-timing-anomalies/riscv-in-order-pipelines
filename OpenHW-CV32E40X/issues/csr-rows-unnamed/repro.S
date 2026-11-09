// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the whole test csr-rows-pairs, kept as it ran (no cut-down reproducer: a confirmation capture, the window 9-15 marked by hand).
# the window: orders 9-15 of the run -- the CSR pairs the Hazards rows 119-120 might mean: an ecall one after csrw mscratch, the handler's csrw mepc then mret (line 126's stall in ID), and a csrr of mstatus at the mret's target; the ecall and the csrr cost the flush alone, so neither is a row's case
# csr-rows-pairs.S -- the reproducer of csr-rows-unnamed, written by hand (7 Nov 2026): the CSR pairs the Hazards rows
# of pipeline.rst 119-120 might mean, one block each, the retirement cycles read from the trace.
#   1. an ecall one after a CSR write (csrw mscratch): the ecall costs the trap's flush alone
#   2. a CSR read of mstatus one after an mret (the first instruction at the mret's target): the mret's flush alone
#   3. an mret one after a CSR write (csrw mepc in the handler): held in ID by line 126's row, 3 cycles
# Neither 1 nor 2 overlaps a CSR access in WB with the next instruction's read in EX, so neither is a row's case;
# the rows name no instruction.
# MARCH: rv32imc_zicsr_zifencei
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    la      t0, handler
    csrw    mtvec, t0                 # direct mode
    li      s1, 0                     # the handler's count
    lui     x0, 1                     # marker: block 1
    li      t1, 0x55
    csrw    mscratch, t1              # a CSR write ...
    ecall                             # ... and an ecall one after it
    csrr    t2, mstatus               # block 2: a CSR read of mstatus, the first instruction after the handler's mret
    lui     x0, 2                     # marker
    li      t3, 1
    bne     s1, t3, fail_count
TEST_END
fail_count:
    li      t5, 61
    j       fail

    .balign 64
handler:
    addi    s1, s1, 1
    csrr    t0, mepc
    addi    t0, t0, 4                 # past the ecall
    csrw    mepc, t0                  # block 3: a CSR write ...
    mret                              # ... and an mret one after it
TEST_HTIF
