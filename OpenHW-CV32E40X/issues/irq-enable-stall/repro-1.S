// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro-1.S -- the reproducer, cut from the test own-cv32e40x-00: the instructions of its orders 1465..1468 with the register and
# memory values they had, so the last one meets the same pipeline state; builds and runs on its own (Makefile).
# What the RTL did there: order 1468 c.sb a4, 0(a3): 2 cycles after the previous retirement; the documentation, read as written, gives 1
# MARCH: rv32ic_zicsr_zcb
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    lui x0, 1   # marker:  aligns block 1 here
    addi x3, x0, 0                    # x3 = 0x0, the value it held at the window's start
    lui x13, 0x80002                  # x13 = 0x80002054, the value it held at the window's start
    lui x6, 2                         # x13 = 0x80002054, the value it held at the window's start (quiet)
    lui x7, 3                         # x13 = 0x80002054, the value it held at the window's start (quiet)
    lui x28, 4                        # x13 = 0x80002054, the value it held at the window's start (quiet)
    addi x13, x13, 84                 # x13 = 0x80002054, the value it held at the window's start
    addi x14, x0, 1462                # x14 = 0x5b6, the value it held at the window's start
    .L1: auipc x13, %pcrel_hi(w0)     # base of the c.sb at order 1468 -> w0, a scratch word
    lui x29, 5                        # base of the c.sb at order 1468 -> w0, a scratch word (quiet)
    lui x6, 6                         # base of the c.sb at order 1468 -> w0, a scratch word (quiet)
    lui x7, 7                         # base of the c.sb at order 1468 -> w0, a scratch word (quiet)
    addi x13, x13, %pcrel_lo(.L1)     # base of the c.sb at order 1468 -> w0, a scratch word
    lui x28, 8                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 9                        # quiet
    lui x6, 10                        # quiet
    csrrs x0, mstatus, x3             # order 1467 of the run
    .option push
    .option rvc
    c.sb x14, 0(x13)   # order 1468 of the run: the mismatching instruction, the instruction under test
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
