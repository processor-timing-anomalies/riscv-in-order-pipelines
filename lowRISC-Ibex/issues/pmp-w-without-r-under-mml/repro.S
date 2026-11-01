# repro.S -- the whole test pmp-w-without-r-mml, kept as it ran (no cut-down reproducer: a confirmation capture, the window 11-25 marked by hand).
# the window: orders 11-25 of the run -- orders 11-12: pmpcfg0 written 0x12 (NA4, W = 1, R = 0) with MML clear reads back 0x10, W cleared; orders 24-25: the same write with MML set reads back 0x12, the shared-region encoding kept
// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# pmp-w-without-r-mml.S -- the reproducer of pmp-w-without-r-under-mml, written by hand (1 Nov 2026): a pmpcfg byte
# written with W = 1 and R = 0.  With mseccfg.MML clear the core stores W = 0 (the manual's rule); with MML set it
# stores the byte as written, since Smepmp gives W = 1, R = 0 the shared-region meanings.  Read pmpcfg0 back in s0
# (MML clear) and s1 (MML set).  Before MML is set, region 14 is the code, locked R X, and region 15 the data, locked
# R W, so M keeps executing and storing under lockdown.
# MARCH: rv32i_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    lui x0, 1                         # marker
    addi t1, x0, 4
    csrw 0x747, t1                    # mseccfg.RLB
    la t2, word
    srli t3, t2, 2
    csrw pmpaddr0, t3                 # region 0 over `word`
    addi t1, x0, 0x12
    csrw pmpcfg0, t1                  # region 0: NA4, W = 1, R = 0, under MML clear
    csrr s0, pmpcfg0                  # s0: the byte as stored (W cleared: 0x10)
    la t1, tdata
    srli t1, t1, 2
    csrw pmpaddr14, t1                # region 14: TOR [0, tdata): the code
    addi t1, x0, -1
    csrw pmpaddr15, t1                # region 15: TOR [tdata, top): the data
    lui t1, 0x8b8d0
    csrw pmpcfg3, t1                  # 14 locked TOR R X (M executes under lockdown), 15 locked TOR R W (M's data)
    addi t1, x0, 5
    csrw 0x747, t1                    # mseccfg.MML with RLB
    addi t1, x0, 0x12
    csrw pmpcfg0, t1                  # region 0: the same byte, under MML
    csrr s1, pmpcfg0                  # s1: the byte as stored (kept: 0x12, a shared data region)
    lui x0, 2                         # marker
TEST_END
    .section .data
    .align 12
tdata:
word:
    .word 0x11223344
TEST_HTIF
