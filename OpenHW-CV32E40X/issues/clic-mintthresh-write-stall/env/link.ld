/* Copyright 2026 processor-timing-anomalies.  SPDX-License-Identifier: Apache-2.0 */
/* link.ld -- RV32 bare-metal layout for the Spike / CV32E40X test program.
 *
 * BOOT_ADDR matches Spike's default DRAM base.  On real silicon the
 * CV32E40X takes its reset vector from the boot_addr_i pin, so this is a
 * configuration choice rather than a property of the core; the Makefile
 * exposes it as a variable. */

OUTPUT_ARCH("riscv")
ENTRY(_start)

SECTIONS
{
  . = DEFINED(BOOT_ADDR) ? BOOT_ADDR : 0x80000000;

  .text : { *(.text.init) *(.text .text.*) }
  .rodata : { *(.rodata .rodata.*) }
  .data : { *(.data .data.*) *(.sdata .sdata.*) }

  /* Spike finds the host interface by looking up these two ELF symbols. */
  .htif ALIGN(4096) : { *(.htif) }

  .bss ALIGN(4) : {
    _bss_start = .;
    *(.bss .bss.*) *(.sbss .sbss.*) *(COMMON)
    _bss_end = .;
  }

  . = ALIGN(16);
  . += 4096;
  _stack_top = .;
}
