// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro-1.S -- the reproducer, cut from the test hz-Zalrsc-sc.w-zalrsc-00: the instructions of its orders 4895..4898 with the register and
# memory values they had, so the last one meets the same pipeline state; builds and runs on its own (Makefile).
# What the RTL did there: order 4898 lb a3, 0(a6): 2 cycles after the previous retirement; the documentation, read as written, gives 1
# MARCH: rv32ia
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    lui x0, 1   # marker:  aligns block 1 here
    lui x13, 0x80008                  # x13 = 0x800083ec, the value it held at the window's start
    lui x6, 2                         # x13 = 0x800083ec, the value it held at the window's start (quiet)
    lui x7, 3                         # x13 = 0x800083ec, the value it held at the window's start (quiet)
    lui x28, 4                        # x13 = 0x800083ec, the value it held at the window's start (quiet)
    addi x13, x13, 1004               # x13 = 0x800083ec, the value it held at the window's start
    addi x15, x0, 2                   # x15 = 0x2, the value it held at the window's start
    lui x16, 0x80008                  # x16 = 0x800083f0, the value it held at the window's start
    lui x29, 5                        # x16 = 0x800083f0, the value it held at the window's start (quiet)
    lui x6, 6                         # x16 = 0x800083f0, the value it held at the window's start (quiet)
    lui x7, 7                         # x16 = 0x800083f0, the value it held at the window's start (quiet)
    addi x16, x16, 1008               # x16 = 0x800083f0, the value it held at the window's start
    .L1: auipc x13, %pcrel_hi(w0)     # base of the sc.w at order 4897 -> w0, a scratch word
    lui x28, 8                        # base of the sc.w at order 4897 -> w0, a scratch word (quiet)
    lui x29, 9                        # base of the sc.w at order 4897 -> w0, a scratch word (quiet)
    lui x6, 10                        # base of the sc.w at order 4897 -> w0, a scratch word (quiet)
    addi x13, x13, %pcrel_lo(.L1)     # base of the sc.w at order 4897 -> w0, a scratch word
    .L2: auipc x16, %pcrel_hi(w1)     # base of the lb at order 4898 -> w1, the word it loaded (0xffffffb2)
    lui x7, 11                        # base of the lb at order 4898 -> w1, the word it loaded (0xffffffb2) (quiet)
    lui x28, 12                       # base of the lb at order 4898 -> w1, the word it loaded (0xffffffb2) (quiet)
    lui x29, 13                       # base of the lb at order 4898 -> w1, the word it loaded (0xffffffb2) (quiet)
    addi x16, x16, %pcrel_lo(.L2)     # base of the lb at order 4898 -> w1, the word it loaded (0xffffffb2)
    lui x6, 14                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 15                        # quiet
    lui x28, 16                       # quiet
    sc.w x14, x15, (x13)              # order 4897 of the run
    lb x13, 0(x16)   # order 4898 of the run: the mismatching instruction, the instruction under test
    lui x29, 17                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 18                        # quiet
    lui x7, 19                        # quiet
TEST_END
    .section .data
    .align 12
tdata:
w0: .word 0x0
w1: .word 0xffffffb2
    .word 0
TEST_HTIF
