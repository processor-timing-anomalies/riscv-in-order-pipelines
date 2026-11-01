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
#   order 31 addi t4, t4, 1: RTL 3 cycles; the documentation, read as written, gives 1
#   order 31 addi t4, t4, 1: RTL 3 cycles; the documentation, read as written, gives 1
#   order 32 addi t4, t4, 1: RTL 1 cycles; the documentation, read as written, gives 3
#   order 32 addi t4, t4, 1: RTL 1 cycles; the documentation, read as written, gives 3
#   order 32 addi t4, t4, 1: RTL 1 cycles; the documentation, read as written, gives 3
#   order 32 addi t4, t4, 1: RTL 1 cycles; the documentation, read as written, gives 3
#   order 32 addi t4, t4, 1: RTL 1 cycles; the documentation, read as written, gives 3
#   order 32 addi t4, t4, 1: RTL 1 cycles; the documentation, read as written, gives 3
#   order 32 addi t4, t4, 1: RTL 1 cycles; the documentation, read as written, gives 3
#
# The traces: rtl.rvvi.txt (the RTL, with CYCLE per retirement) and spike.rvvi.txt, RVVI-TEXT 0.5; the lines
# that matter are followed by a META line saying what was seen there.

CROSS    ?= riscv64-unknown-elf-
MARCH    ?= rv32i_zicsr
MABI     ?= ilp32
SPIKE    ?= spike
SPIKE_ISA ?= rv32imc_zicsr_zifencei_zicclsm_zicntr_zihpm
PRIV     ?= mu
MEM      ?= 0x80000000:0x400000
BOOT     ?= 0x80000080

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
