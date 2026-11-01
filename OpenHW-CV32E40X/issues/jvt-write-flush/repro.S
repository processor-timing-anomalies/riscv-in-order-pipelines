// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the whole test jvt-write-flush, kept as it ran (no cut-down reproducer: a confirmation capture, the window 26-27 marked by hand).
# the window: orders 26-27 of the run -- a write of jvt (order 26) retires in 1 cycle and the instruction behind it 5 cycles later: the write flushes and refetches what follows, the table's 4 (jvt); behind a write of mscratch (orders 32-33) the next instruction follows in 1; with the interrupt line 17 raised right before the write (orders 38-40) the handler's first instruction retires 6 cycles after the jvt write, against 5 after a write of mscratch (orders 55-57)
# MARCH: rv32i_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
    .option norelax
TEST_BEGIN
TEST_TRAPS
    lui x16, %hi(TEST_DEVICE_BASE)
    addi x16, x16, %lo(TEST_DEVICE_BASE)
    lw x6, 24(x16)
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
    csrrw x0, mie, x6
    csrrsi x0, mstatus, 8
    lui x18, 0x11
    lui x17, 0x20
    lui x0, 1
    lui x6, 2
    lui x7, 3
    lui x28, 4
    csrrw x0, 0x017, x18
    lui x29, 5
    lui x0, 2
    lui x6, 6
    lui x7, 7
    lui x28, 8
    csrrw x0, mscratch, x18
    lui x29, 9
    lui x0, 3
    lui x6, 10
    lui x7, 11
    lui x28, 12
    sw x17, 0(x16)
    csrrw x0, 0x017, x18
    lui x29, 13
    lui x0, 4
    lui x6, 14
    lui x7, 15
    lui x28, 16
    sw x17, 0(x16)
    csrrw x0, mscratch, x18
    lui x29, 17
    lui x0, 5
TEST_END
TEST_TRAP_EVENTS
    .section .data
    .align 12
tdata:
    .word 0
TEST_HTIF
