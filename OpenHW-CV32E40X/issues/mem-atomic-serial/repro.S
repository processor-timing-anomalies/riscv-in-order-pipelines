// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the reproducer, cut from the test hz-Zalrsc-sc.w-zalrsc-00: the instructions of its orders 4348..4351 with the register and
# memory values they had, so the last one meets the same pipeline state; builds and runs on its own (Makefile).
# What the RTL did there: order 4351 sb zero, 0(a1): 2 cycles after the previous retirement; the documentation, read as written, gives 1
# MARCH: rv32ia
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    lui x0, 1   # marker:  aligns block 1 here
    lui x12, 0x80008                  # x12 = 0x80008370, the value it held at the window's start
    lui x6, 2                         # x12 = 0x80008370, the value it held at the window's start (quiet)
    lui x7, 3                         # x12 = 0x80008370, the value it held at the window's start (quiet)
    lui x28, 4                        # x12 = 0x80008370, the value it held at the window's start (quiet)
    addi x12, x12, 880                # x12 = 0x80008370, the value it held at the window's start
    addi x13, x0, 548                 # x13 = 0x224, the value it held at the window's start
    lui x11, 0x80008                  # x11 = 0x8000836c, the value it held at the window's start
    lui x29, 5                        # x11 = 0x8000836c, the value it held at the window's start (quiet)
    lui x6, 6                         # x11 = 0x8000836c, the value it held at the window's start (quiet)
    lui x7, 7                         # x11 = 0x8000836c, the value it held at the window's start (quiet)
    addi x11, x11, 876                # x11 = 0x8000836c, the value it held at the window's start
    .L1: auipc x12, %pcrel_hi(w0)     # base of the sc.w at order 4350 -> w0, a scratch word
    lui x28, 8                        # base of the sc.w at order 4350 -> w0, a scratch word (quiet)
    lui x29, 9                        # base of the sc.w at order 4350 -> w0, a scratch word (quiet)
    lui x6, 10                        # base of the sc.w at order 4350 -> w0, a scratch word (quiet)
    addi x12, x12, %pcrel_lo(.L1)     # base of the sc.w at order 4350 -> w0, a scratch word
    .L2: auipc x11, %pcrel_hi(w1)     # base of the sb at order 4351 -> w1, a scratch word
    lui x7, 11                        # base of the sb at order 4351 -> w1, a scratch word (quiet)
    lui x28, 12                       # base of the sb at order 4351 -> w1, a scratch word (quiet)
    lui x29, 13                       # base of the sb at order 4351 -> w1, a scratch word (quiet)
    addi x11, x11, %pcrel_lo(.L2)     # base of the sb at order 4351 -> w1, a scratch word
    lui x6, 14                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 15                        # quiet
    lui x28, 16                       # quiet
    sc.w x0, x13, (x12)               # order 4350 of the run
    sb x0, 0(x11)   # order 4351 of the run: the mismatching instruction, the instruction under test
    lui x29, 17                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 18                        # quiet
    lui x7, 19                        # quiet
TEST_END
    .section .data
    .align 12
tdata:
w0: .word 0x0
w1: .word 0x0
    .word 0
TEST_HTIF
