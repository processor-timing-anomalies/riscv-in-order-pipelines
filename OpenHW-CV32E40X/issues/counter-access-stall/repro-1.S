// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro-1.S -- the reproducer, cut from the test own-cv32e40x-00: the instructions of its orders 4038..4041 with the register and
# memory values they had, so the last one meets the same pipeline state; builds and runs on its own (Makefile).
# What the RTL did there: order 4041 csrrs s9, mhpmcounter4, zero: 2 cycles after the previous retirement; the documentation, read as written, gives 1
# MARCH: rv32i_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    lui x0, 1   # marker:  aligns block 1 here
    addi x3, x0, 1566                 # x3 = 0x61e, the value it held at the window's start
    addi x8, x0, 1573                 # x8 = 0x625, the value it held at the window's start
    lui x6, 2                         # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 3                         # quiet
    lui x28, 4                        # quiet
    sll x27, x3, x8                   # order 4040 of the run
    csrrs x25, mhpmcounter4, x0   # order 4041 of the run: the mismatching instruction, the instruction under test
    lui x29, 5                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 6                         # quiet
    lui x7, 7                         # quiet
TEST_END
    .section .data
    .align 12
tdata:
    .word 0
TEST_HTIF
