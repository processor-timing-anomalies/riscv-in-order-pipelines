# repro.S -- the whole test flush-redirect-extra-cycle, kept as it ran (no cut-down reproducer: a confirmation capture, the window 8-22 marked by hand).
# the window: orders 8-22 of the run -- order 8 ecall at cycle 25; order 9, the handler's first instruction (the vector table's jal), at 29: 4 cycles after the ecall's record; the handler's mret (order 21) at 42 and its target (order 22) at 45: 3 cycles after the mret; the jal of order 23 retires 2 cycles after its predecessor and its target 1 after it: a jump costs 2 where the trap entry costs 4 and the return 3, the FLUSH state's cycle on each
// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# flush-redirect-extra-cycle.S -- the reproducer of flush-redirect-extra-cycle, written by hand (29 Oct 2026): an ecall
# whose handler's first instruction retires 4 cycles after the ecall's record, the handler's mret whose target retires 3
# cycles after the mret, and a jal whose target follows in 2: the trap entry and the return each cost one cycle more
# than a jump, the FLUSH state's own (ibex_controller.sv: an exception or an mret is a special request, DECODE keeps ID
# and enters FLUSH, which sets the pc the cycle after the instruction's own).  The documentation gives no count for either.
# MARCH: rv32i_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
TEST_TRAPS
    lui x0, 1                         # marker
    addi t1, x0, 0
    ecall                             # the trap: its handler's first instruction (the table's j trap_resume) 4 cycles later
    addi t1, t1, 1                    # resumed here by the handler's mret: 3 cycles after the mret
    jal t2, 1f                        # a jump, for comparison: its target 2 cycles later
    addi t1, t1, 4                    # skipped
1:  addi t1, t1, 2
    addi t3, x0, 3
    bne t1, t3, fail                  # the resume landed on the addi after the ecall, the jal skipped one (fail: test.h's)
    lui x0, 2                         # marker
TEST_END
TEST_TRAP_RESUME
    .section .data
    .align 12
tdata:
    .word 0
TEST_HTIF
