// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the reproducer, cut from the test firstTest: the instructions of its orders 96..99 with the register and
# memory values they had, so the last one meets the same pipeline state; builds and runs on its own (Makefile).
# What the RTL did there: order 99 c.li t5, 15: 2 cycles after the previous retirement; the documentation, read as written, gives 1
# MARCH: rv32imc
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    lui x0, 1   # marker:  aligns block 1 here
    addi x10, x0, 100                 # x10 = 0x64, the value it held at the window's start
    addi x11, x0, 7                   # x11 = 0x7, the value it held at the window's start
    lui x6, 2                         # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 3                         # quiet
    lui x28, 4                        # quiet
    div x12, x10, x11                 # order 98 of the run
    .option push
    .option arch, +zca
    c.li x3, 15   # order 99 of the run: the mismatching instruction, the instruction under test
    .option pop
    lui x29, 5                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 6                         # quiet
    lui x7, 7                         # quiet
TEST_END
    .section .data
    .align 12
tdata:
    .word 0
TEST_HTIF
