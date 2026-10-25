// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the whole test divisor-leading-ones, kept as it ran (no cut-down reproducer: a confirmation capture, the window 4-28 marked by hand).
# the window: orders 4-28 of the run -- seven divides, one every four retirements: the cycles each costs by its divisor (the META line after each div)
# divisor-leading-ones -- a divide's cycles by its divisor: the cycle table's "number of leading bits at 0" of
# operand b.  Signed div by 0, 1, 7, by -1, -2, 0x80000000 (negative: no leading zero), and divu by -1.
# MARCH: rv32im
#include "test.h"
    TEST_BEGIN
    .option norvc
    li      a0, 100
    li      a1, 0
    div     a2, a0, a1          # divisor 0: 32 leading zeros
    nop
    nop
    li      a1, 1
    div     a2, a0, a1          # divisor 1: 31 leading zeros
    nop
    nop
    li      a1, 7
    div     a2, a0, a1          # divisor 7: 29 leading zeros
    nop
    nop
    li      a1, -1
    div     a2, a0, a1          # divisor -1: no leading zero, 32 leading ones
    nop
    nop
    li      a1, -2
    div     a2, a0, a1          # divisor -2: 31 leading ones
    nop
    nop
    lui     a1, 0x80000
    div     a2, a0, a1          # divisor 0x80000000: 1 leading one
    nop
    nop
    li      a1, -1
    divu    a2, a0, a1          # divu by 0xffffffff: 0 leading zeros
    nop
    nop
    TEST_END
    TEST_HTIF
