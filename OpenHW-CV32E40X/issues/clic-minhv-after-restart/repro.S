// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the whole test clic-minhv-restart, kept as it ran (no cut-down reproducer: the window at order 28: the window holds a trap or a system instruction).
# the window: orders 12..15 of the run, the last the instruction whose timing differs (RTL 5 cycles; the documentation, read as written, gives 4)
# the window: orders 25..28 of the run, the last the instruction whose timing differs (RTL 2 cycles; the documentation, read as written, gives 1)
# the window: orders 25..28 of the run, the last the instruction whose timing differs (RTL 2 cycles; the documentation, read as written, gives 1)
# the window: orders 25..28 of the run, the last the instruction whose timing differs (RTL 2 cycles; the documentation, read as written, gives 1)
# the window: orders 25..28 of the run, the last the instruction whose timing differs (RTL 2 cycles; the documentation, read as written, gives 1)
# MARCH: rv32imc_zicsr_zifencei_zba_zbb_zbs
# XLEN: 32
#include "test.h"
#ifndef TEST_DEVICE_BASE
#define TEST_DEVICE_BASE 0x02010000
#endif
#define CSR_MTVT        0x307
    TEST_BEGIN
    la      t0, trap_entry
    csrw    mtvec, t0
    li      s0, TEST_DEVICE_BASE
    li      s2, 0
    li      s4, 0
    li      t0, 0x90000000
    csrw    CSR_MTVT, t0
    csrci   mstatus, 8
    li      t1, 20 | (100 << 8) | (1 << 16)
    sw      t1, 32(s0)
    csrsi   mstatus, 8
resume20:
    TEST    1, s4, 20
    TEST_END
    .balign 128
trap_entry:
    csrr    t0, mcause
    bltz    t0, 9f
    csrr    t1, mepc
    la      t1, vtable
    csrw    CSR_MTVT, t1
    addi    t1, t1, 80
    csrw    mepc, t1
    li      t1, 0xC0000014
    csrw    mcause, t1
    mret
9:  li      t5, 60
    j       fail
handler_v20:
    csrr    s2, mcause
    li      s4, 20
    li      t1, 20
    sw      t1, 36(s0)
    la      t1, resume20
    csrw    mepc, t1
    li      t1, 0x40000000
    not     t1, t1
    and     t0, s2, t1
    csrw    mcause, t0
    mret
    .data
    .balign 128
vtable:
    .word   trap_entry, trap_entry, trap_entry, trap_entry, trap_entry, trap_entry, trap_entry, trap_entry
    .word   trap_entry, trap_entry, trap_entry, trap_entry, trap_entry, trap_entry, trap_entry, trap_entry
    .word   trap_entry, trap_entry, trap_entry, trap_entry, handler_v20, trap_entry, trap_entry, trap_entry
    .word   trap_entry, trap_entry, trap_entry, trap_entry, trap_entry, trap_entry, trap_entry, trap_entry
    TEST_HTIF
