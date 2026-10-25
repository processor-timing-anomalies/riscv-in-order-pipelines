// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the whole test hzs-shape-01-zmmul-00, kept as it ran (no cut-down reproducer: a value issue (compare), not a timing window).
# the window: orders 1853..1856 of the run, the last the instruction whose timing differs (RTL 2 cycles; the documentation, read as written, gives 1)
# hzs-shape-01-zmmul-00.S -- a generated compound hazard test for rv32 I,M,Zmmul,Zba,Zbb,Zbs,Zca,Zcb,Zicsr,Zifencei,Sm, DMAX 2, multi-cycle mulh,div:
# one sampled instance of each shape of the grammar no named relation produces (decision 20), one straight-line
# block per case, one straight-line block per case.
# MARCH: rv32im_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
TEST_TRAPS
# block 1  shape/s2_ctrl01_struct12  s0=bge s1=mulhsu s2=lhu  e0=1 e1=1
    lui x0, 1                         # block 1
    lui x6, 2                         # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 3                         # quiet
    lui x28, 4                        # quiet
    addi x3, x0, 263                  # bge's operand
    addi x8, x0, 270                  # bge's operand
    addi x3, x0, 0                    # x3 = 0
    addi x8, x0, 0                    # x8 = 0
    addi x10, x0, 277                 # mulhsu's operand
    addi x11, x0, 284                 # mulhsu's operand
    addi x9, x0, 291                  # mulhsu's rd before (stale)
    .L1: auipc x13, %pcrel_hi(w0)     # lhu's base -> w0
    lui x29, 5                        # lhu's base -> w0 (quiet)
    lui x6, 6                         # lhu's base -> w0 (quiet)
    lui x7, 7                         # lhu's base -> w0 (quiet)
    addi x13, x13, %pcrel_lo(.L1)     # lhu's base -> w0
    addi x12, x0, 305                 # lhu's rd before (stale)
    lui x28, 8                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 9                        # quiet
    lui x6, 10                        # quiet
    bge x3, x8, .L2                   # s0 bge: the taken transfer, s1 d1 after it (ctrl)
.L2:
    mulhsu x9, x10, x11               # s1 mulhsu: d1 after the transfer s0 (ctrl); the busy unit s2 waits behind, d1 (struct)
    lhu x12, 0(x13)                   # subject s2 lhu: d1 behind the busy s1 (struct)
    lui x7, 11                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 12                       # quiet
    lui x29, 13                       # quiet
# block 2  shape/s2_war01_waw12  s0=lw s1=srli s2=mulhu  e0=3 e1=2
    lui x0, 2                         # block 2
    lui x6, 14                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 15                        # quiet
    lui x28, 16                       # quiet
    .L121: auipc x9, %pcrel_hi(w1)    # x9 -> w1
    lui x29, 17                       # x9 -> w1 (quiet)
    lui x6, 18                        # x9 -> w1 (quiet)
    lui x7, 19                        # x9 -> w1 (quiet)
    addi x9, x9, %pcrel_lo(.L121)     # x9 -> w1
    addi x10, x0, 1915                # lw's rd before (stale)
    addi x11, x0, 1922                # srli's operand: the identity delivers the value
    addi x12, x0, 1937                # mulhu's operand: the identity delivers the value
    addi x13, x0, -1                  # mulhu's operand: the identity delivers the value
    lui x28, 20                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 21                       # quiet
    lui x6, 22                        # quiet
    lw x10, 0(x9)                     # s0 lw: reads x9, which s1 writes at d3 (war)
    lui x7, 23                        # filler (gap)
    lui x28, 24                       # filler (gap)
    srli x9, x11, 0                   # s1 srli: writes x9, which s0 read, d3 (war); writes x9 before s2, d2 (waw)
    lui x29, 25                       # filler (gap)
    mulhu x9, x12, x13                # subject s2 mulhu: writes x9 after s1, d2 (waw)
    lui x6, 26                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 27                        # quiet
    lui x28, 28                       # quiet
# block 3  shape/s2_mem13_struct02  s0=mulhsu s1=sb s2=fence s3=lhu  e0=3 e1=3
    lui x0, 3                         # block 3
    lui x29, 29                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 30                        # quiet
    lui x7, 31                        # quiet
    addi x15, x0, 1950                # mulhsu's operand
    addi x16, x0, 1957                # mulhsu's operand
    addi x14, x0, 1964                # mulhsu's rd before (stale)
    .L122: auipc x17, %pcrel_hi(w2)   # sb's base -> w2
    lui x28, 32                       # sb's base -> w2 (quiet)
    lui x29, 33                       # sb's base -> w2 (quiet)
    lui x6, 34                        # sb's base -> w2 (quiet)
    addi x17, x17, %pcrel_lo(.L122)   # sb's base -> w2
    addi x18, x0, 2                   # sb's store data
    .L123: auipc x20, %pcrel_hi(w2)   # lhu's base -> w2
    lui x7, 35                        # lhu's base -> w2 (quiet)
    lui x28, 36                       # lhu's base -> w2 (quiet)
    lui x29, 37                       # lhu's base -> w2 (quiet)
    addi x20, x20, %pcrel_lo(.L123)   # lhu's base -> w2
    addi x19, x0, 1978                # lhu's rd before (stale)
    lui x6, 38                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 39                        # quiet
    lui x28, 40                       # quiet
    mulhsu x14, x15, x16              # s0 mulhsu: the busy unit s2 waits behind, d3 (struct)
    lui x29, 41                       # filler (gap)
    sb x18, 0(x17)                    # s1 sb: stores what s3 loads, d3 (mem)
    fence rw, rw                      # s2 fence: d3 behind the busy s0 (struct)
    lui x6, 42                        # filler (gap)
    lhu x19, 0(x20)                   # subject s3 lhu: loads what s1 stored, d3 (mem)
    lui x7, 43                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 44                       # quiet
    lui x29, 45                       # quiet
# block 4  shape/s3_ctrl01_ctrl02_raw12  s0=jalr s1=sra s2=mulh  e0=1 e1=2 e2=1
    lui x0, 4                         # block 4
    lui x6, 46                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 47                        # quiet
    lui x28, 48                       # quiet
    .L125: auipc x22, %pcrel_hi(.L124) # jalr's target -> .L124, the label after it
    lui x29, 49                       # jalr's target -> .L124, the label after it (quiet)
    lui x6, 50                        # jalr's target -> .L124, the label after it (quiet)
    lui x7, 51                        # jalr's target -> .L124, the label after it (quiet)
    addi x22, x22, %pcrel_lo(.L125)   # jalr's target -> .L124, the label after it
    addi x21, x0, 1985                # jalr's rd before (stale)
    addi x24, x0, 1992                # sra's operand: the identity delivers the value
    addi x25, x0, 0                   # sra's operand: the identity delivers the value
    addi x23, x0, 1999                # sra's rd before (stale)
    addi x27, x0, 2006                # mulh's operand
    addi x26, x0, 2013                # mulh's rd before (stale)
    lui x28, 52                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 53                       # quiet
    lui x6, 54                        # quiet
    jalr x21, 0(x22)                  # s0 jalr: the taken transfer, s1 d1 after it (ctrl); the taken transfer, s2 d2 after it (ctrl)
.L124:
    sra x23, x24, x25                 # s1 sra: d1 after the transfer s0 (ctrl); x23 -> s2 at rs1, d1
    mulh x26, x23, x27                # subject s2 mulh: d2 after the transfer s0 (ctrl); reads x23 from s1 at rs1, d1
    lui x7, 55                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 56                       # quiet
    lui x29, 57                       # quiet
# block 5  shape/s3_ctrl02_war01_war12  s0=bgeu s1=mulh s2=auipc  e0=3 e1=2 e2=1
    lui x0, 5                         # block 5
    lui x6, 58                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 59                        # quiet
    lui x28, 60                       # quiet
    addi x22, x0, 1336                # x22 = 1336
    addi x24, x0, 1343                # bgeu's operand
    addi x24, x0, 1336                # x24 = 1336
    addi x23, x0, 1357                # x23 = 1357
    addi x25, x0, 1371                # mulh's operand
    lui x29, 61                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 62                        # quiet
    lui x7, 63                        # quiet
    bgeu x22, x24, .L146              # s0 bgeu: the taken transfer, s2 d3 after it (ctrl); reads x22, which s1 writes at d2 (war)
.L146:
    lui x28, 64                       # filler (gap)
    mulh x22, x23, x25                # s1 mulh: writes x22, which s0 read, d2 (war); reads x23, which s2 writes at d1 (war)
    auipc x23, 74565                  # subject s2 auipc: d3 after the transfer s0 (ctrl); writes x23, which s1 read, d1 (war)
    lui x29, 65                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 66                        # quiet
    lui x7, 67                        # quiet
# block 6  shape/s3_ctrl12_raw12_struct02  s0=mulhsu s1=jalr s2=jalr  e0=1 e1=1 e2=2
    lui x0, 6                         # block 6
    lui x28, 68                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 69                       # quiet
    lui x6, 70                        # quiet
    addi x27, x0, 1392                # mulhsu's operand
    addi x3, x0, 1399                 # mulhsu's operand
    addi x26, x0, 1406                # mulhsu's rd before (stale)
    .L148: auipc x9, %pcrel_hi(.L147) # jalr's target -> .L147, the label after it
    lui x7, 71                        # jalr's target -> .L147, the label after it (quiet)
    lui x28, 72                       # jalr's target -> .L147, the label after it (quiet)
    lui x29, 73                       # jalr's target -> .L147, the label after it (quiet)
    addi x9, x9, %pcrel_lo(.L148)     # jalr's target -> .L147, the label after it
    addi x8, x0, 1413                 # jalr's rd before (stale)
    addi x10, x0, 1420                # jalr's rd before (stale)
    lui x6, 74                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 75                        # quiet
    lui x28, 76                       # quiet
    mulhsu x26, x27, x3               # s0 mulhsu: the busy unit s2 waits behind, d2 (struct)
    jalr x8, 0(x9)                    # s1 jalr: the taken transfer, s2 d1 after it (ctrl); x8 -> s2 at target, d1
.L147:
    jalr x10, 4(x8)                   # subject s2 jalr: d1 after the transfer s1 (ctrl); reads x8 from s1 at target, d1; d2 behind the busy s0 (struct)
    lui x29, 77                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 78                        # quiet
    lui x7, 79                        # quiet
# block 7  shape/s3_raw01_raw02_waw02  s0=lw s1=mulh s2=lw  e0=2 e1=3 e2=3
    lui x0, 7                         # block 7
    lui x28, 80                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 81                       # quiet
    lui x6, 82                        # quiet
    .L149: auipc x12, %pcrel_hi(w4)   # lw's base -> w4
    lui x7, 83                        # lw's base -> w4 (quiet)
    lui x28, 84                       # lw's base -> w4 (quiet)
    lui x29, 85                       # lw's base -> w4 (quiet)
    addi x12, x12, %pcrel_lo(.L149)   # lw's base -> w4
    addi x11, x0, 1434                # lw's rd before (stale)
    addi x14, x0, 1441                # mulh's operand
    addi x13, x0, 1448                # mulh's rd before (stale)
    lui x6, 86                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 87                        # quiet
    lui x28, 88                       # quiet
    lw x11, 0(x12)                    # s0 lw: x11 -> s1 at rs1, d2; x11 -> s2 at addr, d3; writes x11 before s2, d3 (waw)
    lui x29, 89                       # filler (gap)
    mulh x13, x11, x14                # s1 mulh: reads x11 from s0 at rs1, d2
    lw x11, 0(x11)                    # subject s2 lw: reads x11 from s0 at addr, d3; writes x11 after s0, d3 (waw)
    lui x6, 90                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 91                        # quiet
    lui x28, 92                       # quiet
# block 8  shape/s3_struct02_war02_waw01  s0=mulh s1=auipc s2=jal  e0=2 e1=2 e2=1
    lui x0, 8                         # block 8
    lui x29, 93                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 94                        # quiet
    lui x7, 95                        # quiet
    addi x10, x0, 1765                # x10 = 1765
    addi x12, x0, 1779                # mulh's operand
    addi x11, x0, 1772                # mulh's rd before (stale)
    addi x11, x0, 1793                # auipc's rd before (stale)
    lui x28, 96                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 97                       # quiet
    lui x6, 98                        # quiet
    mulh x11, x10, x12                # s0 mulh: the busy unit s2 waits behind, d2 (struct); reads x10, which s2 writes at d2 (war); writes x11 before s1, d1 (waw)
    auipc x11, 74565                  # s1 auipc: writes x11 after s0, d1 (waw)
    jal x10, .L163                    # subject s2 jal: d2 behind the busy s0 (struct); writes x10, which s0 read, d2 (war)
.L163:
    lui x7, 99                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 100                      # quiet
    lui x29, 101                      # quiet
# block 9  shape/s3_ctrl01_ctrl02_war13  s0=bne s1=mul s2=jalr s3=lui  e0=1 e1=2 e2=2
    lui x0, 9                         # block 9
    lui x6, 102                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 103                       # quiet
    lui x28, 104                      # quiet
    addi x8, x0, 752                  # bne's operand
    addi x9, x0, 759                  # bne's operand
    addi x8, x0, 1                    # x8 = 1
    addi x9, x0, 2                    # x9 = 2
    addi x3, x0, 766                  # x3 = 766
    addi x11, x0, 773                 # mul's operand
    addi x10, x0, 780                 # mul's rd before (stale)
    .L165: auipc x13, %pcrel_hi(.L164) # jalr's target -> .L164, the label after it
    lui x29, 105                      # jalr's target -> .L164, the label after it (quiet)
    lui x6, 106                       # jalr's target -> .L164, the label after it (quiet)
    lui x7, 107                       # jalr's target -> .L164, the label after it (quiet)
    addi x13, x13, %pcrel_lo(.L165)   # jalr's target -> .L164, the label after it
    addi x12, x0, 787                 # jalr's rd before (stale)
    lui x28, 108                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 109                      # quiet
    lui x6, 110                       # quiet
    bne x8, x9, .L166                 # s0 bne: the taken transfer, s1 d1 after it (ctrl); the taken transfer, s2 d2 after it (ctrl)
.L166:
    mul x10, x3, x11                  # s1 mul: d1 after the transfer s0 (ctrl); reads x3, which s3 writes at d2 (war)
    jalr x12, 0(x13)                  # s2 jalr: d2 after the transfer s0 (ctrl)
.L164:
    lui x3, 427618                    # subject s3 lui: writes x3, which s1 read, d2 (war)
    lui x7, 111                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 112                      # quiet
    lui x29, 113                      # quiet
# block 10  shape/s3_ctrl01_ctrl12_ctrl23  s0=jalr s1=jal s2=jalr s3=mul  e0=1 e1=1 e2=3
    lui x0, 10                        # block 10
    lui x6, 114                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 115                       # quiet
    lui x28, 116                      # quiet
    .L168: auipc x15, %pcrel_hi(.L167) # jalr's target -> .L167, the label after it
    lui x29, 117                      # jalr's target -> .L167, the label after it (quiet)
    lui x6, 118                       # jalr's target -> .L167, the label after it (quiet)
    lui x7, 119                       # jalr's target -> .L167, the label after it (quiet)
    addi x15, x15, %pcrel_lo(.L168)   # jalr's target -> .L167, the label after it
    addi x14, x0, 808                 # jalr's rd before (stale)
    addi x16, x0, 815                 # jal's rd before (stale)
    .L170: auipc x18, %pcrel_hi(.L169) # jalr's target -> .L169, the label after it
    lui x28, 120                      # jalr's target -> .L169, the label after it (quiet)
    lui x29, 121                      # jalr's target -> .L169, the label after it (quiet)
    lui x6, 122                       # jalr's target -> .L169, the label after it (quiet)
    addi x18, x18, %pcrel_lo(.L170)   # jalr's target -> .L169, the label after it
    addi x17, x0, 822                 # jalr's rd before (stale)
    addi x20, x0, 829                 # mul's operand
    addi x21, x0, 836                 # mul's operand
    addi x19, x0, 843                 # mul's rd before (stale)
    lui x7, 123                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 124                      # quiet
    lui x29, 125                      # quiet
    jalr x14, 0(x15)                  # s0 jalr: the taken transfer, s1 d1 after it (ctrl)
.L167:
    jal x16, .L171                    # s1 jal: d1 after the transfer s0 (ctrl); the taken transfer, s2 d1 after it (ctrl)
.L171:
    jalr x17, 0(x18)                  # s2 jalr: d1 after the transfer s1 (ctrl); the taken transfer, s3 d3 after it (ctrl)
.L169:
    lui x6, 126                       # filler (gap)
    lui x7, 127                       # filler (gap)
    mul x19, x20, x21                 # subject s3 mul: d3 after the transfer s2 (ctrl)
    lui x28, 128                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 129                      # quiet
    lui x6, 130                       # quiet
# block 11  shape/s3_ctrl01_struct12_waw23  s0=jal s1=mulhsu s2=lui s3=slti  e0=2 e1=3 e2=2
    lui x0, 11                        # block 11
    lui x7, 131                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 132                      # quiet
    lui x29, 133                      # quiet
    addi x22, x0, 850                 # jal's rd before (stale)
    addi x24, x0, 857                 # mulhsu's operand
    addi x25, x0, 864                 # mulhsu's operand
    addi x23, x0, 871                 # mulhsu's rd before (stale)
    addi x26, x0, 885                 # lui's rd before (stale)
    addi x27, x0, 906                 # slti's operand
    addi x26, x0, 899                 # slti's rd before (stale)
    lui x6, 134                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 135                       # quiet
    lui x28, 136                      # quiet
    jal x22, .L172                    # s0 jal: the taken transfer, s1 d2 after it (ctrl)
.L172:
    lui x29, 137                      # filler (gap)
    mulhsu x23, x24, x25              # s1 mulhsu: d2 after the transfer s0 (ctrl); the busy unit s2 waits behind, d3 (struct)
    lui x6, 138                       # filler (gap)
    lui x7, 139                       # filler (gap)
    lui x26, 913654                   # s2 lui: d3 behind the busy s1 (struct); writes x26 before s3, d2 (waw)
    lui x28, 140                      # filler (gap)
    slti x26, x27, 5                  # subject s3 slti: writes x26 after s2, d2 (waw)
    lui x29, 141                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 142                       # quiet
    lui x7, 143                       # quiet
# block 12  shape/s3_ctrl02_raw23_struct12  s0=jalr s1=mulhu s2=lui s3=sltiu  e0=2 e1=3 e2=1
    lui x0, 12                        # block 12
    lui x28, 144                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 145                      # quiet
    lui x6, 146                       # quiet
    .L350: auipc x11, %pcrel_hi(.L349) # jalr's target -> .L349, the label after it
    lui x7, 147                       # jalr's target -> .L349, the label after it (quiet)
    lui x28, 148                      # jalr's target -> .L349, the label after it (quiet)
    lui x29, 149                      # jalr's target -> .L349, the label after it (quiet)
    addi x11, x11, %pcrel_lo(.L350)   # jalr's target -> .L349, the label after it
    addi x10, x0, 845                 # jalr's rd before (stale)
    addi x13, x0, 852                 # mulhu's operand
    addi x14, x0, 859                 # mulhu's operand
    addi x12, x0, 866                 # mulhu's rd before (stale)
    addi x15, x0, 880                 # lui's rd before (stale)
    addi x16, x0, 887                 # sltiu's rd before (stale)
    lui x6, 150                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 151                       # quiet
    lui x28, 152                      # quiet
    jalr x10, 0(x11)                  # s0 jalr: the taken transfer, s2 d2 after it (ctrl)
.L349:
    mulhu x12, x13, x14               # s1 mulhu: the busy unit s2 waits behind, d1 (struct)
    lui x15, 524288                   # s2 lui: d2 after the transfer s0 (ctrl); d1 behind the busy s1 (struct); x15 -> s3 at rs1, d3
    lui x29, 153                      # filler (gap)
    lui x6, 154                       # filler (gap)
    sltiu x16, x15, 5                 # subject s3 sltiu: reads x15 from s2 at rs1, d3
    lui x7, 155                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 156                      # quiet
    lui x29, 157                      # quiet
# block 13  shape/s3_ctrl02_struct13_waw03  s0=jalr s1=mulh s2=fence s3=jalr  e0=2 e1=2 e2=3
    lui x0, 13                        # block 13
    lui x6, 158                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 159                       # quiet
    lui x28, 160                      # quiet
    .L352: auipc x18, %pcrel_hi(.L351) # jalr's target -> .L351, the label after it
    lui x29, 161                      # jalr's target -> .L351, the label after it (quiet)
    lui x6, 162                       # jalr's target -> .L351, the label after it (quiet)
    lui x7, 163                       # jalr's target -> .L351, the label after it (quiet)
    addi x18, x18, %pcrel_lo(.L352)   # jalr's target -> .L351, the label after it
    addi x17, x0, 901                 # jalr's rd before (stale)
    addi x20, x0, 908                 # mulh's operand
    addi x21, x0, 915                 # mulh's operand
    addi x19, x0, 922                 # mulh's rd before (stale)
    .L354: auipc x22, %pcrel_hi(.L353) # jalr's target -> .L353, the label after it
    lui x28, 164                      # jalr's target -> .L353, the label after it (quiet)
    lui x29, 165                      # jalr's target -> .L353, the label after it (quiet)
    lui x6, 166                       # jalr's target -> .L353, the label after it (quiet)
    addi x22, x22, %pcrel_lo(.L354)   # jalr's target -> .L353, the label after it
    addi x17, x0, 936                 # jalr's rd before (stale)
    lui x7, 167                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 168                      # quiet
    lui x29, 169                      # quiet
    jalr x17, 0(x18)                  # s0 jalr: the taken transfer, s2 d2 after it (ctrl); writes x17 before s3, d3 (waw)
.L351:
    mulh x19, x20, x21                # s1 mulh: the busy unit s3 waits behind, d2 (struct)
    fence rw, rw                      # s2 fence: d2 after the transfer s0 (ctrl)
    jalr x17, 0(x22)                  # subject s3 jalr: d2 behind the busy s1 (struct); writes x17 after s0, d3 (waw)
.L353:
    lui x6, 170                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 171                       # quiet
    lui x28, 172                      # quiet
# block 14  shape/s3_ctrl03_struct12_war01  s0=bgeu s1=mulhu s2=auipc s3=jalr  e0=3 e1=1 e2=1
    lui x0, 14                        # block 14
    lui x29, 173                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 174                       # quiet
    lui x7, 175                       # quiet
    addi x23, x0, 943                 # x23 = 943
    addi x24, x0, 950                 # bgeu's operand
    addi x24, x0, 943                 # x24 = 943
    addi x25, x0, 958                 # mulhu's operand: the identity delivers the value
    addi x26, x0, -1                  # mulhu's operand: the identity delivers the value
    addi x27, x0, 971                 # auipc's rd before (stale)
    .L356: auipc x8, %pcrel_hi(.L355) # jalr's target -> .L355, the label after it
    lui x28, 176                      # jalr's target -> .L355, the label after it (quiet)
    lui x29, 177                      # jalr's target -> .L355, the label after it (quiet)
    lui x6, 178                       # jalr's target -> .L355, the label after it (quiet)
    addi x8, x8, %pcrel_lo(.L356)     # jalr's target -> .L355, the label after it
    addi x3, x0, 978                  # jalr's rd before (stale)
    lui x7, 179                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 180                      # quiet
    lui x29, 181                      # quiet
    bgeu x23, x24, .L357              # s0 bgeu: the taken transfer, s3 d3 after it (ctrl); reads x23, which s1 writes at d1 (war)
.L357:
    mulhu x23, x25, x26               # s1 mulhu: writes x23, which s0 read, d1 (war); the busy unit s2 waits behind, d1 (struct)
    auipc x27, 74565                  # s2 auipc: d1 behind the busy s1 (struct)
    jalr x3, 0(x8)                    # subject s3 jalr: d3 after the transfer s0 (ctrl)
.L355:
    lui x6, 182                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 183                       # quiet
    lui x28, 184                      # quiet
# block 15  shape/s3_ctrl03_struct23_waw12  s0=jalr s1=sltu s2=mulh s3=mulh  e0=3 e1=1 e2=1
    lui x0, 15                        # block 15
    lui x29, 185                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 186                       # quiet
    lui x7, 187                       # quiet
    .L359: auipc x10, %pcrel_hi(.L358) # jalr's target -> .L358, the label after it
    lui x28, 188                      # jalr's target -> .L358, the label after it (quiet)
    lui x29, 189                      # jalr's target -> .L358, the label after it (quiet)
    lui x6, 190                       # jalr's target -> .L358, the label after it (quiet)
    addi x10, x10, %pcrel_lo(.L359)   # jalr's target -> .L358, the label after it
    addi x9, x0, 985                  # jalr's rd before (stale)
    addi x12, x0, 1006                # sltu's operand
    addi x13, x0, 1013                # sltu's operand
    addi x11, x0, 999                 # sltu's rd before (stale)
    addi x14, x0, 1034                # mulh's operand
    addi x15, x0, 1041                # mulh's operand
    addi x11, x0, 1027                # mulh's rd before (stale)
    addi x17, x0, 1048                # mulh's operand
    addi x18, x0, 1055                # mulh's operand
    addi x16, x0, 1062                # mulh's rd before (stale)
    lui x7, 191                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 192                      # quiet
    lui x29, 193                      # quiet
    jalr x9, 0(x10)                   # s0 jalr: the taken transfer, s3 d3 after it (ctrl)
.L358:
    sltu x11, x12, x13                # s1 sltu: writes x11 before s2, d1 (waw)
    mulh x11, x14, x15                # s2 mulh: writes x11 after s1, d1 (waw); the busy unit s3 waits behind, d1 (struct)
    mulh x16, x17, x18                # subject s3 mulh: d3 after the transfer s0 (ctrl); d1 behind the busy s2 (struct)
    lui x6, 194                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 195                       # quiet
    lui x28, 196                      # quiet
# block 16  shape/s3_ctrl12_struct03_waw13  s0=mulh s1=jal s2=jalr s3=mul  e0=1 e1=3 e2=2
    lui x0, 16                        # block 16
    lui x29, 197                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 198                       # quiet
    lui x7, 199                       # quiet
    addi x20, x0, 1069                # mulh's operand
    addi x21, x0, 1076                # mulh's operand
    addi x19, x0, 1083                # mulh's rd before (stale)
    addi x22, x0, 1097                # jal's rd before (stale)
    .L361: auipc x24, %pcrel_hi(.L360) # jalr's target -> .L360, the label after it
    lui x28, 200                      # jalr's target -> .L360, the label after it (quiet)
    lui x29, 201                      # jalr's target -> .L360, the label after it (quiet)
    lui x6, 202                       # jalr's target -> .L360, the label after it (quiet)
    addi x24, x24, %pcrel_lo(.L361)   # jalr's target -> .L360, the label after it
    addi x23, x0, 1104                # jalr's rd before (stale)
    addi x25, x0, 1111                # mul's operand: the identity delivers the value
    addi x26, x0, 1                   # mul's operand: the identity delivers the value
    addi x22, x0, 1118                # mul's rd before (stale)
    lui x7, 203                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 204                      # quiet
    lui x29, 205                      # quiet
    mulh x19, x20, x21                # s0 mulh: the busy unit s3 waits behind, d3 (struct)
    jal x22, .L362                    # s1 jal: the taken transfer, s2 d1 after it (ctrl); writes x22 before s3, d2 (waw)
.L362:
    jalr x23, 0(x24)                  # s2 jalr: d1 after the transfer s1 (ctrl)
.L360:
    mul x22, x25, x26                 # subject s3 mul: d3 behind the busy s0 (struct); writes x22 after s1, d2 (waw)
    lui x6, 206                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 207                       # quiet
    lui x28, 208                      # quiet
# block 17  shape/s3_ctrl13_struct02_waw23  s0=mulhsu s1=jal s2=lbu s3=andi  e0=3 e1=3 e2=1
    lui x0, 17                        # block 17
    lui x29, 209                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 210                       # quiet
    lui x7, 211                       # quiet
    addi x14, x0, 1181                # mulhsu's operand
    addi x15, x0, 1188                # mulhsu's operand
    addi x13, x0, 1195                # mulhsu's rd before (stale)
    addi x16, x0, 1202                # jal's rd before (stale)
    .L366: auipc x18, %pcrel_hi(w5)   # lbu's base -> w5
    lui x28, 212                      # lbu's base -> w5 (quiet)
    lui x29, 213                      # lbu's base -> w5 (quiet)
    lui x6, 214                       # lbu's base -> w5 (quiet)
    addi x18, x18, %pcrel_lo(.L366)   # lbu's base -> w5
    addi x17, x0, 1216                # lbu's rd before (stale)
    addi x19, x0, 1230                # andi's operand: the identity delivers the value
    addi x17, x0, 1237                # andi's rd before (stale)
    lui x7, 215                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 216                      # quiet
    lui x29, 217                      # quiet
    mulhsu x13, x14, x15              # s0 mulhsu: the busy unit s2 waits behind, d3 (struct)
    jal x16, .L367                    # s1 jal: the taken transfer, s3 d3 after it (ctrl)
.L367:
    lui x6, 218                       # filler (gap)
    lbu x17, 0(x18)                   # s2 lbu: d3 behind the busy s0 (struct); writes x17 before s3, d1 (waw)
    andi x17, x19, -1                 # subject s3 andi: d3 after the transfer s1 (ctrl); writes x17 after s2, d1 (waw)
    lui x7, 219                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 220                      # quiet
    lui x29, 221                      # quiet
# block 18  shape/s3_ctrl23_raw01_struct13  s0=lhu s1=mulhu s2=bne s3=sw  e0=1 e1=2 e2=3
    lui x0, 18                        # block 18
    lui x6, 222                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 223                       # quiet
    lui x28, 224                      # quiet
    .L368: auipc x21, %pcrel_hi(w6)   # lhu's base -> w6
    lui x29, 225                      # lhu's base -> w6 (quiet)
    lui x6, 226                       # lhu's base -> w6 (quiet)
    lui x7, 227                       # lhu's base -> w6 (quiet)
    addi x21, x21, %pcrel_lo(.L368)   # lhu's base -> w6
    addi x20, x0, 1251                # lhu's rd before (stale)
    addi x23, x0, 1265                # mulhu's operand
    addi x22, x0, 1272                # mulhu's rd before (stale)
    addi x24, x0, 1279                # bne's operand
    addi x25, x0, 1286                # bne's operand
    addi x24, x0, 1                   # x24 = 1
    addi x25, x0, 2                   # x25 = 2
    .L369: auipc x26, %pcrel_hi(w7)   # sw's base -> w7
    lui x28, 228                      # sw's base -> w7 (quiet)
    lui x29, 229                      # sw's base -> w7 (quiet)
    lui x6, 230                       # sw's base -> w7 (quiet)
    addi x26, x26, %pcrel_lo(.L369)   # sw's base -> w7
    addi x27, x0, 1                   # sw's store data
    lui x7, 231                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 232                      # quiet
    lui x29, 233                      # quiet
    lhu x20, 0(x21)                   # s0 lhu: x20 -> s1 at rs1, d2
    lui x6, 234                       # filler (gap)
    mulhu x22, x20, x23               # s1 mulhu: reads x20 from s0 at rs1, d2; the busy unit s3 waits behind, d3 (struct)
    lui x7, 235                       # filler (gap)
    bne x24, x25, .L370               # s2 bne: the taken transfer, s3 d1 after it (ctrl)
.L370:
    sw x27, 0(x26)                    # subject s3 sw: d1 after the transfer s2 (ctrl); d3 behind the busy s1 (struct)
    lui x28, 236                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 237                      # quiet
    lui x6, 238                       # quiet
# block 19  shape/s3_mem03_raw12_struct13  s0=sh s1=mulh s2=mul s3=lb  e0=3 e1=1 e2=2
    lui x0, 19                        # block 19
    lui x7, 239                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 240                      # quiet
    lui x29, 241                      # quiet
    .L499: auipc x12, %pcrel_hi(w8)   # sh's base -> w8
    lui x6, 242                       # sh's base -> w8 (quiet)
    lui x7, 243                       # sh's base -> w8 (quiet)
    lui x28, 244                      # sh's base -> w8 (quiet)
    addi x12, x12, %pcrel_lo(.L499)   # sh's base -> w8
    addi x13, x0, 1113                # sh's store data
    addi x15, x0, 1134                # mulh's operand
    addi x16, x0, 1141                # mulh's operand
    addi x14, x0, 1127                # mulh's rd before (stale)
    addi x18, x0, 1148                # mul's operand
    addi x17, x0, 1155                # mul's rd before (stale)
    .L500: auipc x20, %pcrel_hi(w8)   # lb's base -> w8
    lui x29, 245                      # lb's base -> w8 (quiet)
    lui x6, 246                       # lb's base -> w8 (quiet)
    lui x7, 247                       # lb's base -> w8 (quiet)
    addi x20, x20, %pcrel_lo(.L500)   # lb's base -> w8
    addi x19, x0, 1162                # lb's rd before (stale)
    lui x28, 248                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 249                      # quiet
    lui x6, 250                       # quiet
    sh x13, 0(x12)                    # s0 sh: stores what s3 loads, d3 (mem)
    mulh x14, x15, x16                # s1 mulh: x14 -> s2 at rs1, d1; the busy unit s3 waits behind, d2 (struct)
    mul x17, x14, x18                 # s2 mul: reads x14 from s1 at rs1, d1
    lb x19, 0(x20)                    # subject s3 lb: loads what s0 stored, d3 (mem); d2 behind the busy s1 (struct)
    lui x7, 251                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 252                      # quiet
    lui x29, 253                      # quiet
# block 20  shape/s3_mem13_struct02_struct03  s0=mulh s1=sw s2=sb s3=lb  e0=2 e1=2 e2=3
    lui x0, 20                        # block 20
    lui x6, 254                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 255                       # quiet
    lui x28, 256                      # quiet
    addi x13, x0, 1656                # mulh's operand
    addi x14, x0, 1663                # mulh's operand
    addi x12, x0, 1670                # mulh's rd before (stale)
    .L739: auipc x15, %pcrel_hi(w9)   # sw's base -> w9
    lui x29, 257                      # sw's base -> w9 (quiet)
    lui x6, 258                       # sw's base -> w9 (quiet)
    lui x7, 259                       # sw's base -> w9 (quiet)
    addi x15, x15, %pcrel_lo(.L739)   # sw's base -> w9
    addi x16, x0, -1                  # sw's store data
    .L740: auipc x17, %pcrel_hi(w10)  # sb's base -> w10
    lui x28, 260                      # sb's base -> w10 (quiet)
    lui x29, 261                      # sb's base -> w10 (quiet)
    lui x6, 262                       # sb's base -> w10 (quiet)
    addi x17, x17, %pcrel_lo(.L740)   # sb's base -> w10
    addi x18, x0, 1691                # sb's store data
    .L741: auipc x20, %pcrel_hi(w9)   # lb's base -> w9
    lui x7, 263                       # lb's base -> w9 (quiet)
    lui x28, 264                      # lb's base -> w9 (quiet)
    lui x29, 265                      # lb's base -> w9 (quiet)
    addi x20, x20, %pcrel_lo(.L741)   # lb's base -> w9
    addi x19, x0, 1698                # lb's rd before (stale)
    lui x6, 266                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 267                       # quiet
    lui x28, 268                      # quiet
    mulh x12, x13, x14                # s0 mulh: the busy unit s2 waits behind, d2 (struct); the busy unit s3 waits behind, d3 (struct)
    sw x16, 0(x15)                    # s1 sw: stores what s3 loads, d2 (mem)
    sb x18, 0(x17)                    # s2 sb: d2 behind the busy s0 (struct)
    lb x19, 0(x20)                    # subject s3 lb: loads what s1 stored, d2 (mem); d3 behind the busy s0 (struct)
    lui x29, 269                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 270                       # quiet
    lui x7, 271                       # quiet
# block 21  shape/s3_mem23_raw02_struct13  s0=sub s1=mulhu s2=sh s3=lb  e0=1 e1=3 e2=2
    lui x0, 21                        # block 21
    lui x28, 272                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 273                      # quiet
    lui x6, 274                       # quiet
    addi x15, x0, 363                 # sub's operand: the identity delivers the value
    addi x16, x0, 0                   # sub's operand: the identity delivers the value
    addi x14, x0, 370                 # sub's rd before (stale)
    addi x18, x0, 377                 # mulhu's operand
    addi x19, x0, 384                 # mulhu's operand
    addi x17, x0, 391                 # mulhu's rd before (stale)
    .L758: auipc x20, %pcrel_hi(w11)  # sh's base -> w11
    lui x7, 275                       # sh's base -> w11 (quiet)
    lui x28, 276                      # sh's base -> w11 (quiet)
    lui x29, 277                      # sh's base -> w11 (quiet)
    addi x20, x20, %pcrel_lo(.L758)   # sh's base -> w11
    .L759: auipc x22, %pcrel_hi(w11)  # lb's base -> w11
    lui x6, 278                       # lb's base -> w11 (quiet)
    lui x7, 279                       # lb's base -> w11 (quiet)
    lui x28, 280                      # lb's base -> w11 (quiet)
    addi x22, x22, %pcrel_lo(.L759)   # lb's base -> w11
    addi x21, x0, 405                 # lb's rd before (stale)
    lui x29, 281                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 282                       # quiet
    lui x7, 283                       # quiet
    sub x14, x15, x16                 # s0 sub: x14 -> s2 at data, d3
    lui x28, 284                      # filler (gap)
    mulhu x17, x18, x19               # s1 mulhu: the busy unit s3 waits behind, d2 (struct)
    sh x14, 0(x20)                    # s2 sh: reads x14 from s0 at data, d3; stores what s3 loads, d1 (mem)
    lb x21, 0(x22)                    # subject s3 lb: loads what s2 stored, d1 (mem); d2 behind the busy s1 (struct)
    lui x29, 285                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 286                       # quiet
    lui x7, 287                       # quiet
# block 22  shape/s3_mem23_struct01_waw03  s0=mulhu s1=jalr s2=sb s3=lb  e0=1 e1=1 e2=3
    lui x0, 22                        # block 22
    lui x28, 288                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 289                      # quiet
    lui x6, 290                       # quiet
    addi x24, x0, 413                 # mulhu's operand: the identity delivers the value
    addi x25, x0, -1                  # mulhu's operand: the identity delivers the value
    addi x23, x0, 419                 # mulhu's rd before (stale)
    .L761: auipc x27, %pcrel_hi(.L760) # jalr's target -> .L760, the label after it
    lui x7, 291                       # jalr's target -> .L760, the label after it (quiet)
    lui x28, 292                      # jalr's target -> .L760, the label after it (quiet)
    lui x29, 293                      # jalr's target -> .L760, the label after it (quiet)
    addi x27, x27, %pcrel_lo(.L761)   # jalr's target -> .L760, the label after it
    addi x26, x0, 426                 # jalr's rd before (stale)
    .L762: auipc x3, %pcrel_hi(w12)   # sb's base -> w12
    lui x6, 294                       # sb's base -> w12 (quiet)
    lui x7, 295                       # sb's base -> w12 (quiet)
    lui x28, 296                      # sb's base -> w12 (quiet)
    addi x3, x3, %pcrel_lo(.L762)     # sb's base -> w12
    addi x8, x0, 440                  # sb's store data
    .L763: auipc x9, %pcrel_hi(w12)   # lb's base -> w12
    lui x29, 297                      # lb's base -> w12 (quiet)
    lui x6, 298                       # lb's base -> w12 (quiet)
    lui x7, 299                       # lb's base -> w12 (quiet)
    addi x9, x9, %pcrel_lo(.L763)     # lb's base -> w12
    addi x23, x0, 454                 # lb's rd before (stale)
    lui x28, 300                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 301                      # quiet
    lui x6, 302                       # quiet
    mulhu x23, x24, x25               # s0 mulhu: the busy unit s1 waits behind, d1 (struct); writes x23 before s3, d3 (waw)
    jalr x26, 0(x27)                  # s1 jalr: d1 behind the busy s0 (struct)
.L760:
    sb x8, 0(x3)                      # s2 sb: stores what s3 loads, d1 (mem)
    lb x23, 0(x9)                     # subject s3 lb: loads what s2 stored, d1 (mem); writes x23 after s0, d3 (waw)
    lui x7, 303                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 304                      # quiet
    lui x29, 305                      # quiet
# block 23  shape/s3_raw01_raw02_waw03  s0=mul s1=mul s2=mulhsu s3=lb  e0=1 e1=2 e2=3
    lui x0, 23                        # block 23
    lui x6, 306                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 307                       # quiet
    lui x28, 308                      # quiet
    addi x11, x0, 461                 # mul's operand: the identity delivers the value
    addi x12, x0, 1                   # mul's operand: the identity delivers the value
    addi x10, x0, 468                 # mul's rd before (stale)
    addi x14, x0, 475                 # mul's operand
    addi x13, x0, 482                 # mul's rd before (stale)
    addi x16, x0, 489                 # mulhsu's operand
    addi x15, x0, 496                 # mulhsu's rd before (stale)
    .L764: auipc x17, %pcrel_hi(w13)  # lb's base -> w13
    lui x29, 309                      # lb's base -> w13 (quiet)
    lui x6, 310                       # lb's base -> w13 (quiet)
    lui x7, 311                       # lb's base -> w13 (quiet)
    addi x17, x17, %pcrel_lo(.L764)   # lb's base -> w13
    addi x10, x0, 510                 # lb's rd before (stale)
    lui x28, 312                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 313                      # quiet
    lui x6, 314                       # quiet
    mul x10, x11, x12                 # s0 mul: x10 -> s1 at rs1, d1; x10 -> s2 at rs1, d2; writes x10 before s3, d3 (waw)
    mul x13, x10, x14                 # s1 mul: reads x10 from s0 at rs1, d1
    mulhsu x15, x10, x16              # s2 mulhsu: reads x10 from s0 at rs1, d2
    lb x10, 0(x17)                    # subject s3 lb: writes x10 after s0, d3 (waw)
    lui x7, 315                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 316                      # quiet
    lui x29, 317                      # quiet
# block 24  shape/s3_raw01_raw12_waw13  s0=lui s1=mulhsu s2=sb s3=lbu  e0=2 e1=1 e2=2
    lui x0, 24                        # block 24
    lui x6, 318                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 319                       # quiet
    lui x28, 320                      # quiet
    addi x18, x0, 531                 # lui's rd before (stale)
    addi x20, x0, 538                 # mulhsu's operand
    addi x19, x0, 545                 # mulhsu's rd before (stale)
    .L765: auipc x21, %pcrel_hi(w14)  # sb's base -> w14
    lui x29, 321                      # sb's base -> w14 (quiet)
    lui x6, 322                       # sb's base -> w14 (quiet)
    lui x7, 323                       # sb's base -> w14 (quiet)
    addi x21, x21, %pcrel_lo(.L765)   # sb's base -> w14
    .L766: auipc x22, %pcrel_hi(w15)  # lbu's base -> w15
    lui x28, 324                      # lbu's base -> w15 (quiet)
    lui x29, 325                      # lbu's base -> w15 (quiet)
    lui x6, 326                       # lbu's base -> w15 (quiet)
    addi x22, x22, %pcrel_lo(.L766)   # lbu's base -> w15
    addi x19, x0, 566                 # lbu's rd before (stale)
    lui x7, 327                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 328                      # quiet
    lui x29, 329                      # quiet
    lui x18, 963283                   # s0 lui: x18 -> s1 at rs1, d2
    lui x6, 330                       # filler (gap)
    mulhsu x19, x18, x20              # s1 mulhsu: reads x18 from s0 at rs1, d2; x19 -> s2 at data, d1; writes x19 before s3, d2 (waw)
    sb x19, 0(x21)                    # s2 sb: reads x19 from s1 at data, d1
    lbu x19, 0(x22)                   # subject s3 lbu: writes x19 after s1, d2 (waw)
    lui x7, 331                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 332                      # quiet
    lui x29, 333                      # quiet
# block 25  shape/s3_raw03_raw12_waw13  s0=jal s1=jal s2=mul s3=lhu  e0=3 e1=1 e2=2
    lui x0, 25                        # block 25
    lui x6, 334                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 335                       # quiet
    lui x28, 336                      # quiet
    addi x23, x0, 580                 # jal's rd before (stale)
    addi x24, x0, 587                 # jal's rd before (stale)
    addi x26, x0, 594                 # mul's operand
    addi x25, x0, 601                 # mul's rd before (stale)
    addi x24, x0, 608                 # lhu's rd before (stale)
    lui x29, 337                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 338                       # quiet
    lui x7, 339                       # quiet
    jal x23, .L767                    # s0 jal: x23 -> s3 at addr, d3
.L767:
    jal x24, .L768                    # s1 jal: x24 -> s2 at rs1, d1; writes x24 before s3, d2 (waw)
.L768:
    mul x25, x24, x26                 # s2 mul: reads x24 from s1 at rs1, d1
    lhu x24, 0(x23)                   # subject s3 lhu: reads x23 from s0 at addr, d3; writes x24 after s1, d2 (waw)
    lui x28, 340                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 341                      # quiet
    lui x6, 342                       # quiet
# block 26  shape/s3_raw12_waw02_waw23  s0=mulhu s1=jal s2=sltu s3=mul  e0=1 e1=2 e2=2
    lui x0, 26                        # block 26
    lui x7, 343                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 344                      # quiet
    lui x29, 345                      # quiet
    addi x27, x0, 641                 # mulhu's operand: the identity delivers the value
    addi x3, x0, -1                   # mulhu's operand: the identity delivers the value
    addi x26, x0, 647                 # mulhu's rd before (stale)
    addi x8, x0, 654                  # jal's rd before (stale)
    addi x9, x0, 661                  # sltu's operand
    addi x26, x0, 668                 # sltu's rd before (stale)
    addi x10, x0, 675                 # mul's operand: the identity delivers the value
    addi x11, x0, 1                   # mul's operand: the identity delivers the value
    addi x26, x0, 682                 # mul's rd before (stale)
    lui x6, 346                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 347                       # quiet
    lui x28, 348                      # quiet
    mulhu x26, x27, x3                # s0 mulhu: writes x26 before s2, d2 (waw)
    jal x8, .L844                     # s1 jal: x8 -> s2 at rs1, d1
.L844:
    sltu x26, x8, x9                  # s2 sltu: reads x8 from s1 at rs1, d1; writes x26 after s0, d2 (waw); writes x26 before s3, d2 (waw)
    lui x29, 349                      # filler (gap)
    mul x26, x10, x11                 # subject s3 mul: writes x26 after s2, d2 (waw)
    lui x6, 350                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 351                       # quiet
    lui x28, 352                      # quiet
# block 27  shape/s3_raw13_struct02_waw02  s0=mulhu s1=jalr s2=mul s3=srl  e0=3 e1=2 e2=2
    lui x0, 27                        # block 27
    lui x29, 353                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 354                       # quiet
    lui x7, 355                       # quiet
    addi x13, x0, 690                 # mulhu's operand: the identity delivers the value
    addi x14, x0, -1                  # mulhu's operand: the identity delivers the value
    addi x12, x0, 696                 # mulhu's rd before (stale)
    .L846: auipc x16, %pcrel_hi(.L845) # jalr's target -> .L845, the label after it
    lui x28, 356                      # jalr's target -> .L845, the label after it (quiet)
    lui x29, 357                      # jalr's target -> .L845, the label after it (quiet)
    lui x6, 358                       # jalr's target -> .L845, the label after it (quiet)
    addi x16, x16, %pcrel_lo(.L846)   # jalr's target -> .L845, the label after it
    addi x15, x0, 703                 # jalr's rd before (stale)
    addi x17, x0, 710                 # mul's operand: the identity delivers the value
    addi x18, x0, 1                   # mul's operand: the identity delivers the value
    addi x12, x0, 717                 # mul's rd before (stale)
    addi x20, x0, 724                 # srl's operand
    addi x19, x0, 731                 # srl's rd before (stale)
    lui x7, 359                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 360                      # quiet
    lui x29, 361                      # quiet
    mulhu x12, x13, x14               # s0 mulhu: the busy unit s2 waits behind, d2 (struct); writes x12 before s2, d2 (waw)
    jalr x15, 0(x16)                  # s1 jalr: x15 -> s3 at rs1, d3
.L845:
    mul x12, x17, x18                 # s2 mul: d2 behind the busy s0 (struct); writes x12 after s0, d2 (waw)
    lui x6, 362                       # filler (gap)
    srl x19, x15, x20                 # subject s3 srl: reads x15 from s1 at rs1, d3
    lui x7, 363                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 364                      # quiet
    lui x29, 365                      # quiet
# block 28  shape/s3_raw13_war03_waw23  s0=sll s1=lhu s2=lhu s3=mulhu  e0=2 e1=3 e2=1
    lui x0, 28                        # block 28
    lui x6, 366                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 367                       # quiet
    lui x28, 368                      # quiet
    addi x21, x0, 738                 # x21 = 738
    addi x23, x0, 745                 # sll's operand
    addi x22, x0, 752                 # sll's rd before (stale)
    .L847: auipc x25, %pcrel_hi(w16)  # lhu's base -> w16
    lui x29, 369                      # lhu's base -> w16 (quiet)
    lui x6, 370                       # lhu's base -> w16 (quiet)
    lui x7, 371                       # lhu's base -> w16 (quiet)
    addi x25, x25, %pcrel_lo(.L847)   # lhu's base -> w16
    addi x24, x0, 766                 # lhu's rd before (stale)
    .L848: auipc x26, %pcrel_hi(w17)  # lhu's base -> w17
    lui x28, 372                      # lhu's base -> w17 (quiet)
    lui x29, 373                      # lhu's base -> w17 (quiet)
    lui x6, 374                       # lhu's base -> w17 (quiet)
    addi x26, x26, %pcrel_lo(.L848)   # lhu's base -> w17
    addi x27, x0, 801                 # mulhu's operand
    lui x7, 375                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 376                      # quiet
    lui x29, 377                      # quiet
    sll x22, x21, x23                 # s0 sll: reads x21, which s3 writes at d3 (war)
    lhu x24, 0(x25)                   # s1 lhu: x24 -> s3 at rs1, d2
    lhu x21, 0(x26)                   # s2 lhu: writes x21 before s3, d1 (waw)
    mulhu x21, x24, x27               # subject s3 mulhu: reads x24 from s1 at rs1, d2; writes x21, which s0 read, d3 (war); writes x21 after s2, d1 (waw)
    lui x6, 378                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 379                       # quiet
    lui x28, 380                      # quiet
# block 29  shape/s3_struct01_war02_war13  s0=mulh s1=lh s2=jal s3=lh  e0=2 e1=3 e2=3
    lui x0, 29                        # block 29
    lui x29, 381                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 382                       # quiet
    lui x7, 383                       # quiet
    addi x24, x0, 1312                # x24 = 1312
    addi x27, x0, 1319                # mulh's operand
    addi x26, x0, 1326                # mulh's rd before (stale)
    .L849: auipc x25, %pcrel_hi(w18)  # x25 -> w18
    lui x28, 384                      # x25 -> w18 (quiet)
    lui x29, 385                      # x25 -> w18 (quiet)
    lui x6, 386                       # x25 -> w18 (quiet)
    addi x25, x25, %pcrel_lo(.L849)   # x25 -> w18
    addi x3, x0, 1340                 # lh's rd before (stale)
    .L850: auipc x8, %pcrel_hi(w19)   # lh's base -> w19
    lui x7, 387                       # lh's base -> w19 (quiet)
    lui x28, 388                      # lh's base -> w19 (quiet)
    lui x29, 389                      # lh's base -> w19 (quiet)
    addi x8, x8, %pcrel_lo(.L850)     # lh's base -> w19
    lui x6, 390                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 391                       # quiet
    lui x28, 392                      # quiet
    mulh x26, x24, x27                # s0 mulh: the busy unit s1 waits behind, d2 (struct); reads x24, which s2 writes at d3 (war)
    lui x29, 393                      # filler (gap)
    lh x3, 0(x25)                     # s1 lh: d2 behind the busy s0 (struct); reads x25, which s3 writes at d3 (war)
    jal x24, .L851                    # s2 jal: writes x24, which s0 read, d3 (war)
.L851:
    lui x6, 394                       # filler (gap)
    lh x25, 0(x8)                     # subject s3 lh: writes x25, which s1 read, d3 (war)
    lui x7, 395                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 396                      # quiet
    lui x29, 397                      # quiet
# block 30  shape/s3_struct02_war12_waw13  s0=mulhu s1=jalr s2=jal s3=jalr  e0=3 e1=1 e2=2
    lui x0, 30                        # block 30
    lui x6, 398                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 399                       # quiet
    lui x28, 400                      # quiet
    addi x9, x0, 1718                 # mulhu's operand
    addi x10, x0, 1725                # mulhu's operand
    addi x8, x0, 1732                 # mulhu's rd before (stale)
    .L861: auipc x3, %pcrel_hi(.L860) # x3 -> .L860
    lui x29, 401                      # x3 -> .L860 (quiet)
    lui x6, 402                       # x3 -> .L860 (quiet)
    lui x7, 403                       # x3 -> .L860 (quiet)
    addi x3, x3, %pcrel_lo(.L861)     # x3 -> .L860
    addi x11, x0, 1746                # jalr's rd before (stale)
    .L863: auipc x12, %pcrel_hi(.L862) # jalr's target -> .L862, the label after it
    lui x28, 404                      # jalr's target -> .L862, the label after it (quiet)
    lui x29, 405                      # jalr's target -> .L862, the label after it (quiet)
    lui x6, 406                       # jalr's target -> .L862, the label after it (quiet)
    addi x12, x12, %pcrel_lo(.L863)   # jalr's target -> .L862, the label after it
    addi x11, x0, 1774                # jalr's rd before (stale)
    lui x7, 407                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 408                      # quiet
    lui x29, 409                      # quiet
    mulhu x8, x9, x10                 # s0 mulhu: the busy unit s2 waits behind, d3 (struct)
    lui x6, 410                       # filler (gap)
    jalr x11, 0(x3)                   # s1 jalr: reads x3, which s2 writes at d1 (war); writes x11 before s3, d2 (waw)
.L860:
    jal x3, .L864                     # s2 jal: d3 behind the busy s0 (struct); writes x3, which s1 read, d1 (war)
.L864:
    jalr x11, 0(x12)                  # subject s3 jalr: writes x11 after s1, d2 (waw)
.L862:
    lui x7, 411                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 412                      # quiet
    lui x29, 413                      # quiet
# block 31  shape/s3_struct03_war12_waw01  s0=mulhu s1=sltu s2=jalr s3=lui  e0=3 e1=1 e2=1
    lui x0, 31                        # block 31
    lui x6, 414                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 415                       # quiet
    lui x28, 416                      # quiet
    addi x15, x0, 1782                # mulhu's operand: the identity delivers the value
    addi x16, x0, -1                  # mulhu's operand: the identity delivers the value
    addi x14, x0, 1788                # mulhu's rd before (stale)
    addi x13, x0, 1802                # x13 = 1802
    addi x17, x0, 1816                # sltu's operand
    addi x14, x0, 1809                # sltu's rd before (stale)
    .L866: auipc x18, %pcrel_hi(.L865) # jalr's target -> .L865, the label after it
    lui x29, 417                      # jalr's target -> .L865, the label after it (quiet)
    lui x6, 418                       # jalr's target -> .L865, the label after it (quiet)
    lui x7, 419                       # jalr's target -> .L865, the label after it (quiet)
    addi x18, x18, %pcrel_lo(.L866)   # jalr's target -> .L865, the label after it
    addi x19, x0, 1837                # lui's rd before (stale)
    lui x28, 420                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 421                      # quiet
    lui x6, 422                       # quiet
    mulhu x14, x15, x16               # s0 mulhu: the busy unit s3 waits behind, d3 (struct); writes x14 before s1, d1 (waw)
    sltu x14, x13, x17                # s1 sltu: writes x14 after s0, d1 (waw); reads x13, which s2 writes at d1 (war)
    jalr x13, 0(x18)                  # s2 jalr: writes x13, which s1 read, d1 (war)
.L865:
    lui x19, 74565                    # subject s3 lui: d3 behind the busy s0 (struct)
    lui x7, 423                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 424                      # quiet
    lui x29, 425                      # quiet
# block 32  shape/s3_struct13_war23_waw02  s0=mulhsu s1=mulh s2=slti s3=jalr  e0=2 e1=1 e2=3
    lui x0, 32                        # block 32
    lui x6, 426                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 427                       # quiet
    lui x28, 428                      # quiet
    addi x13, x0, 1007                # mulhsu's operand: the identity delivers the value
    addi x14, x0, -1                  # mulhsu's operand: the identity delivers the value
    addi x12, x0, 1013                # mulhsu's rd before (stale)
    addi x16, x0, 1020                # mulh's operand
    addi x17, x0, 1027                # mulh's operand
    addi x15, x0, 1034                # mulh's rd before (stale)
    addi x11, x0, 1048                # x11 = 1048
    addi x12, x0, 1055                # slti's rd before (stale)
    .L878: auipc x18, %pcrel_hi(.L877) # jalr's target -> .L877, the label after it
    lui x29, 429                      # jalr's target -> .L877, the label after it (quiet)
    lui x6, 430                       # jalr's target -> .L877, the label after it (quiet)
    lui x7, 431                       # jalr's target -> .L877, the label after it (quiet)
    addi x18, x18, %pcrel_lo(.L878)   # jalr's target -> .L877, the label after it
    lui x28, 432                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 433                      # quiet
    lui x6, 434                       # quiet
    mulhsu x12, x13, x14              # s0 mulhsu: writes x12 before s2, d3 (waw)
    lui x7, 435                       # filler (gap)
    mulh x15, x16, x17                # s1 mulh: the busy unit s3 waits behind, d2 (struct)
    slti x12, x11, 5                  # s2 slti: writes x12 after s0, d3 (waw); reads x11, which s3 writes at d1 (war)
    jalr x11, 0(x18)                  # subject s3 jalr: d2 behind the busy s1 (struct); writes x11, which s2 read, d1 (war)
.L877:
    lui x28, 436                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 437                      # quiet
    lui x6, 438                       # quiet
# block 33  shape/s3_ctrl01_mem23_war14  s0=jalr s1=mul s2=sb s3=lhu s4=lw  e0=3 e1=1 e2=3
    lui x0, 33                        # block 33
    lui x7, 439                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 440                      # quiet
    lui x29, 441                      # quiet
    .L880: auipc x14, %pcrel_hi(.L879) # jalr's target -> .L879, the label after it
    lui x6, 442                       # jalr's target -> .L879, the label after it (quiet)
    lui x7, 443                       # jalr's target -> .L879, the label after it (quiet)
    lui x28, 444                      # jalr's target -> .L879, the label after it (quiet)
    addi x14, x14, %pcrel_lo(.L880)   # jalr's target -> .L879, the label after it
    addi x13, x0, 1636                # jalr's rd before (stale)
    addi x12, x0, 1643                # x12 = 1643
    addi x16, x0, 1650                # mul's operand
    addi x15, x0, 1657                # mul's rd before (stale)
    .L881: auipc x17, %pcrel_hi(w20)  # sb's base -> w20
    lui x29, 445                      # sb's base -> w20 (quiet)
    lui x6, 446                       # sb's base -> w20 (quiet)
    lui x7, 447                       # sb's base -> w20 (quiet)
    addi x17, x17, %pcrel_lo(.L881)   # sb's base -> w20
    addi x18, x0, 1671                # sb's store data
    .L882: auipc x20, %pcrel_hi(w20)  # lhu's base -> w20
    lui x28, 448                      # lhu's base -> w20 (quiet)
    lui x29, 449                      # lhu's base -> w20 (quiet)
    lui x6, 450                       # lhu's base -> w20 (quiet)
    addi x20, x20, %pcrel_lo(.L882)   # lhu's base -> w20
    addi x19, x0, 1678                # lhu's rd before (stale)
    .L883: auipc x21, %pcrel_hi(w21)  # lw's base -> w21
    lui x7, 451                       # lw's base -> w21 (quiet)
    lui x28, 452                      # lw's base -> w21 (quiet)
    lui x29, 453                      # lw's base -> w21 (quiet)
    addi x21, x21, %pcrel_lo(.L883)   # lw's base -> w21
    lui x6, 454                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 455                       # quiet
    lui x28, 456                      # quiet
    jalr x13, 0(x14)                  # s0 jalr: the taken transfer, s1 d3 after it (ctrl)
.L879:
    lui x29, 457                      # filler (gap)
    lui x6, 458                       # filler (gap)
    mul x15, x12, x16                 # s1 mul: d3 after the transfer s0 (ctrl); reads x12, which s4 writes at d3 (war)
    sb x18, 0(x17)                    # s2 sb: stores what s3 loads, d1 (mem)
    lhu x19, 0(x20)                   # s3 lhu: loads what s2 stored, d1 (mem)
    lw x12, 0(x21)                    # subject s4 lw: writes x12, which s1 read, d3 (war)
    lui x7, 459                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 460                      # quiet
    lui x29, 461                      # quiet
# block 34  shape/s3_ctrl02_war14_waw13  s0=jal s1=slt s2=sw s3=mulhu s4=lbu  e0=3 e1=3 e2=2
    lui x0, 34                        # block 34
    lui x6, 462                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 463                       # quiet
    lui x28, 464                      # quiet
    addi x20, x0, 1853                # jal's rd before (stale)
    addi x19, x0, 1867                # x19 = 1867
    addi x22, x0, 1881                # slt's operand
    addi x21, x0, 1874                # slt's rd before (stale)
    .L890: auipc x23, %pcrel_hi(w22)  # sw's base -> w22
    lui x29, 465                      # sw's base -> w22 (quiet)
    lui x6, 466                       # sw's base -> w22 (quiet)
    lui x7, 467                       # sw's base -> w22 (quiet)
    addi x23, x23, %pcrel_lo(.L890)   # sw's base -> w22
    addi x24, x0, 1895                # sw's store data
    addi x25, x0, 1903                # mulhu's operand: the identity delivers the value
    addi x26, x0, -1                  # mulhu's operand: the identity delivers the value
    addi x21, x0, 1909                # mulhu's rd before (stale)
    .L891: auipc x27, %pcrel_hi(w23)  # lbu's base -> w23
    lui x28, 468                      # lbu's base -> w23 (quiet)
    lui x29, 469                      # lbu's base -> w23 (quiet)
    lui x6, 470                       # lbu's base -> w23 (quiet)
    addi x27, x27, %pcrel_lo(.L891)   # lbu's base -> w23
    lui x7, 471                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 472                      # quiet
    lui x29, 473                      # quiet
    jal x20, .L892                    # s0 jal: the taken transfer, s2 d3 after it (ctrl)
.L892:
    lui x6, 474                       # filler (gap)
    slt x21, x19, x22                 # s1 slt: reads x19, which s4 writes at d3 (war); writes x21 before s3, d2 (waw)
    sw x24, 0(x23)                    # s2 sw: d3 after the transfer s0 (ctrl)
    mulhu x21, x25, x26               # s3 mulhu: writes x21 after s1, d2 (waw)
    lbu x19, 0(x27)                   # subject s4 lbu: writes x19, which s1 read, d3 (war)
    lui x7, 475                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 476                      # quiet
    lui x29, 477                      # quiet
# block 35  shape/s3_ctrl03_mem24_struct14  s0=jalr s1=mulhu s2=sh s3=xori s4=lbu  e0=3 e1=2 e2=3
    lui x0, 35                        # block 35
    lui x6, 478                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 479                       # quiet
    lui x28, 480                      # quiet
    .L894: auipc x8, %pcrel_hi(.L893) # jalr's target -> .L893, the label after it
    lui x29, 481                      # jalr's target -> .L893, the label after it (quiet)
    lui x6, 482                       # jalr's target -> .L893, the label after it (quiet)
    lui x7, 483                       # jalr's target -> .L893, the label after it (quiet)
    addi x8, x8, %pcrel_lo(.L894)     # jalr's target -> .L893, the label after it
    addi x3, x0, 1937                 # jalr's rd before (stale)
    addi x10, x0, 1944                # mulhu's operand
    addi x11, x0, 1951                # mulhu's operand
    addi x9, x0, 1958                 # mulhu's rd before (stale)
    .L895: auipc x12, %pcrel_hi(w24)  # sh's base -> w24
    lui x28, 484                      # sh's base -> w24 (quiet)
    lui x29, 485                      # sh's base -> w24 (quiet)
    lui x6, 486                       # sh's base -> w24 (quiet)
    addi x12, x12, %pcrel_lo(.L895)   # sh's base -> w24
    addi x13, x0, 1972                # sh's store data
    addi x15, x0, 1979                # xori's operand
    addi x14, x0, 1986                # xori's rd before (stale)
    .L896: auipc x17, %pcrel_hi(w24)  # lbu's base -> w24
    lui x7, 487                       # lbu's base -> w24 (quiet)
    lui x28, 488                      # lbu's base -> w24 (quiet)
    lui x29, 489                      # lbu's base -> w24 (quiet)
    addi x17, x17, %pcrel_lo(.L896)   # lbu's base -> w24
    addi x16, x0, 1993                # lbu's rd before (stale)
    lui x6, 490                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 491                       # quiet
    lui x28, 492                      # quiet
    jalr x3, 0(x8)                    # s0 jalr: the taken transfer, s3 d3 after it (ctrl)
.L893:
    mulhu x9, x10, x11                # s1 mulhu: the busy unit s4 waits behind, d3 (struct)
    sh x13, 0(x12)                    # s2 sh: stores what s4 loads, d2 (mem)
    xori x14, x15, 0                  # s3 xori: d3 after the transfer s0 (ctrl)
    lbu x16, 0(x17)                   # subject s4 lbu: loads what s2 stored, d2 (mem); d3 behind the busy s1 (struct)
    lui x29, 493                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 494                       # quiet
    lui x7, 495                       # quiet
# block 36  shape/s3_ctrl03_raw24_war13  s0=jal s1=and s2=mul s3=lbu s4=jalr  e0=3 e1=3 e2=2
    lui x0, 36                        # block 36
    lui x28, 496                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 497                      # quiet
    lui x6, 498                       # quiet
    addi x19, x0, 2000                # jal's rd before (stale)
    addi x18, x0, 2007                # x18 = 2007
    addi x21, x0, 2014                # and's operand
    addi x20, x0, 2021                # and's rd before (stale)
    .L898: auipc x23, %pcrel_hi(.L897) # mul's operand: the identity delivers the value
    lui x7, 499                       # mul's operand: the identity delivers the value (quiet)
    lui x28, 500                      # mul's operand: the identity delivers the value (quiet)
    lui x29, 501                      # mul's operand: the identity delivers the value (quiet)
    addi x23, x23, %pcrel_lo(.L898)   # mul's operand: the identity delivers the value
    addi x24, x0, 1                   # mul's operand: the identity delivers the value
    addi x22, x0, 2028                # mul's rd before (stale)
    .L899: auipc x25, %pcrel_hi(w25)  # lbu's base -> w25
    lui x6, 502                       # lbu's base -> w25 (quiet)
    lui x7, 503                       # lbu's base -> w25 (quiet)
    lui x28, 504                      # lbu's base -> w25 (quiet)
    addi x25, x25, %pcrel_lo(.L899)   # lbu's base -> w25
    addi x26, x0, 280                 # jalr's rd before (stale)
    lui x29, 505                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 506                       # quiet
    lui x7, 507                       # quiet
    jal x19, .L900                    # s0 jal: the taken transfer, s3 d3 after it (ctrl)
.L900:
    and x20, x18, x21                 # s1 and: reads x18, which s3 writes at d2 (war)
    mul x22, x23, x24                 # s2 mul: x22 -> s4 at target, d3
    lbu x18, 0(x25)                   # s3 lbu: d3 after the transfer s0 (ctrl); writes x18, which s1 read, d2 (war)
    lui x28, 508                      # filler (gap)
    jalr x26, 0(x22)                  # subject s4 jalr: reads x22 from s2 at target, d3
.L897:
    lui x29, 509                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 510                       # quiet
    lui x7, 511                       # quiet
# block 37  shape/s3_ctrl03_struct24_war12  s0=jalr s1=sra s2=mulh s3=sra s4=fence  e0=3 e1=3 e2=1
    lui x0, 37                        # block 37
    lui x28, 512                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 513                      # quiet
    lui x6, 514                       # quiet
    .L902: auipc x8, %pcrel_hi(.L901) # jalr's target -> .L901, the label after it
    lui x7, 515                       # jalr's target -> .L901, the label after it (quiet)
    lui x28, 516                      # jalr's target -> .L901, the label after it (quiet)
    lui x29, 517                      # jalr's target -> .L901, the label after it (quiet)
    addi x8, x8, %pcrel_lo(.L902)     # jalr's target -> .L901, the label after it
    addi x3, x0, 287                  # jalr's rd before (stale)
    addi x27, x0, 294                 # x27 = 294
    addi x10, x0, 301                 # sra's operand
    addi x9, x0, 308                  # sra's rd before (stale)
    addi x11, x0, 329                 # mulh's operand
    addi x12, x0, 336                 # mulh's operand
    addi x14, x0, 343                 # sra's operand
    addi x15, x0, 350                 # sra's operand
    addi x13, x0, 357                 # sra's rd before (stale)
    lui x6, 518                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 519                       # quiet
    lui x28, 520                      # quiet
    jalr x3, 0(x8)                    # s0 jalr: the taken transfer, s3 d3 after it (ctrl)
.L901:
    sra x9, x27, x10                  # s1 sra: reads x27, which s2 writes at d1 (war)
    mulh x27, x11, x12                # s2 mulh: writes x27, which s1 read, d1 (war); the busy unit s4 waits behind, d3 (struct)
    sra x13, x14, x15                 # s3 sra: d3 after the transfer s0 (ctrl)
    lui x29, 521                      # filler (gap)
    fence rw, rw                      # subject s4 fence: d3 behind the busy s2 (struct)
    lui x6, 522                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 523                       # quiet
    lui x28, 524                      # quiet
# block 38  shape/s3_ctrl12_ctrl14_mem03  s0=sw s1=jalr s2=mul s3=lbu s4=addi  e0=1 e1=3 e2=3
    lui x0, 38                        # block 38
    lui x29, 525                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 526                       # quiet
    lui x7, 527                       # quiet
    .L903: auipc x16, %pcrel_hi(w26)  # sw's base -> w26
    lui x28, 528                      # sw's base -> w26 (quiet)
    lui x29, 529                      # sw's base -> w26 (quiet)
    lui x6, 530                       # sw's base -> w26 (quiet)
    addi x16, x16, %pcrel_lo(.L903)   # sw's base -> w26
    addi x17, x0, 2                   # sw's store data
    .L905: auipc x19, %pcrel_hi(.L904) # jalr's target -> .L904, the label after it
    lui x7, 531                       # jalr's target -> .L904, the label after it (quiet)
    lui x28, 532                      # jalr's target -> .L904, the label after it (quiet)
    lui x29, 533                      # jalr's target -> .L904, the label after it (quiet)
    addi x19, x19, %pcrel_lo(.L905)   # jalr's target -> .L904, the label after it
    addi x18, x0, 371                 # jalr's rd before (stale)
    addi x21, x0, 378                 # mul's operand
    addi x22, x0, 385                 # mul's operand
    addi x20, x0, 392                 # mul's rd before (stale)
    .L906: auipc x24, %pcrel_hi(w26)  # lbu's base -> w26
    lui x6, 534                       # lbu's base -> w26 (quiet)
    lui x7, 535                       # lbu's base -> w26 (quiet)
    lui x28, 536                      # lbu's base -> w26 (quiet)
    addi x24, x24, %pcrel_lo(.L906)   # lbu's base -> w26
    addi x23, x0, 399                 # lbu's rd before (stale)
    addi x26, x0, 406                 # addi's operand
    addi x25, x0, 413                 # addi's rd before (stale)
    lui x29, 537                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 538                       # quiet
    lui x7, 539                       # quiet
    sw x17, 0(x16)                    # s0 sw: stores what s3 loads, d3 (mem)
    jalr x18, 0(x19)                  # s1 jalr: the taken transfer, s2 d1 after it (ctrl); the taken transfer, s4 d3 after it (ctrl)
.L904:
    mul x20, x21, x22                 # s2 mul: d1 after the transfer s1 (ctrl)
    lbu x23, 0(x24)                   # s3 lbu: loads what s0 stored, d3 (mem)
    addi x25, x26, 0                  # subject s4 addi: d3 after the transfer s1 (ctrl)
    lui x28, 540                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 541                      # quiet
    lui x6, 542                       # quiet
# block 39  shape/s3_ctrl12_mem03_waw34  s0=sw s1=jalr s2=mul s3=lbu s4=slli  e0=1 e1=3 e2=2
    lui x0, 39                        # block 39
    lui x7, 543                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 544                      # quiet
    lui x29, 545                      # quiet
    .L907: auipc x27, %pcrel_hi(w27)  # sw's base -> w27
    lui x6, 546                       # sw's base -> w27 (quiet)
    lui x7, 547                       # sw's base -> w27 (quiet)
    lui x28, 548                      # sw's base -> w27 (quiet)
    addi x27, x27, %pcrel_lo(.L907)   # sw's base -> w27
    addi x3, x0, 427                  # sw's store data
    .L909: auipc x9, %pcrel_hi(.L908) # jalr's target -> .L908, the label after it
    lui x29, 549                      # jalr's target -> .L908, the label after it (quiet)
    lui x6, 550                       # jalr's target -> .L908, the label after it (quiet)
    lui x7, 551                       # jalr's target -> .L908, the label after it (quiet)
    addi x9, x9, %pcrel_lo(.L909)     # jalr's target -> .L908, the label after it
    addi x8, x0, 434                  # jalr's rd before (stale)
    addi x11, x0, 441                 # mul's operand
    addi x12, x0, 448                 # mul's operand
    addi x10, x0, 455                 # mul's rd before (stale)
    .L910: auipc x14, %pcrel_hi(w27)  # lbu's base -> w27
    lui x28, 552                      # lbu's base -> w27 (quiet)
    lui x29, 553                      # lbu's base -> w27 (quiet)
    lui x6, 554                       # lbu's base -> w27 (quiet)
    addi x14, x14, %pcrel_lo(.L910)   # lbu's base -> w27
    addi x13, x0, 469                 # lbu's rd before (stale)
    addi x15, x0, 476                 # slli's operand: the identity delivers the value
    addi x13, x0, 483                 # slli's rd before (stale)
    lui x7, 555                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 556                      # quiet
    lui x29, 557                      # quiet
    sw x3, 0(x27)                     # s0 sw: stores what s3 loads, d3 (mem)
    jalr x8, 0(x9)                    # s1 jalr: the taken transfer, s2 d1 after it (ctrl)
.L908:
    mul x10, x11, x12                 # s2 mul: d1 after the transfer s1 (ctrl)
    lbu x13, 0(x14)                   # s3 lbu: loads what s0 stored, d3 (mem); writes x13 before s4, d2 (waw)
    lui x6, 558                       # filler (gap)
    slli x13, x15, 0                  # subject s4 slli: writes x13 after s3, d2 (waw)
    lui x7, 559                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 560                      # quiet
    lui x29, 561                      # quiet
# block 40  shape/s3_ctrl12_raw03_raw14  s0=jalr s1=jalr s2=mul s3=addi s4=jalr  e0=1 e1=3 e2=3
    lui x0, 40                        # block 40
    lui x6, 562                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 563                       # quiet
    lui x28, 564                      # quiet
    .L912: auipc x17, %pcrel_hi(.L911) # jalr's target -> .L911, the label after it
    lui x29, 565                      # jalr's target -> .L911, the label after it (quiet)
    lui x6, 566                       # jalr's target -> .L911, the label after it (quiet)
    lui x7, 567                       # jalr's target -> .L911, the label after it (quiet)
    addi x17, x17, %pcrel_lo(.L912)   # jalr's target -> .L911, the label after it
    addi x16, x0, 490                 # jalr's rd before (stale)
    .L914: auipc x19, %pcrel_hi(.L913) # jalr's target -> .L913, the label after it
    lui x28, 568                      # jalr's target -> .L913, the label after it (quiet)
    lui x29, 569                      # jalr's target -> .L913, the label after it (quiet)
    lui x6, 570                       # jalr's target -> .L913, the label after it (quiet)
    addi x19, x19, %pcrel_lo(.L914)   # jalr's target -> .L913, the label after it
    addi x18, x0, 497                 # jalr's rd before (stale)
    addi x21, x0, 504                 # mul's operand
    addi x22, x0, 511                 # mul's operand
    addi x20, x0, 518                 # mul's rd before (stale)
    addi x23, x0, 525                 # addi's rd before (stale)
    addi x24, x0, 532                 # jalr's rd before (stale)
    lui x7, 571                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 572                      # quiet
    lui x29, 573                      # quiet
    jalr x16, 0(x17)                  # s0 jalr: x16 -> s3 at rs1, d3
.L911:
    jalr x18, 0(x19)                  # s1 jalr: the taken transfer, s2 d1 after it (ctrl); x18 -> s4 at target, d3
.L913:
    mul x20, x21, x22                 # s2 mul: d1 after the transfer s1 (ctrl)
    addi x23, x16, 0                  # s3 addi: reads x16 from s0 at rs1, d3
    jalr x24, 12(x18)                 # subject s4 jalr: reads x18 from s1 at target, d3
    lui x6, 574                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 575                       # quiet
    lui x28, 576                      # quiet
# block 41  shape/s3_ctrl13_mem24_raw02  s0=mul s1=jal s2=sw s3=add s4=lw  e0=3 e1=3 e2=2
    lui x0, 41                        # block 41
    lui x29, 577                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 578                       # quiet
    lui x7, 579                       # quiet
    addi x26, x0, 539                 # mul's operand: the identity delivers the value
    addi x27, x0, 1                   # mul's operand: the identity delivers the value
    addi x25, x0, 546                 # mul's rd before (stale)
    addi x3, x0, 553                  # jal's rd before (stale)
    .L915: auipc x8, %pcrel_hi(w28)   # sw's base -> w28
    lui x28, 580                      # sw's base -> w28 (quiet)
    lui x29, 581                      # sw's base -> w28 (quiet)
    lui x6, 582                       # sw's base -> w28 (quiet)
    addi x8, x8, %pcrel_lo(.L915)     # sw's base -> w28
    addi x10, x0, 567                 # add's operand
    addi x11, x0, 574                 # add's operand
    addi x9, x0, 581                  # add's rd before (stale)
    .L916: auipc x13, %pcrel_hi(w28)  # lw's base -> w28
    lui x7, 583                       # lw's base -> w28 (quiet)
    lui x28, 584                      # lw's base -> w28 (quiet)
    lui x29, 585                      # lw's base -> w28 (quiet)
    addi x13, x13, %pcrel_lo(.L916)   # lw's base -> w28
    addi x12, x0, 588                 # lw's rd before (stale)
    lui x6, 586                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 587                       # quiet
    lui x28, 588                      # quiet
    mul x25, x26, x27                 # s0 mul: x25 -> s2 at data, d2
    jal x3, .L917                     # s1 jal: the taken transfer, s3 d3 after it (ctrl)
.L917:
    sw x25, 0(x8)                     # s2 sw: reads x25 from s0 at data, d2; stores what s4 loads, d3 (mem)
    lui x29, 589                      # filler (gap)
    add x9, x10, x11                  # s3 add: d3 after the transfer s1 (ctrl)
    lw x12, 0(x13)                    # subject s4 lw: loads what s2 stored, d3 (mem)
    lui x6, 590                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 591                       # quiet
    lui x28, 592                      # quiet
# block 42  shape/s3_ctrl13_war02_waw14  s0=mul s1=jal s2=srl s3=sh s4=lh  e0=2 e1=3 e2=3
    lui x0, 42                        # block 42
    lui x29, 593                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 594                       # quiet
    lui x7, 595                       # quiet
    addi x14, x0, 595                 # x14 = 595
    addi x16, x0, 602                 # mul's operand
    addi x15, x0, 609                 # mul's rd before (stale)
    addi x17, x0, 623                 # jal's rd before (stale)
    addi x18, x0, 630                 # srl's operand: the identity delivers the value
    addi x19, x0, 0                   # srl's operand: the identity delivers the value
    .L918: auipc x20, %pcrel_hi(w29)  # sh's base -> w29
    lui x28, 596                      # sh's base -> w29 (quiet)
    lui x29, 597                      # sh's base -> w29 (quiet)
    lui x6, 598                       # sh's base -> w29 (quiet)
    addi x20, x20, %pcrel_lo(.L918)   # sh's base -> w29
    addi x21, x0, 651                 # sh's store data
    .L919: auipc x22, %pcrel_hi(w30)  # lh's base -> w30
    lui x7, 599                       # lh's base -> w30 (quiet)
    lui x28, 600                      # lh's base -> w30 (quiet)
    lui x29, 601                      # lh's base -> w30 (quiet)
    addi x22, x22, %pcrel_lo(.L919)   # lh's base -> w30
    addi x17, x0, 665                 # lh's rd before (stale)
    lui x6, 602                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 603                       # quiet
    lui x28, 604                      # quiet
    mul x15, x14, x16                 # s0 mul: reads x14, which s2 writes at d3 (war)
    lui x29, 605                      # filler (gap)
    jal x17, .L920                    # s1 jal: the taken transfer, s3 d2 after it (ctrl); writes x17 before s4, d3 (waw)
.L920:
    srl x14, x18, x19                 # s2 srl: writes x14, which s0 read, d3 (war)
    sh x21, 0(x20)                    # s3 sh: d2 after the transfer s1 (ctrl)
    lh x17, 0(x22)                    # subject s4 lh: writes x17 after s1, d3 (waw)
    lui x6, 606                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 607                       # quiet
    lui x28, 608                      # quiet
# block 43  shape/s3_ctrl24_struct01_war13  s0=mulhsu s1=mul s2=bltu s3=auipc s4=fence  e0=3 e1=2 e2=3
    lui x0, 43                        # block 43
    lui x29, 609                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 610                       # quiet
    lui x7, 611                       # quiet
    addi x25, x0, 679                 # mulhsu's operand
    addi x26, x0, 686                 # mulhsu's operand
    addi x24, x0, 693                 # mulhsu's rd before (stale)
    addi x23, x0, 700                 # x23 = 700
    addi x3, x0, 707                  # mul's operand
    addi x27, x0, 714                 # mul's rd before (stale)
    addi x8, x0, 721                  # bltu's operand
    addi x9, x0, 728                  # bltu's operand
    addi x8, x0, 1                    # x8 = 1
    addi x9, x0, 2                    # x9 = 2
    lui x28, 612                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 613                      # quiet
    lui x6, 614                       # quiet
    mulhsu x24, x25, x26              # s0 mulhsu: the busy unit s1 waits behind, d2 (struct)
    lui x7, 615                       # filler (gap)
    mul x27, x23, x3                  # s1 mul: d2 behind the busy s0 (struct); reads x23, which s3 writes at d3 (war)
    bltu x8, x9, .L921                # s2 bltu: the taken transfer, s4 d3 after it (ctrl)
.L921:
    lui x28, 616                      # filler (gap)
    auipc x23, 74565                  # s3 auipc: writes x23, which s1 read, d3 (war)
    fence rw, rw                      # subject s4 fence: d3 after the transfer s2 (ctrl)
    lui x29, 617                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 618                       # quiet
    lui x7, 619                       # quiet
# block 44  shape/s3_mem01_raw24_waw13  s0=sb s1=lhu s2=mul s3=xor s4=lw  e0=3 e1=3 e2=2
    lui x0, 44                        # block 44
    lui x28, 620                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 621                      # quiet
    lui x6, 622                       # quiet
    .L922: auipc x10, %pcrel_hi(w31)  # sb's base -> w31
    lui x7, 623                       # sb's base -> w31 (quiet)
    lui x28, 624                      # sb's base -> w31 (quiet)
    lui x29, 625                      # sb's base -> w31 (quiet)
    addi x10, x10, %pcrel_lo(.L922)   # sb's base -> w31
    addi x11, x0, 756                 # sb's store data
    .L923: auipc x13, %pcrel_hi(w31)  # lhu's base -> w31
    lui x6, 626                       # lhu's base -> w31 (quiet)
    lui x7, 627                       # lhu's base -> w31 (quiet)
    lui x28, 628                      # lhu's base -> w31 (quiet)
    addi x13, x13, %pcrel_lo(.L923)   # lhu's base -> w31
    addi x12, x0, 770                 # lhu's rd before (stale)
    .L924: auipc x15, %pcrel_hi(w32)  # mul's operand: the identity delivers the value
    lui x29, 629                      # mul's operand: the identity delivers the value (quiet)
    lui x6, 630                       # mul's operand: the identity delivers the value (quiet)
    lui x7, 631                       # mul's operand: the identity delivers the value (quiet)
    addi x15, x15, %pcrel_lo(.L924)   # mul's operand: the identity delivers the value
    addi x16, x0, 1                   # mul's operand: the identity delivers the value
    addi x14, x0, 784                 # mul's rd before (stale)
    addi x17, x0, 791                 # xor's operand: the identity delivers the value
    addi x18, x0, 0                   # xor's operand: the identity delivers the value
    addi x12, x0, 798                 # xor's rd before (stale)
    addi x19, x0, 805                 # lw's rd before (stale)
    lui x28, 632                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 633                      # quiet
    lui x6, 634                       # quiet
    sb x11, 0(x10)                    # s0 sb: stores what s1 loads, d3 (mem)
    lui x7, 635                       # filler (gap)
    lui x28, 636                      # filler (gap)
    lhu x12, 0(x13)                   # s1 lhu: loads what s0 stored, d3 (mem); writes x12 before s3, d2 (waw)
    mul x14, x15, x16                 # s2 mul: x14 -> s4 at addr, d3
    xor x12, x17, x18                 # s3 xor: writes x12 after s1, d2 (waw)
    lui x29, 637                      # filler (gap)
    lw x19, 0(x14)                    # subject s4 lw: reads x14 from s2 at addr, d3
    lui x6, 638                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 639                       # quiet
    lui x28, 640                      # quiet
# block 45  shape/s3_mem01_war03_waw24  s0=sh s1=lhu s2=jalr s3=mul s4=lui  e0=1 e1=3 e2=3
    lui x0, 45                        # block 45
    lui x29, 641                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 642                       # quiet
    lui x7, 643                       # quiet
    addi x20, x0, 819                 # x20 = 819
    .L925: auipc x21, %pcrel_hi(w33)  # sh's base -> w33
    lui x28, 644                      # sh's base -> w33 (quiet)
    lui x29, 645                      # sh's base -> w33 (quiet)
    lui x6, 646                       # sh's base -> w33 (quiet)
    addi x21, x21, %pcrel_lo(.L925)   # sh's base -> w33
    .L926: auipc x23, %pcrel_hi(w33)  # lhu's base -> w33
    lui x7, 647                       # lhu's base -> w33 (quiet)
    lui x28, 648                      # lhu's base -> w33 (quiet)
    lui x29, 649                      # lhu's base -> w33 (quiet)
    addi x23, x23, %pcrel_lo(.L926)   # lhu's base -> w33
    addi x22, x0, 826                 # lhu's rd before (stale)
    .L928: auipc x25, %pcrel_hi(.L927) # jalr's target -> .L927, the label after it
    lui x6, 650                       # jalr's target -> .L927, the label after it (quiet)
    lui x7, 651                       # jalr's target -> .L927, the label after it (quiet)
    lui x28, 652                      # jalr's target -> .L927, the label after it (quiet)
    addi x25, x25, %pcrel_lo(.L928)   # jalr's target -> .L927, the label after it
    addi x24, x0, 840                 # jalr's rd before (stale)
    addi x26, x0, 847                 # mul's operand: the identity delivers the value
    addi x27, x0, 1                   # mul's operand: the identity delivers the value
    addi x24, x0, 868                 # lui's rd before (stale)
    lui x29, 653                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 654                       # quiet
    lui x7, 655                       # quiet
    sh x20, 0(x21)                    # s0 sh: stores what s1 loads, d1 (mem); reads x20, which s3 writes at d3 (war)
    lhu x22, 0(x23)                   # s1 lhu: loads what s0 stored, d1 (mem)
    jalr x24, 0(x25)                  # s2 jalr: writes x24 before s4, d3 (waw)
.L927:
    mul x20, x26, x27                 # s3 mul: writes x20, which s0 read, d3 (war)
    lui x28, 656                      # filler (gap)
    lui x24, 1                        # subject s4 lui: writes x24 after s2, d3 (waw)
    lui x29, 657                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 658                       # quiet
    lui x7, 659                       # quiet
# block 46  shape/s3_mem03_war24_waw13  s0=sh s1=lb s2=mul s3=lb s4=jalr  e0=3 e1=2 e2=2
    lui x0, 46                        # block 46
    lui x28, 660                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 661                      # quiet
    lui x6, 662                       # quiet
    .L964: auipc x8, %pcrel_hi(w34)   # sh's base -> w34
    lui x7, 663                       # sh's base -> w34 (quiet)
    lui x28, 664                      # sh's base -> w34 (quiet)
    lui x29, 665                      # sh's base -> w34 (quiet)
    addi x8, x8, %pcrel_lo(.L964)     # sh's base -> w34
    addi x9, x0, 1456                 # sh's store data
    .L965: auipc x11, %pcrel_hi(w35)  # lb's base -> w35
    lui x6, 666                       # lb's base -> w35 (quiet)
    lui x7, 667                       # lb's base -> w35 (quiet)
    lui x28, 668                      # lb's base -> w35 (quiet)
    addi x11, x11, %pcrel_lo(.L965)   # lb's base -> w35
    addi x10, x0, 1470                # lb's rd before (stale)
    addi x3, x0, 1484                 # x3 = 1484
    addi x13, x0, 1491                # mul's operand
    addi x12, x0, 1498                # mul's rd before (stale)
    .L966: auipc x14, %pcrel_hi(w34)  # lb's base -> w34
    lui x29, 669                      # lb's base -> w34 (quiet)
    lui x6, 670                       # lb's base -> w34 (quiet)
    lui x7, 671                       # lb's base -> w34 (quiet)
    addi x14, x14, %pcrel_lo(.L966)   # lb's base -> w34
    addi x10, x0, 1512                # lb's rd before (stale)
    .L968: auipc x15, %pcrel_hi(.L967) # jalr's target -> .L967, the label after it
    lui x28, 672                      # jalr's target -> .L967, the label after it (quiet)
    lui x29, 673                      # jalr's target -> .L967, the label after it (quiet)
    lui x6, 674                       # jalr's target -> .L967, the label after it (quiet)
    addi x15, x15, %pcrel_lo(.L968)   # jalr's target -> .L967, the label after it
    lui x7, 675                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 676                      # quiet
    lui x29, 677                      # quiet
    sh x9, 0(x8)                      # s0 sh: stores what s3 loads, d3 (mem)
    lb x10, 0(x11)                    # s1 lb: writes x10 before s3, d2 (waw)
    mul x12, x3, x13                  # s2 mul: reads x3, which s4 writes at d2 (war)
    lb x10, 0(x14)                    # s3 lb: loads what s0 stored, d3 (mem); writes x10 after s1, d2 (waw)
    jalr x3, 0(x15)                   # subject s4 jalr: writes x3, which s2 read, d2 (war)
.L967:
    lui x6, 678                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 679                       # quiet
    lui x28, 680                      # quiet
# block 47  shape/s3_mem12_waw03_waw34  s0=jalr s1=sw s2=lbu s3=jal s4=mulh  e0=1 e1=3 e2=3
    lui x0, 47                        # block 47
    lui x29, 681                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 682                       # quiet
    lui x7, 683                       # quiet
    .L970: auipc x17, %pcrel_hi(.L969) # jalr's target -> .L969, the label after it
    lui x28, 684                      # jalr's target -> .L969, the label after it (quiet)
    lui x29, 685                      # jalr's target -> .L969, the label after it (quiet)
    lui x6, 686                       # jalr's target -> .L969, the label after it (quiet)
    addi x17, x17, %pcrel_lo(.L970)   # jalr's target -> .L969, the label after it
    addi x16, x0, 1540                # jalr's rd before (stale)
    .L971: auipc x18, %pcrel_hi(w36)  # sw's base -> w36
    lui x7, 687                       # sw's base -> w36 (quiet)
    lui x28, 688                      # sw's base -> w36 (quiet)
    lui x29, 689                      # sw's base -> w36 (quiet)
    addi x18, x18, %pcrel_lo(.L971)   # sw's base -> w36
    addi x19, x0, 1554                # sw's store data
    .L972: auipc x21, %pcrel_hi(w36)  # lbu's base -> w36
    lui x6, 690                       # lbu's base -> w36 (quiet)
    lui x7, 691                       # lbu's base -> w36 (quiet)
    lui x28, 692                      # lbu's base -> w36 (quiet)
    addi x21, x21, %pcrel_lo(.L972)   # lbu's base -> w36
    addi x20, x0, 1561                # lbu's rd before (stale)
    addi x16, x0, 1575                # jal's rd before (stale)
    addi x22, x0, 1596                # mulh's operand
    addi x23, x0, 1603                # mulh's operand
    addi x16, x0, 1589                # mulh's rd before (stale)
    lui x29, 693                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 694                       # quiet
    lui x7, 695                       # quiet
    jalr x16, 0(x17)                  # s0 jalr: writes x16 before s3, d3 (waw)
.L969:
    sw x19, 0(x18)                    # s1 sw: stores what s2 loads, d1 (mem)
    lbu x20, 0(x21)                   # s2 lbu: loads what s1 stored, d1 (mem)
    jal x16, .L973                    # s3 jal: writes x16 after s0, d3 (waw); writes x16 before s4, d3 (waw)
.L973:
    lui x28, 696                      # filler (gap)
    lui x29, 697                      # filler (gap)
    mulh x16, x22, x23                # subject s4 mulh: writes x16 after s3, d3 (waw)
    lui x6, 698                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 699                       # quiet
    lui x28, 700                      # quiet
# block 48  shape/s3_mem34_struct02_waw14  s0=mulhsu s1=srai s2=mulhsu s3=sb s4=lbu  e0=1 e1=2 e2=3
    lui x0, 48                        # block 48
    lui x29, 701                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 702                       # quiet
    lui x7, 703                       # quiet
    addi x8, x0, 295                  # mulhsu's operand
    addi x9, x0, 302                  # mulhsu's operand
    addi x3, x0, 309                  # mulhsu's rd before (stale)
    addi x11, x0, 316                 # srai's operand: the identity delivers the value
    addi x10, x0, 323                 # srai's rd before (stale)
    addi x13, x0, 330                 # mulhsu's operand
    addi x14, x0, 337                 # mulhsu's operand
    addi x12, x0, 344                 # mulhsu's rd before (stale)
    .L1189: auipc x15, %pcrel_hi(w37) # sb's base -> w37
    lui x28, 704                      # sb's base -> w37 (quiet)
    lui x29, 705                      # sb's base -> w37 (quiet)
    lui x6, 706                       # sb's base -> w37 (quiet)
    addi x15, x15, %pcrel_lo(.L1189)  # sb's base -> w37
    addi x16, x0, 358                 # sb's store data
    .L1190: auipc x17, %pcrel_hi(w37) # lbu's base -> w37
    lui x7, 707                       # lbu's base -> w37 (quiet)
    lui x28, 708                      # lbu's base -> w37 (quiet)
    lui x29, 709                      # lbu's base -> w37 (quiet)
    addi x17, x17, %pcrel_lo(.L1190)  # lbu's base -> w37
    addi x10, x0, 372                 # lbu's rd before (stale)
    lui x6, 710                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 711                       # quiet
    lui x28, 712                      # quiet
    mulhsu x3, x8, x9                 # s0 mulhsu: the busy unit s2 waits behind, d2 (struct)
    srai x10, x11, 0                  # s1 srai: writes x10 before s4, d3 (waw)
    mulhsu x12, x13, x14              # s2 mulhsu: d2 behind the busy s0 (struct)
    sb x16, 0(x15)                    # s3 sb: stores what s4 loads, d1 (mem)
    lbu x10, 0(x17)                   # subject s4 lbu: loads what s3 stored, d1 (mem); writes x10 after s1, d3 (waw)
    lui x29, 713                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 714                       # quiet
    lui x7, 715                       # quiet
# block 49  shape/s3_raw01_war23_waw14  s0=jalr s1=jalr s2=mulhsu s3=lbu s4=srli  e0=1 e1=1 e2=3
    lui x0, 49                        # block 49
    lui x28, 716                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 717                      # quiet
    lui x6, 718                       # quiet
    .L1192: auipc x20, %pcrel_hi(.L1191) # jalr's target -> .L1191, the label after it
    lui x7, 719                       # jalr's target -> .L1191, the label after it (quiet)
    lui x28, 720                      # jalr's target -> .L1191, the label after it (quiet)
    lui x29, 721                      # jalr's target -> .L1191, the label after it (quiet)
    addi x20, x20, %pcrel_lo(.L1192)  # jalr's target -> .L1191, the label after it
    addi x19, x0, 379                 # jalr's rd before (stale)
    addi x21, x0, 386                 # jalr's rd before (stale)
    addi x18, x0, 393                 # x18 = 393
    addi x23, x0, 400                 # mulhsu's operand
    addi x22, x0, 407                 # mulhsu's rd before (stale)
    .L1193: auipc x24, %pcrel_hi(w38) # lbu's base -> w38
    lui x6, 722                       # lbu's base -> w38 (quiet)
    lui x7, 723                       # lbu's base -> w38 (quiet)
    lui x28, 724                      # lbu's base -> w38 (quiet)
    addi x24, x24, %pcrel_lo(.L1193)  # lbu's base -> w38
    addi x25, x0, 435                 # srli's operand: the identity delivers the value
    addi x21, x0, 442                 # srli's rd before (stale)
    lui x29, 725                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 726                       # quiet
    lui x7, 727                       # quiet
    jalr x19, 0(x20)                  # s0 jalr: x19 -> s1 at target, d1
.L1191:
    jalr x21, 4(x19)                  # s1 jalr: reads x19 from s0 at target, d1; writes x21 before s4, d3 (waw)
    mulhsu x22, x18, x23              # s2 mulhsu: reads x18, which s3 writes at d1 (war)
    lbu x18, 0(x24)                   # s3 lbu: writes x18, which s2 read, d1 (war)
    srli x21, x25, 0                  # subject s4 srli: writes x21 after s1, d3 (waw)
    lui x28, 728                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 729                      # quiet
    lui x6, 730                       # quiet
# block 50  shape/s3_raw02_struct34_waw14  s0=auipc s1=jal s2=addi s3=mulh s4=lw  e0=2 e1=1 e2=3
    lui x0, 50                        # block 50
    lui x7, 731                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 732                      # quiet
    lui x29, 733                      # quiet
    addi x11, x0, 792                 # auipc's rd before (stale)
    addi x12, x0, 806                 # jal's rd before (stale)
    addi x13, x0, 813                 # addi's rd before (stale)
    addi x15, x0, 820                 # mulh's operand
    addi x16, x0, 827                 # mulh's operand
    addi x14, x0, 834                 # mulh's rd before (stale)
    .L1202: auipc x17, %pcrel_hi(w39) # lw's base -> w39
    lui x6, 734                       # lw's base -> w39 (quiet)
    lui x7, 735                       # lw's base -> w39 (quiet)
    lui x28, 736                      # lw's base -> w39 (quiet)
    addi x17, x17, %pcrel_lo(.L1202)  # lw's base -> w39
    addi x12, x0, 848                 # lw's rd before (stale)
    lui x29, 737                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 738                       # quiet
    lui x7, 739                       # quiet
    auipc x11, 74565                  # s0 auipc: x11 -> s2 at rs1, d2
    jal x12, .L1203                   # s1 jal: writes x12 before s4, d3 (waw)
.L1203:
    addi x13, x11, 0                  # s2 addi: reads x11 from s0 at rs1, d2
    mulh x14, x15, x16                # s3 mulh: the busy unit s4 waits behind, d1 (struct)
    lw x12, 0(x17)                    # subject s4 lw: d1 behind the busy s3 (struct); writes x12 after s1, d3 (waw)
    lui x28, 740                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 741                      # quiet
    lui x6, 742                       # quiet
# block 51  shape/s3_raw03_war14_war23  s0=mul s1=bltu s2=bltu s3=lhu s4=slti  e0=3 e1=3 e2=1
    lui x0, 51                        # block 51
    lui x7, 743                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 744                      # quiet
    lui x29, 745                      # quiet
    .L1228: auipc x15, %pcrel_hi(w40) # mul's operand: the identity delivers the value
    lui x6, 746                       # mul's operand: the identity delivers the value (quiet)
    lui x7, 747                       # mul's operand: the identity delivers the value (quiet)
    lui x28, 748                      # mul's operand: the identity delivers the value (quiet)
    addi x15, x15, %pcrel_lo(.L1228)  # mul's operand: the identity delivers the value
    addi x16, x0, 1                   # mul's operand: the identity delivers the value
    addi x14, x0, 1597                # mul's rd before (stale)
    addi x12, x0, 1604                # x12 = 1604
    addi x17, x0, 1611                # bltu's operand
    addi x13, x0, 1618                # x13 = 1618
    addi x18, x0, 1625                # bltu's operand
    addi x19, x0, 1646                # slti's operand
    lui x29, 749                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 750                       # quiet
    lui x7, 751                       # quiet
    mul x14, x15, x16                 # s0 mul: x14 -> s3 at addr, d3
    bltu x12, x17, .L1229             # s1 bltu: reads x12, which s4 writes at d3 (war)
.L1229:
    bltu x13, x18, .L1230             # s2 bltu: reads x13, which s3 writes at d1 (war)
.L1230:
    lhu x13, 0(x14)                   # s3 lhu: reads x14 from s0 at addr, d3; writes x13, which s2 read, d1 (war)
    slti x12, x19, 5                  # subject s4 slti: writes x12, which s1 read, d3 (war)
    lui x28, 752                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 753                      # quiet
    lui x6, 754                       # quiet
# block 52  shape/s3_raw14_struct13_waw02  s0=mul s1=mulhsu s2=jalr s3=jal s4=lbu  e0=3 e1=2 e2=2
    lui x0, 52                        # block 52
    lui x7, 755                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 756                      # quiet
    lui x29, 757                      # quiet
    addi x21, x0, 1653                # mul's operand: the identity delivers the value
    addi x22, x0, 1                   # mul's operand: the identity delivers the value
    addi x20, x0, 1660                # mul's rd before (stale)
    .L1231: auipc x24, %pcrel_hi(w41) # mulhsu's operand: the identity delivers the value
    lui x6, 758                       # mulhsu's operand: the identity delivers the value (quiet)
    lui x7, 759                       # mulhsu's operand: the identity delivers the value (quiet)
    lui x28, 760                      # mulhsu's operand: the identity delivers the value (quiet)
    addi x24, x24, %pcrel_lo(.L1231)  # mulhsu's operand: the identity delivers the value
    addi x25, x0, -1                  # mulhsu's operand: the identity delivers the value
    addi x23, x0, 1674                # mulhsu's rd before (stale)
    .L1233: auipc x26, %pcrel_hi(.L1232) # jalr's target -> .L1232, the label after it
    lui x29, 761                      # jalr's target -> .L1232, the label after it (quiet)
    lui x6, 762                       # jalr's target -> .L1232, the label after it (quiet)
    lui x7, 763                       # jalr's target -> .L1232, the label after it (quiet)
    addi x26, x26, %pcrel_lo(.L1233)  # jalr's target -> .L1232, the label after it
    addi x20, x0, 1688                # jalr's rd before (stale)
    addi x27, x0, 1695                # jal's rd before (stale)
    addi x3, x0, 1702                 # lbu's rd before (stale)
    lui x28, 764                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 765                      # quiet
    lui x6, 766                       # quiet
    mul x20, x21, x22                 # s0 mul: writes x20 before s2, d2 (waw)
    mulhsu x23, x24, x25              # s1 mulhsu: x23 -> s4 at addr, d3; the busy unit s3 waits behind, d2 (struct)
    jalr x20, 0(x26)                  # s2 jalr: writes x20 after s0, d2 (waw)
.L1232:
    jal x27, .L1234                   # s3 jal: d2 behind the busy s1 (struct)
.L1234:
    lbu x3, 0(x23)                    # subject s4 lbu: reads x23 from s1 at addr, d3
    lui x7, 767                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 768                      # quiet
    lui x29, 769                      # quiet
# block 53  shape/s3_raw24_struct13_war02  s0=sh s1=mulhsu s2=lhu s3=mulhsu s4=sh  e0=2 e1=2 e2=2
    lui x0, 53                        # block 53
    lui x6, 770                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 771                       # quiet
    lui x28, 772                      # quiet
    addi x8, x0, 1709                 # x8 = 1709
    .L1235: auipc x9, %pcrel_hi(w42)  # sh's base -> w42
    lui x29, 773                      # sh's base -> w42 (quiet)
    lui x6, 774                       # sh's base -> w42 (quiet)
    lui x7, 775                       # sh's base -> w42 (quiet)
    addi x9, x9, %pcrel_lo(.L1235)    # sh's base -> w42
    addi x11, x0, 1723                # mulhsu's operand
    addi x12, x0, 1730                # mulhsu's operand
    addi x10, x0, 1737                # mulhsu's rd before (stale)
    .L1236: auipc x13, %pcrel_hi(w43) # lhu's base -> w43
    lui x28, 776                      # lhu's base -> w43 (quiet)
    lui x29, 777                      # lhu's base -> w43 (quiet)
    lui x6, 778                       # lhu's base -> w43 (quiet)
    addi x13, x13, %pcrel_lo(.L1236)  # lhu's base -> w43
    addi x15, x0, 1765                # mulhsu's operand
    addi x16, x0, 1772                # mulhsu's operand
    addi x14, x0, 1779                # mulhsu's rd before (stale)
    .L1237: auipc x17, %pcrel_hi(w44) # sh's base -> w44
    lui x7, 779                       # sh's base -> w44 (quiet)
    lui x28, 780                      # sh's base -> w44 (quiet)
    lui x29, 781                      # sh's base -> w44 (quiet)
    addi x17, x17, %pcrel_lo(.L1237)  # sh's base -> w44
    lui x6, 782                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 783                       # quiet
    lui x28, 784                      # quiet
    sh x8, 0(x9)                      # s0 sh: reads x8, which s2 writes at d2 (war)
    mulhsu x10, x11, x12              # s1 mulhsu: the busy unit s3 waits behind, d2 (struct)
    lhu x8, 0(x13)                    # s2 lhu: writes x8, which s0 read, d2 (war); x8 -> s4 at data, d2
    mulhsu x14, x15, x16              # s3 mulhsu: d2 behind the busy s1 (struct)
    sh x8, 0(x17)                     # subject s4 sh: reads x8 from s2 at data, d2
    lui x29, 785                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 786                       # quiet
    lui x7, 787                       # quiet
# block 54  shape/s3_struct03_war24_waw01  s0=mulhsu s1=jal s2=mulh s3=blt s4=addi  e0=3 e1=2 e2=1
    lui x0, 54                        # block 54
    lui x28, 788                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 789                      # quiet
    lui x6, 790                       # quiet
    addi x20, x0, 1794                # mulhsu's operand: the identity delivers the value
    addi x21, x0, -1                  # mulhsu's operand: the identity delivers the value
    addi x19, x0, 1800                # mulhsu's rd before (stale)
    addi x19, x0, 1814                # jal's rd before (stale)
    addi x18, x0, 1821                # x18 = 1821
    addi x23, x0, 1828                # mulh's operand
    addi x22, x0, 1835                # mulh's rd before (stale)
    addi x24, x0, 1842                # blt's operand
    addi x25, x0, 1849                # blt's operand
    addi x26, x0, 1856                # addi's operand: the identity delivers the value
    lui x7, 791                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 792                      # quiet
    lui x29, 793                      # quiet
    mulhsu x19, x20, x21              # s0 mulhsu: the busy unit s3 waits behind, d3 (struct); writes x19 before s1, d1 (waw)
    jal x19, .L1238                   # s1 jal: writes x19 after s0, d1 (waw)
.L1238:
    mulh x22, x18, x23                # s2 mulh: reads x18, which s4 writes at d2 (war)
    blt x24, x25, .L1239              # s3 blt: d3 behind the busy s0 (struct)
.L1239:
    addi x18, x26, 0                  # subject s4 addi: writes x18, which s2 read, d2 (war)
    lui x6, 794                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 795                       # quiet
    lui x28, 796                      # quiet
# block 55  shape/s3_struct13_waw03_waw24  s0=auipc s1=mulhsu s2=mul s3=jal s4=mulhsu  e0=2 e1=3 e2=3
    lui x0, 55                        # block 55
    lui x29, 797                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 798                       # quiet
    lui x7, 799                       # quiet
    addi x15, x0, 717                 # auipc's rd before (stale)
    addi x17, x0, 724                 # mulhsu's operand
    addi x18, x0, 731                 # mulhsu's operand
    addi x16, x0, 738                 # mulhsu's rd before (stale)
    addi x20, x0, 745                 # mul's operand: the identity delivers the value
    addi x21, x0, 1                   # mul's operand: the identity delivers the value
    addi x19, x0, 752                 # mul's rd before (stale)
    addi x15, x0, 766                 # jal's rd before (stale)
    addi x22, x0, 774                 # mulhsu's operand: the identity delivers the value
    addi x23, x0, -1                  # mulhsu's operand: the identity delivers the value
    addi x19, x0, 780                 # mulhsu's rd before (stale)
    lui x28, 800                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 801                      # quiet
    lui x6, 802                       # quiet
    auipc x15, 74565                  # s0 auipc: writes x15 before s3, d3 (waw)
    mulhsu x16, x17, x18              # s1 mulhsu: the busy unit s3 waits behind, d2 (struct)
    mul x19, x20, x21                 # s2 mul: writes x19 before s4, d3 (waw)
    jal x15, .L1248                   # s3 jal: d2 behind the busy s1 (struct); writes x15 after s0, d3 (waw)
.L1248:
    lui x7, 803                       # filler (gap)
    mulhsu x19, x22, x23              # subject s4 mulhsu: writes x19 after s2, d3 (waw)
    lui x28, 804                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 805                      # quiet
    lui x6, 806                       # quiet
# block 56  shape/s3_war02_waw14_waw23  s0=mulhsu s1=xor s2=slti s3=srli s4=lh  e0=3 e1=3 e2=1
    lui x0, 56                        # block 56
    lui x7, 807                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 808                      # quiet
    lui x29, 809                      # quiet
    addi x26, x0, 1734                # x26 = 1734
    addi x3, x0, 1741                 # mulhsu's operand
    addi x27, x0, 1748                # mulhsu's rd before (stale)
    addi x9, x0, 1755                 # xor's operand: the identity delivers the value
    addi x10, x0, 0                   # xor's operand: the identity delivers the value
    addi x8, x0, 1762                 # xor's rd before (stale)
    addi x11, x0, 1783                # slti's operand
    addi x12, x0, 1790                # srli's operand: the identity delivers the value
    .L1297: auipc x13, %pcrel_hi(w45) # lh's base -> w45
    lui x6, 810                       # lh's base -> w45 (quiet)
    lui x7, 811                       # lh's base -> w45 (quiet)
    lui x28, 812                      # lh's base -> w45 (quiet)
    addi x13, x13, %pcrel_lo(.L1297)  # lh's base -> w45
    addi x8, x0, 1811                 # lh's rd before (stale)
    lui x29, 813                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 814                       # quiet
    lui x7, 815                       # quiet
    mulhsu x27, x26, x3               # s0 mulhsu: reads x26, which s2 writes at d3 (war)
    lui x28, 816                      # filler (gap)
    xor x8, x9, x10                   # s1 xor: writes x8 before s4, d3 (waw)
    slti x26, x11, 5                  # s2 slti: writes x26, which s0 read, d3 (war); writes x26 before s3, d1 (waw)
    srli x26, x12, 0                  # s3 srli: writes x26 after s2, d1 (waw)
    lh x8, 0(x13)                     # subject s4 lh: writes x8 after s1, d3 (waw)
    lui x29, 817                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 818                       # quiet
    lui x7, 819                       # quiet
# block 57  shape/s3_war23_waw01_waw14  s0=mul s1=jal s2=sh s3=mul s4=lw  e0=1 e1=1 e2=3
    lui x0, 57                        # block 57
    lui x28, 820                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 821                      # quiet
    lui x6, 822                       # quiet
    addi x16, x0, 1825                # mul's operand: the identity delivers the value
    addi x17, x0, 1                   # mul's operand: the identity delivers the value
    addi x15, x0, 1832                # mul's rd before (stale)
    addi x15, x0, 1846                # jal's rd before (stale)
    addi x14, x0, 1853                # x14 = 1853
    .L1298: auipc x18, %pcrel_hi(w46) # sh's base -> w46
    lui x7, 823                       # sh's base -> w46 (quiet)
    lui x28, 824                      # sh's base -> w46 (quiet)
    lui x29, 825                      # sh's base -> w46 (quiet)
    addi x18, x18, %pcrel_lo(.L1298)  # sh's base -> w46
    addi x19, x0, 1867                # mul's operand: the identity delivers the value
    addi x20, x0, 1                   # mul's operand: the identity delivers the value
    .L1299: auipc x21, %pcrel_hi(w47) # lw's base -> w47
    lui x6, 826                       # lw's base -> w47 (quiet)
    lui x7, 827                       # lw's base -> w47 (quiet)
    lui x28, 828                      # lw's base -> w47 (quiet)
    addi x21, x21, %pcrel_lo(.L1299)  # lw's base -> w47
    addi x15, x0, 1888                # lw's rd before (stale)
    lui x29, 829                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 830                       # quiet
    lui x7, 831                       # quiet
    mul x15, x16, x17                 # s0 mul: writes x15 before s1, d1 (waw)
    jal x15, .L1300                   # s1 jal: writes x15 after s0, d1 (waw); writes x15 before s4, d3 (waw)
.L1300:
    sh x14, 0(x18)                    # s2 sh: reads x14, which s3 writes at d1 (war)
    mul x14, x19, x20                 # s3 mul: writes x14, which s2 read, d1 (war)
    lw x15, 0(x21)                    # subject s4 lw: writes x15 after s1, d3 (waw)
    lui x28, 832                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 833                      # quiet
    lui x6, 834                       # quiet
# block 58  shape/s3_ctrl14_mem02_struct35  s0=sw s1=jalr s2=lbu s3=mulh s4=beq s5=sb  e0=3 e1=3 e2=2
    lui x0, 58                        # block 58
    lui x7, 835                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 836                      # quiet
    lui x29, 837                      # quiet
    .L1301: auipc x22, %pcrel_hi(w48) # sw's base -> w48
    lui x6, 838                       # sw's base -> w48 (quiet)
    lui x7, 839                       # sw's base -> w48 (quiet)
    lui x28, 840                      # sw's base -> w48 (quiet)
    addi x22, x22, %pcrel_lo(.L1301)  # sw's base -> w48
    addi x23, x0, 1909                # sw's store data
    .L1303: auipc x25, %pcrel_hi(.L1302) # jalr's target -> .L1302, the label after it
    lui x29, 841                      # jalr's target -> .L1302, the label after it (quiet)
    lui x6, 842                       # jalr's target -> .L1302, the label after it (quiet)
    lui x7, 843                       # jalr's target -> .L1302, the label after it (quiet)
    addi x25, x25, %pcrel_lo(.L1303)  # jalr's target -> .L1302, the label after it
    addi x24, x0, 1916                # jalr's rd before (stale)
    .L1304: auipc x27, %pcrel_hi(w48) # lbu's base -> w48
    lui x28, 844                      # lbu's base -> w48 (quiet)
    lui x29, 845                      # lbu's base -> w48 (quiet)
    lui x6, 846                       # lbu's base -> w48 (quiet)
    addi x27, x27, %pcrel_lo(.L1304)  # lbu's base -> w48
    addi x26, x0, 1923                # lbu's rd before (stale)
    addi x8, x0, 1930                 # mulh's operand
    addi x9, x0, 1937                 # mulh's operand
    addi x3, x0, 1944                 # mulh's rd before (stale)
    addi x10, x0, 1951                # beq's operand
    addi x11, x0, 1958                # beq's operand
    .L1305: auipc x12, %pcrel_hi(w49) # sb's base -> w49
    lui x7, 847                       # sb's base -> w49 (quiet)
    lui x28, 848                      # sb's base -> w49 (quiet)
    lui x29, 849                      # sb's base -> w49 (quiet)
    addi x12, x12, %pcrel_lo(.L1305)  # sb's base -> w49
    addi x13, x0, 1972                # sb's store data
    lui x6, 850                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 851                       # quiet
    lui x28, 852                      # quiet
    sw x23, 0(x22)                    # s0 sw: stores what s2 loads, d3 (mem)
    lui x29, 853                      # filler (gap)
    jalr x24, 0(x25)                  # s1 jalr: the taken transfer, s4 d3 after it (ctrl)
.L1302:
    lbu x26, 0(x27)                   # s2 lbu: loads what s0 stored, d3 (mem)
    mulh x3, x8, x9                   # s3 mulh: the busy unit s5 waits behind, d2 (struct)
    beq x10, x11, .L1306              # s4 beq: d3 after the transfer s1 (ctrl)
.L1306:
    sb x13, 0(x12)                    # subject s5 sb: d2 behind the busy s3 (struct)
    lui x6, 854                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 855                       # quiet
    lui x28, 856                      # quiet
# block 59  shape/s3_mem03_war14_waw25  s0=sb s1=sll s2=mulhu s3=lh s4=lhu s5=mulhsu  e0=3 e1=3 e2=3
    lui x0, 59                        # block 59
    lui x29, 857                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 858                       # quiet
    lui x7, 859                       # quiet
    .L1307: auipc x15, %pcrel_hi(w50) # sb's base -> w50
    lui x28, 860                      # sb's base -> w50 (quiet)
    lui x29, 861                      # sb's base -> w50 (quiet)
    lui x6, 862                       # sb's base -> w50 (quiet)
    addi x15, x15, %pcrel_lo(.L1307)  # sb's base -> w50
    addi x16, x0, 1986                # sb's store data
    addi x14, x0, 1993                # x14 = 1993
    addi x18, x0, 2000                # sll's operand
    addi x17, x0, 2007                # sll's rd before (stale)
    addi x20, x0, 2015                # mulhu's operand: the identity delivers the value
    addi x21, x0, -1                  # mulhu's operand: the identity delivers the value
    addi x19, x0, 2021                # mulhu's rd before (stale)
    .L1308: auipc x23, %pcrel_hi(w50) # lh's base -> w50
    lui x7, 863                       # lh's base -> w50 (quiet)
    lui x28, 864                      # lh's base -> w50 (quiet)
    lui x29, 865                      # lh's base -> w50 (quiet)
    addi x23, x23, %pcrel_lo(.L1308)  # lh's base -> w50
    addi x22, x0, 2028                # lh's rd before (stale)
    .L1309: auipc x24, %pcrel_hi(w51) # lhu's base -> w51
    lui x6, 866                       # lhu's base -> w51 (quiet)
    lui x7, 867                       # lhu's base -> w51 (quiet)
    lui x28, 868                      # lhu's base -> w51 (quiet)
    addi x24, x24, %pcrel_lo(.L1309)  # lhu's base -> w51
    addi x25, x0, 281                 # mulhsu's operand: the identity delivers the value
    addi x26, x0, -1                  # mulhsu's operand: the identity delivers the value
    addi x19, x0, 287                 # mulhsu's rd before (stale)
    lui x29, 869                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 870                       # quiet
    lui x7, 871                       # quiet
    sb x16, 0(x15)                    # s0 sb: stores what s3 loads, d3 (mem)
    sll x17, x14, x18                 # s1 sll: reads x14, which s4 writes at d3 (war)
    mulhu x19, x20, x21               # s2 mulhu: writes x19 before s5, d3 (waw)
    lh x22, 0(x23)                    # s3 lh: loads what s0 stored, d3 (mem)
    lhu x14, 0(x24)                   # s4 lhu: writes x14, which s1 read, d3 (war)
    mulhsu x19, x25, x26              # subject s5 mulhsu: writes x19 after s2, d3 (waw)
    lui x28, 872                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 873                      # quiet
    lui x6, 874                       # quiet
# block 60  shape/s3_mem14_mem25_struct03  s0=mulh s1=sw s2=sw s3=sb s4=lb s5=lb  e0=3 e1=3 e2=3
    lui x0, 60                        # block 60
    lui x7, 875                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 876                      # quiet
    lui x29, 877                      # quiet
    addi x3, x0, 294                  # mulh's operand
    addi x8, x0, 301                  # mulh's operand
    addi x27, x0, 308                 # mulh's rd before (stale)
    .L1310: auipc x9, %pcrel_hi(w52)  # sw's base -> w52
    lui x6, 878                       # sw's base -> w52 (quiet)
    lui x7, 879                       # sw's base -> w52 (quiet)
    lui x28, 880                      # sw's base -> w52 (quiet)
    addi x9, x9, %pcrel_lo(.L1310)    # sw's base -> w52
    addi x10, x0, 0                   # sw's store data
    .L1311: auipc x11, %pcrel_hi(w53) # sw's base -> w53
    lui x29, 881                      # sw's base -> w53 (quiet)
    lui x6, 882                       # sw's base -> w53 (quiet)
    lui x7, 883                       # sw's base -> w53 (quiet)
    addi x11, x11, %pcrel_lo(.L1311)  # sw's base -> w53
    addi x12, x0, 329                 # sw's store data
    .L1312: auipc x13, %pcrel_hi(w54) # sb's base -> w54
    lui x28, 884                      # sb's base -> w54 (quiet)
    lui x29, 885                      # sb's base -> w54 (quiet)
    lui x6, 886                       # sb's base -> w54 (quiet)
    addi x13, x13, %pcrel_lo(.L1312)  # sb's base -> w54
    addi x14, x0, 343                 # sb's store data
    .L1313: auipc x16, %pcrel_hi(w52) # lb's base -> w52
    lui x7, 887                       # lb's base -> w52 (quiet)
    lui x28, 888                      # lb's base -> w52 (quiet)
    lui x29, 889                      # lb's base -> w52 (quiet)
    addi x16, x16, %pcrel_lo(.L1313)  # lb's base -> w52
    addi x15, x0, 350                 # lb's rd before (stale)
    .L1314: auipc x18, %pcrel_hi(w53) # lb's base -> w53
    lui x6, 890                       # lb's base -> w53 (quiet)
    lui x7, 891                       # lb's base -> w53 (quiet)
    lui x28, 892                      # lb's base -> w53 (quiet)
    addi x18, x18, %pcrel_lo(.L1314)  # lb's base -> w53
    addi x17, x0, 357                 # lb's rd before (stale)
    lui x29, 893                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 894                       # quiet
    lui x7, 895                       # quiet
    mulh x27, x3, x8                  # s0 mulh: the busy unit s3 waits behind, d3 (struct)
    sw x10, 0(x9)                     # s1 sw: stores what s4 loads, d3 (mem)
    sw x12, 0(x11)                    # s2 sw: stores what s5 loads, d3 (mem)
    sb x14, 0(x13)                    # s3 sb: d3 behind the busy s0 (struct)
    lb x15, 0(x16)                    # s4 lb: loads what s1 stored, d3 (mem)
    lb x17, 0(x18)                    # subject s5 lb: loads what s2 stored, d3 (mem)
    lui x28, 896                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 897                      # quiet
    lui x6, 898                       # quiet
# block 61  shape/s3_raw35_war02_waw14  s0=srli s1=mulhu s2=lui s3=slti s4=jal s5=srl  e0=3 e1=2 e2=3
    lui x0, 61                        # block 61
    lui x7, 899                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 900                      # quiet
    lui x29, 901                      # quiet
    addi x19, x0, 364                 # x19 = 364
    addi x20, x0, 371                 # srli's rd before (stale)
    addi x22, x0, 379                 # mulhu's operand: the identity delivers the value
    addi x23, x0, -1                  # mulhu's operand: the identity delivers the value
    addi x21, x0, 385                 # mulhu's rd before (stale)
    addi x25, x0, 420                 # slti's operand
    addi x24, x0, 413                 # slti's rd before (stale)
    addi x21, x0, 434                 # jal's rd before (stale)
    addi x27, x0, 441                 # srl's operand
    addi x26, x0, 448                 # srl's rd before (stale)
    lui x6, 902                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 903                       # quiet
    lui x28, 904                      # quiet
    srli x20, x19, 0                  # s0 srli: reads x19, which s2 writes at d2 (war)
    mulhu x21, x22, x23               # s1 mulhu: writes x21 before s4, d3 (waw)
    lui x19, 1040074                  # s2 lui: writes x19, which s0 read, d2 (war)
    slti x24, x25, 5                  # s3 slti: x24 -> s5 at rs1, d3
    jal x21, .L1315                   # s4 jal: writes x21 after s1, d3 (waw)
.L1315:
    lui x29, 905                      # filler (gap)
    srl x26, x24, x27                 # subject s5 srl: reads x24 from s3 at rs1, d3
    lui x6, 906                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 907                       # quiet
    lui x28, 908                      # quiet
TEST_END
TEST_TRAP_RESUME
    .section .data
    .align 12
tdata:
w0: .word 0x12a
w1: .word 0x774
w2: .word 0x7b3
w3: .word 0x593
w4: .word w3
w5: .word 0xb9
w6: .word 0x4dc
w7: .word 0x50d
w8: .word 0x452
w9: .word 0x68d
w10: .word 0x694
w11: .word 0x18e
w12: .word 0xbf
w13: .word 0xf7
w14: .word 0x228
w15: .word 0x2f
w16: .word 0x2f7
w17: .word 0x30c
w18: .word 0x535
w19: .word 0x551
w20: .word 0x680
w21: .word 0x695
w22: .word 0x760
w23: .word 0x7c
w24: .word 0x7ad
w25: .word 0x3
w26: .word 0x16c
w27: .word 0xce
w28: .word 0x230
w29: .word 0x284
w30: .word 0x292
w31: .word 0x2fb
w32: .word 0x309
w33: .word 0x32c
w34: .word 0xe1
w35: .word 0xb7
w36: .word 0x60b
w37: .word 0x6d
w38: .word 0x9e
w39: .word 0x349
w40: .word 0x636
w41: .word 0x683
w42: .word 0x6b4
w43: .word 0x6d0
w44: .word 0x6fa
w45: .word 0x70c
w46: .word 0x744
w47: .word 0x759
w48: .word 0x76e
w49: .word 0x7ad
w50: .word 0x7bb
w51: .word 0x103
w52: .word 0x13b
w53: .word 0x142
w54: .word 0x150
    .word 0
TEST_HTIF
