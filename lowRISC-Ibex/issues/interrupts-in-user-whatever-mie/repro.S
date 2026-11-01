# repro.S -- the whole test u-irq-mie-clear, kept as it ran (no cut-down reproducer: the window at order 31: the window holds a trap or a system instruction; the window at order 32: the window holds a trap or a system instruction).
# the window: orders 30..31 of the run, the last the instruction whose timing differs (RTL 3 cycles; the documentation, read as written, gives 1)
# the window: orders 30..31 of the run, the last the instruction whose timing differs (RTL 3 cycles; the documentation, read as written, gives 1)
# the window: orders 31..32 of the run, the last the instruction whose timing differs (RTL 1 cycles; the documentation, read as written, gives 3)
# the window: orders 31..32 of the run, the last the instruction whose timing differs (RTL 1 cycles; the documentation, read as written, gives 3)
# the window: orders 31..32 of the run, the last the instruction whose timing differs (RTL 1 cycles; the documentation, read as written, gives 3)
# the window: orders 31..32 of the run, the last the instruction whose timing differs (RTL 1 cycles; the documentation, read as written, gives 3)
# the window: orders 31..32 of the run, the last the instruction whose timing differs (RTL 1 cycles; the documentation, read as written, gives 3)
# the window: orders 31..32 of the run, the last the instruction whose timing differs (RTL 1 cycles; the documentation, read as written, gives 3)
# the window: orders 31..32 of the run, the last the instruction whose timing differs (RTL 1 cycles; the documentation, read as written, gives 3)
// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# MARCH: rv32i_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
TEST_TRAPS
    lui x0, 1
    lui t1, 0x20
    csrw mie, t1
    lui t1, 0x2
    addi t1, t1, -0x780
    csrc mstatus, t1
    la t1, 1f
    csrw mepc, t1
    lui t2, %hi(TEST_DEVICE_BASE)
    addi t2, t2, %lo(TEST_DEVICE_BASE)
    lui t3, 0x20
    addi t4, x0, 0
    mret
1:  sw t3, 0(t2)
    addi t4, t4, 1
    addi t4, t4, 1
    addi t4, t4, 1
    addi t4, t4, 1
    addi a7, x0, 1
    ecall
    addi t1, x0, 4
    bne t4, t1, fail
    lui x0, 2
TEST_END
TEST_TRAP_EVENTS
    .section .data
    .align 12
tdata:
    .word 0
TEST_HTIF
