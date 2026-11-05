# Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0
# Makefile -- the reproducer of this issue, on its own: the RISC-V toolchain and Spike are all it needs.
#
#   make            build repro.elf (and the probes) with the toolchain
#   make spike      run it on Spike: exit 0 is the program finding what it expects
#   make dasm       the disassembly, to read beside the traces
#
# What the RTL did, from the run this was captured from (run.json has the rest; a cycle count is the
# cycles between a retirement and the one before it, CYCLE in rtl.rvvi.txt):
#   orders 13..14 (addi a6, zero, 7: 2 cycles after the previous retirement): the words after the divide drain the fill buffers filled during its 37 cycles: addi a6 (order 14) retires 2 cycles after addi a5 where the five words before it took 1 each; its lookup needed a buffer whose last word was taken in the cycle before, and the buffer frees a cycle after that (the done state is registered), so the lookup is granted a cycle later than a buffer freed at once would allow; a model of the cache with the buffer freed at once gives this word 1 cycle, the registered one 2 as the RTL
#
# The traces: rtl.rvvi.txt (the RTL, with CYCLE per retirement) and spike.rvvi.txt, RVVI-TEXT 0.5; the lines
# that matter are followed by a META line saying what was seen there.

CROSS    ?= riscv64-unknown-elf-
MARCH    ?= rv32im_zicsr
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
