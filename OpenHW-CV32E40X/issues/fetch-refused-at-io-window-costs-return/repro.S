// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the reproducer: the whole program the traces in this directory were captured from (rtl.rvvi.txt,
# spike.rvvi.txt are its runs: the same instructions at the same addresses).
# The core's PMA has an I/O region from 0x803f0000 (32 KiB, main = 0) inside the 4 MiB main memory at 0x80000000.
# The program writes two instructions into main memory's last two words before that region (0x803efff8, 0x803efffc),
# runs fence.i, calls them with jalr ra, and the second, jalr zero, 0(ra), jumps back.
# What the RTL did: addi s1, zero, 1 at the jump's target retires 3 cycles after the jump; the cycle table gives 2
# (Jump: 2), and the same program with the two words at 0x803eff00 (probe-far-from-window.S) retires it in 2.
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
    lui x3, 0x803f0                   # x3 = 0x803efff8: main memory's last two words before the I/O region
    lui x29, 5
    lui x6, 6
    lui x7, 7
    addi x3, x3, -8
    lui x8, 0x701                     # x8 = 0x00700e93, the word of addi x29, x0, 7
    lui x28, 8
    lui x29, 9
    lui x6, 10
    addi x8, x8, -365
    sw x8, 0(x3)                      # written at 0x803efff8
    lui x8, 0x8                       # x8 = 0x00008067, the word of jalr x0, 0(ra)
    lui x7, 11
    lui x28, 12
    lui x29, 13
    addi x8, x8, 103
    sw x8, 4(x3)                      # written at 0x803efffc, the last word before 0x803f0000
    fence.i
    jalr x1, 0(x3)                    # run the two; the next sequential word, 0x803f0000, is in the I/O region
    addi x9, x0, 1                    # the jump's target: retires 3 cycles after jalr x0, 0(ra) on the RTL
TEST_END
TEST_TRAP_RESUME
    .section .data
    .align 12
tdata:
    .word 0
TEST_HTIF
