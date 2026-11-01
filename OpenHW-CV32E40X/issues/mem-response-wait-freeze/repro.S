// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the whole test mem-response-wait-freeze, kept as it ran (no cut-down reproducer: a confirmation capture, the window 12-15 marked by hand).
# the window: orders 12-15 of the run -- under a data bus answering every second request two cycles after its grant (respond:2): the store (request 2, late) retires 3 cycles after the jalr whose link is its address, the jal behind it 1 cycle after the store as always, and the jal's target, fetched while the store waited for its link, 2 cycles after the jal: it sat in IF while the store in WB waited for its response, although ID and EX had room; let into ID during that wait it would retire 1 after the jal, the cycle table's count; with the store's response on time (orders 22-25) the store retires in 2 and the target again 2 after the jal, the jump's own cost; the same behind a load, late (orders 32-35) and on time (orders 42-45)
# mem-response-wait-freeze.S -- the reproducer of mem-response-wait-freeze, written by hand (29 Oct 2026): run under
# a data bus that answers every second request two cycles after its grant (respond:2).  A jalr to the next
# instruction writes its link; the store behind it uses the link as its address, so it waits a cycle in ID for it,
# and the jal behind the store resolves in ID while the store moves on, so the jump's target is fetched then.  With
# the store's response late (request 2) the store retires 3 cycles after the jalr, the jal 1 cycle after the store
# as always, and the target 2 cycles after the jal: the target, already fetched, waited in IF while the store in WB
# waited for its response, although ID and EX had room; a core that let it into ID during that wait would retire it
# 1 cycle after the jal, which is what the cycle table, read as written, gives.  With the store's response on time
# (request 3) the store retires in 2 and the target again 2 after the jal, the jump's own cost.  The same behind a
# load with a late response (request 4) and one on time (request 5).
# MARCH: rv32i
# XLEN: 32
#include "test.h"
    .option norvc
    .option norelax
TEST_BEGIN
    la   x9, tdata
    addi x21, x0, 1054                # the store's data
    lui x0, 1                         # marker
    lw   x11, 0(x9)                   # request 1: answered the cycle after its grant
    la   x22, 1f                      # the jalr's target: the instruction after it
    lui x6, 2                         # fillers: nothing older in flight
    lui x7, 3
    lui x28, 4
    jalr x20, 0(x22)                  # a jump to the next instruction, writing the link x20
1:  sw   x21, 8(x20)                  # request 2, answered two cycles after its grant: waits a cycle for x20, 2 cycles
    jal  x0, 2f                       # behind the store: 1 cycle
    .word 0x42c                       # the word the store wrote, skipped
2:  lui x29, 5                        # the target, fetched while the store waited for x20: 2 cycles, 1 if it had entered ID during the store's wait
    lui x0, 2                         # marker
    la   x22, 3f
    lui x6, 6
    lui x7, 7
    lui x28, 8
    jalr x20, 0(x22)
3:  sw   x21, 8(x20)                  # request 3, answered the cycle after its grant: 2 cycles (the wait for x20)
    jal  x0, 4f                       # 1 cycle
    .word 0x42c
4:  lui x29, 9                        # the target: 2 cycles, the jump's own cost
    lui x0, 3                         # marker
    la   x22, 5f
    lui x6, 10
    lui x7, 11
    lui x28, 12
    jalr x20, 0(x22)
5:  lw   x23, 8(x20)                  # request 4, answered two cycles after its grant: 3 cycles
    jal  x0, 6f                       # 1 cycle
    .word 0x42c
6:  lui x29, 13                       # the target: 2 cycles
    lui x0, 4                         # marker
    la   x22, 7f
    lui x6, 14
    lui x7, 15
    lui x28, 16
    jalr x20, 0(x22)
7:  lw   x23, 8(x20)                  # request 5, answered the cycle after its grant: 2 cycles
    jal  x0, 8f                       # 1 cycle
    .word 0x42c
8:  lui x29, 17                       # the target: 2 cycles, the jump's own cost
    lui x0, 5                         # marker
TEST_END
    .section .data
    .align 12
tdata:
    .word 0
TEST_HTIF
