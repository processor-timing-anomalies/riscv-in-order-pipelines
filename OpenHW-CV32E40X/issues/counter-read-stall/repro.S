// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the reproducer, cut from the test issue-counter-csr-read: the instructions of its orders 19..22 with the register and
# memory values they had, so the last one meets the same pipeline state; builds and runs on its own (Makefile).
# What the RTL did there: order 22 csrrs a2, mcycle, zero: 2 cycles after the previous retirement; the documentation, read as written, gives 1
# MARCH: rv32i_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    lui x0, 1   # marker:  aligns block 1 here
    lui x3, 0x80000                   # x3 = 0x80000060, the value x5 held at the window's start
    lui x6, 2                         # x3 = 0x80000060, the value x5 held at the window's start (quiet)
    lui x7, 3                         # x3 = 0x80000060, the value x5 held at the window's start (quiet)
    lui x28, 4                        # x3 = 0x80000060, the value x5 held at the window's start (quiet)
    addi x3, x3, 96                   # x3 = 0x80000060, the value x5 held at the window's start
    .L2: auipc x3, %pcrel_hi(.L1)     # target of the jalr at order 20 -> the instruction after it
    lui x29, 5                        # target of the jalr at order 20 -> the instruction after it (quiet)
    lui x6, 6                         # target of the jalr at order 20 -> the instruction after it (quiet)
    lui x7, 7                         # target of the jalr at order 20 -> the instruction after it (quiet)
    addi x3, x3, %pcrel_lo(.L2)       # target of the jalr at order 20 -> the instruction after it
    lui x28, 8                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 9                        # quiet
    lui x6, 10                        # quiet
    jalr x0, 0(x3)                    # order 20 of the run
.L1:
    addi x11, x0, 1                   # order 21 of the run
    csrrs x12, mcycle, x0   # order 22 of the run: the mismatching instruction, the instruction under test
    lui x7, 11                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 12                       # quiet
    lui x29, 13                       # quiet
TEST_END
    .section .data
    .align 12
tdata:
    .word 0
TEST_HTIF
