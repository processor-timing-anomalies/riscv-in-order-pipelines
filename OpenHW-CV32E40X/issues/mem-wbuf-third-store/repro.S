// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the whole test mem-wbuf-third-store, kept as it ran (no cut-down reproducer: a confirmation capture, the window 24-27 marked by hand).
# the window: orders 24-27 of the run -- three bufferable stores behind a 4-cycle mulh, under the bus schedule published beside the program (repro.sched.json): the first (request 1, its grant withheld one cycle) and the second (request 2, granted at once) retire 1 cycle each, the third, the sb (request 3, its grant withheld two cycles), 2 cycles where the write-buffer rule gives 1: the buffer's transfer still holds the last outstanding slot of the response filter; the lb behind it (request 4, its grant withheld three cycles) 6 cycles, the lb after it 1
# mem-wbuf-third-store.S -- the reproducer of mem-wbuf-third-store, written by hand (29 Oct 2026), for the PMA build,
# whose main memory is bufferable, under the data bus schedule of the file beside this one: the first store's grant
# withheld one cycle, the second's given at once, the third's withheld two cycles, the first load's three.  Three
# bufferable stores in a row behind a 4-cycle mulh: the first two retire 1 cycle each, the third (sb) 2 cycles where
# the write buffer gives 1, because the buffer's transfer still holds the last outstanding slot; the load behind it 6.
# MARCH: rv32im
# XLEN: 32
#include "test.h"
    .option norvc
    .option norelax
TEST_BEGIN
    addi x3, x0, 294                  # mulh's operands
    addi x8, x0, 301
    addi x27, x0, 308                 # mulh's rd before
    la   x9, w0                       # the first store's address
    addi x10, x0, 0                   # its data
    la   x11, w1                      # the second store's address
    addi x12, x0, 329
    la   x13, w2                      # the third store's address
    addi x14, x0, 343
    la   x16, w0                      # the loads' addresses
    addi x15, x0, 350                 # the loads' rd before
    la   x18, w1
    addi x17, x0, 357
    lui x0, 1                         # marker
    lui x29, 2                        # fillers: nothing older in flight
    lui x6, 3
    lui x7, 4
    mulh x27, x3, x8                  # 4 cycles
    sw   x10, 0(x9)                   # request 1, its grant withheld one cycle: 1 cycle
    sw   x12, 0(x11)                  # request 2, granted at once: 1 cycle
    sb   x14, 0(x13)                  # request 3, its grant withheld two cycles: 2 cycles where the write buffer gives 1
    lb   x15, 0(x16)                  # request 4, its grant withheld three cycles: 6 cycles
    lb   x17, 0(x18)                  # request 5
    lui x0, 2                         # marker
TEST_END
    .section .data
    .align 12
tdata:
w0: .word 0
w1: .word 0
w2: .word 0
    .word 0
TEST_HTIF
