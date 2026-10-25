// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro-1.S -- the reproducer, cut from the test own-cv32e40x-clic-00: the instructions of its orders 4938..4941 with the register and
# memory values they had, so the last one meets the same pipeline state; builds and runs on its own (Makefile).
# What the RTL did there: order 4941 c.lw a0, 0(a1): 1 cycles after the previous retirement; the documentation, read as written, gives 2
# MARCH: rv32ic_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    lui x0, 1   # marker:  aligns block 1 here
    addi x16, x0, 8                   # x16 = 0x8, the value it held at the window's start
    lui x11, 0x80006                  # x11 = 0x80006144, the value it held at the window's start
    lui x6, 2                         # x11 = 0x80006144, the value it held at the window's start (quiet)
    lui x7, 3                         # x11 = 0x80006144, the value it held at the window's start (quiet)
    lui x28, 4                        # x11 = 0x80006144, the value it held at the window's start (quiet)
    addi x11, x11, 324                # x11 = 0x80006144, the value it held at the window's start
    .L1: auipc x11, %pcrel_hi(w0)     # base of the c.lw at order 4941 -> w0, the word it loaded (0x73f)
    lui x29, 5                        # base of the c.lw at order 4941 -> w0, the word it loaded (0x73f) (quiet)
    lui x6, 6                         # base of the c.lw at order 4941 -> w0, the word it loaded (0x73f) (quiet)
    lui x7, 7                         # base of the c.lw at order 4941 -> w0, the word it loaded (0x73f) (quiet)
    addi x11, x11, %pcrel_lo(.L1)     # base of the c.lw at order 4941 -> w0, the word it loaded (0x73f)
    lui x28, 8                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 9                        # quiet
    lui x6, 10                        # quiet
    csrrs x0, mie, x16                # order 4940 of the run
    .option push
    .option rvc
    c.lw x10, 0(x11)   # order 4941 of the run: the mismatching instruction, the instruction under test
    .option pop
    lui x7, 11                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 12                       # quiet
    lui x29, 13                       # quiet
TEST_END
    .section .data
    .align 12
tdata:
w0: .word 0x73f
    .word 0
TEST_HTIF
