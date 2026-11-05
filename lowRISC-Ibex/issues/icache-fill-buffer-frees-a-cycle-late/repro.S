# repro.S -- the whole test icache-fill-buffer-free, kept as it ran (no cut-down reproducer: a confirmation capture, the window 13-14 marked by hand).
# the window: orders 13-14 of the run -- the words after the divide drain the fill buffers filled during its 37 cycles: addi a6 (order 14) retires 2 cycles after addi a5 where the five words before it took 1 each; its lookup needed a buffer whose last word was taken in the cycle before, and the buffer frees a cycle after that (the done state is registered), so the lookup is granted a cycle later than a buffer freed at once would allow; a model of the cache with the buffer freed at once gives this word 1 cycle, the registered one 2 as the RTL
// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# icache-fill-buffer-free.S -- the reproducer of icache-fill-buffer-frees-a-cycle-late, written by hand (5 Nov 2026):
# a divide holds the pipeline for 37 cycles while the cache fetches ahead until its fill buffers hold three lines; the
# straight-line words after it drain the buffers.  Under an instruction-side bus that withholds every grant one cycle,
# the lookup that needs a freed buffer is granted one cycle after the buffer's last word was taken, not in that
# cycle, and the instruction it fetches retires a cycle later than a buffer freed at once would allow.  Read t3 at the end.
# MARCH: rv32im_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    lui x0, 1                         # marker
    addi t1, x0, 700
    addi t2, x0, 7
    div t3, t1, t2                    # 37 cycles: the fetch side runs ahead and fills its buffers
    addi a0, x0, 1                    # the straight-line words drain the buffers
    addi a1, x0, 2
    addi a2, x0, 3
    addi a3, x0, 4
    addi a4, x0, 5
    addi a5, x0, 6
    addi a6, x0, 7
    addi a7, x0, 8
    addi s2, x0, 9
    addi s3, x0, 10
    addi s4, x0, 11
    addi s5, x0, 12
    addi s6, x0, 13
    addi s7, x0, 14
    addi s8, x0, 15
    addi s9, x0, 16
    lui x0, 2                         # marker
    TEST 1, t3, 100
TEST_END
    .section .data
    .align 12
tdata:
    .word 0
TEST_HTIF
