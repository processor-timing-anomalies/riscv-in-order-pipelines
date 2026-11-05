# repro.S -- the whole test icache-reset-walk, kept as it ran (no cut-down reproducer: a confirmation capture, the window 98-103 marked by hand).
# the window: orders 98-103 of the run -- the end of the walk after reset: the three-word loop ran from the bus since its first iteration (order 8, cycle 34), 8 cycles each under a grant withheld one cycle per word, the cache enabled since order 3 and never hitting; orders 98-100 are its last bus-fetched iteration and orders 101-103 (cycle 282 to 286) the first cached one at 4 cycles: the 258-cycle invalidation walk the cache runs after reset, which the document does not mention
// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# icache-reset-walk.S -- the reproducer of icache-reset-walk, written by hand (5 Nov 2026): the cache enabled at the
# program's first instruction, then a counted loop of 100 iterations from the start of the program.  Under an
# instruction-side bus that withholds every grant one cycle, every iteration in the first 258 cycles after reset fetches
# from the bus (the cache's invalidation walk after reset blocks every lookup), and the iterations after it are cached
# and shorter.  Read t2 at the end.
# MARCH: rv32i_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    lui x0, 1                         # marker
    addi t1, x0, 100
    addi t2, x0, 0
    lui x0, 2                         # marker: the loop
1:  addi t1, t1, -1
    addi t2, t2, 1
    bne t1, x0, 1b                    # from the bus while the walk runs, then cached
    lui x0, 3                         # marker
    TEST 1, t2, 100
TEST_END
    .section .data
    .align 12
tdata:
    .word 0
TEST_HTIF
