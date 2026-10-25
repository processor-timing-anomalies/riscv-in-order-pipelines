// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro-2.S -- the reproducer, cut from the test hz-Zalrsc-sc.w-zalrsc-00: the instructions of its orders 4971..4974 with the register and
# memory values they had, so the last one meets the same pipeline state; builds and runs on its own (Makefile).
# What the RTL did there: order 4974 sc.w s9, s0, (gp): 2 cycles after the previous retirement; the documentation, read as written, gives 1
# MARCH: rv32ia
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    lui x0, 1   # marker:  aligns block 1 here
    lui x25, 0x80008                  # x25 = 0x80008404, the value it held at the window's start
    lui x6, 2                         # x25 = 0x80008404, the value it held at the window's start (quiet)
    lui x7, 3                         # x25 = 0x80008404, the value it held at the window's start (quiet)
    lui x28, 4                        # x25 = 0x80008404, the value it held at the window's start (quiet)
    addi x25, x25, 1028               # x25 = 0x80008404, the value it held at the window's start
    addi x27, x0, 1528                # x27 = 0x5f8, the value it held at the window's start
    lui x3, 0x80008                   # x3 = 0x80008408, the value it held at the window's start
    lui x29, 5                        # x3 = 0x80008408, the value it held at the window's start (quiet)
    lui x6, 6                         # x3 = 0x80008408, the value it held at the window's start (quiet)
    lui x7, 7                         # x3 = 0x80008408, the value it held at the window's start (quiet)
    addi x3, x3, 1032                 # x3 = 0x80008408, the value it held at the window's start
    addi x8, x0, -1                   # x8 = 0xffffffff, the value it held at the window's start
    .L1: auipc x25, %pcrel_hi(w0)     # base of the sc.w at order 4973 -> w0, a scratch word
    lui x28, 8                        # base of the sc.w at order 4973 -> w0, a scratch word (quiet)
    lui x29, 9                        # base of the sc.w at order 4973 -> w0, a scratch word (quiet)
    lui x6, 10                        # base of the sc.w at order 4973 -> w0, a scratch word (quiet)
    addi x25, x25, %pcrel_lo(.L1)     # base of the sc.w at order 4973 -> w0, a scratch word
    .L2: auipc x3, %pcrel_hi(w1)      # base of the sc.w at order 4974 -> w1, a scratch word
    lui x7, 11                        # base of the sc.w at order 4974 -> w1, a scratch word (quiet)
    lui x28, 12                       # base of the sc.w at order 4974 -> w1, a scratch word (quiet)
    lui x29, 13                       # base of the sc.w at order 4974 -> w1, a scratch word (quiet)
    addi x3, x3, %pcrel_lo(.L2)       # base of the sc.w at order 4974 -> w1, a scratch word
    lui x6, 14                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 15                        # quiet
    lui x28, 16                       # quiet
    sc.w x26, x27, (x25)              # order 4973 of the run
    sc.w x25, x8, (x3)   # order 4974 of the run: the mismatching instruction, the instruction under test
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
