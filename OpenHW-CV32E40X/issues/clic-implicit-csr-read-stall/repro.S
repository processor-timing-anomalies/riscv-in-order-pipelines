// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the whole test clic-implicit-csr-read-stall, kept as it ran (no cut-down reproducer: a confirmation capture, the window 10-11 marked by hand).
# the window: orders 10-11 of the run -- in CLIC mode a read of mnxti (csrrs rd, mnxti, x0) one behind a CSR instruction (a csrrc of mscratch) retires in 2 cycles where any other CSR instruction in that position takes 1 (a read of mtval, orders 22-23: 1): the core reads mstatus implicitly for mnxti and holds the access in EX while a CSR instruction is in WB; the access of mscratchcswl (csrrw rd, mscratchcswl, rs1) one behind a csrrs of mscratch (orders 16-17) likewise 2; the mnxti read two behind (orders 28-30) 1
# clic-implicit-csr-read-stall.S -- the reproducer of clic-implicit-csr-read-stall, written by hand (29 Oct 2026),
# for the CLIC build: an access of mnxti (csrrs rd, mnxti, x0) or of mscratchcswl (csrrw rd, mscratchcswl, rs1) one
# behind any CSR instruction retires in 2 cycles where any other CSR instruction in that position takes 1: the core
# reads another CSR implicitly for these two (mstatus for mnxti; mscratch, mcause and mintstatus for mscratchcswl)
# and holds the access in EX while a CSR instruction is in WB.  The Hazards list's implicit-read row names no
# instruction.  Two behind, the access takes 1.
# MARCH: rv32i_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
    .option norelax
TEST_BEGIN
    addi x18, x0, 1897                # the csrrc's operand
    addi x17, x0, 1904                # its rd before
    addi x23, x0, 1953                # the csrrs's operand
    addi x24, x0, 1960                # the mscratchcswl access's operand
    lui x0, 1                         # marker
    lui x29, 2                        # fillers: nothing older in flight
    lui x6, 3
    lui x7, 4
    csrrc x17, mscratch, x18          # a CSR instruction
    csrrs x16, 0x345, x0              # the mnxti read one behind it: 2 cycles
    lui x0, 2                         # marker
    lui x29, 5
    lui x6, 6
    lui x7, 7
    csrrs x22, mscratch, x23          # a CSR instruction
    csrrw x21, 0x349, x24             # the mscratchcswl access one behind it: 2 cycles
    lui x0, 3                         # marker
    lui x29, 8
    lui x6, 9
    lui x7, 10
    csrrc x17, mscratch, x18          # a CSR instruction
    csrrs x16, mtval, x0              # another CSR read one behind it: 1 cycle
    lui x0, 4                         # marker
    lui x29, 11
    lui x6, 12
    lui x7, 13
    csrrc x17, mscratch, x18          # a CSR instruction
    lui x28, 14
    csrrs x16, 0x345, x0              # the mnxti read two behind it: 1 cycle
    lui x0, 5                         # marker
TEST_END
    .section .data
    .align 12
tdata:
    .word 0
TEST_HTIF
