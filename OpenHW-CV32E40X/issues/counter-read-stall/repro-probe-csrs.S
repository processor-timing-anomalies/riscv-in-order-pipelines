// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro-probe-csrs -- a probe: which CSRs cost the extra cycle when read straight-line.  On cv32e40x (30 Sep 2026)
# mcycle, mcycleh, minstret, minstreth and mhpmcounter3 retire 2 cycles after the instruction before them; mscratch
# and mcountinhibit 1, as the cycle table gives every CSR but jvt.  Builds and runs on its own (Makefile); exit 0.
# MARCH: rv32i_zicsr_zifencei
#include "test.h"
    TEST_BEGIN
    .option norvc
    addi a1, zero, 1
    addi a1, zero, 2
    csrrs a2, mcycle, zero
    addi a1, zero, 3
    addi a1, zero, 4
    csrrs a2, mcycleh, zero
    addi a1, zero, 5
    addi a1, zero, 6
    csrrs a2, minstret, zero
    addi a1, zero, 7
    addi a1, zero, 8
    csrrs a2, minstreth, zero
    addi a1, zero, 9
    addi a1, zero, 10
    csrrs a2, mscratch, zero
    addi a1, zero, 11
    addi a1, zero, 12
    csrrs a2, mhpmcounter3, zero
    addi a1, zero, 13
    addi a1, zero, 14
    csrrw zero, mscratch, a1
    addi a1, zero, 15
    csrrs a2, mcountinhibit, zero
    addi a1, zero, 16
    nop
    TEST_END
    TEST_HTIF
