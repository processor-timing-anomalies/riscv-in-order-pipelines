// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro-3.S -- the reproducer, cut from the test hz-Zalrsc-sc.w-zalrsc-00: the instructions of its orders 6345..6348 with the register and
# memory values they had, so the last one meets the same pipeline state; builds and runs on its own (Makefile).
# What the RTL did there: order 6348 sc.w s3, s6, (s5): 2 cycles after the previous retirement; the documentation, read as written, gives 1
# MARCH: rv32ia
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    lui x0, 1   # marker:  aligns block 1 here
    lui x20, 0x80008                  # x20 = 0x8000853c, the value it held at the window's start
    lui x6, 2                         # x20 = 0x8000853c, the value it held at the window's start (quiet)
    lui x7, 3                         # x20 = 0x8000853c, the value it held at the window's start (quiet)
    lui x28, 4                        # x20 = 0x8000853c, the value it held at the window's start (quiet)
    addi x20, x20, 1340               # x20 = 0x8000853c, the value it held at the window's start
    lui x21, 0x80008                  # x21 = 0x80008540, the value it held at the window's start
    lui x29, 5                        # x21 = 0x80008540, the value it held at the window's start (quiet)
    lui x6, 6                         # x21 = 0x80008540, the value it held at the window's start (quiet)
    lui x7, 7                         # x21 = 0x80008540, the value it held at the window's start (quiet)
    addi x21, x21, 1344               # x21 = 0x80008540, the value it held at the window's start
    addi x22, x0, 2                   # x22 = 0x2, the value it held at the window's start
    .L1: auipc x20, %pcrel_hi(w0)     # base of the lb at order 6347 -> w0, the word it loaded (0x21)
    lui x28, 8                        # base of the lb at order 6347 -> w0, the word it loaded (0x21) (quiet)
    lui x29, 9                        # base of the lb at order 6347 -> w0, the word it loaded (0x21) (quiet)
    lui x6, 10                        # base of the lb at order 6347 -> w0, the word it loaded (0x21) (quiet)
    addi x20, x20, %pcrel_lo(.L1)     # base of the lb at order 6347 -> w0, the word it loaded (0x21)
    .L2: auipc x21, %pcrel_hi(w1)     # base of the sc.w at order 6348 -> w1, a scratch word
    lui x7, 11                        # base of the sc.w at order 6348 -> w1, a scratch word (quiet)
    lui x28, 12                       # base of the sc.w at order 6348 -> w1, a scratch word (quiet)
    lui x29, 13                       # base of the sc.w at order 6348 -> w1, a scratch word (quiet)
    addi x21, x21, %pcrel_lo(.L2)     # base of the sc.w at order 6348 -> w1, a scratch word
    lui x6, 14                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 15                        # quiet
    lui x28, 16                       # quiet
    lb x19, 0(x20)                    # order 6347 of the run
    sc.w x19, x22, (x21)   # order 6348 of the run: the mismatching instruction, the instruction under test
    lui x29, 17                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 18                        # quiet
    lui x7, 19                        # quiet
TEST_END
    .section .data
    .align 12
tdata:
w0: .word 0x21
w1: .word 0x0
    .word 0
TEST_HTIF
