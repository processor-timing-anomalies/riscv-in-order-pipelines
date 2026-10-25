// Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# repro.S -- the whole test hze-jvt-00, kept as it ran (no cut-down reproducer: the window at order 39: the window accesses the test device: its line and the handler decide the cycles; the window at order 112: the window holds an interrupt entry: the device and the handler decide its cycles; the window at order 50: the window holds a trap or a system instruction; the window at order 195: the window holds a trap or a system instruction; the window at order 148: the window holds an interrupt entry: the device and the handler decide its cycles; the window at order 184: the window holds an interrupt entry: the device and the handler decide its cycles; the window at order 220: the window holds an interrupt entry: the device and the handler decide its cycles; the window at order 435: the window accesses the test device: its line and the handler decide the cycles; the window at order 833: the window accesses the test device: its line and the handler decide the cycles; the window at order 834: the window holds an interrupt entry: the device and the handler decide its cycles; the window at order 844: the window holds a trap or a system instruction; the window at order 921: the window holds a trap or a system instruction; the window at order 872: the window holds an interrupt entry: the device and the handler decide its cycles; the window at order 910: the window holds an interrupt entry: the device and the handler decide its cycles; the window at order 948: the window holds an interrupt entry: the device and the handler decide its cycles; the window at order 1251: the window accesses the test device: its line and the handler decide the cycles).
# the window: orders 265..268 of the run, the last the instruction whose timing differs (RTL 1 cycles; the documentation, read as written, gives 2)
# the window: orders 36..39 of the run, the last the instruction whose timing differs (RTL 1 cycles; the documentation, read as written, gives 5)
# the window: orders 109..112 of the run, the last the instruction whose timing differs (RTL 6 cycles; the documentation, read as written, gives 7)
# the window: orders 47..50 of the run, the last the instruction whose timing differs (RTL 2 cycles; the documentation, read as written, gives 1)
# the window: orders 192..195 of the run, the last the instruction whose timing differs (RTL 1 cycles; the documentation, read as written, gives 2)
# the window: orders 109..112 of the run, the last the instruction whose timing differs (RTL 6 cycles; the documentation, read as written, gives 7)
# the window: orders 145..148 of the run, the last the instruction whose timing differs (RTL 7 cycles; the documentation, read as written, gives 8)
# the window: orders 181..184 of the run, the last the instruction whose timing differs (RTL 8 cycles; the documentation, read as written, gives 5)
# the window: orders 217..220 of the run, the last the instruction whose timing differs (RTL 9 cycles; the documentation, read as written, gives 5)
# the window: orders 432..435 of the run, the last the instruction whose timing differs (RTL 1 cycles; the documentation, read as written, gives 5)
# the window: orders 830..833 of the run, the last the instruction whose timing differs (RTL 1 cycles; the documentation, read as written, gives 5)
# the window: orders 831..834 of the run, the last the instruction whose timing differs (RTL 6 cycles; the documentation, read as written, gives 7)
# the window: orders 841..844 of the run, the last the instruction whose timing differs (RTL 2 cycles; the documentation, read as written, gives 1)
# the window: orders 918..921 of the run, the last the instruction whose timing differs (RTL 1 cycles; the documentation, read as written, gives 2)
# the window: orders 869..872 of the run, the last the instruction whose timing differs (RTL 7 cycles; the documentation, read as written, gives 8)
# the window: orders 907..910 of the run, the last the instruction whose timing differs (RTL 8 cycles; the documentation, read as written, gives 5)
# the window: orders 945..948 of the run, the last the instruction whose timing differs (RTL 9 cycles; the documentation, read as written, gives 5)
# the window: orders 1248..1251 of the run, the last the instruction whose timing differs (RTL 1 cycles; the documentation, read as written, gives 5)
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
    lui x17, 0x20
    addi x17, x17, 0
    lui x18, 0x11
    addi x18, x18, 0
    lui x7, 11
    lui x28, 12
    lui x29, 13
    sw x17, 0(x16)
    csrrw x0, 0x017, x18
    lui x6, 14
    lui x7, 15
    lui x28, 16
    lui x29, 17
    lui x6, 18
    lui x7, 19
    lui x28, 20
    lui x29, 21
    lui x6, 22
    lui x7, 23
    lui x28, 24
    lui x29, 25
    lui x6, 26
    lui x0, 2
    lui x7, 27
    lui x28, 28
    lui x29, 29
    lui x19, 0x20
    addi x19, x19, 0
    lui x20, 0x12
    addi x20, x20, 0
    lui x6, 30
    lui x7, 31
    lui x28, 32
    sw x19, 0(x16)
    csrrw x0, 0x017, x20
    lui x29, 33
    lui x6, 34
    lui x7, 35
    lui x28, 36
    lui x29, 37
    lui x6, 38
    lui x7, 39
    lui x28, 40
    lui x29, 41
    lui x6, 42
    lui x7, 43
    lui x28, 44
    lui x29, 45
    lui x0, 3
    lui x6, 46
    lui x7, 47
    lui x28, 48
    lui x21, 0x20
    addi x21, x21, 0
    lui x22, 0x13
    addi x22, x22, 0
    lui x29, 49
    lui x6, 50
    lui x7, 51
    sw x21, 0(x16)
    csrrw x0, 0x017, x22
    lui x28, 52
    lui x29, 53
    lui x6, 54
    lui x7, 55
    lui x28, 56
    lui x29, 57
    lui x6, 58
    lui x7, 59
    lui x28, 60
    lui x29, 61
    lui x6, 62
    lui x7, 63
    lui x28, 64
    lui x0, 4
    lui x29, 65
    lui x6, 66
    lui x7, 67
    lui x23, 0x20
    addi x23, x23, 0
    lui x24, 0x14
    addi x24, x24, 0
    lui x28, 68
    lui x29, 69
    lui x6, 70
    sw x23, 0(x16)
    csrrw x0, 0x017, x24
    lui x7, 71
    lui x28, 72
    lui x29, 73
    lui x6, 74
    lui x7, 75
    lui x28, 76
    lui x29, 77
    lui x6, 78
    lui x7, 79
    lui x28, 80
    lui x29, 81
    lui x6, 82
    lui x7, 83
    lui x0, 5
    lui x28, 84
    lui x29, 85
    lui x6, 86
    lui x25, 0x20
    addi x25, x25, 0
    lui x26, 0x15
    addi x26, x26, 0
    lui x7, 87
    lui x28, 88
    lui x29, 89
    sw x25, 0(x16)
    csrrw x0, 0x017, x26
    lui x6, 90
    lui x7, 91
    lui x28, 92
    lui x29, 93
    lui x6, 94
    lui x7, 95
    lui x28, 96
    lui x29, 97
    lui x6, 98
    lui x7, 99
    lui x28, 100
    lui x29, 101
    lui x6, 102
    lui x0, 6
    lui x7, 103
    lui x28, 104
    lui x29, 105
    lui x27, 0x20
    addi x27, x27, 0
    lui x3, 0x16
    addi x3, x3, 0
    lui x6, 106
    lui x7, 107
    lui x28, 108
    sw x27, 0(x16)
    csrrw x0, 0x017, x3
    lui x29, 109
    lui x6, 110
    lui x7, 111
    lui x28, 112
    lui x29, 113
    lui x6, 114
    lui x7, 115
    lui x28, 116
    lui x29, 117
    lui x6, 118
    lui x7, 119
    lui x28, 120
    lui x29, 121
    lui x0, 7
    lui x6, 122
    lui x7, 123
    lui x28, 124
    lui x8, 0x20
    addi x8, x8, 0
    lui x9, 0x17
    addi x9, x9, 0
    lui x29, 125
    lui x6, 126
    lui x7, 127
    sw x8, 0(x16)
    csrrw x0, 0x017, x9
    lui x28, 128
    lui x29, 129
    lui x6, 130
    lui x7, 131
    lui x28, 132
    lui x29, 133
    lui x6, 134
    lui x7, 135
    lui x28, 136
    lui x29, 137
    lui x6, 138
    lui x7, 139
    lui x28, 140
    lui x0, 8
    lui x29, 141
    lui x6, 142
    lui x7, 143
    lui x10, 0x20
    addi x10, x10, 0
    lui x11, 0x18
    addi x11, x11, 0
    lui x28, 144
    lui x29, 145
    lui x6, 146
    sw x10, 0(x16)
    csrrw x0, 0x017, x11
    lui x7, 147
    lui x28, 148
    lui x29, 149
    lui x6, 150
    lui x7, 151
    lui x28, 152
    lui x29, 153
    lui x6, 154
    lui x7, 155
    lui x28, 156
    lui x29, 157
    lui x6, 158
    lui x7, 159
    lui x0, 9
    lui x28, 160
    lui x29, 161
    lui x6, 162
    lui x12, 0x20
    addi x12, x12, 0
    lui x13, 0x19
    addi x13, x13, 0
    lui x7, 163
    lui x28, 164
    lui x29, 165
    sw x12, 0(x16)
    csrrw x0, 0x017, x13
    lui x6, 166
    lui x7, 167
    lui x28, 168
    lui x29, 169
    lui x6, 170
    lui x7, 171
    lui x28, 172
    lui x29, 173
    lui x6, 174
    lui x7, 175
    lui x28, 176
    lui x29, 177
    lui x6, 178
    lui x0, 10
    lui x7, 179
    lui x28, 180
    lui x29, 181
    lui x14, 0x20
    addi x14, x14, 0
    lui x15, 0x1a
    addi x15, x15, 0
    lui x6, 182
    lui x7, 183
    lui x28, 184
    sw x14, 0(x16)
    csrrw x0, 0x017, x15
    lui x29, 185
    lui x6, 186
    lui x7, 187
    lui x28, 188
    lui x29, 189
    lui x6, 190
    lui x7, 191
    lui x28, 192
    lui x29, 193
    lui x6, 194
    lui x7, 195
    lui x28, 196
    lui x29, 197
    lui x0, 11
    lui x6, 198
    lui x7, 199
    lui x28, 200
    lui x17, 0x20
    addi x17, x17, 0
    lui x18, 0x1b
    addi x18, x18, 0
    lui x29, 201
    lui x6, 202
    lui x7, 203
    sw x17, 0(x16)
    csrrw x0, 0x017, x18
    lui x28, 204
    lui x29, 205
    lui x6, 206
    lui x7, 207
    lui x28, 208
    lui x29, 209
    lui x6, 210
    lui x7, 211
    lui x28, 212
    lui x29, 213
    lui x6, 214
    lui x7, 215
    lui x28, 216
    lui x0, 12
    lui x29, 217
    lui x6, 218
    lui x7, 219
    lui x19, 0x20
    addi x19, x19, 0
    lui x20, 0x1c
    addi x20, x20, 0
    lui x28, 220
    lui x29, 221
    lui x6, 222
    sw x19, 0(x16)
    csrrs x0, 0x017, x20
    lui x7, 223
    lui x28, 224
    lui x29, 225
    lui x6, 226
    lui x7, 227
    lui x28, 228
    lui x29, 229
    lui x6, 230
    lui x7, 231
    lui x28, 232
    lui x29, 233
    lui x6, 234
    lui x7, 235
    lui x0, 13
    lui x28, 236
    lui x29, 237
    lui x6, 238
    lui x21, 0x20
    addi x21, x21, 0
    lui x22, 0x1d
    addi x22, x22, 0
    lui x7, 239
    lui x28, 240
    lui x29, 241
    sw x21, 0(x16)
    csrrs x0, 0x017, x22
    lui x6, 242
    lui x7, 243
    lui x28, 244
    lui x29, 245
    lui x6, 246
    lui x7, 247
    lui x28, 248
    lui x29, 249
    lui x6, 250
    lui x7, 251
    lui x28, 252
    lui x29, 253
    lui x6, 254
    lui x0, 14
    lui x7, 255
    lui x28, 256
    lui x29, 257
    lui x23, 0x20
    addi x23, x23, 0
    lui x24, 0x1e
    addi x24, x24, 0
    lui x6, 258
    lui x7, 259
    lui x28, 260
    sw x23, 0(x16)
    csrrs x0, 0x017, x24
    lui x29, 261
    lui x6, 262
    lui x7, 263
    lui x28, 264
    lui x29, 265
    lui x6, 266
    lui x7, 267
    lui x28, 268
    lui x29, 269
    lui x6, 270
    lui x7, 271
    lui x28, 272
    lui x29, 273
    lui x0, 15
    lui x6, 274
    lui x7, 275
    lui x28, 276
    lui x25, 0x20
    addi x25, x25, 0
    lui x26, 0x1f
    addi x26, x26, 0
    lui x29, 277
    lui x6, 278
    lui x7, 279
    sw x25, 0(x16)
    csrrs x0, 0x017, x26
    lui x28, 280
    lui x29, 281
    lui x6, 282
    lui x7, 283
    lui x28, 284
    lui x29, 285
    lui x6, 286
    lui x7, 287
    lui x28, 288
    lui x29, 289
    lui x6, 290
    lui x7, 291
    lui x28, 292
    lui x0, 16
    lui x29, 293
    lui x6, 294
    lui x7, 295
    lui x27, 0x20
    addi x27, x27, 0
    lui x3, 0x20
    addi x3, x3, 0
    lui x28, 296
    lui x29, 297
    lui x6, 298
    sw x27, 0(x16)
    csrrs x0, 0x017, x3
    lui x7, 299
    lui x28, 300
    lui x29, 301
    lui x6, 302
    lui x7, 303
    lui x28, 304
    lui x29, 305
    lui x6, 306
    lui x7, 307
    lui x28, 308
    lui x29, 309
    lui x6, 310
    lui x7, 311
    lui x0, 17
    lui x28, 312
    lui x29, 313
    lui x6, 314
    lui x8, 0x20
    addi x8, x8, 0
    lui x9, 0x21
    addi x9, x9, 0
    lui x7, 315
    lui x28, 316
    lui x29, 317
    sw x8, 0(x16)
    csrrs x0, 0x017, x9
    lui x6, 318
    lui x7, 319
    lui x28, 320
    lui x29, 321
    lui x6, 322
    lui x7, 323
    lui x28, 324
    lui x29, 325
    lui x6, 326
    lui x7, 327
    lui x28, 328
    lui x29, 329
    lui x6, 330
    lui x0, 18
    lui x7, 331
    lui x28, 332
    lui x29, 333
    lui x10, 0x20
    addi x10, x10, 0
    lui x11, 0x22
    addi x11, x11, 0
    lui x6, 334
    lui x7, 335
    lui x28, 336
    sw x10, 0(x16)
    csrrs x0, 0x017, x11
    lui x29, 337
    lui x6, 338
    lui x7, 339
    lui x28, 340
    lui x29, 341
    lui x6, 342
    lui x7, 343
    lui x28, 344
    lui x29, 345
    lui x6, 346
    lui x7, 347
    lui x28, 348
    lui x29, 349
    lui x0, 19
    lui x6, 350
    lui x7, 351
    lui x28, 352
    lui x12, 0x20
    addi x12, x12, 0
    lui x13, 0x23
    addi x13, x13, 0
    lui x29, 353
    lui x6, 354
    lui x7, 355
    sw x12, 0(x16)
    csrrs x0, 0x017, x13
    lui x28, 356
    lui x29, 357
    lui x6, 358
    lui x7, 359
    lui x28, 360
    lui x29, 361
    lui x6, 362
    lui x7, 363
    lui x28, 364
    lui x29, 365
    lui x6, 366
    lui x7, 367
    lui x28, 368
    lui x0, 20
    lui x29, 369
    lui x6, 370
    lui x7, 371
    lui x14, 0x20
    addi x14, x14, 0
    lui x15, 0x24
    addi x15, x15, 0
    lui x28, 372
    lui x29, 373
    lui x6, 374
    sw x14, 0(x16)
    csrrs x0, 0x017, x15
    lui x7, 375
    lui x28, 376
    lui x29, 377
    lui x6, 378
    lui x7, 379
    lui x28, 380
    lui x29, 381
    lui x6, 382
    lui x7, 383
    lui x28, 384
    lui x29, 385
    lui x6, 386
    lui x7, 387
    lui x0, 21
    lui x28, 388
    lui x29, 389
    lui x6, 390
    lui x17, 0x20
    addi x17, x17, 0
    lui x18, 0x25
    addi x18, x18, 0
    lui x7, 391
    lui x28, 392
    lui x29, 393
    sw x17, 0(x16)
    csrrs x0, 0x017, x18
    lui x6, 394
    lui x7, 395
    lui x28, 396
    lui x29, 397
    lui x6, 398
    lui x7, 399
    lui x28, 400
    lui x29, 401
    lui x6, 402
    lui x7, 403
    lui x28, 404
    lui x29, 405
    lui x6, 406
    lui x0, 22
    lui x7, 407
    lui x28, 408
    lui x29, 409
    lui x19, 0x20
    addi x19, x19, 0
    lui x20, 0x26
    addi x20, x20, 0
    lui x6, 410
    lui x7, 411
    lui x28, 412
    sw x19, 0(x16)
    csrrs x0, 0x017, x20
    lui x29, 413
    lui x6, 414
    lui x7, 415
    lui x28, 416
    lui x29, 417
    lui x6, 418
    lui x7, 419
    lui x28, 420
    lui x29, 421
    lui x6, 422
    lui x7, 423
    lui x28, 424
    lui x29, 425
    lui x0, 23
    lui x6, 426
    lui x7, 427
    lui x28, 428
    lui x21, 0x0
    addi x21, x21, 529
    lui x22, 0x27
    addi x22, x22, 0
    lui x29, 429
    lui x6, 430
    lui x7, 431
    sw x21, 16(x16)
    lui x28, 432
    lui x29, 433
    csrrw x0, 0x017, x22
    lui x6, 434
    lui x7, 435
    lui x28, 436
    lui x29, 437
    lui x6, 438
    lui x7, 439
    lui x28, 440
    lui x29, 441
    lui x6, 442
    lui x7, 443
    lui x28, 444
    lui x29, 445
    lui x6, 446
    lui x0, 24
    lui x7, 447
    lui x28, 448
    lui x29, 449
    lui x23, 0x0
    addi x23, x23, 529
    lui x24, 0x28
    addi x24, x24, 0
    lui x6, 450
    lui x7, 451
    lui x28, 452
    sw x23, 16(x16)
    lui x29, 453
    lui x6, 454
    csrrw x0, 0x017, x24
    lui x7, 455
    lui x28, 456
    lui x29, 457
    lui x6, 458
    lui x7, 459
    lui x28, 460
    lui x29, 461
    lui x6, 462
    lui x7, 463
    lui x28, 464
    lui x29, 465
    lui x6, 466
    lui x7, 467
    lui x0, 25
    lui x28, 468
    lui x29, 469
    lui x6, 470
    lui x25, 0x0
    addi x25, x25, 529
    lui x26, 0x29
    addi x26, x26, 0
    lui x7, 471
    lui x28, 472
    lui x29, 473
    sw x25, 16(x16)
    lui x6, 474
    lui x7, 475
    csrrw x0, 0x017, x26
    lui x28, 476
    lui x29, 477
    lui x6, 478
    lui x7, 479
    lui x28, 480
    lui x29, 481
    lui x6, 482
    lui x7, 483
    lui x28, 484
    lui x29, 485
    lui x6, 486
    lui x7, 487
    lui x28, 488
    lui x0, 26
    lui x29, 489
    lui x6, 490
    lui x7, 491
    lui x27, 0x0
    addi x27, x27, 529
    lui x3, 0x2a
    addi x3, x3, 0
    lui x28, 492
    lui x29, 493
    lui x6, 494
    sw x27, 16(x16)
    lui x7, 495
    lui x28, 496
    csrrw x0, 0x017, x3
    lui x29, 497
    lui x6, 498
    lui x7, 499
    lui x28, 500
    lui x29, 501
    lui x6, 502
    lui x7, 503
    lui x28, 504
    lui x29, 505
    lui x6, 506
    lui x7, 507
    lui x28, 508
    lui x29, 509
    lui x0, 27
    lui x6, 510
    lui x7, 511
    lui x28, 512
    lui x8, 0x0
    addi x8, x8, 529
    lui x9, 0x2b
    addi x9, x9, 0
    lui x29, 513
    lui x6, 514
    lui x7, 515
    sw x8, 16(x16)
    lui x28, 516
    lui x29, 517
    csrrw x0, 0x017, x9
    lui x6, 518
    lui x7, 519
    lui x28, 520
    lui x29, 521
    lui x6, 522
    lui x7, 523
    lui x28, 524
    lui x29, 525
    lui x6, 526
    lui x7, 527
    lui x28, 528
    lui x29, 529
    lui x6, 530
    lui x0, 28
    lui x7, 531
    lui x28, 532
    lui x29, 533
    lui x10, 0x0
    addi x10, x10, 529
    lui x11, 0x2c
    addi x11, x11, 0
    lui x6, 534
    lui x7, 535
    lui x28, 536
    sw x10, 16(x16)
    lui x29, 537
    lui x6, 538
    csrrw x0, 0x017, x11
    lui x7, 539
    lui x28, 540
    lui x29, 541
    lui x6, 542
    lui x7, 543
    lui x28, 544
    lui x29, 545
    lui x6, 546
    lui x7, 547
    lui x28, 548
    lui x29, 549
    lui x6, 550
    lui x7, 551
    lui x0, 29
    lui x28, 552
    lui x29, 553
    lui x6, 554
    lui x12, 0x0
    addi x12, x12, 529
    lui x13, 0x2d
    addi x13, x13, 0
    lui x7, 555
    lui x28, 556
    lui x29, 557
    sw x12, 16(x16)
    lui x6, 558
    lui x7, 559
    csrrw x0, 0x017, x13
    lui x28, 560
    lui x29, 561
    lui x6, 562
    lui x7, 563
    lui x28, 564
    lui x29, 565
    lui x6, 566
    lui x7, 567
    lui x28, 568
    lui x29, 569
    lui x6, 570
    lui x7, 571
    lui x28, 572
    lui x0, 30
    lui x29, 573
    lui x6, 574
    lui x7, 575
    lui x14, 0x0
    addi x14, x14, 529
    lui x15, 0x2e
    addi x15, x15, 0
    lui x28, 576
    lui x29, 577
    lui x6, 578
    sw x14, 16(x16)
    lui x7, 579
    lui x28, 580
    csrrw x0, 0x017, x15
    lui x29, 581
    lui x6, 582
    lui x7, 583
    lui x28, 584
    lui x29, 585
    lui x6, 586
    lui x7, 587
    lui x28, 588
    lui x29, 589
    lui x6, 590
    lui x7, 591
    lui x28, 592
    lui x29, 593
    lui x0, 31
    lui x6, 594
    lui x7, 595
    lui x28, 596
    lui x17, 0x0
    addi x17, x17, 529
    lui x18, 0x2f
    addi x18, x18, 0
    lui x29, 597
    lui x6, 598
    lui x7, 599
    sw x17, 16(x16)
    lui x28, 600
    lui x29, 601
    csrrw x0, 0x017, x18
    lui x6, 602
    lui x7, 603
    lui x28, 604
    lui x29, 605
    lui x6, 606
    lui x7, 607
    lui x28, 608
    lui x29, 609
    lui x6, 610
    lui x7, 611
    lui x28, 612
    lui x29, 613
    lui x6, 614
    lui x0, 32
    lui x7, 615
    lui x28, 616
    lui x29, 617
    lui x19, 0x0
    addi x19, x19, 529
    lui x20, 0x30
    addi x20, x20, 0
    lui x6, 618
    lui x7, 619
    lui x28, 620
    sw x19, 16(x16)
    lui x29, 621
    lui x6, 622
    csrrw x0, 0x017, x20
    lui x7, 623
    lui x28, 624
    lui x29, 625
    lui x6, 626
    lui x7, 627
    lui x28, 628
    lui x29, 629
    lui x6, 630
    lui x7, 631
    lui x28, 632
    lui x29, 633
    lui x6, 634
    lui x7, 635
    lui x0, 33
    lui x28, 636
    lui x29, 637
    lui x6, 638
    lui x21, 0x0
    addi x21, x21, 529
    lui x22, 0x31
    addi x22, x22, 0
    lui x7, 639
    lui x28, 640
    lui x29, 641
    sw x21, 16(x16)
    lui x6, 642
    lui x7, 643
    csrrw x0, 0x017, x22
    lui x28, 644
    lui x29, 645
    lui x6, 646
    lui x7, 647
    lui x28, 648
    lui x29, 649
    lui x6, 650
    lui x7, 651
    lui x28, 652
    lui x29, 653
    lui x6, 654
    lui x7, 655
    lui x28, 656
    lui x0, 34
    lui x29, 657
    lui x6, 658
    lui x7, 659
    lui x23, 0x0
    addi x23, x23, 529
    lui x24, 0x32
    addi x24, x24, 0
    lui x28, 660
    lui x29, 661
    lui x6, 662
    sw x23, 16(x16)
    lui x7, 663
    lui x28, 664
    csrrs x0, 0x017, x24
    lui x29, 665
    lui x6, 666
    lui x7, 667
    lui x28, 668
    lui x29, 669
    lui x6, 670
    lui x7, 671
    lui x28, 672
    lui x29, 673
    lui x6, 674
    lui x7, 675
    lui x28, 676
    lui x29, 677
    lui x0, 35
    lui x6, 678
    lui x7, 679
    lui x28, 680
    lui x25, 0x0
    addi x25, x25, 529
    lui x26, 0x33
    addi x26, x26, 0
    lui x29, 681
    lui x6, 682
    lui x7, 683
    sw x25, 16(x16)
    lui x28, 684
    lui x29, 685
    csrrs x0, 0x017, x26
    lui x6, 686
    lui x7, 687
    lui x28, 688
    lui x29, 689
    lui x6, 690
    lui x7, 691
    lui x28, 692
    lui x29, 693
    lui x6, 694
    lui x7, 695
    lui x28, 696
    lui x29, 697
    lui x6, 698
    lui x0, 36
    lui x7, 699
    lui x28, 700
    lui x29, 701
    lui x27, 0x0
    addi x27, x27, 529
    lui x3, 0x34
    addi x3, x3, 0
    lui x6, 702
    lui x7, 703
    lui x28, 704
    sw x27, 16(x16)
    lui x29, 705
    lui x6, 706
    csrrs x0, 0x017, x3
    lui x7, 707
    lui x28, 708
    lui x29, 709
    lui x6, 710
    lui x7, 711
    lui x28, 712
    lui x29, 713
    lui x6, 714
    lui x7, 715
    lui x28, 716
    lui x29, 717
    lui x6, 718
    lui x7, 719
    lui x0, 37
    lui x28, 720
    lui x29, 721
    lui x6, 722
    lui x8, 0x0
    addi x8, x8, 529
    lui x9, 0x35
    addi x9, x9, 0
    lui x7, 723
    lui x28, 724
    lui x29, 725
    sw x8, 16(x16)
    lui x6, 726
    lui x7, 727
    csrrs x0, 0x017, x9
    lui x28, 728
    lui x29, 729
    lui x6, 730
    lui x7, 731
    lui x28, 732
    lui x29, 733
    lui x6, 734
    lui x7, 735
    lui x28, 736
    lui x29, 737
    lui x6, 738
    lui x7, 739
    lui x28, 740
    lui x0, 38
    lui x29, 741
    lui x6, 742
    lui x7, 743
    lui x10, 0x0
    addi x10, x10, 529
    lui x11, 0x36
    addi x11, x11, 0
    lui x28, 744
    lui x29, 745
    lui x6, 746
    sw x10, 16(x16)
    lui x7, 747
    lui x28, 748
    csrrs x0, 0x017, x11
    lui x29, 749
    lui x6, 750
    lui x7, 751
    lui x28, 752
    lui x29, 753
    lui x6, 754
    lui x7, 755
    lui x28, 756
    lui x29, 757
    lui x6, 758
    lui x7, 759
    lui x28, 760
    lui x29, 761
    lui x0, 39
    lui x6, 762
    lui x7, 763
    lui x28, 764
    lui x12, 0x0
    addi x12, x12, 529
    lui x13, 0x37
    addi x13, x13, 0
    lui x29, 765
    lui x6, 766
    lui x7, 767
    sw x12, 16(x16)
    lui x28, 768
    lui x29, 769
    csrrs x0, 0x017, x13
    lui x6, 770
    lui x7, 771
    lui x28, 772
    lui x29, 773
    lui x6, 774
    lui x7, 775
    lui x28, 776
    lui x29, 777
    lui x6, 778
    lui x7, 779
    lui x28, 780
    lui x29, 781
    lui x6, 782
    lui x0, 40
    lui x7, 783
    lui x28, 784
    lui x29, 785
    lui x14, 0x0
    addi x14, x14, 529
    lui x15, 0x38
    addi x15, x15, 0
    lui x6, 786
    lui x7, 787
    lui x28, 788
    sw x14, 16(x16)
    lui x29, 789
    lui x6, 790
    csrrs x0, 0x017, x15
    lui x7, 791
    lui x28, 792
    lui x29, 793
    lui x6, 794
    lui x7, 795
    lui x28, 796
    lui x29, 797
    lui x6, 798
    lui x7, 799
    lui x28, 800
    lui x29, 801
    lui x6, 802
    lui x7, 803
    lui x0, 41
    lui x28, 804
    lui x29, 805
    lui x6, 806
    lui x17, 0x0
    addi x17, x17, 529
    lui x18, 0x39
    addi x18, x18, 0
    lui x7, 807
    lui x28, 808
    lui x29, 809
    sw x17, 16(x16)
    lui x6, 810
    lui x7, 811
    csrrs x0, 0x017, x18
    lui x28, 812
    lui x29, 813
    lui x6, 814
    lui x7, 815
    lui x28, 816
    lui x29, 817
    lui x6, 818
    lui x7, 819
    lui x28, 820
    lui x29, 821
    lui x6, 822
    lui x7, 823
    lui x28, 824
    lui x0, 42
    lui x29, 825
    lui x6, 826
    lui x7, 827
    lui x19, 0x0
    addi x19, x19, 529
    lui x20, 0x3a
    addi x20, x20, 0
    lui x28, 828
    lui x29, 829
    lui x6, 830
    sw x19, 16(x16)
    lui x7, 831
    lui x28, 832
    csrrs x0, 0x017, x20
    lui x29, 833
    lui x6, 834
    lui x7, 835
    lui x28, 836
    lui x29, 837
    lui x6, 838
    lui x7, 839
    lui x28, 840
    lui x29, 841
    lui x6, 842
    lui x7, 843
    lui x28, 844
    lui x29, 845
    lui x0, 43
    lui x6, 846
    lui x7, 847
    lui x28, 848
    lui x21, 0x0
    addi x21, x21, 529
    lui x22, 0x3b
    addi x22, x22, 0
    lui x29, 849
    lui x6, 850
    lui x7, 851
    sw x21, 16(x16)
    lui x28, 852
    lui x29, 853
    csrrs x0, 0x017, x22
    lui x6, 854
    lui x7, 855
    lui x28, 856
    lui x29, 857
    lui x6, 858
    lui x7, 859
    lui x28, 860
    lui x29, 861
    lui x6, 862
    lui x7, 863
    lui x28, 864
    lui x29, 865
    lui x6, 866
    lui x0, 44
    lui x7, 867
    lui x28, 868
    lui x29, 869
    lui x23, 0x0
    addi x23, x23, 529
    lui x24, 0x3c
    addi x24, x24, 0
    lui x6, 870
    lui x7, 871
    lui x28, 872
    sw x23, 16(x16)
    lui x29, 873
    lui x6, 874
    csrrs x0, 0x017, x24
    lui x7, 875
    lui x28, 876
    lui x29, 877
    lui x6, 878
    lui x7, 879
    lui x28, 880
    lui x29, 881
    lui x6, 882
    lui x7, 883
    lui x28, 884
    lui x29, 885
    lui x6, 886
    lui x7, 887
    lui x28, 888
    lui x29, 889
    lui x6, 890
TEST_END
TEST_TRAP_EVENTS
    .section .data
    .align 12
tdata:
    .word 0
TEST_HTIF
