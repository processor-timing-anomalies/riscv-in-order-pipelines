# repro.S -- the whole test stale-load-use-check, kept as it ran (no cut-down reproducer: a confirmation capture, the window 8-9 marked by hand).
# the window: orders 8-9 of the run -- lui t3, 0x5 behind lw s3, 0(s3) with the ID stage empty: 3 cycles after the load, where the same lui behind lw s4, 0(s3) (order 14) takes 2; the load-use check fired on the load's own stale register fields
// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# stale-load-use-check.S -- the reproducer, written by hand: a load whose destination is its own address register, with the
# instruction behind it arriving from the instruction bus a cycle late, so the ID stage is empty while the load is in EX.
# Block A is the subject: lw x19, 0(x19) then an independent lui.  Block B is the control: the same load into x20 (rd != rs1),
# the same lui behind it.  Block C is the load with an instruction that reads its result, the case the manual's Hazards list
# gives one cycle to: under the same late fetch it pays the same one cycle, from the same check, since it too is not yet in ID.
# The fetch schedule (FSCHED, run.json fetch_schedule) withholds the instruction words; without a wait the lui is already in ID
# when the load enters EX, the check reads its real fields, and nothing shows.
# What the RTL did (9 Nov 2026, the instruction bus granting every fetch one cycle after its request): block A's lui 3 cycles
# MARCH: rv32imc
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    lui x0, 1   # marker:  aligns block 1 here
    la x19, tdata                     # x19 -> tdata, and tdata holds its own address: lw x19, 0(x19) leaves x19 unchanged
    lui x6, 2                         # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 3                         # quiet
    lui x28, 4                        # quiet
    lw x19, 0(x19)                    # A: the load, rd = rs1 = x19
    lui x28, 5                        # A: the subject, independent of the load; arrives late from the bus, finds ID empty
    lui x29, 6                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 7                         # quiet
    lui x7, 8                         # quiet
    lw x20, 0(x19)                    # B: the control, the same load with rd = x20 != rs1
    lui x29, 9                        # B: the same lui behind it
    lui x6, 10                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 11                        # quiet
    lui x28, 12                       # quiet
    lw x19, 0(x19)                    # C: the load again
    addi x21, x19, 1                  # C: reads the load's result (the manual's load data hazard); the same cycle, the same check
    lui x29, 13                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 14                        # quiet
    lui x7, 15                        # quiet
    li t5, 1
    la t6, tdata
    bne x19, t6, fail                 # x19 still holds tdata's address after the two loads
    bne x20, t6, fail
TEST_END
    .section .data
    .align 12
tdata:
    .word tdata
TEST_HTIF
