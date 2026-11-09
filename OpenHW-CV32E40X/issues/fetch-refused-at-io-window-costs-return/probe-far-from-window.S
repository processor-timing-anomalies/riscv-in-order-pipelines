// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# probe-far-from-window.S -- repro.S with one change: the two instructions are written at 0x803eff00 and 0x803eff04,
# 256 bytes below the I/O region at 0x803f0000, so the next sequential word (0x803eff08) is main memory.
# What the RTL did: addi s1, zero, 1 at the jump's target retires 2 cycles after jalr zero, 0(ra), as the cycle
# table gives (Jump: 2); the instruction bus saw the prefetch of 0x803eff08 and then the target's request.
# MARCH: rv32i_zicsr_zifencei
# XLEN: 32
#include "test.h"
    .option norvc
    .option arch, +zicsr, +zifencei
TEST_BEGIN
TEST_TRAPS
    lui x0, 1                         # marker
    lui x6, 2                         # fillers: nothing older in flight
    lui x7, 3
    lui x28, 4
    lui x3, 0x803f0                   # x3 = 0x803eff00: two words well inside main memory
    lui x29, 5
    lui x6, 6
    lui x7, 7
    addi x3, x3, -256
    lui x8, 0x701                     # x8 = 0x00700e93, the word of addi x29, x0, 7
    lui x28, 8
    lui x29, 9
    lui x6, 10
    addi x8, x8, -365
    sw x8, 0(x3)                      # written at 0x803eff00
    lui x8, 0x8                       # x8 = 0x00008067, the word of jalr x0, 0(ra)
    lui x7, 11
    lui x28, 12
    lui x29, 13
    addi x8, x8, 103
    sw x8, 4(x3)                      # written at 0x803eff04
    fence.i
    jalr x1, 0(x3)                    # run the two; the next sequential word, 0x803eff08, is main memory
    addi x9, x0, 1                    # the jump's target: retires 2 cycles after jalr x0, 0(ra) on the RTL
TEST_END
TEST_TRAP_RESUME
    .section .data
    .align 12
tdata:
    .word 0
TEST_HTIF
