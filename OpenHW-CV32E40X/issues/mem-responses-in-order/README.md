# Responses return in order, at most one per cycle

- Title: mem-responses-in-order
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle on a response due with or before the previous one
- Core: cv32e40x

## Issue

responses are returned in order and at most one per cycle, so a response whose own delay would put it in the same cycle as, or before, the previous response waits for the cycle after it.

## What the documentation says

load_store_unit.rst 93-95: with several granted requests outstanding 'the memory requests will be kept in-order and one data_rvalid_i will be signaled for each of them, in the order they were issued'; the one-per-cycle spacing is the OBI protocol's (one response phase per cycle) and the harness's

## What the RTL does

Misalign-lw-00 random:0-3 seed 7: k33 granted 454 with respond 2 -> 456; k34 granted 455 with respond 1 -> due 456, answered 457; a cycle model that gave k34 its response at 456 was a cycle early on the following instruction until it spaced responses as the memory does

---

© 2026 processor-timing-anomalies, Apache License 2.0
