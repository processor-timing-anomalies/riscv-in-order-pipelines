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
#   orders 26..27 (lui t4, 0x5: 5 cycles after the previous retirement): a write of jvt (order 26) retires in 1 cycle and the instruction behind it 5 cycles later: the write flushes and refetches what follows, the table's 4 (jvt); behind a write of mscratch (orders 32-33) the next instruction follows in 1; with the interrupt line 17 raised right before the write (orders 38-40) the handler's first instruction retires 6 cycles after the jvt write, against 5 after a write of mscratch (orders 55-57)
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
