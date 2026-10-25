// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the reproducer, cut from the test own-cv32e40x-00: the instructions of its orders 1519..1522 with the register and
# memory values they had, so the last one meets the same pipeline state; builds and runs on its own (Makefile).
# What the RTL did there: order 1522 csrrs a6, mhpmcounter3h, zero: 2 cycles after the previous retirement; the documentation, read as written, gives 1
# MARCH: rv32ic_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    lui x0, 1   # marker:  aligns block 1 here
    addi x19, x0, 1490                # x19 = 0x5d2, the value it held at the window's start
    lui x6, 2                         # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 3                         # quiet
    lui x28, 4                        # quiet
    .option push
    .option rvc
    c.add x18, x19                # order 1521 of the run
    .option pop
    csrrs x16, mhpmcounter3h, x0   # order 1522 of the run: the mismatching instruction, the instruction under test
    lui x29, 5                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 6                         # quiet
    lui x7, 7                         # quiet
TEST_END
    .section .data
    .align 12
tdata:
    .word 0
TEST_HTIF
