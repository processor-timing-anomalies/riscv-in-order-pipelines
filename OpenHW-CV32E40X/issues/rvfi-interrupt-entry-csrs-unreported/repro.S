// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the whole test eventdevice-smoke, kept as it ran (no cut-down reproducer: a confirmation capture, the window 24-25 marked by hand).
# the window: orders 24-25 of the run -- the first interrupt entry: order 24 is the last retirement before it, order 25 the handler's first (csrrs s2, mcause; rvfi_intr set, mcause 0x80000011); the RTL's RVFI reports no CSR write for the entry's mstatus, mepc and mcause, while a reference ISS reports all three
# MARCH: rv32imc_zicsr_zifencei_zba_zbb_zbs
# XLEN: 32
#include "test.h"
#ifndef TEST_DEVICE_BASE
#define TEST_DEVICE_BASE 0x02010000
#endif
    TEST_BEGIN
    la      t0, trap_table
    csrw    mtvec, t0
    li      s0, TEST_DEVICE_BASE
    li      s1, 0
    li      s2, 0
    li      s3, 0
    li      s4, 0
    lw      t1, 24(s0)
    TEST    1, t1, 2
    csrr    t1, mtvec
    andi    t1, t1, 3
    TEST    2, t1, 0
    li      t1, 1 << 17
    csrw    mie, t1
    csrsi   mstatus, 8
    sw      t1, 0(s0)
    nop
    nop
    TEST    3, s1, 1
    li      t6, 0x80000011
    TEST    4, s2, 0x80000011
    lw      t1, 12(s0)
    TEST    5, t1, 0
    li      t1, (1 << 17) | (1 << 16)
    csrw    mie, t1
    li      s1, 0
    li      t1, (3 << 8) | 16
    sw      t1, 16(s0)
    addi    a0, a0, 1
    addi    a0, a0, 1
    addi    a0, a0, 1
    addi    a0, a0, 1
    TEST    6, s1, 1
    TEST    7, s2, 0x80000010
    lw      t1, 16(s0)
    TEST    8, t1, 0
    lw      t1, 20(s0)
    lw      t2, 20(s0)
    sub     t2, t2, t1
    TEST    9, t2, 1
    li      s1, 0
    li      s3, 0
    li      t1, (1 << 17) | (1 << 16)
    sw      t1, 0(s0)
    nop
    nop
    nop
    TEST    10, s1, 2
    TEST    11, s3, 0x1110
    csrw    mie, zero
    li      t1, 1 << 16
    sw      t1, 0(s0)
    li      t1, (2 << 8) | (32 + 16)
    sw      t1, 16(s0)
    lw      t1, 12(s0)
    addi    a0, a0, 1
    nop
    nop
    lw      t2, 12(s0)
    TEST    12, t1, 1 << 16
    TEST    13, t2, 0
    li      s1, 0
    li      t1, 1
    sw      t1, 8(s0)
    la      t3, scratch
    sw      a0, 0(t3)
    nop
    nop
    nop
    TEST    14, s1, 1
    TEST    15, s2, 0x80000401
    la      t0, trap_table
    ori     t0, t0, 1
    csrw    mtvec, t0
    li      s1, 0
    sw      zero, 8(s0)
    lw      a0, 0(t3)
    nop
    nop
    nop
    TEST    16, s2, 0x80000400
    TEST    17, s4, 15
    TEST_END
    .option push
    .option norvc
    .balign 256
trap_table:
    .rept 15
    j       handler
    .endr
    j       handler15
    .rept 16
    j       handler
    .endr
    .option pop
handler15:
    li      s4, 15
handler:
    csrr    s2, mcause
    addi    s1, s1, 1
    slli    s3, s3, 8
    andi    t0, s2, 0xff
    or      s3, s3, t0
    li      t1, 1
    sll     t1, t1, t0
    sw      t1, 4(s0)
    mret
    .data
    .balign 4
scratch:
    .word   0
    TEST_HTIF
