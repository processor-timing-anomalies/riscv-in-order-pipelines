# A split access into I/O issues its legal first half, then faults a cycle later

- Title: mem-pma-split-first-half
- Class: function -- not a timing finding: a value, a fault or a sequence
- Core: cv32e40x
- Found while running: cv32e40x-pma

## Issue

on a configuration with PMA regions (cv32e40x-pma), a split (misaligned, word-crossing) load or store whose first transaction is in main memory and whose second falls into I/O issues the first transaction on the bus -- a read as well as a write -- and takes the precise access fault (code 5 / 7) one cycle after a fault whose first transaction is already into I/O; the RTL's RVFI reports that transaction as the trapped instruction's memory access, Spike (which logs no memory access of an instruction that trapped) none.

## What the documentation says

pma.rst 87-111 (Instructions with multiple memory operations): 'Misaligned store, 2: Exception taken, first store visible outside of the core', while the load rows say only 'Exception taken, no state updates' -- that the first load transaction is issued too, and that the fault costs the second transaction's cycle, is not said

## What the RTL does

hzp-pma-00 on cv32e40x-pma, 10 Oct 2026: blocks pma_load_split_hole and pma_store_split_hole (lw / sw at 0x803ffffe, the memory's last two bytes, the hole from 0x80400000): the harness log shows one request each (k6 read 0x803ffffe, k8 write 0x803ffffe of 0x11c, 2 bytes), the RTL trace carries that transaction as the instruction's memory record where Spike's carries none, and the RTL retires each of the two one cycle later (+2) than a fault on the first transaction costs (+1); the misaligned blocks wholly in the hole (lw / sw at 0x80400001) issue nothing and agree at +1

## From the RTL source (read, not measured)

`rtl/cv32e40x_load_store_unit.sv`, lines 400-453 (`split_q / lsu_split_0_o`): the first phase of a split access is issued before the second is checked; the MPU (cv32e40x_mpu.sv, pma_err) refuses the second transaction alone

---

© 2026 processor-timing-anomalies, Apache License 2.0
