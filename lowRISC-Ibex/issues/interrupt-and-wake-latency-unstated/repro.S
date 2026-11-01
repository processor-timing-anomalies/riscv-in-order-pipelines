// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the whole test hze-wfi-00, kept as it ran (no cut-down reproducer: a value issue (compare), not a timing window).
# the window: orders 174..175 of the run, the last the instruction whose timing differs (RTL 6 cycles; the documentation, read as written, gives 5)
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
    lui x6, 0x20
    addi x6, x6, 0
    csrrw x0, mie, x6
    csrrsi x0, mstatus, 8
    lui x29, 5
    lui x6, 6
    lui x7, 7
    lui x0, 1
    lui x28, 8
    lui x29, 9
    lui x6, 10
    csrrci x0, mstatus, 8
    lui x8, 0x20
    addi x8, x8, 0
    lui x7, 11
    lui x28, 12
    lui x29, 13
    sw x8, 0(x3)
    wfi
    csrrsi x0, mstatus, 8
    lui x6, 14
    lui x7, 15
    lui x28, 16
    lui x29, 17
    lui x0, 2
    lui x6, 18
    lui x7, 19
    lui x28, 20
    csrrci x0, mstatus, 8
    lui x9, 0x20
    addi x9, x9, 0
    lui x29, 21
    lui x6, 22
    lui x7, 23
    sw x9, 0(x3)
    wfi
    csrrsi x0, mstatus, 8
    lui x28, 24
    lui x29, 25
    lui x6, 26
    lui x7, 27
    lui x0, 3
    lui x28, 28
    lui x29, 29
    lui x6, 30
    csrrci x0, mstatus, 8
    lui x10, 0x20
    addi x10, x10, 0
    lui x7, 31
    lui x28, 32
    lui x29, 33
    sw x10, 0(x3)
    wfi
    csrrsi x0, mstatus, 8
    lui x6, 34
    lui x7, 35
    lui x28, 36
    lui x29, 37
    lui x0, 4
    lui x6, 38
    lui x7, 39
    lui x28, 40
    csrrci x0, mstatus, 8
    lui x11, 0x20
    addi x11, x11, 0
    lui x29, 41
    lui x6, 42
    lui x7, 43
    sw x11, 0(x3)
    wfi
    csrrsi x0, mstatus, 8
    lui x28, 44
    lui x29, 45
    lui x6, 46
    lui x7, 47
    lui x0, 5
    lui x28, 48
    lui x29, 49
    lui x6, 50
    csrrci x0, mstatus, 8
    lui x12, 0x20
    addi x12, x12, 0
    lui x7, 51
    lui x28, 52
    lui x29, 53
    sw x12, 0(x3)
    wfi
    csrrsi x0, mstatus, 8
    lui x6, 54
    lui x7, 55
    lui x28, 56
    lui x29, 57
    lui x0, 6
    lui x6, 58
    lui x7, 59
    lui x28, 60
    csrrci x0, mstatus, 8
    lui x13, 0x20
    addi x13, x13, 0
    lui x29, 61
    lui x6, 62
    lui x7, 63
    sw x13, 0(x3)
    wfi
    csrrsi x0, mstatus, 8
    lui x28, 64
    lui x29, 65
    lui x6, 66
    lui x7, 67
    lui x0, 7
    lui x28, 68
    lui x29, 69
    lui x6, 70
    csrrci x0, mstatus, 8
    lui x14, 0x20
    addi x14, x14, 0
    lui x7, 71
    lui x28, 72
    lui x29, 73
    sw x14, 0(x3)
    wfi
    csrrsi x0, mstatus, 8
    lui x6, 74
    lui x7, 75
    lui x28, 76
    lui x29, 77
    lui x6, 78
    lui x7, 79
    lui x28, 80
TEST_END
TEST_TRAP_EVENTS
    .section .data
    .align 12
tdata:
    .word 0
TEST_HTIF
