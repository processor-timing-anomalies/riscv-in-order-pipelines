# A load's result is not forwarded before its response is on the wire

- Title: mem-late-data-forward
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: a consumer two or more behind a load waits until the data is on the wire, a jalr one cycle more, instead of the free forward the list gives
- Core: cv32e40x

## Issue

a load's result cannot be forwarded before its response is on the wire: a consumer that the Hazards list lets read the value at no cost (distance 2 and beyond) stalls until the data arrives, and a jalr, which needs the value a stage earlier, until the cycle after.

## What the documentation says

pipeline.rst Hazards (114-126): the load data hazard is charged to 'the instruction immediately following a load' only, and the cycle table assumes 'zero stall on the data-side memory interface' (30-31): nothing about a consumer of a load whose response is late

## What the RTL does

Misalign-lw-00 random:0-3 seed 7: beq tp, a3 (order 285) at distance 2 behind lw a3 (respond 2, data at 343) and distance 1 behind lw tp (respond 3, data at 345) retires at 348, one cycle later than the Hazards list's costs give; the generated compound tests hzc-interleave-00/01/03/04/05: a jalr at distance 2 behind a load with a late response retires one cycle later still than a load-use consumer would

## From the RTL source (read, not measured)

`rtl/cv32e40x_wb_stage.sv`, lines 150-157 (`lsu_valid_o / wb_ready_o`): the WB stage is valid for a load only when the LSU's response is valid (lsu_ready_i, 'The late (data_rvalid_i based) downstream wb_ready_i signal', ex_stage.sv 469-472): the register-file write and the forwarding path carry the data from that cycle

---

© 2026 processor-timing-anomalies, Apache License 2.0
