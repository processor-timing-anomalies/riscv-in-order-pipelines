// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the whole test hz-I-sw-base-00, kept as it ran (no cut-down reproducer: a confirmation capture, the window 137-139 marked by hand).
# the window: orders 137-139 of the run -- under a data bus that answers every request two cycles after its grant: the sw's response is late, the jal behind it retires +1 as always, but its target, the lui already fetched, retires +2 instead of +1: it sat in IF while the store in WB waited, although ID and EX had room (sched.txt is the run's bus timing)
# MARCH: rv32i
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
# block 1  raw_addr_load_d1  sw after lw  expect(isa): stall 1
    lui x0, 1  # marker: block 1
    lui x6, 2                         # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 3                         # quiet
    lui x28, 4                        # quiet
    addi x20, x0, 375                 # sw's store data
    .L5: auipc x21, %pcrel_hi(w1)     # lw's base -> w1
    lui x29, 5                        # lw's base -> w1 (quiet)
    lui x6, 6                         # lw's base -> w1 (quiet)
    lui x7, 7                         # lw's base -> w1 (quiet)
    addi x21, x21, %pcrel_lo(.L5)     # lw's base -> w1
    addi x19, x0, 382                 # lw's rd before (stale)
    lui x28, 8                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 9                        # quiet
    lui x6, 10                        # quiet
    lw x19, 0(x21)                    # lw: producer, writes the link x19
    sw x20, 0(x19)                    # subject sw: consumer, reads x19 at addr, d1 (raw_addr_load_d1)
    lui x7, 11                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 12                       # quiet
    lui x29, 13                       # quiet
# block 2  raw_addr_load_d1  sw after lw  expect(isa): stall 1
    lui x0, 2  # marker: block 2
    lui x6, 14                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 15                        # quiet
    lui x28, 16                       # quiet
    addi x10, x0, 508                 # sw's store data
    .L10: auipc x11, %pcrel_hi(w3)    # lw's base -> w3
    lui x29, 17                       # lw's base -> w3 (quiet)
    lui x6, 18                        # lw's base -> w3 (quiet)
    lui x7, 19                        # lw's base -> w3 (quiet)
    addi x11, x11, %pcrel_lo(.L10)    # lw's base -> w3
    addi x8, x0, 515                  # lw's rd before (stale)
    lui x28, 20                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 21                       # quiet
    lui x6, 22                        # quiet
    lw x8, 0(x11)                     # lw: producer, writes the link x8
    sw x10, 0(x8)                     # subject sw: consumer, reads x8 at addr, d1 (raw_addr_load_d1)
    lui x7, 23                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 24                       # quiet
    lui x29, 25                       # quiet
# block 4  raw_addr_load_d2  sw after lw  expect(isa): forward 0
    lui x0, 4  # marker: block 4
    lui x6, 26                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 27                        # quiet
    lui x28, 28                       # quiet
    addi x25, x0, 641                 # sw's store data
    .L15: auipc x26, %pcrel_hi(w5)    # lw's base -> w5
    lui x29, 29                       # lw's base -> w5 (quiet)
    lui x6, 30                        # lw's base -> w5 (quiet)
    lui x7, 31                        # lw's base -> w5 (quiet)
    addi x26, x26, %pcrel_lo(.L15)    # lw's base -> w5
    addi x24, x0, 648                 # lw's rd before (stale)
    lui x28, 32                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 33                       # quiet
    lui x6, 34                        # quiet
    lw x24, 0(x26)                    # lw: producer, writes the link x24
    lui x7, 35                        # filler (gap)
    sw x25, 0(x24)                    # subject sw: consumer, reads x24 at addr, d2 (raw_addr_load_d2)
    lui x28, 36                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 37                       # quiet
    lui x6, 38                        # quiet
# block 5  raw_addr_load_d2  sw after lw  expect(isa): forward 0
    lui x0, 5  # marker: block 5
    lui x7, 39                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 40                       # quiet
    lui x29, 41                       # quiet
    addi x14, x0, 1                   # sw's store data
    .L20: auipc x15, %pcrel_hi(w7)    # lw's base -> w7
    lui x6, 42                        # lw's base -> w7 (quiet)
    lui x7, 43                        # lw's base -> w7 (quiet)
    lui x28, 44                       # lw's base -> w7 (quiet)
    addi x15, x15, %pcrel_lo(.L20)    # lw's base -> w7
    addi x4, x0, 774                  # lw's rd before (stale)
    lui x29, 45                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 46                        # quiet
    lui x7, 47                        # quiet
    lw x4, 0(x15)                     # lw: producer, writes the link x4
    lui x28, 48                       # filler (gap)
    sw x14, 0(x4)                     # subject sw: consumer, reads x4 at addr, d2 (raw_addr_load_d2)
    lui x29, 49                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 50                        # quiet
    lui x7, 51                        # quiet
# block 7  raw_addr_load_d3  sw after lw  expect(isa): none 0
    lui x0, 7  # marker: block 7
    lui x28, 52                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 53                       # quiet
    lui x6, 54                        # quiet
    addi x8, x0, 900                  # sw's store data
    .L25: auipc x9, %pcrel_hi(w9)     # lw's base -> w9
    lui x7, 55                        # lw's base -> w9 (quiet)
    lui x28, 56                       # lw's base -> w9 (quiet)
    lui x29, 57                       # lw's base -> w9 (quiet)
    addi x9, x9, %pcrel_lo(.L25)      # lw's base -> w9
    addi x3, x0, 907                  # lw's rd before (stale)
    lui x6, 58                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 59                        # quiet
    lui x28, 60                       # quiet
    lw x3, 0(x9)                      # lw: producer, writes the link x3
    lui x29, 61                       # filler (gap)
    lui x6, 62                        # filler (gap)
    sw x8, 0(x3)                      # subject sw: consumer, reads x3 at addr, d3 (raw_addr_load_d3)
    lui x7, 63                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 64                       # quiet
    lui x29, 65                       # quiet
# block 8  raw_addr_load_d3  sw after lw  expect(isa): none 0
    lui x0, 8  # marker: block 8
    lui x6, 66                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 67                        # quiet
    lui x28, 68                       # quiet
    addi x18, x0, 1033                # sw's store data
    .L30: auipc x19, %pcrel_hi(w11)   # lw's base -> w11
    lui x29, 69                       # lw's base -> w11 (quiet)
    lui x6, 70                        # lw's base -> w11 (quiet)
    lui x7, 71                        # lw's base -> w11 (quiet)
    addi x19, x19, %pcrel_lo(.L30)    # lw's base -> w11
    addi x1, x0, 1040                 # lw's rd before (stale)
    lui x28, 72                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 73                       # quiet
    lui x6, 74                        # quiet
    lw x1, 0(x19)                     # lw: producer, writes the link x1
    lui x7, 75                        # filler (gap)
    lui x28, 76                       # filler (gap)
    sw x18, 0(x1)                     # subject sw: consumer, reads x1 at addr, d3 (raw_addr_load_d3)
    lui x29, 77                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 78                        # quiet
    lui x7, 79                        # quiet
# block 10  raw_addr_jalr_d1  sw after jalr  expect(isa): stall 1
    lui x0, 10  # marker: block 10
    lui x28, 80                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 81                       # quiet
    lui x6, 82                        # quiet
    addi x21, x0, 1054                # sw's store data
    .L33: auipc x22, %pcrel_hi(.L32)  # jalr's target -> .L32, the label after it
    lui x7, 83                        # jalr's target -> .L32, the label after it (quiet)
    lui x28, 84                       # jalr's target -> .L32, the label after it (quiet)
    lui x29, 85                       # jalr's target -> .L32, the label after it (quiet)
    addi x22, x22, %pcrel_lo(.L33)    # jalr's target -> .L32, the label after it
    addi x20, x0, 1061                # jalr's rd before (stale)
    lui x6, 86                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 87                        # quiet
    lui x28, 88                       # quiet
    jalr x20, 0(x22)                  # jalr: producer, writes the link x20
.L32:
.L31:
    sw x21, 8(x20)                    # subject sw: consumer, reads x20 at addr, d1 (raw_addr_jalr_d1)
    j .L34                            # over the data word iw1, reached from the link
iw1: .word 0x42c
.L34:
    lui x29, 89                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 90                        # quiet
    lui x7, 91                        # quiet
# block 11  raw_addr_jalr_d1  sw after jalr  expect(isa): stall 1
    lui x0, 11  # marker: block 11
    lui x28, 92                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 93                       # quiet
    lui x6, 94                        # quiet
    addi x23, x0, 0                   # sw's store data
    .L37: auipc x24, %pcrel_hi(.L36)  # jalr's target -> .L36, the label after it
    lui x7, 95                        # jalr's target -> .L36, the label after it (quiet)
    lui x28, 96                       # jalr's target -> .L36, the label after it (quiet)
    lui x29, 97                       # jalr's target -> .L36, the label after it (quiet)
    addi x24, x24, %pcrel_lo(.L37)    # jalr's target -> .L36, the label after it
    addi x16, x0, 1075                # jalr's rd before (stale)
    lui x6, 98                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 99                        # quiet
    lui x28, 100                      # quiet
    jalr x16, 0(x24)                  # jalr: producer, writes the link x16
.L36:
.L35:
    sw x23, 8(x16)                    # subject sw: consumer, reads x16 at addr, d1 (raw_addr_jalr_d1)
    j .L38                            # over the data word iw2, reached from the link
iw2: .word 0x43a
.L38:
    lui x29, 101                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 102                       # quiet
    lui x7, 103                       # quiet
# block 13  raw_addr_jalr_d2  sw after jalr  expect(isa): forward 0
    lui x0, 13  # marker: block 13
    lui x28, 104                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 105                      # quiet
    lui x6, 106                       # quiet
    addi x26, x0, 1089                # sw's store data
    .L41: auipc x27, %pcrel_hi(.L40)  # jalr's target -> .L40, the label after it
    lui x7, 107                       # jalr's target -> .L40, the label after it (quiet)
    lui x28, 108                      # jalr's target -> .L40, the label after it (quiet)
    lui x29, 109                      # jalr's target -> .L40, the label after it (quiet)
    addi x27, x27, %pcrel_lo(.L41)    # jalr's target -> .L40, the label after it
    addi x25, x0, 1096                # jalr's rd before (stale)
    lui x6, 110                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 111                       # quiet
    lui x28, 112                      # quiet
    jalr x25, 0(x27)                  # jalr: producer, writes the link x25
.L40:
.L39:
    lui x29, 113                      # filler (gap)
    sw x26, 12(x25)                   # subject sw: consumer, reads x25 at addr, d2 (raw_addr_jalr_d2)
    j .L42                            # over the data word iw3, reached from the link
iw3: .word 0x44f
.L42:
    lui x6, 114                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 115                       # quiet
    lui x28, 116                      # quiet
# block 14  raw_addr_jalr_d2  sw after jalr  expect(isa): forward 0
    lui x0, 14  # marker: block 14
    lui x29, 117                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 118                       # quiet
    lui x7, 119                       # quiet
    addi x3, x0, 1110                 # sw's store data
    .L45: auipc x9, %pcrel_hi(.L44)   # jalr's target -> .L44, the label after it
    lui x28, 120                      # jalr's target -> .L44, the label after it (quiet)
    lui x29, 121                      # jalr's target -> .L44, the label after it (quiet)
    lui x6, 122                       # jalr's target -> .L44, the label after it (quiet)
    addi x9, x9, %pcrel_lo(.L45)      # jalr's target -> .L44, the label after it
    addi x8, x0, 1117                 # jalr's rd before (stale)
    lui x7, 123                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 124                      # quiet
    lui x29, 125                      # quiet
    jalr x8, 0(x9)                    # jalr: producer, writes the link x8
.L44:
.L43:
    lui x6, 126                       # filler (gap)
    sw x3, 12(x8)                     # subject sw: consumer, reads x8 at addr, d2 (raw_addr_jalr_d2)
    j .L46                            # over the data word iw4, reached from the link
iw4: .word 0x464
.L46:
    lui x7, 127                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 128                      # quiet
    lui x29, 129                      # quiet
# block 16  raw_addr_jalr_d3  sw after jalr  expect(isa): none 0
    lui x0, 16  # marker: block 16
    lui x6, 130                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 131                       # quiet
    lui x28, 132                      # quiet
    addi x11, x0, 1131                # sw's store data
    .L49: auipc x12, %pcrel_hi(.L48)  # jalr's target -> .L48, the label after it
    lui x29, 133                      # jalr's target -> .L48, the label after it (quiet)
    lui x6, 134                       # jalr's target -> .L48, the label after it (quiet)
    lui x7, 135                       # jalr's target -> .L48, the label after it (quiet)
    addi x12, x12, %pcrel_lo(.L49)    # jalr's target -> .L48, the label after it
    addi x10, x0, 1138                # jalr's rd before (stale)
    lui x28, 136                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 137                      # quiet
    lui x6, 138                       # quiet
    jalr x10, 0(x12)                  # jalr: producer, writes the link x10
.L48:
.L47:
    lui x7, 139                       # filler (gap)
    lui x28, 140                      # filler (gap)
    sw x11, 16(x10)                   # subject sw: consumer, reads x10 at addr, d3 (raw_addr_jalr_d3)
    j .L50                            # over the data word iw5, reached from the link
iw5: .word 0x479
.L50:
    lui x29, 141                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 142                       # quiet
    lui x7, 143                       # quiet
# block 17  raw_addr_jalr_d3  sw after jalr  expect(isa): none 0
    lui x0, 17  # marker: block 17
    lui x28, 144                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 145                      # quiet
    lui x6, 146                       # quiet
    addi x13, x0, 1                   # sw's store data
    .L53: auipc x14, %pcrel_hi(.L52)  # jalr's target -> .L52, the label after it
    lui x7, 147                       # jalr's target -> .L52, the label after it (quiet)
    lui x28, 148                      # jalr's target -> .L52, the label after it (quiet)
    lui x29, 149                      # jalr's target -> .L52, the label after it (quiet)
    addi x14, x14, %pcrel_lo(.L53)    # jalr's target -> .L52, the label after it
    addi x4, x0, 1152                 # jalr's rd before (stale)
    lui x6, 150                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 151                       # quiet
    lui x28, 152                      # quiet
    jalr x4, 0(x14)                   # jalr: producer, writes the link x4
.L52:
.L51:
    lui x29, 153                      # filler (gap)
    lui x6, 154                       # filler (gap)
    sw x13, 16(x4)                    # subject sw: consumer, reads x4 at addr, d3 (raw_addr_jalr_d3)
    j .L54                            # over the data word iw6, reached from the link
iw6: .word 0x487
.L54:
    lui x7, 155                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 156                      # quiet
    lui x29, 157                      # quiet
# block 19  raw_addr_jal_d1  sw after jal  expect(isa): stall 1
    lui x0, 19  # marker: block 19
    lui x6, 158                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 159                       # quiet
    lui x28, 160                      # quiet
    addi x16, x0, 1166                # sw's store data
    addi x15, x0, 1173                # jal's rd before (stale)
    lui x29, 161                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 162                       # quiet
    lui x7, 163                       # quiet
    jal x15, .L56                     # jal: producer, writes the link x15
.L56:
.L55:
    sw x16, 8(x15)                    # subject sw: consumer, reads x15 at addr, d1 (raw_addr_jal_d1)
    j .L57                            # over the data word iw7, reached from the link
iw7: .word 0x49c
.L57:
    lui x28, 164                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 165                      # quiet
    lui x6, 166                       # quiet
# block 20  raw_addr_jal_d1  sw after jal  expect(isa): stall 1
    lui x0, 20  # marker: block 20
    lui x7, 167                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 168                      # quiet
    lui x29, 169                      # quiet
    addi x17, x0, 1187                # sw's store data
    addi x1, x0, 1194                 # jal's rd before (stale)
    lui x6, 170                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 171                       # quiet
    lui x28, 172                      # quiet
    jal x1, .L59                      # jal: producer, writes the link x1
.L59:
.L58:
    sw x17, 8(x1)                     # subject sw: consumer, reads x1 at addr, d1 (raw_addr_jal_d1)
    j .L60                            # over the data word iw8, reached from the link
iw8: .word 0x4b1
.L60:
    lui x29, 173                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 174                       # quiet
    lui x7, 175                       # quiet
# block 22  raw_addr_jal_d2  sw after jal  expect(isa): forward 0
    lui x0, 22  # marker: block 22
    lui x28, 176                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 177                      # quiet
    lui x6, 178                       # quiet
    addi x19, x0, 1208                # sw's store data
    addi x18, x0, 1215                # jal's rd before (stale)
    lui x7, 179                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 180                      # quiet
    lui x29, 181                      # quiet
    jal x18, .L62                     # jal: producer, writes the link x18
.L62:
.L61:
    lui x6, 182                       # filler (gap)
    sw x19, 12(x18)                   # subject sw: consumer, reads x18 at addr, d2 (raw_addr_jal_d2)
    j .L63                            # over the data word iw9, reached from the link
iw9: .word 0x4c6
.L63:
    lui x7, 183                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 184                      # quiet
    lui x29, 185                      # quiet
# block 23  raw_addr_jal_d2  sw after jal  expect(isa): forward 0
    lui x0, 23  # marker: block 23
    lui x6, 186                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 187                       # quiet
    lui x28, 188                      # quiet
    addi x20, x0, 2                   # sw's store data
    addi x16, x0, 1229                # jal's rd before (stale)
    lui x29, 189                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 190                       # quiet
    lui x7, 191                       # quiet
    jal x16, .L65                     # jal: producer, writes the link x16
.L65:
.L64:
    lui x28, 192                      # filler (gap)
    sw x20, 12(x16)                   # subject sw: consumer, reads x16 at addr, d2 (raw_addr_jal_d2)
    j .L66                            # over the data word iw10, reached from the link
iw10: .word 0x4d4
.L66:
    lui x29, 193                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 194                       # quiet
    lui x7, 195                       # quiet
# block 25  raw_addr_jal_d3  sw after jal  expect(isa): none 0
    lui x0, 25  # marker: block 25
    lui x28, 196                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 197                      # quiet
    lui x6, 198                       # quiet
    addi x22, x0, 1243                # sw's store data
    addi x21, x0, 1250                # jal's rd before (stale)
    lui x7, 199                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 200                      # quiet
    lui x29, 201                      # quiet
    jal x21, .L68                     # jal: producer, writes the link x21
.L68:
.L67:
    lui x6, 202                       # filler (gap)
    lui x7, 203                       # filler (gap)
    sw x22, 16(x21)                   # subject sw: consumer, reads x21 at addr, d3 (raw_addr_jal_d3)
    j .L69                            # over the data word iw11, reached from the link
iw11: .word 0x4e9
.L69:
    lui x28, 204                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 205                      # quiet
    lui x6, 206                       # quiet
# block 26  raw_addr_jal_d3  sw after jal  expect(isa): none 0
    lui x0, 26  # marker: block 26
    lui x7, 207                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 208                      # quiet
    lui x29, 209                      # quiet
    addi x23, x0, 1264                # sw's store data
    addi x8, x0, 1271                 # jal's rd before (stale)
    lui x6, 210                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 211                       # quiet
    lui x28, 212                      # quiet
    jal x8, .L71                      # jal: producer, writes the link x8
.L71:
.L70:
    lui x29, 213                      # filler (gap)
    lui x6, 214                       # filler (gap)
    sw x23, 16(x8)                    # subject sw: consumer, reads x8 at addr, d3 (raw_addr_jal_d3)
    j .L72                            # over the data word iw12, reached from the link
iw12: .word 0x4fe
.L72:
    lui x7, 215                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 216                      # quiet
    lui x29, 217                      # quiet
# block 28  raw_addr_alu_rr_d1  sw after add  expect(isa): stall 1
    lui x0, 28  # marker: block 28
    lui x6, 218                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 219                       # quiet
    lui x28, 220                      # quiet
    addi x25, x0, 1292                # sw's store data
    .L73: auipc x26, %pcrel_hi(w12)   # add's operand: the identity delivers the value
    lui x29, 221                      # add's operand: the identity delivers the value (quiet)
    lui x6, 222                       # add's operand: the identity delivers the value (quiet)
    lui x7, 223                       # add's operand: the identity delivers the value (quiet)
    addi x26, x26, %pcrel_lo(.L73)    # add's operand: the identity delivers the value
    addi x27, x0, 0                   # add's operand: the identity delivers the value
    addi x24, x0, 1299                # add's rd before (stale)
    lui x28, 224                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 225                      # quiet
    lui x6, 226                       # quiet
    add x24, x26, x27                 # add: producer, writes the link x24
    sw x25, 0(x24)                    # subject sw: consumer, reads x24 at addr, d1 (raw_addr_alu_rr_d1)
    lui x7, 227                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 228                      # quiet
    lui x29, 229                      # quiet
# block 29  raw_addr_alu_rr_d1  sw after add  expect(isa): stall 1
    lui x0, 29  # marker: block 29
    lui x6, 230                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 231                       # quiet
    lui x28, 232                      # quiet
    addi x3, x0, 1                    # sw's store data
    .L74: auipc x8, %pcrel_hi(w13)    # add's operand: the identity delivers the value
    lui x29, 233                      # add's operand: the identity delivers the value (quiet)
    lui x6, 234                       # add's operand: the identity delivers the value (quiet)
    lui x7, 235                       # add's operand: the identity delivers the value (quiet)
    addi x8, x8, %pcrel_lo(.L74)      # add's operand: the identity delivers the value
    addi x9, x0, 0                    # add's operand: the identity delivers the value
    addi x4, x0, 1313                 # add's rd before (stale)
    lui x28, 236                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 237                      # quiet
    lui x6, 238                       # quiet
    add x4, x8, x9                    # add: producer, writes the link x4
    sw x3, 0(x4)                      # subject sw: consumer, reads x4 at addr, d1 (raw_addr_alu_rr_d1)
    lui x7, 239                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 240                      # quiet
    lui x29, 241                      # quiet
# block 31  raw_addr_alu_rr_d2  sw after add  expect(isa): forward 0
    lui x0, 31  # marker: block 31
    lui x6, 242                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 243                       # quiet
    lui x28, 244                      # quiet
    addi x11, x0, 1327                # sw's store data
    .L75: auipc x12, %pcrel_hi(w14)   # add's operand: the identity delivers the value
    lui x29, 245                      # add's operand: the identity delivers the value (quiet)
    lui x6, 246                       # add's operand: the identity delivers the value (quiet)
    lui x7, 247                       # add's operand: the identity delivers the value (quiet)
    addi x12, x12, %pcrel_lo(.L75)    # add's operand: the identity delivers the value
    addi x13, x0, 0                   # add's operand: the identity delivers the value
    addi x10, x0, 1334                # add's rd before (stale)
    lui x28, 248                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 249                      # quiet
    lui x6, 250                       # quiet
    add x10, x12, x13                 # add: producer, writes the link x10
    lui x7, 251                       # filler (gap)
    sw x11, 0(x10)                    # subject sw: consumer, reads x10 at addr, d2 (raw_addr_alu_rr_d2)
    lui x28, 252                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 253                      # quiet
    lui x6, 254                       # quiet
# block 32  raw_addr_alu_rr_d2  sw after add  expect(isa): forward 0
    lui x0, 32  # marker: block 32
    lui x7, 255                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 256                      # quiet
    lui x29, 257                      # quiet
    addi x14, x0, 1348                # sw's store data
    .L76: auipc x15, %pcrel_hi(w15)   # add's operand: the identity delivers the value
    lui x6, 258                       # add's operand: the identity delivers the value (quiet)
    lui x7, 259                       # add's operand: the identity delivers the value (quiet)
    lui x28, 260                      # add's operand: the identity delivers the value (quiet)
    addi x15, x15, %pcrel_lo(.L76)    # add's operand: the identity delivers the value
    addi x16, x0, 0                   # add's operand: the identity delivers the value
    addi x1, x0, 1355                 # add's rd before (stale)
    lui x29, 261                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 262                       # quiet
    lui x7, 263                       # quiet
    add x1, x15, x16                  # add: producer, writes the link x1
    lui x28, 264                      # filler (gap)
    sw x14, 0(x1)                     # subject sw: consumer, reads x1 at addr, d2 (raw_addr_alu_rr_d2)
    lui x29, 265                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 266                       # quiet
    lui x7, 267                       # quiet
# block 34  raw_addr_alu_rr_d3  sw after add  expect(isa): none 0
    lui x0, 34  # marker: block 34
    lui x28, 268                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 269                      # quiet
    lui x6, 270                       # quiet
    addi x18, x0, 1369                # sw's store data
    .L77: auipc x19, %pcrel_hi(w16)   # add's operand: the identity delivers the value
    lui x7, 271                       # add's operand: the identity delivers the value (quiet)
    lui x28, 272                      # add's operand: the identity delivers the value (quiet)
    lui x29, 273                      # add's operand: the identity delivers the value (quiet)
    addi x19, x19, %pcrel_lo(.L77)    # add's operand: the identity delivers the value
    addi x20, x0, 0                   # add's operand: the identity delivers the value
    addi x17, x0, 1376                # add's rd before (stale)
    lui x6, 274                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 275                       # quiet
    lui x28, 276                      # quiet
    add x17, x19, x20                 # add: producer, writes the link x17
    lui x29, 277                      # filler (gap)
    lui x6, 278                       # filler (gap)
    sw x18, 0(x17)                    # subject sw: consumer, reads x17 at addr, d3 (raw_addr_alu_rr_d3)
    lui x7, 279                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 280                      # quiet
    lui x29, 281                      # quiet
# block 35  raw_addr_alu_rr_d3  sw after add  expect(isa): none 0
    lui x0, 35  # marker: block 35
    lui x6, 282                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 283                       # quiet
    lui x28, 284                      # quiet
    addi x21, x0, 2                   # sw's store data
    .L78: auipc x22, %pcrel_hi(w17)   # add's operand: the identity delivers the value
    lui x29, 285                      # add's operand: the identity delivers the value (quiet)
    lui x6, 286                       # add's operand: the identity delivers the value (quiet)
    lui x7, 287                       # add's operand: the identity delivers the value (quiet)
    addi x22, x22, %pcrel_lo(.L78)    # add's operand: the identity delivers the value
    addi x23, x0, 0                   # add's operand: the identity delivers the value
    addi x16, x0, 1390                # add's rd before (stale)
    lui x28, 288                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 289                      # quiet
    lui x6, 290                       # quiet
    add x16, x22, x23                 # add: producer, writes the link x16
    lui x7, 291                       # filler (gap)
    lui x28, 292                      # filler (gap)
    sw x21, 0(x16)                    # subject sw: consumer, reads x16 at addr, d3 (raw_addr_alu_rr_d3)
    lui x29, 293                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 294                       # quiet
    lui x7, 295                       # quiet
# block 37  raw_addr_alu_ri_d1  sw after addi  expect(isa): stall 1
    lui x0, 37  # marker: block 37
    lui x28, 296                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 297                      # quiet
    lui x6, 298                       # quiet
    addi x25, x0, 1404                # sw's store data
    .L79: auipc x26, %pcrel_hi(w18)   # addi's operand: the identity delivers the value
    lui x7, 299                       # addi's operand: the identity delivers the value (quiet)
    lui x28, 300                      # addi's operand: the identity delivers the value (quiet)
    lui x29, 301                      # addi's operand: the identity delivers the value (quiet)
    addi x26, x26, %pcrel_lo(.L79)    # addi's operand: the identity delivers the value
    addi x24, x0, 1411                # addi's rd before (stale)
    lui x6, 302                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 303                       # quiet
    lui x28, 304                      # quiet
    addi x24, x26, 0                  # addi: producer, writes the link x24
    sw x25, 0(x24)                    # subject sw: consumer, reads x24 at addr, d1 (raw_addr_alu_ri_d1)
    lui x29, 305                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 306                       # quiet
    lui x7, 307                       # quiet
# block 38  raw_addr_alu_ri_d1  sw after addi  expect(isa): stall 1
    lui x0, 38  # marker: block 38
    lui x28, 308                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 309                      # quiet
    lui x6, 310                       # quiet
    addi x27, x0, 1425                # sw's store data
    .L80: auipc x3, %pcrel_hi(w19)    # addi's operand: the identity delivers the value
    lui x7, 311                       # addi's operand: the identity delivers the value (quiet)
    lui x28, 312                      # addi's operand: the identity delivers the value (quiet)
    lui x29, 313                      # addi's operand: the identity delivers the value (quiet)
    addi x3, x3, %pcrel_lo(.L80)      # addi's operand: the identity delivers the value
    addi x8, x0, 1432                 # addi's rd before (stale)
    lui x6, 314                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 315                       # quiet
    lui x28, 316                      # quiet
    addi x8, x3, 0                    # addi: producer, writes the link x8
    sw x27, 0(x8)                     # subject sw: consumer, reads x8 at addr, d1 (raw_addr_alu_ri_d1)
    lui x29, 317                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 318                       # quiet
    lui x7, 319                       # quiet
# block 40  raw_addr_alu_ri_d2  sw after addi  expect(isa): forward 0
    lui x0, 40  # marker: block 40
    lui x28, 320                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 321                      # quiet
    lui x6, 322                       # quiet
    addi x9, x0, 1446                 # sw's store data
    .L81: auipc x10, %pcrel_hi(w20)   # addi's operand: the identity delivers the value
    lui x7, 323                       # addi's operand: the identity delivers the value (quiet)
    lui x28, 324                      # addi's operand: the identity delivers the value (quiet)
    lui x29, 325                      # addi's operand: the identity delivers the value (quiet)
    addi x10, x10, %pcrel_lo(.L81)    # addi's operand: the identity delivers the value
    addi x8, x0, 1453                 # addi's rd before (stale)
    lui x6, 326                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 327                       # quiet
    lui x28, 328                      # quiet
    addi x8, x10, 0                   # addi: producer, writes the link x8
    lui x29, 329                      # filler (gap)
    sw x9, 0(x8)                      # subject sw: consumer, reads x8 at addr, d2 (raw_addr_alu_ri_d2)
    lui x6, 330                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 331                       # quiet
    lui x28, 332                      # quiet
# block 41  raw_addr_alu_ri_d2  sw after addi  expect(isa): forward 0
    lui x0, 41  # marker: block 41
    lui x29, 333                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 334                       # quiet
    lui x7, 335                       # quiet
    addi x11, x0, -1                  # sw's store data
    .L82: auipc x12, %pcrel_hi(w21)   # addi's operand: the identity delivers the value
    lui x28, 336                      # addi's operand: the identity delivers the value (quiet)
    lui x29, 337                      # addi's operand: the identity delivers the value (quiet)
    lui x6, 338                       # addi's operand: the identity delivers the value (quiet)
    addi x12, x12, %pcrel_lo(.L82)    # addi's operand: the identity delivers the value
    addi x4, x0, 1467                 # addi's rd before (stale)
    lui x7, 339                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 340                      # quiet
    lui x29, 341                      # quiet
    addi x4, x12, 0                   # addi: producer, writes the link x4
    lui x6, 342                       # filler (gap)
    sw x11, 0(x4)                     # subject sw: consumer, reads x4 at addr, d2 (raw_addr_alu_ri_d2)
    lui x7, 343                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 344                      # quiet
    lui x29, 345                      # quiet
# block 43  raw_addr_alu_ri_d3  sw after addi  expect(isa): none 0
    lui x0, 43  # marker: block 43
    lui x6, 346                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 347                       # quiet
    lui x28, 348                      # quiet
    addi x14, x0, 1481                # sw's store data
    .L83: auipc x15, %pcrel_hi(w22)   # addi's operand: the identity delivers the value
    lui x29, 349                      # addi's operand: the identity delivers the value (quiet)
    lui x6, 350                       # addi's operand: the identity delivers the value (quiet)
    lui x7, 351                       # addi's operand: the identity delivers the value (quiet)
    addi x15, x15, %pcrel_lo(.L83)    # addi's operand: the identity delivers the value
    addi x13, x0, 1488                # addi's rd before (stale)
    lui x28, 352                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 353                      # quiet
    lui x6, 354                       # quiet
    addi x13, x15, 0                  # addi: producer, writes the link x13
    lui x7, 355                       # filler (gap)
    lui x28, 356                      # filler (gap)
    sw x14, 0(x13)                    # subject sw: consumer, reads x13 at addr, d3 (raw_addr_alu_ri_d3)
    lui x29, 357                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 358                       # quiet
    lui x7, 359                       # quiet
# block 44  raw_addr_alu_ri_d3  sw after addi  expect(isa): none 0
    lui x0, 44  # marker: block 44
    lui x28, 360                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 361                      # quiet
    lui x6, 362                       # quiet
    addi x16, x0, 1502                # sw's store data
    .L84: auipc x17, %pcrel_hi(w23)   # addi's operand: the identity delivers the value
    lui x7, 363                       # addi's operand: the identity delivers the value (quiet)
    lui x28, 364                      # addi's operand: the identity delivers the value (quiet)
    lui x29, 365                      # addi's operand: the identity delivers the value (quiet)
    addi x17, x17, %pcrel_lo(.L84)    # addi's operand: the identity delivers the value
    addi x1, x0, 1509                 # addi's rd before (stale)
    lui x6, 366                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 367                       # quiet
    lui x28, 368                      # quiet
    addi x1, x17, 0                   # addi: producer, writes the link x1
    lui x29, 369                      # filler (gap)
    lui x6, 370                       # filler (gap)
    sw x16, 0(x1)                     # subject sw: consumer, reads x1 at addr, d3 (raw_addr_alu_ri_d3)
    lui x7, 371                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 372                      # quiet
    lui x29, 373                      # quiet
# block 46  raw_addr_alu_nosrc_d1  sw after lui  expect(isa): stall 1
    lui x0, 46  # marker: block 46
    lui x6, 374                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 375                       # quiet
    lui x28, 376                      # quiet
    addi x21, x0, -2                  # sw's store data
    addi x20, x0, 1537                # lui's rd before (stale)
    lui x29, 377                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 378                       # quiet
    lui x7, 379                       # quiet
    lui x20, %hi(w0)                  # lui: producer, writes the link x20
    sw x21, 0(x20)                    # subject sw: consumer, reads x20 at addr, d1 (raw_addr_alu_nosrc_d1)
    lui x28, 380                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 381                      # quiet
    lui x6, 382                       # quiet
# block 47  raw_addr_alu_nosrc_d1  sw after lui  expect(isa): stall 1
    lui x0, 47  # marker: block 47
    lui x7, 383                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 384                      # quiet
    lui x29, 385                      # quiet
    addi x23, x0, 1565                # sw's store data
    addi x16, x0, 1572                # lui's rd before (stale)
    lui x6, 386                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 387                       # quiet
    lui x28, 388                      # quiet
    lui x16, %hi(w0)                  # lui: producer, writes the link x16
    sw x23, 0(x16)                    # subject sw: consumer, reads x16 at addr, d1 (raw_addr_alu_nosrc_d1)
    lui x29, 389                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 390                       # quiet
    lui x7, 391                       # quiet
# block 49  raw_addr_alu_nosrc_d2  sw after lui  expect(isa): forward 0
    lui x0, 49  # marker: block 49
    lui x28, 392                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 393                      # quiet
    lui x6, 394                       # quiet
    addi x27, x0, 0                   # sw's store data
    addi x26, x0, 1600                # lui's rd before (stale)
    lui x7, 395                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 396                      # quiet
    lui x29, 397                      # quiet
    lui x26, %hi(w0)                  # lui: producer, writes the link x26
    lui x6, 398                       # filler (gap)
    sw x27, 0(x26)                    # subject sw: consumer, reads x26 at addr, d2 (raw_addr_alu_nosrc_d2)
    lui x7, 399                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 400                      # quiet
    lui x29, 401                      # quiet
# block 50  raw_addr_alu_nosrc_d2  sw after lui  expect(isa): forward 0
    lui x0, 50  # marker: block 50
    lui x6, 402                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 403                       # quiet
    lui x28, 404                      # quiet
    addi x9, x0, 1628                 # sw's store data
    addi x8, x0, 1635                 # lui's rd before (stale)
    lui x29, 405                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 406                       # quiet
    lui x7, 407                       # quiet
    lui x8, %hi(w0)                   # lui: producer, writes the link x8
    lui x28, 408                      # filler (gap)
    sw x9, 0(x8)                      # subject sw: consumer, reads x8 at addr, d2 (raw_addr_alu_nosrc_d2)
    lui x29, 409                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 410                       # quiet
    lui x7, 411                       # quiet
# block 52  raw_addr_alu_nosrc_d3  sw after lui  expect(isa): none 0
    lui x0, 52  # marker: block 52
    lui x28, 412                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 413                      # quiet
    lui x6, 414                       # quiet
    addi x13, x0, 1                   # sw's store data
    addi x12, x0, 1663                # lui's rd before (stale)
    lui x7, 415                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 416                      # quiet
    lui x29, 417                      # quiet
    lui x12, %hi(w0)                  # lui: producer, writes the link x12
    lui x6, 418                       # filler (gap)
    lui x7, 419                       # filler (gap)
    sw x13, 0(x12)                    # subject sw: consumer, reads x12 at addr, d3 (raw_addr_alu_nosrc_d3)
    lui x28, 420                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 421                      # quiet
    lui x6, 422                       # quiet
# block 53  raw_addr_alu_nosrc_d3  sw after lui  expect(isa): none 0
    lui x0, 53  # marker: block 53
    lui x7, 423                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 424                      # quiet
    lui x29, 425                      # quiet
    addi x15, x0, 1691                # sw's store data
    addi x4, x0, 1698                 # lui's rd before (stale)
    lui x6, 426                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 427                       # quiet
    lui x28, 428                      # quiet
    lui x4, %hi(w0)                   # lui: producer, writes the link x4
    lui x29, 429                      # filler (gap)
    lui x6, 430                       # filler (gap)
    sw x15, 0(x4)                     # subject sw: consumer, reads x4 at addr, d3 (raw_addr_alu_nosrc_d3)
    lui x7, 431                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 432                      # quiet
    lui x29, 433                      # quiet
# block 55  raw_data_load_d1  sw after lb  expect(isa): stall 1
    lui x0, 55  # marker: block 55
    lui x6, 434                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 435                       # quiet
    lui x28, 436                      # quiet
    .L85: auipc x17, %pcrel_hi(w24)   # sw's base -> w24
    lui x29, 437                      # sw's base -> w24 (quiet)
    lui x6, 438                       # sw's base -> w24 (quiet)
    lui x7, 439                       # sw's base -> w24 (quiet)
    addi x17, x17, %pcrel_lo(.L85)    # sw's base -> w24
    .L86: auipc x18, %pcrel_hi(w25)   # lb's base -> w25
    lui x28, 440                      # lb's base -> w25 (quiet)
    lui x29, 441                      # lb's base -> w25 (quiet)
    lui x6, 442                       # lb's base -> w25 (quiet)
    addi x18, x18, %pcrel_lo(.L86)    # lb's base -> w25
    addi x16, x0, 1719                # lb's rd before (stale)
    lui x7, 443                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 444                      # quiet
    lui x29, 445                      # quiet
    lb x16, 0(x18)                    # lb: producer, writes the link x16
    sw x16, 0(x17)                    # subject sw: consumer, reads x16 at data, d1 (raw_data_load_d1)
    lui x6, 446                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 447                       # quiet
    lui x28, 448                      # quiet
# block 56  raw_data_load_d1  sw after lb  expect(isa): stall 1
    lui x0, 56  # marker: block 56
    lui x29, 449                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 450                       # quiet
    lui x7, 451                       # quiet
    .L87: auipc x19, %pcrel_hi(w26)   # sw's base -> w26
    lui x28, 452                      # sw's base -> w26 (quiet)
    lui x29, 453                      # sw's base -> w26 (quiet)
    lui x6, 454                       # sw's base -> w26 (quiet)
    addi x19, x19, %pcrel_lo(.L87)    # sw's base -> w26
    .L88: auipc x20, %pcrel_hi(w27)   # lb's base -> w27
    lui x7, 455                       # lb's base -> w27 (quiet)
    lui x28, 456                      # lb's base -> w27 (quiet)
    lui x29, 457                      # lb's base -> w27 (quiet)
    addi x20, x20, %pcrel_lo(.L88)    # lb's base -> w27
    addi x1, x0, 1747                 # lb's rd before (stale)
    lui x6, 458                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 459                       # quiet
    lui x28, 460                      # quiet
    lb x1, 0(x20)                     # lb: producer, writes the link x1
    sw x1, 0(x19)                     # subject sw: consumer, reads x1 at data, d1 (raw_data_load_d1)
    lui x29, 461                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 462                       # quiet
    lui x7, 463                       # quiet
# block 57  raw_data_load_d1_x0  sw after lb  expect(isa): none 0
    lui x0, 57  # marker: block 57
    lui x28, 464                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 465                      # quiet
    lui x6, 466                       # quiet
    .L89: auipc x21, %pcrel_hi(w28)   # sw's base -> w28
    lui x7, 467                       # sw's base -> w28 (quiet)
    lui x28, 468                      # sw's base -> w28 (quiet)
    lui x29, 469                      # sw's base -> w28 (quiet)
    addi x21, x21, %pcrel_lo(.L89)    # sw's base -> w28
    .L90: auipc x22, %pcrel_hi(w29)   # lb's base -> w29
    lui x6, 470                       # lb's base -> w29 (quiet)
    lui x7, 471                       # lb's base -> w29 (quiet)
    lui x28, 472                      # lb's base -> w29 (quiet)
    addi x22, x22, %pcrel_lo(.L90)    # lb's base -> w29
    lui x29, 473                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 474                       # quiet
    lui x7, 475                       # quiet
    lb x0, 0(x22)                     # lb: producer, writes the link x0
    sw x0, 0(x21)                     # subject sw: consumer, reads x0 at data, d1 (raw_data_load_d1_x0)
    lui x28, 476                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 477                      # quiet
    lui x6, 478                       # quiet
# block 58  raw_data_load_d2  sw after lb  expect(isa): forward 0
    lui x0, 58  # marker: block 58
    lui x7, 479                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 480                      # quiet
    lui x29, 481                      # quiet
    .L91: auipc x24, %pcrel_hi(w30)   # sw's base -> w30
    lui x6, 482                       # sw's base -> w30 (quiet)
    lui x7, 483                       # sw's base -> w30 (quiet)
    lui x28, 484                      # sw's base -> w30 (quiet)
    addi x24, x24, %pcrel_lo(.L91)    # sw's base -> w30
    .L92: auipc x25, %pcrel_hi(w31)   # lb's base -> w31
    lui x29, 485                      # lb's base -> w31 (quiet)
    lui x6, 486                       # lb's base -> w31 (quiet)
    lui x7, 487                       # lb's base -> w31 (quiet)
    addi x25, x25, %pcrel_lo(.L92)    # lb's base -> w31
    addi x23, x0, 1803                # lb's rd before (stale)
    lui x28, 488                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 489                      # quiet
    lui x6, 490                       # quiet
    lb x23, 0(x25)                    # lb: producer, writes the link x23
    lui x7, 491                       # filler (gap)
    sw x23, 0(x24)                    # subject sw: consumer, reads x23 at data, d2 (raw_data_load_d2)
    lui x28, 492                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 493                      # quiet
    lui x6, 494                       # quiet
# block 59  raw_data_load_d2  sw after lb  expect(isa): forward 0
    lui x0, 59  # marker: block 59
    lui x7, 495                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 496                      # quiet
    lui x29, 497                      # quiet
    .L93: auipc x26, %pcrel_hi(w32)   # sw's base -> w32
    lui x6, 498                       # sw's base -> w32 (quiet)
    lui x7, 499                       # sw's base -> w32 (quiet)
    lui x28, 500                      # sw's base -> w32 (quiet)
    addi x26, x26, %pcrel_lo(.L93)    # sw's base -> w32
    .L94: auipc x27, %pcrel_hi(w33)   # lb's base -> w33
    lui x29, 501                      # lb's base -> w33 (quiet)
    lui x6, 502                       # lb's base -> w33 (quiet)
    lui x7, 503                       # lb's base -> w33 (quiet)
    addi x27, x27, %pcrel_lo(.L94)    # lb's base -> w33
    addi x16, x0, 1831                # lb's rd before (stale)
    lui x28, 504                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 505                      # quiet
    lui x6, 506                       # quiet
    lb x16, 0(x27)                    # lb: producer, writes the link x16
    lui x7, 507                       # filler (gap)
    sw x16, 0(x26)                    # subject sw: consumer, reads x16 at data, d2 (raw_data_load_d2)
    lui x28, 508                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 509                      # quiet
    lui x6, 510                       # quiet
# block 60  raw_data_load_d2_x0  sw after lb  expect(isa): none 0
    lui x0, 60  # marker: block 60
    lui x7, 511                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 512                      # quiet
    lui x29, 513                      # quiet
    .L95: auipc x3, %pcrel_hi(w34)    # sw's base -> w34
    lui x6, 514                       # sw's base -> w34 (quiet)
    lui x7, 515                       # sw's base -> w34 (quiet)
    lui x28, 516                      # sw's base -> w34 (quiet)
    addi x3, x3, %pcrel_lo(.L95)      # sw's base -> w34
    .L96: auipc x8, %pcrel_hi(w35)    # lb's base -> w35
    lui x29, 517                      # lb's base -> w35 (quiet)
    lui x6, 518                       # lb's base -> w35 (quiet)
    lui x7, 519                       # lb's base -> w35 (quiet)
    addi x8, x8, %pcrel_lo(.L96)      # lb's base -> w35
    lui x28, 520                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 521                      # quiet
    lui x6, 522                       # quiet
    lb x0, 0(x8)                      # lb: producer, writes the link x0
    lui x7, 523                       # filler (gap)
    sw x0, 0(x3)                      # subject sw: consumer, reads x0 at data, d2 (raw_data_load_d2_x0)
    lui x28, 524                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 525                      # quiet
    lui x6, 526                       # quiet
# block 61  raw_data_load_d3  sw after lb  expect(isa): none 0
    lui x0, 61  # marker: block 61
    lui x7, 527                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 528                      # quiet
    lui x29, 529                      # quiet
    .L97: auipc x10, %pcrel_hi(w36)   # sw's base -> w36
    lui x6, 530                       # sw's base -> w36 (quiet)
    lui x7, 531                       # sw's base -> w36 (quiet)
    lui x28, 532                      # sw's base -> w36 (quiet)
    addi x10, x10, %pcrel_lo(.L97)    # sw's base -> w36
    .L98: auipc x11, %pcrel_hi(w37)   # lb's base -> w37
    lui x29, 533                      # lb's base -> w37 (quiet)
    lui x6, 534                       # lb's base -> w37 (quiet)
    lui x7, 535                       # lb's base -> w37 (quiet)
    addi x11, x11, %pcrel_lo(.L98)    # lb's base -> w37
    addi x9, x0, 1887                 # lb's rd before (stale)
    lui x28, 536                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 537                      # quiet
    lui x6, 538                       # quiet
    lb x9, 0(x11)                     # lb: producer, writes the link x9
    lui x7, 539                       # filler (gap)
    lui x28, 540                      # filler (gap)
    sw x9, 0(x10)                     # subject sw: consumer, reads x9 at data, d3 (raw_data_load_d3)
    lui x29, 541                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 542                       # quiet
    lui x7, 543                       # quiet
# block 62  raw_data_load_d3  sw after lb  expect(isa): none 0
    lui x0, 62  # marker: block 62
    lui x28, 544                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 545                      # quiet
    lui x6, 546                       # quiet
    .L99: auipc x12, %pcrel_hi(w38)   # sw's base -> w38
    lui x7, 547                       # sw's base -> w38 (quiet)
    lui x28, 548                      # sw's base -> w38 (quiet)
    lui x29, 549                      # sw's base -> w38 (quiet)
    addi x12, x12, %pcrel_lo(.L99)    # sw's base -> w38
    .L100: auipc x13, %pcrel_hi(w39)  # lb's base -> w39
    lui x6, 550                       # lb's base -> w39 (quiet)
    lui x7, 551                       # lb's base -> w39 (quiet)
    lui x28, 552                      # lb's base -> w39 (quiet)
    addi x13, x13, %pcrel_lo(.L100)   # lb's base -> w39
    addi x8, x0, 1915                 # lb's rd before (stale)
    lui x29, 553                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 554                       # quiet
    lui x7, 555                       # quiet
    lb x8, 0(x13)                     # lb: producer, writes the link x8
    lui x28, 556                      # filler (gap)
    lui x29, 557                      # filler (gap)
    sw x8, 0(x12)                     # subject sw: consumer, reads x8 at data, d3 (raw_data_load_d3)
    lui x6, 558                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 559                       # quiet
    lui x28, 560                      # quiet
# block 63  raw_data_load_d3_x0  sw after lb  expect(isa): none 0
    lui x0, 63  # marker: block 63
    lui x29, 561                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 562                       # quiet
    lui x7, 563                       # quiet
    .L101: auipc x14, %pcrel_hi(w40)  # sw's base -> w40
    lui x28, 564                      # sw's base -> w40 (quiet)
    lui x29, 565                      # sw's base -> w40 (quiet)
    lui x6, 566                       # sw's base -> w40 (quiet)
    addi x14, x14, %pcrel_lo(.L101)   # sw's base -> w40
    .L102: auipc x15, %pcrel_hi(w41)  # lb's base -> w41
    lui x7, 567                       # lb's base -> w41 (quiet)
    lui x28, 568                      # lb's base -> w41 (quiet)
    lui x29, 569                      # lb's base -> w41 (quiet)
    addi x15, x15, %pcrel_lo(.L102)   # lb's base -> w41
    lui x6, 570                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 571                       # quiet
    lui x28, 572                      # quiet
    lb x0, 0(x15)                     # lb: producer, writes the link x0
    lui x29, 573                      # filler (gap)
    lui x6, 574                       # filler (gap)
    sw x0, 0(x14)                     # subject sw: consumer, reads x0 at data, d3 (raw_data_load_d3_x0)
    lui x7, 575                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 576                      # quiet
    lui x29, 577                      # quiet
# block 64  raw_data_jalr_d1  sw after jalr  expect(isa): stall 1
    lui x0, 64  # marker: block 64
    lui x6, 578                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 579                       # quiet
    lui x28, 580                      # quiet
    .L103: auipc x17, %pcrel_hi(w42)  # sw's base -> w42
    lui x29, 581                      # sw's base -> w42 (quiet)
    lui x6, 582                       # sw's base -> w42 (quiet)
    lui x7, 583                       # sw's base -> w42 (quiet)
    addi x17, x17, %pcrel_lo(.L103)   # sw's base -> w42
    .L105: auipc x18, %pcrel_hi(.L104) # jalr's target -> .L104, the label after it
    lui x28, 584                      # jalr's target -> .L104, the label after it (quiet)
    lui x29, 585                      # jalr's target -> .L104, the label after it (quiet)
    lui x6, 586                       # jalr's target -> .L104, the label after it (quiet)
    addi x18, x18, %pcrel_lo(.L105)   # jalr's target -> .L104, the label after it
    addi x16, x0, 1971                # jalr's rd before (stale)
    lui x7, 587                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 588                      # quiet
    lui x29, 589                      # quiet
    jalr x16, 0(x18)                  # jalr: producer, writes the link x16
.L104:
    sw x16, 0(x17)                    # subject sw: consumer, reads x16 at data, d1 (raw_data_jalr_d1)
    lui x6, 590                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 591                       # quiet
    lui x28, 592                      # quiet
# block 65  raw_data_jalr_d1  sw after jalr  expect(isa): stall 1
    lui x0, 65  # marker: block 65
    lui x29, 593                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 594                       # quiet
    lui x7, 595                       # quiet
    .L106: auipc x19, %pcrel_hi(w43)  # sw's base -> w43
    lui x28, 596                      # sw's base -> w43 (quiet)
    lui x29, 597                      # sw's base -> w43 (quiet)
    lui x6, 598                       # sw's base -> w43 (quiet)
    addi x19, x19, %pcrel_lo(.L106)   # sw's base -> w43
    .L108: auipc x20, %pcrel_hi(.L107) # jalr's target -> .L107, the label after it
    lui x7, 599                       # jalr's target -> .L107, the label after it (quiet)
    lui x28, 600                      # jalr's target -> .L107, the label after it (quiet)
    lui x29, 601                      # jalr's target -> .L107, the label after it (quiet)
    addi x20, x20, %pcrel_lo(.L108)   # jalr's target -> .L107, the label after it
    addi x4, x0, 1992                 # jalr's rd before (stale)
    lui x6, 602                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 603                       # quiet
    lui x28, 604                      # quiet
    jalr x4, 0(x20)                   # jalr: producer, writes the link x4
.L107:
    sw x4, 0(x19)                     # subject sw: consumer, reads x4 at data, d1 (raw_data_jalr_d1)
    lui x29, 605                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 606                       # quiet
    lui x7, 607                       # quiet
# block 66  raw_data_jalr_d1_x0  sw after jalr  expect(isa): none 0
    lui x0, 66  # marker: block 66
    lui x28, 608                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 609                      # quiet
    lui x6, 610                       # quiet
    .L109: auipc x21, %pcrel_hi(w44)  # sw's base -> w44
    lui x7, 611                       # sw's base -> w44 (quiet)
    lui x28, 612                      # sw's base -> w44 (quiet)
    lui x29, 613                      # sw's base -> w44 (quiet)
    addi x21, x21, %pcrel_lo(.L109)   # sw's base -> w44
    .L111: auipc x22, %pcrel_hi(.L110) # jalr's target -> .L110, the label after it
    lui x6, 614                       # jalr's target -> .L110, the label after it (quiet)
    lui x7, 615                       # jalr's target -> .L110, the label after it (quiet)
    lui x28, 616                      # jalr's target -> .L110, the label after it (quiet)
    addi x22, x22, %pcrel_lo(.L111)   # jalr's target -> .L110, the label after it
    lui x29, 617                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 618                       # quiet
    lui x7, 619                       # quiet
    jalr x0, 0(x22)                   # jalr: producer, writes the link x0
.L110:
    sw x0, 0(x21)                     # subject sw: consumer, reads x0 at data, d1 (raw_data_jalr_d1_x0)
    lui x28, 620                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 621                      # quiet
    lui x6, 622                       # quiet
# block 67  raw_data_jalr_d2  sw after jalr  expect(isa): forward 0
    lui x0, 67  # marker: block 67
    lui x7, 623                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 624                      # quiet
    lui x29, 625                      # quiet
    .L112: auipc x24, %pcrel_hi(w45)  # sw's base -> w45
    lui x6, 626                       # sw's base -> w45 (quiet)
    lui x7, 627                       # sw's base -> w45 (quiet)
    lui x28, 628                      # sw's base -> w45 (quiet)
    addi x24, x24, %pcrel_lo(.L112)   # sw's base -> w45
    .L114: auipc x25, %pcrel_hi(.L113) # jalr's target -> .L113, the label after it
    lui x29, 629                      # jalr's target -> .L113, the label after it (quiet)
    lui x6, 630                       # jalr's target -> .L113, the label after it (quiet)
    lui x7, 631                       # jalr's target -> .L113, the label after it (quiet)
    addi x25, x25, %pcrel_lo(.L114)   # jalr's target -> .L113, the label after it
    addi x23, x0, 258                 # jalr's rd before (stale)
    lui x28, 632                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 633                      # quiet
    lui x6, 634                       # quiet
    jalr x23, 0(x25)                  # jalr: producer, writes the link x23
.L113:
    lui x7, 635                       # filler (gap)
    sw x23, 0(x24)                    # subject sw: consumer, reads x23 at data, d2 (raw_data_jalr_d2)
    lui x28, 636                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 637                      # quiet
    lui x6, 638                       # quiet
# block 68  raw_data_jalr_d2  sw after jalr  expect(isa): forward 0
    lui x0, 68  # marker: block 68
    lui x7, 639                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 640                      # quiet
    lui x29, 641                      # quiet
    .L115: auipc x26, %pcrel_hi(w46)  # sw's base -> w46
    lui x6, 642                       # sw's base -> w46 (quiet)
    lui x7, 643                       # sw's base -> w46 (quiet)
    lui x28, 644                      # sw's base -> w46 (quiet)
    addi x26, x26, %pcrel_lo(.L115)   # sw's base -> w46
    .L117: auipc x27, %pcrel_hi(.L116) # jalr's target -> .L116, the label after it
    lui x29, 645                      # jalr's target -> .L116, the label after it (quiet)
    lui x6, 646                       # jalr's target -> .L116, the label after it (quiet)
    lui x7, 647                       # jalr's target -> .L116, the label after it (quiet)
    addi x27, x27, %pcrel_lo(.L117)   # jalr's target -> .L116, the label after it
    addi x1, x0, 279                  # jalr's rd before (stale)
    lui x28, 648                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 649                      # quiet
    lui x6, 650                       # quiet
    jalr x1, 0(x27)                   # jalr: producer, writes the link x1
.L116:
    lui x7, 651                       # filler (gap)
    sw x1, 0(x26)                     # subject sw: consumer, reads x1 at data, d2 (raw_data_jalr_d2)
    lui x28, 652                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 653                      # quiet
    lui x6, 654                       # quiet
# block 69  raw_data_jalr_d2_x0  sw after jalr  expect(isa): none 0
    lui x0, 69  # marker: block 69
    lui x7, 655                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 656                      # quiet
    lui x29, 657                      # quiet
    .L118: auipc x3, %pcrel_hi(w47)   # sw's base -> w47
    lui x6, 658                       # sw's base -> w47 (quiet)
    lui x7, 659                       # sw's base -> w47 (quiet)
    lui x28, 660                      # sw's base -> w47 (quiet)
    addi x3, x3, %pcrel_lo(.L118)     # sw's base -> w47
    .L120: auipc x8, %pcrel_hi(.L119) # jalr's target -> .L119, the label after it
    lui x29, 661                      # jalr's target -> .L119, the label after it (quiet)
    lui x6, 662                       # jalr's target -> .L119, the label after it (quiet)
    lui x7, 663                       # jalr's target -> .L119, the label after it (quiet)
    addi x8, x8, %pcrel_lo(.L120)     # jalr's target -> .L119, the label after it
    lui x28, 664                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 665                      # quiet
    lui x6, 666                       # quiet
    jalr x0, 0(x8)                    # jalr: producer, writes the link x0
.L119:
    lui x7, 667                       # filler (gap)
    sw x0, 0(x3)                      # subject sw: consumer, reads x0 at data, d2 (raw_data_jalr_d2_x0)
    lui x28, 668                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 669                      # quiet
    lui x6, 670                       # quiet
# block 70  raw_data_jalr_d3  sw after jalr  expect(isa): none 0
    lui x0, 70  # marker: block 70
    lui x7, 671                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 672                      # quiet
    lui x29, 673                      # quiet
    .L121: auipc x10, %pcrel_hi(w48)  # sw's base -> w48
    lui x6, 674                       # sw's base -> w48 (quiet)
    lui x7, 675                       # sw's base -> w48 (quiet)
    lui x28, 676                      # sw's base -> w48 (quiet)
    addi x10, x10, %pcrel_lo(.L121)   # sw's base -> w48
    .L123: auipc x11, %pcrel_hi(.L122) # jalr's target -> .L122, the label after it
    lui x29, 677                      # jalr's target -> .L122, the label after it (quiet)
    lui x6, 678                       # jalr's target -> .L122, the label after it (quiet)
    lui x7, 679                       # jalr's target -> .L122, the label after it (quiet)
    addi x11, x11, %pcrel_lo(.L123)   # jalr's target -> .L122, the label after it
    addi x9, x0, 321                  # jalr's rd before (stale)
    lui x28, 680                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 681                      # quiet
    lui x6, 682                       # quiet
    jalr x9, 0(x11)                   # jalr: producer, writes the link x9
.L122:
    lui x7, 683                       # filler (gap)
    lui x28, 684                      # filler (gap)
    sw x9, 0(x10)                     # subject sw: consumer, reads x9 at data, d3 (raw_data_jalr_d3)
    lui x29, 685                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 686                       # quiet
    lui x7, 687                       # quiet
# block 71  raw_data_jalr_d3  sw after jalr  expect(isa): none 0
    lui x0, 71  # marker: block 71
    lui x28, 688                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 689                      # quiet
    lui x6, 690                       # quiet
    .L124: auipc x12, %pcrel_hi(w49)  # sw's base -> w49
    lui x7, 691                       # sw's base -> w49 (quiet)
    lui x28, 692                      # sw's base -> w49 (quiet)
    lui x29, 693                      # sw's base -> w49 (quiet)
    addi x12, x12, %pcrel_lo(.L124)   # sw's base -> w49
    .L126: auipc x13, %pcrel_hi(.L125) # jalr's target -> .L125, the label after it
    lui x6, 694                       # jalr's target -> .L125, the label after it (quiet)
    lui x7, 695                       # jalr's target -> .L125, the label after it (quiet)
    lui x28, 696                      # jalr's target -> .L125, the label after it (quiet)
    addi x13, x13, %pcrel_lo(.L126)   # jalr's target -> .L125, the label after it
    addi x16, x0, 342                 # jalr's rd before (stale)
    lui x29, 697                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 698                       # quiet
    lui x7, 699                       # quiet
    jalr x16, 0(x13)                  # jalr: producer, writes the link x16
.L125:
    lui x28, 700                      # filler (gap)
    lui x29, 701                      # filler (gap)
    sw x16, 0(x12)                    # subject sw: consumer, reads x16 at data, d3 (raw_data_jalr_d3)
    lui x6, 702                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 703                       # quiet
    lui x28, 704                      # quiet
# block 72  raw_data_jalr_d3_x0  sw after jalr  expect(isa): none 0
    lui x0, 72  # marker: block 72
    lui x29, 705                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 706                       # quiet
    lui x7, 707                       # quiet
    .L127: auipc x14, %pcrel_hi(w50)  # sw's base -> w50
    lui x28, 708                      # sw's base -> w50 (quiet)
    lui x29, 709                      # sw's base -> w50 (quiet)
    lui x6, 710                       # sw's base -> w50 (quiet)
    addi x14, x14, %pcrel_lo(.L127)   # sw's base -> w50
    .L129: auipc x15, %pcrel_hi(.L128) # jalr's target -> .L128, the label after it
    lui x7, 711                       # jalr's target -> .L128, the label after it (quiet)
    lui x28, 712                      # jalr's target -> .L128, the label after it (quiet)
    lui x29, 713                      # jalr's target -> .L128, the label after it (quiet)
    addi x15, x15, %pcrel_lo(.L129)   # jalr's target -> .L128, the label after it
    lui x6, 714                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 715                       # quiet
    lui x28, 716                      # quiet
    jalr x0, 0(x15)                   # jalr: producer, writes the link x0
.L128:
    lui x29, 717                      # filler (gap)
    lui x6, 718                       # filler (gap)
    sw x0, 0(x14)                     # subject sw: consumer, reads x0 at data, d3 (raw_data_jalr_d3_x0)
    lui x7, 719                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 720                      # quiet
    lui x29, 721                      # quiet
# block 73  raw_data_jal_d1  sw after jal  expect(isa): stall 1
    lui x0, 73  # marker: block 73
    lui x6, 722                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 723                       # quiet
    lui x28, 724                      # quiet
    .L130: auipc x17, %pcrel_hi(w51)  # sw's base -> w51
    lui x29, 725                      # sw's base -> w51 (quiet)
    lui x6, 726                       # sw's base -> w51 (quiet)
    lui x7, 727                       # sw's base -> w51 (quiet)
    addi x17, x17, %pcrel_lo(.L130)   # sw's base -> w51
    addi x16, x0, 384                 # jal's rd before (stale)
    lui x28, 728                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 729                      # quiet
    lui x6, 730                       # quiet
    jal x16, .L131                    # jal: producer, writes the link x16
.L131:
    sw x16, 0(x17)                    # subject sw: consumer, reads x16 at data, d1 (raw_data_jal_d1)
    lui x7, 731                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 732                      # quiet
    lui x29, 733                      # quiet
# block 74  raw_data_jal_d1  sw after jal  expect(isa): stall 1
    lui x0, 74  # marker: block 74
    lui x6, 734                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 735                       # quiet
    lui x28, 736                      # quiet
    .L132: auipc x18, %pcrel_hi(w52)  # sw's base -> w52
    lui x29, 737                      # sw's base -> w52 (quiet)
    lui x6, 738                       # sw's base -> w52 (quiet)
    lui x7, 739                       # sw's base -> w52 (quiet)
    addi x18, x18, %pcrel_lo(.L132)   # sw's base -> w52
    addi x8, x0, 405                  # jal's rd before (stale)
    lui x28, 740                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 741                      # quiet
    lui x6, 742                       # quiet
    jal x8, .L133                     # jal: producer, writes the link x8
.L133:
    sw x8, 0(x18)                     # subject sw: consumer, reads x8 at data, d1 (raw_data_jal_d1)
    lui x7, 743                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 744                      # quiet
    lui x29, 745                      # quiet
# block 75  raw_data_jal_d1_x0  sw after jal  expect(isa): none 0
    lui x0, 75  # marker: block 75
    lui x6, 746                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 747                       # quiet
    lui x28, 748                      # quiet
    .L134: auipc x19, %pcrel_hi(w53)  # sw's base -> w53
    lui x29, 749                      # sw's base -> w53 (quiet)
    lui x6, 750                       # sw's base -> w53 (quiet)
    lui x7, 751                       # sw's base -> w53 (quiet)
    addi x19, x19, %pcrel_lo(.L134)   # sw's base -> w53
    lui x28, 752                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 753                      # quiet
    lui x6, 754                       # quiet
    jal x0, .L135                     # jal: producer, writes the link x0
.L135:
    sw x0, 0(x19)                     # subject sw: consumer, reads x0 at data, d1 (raw_data_jal_d1_x0)
    lui x7, 755                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 756                      # quiet
    lui x29, 757                      # quiet
# block 76  raw_data_jal_d2  sw after jal  expect(isa): forward 0
    lui x0, 76  # marker: block 76
    lui x6, 758                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 759                       # quiet
    lui x28, 760                      # quiet
    .L136: auipc x21, %pcrel_hi(w54)  # sw's base -> w54
    lui x29, 761                      # sw's base -> w54 (quiet)
    lui x6, 762                       # sw's base -> w54 (quiet)
    lui x7, 763                       # sw's base -> w54 (quiet)
    addi x21, x21, %pcrel_lo(.L136)   # sw's base -> w54
    addi x20, x0, 447                 # jal's rd before (stale)
    lui x28, 764                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 765                      # quiet
    lui x6, 766                       # quiet
    jal x20, .L137                    # jal: producer, writes the link x20
.L137:
    lui x7, 767                       # filler (gap)
    sw x20, 0(x21)                    # subject sw: consumer, reads x20 at data, d2 (raw_data_jal_d2)
    lui x28, 768                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 769                      # quiet
    lui x6, 770                       # quiet
# block 77  raw_data_jal_d2  sw after jal  expect(isa): forward 0
    lui x0, 77  # marker: block 77
    lui x7, 771                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 772                      # quiet
    lui x29, 773                      # quiet
    .L138: auipc x22, %pcrel_hi(w55)  # sw's base -> w55
    lui x6, 774                       # sw's base -> w55 (quiet)
    lui x7, 775                       # sw's base -> w55 (quiet)
    lui x28, 776                      # sw's base -> w55 (quiet)
    addi x22, x22, %pcrel_lo(.L138)   # sw's base -> w55
    addi x4, x0, 468                  # jal's rd before (stale)
    lui x29, 777                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 778                       # quiet
    lui x7, 779                       # quiet
    jal x4, .L139                     # jal: producer, writes the link x4
.L139:
    lui x28, 780                      # filler (gap)
    sw x4, 0(x22)                     # subject sw: consumer, reads x4 at data, d2 (raw_data_jal_d2)
    lui x29, 781                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 782                       # quiet
    lui x7, 783                       # quiet
# block 78  raw_data_jal_d2_x0  sw after jal  expect(isa): none 0
    lui x0, 78  # marker: block 78
    lui x28, 784                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 785                      # quiet
    lui x6, 786                       # quiet
    .L140: auipc x23, %pcrel_hi(w56)  # sw's base -> w56
    lui x7, 787                       # sw's base -> w56 (quiet)
    lui x28, 788                      # sw's base -> w56 (quiet)
    lui x29, 789                      # sw's base -> w56 (quiet)
    addi x23, x23, %pcrel_lo(.L140)   # sw's base -> w56
    lui x6, 790                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 791                       # quiet
    lui x28, 792                      # quiet
    jal x0, .L141                     # jal: producer, writes the link x0
.L141:
    lui x29, 793                      # filler (gap)
    sw x0, 0(x23)                     # subject sw: consumer, reads x0 at data, d2 (raw_data_jal_d2_x0)
    lui x6, 794                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 795                       # quiet
    lui x28, 796                      # quiet
# block 79  raw_data_jal_d3  sw after jal  expect(isa): none 0
    lui x0, 79  # marker: block 79
    lui x29, 797                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 798                       # quiet
    lui x7, 799                       # quiet
    .L142: auipc x25, %pcrel_hi(w57)  # sw's base -> w57
    lui x28, 800                      # sw's base -> w57 (quiet)
    lui x29, 801                      # sw's base -> w57 (quiet)
    lui x6, 802                       # sw's base -> w57 (quiet)
    addi x25, x25, %pcrel_lo(.L142)   # sw's base -> w57
    addi x24, x0, 510                 # jal's rd before (stale)
    lui x7, 803                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 804                      # quiet
    lui x29, 805                      # quiet
    jal x24, .L143                    # jal: producer, writes the link x24
.L143:
    lui x6, 806                       # filler (gap)
    lui x7, 807                       # filler (gap)
    sw x24, 0(x25)                    # subject sw: consumer, reads x24 at data, d3 (raw_data_jal_d3)
    lui x28, 808                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 809                      # quiet
    lui x6, 810                       # quiet
# block 80  raw_data_jal_d3  sw after jal  expect(isa): none 0
    lui x0, 80  # marker: block 80
    lui x7, 811                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 812                      # quiet
    lui x29, 813                      # quiet
    .L144: auipc x26, %pcrel_hi(w58)  # sw's base -> w58
    lui x6, 814                       # sw's base -> w58 (quiet)
    lui x7, 815                       # sw's base -> w58 (quiet)
    lui x28, 816                      # sw's base -> w58 (quiet)
    addi x26, x26, %pcrel_lo(.L144)   # sw's base -> w58
    addi x1, x0, 531                  # jal's rd before (stale)
    lui x29, 817                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 818                       # quiet
    lui x7, 819                       # quiet
    jal x1, .L145                     # jal: producer, writes the link x1
.L145:
    lui x28, 820                      # filler (gap)
    lui x29, 821                      # filler (gap)
    sw x1, 0(x26)                     # subject sw: consumer, reads x1 at data, d3 (raw_data_jal_d3)
    lui x6, 822                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 823                       # quiet
    lui x28, 824                      # quiet
# block 81  raw_data_jal_d3_x0  sw after jal  expect(isa): none 0
    lui x0, 81  # marker: block 81
    lui x29, 825                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 826                       # quiet
    lui x7, 827                       # quiet
    .L146: auipc x27, %pcrel_hi(w59)  # sw's base -> w59
    lui x28, 828                      # sw's base -> w59 (quiet)
    lui x29, 829                      # sw's base -> w59 (quiet)
    lui x6, 830                       # sw's base -> w59 (quiet)
    addi x27, x27, %pcrel_lo(.L146)   # sw's base -> w59
    lui x7, 831                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 832                      # quiet
    lui x29, 833                      # quiet
    jal x0, .L147                     # jal: producer, writes the link x0
.L147:
    lui x6, 834                       # filler (gap)
    lui x7, 835                       # filler (gap)
    sw x0, 0(x27)                     # subject sw: consumer, reads x0 at data, d3 (raw_data_jal_d3_x0)
    lui x28, 836                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 837                      # quiet
    lui x6, 838                       # quiet
# block 82  raw_data_alu_rr_d1  sw after add  expect(isa): stall 1
    lui x0, 82  # marker: block 82
    lui x7, 839                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 840                      # quiet
    lui x29, 841                      # quiet
    .L148: auipc x8, %pcrel_hi(w60)   # sw's base -> w60
    lui x6, 842                       # sw's base -> w60 (quiet)
    lui x7, 843                       # sw's base -> w60 (quiet)
    lui x28, 844                      # sw's base -> w60 (quiet)
    addi x8, x8, %pcrel_lo(.L148)     # sw's base -> w60
    addi x9, x0, 559                  # add's operand: the identity delivers the value
    addi x10, x0, 0                   # add's operand: the identity delivers the value
    addi x3, x0, 573                  # add's rd before (stale)
    lui x29, 845                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 846                       # quiet
    lui x7, 847                       # quiet
    add x3, x9, x10                   # add: producer, writes the link x3
    sw x3, 0(x8)                      # subject sw: consumer, reads x3 at data, d1 (raw_data_alu_rr_d1)
    lui x28, 848                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 849                      # quiet
    lui x6, 850                       # quiet
# block 83  raw_data_alu_rr_d1  sw after add  expect(isa): stall 1
    lui x0, 83  # marker: block 83
    lui x7, 851                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 852                      # quiet
    lui x29, 853                      # quiet
    .L149: auipc x11, %pcrel_hi(w61)  # sw's base -> w61
    lui x6, 854                       # sw's base -> w61 (quiet)
    lui x7, 855                       # sw's base -> w61 (quiet)
    lui x28, 856                      # sw's base -> w61 (quiet)
    addi x11, x11, %pcrel_lo(.L149)   # sw's base -> w61
    addi x12, x0, 580                 # add's operand: the identity delivers the value
    addi x13, x0, 0                   # add's operand: the identity delivers the value
    addi x16, x0, 594                 # add's rd before (stale)
    lui x29, 857                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 858                       # quiet
    lui x7, 859                       # quiet
    add x16, x12, x13                 # add: producer, writes the link x16
    sw x16, 0(x11)                    # subject sw: consumer, reads x16 at data, d1 (raw_data_alu_rr_d1)
    lui x28, 860                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 861                      # quiet
    lui x6, 862                       # quiet
# block 84  raw_data_alu_rr_d1_x0  sw after add  expect(isa): none 0
    lui x0, 84  # marker: block 84
    lui x7, 863                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 864                      # quiet
    lui x29, 865                      # quiet
    .L150: auipc x14, %pcrel_hi(w62)  # sw's base -> w62
    lui x6, 866                       # sw's base -> w62 (quiet)
    lui x7, 867                       # sw's base -> w62 (quiet)
    lui x28, 868                      # sw's base -> w62 (quiet)
    addi x14, x14, %pcrel_lo(.L150)   # sw's base -> w62
    addi x15, x0, 601                 # add's operand: the identity delivers the value
    addi x16, x0, 0                   # add's operand: the identity delivers the value
    lui x29, 869                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 870                       # quiet
    lui x7, 871                       # quiet
    add x0, x15, x16                  # add: producer, writes the link x0
    sw x0, 0(x14)                     # subject sw: consumer, reads x0 at data, d1 (raw_data_alu_rr_d1_x0)
    lui x28, 872                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 873                      # quiet
    lui x6, 874                       # quiet
# block 85  raw_data_alu_rr_d2  sw after add  expect(isa): forward 0
    lui x0, 85  # marker: block 85
    lui x7, 875                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 876                      # quiet
    lui x29, 877                      # quiet
    .L151: auipc x18, %pcrel_hi(w63)  # sw's base -> w63
    lui x6, 878                       # sw's base -> w63 (quiet)
    lui x7, 879                       # sw's base -> w63 (quiet)
    lui x28, 880                      # sw's base -> w63 (quiet)
    addi x18, x18, %pcrel_lo(.L151)   # sw's base -> w63
    addi x19, x0, 622                 # add's operand: the identity delivers the value
    addi x20, x0, 0                   # add's operand: the identity delivers the value
    addi x17, x0, 636                 # add's rd before (stale)
    lui x29, 881                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 882                       # quiet
    lui x7, 883                       # quiet
    add x17, x19, x20                 # add: producer, writes the link x17
    lui x28, 884                      # filler (gap)
    sw x17, 0(x18)                    # subject sw: consumer, reads x17 at data, d2 (raw_data_alu_rr_d2)
    lui x29, 885                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 886                       # quiet
    lui x7, 887                       # quiet
# block 86  raw_data_alu_rr_d2  sw after add  expect(isa): forward 0
    lui x0, 86  # marker: block 86
    lui x28, 888                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 889                      # quiet
    lui x6, 890                       # quiet
    .L152: auipc x21, %pcrel_hi(w64)  # sw's base -> w64
    lui x7, 891                       # sw's base -> w64 (quiet)
    lui x28, 892                      # sw's base -> w64 (quiet)
    lui x29, 893                      # sw's base -> w64 (quiet)
    addi x21, x21, %pcrel_lo(.L152)   # sw's base -> w64
    addi x22, x0, 643                 # add's operand: the identity delivers the value
    addi x23, x0, 0                   # add's operand: the identity delivers the value
    addi x8, x0, 657                  # add's rd before (stale)
    lui x6, 894                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 895                       # quiet
    lui x28, 896                      # quiet
    add x8, x22, x23                  # add: producer, writes the link x8
    lui x29, 897                      # filler (gap)
    sw x8, 0(x21)                     # subject sw: consumer, reads x8 at data, d2 (raw_data_alu_rr_d2)
    lui x6, 898                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 899                       # quiet
    lui x28, 900                      # quiet
# block 87  raw_data_alu_rr_d2_x0  sw after add  expect(isa): none 0
    lui x0, 87  # marker: block 87
    lui x29, 901                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 902                       # quiet
    lui x7, 903                       # quiet
    .L153: auipc x24, %pcrel_hi(w65)  # sw's base -> w65
    lui x28, 904                      # sw's base -> w65 (quiet)
    lui x29, 905                      # sw's base -> w65 (quiet)
    lui x6, 906                       # sw's base -> w65 (quiet)
    addi x24, x24, %pcrel_lo(.L153)   # sw's base -> w65
    addi x25, x0, 664                 # add's operand: the identity delivers the value
    addi x26, x0, 0                   # add's operand: the identity delivers the value
    lui x7, 907                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 908                      # quiet
    lui x29, 909                      # quiet
    add x0, x25, x26                  # add: producer, writes the link x0
    lui x6, 910                       # filler (gap)
    sw x0, 0(x24)                     # subject sw: consumer, reads x0 at data, d2 (raw_data_alu_rr_d2_x0)
    lui x7, 911                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 912                      # quiet
    lui x29, 913                      # quiet
# block 88  raw_data_alu_rr_d3  sw after add  expect(isa): none 0
    lui x0, 88  # marker: block 88
    lui x6, 914                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 915                       # quiet
    lui x28, 916                      # quiet
    .L154: auipc x3, %pcrel_hi(w66)   # sw's base -> w66
    lui x29, 917                      # sw's base -> w66 (quiet)
    lui x6, 918                       # sw's base -> w66 (quiet)
    lui x7, 919                       # sw's base -> w66 (quiet)
    addi x3, x3, %pcrel_lo(.L154)     # sw's base -> w66
    addi x8, x0, 685                  # add's operand: the identity delivers the value
    addi x9, x0, 0                    # add's operand: the identity delivers the value
    addi x27, x0, 699                 # add's rd before (stale)
    lui x28, 920                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 921                      # quiet
    lui x6, 922                       # quiet
    add x27, x8, x9                   # add: producer, writes the link x27
    lui x7, 923                       # filler (gap)
    lui x28, 924                      # filler (gap)
    sw x27, 0(x3)                     # subject sw: consumer, reads x27 at data, d3 (raw_data_alu_rr_d3)
    lui x29, 925                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 926                       # quiet
    lui x7, 927                       # quiet
# block 89  raw_data_alu_rr_d3  sw after add  expect(isa): none 0
    lui x0, 89  # marker: block 89
    lui x28, 928                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 929                      # quiet
    lui x6, 930                       # quiet
    .L155: auipc x10, %pcrel_hi(w67)  # sw's base -> w67
    lui x7, 931                       # sw's base -> w67 (quiet)
    lui x28, 932                      # sw's base -> w67 (quiet)
    lui x29, 933                      # sw's base -> w67 (quiet)
    addi x10, x10, %pcrel_lo(.L155)   # sw's base -> w67
    addi x11, x0, 706                 # add's operand: the identity delivers the value
    addi x12, x0, 0                   # add's operand: the identity delivers the value
    addi x4, x0, 720                  # add's rd before (stale)
    lui x6, 934                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 935                       # quiet
    lui x28, 936                      # quiet
    add x4, x11, x12                  # add: producer, writes the link x4
    lui x29, 937                      # filler (gap)
    lui x6, 938                       # filler (gap)
    sw x4, 0(x10)                     # subject sw: consumer, reads x4 at data, d3 (raw_data_alu_rr_d3)
    lui x7, 939                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 940                      # quiet
    lui x29, 941                      # quiet
# block 90  raw_data_alu_rr_d3_x0  sw after add  expect(isa): none 0
    lui x0, 90  # marker: block 90
    lui x6, 942                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 943                       # quiet
    lui x28, 944                      # quiet
    .L156: auipc x13, %pcrel_hi(w68)  # sw's base -> w68
    lui x29, 945                      # sw's base -> w68 (quiet)
    lui x6, 946                       # sw's base -> w68 (quiet)
    lui x7, 947                       # sw's base -> w68 (quiet)
    addi x13, x13, %pcrel_lo(.L156)   # sw's base -> w68
    addi x14, x0, 727                 # add's operand: the identity delivers the value
    addi x15, x0, 0                   # add's operand: the identity delivers the value
    lui x28, 948                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 949                      # quiet
    lui x6, 950                       # quiet
    add x0, x14, x15                  # add: producer, writes the link x0
    lui x7, 951                       # filler (gap)
    lui x28, 952                      # filler (gap)
    sw x0, 0(x13)                     # subject sw: consumer, reads x0 at data, d3 (raw_data_alu_rr_d3_x0)
    lui x29, 953                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 954                       # quiet
    lui x7, 955                       # quiet
# block 91  raw_data_alu_ri_d1  sw after addi  expect(isa): stall 1
    lui x0, 91  # marker: block 91
    lui x28, 956                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 957                      # quiet
    lui x6, 958                       # quiet
    .L157: auipc x17, %pcrel_hi(w69)  # sw's base -> w69
    lui x7, 959                       # sw's base -> w69 (quiet)
    lui x28, 960                      # sw's base -> w69 (quiet)
    lui x29, 961                      # sw's base -> w69 (quiet)
    addi x17, x17, %pcrel_lo(.L157)   # sw's base -> w69
    addi x18, x0, 748                 # addi's operand: the identity delivers the value
    addi x16, x0, 762                 # addi's rd before (stale)
    lui x6, 962                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 963                       # quiet
    lui x28, 964                      # quiet
    addi x16, x18, 0                  # addi: producer, writes the link x16
    sw x16, 0(x17)                    # subject sw: consumer, reads x16 at data, d1 (raw_data_alu_ri_d1)
    lui x29, 965                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 966                       # quiet
    lui x7, 967                       # quiet
# block 92  raw_data_alu_ri_d1  sw after addi  expect(isa): stall 1
    lui x0, 92  # marker: block 92
    lui x28, 968                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 969                      # quiet
    lui x6, 970                       # quiet
    .L158: auipc x19, %pcrel_hi(w70)  # sw's base -> w70
    lui x7, 971                       # sw's base -> w70 (quiet)
    lui x28, 972                      # sw's base -> w70 (quiet)
    lui x29, 973                      # sw's base -> w70 (quiet)
    addi x19, x19, %pcrel_lo(.L158)   # sw's base -> w70
    addi x20, x0, 769                 # addi's operand: the identity delivers the value
    addi x1, x0, 783                  # addi's rd before (stale)
    lui x6, 974                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 975                       # quiet
    lui x28, 976                      # quiet
    addi x1, x20, 0                   # addi: producer, writes the link x1
    sw x1, 0(x19)                     # subject sw: consumer, reads x1 at data, d1 (raw_data_alu_ri_d1)
    lui x29, 977                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 978                       # quiet
    lui x7, 979                       # quiet
# block 93  raw_data_alu_ri_d1_x0  sw after addi  expect(isa): none 0
    lui x0, 93  # marker: block 93
    lui x28, 980                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 981                      # quiet
    lui x6, 982                       # quiet
    .L159: auipc x21, %pcrel_hi(w71)  # sw's base -> w71
    lui x7, 983                       # sw's base -> w71 (quiet)
    lui x28, 984                      # sw's base -> w71 (quiet)
    lui x29, 985                      # sw's base -> w71 (quiet)
    addi x21, x21, %pcrel_lo(.L159)   # sw's base -> w71
    addi x22, x0, 790                 # addi's operand: the identity delivers the value
    lui x6, 986                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 987                       # quiet
    lui x28, 988                      # quiet
    addi x0, x22, 0                   # addi: producer, writes the link x0
    sw x0, 0(x21)                     # subject sw: consumer, reads x0 at data, d1 (raw_data_alu_ri_d1_x0)
    lui x29, 989                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 990                       # quiet
    lui x7, 991                       # quiet
# block 94  raw_data_alu_ri_d2  sw after addi  expect(isa): forward 0
    lui x0, 94  # marker: block 94
    lui x28, 992                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 993                      # quiet
    lui x6, 994                       # quiet
    .L160: auipc x24, %pcrel_hi(w72)  # sw's base -> w72
    lui x7, 995                       # sw's base -> w72 (quiet)
    lui x28, 996                      # sw's base -> w72 (quiet)
    lui x29, 997                      # sw's base -> w72 (quiet)
    addi x24, x24, %pcrel_lo(.L160)   # sw's base -> w72
    addi x25, x0, 811                 # addi's operand: the identity delivers the value
    addi x23, x0, 825                 # addi's rd before (stale)
    lui x6, 998                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 999                       # quiet
    lui x28, 1000                     # quiet
    addi x23, x25, 0                  # addi: producer, writes the link x23
    lui x29, 1                        # filler (gap)
    sw x23, 0(x24)                    # subject sw: consumer, reads x23 at data, d2 (raw_data_alu_ri_d2)
    lui x6, 2                         # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 3                         # quiet
    lui x28, 4                        # quiet
# block 95  raw_data_alu_ri_d2  sw after addi  expect(isa): forward 0
    lui x0, 95  # marker: block 95
    lui x29, 5                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 6                         # quiet
    lui x7, 7                         # quiet
    .L161: auipc x26, %pcrel_hi(w73)  # sw's base -> w73
    lui x28, 8                        # sw's base -> w73 (quiet)
    lui x29, 9                        # sw's base -> w73 (quiet)
    lui x6, 10                        # sw's base -> w73 (quiet)
    addi x26, x26, %pcrel_lo(.L161)   # sw's base -> w73
    addi x27, x0, 832                 # addi's operand: the identity delivers the value
    addi x16, x0, 846                 # addi's rd before (stale)
    lui x7, 11                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 12                       # quiet
    lui x29, 13                       # quiet
    addi x16, x27, 0                  # addi: producer, writes the link x16
    lui x6, 14                        # filler (gap)
    sw x16, 0(x26)                    # subject sw: consumer, reads x16 at data, d2 (raw_data_alu_ri_d2)
    lui x7, 15                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 16                       # quiet
    lui x29, 17                       # quiet
# block 96  raw_data_alu_ri_d2_x0  sw after addi  expect(isa): none 0
    lui x0, 96  # marker: block 96
    lui x6, 18                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 19                        # quiet
    lui x28, 20                       # quiet
    .L162: auipc x3, %pcrel_hi(w74)   # sw's base -> w74
    lui x29, 21                       # sw's base -> w74 (quiet)
    lui x6, 22                        # sw's base -> w74 (quiet)
    lui x7, 23                        # sw's base -> w74 (quiet)
    addi x3, x3, %pcrel_lo(.L162)     # sw's base -> w74
    addi x8, x0, 853                  # addi's operand: the identity delivers the value
    lui x28, 24                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 25                       # quiet
    lui x6, 26                        # quiet
    addi x0, x8, 0                    # addi: producer, writes the link x0
    lui x7, 27                        # filler (gap)
    sw x0, 0(x3)                      # subject sw: consumer, reads x0 at data, d2 (raw_data_alu_ri_d2_x0)
    lui x28, 28                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 29                       # quiet
    lui x6, 30                        # quiet
# block 97  raw_data_alu_ri_d3  sw after addi  expect(isa): none 0
    lui x0, 97  # marker: block 97
    lui x7, 31                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 32                       # quiet
    lui x29, 33                       # quiet
    .L163: auipc x10, %pcrel_hi(w75)  # sw's base -> w75
    lui x6, 34                        # sw's base -> w75 (quiet)
    lui x7, 35                        # sw's base -> w75 (quiet)
    lui x28, 36                       # sw's base -> w75 (quiet)
    addi x10, x10, %pcrel_lo(.L163)   # sw's base -> w75
    addi x11, x0, 874                 # addi's operand: the identity delivers the value
    addi x9, x0, 888                  # addi's rd before (stale)
    lui x29, 37                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 38                        # quiet
    lui x7, 39                        # quiet
    addi x9, x11, 0                   # addi: producer, writes the link x9
    lui x28, 40                       # filler (gap)
    lui x29, 41                       # filler (gap)
    sw x9, 0(x10)                     # subject sw: consumer, reads x9 at data, d3 (raw_data_alu_ri_d3)
    lui x6, 42                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 43                        # quiet
    lui x28, 44                       # quiet
# block 98  raw_data_alu_ri_d3  sw after addi  expect(isa): none 0
    lui x0, 98  # marker: block 98
    lui x29, 45                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 46                        # quiet
    lui x7, 47                        # quiet
    .L164: auipc x12, %pcrel_hi(w76)  # sw's base -> w76
    lui x28, 48                       # sw's base -> w76 (quiet)
    lui x29, 49                       # sw's base -> w76 (quiet)
    lui x6, 50                        # sw's base -> w76 (quiet)
    addi x12, x12, %pcrel_lo(.L164)   # sw's base -> w76
    addi x13, x0, 895                 # addi's operand: the identity delivers the value
    addi x8, x0, 909                  # addi's rd before (stale)
    lui x7, 51                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 52                       # quiet
    lui x29, 53                       # quiet
    addi x8, x13, 0                   # addi: producer, writes the link x8
    lui x6, 54                        # filler (gap)
    lui x7, 55                        # filler (gap)
    sw x8, 0(x12)                     # subject sw: consumer, reads x8 at data, d3 (raw_data_alu_ri_d3)
    lui x28, 56                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 57                       # quiet
    lui x6, 58                        # quiet
# block 99  raw_data_alu_ri_d3_x0  sw after addi  expect(isa): none 0
    lui x0, 99  # marker: block 99
    lui x7, 59                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 60                       # quiet
    lui x29, 61                       # quiet
    .L165: auipc x14, %pcrel_hi(w77)  # sw's base -> w77
    lui x6, 62                        # sw's base -> w77 (quiet)
    lui x7, 63                        # sw's base -> w77 (quiet)
    lui x28, 64                       # sw's base -> w77 (quiet)
    addi x14, x14, %pcrel_lo(.L165)   # sw's base -> w77
    addi x15, x0, 916                 # addi's operand: the identity delivers the value
    lui x29, 65                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 66                        # quiet
    lui x7, 67                        # quiet
    addi x0, x15, 0                   # addi: producer, writes the link x0
    lui x28, 68                       # filler (gap)
    lui x29, 69                       # filler (gap)
    sw x0, 0(x14)                     # subject sw: consumer, reads x0 at data, d3 (raw_data_alu_ri_d3_x0)
    lui x6, 70                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 71                        # quiet
    lui x28, 72                       # quiet
# block 100  raw_data_alu_nosrc_d1  sw after auipc  expect(isa): stall 1
    lui x0, 100  # marker: block 100
    lui x29, 73                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 74                        # quiet
    lui x7, 75                        # quiet
    .L166: auipc x17, %pcrel_hi(w78)  # sw's base -> w78
    lui x28, 76                       # sw's base -> w78 (quiet)
    lui x29, 77                       # sw's base -> w78 (quiet)
    lui x6, 78                        # sw's base -> w78 (quiet)
    addi x17, x17, %pcrel_lo(.L166)   # sw's base -> w78
    addi x16, x0, 951                 # auipc's rd before (stale)
    lui x7, 79                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 80                       # quiet
    lui x29, 81                       # quiet
    auipc x16, 74565                  # auipc: producer, writes the link x16
    sw x16, 0(x17)                    # subject sw: consumer, reads x16 at data, d1 (raw_data_alu_nosrc_d1)
    lui x6, 82                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 83                        # quiet
    lui x28, 84                       # quiet
# block 101  raw_data_alu_nosrc_d1  sw after auipc  expect(isa): stall 1
    lui x0, 101  # marker: block 101
    lui x29, 85                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 86                        # quiet
    lui x7, 87                        # quiet
    .L167: auipc x18, %pcrel_hi(w79)  # sw's base -> w79
    lui x28, 88                       # sw's base -> w79 (quiet)
    lui x29, 89                       # sw's base -> w79 (quiet)
    lui x6, 90                        # sw's base -> w79 (quiet)
    addi x18, x18, %pcrel_lo(.L167)   # sw's base -> w79
    addi x4, x0, 972                  # auipc's rd before (stale)
    lui x7, 91                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 92                       # quiet
    lui x29, 93                       # quiet
    auipc x4, 74565                   # auipc: producer, writes the link x4
    sw x4, 0(x18)                     # subject sw: consumer, reads x4 at data, d1 (raw_data_alu_nosrc_d1)
    lui x6, 94                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 95                        # quiet
    lui x28, 96                       # quiet
# block 102  raw_data_alu_nosrc_d1_x0  sw after auipc  expect(isa): none 0
    lui x0, 102  # marker: block 102
    lui x29, 97                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 98                        # quiet
    lui x7, 99                        # quiet
    .L168: auipc x19, %pcrel_hi(w80)  # sw's base -> w80
    lui x28, 100                      # sw's base -> w80 (quiet)
    lui x29, 101                      # sw's base -> w80 (quiet)
    lui x6, 102                       # sw's base -> w80 (quiet)
    addi x19, x19, %pcrel_lo(.L168)   # sw's base -> w80
    lui x7, 103                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 104                      # quiet
    lui x29, 105                      # quiet
    auipc x0, 74565                   # auipc: producer, writes the link x0
    sw x0, 0(x19)                     # subject sw: consumer, reads x0 at data, d1 (raw_data_alu_nosrc_d1_x0)
    lui x6, 106                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 107                       # quiet
    lui x28, 108                      # quiet
# block 103  raw_data_alu_nosrc_d2  sw after auipc  expect(isa): forward 0
    lui x0, 103  # marker: block 103
    lui x29, 109                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 110                       # quiet
    lui x7, 111                       # quiet
    .L169: auipc x21, %pcrel_hi(w81)  # sw's base -> w81
    lui x28, 112                      # sw's base -> w81 (quiet)
    lui x29, 113                      # sw's base -> w81 (quiet)
    lui x6, 114                       # sw's base -> w81 (quiet)
    addi x21, x21, %pcrel_lo(.L169)   # sw's base -> w81
    addi x20, x0, 1014                # auipc's rd before (stale)
    lui x7, 115                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 116                      # quiet
    lui x29, 117                      # quiet
    auipc x20, 74565                  # auipc: producer, writes the link x20
    lui x6, 118                       # filler (gap)
    sw x20, 0(x21)                    # subject sw: consumer, reads x20 at data, d2 (raw_data_alu_nosrc_d2)
    lui x7, 119                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 120                      # quiet
    lui x29, 121                      # quiet
# block 104  raw_data_alu_nosrc_d2  sw after auipc  expect(isa): forward 0
    lui x0, 104  # marker: block 104
    lui x6, 122                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 123                       # quiet
    lui x28, 124                      # quiet
    .L170: auipc x22, %pcrel_hi(w82)  # sw's base -> w82
    lui x29, 125                      # sw's base -> w82 (quiet)
    lui x6, 126                       # sw's base -> w82 (quiet)
    lui x7, 127                       # sw's base -> w82 (quiet)
    addi x22, x22, %pcrel_lo(.L170)   # sw's base -> w82
    addi x1, x0, 1035                 # auipc's rd before (stale)
    lui x28, 128                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 129                      # quiet
    lui x6, 130                       # quiet
    auipc x1, 74565                   # auipc: producer, writes the link x1
    lui x7, 131                       # filler (gap)
    sw x1, 0(x22)                     # subject sw: consumer, reads x1 at data, d2 (raw_data_alu_nosrc_d2)
    lui x28, 132                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 133                      # quiet
    lui x6, 134                       # quiet
# block 105  raw_data_alu_nosrc_d2_x0  sw after auipc  expect(isa): none 0
    lui x0, 105  # marker: block 105
    lui x7, 135                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 136                      # quiet
    lui x29, 137                      # quiet
    .L171: auipc x23, %pcrel_hi(w83)  # sw's base -> w83
    lui x6, 138                       # sw's base -> w83 (quiet)
    lui x7, 139                       # sw's base -> w83 (quiet)
    lui x28, 140                      # sw's base -> w83 (quiet)
    addi x23, x23, %pcrel_lo(.L171)   # sw's base -> w83
    lui x29, 141                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 142                       # quiet
    lui x7, 143                       # quiet
    auipc x0, 74565                   # auipc: producer, writes the link x0
    lui x28, 144                      # filler (gap)
    sw x0, 0(x23)                     # subject sw: consumer, reads x0 at data, d2 (raw_data_alu_nosrc_d2_x0)
    lui x29, 145                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 146                       # quiet
    lui x7, 147                       # quiet
# block 106  raw_data_alu_nosrc_d3  sw after auipc  expect(isa): none 0
    lui x0, 106  # marker: block 106
    lui x28, 148                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 149                      # quiet
    lui x6, 150                       # quiet
    .L172: auipc x25, %pcrel_hi(w84)  # sw's base -> w84
    lui x7, 151                       # sw's base -> w84 (quiet)
    lui x28, 152                      # sw's base -> w84 (quiet)
    lui x29, 153                      # sw's base -> w84 (quiet)
    addi x25, x25, %pcrel_lo(.L172)   # sw's base -> w84
    addi x24, x0, 1077                # auipc's rd before (stale)
    lui x6, 154                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 155                       # quiet
    lui x28, 156                      # quiet
    auipc x24, 74565                  # auipc: producer, writes the link x24
    lui x29, 157                      # filler (gap)
    lui x6, 158                       # filler (gap)
    sw x24, 0(x25)                    # subject sw: consumer, reads x24 at data, d3 (raw_data_alu_nosrc_d3)
    lui x7, 159                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 160                      # quiet
    lui x29, 161                      # quiet
# block 107  raw_data_alu_nosrc_d3  sw after auipc  expect(isa): none 0
    lui x0, 107  # marker: block 107
    lui x6, 162                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 163                       # quiet
    lui x28, 164                      # quiet
    .L173: auipc x26, %pcrel_hi(w85)  # sw's base -> w85
    lui x29, 165                      # sw's base -> w85 (quiet)
    lui x6, 166                       # sw's base -> w85 (quiet)
    lui x7, 167                       # sw's base -> w85 (quiet)
    addi x26, x26, %pcrel_lo(.L173)   # sw's base -> w85
    addi x16, x0, 1098                # auipc's rd before (stale)
    lui x28, 168                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 169                      # quiet
    lui x6, 170                       # quiet
    auipc x16, 74565                  # auipc: producer, writes the link x16
    lui x7, 171                       # filler (gap)
    lui x28, 172                      # filler (gap)
    sw x16, 0(x26)                    # subject sw: consumer, reads x16 at data, d3 (raw_data_alu_nosrc_d3)
    lui x29, 173                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 174                       # quiet
    lui x7, 175                       # quiet
# block 108  raw_data_alu_nosrc_d3_x0  sw after auipc  expect(isa): none 0
    lui x0, 108  # marker: block 108
    lui x28, 176                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 177                      # quiet
    lui x6, 178                       # quiet
    .L174: auipc x27, %pcrel_hi(w86)  # sw's base -> w86
    lui x7, 179                       # sw's base -> w86 (quiet)
    lui x28, 180                      # sw's base -> w86 (quiet)
    lui x29, 181                      # sw's base -> w86 (quiet)
    addi x27, x27, %pcrel_lo(.L174)   # sw's base -> w86
    lui x6, 182                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 183                       # quiet
    lui x28, 184                      # quiet
    auipc x0, 74565                   # auipc: producer, writes the link x0
    lui x29, 185                      # filler (gap)
    lui x6, 186                       # filler (gap)
    sw x0, 0(x27)                     # subject sw: consumer, reads x0 at data, d3 (raw_data_alu_nosrc_d3_x0)
    lui x7, 187                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 188                      # quiet
    lui x29, 189                      # quiet
# block 109  raw_addr_nearest_load_d1  sw after lw  expect(isa): stall 1
    lui x0, 109  # marker: block 109
    lui x6, 190                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 191                       # quiet
    lui x28, 192                      # quiet
    addi x20, x0, 1238                # sw's store data
    .L179: auipc x21, %pcrel_hi(w88)  # lw's base -> w88
    lui x29, 193                      # lw's base -> w88 (quiet)
    lui x6, 194                       # lw's base -> w88 (quiet)
    lui x7, 195                       # lw's base -> w88 (quiet)
    addi x21, x21, %pcrel_lo(.L179)   # lw's base -> w88
    addi x19, x0, 1245                # lw's rd before (stale)
    lui x28, 196                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 197                      # quiet
    lui x6, 198                       # quiet
    lui x19, 0x5e                     # an older writer of x19 at DMAX: the nearer one wins
    lw x19, 0(x21)                    # lw: producer, writes the link x19
    sw x20, 0(x19)                    # subject sw: consumer, reads x19 at addr, d1 (raw_addr_nearest_load_d1)
    lui x7, 199                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 200                      # quiet
    lui x29, 201                      # quiet
# block 110  raw_addr_nearest_load_d1  sw after lw  expect(isa): stall 1
    lui x0, 110  # marker: block 110
    lui x6, 202                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 203                       # quiet
    lui x28, 204                      # quiet
    addi x10, x0, 1371                # sw's store data
    .L184: auipc x11, %pcrel_hi(w90)  # lw's base -> w90
    lui x29, 205                      # lw's base -> w90 (quiet)
    lui x6, 206                       # lw's base -> w90 (quiet)
    lui x7, 207                       # lw's base -> w90 (quiet)
    addi x11, x11, %pcrel_lo(.L184)   # lw's base -> w90
    addi x8, x0, 1378                 # lw's rd before (stale)
    lui x28, 208                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 209                      # quiet
    lui x6, 210                       # quiet
    lui x8, 0x5f                      # an older writer of x8 at DMAX: the nearer one wins
    lw x8, 0(x11)                     # lw: producer, writes the link x8
    sw x10, 0(x8)                     # subject sw: consumer, reads x8 at addr, d1 (raw_addr_nearest_load_d1)
    lui x7, 211                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 212                      # quiet
    lui x29, 213                      # quiet
# block 111  raw_addr_nearest_jalr_d1  sw after jalr  expect(isa): stall 1
    lui x0, 111  # marker: block 111
    lui x6, 214                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 215                       # quiet
    lui x28, 216                      # quiet
    addi x13, x0, 1392                # sw's store data
    .L187: auipc x14, %pcrel_hi(.L186) # jalr's target -> .L186, the label after it
    lui x29, 217                      # jalr's target -> .L186, the label after it (quiet)
    lui x6, 218                       # jalr's target -> .L186, the label after it (quiet)
    lui x7, 219                       # jalr's target -> .L186, the label after it (quiet)
    addi x14, x14, %pcrel_lo(.L187)   # jalr's target -> .L186, the label after it
    addi x12, x0, 1399                # jalr's rd before (stale)
    lui x28, 220                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 221                      # quiet
    lui x6, 222                       # quiet
    lui x12, 0x60                     # an older writer of x12 at DMAX: the nearer one wins
    jalr x12, 0(x14)                  # jalr: producer, writes the link x12
.L186:
.L185:
    sw x13, 8(x12)                    # subject sw: consumer, reads x12 at addr, d1 (raw_addr_nearest_jalr_d1)
    j .L188                           # over the data word iw13, reached from the link
iw13: .word 0x57e
.L188:
    lui x7, 223                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 224                      # quiet
    lui x29, 225                      # quiet
# block 112  raw_addr_nearest_jalr_d1  sw after jalr  expect(isa): stall 1
    lui x0, 112  # marker: block 112
    lui x6, 226                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 227                       # quiet
    lui x28, 228                      # quiet
    addi x15, x0, 1                   # sw's store data
    .L191: auipc x16, %pcrel_hi(.L190) # jalr's target -> .L190, the label after it
    lui x29, 229                      # jalr's target -> .L190, the label after it (quiet)
    lui x6, 230                       # jalr's target -> .L190, the label after it (quiet)
    lui x7, 231                       # jalr's target -> .L190, the label after it (quiet)
    addi x16, x16, %pcrel_lo(.L191)   # jalr's target -> .L190, the label after it
    addi x1, x0, 1413                 # jalr's rd before (stale)
    lui x28, 232                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 233                      # quiet
    lui x6, 234                       # quiet
    lui x1, 0x61                      # an older writer of x1 at DMAX: the nearer one wins
    jalr x1, 0(x16)                   # jalr: producer, writes the link x1
.L190:
.L189:
    sw x15, 8(x1)                     # subject sw: consumer, reads x1 at addr, d1 (raw_addr_nearest_jalr_d1)
    j .L192                           # over the data word iw14, reached from the link
iw14: .word 0x58c
.L192:
    lui x7, 235                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 236                      # quiet
    lui x29, 237                      # quiet
# block 113  raw_addr_nearest_jal_d1  sw after jal  expect(isa): stall 1
    lui x0, 113  # marker: block 113
    lui x6, 238                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 239                       # quiet
    lui x28, 240                      # quiet
    addi x18, x0, 1427                # sw's store data
    addi x17, x0, 1434                # jal's rd before (stale)
    lui x29, 241                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 242                       # quiet
    lui x7, 243                       # quiet
    lui x17, 0x62                     # an older writer of x17 at DMAX: the nearer one wins
    jal x17, .L194                    # jal: producer, writes the link x17
.L194:
.L193:
    sw x18, 8(x17)                    # subject sw: consumer, reads x17 at addr, d1 (raw_addr_nearest_jal_d1)
    j .L195                           # over the data word iw15, reached from the link
iw15: .word 0x5a1
.L195:
    lui x28, 244                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 245                      # quiet
    lui x6, 246                       # quiet
# block 114  raw_addr_nearest_jal_d1  sw after jal  expect(isa): stall 1
    lui x0, 114  # marker: block 114
    lui x7, 247                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 248                      # quiet
    lui x29, 249                      # quiet
    addi x19, x0, 1448                # sw's store data
    addi x8, x0, 1455                 # jal's rd before (stale)
    lui x6, 250                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 251                       # quiet
    lui x28, 252                      # quiet
    lui x8, 0x63                      # an older writer of x8 at DMAX: the nearer one wins
    jal x8, .L197                     # jal: producer, writes the link x8
.L197:
.L196:
    sw x19, 8(x8)                     # subject sw: consumer, reads x8 at addr, d1 (raw_addr_nearest_jal_d1)
    j .L198                           # over the data word iw16, reached from the link
iw16: .word 0x5b6
.L198:
    lui x29, 253                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 254                       # quiet
    lui x7, 255                       # quiet
# block 115  raw_addr_nearest_alu_rr_d1  sw after add  expect(isa): stall 1
    lui x0, 115  # marker: block 115
    lui x28, 256                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 257                      # quiet
    lui x6, 258                       # quiet
    addi x21, x0, 1476                # sw's store data
    .L199: auipc x22, %pcrel_hi(w91)  # add's operand: the identity delivers the value
    lui x7, 259                       # add's operand: the identity delivers the value (quiet)
    lui x28, 260                      # add's operand: the identity delivers the value (quiet)
    lui x29, 261                      # add's operand: the identity delivers the value (quiet)
    addi x22, x22, %pcrel_lo(.L199)   # add's operand: the identity delivers the value
    addi x23, x0, 0                   # add's operand: the identity delivers the value
    addi x20, x0, 1483                # add's rd before (stale)
    lui x6, 262                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 263                       # quiet
    lui x28, 264                      # quiet
    lui x20, 0x64                     # an older writer of x20 at DMAX: the nearer one wins
    add x20, x22, x23                 # add: producer, writes the link x20
    sw x21, 0(x20)                    # subject sw: consumer, reads x20 at addr, d1 (raw_addr_nearest_alu_rr_d1)
    lui x29, 265                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 266                       # quiet
    lui x7, 267                       # quiet
# block 116  raw_addr_nearest_alu_rr_d1  sw after add  expect(isa): stall 1
    lui x0, 116  # marker: block 116
    lui x28, 268                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 269                      # quiet
    lui x6, 270                       # quiet
    addi x24, x0, -1                  # sw's store data
    .L200: auipc x25, %pcrel_hi(w92)  # add's operand: the identity delivers the value
    lui x7, 271                       # add's operand: the identity delivers the value (quiet)
    lui x28, 272                      # add's operand: the identity delivers the value (quiet)
    lui x29, 273                      # add's operand: the identity delivers the value (quiet)
    addi x25, x25, %pcrel_lo(.L200)   # add's operand: the identity delivers the value
    addi x26, x0, 0                   # add's operand: the identity delivers the value
    addi x1, x0, 1497                 # add's rd before (stale)
    lui x6, 274                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 275                       # quiet
    lui x28, 276                      # quiet
    lui x1, 0x65                      # an older writer of x1 at DMAX: the nearer one wins
    add x1, x25, x26                  # add: producer, writes the link x1
    sw x24, 0(x1)                     # subject sw: consumer, reads x1 at addr, d1 (raw_addr_nearest_alu_rr_d1)
    lui x29, 277                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 278                       # quiet
    lui x7, 279                       # quiet
# block 117  raw_addr_nearest_alu_ri_d1  sw after addi  expect(isa): stall 1
    lui x0, 117  # marker: block 117
    lui x28, 280                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 281                      # quiet
    lui x6, 282                       # quiet
    addi x3, x0, 1511                 # sw's store data
    .L201: auipc x8, %pcrel_hi(w93)   # addi's operand: the identity delivers the value
    lui x7, 283                       # addi's operand: the identity delivers the value (quiet)
    lui x28, 284                      # addi's operand: the identity delivers the value (quiet)
    lui x29, 285                      # addi's operand: the identity delivers the value (quiet)
    addi x8, x8, %pcrel_lo(.L201)     # addi's operand: the identity delivers the value
    addi x27, x0, 1518                # addi's rd before (stale)
    lui x6, 286                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 287                       # quiet
    lui x28, 288                      # quiet
    lui x27, 0x66                     # an older writer of x27 at DMAX: the nearer one wins
    addi x27, x8, 0                   # addi: producer, writes the link x27
    sw x3, 0(x27)                     # subject sw: consumer, reads x27 at addr, d1 (raw_addr_nearest_alu_ri_d1)
    lui x29, 289                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 290                       # quiet
    lui x7, 291                       # quiet
# block 118  raw_addr_nearest_alu_ri_d1  sw after addi  expect(isa): stall 1
    lui x0, 118  # marker: block 118
    lui x28, 292                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 293                      # quiet
    lui x6, 294                       # quiet
    addi x9, x0, 1532                 # sw's store data
    .L202: auipc x10, %pcrel_hi(w94)  # addi's operand: the identity delivers the value
    lui x7, 295                       # addi's operand: the identity delivers the value (quiet)
    lui x28, 296                      # addi's operand: the identity delivers the value (quiet)
    lui x29, 297                      # addi's operand: the identity delivers the value (quiet)
    addi x10, x10, %pcrel_lo(.L202)   # addi's operand: the identity delivers the value
    addi x8, x0, 1539                 # addi's rd before (stale)
    lui x6, 298                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 299                       # quiet
    lui x28, 300                      # quiet
    lui x8, 0x67                      # an older writer of x8 at DMAX: the nearer one wins
    addi x8, x10, 0                   # addi: producer, writes the link x8
    sw x9, 0(x8)                      # subject sw: consumer, reads x8 at addr, d1 (raw_addr_nearest_alu_ri_d1)
    lui x29, 301                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 302                       # quiet
    lui x7, 303                       # quiet
# block 119  raw_addr_nearest_alu_nosrc_d1  sw after lui  expect(isa): stall 1
    lui x0, 119  # marker: block 119
    lui x28, 304                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 305                      # quiet
    lui x6, 306                       # quiet
    addi x14, x0, -2                  # sw's store data
    addi x13, x0, 1567                # lui's rd before (stale)
    lui x7, 307                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 308                      # quiet
    lui x29, 309                      # quiet
    lui x13, 0x68                     # an older writer of x13 at DMAX: the nearer one wins
    lui x13, %hi(w0)                  # lui: producer, writes the link x13
    sw x14, 0(x13)                    # subject sw: consumer, reads x13 at addr, d1 (raw_addr_nearest_alu_nosrc_d1)
    lui x6, 310                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 311                       # quiet
    lui x28, 312                      # quiet
# block 120  raw_addr_nearest_alu_nosrc_d1  sw after lui  expect(isa): stall 1
    lui x0, 120  # marker: block 120
    lui x29, 313                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 314                       # quiet
    lui x7, 315                       # quiet
    addi x16, x0, 1595                # sw's store data
    addi x1, x0, 1602                 # lui's rd before (stale)
    lui x28, 316                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 317                      # quiet
    lui x6, 318                       # quiet
    lui x1, 0x69                      # an older writer of x1 at DMAX: the nearer one wins
    lui x1, %hi(w0)                   # lui: producer, writes the link x1
    sw x16, 0(x1)                     # subject sw: consumer, reads x1 at addr, d1 (raw_addr_nearest_alu_nosrc_d1)
    lui x7, 319                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 320                      # quiet
    lui x29, 321                      # quiet
# block 121  raw_data_nearest_load_d1  sw after lb  expect(isa): stall 1
    lui x0, 121  # marker: block 121
    lui x6, 322                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 323                       # quiet
    lui x28, 324                      # quiet
    .L203: auipc x18, %pcrel_hi(w95)  # sw's base -> w95
    lui x29, 325                      # sw's base -> w95 (quiet)
    lui x6, 326                       # sw's base -> w95 (quiet)
    lui x7, 327                       # sw's base -> w95 (quiet)
    addi x18, x18, %pcrel_lo(.L203)   # sw's base -> w95
    .L204: auipc x19, %pcrel_hi(w96)  # lb's base -> w96
    lui x28, 328                      # lb's base -> w96 (quiet)
    lui x29, 329                      # lb's base -> w96 (quiet)
    lui x6, 330                       # lb's base -> w96 (quiet)
    addi x19, x19, %pcrel_lo(.L204)   # lb's base -> w96
    addi x17, x0, 1623                # lb's rd before (stale)
    lui x7, 331                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 332                      # quiet
    lui x29, 333                      # quiet
    lui x17, 0x6a                     # an older writer of x17 at DMAX: the nearer one wins
    lb x17, 0(x19)                    # lb: producer, writes the link x17
    sw x17, 0(x18)                    # subject sw: consumer, reads x17 at data, d1 (raw_data_nearest_load_d1)
    lui x6, 334                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 335                       # quiet
    lui x28, 336                      # quiet
# block 122  raw_data_nearest_load_d1  sw after lb  expect(isa): stall 1
    lui x0, 122  # marker: block 122
    lui x29, 337                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 338                       # quiet
    lui x7, 339                       # quiet
    .L205: auipc x20, %pcrel_hi(w97)  # sw's base -> w97
    lui x28, 340                      # sw's base -> w97 (quiet)
    lui x29, 341                      # sw's base -> w97 (quiet)
    lui x6, 342                       # sw's base -> w97 (quiet)
    addi x20, x20, %pcrel_lo(.L205)   # sw's base -> w97
    .L206: auipc x21, %pcrel_hi(w98)  # lb's base -> w98
    lui x7, 343                       # lb's base -> w98 (quiet)
    lui x28, 344                      # lb's base -> w98 (quiet)
    lui x29, 345                      # lb's base -> w98 (quiet)
    addi x21, x21, %pcrel_lo(.L206)   # lb's base -> w98
    addi x8, x0, 1651                 # lb's rd before (stale)
    lui x6, 346                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 347                       # quiet
    lui x28, 348                      # quiet
    lui x8, 0x6b                      # an older writer of x8 at DMAX: the nearer one wins
    lb x8, 0(x21)                     # lb: producer, writes the link x8
    sw x8, 0(x20)                     # subject sw: consumer, reads x8 at data, d1 (raw_data_nearest_load_d1)
    lui x29, 349                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 350                       # quiet
    lui x7, 351                       # quiet
# block 123  raw_data_nearest_jalr_d1  sw after jalr  expect(isa): stall 1
    lui x0, 123  # marker: block 123
    lui x28, 352                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 353                      # quiet
    lui x6, 354                       # quiet
    .L207: auipc x23, %pcrel_hi(w99)  # sw's base -> w99
    lui x7, 355                       # sw's base -> w99 (quiet)
    lui x28, 356                      # sw's base -> w99 (quiet)
    lui x29, 357                      # sw's base -> w99 (quiet)
    addi x23, x23, %pcrel_lo(.L207)   # sw's base -> w99
    .L209: auipc x24, %pcrel_hi(.L208) # jalr's target -> .L208, the label after it
    lui x6, 358                       # jalr's target -> .L208, the label after it (quiet)
    lui x7, 359                       # jalr's target -> .L208, the label after it (quiet)
    lui x28, 360                      # jalr's target -> .L208, the label after it (quiet)
    addi x24, x24, %pcrel_lo(.L209)   # jalr's target -> .L208, the label after it
    addi x22, x0, 1679                # jalr's rd before (stale)
    lui x29, 361                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 362                       # quiet
    lui x7, 363                       # quiet
    lui x22, 0x6c                     # an older writer of x22 at DMAX: the nearer one wins
    jalr x22, 0(x24)                  # jalr: producer, writes the link x22
.L208:
    sw x22, 0(x23)                    # subject sw: consumer, reads x22 at data, d1 (raw_data_nearest_jalr_d1)
    lui x28, 364                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 365                      # quiet
    lui x6, 366                       # quiet
# block 124  raw_data_nearest_jalr_d1  sw after jalr  expect(isa): stall 1
    lui x0, 124  # marker: block 124
    lui x7, 367                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 368                      # quiet
    lui x29, 369                      # quiet
    .L210: auipc x25, %pcrel_hi(w100) # sw's base -> w100
    lui x6, 370                       # sw's base -> w100 (quiet)
    lui x7, 371                       # sw's base -> w100 (quiet)
    lui x28, 372                      # sw's base -> w100 (quiet)
    addi x25, x25, %pcrel_lo(.L210)   # sw's base -> w100
    .L212: auipc x26, %pcrel_hi(.L211) # jalr's target -> .L211, the label after it
    lui x29, 373                      # jalr's target -> .L211, the label after it (quiet)
    lui x6, 374                       # jalr's target -> .L211, the label after it (quiet)
    lui x7, 375                       # jalr's target -> .L211, the label after it (quiet)
    addi x26, x26, %pcrel_lo(.L212)   # jalr's target -> .L211, the label after it
    addi x1, x0, 1700                 # jalr's rd before (stale)
    lui x28, 376                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 377                      # quiet
    lui x6, 378                       # quiet
    lui x1, 0x6d                      # an older writer of x1 at DMAX: the nearer one wins
    jalr x1, 0(x26)                   # jalr: producer, writes the link x1
.L211:
    sw x1, 0(x25)                     # subject sw: consumer, reads x1 at data, d1 (raw_data_nearest_jalr_d1)
    lui x7, 379                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 380                      # quiet
    lui x29, 381                      # quiet
# block 125  raw_data_nearest_jal_d1  sw after jal  expect(isa): stall 1
    lui x0, 125  # marker: block 125
    lui x6, 382                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 383                       # quiet
    lui x28, 384                      # quiet
    .L213: auipc x3, %pcrel_hi(w101)  # sw's base -> w101
    lui x29, 385                      # sw's base -> w101 (quiet)
    lui x6, 386                       # sw's base -> w101 (quiet)
    lui x7, 387                       # sw's base -> w101 (quiet)
    addi x3, x3, %pcrel_lo(.L213)     # sw's base -> w101
    addi x27, x0, 1721                # jal's rd before (stale)
    lui x28, 388                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 389                      # quiet
    lui x6, 390                       # quiet
    lui x27, 0x6e                     # an older writer of x27 at DMAX: the nearer one wins
    jal x27, .L214                    # jal: producer, writes the link x27
.L214:
    sw x27, 0(x3)                     # subject sw: consumer, reads x27 at data, d1 (raw_data_nearest_jal_d1)
    lui x7, 391                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 392                      # quiet
    lui x29, 393                      # quiet
# block 126  raw_data_nearest_jal_d1  sw after jal  expect(isa): stall 1
    lui x0, 126  # marker: block 126
    lui x6, 394                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 395                       # quiet
    lui x28, 396                      # quiet
    .L215: auipc x9, %pcrel_hi(w102)  # sw's base -> w102
    lui x29, 397                      # sw's base -> w102 (quiet)
    lui x6, 398                       # sw's base -> w102 (quiet)
    lui x7, 399                       # sw's base -> w102 (quiet)
    addi x9, x9, %pcrel_lo(.L215)     # sw's base -> w102
    addi x8, x0, 1742                 # jal's rd before (stale)
    lui x28, 400                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 401                      # quiet
    lui x6, 402                       # quiet
    lui x8, 0x6f                      # an older writer of x8 at DMAX: the nearer one wins
    jal x8, .L216                     # jal: producer, writes the link x8
.L216:
    sw x8, 0(x9)                      # subject sw: consumer, reads x8 at data, d1 (raw_data_nearest_jal_d1)
    lui x7, 403                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 404                      # quiet
    lui x29, 405                      # quiet
# block 127  raw_data_nearest_alu_rr_d1  sw after add  expect(isa): stall 1
    lui x0, 127  # marker: block 127
    lui x6, 406                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 407                       # quiet
    lui x28, 408                      # quiet
    .L217: auipc x11, %pcrel_hi(w103) # sw's base -> w103
    lui x29, 409                      # sw's base -> w103 (quiet)
    lui x6, 410                       # sw's base -> w103 (quiet)
    lui x7, 411                       # sw's base -> w103 (quiet)
    addi x11, x11, %pcrel_lo(.L217)   # sw's base -> w103
    addi x12, x0, 1749                # add's operand: the identity delivers the value
    addi x13, x0, 0                   # add's operand: the identity delivers the value
    addi x10, x0, 1763                # add's rd before (stale)
    lui x28, 412                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 413                      # quiet
    lui x6, 414                       # quiet
    lui x10, 0x70                     # an older writer of x10 at DMAX: the nearer one wins
    add x10, x12, x13                 # add: producer, writes the link x10
    sw x10, 0(x11)                    # subject sw: consumer, reads x10 at data, d1 (raw_data_nearest_alu_rr_d1)
    lui x7, 415                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 416                      # quiet
    lui x29, 417                      # quiet
# block 128  raw_data_nearest_alu_rr_d1  sw after add  expect(isa): stall 1
    lui x0, 128  # marker: block 128
    lui x6, 418                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 419                       # quiet
    lui x28, 420                      # quiet
    .L218: auipc x14, %pcrel_hi(w104) # sw's base -> w104
    lui x29, 421                      # sw's base -> w104 (quiet)
    lui x6, 422                       # sw's base -> w104 (quiet)
    lui x7, 423                       # sw's base -> w104 (quiet)
    addi x14, x14, %pcrel_lo(.L218)   # sw's base -> w104
    addi x15, x0, 1770                # add's operand: the identity delivers the value
    addi x16, x0, 0                   # add's operand: the identity delivers the value
    addi x1, x0, 1784                 # add's rd before (stale)
    lui x28, 424                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 425                      # quiet
    lui x6, 426                       # quiet
    lui x1, 0x71                      # an older writer of x1 at DMAX: the nearer one wins
    add x1, x15, x16                  # add: producer, writes the link x1
    sw x1, 0(x14)                     # subject sw: consumer, reads x1 at data, d1 (raw_data_nearest_alu_rr_d1)
    lui x7, 427                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 428                      # quiet
    lui x29, 429                      # quiet
# block 129  raw_data_nearest_alu_ri_d1  sw after addi  expect(isa): stall 1
    lui x0, 129  # marker: block 129
    lui x6, 430                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 431                       # quiet
    lui x28, 432                      # quiet
    .L219: auipc x18, %pcrel_hi(w105) # sw's base -> w105
    lui x29, 433                      # sw's base -> w105 (quiet)
    lui x6, 434                       # sw's base -> w105 (quiet)
    lui x7, 435                       # sw's base -> w105 (quiet)
    addi x18, x18, %pcrel_lo(.L219)   # sw's base -> w105
    addi x19, x0, 1791                # addi's operand: the identity delivers the value
    addi x17, x0, 1805                # addi's rd before (stale)
    lui x28, 436                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 437                      # quiet
    lui x6, 438                       # quiet
    lui x17, 0x72                     # an older writer of x17 at DMAX: the nearer one wins
    addi x17, x19, 0                  # addi: producer, writes the link x17
    sw x17, 0(x18)                    # subject sw: consumer, reads x17 at data, d1 (raw_data_nearest_alu_ri_d1)
    lui x7, 439                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 440                      # quiet
    lui x29, 441                      # quiet
# block 130  raw_data_nearest_alu_ri_d1  sw after addi  expect(isa): stall 1
    lui x0, 130  # marker: block 130
    lui x6, 442                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 443                       # quiet
    lui x28, 444                      # quiet
    .L220: auipc x20, %pcrel_hi(w106) # sw's base -> w106
    lui x29, 445                      # sw's base -> w106 (quiet)
    lui x6, 446                       # sw's base -> w106 (quiet)
    lui x7, 447                       # sw's base -> w106 (quiet)
    addi x20, x20, %pcrel_lo(.L220)   # sw's base -> w106
    addi x21, x0, 1812                # addi's operand: the identity delivers the value
    addi x8, x0, 1826                 # addi's rd before (stale)
    lui x28, 448                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 449                      # quiet
    lui x6, 450                       # quiet
    lui x8, 0x73                      # an older writer of x8 at DMAX: the nearer one wins
    addi x8, x21, 0                   # addi: producer, writes the link x8
    sw x8, 0(x20)                     # subject sw: consumer, reads x8 at data, d1 (raw_data_nearest_alu_ri_d1)
    lui x7, 451                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 452                      # quiet
    lui x29, 453                      # quiet
# block 131  raw_data_nearest_alu_nosrc_d1  sw after auipc  expect(isa): stall 1
    lui x0, 131  # marker: block 131
    lui x6, 454                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 455                       # quiet
    lui x28, 456                      # quiet
    .L221: auipc x23, %pcrel_hi(w107) # sw's base -> w107
    lui x29, 457                      # sw's base -> w107 (quiet)
    lui x6, 458                       # sw's base -> w107 (quiet)
    lui x7, 459                       # sw's base -> w107 (quiet)
    addi x23, x23, %pcrel_lo(.L221)   # sw's base -> w107
    addi x22, x0, 1847                # auipc's rd before (stale)
    lui x28, 460                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 461                      # quiet
    lui x6, 462                       # quiet
    lui x22, 0x74                     # an older writer of x22 at DMAX: the nearer one wins
    auipc x22, 74565                  # auipc: producer, writes the link x22
    sw x22, 0(x23)                    # subject sw: consumer, reads x22 at data, d1 (raw_data_nearest_alu_nosrc_d1)
    lui x7, 463                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 464                      # quiet
    lui x29, 465                      # quiet
# block 132  raw_data_nearest_alu_nosrc_d1  sw after auipc  expect(isa): stall 1
    lui x0, 132  # marker: block 132
    lui x6, 466                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 467                       # quiet
    lui x28, 468                      # quiet
    .L222: auipc x24, %pcrel_hi(w108) # sw's base -> w108
    lui x29, 469                      # sw's base -> w108 (quiet)
    lui x6, 470                       # sw's base -> w108 (quiet)
    lui x7, 471                       # sw's base -> w108 (quiet)
    addi x24, x24, %pcrel_lo(.L222)   # sw's base -> w108
    addi x1, x0, 1868                 # auipc's rd before (stale)
    lui x28, 472                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 473                      # quiet
    lui x6, 474                       # quiet
    lui x1, 0x75                      # an older writer of x1 at DMAX: the nearer one wins
    auipc x1, 74565                   # auipc: producer, writes the link x1
    sw x1, 0(x24)                     # subject sw: consumer, reads x1 at data, d1 (raw_data_nearest_alu_nosrc_d1)
    lui x7, 475                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 476                      # quiet
    lui x29, 477                      # quiet
# block 133  war_addr_load_d1  sw after lb  expect(isa): none 0
    lui x0, 133  # marker: block 133
    lui x6, 478                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 479                       # quiet
    lui x28, 480                      # quiet
    .L223: auipc x25, %pcrel_hi(w109) # x25 -> w109
    lui x29, 481                      # x25 -> w109 (quiet)
    lui x6, 482                       # x25 -> w109 (quiet)
    lui x7, 483                       # x25 -> w109 (quiet)
    addi x25, x25, %pcrel_lo(.L223)   # x25 -> w109
    addi x26, x0, -2                  # sw's store data
    .L224: auipc x27, %pcrel_hi(w110) # lb's base -> w110
    lui x28, 484                      # lb's base -> w110 (quiet)
    lui x29, 485                      # lb's base -> w110 (quiet)
    lui x6, 486                       # lb's base -> w110 (quiet)
    addi x27, x27, %pcrel_lo(.L224)   # lb's base -> w110
    lui x7, 487                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 488                      # quiet
    lui x29, 489                      # quiet
    sw x26, 0(x25)                    # subject sw: reader, reads x25 at addr (war)
    lb x25, 0(x27)                    # lb: writer, writes x25 after the reader, d1 (war_addr_load_d1)
    lui x6, 490                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 491                       # quiet
    lui x28, 492                      # quiet
# block 134  war_addr_load_d2  sw after lb  expect(isa): none 0
    lui x0, 134  # marker: block 134
    lui x29, 493                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 494                       # quiet
    lui x7, 495                       # quiet
    .L225: auipc x3, %pcrel_hi(w111)  # x3 -> w111
    lui x28, 496                      # x3 -> w111 (quiet)
    lui x29, 497                      # x3 -> w111 (quiet)
    lui x6, 498                       # x3 -> w111 (quiet)
    addi x3, x3, %pcrel_lo(.L225)     # x3 -> w111
    addi x8, x0, 1896                 # sw's store data
    .L226: auipc x9, %pcrel_hi(w112)  # lb's base -> w112
    lui x7, 499                       # lb's base -> w112 (quiet)
    lui x28, 500                      # lb's base -> w112 (quiet)
    lui x29, 501                      # lb's base -> w112 (quiet)
    addi x9, x9, %pcrel_lo(.L226)     # lb's base -> w112
    lui x6, 502                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 503                       # quiet
    lui x28, 504                      # quiet
    sw x8, 0(x3)                      # subject sw: reader, reads x3 at addr (war)
    lui x29, 505                      # filler (gap)
    lb x3, 0(x9)                      # lb: writer, writes x3 after the reader, d2 (war_addr_load_d2)
    lui x6, 506                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 507                       # quiet
    lui x28, 508                      # quiet
# block 135  war_addr_load_d3  sw after lb  expect(isa): none 0
    lui x0, 135  # marker: block 135
    lui x29, 509                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 510                       # quiet
    lui x7, 511                       # quiet
    .L227: auipc x10, %pcrel_hi(w113) # x10 -> w113
    lui x28, 512                      # x10 -> w113 (quiet)
    lui x29, 513                      # x10 -> w113 (quiet)
    lui x6, 514                       # x10 -> w113 (quiet)
    addi x10, x10, %pcrel_lo(.L227)   # x10 -> w113
    addi x11, x0, 1917                # sw's store data
    .L228: auipc x12, %pcrel_hi(w114) # lb's base -> w114
    lui x7, 515                       # lb's base -> w114 (quiet)
    lui x28, 516                      # lb's base -> w114 (quiet)
    lui x29, 517                      # lb's base -> w114 (quiet)
    addi x12, x12, %pcrel_lo(.L228)   # lb's base -> w114
    lui x6, 518                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 519                       # quiet
    lui x28, 520                      # quiet
    sw x11, 0(x10)                    # subject sw: reader, reads x10 at addr (war)
    lui x29, 521                      # filler (gap)
    lui x6, 522                       # filler (gap)
    lb x10, 0(x12)                    # lb: writer, writes x10 after the reader, d3 (war_addr_load_d3)
    lui x7, 523                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 524                      # quiet
    lui x29, 525                      # quiet
# block 136  war_addr_jalr_d1  sw after jalr  expect(isa): none 0
    lui x0, 136  # marker: block 136
    lui x6, 526                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 527                       # quiet
    lui x28, 528                      # quiet
    .L229: auipc x13, %pcrel_hi(w115) # x13 -> w115
    lui x29, 529                      # x13 -> w115 (quiet)
    lui x6, 530                       # x13 -> w115 (quiet)
    lui x7, 531                       # x13 -> w115 (quiet)
    addi x13, x13, %pcrel_lo(.L229)   # x13 -> w115
    addi x14, x0, 1938                # sw's store data
    .L231: auipc x15, %pcrel_hi(.L230) # jalr's target -> .L230, the label after it
    lui x28, 532                      # jalr's target -> .L230, the label after it (quiet)
    lui x29, 533                      # jalr's target -> .L230, the label after it (quiet)
    lui x6, 534                       # jalr's target -> .L230, the label after it (quiet)
    addi x15, x15, %pcrel_lo(.L231)   # jalr's target -> .L230, the label after it
    lui x7, 535                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 536                      # quiet
    lui x29, 537                      # quiet
    sw x14, 0(x13)                    # subject sw: reader, reads x13 at addr (war)
    jalr x13, 0(x15)                  # jalr: writer, writes x13 after the reader, d1 (war_addr_jalr_d1)
.L230:
    lui x6, 538                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 539                       # quiet
    lui x28, 540                      # quiet
# block 137  war_addr_jalr_d2  sw after jalr  expect(isa): none 0
    lui x0, 137  # marker: block 137
    lui x29, 541                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 542                       # quiet
    lui x7, 543                       # quiet
    .L232: auipc x16, %pcrel_hi(w116) # x16 -> w116
    lui x28, 544                      # x16 -> w116 (quiet)
    lui x29, 545                      # x16 -> w116 (quiet)
    lui x6, 546                       # x16 -> w116 (quiet)
    addi x16, x16, %pcrel_lo(.L232)   # x16 -> w116
    addi x17, x0, 1952                # sw's store data
    .L234: auipc x18, %pcrel_hi(.L233) # jalr's target -> .L233, the label after it
    lui x7, 547                       # jalr's target -> .L233, the label after it (quiet)
    lui x28, 548                      # jalr's target -> .L233, the label after it (quiet)
    lui x29, 549                      # jalr's target -> .L233, the label after it (quiet)
    addi x18, x18, %pcrel_lo(.L234)   # jalr's target -> .L233, the label after it
    lui x6, 550                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 551                       # quiet
    lui x28, 552                      # quiet
    sw x17, 0(x16)                    # subject sw: reader, reads x16 at addr (war)
    lui x29, 553                      # filler (gap)
    jalr x16, 0(x18)                  # jalr: writer, writes x16 after the reader, d2 (war_addr_jalr_d2)
.L233:
    lui x6, 554                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 555                       # quiet
    lui x28, 556                      # quiet
# block 138  war_addr_jalr_d3  sw after jalr  expect(isa): none 0
    lui x0, 138  # marker: block 138
    lui x29, 557                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 558                       # quiet
    lui x7, 559                       # quiet
    .L235: auipc x19, %pcrel_hi(w117) # x19 -> w117
    lui x28, 560                      # x19 -> w117 (quiet)
    lui x29, 561                      # x19 -> w117 (quiet)
    lui x6, 562                       # x19 -> w117 (quiet)
    addi x19, x19, %pcrel_lo(.L235)   # x19 -> w117
    addi x20, x0, 1966                # sw's store data
    .L237: auipc x21, %pcrel_hi(.L236) # jalr's target -> .L236, the label after it
    lui x7, 563                       # jalr's target -> .L236, the label after it (quiet)
    lui x28, 564                      # jalr's target -> .L236, the label after it (quiet)
    lui x29, 565                      # jalr's target -> .L236, the label after it (quiet)
    addi x21, x21, %pcrel_lo(.L237)   # jalr's target -> .L236, the label after it
    lui x6, 566                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 567                       # quiet
    lui x28, 568                      # quiet
    sw x20, 0(x19)                    # subject sw: reader, reads x19 at addr (war)
    lui x29, 569                      # filler (gap)
    lui x6, 570                       # filler (gap)
    jalr x19, 0(x21)                  # jalr: writer, writes x19 after the reader, d3 (war_addr_jalr_d3)
.L236:
    lui x7, 571                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 572                      # quiet
    lui x29, 573                      # quiet
# block 139  war_addr_jal_d1  sw after jal  expect(isa): none 0
    lui x0, 139  # marker: block 139
    lui x6, 574                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 575                       # quiet
    lui x28, 576                      # quiet
    .L238: auipc x22, %pcrel_hi(w118) # x22 -> w118
    lui x29, 577                      # x22 -> w118 (quiet)
    lui x6, 578                       # x22 -> w118 (quiet)
    lui x7, 579                       # x22 -> w118 (quiet)
    addi x22, x22, %pcrel_lo(.L238)   # x22 -> w118
    addi x23, x0, 2                   # sw's store data
    lui x28, 580                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 581                      # quiet
    lui x6, 582                       # quiet
    sw x23, 0(x22)                    # subject sw: reader, reads x22 at addr (war)
    jal x22, .L239                    # jal: writer, writes x22 after the reader, d1 (war_addr_jal_d1)
.L239:
    lui x7, 583                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 584                      # quiet
    lui x29, 585                      # quiet
# block 140  war_addr_jal_d2  sw after jal  expect(isa): none 0
    lui x0, 140  # marker: block 140
    lui x6, 586                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 587                       # quiet
    lui x28, 588                      # quiet
    .L240: auipc x24, %pcrel_hi(w119) # x24 -> w119
    lui x29, 589                      # x24 -> w119 (quiet)
    lui x6, 590                       # x24 -> w119 (quiet)
    lui x7, 591                       # x24 -> w119 (quiet)
    addi x24, x24, %pcrel_lo(.L240)   # x24 -> w119
    addi x25, x0, 1987                # sw's store data
    lui x28, 592                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 593                      # quiet
    lui x6, 594                       # quiet
    sw x25, 0(x24)                    # subject sw: reader, reads x24 at addr (war)
    lui x7, 595                       # filler (gap)
    jal x24, .L241                    # jal: writer, writes x24 after the reader, d2 (war_addr_jal_d2)
.L241:
    lui x28, 596                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 597                      # quiet
    lui x6, 598                       # quiet
# block 141  war_addr_jal_d3  sw after jal  expect(isa): none 0
    lui x0, 141  # marker: block 141
    lui x7, 599                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 600                      # quiet
    lui x29, 601                      # quiet
    .L242: auipc x26, %pcrel_hi(w120) # x26 -> w120
    lui x6, 602                       # x26 -> w120 (quiet)
    lui x7, 603                       # x26 -> w120 (quiet)
    lui x28, 604                      # x26 -> w120 (quiet)
    addi x26, x26, %pcrel_lo(.L242)   # x26 -> w120
    addi x27, x0, 2001                # sw's store data
    lui x29, 605                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 606                       # quiet
    lui x7, 607                       # quiet
    sw x27, 0(x26)                    # subject sw: reader, reads x26 at addr (war)
    lui x28, 608                      # filler (gap)
    lui x29, 609                      # filler (gap)
    jal x26, .L243                    # jal: writer, writes x26 after the reader, d3 (war_addr_jal_d3)
.L243:
    lui x6, 610                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 611                       # quiet
    lui x28, 612                      # quiet
# block 142  war_addr_alu_rr_d1  sw after add  expect(isa): none 0
    lui x0, 142  # marker: block 142
    lui x29, 613                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 614                       # quiet
    lui x7, 615                       # quiet
    .L244: auipc x3, %pcrel_hi(w121)  # x3 -> w121
    lui x28, 616                      # x3 -> w121 (quiet)
    lui x29, 617                      # x3 -> w121 (quiet)
    lui x6, 618                       # x3 -> w121 (quiet)
    addi x3, x3, %pcrel_lo(.L244)     # x3 -> w121
    addi x8, x0, 2015                 # sw's store data
    addi x9, x0, 2022                 # add's operand
    addi x10, x0, 2029                # add's operand
    lui x7, 619                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 620                      # quiet
    lui x29, 621                      # quiet
    sw x8, 0(x3)                      # subject sw: reader, reads x3 at addr (war)
    add x3, x9, x10                   # add: writer, writes x3 after the reader, d1 (war_addr_alu_rr_d1)
    lui x6, 622                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 623                       # quiet
    lui x28, 624                      # quiet
# block 143  war_addr_alu_rr_d2  sw after add  expect(isa): none 0
    lui x0, 143  # marker: block 143
    lui x29, 625                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 626                       # quiet
    lui x7, 627                       # quiet
    .L245: auipc x11, %pcrel_hi(w122) # x11 -> w122
    lui x28, 628                      # x11 -> w122 (quiet)
    lui x29, 629                      # x11 -> w122 (quiet)
    lui x6, 630                       # x11 -> w122 (quiet)
    addi x11, x11, %pcrel_lo(.L245)   # x11 -> w122
    addi x12, x0, 267                 # sw's store data
    addi x13, x0, 274                 # add's operand
    addi x14, x0, 281                 # add's operand
    lui x7, 631                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 632                      # quiet
    lui x29, 633                      # quiet
    sw x12, 0(x11)                    # subject sw: reader, reads x11 at addr (war)
    lui x6, 634                       # filler (gap)
    add x11, x13, x14                 # add: writer, writes x11 after the reader, d2 (war_addr_alu_rr_d2)
    lui x7, 635                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 636                      # quiet
    lui x29, 637                      # quiet
# block 144  war_addr_alu_rr_d3  sw after add  expect(isa): none 0
    lui x0, 144  # marker: block 144
    lui x6, 638                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 639                       # quiet
    lui x28, 640                      # quiet
    .L246: auipc x15, %pcrel_hi(w123) # x15 -> w123
    lui x29, 641                      # x15 -> w123 (quiet)
    lui x6, 642                       # x15 -> w123 (quiet)
    lui x7, 643                       # x15 -> w123 (quiet)
    addi x15, x15, %pcrel_lo(.L246)   # x15 -> w123
    addi x16, x0, 295                 # sw's store data
    addi x17, x0, 302                 # add's operand
    addi x18, x0, 309                 # add's operand
    lui x28, 644                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 645                      # quiet
    lui x6, 646                       # quiet
    sw x16, 0(x15)                    # subject sw: reader, reads x15 at addr (war)
    lui x7, 647                       # filler (gap)
    lui x28, 648                      # filler (gap)
    add x15, x17, x18                 # add: writer, writes x15 after the reader, d3 (war_addr_alu_rr_d3)
    lui x29, 649                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 650                       # quiet
    lui x7, 651                       # quiet
# block 145  war_addr_alu_ri_d1  sw after addi  expect(isa): none 0
    lui x0, 145  # marker: block 145
    lui x28, 652                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 653                      # quiet
    lui x6, 654                       # quiet
    .L247: auipc x19, %pcrel_hi(w124) # x19 -> w124
    lui x7, 655                       # x19 -> w124 (quiet)
    lui x28, 656                      # x19 -> w124 (quiet)
    lui x29, 657                      # x19 -> w124 (quiet)
    addi x19, x19, %pcrel_lo(.L247)   # x19 -> w124
    addi x20, x0, 0                   # sw's store data
    addi x21, x0, 323                 # addi's operand
    lui x6, 658                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 659                       # quiet
    lui x28, 660                      # quiet
    sw x20, 0(x19)                    # subject sw: reader, reads x19 at addr (war)
    addi x19, x21, 0                  # addi: writer, writes x19 after the reader, d1 (war_addr_alu_ri_d1)
    lui x29, 661                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 662                       # quiet
    lui x7, 663                       # quiet
# block 146  war_addr_alu_ri_d2  sw after addi  expect(isa): none 0
    lui x0, 146  # marker: block 146
    lui x28, 664                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 665                      # quiet
    lui x6, 666                       # quiet
    .L248: auipc x22, %pcrel_hi(w125) # x22 -> w125
    lui x7, 667                       # x22 -> w125 (quiet)
    lui x28, 668                      # x22 -> w125 (quiet)
    lui x29, 669                      # x22 -> w125 (quiet)
    addi x22, x22, %pcrel_lo(.L248)   # x22 -> w125
    addi x23, x0, 337                 # sw's store data
    addi x24, x0, 344                 # addi's operand
    lui x6, 670                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 671                       # quiet
    lui x28, 672                      # quiet
    sw x23, 0(x22)                    # subject sw: reader, reads x22 at addr (war)
    lui x29, 673                      # filler (gap)
    addi x22, x24, 0                  # addi: writer, writes x22 after the reader, d2 (war_addr_alu_ri_d2)
    lui x6, 674                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 675                       # quiet
    lui x28, 676                      # quiet
# block 147  war_addr_alu_ri_d3  sw after addi  expect(isa): none 0
    lui x0, 147  # marker: block 147
    lui x29, 677                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 678                       # quiet
    lui x7, 679                       # quiet
    .L249: auipc x25, %pcrel_hi(w126) # x25 -> w126
    lui x28, 680                      # x25 -> w126 (quiet)
    lui x29, 681                      # x25 -> w126 (quiet)
    lui x6, 682                       # x25 -> w126 (quiet)
    addi x25, x25, %pcrel_lo(.L249)   # x25 -> w126
    addi x26, x0, 358                 # sw's store data
    addi x27, x0, 365                 # addi's operand
    lui x7, 683                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 684                      # quiet
    lui x29, 685                      # quiet
    sw x26, 0(x25)                    # subject sw: reader, reads x25 at addr (war)
    lui x6, 686                       # filler (gap)
    lui x7, 687                       # filler (gap)
    addi x25, x27, 0                  # addi: writer, writes x25 after the reader, d3 (war_addr_alu_ri_d3)
    lui x28, 688                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 689                      # quiet
    lui x6, 690                       # quiet
# block 148  war_addr_alu_nosrc_d1  sw after auipc  expect(isa): none 0
    lui x0, 148  # marker: block 148
    lui x7, 691                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 692                      # quiet
    lui x29, 693                      # quiet
    .L250: auipc x3, %pcrel_hi(w127)  # x3 -> w127
    lui x6, 694                       # x3 -> w127 (quiet)
    lui x7, 695                       # x3 -> w127 (quiet)
    lui x28, 696                      # x3 -> w127 (quiet)
    addi x3, x3, %pcrel_lo(.L250)     # x3 -> w127
    addi x8, x0, 379                  # sw's store data
    lui x29, 697                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 698                       # quiet
    lui x7, 699                       # quiet
    sw x8, 0(x3)                      # subject sw: reader, reads x3 at addr (war)
    auipc x3, 74565                   # auipc: writer, writes x3 after the reader, d1 (war_addr_alu_nosrc_d1)
    lui x28, 700                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 701                      # quiet
    lui x6, 702                       # quiet
# block 149  war_addr_alu_nosrc_d2  sw after auipc  expect(isa): none 0
    lui x0, 149  # marker: block 149
    lui x7, 703                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 704                      # quiet
    lui x29, 705                      # quiet
    .L251: auipc x9, %pcrel_hi(w128)  # x9 -> w128
    lui x6, 706                       # x9 -> w128 (quiet)
    lui x7, 707                       # x9 -> w128 (quiet)
    lui x28, 708                      # x9 -> w128 (quiet)
    addi x9, x9, %pcrel_lo(.L251)     # x9 -> w128
    addi x10, x0, 1                   # sw's store data
    lui x29, 709                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 710                       # quiet
    lui x7, 711                       # quiet
    sw x10, 0(x9)                     # subject sw: reader, reads x9 at addr (war)
    lui x28, 712                      # filler (gap)
    auipc x9, 74565                   # auipc: writer, writes x9 after the reader, d2 (war_addr_alu_nosrc_d2)
    lui x29, 713                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 714                       # quiet
    lui x7, 715                       # quiet
# block 150  war_addr_alu_nosrc_d3  sw after auipc  expect(isa): none 0
    lui x0, 150  # marker: block 150
    lui x28, 716                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 717                      # quiet
    lui x6, 718                       # quiet
    .L252: auipc x11, %pcrel_hi(w129) # x11 -> w129
    lui x7, 719                       # x11 -> w129 (quiet)
    lui x28, 720                      # x11 -> w129 (quiet)
    lui x29, 721                      # x11 -> w129 (quiet)
    addi x11, x11, %pcrel_lo(.L252)   # x11 -> w129
    addi x12, x0, 400                 # sw's store data
    lui x6, 722                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 723                       # quiet
    lui x28, 724                      # quiet
    sw x12, 0(x11)                    # subject sw: reader, reads x11 at addr (war)
    lui x29, 725                      # filler (gap)
    lui x6, 726                       # filler (gap)
    auipc x11, 74565                  # auipc: writer, writes x11 after the reader, d3 (war_addr_alu_nosrc_d3)
    lui x7, 727                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 728                      # quiet
    lui x29, 729                      # quiet
# block 151  war_data_load_d1  sw after lb  expect(isa): none 0
    lui x0, 151  # marker: block 151
    lui x6, 730                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 731                       # quiet
    lui x28, 732                      # quiet
    addi x13, x0, 407                 # x13 = 407
    .L253: auipc x14, %pcrel_hi(w130) # sw's base -> w130
    lui x29, 733                      # sw's base -> w130 (quiet)
    lui x6, 734                       # sw's base -> w130 (quiet)
    lui x7, 735                       # sw's base -> w130 (quiet)
    addi x14, x14, %pcrel_lo(.L253)   # sw's base -> w130
    .L254: auipc x15, %pcrel_hi(w131) # lb's base -> w131
    lui x28, 736                      # lb's base -> w131 (quiet)
    lui x29, 737                      # lb's base -> w131 (quiet)
    lui x6, 738                       # lb's base -> w131 (quiet)
    addi x15, x15, %pcrel_lo(.L254)   # lb's base -> w131
    lui x7, 739                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 740                      # quiet
    lui x29, 741                      # quiet
    sw x13, 0(x14)                    # subject sw: reader, reads x13 at data (war)
    lb x13, 0(x15)                    # lb: writer, writes x13 after the reader, d1 (war_data_load_d1)
    lui x6, 742                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 743                       # quiet
    lui x28, 744                      # quiet
# block 152  war_data_load_d2  sw after lb  expect(isa): none 0
    lui x0, 152  # marker: block 152
    lui x29, 745                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 746                       # quiet
    lui x7, 747                       # quiet
    addi x16, x0, 428                 # x16 = 428
    .L255: auipc x17, %pcrel_hi(w132) # sw's base -> w132
    lui x28, 748                      # sw's base -> w132 (quiet)
    lui x29, 749                      # sw's base -> w132 (quiet)
    lui x6, 750                       # sw's base -> w132 (quiet)
    addi x17, x17, %pcrel_lo(.L255)   # sw's base -> w132
    .L256: auipc x18, %pcrel_hi(w133) # lb's base -> w133
    lui x7, 751                       # lb's base -> w133 (quiet)
    lui x28, 752                      # lb's base -> w133 (quiet)
    lui x29, 753                      # lb's base -> w133 (quiet)
    addi x18, x18, %pcrel_lo(.L256)   # lb's base -> w133
    lui x6, 754                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 755                       # quiet
    lui x28, 756                      # quiet
    sw x16, 0(x17)                    # subject sw: reader, reads x16 at data (war)
    lui x29, 757                      # filler (gap)
    lb x16, 0(x18)                    # lb: writer, writes x16 after the reader, d2 (war_data_load_d2)
    lui x6, 758                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 759                       # quiet
    lui x28, 760                      # quiet
# block 153  war_data_load_d3  sw after lb  expect(isa): none 0
    lui x0, 153  # marker: block 153
    lui x29, 761                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 762                       # quiet
    lui x7, 763                       # quiet
    addi x19, x0, 449                 # x19 = 449
    .L257: auipc x20, %pcrel_hi(w134) # sw's base -> w134
    lui x28, 764                      # sw's base -> w134 (quiet)
    lui x29, 765                      # sw's base -> w134 (quiet)
    lui x6, 766                       # sw's base -> w134 (quiet)
    addi x20, x20, %pcrel_lo(.L257)   # sw's base -> w134
    .L258: auipc x21, %pcrel_hi(w135) # lb's base -> w135
    lui x7, 767                       # lb's base -> w135 (quiet)
    lui x28, 768                      # lb's base -> w135 (quiet)
    lui x29, 769                      # lb's base -> w135 (quiet)
    addi x21, x21, %pcrel_lo(.L258)   # lb's base -> w135
    lui x6, 770                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 771                       # quiet
    lui x28, 772                      # quiet
    sw x19, 0(x20)                    # subject sw: reader, reads x19 at data (war)
    lui x29, 773                      # filler (gap)
    lui x6, 774                       # filler (gap)
    lb x19, 0(x21)                    # lb: writer, writes x19 after the reader, d3 (war_data_load_d3)
    lui x7, 775                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 776                      # quiet
    lui x29, 777                      # quiet
# block 154  war_data_jalr_d1  sw after jalr  expect(isa): none 0
    lui x0, 154  # marker: block 154
    lui x6, 778                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 779                       # quiet
    lui x28, 780                      # quiet
    addi x22, x0, 470                 # x22 = 470
    .L259: auipc x23, %pcrel_hi(w136) # sw's base -> w136
    lui x29, 781                      # sw's base -> w136 (quiet)
    lui x6, 782                       # sw's base -> w136 (quiet)
    lui x7, 783                       # sw's base -> w136 (quiet)
    addi x23, x23, %pcrel_lo(.L259)   # sw's base -> w136
    .L261: auipc x24, %pcrel_hi(.L260) # jalr's target -> .L260, the label after it
    lui x28, 784                      # jalr's target -> .L260, the label after it (quiet)
    lui x29, 785                      # jalr's target -> .L260, the label after it (quiet)
    lui x6, 786                       # jalr's target -> .L260, the label after it (quiet)
    addi x24, x24, %pcrel_lo(.L261)   # jalr's target -> .L260, the label after it
    lui x7, 787                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 788                      # quiet
    lui x29, 789                      # quiet
    sw x22, 0(x23)                    # subject sw: reader, reads x22 at data (war)
    jalr x22, 0(x24)                  # jalr: writer, writes x22 after the reader, d1 (war_data_jalr_d1)
.L260:
    lui x6, 790                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 791                       # quiet
    lui x28, 792                      # quiet
# block 155  war_data_jalr_d2  sw after jalr  expect(isa): none 0
    lui x0, 155  # marker: block 155
    lui x29, 793                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 794                       # quiet
    lui x7, 795                       # quiet
    addi x25, x0, 484                 # x25 = 484
    .L262: auipc x26, %pcrel_hi(w137) # sw's base -> w137
    lui x28, 796                      # sw's base -> w137 (quiet)
    lui x29, 797                      # sw's base -> w137 (quiet)
    lui x6, 798                       # sw's base -> w137 (quiet)
    addi x26, x26, %pcrel_lo(.L262)   # sw's base -> w137
    .L264: auipc x27, %pcrel_hi(.L263) # jalr's target -> .L263, the label after it
    lui x7, 799                       # jalr's target -> .L263, the label after it (quiet)
    lui x28, 800                      # jalr's target -> .L263, the label after it (quiet)
    lui x29, 801                      # jalr's target -> .L263, the label after it (quiet)
    addi x27, x27, %pcrel_lo(.L264)   # jalr's target -> .L263, the label after it
    lui x6, 802                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 803                       # quiet
    lui x28, 804                      # quiet
    sw x25, 0(x26)                    # subject sw: reader, reads x25 at data (war)
    lui x29, 805                      # filler (gap)
    jalr x25, 0(x27)                  # jalr: writer, writes x25 after the reader, d2 (war_data_jalr_d2)
.L263:
    lui x6, 806                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 807                       # quiet
    lui x28, 808                      # quiet
# block 156  war_data_jalr_d3  sw after jalr  expect(isa): none 0
    lui x0, 156  # marker: block 156
    lui x29, 809                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 810                       # quiet
    lui x7, 811                       # quiet
    addi x3, x0, 498                  # x3 = 498
    .L265: auipc x8, %pcrel_hi(w138)  # sw's base -> w138
    lui x28, 812                      # sw's base -> w138 (quiet)
    lui x29, 813                      # sw's base -> w138 (quiet)
    lui x6, 814                       # sw's base -> w138 (quiet)
    addi x8, x8, %pcrel_lo(.L265)     # sw's base -> w138
    .L267: auipc x9, %pcrel_hi(.L266) # jalr's target -> .L266, the label after it
    lui x7, 815                       # jalr's target -> .L266, the label after it (quiet)
    lui x28, 816                      # jalr's target -> .L266, the label after it (quiet)
    lui x29, 817                      # jalr's target -> .L266, the label after it (quiet)
    addi x9, x9, %pcrel_lo(.L267)     # jalr's target -> .L266, the label after it
    lui x6, 818                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 819                       # quiet
    lui x28, 820                      # quiet
    sw x3, 0(x8)                      # subject sw: reader, reads x3 at data (war)
    lui x29, 821                      # filler (gap)
    lui x6, 822                       # filler (gap)
    jalr x3, 0(x9)                    # jalr: writer, writes x3 after the reader, d3 (war_data_jalr_d3)
.L266:
    lui x7, 823                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 824                      # quiet
    lui x29, 825                      # quiet
# block 157  war_data_jal_d1  sw after jal  expect(isa): none 0
    lui x0, 157  # marker: block 157
    lui x6, 826                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 827                       # quiet
    lui x28, 828                      # quiet
    addi x10, x0, 512                 # x10 = 512
    .L268: auipc x11, %pcrel_hi(w139) # sw's base -> w139
    lui x29, 829                      # sw's base -> w139 (quiet)
    lui x6, 830                       # sw's base -> w139 (quiet)
    lui x7, 831                       # sw's base -> w139 (quiet)
    addi x11, x11, %pcrel_lo(.L268)   # sw's base -> w139
    lui x28, 832                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 833                      # quiet
    lui x6, 834                       # quiet
    sw x10, 0(x11)                    # subject sw: reader, reads x10 at data (war)
    jal x10, .L269                    # jal: writer, writes x10 after the reader, d1 (war_data_jal_d1)
.L269:
    lui x7, 835                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 836                      # quiet
    lui x29, 837                      # quiet
# block 158  war_data_jal_d2  sw after jal  expect(isa): none 0
    lui x0, 158  # marker: block 158
    lui x6, 838                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 839                       # quiet
    lui x28, 840                      # quiet
    addi x12, x0, 526                 # x12 = 526
    .L270: auipc x13, %pcrel_hi(w140) # sw's base -> w140
    lui x29, 841                      # sw's base -> w140 (quiet)
    lui x6, 842                       # sw's base -> w140 (quiet)
    lui x7, 843                       # sw's base -> w140 (quiet)
    addi x13, x13, %pcrel_lo(.L270)   # sw's base -> w140
    lui x28, 844                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 845                      # quiet
    lui x6, 846                       # quiet
    sw x12, 0(x13)                    # subject sw: reader, reads x12 at data (war)
    lui x7, 847                       # filler (gap)
    jal x12, .L271                    # jal: writer, writes x12 after the reader, d2 (war_data_jal_d2)
.L271:
    lui x28, 848                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 849                      # quiet
    lui x6, 850                       # quiet
# block 159  war_data_jal_d3  sw after jal  expect(isa): none 0
    lui x0, 159  # marker: block 159
    lui x7, 851                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 852                      # quiet
    lui x29, 853                      # quiet
    addi x14, x0, 540                 # x14 = 540
    .L272: auipc x15, %pcrel_hi(w141) # sw's base -> w141
    lui x6, 854                       # sw's base -> w141 (quiet)
    lui x7, 855                       # sw's base -> w141 (quiet)
    lui x28, 856                      # sw's base -> w141 (quiet)
    addi x15, x15, %pcrel_lo(.L272)   # sw's base -> w141
    lui x29, 857                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 858                       # quiet
    lui x7, 859                       # quiet
    sw x14, 0(x15)                    # subject sw: reader, reads x14 at data (war)
    lui x28, 860                      # filler (gap)
    lui x29, 861                      # filler (gap)
    jal x14, .L273                    # jal: writer, writes x14 after the reader, d3 (war_data_jal_d3)
.L273:
    lui x6, 862                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 863                       # quiet
    lui x28, 864                      # quiet
# block 160  war_data_alu_rr_d1  sw after add  expect(isa): none 0
    lui x0, 160  # marker: block 160
    lui x29, 865                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 866                       # quiet
    lui x7, 867                       # quiet
    addi x16, x0, 554                 # x16 = 554
    .L274: auipc x17, %pcrel_hi(w142) # sw's base -> w142
    lui x28, 868                      # sw's base -> w142 (quiet)
    lui x29, 869                      # sw's base -> w142 (quiet)
    lui x6, 870                       # sw's base -> w142 (quiet)
    addi x17, x17, %pcrel_lo(.L274)   # sw's base -> w142
    addi x18, x0, 568                 # add's operand
    addi x19, x0, 575                 # add's operand
    lui x7, 871                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 872                      # quiet
    lui x29, 873                      # quiet
    sw x16, 0(x17)                    # subject sw: reader, reads x16 at data (war)
    add x16, x18, x19                 # add: writer, writes x16 after the reader, d1 (war_data_alu_rr_d1)
    lui x6, 874                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 875                       # quiet
    lui x28, 876                      # quiet
# block 161  war_data_alu_rr_d2  sw after add  expect(isa): none 0
    lui x0, 161  # marker: block 161
    lui x29, 877                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 878                       # quiet
    lui x7, 879                       # quiet
    addi x20, x0, 582                 # x20 = 582
    .L275: auipc x21, %pcrel_hi(w143) # sw's base -> w143
    lui x28, 880                      # sw's base -> w143 (quiet)
    lui x29, 881                      # sw's base -> w143 (quiet)
    lui x6, 882                       # sw's base -> w143 (quiet)
    addi x21, x21, %pcrel_lo(.L275)   # sw's base -> w143
    addi x22, x0, 596                 # add's operand
    addi x23, x0, 603                 # add's operand
    lui x7, 883                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 884                      # quiet
    lui x29, 885                      # quiet
    sw x20, 0(x21)                    # subject sw: reader, reads x20 at data (war)
    lui x6, 886                       # filler (gap)
    add x20, x22, x23                 # add: writer, writes x20 after the reader, d2 (war_data_alu_rr_d2)
    lui x7, 887                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 888                      # quiet
    lui x29, 889                      # quiet
# block 162  war_data_alu_rr_d3  sw after add  expect(isa): none 0
    lui x0, 162  # marker: block 162
    lui x6, 890                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 891                       # quiet
    lui x28, 892                      # quiet
    addi x24, x0, 610                 # x24 = 610
    .L276: auipc x25, %pcrel_hi(w144) # sw's base -> w144
    lui x29, 893                      # sw's base -> w144 (quiet)
    lui x6, 894                       # sw's base -> w144 (quiet)
    lui x7, 895                       # sw's base -> w144 (quiet)
    addi x25, x25, %pcrel_lo(.L276)   # sw's base -> w144
    addi x26, x0, 624                 # add's operand
    addi x27, x0, 631                 # add's operand
    lui x28, 896                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 897                      # quiet
    lui x6, 898                       # quiet
    sw x24, 0(x25)                    # subject sw: reader, reads x24 at data (war)
    lui x7, 899                       # filler (gap)
    lui x28, 900                      # filler (gap)
    add x24, x26, x27                 # add: writer, writes x24 after the reader, d3 (war_data_alu_rr_d3)
    lui x29, 901                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 902                       # quiet
    lui x7, 903                       # quiet
# block 163  war_data_alu_ri_d1  sw after addi  expect(isa): none 0
    lui x0, 163  # marker: block 163
    lui x28, 904                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 905                      # quiet
    lui x6, 906                       # quiet
    addi x3, x0, 638                  # x3 = 638
    .L277: auipc x8, %pcrel_hi(w145)  # sw's base -> w145
    lui x7, 907                       # sw's base -> w145 (quiet)
    lui x28, 908                      # sw's base -> w145 (quiet)
    lui x29, 909                      # sw's base -> w145 (quiet)
    addi x8, x8, %pcrel_lo(.L277)     # sw's base -> w145
    addi x9, x0, 652                  # addi's operand
    lui x6, 910                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 911                       # quiet
    lui x28, 912                      # quiet
    sw x3, 0(x8)                      # subject sw: reader, reads x3 at data (war)
    addi x3, x9, 0                    # addi: writer, writes x3 after the reader, d1 (war_data_alu_ri_d1)
    lui x29, 913                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 914                       # quiet
    lui x7, 915                       # quiet
# block 164  war_data_alu_ri_d2  sw after addi  expect(isa): none 0
    lui x0, 164  # marker: block 164
    lui x28, 916                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 917                      # quiet
    lui x6, 918                       # quiet
    addi x10, x0, 659                 # x10 = 659
    .L278: auipc x11, %pcrel_hi(w146) # sw's base -> w146
    lui x7, 919                       # sw's base -> w146 (quiet)
    lui x28, 920                      # sw's base -> w146 (quiet)
    lui x29, 921                      # sw's base -> w146 (quiet)
    addi x11, x11, %pcrel_lo(.L278)   # sw's base -> w146
    addi x12, x0, 673                 # addi's operand
    lui x6, 922                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 923                       # quiet
    lui x28, 924                      # quiet
    sw x10, 0(x11)                    # subject sw: reader, reads x10 at data (war)
    lui x29, 925                      # filler (gap)
    addi x10, x12, 0                  # addi: writer, writes x10 after the reader, d2 (war_data_alu_ri_d2)
    lui x6, 926                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 927                       # quiet
    lui x28, 928                      # quiet
# block 165  war_data_alu_ri_d3  sw after addi  expect(isa): none 0
    lui x0, 165  # marker: block 165
    lui x29, 929                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 930                       # quiet
    lui x7, 931                       # quiet
    addi x13, x0, 680                 # x13 = 680
    .L279: auipc x14, %pcrel_hi(w147) # sw's base -> w147
    lui x28, 932                      # sw's base -> w147 (quiet)
    lui x29, 933                      # sw's base -> w147 (quiet)
    lui x6, 934                       # sw's base -> w147 (quiet)
    addi x14, x14, %pcrel_lo(.L279)   # sw's base -> w147
    addi x15, x0, 694                 # addi's operand
    lui x7, 935                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 936                      # quiet
    lui x29, 937                      # quiet
    sw x13, 0(x14)                    # subject sw: reader, reads x13 at data (war)
    lui x6, 938                       # filler (gap)
    lui x7, 939                       # filler (gap)
    addi x13, x15, 0                  # addi: writer, writes x13 after the reader, d3 (war_data_alu_ri_d3)
    lui x28, 940                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 941                      # quiet
    lui x6, 942                       # quiet
# block 166  war_data_alu_nosrc_d1  sw after auipc  expect(isa): none 0
    lui x0, 166  # marker: block 166
    lui x7, 943                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 944                      # quiet
    lui x29, 945                      # quiet
    addi x16, x0, 701                 # x16 = 701
    .L280: auipc x17, %pcrel_hi(w148) # sw's base -> w148
    lui x6, 946                       # sw's base -> w148 (quiet)
    lui x7, 947                       # sw's base -> w148 (quiet)
    lui x28, 948                      # sw's base -> w148 (quiet)
    addi x17, x17, %pcrel_lo(.L280)   # sw's base -> w148
    lui x29, 949                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 950                       # quiet
    lui x7, 951                       # quiet
    sw x16, 0(x17)                    # subject sw: reader, reads x16 at data (war)
    auipc x16, 74565                  # auipc: writer, writes x16 after the reader, d1 (war_data_alu_nosrc_d1)
    lui x28, 952                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 953                      # quiet
    lui x6, 954                       # quiet
# block 167  war_data_alu_nosrc_d2  sw after auipc  expect(isa): none 0
    lui x0, 167  # marker: block 167
    lui x7, 955                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 956                      # quiet
    lui x29, 957                      # quiet
    addi x18, x0, 715                 # x18 = 715
    .L281: auipc x19, %pcrel_hi(w149) # sw's base -> w149
    lui x6, 958                       # sw's base -> w149 (quiet)
    lui x7, 959                       # sw's base -> w149 (quiet)
    lui x28, 960                      # sw's base -> w149 (quiet)
    addi x19, x19, %pcrel_lo(.L281)   # sw's base -> w149
    lui x29, 961                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 962                       # quiet
    lui x7, 963                       # quiet
    sw x18, 0(x19)                    # subject sw: reader, reads x18 at data (war)
    lui x28, 964                      # filler (gap)
    auipc x18, 74565                  # auipc: writer, writes x18 after the reader, d2 (war_data_alu_nosrc_d2)
    lui x29, 965                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 966                       # quiet
    lui x7, 967                       # quiet
# block 168  war_data_alu_nosrc_d3  sw after auipc  expect(isa): none 0
    lui x0, 168  # marker: block 168
    lui x28, 968                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 969                      # quiet
    lui x6, 970                       # quiet
    addi x20, x0, 729                 # x20 = 729
    .L282: auipc x21, %pcrel_hi(w150) # sw's base -> w150
    lui x7, 971                       # sw's base -> w150 (quiet)
    lui x28, 972                      # sw's base -> w150 (quiet)
    lui x29, 973                      # sw's base -> w150 (quiet)
    addi x21, x21, %pcrel_lo(.L282)   # sw's base -> w150
    lui x6, 974                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 975                       # quiet
    lui x28, 976                      # quiet
    sw x20, 0(x21)                    # subject sw: reader, reads x20 at data (war)
    lui x29, 977                      # filler (gap)
    lui x6, 978                       # filler (gap)
    auipc x20, 74565                  # auipc: writer, writes x20 after the reader, d3 (war_data_alu_nosrc_d3)
    lui x7, 979                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 980                      # quiet
    lui x29, 981                      # quiet
# block 169  ctrl_taken_branch_d1  sw after beq  expect(isa): bubble 3
    lui x0, 169  # marker: block 169
    lui x6, 982                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 983                       # quiet
    lui x28, 984                      # quiet
    addi x22, x0, 743                 # beq's operand
    addi x23, x0, 750                 # beq's operand
    addi x22, x0, 0                   # x22 = 0
    addi x23, x0, 0                   # x23 = 0
    .L283: auipc x24, %pcrel_hi(w151) # sw's base -> w151
    lui x29, 985                      # sw's base -> w151 (quiet)
    lui x6, 986                       # sw's base -> w151 (quiet)
    lui x7, 987                       # sw's base -> w151 (quiet)
    addi x24, x24, %pcrel_lo(.L283)   # sw's base -> w151
    addi x25, x0, 764                 # sw's store data
    lui x28, 988                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 989                      # quiet
    lui x6, 990                       # quiet
    beq x22, x23, .L284               # beq: the taken transfer
.L284:
    sw x25, 0(x24)                    # subject sw: d1 after the transfer (ctrl_taken_branch_d1)
    lui x7, 991                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 992                      # quiet
    lui x29, 993                      # quiet
# block 170  ctrl_taken_branch_d2  sw after beq  expect(isa): bubble 0
    lui x0, 170  # marker: block 170
    lui x6, 994                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 995                       # quiet
    lui x28, 996                      # quiet
    addi x26, x0, 771                 # beq's operand
    addi x27, x0, 778                 # beq's operand
    addi x26, x0, 0                   # x26 = 0
    addi x27, x0, 0                   # x27 = 0
    .L285: auipc x3, %pcrel_hi(w152)  # sw's base -> w152
    lui x29, 997                      # sw's base -> w152 (quiet)
    lui x6, 998                       # sw's base -> w152 (quiet)
    lui x7, 999                       # sw's base -> w152 (quiet)
    addi x3, x3, %pcrel_lo(.L285)     # sw's base -> w152
    addi x8, x0, 792                  # sw's store data
    lui x28, 1000                     # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 1                        # quiet
    lui x6, 2                         # quiet
    beq x26, x27, .L286               # beq: the taken transfer
.L286:
    lui x7, 3                         # filler (gap)
    sw x8, 0(x3)                      # subject sw: d2 after the transfer (ctrl_taken_branch_d2)
    lui x28, 4                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 5                        # quiet
    lui x6, 6                         # quiet
# block 171  ctrl_taken_branch_d3  sw after beq  expect(isa): bubble 0
    lui x0, 171  # marker: block 171
    lui x7, 7                         # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 8                        # quiet
    lui x29, 9                        # quiet
    addi x9, x0, 799                  # beq's operand
    addi x10, x0, 806                 # beq's operand
    addi x9, x0, 0                    # x9 = 0
    addi x10, x0, 0                   # x10 = 0
    .L287: auipc x11, %pcrel_hi(w153) # sw's base -> w153
    lui x6, 10                        # sw's base -> w153 (quiet)
    lui x7, 11                        # sw's base -> w153 (quiet)
    lui x28, 12                       # sw's base -> w153 (quiet)
    addi x11, x11, %pcrel_lo(.L287)   # sw's base -> w153
    addi x12, x0, 0                   # sw's store data
    lui x29, 13                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 14                        # quiet
    lui x7, 15                        # quiet
    beq x9, x10, .L288                # beq: the taken transfer
.L288:
    lui x28, 16                       # filler (gap)
    lui x29, 17                       # filler (gap)
    sw x12, 0(x11)                    # subject sw: d3 after the transfer (ctrl_taken_branch_d3)
    lui x6, 18                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 19                        # quiet
    lui x28, 20                       # quiet
# block 172  ctrl_taken_jal_d1  sw after jal  expect(isa): bubble 3
    lui x0, 172  # marker: block 172
    lui x29, 21                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 22                        # quiet
    lui x7, 23                        # quiet
    addi x13, x0, 820                 # jal's rd before (stale)
    .L289: auipc x14, %pcrel_hi(w154) # sw's base -> w154
    lui x28, 24                       # sw's base -> w154 (quiet)
    lui x29, 25                       # sw's base -> w154 (quiet)
    lui x6, 26                        # sw's base -> w154 (quiet)
    addi x14, x14, %pcrel_lo(.L289)   # sw's base -> w154
    addi x15, x0, 834                 # sw's store data
    lui x7, 27                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 28                       # quiet
    lui x29, 29                       # quiet
    jal x13, .L290                    # jal: the taken transfer
.L290:
    sw x15, 0(x14)                    # subject sw: d1 after the transfer (ctrl_taken_jal_d1)
    lui x6, 30                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 31                        # quiet
    lui x28, 32                       # quiet
# block 173  ctrl_taken_jal_d2  sw after jal  expect(isa): bubble 0
    lui x0, 173  # marker: block 173
    lui x29, 33                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 34                        # quiet
    lui x7, 35                        # quiet
    addi x16, x0, 841                 # jal's rd before (stale)
    .L291: auipc x17, %pcrel_hi(w155) # sw's base -> w155
    lui x28, 36                       # sw's base -> w155 (quiet)
    lui x29, 37                       # sw's base -> w155 (quiet)
    lui x6, 38                        # sw's base -> w155 (quiet)
    addi x17, x17, %pcrel_lo(.L291)   # sw's base -> w155
    addi x18, x0, 855                 # sw's store data
    lui x7, 39                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 40                       # quiet
    lui x29, 41                       # quiet
    jal x16, .L292                    # jal: the taken transfer
.L292:
    lui x6, 42                        # filler (gap)
    sw x18, 0(x17)                    # subject sw: d2 after the transfer (ctrl_taken_jal_d2)
    lui x7, 43                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 44                       # quiet
    lui x29, 45                       # quiet
# block 174  ctrl_taken_jal_d3  sw after jal  expect(isa): bubble 0
    lui x0, 174  # marker: block 174
    lui x6, 46                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 47                        # quiet
    lui x28, 48                       # quiet
    addi x19, x0, 862                 # jal's rd before (stale)
    .L293: auipc x20, %pcrel_hi(w156) # sw's base -> w156
    lui x29, 49                       # sw's base -> w156 (quiet)
    lui x6, 50                        # sw's base -> w156 (quiet)
    lui x7, 51                        # sw's base -> w156 (quiet)
    addi x20, x20, %pcrel_lo(.L293)   # sw's base -> w156
    addi x21, x0, 876                 # sw's store data
    lui x28, 52                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 53                       # quiet
    lui x6, 54                        # quiet
    jal x19, .L294                    # jal: the taken transfer
.L294:
    lui x7, 55                        # filler (gap)
    lui x28, 56                       # filler (gap)
    sw x21, 0(x20)                    # subject sw: d3 after the transfer (ctrl_taken_jal_d3)
    lui x29, 57                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 58                        # quiet
    lui x7, 59                        # quiet
# block 175  ctrl_taken_jalr_d1  sw after jalr  expect(isa): bubble 3
    lui x0, 175  # marker: block 175
    lui x28, 60                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 61                       # quiet
    lui x6, 62                        # quiet
    .L296: auipc x23, %pcrel_hi(.L295) # jalr's target -> .L295, the label after it
    lui x7, 63                        # jalr's target -> .L295, the label after it (quiet)
    lui x28, 64                       # jalr's target -> .L295, the label after it (quiet)
    lui x29, 65                       # jalr's target -> .L295, the label after it (quiet)
    addi x23, x23, %pcrel_lo(.L296)   # jalr's target -> .L295, the label after it
    addi x22, x0, 883                 # jalr's rd before (stale)
    .L297: auipc x24, %pcrel_hi(w157) # sw's base -> w157
    lui x6, 66                        # sw's base -> w157 (quiet)
    lui x7, 67                        # sw's base -> w157 (quiet)
    lui x28, 68                       # sw's base -> w157 (quiet)
    addi x24, x24, %pcrel_lo(.L297)   # sw's base -> w157
    addi x25, x0, 1                   # sw's store data
    lui x29, 69                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 70                        # quiet
    lui x7, 71                        # quiet
    jalr x22, 0(x23)                  # jalr: the taken transfer
.L295:
    sw x25, 0(x24)                    # subject sw: d1 after the transfer (ctrl_taken_jalr_d1)
    lui x28, 72                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 73                       # quiet
    lui x6, 74                        # quiet
# block 176  ctrl_taken_jalr_d2  sw after jalr  expect(isa): bubble 0
    lui x0, 176  # marker: block 176
    lui x7, 75                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 76                       # quiet
    lui x29, 77                       # quiet
    .L299: auipc x27, %pcrel_hi(.L298) # jalr's target -> .L298, the label after it
    lui x6, 78                        # jalr's target -> .L298, the label after it (quiet)
    lui x7, 79                        # jalr's target -> .L298, the label after it (quiet)
    lui x28, 80                       # jalr's target -> .L298, the label after it (quiet)
    addi x27, x27, %pcrel_lo(.L299)   # jalr's target -> .L298, the label after it
    addi x26, x0, 897                 # jalr's rd before (stale)
    .L300: auipc x3, %pcrel_hi(w158)  # sw's base -> w158
    lui x29, 81                       # sw's base -> w158 (quiet)
    lui x6, 82                        # sw's base -> w158 (quiet)
    lui x7, 83                        # sw's base -> w158 (quiet)
    addi x3, x3, %pcrel_lo(.L300)     # sw's base -> w158
    addi x8, x0, 911                  # sw's store data
    lui x28, 84                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 85                       # quiet
    lui x6, 86                        # quiet
    jalr x26, 0(x27)                  # jalr: the taken transfer
.L298:
    lui x7, 87                        # filler (gap)
    sw x8, 0(x3)                      # subject sw: d2 after the transfer (ctrl_taken_jalr_d2)
    lui x28, 88                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 89                       # quiet
    lui x6, 90                        # quiet
# block 177  ctrl_taken_jalr_d3  sw after jalr  expect(isa): bubble 0
    lui x0, 177  # marker: block 177
    lui x7, 91                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 92                       # quiet
    lui x29, 93                       # quiet
    .L302: auipc x10, %pcrel_hi(.L301) # jalr's target -> .L301, the label after it
    lui x6, 94                        # jalr's target -> .L301, the label after it (quiet)
    lui x7, 95                        # jalr's target -> .L301, the label after it (quiet)
    lui x28, 96                       # jalr's target -> .L301, the label after it (quiet)
    addi x10, x10, %pcrel_lo(.L302)   # jalr's target -> .L301, the label after it
    addi x9, x0, 918                  # jalr's rd before (stale)
    .L303: auipc x11, %pcrel_hi(w159) # sw's base -> w159
    lui x29, 97                       # sw's base -> w159 (quiet)
    lui x6, 98                        # sw's base -> w159 (quiet)
    lui x7, 99                        # sw's base -> w159 (quiet)
    addi x11, x11, %pcrel_lo(.L303)   # sw's base -> w159
    addi x12, x0, 932                 # sw's store data
    lui x28, 100                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 101                      # quiet
    lui x6, 102                       # quiet
    jalr x9, 0(x10)                   # jalr: the taken transfer
.L301:
    lui x7, 103                       # filler (gap)
    lui x28, 104                      # filler (gap)
    sw x12, 0(x11)                    # subject sw: d3 after the transfer (ctrl_taken_jalr_d3)
    lui x29, 105                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 106                       # quiet
    lui x7, 107                       # quiet
# block 178  k_x0  sw
    lui x0, 178  # marker: block 178
    lui x28, 108                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 109                      # quiet
    lui x6, 110                       # quiet
    .L304: auipc x3, %pcrel_hi(w160)  # x3 -> w160
    lui x7, 111                       # x3 -> w160 (quiet)
    lui x28, 112                      # x3 -> w160 (quiet)
    lui x29, 113                      # x3 -> w160 (quiet)
    addi x3, x3, %pcrel_lo(.L304)     # x3 -> w160
    lui x6, 114                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 115                       # quiet
    lui x28, 116                      # quiet
    addi x0, x0, 1                    # a writer of x0 in flight
    sw x0, 0(x3)                      # subject sw: the modifier case k_x0
    lui x29, 117                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 118                       # quiet
    lui x7, 119                       # quiet
# block 179  k_rs1_eq_rs2  sw
    lui x0, 179  # marker: block 179
    lui x28, 120                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 121                      # quiet
    lui x6, 122                       # quiet
    .L305: auipc x3, %pcrel_hi(w161)  # x3 -> w161
    lui x7, 123                       # x3 -> w161 (quiet)
    lui x28, 124                      # x3 -> w161 (quiet)
    lui x29, 125                      # x3 -> w161 (quiet)
    addi x3, x3, %pcrel_lo(.L305)     # x3 -> w161
    lui x6, 126                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 127                       # quiet
    lui x28, 128                      # quiet
    sw x3, 0(x3)                      # subject sw: the modifier case k_rs1_eq_rs2
    lui x29, 129                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 130                       # quiet
    lui x7, 131                       # quiet
    lui x0, 180  # marker: block 180
    lui x28, 132                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 133                      # quiet
    lui x6, 134                       # quiet
    .L306: auipc x13, %pcrel_hi(w162) # x13 -> w162
    lui x7, 135                       # x13 -> w162 (quiet)
    lui x28, 136                      # x13 -> w162 (quiet)
    lui x29, 137                      # x13 -> w162 (quiet)
    addi x13, x13, %pcrel_lo(.L306)   # x13 -> w162
    addi x14, x0, 960                 # x14 = 960
    addi x15, x0, 967                 # x15 = 967
    lui x6, 138                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 139                       # quiet
    lui x28, 140                      # quiet
    sb x14, 0(x13)                    # sb: the first access of w162
    sw x15, 0(x13)                    # subject sw: the second access of w162 (hazards_WAW_HAZARD)
    lui x29, 141                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 142                       # quiet
    lui x7, 143                       # quiet
    lui x0, 181  # marker: block 181
    lui x28, 144                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 145                      # quiet
    lui x6, 146                       # quiet
    .L307: auipc x16, %pcrel_hi(w163) # x16 -> w163
    lui x7, 147                       # x16 -> w163 (quiet)
    lui x28, 148                      # x16 -> w163 (quiet)
    lui x29, 149                      # x16 -> w163 (quiet)
    addi x16, x16, %pcrel_lo(.L307)   # x16 -> w163
    addi x17, x0, 981                 # x17 = 981
    addi x18, x0, 988                 # x18 = 988
    lui x6, 150                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 151                       # quiet
    lui x28, 152                      # quiet
    sh x17, 0(x16)                    # sh: the first access of w163
    sw x18, 0(x16)                    # subject sw: the second access of w163 (hazards_WAW_HAZARD)
    lui x29, 153                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 154                       # quiet
    lui x7, 155                       # quiet
    lui x0, 182  # marker: block 182
    lui x28, 156                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 157                      # quiet
    lui x6, 158                       # quiet
    .L308: auipc x19, %pcrel_hi(w164) # x19 -> w164
    lui x7, 159                       # x19 -> w164 (quiet)
    lui x28, 160                      # x19 -> w164 (quiet)
    lui x29, 161                      # x19 -> w164 (quiet)
    addi x19, x19, %pcrel_lo(.L308)   # x19 -> w164
    addi x20, x0, 1002                # x20 = 1002
    addi x21, x0, 1009                # x21 = 1009
    lui x6, 162                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 163                       # quiet
    lui x28, 164                      # quiet
    sw x20, 0(x19)                    # sw: the first access of w164
    sw x21, 0(x19)                    # subject sw: the second access of w164 (hazards_WAW_HAZARD)
    lui x29, 165                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 166                       # quiet
    lui x7, 167                       # quiet
    lui x0, 183  # marker: block 183
    lui x28, 168                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 169                      # quiet
    lui x6, 170                       # quiet
    .L309: auipc x22, %pcrel_hi(w165) # x22 -> w165
    lui x7, 171                       # x22 -> w165 (quiet)
    lui x28, 172                      # x22 -> w165 (quiet)
    lui x29, 173                      # x22 -> w165 (quiet)
    addi x22, x22, %pcrel_lo(.L309)   # x22 -> w165
    addi x24, x0, 1023                # x24 = 1023
    lui x6, 174                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 175                       # quiet
    lui x28, 176                      # quiet
    lb x23, 0(x22)                    # lb: the first access of w165
    sw x24, 0(x22)                    # subject sw: the second access of w165 (hazards_WAR_HAZARD)
    lui x29, 177                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 178                       # quiet
    lui x7, 179                       # quiet
    lui x0, 184  # marker: block 184
    lui x28, 180                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 181                      # quiet
    lui x6, 182                       # quiet
    .L310: auipc x25, %pcrel_hi(w166) # x25 -> w166
    lui x7, 183                       # x25 -> w166 (quiet)
    lui x28, 184                      # x25 -> w166 (quiet)
    lui x29, 185                      # x25 -> w166 (quiet)
    addi x25, x25, %pcrel_lo(.L310)   # x25 -> w166
    addi x27, x0, 1037                # x27 = 1037
    lui x6, 186                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 187                       # quiet
    lui x28, 188                      # quiet
    lh x26, 0(x25)                    # lh: the first access of w166
    sw x27, 0(x25)                    # subject sw: the second access of w166 (hazards_WAR_HAZARD)
    lui x29, 189                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 190                       # quiet
    lui x7, 191                       # quiet
    lui x0, 185  # marker: block 185
    lui x28, 192                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 193                      # quiet
    lui x6, 194                       # quiet
    .L311: auipc x3, %pcrel_hi(w167)  # x3 -> w167
    lui x7, 195                       # x3 -> w167 (quiet)
    lui x28, 196                      # x3 -> w167 (quiet)
    lui x29, 197                      # x3 -> w167 (quiet)
    addi x3, x3, %pcrel_lo(.L311)     # x3 -> w167
    addi x9, x0, 1051                 # x9 = 1051
    lui x6, 198                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 199                       # quiet
    lui x28, 200                      # quiet
    lw x8, 0(x3)                      # lw: the first access of w167
    sw x9, 0(x3)                      # subject sw: the second access of w167 (hazards_WAR_HAZARD)
    lui x29, 201                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 202                       # quiet
    lui x7, 203                       # quiet
TEST_END
    .section .data
    .align 12
tdata:
w0: .word 0x170
w1: .word w0
w2: .word 0x1f5
w3: .word w2
w4: .word 0x27a
w5: .word w4
w6: .word 0x2ff
w7: .word w6
w8: .word 0x37d
w9: .word w8
w10: .word 0x402
w11: .word w10
w12: .word 0x505
w13: .word 0x51a
w14: .word 0x528
w15: .word 0x53d
w16: .word 0x552
w17: .word 0x567
w18: .word 0x575
w19: .word 0x58a
w20: .word 0x59f
w21: .word 0x5b4
w22: .word 0x5c2
w23: .word 0x5d7
w24: .word 0x6b0
w25: .word 0xa9
w26: .word 0x6cc
w27: .word 0xc5
w28: .word 0x6e8
w29: .word 0xe1
w30: .word 0x704
w31: .word 0xfd
w32: .word 0x720
w33: .word 0x19
w34: .word 0x73c
w35: .word 0x35
w36: .word 0x758
w37: .word 0x51
w38: .word 0x774
w39: .word 0x6d
w40: .word 0x790
w41: .word 0x89
w42: .word 0x7ac
w43: .word 0x7c1
w44: .word 0x7d6
w45: .word 0x7eb
w46: .word 0x110
w47: .word 0x125
w48: .word 0x13a
w49: .word 0x14f
w50: .word 0x164
w51: .word 0x179
w52: .word 0x18e
w53: .word 0x1a3
w54: .word 0x1b8
w55: .word 0x1cd
w56: .word 0x1e2
w57: .word 0x1f7
w58: .word 0x20c
w59: .word 0x221
w60: .word 0x236
w61: .word 0x24b
w62: .word 0x260
w63: .word 0x275
w64: .word 0x28a
w65: .word 0x29f
w66: .word 0x2b4
w67: .word 0x2c9
w68: .word 0x2de
w69: .word 0x2f3
w70: .word 0x308
w71: .word 0x31d
w72: .word 0x332
w73: .word 0x347
w74: .word 0x35c
w75: .word 0x371
w76: .word 0x386
w77: .word 0x39b
w78: .word 0x3b0
w79: .word 0x3c5
w80: .word 0x3da
w81: .word 0x3ef
w82: .word 0x404
w83: .word 0x419
w84: .word 0x42e
w85: .word 0x443
w86: .word 0x458
w87: .word 0x4cf
w88: .word w87
w89: .word 0x554
w90: .word w89
w91: .word 0x5bd
w92: .word 0x5d2
w93: .word 0x5e0
w94: .word 0x5f5
w95: .word 0x650
w96: .word 0x49
w97: .word 0x66c
w98: .word 0x65
w99: .word 0x688
w100: .word 0x69d
w101: .word 0x6b2
w102: .word 0x6c7
w103: .word 0x6dc
w104: .word 0x6f1
w105: .word 0x706
w106: .word 0x71b
w107: .word 0x730
w108: .word 0x745
w109: .word 0x753
w110: .word 0x75a
w111: .word 0x761
w112: .word 0x76f
w113: .word 0x776
w114: .word 0x784
w115: .word 0x78b
w116: .word 0x799
w117: .word 0x7a7
w118: .word 0x7b5
w119: .word 0x7bc
w120: .word 0x7ca
w121: .word 0x7d8
w122: .word 0x104
w123: .word 0x120
w124: .word 0x13c
w125: .word 0x14a
w126: .word 0x15f
w127: .word 0x174
w128: .word 0x182
w129: .word 0x189
w130: .word 0x19e
w131: .word 0x1a5
w132: .word 0x1b3
w133: .word 0x1ba
w134: .word 0x1c8
w135: .word 0x1cf
w136: .word 0x1dd
w137: .word 0x1eb
w138: .word 0x1f9
w139: .word 0x207
w140: .word 0x215
w141: .word 0x223
w142: .word 0x231
w143: .word 0x24d
w144: .word 0x269
w145: .word 0x285
w146: .word 0x29a
w147: .word 0x2af
w148: .word 0x2c4
w149: .word 0x2d2
w150: .word 0x2e0
w151: .word 0x2f5
w152: .word 0x311
w153: .word 0x32d
w154: .word 0x33b
w155: .word 0x350
w156: .word 0x365
w157: .word 0x37a
w158: .word 0x388
w159: .word 0x39d
w160: .word 0x3ab
w161: .word 0x3b2
w162: .word 0x3b9
w163: .word 0x3ce
w164: .word 0x3e3
w165: .word 0x3f8
w166: .word 0x406
w167: .word 0x414
    .word 0
TEST_HTIF
