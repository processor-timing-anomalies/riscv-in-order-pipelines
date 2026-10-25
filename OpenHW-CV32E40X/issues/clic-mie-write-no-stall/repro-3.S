// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro-3.S -- the reproducer, cut from the test own-cv32e40x-clic-00: the instructions of its orders 4977..4980 with the register and
# memory values they had, so the last one meets the same pipeline state; builds and runs on its own (Makefile).
# What the RTL did there: order 4980 c.swsp s7, 0(sp): 1 cycles after the previous retirement; the documentation, read as written, gives 2
# MARCH: rv32ic_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    lui x0, 1   # marker:  aligns block 1 here
    addi x22, x0, 8                   # x22 = 0x8, the value it held at the window's start
    addi x23, x0, 1890                # x23 = 0x762, the value it held at the window's start
    .L1: auipc x2, %pcrel_hi(w0)      # base of the c.swsp at order 4980 -> w0, a scratch word
    lui x6, 2                         # base of the c.swsp at order 4980 -> w0, a scratch word (quiet)
    lui x7, 3                         # base of the c.swsp at order 4980 -> w0, a scratch word (quiet)
    lui x28, 4                        # base of the c.swsp at order 4980 -> w0, a scratch word (quiet)
    addi x2, x2, %pcrel_lo(.L1)       # base of the c.swsp at order 4980 -> w0, a scratch word
    lui x29, 5                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 6                         # quiet
    lui x7, 7                         # quiet
    csrrs x0, mie, x22                # order 4979 of the run
    .option push
    .option rvc
    c.swsp x23, 0(sp)   # order 4980 of the run: the mismatching instruction, the instruction under test
    .option pop
    lui x28, 8                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 9                        # quiet
    lui x6, 10                        # quiet
TEST_END
    .section .data
    .align 12
tdata:
w0: .word 0x0
    .word 0
TEST_HTIF
