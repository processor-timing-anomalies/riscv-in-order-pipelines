// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the reproducer, cut from the test hzn-cross2-259: the instructions of its orders 24..27 with the register and
# memory values they had, so the last one meets the same pipeline state; builds and runs on its own (Makefile).
# What the RTL did there: order 27 lw s4, 0(a5): 2 cycles after the previous retirement; the documentation, read as written, gives 1
# MARCH: rv32i_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
# replay of (no id): orders 26..27 of the run, the smallest window that still fires it on the last instruction
    lui x0, 1   # marker:  aligns block 1 here
    addi x18, x0, 0                   # x18 = 0x0, the value it held at the window's start
    lui x15, 0x80001                  # x15 = 0x80001000, the value it held at the window's start
    lui x6, 2                         # x15 = 0x80001000, the value it held at the window's start (quiet)
    lui x7, 3                         # x15 = 0x80001000, the value it held at the window's start (quiet)
    lui x28, 4                        # x15 = 0x80001000, the value it held at the window's start (quiet)
    addi x15, x15, 0                  # x15 = 0x80001000, the value it held at the window's start
    .L1: auipc x15, %pcrel_hi(w0)     # base of the lw at order 27 -> w0, the word it loaded (0x107)
    lui x29, 5                        # base of the lw at order 27 -> w0, the word it loaded (0x107) (quiet)
    lui x6, 6                         # base of the lw at order 27 -> w0, the word it loaded (0x107) (quiet)
    lui x7, 7                         # base of the lw at order 27 -> w0, the word it loaded (0x107) (quiet)
    addi x15, x15, %pcrel_lo(.L1)     # base of the lw at order 27 -> w0, the word it loaded (0x107)
    lui x28, 8                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 9                        # quiet
    lui x6, 10                        # quiet
    csrrw x0, mcause, x18             # order 26 of the run
    lw x20, 0(x15)                    # order 27 of the run: the mismatching instruction, (no id)
    lui x7, 11                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 12                       # quiet
    lui x29, 13                       # quiet
TEST_END
    .section .data
    .align 12
tdata:
w0: .word 0x107
    .word 0
TEST_HTIF
