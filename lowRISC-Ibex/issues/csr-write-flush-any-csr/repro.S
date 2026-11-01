# repro.S -- the whole test csr-write-flush-any-csr, kept as it ran (no cut-down reproducer: a confirmation capture, the window 4-41 marked by hand).
# the window: orders 4-41 of the run -- one CSR access per block, three addi behind it: csrrw of mscratch (orders 4-6) leaves the addi at 1 cycle; csrrw of mcycle, minstret, mcountinhibit, mhpmevent3, mtval, mcause and mcounteren (orders 9-41) each put the addi behind at 3 cycles, the two bubble cycles of the flush, though none of them changes anything an instruction in flight depends on; the reads behind (orders 44-61: csrrs x0, csrrsi 0, csrrc x0, csrr) flush nothing
// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# csr-write-flush-any-csr.S -- the probe of csr-write-flush-any-csr, written by hand (1 Nov 2026): one CSR access per
# block, three independent addi behind it, the cycles of the first addi read: a write of mscratch (no flush: the
# baseline), then writes of CSRs that change nothing an instruction in flight depends on -- mcycle, minstret,
# mcountinhibit, mhpmevent3, mtval, mcause, mcounteren -- and reads with no write (csrrs x0 and csrrsi 0 of mstatus,
# csrrc x0 of mie).  The flush shows as the addi behind the write retiring 3 cycles after it instead of 1.
# MARCH: rv32i_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
    addi t1, x0, 0
    lui x0, 1                         # marker: block 1, mscratch (no flush)
    csrrw x0, mscratch, t1
    addi t2, x0, 1
    addi t3, x0, 2
    addi t4, x0, 3
    lui x0, 2                         # block 2, mcycle
    csrrw x0, mcycle, t1
    addi t2, x0, 1
    addi t3, x0, 2
    addi t4, x0, 3
    lui x0, 3                         # block 3, minstret
    csrrw x0, minstret, t1
    addi t2, x0, 1
    addi t3, x0, 2
    addi t4, x0, 3
    lui x0, 4                         # block 4, mcountinhibit
    csrrw x0, mcountinhibit, t1
    addi t2, x0, 1
    addi t3, x0, 2
    addi t4, x0, 3
    lui x0, 5                         # block 5, mhpmevent3
    csrrw x0, mhpmevent3, t1
    addi t2, x0, 1
    addi t3, x0, 2
    addi t4, x0, 3
    lui x0, 6                         # block 6, mtval
    csrrw x0, mtval, t1
    addi t2, x0, 1
    addi t3, x0, 2
    addi t4, x0, 3
    lui x0, 7                         # block 7, mcause
    csrrw x0, mcause, t1
    addi t2, x0, 1
    addi t3, x0, 2
    addi t4, x0, 3
    lui x0, 8                         # block 8, mcounteren
    csrrw x0, mcounteren, t1
    addi t2, x0, 1
    addi t3, x0, 2
    addi t4, x0, 3
    lui x0, 9                         # block 9, a read of mstatus (csrrs x0: no write)
    csrrs x0, mstatus, x0
    addi t2, x0, 1
    addi t3, x0, 2
    addi t4, x0, 3
    lui x0, 10                        # block 10, a read of mstatus (csrrsi 0: no write)
    csrrsi x0, mstatus, 0
    addi t2, x0, 1
    addi t3, x0, 2
    addi t4, x0, 3
    lui x0, 11                        # block 11, a read of mie (csrrc x0: no write)
    csrrc x0, mie, x0
    addi t2, x0, 1
    addi t3, x0, 2
    addi t4, x0, 3
    lui x0, 12                        # block 12, a read into a register (csrr)
    csrrs t5, mscratch, x0
    addi t2, x0, 1
    addi t3, x0, 2
    addi t4, x0, 3
    lui x0, 13                        # marker: end
TEST_END
    .section .data
    .align 12
tdata:
    .word 0
TEST_HTIF
