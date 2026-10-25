// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro-7.S -- the reproducer, cut from the test own-cv32e40x-clic-00: the instructions of its orders 5260..5263 with the register and
# memory values they had, so the last one meets the same pipeline state; builds and runs on its own (Makefile).
# What the RTL did there: order 5263 c.sh a1, 0(a0): 1 cycles after the previous retirement; the documentation, read as written, gives 2
# MARCH: rv32ic_zicsr_zcb
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    lui x0, 1   # marker:  aligns block 1 here
    addi x9, x0, 8                    # x9 = 0x8, the value it held at the window's start
    lui x10, 0x80006                  # x10 = 0x8000616c, the value it held at the window's start
    lui x6, 2                         # x10 = 0x8000616c, the value it held at the window's start (quiet)
    lui x7, 3                         # x10 = 0x8000616c, the value it held at the window's start (quiet)
    lui x28, 4                        # x10 = 0x8000616c, the value it held at the window's start (quiet)
    addi x10, x10, 364                # x10 = 0x8000616c, the value it held at the window's start
    addi x11, x0, 436                 # x11 = 0x1b4, the value it held at the window's start
    .L1: auipc x10, %pcrel_hi(w0)     # base of the c.sh at order 5263 -> w0, a scratch word
    lui x29, 5                        # base of the c.sh at order 5263 -> w0, a scratch word (quiet)
    lui x6, 6                         # base of the c.sh at order 5263 -> w0, a scratch word (quiet)
    lui x7, 7                         # base of the c.sh at order 5263 -> w0, a scratch word (quiet)
    addi x10, x10, %pcrel_lo(.L1)     # base of the c.sh at order 5263 -> w0, a scratch word
    lui x28, 8                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 9                        # quiet
    lui x6, 10                        # quiet
    csrrs x0, mie, x9                 # order 5262 of the run
    .option push
    .option rvc
    c.sh x11, 0(x10)   # order 5263 of the run: the mismatching instruction, the instruction under test
    .option pop
    lui x7, 11                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 12                       # quiet
    lui x29, 13                       # quiet
TEST_END
    .section .data
    .align 12
tdata:
w0: .word 0x0
    .word 0
TEST_HTIF
