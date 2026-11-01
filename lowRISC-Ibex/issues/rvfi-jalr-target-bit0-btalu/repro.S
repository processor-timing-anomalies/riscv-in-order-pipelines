# repro.S -- the whole test rvfi-jalr-odd-target, kept as it ran (no cut-down reproducer: a confirmation capture, the window 7-7 marked by hand).
# the window: orders 7-7 of the run -- order 7, jalr t5, 1(t0) with t0 = the even address of target: the core jumps to target (order 8 retires there, rvfi_pc_rdata even); before the harness mask of 29 Oct 2026 the RTL's rvfi_pc_wdata on this jalr read the odd sum target + 1 against the reference's even address (the compare of act4's I-jalr-00, Zca-c.jalr-00 and Zca-c.jr-00 on ibex-maxperf, 3 FAIL); these traces are after the mask, both even
// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# rvfi-jalr-odd-target.S -- the reproducer of rvfi-jalr-target-bit0-btalu, written by hand (29 Oct 2026): a jalr whose
# rs1 + imm is odd.  The core jumps to the even address, as the ISA requires (bit 0 of the target is cleared), and the
# program passes; with BranchTargetALU = 1 the RVFI's rvfi_pc_wdata of the jalr reads the odd sum (0x...5 where the
# next retirement is at 0x...4), with BranchTargetALU = 0 the even address.  Observe rvfi_pc_wdata on the jalr's
# retirement against the next instruction's rvfi_pc_rdata.
# MARCH: rv32i
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    lui x0, 1                         # marker
    la t0, target                     # t0 = the even address of `target`
    addi t1, x0, 0
    jalr t5, 1(t0)                    # the instruction under test: rs1 + imm = target + 1, odd; the core clears bit 0
    addi t1, t1, 1                    # skipped: the jump lands on `target`
    .align 2
target:
    addi t1, t1, 2                    # the next retirement: rvfi_pc_rdata is `target`, even
    la t2, target
    bne t2, t0, fail                  # t0 unchanged (fail: test.h's)
    addi t3, x0, 2
    bne t1, t3, fail                  # the skipped addi was skipped
    lui x0, 2                         # marker
TEST_END
    .section .data
    .align 12
tdata:
    .word 0
TEST_HTIF
