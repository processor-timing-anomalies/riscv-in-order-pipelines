// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the whole test csr-mret-rows-class-based, kept as it ran (no cut-down reproducer: a confirmation capture, the window 13-14 marked by hand).
# the window: orders 13-14 of the run -- an mret one behind a csrrc of mscratch, a CSR it does not read, retires 3 cycles after it: 1 plus a stall of 2, as the manual's rows 126 and 118 word it for any CSR access; two behind (orders 22-24) 2 cycles, three behind (orders 32-35) 1
# csr-mret-rows-class-based.S -- the reproducer of csr-mret-rows-class-based, written by hand (29 Oct 2026): an mret
# one behind a csrrc of mscratch, a CSR it does not read, retires 3 cycles after it (2 more than an mret alone), and
# two behind it 2 cycles (1 more); three behind it, 1.  The interlock fires on any CSR access (the manual's rows 126
# and 118: "a CSR access instruction"), not only on mstatus and mepc, which mret reads.  Every mret returns to the
# instruction after it (mepc set just before, MPP machine), so the program runs straight through.
# MARCH: rv32i_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
    .option norelax
TEST_BEGIN
    li   x8, 0x1800                   # mstatus.MPP = machine: the mret stays in M
    csrrs x0, mstatus, x8
    addi x10, x0, 263                 # the csrrc's operand (mscratch is 0: nothing to clear)
    lui x0, 1                         # marker
    la   x9, ret1
    csrrw x0, mepc, x9                # mepc -> ret1
    lui x6, 2                         # fillers: nothing older in flight
    lui x7, 3
    lui x28, 4
    csrrc x0, mscratch, x10           # a CSR access of mscratch, which mret does not read
    mret                              # one behind it: 3 cycles (1 + a stall of 2)
ret1:
    lui x0, 2                         # marker
    la   x9, ret2
    csrrw x0, mepc, x9                # mepc -> ret2
    lui x6, 5
    lui x7, 6
    lui x28, 7
    csrrc x0, mscratch, x10
    lui x29, 8
    mret                              # two behind it: 2 cycles (1 + a stall of 1)
ret2:
    lui x0, 3                         # marker
    la   x9, ret3
    csrrw x0, mepc, x9                # mepc -> ret3
    lui x6, 9
    lui x7, 10
    lui x28, 11
    csrrc x0, mscratch, x10
    lui x29, 12
    lui x6, 13
    mret                              # three behind it: 1 cycle
ret3:
    lui x0, 4                         # marker
TEST_END
    .section .data
    .align 12
tdata:
    .word 0
TEST_HTIF
