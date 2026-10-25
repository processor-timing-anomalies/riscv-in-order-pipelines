# CV32E40X: the anomalies found

This document lists every timing anomaly we found on the CV32E40X: each place where the core's RTL, measured cycle by cycle, does not do what its documentation says, or does something the documentation does not mention.  An anomaly is found by running a program on the RTL and on our cycle-accurate timing reference simulator and comparing the cycle each instruction retires in with the cycle the documentation predicts; it is kept here once a developer has read the RTL source or the manual and confirmed it.  None of them is a functional bug: the programs compute the right results.  They are cycles the documentation does not account for.

Each anomaly has a **class** (the table below: how the hardware's trigger compares with the cause it exists for), a **cost** in cycles, **whom it concerns** (the RTL's developers, the core's performance, or the documentation), a **status**, and, when a small program reproduces it, an **issue directory** under `issues/` with that program, the two RVVI traces (the RTL's and the reference's) and the capture's facts.  The timing specification beside this document (`timing.md`) carries the same anomalies as rows of its section 9, in the context of the rules they break.

Generated from our record on 25 October 2026: 30 anomalies -- 2 in the RTL, 6 on performance, 22 in the documentation.

| class | meaning |
|---|---|
| intent | the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it |
| over-wide | the stall fires in cases that have no cause for it: an interlock wider than needed, a performance flaw |
| narrower | the cause is present and nothing stalls: a functional risk |
| unexplained | no cause has been named for the stall yet |
| function | not a timing finding: a value, a fault or a sequence |

**Contents**

- [All of them](#all-of-them): the table listing all the found anomalies
- [For the RTL's developers](#for-the-rtls-developers)
  - [rvfi-interrupt-entry-csrs-unreported](#rvfi-interrupt-entry-csrs-unreported-an-interrupt-entrys-csr-writes-mstatus-mepc-mcause-are-not-reported-on-rvfi): An interrupt entry's CSR writes (mstatus, mepc, mcause) are not reported on RVFI
  - [clic-minhv-after-restart](#clic-minhv-after-restart-mcauseminhv-stays-set-after-an-mret-restarts-a-faulted-clic-pointer-fetch-successfully): mcause.minhv stays set after an mret restarts a faulted CLIC pointer fetch successfully
- [Performance: a cycle paid without a cause](#performance-a-cycle-paid-without-a-cause)
  - [csr-mret-rows-class-based](#csr-mret-rows-class-based-an-mret-stalls-behind-any-csr-access-including-the-csrs-it-does-not-read): An mret stalls behind any CSR access, including the CSRs it does not read
  - [counter-access-stall](#counter-access-stall-any-csr-instruction-naming-a-counter-costs-one-cycle-more-while-an-instruction-is-in-wb): Any CSR instruction naming a counter costs one cycle more while an instruction is in WB
  - [mem-response-wait-freeze](#mem-response-wait-freeze-if-and-id-freeze-while-a-load-or-store-in-wb-waits-for-its-response): IF and ID freeze while a load or store in WB waits for its response
  - [mem-atomic-serial](#mem-atomic-serial-an-atomic-transaction-overlaps-no-other-a-cycle-lost-on-each-side-of-an-lr-sc-or-amo): An atomic transaction overlaps no other: a cycle lost on each side of an lr, sc or AMO
  - [tselect-access-stall](#tselect-access-stall-a-csr-instruction-behind-any-access-of-tselect-waits-a-cycle): a CSR instruction behind any access of tselect waits a cycle
  - [clic-csr-after-implicit-write-stall](#clic-csr-after-implicit-write-stall-clic-a-csr-instruction-one-behind-an-mscratchcswl-access-waits-a-cycle): CLIC: a CSR instruction one behind an mscratchcswl access waits a cycle
- [For the documentation](#for-the-documentation)
  - [csr-rows-unnamed](#csr-rows-unnamed-csr-rows-unnamed): csr-rows-unnamed
  - [fencei-six-cycles](#fencei-six-cycles-fencei-costs-6-cycles-not-the-cycle-tables-5): fence.i costs 6 cycles, not the cycle table's 5
  - [divisor-leading-ones](#divisor-leading-ones-division-by-a-negative-divisor-the-cycle-count-is-not-the-divisors-leading-zeros): Division by a negative divisor: the cycle count is not the divisor's leading zeros
  - [jump-behind-divider](#jump-behind-divider-a-jump-behind-a-busy-divider-resolves-at-once-its-bubble-hidden): A jump behind a busy divider resolves at once, its bubble hidden
  - [counter-read-stall](#counter-read-stall-a-counter-read-costs-one-cycle-more-while-an-instruction-is-in-wb): A counter read costs one cycle more while an instruction is in WB
  - [irq-enable-stall](#irq-enable-stall-a-load-or-store-behind-a-csr-write-of-mstatus-or-mie-costs-one-cycle-more): A load or store behind a CSR write of mstatus or mie costs one cycle more
  - [mhpmcounter3h-read-stall](#mhpmcounter3h-read-stall-a-read-of-mhpmcounter3h-costs-one-cycle-more-while-an-instruction-is-in-wb): A read of mhpmcounter3h costs one cycle more while an instruction is in WB
  - [mem-address-phase](#mem-address-phase-the-data-bus-accepts-the-next-request-only-the-cycle-after-the-previous-grant): The data bus accepts the next request only the cycle after the previous grant
  - [mem-response-frees-slot](#mem-response-frees-slot-a-response-frees-its-outstanding-slot-the-cycle-after-it-is-on-the-wire): A response frees its outstanding slot the cycle after it is on the wire
  - [mem-responses-in-order](#mem-responses-in-order-responses-return-in-order-at-most-one-per-cycle): Responses return in order, at most one per cycle
  - [mem-split-second-half](#mem-split-second-half-a-split-access-requests-its-second-half-from-wb-the-cycle-after-the-first-grant): A split access requests its second half from WB, the cycle after the first grant
  - [mem-late-data-forward](#mem-late-data-forward-a-loads-result-is-not-forwarded-before-its-response-is-on-the-wire): A load's result is not forwarded before its response is on the wire
  - [mem-wbuf-fence-drain](#mem-wbuf-fence-drain-a-fence-behind-a-buffered-store-waits-for-the-stores-response-then-runs-its-own-cycles): A fence behind a buffered store waits for the store's response, then runs its own cycles
  - [mem-pma-split-first-half](#mem-pma-split-first-half-a-split-access-into-io-issues-its-legal-first-half-then-faults-a-cycle-later): A split access into I/O issues its legal first half, then faults a cycle later
  - [mem-wbuf-third-store](#mem-wbuf-third-store-a-bufferable-store-whose-grant-is-withheld-third-behind-a-mulh-stalls-one-cycle): A bufferable store whose grant is withheld, third behind a mulh, stalls one cycle
  - [mem-atomic-misaligned-cause](#mem-atomic-misaligned-cause-a-misaligned-atomic-raises-an-access-fault-5-7-not-a-misaligned-one-4-6): A misaligned atomic raises an access fault (5, 7), not a misaligned one (4, 6)
  - [nmi-taken-kill](#nmi-taken-kill-a-bus-errors-nmi-is-taken-the-cycle-after-the-faulting-access-retires-every-stage-killed): A bus error's NMI is taken the cycle after the faulting access retires, every stage killed
  - [jvt-write-flush](#jvt-write-flush-jvt-write-the-tables-4-cycles-are-a-flush-of-the-next-instruction): jvt write: the table's 4 cycles are a flush of the next instruction
  - [clic-implicit-csr-read-stall](#clic-implicit-csr-read-stall-clic-an-access-of-mnxti-or-mscratchcswl-behind-any-csr-instruction-waits-a-cycle): CLIC: an access of mnxti or mscratchcswl behind any CSR instruction waits a cycle
  - [clic-mie-write-no-stall](#clic-mie-write-no-stall-clic-a-load-or-store-behind-a-write-of-mie-does-not-wait-unlike-the-clint-core): CLIC: a load or store behind a write of mie does not wait, unlike the CLINT core
  - [clic-mintthresh-write-stall](#clic-mintthresh-write-stall-clic-a-load-or-store-behind-a-write-of-mintthresh-waits-a-cycle): CLIC: a load or store behind a write of mintthresh waits a cycle
  - [clic-mcause-write-irq-enable-stall](#clic-mcause-write-irq-enable-stall-clic-a-load-or-store-one-behind-an-mcause-write-waits-a-cycle): CLIC: a load or store one behind an mcause write waits a cycle

## All of them

| anomaly | for | class | cost | found on | status | issue |
|---|---|---|---|---|---|---|
| An interrupt entry's CSR writes (mstatus, mepc, mcause) are not reported on RVFI | rtl | function | - | cv32e40x | open; to file | [issues/rvfi-interrupt-entry-csrs-unreported/](issues/rvfi-interrupt-entry-csrs-unreported/) |
| mcause.minhv stays set after an mret restarts a faulted CLIC pointer fetch successfully | rtl | function | - | cv32e40x-clic | open; to file | - |
| An mret stalls behind any CSR access, including the CSRs it does not read | performance | over-wide | two cycles on an mret one behind any CSR access and one cycle two behind, mscratch and the other CSRs mret does not read included | cv32e40x | clarified; to file | [issues/csr-mret-rows-class-based/](issues/csr-mret-rows-class-based/) |
| Any CSR instruction naming a counter costs one cycle more while an instruction is in WB | performance | over-wide | one cycle on every CSR instruction that names any counter, machine-level or user alias, implemented or not, reading it or not, while an instruction is in WB | cv32e40x | clarified; to file | [issues/counter-access-stall/](issues/counter-access-stall/) |
| IF and ID freeze while a load or store in WB waits for its response | performance | over-wide | every cycle a load or store in WB waits for its response stalls the whole front: nothing enters EX or ID, occupied or empty | cv32e40x | clarified; to file | [issues/mem-response-wait-freeze/](issues/mem-response-wait-freeze/) |
| An atomic transaction overlaps no other: a cycle lost on each side of an lr, sc or AMO | performance | over-wide | one cycle on every load, store, sc.w or AMO right behind an sc.w or an AMO, and on an atomic right behind a load or store | cv32e40x-pma-a | clarified; to file | [issues/mem-atomic-serial/](issues/mem-atomic-serial/) |
| a CSR instruction behind any access of tselect waits a cycle | performance | over-wide | one cycle on every CSR instruction one behind any access of tselect, a read included | cv32e40x | clarified; to file | [issues/tselect-access-stall/](issues/tselect-access-stall/) |
| CLIC: a CSR instruction one behind an mscratchcswl access waits a cycle | performance | over-wide | one cycle on every CSR instruction one behind an mscratchcswl access, in CLIC mode (an interrupt handler prologue does an mscratchcswl and then a CSR access as a matter of course) | cv32e40x-clic | clarified; to file | [issues/clic-csr-after-implicit-write-stall/](issues/clic-csr-after-implicit-write-stall/) |
| csr-rows-unnamed | document | intent | none observed: the rows name no instruction this core has; an ecall or mret behind a CSR write pays the flush alone | cv32e40x | clarified; to file | - |
| fence.i costs 6 cycles, not the cycle table's 5 | document | intent | one cycle on every fence.i beyond the cycle table's five | cv32e40x | clarified; to file | [issues/fencei-six-cycles/](issues/fencei-six-cycles/) |
| Division by a negative divisor: the cycle count is not the divisor's leading zeros | document | intent | none beyond the document's rule read right: a signed divide by a negative divisor costs 3 plus its leading ones less one | cv32e40x | clarified; to file | [issues/divisor-leading-ones/](issues/divisor-leading-ones/) |
| A jump behind a busy divider resolves at once, its bubble hidden | document | intent | a saving: a jump behind a busy divider pays no bubble of its own, one cycle fewer than the table | cv32e40x | clarified; to file | [issues/jump-behind-divider/](issues/jump-behind-divider/) |
| A counter read costs one cycle more while an instruction is in WB | document | intent | one cycle on every read of a counter while an instruction is in WB | cv32e40x | clarified; to file | [issues/counter-read-stall/](issues/counter-read-stall/) |
| A load or store behind a CSR write of mstatus or mie costs one cycle more | document | intent | one cycle on every load or store right behind a write of mstatus or mie, whatever value the write carries | cv32e40x | clarified; to file | [issues/irq-enable-stall/](issues/irq-enable-stall/) |
| A read of mhpmcounter3h costs one cycle more while an instruction is in WB | document | intent | one cycle on every read of mhpmcounter3h while an instruction is in WB | cv32e40x | clarified; to file | [issues/mhpmcounter3h-read-stall/](issues/mhpmcounter3h-read-stall/) |
| The data bus accepts the next request only the cycle after the previous grant | document | intent | one cycle between consecutive data requests: the next issues the cycle after the previous grant | cv32e40x | clarified; to file | [issues/mem-address-phase/](issues/mem-address-phase/) |
| A response frees its outstanding slot the cycle after it is on the wire | document | intent | one cycle before a third request may issue once two are outstanding: the slot frees the cycle after the response | cv32e40x | clarified; to file | [issues/mem-response-frees-slot/](issues/mem-response-frees-slot/) |
| Responses return in order, at most one per cycle | document | intent | one cycle on a response due with or before the previous one | cv32e40x | clarified; to file | [issues/mem-responses-in-order/](issues/mem-responses-in-order/) |
| A split access requests its second half from WB, the cycle after the first grant | document | intent | a misaligned access pays its second half's grant and response wait from WB, one cycle more than a single access | cv32e40x | clarified; to file | [issues/mem-split-second-half/](issues/mem-split-second-half/) |
| A load's result is not forwarded before its response is on the wire | document | intent | a consumer two or more behind a load waits until the data is on the wire, a jalr one cycle more, instead of the free forward the list gives | cv32e40x | clarified; to file | [issues/mem-late-data-forward/](issues/mem-late-data-forward/) |
| A fence behind a buffered store waits for the store's response, then runs its own cycles | document | intent | a fence behind a store the write buffer took waits for the store's response, not its grant, before its own cycles | cv32e40x-pma | clarified; to file | [issues/mem-wbuf-fence-drain/](issues/mem-wbuf-fence-drain/) |
| A split access into I/O issues its legal first half, then faults a cycle later | document | function | - | cv32e40x-pma | clarified; to file | [issues/mem-pma-split-first-half/](issues/mem-pma-split-first-half/) |
| A bufferable store whose grant is withheld, third behind a mulh, stalls one cycle | document | intent | one cycle on a bufferable store when the buffer's transfer holds the last outstanding slot | cv32e40x-pma | clarified; to file | [issues/mem-wbuf-third-store/](issues/mem-wbuf-third-store/) |
| A misaligned atomic raises an access fault (5, 7), not a misaligned one (4, 6) | document | function | - | cv32e40x-pma-a | clarified; to file | [issues/mem-atomic-misaligned-cause/](issues/mem-atomic-misaligned-cause/) |
| A bus error's NMI is taken the cycle after the faulting access retires, every stage killed | document | intent | the NMI handler's first retirement 5 cycles after the carrier's (the faulting load or store); the instruction behind the carrier retires before the handler only when its data request was outstanding when the error was seen, otherwise it is killed and runs again after the handler's mret | cv32e40x | clarified; to file | [issues/nmi-taken-kill/](issues/nmi-taken-kill/) |
| jvt write: the table's 4 cycles are a flush of the next instruction | document | intent | five cycles on the instruction after every write of jvt (the write itself retires in one), and the interrupt taking blocked for the cycle after the write's retirement | cv32e40x | clarified; to file | [issues/jvt-write-flush/](issues/jvt-write-flush/) |
| CLIC: an access of mnxti or mscratchcswl behind any CSR instruction waits a cycle | document | intent | one cycle on every access of mnxti or mscratchcswl one behind any CSR instruction, in CLIC mode | cv32e40x-clic | clarified; to file | [issues/clic-implicit-csr-read-stall/](issues/clic-implicit-csr-read-stall/) |
| CLIC: a load or store behind a write of mie does not wait, unlike the CLINT core | document | intent | none: a saving of the cycle the core pays in CLINT mode on a load or store one behind a write of mie | cv32e40x-clic | clarified; to file | [issues/clic-mie-write-no-stall/](issues/clic-mie-write-no-stall/) |
| CLIC: a load or store behind a write of mintthresh waits a cycle | document | intent | one cycle on every load or store one behind a write of mintthresh, in CLIC mode | cv32e40x-clic | clarified; to file | [issues/clic-mintthresh-write-stall/](issues/clic-mintthresh-write-stall/) |
| CLIC: a load or store one behind an mcause write waits a cycle | document | intent | one cycle on every load or store one behind an mcause write, in CLIC mode (an interrupt handler that rewrites mcause before saving state pays it) | cv32e40x-clic | clarified; to file | [issues/clic-mcause-write-irq-enable-stall/](issues/clic-mcause-write-irq-enable-stall/) |

## For the RTL's developers

### [rvfi-interrupt-entry-csrs-unreported](issues/rvfi-interrupt-entry-csrs-unreported/): An interrupt entry's CSR writes (mstatus, mepc, mcause) are not reported on RVFI

- Class: function -- not a timing finding: a value, a fault or a sequence
- Found on: cv32e40x
- Status: open; to file
- Issue directory: [issues/rvfi-interrupt-entry-csrs-unreported/](issues/rvfi-interrupt-entry-csrs-unreported/)

an interrupt's (or NMI's) entry writes mstatus, mepc and mcause in a cycle no instruction retires in, and cv32e40x_rvfi samples its CSR write masks with retirements only (rvfi_csr_wmask <= rvfi_csr_wmask_d on a WB retirement), so the trace reports no CSR write for the entry: the handler's first retirement carries rvfi_intr but an empty CSR mask, while an exception's writes are reported on the trapping instruction.  A reference ISS reports mcause, mepc and mstatus at the entry, so a wrong interrupt cause or mepc would be invisible to a consumer comparing CSR writes.

**What the documentation says.**  the RVFI specification (riscv-formal) has no interrupt entry of its own: rvfi_intr marks the first instruction of a handler; cv32e40x's rvfi_intr_t adds cause, interrupt and exception fields but no CSR writes for the entry

### clic-minhv-after-restart: mcause.minhv stays set after an mret restarts a faulted CLIC pointer fetch successfully

- Class: function -- not a timing finding: a value, a fault or a sequence
- Found on: cv32e40x-clic
- Status: open; to file
- Issue directory: -

in CLIC mode a vectored interrupt whose table entry fetch faults traps with mcause.minhv set and mepc the entry's address; an mret with minhv set fetches the pointer again (the restart) and, when that fetch succeeds, enters the handler with minhv still set: the handler reads mcause with bit 30 up, and its own mret restarts a pointer fetch from mepc instead of returning, unless software clears the bit.  The manual (control_status_registers.rst, mcause in CLIC mode) says minhv is "cleared by hardware at end of successful hardware vectoring".

**What the documentation says.**  control_status_registers.rst, Machine Cause (mcause) - CLIC == 1, bit 30: "MINHV. Set by hardware at start of hardware vectoring, cleared by hardware at end of successful hardware vectoring"; the taking of a vectored interrupt reads minhv 0 in the handler (the clearing at the start is not observable either)

**From the RTL source (read, not measured).**  `rtl/cv32e40x_controller_fsm.sv`, lines 743-744, 793-794, 856-857, 979-1000 (`ctrl_fsm_o.csr_cause.minhv`): minhv is written only with a trap's cause: 0 at an interrupt's or NMI's taking, clic_ptr_in_wb || mret_ptr_in_wb at an exception; the mret with minhv restarts the pointer fetch (pc_set_clicv) and nothing clears the bit when that fetch completes

## Performance: a cycle paid without a cause

### [csr-mret-rows-class-based](issues/csr-mret-rows-class-based/): An mret stalls behind any CSR access, including the CSRs it does not read

- Class: over-wide -- the stall fires in cases that have no cause for it: an interlock wider than needed, a performance flaw
- Cost: two cycles on an mret one behind any CSR access and one cycle two behind, mscratch and the other CSRs mret does not read included
- Found on: cv32e40x
- Status: clarified; to file
- Issue directory: [issues/csr-mret-rows-class-based/](issues/csr-mret-rows-class-based/)

the Hazards rows for mret (126: 2 cycles behind a CSR access in EX; 118: 1 cycle behind one in WB) are exact as worded, 'a CSR access instruction', any CSR: the RTL stalled an mret 2 cycles behind a csrrc of mscratch, which mret does not read.

### [counter-access-stall](issues/counter-access-stall/): Any CSR instruction naming a counter costs one cycle more while an instruction is in WB

- Class: over-wide -- the stall fires in cases that have no cause for it: an interlock wider than needed, a performance flaw
- Cost: one cycle on every CSR instruction that names any counter, machine-level or user alias, implemented or not, reading it or not, while an instruction is in WB
- Found on: cv32e40x
- Status: clarified; to file
- Issue directory: [issues/counter-access-stall/](issues/counter-access-stall/)

a CSR instruction that names a counter costs one more cycle than the cycle table's 1 when an instruction is in WB, whether or not it reads the counter, and for the event counters this configuration does not implement as well; the user-level aliases (cycle, instret, hpmcounter3-31 and their halves) stall the same way.

**What the documentation says.**  pipeline.rst, 'Cycle counts per instruction type': CSR Access 1 cycle for every CSR but jvt (lines 44-46); the Hazards list names no stall on an access of a counter (lines 114-126)

**What the RTL does.**  csrrw with rd = x0 -- a write that reads nothing -- of mcycle, mcycleh, minstret, minstreth, mhpmcounter3, mhpmcounter3h, mhpmcounter4, mhpmcounter4h, mhpmcounter31 or mhpmcounter31h retires 2 cycles after the instruction before it, behind an ALU instruction, a load, a store, a CSR instruction, a multiply or a divide (116 of 116).  csrrs reading mhpmcounter4, mhpmcounter31 or their high halves, which read 0 with NUM_MHPMCOUNTERS = 1, does the same (80 of 84; the four that retire after the cycles expected are behind a write of the same counter, where the read waits for that write already).  15 Oct 2026, two generated tests on cv32e40x reading every user-level counter with csrrs and with csrrc: every csrrs or csrrc of cycle, instret, hpmcounter3 to hpmcounter31 or their high halves behind an instruction in WB retires 2 cycles after it, 61 reads in each file, hpmcounter4 to 31 reading zero (not implemented) and stalling all the same

**From the RTL source (read, not measured).**  `rtl/cv32e40x_cs_registers.sv`, lines 302-304 (`csr_raddr`): the flag that holds a counter access in EX (csr_counter_read_o) is decoded from the address field of the CSR instruction alone, for mcycle, minstret, mhpmcounter3 to 31 and their high halves (lines 580-592, 632-644): it does not depend on the instruction reading, nor on NUM_MHPMCOUNTERS

### [mem-response-wait-freeze](issues/mem-response-wait-freeze/): IF and ID freeze while a load or store in WB waits for its response

- Class: over-wide -- the stall fires in cases that have no cause for it: an interlock wider than needed, a performance flaw
- Cost: every cycle a load or store in WB waits for its response stalls the whole front: nothing enters EX or ID, occupied or empty
- Found on: cv32e40x
- Status: clarified; to file
- Issue directory: [issues/mem-response-wait-freeze/](issues/mem-response-wait-freeze/)

from the cycle after a load or store enters WB until the cycle its response is on the wire, no instruction enters EX from ID and none enters ID from IF, occupied or empty: a jump target already fetched waits in IF, a jalr whose operand has just arrived waits in ID; at zero wait the window never opens.

**What the documentation says.**  pipeline.rst 30-31: the cycle table assumes zero stall on the data-side interface; the Hazards list (114-126) and the stage descriptions (12-26) say nothing about what the pipeline's other stages do while WB waits for a response

**What the RTL does.**  a generated store test under a bus answering every request two cycles after its grant: jal zero, 8 (order 161) behind sw gp, 8(ra) with a late response: the jal retires +1 as always, its target lui +2 instead of +1 (the target fetched in the jal's ID cycle sat in IF); under a schedule that delays every second response by one cycle, the single-hazard suite shows 377 intervals a cycle longer than the cycle table and the Hazards list give, in 61 tests, 217 of them the targets of taken jumps, all RTL +2 against the table's +1; all 377 are this rule.  hzc-interleave-00 random:0-3: jalr s4, 0(a6) (order 663) behind lw a6 and lb s2 with late responses retires two cycles after the lb, not one: the waveform shows id_ready and ex_ready low in the two cycles the lb waits in WB.  Waveforms from a tracing build read with a VCD script, 9 Oct 2026

**From the RTL source (read, not measured).**  `rtl/cv32e40x_ex_stage.sv`, lines 469-472 (`ex_ready_o`): 'The late (data_rvalid_i based) downstream wb_ready_i signal fans into the ready signals of all functional units': ex_ready_o includes lsu_ready_i; id_stage.sv 674: id_ready_o = ex_ready_i && !halt_id; wb_stage.sv 157: wb_ready_o includes lsu_ready_i -- the chain is low while the LSU in WB waits for data_rvalid_i

### [mem-atomic-serial](issues/mem-atomic-serial/): An atomic transaction overlaps no other: a cycle lost on each side of an lr, sc or AMO

- Class: over-wide -- the stall fires in cases that have no cause for it: an interlock wider than needed, a performance flaw
- Cost: one cycle on every load, store, sc.w or AMO right behind an sc.w or an AMO, and on an atomic right behind a load or store
- Found on: cv32e40x-pma-a
- Status: clarified; to file
- Issue directory: [issues/mem-atomic-serial/](issues/mem-atomic-serial/)

on cv32e40x-pma-a (A_EXT=A), every load, store, sc.w or AMO right behind an sc.w or an AMO retires a cycle later than the rows give (+2 for +1), and every atomic right behind a load or store likewise; an ALU instruction behind an atomic is not delayed, and an atomic's rd reaches its consumer as a load's does (no extra cycle).

**What the documentation says.**  load_store_unit.rst 164-170 (Atomic Operations): the core supports exclusive and atomic transactions with an external adapter, lr.w / sc.w / the AMOs as single-copy atomic word transactions; nothing on their timing against the transactions before and after them, and the cycle table has no atomic row

**What the RTL does.**  the single suite's A files on cv32e40x-pma-a, 12 Oct 2026, every disagreement a pair at distance 1: an lb / sb / sc.w / AMO right after an sc.w or an AMO retires +2 (the rows: +1), and an AMO right after an sb likewise (hz-Zaamo-amoadd.w-zaamo-00 order 8856: sb a5, 0(a4); amoadd.w a7, a6, (a4): +2); no disagreement at distance 2 or more, none for an ALU, branch or jump behind an atomic, none for a consumer of an atomic's rd (the load-use rule holds for it)

**From the RTL source (read, not measured).**  `rtl/cv32e40x_controller_bypass.sv`, lines 282-293 (`ctrl_byp_o.atomic_stall`): with A_EXT != A_NONE, EX is stalled while lsu_bus_busy_i (the response filter's bus-side count, a transfer accepted and not yet answered) in two cases: an atomic instruction in EX (1: it waits for every outstanding transaction), and any LSU instruction in EX while an atomic is in WB (2: it waits for the atomic's response); the stall is one of the bypass stalls that halt EX (controller_fsm.sv 666) -- on the zero-wait bus a response follows its grant by one cycle, so each case costs exactly one cycle

### [tselect-access-stall](issues/tselect-access-stall/): a CSR instruction behind any access of tselect waits a cycle

- Class: over-wide -- the stall fires in cases that have no cause for it: an interlock wider than needed, a performance flaw
- Cost: one cycle on every CSR instruction one behind any access of tselect, a read included
- Found on: cv32e40x
- Status: clarified; to file
- Issue directory: [issues/tselect-access-stall/](issues/tselect-access-stall/)

a CSR instruction one behind a read of tselect retires a cycle late: the core treats any access of tselect as an implicit CSR write still in the write stage and holds the next CSR instruction in EX for that cycle, though a read of tselect writes nothing; the cycle-count table gives a CSR access 1 cycle and the Hazards list names no instruction for its implicit-write row.

**What the documentation says.**  pipeline.rst, 'Cycle counts per instruction type': CSR Access 1 cycle for every CSR but jvt (line 44); the Hazards list, line 120: 'an instruction causing an explicit CSR read in EX while an instruction causing an implicit CSR write is in the WB stage' -- no instruction is named, and nothing says a read of tselect is one

**What the RTL does.**  csrrc rd, mscratch, rs1 and csrrci rd, mscratch, 7 each one behind csrrs rd, tselect, x0: 2 cycles where every other CSR instruction in that position takes 1 (own-cv32e40x-00 blocks 289 and 290, the only 2 of 5,011 intervals that differ)

**From the RTL source (read, not measured).**  `rtl/cv32e40x_controller_bypass.sv`, lines 256-267 (`csr_impl_write_in_wb`): csr_stall_ex's second term (line 263): a CSR instruction in EX waits while WB holds a CSR instruction flagged csr_impl_wr; cv32e40x_cs_registers.sv 484-487 sets the flag (impl_wr_ex) for any CSR instruction whose address is tselect when DBG_NUM_TRIGGERS > 0 (1 on this build, the RTL's default), whatever the instruction's form

### [clic-csr-after-implicit-write-stall](issues/clic-csr-after-implicit-write-stall/): CLIC: a CSR instruction one behind an mscratchcswl access waits a cycle

- Class: over-wide -- the stall fires in cases that have no cause for it: an interlock wider than needed, a performance flaw
- Cost: one cycle on every CSR instruction one behind an mscratchcswl access, in CLIC mode (an interrupt handler prologue does an mscratchcswl and then a CSR access as a matter of course)
- Found on: cv32e40x-clic
- Status: clarified; to file
- Issue directory: [issues/clic-csr-after-implicit-write-stall/](issues/clic-csr-after-implicit-write-stall/)

in CLIC mode a CSR instruction (read or write form, of any CSR: mintthresh, mscratch, mscratchcswl itself) one behind csrrw rd, mscratchcswl, rs1 retires a cycle late; the mscratchcswl access writes mscratch implicitly and the core holds every explicit CSR access in the execute stage while that implicit write is in the write stage, whether or not the access names a register the swap touches.

**What the documentation says.**  pipeline.rst, Hazards: the list names the implicit CSR read in EX behind a CSR access in WB (line 119, the known finding clic-implicit-csr-read-stall) and no stall of an explicit CSR access behind an implicit CSR write; the CLIC chapter of control_status_registers.rst describes mscratchcswl's swap of mscratch and says nothing of timing

**What the RTL does.**  csrrw s4, mscratchcswl, s3 then csrrw s5, mintthresh, s2: the second retires 2 cycles after the first (1 behind any other CSR write); the same for csrrw s5, mscratch, s2 and for csrrs s5, mintthresh, x0 (cross clic5 of 21 Oct 2026, files 002 and 003; under bus waits the same, clic6); two back it costs 1

**From the RTL source (read, not measured).**  `rtl/cv32e40x_controller_bypass.sv`, lines 259-266 (`csr_impl_write_in_wb (csr_stall_ex, rule 2)`): read 21 Oct 2026 (ours, not the RTL pass's): 'an explicit CSR read is in EX while any implicit write is in WB (conservative stall)' -- the stall is keyed on any implicit write in WB, not on the CSR the read names; mscratchcswl sets csr_impl_wr for the mscratch swap

## For the documentation

### csr-rows-unnamed: csr-rows-unnamed

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: none observed: the rows name no instruction this core has; an ecall or mret behind a CSR write pays the flush alone
- Found on: cv32e40x
- Status: clarified; to file
- Issue directory: -

the Hazards rows 'an instruction causing an implicit CSR read in EX' (119) and 'an instruction causing an implicit CSR write' (120) name no instruction; on the RTL an ecall or an mret 1 after a CSR write, and a CSR read of mstatus 1 after an mret, cost the flush alone, so neither is the row's instruction (a trap or an mret resolves before the next instruction reads).

**What the documentation says.**  pipeline.rst, Hazards: line 119, 'an instruction causing an implicit CSR read in EX while a CSR access instruction or an instruction causing an implicit CSR access is in the WB stage'; line 120, 'an instruction causing an explicit CSR read in EX while an instruction causing an implicit CSR write is in the WB stage'; the note at line 129 defines an implicit read as one 'performed by non-CSR instructions or CSR instructions reading CSR values from another CSR'.  No instruction is named for either row

**What the RTL does.**  an ecall or an mret one after a CSR write, and a CSR read of mstatus one after an mret, retire with the flush's cycles alone: neither pair overlaps in EX and WB, so neither is what the rows mean

**From the RTL source (read, not measured).**  `rtl/cv32e40x_controller_bypass.sv`, lines 256-267 (`csr_stall_ex`): line 119's reader is a CSR instruction that names mnxti or mscratchcswl (cv32e40x_cs_registers.sv:432, 469), both built only with CLIC = 1; line 120's implicit writers (lines 126-138) are an mret, the CLIC and mret pointers and a CSR instruction that writes another CSR, which without CLIC is an access of tselect.  The manual could name them; with CLIC = 0 the first row cannot occur

### [fencei-six-cycles](issues/fencei-six-cycles/): fence.i costs 6 cycles, not the cycle table's 5

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle on every fence.i beyond the cycle table's five
- Found on: cv32e40x
- Status: clarified; to file
- Issue directory: [issues/fencei-six-cycles/](issues/fencei-six-cycles/)

fence.i costs 6 cycles, not the 5 of the cycle table.

**What the documentation says.**  pipeline.rst, 'Cycle counts per instruction type': fence.i 5 (6 when the target is a non-word-aligned non-RVC instruction), 'implemented as a jump to the instruction following'; its description adds that it 'will not complete until the external handshake has been completed', and fencei.rst:8-11 describes that handshake as one cycle with fencei_flush_req_o high

**What the RTL does.**  a fence.i retires 3 cycles after the instruction before it and the instruction after it retires 4 cycles after the fence.i: 7 cycles from the one before to the one after, 6 beyond back-to-back, where the table's 5 gives 6 in all; measured on three fence.i's in straight-line code, with fencei_flush_ack_i tied high

### [divisor-leading-ones](issues/divisor-leading-ones/): Division by a negative divisor: the cycle count is not the divisor's leading zeros

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: none beyond the document's rule read right: a signed divide by a negative divisor costs 3 plus its leading ones less one
- Found on: cv32e40x
- Status: clarified; to file
- Issue directory: [issues/divisor-leading-ones/](issues/divisor-leading-ones/)

a signed division by a negative divisor does not take 'the number of leading bits at 0' of the divisor.

**What the documentation says.**  pipeline.rst, the div/rem row: 3 to 35 cycles, 'depends on the divider operand value (operand b), i.e. in the number of leading bits at 0'; read literally, a negative divisor has no leading zero and would cost 3

**What the RTL does.**  3 + (leading ones of the divisor - 1) cycles for a negative divisor of div or rem: -1 costs 34, -2 costs 33, 0x80000000 costs 3; 3 + leading zeros otherwise: 0 costs 35, 1 costs 34, 7 costs 32 (divu, remu and a non-negative divisor); measured on the seven divides of the reproducer

### [jump-behind-divider](issues/jump-behind-divider/): A jump behind a busy divider resolves at once, its bubble hidden

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: a saving: a jump behind a busy divider pays no bubble of its own, one cycle fewer than the table
- Found on: cv32e40x
- Status: clarified; to file
- Issue directory: [issues/jump-behind-divider/](issues/jump-behind-divider/)

a jump behind a busy divider resolves at once; its bubble is hidden by the wait.

**What the documentation says.**  pipeline.rst line 18, 'Jumps are taken from the ID stage', and line 21, 'Multi-cycle instructions will stall this stage [EX] until they are complete': nothing about a jump held in ID behind a divider

**What the RTL does.**  the jump redirects fetch in the first cycle it sits in ID, whether or not EX lets it advance; the instruction at its target is fetched while the divider still holds EX, so no bubble appears beyond the wait the divider already causes

### [counter-read-stall](issues/counter-read-stall/): A counter read costs one cycle more while an instruction is in WB

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle on every read of a counter while an instruction is in WB
- Found on: cv32e40x
- Status: clarified; to file
- Issue directory: [issues/counter-read-stall/](issues/counter-read-stall/)

a read of a counter (mcycle, minstret, their high halves, mhpmcounter3) costs one more cycle than the cycle table's 1, when an instruction is in WB.

**What the documentation says.**  pipeline.rst, 'Cycle counts per instruction type': CSR Access 1 cycle for every CSR but jvt (lines 44-46); the Hazards list (lines 114-126) names no stall on a read of a counter

**What the RTL does.**  csrrs of mcycle or minstret retires 2 cycles after the instruction before it, straight-line or 2-3 behind a taken jalr; of mscratch, 1; one right behind a jump shows nothing, the jump's bubble having emptied WB

**From the RTL source (read, not measured).**  `rtl/cv32e40x_controller_bypass.sv`, lines 269-273 (`minstret_stall`): the stall has a signal and a comment of its own ('Stall (EX) due to performance counter read'), outside the three CSR stall cases the file lists at lines 241-246: it is not the implicit CSR write of the Hazards list's line 120

### [irq-enable-stall](issues/irq-enable-stall/): A load or store behind a CSR write of mstatus or mie costs one cycle more

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle on every load or store right behind a write of mstatus or mie, whatever value the write carries
- Found on: cv32e40x
- Status: clarified; to file
- Issue directory: [issues/irq-enable-stall/](issues/irq-enable-stall/)

a load or store costs one more cycle than the cycle table's 1 when the instruction before it is a CSR instruction that writes mstatus or mie.

**What the documentation says.**  pipeline.rst, 'Cycle counts per instruction type': Load/Store 1 cycle (lines 48-49); the Hazards list (lines 114-126) names no hazard between a CSR write and a load or store; exceptions_interrupts.rst says interrupts are enabled through mstatus.MIE and mie (line 186) and gives no timing for the write

**What the RTL does.**  a load or store retires 2 cycles after a csrrs that writes mstatus (c.lbu, c.sb) or mie (c.lh, c.sh), the written value unchanged in all four (rs1 holds 0); the loads and stores elsewhere in the same test, not behind such a write, retire after 1

**From the RTL source (read, not measured).**  `rtl/cv32e40x_controller_bypass.sv`, lines 275-278 (`irq_enable_stall`): EX is stalled while a load or store is in it and a write that may enable an interrupt is in WB ('Stall EX when an interrupt may be enabled from WB while there is a LSU instruction in EX'); without CLIC those writes are of mie and mstatus (cv32e40x_cs_registers.sv:1555)

### [mhpmcounter3h-read-stall](issues/mhpmcounter3h-read-stall/): A read of mhpmcounter3h costs one cycle more while an instruction is in WB

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle on every read of mhpmcounter3h while an instruction is in WB
- Found on: cv32e40x
- Status: clarified; to file
- Issue directory: [issues/mhpmcounter3h-read-stall/](issues/mhpmcounter3h-read-stall/)

a read of mhpmcounter3h costs one more cycle than the cycle table's 1 when an instruction is in WB, as a read of the other counters does.

**What the documentation says.**  pipeline.rst, 'Cycle counts per instruction type': CSR Access 1 cycle for every CSR but jvt (lines 44-46); the Hazards list names no stall on a counter read (lines 114-126); perf_counters.rst lists mhpmcounter3(h) among the counters and gives no timing

**What the RTL does.**  csrrs of mhpmcounter3h retires 2 cycles after the instruction before it in 20 of 21 reads, behind an ALU instruction, a load, a store, a multiply or a divide; the one read that retires as predicted is behind a write of the same counter, where the read waits for the write already

**From the RTL source (read, not measured).**  `rtl/cv32e40x_cs_registers.sv`, lines 632-644 (`csr_counter_read_o`): the flag that holds a counter access in EX is set for mhpmcounter3h to mhpmcounter31h as it is for mcycleh and minstreth

### [mem-address-phase](issues/mem-address-phase/): The data bus accepts the next request only the cycle after the previous grant

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle between consecutive data requests: the next issues the cycle after the previous grant
- Found on: cv32e40x
- Status: clarified; to file
- Issue directory: [issues/mem-address-phase/](issues/mem-address-phase/)

the data bus accepts a new request no earlier than the cycle after the previous one was granted: the address phase holds the bus for a cycle, so the next load or store issues its request the cycle after the grant before it, whatever its response has done.

**What the documentation says.**  load_store_unit.rst 'Protocol' (lines 76-95): the memory may grant 'at any time', the response comes 'one or more cycles after', up to two transactions outstanding (74-75); nothing about when the next request may be presented

**What the RTL does.**  with the testbench memory holding grants by a per-request schedule, request k+1 appears on data_req_o in the cycle after request k's grant: Misalign-lw-00 random:0-3 seed 7, k27 requested 388 = k26 granted 387 + 1 while k26's response was still open (390); k24 requested 363 = k23 granted 360... no: k24 waited for the outstanding slot (see mem-response-frees-slot) and then issued 363, k22 and k23 (the two halves of a split) 359 and 360 = grant + 1

**From the RTL source (read, not measured).**  `rtl/cv32e40x_load_store_unit.sv`, lines 194, 512-516 (`trans_valid_q`): 'trans_valid got clocked without trans_ready': the request stays presented until granted; the generation comment: 'Assumes that corresponding response is at least 1 cycle after request'

### [mem-response-frees-slot](issues/mem-response-frees-slot/): A response frees its outstanding slot the cycle after it is on the wire

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle before a third request may issue once two are outstanding: the slot frees the cycle after the response
- Found on: cv32e40x
- Status: clarified; to file
- Issue directory: [issues/mem-response-frees-slot/](issues/mem-response-frees-slot/)

a response frees its outstanding-transaction slot the cycle after it is on the wire, not in it: with two responses open, the next request issues in the cycle of the second-to-last response at the earliest.

**What the documentation says.**  load_store_unit.rst 74-75: 'can cause up to two outstanding transactions'; nothing about the cycle a completed transaction stops counting

**What the RTL does.**  Misalign-lw-00 random:0-3 seed 7: the split lw's halves k22 and k23 granted 359 and 360 with responses 362 and 363; the next load's request k24 appears at 363, the cycle of k23's response (k22's at 362 having freed its slot for 363), not at 362

**From the RTL source (read, not measured).**  `rtl/cv32e40x_load_store_unit.sv`, lines 162-166, 516 (`cnt_q`): the outstanding counter counts up on a grant and down on a response (count_up / count_down, 'can happen at same time'); a request is generated only while cnt_q < DEPTH (2), and cnt_q is a register, so the response's decrement is seen the next cycle

### [mem-responses-in-order](issues/mem-responses-in-order/): Responses return in order, at most one per cycle

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle on a response due with or before the previous one
- Found on: cv32e40x
- Status: clarified; to file
- Issue directory: [issues/mem-responses-in-order/](issues/mem-responses-in-order/)

responses are returned in order and at most one per cycle, so a response whose own delay would put it in the same cycle as, or before, the previous response waits for the cycle after it.

**What the documentation says.**  load_store_unit.rst 93-95: with several granted requests outstanding 'the memory requests will be kept in-order and one data_rvalid_i will be signalled for each of them, in the order they were issued'; the one-per-cycle spacing is the OBI protocol's (one response phase per cycle) and the harness's

**What the RTL does.**  Misalign-lw-00 random:0-3 seed 7: k33 granted 454 with respond 2 -> 456; k34 granted 455 with respond 1 -> due 456, answered 457; a cycle model that gave k34 its response at 456 was a cycle early on the following instruction until it spaced responses as the memory does

### [mem-split-second-half](issues/mem-split-second-half/): A split access requests its second half from WB, the cycle after the first grant

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: a misaligned access pays its second half's grant and response wait from WB, one cycle more than a single access
- Found on: cv32e40x
- Status: clarified; to file
- Issue directory: [issues/mem-split-second-half/](issues/mem-split-second-half/)

the second transaction of a misaligned (split) access is requested the cycle after the first was granted, while the instruction is already in WB: the split's extra cycle is spent there, and the second half's grant and response delays are paid from there.

**What the documentation says.**  pipeline.rst Load/Store row (48-52): 'For misaligned word transfers and for halfword transfers that cross a word boundary 2 bus transactions are performed using EX and WB stages for 2 cycles each'; load_store_unit.rst 56-64: the lower address first

**What the RTL does.**  Misalign-lw-00 random:0-3 seed 7: lw a3, 1(a1) (order 296) is k22 and k23: requested 359 and 360, granted 359 and 360, answered 362 and 363; the instruction retires at 364 = the second response + 1, and the next instruction's request waits for the slot (mem-response-frees-slot).  With accept on the second half (k40 of the every:4 run: granted 434, one cycle held) the instruction retires one later

**From the RTL source (read, not measured).**  `rtl/cv32e40x_load_store_unit.sv`, lines 453, 400-410 (`lsu_split_0_o / split_q`): 'Output will be valid (valid_1_o) only for the last phase of split access'; rdata_q keeps the first half's data while the second is outstanding

### [mem-late-data-forward](issues/mem-late-data-forward/): A load's result is not forwarded before its response is on the wire

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: a consumer two or more behind a load waits until the data is on the wire, a jalr one cycle more, instead of the free forward the list gives
- Found on: cv32e40x
- Status: clarified; to file
- Issue directory: [issues/mem-late-data-forward/](issues/mem-late-data-forward/)

a load's result cannot be forwarded before its response is on the wire: a consumer that the Hazards list lets read the value at no cost (distance 2 and beyond) stalls until the data arrives, and a jalr, which needs the value a stage earlier, until the cycle after.

**What the documentation says.**  pipeline.rst Hazards (114-126): the load data hazard is charged to 'the instruction immediately following a load' only, and the cycle table assumes 'zero stall on the data-side memory interface' (30-31): nothing about a consumer of a load whose response is late

**What the RTL does.**  Misalign-lw-00 random:0-3 seed 7: beq tp, a3 (order 285) at distance 2 behind lw a3 (respond 2, data at 343) and distance 1 behind lw tp (respond 3, data at 345) retires at 348, one cycle later than the Hazards list's costs give; the generated compound tests hzc-interleave-00/01/03/04/05: a jalr at distance 2 behind a load with a late response retires one cycle later still than a load-use consumer would

**From the RTL source (read, not measured).**  `rtl/cv32e40x_wb_stage.sv`, lines 150-157 (`lsu_valid_o / wb_ready_o`): the WB stage is valid for a load only when the LSU's response is valid (lsu_ready_i, 'The late (data_rvalid_i based) downstream wb_ready_i signal', ex_stage.sv 469-472): the register-file write and the forwarding path carry the data from that cycle

### [mem-wbuf-fence-drain](issues/mem-wbuf-fence-drain/): A fence behind a buffered store waits for the store's response, then runs its own cycles

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: a fence behind a store the write buffer took waits for the store's response, not its grant, before its own cycles
- Found on: cv32e40x-pma
- Status: clarified; to file
- Issue directory: [issues/mem-wbuf-fence-drain/](issues/mem-wbuf-fence-drain/)

on a configuration with a bufferable region (cv32e40x-pma, PMA_NUM_REGIONS = 1), a fence, fence.tso or fence.i behind a store the write buffer absorbed waits in WB until that store's response is on the wire -- not its grant -- and only then begins its own sequence (2 cycles in WB for fence and fence.tso, 3 for fence.i, the zero-wait figures), so it leaves WB at rsp + 3 (fence) or rsp + 4 (fence.i) whatever the split between the withheld grant and the late response.

**What the documentation says.**  load_store_unit.rst 155-158: 'Transactions in the write buffer must be completed before the core is able to retire a fence / fence.i'; it does not say whether completed means granted or answered, nor that the fence's own cycles start after the completion rather than overlapping it

**What the RTL does.**  the scheduled hazard suite on cv32e40x-pma, 9 Oct 2026 (the first run of the configuration under a bus schedule): 9 intervals differ in 4 tests, every one a fence behind a bufferable store with a wait: hzs-occupancy-00 orders 13866 and 17000 (sb accept 3: fence RTL +5, the grant rule +2), hzs-shape-05-01 order 3055 (c.sb respond 4: fence.i +6 against +3), hzs-shape-06-01 order 2305 (c.sw respond 2: fence.i +4 against +3), hzs-shape-17-00 order 796 (sb accept 2: fence.tso +4 against +2); the extra equals rsp - req - 1 of the harness log in every case; with the hold ending the cycle after the response and the occupancy counted from there, all four at 0 differ, and the instruction after the fence (its jump target) retires when the sequence ends

**From the RTL source (read, not measured).**  `rtl/cv32e40x_controller_fsm.sv`, lines 891-893 (`lsu_busy_i`): fence_req_q is set only once the LSU has no outstanding transfer (the RTL question fence_lsu_busy_wait, answered by this finding)

### [mem-pma-split-first-half](issues/mem-pma-split-first-half/): A split access into I/O issues its legal first half, then faults a cycle later

- Class: function -- not a timing finding: a value, a fault or a sequence
- Found on: cv32e40x-pma
- Status: clarified; to file
- Issue directory: [issues/mem-pma-split-first-half/](issues/mem-pma-split-first-half/)

on a configuration with PMA regions (cv32e40x-pma), a split (misaligned, word-crossing) load or store whose first transaction is in main memory and whose second falls into I/O issues the first transaction on the bus -- a read as well as a write -- and takes the precise access fault (code 5 / 7) one cycle after a fault whose first transaction is already into I/O; the RTL's RVFI reports that transaction as the trapped instruction's memory access, Spike (which logs no memory access of an instruction that trapped) none.

**What the documentation says.**  pma.rst 87-111 (Instructions with multiple memory operations): 'Misaligned store, 2: Exception taken, first store visible outside of the core', while the load rows say only 'Exception taken, no state updates' -- that the first load transaction is issued too, and that the fault costs the second transaction's cycle, is not said

**What the RTL does.**  hzp-pma-00 on cv32e40x-pma, 10 Oct 2026: blocks pma_load_split_hole and pma_store_split_hole (lw / sw at 0x803ffffe, the memory's last two bytes, the hole from 0x80400000): the harness log shows one request each (k6 read 0x803ffffe, k8 write 0x803ffffe of 0x11c, 2 bytes), the RTL trace carries that transaction as the instruction's memory record where Spike's carries none, and the RTL retires each of the two one cycle later (+2) than a fault on the first transaction costs (+1); the misaligned blocks wholly in the hole (lw / sw at 0x80400001) issue nothing and agree at +1

**From the RTL source (read, not measured).**  `rtl/cv32e40x_load_store_unit.sv`, lines 400-453 (`split_q / lsu_split_0_o`): the first phase of a split access is issued before the second is checked; the MPU (cv32e40x_mpu.sv, pma_err) refuses the second transaction alone

### [mem-wbuf-third-store](issues/mem-wbuf-third-store/): A bufferable store whose grant is withheld, third behind a mulh, stalls one cycle

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle on a bufferable store when the buffer's transfer holds the last outstanding slot
- Found on: cv32e40x-pma
- Status: clarified; to file
- Issue directory: [issues/mem-wbuf-third-store/](issues/mem-wbuf-third-store/)

on cv32e40x-pma, three bufferable stores in a row behind a 4-cycle mulh -- the first with its grant withheld one cycle, the second granted at once, the third (sb) with its grant withheld two cycles -- the third retires one cycle later than a store the write buffer absorbs (+2 against the +1 of the write-buffer rule), and the load behind it one cycle earlier than predicted (+6 against +7); the same block on cv32e40x, where no store is bufferable, is at 0 differ.

**What the documentation says.**  load_store_unit.rst Write buffer (142-160): the buffer, when not full, lets the core proceed without waiting for data_gnt_i and data_rvalid_i of a bufferable transfer; nothing on what happens to the third of three stores when the buffer has just emptied, nor on the early response's timing (the response filter, rtl/cv32e40x_lsu_response_filter.sv, is not in the manual)

**What the RTL does.**  hzs-shape-01-zmmul-00 on cv32e40x-pma, 12 Oct 2026, block 60 (shape s3_mem14_mem25_struct03: mulh, sw accept 1, sw, sb accept 2, lb accept 3, lb): the harness log k71 sw req 2177 gnt 2178 rsp 2179, k72 sw req 2179 gnt 2179 rsp 2180, k73 sb req 2180 gnt 2182 rsp 2183, k74 lb req 2183 gnt 2186 rsp 2187; retirements mulh 2178, sw 2179, sw 2180, sb 2182, lb 2188: the sb takes two cycles where the rule gives one; the memory-kind blocks with a single absorbed store (cp_f3_wbuf absorbed_a2) are at 0 differ, so it is the sequence, not the absorption; traced with the harness's VCD, cycles as the harness log counts them: 2177 the first sw at the filter, its bus-side count 0 and the buffer empty -- taken (count 1); 2178 the first sw granted, the second sw taken by the buffer as it frees (count 2), the first's response given to the core the same cycle; 2179 the sb in EX with the count at 2 (the first sw's response on the wire this cycle, the second sw granted this cycle) -- the filter's ready_o low, the sb held one cycle; 2180 count 1, the buffer empty -- the sb taken, on the bus; 2181 its response given to the core (the oldest open transfer is bufferable), retired 2182; the lb behind it held by the full buffer (2181) and the sb's grant cycle (2182), on the bus 2183, granted 2186, retired 2188 -- the same cycle the rule gave it, so only the sb moves

**From the RTL source (read, not measured).**  `rtl/cv32e40x_lsu_response_filter.sv`, lines 109-110, 158-160 (`bus_cnt_q, ready_o, resp_valid_o`): the filter sits between the MPU and the write buffer (cv32e40x_load_store_unit.sv 873-899); bus_cnt_q counts a transfer from the buffer taking it (bus_trans_accepted = ready_i && valid_o, ready_i the buffer's ready) to its response (resp_valid_i), so a transfer the buffer holds counts as outstanding; ready_o = ready_i && bus_cnt_q < DEPTH (2) holds the core's next transfer, bufferable or not, while two are open; resp_valid_o = bus_resp_is_bufferable ? core_resp_is_bufferable : resp_valid_i gives a bufferable store its response the cycle the buffer takes it when the oldest open transfer is bufferable -- traced cycle by cycle (the rtl field)

### [mem-atomic-misaligned-cause](issues/mem-atomic-misaligned-cause/): A misaligned atomic raises an access fault (5, 7), not a misaligned one (4, 6)

- Class: function -- not a timing finding: a value, a fault or a sequence
- Found on: cv32e40x-pma-a
- Status: clarified; to file
- Issue directory: [issues/mem-atomic-misaligned-cause/](issues/mem-atomic-misaligned-cause/)

on cv32e40x-pma-a (A_EXT=A), an lr.w, sc.w or amoadd.w whose address is not word-aligned (tdata + 2, main memory) traps with mcause 5 (lr.w) or 7 (sc.w, the AMO): the access faults; the exception table (exceptions_interrupts.rst) says a non-naturally aligned Load-Reserved address raises 'Load address misaligned' (4) and a non-naturally aligned Store-Conditional / AMO address 'Store/AMO address misaligned' (6).  No request goes on the bus; Spike raises the same access faults, so the two references agree and only the document differs.

**What the documentation says.**  exceptions_interrupts.rst 30 and 36 (the exception table): code 4 'Load address misaligned' for a 'Non-naturally aligned Load-Reserved address', code 6 'Store/AMO address misaligned' for a 'Non-naturally aligned Store-Conditional / AMO address'; codes 5 and 7 list only the I/O-region and no-atomic-support cases.  load_store_unit.rst 56: 'Misaligned transactions (by non-atomics instructions) are supported in hardware for Main memory regions'; pma.rst 60-65 says nothing on alignment

**What the RTL does.**  the probe's run, 13 Oct 2026: lr.w s7, (s5) at tdata + 2 traps with mcause 5, sc.w s10, s6, (s5) and amoadd.w s0, s6, (s5) with mcause 7; mepc the atomic's pc; no data request on the bus for any of the three; the aligned control amoadd.w completes

**From the RTL source (read, not measured).**  `rtl/cv32e40x_controller_fsm.sv`, lines 343, 356-357 (`exception_cause_wb`): an atomic's alignment error reaching WB (align_status_wb_i != ALIGN_OK, from cv32e40x_align_check.sv: the check runs when atop[5] is set, cv32e40x_load_store_unit.sv 833) is an exception whose cause is EXC_CAUSE_STORE_FAULT for ALIGN_WR_ERR and EXC_CAUSE_LOAD_FAULT otherwise; no EXC_CAUSE_*_MISALIGNED is ever selected by that chain

### [nmi-taken-kill](issues/nmi-taken-kill/): A bus error's NMI is taken the cycle after the faulting access retires, every stage killed

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: the NMI handler's first retirement 5 cycles after the carrier's (the faulting load or store); the instruction behind the carrier retires before the handler only when its data request was outstanding when the error was seen, otherwise it is killed and runs again after the handler's mret
- Found on: cv32e40x
- Status: clarified; to file
- Issue directory: [issues/nmi-taken-kill/](issues/nmi-taken-kill/)

a bus error on a load or store is taken as an NMI the cycle after the faulting access retires: every stage is killed and the pc set to the NMI vector; one more load or store retires first when its request was already outstanding (two retirements after the error at most, as the exceptions chapter says), and a pending interrupt is taken after the NMI handler's mret, not before the NMI.

**What the documentation says.**  exceptions_interrupts.rst line 103 ('the instruction that causes the fault is allowed to retire and the associated NMI is taken afterwards') and line 105 ('Once the NMI is visible to the core, at most two instructions will retire before the NMI is taken'); pipeline.rst says nothing of an NMI's taking, its kills or what is abandoned

**What the RTL does.**  hze-nmi-00: the carrier retires with the error response, the handler's first retirement (the NMI vector's jump, rvfi_intr) comes 5 cycles later, the instructions behind the carrier abandoned and re-executed after the mret; with a lw or sw right behind the carrier that one retires too (its request was outstanding), the handler then 5 cycles after it; with line 17 pending at the same time the NMI's handler runs first and the interrupt's right after its mret

**From the RTL source (read, not measured).**  `rtl/cv32e40x_controller_fsm.sv`, lines 729-742 (`nmi_allowed`): a pending NMI (nmi_pending_q, set at lines 1214-1230 by a bus error on a data response in WB) that is allowed (lines 562-563: the interrupt's conditions without the blanking, and not the cycle after waking to a debug request or an interrupt) kills IF, ID, EX and WB, sets the pc to PC_TRAP_NMI and saves the cause 1024 (load) or 1025 (store)

### [jvt-write-flush](issues/jvt-write-flush/): jvt write: the table's 4 cycles are a flush of the next instruction

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: five cycles on the instruction after every write of jvt (the write itself retires in one), and the interrupt taking blocked for the cycle after the write's retirement
- Found on: cv32e40x
- Status: clarified; to file
- Issue directory: [issues/jvt-write-flush/](issues/jvt-write-flush/)

the cycle-count table gives a CSR access 4 cycles for jvt; on the RTL a write of jvt retires in one cycle and the instructions behind it are flushed and refetched, so the next instruction retires 5 cycles after the write (1 + 4 is the table's 4 over the pair), and an interrupt pending in the cycle after the write's retirement is taken one cycle later than after any other CSR write; the document states neither the flush nor the interrupt's cycle, and a read of jvt costs 1.

**What the documentation says.**  pipeline.rst, 'Cycle counts per instruction type', the CSR Access row (line 44): '4 (jvt)' against 1 for every other CSR; nothing in the table or in the Hazards list says the cycles are a flush of the following instructions, nor that an interrupt is blocked for a cycle

**What the RTL does.**  the jvt write retires one cycle after the instruction before it; the instruction behind it retires 5 cycles after the write (a plain CSR write: 1); with the interrupt line up before the write, the handler's first instruction retires 6 cycles after the write against 5 after any other CSR write (hze-jvt-00, phases 0-10, 44 blocks: the swept line at every phase across the flush and the refetch)

**From the RTL source (read, not measured).**  `rtl/cv32e40x_cs_registers.sv`, lines 1545-1548 (`csr_wr_in_wb_flush_o`): csr_wr_in_wb_flush_o = jvt_wr_in_wb: a write of jvt in WB is the one CSR write that asks the controller for a flush; the controller (rtl/cv32e40x_controller_fsm.sv 933-950) halts IF, ID and EX in that cycle, kills them in the next (csr_flush_ack_q) and restarts fetch from the oldest killed instruction, and interrupt_allowed (line 557) is low in that acknowledge cycle

### [clic-implicit-csr-read-stall](issues/clic-implicit-csr-read-stall/): CLIC: an access of mnxti or mscratchcswl behind any CSR instruction waits a cycle

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle on every access of mnxti or mscratchcswl one behind any CSR instruction, in CLIC mode
- Found on: cv32e40x-clic
- Status: clarified; to file
- Issue directory: [issues/clic-implicit-csr-read-stall/](issues/clic-implicit-csr-read-stall/)

in CLIC mode an access of mnxti (csrrs rd, mnxti, x0) or of mscratchcswl (csrrw rd, mscratchcswl, rs1) one behind any CSR instruction retires a cycle late: the core reads another CSR implicitly for these two (mstatus for mnxti; mscratch, mcause and mintstatus for mscratchcswl) and holds the access in EX while a CSR instruction is in the write stage; the Hazards list's implicit-read row names no instruction, so a reader cannot know these are the two.

**What the documentation says.**  pipeline.rst, Hazards, line 119: 'an instruction causing an implicit CSR read in EX while a CSR access instruction or an instruction causing an implicit CSR access is in the WB stage' -- no instruction named; the CLIC chapter of control_status_registers.rst describes mnxti and mscratchcswl without a cycle

**What the RTL does.**  csrrs rd, mnxti, x0 and csrrw rd, mscratchcswl, rs1, each one behind csrrs/csrrc/csrrci of mscratch: 2 cycles where any other CSR instruction in that position takes 1 (own-cv32e40x-clic-00 on cv32e40x-clic: 4 of 4 blocks, RTL +1 each)

**From the RTL source (read, not measured).**  `rtl/cv32e40x_controller_bypass.sv`, lines 256-267 (`csr_hz_i.impl_re_ex`): csr_stall_ex's first term (line 262): an implicit CSR read in EX -- an access of mnxti (cv32e40x_cs_registers.sv 426-439) or of mscratchcswl (462-482) -- while csr_write_in_wb (lines 143-144): any CSR instruction in WB, a pure read included; EX is halted for that cycle

### [clic-mie-write-no-stall](issues/clic-mie-write-no-stall/): CLIC: a load or store behind a write of mie does not wait, unlike the CLINT core

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: none: a saving of the cycle the core pays in CLINT mode on a load or store one behind a write of mie
- Found on: cv32e40x-clic
- Status: clarified; to file
- Issue directory: [issues/clic-mie-write-no-stall/](issues/clic-mie-write-no-stall/)

in CLIC mode a load or store one behind a write of mie retires in its normal cycle, where the same core in CLINT mode holds it one cycle (the write may enable an interrupt there); in CLIC mode mie has no part in enabling an interrupt and the interlock does not fire; neither the Hazards list nor the CLIC chapter says which writes hold a load or store in either mode.

**What the documentation says.**  pipeline.rst, Hazards (lines 114-126): no row for a load or store behind a write that may enable an interrupt, in either mode; control_status_registers.rst's CLIC section: mie 'reads as zero' in CLIC mode with no word on the interlock

**What the RTL does.**  c.lbu, c.lh, c.lhu, c.lw, c.sb, c.sh, c.sw, c.swsp each one behind csrrs x0, mie, rs1: 1 cycle on cv32e40x-clic (own-cv32e40x-clic-00: 8 of 8 blocks) against the 2 the core's statement irq_enable_lsu_d1 gives, measured on cv32e40x (own-cv32e40x-00, 4 Oct 2026)

**From the RTL source (read, not measured).**  `rtl/cv32e40x_cs_registers.sv`, lines 1550-1557 (`csr_irq_enable_write_o`): the clic_irq_en branch (line 1553): csr_irq_enable_write_o is mstatus_we, priv_lvl_we, mintthresh_we or mintstatus_we -- mie_we is in the CLINT branch only; irq_enable_stall (controller_bypass.sv 275-278) holds a load or store in EX for the cycle the writer is in WB

### [clic-mintthresh-write-stall](issues/clic-mintthresh-write-stall/): CLIC: a load or store behind a write of mintthresh waits a cycle

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle on every load or store one behind a write of mintthresh, in CLIC mode
- Found on: cv32e40x-clic
- Status: clarified; to file
- Issue directory: [issues/clic-mintthresh-write-stall/](issues/clic-mintthresh-write-stall/)

in CLIC mode a load or store one behind a write of mintthresh retires a cycle late: the write may enable an interrupt (it lowers the threshold) and the core holds the load or store in EX while the writer is in the write stage, as it does behind a write of mstatus; a write through mnxti (csrrsi x0, mnxti, 8), which the RTL source reads as a write of mstatus, does not hold it; the Hazards list has no row for any of this.

**What the documentation says.**  pipeline.rst, Hazards (lines 114-126): no row for a load or store behind a write that may enable an interrupt; control_status_registers.rst's mintthresh section gives no cycle

**What the RTL does.**  c.lbu and c.sb each one behind csrrs x0, mintthresh, rs1: 2 cycles (own-cv32e40x-clic-00: 2 of 2 blocks, RTL +1); c.lh and c.sh each one behind csrrsi x0, mnxti, 8: 1 cycle (2 of 2 blocks, no stall)

**From the RTL source (read, not measured).**  `rtl/cv32e40x_cs_registers.sv`, lines 1550-1557 (`csr_irq_enable_write_o`): the clic_irq_en branch (line 1553): csr_irq_enable_write_o includes mintthresh_we; the pass also read an mnxti write as writing mstatus (lines 936-938) and so expected the stall behind it, which the measurement does not show: the write enable it sets is not one of the four the branch names

### [clic-mcause-write-irq-enable-stall](issues/clic-mcause-write-irq-enable-stall/): CLIC: a load or store one behind an mcause write waits a cycle

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle on every load or store one behind an mcause write, in CLIC mode (an interrupt handler that rewrites mcause before saving state pays it)
- Found on: cv32e40x-clic
- Status: clarified; to file
- Issue directory: [issues/clic-mcause-write-irq-enable-stall/](issues/clic-mcause-write-irq-enable-stall/)

in CLIC mode a load or a store one behind a write of mcause retires a cycle late: the core treats an mcause write as a write that may enable an interrupt, as it treats a write of mstatus or mintthresh, because in CLIC mode the mpp and mpie fields of mcause are the same bits as mstatus's; the manual's hazard list names no stall behind a write of mcause.

**What the documentation says.**  pipeline.rst, Hazards: no entry for a load or store behind a write that may enable an interrupt, and none for mcause; control_status_registers.rst's CLIC section says mcause.mpp and mcause.mpie are aliases of mstatus's fields and says nothing of timing

**What the RTL does.**  csrrw x0, mcause, s2 then lw s4, 0(a5): the load retires 2 cycles after the write (1 behind any other CSR write of the base set); the same for sw, lbu, sh; two to four behind, 1 (the row cross cross2 of 22 Oct 2026 on cv32e40x-clic, files 259 and 260; on cv32e40x, where mcause is not aliased, the same load pays nothing, cross2 there)

**From the RTL source (read, not measured).**  `rtl/cv32e40x_cs_registers.sv`, lines 912-920, 1028-1037 (`mstatus_alias_we`): read 22 Oct 2026 (ours, not the RTL pass's): in CLIC mode a write to mcause.mpp or mcause.mpie is aliased to mstatus (mstatus_alias_we, 912-920) and the alias branch sets mstatus_we (1028-1037), so csr_irq_enable_write_o (1550-1557) fires for it and irq_enable_stall (controller_bypass.sv 275-278) holds the load or store in EX while the write is in WB


© 2026 processor-timing-anomalies, Apache License 2.0
