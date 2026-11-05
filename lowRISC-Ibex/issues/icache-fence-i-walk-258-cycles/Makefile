# Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# Makefile -- the reproducer of this issue, on its own: the RISC-V toolchain and Spike are all it needs.
#
#   make            build repro.elf (and the probes) with the toolchain
#   make spike      run it on Spike: exit 0 is the program finding what it expects
#   make dasm       the disassembly, to read beside the traces
#
# What the RTL did, from the run this was captured from (run.json has the rest; a cycle count is the
# cycles between a retirement and the one before it, CYCLE in rtl.rvvi.txt):
#   orders 360..363 (addi t1, t1, -1: 2 cycles after the previous retirement): the end of the walk: the fence.i retired at cycle 547 (order 260); from it every iteration of the three-word loop fetched its words from the bus, 8 cycles each under a grant withheld one cycle per word, where the same loop ran cached at 3 cycles before the fence.i (orders 254-257); the iteration at orders 360-362 is the first whose lookups hit again and allocate, and from order 363 (cycle 829) the loop is cached once more: 258 cycles of invalidation walk from the fence.i, against the cycle table's 1 - N
#
# The traces: rtl.rvvi.txt (the RTL, with CYCLE per retirement) and spike.rvvi.txt, RVVI-TEXT 0.5; the lines
# that matter are followed by a META line saying what was seen there.

CROSS    ?= riscv64-unknown-elf-
MARCH    ?= rv32i_zicsr_zifencei
MABI     ?= ilp32
SPIKE    ?= spike
SPIKE_ISA ?= rv32imc_zicsr_zifencei_zba_zbb_zbc_zbs_zbkb_zbkc_zbkx_zcmp_zcb_zicclsm_zicntr_zihpm_smepmp
PRIV     ?= mu
MEM      ?= 0x80000000:0x400000
BOOT     ?= 0x80000080

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
