# repro.S -- the whole test pmp-disabled-csrs, kept as it ran (no cut-down reproducer: a confirmation capture, the window 7-39 marked by hand).
# the window: orders 7-39 of the run -- orders 8 and 24: a csrr of pmpcfg0 and of pmpaddr0 on a build with PMPEnable = 0 each raise an illegal-instruction exception (mcause 2), the handler resuming behind them; the manual says the registers read as zero
// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# pmp-disabled-csrs.S -- the reproducer of pmp-disabled-csrs-illegal, written by hand (1 Nov 2026) for a build with
# PMPEnable = 0: the manual says the PMP registers read as zero; the core raises an illegal-instruction exception on
# every access of them.  Two reads, each trapping (mcause 2) and resumed by the handler behind it; t4 counts the
# resumes.
# MARCH: rv32i_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
TEST_TRAPS
    lui x0, 1                         # marker
    addi t4, x0, 0
    csrr t2, pmpcfg0                  # illegal instruction on a build without PMP, not a read of zero
    addi t4, t4, 1                    # resumed here
    csrr t3, pmpaddr0                 # the same
    addi t4, t4, 1                    # resumed here
    addi t1, x0, 2
    bne t4, t1, fail                  # both resumed (fail: test.h's)
    lui x0, 2                         # marker
TEST_END
TEST_TRAP_RESUME
    .section .data
    .align 12
tdata:
    .word 0
TEST_HTIF
