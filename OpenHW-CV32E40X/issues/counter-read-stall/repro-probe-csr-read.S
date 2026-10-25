// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro-probe-csr-read -- a probe: a CSR read at distance 1-3 behind a taken jalr, mcycle against mscratch and
# minstret (cases E-K).  On cv32e40x (30 Sep 2026) a read of mcycle or minstret retires 2 cycles after the instruction
# before it where the cycle table gives a CSR read 1 (cases G, I, J, K); right behind the jump (F) it costs 1, the
# jump's bubble having emptied the write-back stage; mscratch costs 1 everywhere (E, H).  Builds and runs on its own
# (Makefile); exit 0.
# MARCH: rv32i_zicsr_zifencei
#include "test.h"
    TEST_BEGIN
    .option norvc
    la      t0, t_E
    jalr    x0, 0(t0)
    .balign 16
t_E:                           # E: jump, then csrrs mscratch at d1
    csrrs a2, mscratch, zero
    nop
    nop
    la      t0, t_F
    nop
    nop
    jalr    x0, 0(t0)
    .balign 16
t_F:                           # F: jump, then csrrs mcycle at d1
    csrrs a2, mcycle, zero
    nop
    nop
    la      t0, t_G
    nop
    nop
    jalr    x0, 0(t0)
    .balign 16
t_G:                           # G: jump, addi, then csrrs mcycle at d2
    addi a1, zero, 1
    csrrs a2, mcycle, zero
    nop
    nop
    la      t0, t_H
    nop
    nop
    jalr    x0, 0(t0)
    .balign 16
t_H:                           # H: jump, addi, then csrrs mscratch at d2
    addi a1, zero, 1
    csrrs a2, mscratch, zero
    nop
    nop
    la      t0, t_I
    nop
    nop
    jalr    x0, 0(t0)
    .balign 16
t_I:                           # I: jump, addi, then csrrs minstret at d2
    addi a1, zero, 1
    csrrs a2, minstret, zero
    nop
    nop
    la      t0, t_J
    nop
    nop
    jalr    x0, 0(t0)
    .balign 16
t_J:                           # J: jump, addi, addi, then csrrs mcycle at d3
    addi a1, zero, 1
    addi a3, zero, 1
    csrrs a2, mcycle, zero
    nop
    nop
    la      t0, t_K
    nop
    nop
    jalr    x0, 0(t0)
    .balign 16
t_K:                           # K: no jump: addi, addi, csrrs mcycle
    addi a1, zero, 1
    addi a3, zero, 1
    csrrs a2, mcycle, zero
    nop
    nop
    TEST_END
    TEST_HTIF
