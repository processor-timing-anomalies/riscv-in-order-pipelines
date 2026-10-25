// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the whole test hze-nmi-00, kept as it ran (no cut-down reproducer: a confirmation capture, the window 41-44 marked by hand).
# the window: orders 41-44 of the run -- the NMI's taking: the load at order 41 is answered with a bus error; orders 42 and 43 retire while the NMI is pending; order 44 is the handler's first retirement, mcause 0x80000400; the instructions in flight behind 43 are killed and run again after the handler's mret
# MARCH: rv32i_zicsr
# XLEN: 32
#include "test.h"
    .option norvc
TEST_BEGIN
TEST_TRAPS
    lui x16, %hi(TEST_DEVICE_BASE)
    addi x16, x16, %lo(TEST_DEVICE_BASE)
    lui x6, 2
    lui x7, 3
    lui x28, 4
    lw x6, 24(x16)
    addi x31, x0, 2
    lui x30, 0x10
    addi x30, x30, -1
    bne x6, x31, fail
    csrrs x6, mtvec, x0
    andi x6, x6, 3
    addi x31, x0, 3
    addi x30, x30, -1
    beq x6, x31, fail
    lui x6, 0x20
    addi x6, x6, 0
    csrrw x0, mie, x6
    csrrsi x0, mstatus, 8
    lui x29, 5
    lui x6, 6
    lui x7, 7
    lui x0, 1
    lui x28, 8
    lui x29, 9
    lui x6, 10
    addi x17, x0, 0
    .L1: auipc x19, %pcrel_hi(w0)
    lui x7, 11
    lui x28, 12
    lui x29, 13
    addi x19, x19, %pcrel_lo(.L1)
    addi x18, x0, 1041
    lui x6, 14
    lui x7, 15
    lui x28, 16
    sw x17, 8(x16)
    lw x18, 0(x19)
    lui x29, 17
    lui x6, 18
    lui x7, 19
    lui x28, 20
    lui x0, 2
    lui x29, 21
    lui x6, 22
    lui x7, 23
    addi x20, x0, 0
    .L2: auipc x22, %pcrel_hi(w1)
    lui x28, 24
    lui x29, 25
    lui x6, 26
    addi x22, x22, %pcrel_lo(.L2)
    addi x21, x0, 1055
    .L3: auipc x24, %pcrel_hi(w2)
    lui x7, 27
    lui x28, 28
    lui x29, 29
    addi x24, x24, %pcrel_lo(.L3)
    addi x23, x0, 1069
    lui x6, 30
    lui x7, 31
    lui x28, 32
    sw x20, 8(x16)
    lw x21, 0(x22)
    lw x23, 0(x24)
    lui x29, 33
    lui x6, 34
    lui x7, 35
    lui x28, 36
    lui x0, 3
    lui x29, 37
    lui x6, 38
    lui x7, 39
    addi x25, x0, 0
    .L4: auipc x27, %pcrel_hi(w3)
    lui x28, 40
    lui x29, 41
    lui x6, 42
    addi x27, x27, %pcrel_lo(.L4)
    addi x26, x0, 1083
    .L5: auipc x3, %pcrel_hi(w4)
    lui x7, 43
    lui x28, 44
    lui x29, 45
    addi x3, x3, %pcrel_lo(.L5)
    addi x8, x0, 1097
    lui x6, 46
    lui x7, 47
    lui x28, 48
    sw x25, 8(x16)
    lw x26, 0(x27)
    sw x8, 0(x3)
    lui x29, 49
    lui x6, 50
    lui x7, 51
    lui x28, 52
    lui x0, 4
    lui x29, 53
    lui x6, 54
    lui x7, 55
    addi x9, x0, 0
    lui x10, 0x20
    addi x10, x10, 0
    .L6: auipc x12, %pcrel_hi(w5)
    lui x28, 56
    lui x29, 57
    lui x6, 58
    addi x12, x12, %pcrel_lo(.L6)
    addi x11, x0, 1111
    lui x7, 59
    lui x28, 60
    lui x29, 61
    sw x10, 0(x16)
    sw x9, 8(x16)
    lw x11, 0(x12)
    lui x6, 62
    lui x7, 63
    lui x28, 64
    lui x29, 65
    lui x0, 5
    lui x6, 66
    lui x7, 67
    lui x28, 68
    addi x13, x0, 1
    .L7: auipc x14, %pcrel_hi(w6)
    lui x29, 69
    lui x6, 70
    lui x7, 71
    addi x14, x14, %pcrel_lo(.L7)
    addi x15, x0, 1125
    lui x28, 72
    lui x29, 73
    lui x6, 74
    sw x13, 8(x16)
    sw x15, 0(x14)
    lui x7, 75
    lui x28, 76
    lui x29, 77
    lui x6, 78
    lui x0, 6
    lui x7, 79
    lui x28, 80
    lui x29, 81
    addi x17, x0, 1
    .L8: auipc x18, %pcrel_hi(w7)
    lui x6, 82
    lui x7, 83
    lui x28, 84
    addi x18, x18, %pcrel_lo(.L8)
    addi x19, x0, 1139
    .L9: auipc x21, %pcrel_hi(w8)
    lui x29, 85
    lui x6, 86
    lui x7, 87
    addi x21, x21, %pcrel_lo(.L9)
    addi x20, x0, 1153
    lui x28, 88
    lui x29, 89
    lui x6, 90
    sw x17, 8(x16)
    sw x19, 0(x18)
    lw x20, 0(x21)
    lui x7, 91
    lui x28, 92
    lui x29, 93
    lui x6, 94
    lui x0, 7
    lui x7, 95
    lui x28, 96
    lui x29, 97
    addi x22, x0, 1
    .L10: auipc x23, %pcrel_hi(w9)
    lui x6, 98
    lui x7, 99
    lui x28, 100
    addi x23, x23, %pcrel_lo(.L10)
    addi x24, x0, 2
    .L11: auipc x25, %pcrel_hi(w10)
    lui x29, 101
    lui x6, 102
    lui x7, 103
    addi x25, x25, %pcrel_lo(.L11)
    addi x26, x0, 1174
    lui x28, 104
    lui x29, 105
    lui x6, 106
    sw x22, 8(x16)
    sw x24, 0(x23)
    sw x26, 0(x25)
    lui x7, 107
    lui x28, 108
    lui x29, 109
    lui x6, 110
    lui x0, 8
    lui x7, 111
    lui x28, 112
    lui x29, 113
    addi x27, x0, 1
    lui x3, 0x20
    addi x3, x3, 0
    .L12: auipc x8, %pcrel_hi(w11)
    lui x6, 114
    lui x7, 115
    lui x28, 116
    addi x8, x8, %pcrel_lo(.L12)
    addi x9, x0, 1188
    lui x29, 117
    lui x6, 118
    lui x7, 119
    sw x3, 0(x16)
    sw x27, 8(x16)
    sw x9, 0(x8)
    lui x28, 120
    lui x29, 121
    lui x6, 122
    lui x7, 123
    lui x28, 124
    lui x29, 125
    lui x6, 126
TEST_END
TEST_TRAP_EVENTS
    .section .data
    .align 12
tdata:
w0: .word 0x40a
w1: .word 0x418
w2: .word 0x426
w3: .word 0x434
w4: .word 0x442
w5: .word 0x450
w6: .word 0x45e
w7: .word 0x46c
w8: .word 0x47a
w9: .word 0x488
w10: .word 0x48f
w11: .word 0x49d
    .word 0
TEST_HTIF
