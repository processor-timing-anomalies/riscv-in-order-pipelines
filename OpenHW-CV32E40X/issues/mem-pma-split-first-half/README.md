# A misaligned load refused on its second half has already read its first

- Title: mem-pma-split-first-half
- Class: function -- not a timing finding: a value, a fault or a sequence
- Core: cv32e40x
- Found while running: cv32e40x-pma

## Issue

on a configuration with PMA regions, a misaligned load whose first half is in main memory and whose second falls into I/O issues the first read on the bus before the PMA refuses the second, and takes the access fault (code 5) with the second operation, one cycle after a fault on the first; the store row says the same of a store (first store visible), the load row says only 'no state updates'.

## What the documentation says

pma.rst 92-94 and the table row 'Misaligned load | 2 | Exception taken, no state updates.' (105-107), with load_store_unit.rst 64 (the lowest address first): the bus read of the first half follows by combining them but is not said, as it is for the store (111); one sentence on the load row would say it

## What the RTL does

hzp-pma-00 on cv32e40x-pma, 10 Oct 2026: blocks pma_load_split_hole and pma_store_split_hole (lw / sw at 0x803ffffe, the memory's last two bytes, the hole from 0x80400000): the harness log shows one request each (k6 read 0x803ffffe, k8 write 0x803ffffe of 0x11c, 2 bytes), the RTL trace carries that transaction as the instruction's memory record where Spike's carries none, and the RTL retires each of the two one cycle later (+2) than a fault on the first transaction costs (+1); the misaligned blocks wholly in the hole (lw / sw at 0x80400001) issue nothing and agree at +1

## From the RTL source (read, not measured)

`rtl/cv32e40x_load_store_unit.sv`, lines 336-342, 479-492 (`split_q / lsu_split_0_o`): the first phase of a split access is issued before the second is checked (split_q at 336-342, lsu_split_0_o at 479-492); the per-phase check is cv32e40x_pma.sv 125-127 (a misaligned or modified access to I/O raises pma_err_o); the MPU (cv32e40x_mpu.sv, pma_err) refuses the second transaction alone

---

© 2026 processor-timing-anomalies, Apache License 2.0
