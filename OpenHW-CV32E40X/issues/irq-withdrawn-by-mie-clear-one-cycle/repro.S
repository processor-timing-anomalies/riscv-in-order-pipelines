// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the whole test hzk-I-toggle_mstatus_MIE_disable_0, kept as it ran (no cut-down reproducer: the window at order 39: the window accesses the test device: its line and the handler decide the cycles).
# the window: orders 36..39 of the run, the last the instruction whose timing differs (RTL 2 cycles; the documentation, read as written, gives 1)
# MARCH: rv32i_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
TEST_TRAPS
    lui x3, %hi(TEST_DEVICE_BASE)
    addi x3, x3, %lo(TEST_DEVICE_BASE)
    lui x6, 2
    lui x7, 3
    lui x28, 4
    lw x6, 24(x3)
    addi x31, x0, 2
    lui x30, 0x10
    addi x30, x30, -1
    bne x6, x31, fail
    csrrs x6, mtvec, x0
    andi x6, x6, 3
    addi x31, x0, 3
    addi x30, x30, -1
    beq x6, x31, fail
    lui x6, 0x80021
    addi x6, x6, -2040
    csrrw x0, mie, x6
    csrrsi x0, mstatus, 8
    lui x29, 5
    lui x6, 6
    lui x7, 7
    lui x0, 1
    lui x28, 8
    lui x29, 9
    lui x6, 10
    lui x8, 0x20
    addi x8, x8, 0
    lui x7, 11
    lui x28, 12
    lui x29, 13
    sw x8, 0(x3)
    csrrci x0, mstatus, 8
    lui x6, 14
    lui x7, 15
    lui x28, 16
    lui x29, 17
    lui x6, 18
    lui x7, 19
    lui x28, 20
    lui x29, 21
    lui x6, 22
    lui x7, 23
    lui x28, 24
    csrrsi x0, mstatus, 8
    lui x29, 25
    lui x6, 26
    lui x7, 27
    lui x28, 28
    lui x29, 29
    lui x6, 30
    lui x7, 31
    lui x28, 32
    lui x29, 33
    lui x6, 34
    lui x7, 35
    lui x28, 36
    lui x29, 37
    lui x6, 38
TEST_END
TEST_TRAP_EVENTS
    .section .data
    .align 12
tdata:
    .word 0
TEST_HTIF
