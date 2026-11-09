# A jalr two behind a load waits a cycle, even at zero wait

- Title: mem-late-data-forward
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle on a jalr two behind the load that writes its rs1
- Core: cv32e40x
- Found while running: cv32e40x (the base build)

## Issue

a jalr whose rs1 is written by a load two instructions before it waits one cycle in ID while the load is in WB, at zero wait on the data bus as with a late response; the Hazards list charges a jalr after a load only when the load immediately precedes it.

## What the documentation says

pipeline.rst Hazards (114-126): '2 cycle penalty ... Jump register (jalr) data hazard (in case that a jalr depends on the result of an immediately preceding load instruction)' (125); nothing for a load two before the jalr

## What the RTL does

at zero wait on the data bus (the test jalr-two-behind-load.S on cv32e40x, 7 Nov 2026): lw x10, 0(x9) (order 8) retires at cycle 24, the independent addi at 25, jalr x0, 0(x10) at 27 and its target at 29; with a jal in the jalr's place (orders 16-19) 34, 35, 36 and 38: the jalr waits one cycle and its target retires one cycle later than the jal's.  controller_bypass.sv 227-231: a jalr is stalled while a load writing its rs1 is in WB, with no term on the response

## From the RTL source (read, not measured)

`rtl/cv32e40x_wb_stage.sv`, lines 157 (`lsu_valid_o / wb_ready_o`): wb_ready_o follows the LSU's response for a load (line 157) (lsu_ready_i, 'The late (data_rvalid_i based) downstream wb_ready_i signal', ex_stage.sv 469-472): the register-file write and the forwarding path carry the data from that cycle; the stalls are cv32e40x_controller_bypass.sv 217 (load_stall: the load-use hazard in WB during a wait state, !wb_ready_i) and 229 (the jalr path: a load in WB whose rd the jalr reads)

---

© 2026 processor-timing-anomalies, Apache License 2.0
