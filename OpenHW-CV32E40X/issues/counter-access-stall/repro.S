// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the reproducer, cut from the test own-cv32e40x-00: the instructions of its orders 224..227 with the register and
# memory values they had, so the last one meets the same pipeline state; builds and runs on its own (Makefile).
# What the RTL did there: order 227 csrrw zero, mcycle, a7: 2 cycles after the previous retirement; the documentation, read as written, gives 1
# MARCH: rv32i_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    lui x0, 1   # marker:  aligns block 1 here
    addi x17, x0, 788                 # x17 = 0x314, the value it held at the window's start
    lui x6, 2                         # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 3                         # quiet
    lui x28, 4                        # quiet
    lui x3, 520192                    # order 226 of the run
    csrrw x0, mcycle, x17   # order 227 of the run: the mismatching instruction, the instruction under test
    lui x29, 5                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 6                         # quiet
    lui x7, 7                         # quiet
TEST_END
    .section .data
    .align 12
tdata:
    .word 0
TEST_HTIF
