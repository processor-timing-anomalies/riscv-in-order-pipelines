// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the whole test amo-misaligned, kept as it ran (no cut-down reproducer: a confirmation capture, the window 13-58 marked by hand).
# the window: orders 13-58 of the run -- a misaligned lr.w (order 13), sc.w (34) and amoadd.w (55) at tdata + 2 in main memory: the RTL raises a load access fault (5) and store/AMO access faults (7), as Spike does; the exception table gives the address-misaligned causes 4 and 6 for them
# amo-misaligned.S -- a probe (13 Oct 2026): a misaligned lr.w, sc.w and
# amoadd.w in main memory (tdata + 2).  pma.rst says atomics are not misaligned; what the RTL does (a misaligned
# exception, an access fault, or a split) is unwritten.  Spike raises the address-misaligned exception (4 / 6).
# MARCH: rv32ia_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
TEST_TRAPS
# block 1  lr.w misaligned
    lui x0, 1                         # marker
    la x21, tdata                     # base: tdata
    addi x21, x21, 2                  # tdata + 2: misaligned by a half word
    addi x22, x0, 291                 # data
    lui x6, 2                         # quiet
    lui x7, 3                         # quiet
    lui x28, 4                        # quiet
    lr.w x23, (x21)                   # subject lr.w: misaligned in main memory
    lui x7, 11                        # quiet
    lui x28, 12                       # quiet
    lui x29, 13                       # quiet
# block 2  sc.w misaligned
    lui x0, 2                         # marker
    lui x6, 14                        # quiet
    lui x7, 15                        # quiet
    lui x28, 16                       # quiet
    sc.w x26, x22, (x21)              # subject sc.w: misaligned in main memory (no reservation held either)
    lui x7, 23                        # quiet
    lui x28, 24                       # quiet
    lui x29, 25                       # quiet
# block 3  amoadd.w misaligned
    lui x0, 3                         # marker
    lui x6, 26                        # quiet
    lui x7, 27                        # quiet
    lui x28, 28                       # quiet
    amoadd.w x8, x22, (x21)           # subject amoadd.w: misaligned in main memory
    lui x7, 35                        # quiet
    lui x28, 36                       # quiet
    lui x29, 37                       # quiet
# block 4  the same, the word aligned: a control that the handler and the data are sound
    lui x0, 4                         # marker
    addi x21, x21, -2                 # tdata, aligned
    lui x6, 38                        # quiet
    lui x7, 39                        # quiet
    lui x28, 40                       # quiet
    amoadd.w x8, x22, (x21)           # control amoadd.w: aligned
    lui x7, 41                        # quiet
    lui x28, 42                       # quiet
    lui x29, 43                       # quiet
TEST_END
TEST_TRAP_RESUME
    .section .data
    .align 12
tdata:
    .word 0x11223344
    .word 0
TEST_HTIF
