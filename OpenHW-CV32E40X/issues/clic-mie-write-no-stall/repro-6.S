// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro-6.S -- the reproducer, cut from the test own-cv32e40x-clic-00: the instructions of its orders 5241..5244 with the register and
# memory values they had, so the last one meets the same pipeline state; builds and runs on its own (Makefile).
# What the RTL did there: order 5244 c.sb s0, 0(a5): 1 cycles after the previous retirement; the documentation, read as written, gives 2
# MARCH: rv32ic_zicsr_zcb
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    lui x0, 1   # marker:  aligns block 1 here
    addi x27, x0, 0                   # x27 = 0x0, the value it held at the window's start
    lui x15, 0x80006                  # x15 = 0x80006168, the value it held at the window's start
    lui x6, 2                         # x15 = 0x80006168, the value it held at the window's start (quiet)
    lui x7, 3                         # x15 = 0x80006168, the value it held at the window's start (quiet)
    lui x28, 4                        # x15 = 0x80006168, the value it held at the window's start (quiet)
    addi x15, x15, 360                # x15 = 0x80006168, the value it held at the window's start
    addi x8, x0, 422                  # x8 = 0x1a6, the value it held at the window's start
    .L1: auipc x15, %pcrel_hi(w0)     # base of the c.sb at order 5244 -> w0, a scratch word
    lui x29, 5                        # base of the c.sb at order 5244 -> w0, a scratch word (quiet)
    lui x6, 6                         # base of the c.sb at order 5244 -> w0, a scratch word (quiet)
    lui x7, 7                         # base of the c.sb at order 5244 -> w0, a scratch word (quiet)
    addi x15, x15, %pcrel_lo(.L1)     # base of the c.sb at order 5244 -> w0, a scratch word
    lui x28, 8                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 9                        # quiet
    lui x6, 10                        # quiet
    csrrs x0, mie, x27                # order 5243 of the run
    .option push
    .option rvc
    c.sb x8, 0(x15)   # order 5244 of the run: the mismatching instruction, the instruction under test
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
