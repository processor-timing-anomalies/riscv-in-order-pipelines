// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the reproducer, cut from the test own-cv32e40x-clic-00: the instructions of its orders 4919..4922 with the register and
# memory values they had, so the last one meets the same pipeline state; builds and runs on its own (Makefile).
# What the RTL did there: order 4922 c.lhu a5, 0(s0): 1 cycles after the previous retirement; the documentation, read as written, gives 2
# MARCH: rv32ic_zicsr_zcb
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    lui x0, 1   # marker:  aligns block 1 here
    addi x13, x0, 0                   # x13 = 0x0, the value it held at the window's start
    lui x8, 0x80006                   # x8 = 0x80006140, the value it held at the window's start
    lui x6, 2                         # x8 = 0x80006140, the value it held at the window's start (quiet)
    lui x7, 3                         # x8 = 0x80006140, the value it held at the window's start (quiet)
    lui x28, 4                        # x8 = 0x80006140, the value it held at the window's start (quiet)
    addi x8, x8, 320                  # x8 = 0x80006140, the value it held at the window's start
    .L1: auipc x8, %pcrel_hi(w0)      # base of the c.lhu at order 4922 -> w0, the word it loaded (0x731)
    lui x29, 5                        # base of the c.lhu at order 4922 -> w0, the word it loaded (0x731) (quiet)
    lui x6, 6                         # base of the c.lhu at order 4922 -> w0, the word it loaded (0x731) (quiet)
    lui x7, 7                         # base of the c.lhu at order 4922 -> w0, the word it loaded (0x731) (quiet)
    addi x8, x8, %pcrel_lo(.L1)       # base of the c.lhu at order 4922 -> w0, the word it loaded (0x731)
    lui x28, 8                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 9                        # quiet
    lui x6, 10                        # quiet
    csrrs x0, mie, x13                # order 4921 of the run
    .option push
    .option rvc
    c.lhu x15, 0(x8)   # order 4922 of the run: the mismatching instruction, the instruction under test
    .option pop
    lui x7, 11                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 12                       # quiet
    lui x29, 13                       # quiet
TEST_END
    .section .data
    .align 12
tdata:
w0: .word 0x731
    .word 0
TEST_HTIF
