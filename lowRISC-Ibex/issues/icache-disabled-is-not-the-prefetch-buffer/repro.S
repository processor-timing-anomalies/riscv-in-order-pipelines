# repro.S -- the whole test icache-off-redirect, kept as it ran (no cut-down reproducer: a confirmation capture, the window 8-14 marked by hand).
# the window: orders 8-14 of the run -- the cache disabled since order 5; after the jump (order 7) its target and the six words after it retire a cycle apart under a bus that answers every other word a cycle late (orders 8-14: 3, 1, 1, 1, 1, 1, 1 cycles), because the cache's fill buffers request the lines ahead; the same program on the build without the cache (ICache = 0, the prefetch buffer with two words outstanding) under the same bus retires them at 3, 1, 2, 1, 2, 1, 2: disabling the cache does not give the uncached build's timing
// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# icache-off-redirect.S -- the reproducer of icache-disabled-is-not-the-prefetch-buffer, written by hand (5 Nov 2026):
# the cache disabled (cpuctrlsts.icache_enable cleared), then a jump and the straight-line words after its target, run
# under an instruction-side bus that answers every other word a cycle late.  From the redirect on, the words arrive by
# the cache's own request stream (a speculative request in the lookup's cycle, the fill buffers requesting a line at a
# time, up to three lines ahead), not the prefetch buffer's (two words outstanding): the same program on the build
# without the cache (ICache = 0) under the same bus retires the words after the target in different cycles.  Read t2
# at the end.
# MARCH: rv32i_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    lui x0, 1                         # marker
#ifdef ICACHE_ENABLE
    csrci 0x7c0, 1                    # the cache disabled: every lookup goes to the bus, nothing is allocated
#endif
    addi t2, x0, 0
    jal x0, 1f                        # the redirect
    addi t2, t2, 100                  # skipped
    addi t2, t2, 100                  # skipped
1:  addi t2, t2, 1                    # the target and the words after it
    addi t2, t2, 1
    addi t2, t2, 1
    addi t2, t2, 1
    addi t2, t2, 1
    addi t2, t2, 1
    lui x0, 2                         # marker
    TEST 1, t2, 6
TEST_END
    .section .data
    .align 12
tdata:
    .word 0
TEST_HTIF
