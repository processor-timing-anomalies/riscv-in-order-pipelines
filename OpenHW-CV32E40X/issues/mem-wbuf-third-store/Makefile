# Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# Makefile -- the reproducer of this issue, on its own: the RISC-V toolchain and Spike are all it needs.
#
#   make            build repro.elf (and the probes) with the toolchain
#   make spike      run it on Spike: exit 0 is the program finding what it expects
#   make dasm       the disassembly, to read beside the traces
#
# What the RTL did, from the run this was captured from (run.json has the rest; a cycle count is the
# cycles between a retirement and the one before it, CYCLE in rtl.rvvi.txt):
#   orders 24..27 (sb a4, 0(a3): 2 cycles after the previous retirement): three bufferable stores behind a 4-cycle mulh, under the bus schedule published beside the program (repro.sched.json): the first (request 1, its grant withheld one cycle) and the second (request 2, granted at once) retire 1 cycle each, the third, the sb (request 3, its grant withheld two cycles), 2 cycles where the write-buffer rule gives 1: the buffer's transfer still holds the last outstanding slot of the response filter; the lb behind it (request 4, its grant withheld three cycles) 6 cycles, the lb after it 1
#
# The traces: rtl.rvvi.txt (the RTL, with CYCLE per retirement) and spike.rvvi.txt, RVVI-TEXT 0.5; the lines
# that matter are followed by a META line saying what was seen there.

CROSS    ?= riscv64-unknown-elf-
MARCH    ?= rv32im
MABI     ?= ilp32
SPIKE    ?= spike
SPIKE_ISA ?= rv32imc_zicsr_zifencei_zba_zbb_zbs_zcb_zicclsm_zicntr_zihpm_zcmt
PRIV     ?= m
MEM      ?= 0x80000000:0x400000
BOOT     ?= 0x80000000

SRCS   := $(wildcard *.S)
ELFS   := $(SRCS:.S=.elf)
FLAGS   = -march=$(MARCH) -mabi=$(MABI) -mcmodel=medany -nostdlib -nostartfiles -ffreestanding -g -O0 -Ienv \
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
