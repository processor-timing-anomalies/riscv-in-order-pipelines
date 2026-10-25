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

    
    .macro TEST_TRAP_EVENTS
    .option push
    .option norvc
    .balign 256
trap_table:
    .rept 32
    j       trap_events
    .endr
    .option pop
trap_events:
    csrr    t0, mcause
    bgez    t0, 3f
    andi    t0, t0, 0xff
    addi    t5, x0, 1
    sll     t5, t5, t0
    lui     t0, %hi(TEST_DEVICE_BASE)
    addi    t0, t0, %lo(TEST_DEVICE_BASE)
    sw      t5, 4(t0)
    mret
3:  csrr    t0, mepc
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

    
    .macro TEST_TRAP_EVENTS_NESTED outer
    .option push
    .option norvc
    .balign 256
trap_table:
    .rept 32
    j       trap_events
    .endr
    .option pop
trap_events:
    csrr    t0, mcause
    bgez    t0, 3f
    andi    t0, t0, 0xff
    addi    t5, x0, 1
    sll     t5, t5, t0
    lui     t0, %hi(TEST_DEVICE_BASE)
    addi    t0, t0, %lo(TEST_DEVICE_BASE)
    sw      t5, 4(t0)
    csrr    t0, mcause
    andi    t0, t0, 0xff
    addi    t5, x0, \outer
    bne     t0, t5, 4f
    csrr    t5, mscratch
    lui     t0, %hi(TEST_DEVICE_BASE)
    addi    t0, t0, %lo(TEST_DEVICE_BASE)
    sw      t5, 16(t0)
    csrr    t0, mepc
    csrw    mscratch, t0
    csrrsi  x0, mstatus, 8
    nop
    nop
    nop
    csrrci  x0, mstatus, 8
    csrr    t0, mscratch
    csrw    mepc, t0
4:  mret
3:  csrr    t0, mepc
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

    
    .macro TEST_TRAP_EVENTS_CLIC_ENTRY
    .option push
    .option norvc
    .balign 128
trap_table:
    j       trap_events
    .option pop
    .endm

    .macro TEST_TRAP_EVENTS_CLIC_TAIL
3:  csrr    t0, mepc
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
clic_sub:
    csrr    t0, mcause
    andi    t0, t0, 0x7ff
    lui     t5, %hi(TEST_DEVICE_BASE)
    addi    t5, t5, %lo(TEST_DEVICE_BASE)
    sw      t0, 36(t5)
    ret
    .section .data
    .balign 128
clic_vtable:
    .rept 16
    .word   trap_events
    .endr
    .rept 16
    .word   clic_sub
    .endr
    .previous
    .endm

    .macro TEST_TRAP_EVENTS_CLIC
    TEST_TRAP_EVENTS_CLIC_ENTRY
trap_events:
    csrr    t0, mcause
    bgez    t0, 3f
    csrr    t0, 0xFB1
    csrr    t0, mcause
    andi    t0, t0, 0x7ff
    lui     t5, %hi(TEST_DEVICE_BASE)
    addi    t5, t5, %lo(TEST_DEVICE_BASE)
    sw      t0, 36(t5)
    mret
    TEST_TRAP_EVENTS_CLIC_TAIL
    .endm

    /* TEST_TRAP_EVENTS_CLIC_NESTED outer: the id `outer`'s handler arms the second event with the CLIC_ARM word the
       block left in mscratch, saves mepc and mcause in memory (clic_save: a nested entry overwrites both CSRs and the
       nested handler clobbers t0 and t5; mcause's mpil is this level), opens the window (mstatus.MIE) for four
       retirements, closes it, restores both and returns; a pre-empting id (a level above this one) lands in the
       window, a lower one waits for the mret.  Retirements after the ARM store: lui 1, addi 2, csrr mepc 3, sw 4,
       csrr mcause 5, sw 6, csrrsi 7, the nops 8-10, csrrci 11. */
    .macro TEST_TRAP_EVENTS_CLIC_NESTED outer
    TEST_TRAP_EVENTS_CLIC_ENTRY
trap_events:
    csrr    t0, mcause
    bgez    t0, 3f
    csrr    t0, 0xFB1
    csrr    t0, mcause
    andi    t0, t0, 0x7ff
    lui     t5, %hi(TEST_DEVICE_BASE)
    addi    t5, t5, %lo(TEST_DEVICE_BASE)
    sw      t0, 36(t5)
    addi    t5, x0, \outer
    bne     t0, t5, 4f
    csrr    t5, mscratch
    lui     t0, %hi(TEST_DEVICE_BASE)
    addi    t0, t0, %lo(TEST_DEVICE_BASE)
    sw      t5, 40(t0)
    lui     t5, %hi(clic_save)
    addi    t5, t5, %lo(clic_save)
    csrr    t0, mepc
    sw      t0, 0(t5)
    csrr    t0, mcause
    sw      t0, 4(t5)
    csrrsi  x0, mstatus, 8
    nop
    nop
    nop
    csrrci  x0, mstatus, 8
    lui     t5, %hi(clic_save)
    addi    t5, t5, %lo(clic_save)
    lw      t0, 0(t5)
    csrw    mepc, t0
    lw      t0, 4(t5)
    csrw    mcause, t0
4:  mret
    TEST_TRAP_EVENTS_CLIC_TAIL
    .section .data
    .balign 8
clic_save:
    .word   0, 0
    .previous
    .endm

    /* TEST_TRAP_EVENTS_CLIC_MNXTI: after the clear, the handler services every further pending non-vectored id above
       its level through mnxti (csrrsi mnxti, MIE: the table entry's address, else 0), calling clic_sub for each, then
       closes MIE and returns: one entry for several ids. */
    .macro TEST_TRAP_EVENTS_CLIC_MNXTI
    TEST_TRAP_EVENTS_CLIC_ENTRY
trap_events:
    csrr    t0, mcause
    bgez    t0, 3f
    csrr    t0, 0xFB1
    csrr    t0, mcause
    andi    t0, t0, 0x7ff
    lui     t5, %hi(TEST_DEVICE_BASE)
    addi    t5, t5, %lo(TEST_DEVICE_BASE)
    sw      t0, 36(t5)
5:  csrrsi  t0, 0x345, 8
    beqz    t0, 4f
    lw      t0, 0(t0)
    jalr    t0
    j       5b
4:  csrrci  x0, mstatus, 8
    mret
    TEST_TRAP_EVENTS_CLIC_TAIL
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
