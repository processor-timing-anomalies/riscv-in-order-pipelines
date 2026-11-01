# repro.S -- the whole test pmp-fault-cycles, kept as it ran (no cut-down reproducer: the window at order 26: the window holds a trap or a system instruction).
# the window: orders 23..25 of the run, the last the instruction whose timing differs (RTL 2 cycles; the documentation, read as written, gives 1)
# the window: orders 24..26 of the run, the last the instruction whose timing differs (RTL 4 cycles; the documentation, read as written, gives 5)
# the window: orders 24..26 of the run, the last the instruction whose timing differs (RTL 4 cycles; the documentation, read as written, gives 5)
// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# pmp-fault-cycles.S -- the reproducer of pmp-fault-two-cycles and pmp-fault-wb-entry-four-cycles, written by hand
# (1 Nov 2026): a word-aligned load the PMP refuses.  Region 0 is a locked NA4 over `word` with no permission (a locked
# region binds M), mseccfg.MMWP is set (so M needs a match: region 15 is NAPOT over everything, RWX, unlocked, and matches for M).  The lw is held
# two cycles in the LSU and then faults from the writeback stage with no bus request; its handler's first instruction
# (the table's jump at mtvec) retires four cycles after the trap entry.  Read the cycle counts on the lw's retirement
# and on the handler's first retirement.
# MARCH: rv32i_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
TEST_TRAPS
    lui x0, 1                         # marker
    addi t1, x0, 4
    csrw 0x747, t1                    # mseccfg.RLB, before any region
    la t2, word
    srli t3, t2, 2
    csrw pmpaddr0, t3                 # region 0 over `word`
    addi t1, x0, -112
    csrw pmpcfg0, t1                  # region 0: 0x90, locked NA4, no R, no W, no X (a locked region binds M)
    addi t1, x0, -1
    csrw pmpaddr15, t1                # region 15: NAPOT over everything
    lui t1, 0x1f000
    csrw pmpcfg3, t1                  # region 15: NAPOT, RWX, unlocked
    addi t1, x0, 6
    csrw 0x747, t1                    # mseccfg.MMWP with RLB: M needs a match
    addi t4, x0, 0
    lui s1, 1                         # three fillers behind the CSR write, as the suite's blocks have (its flush)
    lui s1, 2
    lui s1, 3
    lw s0, 0(t2)                      # refused by region 0: the fault two cycles after the request, no bus transaction
    addi t4, t4, 1                    # resumed here by the handler's mret
    addi t3, x0, 1
    bne t4, t3, fail                  # the handler resumed behind the lw (fail: test.h's)
    lui x0, 2                         # marker
TEST_END
TEST_TRAP_RESUME
    .section .data
    .align 12
tdata:
word:
    .word 0x11223344
TEST_HTIF
