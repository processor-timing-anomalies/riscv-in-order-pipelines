// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the reproducer, cut from the test hz-I-add-m-00: the instructions of its orders 8391..8392 with the register and
# memory values they had, so the last one meets the same pipeline state; builds and runs on its own (Makefile).
# What the RTL did there: order 8392 div a4, a3, a5: 37 cycles after the previous retirement; the documentation, read as written, gives 38
# MARCH: rv32im
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    lui x0, 1   # marker:  aligns block 1 here
    addi x16, x0, 747                 # x16 = 0x2eb, the value it held at the window's start
    addi x17, x0, 0                   # x17 = 0x0, the value it held at the window's start
    addi x15, x0, 754                 # x15 = 0x2f2, the value it held at the window's start
    lui x6, 2                         # quiet: DMAX+1 fillers, nothing older in flight
    add x13, x16, x17                 # order 8391 of the run
    div x14, x13, x15   # order 8392 of the run: the mismatching instruction, the instruction under test
    lui x7, 3                         # quiet: DMAX+1 fillers, nothing older in flight
TEST_END
    .section .data
    .align 12
tdata:
    .word 0
TEST_HTIF
