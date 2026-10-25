# A fence behind a buffered store waits for the store's response, then runs its own cycles

- Title: mem-wbuf-fence-drain
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: a fence behind a store the write buffer took waits for the store's response, not its grant, before its own cycles
- Core: cv32e40x
- Found while running: cv32e40x-pma

## Issue

on a configuration with a bufferable region (cv32e40x-pma, PMA_NUM_REGIONS = 1), a fence, fence.tso or fence.i behind a store the write buffer absorbed waits in WB until that store's response is on the wire -- not its grant -- and only then begins its own sequence (2 cycles in WB for fence and fence.tso, 3 for fence.i, the zero-wait figures), so it leaves WB at rsp + 3 (fence) or rsp + 4 (fence.i) whatever the split between the withheld grant and the late response.

## What the documentation says

load_store_unit.rst 155-158: 'Transactions in the write buffer must be completed before the core is able to retire a fence / fence.i'; it does not say whether completed means granted or answered, nor that the fence's own cycles start after the completion rather than overlapping it

## What the RTL does

the scheduled hazard suite on cv32e40x-pma, 9 Oct 2026 (the first run of the configuration under a bus schedule): 9 intervals differ in 4 tests, every one a fence behind a bufferable store with a wait: hzs-occupancy-00 orders 13866 and 17000 (sb accept 3: fence RTL +5, the grant rule +2), hzs-shape-05-01 order 3055 (c.sb respond 4: fence.i +6 against +3), hzs-shape-06-01 order 2305 (c.sw respond 2: fence.i +4 against +3), hzs-shape-17-00 order 796 (sb accept 2: fence.tso +4 against +2); the extra equals rsp - req - 1 of the harness log in every case; with the hold ending the cycle after the response and the occupancy counted from there, all four at 0 differ, and the instruction after the fence (its jump target) retires when the sequence ends

## From the RTL source (read, not measured)

`rtl/cv32e40x_controller_fsm.sv`, lines 891-893 (`lsu_busy_i`): fence_req_q is set only once the LSU has no outstanding transfer (the RTL question fence_lsu_busy_wait, answered by this finding)

---

© 2026 processor-timing-anomalies, Apache License 2.0
