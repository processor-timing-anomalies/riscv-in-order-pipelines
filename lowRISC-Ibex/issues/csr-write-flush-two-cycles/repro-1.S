// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro-1.S -- the reproducer, cut from the test hz-Zicsr-csrrw-zicsr-00: the instructions of its orders 5..6 with the register and
# memory values they had, so the last one meets the same pipeline state; builds and runs on its own (Makefile).
# What the RTL did there: order 6 lui zero, 0x1: 3 cycles after the previous retirement; the documentation, read as written, gives 2
# MARCH: rv32i_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    lui x0, 1   # marker:  aligns block 1 here
    lui x3, 0x8000d                   # x3 = 0x8000cb00, the value x5 held at the window's start
    lui x6, 2                         # x3 = 0x8000cb00, the value x5 held at the window's start (quiet)
    addi x3, x3, -1280                # x3 = 0x8000cb00, the value x5 held at the window's start
    lui x7, 3                         # quiet: DMAX+1 fillers, nothing older in flight
    csrrw x0, mtvec, x3               # order 5 of the run
    lui x0, 4096   # order 6 of the run: the mismatching instruction, the instruction under test
    lui x28, 4                        # quiet: DMAX+1 fillers, nothing older in flight
TEST_END
    .section .data
    .align 12
tdata:
    .word 0
TEST_HTIF
