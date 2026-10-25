# Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# Makefile -- the reproducer of this issue, on its own: the RISC-V toolchain and Spike are all it needs.
#
# This program uses a memory-mapped test device of ours: an upstream Spike or a plain RTL simulation will not
# run it as it is.  Contact us for a set-up that does.
#
#   make            build repro.elf (and the probes) with the toolchain
#   make spike      run it on Spike: exit 0 is the program finding what it expects
#   make dasm       the disassembly, to read beside the traces
#
# What the RTL did, from the run this was captured from (run.json has the rest; a cycle count is the
# cycles between a retirement and the one before it, CYCLE in rtl.rvvi.txt):
#   order 268 lui t1, 0x82: RTL 1 cycles; the documentation, read as written, gives 2
#   order 39 csrrw zero, jvt, s2: RTL 1 cycles; the documentation, read as written, gives 5
#   order 112 jal zero, 128: RTL 6 cycles; the documentation, read as written, gives 7
#   order 50 lui t1, 0xe: RTL 2 cycles; the documentation, read as written, gives 1
#   order 195 lui t2, 0x5b: RTL 1 cycles; the documentation, read as written, gives 2
#   order 112 jal zero, 128: RTL 6 cycles; the documentation, read as written, gives 7
#   order 148 jal zero, 128: RTL 7 cycles; the documentation, read as written, gives 8
#   order 184 jal zero, 128: RTL 8 cycles; the documentation, read as written, gives 5
#   order 220 jal zero, 128: RTL 9 cycles; the documentation, read as written, gives 5
#   order 435 csrrs zero, jvt, s4: RTL 1 cycles; the documentation, read as written, gives 5
#   order 833 csrrw zero, jvt, s6: RTL 1 cycles; the documentation, read as written, gives 5
#   order 834 jal zero, 128: RTL 6 cycles; the documentation, read as written, gives 7
#   order 844 lui t1, 0x1b2: RTL 2 cycles; the documentation, read as written, gives 1
#   order 921 lui t4, 0x1dd: RTL 1 cycles; the documentation, read as written, gives 2
#   order 872 jal zero, 128: RTL 7 cycles; the documentation, read as written, gives 8
#   order 910 jal zero, 128: RTL 8 cycles; the documentation, read as written, gives 5
#   order 948 jal zero, 128: RTL 9 cycles; the documentation, read as written, gives 5
#   order 1251 csrrs zero, jvt, s8: RTL 1 cycles; the documentation, read as written, gives 5
#
# The traces: rtl.rvvi.txt (the RTL, with CYCLE per retirement) and spike.rvvi.txt, RVVI-TEXT 0.5; the lines
# that matter are followed by a META line saying what was seen there.

CROSS    ?= riscv64-unknown-elf-
MARCH    ?= rv32i_zicsr
MABI     ?= ilp32
SPIKE    ?= spike
SPIKE_ISA ?= rv32imc_zicsr_zifencei_zba_zbb_zbs_zcb_zicclsm_zicntr_zihpm_zcmt
PRIV     ?= m
MEM      ?= 0x80000000:0x400000
BOOT     ?= 0x80000000

SRCS   := $(wildcard *.S)
ELFS   := $(SRCS:.S=.elf)
FLAGS   = -march=$(MARCH) -mabi=$(MABI) -mcmodel=medany -nostdlib -nostartfiles -ffreestanding -g -O0 -Ienv \
          -DTEST_DEVICE_BASE=0x02010000 \
          -Wl,--defsym,BOOT_ADDR=$(BOOT) -Wl,--no-warn-rwx-segments -T env/link.ld

.PHONY: all spike dasm clean

all: $(ELFS)

%.elf: %.S env/test.h env/link.ld
	$(CROSS)gcc $(FLAGS) -o $@ $<

spike: $(ELFS) ## each program on Spike; exit 0 = PASS
	@for e in $(ELFS); do $(SPIKE) --isa=$(SPIKE_ISA) --priv=$(PRIV) -m$(MEM) --pc=$(BOOT) $$e && echo "$$e: PASS" || { echo "$$e: FAIL (exit $$?)"; exit 1; }; done

dasm: $(ELFS)
	@for e in $(ELFS); do $(CROSS)objdump -d -S $$e > $${e%.elf}.dasm; echo "$${e%.elf}.dasm"; done

clean:
	rm -f *.elf *.dasm
