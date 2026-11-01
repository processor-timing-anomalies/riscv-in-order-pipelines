// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the whole test nmi-taken-kill, kept as it ran (no cut-down reproducer: a confirmation capture, the window 31-33 marked by hand).
# the window: orders 31-33 of the run -- the store at order 31 asks the test device for a bus error on the next load; the load at order 32 retires with it (1 cycle); nothing retires while the NMI is pending; order 33 is the handler's first retirement, 5 cycles after the load, mcause 0x80000400, and the instruction behind the load is killed and runs again after the handler's mret (order 43); with a second load right behind the faulting one (orders 49-52) that load retires too, its request already out, and the handler follows 5 cycles after it
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
    la x19, w0
    la x22, w1
    la x24, w2
    addi x17, x0, 0
    addi x18, x0, 1041
    addi x21, x0, 1055
    addi x23, x0, 1069
    lui x0, 1
    lui x6, 2
    lui x7, 3
    lui x28, 4
    sw x17, 8(x16)
    lw x18, 0(x19)
    lui x29, 5
    lui x6, 6
    lui x0, 2
    lui x7, 7
    lui x28, 8
    lui x29, 9
    sw x17, 8(x16)
    lw x21, 0(x22)
    lw x23, 0(x24)
    lui x6, 10
    lui x7, 11
    lui x0, 3
TEST_END
TEST_TRAP_EVENTS
    .section .data
    .align 12
tdata:
w0: .word 0x40a
w1: .word 0x418
w2: .word 0x426
    .word 0
TEST_HTIF
