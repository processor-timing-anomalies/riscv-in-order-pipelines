# repro.S -- the whole test mpp-unsupported, kept as it ran (no cut-down reproducer: a confirmation capture, the window 8-9 marked by hand).
# the window: orders 8-9 of the run -- a write of the reserved value 2 to mstatus.MPP reads back 0 (User mode) where the manual says an unsupported MPP value is interpreted as Machine mode
// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# mpp-unsupported.S -- the reproducer of mpp-unsupported-reads-user, written by hand (6 Nov 2026): a write of the
# reserved value 2 to mstatus.MPP, then a read-back.  The manual (cs_registers.rst 168-169) says an unsupported MPP
# value is interpreted as Machine mode (3); the read-back shows what the core keeps.  MPP is restored to M after.
# MARCH: rv32i_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    lui x0, 1                         # marker
    lui t0, 0x2                       # t0 = 0x1800, the MPP field (bits 12:11)
    addi t0, t0, -0x800
    csrc mstatus, t0                  # MPP = 0
    lui t1, 0x1                       # t1 = 0x1000: MPP = 2, the reserved value
    csrs mstatus, t1                  # write MPP = 2
    csrr t2, mstatus                  # read back: the manual says MPP reads 3 (M)
    and t3, t2, t0                    # t3 = the MPP field as read back
    csrs mstatus, t0                  # restore MPP = 3 (M) for the harness
    lui x0, 2                         # marker
TEST_END
    .section .data
    .align 12
tdata:
    .word 0
TEST_HTIF
