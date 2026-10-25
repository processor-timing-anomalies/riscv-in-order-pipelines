// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the whole test hz-Sm-mret-zicsr-00, kept as it ran (no cut-down reproducer: a confirmation capture, the window 53-54 marked by hand).
# the window: orders 53-54 of the run -- an mret one behind a csrrc of mscratch, a CSR it does not read, retires +2 (the manual's rows 126 and 118 say any CSR access; the second window, orders 110-112, is the same two behind at +1)
# MARCH: rv32i_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
# block 1  raw_csr_csr_r_d1  mret after csrrs  expect(isa): stall 1
    lui x0, 1  # marker: block 1
    lui x6, 2                         # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 3                         # quiet
    lui x28, 4                        # quiet
    lui x8, 0x2                       # mret: MPP = machine mode, so mret stays in M
    lui x29, 5                        # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x6, 6                         # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x7, 7                         # mret: MPP = machine mode, so mret stays in M (quiet)
    addi x8, x8, -2048                # mret: MPP = machine mode, so mret stays in M
    csrrs x0, mstatus, x8             # mret: MPP = machine mode, so mret stays in M
    .L2: auipc x8, %pcrel_hi(.L1)     # mret: mepc -> the label after it
    lui x28, 8                        # mret: mepc -> the label after it (quiet)
    lui x29, 9                        # mret: mepc -> the label after it (quiet)
    lui x6, 10                        # mret: mepc -> the label after it (quiet)
    addi x8, x8, %pcrel_lo(.L2)       # mret: mepc -> the label after it
    lui x7, 11                        # mret: mepc -> the label after it (quiet)
    lui x28, 12                       # mret: mepc -> the label after it (quiet)
    lui x29, 13                       # mret: mepc -> the label after it (quiet)
    csrrw x0, mepc, x8                # mret: mepc -> the label after it
    csrrs x3, mstatus, x0             # mstatus's own value, to write back
    lui x6, 14                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 15                        # quiet
    lui x28, 16                       # quiet
    csrrs x0, mstatus, x3             # csrrs: writes mstatus (the CSR the consumer reads)
    mret                              # subject mret: the trap-class reader of the CSR state, d1 (raw_csr_csr_r_d1)
.L1:
    lui x29, 17                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 18                        # quiet
    lui x7, 19                        # quiet
# block 2  raw_csr_csr_r_d1  mret after csrrc  expect(isa): stall 1
    lui x0, 2  # marker: block 2
    lui x28, 20                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 21                       # quiet
    lui x6, 22                        # quiet
    lui x10, 0x2                      # mret: MPP = machine mode, so mret stays in M
    lui x7, 23                        # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x28, 24                       # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x29, 25                       # mret: MPP = machine mode, so mret stays in M (quiet)
    addi x10, x10, -2048              # mret: MPP = machine mode, so mret stays in M
    csrrs x0, mstatus, x10            # mret: MPP = machine mode, so mret stays in M
    .L4: auipc x10, %pcrel_hi(.L3)    # mret: mepc -> the label after it
    lui x6, 26                        # mret: mepc -> the label after it (quiet)
    lui x7, 27                        # mret: mepc -> the label after it (quiet)
    lui x28, 28                       # mret: mepc -> the label after it (quiet)
    addi x10, x10, %pcrel_lo(.L4)     # mret: mepc -> the label after it
    lui x29, 29                       # mret: mepc -> the label after it (quiet)
    lui x6, 30                        # mret: mepc -> the label after it (quiet)
    lui x7, 31                        # mret: mepc -> the label after it (quiet)
    csrrw x0, mepc, x10               # mret: mepc -> the label after it
    addi x9, x0, 263                  # x9 = 263
    lui x28, 32                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 33                       # quiet
    lui x6, 34                        # quiet
    csrrc x0, mscratch, x9            # csrrc: writes mscratch (the CSR the consumer reads)
    mret                              # subject mret: the trap-class reader of the CSR state, d1 (raw_csr_csr_r_d1)
.L3:
    lui x7, 35                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 36                       # quiet
    lui x29, 37                       # quiet
# block 3  raw_csr_csr_r_d2  mret after csrrs  expect(isa): forward 0
    lui x0, 3  # marker: block 3
    lui x6, 38                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 39                        # quiet
    lui x28, 40                       # quiet
    lui x12, 0x2                      # mret: MPP = machine mode, so mret stays in M
    lui x29, 41                       # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x6, 42                        # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x7, 43                        # mret: MPP = machine mode, so mret stays in M (quiet)
    addi x12, x12, -2048              # mret: MPP = machine mode, so mret stays in M
    csrrs x0, mstatus, x12            # mret: MPP = machine mode, so mret stays in M
    .L6: auipc x12, %pcrel_hi(.L5)    # mret: mepc -> the label after it
    lui x28, 44                       # mret: mepc -> the label after it (quiet)
    lui x29, 45                       # mret: mepc -> the label after it (quiet)
    lui x6, 46                        # mret: mepc -> the label after it (quiet)
    addi x12, x12, %pcrel_lo(.L6)     # mret: mepc -> the label after it
    lui x7, 47                        # mret: mepc -> the label after it (quiet)
    lui x28, 48                       # mret: mepc -> the label after it (quiet)
    lui x29, 49                       # mret: mepc -> the label after it (quiet)
    csrrw x0, mepc, x12               # mret: mepc -> the label after it
    csrrs x11, mstatus, x0            # mstatus's own value, to write back
    lui x6, 50                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 51                        # quiet
    lui x28, 52                       # quiet
    csrrs x0, mstatus, x11            # csrrs: writes mstatus (the CSR the consumer reads)
    lui x29, 53                       # filler (gap)
    mret                              # subject mret: the trap-class reader of the CSR state, d2 (raw_csr_csr_r_d2)
.L5:
    lui x6, 54                        # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 55                        # quiet
    lui x28, 56                       # quiet
# block 4  raw_csr_csr_r_d2  mret after csrrc  expect(isa): forward 0
    lui x0, 4  # marker: block 4
    lui x29, 57                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 58                        # quiet
    lui x7, 59                        # quiet
    lui x14, 0x2                      # mret: MPP = machine mode, so mret stays in M
    lui x28, 60                       # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x29, 61                       # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x6, 62                        # mret: MPP = machine mode, so mret stays in M (quiet)
    addi x14, x14, -2048              # mret: MPP = machine mode, so mret stays in M
    csrrs x0, mstatus, x14            # mret: MPP = machine mode, so mret stays in M
    .L8: auipc x14, %pcrel_hi(.L7)    # mret: mepc -> the label after it
    lui x7, 63                        # mret: mepc -> the label after it (quiet)
    lui x28, 64                       # mret: mepc -> the label after it (quiet)
    lui x29, 65                       # mret: mepc -> the label after it (quiet)
    addi x14, x14, %pcrel_lo(.L8)     # mret: mepc -> the label after it
    lui x6, 66                        # mret: mepc -> the label after it (quiet)
    lui x7, 67                        # mret: mepc -> the label after it (quiet)
    lui x28, 68                       # mret: mepc -> the label after it (quiet)
    csrrw x0, mepc, x14               # mret: mepc -> the label after it
    addi x13, x0, 270                 # x13 = 270
    lui x29, 69                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 70                        # quiet
    lui x7, 71                        # quiet
    csrrc x0, mscratch, x13           # csrrc: writes mscratch (the CSR the consumer reads)
    lui x28, 72                       # filler (gap)
    mret                              # subject mret: the trap-class reader of the CSR state, d2 (raw_csr_csr_r_d2)
.L7:
    lui x29, 73                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 74                        # quiet
    lui x7, 75                        # quiet
# block 5  raw_csr_csr_r_d3  mret after csrrs  expect(isa): none 0
    lui x0, 5  # marker: block 5
    lui x28, 76                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 77                       # quiet
    lui x6, 78                        # quiet
    lui x16, 0x2                      # mret: MPP = machine mode, so mret stays in M
    lui x7, 79                        # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x28, 80                       # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x29, 81                       # mret: MPP = machine mode, so mret stays in M (quiet)
    addi x16, x16, -2048              # mret: MPP = machine mode, so mret stays in M
    csrrs x0, mstatus, x16            # mret: MPP = machine mode, so mret stays in M
    .L10: auipc x16, %pcrel_hi(.L9)   # mret: mepc -> the label after it
    lui x6, 82                        # mret: mepc -> the label after it (quiet)
    lui x7, 83                        # mret: mepc -> the label after it (quiet)
    lui x28, 84                       # mret: mepc -> the label after it (quiet)
    addi x16, x16, %pcrel_lo(.L10)    # mret: mepc -> the label after it
    lui x29, 85                       # mret: mepc -> the label after it (quiet)
    lui x6, 86                        # mret: mepc -> the label after it (quiet)
    lui x7, 87                        # mret: mepc -> the label after it (quiet)
    csrrw x0, mepc, x16               # mret: mepc -> the label after it
    csrrs x15, mstatus, x0            # mstatus's own value, to write back
    lui x28, 88                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 89                       # quiet
    lui x6, 90                        # quiet
    csrrs x0, mstatus, x15            # csrrs: writes mstatus (the CSR the consumer reads)
    lui x7, 91                        # filler (gap)
    lui x28, 92                       # filler (gap)
    mret                              # subject mret: the trap-class reader of the CSR state, d3 (raw_csr_csr_r_d3)
.L9:
    lui x29, 93                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 94                        # quiet
    lui x7, 95                        # quiet
# block 6  raw_csr_csr_r_d3  mret after csrrc  expect(isa): none 0
    lui x0, 6  # marker: block 6
    lui x28, 96                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 97                       # quiet
    lui x6, 98                        # quiet
    lui x18, 0x2                      # mret: MPP = machine mode, so mret stays in M
    lui x7, 99                        # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x28, 100                      # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x29, 101                      # mret: MPP = machine mode, so mret stays in M (quiet)
    addi x18, x18, -2048              # mret: MPP = machine mode, so mret stays in M
    csrrs x0, mstatus, x18            # mret: MPP = machine mode, so mret stays in M
    .L12: auipc x18, %pcrel_hi(.L11)  # mret: mepc -> the label after it
    lui x6, 102                       # mret: mepc -> the label after it (quiet)
    lui x7, 103                       # mret: mepc -> the label after it (quiet)
    lui x28, 104                      # mret: mepc -> the label after it (quiet)
    addi x18, x18, %pcrel_lo(.L12)    # mret: mepc -> the label after it
    lui x29, 105                      # mret: mepc -> the label after it (quiet)
    lui x6, 106                       # mret: mepc -> the label after it (quiet)
    lui x7, 107                       # mret: mepc -> the label after it (quiet)
    csrrw x0, mepc, x18               # mret: mepc -> the label after it
    addi x17, x0, 277                 # x17 = 277
    lui x28, 108                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 109                      # quiet
    lui x6, 110                       # quiet
    csrrc x0, mscratch, x17           # csrrc: writes mscratch (the CSR the consumer reads)
    lui x7, 111                       # filler (gap)
    lui x28, 112                      # filler (gap)
    mret                              # subject mret: the trap-class reader of the CSR state, d3 (raw_csr_csr_r_d3)
.L11:
    lui x29, 113                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 114                       # quiet
    lui x7, 115                       # quiet
# block 7  raw_csr_csr_i_d1  mret after csrrci  expect(isa): stall 1
    lui x0, 7  # marker: block 7
    lui x28, 116                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 117                      # quiet
    lui x6, 118                       # quiet
    lui x20, 0x2                      # mret: MPP = machine mode, so mret stays in M
    lui x7, 119                       # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x28, 120                      # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x29, 121                      # mret: MPP = machine mode, so mret stays in M (quiet)
    addi x20, x20, -2048              # mret: MPP = machine mode, so mret stays in M
    csrrs x0, mstatus, x20            # mret: MPP = machine mode, so mret stays in M
    .L14: auipc x20, %pcrel_hi(.L13)  # mret: mepc -> the label after it
    lui x6, 122                       # mret: mepc -> the label after it (quiet)
    lui x7, 123                       # mret: mepc -> the label after it (quiet)
    lui x28, 124                      # mret: mepc -> the label after it (quiet)
    addi x20, x20, %pcrel_lo(.L14)    # mret: mepc -> the label after it
    lui x29, 125                      # mret: mepc -> the label after it (quiet)
    lui x6, 126                       # mret: mepc -> the label after it (quiet)
    lui x7, 127                       # mret: mepc -> the label after it (quiet)
    csrrw x0, mepc, x20               # mret: mepc -> the label after it
    csrrs x19, mstatus, x0            # mstatus's own value, to write back
    lui x28, 128                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 129                      # quiet
    lui x6, 130                       # quiet
    csrrci x0, mstatus, 8             # csrrci: writes mstatus (the CSR the consumer reads) (csrrci of a clear bit: a write that changes nothing)
    mret                              # subject mret: the trap-class reader of the CSR state, d1 (raw_csr_csr_i_d1)
.L13:
    lui x7, 131                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 132                      # quiet
    lui x29, 133                      # quiet
# block 8  raw_csr_csr_i_d1  mret after csrrci  expect(isa): stall 1
    lui x0, 8  # marker: block 8
    lui x6, 134                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 135                       # quiet
    lui x28, 136                      # quiet
    lui x22, 0x2                      # mret: MPP = machine mode, so mret stays in M
    lui x29, 137                      # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x6, 138                       # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x7, 139                       # mret: MPP = machine mode, so mret stays in M (quiet)
    addi x22, x22, -2048              # mret: MPP = machine mode, so mret stays in M
    csrrs x0, mstatus, x22            # mret: MPP = machine mode, so mret stays in M
    .L16: auipc x22, %pcrel_hi(.L15)  # mret: mepc -> the label after it
    lui x28, 140                      # mret: mepc -> the label after it (quiet)
    lui x29, 141                      # mret: mepc -> the label after it (quiet)
    lui x6, 142                       # mret: mepc -> the label after it (quiet)
    addi x22, x22, %pcrel_lo(.L16)    # mret: mepc -> the label after it
    lui x7, 143                       # mret: mepc -> the label after it (quiet)
    lui x28, 144                      # mret: mepc -> the label after it (quiet)
    lui x29, 145                      # mret: mepc -> the label after it (quiet)
    csrrw x0, mepc, x22               # mret: mepc -> the label after it
    addi x21, x0, 284                 # x21 = 284
    lui x6, 146                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 147                       # quiet
    lui x28, 148                      # quiet
    csrrci x0, mscratch, 1            # csrrci: writes mscratch (the CSR the consumer reads)
    mret                              # subject mret: the trap-class reader of the CSR state, d1 (raw_csr_csr_i_d1)
.L15:
    lui x29, 149                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 150                       # quiet
    lui x7, 151                       # quiet
# block 9  raw_csr_csr_i_d2  mret after csrrci  expect(isa): forward 0
    lui x0, 9  # marker: block 9
    lui x28, 152                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 153                      # quiet
    lui x6, 154                       # quiet
    lui x24, 0x2                      # mret: MPP = machine mode, so mret stays in M
    lui x7, 155                       # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x28, 156                      # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x29, 157                      # mret: MPP = machine mode, so mret stays in M (quiet)
    addi x24, x24, -2048              # mret: MPP = machine mode, so mret stays in M
    csrrs x0, mstatus, x24            # mret: MPP = machine mode, so mret stays in M
    .L18: auipc x24, %pcrel_hi(.L17)  # mret: mepc -> the label after it
    lui x6, 158                       # mret: mepc -> the label after it (quiet)
    lui x7, 159                       # mret: mepc -> the label after it (quiet)
    lui x28, 160                      # mret: mepc -> the label after it (quiet)
    addi x24, x24, %pcrel_lo(.L18)    # mret: mepc -> the label after it
    lui x29, 161                      # mret: mepc -> the label after it (quiet)
    lui x6, 162                       # mret: mepc -> the label after it (quiet)
    lui x7, 163                       # mret: mepc -> the label after it (quiet)
    csrrw x0, mepc, x24               # mret: mepc -> the label after it
    csrrs x23, mstatus, x0            # mstatus's own value, to write back
    lui x28, 164                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 165                      # quiet
    lui x6, 166                       # quiet
    csrrci x0, mstatus, 8             # csrrci: writes mstatus (the CSR the consumer reads) (csrrci of a clear bit: a write that changes nothing)
    lui x7, 167                       # filler (gap)
    mret                              # subject mret: the trap-class reader of the CSR state, d2 (raw_csr_csr_i_d2)
.L17:
    lui x28, 168                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 169                      # quiet
    lui x6, 170                       # quiet
# block 10  raw_csr_csr_i_d2  mret after csrrci  expect(isa): forward 0
    lui x0, 10  # marker: block 10
    lui x7, 171                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 172                      # quiet
    lui x29, 173                      # quiet
    lui x26, 0x2                      # mret: MPP = machine mode, so mret stays in M
    lui x6, 174                       # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x7, 175                       # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x28, 176                      # mret: MPP = machine mode, so mret stays in M (quiet)
    addi x26, x26, -2048              # mret: MPP = machine mode, so mret stays in M
    csrrs x0, mstatus, x26            # mret: MPP = machine mode, so mret stays in M
    .L20: auipc x26, %pcrel_hi(.L19)  # mret: mepc -> the label after it
    lui x29, 177                      # mret: mepc -> the label after it (quiet)
    lui x6, 178                       # mret: mepc -> the label after it (quiet)
    lui x7, 179                       # mret: mepc -> the label after it (quiet)
    addi x26, x26, %pcrel_lo(.L20)    # mret: mepc -> the label after it
    lui x28, 180                      # mret: mepc -> the label after it (quiet)
    lui x29, 181                      # mret: mepc -> the label after it (quiet)
    lui x6, 182                       # mret: mepc -> the label after it (quiet)
    csrrw x0, mepc, x26               # mret: mepc -> the label after it
    addi x25, x0, 291                 # x25 = 291
    lui x7, 183                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 184                      # quiet
    lui x29, 185                      # quiet
    csrrci x0, mscratch, 1            # csrrci: writes mscratch (the CSR the consumer reads)
    lui x6, 186                       # filler (gap)
    mret                              # subject mret: the trap-class reader of the CSR state, d2 (raw_csr_csr_i_d2)
.L19:
    lui x7, 187                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 188                      # quiet
    lui x29, 189                      # quiet
# block 11  raw_csr_csr_i_d3  mret after csrrci  expect(isa): none 0
    lui x0, 11  # marker: block 11
    lui x6, 190                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 191                       # quiet
    lui x28, 192                      # quiet
    lui x3, 0x2                       # mret: MPP = machine mode, so mret stays in M
    lui x29, 193                      # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x6, 194                       # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x7, 195                       # mret: MPP = machine mode, so mret stays in M (quiet)
    addi x3, x3, -2048                # mret: MPP = machine mode, so mret stays in M
    csrrs x0, mstatus, x3             # mret: MPP = machine mode, so mret stays in M
    .L22: auipc x3, %pcrel_hi(.L21)   # mret: mepc -> the label after it
    lui x28, 196                      # mret: mepc -> the label after it (quiet)
    lui x29, 197                      # mret: mepc -> the label after it (quiet)
    lui x6, 198                       # mret: mepc -> the label after it (quiet)
    addi x3, x3, %pcrel_lo(.L22)      # mret: mepc -> the label after it
    lui x7, 199                       # mret: mepc -> the label after it (quiet)
    lui x28, 200                      # mret: mepc -> the label after it (quiet)
    lui x29, 201                      # mret: mepc -> the label after it (quiet)
    csrrw x0, mepc, x3                # mret: mepc -> the label after it
    csrrs x27, mstatus, x0            # mstatus's own value, to write back
    lui x6, 202                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 203                       # quiet
    lui x28, 204                      # quiet
    csrrci x0, mstatus, 8             # csrrci: writes mstatus (the CSR the consumer reads) (csrrci of a clear bit: a write that changes nothing)
    lui x29, 205                      # filler (gap)
    lui x6, 206                       # filler (gap)
    mret                              # subject mret: the trap-class reader of the CSR state, d3 (raw_csr_csr_i_d3)
.L21:
    lui x7, 207                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 208                      # quiet
    lui x29, 209                      # quiet
# block 12  raw_csr_csr_i_d3  mret after csrrci  expect(isa): none 0
    lui x0, 12  # marker: block 12
    lui x6, 210                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 211                       # quiet
    lui x28, 212                      # quiet
    lui x9, 0x2                       # mret: MPP = machine mode, so mret stays in M
    lui x29, 213                      # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x6, 214                       # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x7, 215                       # mret: MPP = machine mode, so mret stays in M (quiet)
    addi x9, x9, -2048                # mret: MPP = machine mode, so mret stays in M
    csrrs x0, mstatus, x9             # mret: MPP = machine mode, so mret stays in M
    .L24: auipc x9, %pcrel_hi(.L23)   # mret: mepc -> the label after it
    lui x28, 216                      # mret: mepc -> the label after it (quiet)
    lui x29, 217                      # mret: mepc -> the label after it (quiet)
    lui x6, 218                       # mret: mepc -> the label after it (quiet)
    addi x9, x9, %pcrel_lo(.L24)      # mret: mepc -> the label after it
    lui x7, 219                       # mret: mepc -> the label after it (quiet)
    lui x28, 220                      # mret: mepc -> the label after it (quiet)
    lui x29, 221                      # mret: mepc -> the label after it (quiet)
    csrrw x0, mepc, x9                # mret: mepc -> the label after it
    addi x8, x0, 298                  # x8 = 298
    lui x6, 222                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 223                       # quiet
    lui x28, 224                      # quiet
    csrrci x0, mscratch, 1            # csrrci: writes mscratch (the CSR the consumer reads)
    lui x29, 225                      # filler (gap)
    lui x6, 226                       # filler (gap)
    mret                              # subject mret: the trap-class reader of the CSR state, d3 (raw_csr_csr_i_d3)
.L23:
    lui x7, 227                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 228                      # quiet
    lui x29, 229                      # quiet
# block 19  ctrl_taken_branch_d1  mret after beq  expect(isa): bubble 3
    lui x0, 19  # marker: block 19
    lui x6, 230                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 231                       # quiet
    lui x28, 232                      # quiet
    addi x10, x0, 305                 # beq's operand
    addi x11, x0, 312                 # beq's operand
    addi x10, x0, 0                   # x10 = 0
    addi x11, x0, 0                   # x11 = 0
    lui x12, 0x2                      # mret: MPP = machine mode, so mret stays in M
    lui x29, 233                      # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x6, 234                       # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x7, 235                       # mret: MPP = machine mode, so mret stays in M (quiet)
    addi x12, x12, -2048              # mret: MPP = machine mode, so mret stays in M
    csrrs x0, mstatus, x12            # mret: MPP = machine mode, so mret stays in M
    .L26: auipc x12, %pcrel_hi(.L25)  # mret: mepc -> the label after it
    lui x28, 236                      # mret: mepc -> the label after it (quiet)
    lui x29, 237                      # mret: mepc -> the label after it (quiet)
    lui x6, 238                       # mret: mepc -> the label after it (quiet)
    addi x12, x12, %pcrel_lo(.L26)    # mret: mepc -> the label after it
    lui x7, 239                       # mret: mepc -> the label after it (quiet)
    lui x28, 240                      # mret: mepc -> the label after it (quiet)
    lui x29, 241                      # mret: mepc -> the label after it (quiet)
    csrrw x0, mepc, x12               # mret: mepc -> the label after it
    lui x6, 242                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 243                       # quiet
    lui x28, 244                      # quiet
    beq x10, x11, .L27                # beq: the taken transfer
.L27:
    mret                              # subject mret: d1 after the transfer (ctrl_taken_branch_d1)
.L25:
    lui x29, 245                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 246                       # quiet
    lui x7, 247                       # quiet
# block 20  ctrl_taken_branch_d2  mret after beq  expect(isa): bubble 0
    lui x0, 20  # marker: block 20
    lui x28, 248                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 249                      # quiet
    lui x6, 250                       # quiet
    addi x13, x0, 319                 # beq's operand
    addi x14, x0, 326                 # beq's operand
    addi x13, x0, 0                   # x13 = 0
    addi x14, x0, 0                   # x14 = 0
    lui x15, 0x2                      # mret: MPP = machine mode, so mret stays in M
    lui x7, 251                       # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x28, 252                      # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x29, 253                      # mret: MPP = machine mode, so mret stays in M (quiet)
    addi x15, x15, -2048              # mret: MPP = machine mode, so mret stays in M
    csrrs x0, mstatus, x15            # mret: MPP = machine mode, so mret stays in M
    .L29: auipc x15, %pcrel_hi(.L28)  # mret: mepc -> the label after it
    lui x6, 254                       # mret: mepc -> the label after it (quiet)
    lui x7, 255                       # mret: mepc -> the label after it (quiet)
    lui x28, 256                      # mret: mepc -> the label after it (quiet)
    addi x15, x15, %pcrel_lo(.L29)    # mret: mepc -> the label after it
    lui x29, 257                      # mret: mepc -> the label after it (quiet)
    lui x6, 258                       # mret: mepc -> the label after it (quiet)
    lui x7, 259                       # mret: mepc -> the label after it (quiet)
    csrrw x0, mepc, x15               # mret: mepc -> the label after it
    lui x28, 260                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 261                      # quiet
    lui x6, 262                       # quiet
    beq x13, x14, .L30                # beq: the taken transfer
.L30:
    lui x7, 263                       # filler (gap)
    mret                              # subject mret: d2 after the transfer (ctrl_taken_branch_d2)
.L28:
    lui x28, 264                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 265                      # quiet
    lui x6, 266                       # quiet
# block 21  ctrl_taken_branch_d3  mret after beq  expect(isa): bubble 0
    lui x0, 21  # marker: block 21
    lui x7, 267                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 268                      # quiet
    lui x29, 269                      # quiet
    addi x16, x0, 333                 # beq's operand
    addi x17, x0, 340                 # beq's operand
    addi x16, x0, 0                   # x16 = 0
    addi x17, x0, 0                   # x17 = 0
    lui x18, 0x2                      # mret: MPP = machine mode, so mret stays in M
    lui x6, 270                       # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x7, 271                       # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x28, 272                      # mret: MPP = machine mode, so mret stays in M (quiet)
    addi x18, x18, -2048              # mret: MPP = machine mode, so mret stays in M
    csrrs x0, mstatus, x18            # mret: MPP = machine mode, so mret stays in M
    .L32: auipc x18, %pcrel_hi(.L31)  # mret: mepc -> the label after it
    lui x29, 273                      # mret: mepc -> the label after it (quiet)
    lui x6, 274                       # mret: mepc -> the label after it (quiet)
    lui x7, 275                       # mret: mepc -> the label after it (quiet)
    addi x18, x18, %pcrel_lo(.L32)    # mret: mepc -> the label after it
    lui x28, 276                      # mret: mepc -> the label after it (quiet)
    lui x29, 277                      # mret: mepc -> the label after it (quiet)
    lui x6, 278                       # mret: mepc -> the label after it (quiet)
    csrrw x0, mepc, x18               # mret: mepc -> the label after it
    lui x7, 279                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 280                      # quiet
    lui x29, 281                      # quiet
    beq x16, x17, .L33                # beq: the taken transfer
.L33:
    lui x6, 282                       # filler (gap)
    lui x7, 283                       # filler (gap)
    mret                              # subject mret: d3 after the transfer (ctrl_taken_branch_d3)
.L31:
    lui x28, 284                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 285                      # quiet
    lui x6, 286                       # quiet
# block 22  ctrl_taken_jal_d1  mret after jal  expect(isa): bubble 3
    lui x0, 22  # marker: block 22
    lui x7, 287                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 288                      # quiet
    lui x29, 289                      # quiet
    addi x19, x0, 347                 # jal's rd before (stale)
    lui x20, 0x2                      # mret: MPP = machine mode, so mret stays in M
    lui x6, 290                       # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x7, 291                       # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x28, 292                      # mret: MPP = machine mode, so mret stays in M (quiet)
    addi x20, x20, -2048              # mret: MPP = machine mode, so mret stays in M
    csrrs x0, mstatus, x20            # mret: MPP = machine mode, so mret stays in M
    .L35: auipc x20, %pcrel_hi(.L34)  # mret: mepc -> the label after it
    lui x29, 293                      # mret: mepc -> the label after it (quiet)
    lui x6, 294                       # mret: mepc -> the label after it (quiet)
    lui x7, 295                       # mret: mepc -> the label after it (quiet)
    addi x20, x20, %pcrel_lo(.L35)    # mret: mepc -> the label after it
    lui x28, 296                      # mret: mepc -> the label after it (quiet)
    lui x29, 297                      # mret: mepc -> the label after it (quiet)
    lui x6, 298                       # mret: mepc -> the label after it (quiet)
    csrrw x0, mepc, x20               # mret: mepc -> the label after it
    lui x7, 299                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 300                      # quiet
    lui x29, 301                      # quiet
    jal x19, .L36                     # jal: the taken transfer
.L36:
    mret                              # subject mret: d1 after the transfer (ctrl_taken_jal_d1)
.L34:
    lui x6, 302                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 303                       # quiet
    lui x28, 304                      # quiet
# block 23  ctrl_taken_jal_d2  mret after jal  expect(isa): bubble 0
    lui x0, 23  # marker: block 23
    lui x29, 305                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 306                       # quiet
    lui x7, 307                       # quiet
    addi x21, x0, 354                 # jal's rd before (stale)
    lui x22, 0x2                      # mret: MPP = machine mode, so mret stays in M
    lui x28, 308                      # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x29, 309                      # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x6, 310                       # mret: MPP = machine mode, so mret stays in M (quiet)
    addi x22, x22, -2048              # mret: MPP = machine mode, so mret stays in M
    csrrs x0, mstatus, x22            # mret: MPP = machine mode, so mret stays in M
    .L38: auipc x22, %pcrel_hi(.L37)  # mret: mepc -> the label after it
    lui x7, 311                       # mret: mepc -> the label after it (quiet)
    lui x28, 312                      # mret: mepc -> the label after it (quiet)
    lui x29, 313                      # mret: mepc -> the label after it (quiet)
    addi x22, x22, %pcrel_lo(.L38)    # mret: mepc -> the label after it
    lui x6, 314                       # mret: mepc -> the label after it (quiet)
    lui x7, 315                       # mret: mepc -> the label after it (quiet)
    lui x28, 316                      # mret: mepc -> the label after it (quiet)
    csrrw x0, mepc, x22               # mret: mepc -> the label after it
    lui x29, 317                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 318                       # quiet
    lui x7, 319                       # quiet
    jal x21, .L39                     # jal: the taken transfer
.L39:
    lui x28, 320                      # filler (gap)
    mret                              # subject mret: d2 after the transfer (ctrl_taken_jal_d2)
.L37:
    lui x29, 321                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 322                       # quiet
    lui x7, 323                       # quiet
# block 24  ctrl_taken_jal_d3  mret after jal  expect(isa): bubble 0
    lui x0, 24  # marker: block 24
    lui x28, 324                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 325                      # quiet
    lui x6, 326                       # quiet
    addi x23, x0, 361                 # jal's rd before (stale)
    lui x24, 0x2                      # mret: MPP = machine mode, so mret stays in M
    lui x7, 327                       # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x28, 328                      # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x29, 329                      # mret: MPP = machine mode, so mret stays in M (quiet)
    addi x24, x24, -2048              # mret: MPP = machine mode, so mret stays in M
    csrrs x0, mstatus, x24            # mret: MPP = machine mode, so mret stays in M
    .L41: auipc x24, %pcrel_hi(.L40)  # mret: mepc -> the label after it
    lui x6, 330                       # mret: mepc -> the label after it (quiet)
    lui x7, 331                       # mret: mepc -> the label after it (quiet)
    lui x28, 332                      # mret: mepc -> the label after it (quiet)
    addi x24, x24, %pcrel_lo(.L41)    # mret: mepc -> the label after it
    lui x29, 333                      # mret: mepc -> the label after it (quiet)
    lui x6, 334                       # mret: mepc -> the label after it (quiet)
    lui x7, 335                       # mret: mepc -> the label after it (quiet)
    csrrw x0, mepc, x24               # mret: mepc -> the label after it
    lui x28, 336                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 337                      # quiet
    lui x6, 338                       # quiet
    jal x23, .L42                     # jal: the taken transfer
.L42:
    lui x7, 339                       # filler (gap)
    lui x28, 340                      # filler (gap)
    mret                              # subject mret: d3 after the transfer (ctrl_taken_jal_d3)
.L40:
    lui x29, 341                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 342                       # quiet
    lui x7, 343                       # quiet
# block 25  ctrl_taken_jalr_d1  mret after jalr  expect(isa): bubble 3
    lui x0, 25  # marker: block 25
    lui x28, 344                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 345                      # quiet
    lui x6, 346                       # quiet
    .L44: auipc x26, %pcrel_hi(.L43)  # jalr's target -> .L43, the label after it
    lui x7, 347                       # jalr's target -> .L43, the label after it (quiet)
    lui x28, 348                      # jalr's target -> .L43, the label after it (quiet)
    lui x29, 349                      # jalr's target -> .L43, the label after it (quiet)
    addi x26, x26, %pcrel_lo(.L44)    # jalr's target -> .L43, the label after it
    addi x25, x0, 368                 # jalr's rd before (stale)
    lui x27, 0x2                      # mret: MPP = machine mode, so mret stays in M
    lui x6, 350                       # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x7, 351                       # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x28, 352                      # mret: MPP = machine mode, so mret stays in M (quiet)
    addi x27, x27, -2048              # mret: MPP = machine mode, so mret stays in M
    csrrs x0, mstatus, x27            # mret: MPP = machine mode, so mret stays in M
    .L46: auipc x27, %pcrel_hi(.L45)  # mret: mepc -> the label after it
    lui x29, 353                      # mret: mepc -> the label after it (quiet)
    lui x6, 354                       # mret: mepc -> the label after it (quiet)
    lui x7, 355                       # mret: mepc -> the label after it (quiet)
    addi x27, x27, %pcrel_lo(.L46)    # mret: mepc -> the label after it
    lui x28, 356                      # mret: mepc -> the label after it (quiet)
    lui x29, 357                      # mret: mepc -> the label after it (quiet)
    lui x6, 358                       # mret: mepc -> the label after it (quiet)
    csrrw x0, mepc, x27               # mret: mepc -> the label after it
    lui x7, 359                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 360                      # quiet
    lui x29, 361                      # quiet
    jalr x25, 0(x26)                  # jalr: the taken transfer
.L43:
    mret                              # subject mret: d1 after the transfer (ctrl_taken_jalr_d1)
.L45:
    lui x6, 362                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 363                       # quiet
    lui x28, 364                      # quiet
# block 26  ctrl_taken_jalr_d2  mret after jalr  expect(isa): bubble 0
    lui x0, 26  # marker: block 26
    lui x29, 365                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x6, 366                       # quiet
    lui x7, 367                       # quiet
    .L48: auipc x8, %pcrel_hi(.L47)   # jalr's target -> .L47, the label after it
    lui x28, 368                      # jalr's target -> .L47, the label after it (quiet)
    lui x29, 369                      # jalr's target -> .L47, the label after it (quiet)
    lui x6, 370                       # jalr's target -> .L47, the label after it (quiet)
    addi x8, x8, %pcrel_lo(.L48)      # jalr's target -> .L47, the label after it
    addi x3, x0, 375                  # jalr's rd before (stale)
    lui x9, 0x2                       # mret: MPP = machine mode, so mret stays in M
    lui x7, 371                       # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x28, 372                      # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x29, 373                      # mret: MPP = machine mode, so mret stays in M (quiet)
    addi x9, x9, -2048                # mret: MPP = machine mode, so mret stays in M
    csrrs x0, mstatus, x9             # mret: MPP = machine mode, so mret stays in M
    .L50: auipc x9, %pcrel_hi(.L49)   # mret: mepc -> the label after it
    lui x6, 374                       # mret: mepc -> the label after it (quiet)
    lui x7, 375                       # mret: mepc -> the label after it (quiet)
    lui x28, 376                      # mret: mepc -> the label after it (quiet)
    addi x9, x9, %pcrel_lo(.L50)      # mret: mepc -> the label after it
    lui x29, 377                      # mret: mepc -> the label after it (quiet)
    lui x6, 378                       # mret: mepc -> the label after it (quiet)
    lui x7, 379                       # mret: mepc -> the label after it (quiet)
    csrrw x0, mepc, x9                # mret: mepc -> the label after it
    lui x28, 380                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 381                      # quiet
    lui x6, 382                       # quiet
    jalr x3, 0(x8)                    # jalr: the taken transfer
.L47:
    lui x7, 383                       # filler (gap)
    mret                              # subject mret: d2 after the transfer (ctrl_taken_jalr_d2)
.L49:
    lui x28, 384                      # quiet: DMAX+1 fillers, nothing older in flight
    lui x29, 385                      # quiet
    lui x6, 386                       # quiet
# block 27  ctrl_taken_jalr_d3  mret after jalr  expect(isa): bubble 0
    lui x0, 27  # marker: block 27
    lui x7, 387                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 388                      # quiet
    lui x29, 389                      # quiet
    .L52: auipc x11, %pcrel_hi(.L51)  # jalr's target -> .L51, the label after it
    lui x6, 390                       # jalr's target -> .L51, the label after it (quiet)
    lui x7, 391                       # jalr's target -> .L51, the label after it (quiet)
    lui x28, 392                      # jalr's target -> .L51, the label after it (quiet)
    addi x11, x11, %pcrel_lo(.L52)    # jalr's target -> .L51, the label after it
    addi x10, x0, 382                 # jalr's rd before (stale)
    lui x12, 0x2                      # mret: MPP = machine mode, so mret stays in M
    lui x29, 393                      # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x6, 394                       # mret: MPP = machine mode, so mret stays in M (quiet)
    lui x7, 395                       # mret: MPP = machine mode, so mret stays in M (quiet)
    addi x12, x12, -2048              # mret: MPP = machine mode, so mret stays in M
    csrrs x0, mstatus, x12            # mret: MPP = machine mode, so mret stays in M
    .L54: auipc x12, %pcrel_hi(.L53)  # mret: mepc -> the label after it
    lui x28, 396                      # mret: mepc -> the label after it (quiet)
    lui x29, 397                      # mret: mepc -> the label after it (quiet)
    lui x6, 398                       # mret: mepc -> the label after it (quiet)
    addi x12, x12, %pcrel_lo(.L54)    # mret: mepc -> the label after it
    lui x7, 399                       # mret: mepc -> the label after it (quiet)
    lui x28, 400                      # mret: mepc -> the label after it (quiet)
    lui x29, 401                      # mret: mepc -> the label after it (quiet)
    csrrw x0, mepc, x12               # mret: mepc -> the label after it
    lui x6, 402                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x7, 403                       # quiet
    lui x28, 404                      # quiet
    jalr x10, 0(x11)                  # jalr: the taken transfer
.L51:
    lui x29, 405                      # filler (gap)
    lui x6, 406                       # filler (gap)
    mret                              # subject mret: d3 after the transfer (ctrl_taken_jalr_d3)
.L53:
    lui x7, 407                       # quiet: DMAX+1 fillers, nothing older in flight
    lui x28, 408                      # quiet
    lui x29, 409                      # quiet
TEST_END
    .section .data
    .align 12
tdata:
    .word 0
TEST_HTIF
