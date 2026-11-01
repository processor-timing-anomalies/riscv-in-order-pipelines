# repro.S -- the whole test pmp-split-store-half, kept as it ran (no cut-down reproducer: the window at order 16: the window holds a trap or a system instruction; the window at order 17: the window holds a trap or a system instruction).
# the window: orders 14..16 of the run, the last the instruction whose timing differs (RTL 3 cycles; the documentation, read as written, gives 2)
# the window: orders 14..16 of the run, the last the instruction whose timing differs (RTL 3 cycles; the documentation, read as written, gives 2)
# the window: orders 15..17 of the run, the last the instruction whose timing differs (RTL 4 cycles; the documentation, read as written, gives 5)
# the window: orders 15..17 of the run, the last the instruction whose timing differs (RTL 4 cycles; the documentation, read as written, gives 5)
// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# pmp-split-store-half.S -- the reproducer of pmp-misaligned-store-second-half-written, written by hand (1 Nov 2026):
# a misaligned store that the PMP refuses on its first half.  Region 0 is NA4 over `w0`, locked, read-only (a locked
# region binds M), and `w1`, the next word, has no region (allowed for M).  sw of 0xAABBCCDD at w0 + 2 splits into
# two transactions: the first (bytes 2 and 3 of w0) is refused and the store faults; the core still writes the second
# (bytes 0 and 1 of w1), so the load of w1 after the handler's return reads 0x0000AABB where the architecture says
# w1 is untouched (the reference reads 0).  Read s0 on the lw.
# MARCH: rv32i_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
TEST_TRAPS
    lui x0, 1                         # marker
    la t2, w0
    srli t3, t2, 2
    csrw pmpaddr0, t3                 # region 0 over w0
    addi t1, x0, 0x91
    csrw pmpcfg0, t1                  # region 0: NA4, locked, R only
    lui t4, 0xaabbd
    addi t4, t4, -0x323               # 0xAABBCCDD
    addi s1, x0, 0
    sw t4, 2(t2)                      # misaligned across w0 / w1: the first half refused, the store faults
    addi s1, s1, 1                    # resumed here by the handler
    lw s0, 4(t2)                      # w1: 0x0000AABB on the core, 0 by the architecture
    lui x0, 2                         # marker
TEST_END
TEST_TRAP_RESUME
    .section .data
    .align 12
tdata:
w0:
    .word 0
w1:
    .word 0
TEST_HTIF
