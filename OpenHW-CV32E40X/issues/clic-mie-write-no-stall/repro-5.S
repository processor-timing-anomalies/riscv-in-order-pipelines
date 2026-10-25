// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro-5.S -- the reproducer, cut from the test own-cv32e40x-clic-00: the instructions of its orders 5221..5224 with the register and
# memory values they had, so the last one meets the same pipeline state; builds and runs on its own (Makefile).
# What the RTL did there: order 5224 c.lh a2, 0(a3): 1 cycles after the previous retirement; the documentation, read as written, gives 2
# MARCH: rv32ic_zicsr_zcb
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    lui x0, 1   # marker:  aligns block 1 here
    addi x24, x0, 8                   # x24 = 0x8, the value it held at the window's start
    lui x13, 0x80006                  # x13 = 0x80006164, the value it held at the window's start
    lui x6, 2                         # x13 = 0x80006164, the value it held at the window's start (quiet)
    lui x7, 3                         # x13 = 0x80006164, the value it held at the window's start (quiet)
    lui x28, 4                        # x13 = 0x80006164, the value it held at the window's start (quiet)
    addi x13, x13, 356                # x13 = 0x80006164, the value it held at the window's start
    .L1: auipc x13, %pcrel_hi(w0)     # base of the c.lh at order 5224 -> w0, the word it loaded (0x191)
    lui x29, 5                        # base of the c.lh at order 5224 -> w0, the word it loaded (0x191) (quiet)
    lui x6, 6                         # base of the c.lh at order 5224 -> w0, the word it loaded (0x191) (quiet)
    lui x7, 7                         # base of the c.lh at order 5224 -> w0, the word it loaded (0x191) (quiet)
    addi x13, x13, %pcrel_lo(.L1)     # base of the c.lh at order 5224 -> w0, the word it loaded (0x191)
    lui x28, 8                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 9                        # quiet
    lui x6, 10                        # quiet
    csrrs x0, mie, x24                # order 5223 of the run
    .option push
    .option rvc
    c.lh x12, 0(x13)   # order 5224 of the run: the mismatching instruction, the instruction under test
    .option pop
    lui x7, 11                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 12                       # quiet
    lui x29, 13                       # quiet
TEST_END
    .section .data
    .align 12
tdata:
w0: .word 0x191
    .word 0
TEST_HTIF
