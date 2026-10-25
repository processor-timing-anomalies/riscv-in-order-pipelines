# A split access requests its second half from WB, the cycle after the first grant

- Title: mem-split-second-half
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: a misaligned access pays its second half's grant and response wait from WB, one cycle more than a single access
- Core: cv32e40x

## Issue

the second transaction of a misaligned (split) access is requested the cycle after the first was granted, while the instruction is already in WB: the split's extra cycle is spent there, and the second half's grant and response delays are paid from there.

## What the documentation says

pipeline.rst Load/Store row (48-52): 'For misaligned word transfers and for halfword transfers that cross a word boundary 2 bus transactions are performed using EX and WB stages for 2 cycles each'; load_store_unit.rst 56-64: the lower address first

## What the RTL does

Misalign-lw-00 random:0-3 seed 7: lw a3, 1(a1) (order 296) is k22 and k23: requested 359 and 360, granted 359 and 360, answered 362 and 363; the instruction retires at 364 = the second response + 1, and the next instruction's request waits for the slot (mem-response-frees-slot).  With accept on the second half (k40 of the every:4 run: granted 434, one cycle held) the instruction retires one later

## From the RTL source (read, not measured)

`rtl/cv32e40x_load_store_unit.sv`, lines 453, 400-410 (`lsu_split_0_o / split_q`): 'Output will be valid (valid_1_o) only for the last phase of split access'; rdata_q keeps the first half's data while the second is outstanding

---

© 2026 processor-timing-anomalies, Apache License 2.0
