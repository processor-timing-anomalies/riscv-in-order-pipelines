// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the reproducer, cut from the test own-cv32e40x-00: the instructions of its orders 1446..1449 with the register and
# memory values they had, so the last one meets the same pipeline state; builds and runs on its own (Makefile).
# What the RTL did there: order 1449 c.lbu a0, 0(a1): 2 cycles after the previous retirement; the documentation, read as written, gives 1
# MARCH: rv32ic_zicsr_zcb
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    lui x0, 1   # marker:  aligns block 1 here
    addi x25, x0, 0                   # x25 = 0x0, the value it held at the window's start
    lui x11, 0x80002                  # x11 = 0x80002050, the value it held at the window's start
    lui x6, 2                         # x11 = 0x80002050, the value it held at the window's start (quiet)
    lui x7, 3                         # x11 = 0x80002050, the value it held at the window's start (quiet)
    lui x28, 4                        # x11 = 0x80002050, the value it held at the window's start (quiet)
    addi x11, x11, 80                 # x11 = 0x80002050, the value it held at the window's start
    .L1: auipc x11, %pcrel_hi(w0)     # base of the c.lbu at order 1449 -> w0, the word it loaded (0xa1)
    lui x29, 5                        # base of the c.lbu at order 1449 -> w0, the word it loaded (0xa1) (quiet)
    lui x6, 6                         # base of the c.lbu at order 1449 -> w0, the word it loaded (0xa1) (quiet)
    lui x7, 7                         # base of the c.lbu at order 1449 -> w0, the word it loaded (0xa1) (quiet)
    addi x11, x11, %pcrel_lo(.L1)     # base of the c.lbu at order 1449 -> w0, the word it loaded (0xa1)
    lui x28, 8                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 9                        # quiet
    lui x6, 10                        # quiet
    csrrs x0, mstatus, x25            # order 1448 of the run
    .option push
    .option rvc
    c.lbu x10, 0(x11)   # order 1449 of the run: the mismatching instruction, the instruction under test
    .option pop
    lui x7, 11                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 12                       # quiet
    lui x29, 13                       # quiet
TEST_END
    .section .data
    .align 12
tdata:
w0: .word 0xa1
    .word 0
TEST_HTIF
