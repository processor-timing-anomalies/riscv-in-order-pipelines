# repro.S -- the whole test icache-fence-i-walk, kept as it ran (no cut-down reproducer: a confirmation capture, the window 360-363 marked by hand).
# the window: orders 360-363 of the run -- the end of the walk: the fence.i retired at cycle 547 (order 260); from it every iteration of the three-word loop fetched its words from the bus, 8 cycles each under a grant withheld one cycle per word, where the same loop ran cached at 3 cycles before the fence.i (orders 254-257); the iteration at orders 360-362 is the first whose lookups hit again and allocate, and from order 363 (cycle 829) the loop is cached once more: 258 cycles of invalidation walk from the fence.i, against the cycle table's 1 - N
// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# icache-fence-i-walk.S -- the reproducer of icache-fence-i-walk-258-cycles, written by hand (5 Nov 2026): a delay loop
# outlasts the invalidation walk the cache runs after reset, a short loop then runs warm (its words cached), a fence.i
# invalidates the cache, and the same loop runs again for 80 iterations.  Under an instruction-side bus that withholds
# every grant one cycle, each iteration after the fence.i fetches from the bus (no lookup hits during the walk) until
# the walk's 258 cycles are over, when the iterations are cached again and shorter.  Read t2 at the end.
# MARCH: rv32i_zicsr_zifencei
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    lui x0, 1                         # marker
    addi t1, x0, 120
1:  addi t1, t1, -1                   # the delay: past the reset walk before the measured loops
    bne t1, x0, 1b
    addi t1, x0, 3
    addi t2, x0, 0
    lui x0, 2                         # marker: the warm loop
2:  addi t1, t1, -1
    addi t2, t2, 1
    bne t1, x0, 2b
    addi t1, x0, 80
    lui x0, 3                         # marker: the fence.i
    fence.i                           # the invalidation walk starts in this cycle
3:  addi t1, t1, -1
    addi t2, t2, 1
    bne t1, x0, 3b                    # from the bus until the walk ends, then cached
    lui x0, 4                         # marker
    TEST 1, t2, 83
TEST_END
    .section .data
    .align 12
tdata:
    .word 0
TEST_HTIF
