// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the whole test jump-behind-divider, kept as it ran (no cut-down reproducer: a confirmation capture, the window 4-6 marked by hand).
# the window: orders 4-6 of the run -- a jal right behind a 35-cycle divide: its target (addi a5, zero, 1) retires 1 cycle after the jal, no bubble, where a jal on its own costs its target 2 cycles (orders 12-13); the divider wait hides the jump bubble
# jump-behind-divider -- a jal right behind a divide: the jump's bubble is hidden by the divider's wait.  Case A:
# a 35-cycle divide (divisor 0), then jal; case B: the same divide, then two nops, then jal; case C: jal alone.
# The cycle table charges a jump 2 cycles (its target fetched one bubble later); behind a busy divider the RTL
# redirects fetch at once, and the target retires as soon as the divide lets it, with no bubble beyond the wait.
# MARCH: rv32im_zicsr_zifencei
#include "test.h"
    TEST_BEGIN
    .option norvc
    li      a1, 7
    li      a2, 0
    div     a3, a1, a2
    jal     a4, t_a
    nop
    .balign 4
t_a:
    addi    a5, zero, 1
    div     a3, a1, a2
    nop
    nop
    jal     a4, t_b
    nop
    .balign 4
t_b:
    addi    a5, zero, 2
    jal     a4, t_c
    nop
    .balign 4
t_c:
    addi    a5, zero, 3
    nop
    TEST_END
    TEST_HTIF
