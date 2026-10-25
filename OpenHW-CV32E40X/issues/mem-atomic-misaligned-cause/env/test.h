/* Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0 */
/* test.h -- the harness for hand-coded tests in this tree.
 *
 * A test is a self-checking RV32 assembly program: every block computes a
 * value and compares it against a constant worked out by hand.  The first
 * mismatch jumps to `fail`, which reports the failing test number to the
 * host as the exit status; a clean run exits 0.
 *
 *     #include "test.h"
 *     TEST_BEGIN                  # .text.init, _start, stack
 *         li   a0, 1
 *         TEST 1, a0, 1           # test number, register, expected value
 *         ...                     # `j fail` also works from hand-written checks
 *     TEST_END                    # pass:, fail:, halt loops
 *         ... subroutines, data ...
 *     TEST_HTIF                   # the tohost/fromhost words Spike and the RTL tb watch
 *
 * Exit is by a tohost write: (exit_code << 1) | 1, so PASS is 1 and test
 * number n failing is (n << 1) | 1.  Spike's HTIF turns that into the exit
 * status; the RTL testbench (cv32e40x1) watches the store to the tohost
 * address it is given.  On RV32 the 64-bit tohost is two 32-bit stores;
 * the high word is written as zero after the low word, so Spike never
 * sees a half-written command it could act on.
 *
 * Registers: t5 holds the number of the test in flight, t6 the expected
 * value; a test must not use them as operands of the instruction under
 * test.  t0 is used by pass/fail.
 */

#ifndef TEST_H
#define TEST_H

    .equ TOHOST_PASS, 1          /* (0 << 1) | 1 */

    .macro TEST n, reg, exp
    li      t5, \n
    li      t6, \exp
    bne     \reg, t6, fail
    .endm

    .macro TEST_BEGIN
    .section .text.init
    .globl _start
_start:
    la      sp, _stack_top
    .endm

    .macro TEST_END
pass:
    la      t0, tohost
    li      t1, TOHOST_PASS
    sw      t1, 0(t0)
    sw      zero, 4(t0)
1:  j       1b

fail:
    slli    t5, t5, 1
    ori     t5, t5, 1
    la      t0, tohost
    sw      t5, 0(t0)
    sw      zero, 4(t0)
1:  j       1b
    .endm

    
    .macro TEST_TRAPS
    la      t0, trap_table
    csrw    mtvec, t0
    .endm

    .macro TEST_TRAP_HANDLER
    .balign 256
trap_table:
    .rept 32
    j       trap_handler
    .endr
trap_handler:
    csrr    t0, mcause
    andi    t0, t0, 0x3f
    ori     t0, t0, 0x40
    slli    t0, t0, 1
    ori     t0, t0, 1
    la      t1, tohost
    sw      t0, 0(t1)
    sw      zero, 4(t1)
1:  j       1b
    .endm

    
    .macro TEST_TRAP_RESUME
    .balign 256
trap_table:
    .rept 32
    j       trap_resume
    .endr
trap_resume:
    csrr    t0, mepc
    csrr    t5, mcause
    addi    t5, t5, -1
    beqz    t5, 2f
    lhu     t5, 0(t0)
    andi    t5, t5, 3
    addi    t0, t0, 2
    addi    t5, t5, -3
    bnez    t5, 1f
    addi    t0, t0, 2
1:  csrw    mepc, t0
    mret
2:  csrw    mepc, ra
    mret
    .endm

    .macro TEST_HTIF
    .section .htif, "aw", @progbits
    .align 6
    .globl tohost
tohost:
    .dword  0
    .globl fromhost
fromhost:
    .dword  0
    .endm

#endif /* TEST_H */
