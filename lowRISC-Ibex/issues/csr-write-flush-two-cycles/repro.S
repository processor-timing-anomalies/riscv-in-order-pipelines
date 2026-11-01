// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the reproducer, cut from the test hz-Zicsr-csrrw-zicsr-00: the instructions of its orders 375..376 with the register and
# memory values they had, so the last one meets the same pipeline state; builds and runs on its own (Makefile).
# What the RTL did there: order 376 auipc a1, 0x0: 3 cycles after the previous retirement; the documentation, read as written, gives 2
# MARCH: rv32i_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    lui x0, 1   # marker:  aligns block 1 here
    lui x11, 0x2                      # x11 = 0x1800, the value it held at the window's start
    lui x6, 2                         # x11 = 0x1800, the value it held at the window's start (quiet)
    addi x11, x11, -2048              # x11 = 0x1800, the value it held at the window's start
    lui x7, 3                         # quiet: DMAX+1 fillers, nothing older in flight
    csrrs x0, mstatus, x11            # order 375 of the run
    auipc x11, 0   # order 376 of the run: the mismatching instruction, the instruction under test
    lui x28, 4                        # quiet: DMAX+1 fillers, nothing older in flight
TEST_END
    .section .data
    .align 12
tdata:
    .word 0
TEST_HTIF
