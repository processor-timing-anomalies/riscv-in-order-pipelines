# A fence or fence.tso behind a buffered store waits for the store's response first

- Title: mem-wbuf-fence-drain
- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: a fence or fence.tso behind a store the write buffer took waits for the store's response before its own two cycles
- Core: cv32e40x
- Found while running: cv32e40x-pma

## Issue

on a configuration with a bufferable region, a fence or fence.tso behind a store the write buffer absorbed begins its own two cycles in WB only once that store's response is on the wire: the wait and the fence's cycles add, they do not overlap.

## What the documentation says

load_store_unit.rst 154-156 ('Transactions in the write buffer must be completed before the' the core 'is able to:', then 'Retire a ``fence`` instruction'), with 90-91 and 152 making completed mean answered; for fence.i, fencei.rst 8-11 says its handshake starts only once earlier stores have fully completed, the write buffer emptied, so fence.i's own sequence follows the completion; for fence and fence.tso nothing says their own cycles follow it.  One sentence would say it

## What the RTL does

the scheduled hazard suite on cv32e40x-pma, 9 Oct 2026 (the first run of the configuration under a bus schedule): 9 intervals differ in 4 tests, every one a fence behind a bufferable store with a wait: hzs-occupancy-00 orders 13866 and 17000 (sb accept 3: fence RTL +5, the grant rule +2), hzs-shape-05-01 order 3055 (c.sb respond 4: fence.i +6 against +3), hzs-shape-06-01 order 2305 (c.sw respond 2: fence.i +4 against +3), hzs-shape-17-00 order 796 (sb accept 2: fence.tso +4 against +2); the extra equals rsp - req - 1 of the harness log in every case; with the hold ending the cycle after the response and the occupancy counted from there, all four at 0 differ, and the instruction after the fence (its jump target) retires when the sequence ends

## From the RTL source (read, not measured)

`rtl/cv32e40x_controller_fsm.sv`, lines 891-893 (`lsu_busy_i`): fence_req_q is set only once the LSU has no outstanding transfer (the RTL question fence_lsu_busy_wait, answered by this finding)

---

© 2026 processor-timing-anomalies, Apache License 2.0
