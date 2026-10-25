// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the whole test own-cv32e40x-clic-00, kept as it ran (no cut-down reproducer: a confirmation capture, the window 5048-5051 marked by hand).
# the window: orders 5048-5051 of the run -- the load one behind the write of mintthresh: 2 cycles where a load takes 1
# (rtl-questions.json): one block per row, CSR or subject, and class, from the row's match rule.
# LAYER: cv32e40x-clic
# MARCH: rv32ic_zicsr_zcb
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
# block 1  csr_counter_read_d1  csr_counter_read_d1__mcycle__alu_rr (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 1  # marker: block 1
    lui x6, 2                         # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 3                         # quiet
    lui x28, 4                        # quiet
    addi x8, x0, 1                    # mcountinhibit for mcycle: inhibited
    csrrw x0, mcountinhibit, x8       # mcountinhibit for mcycle: inhibited
    addi x10, x0, 263                 # c.add's operand
    addi x9, x0, 270                  # c.add's rd before (stale)
    lui x29, 5                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 6                         # quiet
    lui x7, 7                         # quiet
    .option push
    .option rvc
    c.add x9, x10                 # c.add: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x3, mcycle, x0              # subject csrrs: reads mcycle, d1 (csr_counter_read_d1)
    lui x28, 8                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 9                        # quiet
    lui x6, 10                        # quiet
    addi x3, x0, 284                  # x3 known again: it held the counter, which differs between the engines
# block 2  csr_counter_read_d1  csr_counter_read_d1__mcycle__alu_rr (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 2  # marker: block 2
    lui x7, 11                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 12                       # quiet
    lui x29, 13                       # quiet
    addi x12, x0, 0                   # mcountinhibit for mcycle: enabled
    csrrw x0, mcountinhibit, x12      # mcountinhibit for mcycle: enabled
    addi x15, x0, 291                 # c.and's operand
    addi x14, x0, 298                 # c.and's rd before (stale)
    lui x6, 14                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 15                        # quiet
    lui x28, 16                       # quiet
    .option push
    .option rvc
    c.and x14, x15                # c.and: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x11, mcycle, x0             # subject csrrs: reads mcycle, d1 (csr_counter_read_d1)
    lui x29, 17                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 18                        # quiet
    lui x7, 19                        # quiet
    addi x11, x0, 312                 # x11 known again: it held the counter, which differs between the engines
# block 3  csr_counter_read_d1  csr_counter_read_d1__mcycle__alu_rr (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 3  # marker: block 3
    lui x28, 20                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 21                       # quiet
    lui x6, 22                        # quiet
    addi x16, x0, 319                 # x16 = 319
    addi x18, x0, 326                 # c.mv's operand
    addi x17, x0, 333                 # c.mv's rd before (stale)
    lui x7, 23                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 24                       # quiet
    lui x29, 25                       # quiet
    .option push
    .option rvc
    c.mv x17, x18                 # c.mv: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrw x0, mcycle, x16             # subject csrrw: names mcycle and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x6, 26                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 27                        # quiet
    lui x28, 28                       # quiet
# block 4  csr_counter_read_d1  csr_counter_read_d1__mcycle__alu_ri (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 4  # marker: block 4
    lui x29, 29                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 30                        # quiet
    lui x7, 31                        # quiet
    addi x20, x0, 1                   # mcountinhibit for mcycle: inhibited
    csrrw x0, mcountinhibit, x20      # mcountinhibit for mcycle: inhibited
    addi x21, x0, 340                 # c.addi's rd before (stale)
    lui x28, 32                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 33                       # quiet
    lui x6, 34                        # quiet
    .option push
    .option rvc
    c.addi x21, 5                 # c.addi: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x19, mcycle, x0             # subject csrrs: reads mcycle, d1 (csr_counter_read_d1)
    lui x7, 35                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 36                       # quiet
    lui x29, 37                       # quiet
    addi x19, x0, 354                 # x19 known again: it held the counter, which differs between the engines
# block 5  csr_counter_read_d1  csr_counter_read_d1__mcycle__alu_ri (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 5  # marker: block 5
    lui x6, 38                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 39                        # quiet
    lui x28, 40                       # quiet
    addi x23, x0, 0                   # mcountinhibit for mcycle: enabled
    csrrw x0, mcountinhibit, x23      # mcountinhibit for mcycle: enabled
    addi x2, x0, 361                  # c.addi16sp's operand
    addi x2, x0, 368                  # c.addi16sp's rd before (stale)
    lui x29, 41                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 42                        # quiet
    lui x7, 43                        # quiet
    .option push
    .option rvc
    c.addi16sp sp, 16             # c.addi16sp: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x22, mcycle, x0             # subject csrrs: reads mcycle, d1 (csr_counter_read_d1)
    lui x28, 44                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 45                       # quiet
    lui x6, 46                        # quiet
    addi x22, x0, 389                 # x22 known again: it held the counter, which differs between the engines
# block 6  csr_counter_read_d1  csr_counter_read_d1__mcycle__alu_ri (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 6  # marker: block 6
    lui x7, 47                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 48                       # quiet
    lui x29, 49                       # quiet
    addi x25, x0, 396                 # x25 = 396
    addi x2, x0, 403                  # c.addi4spn's operand
    addi x11, x0, 410                 # c.addi4spn's rd before (stale)
    lui x6, 50                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 51                        # quiet
    lui x28, 52                       # quiet
    .option push
    .option rvc
    c.addi4spn x11, sp, 4         # c.addi4spn: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrw x0, mcycle, x25             # subject csrrw: names mcycle and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x29, 53                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 54                        # quiet
    lui x7, 55                        # quiet
# block 7  csr_counter_read_d1  csr_counter_read_d1__mcycle__alu_nosrc (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 7  # marker: block 7
    lui x28, 56                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 57                       # quiet
    lui x6, 58                        # quiet
    addi x3, x0, 1                    # mcountinhibit for mcycle: inhibited
    csrrw x0, mcountinhibit, x3       # mcountinhibit for mcycle: inhibited
    addi x8, x0, 424                  # c.li's rd before (stale)
    lui x7, 59                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 60                       # quiet
    lui x29, 61                       # quiet
    .option push
    .option rvc
    c.li x8, 5                    # c.li: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x27, mcycle, x0             # subject csrrs: reads mcycle, d1 (csr_counter_read_d1)
    lui x6, 62                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 63                        # quiet
    lui x28, 64                       # quiet
    addi x27, x0, 438                 # x27 known again: it held the counter, which differs between the engines
# block 8  csr_counter_read_d1  csr_counter_read_d1__mcycle__alu_nosrc (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 8  # marker: block 8
    lui x29, 65                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 66                        # quiet
    lui x7, 67                        # quiet
    addi x10, x0, 0                   # mcountinhibit for mcycle: enabled
    csrrw x0, mcountinhibit, x10      # mcountinhibit for mcycle: enabled
    addi x11, x0, 445                 # c.lui's rd before (stale)
    lui x28, 68                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 69                       # quiet
    lui x6, 70                        # quiet
    .option push
    .option rvc
    c.lui x11, 5                  # c.lui: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x9, mcycle, x0              # subject csrrs: reads mcycle, d1 (csr_counter_read_d1)
    lui x7, 71                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 72                       # quiet
    lui x29, 73                       # quiet
    addi x9, x0, 459                  # x9 known again: it held the counter, which differs between the engines
# block 9  csr_counter_read_d1  csr_counter_read_d1__mcycle__alu_nosrc (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 9  # marker: block 9
    lui x6, 74                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 75                        # quiet
    lui x28, 76                       # quiet
    addi x13, x0, 466                 # x13 = 466
    addi x14, x0, 473                 # auipc's rd before (stale)
    lui x29, 77                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 78                        # quiet
    lui x7, 79                        # quiet
    auipc x14, 74565                  # auipc: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mcycle, x13             # subject csrrw: names mcycle and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 80                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 81                       # quiet
    lui x6, 82                        # quiet
# block 10  csr_counter_read_d1  csr_counter_read_d1__mcycle__load (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 10  # marker: block 10
    lui x7, 83                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 84                       # quiet
    lui x29, 85                       # quiet
    addi x18, x0, 1                   # mcountinhibit for mcycle: inhibited
    csrrw x0, mcountinhibit, x18      # mcountinhibit for mcycle: inhibited
    .L1: auipc x12, %pcrel_hi(w0)     # c.lbu's base -> w0
    lui x6, 86                        # c.lbu's base -> w0 (quiet)
    lui x7, 87                        # c.lbu's base -> w0 (quiet)
    lui x28, 88                       # c.lbu's base -> w0 (quiet)
    addi x12, x12, %pcrel_lo(.L1)     # c.lbu's base -> w0
    addi x11, x0, 767                 # c.lbu's rd before (stale)
    lui x29, 89                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 90                        # quiet
    lui x7, 91                        # quiet
    .option push
    .option rvc
    c.lbu x11, 0(x12)             # c.lbu: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x17, mcycle, x0             # subject csrrs: reads mcycle, d1 (csr_counter_read_d1)
    lui x28, 92                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 93                       # quiet
    lui x6, 94                        # quiet
    addi x17, x0, 781                 # x17 known again: it held the counter, which differs between the engines
# block 11  csr_counter_read_d1  csr_counter_read_d1__mcycle__load (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 11  # marker: block 11
    lui x7, 95                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 96                       # quiet
    lui x29, 97                       # quiet
    addi x22, x0, 0                   # mcountinhibit for mcycle: enabled
    csrrw x0, mcountinhibit, x22      # mcountinhibit for mcycle: enabled
    .L2: auipc x8, %pcrel_hi(w1)      # c.lh's base -> w1
    lui x6, 98                        # c.lh's base -> w1 (quiet)
    lui x7, 99                        # c.lh's base -> w1 (quiet)
    lui x28, 100                      # c.lh's base -> w1 (quiet)
    addi x8, x8, %pcrel_lo(.L2)       # c.lh's base -> w1
    addi x15, x0, 795                 # c.lh's rd before (stale)
    lui x29, 101                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 102                       # quiet
    lui x7, 103                       # quiet
    .option push
    .option rvc
    c.lh x15, 0(x8)               # c.lh: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x21, mcycle, x0             # subject csrrs: reads mcycle, d1 (csr_counter_read_d1)
    lui x28, 104                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 105                      # quiet
    lui x6, 106                       # quiet
    addi x21, x0, 809                 # x21 known again: it held the counter, which differs between the engines
# block 12  csr_counter_read_d1  csr_counter_read_d1__mcycle__load (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 12  # marker: block 12
    lui x7, 107                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 108                      # quiet
    lui x29, 109                      # quiet
    addi x26, x0, 816                 # x26 = 816
    .L3: auipc x12, %pcrel_hi(w2)     # c.lhu's base -> w2
    lui x6, 110                       # c.lhu's base -> w2 (quiet)
    lui x7, 111                       # c.lhu's base -> w2 (quiet)
    lui x28, 112                      # c.lhu's base -> w2 (quiet)
    addi x12, x12, %pcrel_lo(.L3)     # c.lhu's base -> w2
    addi x11, x0, 830                 # c.lhu's rd before (stale)
    lui x29, 113                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 114                       # quiet
    lui x7, 115                       # quiet
    .option push
    .option rvc
    c.lhu x11, 0(x12)             # c.lhu: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrw x0, mcycle, x26             # subject csrrw: names mcycle and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 116                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 117                      # quiet
    lui x6, 118                       # quiet
# block 13  csr_counter_read_d1  csr_counter_read_d1__mcycle__store (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 13  # marker: block 13
    lui x7, 119                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 120                      # quiet
    lui x29, 121                      # quiet
    addi x9, x0, 1                    # mcountinhibit for mcycle: inhibited
    csrrw x0, mcountinhibit, x9       # mcountinhibit for mcycle: inhibited
    .L4: auipc x15, %pcrel_hi(w3)     # c.sb's base -> w3
    lui x6, 122                       # c.sb's base -> w3 (quiet)
    lui x7, 123                       # c.sb's base -> w3 (quiet)
    lui x28, 124                      # c.sb's base -> w3 (quiet)
    addi x15, x15, %pcrel_lo(.L4)     # c.sb's base -> w3
    addi x10, x0, 844                 # c.sb's store data
    lui x29, 125                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 126                       # quiet
    lui x7, 127                       # quiet
    .option push
    .option rvc
    c.sb x10, 0(x15)              # c.sb: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x8, mcycle, x0              # subject csrrs: reads mcycle, d1 (csr_counter_read_d1)
    lui x28, 128                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 129                      # quiet
    lui x6, 130                       # quiet
    addi x8, x0, 858                  # x8 known again: it held the counter, which differs between the engines
# block 14  csr_counter_read_d1  csr_counter_read_d1__mcycle__store (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 14  # marker: block 14
    lui x7, 131                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 132                      # quiet
    lui x29, 133                      # quiet
    addi x15, x0, 0                   # mcountinhibit for mcycle: enabled
    csrrw x0, mcountinhibit, x15      # mcountinhibit for mcycle: enabled
    .L5: auipc x13, %pcrel_hi(w4)     # c.sh's base -> w4
    lui x6, 134                       # c.sh's base -> w4 (quiet)
    lui x7, 135                       # c.sh's base -> w4 (quiet)
    lui x28, 136                      # c.sh's base -> w4 (quiet)
    addi x13, x13, %pcrel_lo(.L5)     # c.sh's base -> w4
    addi x8, x0, 872                  # c.sh's store data
    lui x29, 137                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 138                       # quiet
    lui x7, 139                       # quiet
    .option push
    .option rvc
    c.sh x8, 0(x13)               # c.sh: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x14, mcycle, x0             # subject csrrs: reads mcycle, d1 (csr_counter_read_d1)
    lui x28, 140                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 141                      # quiet
    lui x6, 142                       # quiet
    addi x14, x0, 886                 # x14 known again: it held the counter, which differs between the engines
# block 15  csr_counter_read_d1  csr_counter_read_d1__mcycle__store (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 15  # marker: block 15
    lui x7, 143                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 144                      # quiet
    lui x29, 145                      # quiet
    addi x21, x0, 893                 # x21 = 893
    .L6: auipc x11, %pcrel_hi(w5)     # c.sw's base -> w5
    lui x6, 146                       # c.sw's base -> w5 (quiet)
    lui x7, 147                       # c.sw's base -> w5 (quiet)
    lui x28, 148                      # c.sw's base -> w5 (quiet)
    addi x11, x11, %pcrel_lo(.L6)     # c.sw's base -> w5
    addi x12, x0, 907                 # c.sw's store data
    lui x29, 149                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 150                       # quiet
    lui x7, 151                       # quiet
    .option push
    .option rvc
    c.sw x12, 0(x11)              # c.sw: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrw x0, mcycle, x21             # subject csrrw: names mcycle and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 152                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 153                      # quiet
    lui x6, 154                       # quiet
# block 16  csr_counter_read_d1  csr_counter_read_d1__mcycle__csr_r (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 16  # marker: block 16
    lui x7, 155                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 156                      # quiet
    lui x29, 157                      # quiet
    addi x25, x0, 1                   # mcountinhibit for mcycle: inhibited
    csrrw x0, mcountinhibit, x25      # mcountinhibit for mcycle: inhibited
    addi x27, x0, 914                 # csrrc's operand
    addi x26, x0, 921                 # csrrc's rd before (stale)
    lui x6, 158                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 159                       # quiet
    lui x28, 160                      # quiet
    csrrc x26, mscratch, x27          # csrrc: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x24, mcycle, x0             # subject csrrs: reads mcycle, d1 (csr_counter_read_d1)
    lui x29, 161                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 162                       # quiet
    lui x7, 163                       # quiet
    addi x24, x0, 935                 # x24 known again: it held the counter, which differs between the engines
# block 17  csr_counter_read_d1  csr_counter_read_d1__mcycle__csr_r (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 17  # marker: block 17
    lui x28, 164                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 165                      # quiet
    lui x6, 166                       # quiet
    addi x8, x0, 0                    # mcountinhibit for mcycle: enabled
    csrrw x0, mcountinhibit, x8       # mcountinhibit for mcycle: enabled
    addi x10, x0, 942                 # csrrs's operand
    addi x9, x0, 949                  # csrrs's rd before (stale)
    lui x7, 167                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 168                      # quiet
    lui x29, 169                      # quiet
    csrrs x9, mscratch, x10           # csrrs: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x3, mcycle, x0              # subject csrrs: reads mcycle, d1 (csr_counter_read_d1)
    lui x6, 170                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 171                       # quiet
    lui x28, 172                      # quiet
    addi x3, x0, 963                  # x3 known again: it held the counter, which differs between the engines
# block 18  csr_counter_read_d1  csr_counter_read_d1__mcycle__csr_r (after_write)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 18  # marker: block 18
    lui x29, 173                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 174                       # quiet
    lui x7, 175                       # quiet
    addi x12, x0, 970                 # x12 = 970
    lui x28, 176                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 177                      # quiet
    lui x6, 178                       # quiet
    csrrw x0, mcycle, x12             # csrrw: writes mcycle, the counter the subject reads
    csrrs x11, mcycle, x0             # subject csrrs: reads mcycle, d1 (csr_counter_read_d1)
    lui x7, 179                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 180                      # quiet
    lui x29, 181                      # quiet
    addi x11, x0, 984                 # x11 known again: it held the counter, which differs between the engines
# block 19  csr_counter_read_d1  csr_counter_read_d1__mcycle__csr_r (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 19  # marker: block 19
    lui x6, 182                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 183                       # quiet
    lui x28, 184                      # quiet
    addi x14, x0, 991                 # x14 = 991
    addi x16, x0, 998                 # csrrc's operand
    addi x15, x0, 1005                # csrrc's rd before (stale)
    lui x29, 185                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 186                       # quiet
    lui x7, 187                       # quiet
    csrrc x15, mscratch, x16          # csrrc: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mcycle, x14             # subject csrrw: names mcycle and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 188                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 189                      # quiet
    lui x6, 190                       # quiet
# block 20  csr_counter_read_d1  csr_counter_read_d1__mcycle__csr_i (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 20  # marker: block 20
    lui x7, 191                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 192                      # quiet
    lui x29, 193                      # quiet
    addi x18, x0, 1                   # mcountinhibit for mcycle: inhibited
    csrrw x0, mcountinhibit, x18      # mcountinhibit for mcycle: inhibited
    addi x19, x0, 1012                # csrrci's rd before (stale)
    lui x6, 194                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 195                       # quiet
    lui x28, 196                      # quiet
    csrrci x19, mscratch, 7           # csrrci: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x17, mcycle, x0             # subject csrrs: reads mcycle, d1 (csr_counter_read_d1)
    lui x29, 197                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 198                       # quiet
    lui x7, 199                       # quiet
    addi x17, x0, 1026                # x17 known again: it held the counter, which differs between the engines
# block 21  csr_counter_read_d1  csr_counter_read_d1__mcycle__csr_i (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 21  # marker: block 21
    lui x28, 200                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 201                      # quiet
    lui x6, 202                       # quiet
    addi x21, x0, 0                   # mcountinhibit for mcycle: enabled
    csrrw x0, mcountinhibit, x21      # mcountinhibit for mcycle: enabled
    addi x22, x0, 1033                # csrrsi's rd before (stale)
    lui x7, 203                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 204                      # quiet
    lui x29, 205                      # quiet
    csrrsi x22, mscratch, 7           # csrrsi: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x20, mcycle, x0             # subject csrrs: reads mcycle, d1 (csr_counter_read_d1)
    lui x6, 206                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 207                       # quiet
    lui x28, 208                      # quiet
    addi x20, x0, 1047                # x20 known again: it held the counter, which differs between the engines
# block 22  csr_counter_read_d1  csr_counter_read_d1__mcycle__csr_i (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 22  # marker: block 22
    lui x29, 209                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 210                       # quiet
    lui x7, 211                       # quiet
    addi x24, x0, 1054                # x24 = 1054
    addi x25, x0, 1061                # csrrwi's rd before (stale)
    lui x28, 212                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 213                      # quiet
    lui x6, 214                       # quiet
    csrrwi x25, mscratch, 7           # csrrwi: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mcycle, x24             # subject csrrw: names mcycle and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x7, 215                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 216                      # quiet
    lui x29, 217                      # quiet
# block 23  csr_counter_read_d1  csr_counter_read_d1__mcycleh__alu_rr (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 23  # marker: block 23
    lui x6, 218                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 219                       # quiet
    lui x28, 220                      # quiet
    addi x27, x0, 1                   # mcountinhibit for mcycleh: inhibited
    csrrw x0, mcountinhibit, x27      # mcountinhibit for mcycleh: inhibited
    addi x15, x0, 1068                # c.or's operand
    addi x14, x0, 1075                # c.or's rd before (stale)
    lui x29, 221                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 222                       # quiet
    lui x7, 223                       # quiet
    .option push
    .option rvc
    c.or x14, x15                 # c.or: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x26, mcycleh, x0            # subject csrrs: reads mcycleh, d1 (csr_counter_read_d1)
    lui x28, 224                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 225                      # quiet
    lui x6, 226                       # quiet
    addi x26, x0, 1089                # x26 known again: it held the counter, which differs between the engines
# block 24  csr_counter_read_d1  csr_counter_read_d1__mcycleh__alu_rr (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 24  # marker: block 24
    lui x7, 227                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 228                      # quiet
    lui x29, 229                      # quiet
    addi x10, x0, 0                   # mcountinhibit for mcycleh: enabled
    csrrw x0, mcountinhibit, x10      # mcountinhibit for mcycleh: enabled
    addi x12, x0, 1096                # c.sub's operand
    addi x11, x0, 1103                # c.sub's rd before (stale)
    lui x6, 230                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 231                       # quiet
    lui x28, 232                      # quiet
    .option push
    .option rvc
    c.sub x11, x12                # c.sub: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x9, mcycleh, x0             # subject csrrs: reads mcycleh, d1 (csr_counter_read_d1)
    lui x29, 233                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 234                       # quiet
    lui x7, 235                       # quiet
    addi x9, x0, 1117                 # x9 known again: it held the counter, which differs between the engines
# block 25  csr_counter_read_d1  csr_counter_read_d1__mcycleh__alu_rr (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 25  # marker: block 25
    lui x28, 236                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 237                      # quiet
    lui x6, 238                       # quiet
    addi x15, x0, 1124                # x15 = 1124
    addi x9, x0, 1131                 # c.xor's operand
    addi x8, x0, 1138                 # c.xor's rd before (stale)
    lui x7, 239                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 240                      # quiet
    lui x29, 241                      # quiet
    .option push
    .option rvc
    c.xor x8, x9                  # c.xor: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrw x0, mcycleh, x15            # subject csrrw: names mcycleh and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x6, 242                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 243                       # quiet
    lui x28, 244                      # quiet
# block 26  csr_counter_read_d1  csr_counter_read_d1__mcycleh__alu_ri (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 26  # marker: block 26
    lui x29, 245                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 246                       # quiet
    lui x7, 247                       # quiet
    addi x20, x0, 1                   # mcountinhibit for mcycleh: inhibited
    csrrw x0, mcountinhibit, x20      # mcountinhibit for mcycleh: inhibited
    addi x12, x0, 1145                # c.andi's rd before (stale)
    lui x28, 248                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 249                      # quiet
    lui x6, 250                       # quiet
    .option push
    .option rvc
    c.andi x12, 5                 # c.andi: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x19, mcycleh, x0            # subject csrrs: reads mcycleh, d1 (csr_counter_read_d1)
    lui x7, 251                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 252                      # quiet
    lui x29, 253                      # quiet
    addi x19, x0, 1159                # x19 known again: it held the counter, which differs between the engines
# block 27  csr_counter_read_d1  csr_counter_read_d1__mcycleh__alu_ri (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 27  # marker: block 27
    lui x6, 254                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 255                       # quiet
    lui x28, 256                      # quiet
    addi x23, x0, 0                   # mcountinhibit for mcycleh: enabled
    csrrw x0, mcountinhibit, x23      # mcountinhibit for mcycleh: enabled
    addi x15, x0, 1166                # c.not's rd before (stale)
    lui x29, 257                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 258                       # quiet
    lui x7, 259                       # quiet
    .option push
    .option rvc
    c.not x15                     # c.not: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x22, mcycleh, x0            # subject csrrs: reads mcycleh, d1 (csr_counter_read_d1)
    lui x28, 260                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 261                      # quiet
    lui x6, 262                       # quiet
    addi x22, x0, 1180                # x22 known again: it held the counter, which differs between the engines
# block 28  csr_counter_read_d1  csr_counter_read_d1__mcycleh__alu_ri (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 28  # marker: block 28
    lui x7, 263                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 264                      # quiet
    lui x29, 265                      # quiet
    addi x26, x0, 1187                # x26 = 1187
    addi x27, x0, 1194                # c.slli's rd before (stale)
    lui x6, 266                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 267                       # quiet
    lui x28, 268                      # quiet
    .option push
    .option rvc
    c.slli x27, 3                 # c.slli: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrw x0, mcycleh, x26            # subject csrrw: names mcycleh and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x29, 269                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 270                       # quiet
    lui x7, 271                       # quiet
# block 29  csr_counter_read_d1  csr_counter_read_d1__mcycleh__alu_nosrc (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 29  # marker: block 29
    lui x28, 272                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 273                      # quiet
    lui x6, 274                       # quiet
    addi x8, x0, 1                    # mcountinhibit for mcycleh: inhibited
    csrrw x0, mcountinhibit, x8       # mcountinhibit for mcycleh: inhibited
    addi x9, x0, 1201                 # lui's rd before (stale)
    lui x7, 275                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 276                      # quiet
    lui x29, 277                      # quiet
    lui x9, 74565                     # lui: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x3, mcycleh, x0             # subject csrrs: reads mcycleh, d1 (csr_counter_read_d1)
    lui x6, 278                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 279                       # quiet
    lui x28, 280                      # quiet
    addi x3, x0, 1215                 # x3 known again: it held the counter, which differs between the engines
# block 30  csr_counter_read_d1  csr_counter_read_d1__mcycleh__alu_nosrc (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 30  # marker: block 30
    lui x29, 281                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 282                       # quiet
    lui x7, 283                       # quiet
    addi x11, x0, 0                   # mcountinhibit for mcycleh: enabled
    csrrw x0, mcountinhibit, x11      # mcountinhibit for mcycleh: enabled
    addi x12, x0, 1222                # c.li's rd before (stale)
    lui x28, 284                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 285                      # quiet
    lui x6, 286                       # quiet
    .option push
    .option rvc
    c.li x12, 5                   # c.li: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x10, mcycleh, x0            # subject csrrs: reads mcycleh, d1 (csr_counter_read_d1)
    lui x7, 287                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 288                      # quiet
    lui x29, 289                      # quiet
    addi x10, x0, 1236                # x10 known again: it held the counter, which differs between the engines
# block 31  csr_counter_read_d1  csr_counter_read_d1__mcycleh__alu_nosrc (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 31  # marker: block 31
    lui x6, 290                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 291                       # quiet
    lui x28, 292                      # quiet
    addi x14, x0, 1243                # x14 = 1243
    addi x15, x0, 1250                # c.lui's rd before (stale)
    lui x29, 293                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 294                       # quiet
    lui x7, 295                       # quiet
    .option push
    .option rvc
    c.lui x15, 5                  # c.lui: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrw x0, mcycleh, x14            # subject csrrw: names mcycleh and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 296                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 297                      # quiet
    lui x6, 298                       # quiet
# block 32  csr_counter_read_d1  csr_counter_read_d1__mcycleh__load (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 32  # marker: block 32
    lui x7, 299                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 300                      # quiet
    lui x29, 301                      # quiet
    addi x19, x0, 1                   # mcountinhibit for mcycleh: inhibited
    csrrw x0, mcountinhibit, x19      # mcountinhibit for mcycleh: inhibited
    .L7: auipc x11, %pcrel_hi(w6)     # c.lw's base -> w6
    lui x6, 302                       # c.lw's base -> w6 (quiet)
    lui x7, 303                       # c.lw's base -> w6 (quiet)
    lui x28, 304                      # c.lw's base -> w6 (quiet)
    addi x11, x11, %pcrel_lo(.L7)     # c.lw's base -> w6
    addi x10, x0, 1551                # c.lw's rd before (stale)
    lui x29, 305                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 306                       # quiet
    lui x7, 307                       # quiet
    .option push
    .option rvc
    c.lw x10, 0(x11)              # c.lw: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x18, mcycleh, x0            # subject csrrs: reads mcycleh, d1 (csr_counter_read_d1)
    lui x28, 308                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 309                      # quiet
    lui x6, 310                       # quiet
    addi x18, x0, 1565                # x18 known again: it held the counter, which differs between the engines
# block 33  csr_counter_read_d1  csr_counter_read_d1__mcycleh__load (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 33  # marker: block 33
    lui x7, 311                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 312                      # quiet
    lui x29, 313                      # quiet
    addi x23, x0, 0                   # mcountinhibit for mcycleh: enabled
    csrrw x0, mcountinhibit, x23      # mcountinhibit for mcycleh: enabled
    .L8: auipc x2, %pcrel_hi(w7)      # c.lwsp's base -> w7
    lui x6, 314                       # c.lwsp's base -> w7 (quiet)
    lui x7, 315                       # c.lwsp's base -> w7 (quiet)
    lui x28, 316                      # c.lwsp's base -> w7 (quiet)
    addi x2, x2, %pcrel_lo(.L8)       # c.lwsp's base -> w7
    addi x24, x0, 1579                # c.lwsp's rd before (stale)
    lui x29, 317                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 318                       # quiet
    lui x7, 319                       # quiet
    .option push
    .option rvc
    c.lwsp x24, 0(sp)             # c.lwsp: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x22, mcycleh, x0            # subject csrrs: reads mcycleh, d1 (csr_counter_read_d1)
    lui x28, 320                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 321                      # quiet
    lui x6, 322                       # quiet
    addi x22, x0, 1593                # x22 known again: it held the counter, which differs between the engines
# block 34  csr_counter_read_d1  csr_counter_read_d1__mcycleh__load (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 34  # marker: block 34
    lui x7, 323                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 324                      # quiet
    lui x29, 325                      # quiet
    addi x26, x0, 1600                # x26 = 1600
    .L9: auipc x3, %pcrel_hi(w8)      # lb's base -> w8
    lui x6, 326                       # lb's base -> w8 (quiet)
    lui x7, 327                       # lb's base -> w8 (quiet)
    lui x28, 328                      # lb's base -> w8 (quiet)
    addi x3, x3, %pcrel_lo(.L9)       # lb's base -> w8
    addi x27, x0, 1614                # lb's rd before (stale)
    lui x29, 329                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 330                       # quiet
    lui x7, 331                       # quiet
    lb x27, 0(x3)                     # lb: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mcycleh, x26            # subject csrrw: names mcycleh and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 332                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 333                      # quiet
    lui x6, 334                       # quiet
# block 35  csr_counter_read_d1  csr_counter_read_d1__mcycleh__store (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 35  # marker: block 35
    lui x7, 335                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 336                      # quiet
    lui x29, 337                      # quiet
    addi x9, x0, 1                    # mcountinhibit for mcycleh: inhibited
    csrrw x0, mcountinhibit, x9       # mcountinhibit for mcycleh: inhibited
    .L10: auipc x2, %pcrel_hi(w9)     # c.swsp's base -> w9
    lui x6, 338                       # c.swsp's base -> w9 (quiet)
    lui x7, 339                       # c.swsp's base -> w9 (quiet)
    lui x28, 340                      # c.swsp's base -> w9 (quiet)
    addi x2, x2, %pcrel_lo(.L10)      # c.swsp's base -> w9
    addi x10, x0, 1                   # c.swsp's store data
    lui x29, 341                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 342                       # quiet
    lui x7, 343                       # quiet
    .option push
    .option rvc
    c.swsp x10, 0(sp)             # c.swsp: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x8, mcycleh, x0             # subject csrrs: reads mcycleh, d1 (csr_counter_read_d1)
    lui x28, 344                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 345                      # quiet
    lui x6, 346                       # quiet
    addi x8, x0, 1635                 # x8 known again: it held the counter, which differs between the engines
# block 36  csr_counter_read_d1  csr_counter_read_d1__mcycleh__store (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 36  # marker: block 36
    lui x7, 347                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 348                      # quiet
    lui x29, 349                      # quiet
    addi x12, x0, 0                   # mcountinhibit for mcycleh: enabled
    csrrw x0, mcountinhibit, x12      # mcountinhibit for mcycleh: enabled
    .L11: auipc x13, %pcrel_hi(w10)   # sb's base -> w10
    lui x6, 350                       # sb's base -> w10 (quiet)
    lui x7, 351                       # sb's base -> w10 (quiet)
    lui x28, 352                      # sb's base -> w10 (quiet)
    addi x13, x13, %pcrel_lo(.L11)    # sb's base -> w10
    addi x14, x0, 1649                # sb's store data
    lui x29, 353                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 354                       # quiet
    lui x7, 355                       # quiet
    sb x14, 0(x13)                    # sb: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x11, mcycleh, x0            # subject csrrs: reads mcycleh, d1 (csr_counter_read_d1)
    lui x28, 356                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 357                      # quiet
    lui x6, 358                       # quiet
    addi x11, x0, 1663                # x11 known again: it held the counter, which differs between the engines
# block 37  csr_counter_read_d1  csr_counter_read_d1__mcycleh__store (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 37  # marker: block 37
    lui x7, 359                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 360                      # quiet
    lui x29, 361                      # quiet
    addi x16, x0, 1670                # x16 = 1670
    .L12: auipc x17, %pcrel_hi(w11)   # sh's base -> w11
    lui x6, 362                       # sh's base -> w11 (quiet)
    lui x7, 363                       # sh's base -> w11 (quiet)
    lui x28, 364                      # sh's base -> w11 (quiet)
    addi x17, x17, %pcrel_lo(.L12)    # sh's base -> w11
    addi x18, x0, 1684                # sh's store data
    lui x29, 365                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 366                       # quiet
    lui x7, 367                       # quiet
    sh x18, 0(x17)                    # sh: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mcycleh, x16            # subject csrrw: names mcycleh and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 368                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 369                      # quiet
    lui x6, 370                       # quiet
# block 38  csr_counter_read_d1  csr_counter_read_d1__mcycleh__csr_r (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 38  # marker: block 38
    lui x7, 371                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 372                      # quiet
    lui x29, 373                      # quiet
    addi x20, x0, 1                   # mcountinhibit for mcycleh: inhibited
    csrrw x0, mcountinhibit, x20      # mcountinhibit for mcycleh: inhibited
    addi x22, x0, 1691                # csrrs's operand
    addi x21, x0, 1698                # csrrs's rd before (stale)
    lui x6, 374                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 375                       # quiet
    lui x28, 376                      # quiet
    csrrs x21, mscratch, x22          # csrrs: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x19, mcycleh, x0            # subject csrrs: reads mcycleh, d1 (csr_counter_read_d1)
    lui x29, 377                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 378                       # quiet
    lui x7, 379                       # quiet
    addi x19, x0, 1712                # x19 known again: it held the counter, which differs between the engines
# block 39  csr_counter_read_d1  csr_counter_read_d1__mcycleh__csr_r (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 39  # marker: block 39
    lui x28, 380                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 381                      # quiet
    lui x6, 382                       # quiet
    addi x24, x0, 0                   # mcountinhibit for mcycleh: enabled
    csrrw x0, mcountinhibit, x24      # mcountinhibit for mcycleh: enabled
    addi x26, x0, 1719                # csrrw's operand
    addi x25, x0, 1726                # csrrw's rd before (stale)
    lui x7, 383                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 384                      # quiet
    lui x29, 385                      # quiet
    csrrw x25, mscratch, x26          # csrrw: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x23, mcycleh, x0            # subject csrrs: reads mcycleh, d1 (csr_counter_read_d1)
    lui x6, 386                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 387                       # quiet
    lui x28, 388                      # quiet
    addi x23, x0, 1740                # x23 known again: it held the counter, which differs between the engines
# block 40  csr_counter_read_d1  csr_counter_read_d1__mcycleh__csr_r (after_write)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 40  # marker: block 40
    lui x29, 389                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 390                       # quiet
    lui x7, 391                       # quiet
    addi x3, x0, 1747                 # x3 = 1747
    lui x28, 392                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 393                      # quiet
    lui x6, 394                       # quiet
    csrrw x0, mcycleh, x3             # csrrw: writes mcycleh, the counter the subject reads
    csrrs x27, mcycleh, x0            # subject csrrs: reads mcycleh, d1 (csr_counter_read_d1)
    lui x7, 395                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 396                      # quiet
    lui x29, 397                      # quiet
    addi x27, x0, 1761                # x27 known again: it held the counter, which differs between the engines
# block 41  csr_counter_read_d1  csr_counter_read_d1__mcycleh__csr_r (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 41  # marker: block 41
    lui x6, 398                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 399                       # quiet
    lui x28, 400                      # quiet
    addi x9, x0, 1768                 # x9 = 1768
    addi x11, x0, 1775                # csrrs's operand
    addi x10, x0, 1782                # csrrs's rd before (stale)
    lui x29, 401                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 402                       # quiet
    lui x7, 403                       # quiet
    csrrs x10, mscratch, x11          # csrrs: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mcycleh, x9             # subject csrrw: names mcycleh and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 404                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 405                      # quiet
    lui x6, 406                       # quiet
# block 42  csr_counter_read_d1  csr_counter_read_d1__mcycleh__csr_i (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 42  # marker: block 42
    lui x7, 407                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 408                      # quiet
    lui x29, 409                      # quiet
    addi x13, x0, 1                   # mcountinhibit for mcycleh: inhibited
    csrrw x0, mcountinhibit, x13      # mcountinhibit for mcycleh: inhibited
    addi x14, x0, 1789                # csrrci's rd before (stale)
    lui x6, 410                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 411                       # quiet
    lui x28, 412                      # quiet
    csrrci x14, mscratch, 7           # csrrci: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x12, mcycleh, x0            # subject csrrs: reads mcycleh, d1 (csr_counter_read_d1)
    lui x29, 413                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 414                       # quiet
    lui x7, 415                       # quiet
    addi x12, x0, 1803                # x12 known again: it held the counter, which differs between the engines
# block 43  csr_counter_read_d1  csr_counter_read_d1__mcycleh__csr_i (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 43  # marker: block 43
    lui x28, 416                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 417                      # quiet
    lui x6, 418                       # quiet
    addi x16, x0, 0                   # mcountinhibit for mcycleh: enabled
    csrrw x0, mcountinhibit, x16      # mcountinhibit for mcycleh: enabled
    addi x17, x0, 1810                # csrrsi's rd before (stale)
    lui x7, 419                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 420                      # quiet
    lui x29, 421                      # quiet
    csrrsi x17, mscratch, 7           # csrrsi: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x15, mcycleh, x0            # subject csrrs: reads mcycleh, d1 (csr_counter_read_d1)
    lui x6, 422                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 423                       # quiet
    lui x28, 424                      # quiet
    addi x15, x0, 1824                # x15 known again: it held the counter, which differs between the engines
# block 44  csr_counter_read_d1  csr_counter_read_d1__mcycleh__csr_i (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 44  # marker: block 44
    lui x29, 425                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 426                       # quiet
    lui x7, 427                       # quiet
    addi x19, x0, 1831                # x19 = 1831
    addi x20, x0, 1838                # csrrwi's rd before (stale)
    lui x28, 428                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 429                      # quiet
    lui x6, 430                       # quiet
    csrrwi x20, mscratch, 7           # csrrwi: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mcycleh, x19            # subject csrrw: names mcycleh and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x7, 431                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 432                      # quiet
    lui x29, 433                      # quiet
# block 45  csr_counter_read_d1  csr_counter_read_d1__minstret__alu_rr (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 45  # marker: block 45
    lui x6, 434                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 435                       # quiet
    lui x28, 436                      # quiet
    addi x22, x0, 4                   # mcountinhibit for minstret: inhibited
    csrrw x0, mcountinhibit, x22      # mcountinhibit for minstret: inhibited
    addi x24, x0, 1845                # add's operand
    addi x25, x0, 1852                # add's operand
    addi x23, x0, 1859                # add's rd before (stale)
    lui x29, 437                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 438                       # quiet
    lui x7, 439                       # quiet
    add x23, x24, x25                 # add: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x21, minstret, x0           # subject csrrs: reads minstret, d1 (csr_counter_read_d1)
    lui x28, 440                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 441                      # quiet
    lui x6, 442                       # quiet
    addi x21, x0, 1873                # x21 known again: it held the counter, which differs between the engines
# block 46  csr_counter_read_d1  csr_counter_read_d1__minstret__alu_rr (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 46  # marker: block 46
    lui x7, 443                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 444                      # quiet
    lui x29, 445                      # quiet
    addi x27, x0, 0                   # mcountinhibit for minstret: enabled
    csrrw x0, mcountinhibit, x27      # mcountinhibit for minstret: enabled
    addi x8, x0, 1880                 # and's operand
    addi x9, x0, 1887                 # and's operand
    addi x3, x0, 1894                 # and's rd before (stale)
    lui x6, 446                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 447                       # quiet
    lui x28, 448                      # quiet
    and x3, x8, x9                    # and: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x26, minstret, x0           # subject csrrs: reads minstret, d1 (csr_counter_read_d1)
    lui x29, 449                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 450                       # quiet
    lui x7, 451                       # quiet
    addi x26, x0, 1908                # x26 known again: it held the counter, which differs between the engines
# block 47  csr_counter_read_d1  csr_counter_read_d1__minstret__alu_rr (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 47  # marker: block 47
    lui x28, 452                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 453                      # quiet
    lui x6, 454                       # quiet
    addi x11, x0, 1915                # x11 = 1915
    addi x13, x0, 1922                # or's operand
    addi x14, x0, 1929                # or's operand
    addi x12, x0, 1936                # or's rd before (stale)
    lui x7, 455                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 456                      # quiet
    lui x29, 457                      # quiet
    or x12, x13, x14                  # or: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, minstret, x11           # subject csrrw: names minstret and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x6, 458                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 459                       # quiet
    lui x28, 460                      # quiet
# block 48  csr_counter_read_d1  csr_counter_read_d1__minstret__alu_ri (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 48  # marker: block 48
    lui x29, 461                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 462                       # quiet
    lui x7, 463                       # quiet
    addi x16, x0, 4                   # mcountinhibit for minstret: inhibited
    csrrw x0, mcountinhibit, x16      # mcountinhibit for minstret: inhibited
    addi x17, x0, 1943                # c.slli's rd before (stale)
    lui x28, 464                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 465                      # quiet
    lui x6, 466                       # quiet
    .option push
    .option rvc
    c.slli x17, 3                 # c.slli: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x15, minstret, x0           # subject csrrs: reads minstret, d1 (csr_counter_read_d1)
    lui x7, 467                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 468                      # quiet
    lui x29, 469                      # quiet
    addi x15, x0, 1957                # x15 known again: it held the counter, which differs between the engines
# block 49  csr_counter_read_d1  csr_counter_read_d1__minstret__alu_ri (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 49  # marker: block 49
    lui x6, 470                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 471                       # quiet
    lui x28, 472                      # quiet
    addi x19, x0, 0                   # mcountinhibit for minstret: enabled
    csrrw x0, mcountinhibit, x19      # mcountinhibit for minstret: enabled
    addi x20, x0, 1964                # c.slli's rd before (stale)
    lui x29, 473                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 474                       # quiet
    lui x7, 475                       # quiet
    .option push
    .option rvc
    c.slli x20, 3                 # c.slli: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x18, minstret, x0           # subject csrrs: reads minstret, d1 (csr_counter_read_d1)
    lui x28, 476                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 477                      # quiet
    lui x6, 478                       # quiet
    addi x18, x0, 1978                # x18 known again: it held the counter, which differs between the engines
# block 50  csr_counter_read_d1  csr_counter_read_d1__minstret__alu_ri (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 50  # marker: block 50
    lui x7, 479                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 480                      # quiet
    lui x29, 481                      # quiet
    addi x22, x0, 1985                # x22 = 1985
    addi x12, x0, 1992                # c.srai's rd before (stale)
    lui x6, 482                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 483                       # quiet
    lui x28, 484                      # quiet
    .option push
    .option rvc
    c.srai x12, 3                 # c.srai: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrw x0, minstret, x22           # subject csrrw: names minstret and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x29, 485                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 486                       # quiet
    lui x7, 487                       # quiet
# block 51  csr_counter_read_d1  csr_counter_read_d1__minstret__alu_nosrc (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 51  # marker: block 51
    lui x28, 488                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 489                      # quiet
    lui x6, 490                       # quiet
    addi x25, x0, 4                   # mcountinhibit for minstret: inhibited
    csrrw x0, mcountinhibit, x25      # mcountinhibit for minstret: inhibited
    addi x26, x0, 1999                # auipc's rd before (stale)
    lui x7, 491                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 492                      # quiet
    lui x29, 493                      # quiet
    auipc x26, 74565                  # auipc: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x24, minstret, x0           # subject csrrs: reads minstret, d1 (csr_counter_read_d1)
    lui x6, 494                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 495                       # quiet
    lui x28, 496                      # quiet
    addi x24, x0, 2013                # x24 known again: it held the counter, which differs between the engines
# block 52  csr_counter_read_d1  csr_counter_read_d1__minstret__alu_nosrc (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 52  # marker: block 52
    lui x29, 497                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 498                       # quiet
    lui x7, 499                       # quiet
    addi x3, x0, 0                    # mcountinhibit for minstret: enabled
    csrrw x0, mcountinhibit, x3       # mcountinhibit for minstret: enabled
    addi x8, x0, 2020                 # lui's rd before (stale)
    lui x28, 500                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 501                      # quiet
    lui x6, 502                       # quiet
    lui x8, 74565                     # lui: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x27, minstret, x0           # subject csrrs: reads minstret, d1 (csr_counter_read_d1)
    lui x7, 503                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 504                      # quiet
    lui x29, 505                      # quiet
    addi x27, x0, 258                 # x27 known again: it held the counter, which differs between the engines
# block 53  csr_counter_read_d1  csr_counter_read_d1__minstret__alu_nosrc (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 53  # marker: block 53
    lui x6, 506                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 507                       # quiet
    lui x28, 508                      # quiet
    addi x10, x0, 265                 # x10 = 265
    addi x11, x0, 272                 # c.li's rd before (stale)
    lui x29, 509                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 510                       # quiet
    lui x7, 511                       # quiet
    .option push
    .option rvc
    c.li x11, 5                   # c.li: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrw x0, minstret, x10           # subject csrrw: names minstret and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 512                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 513                      # quiet
    lui x6, 514                       # quiet
# block 54  csr_counter_read_d1  csr_counter_read_d1__minstret__load (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 54  # marker: block 54
    lui x7, 515                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 516                      # quiet
    lui x29, 517                      # quiet
    addi x14, x0, 4                   # mcountinhibit for minstret: inhibited
    csrrw x0, mcountinhibit, x14      # mcountinhibit for minstret: inhibited
    .L13: auipc x16, %pcrel_hi(w12)   # lbu's base -> w12
    lui x6, 518                       # lbu's base -> w12 (quiet)
    lui x7, 519                       # lbu's base -> w12 (quiet)
    lui x28, 520                      # lbu's base -> w12 (quiet)
    addi x16, x16, %pcrel_lo(.L13)    # lbu's base -> w12
    addi x15, x0, 566                 # lbu's rd before (stale)
    lui x29, 521                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 522                       # quiet
    lui x7, 523                       # quiet
    lbu x15, 0(x16)                   # lbu: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x13, minstret, x0           # subject csrrs: reads minstret, d1 (csr_counter_read_d1)
    lui x28, 524                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 525                      # quiet
    lui x6, 526                       # quiet
    addi x13, x0, 580                 # x13 known again: it held the counter, which differs between the engines
# block 55  csr_counter_read_d1  csr_counter_read_d1__minstret__load (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 55  # marker: block 55
    lui x7, 527                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 528                      # quiet
    lui x29, 529                      # quiet
    addi x18, x0, 0                   # mcountinhibit for minstret: enabled
    csrrw x0, mcountinhibit, x18      # mcountinhibit for minstret: enabled
    .L14: auipc x20, %pcrel_hi(w13)   # lh's base -> w13
    lui x6, 530                       # lh's base -> w13 (quiet)
    lui x7, 531                       # lh's base -> w13 (quiet)
    lui x28, 532                      # lh's base -> w13 (quiet)
    addi x20, x20, %pcrel_lo(.L14)    # lh's base -> w13
    addi x19, x0, 594                 # lh's rd before (stale)
    lui x29, 533                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 534                       # quiet
    lui x7, 535                       # quiet
    lh x19, 0(x20)                    # lh: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x17, minstret, x0           # subject csrrs: reads minstret, d1 (csr_counter_read_d1)
    lui x28, 536                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 537                      # quiet
    lui x6, 538                       # quiet
    addi x17, x0, 608                 # x17 known again: it held the counter, which differs between the engines
# block 56  csr_counter_read_d1  csr_counter_read_d1__minstret__load (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 56  # marker: block 56
    lui x7, 539                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 540                      # quiet
    lui x29, 541                      # quiet
    addi x22, x0, 615                 # x22 = 615
    .L15: auipc x24, %pcrel_hi(w14)   # lhu's base -> w14
    lui x6, 542                       # lhu's base -> w14 (quiet)
    lui x7, 543                       # lhu's base -> w14 (quiet)
    lui x28, 544                      # lhu's base -> w14 (quiet)
    addi x24, x24, %pcrel_lo(.L15)    # lhu's base -> w14
    addi x23, x0, 629                 # lhu's rd before (stale)
    lui x29, 545                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 546                       # quiet
    lui x7, 547                       # quiet
    lhu x23, 0(x24)                   # lhu: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, minstret, x22           # subject csrrw: names minstret and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 548                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 549                      # quiet
    lui x6, 550                       # quiet
# block 57  csr_counter_read_d1  csr_counter_read_d1__minstret__store (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 57  # marker: block 57
    lui x7, 551                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 552                      # quiet
    lui x29, 553                      # quiet
    addi x26, x0, 4                   # mcountinhibit for minstret: inhibited
    csrrw x0, mcountinhibit, x26      # mcountinhibit for minstret: inhibited
    .L16: auipc x27, %pcrel_hi(w15)   # sw's base -> w15
    lui x6, 554                       # sw's base -> w15 (quiet)
    lui x7, 555                       # sw's base -> w15 (quiet)
    lui x28, 556                      # sw's base -> w15 (quiet)
    addi x27, x27, %pcrel_lo(.L16)    # sw's base -> w15
    addi x3, x0, 643                  # sw's store data
    lui x29, 557                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 558                       # quiet
    lui x7, 559                       # quiet
    sw x3, 0(x27)                     # sw: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x25, minstret, x0           # subject csrrs: reads minstret, d1 (csr_counter_read_d1)
    lui x28, 560                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 561                      # quiet
    lui x6, 562                       # quiet
    addi x25, x0, 657                 # x25 known again: it held the counter, which differs between the engines
# block 58  csr_counter_read_d1  csr_counter_read_d1__minstret__store (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 58  # marker: block 58
    lui x7, 563                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 564                      # quiet
    lui x29, 565                      # quiet
    addi x9, x0, 0                    # mcountinhibit for minstret: enabled
    csrrw x0, mcountinhibit, x9       # mcountinhibit for minstret: enabled
    .L17: auipc x11, %pcrel_hi(w16)   # c.sb's base -> w16
    lui x6, 566                       # c.sb's base -> w16 (quiet)
    lui x7, 567                       # c.sb's base -> w16 (quiet)
    lui x28, 568                      # c.sb's base -> w16 (quiet)
    addi x11, x11, %pcrel_lo(.L17)    # c.sb's base -> w16
    addi x12, x0, 2                   # c.sb's store data
    lui x29, 569                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 570                       # quiet
    lui x7, 571                       # quiet
    .option push
    .option rvc
    c.sb x12, 0(x11)              # c.sb: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x8, minstret, x0            # subject csrrs: reads minstret, d1 (csr_counter_read_d1)
    lui x28, 572                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 573                      # quiet
    lui x6, 574                       # quiet
    addi x8, x0, 678                  # x8 known again: it held the counter, which differs between the engines
# block 59  csr_counter_read_d1  csr_counter_read_d1__minstret__store (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 59  # marker: block 59
    lui x7, 575                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 576                      # quiet
    lui x29, 577                      # quiet
    addi x13, x0, 685                 # x13 = 685
    .L18: auipc x15, %pcrel_hi(w17)   # c.sh's base -> w17
    lui x6, 578                       # c.sh's base -> w17 (quiet)
    lui x7, 579                       # c.sh's base -> w17 (quiet)
    lui x28, 580                      # c.sh's base -> w17 (quiet)
    addi x15, x15, %pcrel_lo(.L18)    # c.sh's base -> w17
    addi x8, x0, 699                  # c.sh's store data
    lui x29, 581                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 582                       # quiet
    lui x7, 583                       # quiet
    .option push
    .option rvc
    c.sh x8, 0(x15)               # c.sh: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrw x0, minstret, x13           # subject csrrw: names minstret and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 584                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 585                      # quiet
    lui x6, 586                       # quiet
# block 60  csr_counter_read_d1  csr_counter_read_d1__minstret__csr_r (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 60  # marker: block 60
    lui x7, 587                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 588                      # quiet
    lui x29, 589                      # quiet
    addi x17, x0, 4                   # mcountinhibit for minstret: inhibited
    csrrw x0, mcountinhibit, x17      # mcountinhibit for minstret: inhibited
    addi x19, x0, 706                 # csrrw's operand
    addi x18, x0, 713                 # csrrw's rd before (stale)
    lui x6, 590                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 591                       # quiet
    lui x28, 592                      # quiet
    csrrw x18, mscratch, x19          # csrrw: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x16, minstret, x0           # subject csrrs: reads minstret, d1 (csr_counter_read_d1)
    lui x29, 593                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 594                       # quiet
    lui x7, 595                       # quiet
    addi x16, x0, 727                 # x16 known again: it held the counter, which differs between the engines
# block 61  csr_counter_read_d1  csr_counter_read_d1__minstret__csr_r (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 61  # marker: block 61
    lui x28, 596                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 597                      # quiet
    lui x6, 598                       # quiet
    addi x21, x0, 0                   # mcountinhibit for minstret: enabled
    csrrw x0, mcountinhibit, x21      # mcountinhibit for minstret: enabled
    addi x23, x0, 734                 # csrrc's operand
    addi x22, x0, 741                 # csrrc's rd before (stale)
    lui x7, 599                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 600                      # quiet
    lui x29, 601                      # quiet
    csrrc x22, mscratch, x23          # csrrc: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x20, minstret, x0           # subject csrrs: reads minstret, d1 (csr_counter_read_d1)
    lui x6, 602                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 603                       # quiet
    lui x28, 604                      # quiet
    addi x20, x0, 755                 # x20 known again: it held the counter, which differs between the engines
# block 62  csr_counter_read_d1  csr_counter_read_d1__minstret__csr_r (after_write)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 62  # marker: block 62
    lui x29, 605                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 606                       # quiet
    lui x7, 607                       # quiet
    addi x25, x0, 762                 # x25 = 762
    lui x28, 608                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 609                      # quiet
    lui x6, 610                       # quiet
    csrrw x0, minstret, x25           # csrrw: writes minstret, the counter the subject reads
    csrrs x24, minstret, x0           # subject csrrs: reads minstret, d1 (csr_counter_read_d1)
    lui x7, 611                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 612                      # quiet
    lui x29, 613                      # quiet
    addi x24, x0, 776                 # x24 known again: it held the counter, which differs between the engines
# block 63  csr_counter_read_d1  csr_counter_read_d1__minstret__csr_r (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 63  # marker: block 63
    lui x6, 614                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 615                       # quiet
    lui x28, 616                      # quiet
    addi x27, x0, 783                 # x27 = 783
    addi x8, x0, 790                  # csrrw's operand
    addi x3, x0, 797                  # csrrw's rd before (stale)
    lui x29, 617                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 618                       # quiet
    lui x7, 619                       # quiet
    csrrw x3, mscratch, x8            # csrrw: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, minstret, x27           # subject csrrw: names minstret and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 620                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 621                      # quiet
    lui x6, 622                       # quiet
# block 64  csr_counter_read_d1  csr_counter_read_d1__minstret__csr_i (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 64  # marker: block 64
    lui x7, 623                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 624                      # quiet
    lui x29, 625                      # quiet
    addi x10, x0, 4                   # mcountinhibit for minstret: inhibited
    csrrw x0, mcountinhibit, x10      # mcountinhibit for minstret: inhibited
    addi x11, x0, 804                 # csrrci's rd before (stale)
    lui x6, 626                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 627                       # quiet
    lui x28, 628                      # quiet
    csrrci x11, mscratch, 7           # csrrci: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x9, minstret, x0            # subject csrrs: reads minstret, d1 (csr_counter_read_d1)
    lui x29, 629                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 630                       # quiet
    lui x7, 631                       # quiet
    addi x9, x0, 818                  # x9 known again: it held the counter, which differs between the engines
# block 65  csr_counter_read_d1  csr_counter_read_d1__minstret__csr_i (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 65  # marker: block 65
    lui x28, 632                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 633                      # quiet
    lui x6, 634                       # quiet
    addi x13, x0, 0                   # mcountinhibit for minstret: enabled
    csrrw x0, mcountinhibit, x13      # mcountinhibit for minstret: enabled
    addi x14, x0, 825                 # csrrsi's rd before (stale)
    lui x7, 635                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 636                      # quiet
    lui x29, 637                      # quiet
    csrrsi x14, mscratch, 7           # csrrsi: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x12, minstret, x0           # subject csrrs: reads minstret, d1 (csr_counter_read_d1)
    lui x6, 638                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 639                       # quiet
    lui x28, 640                      # quiet
    addi x12, x0, 839                 # x12 known again: it held the counter, which differs between the engines
# block 66  csr_counter_read_d1  csr_counter_read_d1__minstret__csr_i (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 66  # marker: block 66
    lui x29, 641                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 642                       # quiet
    lui x7, 643                       # quiet
    addi x16, x0, 846                 # x16 = 846
    addi x17, x0, 853                 # csrrwi's rd before (stale)
    lui x28, 644                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 645                      # quiet
    lui x6, 646                       # quiet
    csrrwi x17, mscratch, 7           # csrrwi: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, minstret, x16           # subject csrrw: names minstret and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x7, 647                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 648                      # quiet
    lui x29, 649                      # quiet
# block 67  csr_counter_read_d1  csr_counter_read_d1__minstreth__alu_rr (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 67  # marker: block 67
    lui x6, 650                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 651                       # quiet
    lui x28, 652                      # quiet
    addi x19, x0, 4                   # mcountinhibit for minstreth: inhibited
    csrrw x0, mcountinhibit, x19      # mcountinhibit for minstreth: inhibited
    addi x21, x0, 860                 # or's operand
    addi x22, x0, 867                 # or's operand
    addi x20, x0, 874                 # or's rd before (stale)
    lui x29, 653                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 654                       # quiet
    lui x7, 655                       # quiet
    or x20, x21, x22                  # or: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x18, minstreth, x0          # subject csrrs: reads minstreth, d1 (csr_counter_read_d1)
    lui x28, 656                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 657                      # quiet
    lui x6, 658                       # quiet
    addi x18, x0, 888                 # x18 known again: it held the counter, which differs between the engines
# block 68  csr_counter_read_d1  csr_counter_read_d1__minstreth__alu_rr (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 68  # marker: block 68
    lui x7, 659                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 660                      # quiet
    lui x29, 661                      # quiet
    addi x24, x0, 0                   # mcountinhibit for minstreth: enabled
    csrrw x0, mcountinhibit, x24      # mcountinhibit for minstreth: enabled
    addi x26, x0, 895                 # or's operand
    addi x27, x0, 902                 # or's operand
    addi x25, x0, 909                 # or's rd before (stale)
    lui x6, 662                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 663                       # quiet
    lui x28, 664                      # quiet
    or x25, x26, x27                  # or: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x23, minstreth, x0          # subject csrrs: reads minstreth, d1 (csr_counter_read_d1)
    lui x29, 665                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 666                       # quiet
    lui x7, 667                       # quiet
    addi x23, x0, 923                 # x23 known again: it held the counter, which differs between the engines
# block 69  csr_counter_read_d1  csr_counter_read_d1__minstreth__alu_rr (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 69  # marker: block 69
    lui x28, 668                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 669                      # quiet
    lui x6, 670                       # quiet
    addi x8, x0, 930                  # x8 = 930
    addi x10, x0, 937                 # or's operand
    addi x11, x0, 944                 # or's operand
    addi x9, x0, 951                  # or's rd before (stale)
    lui x7, 671                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 672                      # quiet
    lui x29, 673                      # quiet
    or x9, x10, x11                   # or: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, minstreth, x8           # subject csrrw: names minstreth and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x6, 674                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 675                       # quiet
    lui x28, 676                      # quiet
# block 70  csr_counter_read_d1  csr_counter_read_d1__minstreth__alu_ri (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 70  # marker: block 70
    lui x29, 677                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 678                       # quiet
    lui x7, 679                       # quiet
    addi x13, x0, 4                   # mcountinhibit for minstreth: inhibited
    csrrw x0, mcountinhibit, x13      # mcountinhibit for minstreth: inhibited
    addi x9, x0, 958                  # c.srli's rd before (stale)
    lui x28, 680                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 681                      # quiet
    lui x6, 682                       # quiet
    .option push
    .option rvc
    c.srli x9, 3                  # c.srli: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x12, minstreth, x0          # subject csrrs: reads minstreth, d1 (csr_counter_read_d1)
    lui x7, 683                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 684                      # quiet
    lui x29, 685                      # quiet
    addi x12, x0, 972                 # x12 known again: it held the counter, which differs between the engines
# block 71  csr_counter_read_d1  csr_counter_read_d1__minstreth__alu_ri (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 71  # marker: block 71
    lui x6, 686                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 687                       # quiet
    lui x28, 688                      # quiet
    addi x16, x0, 0                   # mcountinhibit for minstreth: enabled
    csrrw x0, mcountinhibit, x16      # mcountinhibit for minstreth: enabled
    addi x12, x0, 979                 # c.zext.b's rd before (stale)
    lui x29, 689                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 690                       # quiet
    lui x7, 691                       # quiet
    .option push
    .option rvc
    c.zext.b x12                  # c.zext.b: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x15, minstreth, x0          # subject csrrs: reads minstreth, d1 (csr_counter_read_d1)
    lui x28, 692                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 693                      # quiet
    lui x6, 694                       # quiet
    addi x15, x0, 993                 # x15 known again: it held the counter, which differs between the engines
# block 72  csr_counter_read_d1  csr_counter_read_d1__minstreth__alu_ri (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 72  # marker: block 72
    lui x7, 695                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 696                      # quiet
    lui x29, 697                      # quiet
    addi x19, x0, 1000                # x19 = 1000
    addi x21, x0, 1007                # addi's operand
    addi x20, x0, 1014                # addi's rd before (stale)
    lui x6, 698                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 699                       # quiet
    lui x28, 700                      # quiet
    addi x20, x21, 0                  # addi: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, minstreth, x19          # subject csrrw: names minstreth and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x29, 701                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 702                       # quiet
    lui x7, 703                       # quiet
# block 73  csr_counter_read_d1  csr_counter_read_d1__minstreth__alu_nosrc (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 73  # marker: block 73
    lui x28, 704                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 705                      # quiet
    lui x6, 706                       # quiet
    addi x23, x0, 4                   # mcountinhibit for minstreth: inhibited
    csrrw x0, mcountinhibit, x23      # mcountinhibit for minstreth: inhibited
    addi x24, x0, 1021                # c.lui's rd before (stale)
    lui x7, 707                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 708                      # quiet
    lui x29, 709                      # quiet
    .option push
    .option rvc
    c.lui x24, 5                  # c.lui: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x22, minstreth, x0          # subject csrrs: reads minstreth, d1 (csr_counter_read_d1)
    lui x6, 710                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 711                       # quiet
    lui x28, 712                      # quiet
    addi x22, x0, 1035                # x22 known again: it held the counter, which differs between the engines
# block 74  csr_counter_read_d1  csr_counter_read_d1__minstreth__alu_nosrc (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 74  # marker: block 74
    lui x29, 713                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 714                       # quiet
    lui x7, 715                       # quiet
    addi x26, x0, 0                   # mcountinhibit for minstreth: enabled
    csrrw x0, mcountinhibit, x26      # mcountinhibit for minstreth: enabled
    addi x27, x0, 1042                # auipc's rd before (stale)
    lui x28, 716                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 717                      # quiet
    lui x6, 718                       # quiet
    auipc x27, 74565                  # auipc: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x25, minstreth, x0          # subject csrrs: reads minstreth, d1 (csr_counter_read_d1)
    lui x7, 719                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 720                      # quiet
    lui x29, 721                      # quiet
    addi x25, x0, 1056                # x25 known again: it held the counter, which differs between the engines
# block 75  csr_counter_read_d1  csr_counter_read_d1__minstreth__alu_nosrc (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 75  # marker: block 75
    lui x6, 722                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 723                       # quiet
    lui x28, 724                      # quiet
    addi x8, x0, 1063                 # x8 = 1063
    addi x9, x0, 1070                 # lui's rd before (stale)
    lui x29, 725                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 726                       # quiet
    lui x7, 727                       # quiet
    lui x9, 74565                     # lui: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, minstreth, x8           # subject csrrw: names minstreth and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 728                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 729                      # quiet
    lui x6, 730                       # quiet
# block 76  csr_counter_read_d1  csr_counter_read_d1__minstreth__load (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 76  # marker: block 76
    lui x7, 731                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 732                      # quiet
    lui x29, 733                      # quiet
    addi x13, x0, 4                   # mcountinhibit for minstreth: inhibited
    csrrw x0, mcountinhibit, x13      # mcountinhibit for minstreth: inhibited
    .L19: auipc x15, %pcrel_hi(w18)   # lw's base -> w18
    lui x6, 734                       # lw's base -> w18 (quiet)
    lui x7, 735                       # lw's base -> w18 (quiet)
    lui x28, 736                      # lw's base -> w18 (quiet)
    addi x15, x15, %pcrel_lo(.L19)    # lw's base -> w18
    addi x14, x0, 1371                # lw's rd before (stale)
    lui x29, 737                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 738                       # quiet
    lui x7, 739                       # quiet
    lw x14, 0(x15)                    # lw: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x12, minstreth, x0          # subject csrrs: reads minstreth, d1 (csr_counter_read_d1)
    lui x28, 740                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 741                      # quiet
    lui x6, 742                       # quiet
    addi x12, x0, 1385                # x12 known again: it held the counter, which differs between the engines
# block 77  csr_counter_read_d1  csr_counter_read_d1__minstreth__load (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 77  # marker: block 77
    lui x7, 743                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 744                      # quiet
    lui x29, 745                      # quiet
    addi x17, x0, 0                   # mcountinhibit for minstreth: enabled
    csrrw x0, mcountinhibit, x17      # mcountinhibit for minstreth: enabled
    .L20: auipc x19, %pcrel_hi(w19)   # lw's base -> w19
    lui x6, 746                       # lw's base -> w19 (quiet)
    lui x7, 747                       # lw's base -> w19 (quiet)
    lui x28, 748                      # lw's base -> w19 (quiet)
    addi x19, x19, %pcrel_lo(.L20)    # lw's base -> w19
    addi x18, x0, 1399                # lw's rd before (stale)
    lui x29, 749                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 750                       # quiet
    lui x7, 751                       # quiet
    lw x18, 0(x19)                    # lw: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x16, minstreth, x0          # subject csrrs: reads minstreth, d1 (csr_counter_read_d1)
    lui x28, 752                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 753                      # quiet
    lui x6, 754                       # quiet
    addi x16, x0, 1413                # x16 known again: it held the counter, which differs between the engines
# block 78  csr_counter_read_d1  csr_counter_read_d1__minstreth__load (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 78  # marker: block 78
    lui x7, 755                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 756                      # quiet
    lui x29, 757                      # quiet
    addi x21, x0, 1420                # x21 = 1420
    .L21: auipc x23, %pcrel_hi(w20)   # lw's base -> w20
    lui x6, 758                       # lw's base -> w20 (quiet)
    lui x7, 759                       # lw's base -> w20 (quiet)
    lui x28, 760                      # lw's base -> w20 (quiet)
    addi x23, x23, %pcrel_lo(.L21)    # lw's base -> w20
    addi x22, x0, 1434                # lw's rd before (stale)
    lui x29, 761                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 762                       # quiet
    lui x7, 763                       # quiet
    lw x22, 0(x23)                    # lw: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, minstreth, x21          # subject csrrw: names minstreth and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 764                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 765                      # quiet
    lui x6, 766                       # quiet
# block 79  csr_counter_read_d1  csr_counter_read_d1__minstreth__store (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 79  # marker: block 79
    lui x7, 767                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 768                      # quiet
    lui x29, 769                      # quiet
    addi x25, x0, 4                   # mcountinhibit for minstreth: inhibited
    csrrw x0, mcountinhibit, x25      # mcountinhibit for minstreth: inhibited
    .L22: auipc x12, %pcrel_hi(w21)   # c.sw's base -> w21
    lui x6, 770                       # c.sw's base -> w21 (quiet)
    lui x7, 771                       # c.sw's base -> w21 (quiet)
    lui x28, 772                      # c.sw's base -> w21 (quiet)
    addi x12, x12, %pcrel_lo(.L22)    # c.sw's base -> w21
    addi x13, x0, 1448                # c.sw's store data
    lui x29, 773                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 774                       # quiet
    lui x7, 775                       # quiet
    .option push
    .option rvc
    c.sw x13, 0(x12)              # c.sw: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x24, minstreth, x0          # subject csrrs: reads minstreth, d1 (csr_counter_read_d1)
    lui x28, 776                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 777                      # quiet
    lui x6, 778                       # quiet
    addi x24, x0, 1462                # x24 known again: it held the counter, which differs between the engines
# block 80  csr_counter_read_d1  csr_counter_read_d1__minstreth__store (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 80  # marker: block 80
    lui x7, 779                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 780                      # quiet
    lui x29, 781                      # quiet
    addi x8, x0, 0                    # mcountinhibit for minstreth: enabled
    csrrw x0, mcountinhibit, x8       # mcountinhibit for minstreth: enabled
    .L23: auipc x2, %pcrel_hi(w22)    # c.swsp's base -> w22
    lui x6, 782                       # c.swsp's base -> w22 (quiet)
    lui x7, 783                       # c.swsp's base -> w22 (quiet)
    lui x28, 784                      # c.swsp's base -> w22 (quiet)
    addi x2, x2, %pcrel_lo(.L23)      # c.swsp's base -> w22
    addi x9, x0, 1476                 # c.swsp's store data
    lui x29, 785                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 786                       # quiet
    lui x7, 787                       # quiet
    .option push
    .option rvc
    c.swsp x9, 0(sp)              # c.swsp: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x3, minstreth, x0           # subject csrrs: reads minstreth, d1 (csr_counter_read_d1)
    lui x28, 788                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 789                      # quiet
    lui x6, 790                       # quiet
    addi x3, x0, 1490                 # x3 known again: it held the counter, which differs between the engines
# block 81  csr_counter_read_d1  csr_counter_read_d1__minstreth__store (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 81  # marker: block 81
    lui x7, 791                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 792                      # quiet
    lui x29, 793                      # quiet
    addi x11, x0, 1497                # x11 = 1497
    .L24: auipc x12, %pcrel_hi(w23)   # sb's base -> w23
    lui x6, 794                       # sb's base -> w23 (quiet)
    lui x7, 795                       # sb's base -> w23 (quiet)
    lui x28, 796                      # sb's base -> w23 (quiet)
    addi x12, x12, %pcrel_lo(.L24)    # sb's base -> w23
    addi x13, x0, -1                  # sb's store data
    lui x29, 797                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 798                       # quiet
    lui x7, 799                       # quiet
    sb x13, 0(x12)                    # sb: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, minstreth, x11          # subject csrrw: names minstreth and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 800                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 801                      # quiet
    lui x6, 802                       # quiet
# block 82  csr_counter_read_d1  csr_counter_read_d1__minstreth__csr_r (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 82  # marker: block 82
    lui x7, 803                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 804                      # quiet
    lui x29, 805                      # quiet
    addi x15, x0, 4                   # mcountinhibit for minstreth: inhibited
    csrrw x0, mcountinhibit, x15      # mcountinhibit for minstreth: inhibited
    addi x17, x0, 1511                # csrrc's operand
    addi x16, x0, 1518                # csrrc's rd before (stale)
    lui x6, 806                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 807                       # quiet
    lui x28, 808                      # quiet
    csrrc x16, mscratch, x17          # csrrc: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x14, minstreth, x0          # subject csrrs: reads minstreth, d1 (csr_counter_read_d1)
    lui x29, 809                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 810                       # quiet
    lui x7, 811                       # quiet
    addi x14, x0, 1532                # x14 known again: it held the counter, which differs between the engines
# block 83  csr_counter_read_d1  csr_counter_read_d1__minstreth__csr_r (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 83  # marker: block 83
    lui x28, 812                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 813                      # quiet
    lui x6, 814                       # quiet
    addi x19, x0, 0                   # mcountinhibit for minstreth: enabled
    csrrw x0, mcountinhibit, x19      # mcountinhibit for minstreth: enabled
    addi x21, x0, 1539                # csrrs's operand
    addi x20, x0, 1546                # csrrs's rd before (stale)
    lui x7, 815                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 816                      # quiet
    lui x29, 817                      # quiet
    csrrs x20, mscratch, x21          # csrrs: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x18, minstreth, x0          # subject csrrs: reads minstreth, d1 (csr_counter_read_d1)
    lui x6, 818                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 819                       # quiet
    lui x28, 820                      # quiet
    addi x18, x0, 1560                # x18 known again: it held the counter, which differs between the engines
# block 84  csr_counter_read_d1  csr_counter_read_d1__minstreth__csr_r (after_write)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 84  # marker: block 84
    lui x29, 821                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 822                       # quiet
    lui x7, 823                       # quiet
    addi x23, x0, 1567                # x23 = 1567
    lui x28, 824                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 825                      # quiet
    lui x6, 826                       # quiet
    csrrw x0, minstreth, x23          # csrrw: writes minstreth, the counter the subject reads
    csrrs x22, minstreth, x0          # subject csrrs: reads minstreth, d1 (csr_counter_read_d1)
    lui x7, 827                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 828                      # quiet
    lui x29, 829                      # quiet
    addi x22, x0, 1581                # x22 known again: it held the counter, which differs between the engines
# block 85  csr_counter_read_d1  csr_counter_read_d1__minstreth__csr_r (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 85  # marker: block 85
    lui x6, 830                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 831                       # quiet
    lui x28, 832                      # quiet
    addi x25, x0, 1588                # x25 = 1588
    addi x27, x0, 1595                # csrrc's operand
    addi x26, x0, 1602                # csrrc's rd before (stale)
    lui x29, 833                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 834                       # quiet
    lui x7, 835                       # quiet
    csrrc x26, mscratch, x27          # csrrc: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, minstreth, x25          # subject csrrw: names minstreth and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 836                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 837                      # quiet
    lui x6, 838                       # quiet
# block 86  csr_counter_read_d1  csr_counter_read_d1__minstreth__csr_i (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 86  # marker: block 86
    lui x7, 839                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 840                      # quiet
    lui x29, 841                      # quiet
    addi x8, x0, 4                    # mcountinhibit for minstreth: inhibited
    csrrw x0, mcountinhibit, x8       # mcountinhibit for minstreth: inhibited
    addi x9, x0, 1609                 # csrrci's rd before (stale)
    lui x6, 842                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 843                       # quiet
    lui x28, 844                      # quiet
    csrrci x9, mscratch, 7            # csrrci: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x3, minstreth, x0           # subject csrrs: reads minstreth, d1 (csr_counter_read_d1)
    lui x29, 845                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 846                       # quiet
    lui x7, 847                       # quiet
    addi x3, x0, 1623                 # x3 known again: it held the counter, which differs between the engines
# block 87  csr_counter_read_d1  csr_counter_read_d1__minstreth__csr_i (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 87  # marker: block 87
    lui x28, 848                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 849                      # quiet
    lui x6, 850                       # quiet
    addi x11, x0, 0                   # mcountinhibit for minstreth: enabled
    csrrw x0, mcountinhibit, x11      # mcountinhibit for minstreth: enabled
    addi x12, x0, 1630                # csrrsi's rd before (stale)
    lui x7, 851                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 852                      # quiet
    lui x29, 853                      # quiet
    csrrsi x12, mscratch, 7           # csrrsi: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x10, minstreth, x0          # subject csrrs: reads minstreth, d1 (csr_counter_read_d1)
    lui x6, 854                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 855                       # quiet
    lui x28, 856                      # quiet
    addi x10, x0, 1644                # x10 known again: it held the counter, which differs between the engines
# block 88  csr_counter_read_d1  csr_counter_read_d1__minstreth__csr_i (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 88  # marker: block 88
    lui x29, 857                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 858                       # quiet
    lui x7, 859                       # quiet
    addi x14, x0, 1651                # x14 = 1651
    addi x15, x0, 1658                # csrrwi's rd before (stale)
    lui x28, 860                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 861                      # quiet
    lui x6, 862                       # quiet
    csrrwi x15, mscratch, 7           # csrrwi: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, minstreth, x14          # subject csrrw: names minstreth and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x7, 863                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 864                      # quiet
    lui x29, 865                      # quiet
# block 89  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3__alu_rr (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 89  # marker: block 89
    lui x6, 866                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 867                       # quiet
    lui x28, 868                      # quiet
    addi x17, x0, 8                   # mcountinhibit for mhpmcounter3: inhibited
    csrrw x0, mcountinhibit, x17      # mcountinhibit for mhpmcounter3: inhibited
    addi x19, x0, 1665                # or's operand
    addi x20, x0, 1672                # or's operand
    addi x18, x0, 1679                # or's rd before (stale)
    lui x29, 869                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 870                       # quiet
    lui x7, 871                       # quiet
    or x18, x19, x20                  # or: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x16, mhpmcounter3, x0       # subject csrrs: reads mhpmcounter3, d1 (csr_counter_read_d1)
    lui x28, 872                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 873                      # quiet
    lui x6, 874                       # quiet
    addi x16, x0, 1693                # x16 known again: it held the counter, which differs between the engines
# block 90  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3__alu_rr (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 90  # marker: block 90
    lui x7, 875                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 876                      # quiet
    lui x29, 877                      # quiet
    addi x22, x0, 0                   # mcountinhibit for mhpmcounter3: enabled
    csrrw x0, mcountinhibit, x22      # mcountinhibit for mhpmcounter3: enabled
    addi x24, x0, 1700                # or's operand
    addi x25, x0, 1707                # or's operand
    addi x23, x0, 1714                # or's rd before (stale)
    lui x6, 878                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 879                       # quiet
    lui x28, 880                      # quiet
    or x23, x24, x25                  # or: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x21, mhpmcounter3, x0       # subject csrrs: reads mhpmcounter3, d1 (csr_counter_read_d1)
    lui x29, 881                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 882                       # quiet
    lui x7, 883                       # quiet
    addi x21, x0, 1728                # x21 known again: it held the counter, which differs between the engines
# block 91  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3__alu_rr (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 91  # marker: block 91
    lui x28, 884                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 885                      # quiet
    lui x6, 886                       # quiet
    addi x27, x0, 1735                # x27 = 1735
    addi x8, x0, 1742                 # or's operand
    addi x9, x0, 1749                 # or's operand
    addi x3, x0, 1756                 # or's rd before (stale)
    lui x7, 887                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 888                      # quiet
    lui x29, 889                      # quiet
    or x3, x8, x9                     # or: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter3, x27       # subject csrrw: names mhpmcounter3 and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x6, 890                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 891                       # quiet
    lui x28, 892                      # quiet
# block 92  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3__alu_ri (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 92  # marker: block 92
    lui x29, 893                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 894                       # quiet
    lui x7, 895                       # quiet
    addi x11, x0, 8                   # mcountinhibit for mhpmcounter3: inhibited
    csrrw x0, mcountinhibit, x11      # mcountinhibit for mhpmcounter3: inhibited
    addi x13, x0, 1763                # addi's operand
    addi x12, x0, 1770                # addi's rd before (stale)
    lui x28, 896                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 897                      # quiet
    lui x6, 898                       # quiet
    addi x12, x13, 0                  # addi: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x10, mhpmcounter3, x0       # subject csrrs: reads mhpmcounter3, d1 (csr_counter_read_d1)
    lui x7, 899                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 900                      # quiet
    lui x29, 901                      # quiet
    addi x10, x0, 1784                # x10 known again: it held the counter, which differs between the engines
# block 93  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3__alu_ri (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 93  # marker: block 93
    lui x6, 902                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 903                       # quiet
    lui x28, 904                      # quiet
    addi x15, x0, 0                   # mcountinhibit for mhpmcounter3: enabled
    csrrw x0, mcountinhibit, x15      # mcountinhibit for mhpmcounter3: enabled
    addi x17, x0, 1791                # andi's operand
    addi x16, x0, 1798                # andi's rd before (stale)
    lui x29, 905                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 906                       # quiet
    lui x7, 907                       # quiet
    andi x16, x17, -1                 # andi: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x14, mhpmcounter3, x0       # subject csrrs: reads mhpmcounter3, d1 (csr_counter_read_d1)
    lui x28, 908                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 909                      # quiet
    lui x6, 910                       # quiet
    addi x14, x0, 1812                # x14 known again: it held the counter, which differs between the engines
# block 94  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3__alu_ri (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 94  # marker: block 94
    lui x7, 911                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 912                      # quiet
    lui x29, 913                      # quiet
    addi x19, x0, 1819                # x19 = 1819
    addi x21, x0, 1826                # ori's operand
    addi x20, x0, 1833                # ori's rd before (stale)
    lui x6, 914                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 915                       # quiet
    lui x28, 916                      # quiet
    ori x20, x21, 0                   # ori: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter3, x19       # subject csrrw: names mhpmcounter3 and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x29, 917                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 918                       # quiet
    lui x7, 919                       # quiet
# block 95  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3__alu_nosrc (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 95  # marker: block 95
    lui x28, 920                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 921                      # quiet
    lui x6, 922                       # quiet
    addi x23, x0, 8                   # mcountinhibit for mhpmcounter3: inhibited
    csrrw x0, mcountinhibit, x23      # mcountinhibit for mhpmcounter3: inhibited
    addi x24, x0, 1840                # c.li's rd before (stale)
    lui x7, 923                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 924                      # quiet
    lui x29, 925                      # quiet
    .option push
    .option rvc
    c.li x24, 5                   # c.li: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x22, mhpmcounter3, x0       # subject csrrs: reads mhpmcounter3, d1 (csr_counter_read_d1)
    lui x6, 926                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 927                       # quiet
    lui x28, 928                      # quiet
    addi x22, x0, 1854                # x22 known again: it held the counter, which differs between the engines
# block 96  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3__alu_nosrc (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 96  # marker: block 96
    lui x29, 929                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 930                       # quiet
    lui x7, 931                       # quiet
    addi x26, x0, 0                   # mcountinhibit for mhpmcounter3: enabled
    csrrw x0, mcountinhibit, x26      # mcountinhibit for mhpmcounter3: enabled
    addi x27, x0, 1861                # c.lui's rd before (stale)
    lui x28, 932                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 933                      # quiet
    lui x6, 934                       # quiet
    .option push
    .option rvc
    c.lui x27, 5                  # c.lui: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x25, mhpmcounter3, x0       # subject csrrs: reads mhpmcounter3, d1 (csr_counter_read_d1)
    lui x7, 935                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 936                      # quiet
    lui x29, 937                      # quiet
    addi x25, x0, 1875                # x25 known again: it held the counter, which differs between the engines
# block 97  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3__alu_nosrc (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 97  # marker: block 97
    lui x6, 938                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 939                       # quiet
    lui x28, 940                      # quiet
    addi x8, x0, 1882                 # x8 = 1882
    addi x9, x0, 1889                 # auipc's rd before (stale)
    lui x29, 941                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 942                       # quiet
    lui x7, 943                       # quiet
    auipc x9, 74565                   # auipc: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter3, x8        # subject csrrw: names mhpmcounter3 and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 944                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 945                      # quiet
    lui x6, 946                       # quiet
# block 98  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3__load (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 98  # marker: block 98
    lui x7, 947                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 948                      # quiet
    lui x29, 949                      # quiet
    addi x14, x0, 8                   # mcountinhibit for mhpmcounter3: inhibited
    csrrw x0, mcountinhibit, x14      # mcountinhibit for mhpmcounter3: inhibited
    .L25: auipc x16, %pcrel_hi(w24)   # lw's base -> w24
    lui x6, 950                       # lw's base -> w24 (quiet)
    lui x7, 951                       # lw's base -> w24 (quiet)
    lui x28, 952                      # lw's base -> w24 (quiet)
    addi x16, x16, %pcrel_lo(.L25)    # lw's base -> w24
    addi x15, x0, 407                 # lw's rd before (stale)
    lui x29, 953                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 954                       # quiet
    lui x7, 955                       # quiet
    lw x15, 0(x16)                    # lw: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x13, mhpmcounter3, x0       # subject csrrs: reads mhpmcounter3, d1 (csr_counter_read_d1)
    lui x28, 956                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 957                      # quiet
    lui x6, 958                       # quiet
    addi x13, x0, 421                 # x13 known again: it held the counter, which differs between the engines
# block 99  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3__load (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 99  # marker: block 99
    lui x7, 959                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 960                      # quiet
    lui x29, 961                      # quiet
    addi x18, x0, 0                   # mcountinhibit for mhpmcounter3: enabled
    csrrw x0, mcountinhibit, x18      # mcountinhibit for mhpmcounter3: enabled
    .L26: auipc x20, %pcrel_hi(w25)   # lw's base -> w25
    lui x6, 962                       # lw's base -> w25 (quiet)
    lui x7, 963                       # lw's base -> w25 (quiet)
    lui x28, 964                      # lw's base -> w25 (quiet)
    addi x20, x20, %pcrel_lo(.L26)    # lw's base -> w25
    addi x19, x0, 435                 # lw's rd before (stale)
    lui x29, 965                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 966                       # quiet
    lui x7, 967                       # quiet
    lw x19, 0(x20)                    # lw: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x17, mhpmcounter3, x0       # subject csrrs: reads mhpmcounter3, d1 (csr_counter_read_d1)
    lui x28, 968                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 969                      # quiet
    lui x6, 970                       # quiet
    addi x17, x0, 449                 # x17 known again: it held the counter, which differs between the engines
# block 100  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3__load (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 100  # marker: block 100
    lui x7, 971                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 972                      # quiet
    lui x29, 973                      # quiet
    addi x22, x0, 456                 # x22 = 456
    .L27: auipc x8, %pcrel_hi(w26)    # c.lbu's base -> w26
    lui x6, 974                       # c.lbu's base -> w26 (quiet)
    lui x7, 975                       # c.lbu's base -> w26 (quiet)
    lui x28, 976                      # c.lbu's base -> w26 (quiet)
    addi x8, x8, %pcrel_lo(.L27)      # c.lbu's base -> w26
    addi x15, x0, 470                 # c.lbu's rd before (stale)
    lui x29, 977                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 978                       # quiet
    lui x7, 979                       # quiet
    .option push
    .option rvc
    c.lbu x15, 0(x8)              # c.lbu: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrw x0, mhpmcounter3, x22       # subject csrrw: names mhpmcounter3 and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 980                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 981                      # quiet
    lui x6, 982                       # quiet
# block 101  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3__store (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 101  # marker: block 101
    lui x7, 983                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 984                      # quiet
    lui x29, 985                      # quiet
    addi x26, x0, 8                   # mcountinhibit for mhpmcounter3: inhibited
    csrrw x0, mcountinhibit, x26      # mcountinhibit for mhpmcounter3: inhibited
    .L28: auipc x27, %pcrel_hi(w27)   # sh's base -> w27
    lui x6, 986                       # sh's base -> w27 (quiet)
    lui x7, 987                       # sh's base -> w27 (quiet)
    lui x28, 988                      # sh's base -> w27 (quiet)
    addi x27, x27, %pcrel_lo(.L28)    # sh's base -> w27
    addi x3, x0, 484                  # sh's store data
    lui x29, 989                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 990                       # quiet
    lui x7, 991                       # quiet
    sh x3, 0(x27)                     # sh: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x25, mhpmcounter3, x0       # subject csrrs: reads mhpmcounter3, d1 (csr_counter_read_d1)
    lui x28, 992                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 993                      # quiet
    lui x6, 994                       # quiet
    addi x25, x0, 498                 # x25 known again: it held the counter, which differs between the engines
# block 102  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3__store (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 102  # marker: block 102
    lui x7, 995                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 996                      # quiet
    lui x29, 997                      # quiet
    addi x9, x0, 0                    # mcountinhibit for mhpmcounter3: enabled
    csrrw x0, mcountinhibit, x9       # mcountinhibit for mhpmcounter3: enabled
    .L29: auipc x10, %pcrel_hi(w28)   # sw's base -> w28
    lui x6, 998                       # sw's base -> w28 (quiet)
    lui x7, 999                       # sw's base -> w28 (quiet)
    lui x28, 1000                     # sw's base -> w28 (quiet)
    addi x10, x10, %pcrel_lo(.L29)    # sw's base -> w28
    addi x11, x0, 512                 # sw's store data
    lui x29, 1                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 2                         # quiet
    lui x7, 3                         # quiet
    sw x11, 0(x10)                    # sw: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x8, mhpmcounter3, x0        # subject csrrs: reads mhpmcounter3, d1 (csr_counter_read_d1)
    lui x28, 4                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 5                        # quiet
    lui x6, 6                         # quiet
    addi x8, x0, 526                  # x8 known again: it held the counter, which differs between the engines
# block 103  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3__store (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 103  # marker: block 103
    lui x7, 7                         # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 8                        # quiet
    lui x29, 9                        # quiet
    addi x13, x0, 533                 # x13 = 533
    .L30: auipc x11, %pcrel_hi(w29)   # c.sb's base -> w29
    lui x6, 10                        # c.sb's base -> w29 (quiet)
    lui x7, 11                        # c.sb's base -> w29 (quiet)
    lui x28, 12                       # c.sb's base -> w29 (quiet)
    addi x11, x11, %pcrel_lo(.L30)    # c.sb's base -> w29
    addi x14, x0, 547                 # c.sb's store data
    lui x29, 13                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 14                        # quiet
    lui x7, 15                        # quiet
    .option push
    .option rvc
    c.sb x14, 0(x11)              # c.sb: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrw x0, mhpmcounter3, x13       # subject csrrw: names mhpmcounter3 and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 16                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 17                       # quiet
    lui x6, 18                        # quiet
# block 104  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3__csr_r (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 104  # marker: block 104
    lui x7, 19                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 20                       # quiet
    lui x29, 21                       # quiet
    addi x19, x0, 8                   # mcountinhibit for mhpmcounter3: inhibited
    csrrw x0, mcountinhibit, x19      # mcountinhibit for mhpmcounter3: inhibited
    addi x21, x0, 554                 # csrrs's operand
    addi x20, x0, 561                 # csrrs's rd before (stale)
    lui x6, 22                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 23                        # quiet
    lui x28, 24                       # quiet
    csrrs x20, mscratch, x21          # csrrs: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x18, mhpmcounter3, x0       # subject csrrs: reads mhpmcounter3, d1 (csr_counter_read_d1)
    lui x29, 25                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 26                        # quiet
    lui x7, 27                        # quiet
    addi x18, x0, 575                 # x18 known again: it held the counter, which differs between the engines
# block 105  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3__csr_r (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 105  # marker: block 105
    lui x28, 28                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 29                       # quiet
    lui x6, 30                        # quiet
    addi x23, x0, 0                   # mcountinhibit for mhpmcounter3: enabled
    csrrw x0, mcountinhibit, x23      # mcountinhibit for mhpmcounter3: enabled
    addi x25, x0, 582                 # csrrw's operand
    addi x24, x0, 589                 # csrrw's rd before (stale)
    lui x7, 31                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 32                       # quiet
    lui x29, 33                       # quiet
    csrrw x24, mscratch, x25          # csrrw: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x22, mhpmcounter3, x0       # subject csrrs: reads mhpmcounter3, d1 (csr_counter_read_d1)
    lui x6, 34                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 35                        # quiet
    lui x28, 36                       # quiet
    addi x22, x0, 603                 # x22 known again: it held the counter, which differs between the engines
# block 106  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3__csr_r (after_write)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 106  # marker: block 106
    lui x29, 37                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 38                        # quiet
    lui x7, 39                        # quiet
    addi x27, x0, 610                 # x27 = 610
    lui x28, 40                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 41                       # quiet
    lui x6, 42                        # quiet
    csrrw x0, mhpmcounter3, x27       # csrrw: writes mhpmcounter3, the counter the subject reads
    csrrs x26, mhpmcounter3, x0       # subject csrrs: reads mhpmcounter3, d1 (csr_counter_read_d1)
    lui x7, 43                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 44                       # quiet
    lui x29, 45                       # quiet
    addi x26, x0, 624                 # x26 known again: it held the counter, which differs between the engines
# block 107  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3__csr_r (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 107  # marker: block 107
    lui x6, 46                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 47                        # quiet
    lui x28, 48                       # quiet
    addi x8, x0, 631                  # x8 = 631
    addi x10, x0, 638                 # csrrs's operand
    addi x9, x0, 645                  # csrrs's rd before (stale)
    lui x29, 49                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 50                        # quiet
    lui x7, 51                        # quiet
    csrrs x9, mscratch, x10           # csrrs: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter3, x8        # subject csrrw: names mhpmcounter3 and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 52                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 53                       # quiet
    lui x6, 54                        # quiet
# block 108  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3__csr_i (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 108  # marker: block 108
    lui x7, 55                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 56                       # quiet
    lui x29, 57                       # quiet
    addi x12, x0, 8                   # mcountinhibit for mhpmcounter3: inhibited
    csrrw x0, mcountinhibit, x12      # mcountinhibit for mhpmcounter3: inhibited
    addi x13, x0, 652                 # csrrci's rd before (stale)
    lui x6, 58                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 59                        # quiet
    lui x28, 60                       # quiet
    csrrci x13, mscratch, 7           # csrrci: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x11, mhpmcounter3, x0       # subject csrrs: reads mhpmcounter3, d1 (csr_counter_read_d1)
    lui x29, 61                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 62                        # quiet
    lui x7, 63                        # quiet
    addi x11, x0, 666                 # x11 known again: it held the counter, which differs between the engines
# block 109  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3__csr_i (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 109  # marker: block 109
    lui x28, 64                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 65                       # quiet
    lui x6, 66                        # quiet
    addi x15, x0, 0                   # mcountinhibit for mhpmcounter3: enabled
    csrrw x0, mcountinhibit, x15      # mcountinhibit for mhpmcounter3: enabled
    addi x16, x0, 673                 # csrrsi's rd before (stale)
    lui x7, 67                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 68                       # quiet
    lui x29, 69                       # quiet
    csrrsi x16, mscratch, 7           # csrrsi: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x14, mhpmcounter3, x0       # subject csrrs: reads mhpmcounter3, d1 (csr_counter_read_d1)
    lui x6, 70                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 71                        # quiet
    lui x28, 72                       # quiet
    addi x14, x0, 687                 # x14 known again: it held the counter, which differs between the engines
# block 110  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3__csr_i (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 110  # marker: block 110
    lui x29, 73                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 74                        # quiet
    lui x7, 75                        # quiet
    addi x18, x0, 694                 # x18 = 694
    addi x19, x0, 701                 # csrrwi's rd before (stale)
    lui x28, 76                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 77                       # quiet
    lui x6, 78                        # quiet
    csrrwi x19, mscratch, 7           # csrrwi: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter3, x18       # subject csrrw: names mhpmcounter3 and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x7, 79                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 80                       # quiet
    lui x29, 81                       # quiet
# block 111  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3h__alu_rr (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 111  # marker: block 111
    lui x6, 82                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 83                        # quiet
    lui x28, 84                       # quiet
    addi x21, x0, 8                   # mcountinhibit for mhpmcounter3h: inhibited
    csrrw x0, mcountinhibit, x21      # mcountinhibit for mhpmcounter3h: inhibited
    addi x23, x0, 708                 # or's operand
    addi x24, x0, 715                 # or's operand
    addi x22, x0, 722                 # or's rd before (stale)
    lui x29, 85                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 86                        # quiet
    lui x7, 87                        # quiet
    or x22, x23, x24                  # or: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x20, mhpmcounter3h, x0      # subject csrrs: reads mhpmcounter3h, d1 (csr_counter_read_d1)
    lui x28, 88                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 89                       # quiet
    lui x6, 90                        # quiet
    addi x20, x0, 736                 # x20 known again: it held the counter, which differs between the engines
# block 112  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3h__alu_rr (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 112  # marker: block 112
    lui x7, 91                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 92                       # quiet
    lui x29, 93                       # quiet
    addi x26, x0, 0                   # mcountinhibit for mhpmcounter3h: enabled
    csrrw x0, mcountinhibit, x26      # mcountinhibit for mhpmcounter3h: enabled
    addi x3, x0, 743                  # or's operand
    addi x8, x0, 750                  # or's operand
    addi x27, x0, 757                 # or's rd before (stale)
    lui x6, 94                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 95                        # quiet
    lui x28, 96                       # quiet
    or x27, x3, x8                    # or: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x25, mhpmcounter3h, x0      # subject csrrs: reads mhpmcounter3h, d1 (csr_counter_read_d1)
    lui x29, 97                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 98                        # quiet
    lui x7, 99                        # quiet
    addi x25, x0, 771                 # x25 known again: it held the counter, which differs between the engines
# block 113  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3h__alu_rr (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 113  # marker: block 113
    lui x28, 100                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 101                      # quiet
    lui x6, 102                       # quiet
    addi x10, x0, 778                 # x10 = 778
    addi x12, x0, 785                 # or's operand
    addi x13, x0, 792                 # or's operand
    addi x11, x0, 799                 # or's rd before (stale)
    lui x7, 103                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 104                      # quiet
    lui x29, 105                      # quiet
    or x11, x12, x13                  # or: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter3h, x10      # subject csrrw: names mhpmcounter3h and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x6, 106                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 107                       # quiet
    lui x28, 108                      # quiet
# block 114  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3h__alu_ri (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 114  # marker: block 114
    lui x29, 109                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 110                       # quiet
    lui x7, 111                       # quiet
    addi x15, x0, 8                   # mcountinhibit for mhpmcounter3h: inhibited
    csrrw x0, mcountinhibit, x15      # mcountinhibit for mhpmcounter3h: inhibited
    addi x17, x0, 806                 # ori's operand
    addi x16, x0, 813                 # ori's rd before (stale)
    lui x28, 112                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 113                      # quiet
    lui x6, 114                       # quiet
    ori x16, x17, 0                   # ori: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x14, mhpmcounter3h, x0      # subject csrrs: reads mhpmcounter3h, d1 (csr_counter_read_d1)
    lui x7, 115                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 116                      # quiet
    lui x29, 117                      # quiet
    addi x14, x0, 827                 # x14 known again: it held the counter, which differs between the engines
# block 115  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3h__alu_ri (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 115  # marker: block 115
    lui x6, 118                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 119                       # quiet
    lui x28, 120                      # quiet
    addi x19, x0, 0                   # mcountinhibit for mhpmcounter3h: enabled
    csrrw x0, mcountinhibit, x19      # mcountinhibit for mhpmcounter3h: enabled
    addi x21, x0, 834                 # ori's operand
    addi x20, x0, 841                 # ori's rd before (stale)
    lui x29, 121                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 122                       # quiet
    lui x7, 123                       # quiet
    ori x20, x21, 0                   # ori: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x18, mhpmcounter3h, x0      # subject csrrs: reads mhpmcounter3h, d1 (csr_counter_read_d1)
    lui x28, 124                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 125                      # quiet
    lui x6, 126                       # quiet
    addi x18, x0, 855                 # x18 known again: it held the counter, which differs between the engines
# block 116  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3h__alu_ri (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 116  # marker: block 116
    lui x7, 127                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 128                      # quiet
    lui x29, 129                      # quiet
    addi x23, x0, 862                 # x23 = 862
    addi x25, x0, 869                 # ori's operand
    addi x24, x0, 876                 # ori's rd before (stale)
    lui x6, 130                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 131                       # quiet
    lui x28, 132                      # quiet
    ori x24, x25, 0                   # ori: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter3h, x23      # subject csrrw: names mhpmcounter3h and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x29, 133                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 134                       # quiet
    lui x7, 135                       # quiet
# block 117  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3h__alu_nosrc (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 117  # marker: block 117
    lui x28, 136                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 137                      # quiet
    lui x6, 138                       # quiet
    addi x27, x0, 8                   # mcountinhibit for mhpmcounter3h: inhibited
    csrrw x0, mcountinhibit, x27      # mcountinhibit for mhpmcounter3h: inhibited
    addi x3, x0, 883                  # lui's rd before (stale)
    lui x7, 139                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 140                      # quiet
    lui x29, 141                      # quiet
    lui x3, 74565                     # lui: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x26, mhpmcounter3h, x0      # subject csrrs: reads mhpmcounter3h, d1 (csr_counter_read_d1)
    lui x6, 142                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 143                       # quiet
    lui x28, 144                      # quiet
    addi x26, x0, 897                 # x26 known again: it held the counter, which differs between the engines
# block 118  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3h__alu_nosrc (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 118  # marker: block 118
    lui x29, 145                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 146                       # quiet
    lui x7, 147                       # quiet
    addi x9, x0, 0                    # mcountinhibit for mhpmcounter3h: enabled
    csrrw x0, mcountinhibit, x9       # mcountinhibit for mhpmcounter3h: enabled
    addi x10, x0, 904                 # c.li's rd before (stale)
    lui x28, 148                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 149                      # quiet
    lui x6, 150                       # quiet
    .option push
    .option rvc
    c.li x10, 5                   # c.li: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x8, mhpmcounter3h, x0       # subject csrrs: reads mhpmcounter3h, d1 (csr_counter_read_d1)
    lui x7, 151                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 152                      # quiet
    lui x29, 153                      # quiet
    addi x8, x0, 918                  # x8 known again: it held the counter, which differs between the engines
# block 119  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3h__alu_nosrc (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 119  # marker: block 119
    lui x6, 154                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 155                       # quiet
    lui x28, 156                      # quiet
    addi x12, x0, 925                 # x12 = 925
    addi x13, x0, 932                 # c.lui's rd before (stale)
    lui x29, 157                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 158                       # quiet
    lui x7, 159                       # quiet
    .option push
    .option rvc
    c.lui x13, 5                  # c.lui: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrw x0, mhpmcounter3h, x12      # subject csrrw: names mhpmcounter3h and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 160                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 161                      # quiet
    lui x6, 162                       # quiet
# block 120  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3h__load (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 120  # marker: block 120
    lui x7, 163                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 164                      # quiet
    lui x29, 165                      # quiet
    addi x17, x0, 8                   # mcountinhibit for mhpmcounter3h: inhibited
    csrrw x0, mcountinhibit, x17      # mcountinhibit for mhpmcounter3h: inhibited
    .L31: auipc x9, %pcrel_hi(w30)    # c.lh's base -> w30
    lui x6, 166                       # c.lh's base -> w30 (quiet)
    lui x7, 167                       # c.lh's base -> w30 (quiet)
    lui x28, 168                      # c.lh's base -> w30 (quiet)
    addi x9, x9, %pcrel_lo(.L31)      # c.lh's base -> w30
    addi x8, x0, 1233                 # c.lh's rd before (stale)
    lui x29, 169                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 170                       # quiet
    lui x7, 171                       # quiet
    .option push
    .option rvc
    c.lh x8, 0(x9)                # c.lh: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x16, mhpmcounter3h, x0      # subject csrrs: reads mhpmcounter3h, d1 (csr_counter_read_d1)
    lui x28, 172                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 173                      # quiet
    lui x6, 174                       # quiet
    addi x16, x0, 1247                # x16 known again: it held the counter, which differs between the engines
# block 121  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3h__load (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 121  # marker: block 121
    lui x7, 175                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 176                      # quiet
    lui x29, 177                      # quiet
    addi x21, x0, 0                   # mcountinhibit for mhpmcounter3h: enabled
    csrrw x0, mcountinhibit, x21      # mcountinhibit for mhpmcounter3h: enabled
    .L32: auipc x13, %pcrel_hi(w31)   # c.lhu's base -> w31
    lui x6, 178                       # c.lhu's base -> w31 (quiet)
    lui x7, 179                       # c.lhu's base -> w31 (quiet)
    lui x28, 180                      # c.lhu's base -> w31 (quiet)
    addi x13, x13, %pcrel_lo(.L32)    # c.lhu's base -> w31
    addi x12, x0, 1261                # c.lhu's rd before (stale)
    lui x29, 181                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 182                       # quiet
    lui x7, 183                       # quiet
    .option push
    .option rvc
    c.lhu x12, 0(x13)             # c.lhu: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x20, mhpmcounter3h, x0      # subject csrrs: reads mhpmcounter3h, d1 (csr_counter_read_d1)
    lui x28, 184                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 185                      # quiet
    lui x6, 186                       # quiet
    addi x20, x0, 1275                # x20 known again: it held the counter, which differs between the engines
# block 122  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3h__load (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 122  # marker: block 122
    lui x7, 187                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 188                      # quiet
    lui x29, 189                      # quiet
    addi x25, x0, 1282                # x25 = 1282
    .L33: auipc x9, %pcrel_hi(w32)    # c.lw's base -> w32
    lui x6, 190                       # c.lw's base -> w32 (quiet)
    lui x7, 191                       # c.lw's base -> w32 (quiet)
    lui x28, 192                      # c.lw's base -> w32 (quiet)
    addi x9, x9, %pcrel_lo(.L33)      # c.lw's base -> w32
    addi x8, x0, 1296                 # c.lw's rd before (stale)
    lui x29, 193                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 194                       # quiet
    lui x7, 195                       # quiet
    .option push
    .option rvc
    c.lw x8, 0(x9)                # c.lw: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrw x0, mhpmcounter3h, x25      # subject csrrw: names mhpmcounter3h and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 196                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 197                      # quiet
    lui x6, 198                       # quiet
# block 123  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3h__store (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 123  # marker: block 123
    lui x7, 199                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 200                      # quiet
    lui x29, 201                      # quiet
    addi x8, x0, 8                    # mcountinhibit for mhpmcounter3h: inhibited
    csrrw x0, mcountinhibit, x8       # mcountinhibit for mhpmcounter3h: inhibited
    .L34: auipc x12, %pcrel_hi(w33)   # c.sh's base -> w33
    lui x6, 202                       # c.sh's base -> w33 (quiet)
    lui x7, 203                       # c.sh's base -> w33 (quiet)
    lui x28, 204                      # c.sh's base -> w33 (quiet)
    addi x12, x12, %pcrel_lo(.L34)    # c.sh's base -> w33
    addi x13, x0, -2                  # c.sh's store data
    lui x29, 205                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 206                       # quiet
    lui x7, 207                       # quiet
    .option push
    .option rvc
    c.sh x13, 0(x12)              # c.sh: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x3, mhpmcounter3h, x0       # subject csrrs: reads mhpmcounter3h, d1 (csr_counter_read_d1)
    lui x28, 208                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 209                      # quiet
    lui x6, 210                       # quiet
    addi x3, x0, 1317                 # x3 known again: it held the counter, which differs between the engines
# block 124  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3h__store (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 124  # marker: block 124
    lui x7, 211                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 212                      # quiet
    lui x29, 213                      # quiet
    addi x12, x0, 0                   # mcountinhibit for mhpmcounter3h: enabled
    csrrw x0, mcountinhibit, x12      # mcountinhibit for mhpmcounter3h: enabled
    .L35: auipc x8, %pcrel_hi(w34)    # c.sw's base -> w34
    lui x6, 214                       # c.sw's base -> w34 (quiet)
    lui x7, 215                       # c.sw's base -> w34 (quiet)
    lui x28, 216                      # c.sw's base -> w34 (quiet)
    addi x8, x8, %pcrel_lo(.L35)      # c.sw's base -> w34
    addi x9, x0, 1331                 # c.sw's store data
    lui x29, 217                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 218                       # quiet
    lui x7, 219                       # quiet
    .option push
    .option rvc
    c.sw x9, 0(x8)                # c.sw: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x11, mhpmcounter3h, x0      # subject csrrs: reads mhpmcounter3h, d1 (csr_counter_read_d1)
    lui x28, 220                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 221                      # quiet
    lui x6, 222                       # quiet
    addi x11, x0, 1345                # x11 known again: it held the counter, which differs between the engines
# block 125  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3h__store (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 125  # marker: block 125
    lui x7, 223                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 224                      # quiet
    lui x29, 225                      # quiet
    addi x16, x0, 1352                # x16 = 1352
    .L36: auipc x2, %pcrel_hi(w35)    # c.swsp's base -> w35
    lui x6, 226                       # c.swsp's base -> w35 (quiet)
    lui x7, 227                       # c.swsp's base -> w35 (quiet)
    lui x28, 228                      # c.swsp's base -> w35 (quiet)
    addi x2, x2, %pcrel_lo(.L36)      # c.swsp's base -> w35
    addi x17, x0, 1366                # c.swsp's store data
    lui x29, 229                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 230                       # quiet
    lui x7, 231                       # quiet
    .option push
    .option rvc
    c.swsp x17, 0(sp)             # c.swsp: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrw x0, mhpmcounter3h, x16      # subject csrrw: names mhpmcounter3h and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 232                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 233                      # quiet
    lui x6, 234                       # quiet
# block 126  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3h__csr_r (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 126  # marker: block 126
    lui x7, 235                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 236                      # quiet
    lui x29, 237                      # quiet
    addi x19, x0, 8                   # mcountinhibit for mhpmcounter3h: inhibited
    csrrw x0, mcountinhibit, x19      # mcountinhibit for mhpmcounter3h: inhibited
    addi x21, x0, 1373                # csrrw's operand
    addi x20, x0, 1380                # csrrw's rd before (stale)
    lui x6, 238                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 239                       # quiet
    lui x28, 240                      # quiet
    csrrw x20, mscratch, x21          # csrrw: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x18, mhpmcounter3h, x0      # subject csrrs: reads mhpmcounter3h, d1 (csr_counter_read_d1)
    lui x29, 241                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 242                       # quiet
    lui x7, 243                       # quiet
    addi x18, x0, 1394                # x18 known again: it held the counter, which differs between the engines
# block 127  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3h__csr_r (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 127  # marker: block 127
    lui x28, 244                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 245                      # quiet
    lui x6, 246                       # quiet
    addi x23, x0, 0                   # mcountinhibit for mhpmcounter3h: enabled
    csrrw x0, mcountinhibit, x23      # mcountinhibit for mhpmcounter3h: enabled
    addi x25, x0, 1401                # csrrc's operand
    addi x24, x0, 1408                # csrrc's rd before (stale)
    lui x7, 247                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 248                      # quiet
    lui x29, 249                      # quiet
    csrrc x24, mscratch, x25          # csrrc: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x22, mhpmcounter3h, x0      # subject csrrs: reads mhpmcounter3h, d1 (csr_counter_read_d1)
    lui x6, 250                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 251                       # quiet
    lui x28, 252                      # quiet
    addi x22, x0, 1422                # x22 known again: it held the counter, which differs between the engines
# block 128  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3h__csr_r (after_write)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 128  # marker: block 128
    lui x29, 253                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 254                       # quiet
    lui x7, 255                       # quiet
    addi x27, x0, 1429                # x27 = 1429
    lui x28, 256                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 257                      # quiet
    lui x6, 258                       # quiet
    csrrw x0, mhpmcounter3h, x27      # csrrw: writes mhpmcounter3h, the counter the subject reads
    csrrs x26, mhpmcounter3h, x0      # subject csrrs: reads mhpmcounter3h, d1 (csr_counter_read_d1)
    lui x7, 259                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 260                      # quiet
    lui x29, 261                      # quiet
    addi x26, x0, 1443                # x26 known again: it held the counter, which differs between the engines
# block 129  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3h__csr_r (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 129  # marker: block 129
    lui x6, 262                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 263                       # quiet
    lui x28, 264                      # quiet
    addi x8, x0, 1450                 # x8 = 1450
    addi x10, x0, 1457                # csrrw's operand
    addi x9, x0, 1464                 # csrrw's rd before (stale)
    lui x29, 265                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 266                       # quiet
    lui x7, 267                       # quiet
    csrrw x9, mscratch, x10           # csrrw: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter3h, x8       # subject csrrw: names mhpmcounter3h and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 268                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 269                      # quiet
    lui x6, 270                       # quiet
# block 130  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3h__csr_i (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 130  # marker: block 130
    lui x7, 271                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 272                      # quiet
    lui x29, 273                      # quiet
    addi x12, x0, 8                   # mcountinhibit for mhpmcounter3h: inhibited
    csrrw x0, mcountinhibit, x12      # mcountinhibit for mhpmcounter3h: inhibited
    addi x13, x0, 1471                # csrrci's rd before (stale)
    lui x6, 274                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 275                       # quiet
    lui x28, 276                      # quiet
    csrrci x13, mscratch, 7           # csrrci: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x11, mhpmcounter3h, x0      # subject csrrs: reads mhpmcounter3h, d1 (csr_counter_read_d1)
    lui x29, 277                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 278                       # quiet
    lui x7, 279                       # quiet
    addi x11, x0, 1485                # x11 known again: it held the counter, which differs between the engines
# block 131  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3h__csr_i (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 131  # marker: block 131
    lui x28, 280                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 281                      # quiet
    lui x6, 282                       # quiet
    addi x15, x0, 0                   # mcountinhibit for mhpmcounter3h: enabled
    csrrw x0, mcountinhibit, x15      # mcountinhibit for mhpmcounter3h: enabled
    addi x16, x0, 1492                # csrrsi's rd before (stale)
    lui x7, 283                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 284                      # quiet
    lui x29, 285                      # quiet
    csrrsi x16, mscratch, 7           # csrrsi: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x14, mhpmcounter3h, x0      # subject csrrs: reads mhpmcounter3h, d1 (csr_counter_read_d1)
    lui x6, 286                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 287                       # quiet
    lui x28, 288                      # quiet
    addi x14, x0, 1506                # x14 known again: it held the counter, which differs between the engines
# block 132  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter3h__csr_i (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 132  # marker: block 132
    lui x29, 289                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 290                       # quiet
    lui x7, 291                       # quiet
    addi x18, x0, 1513                # x18 = 1513
    addi x19, x0, 1520                # csrrwi's rd before (stale)
    lui x28, 292                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 293                      # quiet
    lui x6, 294                       # quiet
    csrrwi x19, mscratch, 7           # csrrwi: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter3h, x18      # subject csrrw: names mhpmcounter3h and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x7, 295                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 296                      # quiet
    lui x29, 297                      # quiet
# block 133  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4__alu_rr (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 133  # marker: block 133
    lui x6, 298                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 299                       # quiet
    lui x28, 300                      # quiet
    addi x21, x0, 16                  # mcountinhibit for mhpmcounter4: inhibited
    csrrw x0, mcountinhibit, x21      # mcountinhibit for mhpmcounter4: inhibited
    addi x23, x0, 1527                # or's operand
    addi x24, x0, 1534                # or's operand
    addi x22, x0, 1541                # or's rd before (stale)
    lui x29, 301                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 302                       # quiet
    lui x7, 303                       # quiet
    or x22, x23, x24                  # or: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x20, mhpmcounter4, x0       # subject csrrs: reads mhpmcounter4, d1 (csr_counter_read_d1)
    lui x28, 304                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 305                      # quiet
    lui x6, 306                       # quiet
    addi x20, x0, 1555                # x20 known again: it held the counter, which differs between the engines
# block 134  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4__alu_rr (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 134  # marker: block 134
    lui x7, 307                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 308                      # quiet
    lui x29, 309                      # quiet
    addi x26, x0, 0                   # mcountinhibit for mhpmcounter4: enabled
    csrrw x0, mcountinhibit, x26      # mcountinhibit for mhpmcounter4: enabled
    addi x3, x0, 1562                 # or's operand
    addi x8, x0, 1569                 # or's operand
    addi x27, x0, 1576                # or's rd before (stale)
    lui x6, 310                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 311                       # quiet
    lui x28, 312                      # quiet
    or x27, x3, x8                    # or: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x25, mhpmcounter4, x0       # subject csrrs: reads mhpmcounter4, d1 (csr_counter_read_d1)
    lui x29, 313                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 314                       # quiet
    lui x7, 315                       # quiet
    addi x25, x0, 1590                # x25 known again: it held the counter, which differs between the engines
# block 135  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4__alu_rr (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 135  # marker: block 135
    lui x28, 316                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 317                      # quiet
    lui x6, 318                       # quiet
    addi x10, x0, 1597                # x10 = 1597
    addi x12, x0, 1604                # or's operand
    addi x13, x0, 1611                # or's operand
    addi x11, x0, 1618                # or's rd before (stale)
    lui x7, 319                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 320                      # quiet
    lui x29, 321                      # quiet
    or x11, x12, x13                  # or: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter4, x10       # subject csrrw: names mhpmcounter4 and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x6, 322                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 323                       # quiet
    lui x28, 324                      # quiet
# block 136  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4__alu_ri (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 136  # marker: block 136
    lui x29, 325                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 326                       # quiet
    lui x7, 327                       # quiet
    addi x15, x0, 16                  # mcountinhibit for mhpmcounter4: inhibited
    csrrw x0, mcountinhibit, x15      # mcountinhibit for mhpmcounter4: inhibited
    addi x17, x0, 1625                # ori's operand
    addi x16, x0, 1632                # ori's rd before (stale)
    lui x28, 328                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 329                      # quiet
    lui x6, 330                       # quiet
    ori x16, x17, 0                   # ori: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x14, mhpmcounter4, x0       # subject csrrs: reads mhpmcounter4, d1 (csr_counter_read_d1)
    lui x7, 331                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 332                      # quiet
    lui x29, 333                      # quiet
    addi x14, x0, 1646                # x14 known again: it held the counter, which differs between the engines
# block 137  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4__alu_ri (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 137  # marker: block 137
    lui x6, 334                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 335                       # quiet
    lui x28, 336                      # quiet
    addi x19, x0, 0                   # mcountinhibit for mhpmcounter4: enabled
    csrrw x0, mcountinhibit, x19      # mcountinhibit for mhpmcounter4: enabled
    addi x21, x0, 1653                # ori's operand
    addi x20, x0, 1660                # ori's rd before (stale)
    lui x29, 337                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 338                       # quiet
    lui x7, 339                       # quiet
    ori x20, x21, 0                   # ori: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x18, mhpmcounter4, x0       # subject csrrs: reads mhpmcounter4, d1 (csr_counter_read_d1)
    lui x28, 340                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 341                      # quiet
    lui x6, 342                       # quiet
    addi x18, x0, 1674                # x18 known again: it held the counter, which differs between the engines
# block 138  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4__alu_ri (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 138  # marker: block 138
    lui x7, 343                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 344                      # quiet
    lui x29, 345                      # quiet
    addi x23, x0, 1681                # x23 = 1681
    addi x25, x0, 1688                # ori's operand
    addi x24, x0, 1695                # ori's rd before (stale)
    lui x6, 346                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 347                       # quiet
    lui x28, 348                      # quiet
    ori x24, x25, 0                   # ori: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter4, x23       # subject csrrw: names mhpmcounter4 and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x29, 349                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 350                       # quiet
    lui x7, 351                       # quiet
# block 139  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4__alu_nosrc (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 139  # marker: block 139
    lui x28, 352                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 353                      # quiet
    lui x6, 354                       # quiet
    addi x27, x0, 16                  # mcountinhibit for mhpmcounter4: inhibited
    csrrw x0, mcountinhibit, x27      # mcountinhibit for mhpmcounter4: inhibited
    addi x3, x0, 1702                 # auipc's rd before (stale)
    lui x7, 355                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 356                      # quiet
    lui x29, 357                      # quiet
    auipc x3, 74565                   # auipc: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x26, mhpmcounter4, x0       # subject csrrs: reads mhpmcounter4, d1 (csr_counter_read_d1)
    lui x6, 358                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 359                       # quiet
    lui x28, 360                      # quiet
    addi x26, x0, 1716                # x26 known again: it held the counter, which differs between the engines
# block 140  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4__alu_nosrc (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 140  # marker: block 140
    lui x29, 361                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 362                       # quiet
    lui x7, 363                       # quiet
    addi x9, x0, 0                    # mcountinhibit for mhpmcounter4: enabled
    csrrw x0, mcountinhibit, x9       # mcountinhibit for mhpmcounter4: enabled
    addi x10, x0, 1723                # lui's rd before (stale)
    lui x28, 364                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 365                      # quiet
    lui x6, 366                       # quiet
    lui x10, 74565                    # lui: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x8, mhpmcounter4, x0        # subject csrrs: reads mhpmcounter4, d1 (csr_counter_read_d1)
    lui x7, 367                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 368                      # quiet
    lui x29, 369                      # quiet
    addi x8, x0, 1737                 # x8 known again: it held the counter, which differs between the engines
# block 141  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4__alu_nosrc (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 141  # marker: block 141
    lui x6, 370                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 371                       # quiet
    lui x28, 372                      # quiet
    addi x12, x0, 1744                # x12 = 1744
    addi x13, x0, 1751                # c.li's rd before (stale)
    lui x29, 373                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 374                       # quiet
    lui x7, 375                       # quiet
    .option push
    .option rvc
    c.li x13, 5                   # c.li: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrw x0, mhpmcounter4, x12       # subject csrrw: names mhpmcounter4 and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 376                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 377                      # quiet
    lui x6, 378                       # quiet
# block 142  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4__load (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 142  # marker: block 142
    lui x7, 379                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 380                      # quiet
    lui x29, 381                      # quiet
    addi x16, x0, 16                  # mcountinhibit for mhpmcounter4: inhibited
    csrrw x0, mcountinhibit, x16      # mcountinhibit for mhpmcounter4: inhibited
    .L37: auipc x2, %pcrel_hi(w36)    # c.lwsp's base -> w36
    lui x6, 382                       # c.lwsp's base -> w36 (quiet)
    lui x7, 383                       # c.lwsp's base -> w36 (quiet)
    lui x28, 384                      # c.lwsp's base -> w36 (quiet)
    addi x2, x2, %pcrel_lo(.L37)      # c.lwsp's base -> w36
    addi x17, x0, 269                 # c.lwsp's rd before (stale)
    lui x29, 385                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 386                       # quiet
    lui x7, 387                       # quiet
    .option push
    .option rvc
    c.lwsp x17, 0(sp)             # c.lwsp: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x15, mhpmcounter4, x0       # subject csrrs: reads mhpmcounter4, d1 (csr_counter_read_d1)
    lui x28, 388                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 389                      # quiet
    lui x6, 390                       # quiet
    addi x15, x0, 283                 # x15 known again: it held the counter, which differs between the engines
# block 143  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4__load (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 143  # marker: block 143
    lui x7, 391                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 392                      # quiet
    lui x29, 393                      # quiet
    addi x19, x0, 0                   # mcountinhibit for mhpmcounter4: enabled
    csrrw x0, mcountinhibit, x19      # mcountinhibit for mhpmcounter4: enabled
    .L38: auipc x21, %pcrel_hi(w37)   # lb's base -> w37
    lui x6, 394                       # lb's base -> w37 (quiet)
    lui x7, 395                       # lb's base -> w37 (quiet)
    lui x28, 396                      # lb's base -> w37 (quiet)
    addi x21, x21, %pcrel_lo(.L38)    # lb's base -> w37
    addi x20, x0, 297                 # lb's rd before (stale)
    lui x29, 397                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 398                       # quiet
    lui x7, 399                       # quiet
    lb x20, 0(x21)                    # lb: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x18, mhpmcounter4, x0       # subject csrrs: reads mhpmcounter4, d1 (csr_counter_read_d1)
    lui x28, 400                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 401                      # quiet
    lui x6, 402                       # quiet
    addi x18, x0, 311                 # x18 known again: it held the counter, which differs between the engines
# block 144  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4__load (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 144  # marker: block 144
    lui x7, 403                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 404                      # quiet
    lui x29, 405                      # quiet
    addi x23, x0, 318                 # x23 = 318
    .L39: auipc x25, %pcrel_hi(w38)   # lbu's base -> w38
    lui x6, 406                       # lbu's base -> w38 (quiet)
    lui x7, 407                       # lbu's base -> w38 (quiet)
    lui x28, 408                      # lbu's base -> w38 (quiet)
    addi x25, x25, %pcrel_lo(.L39)    # lbu's base -> w38
    addi x24, x0, 332                 # lbu's rd before (stale)
    lui x29, 409                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 410                       # quiet
    lui x7, 411                       # quiet
    lbu x24, 0(x25)                   # lbu: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter4, x23       # subject csrrw: names mhpmcounter4 and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 412                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 413                      # quiet
    lui x6, 414                       # quiet
# block 145  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4__store (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 145  # marker: block 145
    lui x7, 415                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 416                      # quiet
    lui x29, 417                      # quiet
    addi x27, x0, 16                  # mcountinhibit for mhpmcounter4: inhibited
    csrrw x0, mcountinhibit, x27      # mcountinhibit for mhpmcounter4: inhibited
    .L40: auipc x3, %pcrel_hi(w39)    # sb's base -> w39
    lui x6, 418                       # sb's base -> w39 (quiet)
    lui x7, 419                       # sb's base -> w39 (quiet)
    lui x28, 420                      # sb's base -> w39 (quiet)
    addi x3, x3, %pcrel_lo(.L40)      # sb's base -> w39
    addi x8, x0, 346                  # sb's store data
    lui x29, 421                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 422                       # quiet
    lui x7, 423                       # quiet
    sb x8, 0(x3)                      # sb: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x26, mhpmcounter4, x0       # subject csrrs: reads mhpmcounter4, d1 (csr_counter_read_d1)
    lui x28, 424                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 425                      # quiet
    lui x6, 426                       # quiet
    addi x26, x0, 360                 # x26 known again: it held the counter, which differs between the engines
# block 146  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4__store (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 146  # marker: block 146
    lui x7, 427                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 428                      # quiet
    lui x29, 429                      # quiet
    addi x10, x0, 0                   # mcountinhibit for mhpmcounter4: enabled
    csrrw x0, mcountinhibit, x10      # mcountinhibit for mhpmcounter4: enabled
    .L41: auipc x11, %pcrel_hi(w40)   # sh's base -> w40
    lui x6, 430                       # sh's base -> w40 (quiet)
    lui x7, 431                       # sh's base -> w40 (quiet)
    lui x28, 432                      # sh's base -> w40 (quiet)
    addi x11, x11, %pcrel_lo(.L41)    # sh's base -> w40
    addi x12, x0, 0                   # sh's store data
    lui x29, 433                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 434                       # quiet
    lui x7, 435                       # quiet
    sh x12, 0(x11)                    # sh: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x9, mhpmcounter4, x0        # subject csrrs: reads mhpmcounter4, d1 (csr_counter_read_d1)
    lui x28, 436                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 437                      # quiet
    lui x6, 438                       # quiet
    addi x9, x0, 381                  # x9 known again: it held the counter, which differs between the engines
# block 147  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4__store (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 147  # marker: block 147
    lui x7, 439                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 440                      # quiet
    lui x29, 441                      # quiet
    addi x14, x0, 388                 # x14 = 388
    .L42: auipc x15, %pcrel_hi(w41)   # sw's base -> w41
    lui x6, 442                       # sw's base -> w41 (quiet)
    lui x7, 443                       # sw's base -> w41 (quiet)
    lui x28, 444                      # sw's base -> w41 (quiet)
    addi x15, x15, %pcrel_lo(.L42)    # sw's base -> w41
    addi x16, x0, 402                 # sw's store data
    lui x29, 445                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 446                       # quiet
    lui x7, 447                       # quiet
    sw x16, 0(x15)                    # sw: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter4, x14       # subject csrrw: names mhpmcounter4 and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 448                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 449                      # quiet
    lui x6, 450                       # quiet
# block 148  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4__csr_r (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 148  # marker: block 148
    lui x7, 451                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 452                      # quiet
    lui x29, 453                      # quiet
    addi x18, x0, 16                  # mcountinhibit for mhpmcounter4: inhibited
    csrrw x0, mcountinhibit, x18      # mcountinhibit for mhpmcounter4: inhibited
    addi x20, x0, 409                 # csrrc's operand
    addi x19, x0, 416                 # csrrc's rd before (stale)
    lui x6, 454                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 455                       # quiet
    lui x28, 456                      # quiet
    csrrc x19, mscratch, x20          # csrrc: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x17, mhpmcounter4, x0       # subject csrrs: reads mhpmcounter4, d1 (csr_counter_read_d1)
    lui x29, 457                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 458                       # quiet
    lui x7, 459                       # quiet
    addi x17, x0, 430                 # x17 known again: it held the counter, which differs between the engines
# block 149  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4__csr_r (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 149  # marker: block 149
    lui x28, 460                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 461                      # quiet
    lui x6, 462                       # quiet
    addi x22, x0, 0                   # mcountinhibit for mhpmcounter4: enabled
    csrrw x0, mcountinhibit, x22      # mcountinhibit for mhpmcounter4: enabled
    addi x24, x0, 437                 # csrrs's operand
    addi x23, x0, 444                 # csrrs's rd before (stale)
    lui x7, 463                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 464                      # quiet
    lui x29, 465                      # quiet
    csrrs x23, mscratch, x24          # csrrs: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x21, mhpmcounter4, x0       # subject csrrs: reads mhpmcounter4, d1 (csr_counter_read_d1)
    lui x6, 466                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 467                       # quiet
    lui x28, 468                      # quiet
    addi x21, x0, 458                 # x21 known again: it held the counter, which differs between the engines
# block 150  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4__csr_r (after_write)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 150  # marker: block 150
    lui x29, 469                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 470                       # quiet
    lui x7, 471                       # quiet
    addi x26, x0, 465                 # x26 = 465
    lui x28, 472                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 473                      # quiet
    lui x6, 474                       # quiet
    csrrw x0, mhpmcounter4, x26       # csrrw: writes mhpmcounter4, the counter the subject reads
    csrrs x25, mhpmcounter4, x0       # subject csrrs: reads mhpmcounter4, d1 (csr_counter_read_d1)
    lui x7, 475                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 476                      # quiet
    lui x29, 477                      # quiet
    addi x25, x0, 479                 # x25 known again: it held the counter, which differs between the engines
# block 151  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4__csr_r (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 151  # marker: block 151
    lui x6, 478                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 479                       # quiet
    lui x28, 480                      # quiet
    addi x3, x0, 486                  # x3 = 486
    addi x9, x0, 493                  # csrrc's operand
    addi x8, x0, 500                  # csrrc's rd before (stale)
    lui x29, 481                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 482                       # quiet
    lui x7, 483                       # quiet
    csrrc x8, mscratch, x9            # csrrc: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter4, x3        # subject csrrw: names mhpmcounter4 and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 484                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 485                      # quiet
    lui x6, 486                       # quiet
# block 152  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4__csr_i (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 152  # marker: block 152
    lui x7, 487                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 488                      # quiet
    lui x29, 489                      # quiet
    addi x11, x0, 16                  # mcountinhibit for mhpmcounter4: inhibited
    csrrw x0, mcountinhibit, x11      # mcountinhibit for mhpmcounter4: inhibited
    addi x12, x0, 507                 # csrrci's rd before (stale)
    lui x6, 490                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 491                       # quiet
    lui x28, 492                      # quiet
    csrrci x12, mscratch, 7           # csrrci: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x10, mhpmcounter4, x0       # subject csrrs: reads mhpmcounter4, d1 (csr_counter_read_d1)
    lui x29, 493                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 494                       # quiet
    lui x7, 495                       # quiet
    addi x10, x0, 521                 # x10 known again: it held the counter, which differs between the engines
# block 153  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4__csr_i (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 153  # marker: block 153
    lui x28, 496                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 497                      # quiet
    lui x6, 498                       # quiet
    addi x14, x0, 0                   # mcountinhibit for mhpmcounter4: enabled
    csrrw x0, mcountinhibit, x14      # mcountinhibit for mhpmcounter4: enabled
    addi x15, x0, 528                 # csrrsi's rd before (stale)
    lui x7, 499                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 500                      # quiet
    lui x29, 501                      # quiet
    csrrsi x15, mscratch, 7           # csrrsi: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x13, mhpmcounter4, x0       # subject csrrs: reads mhpmcounter4, d1 (csr_counter_read_d1)
    lui x6, 502                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 503                       # quiet
    lui x28, 504                      # quiet
    addi x13, x0, 542                 # x13 known again: it held the counter, which differs between the engines
# block 154  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4__csr_i (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 154  # marker: block 154
    lui x29, 505                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 506                       # quiet
    lui x7, 507                       # quiet
    addi x17, x0, 549                 # x17 = 549
    addi x18, x0, 556                 # csrrwi's rd before (stale)
    lui x28, 508                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 509                      # quiet
    lui x6, 510                       # quiet
    csrrwi x18, mscratch, 7           # csrrwi: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter4, x17       # subject csrrw: names mhpmcounter4 and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x7, 511                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 512                      # quiet
    lui x29, 513                      # quiet
# block 155  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4h__alu_rr (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 155  # marker: block 155
    lui x6, 514                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 515                       # quiet
    lui x28, 516                      # quiet
    addi x20, x0, 16                  # mcountinhibit for mhpmcounter4h: inhibited
    csrrw x0, mcountinhibit, x20      # mcountinhibit for mhpmcounter4h: inhibited
    addi x22, x0, 563                 # sll's operand
    addi x23, x0, 570                 # sll's operand
    addi x21, x0, 577                 # sll's rd before (stale)
    lui x29, 517                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 518                       # quiet
    lui x7, 519                       # quiet
    sll x21, x22, x23                 # sll: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x19, mhpmcounter4h, x0      # subject csrrs: reads mhpmcounter4h, d1 (csr_counter_read_d1)
    lui x28, 520                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 521                      # quiet
    lui x6, 522                       # quiet
    addi x19, x0, 591                 # x19 known again: it held the counter, which differs between the engines
# block 156  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4h__alu_rr (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 156  # marker: block 156
    lui x7, 523                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 524                      # quiet
    lui x29, 525                      # quiet
    addi x25, x0, 0                   # mcountinhibit for mhpmcounter4h: enabled
    csrrw x0, mcountinhibit, x25      # mcountinhibit for mhpmcounter4h: enabled
    addi x27, x0, 598                 # sll's operand
    addi x3, x0, 605                  # sll's operand
    addi x26, x0, 612                 # sll's rd before (stale)
    lui x6, 526                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 527                       # quiet
    lui x28, 528                      # quiet
    sll x26, x27, x3                  # sll: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x24, mhpmcounter4h, x0      # subject csrrs: reads mhpmcounter4h, d1 (csr_counter_read_d1)
    lui x29, 529                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 530                       # quiet
    lui x7, 531                       # quiet
    addi x24, x0, 626                 # x24 known again: it held the counter, which differs between the engines
# block 157  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4h__alu_rr (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 157  # marker: block 157
    lui x28, 532                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 533                      # quiet
    lui x6, 534                       # quiet
    addi x9, x0, 633                  # x9 = 633
    addi x11, x0, 640                 # sll's operand
    addi x12, x0, 647                 # sll's operand
    addi x10, x0, 654                 # sll's rd before (stale)
    lui x7, 535                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 536                      # quiet
    lui x29, 537                      # quiet
    sll x10, x11, x12                 # sll: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter4h, x9       # subject csrrw: names mhpmcounter4h and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x6, 538                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 539                       # quiet
    lui x28, 540                      # quiet
# block 158  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4h__alu_ri (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 158  # marker: block 158
    lui x29, 541                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 542                       # quiet
    lui x7, 543                       # quiet
    addi x14, x0, 16                  # mcountinhibit for mhpmcounter4h: inhibited
    csrrw x0, mcountinhibit, x14      # mcountinhibit for mhpmcounter4h: inhibited
    addi x16, x0, 661                 # ori's operand
    addi x15, x0, 668                 # ori's rd before (stale)
    lui x28, 544                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 545                      # quiet
    lui x6, 546                       # quiet
    ori x15, x16, 0                   # ori: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x13, mhpmcounter4h, x0      # subject csrrs: reads mhpmcounter4h, d1 (csr_counter_read_d1)
    lui x7, 547                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 548                      # quiet
    lui x29, 549                      # quiet
    addi x13, x0, 682                 # x13 known again: it held the counter, which differs between the engines
# block 159  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4h__alu_ri (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 159  # marker: block 159
    lui x6, 550                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 551                       # quiet
    lui x28, 552                      # quiet
    addi x18, x0, 0                   # mcountinhibit for mhpmcounter4h: enabled
    csrrw x0, mcountinhibit, x18      # mcountinhibit for mhpmcounter4h: enabled
    addi x20, x0, 689                 # ori's operand
    addi x19, x0, 696                 # ori's rd before (stale)
    lui x29, 553                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 554                       # quiet
    lui x7, 555                       # quiet
    ori x19, x20, 0                   # ori: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x17, mhpmcounter4h, x0      # subject csrrs: reads mhpmcounter4h, d1 (csr_counter_read_d1)
    lui x28, 556                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 557                      # quiet
    lui x6, 558                       # quiet
    addi x17, x0, 710                 # x17 known again: it held the counter, which differs between the engines
# block 160  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4h__alu_ri (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 160  # marker: block 160
    lui x7, 559                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 560                      # quiet
    lui x29, 561                      # quiet
    addi x22, x0, 717                 # x22 = 717
    addi x24, x0, 724                 # slli's operand
    addi x23, x0, 731                 # slli's rd before (stale)
    lui x6, 562                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 563                       # quiet
    lui x28, 564                      # quiet
    slli x23, x24, 0                  # slli: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter4h, x22      # subject csrrw: names mhpmcounter4h and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x29, 565                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 566                       # quiet
    lui x7, 567                       # quiet
# block 161  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4h__alu_nosrc (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 161  # marker: block 161
    lui x28, 568                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 569                      # quiet
    lui x6, 570                       # quiet
    addi x26, x0, 16                  # mcountinhibit for mhpmcounter4h: inhibited
    csrrw x0, mcountinhibit, x26      # mcountinhibit for mhpmcounter4h: inhibited
    addi x27, x0, 738                 # c.lui's rd before (stale)
    lui x7, 571                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 572                      # quiet
    lui x29, 573                      # quiet
    .option push
    .option rvc
    c.lui x27, 5                  # c.lui: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x25, mhpmcounter4h, x0      # subject csrrs: reads mhpmcounter4h, d1 (csr_counter_read_d1)
    lui x6, 574                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 575                       # quiet
    lui x28, 576                      # quiet
    addi x25, x0, 752                 # x25 known again: it held the counter, which differs between the engines
# block 162  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4h__alu_nosrc (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 162  # marker: block 162
    lui x29, 577                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 578                       # quiet
    lui x7, 579                       # quiet
    addi x8, x0, 0                    # mcountinhibit for mhpmcounter4h: enabled
    csrrw x0, mcountinhibit, x8       # mcountinhibit for mhpmcounter4h: enabled
    addi x9, x0, 759                  # auipc's rd before (stale)
    lui x28, 580                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 581                      # quiet
    lui x6, 582                       # quiet
    auipc x9, 74565                   # auipc: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x3, mhpmcounter4h, x0       # subject csrrs: reads mhpmcounter4h, d1 (csr_counter_read_d1)
    lui x7, 583                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 584                      # quiet
    lui x29, 585                      # quiet
    addi x3, x0, 773                  # x3 known again: it held the counter, which differs between the engines
# block 163  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4h__alu_nosrc (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 163  # marker: block 163
    lui x6, 586                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 587                       # quiet
    lui x28, 588                      # quiet
    addi x11, x0, 780                 # x11 = 780
    addi x12, x0, 787                 # lui's rd before (stale)
    lui x29, 589                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 590                       # quiet
    lui x7, 591                       # quiet
    lui x12, 74565                    # lui: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter4h, x11      # subject csrrw: names mhpmcounter4h and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 592                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 593                      # quiet
    lui x6, 594                       # quiet
# block 164  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4h__load (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 164  # marker: block 164
    lui x7, 595                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 596                      # quiet
    lui x29, 597                      # quiet
    addi x16, x0, 16                  # mcountinhibit for mhpmcounter4h: inhibited
    csrrw x0, mcountinhibit, x16      # mcountinhibit for mhpmcounter4h: inhibited
    .L43: auipc x18, %pcrel_hi(w42)   # lh's base -> w42
    lui x6, 598                       # lh's base -> w42 (quiet)
    lui x7, 599                       # lh's base -> w42 (quiet)
    lui x28, 600                      # lh's base -> w42 (quiet)
    addi x18, x18, %pcrel_lo(.L43)    # lh's base -> w42
    addi x17, x0, 1088                # lh's rd before (stale)
    lui x29, 601                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 602                       # quiet
    lui x7, 603                       # quiet
    lh x17, 0(x18)                    # lh: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x15, mhpmcounter4h, x0      # subject csrrs: reads mhpmcounter4h, d1 (csr_counter_read_d1)
    lui x28, 604                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 605                      # quiet
    lui x6, 606                       # quiet
    addi x15, x0, 1102                # x15 known again: it held the counter, which differs between the engines
# block 165  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4h__load (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 165  # marker: block 165
    lui x7, 607                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 608                      # quiet
    lui x29, 609                      # quiet
    addi x20, x0, 0                   # mcountinhibit for mhpmcounter4h: enabled
    csrrw x0, mcountinhibit, x20      # mcountinhibit for mhpmcounter4h: enabled
    .L44: auipc x22, %pcrel_hi(w43)   # lhu's base -> w43
    lui x6, 610                       # lhu's base -> w43 (quiet)
    lui x7, 611                       # lhu's base -> w43 (quiet)
    lui x28, 612                      # lhu's base -> w43 (quiet)
    addi x22, x22, %pcrel_lo(.L44)    # lhu's base -> w43
    addi x21, x0, 1116                # lhu's rd before (stale)
    lui x29, 613                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 614                       # quiet
    lui x7, 615                       # quiet
    lhu x21, 0(x22)                   # lhu: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x19, mhpmcounter4h, x0      # subject csrrs: reads mhpmcounter4h, d1 (csr_counter_read_d1)
    lui x28, 616                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 617                      # quiet
    lui x6, 618                       # quiet
    addi x19, x0, 1130                # x19 known again: it held the counter, which differs between the engines
# block 166  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4h__load (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 166  # marker: block 166
    lui x7, 619                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 620                      # quiet
    lui x29, 621                      # quiet
    addi x24, x0, 1137                # x24 = 1137
    .L45: auipc x26, %pcrel_hi(w44)   # lw's base -> w44
    lui x6, 622                       # lw's base -> w44 (quiet)
    lui x7, 623                       # lw's base -> w44 (quiet)
    lui x28, 624                      # lw's base -> w44 (quiet)
    addi x26, x26, %pcrel_lo(.L45)    # lw's base -> w44
    addi x25, x0, 1151                # lw's rd before (stale)
    lui x29, 625                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 626                       # quiet
    lui x7, 627                       # quiet
    lw x25, 0(x26)                    # lw: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter4h, x24      # subject csrrw: names mhpmcounter4h and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 628                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 629                      # quiet
    lui x6, 630                       # quiet
# block 167  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4h__store (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 167  # marker: block 167
    lui x7, 631                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 632                      # quiet
    lui x29, 633                      # quiet
    addi x3, x0, 16                   # mcountinhibit for mhpmcounter4h: inhibited
    csrrw x0, mcountinhibit, x3       # mcountinhibit for mhpmcounter4h: inhibited
    .L46: auipc x15, %pcrel_hi(w45)   # c.sb's base -> w45
    lui x6, 634                       # c.sb's base -> w45 (quiet)
    lui x7, 635                       # c.sb's base -> w45 (quiet)
    lui x28, 636                      # c.sb's base -> w45 (quiet)
    addi x15, x15, %pcrel_lo(.L46)    # c.sb's base -> w45
    addi x8, x0, 1165                 # c.sb's store data
    lui x29, 637                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 638                       # quiet
    lui x7, 639                       # quiet
    .option push
    .option rvc
    c.sb x8, 0(x15)               # c.sb: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x27, mhpmcounter4h, x0      # subject csrrs: reads mhpmcounter4h, d1 (csr_counter_read_d1)
    lui x28, 640                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 641                      # quiet
    lui x6, 642                       # quiet
    addi x27, x0, 1179                # x27 known again: it held the counter, which differs between the engines
# block 168  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4h__store (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 168  # marker: block 168
    lui x7, 643                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 644                      # quiet
    lui x29, 645                      # quiet
    addi x11, x0, 0                   # mcountinhibit for mhpmcounter4h: enabled
    csrrw x0, mcountinhibit, x11      # mcountinhibit for mhpmcounter4h: enabled
    .L47: auipc x12, %pcrel_hi(w46)   # c.sh's base -> w46
    lui x6, 646                       # c.sh's base -> w46 (quiet)
    lui x7, 647                       # c.sh's base -> w46 (quiet)
    lui x28, 648                      # c.sh's base -> w46 (quiet)
    addi x12, x12, %pcrel_lo(.L47)    # c.sh's base -> w46
    addi x13, x0, 1193                # c.sh's store data
    lui x29, 649                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 650                       # quiet
    lui x7, 651                       # quiet
    .option push
    .option rvc
    c.sh x13, 0(x12)              # c.sh: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x10, mhpmcounter4h, x0      # subject csrrs: reads mhpmcounter4h, d1 (csr_counter_read_d1)
    lui x28, 652                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 653                      # quiet
    lui x6, 654                       # quiet
    addi x10, x0, 1207                # x10 known again: it held the counter, which differs between the engines
# block 169  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4h__store (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 169  # marker: block 169
    lui x7, 655                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 656                      # quiet
    lui x29, 657                      # quiet
    addi x16, x0, 1214                # x16 = 1214
    .L48: auipc x8, %pcrel_hi(w47)    # c.sw's base -> w47
    lui x6, 658                       # c.sw's base -> w47 (quiet)
    lui x7, 659                       # c.sw's base -> w47 (quiet)
    lui x28, 660                      # c.sw's base -> w47 (quiet)
    addi x8, x8, %pcrel_lo(.L48)      # c.sw's base -> w47
    addi x9, x0, 1                    # c.sw's store data
    lui x29, 661                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 662                       # quiet
    lui x7, 663                       # quiet
    .option push
    .option rvc
    c.sw x9, 0(x8)                # c.sw: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrw x0, mhpmcounter4h, x16      # subject csrrw: names mhpmcounter4h and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 664                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 665                      # quiet
    lui x6, 666                       # quiet
# block 170  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4h__csr_r (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 170  # marker: block 170
    lui x7, 667                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 668                      # quiet
    lui x29, 669                      # quiet
    addi x20, x0, 16                  # mcountinhibit for mhpmcounter4h: inhibited
    csrrw x0, mcountinhibit, x20      # mcountinhibit for mhpmcounter4h: inhibited
    addi x22, x0, 1228                # csrrs's operand
    addi x21, x0, 1235                # csrrs's rd before (stale)
    lui x6, 670                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 671                       # quiet
    lui x28, 672                      # quiet
    csrrs x21, mscratch, x22          # csrrs: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x19, mhpmcounter4h, x0      # subject csrrs: reads mhpmcounter4h, d1 (csr_counter_read_d1)
    lui x29, 673                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 674                       # quiet
    lui x7, 675                       # quiet
    addi x19, x0, 1249                # x19 known again: it held the counter, which differs between the engines
# block 171  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4h__csr_r (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 171  # marker: block 171
    lui x28, 676                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 677                      # quiet
    lui x6, 678                       # quiet
    addi x24, x0, 0                   # mcountinhibit for mhpmcounter4h: enabled
    csrrw x0, mcountinhibit, x24      # mcountinhibit for mhpmcounter4h: enabled
    addi x26, x0, 1256                # csrrw's operand
    addi x25, x0, 1263                # csrrw's rd before (stale)
    lui x7, 679                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 680                      # quiet
    lui x29, 681                      # quiet
    csrrw x25, mscratch, x26          # csrrw: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x23, mhpmcounter4h, x0      # subject csrrs: reads mhpmcounter4h, d1 (csr_counter_read_d1)
    lui x6, 682                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 683                       # quiet
    lui x28, 684                      # quiet
    addi x23, x0, 1277                # x23 known again: it held the counter, which differs between the engines
# block 172  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4h__csr_r (after_write)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 172  # marker: block 172
    lui x29, 685                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 686                       # quiet
    lui x7, 687                       # quiet
    addi x3, x0, 1284                 # x3 = 1284
    lui x28, 688                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 689                      # quiet
    lui x6, 690                       # quiet
    csrrw x0, mhpmcounter4h, x3       # csrrw: writes mhpmcounter4h, the counter the subject reads
    csrrs x27, mhpmcounter4h, x0      # subject csrrs: reads mhpmcounter4h, d1 (csr_counter_read_d1)
    lui x7, 691                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 692                      # quiet
    lui x29, 693                      # quiet
    addi x27, x0, 1298                # x27 known again: it held the counter, which differs between the engines
# block 173  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4h__csr_r (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 173  # marker: block 173
    lui x6, 694                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 695                       # quiet
    lui x28, 696                      # quiet
    addi x9, x0, 1305                 # x9 = 1305
    addi x11, x0, 1312                # csrrs's operand
    addi x10, x0, 1319                # csrrs's rd before (stale)
    lui x29, 697                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 698                       # quiet
    lui x7, 699                       # quiet
    csrrs x10, mscratch, x11          # csrrs: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter4h, x9       # subject csrrw: names mhpmcounter4h and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 700                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 701                      # quiet
    lui x6, 702                       # quiet
# block 174  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4h__csr_i (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 174  # marker: block 174
    lui x7, 703                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 704                      # quiet
    lui x29, 705                      # quiet
    addi x13, x0, 16                  # mcountinhibit for mhpmcounter4h: inhibited
    csrrw x0, mcountinhibit, x13      # mcountinhibit for mhpmcounter4h: inhibited
    addi x14, x0, 1326                # csrrci's rd before (stale)
    lui x6, 706                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 707                       # quiet
    lui x28, 708                      # quiet
    csrrci x14, mscratch, 7           # csrrci: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x12, mhpmcounter4h, x0      # subject csrrs: reads mhpmcounter4h, d1 (csr_counter_read_d1)
    lui x29, 709                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 710                       # quiet
    lui x7, 711                       # quiet
    addi x12, x0, 1340                # x12 known again: it held the counter, which differs between the engines
# block 175  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4h__csr_i (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 175  # marker: block 175
    lui x28, 712                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 713                      # quiet
    lui x6, 714                       # quiet
    addi x16, x0, 0                   # mcountinhibit for mhpmcounter4h: enabled
    csrrw x0, mcountinhibit, x16      # mcountinhibit for mhpmcounter4h: enabled
    addi x17, x0, 1347                # csrrsi's rd before (stale)
    lui x7, 715                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 716                      # quiet
    lui x29, 717                      # quiet
    csrrsi x17, mscratch, 7           # csrrsi: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x15, mhpmcounter4h, x0      # subject csrrs: reads mhpmcounter4h, d1 (csr_counter_read_d1)
    lui x6, 718                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 719                       # quiet
    lui x28, 720                      # quiet
    addi x15, x0, 1361                # x15 known again: it held the counter, which differs between the engines
# block 176  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter4h__csr_i (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 176  # marker: block 176
    lui x29, 721                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 722                       # quiet
    lui x7, 723                       # quiet
    addi x19, x0, 1368                # x19 = 1368
    addi x20, x0, 1375                # csrrwi's rd before (stale)
    lui x28, 724                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 725                      # quiet
    lui x6, 726                       # quiet
    csrrwi x20, mscratch, 7           # csrrwi: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter4h, x19      # subject csrrw: names mhpmcounter4h and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x7, 727                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 728                      # quiet
    lui x29, 729                      # quiet
# block 177  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31__alu_rr (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 177  # marker: block 177
    lui x6, 730                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 731                       # quiet
    lui x28, 732                      # quiet
    lui x22, 0x80000                  # mcountinhibit for mhpmcounter31: inhibited
    lui x29, 733                      # mcountinhibit for mhpmcounter31: inhibited (quiet)
    lui x6, 734                       # mcountinhibit for mhpmcounter31: inhibited (quiet)
    lui x7, 735                       # mcountinhibit for mhpmcounter31: inhibited (quiet)
    addi x22, x22, 0                  # mcountinhibit for mhpmcounter31: inhibited
    csrrw x0, mcountinhibit, x22      # mcountinhibit for mhpmcounter31: inhibited
    addi x24, x0, 1382                # sll's operand
    addi x25, x0, 1389                # sll's operand
    addi x23, x0, 1396                # sll's rd before (stale)
    lui x28, 736                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 737                      # quiet
    lui x6, 738                       # quiet
    sll x23, x24, x25                 # sll: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x21, mhpmcounter31, x0      # subject csrrs: reads mhpmcounter31, d1 (csr_counter_read_d1)
    lui x7, 739                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 740                      # quiet
    lui x29, 741                      # quiet
    addi x21, x0, 1410                # x21 known again: it held the counter, which differs between the engines
# block 178  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31__alu_rr (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 178  # marker: block 178
    lui x6, 742                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 743                       # quiet
    lui x28, 744                      # quiet
    addi x27, x0, 0                   # mcountinhibit for mhpmcounter31: enabled
    csrrw x0, mcountinhibit, x27      # mcountinhibit for mhpmcounter31: enabled
    addi x8, x0, 1417                 # sll's operand
    addi x9, x0, 1424                 # sll's operand
    addi x3, x0, 1431                 # sll's rd before (stale)
    lui x29, 745                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 746                       # quiet
    lui x7, 747                       # quiet
    sll x3, x8, x9                    # sll: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x26, mhpmcounter31, x0      # subject csrrs: reads mhpmcounter31, d1 (csr_counter_read_d1)
    lui x28, 748                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 749                      # quiet
    lui x6, 750                       # quiet
    addi x26, x0, 1445                # x26 known again: it held the counter, which differs between the engines
# block 179  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31__alu_rr (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 179  # marker: block 179
    lui x7, 751                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 752                      # quiet
    lui x29, 753                      # quiet
    addi x11, x0, 1452                # x11 = 1452
    addi x13, x0, 1459                # sll's operand
    addi x14, x0, 1466                # sll's operand
    addi x12, x0, 1473                # sll's rd before (stale)
    lui x6, 754                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 755                       # quiet
    lui x28, 756                      # quiet
    sll x12, x13, x14                 # sll: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter31, x11      # subject csrrw: names mhpmcounter31 and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x29, 757                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 758                       # quiet
    lui x7, 759                       # quiet
# block 180  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31__alu_ri (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 180  # marker: block 180
    lui x28, 760                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 761                      # quiet
    lui x6, 762                       # quiet
    lui x16, 0x80000                  # mcountinhibit for mhpmcounter31: inhibited
    lui x7, 763                       # mcountinhibit for mhpmcounter31: inhibited (quiet)
    lui x28, 764                      # mcountinhibit for mhpmcounter31: inhibited (quiet)
    lui x29, 765                      # mcountinhibit for mhpmcounter31: inhibited (quiet)
    addi x16, x16, 0                  # mcountinhibit for mhpmcounter31: inhibited
    csrrw x0, mcountinhibit, x16      # mcountinhibit for mhpmcounter31: inhibited
    addi x18, x0, 1480                # slli's operand
    addi x17, x0, 1487                # slli's rd before (stale)
    lui x6, 766                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 767                       # quiet
    lui x28, 768                      # quiet
    slli x17, x18, 0                  # slli: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x15, mhpmcounter31, x0      # subject csrrs: reads mhpmcounter31, d1 (csr_counter_read_d1)
    lui x29, 769                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 770                       # quiet
    lui x7, 771                       # quiet
    addi x15, x0, 1501                # x15 known again: it held the counter, which differs between the engines
# block 181  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31__alu_ri (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 181  # marker: block 181
    lui x28, 772                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 773                      # quiet
    lui x6, 774                       # quiet
    addi x20, x0, 0                   # mcountinhibit for mhpmcounter31: enabled
    csrrw x0, mcountinhibit, x20      # mcountinhibit for mhpmcounter31: enabled
    addi x22, x0, 1508                # slli's operand
    addi x21, x0, 1515                # slli's rd before (stale)
    lui x7, 775                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 776                      # quiet
    lui x29, 777                      # quiet
    slli x21, x22, 0                  # slli: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x19, mhpmcounter31, x0      # subject csrrs: reads mhpmcounter31, d1 (csr_counter_read_d1)
    lui x6, 778                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 779                       # quiet
    lui x28, 780                      # quiet
    addi x19, x0, 1529                # x19 known again: it held the counter, which differs between the engines
# block 182  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31__alu_ri (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 182  # marker: block 182
    lui x29, 781                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 782                       # quiet
    lui x7, 783                       # quiet
    addi x24, x0, 1536                # x24 = 1536
    addi x26, x0, 1543                # slli's operand
    addi x25, x0, 1550                # slli's rd before (stale)
    lui x28, 784                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 785                      # quiet
    lui x6, 786                       # quiet
    slli x25, x26, 0                  # slli: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter31, x24      # subject csrrw: names mhpmcounter31 and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x7, 787                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 788                      # quiet
    lui x29, 789                      # quiet
# block 183  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31__alu_nosrc (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 183  # marker: block 183
    lui x6, 790                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 791                       # quiet
    lui x28, 792                      # quiet
    lui x3, 0x80000                   # mcountinhibit for mhpmcounter31: inhibited
    lui x29, 793                      # mcountinhibit for mhpmcounter31: inhibited (quiet)
    lui x6, 794                       # mcountinhibit for mhpmcounter31: inhibited (quiet)
    lui x7, 795                       # mcountinhibit for mhpmcounter31: inhibited (quiet)
    addi x3, x3, 0                    # mcountinhibit for mhpmcounter31: inhibited
    csrrw x0, mcountinhibit, x3       # mcountinhibit for mhpmcounter31: inhibited
    addi x8, x0, 1557                 # c.li's rd before (stale)
    lui x28, 796                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 797                      # quiet
    lui x6, 798                       # quiet
    .option push
    .option rvc
    c.li x8, 5                    # c.li: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x27, mhpmcounter31, x0      # subject csrrs: reads mhpmcounter31, d1 (csr_counter_read_d1)
    lui x7, 799                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 800                      # quiet
    lui x29, 801                      # quiet
    addi x27, x0, 1571                # x27 known again: it held the counter, which differs between the engines
# block 184  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31__alu_nosrc (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 184  # marker: block 184
    lui x6, 802                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 803                       # quiet
    lui x28, 804                      # quiet
    addi x10, x0, 0                   # mcountinhibit for mhpmcounter31: enabled
    csrrw x0, mcountinhibit, x10      # mcountinhibit for mhpmcounter31: enabled
    addi x11, x0, 1578                # c.lui's rd before (stale)
    lui x29, 805                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 806                       # quiet
    lui x7, 807                       # quiet
    .option push
    .option rvc
    c.lui x11, 5                  # c.lui: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x9, mhpmcounter31, x0       # subject csrrs: reads mhpmcounter31, d1 (csr_counter_read_d1)
    lui x28, 808                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 809                      # quiet
    lui x6, 810                       # quiet
    addi x9, x0, 1592                 # x9 known again: it held the counter, which differs between the engines
# block 185  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31__alu_nosrc (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 185  # marker: block 185
    lui x7, 811                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 812                      # quiet
    lui x29, 813                      # quiet
    addi x13, x0, 1599                # x13 = 1599
    addi x14, x0, 1606                # auipc's rd before (stale)
    lui x6, 814                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 815                       # quiet
    lui x28, 816                      # quiet
    auipc x14, 74565                  # auipc: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter31, x13      # subject csrrw: names mhpmcounter31 and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x29, 817                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 818                       # quiet
    lui x7, 819                       # quiet
# block 186  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31__load (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 186  # marker: block 186
    lui x28, 820                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 821                      # quiet
    lui x6, 822                       # quiet
    lui x18, 0x80000                  # mcountinhibit for mhpmcounter31: inhibited
    lui x7, 823                       # mcountinhibit for mhpmcounter31: inhibited (quiet)
    lui x28, 824                      # mcountinhibit for mhpmcounter31: inhibited (quiet)
    lui x29, 825                      # mcountinhibit for mhpmcounter31: inhibited (quiet)
    addi x18, x18, 0                  # mcountinhibit for mhpmcounter31: inhibited
    csrrw x0, mcountinhibit, x18      # mcountinhibit for mhpmcounter31: inhibited
    .L49: auipc x20, %pcrel_hi(w48)   # lw's base -> w48
    lui x6, 826                       # lw's base -> w48 (quiet)
    lui x7, 827                       # lw's base -> w48 (quiet)
    lui x28, 828                      # lw's base -> w48 (quiet)
    addi x20, x20, %pcrel_lo(.L49)    # lw's base -> w48
    addi x19, x0, 1900                # lw's rd before (stale)
    lui x29, 829                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 830                       # quiet
    lui x7, 831                       # quiet
    lw x19, 0(x20)                    # lw: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x17, mhpmcounter31, x0      # subject csrrs: reads mhpmcounter31, d1 (csr_counter_read_d1)
    lui x28, 832                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 833                      # quiet
    lui x6, 834                       # quiet
    addi x17, x0, 1914                # x17 known again: it held the counter, which differs between the engines
# block 187  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31__load (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 187  # marker: block 187
    lui x7, 835                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 836                      # quiet
    lui x29, 837                      # quiet
    addi x22, x0, 0                   # mcountinhibit for mhpmcounter31: enabled
    csrrw x0, mcountinhibit, x22      # mcountinhibit for mhpmcounter31: enabled
    .L50: auipc x24, %pcrel_hi(w49)   # lw's base -> w49
    lui x6, 838                       # lw's base -> w49 (quiet)
    lui x7, 839                       # lw's base -> w49 (quiet)
    lui x28, 840                      # lw's base -> w49 (quiet)
    addi x24, x24, %pcrel_lo(.L50)    # lw's base -> w49
    addi x23, x0, 1928                # lw's rd before (stale)
    lui x29, 841                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 842                       # quiet
    lui x7, 843                       # quiet
    lw x23, 0(x24)                    # lw: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x21, mhpmcounter31, x0      # subject csrrs: reads mhpmcounter31, d1 (csr_counter_read_d1)
    lui x28, 844                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 845                      # quiet
    lui x6, 846                       # quiet
    addi x21, x0, 1942                # x21 known again: it held the counter, which differs between the engines
# block 188  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31__load (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 188  # marker: block 188
    lui x7, 847                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 848                      # quiet
    lui x29, 849                      # quiet
    addi x26, x0, 1949                # x26 = 1949
    .L51: auipc x3, %pcrel_hi(w50)    # lw's base -> w50
    lui x6, 850                       # lw's base -> w50 (quiet)
    lui x7, 851                       # lw's base -> w50 (quiet)
    lui x28, 852                      # lw's base -> w50 (quiet)
    addi x3, x3, %pcrel_lo(.L51)      # lw's base -> w50
    addi x27, x0, 1963                # lw's rd before (stale)
    lui x29, 853                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 854                       # quiet
    lui x7, 855                       # quiet
    lw x27, 0(x3)                     # lw: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter31, x26      # subject csrrw: names mhpmcounter31 and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 856                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 857                      # quiet
    lui x6, 858                       # quiet
# block 189  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31__store (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 189  # marker: block 189
    lui x7, 859                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 860                      # quiet
    lui x29, 861                      # quiet
    lui x9, 0x80000                   # mcountinhibit for mhpmcounter31: inhibited
    lui x6, 862                       # mcountinhibit for mhpmcounter31: inhibited (quiet)
    lui x7, 863                       # mcountinhibit for mhpmcounter31: inhibited (quiet)
    lui x28, 864                      # mcountinhibit for mhpmcounter31: inhibited (quiet)
    addi x9, x9, 0                    # mcountinhibit for mhpmcounter31: inhibited
    csrrw x0, mcountinhibit, x9       # mcountinhibit for mhpmcounter31: inhibited
    .L52: auipc x2, %pcrel_hi(w51)    # c.swsp's base -> w51
    lui x29, 865                      # c.swsp's base -> w51 (quiet)
    lui x6, 866                       # c.swsp's base -> w51 (quiet)
    lui x7, 867                       # c.swsp's base -> w51 (quiet)
    addi x2, x2, %pcrel_lo(.L52)      # c.swsp's base -> w51
    addi x10, x0, 1977                # c.swsp's store data
    lui x28, 868                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 869                      # quiet
    lui x6, 870                       # quiet
    .option push
    .option rvc
    c.swsp x10, 0(sp)             # c.swsp: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x8, mhpmcounter31, x0       # subject csrrs: reads mhpmcounter31, d1 (csr_counter_read_d1)
    lui x7, 871                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 872                      # quiet
    lui x29, 873                      # quiet
    addi x8, x0, 1991                 # x8 known again: it held the counter, which differs between the engines
# block 190  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31__store (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 190  # marker: block 190
    lui x6, 874                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 875                       # quiet
    lui x28, 876                      # quiet
    addi x12, x0, 0                   # mcountinhibit for mhpmcounter31: enabled
    csrrw x0, mcountinhibit, x12      # mcountinhibit for mhpmcounter31: enabled
    .L53: auipc x13, %pcrel_hi(w52)   # sb's base -> w52
    lui x29, 877                      # sb's base -> w52 (quiet)
    lui x6, 878                       # sb's base -> w52 (quiet)
    lui x7, 879                       # sb's base -> w52 (quiet)
    addi x13, x13, %pcrel_lo(.L53)    # sb's base -> w52
    addi x14, x0, 2005                # sb's store data
    lui x28, 880                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 881                      # quiet
    lui x6, 882                       # quiet
    sb x14, 0(x13)                    # sb: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x11, mhpmcounter31, x0      # subject csrrs: reads mhpmcounter31, d1 (csr_counter_read_d1)
    lui x7, 883                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 884                      # quiet
    lui x29, 885                      # quiet
    addi x11, x0, 2019                # x11 known again: it held the counter, which differs between the engines
# block 191  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31__store (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 191  # marker: block 191
    lui x6, 886                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 887                       # quiet
    lui x28, 888                      # quiet
    addi x16, x0, 2026                # x16 = 2026
    .L54: auipc x17, %pcrel_hi(w53)   # sh's base -> w53
    lui x29, 889                      # sh's base -> w53 (quiet)
    lui x6, 890                       # sh's base -> w53 (quiet)
    lui x7, 891                       # sh's base -> w53 (quiet)
    addi x17, x17, %pcrel_lo(.L54)    # sh's base -> w53
    addi x18, x0, 264                 # sh's store data
    lui x28, 892                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 893                      # quiet
    lui x6, 894                       # quiet
    sh x18, 0(x17)                    # sh: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter31, x16      # subject csrrw: names mhpmcounter31 and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x7, 895                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 896                      # quiet
    lui x29, 897                      # quiet
# block 192  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31__csr_r (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 192  # marker: block 192
    lui x6, 898                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 899                       # quiet
    lui x28, 900                      # quiet
    lui x20, 0x80000                  # mcountinhibit for mhpmcounter31: inhibited
    lui x29, 901                      # mcountinhibit for mhpmcounter31: inhibited (quiet)
    lui x6, 902                       # mcountinhibit for mhpmcounter31: inhibited (quiet)
    lui x7, 903                       # mcountinhibit for mhpmcounter31: inhibited (quiet)
    addi x20, x20, 0                  # mcountinhibit for mhpmcounter31: inhibited
    csrrw x0, mcountinhibit, x20      # mcountinhibit for mhpmcounter31: inhibited
    addi x22, x0, 271                 # csrrw's operand
    addi x21, x0, 278                 # csrrw's rd before (stale)
    lui x28, 904                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 905                      # quiet
    lui x6, 906                       # quiet
    csrrw x21, mscratch, x22          # csrrw: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x19, mhpmcounter31, x0      # subject csrrs: reads mhpmcounter31, d1 (csr_counter_read_d1)
    lui x7, 907                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 908                      # quiet
    lui x29, 909                      # quiet
    addi x19, x0, 292                 # x19 known again: it held the counter, which differs between the engines
# block 193  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31__csr_r (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 193  # marker: block 193
    lui x6, 910                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 911                       # quiet
    lui x28, 912                      # quiet
    addi x24, x0, 0                   # mcountinhibit for mhpmcounter31: enabled
    csrrw x0, mcountinhibit, x24      # mcountinhibit for mhpmcounter31: enabled
    addi x26, x0, 299                 # csrrc's operand
    addi x25, x0, 306                 # csrrc's rd before (stale)
    lui x29, 913                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 914                       # quiet
    lui x7, 915                       # quiet
    csrrc x25, mscratch, x26          # csrrc: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x23, mhpmcounter31, x0      # subject csrrs: reads mhpmcounter31, d1 (csr_counter_read_d1)
    lui x28, 916                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 917                      # quiet
    lui x6, 918                       # quiet
    addi x23, x0, 320                 # x23 known again: it held the counter, which differs between the engines
# block 194  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31__csr_r (after_write)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 194  # marker: block 194
    lui x7, 919                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 920                      # quiet
    lui x29, 921                      # quiet
    addi x3, x0, 327                  # x3 = 327
    lui x6, 922                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 923                       # quiet
    lui x28, 924                      # quiet
    csrrw x0, mhpmcounter31, x3       # csrrw: writes mhpmcounter31, the counter the subject reads
    csrrs x27, mhpmcounter31, x0      # subject csrrs: reads mhpmcounter31, d1 (csr_counter_read_d1)
    lui x29, 925                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 926                       # quiet
    lui x7, 927                       # quiet
    addi x27, x0, 341                 # x27 known again: it held the counter, which differs between the engines
# block 195  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31__csr_r (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 195  # marker: block 195
    lui x28, 928                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 929                      # quiet
    lui x6, 930                       # quiet
    addi x9, x0, 348                  # x9 = 348
    addi x11, x0, 355                 # csrrw's operand
    addi x10, x0, 362                 # csrrw's rd before (stale)
    lui x7, 931                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 932                      # quiet
    lui x29, 933                      # quiet
    csrrw x10, mscratch, x11          # csrrw: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter31, x9       # subject csrrw: names mhpmcounter31 and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x6, 934                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 935                       # quiet
    lui x28, 936                      # quiet
# block 196  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31__csr_i (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 196  # marker: block 196
    lui x29, 937                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 938                       # quiet
    lui x7, 939                       # quiet
    lui x13, 0x80000                  # mcountinhibit for mhpmcounter31: inhibited
    lui x28, 940                      # mcountinhibit for mhpmcounter31: inhibited (quiet)
    lui x29, 941                      # mcountinhibit for mhpmcounter31: inhibited (quiet)
    lui x6, 942                       # mcountinhibit for mhpmcounter31: inhibited (quiet)
    addi x13, x13, 0                  # mcountinhibit for mhpmcounter31: inhibited
    csrrw x0, mcountinhibit, x13      # mcountinhibit for mhpmcounter31: inhibited
    addi x14, x0, 369                 # csrrci's rd before (stale)
    lui x7, 943                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 944                      # quiet
    lui x29, 945                      # quiet
    csrrci x14, mscratch, 7           # csrrci: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x12, mhpmcounter31, x0      # subject csrrs: reads mhpmcounter31, d1 (csr_counter_read_d1)
    lui x6, 946                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 947                       # quiet
    lui x28, 948                      # quiet
    addi x12, x0, 383                 # x12 known again: it held the counter, which differs between the engines
# block 197  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31__csr_i (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 197  # marker: block 197
    lui x29, 949                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 950                       # quiet
    lui x7, 951                       # quiet
    addi x16, x0, 0                   # mcountinhibit for mhpmcounter31: enabled
    csrrw x0, mcountinhibit, x16      # mcountinhibit for mhpmcounter31: enabled
    addi x17, x0, 390                 # csrrsi's rd before (stale)
    lui x28, 952                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 953                      # quiet
    lui x6, 954                       # quiet
    csrrsi x17, mscratch, 7           # csrrsi: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x15, mhpmcounter31, x0      # subject csrrs: reads mhpmcounter31, d1 (csr_counter_read_d1)
    lui x7, 955                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 956                      # quiet
    lui x29, 957                      # quiet
    addi x15, x0, 404                 # x15 known again: it held the counter, which differs between the engines
# block 198  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31__csr_i (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 198  # marker: block 198
    lui x6, 958                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 959                       # quiet
    lui x28, 960                      # quiet
    addi x19, x0, 411                 # x19 = 411
    addi x20, x0, 418                 # csrrwi's rd before (stale)
    lui x29, 961                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 962                       # quiet
    lui x7, 963                       # quiet
    csrrwi x20, mscratch, 7           # csrrwi: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter31, x19      # subject csrrw: names mhpmcounter31 and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 964                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 965                      # quiet
    lui x6, 966                       # quiet
# block 199  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31h__alu_rr (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 199  # marker: block 199
    lui x7, 967                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 968                      # quiet
    lui x29, 969                      # quiet
    lui x22, 0x80000                  # mcountinhibit for mhpmcounter31h: inhibited
    lui x6, 970                       # mcountinhibit for mhpmcounter31h: inhibited (quiet)
    lui x7, 971                       # mcountinhibit for mhpmcounter31h: inhibited (quiet)
    lui x28, 972                      # mcountinhibit for mhpmcounter31h: inhibited (quiet)
    addi x22, x22, 0                  # mcountinhibit for mhpmcounter31h: inhibited
    csrrw x0, mcountinhibit, x22      # mcountinhibit for mhpmcounter31h: inhibited
    addi x24, x0, 425                 # sll's operand
    addi x25, x0, 432                 # sll's operand
    addi x23, x0, 439                 # sll's rd before (stale)
    lui x29, 973                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 974                       # quiet
    lui x7, 975                       # quiet
    sll x23, x24, x25                 # sll: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x21, mhpmcounter31h, x0     # subject csrrs: reads mhpmcounter31h, d1 (csr_counter_read_d1)
    lui x28, 976                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 977                      # quiet
    lui x6, 978                       # quiet
    addi x21, x0, 453                 # x21 known again: it held the counter, which differs between the engines
# block 200  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31h__alu_rr (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 200  # marker: block 200
    lui x7, 979                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 980                      # quiet
    lui x29, 981                      # quiet
    addi x27, x0, 0                   # mcountinhibit for mhpmcounter31h: enabled
    csrrw x0, mcountinhibit, x27      # mcountinhibit for mhpmcounter31h: enabled
    addi x8, x0, 460                  # slt's operand
    addi x9, x0, 467                  # slt's operand
    addi x3, x0, 474                  # slt's rd before (stale)
    lui x6, 982                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 983                       # quiet
    lui x28, 984                      # quiet
    slt x3, x8, x9                    # slt: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x26, mhpmcounter31h, x0     # subject csrrs: reads mhpmcounter31h, d1 (csr_counter_read_d1)
    lui x29, 985                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 986                       # quiet
    lui x7, 987                       # quiet
    addi x26, x0, 488                 # x26 known again: it held the counter, which differs between the engines
# block 201  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31h__alu_rr (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 201  # marker: block 201
    lui x28, 988                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 989                      # quiet
    lui x6, 990                       # quiet
    addi x11, x0, 495                 # x11 = 495
    addi x13, x0, 502                 # sltu's operand
    addi x14, x0, 509                 # sltu's operand
    addi x12, x0, 516                 # sltu's rd before (stale)
    lui x7, 991                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 992                      # quiet
    lui x29, 993                      # quiet
    sltu x12, x13, x14                # sltu: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter31h, x11     # subject csrrw: names mhpmcounter31h and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x6, 994                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 995                       # quiet
    lui x28, 996                      # quiet
# block 202  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31h__alu_ri (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 202  # marker: block 202
    lui x29, 997                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 998                       # quiet
    lui x7, 999                       # quiet
    lui x16, 0x80000                  # mcountinhibit for mhpmcounter31h: inhibited
    lui x28, 1000                     # mcountinhibit for mhpmcounter31h: inhibited (quiet)
    lui x29, 1                        # mcountinhibit for mhpmcounter31h: inhibited (quiet)
    lui x6, 2                         # mcountinhibit for mhpmcounter31h: inhibited (quiet)
    addi x16, x16, 0                  # mcountinhibit for mhpmcounter31h: inhibited
    csrrw x0, mcountinhibit, x16      # mcountinhibit for mhpmcounter31h: inhibited
    addi x18, x0, 523                 # slli's operand
    addi x17, x0, 530                 # slli's rd before (stale)
    lui x7, 3                         # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 4                        # quiet
    lui x29, 5                        # quiet
    slli x17, x18, 0                  # slli: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x15, mhpmcounter31h, x0     # subject csrrs: reads mhpmcounter31h, d1 (csr_counter_read_d1)
    lui x6, 6                         # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 7                         # quiet
    lui x28, 8                        # quiet
    addi x15, x0, 544                 # x15 known again: it held the counter, which differs between the engines
# block 203  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31h__alu_ri (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 203  # marker: block 203
    lui x29, 9                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 10                        # quiet
    lui x7, 11                        # quiet
    addi x20, x0, 0                   # mcountinhibit for mhpmcounter31h: enabled
    csrrw x0, mcountinhibit, x20      # mcountinhibit for mhpmcounter31h: enabled
    addi x22, x0, 551                 # slti's operand
    addi x21, x0, 558                 # slti's rd before (stale)
    lui x28, 12                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 13                       # quiet
    lui x6, 14                        # quiet
    slti x21, x22, 5                  # slti: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x19, mhpmcounter31h, x0     # subject csrrs: reads mhpmcounter31h, d1 (csr_counter_read_d1)
    lui x7, 15                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 16                       # quiet
    lui x29, 17                       # quiet
    addi x19, x0, 572                 # x19 known again: it held the counter, which differs between the engines
# block 204  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31h__alu_ri (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 204  # marker: block 204
    lui x6, 18                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 19                        # quiet
    lui x28, 20                       # quiet
    addi x24, x0, 579                 # x24 = 579
    addi x26, x0, 586                 # sltiu's operand
    addi x25, x0, 593                 # sltiu's rd before (stale)
    lui x29, 21                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 22                        # quiet
    lui x7, 23                        # quiet
    sltiu x25, x26, 5                 # sltiu: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter31h, x24     # subject csrrw: names mhpmcounter31h and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 24                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 25                       # quiet
    lui x6, 26                        # quiet
# block 205  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31h__alu_nosrc (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 205  # marker: block 205
    lui x7, 27                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 28                       # quiet
    lui x29, 29                       # quiet
    lui x3, 0x80000                   # mcountinhibit for mhpmcounter31h: inhibited
    lui x6, 30                        # mcountinhibit for mhpmcounter31h: inhibited (quiet)
    lui x7, 31                        # mcountinhibit for mhpmcounter31h: inhibited (quiet)
    lui x28, 32                       # mcountinhibit for mhpmcounter31h: inhibited (quiet)
    addi x3, x3, 0                    # mcountinhibit for mhpmcounter31h: inhibited
    csrrw x0, mcountinhibit, x3       # mcountinhibit for mhpmcounter31h: inhibited
    addi x8, x0, 600                  # lui's rd before (stale)
    lui x29, 33                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 34                        # quiet
    lui x7, 35                        # quiet
    lui x8, 74565                     # lui: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x27, mhpmcounter31h, x0     # subject csrrs: reads mhpmcounter31h, d1 (csr_counter_read_d1)
    lui x28, 36                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 37                       # quiet
    lui x6, 38                        # quiet
    addi x27, x0, 614                 # x27 known again: it held the counter, which differs between the engines
# block 206  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31h__alu_nosrc (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 206  # marker: block 206
    lui x7, 39                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 40                       # quiet
    lui x29, 41                       # quiet
    addi x10, x0, 0                   # mcountinhibit for mhpmcounter31h: enabled
    csrrw x0, mcountinhibit, x10      # mcountinhibit for mhpmcounter31h: enabled
    addi x11, x0, 621                 # c.li's rd before (stale)
    lui x6, 42                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 43                        # quiet
    lui x28, 44                       # quiet
    .option push
    .option rvc
    c.li x11, 5                   # c.li: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x9, mhpmcounter31h, x0      # subject csrrs: reads mhpmcounter31h, d1 (csr_counter_read_d1)
    lui x29, 45                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 46                        # quiet
    lui x7, 47                        # quiet
    addi x9, x0, 635                  # x9 known again: it held the counter, which differs between the engines
# block 207  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31h__alu_nosrc (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 207  # marker: block 207
    lui x28, 48                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 49                       # quiet
    lui x6, 50                        # quiet
    addi x13, x0, 642                 # x13 = 642
    addi x14, x0, 649                 # c.lui's rd before (stale)
    lui x7, 51                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 52                       # quiet
    lui x29, 53                       # quiet
    .option push
    .option rvc
    c.lui x14, 5                  # c.lui: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrw x0, mhpmcounter31h, x13     # subject csrrw: names mhpmcounter31h and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x6, 54                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 55                        # quiet
    lui x28, 56                       # quiet
# block 208  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31h__load (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 208  # marker: block 208
    lui x29, 57                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 58                        # quiet
    lui x7, 59                        # quiet
    lui x18, 0x80000                  # mcountinhibit for mhpmcounter31h: inhibited
    lui x28, 60                       # mcountinhibit for mhpmcounter31h: inhibited (quiet)
    lui x29, 61                       # mcountinhibit for mhpmcounter31h: inhibited (quiet)
    lui x6, 62                        # mcountinhibit for mhpmcounter31h: inhibited (quiet)
    addi x18, x18, 0                  # mcountinhibit for mhpmcounter31h: inhibited
    csrrw x0, mcountinhibit, x18      # mcountinhibit for mhpmcounter31h: inhibited
    .L55: auipc x20, %pcrel_hi(w54)   # lw's base -> w54
    lui x7, 63                        # lw's base -> w54 (quiet)
    lui x28, 64                       # lw's base -> w54 (quiet)
    lui x29, 65                       # lw's base -> w54 (quiet)
    addi x20, x20, %pcrel_lo(.L55)    # lw's base -> w54
    addi x19, x0, 950                 # lw's rd before (stale)
    lui x6, 66                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 67                        # quiet
    lui x28, 68                       # quiet
    lw x19, 0(x20)                    # lw: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x17, mhpmcounter31h, x0     # subject csrrs: reads mhpmcounter31h, d1 (csr_counter_read_d1)
    lui x29, 69                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 70                        # quiet
    lui x7, 71                        # quiet
    addi x17, x0, 964                 # x17 known again: it held the counter, which differs between the engines
# block 209  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31h__load (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 209  # marker: block 209
    lui x28, 72                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 73                       # quiet
    lui x6, 74                        # quiet
    addi x22, x0, 0                   # mcountinhibit for mhpmcounter31h: enabled
    csrrw x0, mcountinhibit, x22      # mcountinhibit for mhpmcounter31h: enabled
    .L56: auipc x14, %pcrel_hi(w55)   # c.lbu's base -> w55
    lui x7, 75                        # c.lbu's base -> w55 (quiet)
    lui x28, 76                       # c.lbu's base -> w55 (quiet)
    lui x29, 77                       # c.lbu's base -> w55 (quiet)
    addi x14, x14, %pcrel_lo(.L56)    # c.lbu's base -> w55
    addi x13, x0, 978                 # c.lbu's rd before (stale)
    lui x6, 78                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 79                        # quiet
    lui x28, 80                       # quiet
    .option push
    .option rvc
    c.lbu x13, 0(x14)             # c.lbu: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x21, mhpmcounter31h, x0     # subject csrrs: reads mhpmcounter31h, d1 (csr_counter_read_d1)
    lui x29, 81                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 82                        # quiet
    lui x7, 83                        # quiet
    addi x21, x0, 992                 # x21 known again: it held the counter, which differs between the engines
# block 210  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31h__load (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 210  # marker: block 210
    lui x28, 84                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 85                       # quiet
    lui x6, 86                        # quiet
    addi x26, x0, 999                 # x26 = 999
    .L57: auipc x10, %pcrel_hi(w56)   # c.lh's base -> w56
    lui x7, 87                        # c.lh's base -> w56 (quiet)
    lui x28, 88                       # c.lh's base -> w56 (quiet)
    lui x29, 89                       # c.lh's base -> w56 (quiet)
    addi x10, x10, %pcrel_lo(.L57)    # c.lh's base -> w56
    addi x9, x0, 1013                 # c.lh's rd before (stale)
    lui x6, 90                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 91                        # quiet
    lui x28, 92                       # quiet
    .option push
    .option rvc
    c.lh x9, 0(x10)               # c.lh: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrw x0, mhpmcounter31h, x26     # subject csrrw: names mhpmcounter31h and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x29, 93                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 94                        # quiet
    lui x7, 95                        # quiet
# block 211  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31h__store (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 211  # marker: block 211
    lui x28, 96                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 97                       # quiet
    lui x6, 98                        # quiet
    lui x9, 0x80000                   # mcountinhibit for mhpmcounter31h: inhibited
    lui x7, 99                        # mcountinhibit for mhpmcounter31h: inhibited (quiet)
    lui x28, 100                      # mcountinhibit for mhpmcounter31h: inhibited (quiet)
    lui x29, 101                      # mcountinhibit for mhpmcounter31h: inhibited (quiet)
    addi x9, x9, 0                    # mcountinhibit for mhpmcounter31h: inhibited
    csrrw x0, mcountinhibit, x9       # mcountinhibit for mhpmcounter31h: inhibited
    .L58: auipc x10, %pcrel_hi(w57)   # sw's base -> w57
    lui x6, 102                       # sw's base -> w57 (quiet)
    lui x7, 103                       # sw's base -> w57 (quiet)
    lui x28, 104                      # sw's base -> w57 (quiet)
    addi x10, x10, %pcrel_lo(.L58)    # sw's base -> w57
    addi x11, x0, 2                   # sw's store data
    lui x29, 105                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 106                       # quiet
    lui x7, 107                       # quiet
    sw x11, 0(x10)                    # sw: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x8, mhpmcounter31h, x0      # subject csrrs: reads mhpmcounter31h, d1 (csr_counter_read_d1)
    lui x28, 108                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 109                      # quiet
    lui x6, 110                       # quiet
    addi x8, x0, 1034                 # x8 known again: it held the counter, which differs between the engines
# block 212  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31h__store (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 212  # marker: block 212
    lui x7, 111                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 112                      # quiet
    lui x29, 113                      # quiet
    addi x13, x0, 0                   # mcountinhibit for mhpmcounter31h: enabled
    csrrw x0, mcountinhibit, x13      # mcountinhibit for mhpmcounter31h: enabled
    .L59: auipc x9, %pcrel_hi(w58)    # c.sb's base -> w58
    lui x6, 114                       # c.sb's base -> w58 (quiet)
    lui x7, 115                       # c.sb's base -> w58 (quiet)
    lui x28, 116                      # c.sb's base -> w58 (quiet)
    addi x9, x9, %pcrel_lo(.L59)      # c.sb's base -> w58
    addi x10, x0, 1048                # c.sb's store data
    lui x29, 117                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 118                       # quiet
    lui x7, 119                       # quiet
    .option push
    .option rvc
    c.sb x10, 0(x9)               # c.sb: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x12, mhpmcounter31h, x0     # subject csrrs: reads mhpmcounter31h, d1 (csr_counter_read_d1)
    lui x28, 120                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 121                      # quiet
    lui x6, 122                       # quiet
    addi x12, x0, 1062                # x12 known again: it held the counter, which differs between the engines
# block 213  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31h__store (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 213  # marker: block 213
    lui x7, 123                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 124                      # quiet
    lui x29, 125                      # quiet
    addi x17, x0, 1069                # x17 = 1069
    .L60: auipc x13, %pcrel_hi(w59)   # c.sh's base -> w59
    lui x6, 126                       # c.sh's base -> w59 (quiet)
    lui x7, 127                       # c.sh's base -> w59 (quiet)
    lui x28, 128                      # c.sh's base -> w59 (quiet)
    addi x13, x13, %pcrel_lo(.L60)    # c.sh's base -> w59
    addi x14, x0, 1083                # c.sh's store data
    lui x29, 129                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 130                       # quiet
    lui x7, 131                       # quiet
    .option push
    .option rvc
    c.sh x14, 0(x13)              # c.sh: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrw x0, mhpmcounter31h, x17     # subject csrrw: names mhpmcounter31h and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x28, 132                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 133                      # quiet
    lui x6, 134                       # quiet
# block 214  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31h__csr_r (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 214  # marker: block 214
    lui x7, 135                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 136                      # quiet
    lui x29, 137                      # quiet
    lui x21, 0x80000                  # mcountinhibit for mhpmcounter31h: inhibited
    lui x6, 138                       # mcountinhibit for mhpmcounter31h: inhibited (quiet)
    lui x7, 139                       # mcountinhibit for mhpmcounter31h: inhibited (quiet)
    lui x28, 140                      # mcountinhibit for mhpmcounter31h: inhibited (quiet)
    addi x21, x21, 0                  # mcountinhibit for mhpmcounter31h: inhibited
    csrrw x0, mcountinhibit, x21      # mcountinhibit for mhpmcounter31h: inhibited
    addi x23, x0, 1090                # csrrc's operand
    addi x22, x0, 1097                # csrrc's rd before (stale)
    lui x29, 141                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 142                       # quiet
    lui x7, 143                       # quiet
    csrrc x22, mscratch, x23          # csrrc: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x20, mhpmcounter31h, x0     # subject csrrs: reads mhpmcounter31h, d1 (csr_counter_read_d1)
    lui x28, 144                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 145                      # quiet
    lui x6, 146                       # quiet
    addi x20, x0, 1111                # x20 known again: it held the counter, which differs between the engines
# block 215  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31h__csr_r (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 215  # marker: block 215
    lui x7, 147                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 148                      # quiet
    lui x29, 149                      # quiet
    addi x25, x0, 0                   # mcountinhibit for mhpmcounter31h: enabled
    csrrw x0, mcountinhibit, x25      # mcountinhibit for mhpmcounter31h: enabled
    addi x27, x0, 1118                # csrrs's operand
    addi x26, x0, 1125                # csrrs's rd before (stale)
    lui x6, 150                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 151                       # quiet
    lui x28, 152                      # quiet
    csrrs x26, mscratch, x27          # csrrs: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x24, mhpmcounter31h, x0     # subject csrrs: reads mhpmcounter31h, d1 (csr_counter_read_d1)
    lui x29, 153                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 154                       # quiet
    lui x7, 155                       # quiet
    addi x24, x0, 1139                # x24 known again: it held the counter, which differs between the engines
# block 216  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31h__csr_r (after_write)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 216  # marker: block 216
    lui x28, 156                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 157                      # quiet
    lui x6, 158                       # quiet
    addi x8, x0, 1146                 # x8 = 1146
    lui x7, 159                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 160                      # quiet
    lui x29, 161                      # quiet
    csrrw x0, mhpmcounter31h, x8      # csrrw: writes mhpmcounter31h, the counter the subject reads
    csrrs x3, mhpmcounter31h, x0      # subject csrrs: reads mhpmcounter31h, d1 (csr_counter_read_d1)
    lui x6, 162                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 163                       # quiet
    lui x28, 164                      # quiet
    addi x3, x0, 1160                 # x3 known again: it held the counter, which differs between the engines
# block 217  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31h__csr_r (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 217  # marker: block 217
    lui x29, 165                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 166                       # quiet
    lui x7, 167                       # quiet
    addi x10, x0, 1167                # x10 = 1167
    addi x12, x0, 1174                # csrrc's operand
    addi x11, x0, 1181                # csrrc's rd before (stale)
    lui x28, 168                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 169                      # quiet
    lui x6, 170                       # quiet
    csrrc x11, mscratch, x12          # csrrc: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter31h, x10     # subject csrrw: names mhpmcounter31h and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x7, 171                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 172                      # quiet
    lui x29, 173                      # quiet
# block 218  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31h__csr_i (inhibited)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 218  # marker: block 218
    lui x6, 174                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 175                       # quiet
    lui x28, 176                      # quiet
    lui x14, 0x80000                  # mcountinhibit for mhpmcounter31h: inhibited
    lui x29, 177                      # mcountinhibit for mhpmcounter31h: inhibited (quiet)
    lui x6, 178                       # mcountinhibit for mhpmcounter31h: inhibited (quiet)
    lui x7, 179                       # mcountinhibit for mhpmcounter31h: inhibited (quiet)
    addi x14, x14, 0                  # mcountinhibit for mhpmcounter31h: inhibited
    csrrw x0, mcountinhibit, x14      # mcountinhibit for mhpmcounter31h: inhibited
    addi x15, x0, 1188                # csrrci's rd before (stale)
    lui x28, 180                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 181                      # quiet
    lui x6, 182                       # quiet
    csrrci x15, mscratch, 7           # csrrci: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x13, mhpmcounter31h, x0     # subject csrrs: reads mhpmcounter31h, d1 (csr_counter_read_d1)
    lui x7, 183                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 184                      # quiet
    lui x29, 185                      # quiet
    addi x13, x0, 1202                # x13 known again: it held the counter, which differs between the engines
# block 219  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31h__csr_i (enabled)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 219  # marker: block 219
    lui x6, 186                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 187                       # quiet
    lui x28, 188                      # quiet
    addi x17, x0, 0                   # mcountinhibit for mhpmcounter31h: enabled
    csrrw x0, mcountinhibit, x17      # mcountinhibit for mhpmcounter31h: enabled
    addi x18, x0, 1209                # csrrsi's rd before (stale)
    lui x29, 189                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 190                       # quiet
    lui x7, 191                       # quiet
    csrrsi x18, mscratch, 7           # csrrsi: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x16, mhpmcounter31h, x0     # subject csrrs: reads mhpmcounter31h, d1 (csr_counter_read_d1)
    lui x28, 192                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 193                      # quiet
    lui x6, 194                       # quiet
    addi x16, x0, 1223                # x16 known again: it held the counter, which differs between the engines
# block 220  csr_counter_read_d1  csr_counter_read_d1__mhpmcounter31h__csr_i (no_read)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 220  # marker: block 220
    lui x7, 195                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 196                      # quiet
    lui x29, 197                      # quiet
    addi x20, x0, 1230                # x20 = 1230
    addi x21, x0, 1237                # csrrwi's rd before (stale)
    lui x6, 198                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 199                       # quiet
    lui x28, 200                      # quiet
    csrrwi x21, mscratch, 7           # csrrwi: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrw x0, mhpmcounter31h, x20     # subject csrrw: names mhpmcounter31h and reads nothing (rd is x0), d1 (csr_counter_read_d1)
    lui x29, 201                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 202                       # quiet
    lui x7, 203                       # quiet
# block 221  csr_counter_read_d1  csr_counter_read_d1__cycle__alu_rr  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 221  # marker: block 221
    lui x28, 204                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 205                      # quiet
    lui x6, 206                       # quiet
    addi x24, x0, 1244                # sra's operand
    addi x25, x0, 1251                # sra's operand
    addi x23, x0, 1258                # sra's rd before (stale)
    lui x7, 207                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 208                      # quiet
    lui x29, 209                      # quiet
    sra x23, x24, x25                 # sra: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x22, cycle, x0              # subject csrrs: reads cycle, d1 (csr_counter_read_d1)
    lui x6, 210                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 211                       # quiet
    lui x28, 212                      # quiet
    addi x22, x0, 1272                # x22 known again: it held the counter, which differs between the engines
# block 222  csr_counter_read_d1  csr_counter_read_d1__cycle__alu_ri  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 222  # marker: block 222
    lui x29, 213                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 214                       # quiet
    lui x7, 215                       # quiet
    addi x3, x0, 1279                 # srai's operand
    addi x27, x0, 1286                # srai's rd before (stale)
    lui x28, 216                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 217                      # quiet
    lui x6, 218                       # quiet
    srai x27, x3, 0                   # srai: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x26, cycle, x0              # subject csrrs: reads cycle, d1 (csr_counter_read_d1)
    lui x7, 219                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 220                      # quiet
    lui x29, 221                      # quiet
    addi x26, x0, 1300                # x26 known again: it held the counter, which differs between the engines
# block 223  csr_counter_read_d1  csr_counter_read_d1__cycle__alu_nosrc  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 223  # marker: block 223
    lui x6, 222                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 223                       # quiet
    lui x28, 224                      # quiet
    addi x9, x0, 1307                 # auipc's rd before (stale)
    lui x29, 225                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 226                       # quiet
    lui x7, 227                       # quiet
    auipc x9, 74565                   # auipc: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x8, cycle, x0               # subject csrrs: reads cycle, d1 (csr_counter_read_d1)
    lui x28, 228                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 229                      # quiet
    lui x6, 230                       # quiet
    addi x8, x0, 1321                 # x8 known again: it held the counter, which differs between the engines
# block 224  csr_counter_read_d1  csr_counter_read_d1__cycle__load  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 224  # marker: block 224
    lui x7, 231                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 232                      # quiet
    lui x29, 233                      # quiet
    .L61: auipc x12, %pcrel_hi(w60)   # c.lhu's base -> w60
    lui x6, 234                       # c.lhu's base -> w60 (quiet)
    lui x7, 235                       # c.lhu's base -> w60 (quiet)
    lui x28, 236                      # c.lhu's base -> w60 (quiet)
    addi x12, x12, %pcrel_lo(.L61)    # c.lhu's base -> w60
    addi x11, x0, 1433                # c.lhu's rd before (stale)
    lui x29, 237                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 238                       # quiet
    lui x7, 239                       # quiet
    .option push
    .option rvc
    c.lhu x11, 0(x12)             # c.lhu: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x21, cycle, x0              # subject csrrs: reads cycle, d1 (csr_counter_read_d1)
    lui x28, 240                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 241                      # quiet
    lui x6, 242                       # quiet
    addi x21, x0, 1447                # x21 known again: it held the counter, which differs between the engines
# block 225  csr_counter_read_d1  csr_counter_read_d1__cycle__store  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 225  # marker: block 225
    lui x7, 243                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 244                      # quiet
    lui x29, 245                      # quiet
    .L62: auipc x14, %pcrel_hi(w61)   # c.sw's base -> w61
    lui x6, 246                       # c.sw's base -> w61 (quiet)
    lui x7, 247                       # c.sw's base -> w61 (quiet)
    lui x28, 248                      # c.sw's base -> w61 (quiet)
    addi x14, x14, %pcrel_lo(.L62)    # c.sw's base -> w61
    addi x15, x0, 1461                # c.sw's store data
    lui x29, 249                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 250                       # quiet
    lui x7, 251                       # quiet
    .option push
    .option rvc
    c.sw x15, 0(x14)              # c.sw: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x24, cycle, x0              # subject csrrs: reads cycle, d1 (csr_counter_read_d1)
    lui x28, 252                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 253                      # quiet
    lui x6, 254                       # quiet
    addi x24, x0, 1475                # x24 known again: it held the counter, which differs between the engines
# block 226  csr_counter_read_d1  csr_counter_read_d1__cycle__csr_r  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 226  # marker: block 226
    lui x7, 255                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 256                      # quiet
    lui x29, 257                      # quiet
    addi x8, x0, 1482                 # csrrs's operand
    addi x3, x0, 1489                 # csrrs's rd before (stale)
    lui x6, 258                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 259                       # quiet
    lui x28, 260                      # quiet
    csrrs x3, mscratch, x8            # csrrs: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x27, cycle, x0              # subject csrrs: reads cycle, d1 (csr_counter_read_d1)
    lui x29, 261                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 262                       # quiet
    lui x7, 263                       # quiet
    addi x27, x0, 1503                # x27 known again: it held the counter, which differs between the engines
# block 227  csr_counter_read_d1  csr_counter_read_d1__cycle__csr_i  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 227  # marker: block 227
    lui x28, 264                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 265                      # quiet
    lui x6, 266                       # quiet
    addi x10, x0, 1510                # csrrci's rd before (stale)
    lui x7, 267                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 268                      # quiet
    lui x29, 269                      # quiet
    csrrci x10, mscratch, 7           # csrrci: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x9, cycle, x0               # subject csrrs: reads cycle, d1 (csr_counter_read_d1)
    lui x6, 270                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 271                       # quiet
    lui x28, 272                      # quiet
    addi x9, x0, 1524                 # x9 known again: it held the counter, which differs between the engines
# block 228  csr_counter_read_d1  csr_counter_read_d1__cycleh__alu_rr  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 228  # marker: block 228
    lui x29, 273                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 274                       # quiet
    lui x7, 275                       # quiet
    addi x13, x0, 1531                # srl's operand
    addi x14, x0, 1538                # srl's operand
    addi x12, x0, 1545                # srl's rd before (stale)
    lui x28, 276                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 277                      # quiet
    lui x6, 278                       # quiet
    srl x12, x13, x14                 # srl: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x11, cycleh, x0             # subject csrrs: reads cycleh, d1 (csr_counter_read_d1)
    lui x7, 279                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 280                      # quiet
    lui x29, 281                      # quiet
    addi x11, x0, 1559                # x11 known again: it held the counter, which differs between the engines
# block 229  csr_counter_read_d1  csr_counter_read_d1__cycleh__alu_ri  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 229  # marker: block 229
    lui x6, 282                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 283                       # quiet
    lui x28, 284                      # quiet
    addi x17, x0, 1566                # srli's operand
    addi x16, x0, 1573                # srli's rd before (stale)
    lui x29, 285                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 286                       # quiet
    lui x7, 287                       # quiet
    srli x16, x17, 0                  # srli: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x15, cycleh, x0             # subject csrrs: reads cycleh, d1 (csr_counter_read_d1)
    lui x28, 288                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 289                      # quiet
    lui x6, 290                       # quiet
    addi x15, x0, 1587                # x15 known again: it held the counter, which differs between the engines
# block 230  csr_counter_read_d1  csr_counter_read_d1__cycleh__alu_nosrc  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 230  # marker: block 230
    lui x7, 291                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 292                      # quiet
    lui x29, 293                      # quiet
    addi x19, x0, 1594                # lui's rd before (stale)
    lui x6, 294                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 295                       # quiet
    lui x28, 296                      # quiet
    lui x19, 74565                    # lui: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x18, cycleh, x0             # subject csrrs: reads cycleh, d1 (csr_counter_read_d1)
    lui x29, 297                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 298                       # quiet
    lui x7, 299                       # quiet
    addi x18, x0, 1608                # x18 known again: it held the counter, which differs between the engines
# block 231  csr_counter_read_d1  csr_counter_read_d1__cycleh__load  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 231  # marker: block 231
    lui x28, 300                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 301                      # quiet
    lui x6, 302                       # quiet
    .L63: auipc x13, %pcrel_hi(w62)   # c.lw's base -> w62
    lui x7, 303                       # c.lw's base -> w62 (quiet)
    lui x28, 304                      # c.lw's base -> w62 (quiet)
    lui x29, 305                      # c.lw's base -> w62 (quiet)
    addi x13, x13, %pcrel_lo(.L63)    # c.lw's base -> w62
    addi x12, x0, 1727                # c.lw's rd before (stale)
    lui x6, 306                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 307                       # quiet
    lui x28, 308                      # quiet
    .option push
    .option rvc
    c.lw x12, 0(x13)              # c.lw: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x11, cycleh, x0             # subject csrrs: reads cycleh, d1 (csr_counter_read_d1)
    lui x29, 309                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 310                       # quiet
    lui x7, 311                       # quiet
    addi x11, x0, 1741                # x11 known again: it held the counter, which differs between the engines
# block 232  csr_counter_read_d1  csr_counter_read_d1__cycleh__store  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 232  # marker: block 232
    lui x28, 312                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 313                      # quiet
    lui x6, 314                       # quiet
    .L64: auipc x2, %pcrel_hi(w63)    # c.swsp's base -> w63
    lui x7, 315                       # c.swsp's base -> w63 (quiet)
    lui x28, 316                      # c.swsp's base -> w63 (quiet)
    lui x29, 317                      # c.swsp's base -> w63 (quiet)
    addi x2, x2, %pcrel_lo(.L64)      # c.swsp's base -> w63
    addi x16, x0, -1                  # c.swsp's store data
    lui x6, 318                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 319                       # quiet
    lui x28, 320                      # quiet
    .option push
    .option rvc
    c.swsp x16, 0(sp)             # c.swsp: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x15, cycleh, x0             # subject csrrs: reads cycleh, d1 (csr_counter_read_d1)
    lui x29, 321                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 322                       # quiet
    lui x7, 323                       # quiet
    addi x15, x0, 1762                # x15 known again: it held the counter, which differs between the engines
# block 233  csr_counter_read_d1  csr_counter_read_d1__cycleh__csr_r  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 233  # marker: block 233
    lui x28, 324                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 325                      # quiet
    lui x6, 326                       # quiet
    addi x19, x0, 1769                # csrrw's operand
    addi x18, x0, 1776                # csrrw's rd before (stale)
    lui x7, 327                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 328                      # quiet
    lui x29, 329                      # quiet
    csrrw x18, mscratch, x19          # csrrw: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x17, cycleh, x0             # subject csrrs: reads cycleh, d1 (csr_counter_read_d1)
    lui x6, 330                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 331                       # quiet
    lui x28, 332                      # quiet
    addi x17, x0, 1790                # x17 known again: it held the counter, which differs between the engines
# block 234  csr_counter_read_d1  csr_counter_read_d1__cycleh__csr_i  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 234  # marker: block 234
    lui x29, 333                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 334                       # quiet
    lui x7, 335                       # quiet
    addi x21, x0, 1797                # csrrsi's rd before (stale)
    lui x28, 336                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 337                      # quiet
    lui x6, 338                       # quiet
    csrrsi x21, mscratch, 7           # csrrsi: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x20, cycleh, x0             # subject csrrs: reads cycleh, d1 (csr_counter_read_d1)
    lui x7, 339                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 340                      # quiet
    lui x29, 341                      # quiet
    addi x20, x0, 1811                # x20 known again: it held the counter, which differs between the engines
# block 235  csr_counter_read_d1  csr_counter_read_d1__instret__alu_rr  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 235  # marker: block 235
    lui x6, 342                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 343                       # quiet
    lui x28, 344                      # quiet
    addi x24, x0, 1818                # sub's operand
    addi x25, x0, 1825                # sub's operand
    addi x23, x0, 1832                # sub's rd before (stale)
    lui x29, 345                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 346                       # quiet
    lui x7, 347                       # quiet
    sub x23, x24, x25                 # sub: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x22, instret, x0            # subject csrrs: reads instret, d1 (csr_counter_read_d1)
    lui x28, 348                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 349                      # quiet
    lui x6, 350                       # quiet
    addi x22, x0, 1846                # x22 known again: it held the counter, which differs between the engines
# block 236  csr_counter_read_d1  csr_counter_read_d1__instret__alu_ri  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 236  # marker: block 236
    lui x7, 351                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 352                      # quiet
    lui x29, 353                      # quiet
    addi x3, x0, 1853                 # xori's operand
    addi x27, x0, 1860                # xori's rd before (stale)
    lui x6, 354                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 355                       # quiet
    lui x28, 356                      # quiet
    xori x27, x3, 0                   # xori: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x26, instret, x0            # subject csrrs: reads instret, d1 (csr_counter_read_d1)
    lui x29, 357                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 358                       # quiet
    lui x7, 359                       # quiet
    addi x26, x0, 1874                # x26 known again: it held the counter, which differs between the engines
# block 237  csr_counter_read_d1  csr_counter_read_d1__instret__alu_nosrc  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 237  # marker: block 237
    lui x28, 360                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 361                      # quiet
    lui x6, 362                       # quiet
    addi x9, x0, 1881                 # c.li's rd before (stale)
    lui x7, 363                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 364                      # quiet
    lui x29, 365                      # quiet
    .option push
    .option rvc
    c.li x9, 5                    # c.li: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x8, instret, x0             # subject csrrs: reads instret, d1 (csr_counter_read_d1)
    lui x6, 366                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 367                       # quiet
    lui x28, 368                      # quiet
    addi x8, x0, 1895                 # x8 known again: it held the counter, which differs between the engines
# block 238  csr_counter_read_d1  csr_counter_read_d1__instret__load  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 238  # marker: block 238
    lui x29, 369                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 370                       # quiet
    lui x7, 371                       # quiet
    .L65: auipc x2, %pcrel_hi(w64)    # c.lwsp's base -> w64
    lui x28, 372                      # c.lwsp's base -> w64 (quiet)
    lui x29, 373                      # c.lwsp's base -> w64 (quiet)
    lui x6, 374                       # c.lwsp's base -> w64 (quiet)
    addi x2, x2, %pcrel_lo(.L65)      # c.lwsp's base -> w64
    addi x22, x0, 2007                # c.lwsp's rd before (stale)
    lui x7, 375                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 376                      # quiet
    lui x29, 377                      # quiet
    .option push
    .option rvc
    c.lwsp x22, 0(sp)             # c.lwsp: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x21, instret, x0            # subject csrrs: reads instret, d1 (csr_counter_read_d1)
    lui x6, 378                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 379                       # quiet
    lui x28, 380                      # quiet
    addi x21, x0, 2021                # x21 known again: it held the counter, which differs between the engines
# block 239  csr_counter_read_d1  csr_counter_read_d1__instret__store  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 239  # marker: block 239
    lui x29, 381                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 382                       # quiet
    lui x7, 383                       # quiet
    .L66: auipc x24, %pcrel_hi(w65)   # sb's base -> w65
    lui x28, 384                      # sb's base -> w65 (quiet)
    lui x29, 385                      # sb's base -> w65 (quiet)
    lui x6, 386                       # sb's base -> w65 (quiet)
    addi x24, x24, %pcrel_lo(.L66)    # sb's base -> w65
    addi x25, x0, 259                 # sb's store data
    lui x7, 387                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 388                      # quiet
    lui x29, 389                      # quiet
    sb x25, 0(x24)                    # sb: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x23, instret, x0            # subject csrrs: reads instret, d1 (csr_counter_read_d1)
    lui x6, 390                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 391                       # quiet
    lui x28, 392                      # quiet
    addi x23, x0, 273                 # x23 known again: it held the counter, which differs between the engines
# block 240  csr_counter_read_d1  csr_counter_read_d1__instret__csr_r  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 240  # marker: block 240
    lui x29, 393                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 394                       # quiet
    lui x7, 395                       # quiet
    addi x3, x0, 280                  # csrrc's operand
    addi x27, x0, 287                 # csrrc's rd before (stale)
    lui x28, 396                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 397                      # quiet
    lui x6, 398                       # quiet
    csrrc x27, mscratch, x3           # csrrc: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x26, instret, x0            # subject csrrs: reads instret, d1 (csr_counter_read_d1)
    lui x7, 399                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 400                      # quiet
    lui x29, 401                      # quiet
    addi x26, x0, 301                 # x26 known again: it held the counter, which differs between the engines
# block 241  csr_counter_read_d1  csr_counter_read_d1__instret__csr_i  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 241  # marker: block 241
    lui x6, 402                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 403                       # quiet
    lui x28, 404                      # quiet
    addi x9, x0, 308                  # csrrwi's rd before (stale)
    lui x29, 405                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 406                       # quiet
    lui x7, 407                       # quiet
    csrrwi x9, mscratch, 7            # csrrwi: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x8, instret, x0             # subject csrrs: reads instret, d1 (csr_counter_read_d1)
    lui x28, 408                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 409                      # quiet
    lui x6, 410                       # quiet
    addi x8, x0, 322                  # x8 known again: it held the counter, which differs between the engines
# block 242  csr_counter_read_d1  csr_counter_read_d1__instreth__alu_rr  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 242  # marker: block 242
    lui x7, 411                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 412                      # quiet
    lui x29, 413                      # quiet
    addi x12, x0, 329                 # xor's operand
    addi x13, x0, 336                 # xor's operand
    addi x11, x0, 343                 # xor's rd before (stale)
    lui x6, 414                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 415                       # quiet
    lui x28, 416                      # quiet
    xor x11, x12, x13                 # xor: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x10, instreth, x0           # subject csrrs: reads instreth, d1 (csr_counter_read_d1)
    lui x29, 417                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 418                       # quiet
    lui x7, 419                       # quiet
    addi x10, x0, 357                 # x10 known again: it held the counter, which differs between the engines
# block 243  csr_counter_read_d1  csr_counter_read_d1__instreth__alu_ri  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 243  # marker: block 243
    lui x28, 420                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 421                      # quiet
    lui x6, 422                       # quiet
    addi x15, x0, 364                 # c.addi's rd before (stale)
    lui x7, 423                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 424                      # quiet
    lui x29, 425                      # quiet
    .option push
    .option rvc
    c.addi x15, 5                 # c.addi: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x14, instreth, x0           # subject csrrs: reads instreth, d1 (csr_counter_read_d1)
    lui x6, 426                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 427                       # quiet
    lui x28, 428                      # quiet
    addi x14, x0, 378                 # x14 known again: it held the counter, which differs between the engines
# block 244  csr_counter_read_d1  csr_counter_read_d1__instreth__alu_nosrc  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 244  # marker: block 244
    lui x29, 429                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 430                       # quiet
    lui x7, 431                       # quiet
    addi x17, x0, 385                 # c.lui's rd before (stale)
    lui x28, 432                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 433                      # quiet
    lui x6, 434                       # quiet
    .option push
    .option rvc
    c.lui x17, 5                  # c.lui: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x16, instreth, x0           # subject csrrs: reads instreth, d1 (csr_counter_read_d1)
    lui x7, 435                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 436                      # quiet
    lui x29, 437                      # quiet
    addi x16, x0, 399                 # x16 known again: it held the counter, which differs between the engines
# block 245  csr_counter_read_d1  csr_counter_read_d1__instreth__load  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 245  # marker: block 245
    lui x6, 438                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 439                       # quiet
    lui x28, 440                      # quiet
    .L67: auipc x11, %pcrel_hi(w66)   # lb's base -> w66
    lui x29, 441                      # lb's base -> w66 (quiet)
    lui x6, 442                       # lb's base -> w66 (quiet)
    lui x7, 443                       # lb's base -> w66 (quiet)
    addi x11, x11, %pcrel_lo(.L67)    # lb's base -> w66
    addi x10, x0, 518                 # lb's rd before (stale)
    lui x28, 444                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 445                      # quiet
    lui x6, 446                       # quiet
    lb x10, 0(x11)                    # lb: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x9, instreth, x0            # subject csrrs: reads instreth, d1 (csr_counter_read_d1)
    lui x7, 447                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 448                      # quiet
    lui x29, 449                      # quiet
    addi x9, x0, 532                  # x9 known again: it held the counter, which differs between the engines
# block 246  csr_counter_read_d1  csr_counter_read_d1__instreth__store  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 246  # marker: block 246
    lui x6, 450                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 451                       # quiet
    lui x28, 452                      # quiet
    .L68: auipc x13, %pcrel_hi(w67)   # sh's base -> w67
    lui x29, 453                      # sh's base -> w67 (quiet)
    lui x6, 454                       # sh's base -> w67 (quiet)
    lui x7, 455                       # sh's base -> w67 (quiet)
    addi x13, x13, %pcrel_lo(.L68)    # sh's base -> w67
    addi x14, x0, 546                 # sh's store data
    lui x28, 456                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 457                      # quiet
    lui x6, 458                       # quiet
    sh x14, 0(x13)                    # sh: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x12, instreth, x0           # subject csrrs: reads instreth, d1 (csr_counter_read_d1)
    lui x7, 459                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 460                      # quiet
    lui x29, 461                      # quiet
    addi x12, x0, 560                 # x12 known again: it held the counter, which differs between the engines
# block 247  csr_counter_read_d1  csr_counter_read_d1__instreth__csr_r  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 247  # marker: block 247
    lui x6, 462                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 463                       # quiet
    lui x28, 464                      # quiet
    addi x17, x0, 567                 # csrrs's operand
    addi x16, x0, 574                 # csrrs's rd before (stale)
    lui x29, 465                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 466                       # quiet
    lui x7, 467                       # quiet
    csrrs x16, mscratch, x17          # csrrs: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x15, instreth, x0           # subject csrrs: reads instreth, d1 (csr_counter_read_d1)
    lui x28, 468                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 469                      # quiet
    lui x6, 470                       # quiet
    addi x15, x0, 588                 # x15 known again: it held the counter, which differs between the engines
# block 248  csr_counter_read_d1  csr_counter_read_d1__instreth__csr_i  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 248  # marker: block 248
    lui x7, 471                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 472                      # quiet
    lui x29, 473                      # quiet
    addi x19, x0, 595                 # csrrci's rd before (stale)
    lui x6, 474                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 475                       # quiet
    lui x28, 476                      # quiet
    csrrci x19, mscratch, 7           # csrrci: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x18, instreth, x0           # subject csrrs: reads instreth, d1 (csr_counter_read_d1)
    lui x29, 477                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 478                       # quiet
    lui x7, 479                       # quiet
    addi x18, x0, 609                 # x18 known again: it held the counter, which differs between the engines
# block 249  csr_counter_read_d1  csr_counter_read_d1__hpmcounter3__alu_rr  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 249  # marker: block 249
    lui x28, 480                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 481                      # quiet
    lui x6, 482                       # quiet
    addi x22, x0, 616                 # xor's operand
    addi x23, x0, 623                 # xor's operand
    addi x21, x0, 630                 # xor's rd before (stale)
    lui x7, 483                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 484                      # quiet
    lui x29, 485                      # quiet
    xor x21, x22, x23                 # xor: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x20, hpmcounter3, x0        # subject csrrs: reads hpmcounter3, d1 (csr_counter_read_d1)
    lui x6, 486                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 487                       # quiet
    lui x28, 488                      # quiet
    addi x20, x0, 644                 # x20 known again: it held the counter, which differs between the engines
# block 250  csr_counter_read_d1  csr_counter_read_d1__hpmcounter3__alu_ri  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 250  # marker: block 250
    lui x29, 489                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 490                       # quiet
    lui x7, 491                       # quiet
    addi x25, x0, 651                 # c.addi's rd before (stale)
    lui x28, 492                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 493                      # quiet
    lui x6, 494                       # quiet
    .option push
    .option rvc
    c.addi x25, 5                 # c.addi: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x24, hpmcounter3, x0        # subject csrrs: reads hpmcounter3, d1 (csr_counter_read_d1)
    lui x7, 495                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 496                      # quiet
    lui x29, 497                      # quiet
    addi x24, x0, 665                 # x24 known again: it held the counter, which differs between the engines
# block 251  csr_counter_read_d1  csr_counter_read_d1__hpmcounter3__alu_nosrc  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 251  # marker: block 251
    lui x6, 498                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 499                       # quiet
    lui x28, 500                      # quiet
    addi x27, x0, 672                 # auipc's rd before (stale)
    lui x29, 501                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 502                       # quiet
    lui x7, 503                       # quiet
    auipc x27, 74565                  # auipc: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x26, hpmcounter3, x0        # subject csrrs: reads hpmcounter3, d1 (csr_counter_read_d1)
    lui x28, 504                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 505                      # quiet
    lui x6, 506                       # quiet
    addi x26, x0, 686                 # x26 known again: it held the counter, which differs between the engines
# block 252  csr_counter_read_d1  csr_counter_read_d1__hpmcounter3__load  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 252  # marker: block 252
    lui x7, 507                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 508                      # quiet
    lui x29, 509                      # quiet
    .L69: auipc x20, %pcrel_hi(w68)   # lbu's base -> w68
    lui x6, 510                       # lbu's base -> w68 (quiet)
    lui x7, 511                       # lbu's base -> w68 (quiet)
    lui x28, 512                      # lbu's base -> w68 (quiet)
    addi x20, x20, %pcrel_lo(.L69)    # lbu's base -> w68
    addi x19, x0, 798                 # lbu's rd before (stale)
    lui x29, 513                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 514                       # quiet
    lui x7, 515                       # quiet
    lbu x19, 0(x20)                   # lbu: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x18, hpmcounter3, x0        # subject csrrs: reads hpmcounter3, d1 (csr_counter_read_d1)
    lui x28, 516                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 517                      # quiet
    lui x6, 518                       # quiet
    addi x18, x0, 812                 # x18 known again: it held the counter, which differs between the engines
# block 253  csr_counter_read_d1  csr_counter_read_d1__hpmcounter3__store  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 253  # marker: block 253
    lui x7, 519                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 520                      # quiet
    lui x29, 521                      # quiet
    .L70: auipc x22, %pcrel_hi(w69)   # sw's base -> w69
    lui x6, 522                       # sw's base -> w69 (quiet)
    lui x7, 523                       # sw's base -> w69 (quiet)
    lui x28, 524                      # sw's base -> w69 (quiet)
    addi x22, x22, %pcrel_lo(.L70)    # sw's base -> w69
    addi x23, x0, 826                 # sw's store data
    lui x29, 525                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 526                       # quiet
    lui x7, 527                       # quiet
    sw x23, 0(x22)                    # sw: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x21, hpmcounter3, x0        # subject csrrs: reads hpmcounter3, d1 (csr_counter_read_d1)
    lui x28, 528                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 529                      # quiet
    lui x6, 530                       # quiet
    addi x21, x0, 840                 # x21 known again: it held the counter, which differs between the engines
# block 254  csr_counter_read_d1  csr_counter_read_d1__hpmcounter3__csr_r  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 254  # marker: block 254
    lui x7, 531                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 532                      # quiet
    lui x29, 533                      # quiet
    addi x26, x0, 847                 # csrrw's operand
    addi x25, x0, 854                 # csrrw's rd before (stale)
    lui x6, 534                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 535                       # quiet
    lui x28, 536                      # quiet
    csrrw x25, mscratch, x26          # csrrw: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x24, hpmcounter3, x0        # subject csrrs: reads hpmcounter3, d1 (csr_counter_read_d1)
    lui x29, 537                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 538                       # quiet
    lui x7, 539                       # quiet
    addi x24, x0, 868                 # x24 known again: it held the counter, which differs between the engines
# block 255  csr_counter_read_d1  csr_counter_read_d1__hpmcounter3__csr_i  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 255  # marker: block 255
    lui x28, 540                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 541                      # quiet
    lui x6, 542                       # quiet
    addi x3, x0, 875                  # csrrsi's rd before (stale)
    lui x7, 543                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 544                      # quiet
    lui x29, 545                      # quiet
    csrrsi x3, mscratch, 7            # csrrsi: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x27, hpmcounter3, x0        # subject csrrs: reads hpmcounter3, d1 (csr_counter_read_d1)
    lui x6, 546                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 547                       # quiet
    lui x28, 548                      # quiet
    addi x27, x0, 889                 # x27 known again: it held the counter, which differs between the engines
# block 256  csr_counter_read_d1  csr_counter_read_d1__hpmcounter3h__alu_rr  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 256  # marker: block 256
    lui x29, 549                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 550                       # quiet
    lui x7, 551                       # quiet
    addi x10, x0, 896                 # c.add's operand
    addi x9, x0, 903                  # c.add's rd before (stale)
    lui x28, 552                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 553                      # quiet
    lui x6, 554                       # quiet
    .option push
    .option rvc
    c.add x9, x10                 # c.add: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x8, hpmcounter3h, x0        # subject csrrs: reads hpmcounter3h, d1 (csr_counter_read_d1)
    lui x7, 555                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 556                      # quiet
    lui x29, 557                      # quiet
    addi x8, x0, 917                  # x8 known again: it held the counter, which differs between the engines
# block 257  csr_counter_read_d1  csr_counter_read_d1__hpmcounter3h__alu_ri  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 257  # marker: block 257
    lui x6, 558                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 559                       # quiet
    lui x28, 560                      # quiet
    addi x2, x0, 924                  # c.addi16sp's operand
    addi x2, x0, 931                  # c.addi16sp's rd before (stale)
    lui x29, 561                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 562                       # quiet
    lui x7, 563                       # quiet
    .option push
    .option rvc
    c.addi16sp sp, 16             # c.addi16sp: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x11, hpmcounter3h, x0       # subject csrrs: reads hpmcounter3h, d1 (csr_counter_read_d1)
    lui x28, 564                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 565                      # quiet
    lui x6, 566                       # quiet
    addi x11, x0, 952                 # x11 known again: it held the counter, which differs between the engines
# block 258  csr_counter_read_d1  csr_counter_read_d1__hpmcounter3h__alu_nosrc  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 258  # marker: block 258
    lui x7, 567                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 568                      # quiet
    lui x29, 569                      # quiet
    addi x13, x0, 959                 # lui's rd before (stale)
    lui x6, 570                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 571                       # quiet
    lui x28, 572                      # quiet
    lui x13, 74565                    # lui: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x12, hpmcounter3h, x0       # subject csrrs: reads hpmcounter3h, d1 (csr_counter_read_d1)
    lui x29, 573                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 574                       # quiet
    lui x7, 575                       # quiet
    addi x12, x0, 973                 # x12 known again: it held the counter, which differs between the engines
# block 259  csr_counter_read_d1  csr_counter_read_d1__hpmcounter3h__load  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 259  # marker: block 259
    lui x28, 576                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 577                      # quiet
    lui x6, 578                       # quiet
    .L71: auipc x3, %pcrel_hi(w70)    # lh's base -> w70
    lui x7, 579                       # lh's base -> w70 (quiet)
    lui x28, 580                      # lh's base -> w70 (quiet)
    lui x29, 581                      # lh's base -> w70 (quiet)
    addi x3, x3, %pcrel_lo(.L71)      # lh's base -> w70
    addi x27, x0, 1092                # lh's rd before (stale)
    lui x6, 582                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 583                       # quiet
    lui x28, 584                      # quiet
    lh x27, 0(x3)                     # lh: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x26, hpmcounter3h, x0       # subject csrrs: reads hpmcounter3h, d1 (csr_counter_read_d1)
    lui x29, 585                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 586                       # quiet
    lui x7, 587                       # quiet
    addi x26, x0, 1106                # x26 known again: it held the counter, which differs between the engines
# block 260  csr_counter_read_d1  csr_counter_read_d1__hpmcounter3h__store  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 260  # marker: block 260
    lui x28, 588                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 589                      # quiet
    lui x6, 590                       # quiet
    .L72: auipc x14, %pcrel_hi(w71)   # c.sb's base -> w71
    lui x7, 591                       # c.sb's base -> w71 (quiet)
    lui x28, 592                      # c.sb's base -> w71 (quiet)
    lui x29, 593                      # c.sb's base -> w71 (quiet)
    addi x14, x14, %pcrel_lo(.L72)    # c.sb's base -> w71
    addi x15, x0, -2                  # c.sb's store data
    lui x6, 594                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 595                       # quiet
    lui x28, 596                      # quiet
    .option push
    .option rvc
    c.sb x15, 0(x14)              # c.sb: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x8, hpmcounter3h, x0        # subject csrrs: reads hpmcounter3h, d1 (csr_counter_read_d1)
    lui x29, 597                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 598                       # quiet
    lui x7, 599                       # quiet
    addi x8, x0, 1127                 # x8 known again: it held the counter, which differs between the engines
# block 261  csr_counter_read_d1  csr_counter_read_d1__hpmcounter3h__csr_r  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 261  # marker: block 261
    lui x28, 600                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 601                      # quiet
    lui x6, 602                       # quiet
    addi x13, x0, 1134                # csrrc's operand
    addi x12, x0, 1141                # csrrc's rd before (stale)
    lui x7, 603                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 604                      # quiet
    lui x29, 605                      # quiet
    csrrc x12, mscratch, x13          # csrrc: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x11, hpmcounter3h, x0       # subject csrrs: reads hpmcounter3h, d1 (csr_counter_read_d1)
    lui x6, 606                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 607                       # quiet
    lui x28, 608                      # quiet
    addi x11, x0, 1155                # x11 known again: it held the counter, which differs between the engines
# block 262  csr_counter_read_d1  csr_counter_read_d1__hpmcounter3h__csr_i  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 262  # marker: block 262
    lui x29, 609                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 610                       # quiet
    lui x7, 611                       # quiet
    addi x15, x0, 1162                # csrrwi's rd before (stale)
    lui x28, 612                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 613                      # quiet
    lui x6, 614                       # quiet
    csrrwi x15, mscratch, 7           # csrrwi: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x14, hpmcounter3h, x0       # subject csrrs: reads hpmcounter3h, d1 (csr_counter_read_d1)
    lui x7, 615                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 616                      # quiet
    lui x29, 617                      # quiet
    addi x14, x0, 1176                # x14 known again: it held the counter, which differs between the engines
# block 263  csr_counter_read_d1  csr_counter_read_d1__hpmcounter4__alu_rr  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 263  # marker: block 263
    lui x6, 618                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 619                       # quiet
    lui x28, 620                      # quiet
    addi x15, x0, 1183                # c.and's operand
    addi x14, x0, 1190                # c.and's rd before (stale)
    lui x29, 621                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 622                       # quiet
    lui x7, 623                       # quiet
    .option push
    .option rvc
    c.and x14, x15                # c.and: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x16, hpmcounter4, x0        # subject csrrs: reads hpmcounter4, d1 (csr_counter_read_d1)
    lui x28, 624                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 625                      # quiet
    lui x6, 626                       # quiet
    addi x16, x0, 1204                # x16 known again: it held the counter, which differs between the engines
# block 264  csr_counter_read_d1  csr_counter_read_d1__hpmcounter4__alu_ri  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 264  # marker: block 264
    lui x7, 627                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 628                      # quiet
    lui x29, 629                      # quiet
    addi x2, x0, 1211                 # c.addi4spn's operand
    addi x9, x0, 1218                 # c.addi4spn's rd before (stale)
    lui x6, 630                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 631                       # quiet
    lui x28, 632                      # quiet
    .option push
    .option rvc
    c.addi4spn x9, sp, 4          # c.addi4spn: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x19, hpmcounter4, x0        # subject csrrs: reads hpmcounter4, d1 (csr_counter_read_d1)
    lui x29, 633                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 634                       # quiet
    lui x7, 635                       # quiet
    addi x19, x0, 1239                # x19 known again: it held the counter, which differs between the engines
# block 265  csr_counter_read_d1  csr_counter_read_d1__hpmcounter4__alu_nosrc  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 265  # marker: block 265
    lui x28, 636                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 637                      # quiet
    lui x6, 638                       # quiet
    addi x22, x0, 1246                # c.li's rd before (stale)
    lui x7, 639                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 640                      # quiet
    lui x29, 641                      # quiet
    .option push
    .option rvc
    c.li x22, 5                   # c.li: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x21, hpmcounter4, x0        # subject csrrs: reads hpmcounter4, d1 (csr_counter_read_d1)
    lui x6, 642                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 643                       # quiet
    lui x28, 644                      # quiet
    addi x21, x0, 1260                # x21 known again: it held the counter, which differs between the engines
# block 266  csr_counter_read_d1  csr_counter_read_d1__hpmcounter4__load  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 266  # marker: block 266
    lui x29, 645                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 646                       # quiet
    lui x7, 647                       # quiet
    .L73: auipc x15, %pcrel_hi(w72)   # lhu's base -> w72
    lui x28, 648                      # lhu's base -> w72 (quiet)
    lui x29, 649                      # lhu's base -> w72 (quiet)
    lui x6, 650                       # lhu's base -> w72 (quiet)
    addi x15, x15, %pcrel_lo(.L73)    # lhu's base -> w72
    addi x14, x0, 1372                # lhu's rd before (stale)
    lui x7, 651                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 652                      # quiet
    lui x29, 653                      # quiet
    lhu x14, 0(x15)                   # lhu: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x13, hpmcounter4, x0        # subject csrrs: reads hpmcounter4, d1 (csr_counter_read_d1)
    lui x6, 654                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 655                       # quiet
    lui x28, 656                      # quiet
    addi x13, x0, 1386                # x13 known again: it held the counter, which differs between the engines
# block 267  csr_counter_read_d1  csr_counter_read_d1__hpmcounter4__store  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 267  # marker: block 267
    lui x29, 657                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 658                       # quiet
    lui x7, 659                       # quiet
    .L74: auipc x11, %pcrel_hi(w73)   # c.sh's base -> w73
    lui x28, 660                      # c.sh's base -> w73 (quiet)
    lui x29, 661                      # c.sh's base -> w73 (quiet)
    lui x6, 662                       # c.sh's base -> w73 (quiet)
    addi x11, x11, %pcrel_lo(.L74)    # c.sh's base -> w73
    addi x12, x0, 1400                # c.sh's store data
    lui x7, 663                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 664                      # quiet
    lui x29, 665                      # quiet
    .option push
    .option rvc
    c.sh x12, 0(x11)              # c.sh: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x16, hpmcounter4, x0        # subject csrrs: reads hpmcounter4, d1 (csr_counter_read_d1)
    lui x6, 666                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 667                       # quiet
    lui x28, 668                      # quiet
    addi x16, x0, 1414                # x16 known again: it held the counter, which differs between the engines
# block 268  csr_counter_read_d1  csr_counter_read_d1__hpmcounter4__csr_r  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 268  # marker: block 268
    lui x29, 669                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 670                       # quiet
    lui x7, 671                       # quiet
    addi x21, x0, 1421                # csrrs's operand
    addi x20, x0, 1428                # csrrs's rd before (stale)
    lui x28, 672                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 673                      # quiet
    lui x6, 674                       # quiet
    csrrs x20, mscratch, x21          # csrrs: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x19, hpmcounter4, x0        # subject csrrs: reads hpmcounter4, d1 (csr_counter_read_d1)
    lui x7, 675                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 676                      # quiet
    lui x29, 677                      # quiet
    addi x19, x0, 1442                # x19 known again: it held the counter, which differs between the engines
# block 269  csr_counter_read_d1  csr_counter_read_d1__hpmcounter4__csr_i  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 269  # marker: block 269
    lui x6, 678                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 679                       # quiet
    lui x28, 680                      # quiet
    addi x23, x0, 1449                # csrrci's rd before (stale)
    lui x29, 681                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 682                       # quiet
    lui x7, 683                       # quiet
    csrrci x23, mscratch, 7           # csrrci: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x22, hpmcounter4, x0        # subject csrrs: reads hpmcounter4, d1 (csr_counter_read_d1)
    lui x28, 684                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 685                      # quiet
    lui x6, 686                       # quiet
    addi x22, x0, 1463                # x22 known again: it held the counter, which differs between the engines
# block 270  csr_counter_read_d1  csr_counter_read_d1__hpmcounter31__alu_rr  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 270  # marker: block 270
    lui x7, 687                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 688                      # quiet
    lui x29, 689                      # quiet
    addi x26, x0, 1470                # c.mv's operand
    addi x25, x0, 1477                # c.mv's rd before (stale)
    lui x6, 690                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 691                       # quiet
    lui x28, 692                      # quiet
    .option push
    .option rvc
    c.mv x25, x26                 # c.mv: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x24, hpmcounter31, x0       # subject csrrs: reads hpmcounter31, d1 (csr_counter_read_d1)
    lui x29, 693                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 694                       # quiet
    lui x7, 695                       # quiet
    addi x24, x0, 1491                # x24 known again: it held the counter, which differs between the engines
# block 271  csr_counter_read_d1  csr_counter_read_d1__hpmcounter31__alu_ri  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 271  # marker: block 271
    lui x28, 696                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 697                      # quiet
    lui x6, 698                       # quiet
    addi x14, x0, 1498                # c.andi's rd before (stale)
    lui x7, 699                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 700                      # quiet
    lui x29, 701                      # quiet
    .option push
    .option rvc
    c.andi x14, 5                 # c.andi: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x27, hpmcounter31, x0       # subject csrrs: reads hpmcounter31, d1 (csr_counter_read_d1)
    lui x6, 702                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 703                       # quiet
    lui x28, 704                      # quiet
    addi x27, x0, 1512                # x27 known again: it held the counter, which differs between the engines
# block 272  csr_counter_read_d1  csr_counter_read_d1__hpmcounter31__alu_nosrc  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 272  # marker: block 272
    lui x29, 705                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 706                       # quiet
    lui x7, 707                       # quiet
    addi x9, x0, 1519                 # c.lui's rd before (stale)
    lui x28, 708                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 709                      # quiet
    lui x6, 710                       # quiet
    .option push
    .option rvc
    c.lui x9, 5                   # c.lui: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x8, hpmcounter31, x0        # subject csrrs: reads hpmcounter31, d1 (csr_counter_read_d1)
    lui x7, 711                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 712                      # quiet
    lui x29, 713                      # quiet
    addi x8, x0, 1533                 # x8 known again: it held the counter, which differs between the engines
# block 273  csr_counter_read_d1  csr_counter_read_d1__hpmcounter31__load  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 273  # marker: block 273
    lui x6, 714                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 715                       # quiet
    lui x28, 716                      # quiet
    .L75: auipc x24, %pcrel_hi(w74)   # lw's base -> w74
    lui x29, 717                      # lw's base -> w74 (quiet)
    lui x6, 718                       # lw's base -> w74 (quiet)
    lui x7, 719                       # lw's base -> w74 (quiet)
    addi x24, x24, %pcrel_lo(.L75)    # lw's base -> w74
    addi x23, x0, 1652                # lw's rd before (stale)
    lui x28, 720                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 721                      # quiet
    lui x6, 722                       # quiet
    lw x23, 0(x24)                    # lw: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x22, hpmcounter31, x0       # subject csrrs: reads hpmcounter31, d1 (csr_counter_read_d1)
    lui x7, 723                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 724                      # quiet
    lui x29, 725                      # quiet
    addi x22, x0, 1666                # x22 known again: it held the counter, which differs between the engines
# block 274  csr_counter_read_d1  csr_counter_read_d1__hpmcounter31__store  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 274  # marker: block 274
    lui x6, 726                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 727                       # quiet
    lui x28, 728                      # quiet
    .L76: auipc x9, %pcrel_hi(w75)    # c.sw's base -> w75
    lui x29, 729                      # c.sw's base -> w75 (quiet)
    lui x6, 730                       # c.sw's base -> w75 (quiet)
    lui x7, 731                       # c.sw's base -> w75 (quiet)
    addi x9, x9, %pcrel_lo(.L76)      # c.sw's base -> w75
    addi x10, x0, 1680                # c.sw's store data
    lui x28, 732                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 733                      # quiet
    lui x6, 734                       # quiet
    .option push
    .option rvc
    c.sw x10, 0(x9)               # c.sw: in the write stage when the read is one behind (csr_counter_read_d1)
    .option pop
    csrrs x25, hpmcounter31, x0       # subject csrrs: reads hpmcounter31, d1 (csr_counter_read_d1)
    lui x7, 735                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 736                      # quiet
    lui x29, 737                      # quiet
    addi x25, x0, 1694                # x25 known again: it held the counter, which differs between the engines
# block 275  csr_counter_read_d1  csr_counter_read_d1__hpmcounter31__csr_r  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 275  # marker: block 275
    lui x6, 738                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 739                       # quiet
    lui x28, 740                      # quiet
    addi x9, x0, 1701                 # csrrw's operand
    addi x8, x0, 1708                 # csrrw's rd before (stale)
    lui x29, 741                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 742                       # quiet
    lui x7, 743                       # quiet
    csrrw x8, mscratch, x9            # csrrw: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x3, hpmcounter31, x0        # subject csrrs: reads hpmcounter31, d1 (csr_counter_read_d1)
    lui x28, 744                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 745                      # quiet
    lui x6, 746                       # quiet
    addi x3, x0, 1722                 # x3 known again: it held the counter, which differs between the engines
# block 276  csr_counter_read_d1  csr_counter_read_d1__hpmcounter31__csr_i  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 276  # marker: block 276
    lui x7, 747                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 748                      # quiet
    lui x29, 749                      # quiet
    addi x11, x0, 1729                # csrrsi's rd before (stale)
    lui x6, 750                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 751                       # quiet
    lui x28, 752                      # quiet
    csrrsi x11, mscratch, 7           # csrrsi: in the write stage when the read is one behind (csr_counter_read_d1)
    csrrs x10, hpmcounter31, x0       # subject csrrs: reads hpmcounter31, d1 (csr_counter_read_d1)
    lui x29, 753                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 754                       # quiet
    lui x7, 755                       # quiet
    addi x10, x0, 1743                # x10 known again: it held the counter, which differs between the engines
# block 277  csr_implicit_mret_d1  csr_implicit_mret_d1__mret__csr_r  a statement of the core's own; expect(cv32e40x-clic): stall 2
    lui x0, 277  # marker: block 277
    lui x28, 756                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 757                      # quiet
    lui x6, 758                       # quiet
    lui x12, 0x2                      # mret: MPP = machine mode, so mret stays in M
    lui x7, 759                       # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x28, 760                      # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x29, 761                      # mret: MPP = machine mode, so mret stays in M (quiet)
    addi x12, x12, -2048              # mret: MPP = machine mode, so mret stays in M
    csrrs x0, mstatus, x12            # mret: MPP = machine mode, so mret stays in M
    .L78: auipc x12, %pcrel_hi(.L77)  # mret: mepc -> the label after it
    lui x6, 762                       # mret: mepc -> the label after it (quiet)
    lui x7, 763                       # mret: mepc -> the label after it (quiet)
    lui x28, 764                      # mret: mepc -> the label after it (quiet)
    addi x12, x12, %pcrel_lo(.L78)    # mret: mepc -> the label after it
    lui x29, 765                      # mret: mepc -> the label after it (quiet)
    lui x6, 766                       # mret: mepc -> the label after it (quiet)
    lui x7, 767                       # mret: mepc -> the label after it (quiet)
    csrrw x0, mepc, x12               # mret: mepc -> the label after it
    addi x14, x0, 1750                # csrrc's operand
    addi x13, x0, 1757                # csrrc's rd before (stale)
    lui x28, 768                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 769                      # quiet
    lui x6, 770                       # quiet
    csrrc x13, mscratch, x14          # csrrc: the instruction the subject follows (csr_implicit_mret_d1)
    mret                              # subject mret: d1 behind it (csr_implicit_mret_d1)
.L77:
    lui x7, 771                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 772                      # quiet
    lui x29, 773                      # quiet
# block 278  csr_implicit_mret_d1  csr_implicit_mret_d1__mret__csr_i  a statement of the core's own; expect(cv32e40x-clic): stall 2
    lui x0, 278  # marker: block 278
    lui x6, 774                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 775                       # quiet
    lui x28, 776                      # quiet
    lui x15, 0x2                      # mret: MPP = machine mode, so mret stays in M
    lui x29, 777                      # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x6, 778                       # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x7, 779                       # mret: MPP = machine mode, so mret stays in M (quiet)
    addi x15, x15, -2048              # mret: MPP = machine mode, so mret stays in M
    csrrs x0, mstatus, x15            # mret: MPP = machine mode, so mret stays in M
    .L80: auipc x15, %pcrel_hi(.L79)  # mret: mepc -> the label after it
    lui x28, 780                      # mret: mepc -> the label after it (quiet)
    lui x29, 781                      # mret: mepc -> the label after it (quiet)
    lui x6, 782                       # mret: mepc -> the label after it (quiet)
    addi x15, x15, %pcrel_lo(.L80)    # mret: mepc -> the label after it
    lui x7, 783                       # mret: mepc -> the label after it (quiet)
    lui x28, 784                      # mret: mepc -> the label after it (quiet)
    lui x29, 785                      # mret: mepc -> the label after it (quiet)
    csrrw x0, mepc, x15               # mret: mepc -> the label after it
    addi x16, x0, 1764                # csrrci's rd before (stale)
    lui x6, 786                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 787                       # quiet
    lui x28, 788                      # quiet
    csrrci x16, mscratch, 7           # csrrci: the instruction the subject follows (csr_implicit_mret_d1)
    mret                              # subject mret: d1 behind it (csr_implicit_mret_d1)
.L79:
    lui x29, 789                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 790                       # quiet
    lui x7, 791                       # quiet
# block 279  csr_implicit_mret_d2  csr_implicit_mret_d2__mret__csr_r  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 279  # marker: block 279
    lui x28, 792                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 793                      # quiet
    lui x6, 794                       # quiet
    lui x17, 0x2                      # mret: MPP = machine mode, so mret stays in M
    lui x7, 795                       # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x28, 796                      # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x29, 797                      # mret: MPP = machine mode, so mret stays in M (quiet)
    addi x17, x17, -2048              # mret: MPP = machine mode, so mret stays in M
    csrrs x0, mstatus, x17            # mret: MPP = machine mode, so mret stays in M
    .L82: auipc x17, %pcrel_hi(.L81)  # mret: mepc -> the label after it
    lui x6, 798                       # mret: mepc -> the label after it (quiet)
    lui x7, 799                       # mret: mepc -> the label after it (quiet)
    lui x28, 800                      # mret: mepc -> the label after it (quiet)
    addi x17, x17, %pcrel_lo(.L82)    # mret: mepc -> the label after it
    lui x29, 801                      # mret: mepc -> the label after it (quiet)
    lui x6, 802                       # mret: mepc -> the label after it (quiet)
    lui x7, 803                       # mret: mepc -> the label after it (quiet)
    csrrw x0, mepc, x17               # mret: mepc -> the label after it
    addi x19, x0, 1771                # csrrc's operand
    addi x18, x0, 1778                # csrrc's rd before (stale)
    lui x28, 804                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 805                      # quiet
    lui x6, 806                       # quiet
    csrrc x18, mscratch, x19          # csrrc: the instruction the subject follows (csr_implicit_mret_d2)
    lui x7, 807                       # filler (gap)
    mret                              # subject mret: d2 behind it (csr_implicit_mret_d2)
.L81:
    lui x28, 808                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 809                      # quiet
    lui x6, 810                       # quiet
# block 280  csr_implicit_mret_d2  csr_implicit_mret_d2__mret__csr_i  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 280  # marker: block 280
    lui x7, 811                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 812                      # quiet
    lui x29, 813                      # quiet
    lui x20, 0x2                      # mret: MPP = machine mode, so mret stays in M
    lui x6, 814                       # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x7, 815                       # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x28, 816                      # mret: MPP = machine mode, so mret stays in M (quiet)
    addi x20, x20, -2048              # mret: MPP = machine mode, so mret stays in M
    csrrs x0, mstatus, x20            # mret: MPP = machine mode, so mret stays in M
    .L84: auipc x20, %pcrel_hi(.L83)  # mret: mepc -> the label after it
    lui x29, 817                      # mret: mepc -> the label after it (quiet)
    lui x6, 818                       # mret: mepc -> the label after it (quiet)
    lui x7, 819                       # mret: mepc -> the label after it (quiet)
    addi x20, x20, %pcrel_lo(.L84)    # mret: mepc -> the label after it
    lui x28, 820                      # mret: mepc -> the label after it (quiet)
    lui x29, 821                      # mret: mepc -> the label after it (quiet)
    lui x6, 822                       # mret: mepc -> the label after it (quiet)
    csrrw x0, mepc, x20               # mret: mepc -> the label after it
    addi x21, x0, 1785                # csrrci's rd before (stale)
    lui x7, 823                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 824                      # quiet
    lui x29, 825                      # quiet
    csrrci x21, mscratch, 7           # csrrci: the instruction the subject follows (csr_implicit_mret_d2)
    lui x6, 826                       # filler (gap)
    mret                              # subject mret: d2 behind it (csr_implicit_mret_d2)
.L83:
    lui x7, 827                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 828                      # quiet
    lui x29, 829                      # quiet
# block 281  csr_after_tselect_d1  csr_after_tselect_d1__tselect__csr_r  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 281  # marker: block 281
    lui x6, 830                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 831                       # quiet
    lui x28, 832                      # quiet
    addi x24, x0, 1792                # csrrc's operand
    addi x23, x0, 1799                # csrrc's rd before (stale)
    lui x29, 833                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 834                       # quiet
    lui x7, 835                       # quiet
    csrrs x22, tselect, x0            # csrrs rd, tselect, x0: a read of tselect, no write (the access alone)
    csrrc x23, mscratch, x24          # subject csrrc: d1 behind the read of tselect (csr_after_tselect_d1)
    addi x22, x0, 1806                # x22 known again: it held tselect, which may differ between the engines
# block 282  csr_after_tselect_d1  csr_after_tselect_d1__tselect__csr_i  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 282  # marker: block 282
    lui x28, 836                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 837                      # quiet
    lui x6, 838                       # quiet
    addi x26, x0, 1813                # csrrci's rd before (stale)
    lui x7, 839                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 840                      # quiet
    lui x29, 841                      # quiet
    csrrs x25, tselect, x0            # csrrs rd, tselect, x0: a read of tselect, no write (the access alone)
    csrrci x26, mscratch, 7           # subject csrrci: d1 behind the read of tselect (csr_after_tselect_d1)
    addi x25, x0, 1820                # x25 known again: it held tselect, which may differ between the engines
# block 283  csr_after_mstatus_mcause_access_d1  csr_after_mstatus_mcause_access_d1__mstatus__csr_r  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 283  # marker: block 283
    lui x6, 842                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 843                       # quiet
    lui x28, 844                      # quiet
    addi x8, x0, 1827                 # csrrc's operand
    addi x3, x0, 1834                 # csrrc's rd before (stale)
    lui x29, 845                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 846                       # quiet
    lui x7, 847                       # quiet
    csrrs x27, mstatus, x0            # csrrs rd, mstatus, x0: a read of mstatus, no write (the access alone)
    csrrc x3, mscratch, x8            # subject csrrc: d1 behind the read of mstatus (csr_after_mstatus_mcause_access_d1)
    addi x27, x0, 1841                # x27 known again: it held mstatus, which may differ between the engines
# block 284  csr_after_mstatus_mcause_access_d1  csr_after_mstatus_mcause_access_d1__mstatus__csr_i  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 284  # marker: block 284
    lui x28, 848                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 849                      # quiet
    lui x6, 850                       # quiet
    addi x10, x0, 1848                # csrrci's rd before (stale)
    lui x7, 851                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 852                      # quiet
    lui x29, 853                      # quiet
    csrrs x9, mstatus, x0             # csrrs rd, mstatus, x0: a read of mstatus, no write (the access alone)
    csrrci x10, mscratch, 7           # subject csrrci: d1 behind the read of mstatus (csr_after_mstatus_mcause_access_d1)
    addi x9, x0, 1855                 # x9 known again: it held mstatus, which may differ between the engines
# block 285  csr_after_mstatus_mcause_access_d1  csr_after_mstatus_mcause_access_d1__mcause__csr_r  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 285  # marker: block 285
    lui x6, 854                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 855                       # quiet
    lui x28, 856                      # quiet
    addi x13, x0, 1862                # csrrs's operand
    addi x12, x0, 1869                # csrrs's rd before (stale)
    lui x29, 857                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 858                       # quiet
    lui x7, 859                       # quiet
    csrrs x11, mcause, x0             # csrrs rd, mcause, x0: a read of mcause, no write (the access alone)
    csrrs x12, mscratch, x13          # subject csrrs: d1 behind the read of mcause (csr_after_mstatus_mcause_access_d1)
    addi x11, x0, 1876                # x11 known again: it held mcause, which may differ between the engines
# block 286  csr_after_mstatus_mcause_access_d1  csr_after_mstatus_mcause_access_d1__mcause__csr_i  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 286  # marker: block 286
    lui x28, 860                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 861                      # quiet
    lui x6, 862                       # quiet
    addi x15, x0, 1883                # csrrsi's rd before (stale)
    lui x7, 863                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 864                      # quiet
    lui x29, 865                      # quiet
    csrrs x14, mcause, x0             # csrrs rd, mcause, x0: a read of mcause, no write (the access alone)
    csrrsi x15, mscratch, 7           # subject csrrsi: d1 behind the read of mcause (csr_after_mstatus_mcause_access_d1)
    addi x14, x0, 1890                # x14 known again: it held mcause, which may differ between the engines
# block 287  csr_mnxti_mscratchcswl_after_csr_d1  csr_mnxti_mscratchcswl_after_csr_d1__mnxti__csr_r  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 287  # marker: block 287
    lui x6, 866                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 867                       # quiet
    lui x28, 868                      # quiet
    addi x18, x0, 1897                # csrrc's operand
    addi x17, x0, 1904                # csrrc's rd before (stale)
    lui x29, 869                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 870                       # quiet
    lui x7, 871                       # quiet
    csrrc x17, mscratch, x18          # csrrc: in the write stage when the read is one behind (csr_mnxti_mscratchcswl_after_csr_d1)
    csrrs x16, 0x345, x0              # subject csrrs: reads mnxti, d1 (csr_mnxti_mscratchcswl_after_csr_d1)
    lui x28, 872                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 873                      # quiet
    lui x6, 874                       # quiet
    addi x16, x0, 1918                # x16 known again: it held the counter, which differs between the engines
# block 288  csr_mnxti_mscratchcswl_after_csr_d1  csr_mnxti_mscratchcswl_after_csr_d1__mnxti__csr_i  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 288  # marker: block 288
    lui x7, 875                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 876                      # quiet
    lui x29, 877                      # quiet
    addi x20, x0, 1925                # csrrci's rd before (stale)
    lui x6, 878                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 879                       # quiet
    lui x28, 880                      # quiet
    csrrci x20, mscratch, 7           # csrrci: in the write stage when the read is one behind (csr_mnxti_mscratchcswl_after_csr_d1)
    csrrs x19, 0x345, x0              # subject csrrs: reads mnxti, d1 (csr_mnxti_mscratchcswl_after_csr_d1)
    lui x29, 881                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 882                       # quiet
    lui x7, 883                       # quiet
    addi x19, x0, 1939                # x19 known again: it held the counter, which differs between the engines
# block 289  csr_mnxti_mscratchcswl_after_csr_d1  csr_mnxti_mscratchcswl_after_csr_d1__mscratchcswl__csr_r  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 289  # marker: block 289
    lui x28, 884                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 885                      # quiet
    lui x6, 886                       # quiet
    addi x23, x0, 1946                # csrrs's operand
    addi x22, x0, 1953                # csrrs's rd before (stale)
    lui x7, 887                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 888                      # quiet
    lui x29, 889                      # quiet
    addi x24, x0, 1960                # x24 = 1960
    csrrs x22, mscratch, x23          # csrrs: in the write stage when the read is one behind (csr_mnxti_mscratchcswl_after_csr_d1)
    csrrw x21, 0x349, x24             # subject csrrw: the access of mscratchcswl in its one legal form, d1 (csr_mnxti_mscratchcswl_after_csr_d1)
    lui x6, 890                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 891                       # quiet
    lui x28, 892                      # quiet
    addi x21, x0, 1974                # x21 known again: it held what the swap returned
# block 290  csr_mnxti_mscratchcswl_after_csr_d1  csr_mnxti_mscratchcswl_after_csr_d1__mscratchcswl__csr_i  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 290  # marker: block 290
    lui x29, 893                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 894                       # quiet
    lui x7, 895                       # quiet
    addi x26, x0, 1981                # csrrsi's rd before (stale)
    lui x28, 896                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 897                      # quiet
    lui x6, 898                       # quiet
    addi x27, x0, 1988                # x27 = 1988
    csrrsi x26, mscratch, 7           # csrrsi: in the write stage when the read is one behind (csr_mnxti_mscratchcswl_after_csr_d1)
    csrrw x25, 0x349, x27             # subject csrrw: the access of mscratchcswl in its one legal form, d1 (csr_mnxti_mscratchcswl_after_csr_d1)
    lui x7, 899                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 900                      # quiet
    lui x29, 901                      # quiet
    addi x25, x0, 2002                # x25 known again: it held what the swap returned
# block 291  irq_enable_lsu_d1  irq_enable_lsu_d1__mstatus__load  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 291  # marker: block 291
    lui x6, 902                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 903                       # quiet
    lui x28, 904                      # quiet
    addi x3, x0, 0                    # x3 = 0: the write of mstatus changes no bit
    .L85: auipc x15, %pcrel_hi(w76)   # c.lbu's base -> w76
    lui x29, 905                      # c.lbu's base -> w76 (quiet)
    lui x6, 906                       # c.lbu's base -> w76 (quiet)
    lui x7, 907                       # c.lbu's base -> w76 (quiet)
    addi x15, x15, %pcrel_lo(.L85)    # c.lbu's base -> w76
    addi x14, x0, 2016                # c.lbu's rd before (stale)
    lui x28, 908                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 909                      # quiet
    lui x6, 910                       # quiet
    csrrs x0, mstatus, x3             # csrrs: a write of mstatus (rs1 is not x0), its value unchanged
    .option push
    .option rvc
    c.lbu x14, 0(x15)             # subject c.lbu: d1 behind the write of mstatus (irq_enable_lsu_d1)
    .option pop
    lui x7, 911                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 912                      # quiet
    lui x29, 913                      # quiet
# block 292  irq_enable_lsu_d1  irq_enable_lsu_d1__mstatus__load (enabling)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 292  # marker: block 292
    lui x6, 914                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 915                       # quiet
    lui x28, 916                      # quiet
    addi x10, x0, 8                   # x10 = the enable bit of mstatus: the write enables
    .L86: auipc x11, %pcrel_hi(w77)   # c.lh's base -> w77
    lui x29, 917                      # c.lh's base -> w77 (quiet)
    lui x6, 918                       # c.lh's base -> w77 (quiet)
    lui x7, 919                       # c.lh's base -> w77 (quiet)
    addi x11, x11, %pcrel_lo(.L86)    # c.lh's base -> w77
    addi x9, x0, 2030                 # c.lh's rd before (stale)
    lui x28, 920                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 921                      # quiet
    lui x6, 922                       # quiet
    csrrs x0, mstatus, x10            # csrrs: a write of mstatus (rs1 is not x0), the enable bit set
    .option push
    .option rvc
    c.lh x9, 0(x11)               # subject c.lh: d1 behind the write of mstatus (irq_enable_lsu_d1)
    .option pop
    lui x7, 923                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 924                      # quiet
    lui x29, 925                      # quiet
    csrrc x0, mstatus, x10            # the enable bit of mstatus cleared again
# block 293  irq_enable_lsu_d1  irq_enable_lsu_d1__mstatus__store  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 293  # marker: block 293
    lui x6, 926                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 927                       # quiet
    lui x28, 928                      # quiet
    addi x14, x0, 0                   # x14 = 0: the write of mstatus changes no bit
    .L87: auipc x13, %pcrel_hi(w78)   # c.sb's base -> w78
    lui x29, 929                      # c.sb's base -> w78 (quiet)
    lui x6, 930                       # c.sb's base -> w78 (quiet)
    lui x7, 931                       # c.sb's base -> w78 (quiet)
    addi x13, x13, %pcrel_lo(.L87)    # c.sb's base -> w78
    addi x15, x0, 268                 # c.sb's store data
    lui x28, 932                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 933                      # quiet
    lui x6, 934                       # quiet
    csrrs x0, mstatus, x14            # csrrs: a write of mstatus (rs1 is not x0), its value unchanged
    .option push
    .option rvc
    c.sb x15, 0(x13)              # subject c.sb: d1 behind the write of mstatus (irq_enable_lsu_d1)
    .option pop
    lui x7, 935                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 936                      # quiet
    lui x29, 937                      # quiet
# block 294  irq_enable_lsu_d1  irq_enable_lsu_d1__mstatus__store (enabling)  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 294  # marker: block 294
    lui x6, 938                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 939                       # quiet
    lui x28, 940                      # quiet
    addi x18, x0, 8                   # x18 = the enable bit of mstatus: the write enables
    .L88: auipc x9, %pcrel_hi(w79)    # c.sh's base -> w79
    lui x29, 941                      # c.sh's base -> w79 (quiet)
    lui x6, 942                       # c.sh's base -> w79 (quiet)
    lui x7, 943                       # c.sh's base -> w79 (quiet)
    addi x9, x9, %pcrel_lo(.L88)      # c.sh's base -> w79
    addi x10, x0, 0                   # c.sh's store data
    lui x28, 944                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 945                      # quiet
    lui x6, 946                       # quiet
    csrrs x0, mstatus, x18            # csrrs: a write of mstatus (rs1 is not x0), the enable bit set
    .option push
    .option rvc
    c.sh x10, 0(x9)               # subject c.sh: d1 behind the write of mstatus (irq_enable_lsu_d1)
    .option pop
    lui x7, 947                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 948                      # quiet
    lui x29, 949                      # quiet
    csrrc x0, mstatus, x18            # the enable bit of mstatus cleared again
# block 295  irq_enable_lsu_d1  irq_enable_lsu_d1__mintthresh__load  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 295  # marker: block 295
    lui x6, 950                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 951                       # quiet
    lui x28, 952                      # quiet
    addi x21, x0, 0                   # x21 = 0: the write of mintthresh changes no bit
    .L89: auipc x13, %pcrel_hi(w80)   # c.lhu's base -> w80
    lui x29, 953                      # c.lhu's base -> w80 (quiet)
    lui x6, 954                       # c.lhu's base -> w80 (quiet)
    lui x7, 955                       # c.lhu's base -> w80 (quiet)
    addi x13, x13, %pcrel_lo(.L89)    # c.lhu's base -> w80
    addi x12, x0, 289                 # c.lhu's rd before (stale)
    lui x28, 956                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 957                      # quiet
    lui x6, 958                       # quiet
    csrrs x0, 0x347, x21              # csrrs: a write of mintthresh (rs1 is not x0), its value unchanged
    .option push
    .option rvc
    c.lhu x12, 0(x13)             # subject c.lhu: d1 behind the write of mintthresh (irq_enable_lsu_d1)
    .option pop
    lui x7, 959                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 960                      # quiet
    lui x29, 961                      # quiet
# block 296  irq_enable_lsu_d1  irq_enable_lsu_d1__mintthresh__store  a statement of the core's own; expect(cv32e40x-clic): stall 1
    lui x0, 296  # marker: block 296
    lui x6, 962                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 963                       # quiet
    lui x28, 964                      # quiet
    addi x24, x0, 0                   # x24 = 0: the write of mintthresh changes no bit
    .L90: auipc x15, %pcrel_hi(w81)   # c.sw's base -> w81
    lui x29, 965                      # c.sw's base -> w81 (quiet)
    lui x6, 966                       # c.sw's base -> w81 (quiet)
    lui x7, 967                       # c.sw's base -> w81 (quiet)
    addi x15, x15, %pcrel_lo(.L90)    # c.sw's base -> w81
    addi x8, x0, 303                  # c.sw's store data
    lui x28, 968                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 969                      # quiet
    lui x6, 970                       # quiet
    csrrs x0, 0x347, x24              # csrrs: a write of mintthresh (rs1 is not x0), its value unchanged
    .option push
    .option rvc
    c.sw x8, 0(x15)               # subject c.sw: d1 behind the write of mintthresh (irq_enable_lsu_d1)
    .option pop
    lui x7, 971                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 972                      # quiet
    lui x29, 973                      # quiet
TEST_END
    .section .data
    .align 12
tdata:
w0: .word 0x2f8
w1: .word 0x314
w2: .word 0x337
w3: .word 0x345
w4: .word 0x361
w5: .word 0x384
w6: .word 0x608
w7: .word 0x624
w8: .word 0x647
w9: .word 0x655
w10: .word 0x66a
w11: .word 0x68d
w12: .word 0x22f
w13: .word 0x24b
w14: .word 0x26e
w15: .word 0x27c
w16: .word 0x298
w17: .word 0x2b4
w18: .word 0x554
w19: .word 0x570
w20: .word 0x593
w21: .word 0x5a1
w22: .word 0x5bd
w23: .word 0x5e0
w24: .word 0x190
w25: .word 0x1ac
w26: .word 0x1cf
w27: .word 0x1dd
w28: .word 0x1f9
w29: .word 0x21c
w30: .word 0x4ca
w31: .word 0x4e6
w32: .word 0x509
w33: .word 0x517
w34: .word 0x52c
w35: .word 0x54f
w36: .word 0x106
w37: .word 0x122
w38: .word 0x145
w39: .word 0x153
w40: .word 0x16f
w41: .word 0x18b
w42: .word 0x439
w43: .word 0x455
w44: .word 0x478
w45: .word 0x486
w46: .word 0x4a2
w47: .word 0x4c5
w48: .word 0x765
w49: .word 0x781
w50: .word 0x7a4
w51: .word 0x7b2
w52: .word 0x7ce
w53: .word 0x101
w54: .word 0x3af
w55: .word 0x3cb
w56: .word 0x3ee
w57: .word 0x3fc
w58: .word 0x411
w59: .word 0x434
w60: .word 0x592
w61: .word 0x5ae
w62: .word 0x6b8
w63: .word 0x6d4
w64: .word 0x7d0
w65: .word 0x7ec
w66: .word 0x1ff
w67: .word 0x21b
w68: .word 0x317
w69: .word 0x333
w70: .word 0x43d
w71: .word 0x459
w72: .word 0x555
w73: .word 0x571
w74: .word 0x66d
w75: .word 0x689
w76: .word 0x7d9
w77: .word 0x7e7
w78: .word 0x105
w79: .word 0x113
w80: .word 0x11a
w81: .word 0x128
    .word 0
TEST_HTIF
