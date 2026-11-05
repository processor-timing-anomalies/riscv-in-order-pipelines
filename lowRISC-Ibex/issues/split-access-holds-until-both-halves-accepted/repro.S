# repro.S -- the whole test split-access-hold, kept as it ran (no cut-down reproducer: a confirmation capture, the window 9-10 marked by hand).
# the window: orders 9-10 of the run -- the misaligned store (order 9) and the misaligned load (order 10) each take 4 cycles under a data bus that withholds every grant one cycle, where the manual gives a misaligned access at least two: each holds ID/EX until its second half is accepted and its first half's response is on the wire
// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# split-access-hold.S -- the reproducer of split-access-holds-until-both-halves-accepted, written by hand (5 Nov 2026):
# a store and a load misaligned across two words, each split by the LSU into two transactions, under a data bus that
# withholds every grant one cycle.  The manual gives a misaligned access at least two cycles; here each holds ID/EX
# until the second half's request is accepted and the first half's response is on the wire.  Read t3 at the end.
# MARCH: rv32i_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    lui x0, 1                         # marker
    la t2, w0
    lui t4, 0xaabbd
    addi t4, t4, -0x323               # 0xAABBCCDD
    sw t4, 2(t2)                      # misaligned across w0 / w1: two transactions
    lw t3, 2(t2)                      # misaligned: two transactions
    lui x0, 2                         # marker
    TEST 1, t3, 0xAABBCCDD
TEST_END
    .section .data
    .align 12
tdata:
w0:
    .word 0
w1:
    .word 0
TEST_HTIF
