// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the whole test clic-csr-after-implicit-write-stall, kept as it ran (no cut-down reproducer: a confirmation capture, the window 8-9 marked by hand).
# the window: orders 8-9 of the run -- in CLIC mode a write of mintthresh one behind csrrw rd, mscratchcswl, rs1 retires in 2 cycles where it takes 1 behind an explicit write of mscratch (orders 33-34): the mscratchcswl access writes mscratch implicitly and the core holds every explicit CSR access in EX while that implicit write is in WB, whether or not the access names a register the swap touches; a write of mscratch one behind it (orders 14-15) 2, a read of mintthresh (orders 20-21) 2, a write of mintthresh two behind it (orders 26-28) 1
# clic-csr-after-implicit-write-stall.S -- the reproducer of clic-csr-after-implicit-write-stall, written by hand
# (29 Oct 2026), for the CLIC build: a CSR instruction one behind csrrw rd, mscratchcswl, rs1 retires in 2 cycles,
# whatever CSR it names and whether it reads or writes (mintthresh, which the swap does not touch; mscratch, which
# it does; the read form csrrs rd, mintthresh, x0), where one behind an explicit write of mscratch it takes 1; two
# behind the mscratchcswl access it takes 1.  The access writes mscratch implicitly and the core holds every explicit
# CSR access in EX while that implicit write is in WB.
# MARCH: rv32i_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
    .option norelax
TEST_BEGIN
    addi x19, x0, 1                   # the mscratchcswl access's operand
    addi x18, x0, 0                   # the mintthresh value: unchanged
    lui x0, 1                         # marker
    lui x6, 2                         # fillers: nothing older in flight
    lui x7, 3
    lui x28, 4
    csrrw x20, 0x349, x19             # the mscratchcswl access: an implicit write of mscratch
    csrrw x21, 0x347, x18             # a write of mintthresh one behind it: 2 cycles
    lui x0, 2                         # marker
    lui x6, 5
    lui x7, 6
    lui x28, 7
    csrrw x20, 0x349, x19             # the mscratchcswl access
    csrrw x21, mscratch, x18          # a write of mscratch one behind it: 2 cycles
    lui x0, 3                         # marker
    lui x6, 8
    lui x7, 9
    lui x28, 10
    csrrw x20, 0x349, x19             # the mscratchcswl access
    csrrs x21, 0x347, x0              # a read of mintthresh one behind it: 2 cycles
    lui x0, 4                         # marker
    lui x6, 11
    lui x7, 12
    lui x28, 13
    csrrw x20, 0x349, x19             # the mscratchcswl access
    lui x29, 14
    csrrw x21, 0x347, x18             # a write of mintthresh two behind it: 1 cycle
    lui x0, 5                         # marker
    lui x6, 15
    lui x7, 16
    lui x28, 17
    csrrw x20, mscratch, x19          # an explicit write of mscratch
    csrrw x21, 0x347, x18             # a write of mintthresh one behind it: 1 cycle
    lui x0, 6                         # marker
TEST_END
    .section .data
    .align 12
tdata:
    .word 0
TEST_HTIF
