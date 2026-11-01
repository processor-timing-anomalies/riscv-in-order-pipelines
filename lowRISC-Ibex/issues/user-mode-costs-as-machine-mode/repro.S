# repro.S -- the whole test u-mode-same-cost, kept as it ran (no cut-down reproducer: a confirmation capture, the window 9-21 marked by hand).
# the window: orders 9-21 of the run -- orders 9-10 in M and 20-21 in U: an add then its dependent addi, 1 cycle each in both modes; order 17 the mret into U
// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# u-mode-same-cost.S -- the reproducer of user-mode-costs-as-machine-mode, written by hand (1 Nov 2026): the same
# three-instruction block, two operands set up then an add and its dependent addi, run in M and then in U after the
# drop (mret with MPP = U).  Read the cycle counts of the two adds and the two addis: the same in both modes.  An
# ecall with a7 = 1 brings the program back to M.
# MARCH: rv32i_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
TEST_TRAPS
    lui x0, 1                         # marker
    addi t1, x0, 5
    addi t2, x0, 7
    add t3, t1, t2                    # in M
    addi t4, t3, 1                    # in M, dependent at distance 1
    lui s0, 0x2
    addi s0, s0, -0x800
    csrc mstatus, s0                  # MPP = U
    la s0, 1f
    csrw mepc, s0
    mret                              # into U
1:  addi t1, x0, 5
    addi t2, x0, 7
    add t3, t1, t2                    # in U
    addi t4, t3, 1                    # in U, dependent at distance 1
    addi a7, x0, 1
    ecall                             # back to M
    addi s1, x0, 13
    bne t4, s1, fail                  # 5 + 7 + 1 (fail: test.h's)
    lui x0, 2                         # marker
TEST_END
TEST_TRAP_RESUME
    .section .data
    .align 12
tdata:
    .word 0
TEST_HTIF
