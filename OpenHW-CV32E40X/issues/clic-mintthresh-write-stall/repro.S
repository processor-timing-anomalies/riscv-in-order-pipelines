// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the whole test clic-mintthresh-write-stall, kept as it ran (no cut-down reproducer: a confirmation capture, the window 11-12 marked by hand).
# the window: orders 11-12 of the run -- in CLIC mode a load one behind a write of mintthresh (csrrs x0, mintthresh, rs1) retires in 2 cycles where a load takes 1: the write may enable an interrupt and the core holds the load in EX while the writer is in WB; a store one behind the same write (orders 17-18) likewise 2; one behind a write of mscratch (orders 23-24) the load takes 1
# clic-mintthresh-write-stall.S -- the reproducer of clic-mintthresh-write-stall, written by hand (29 Oct 2026), for
# the CLIC build: a load or store one behind a write of mintthresh retires in 2 cycles where it takes 1 behind a write
# of mscratch: the write may enable an interrupt (it lowers the threshold), so the core holds the load or store in EX
# while the writer is in WB, as it does behind a write of mstatus.  The Hazards list has no row for it.
# MARCH: rv32i_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
    .option norelax
TEST_BEGIN
    la   x13, w0
    addi x21, x0, 0                   # the mintthresh value: unchanged
    addi x12, x0, 289                 # the loads' rd before
    addi x14, x0, 343                 # the store's data
    lui x0, 1                         # marker
    lui x28, 2                        # fillers: nothing older in flight
    lui x29, 3
    lui x6, 4
    csrrs x0, 0x347, x21              # a write of mintthresh (rs1 not x0)
    lhu  x12, 0(x13)                  # a load one behind it: 2 cycles
    lui x0, 2                         # marker
    lui x28, 5
    lui x29, 6
    lui x6, 7
    csrrs x0, 0x347, x21              # a write of mintthresh
    sb   x14, 4(x13)                  # a store one behind it: 2 cycles
    lui x0, 3                         # marker
    lui x28, 8
    lui x29, 9
    lui x6, 10
    csrrs x0, mscratch, x21           # a write of mscratch
    lhu  x12, 0(x13)                  # a load one behind it: 1 cycle
    lui x0, 4                         # marker
TEST_END
    .section .data
    .align 12
tdata:
w0: .word 0x11a
    .word 0
TEST_HTIF
