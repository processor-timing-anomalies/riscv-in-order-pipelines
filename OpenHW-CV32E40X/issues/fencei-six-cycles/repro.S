// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the whole test fencei-six-cycles, kept as it ran (no cut-down reproducer: a confirmation capture, the window 4-5 marked by hand).
# the window: orders 4-5 of the run -- a fence.i and the instruction after it: 3 and 4 cycles, 7 from the instruction before to the one after -- 6 beyond back-to-back, where the table's 5 gives 5
# fencei-six-cycles -- what the instruction after a fence.i costs: the cycle table's 5 against the RTL.
# Three fence.i's in straight-line code, each followed by a nop whose retirement is 'the instruction after'.
# MARCH: rv32i_zifencei
#include "test.h"
    TEST_BEGIN
    .option norvc
    nop
    nop
    fence.i
    nop                         # the instruction after the first fence.i
    nop
    nop
    fence.i
    nop                         # after the second
    nop
    nop
    fence.i
    nop                         # after the third
    nop
    nop
    TEST_END
    TEST_HTIF
