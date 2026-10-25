# The data bus accepts the next request only the cycle after the previous grant

- Title: mem-address-phase
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle between consecutive data requests: the next issues the cycle after the previous grant
- Core: cv32e40x

## Issue

the data bus accepts a new request no earlier than the cycle after the previous one was granted: the address phase holds the bus for a cycle, so the next load or store issues its request the cycle after the grant before it, whatever its response has done.

## What the documentation says

load_store_unit.rst 'Protocol' (lines 76-95): the memory may grant 'at any time', the response comes 'one or more cycles after', up to two transactions outstanding (74-75); nothing about when the next request may be presented

## What the RTL does

with the testbench memory holding grants by a per-request schedule, request k+1 appears on data_req_o in the cycle after request k's grant: Misalign-lw-00 random:0-3 seed 7, k27 requested 388 = k26 granted 387 + 1 while k26's response was still open (390); k24 requested 363 = k23 granted 360... no: k24 waited for the outstanding slot (see mem-response-frees-slot) and then issued 363, k22 and k23 (the two halves of a split) 359 and 360 = grant + 1

## From the RTL source (read, not measured)

`rtl/cv32e40x_load_store_unit.sv`, lines 194, 512-516 (`trans_valid_q`): 'trans_valid got clocked without trans_ready': the request stays presented until granted; the generation comment: 'Assumes that corresponding response is at least 1 cycle after request'

---

© 2026 processor-timing-anomalies, Apache License 2.0
