# A response frees its outstanding slot the cycle after it is on the wire

- Title: mem-response-frees-slot
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle before a third request may issue once two are outstanding: the slot frees the cycle after the response
- Core: cv32e40x

## Issue

a response frees its outstanding-transaction slot the cycle after it is on the wire, not in it: with two responses open, the next request issues in the cycle of the second-to-last response at the earliest.

## What the documentation says

load_store_unit.rst 74-75: 'can cause up to two outstanding transactions'; nothing about the cycle a completed transaction stops counting

## What the RTL does

Misalign-lw-00 random:0-3 seed 7: the split lw's halves k22 and k23 granted 359 and 360 with responses 362 and 363; the next load's request k24 appears at 363, the cycle of k23's response (k22's at 362 having freed its slot for 363), not at 362

## From the RTL source (read, not measured)

`rtl/cv32e40x_load_store_unit.sv`, lines 162-166, 516 (`cnt_q`): the outstanding counter counts up on a grant and down on a response (count_up / count_down, 'can happen at same time'); a request is generated only while cnt_q < DEPTH (2), and cnt_q is a register, so the response's decrement is seen the next cycle

---

© 2026 processor-timing-anomalies, Apache License 2.0
