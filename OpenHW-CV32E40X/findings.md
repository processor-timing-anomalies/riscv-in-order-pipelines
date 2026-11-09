# CV32E40X: the anomalies found

This document lists every timing anomaly we found on the CV32E40X: each place where the core's RTL, measured cycle by cycle, does not do what its documentation says, or does something the documentation does not mention.  An anomaly is found by running a program on the RTL and on our cycle-accurate timing reference simulator and comparing the cycle each instruction retires in with the cycle the documentation predicts; it is kept here once a developer has read the RTL source or the manual and confirmed it.  None of them is a functional bug: the programs compute the right results.  They are cycles the documentation does not account for.

Each anomaly has a **class** (the table below: how the hardware's trigger compares with the cause it exists for), a **cost** in cycles, **whom it concerns** (the RTL's developers, the core's performance, or the documentation), a **status**, and, for most, an **issue directory** under `issues/` with the issue's text and, when a small program reproduces it, that program, the two RVVI traces (the RTL's and the reference's) and the capture's facts; `issues/README.md` says what each directory holds.  The timing specification beside this document (`timing.md`) carries the same anomalies as rows of its section 9, in the context of the rules they break.

Generated from our record on 9 November 2026: 37 anomalies -- 2 in the RTL, 9 on performance, 26 in the documentation.

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
  - [mem-response-wait-freeze](#mem-response-wait-freeze-while-a-load-or-store-waits-in-wb-nothing-moves-into-id-or-ex-even-into-an-empty-stage): While a load or store waits in WB, nothing moves into ID or EX, even into an empty stage
  - [mem-atomic-serial](#mem-atomic-serial-an-atomic-transaction-overlaps-no-other-a-cycle-lost-on-each-side-of-an-lr-sc-or-amo): An atomic transaction overlaps no other: a cycle lost on each side of an lr, sc or AMO
  - [tselect-access-stall](#tselect-access-stall-a-csr-instruction-behind-any-access-of-tselect-waits-a-cycle): a CSR instruction behind any access of tselect waits a cycle
  - [clic-csr-after-implicit-write-stall](#clic-csr-after-implicit-write-stall-clic-a-csr-instruction-one-behind-an-mscratchcswl-access-waits-a-cycle): CLIC: a CSR instruction one behind an mscratchcswl access waits a cycle
  - [occupancy-freezes-empty-id](#occupancy-freezes-empty-id-an-empty-id-stage-takes-no-instruction-while-a-multi-cycle-instruction-holds-ex): An empty ID stage takes no instruction while a multi-cycle instruction holds EX
  - [fetch-refused-at-io-window-costs-return](#fetch-refused-at-io-window-costs-return-a-jump-in-the-last-word-before-an-io-region-puts-its-targets-fetch-a-cycle-late): A jump in the last word before an I/O region puts its target's fetch a cycle late
  - [stale-load-use-check](#stale-load-use-check-an-empty-id-stage-stalls-on-a-load-use-hazard-with-the-loads-own-stale-register-fields): An empty ID stage stalls on a load-use hazard with the load's own stale register fields
- [For the documentation](#for-the-documentation)
  - [csr-rows-unnamed](#csr-rows-unnamed-csr-rows-unnamed): csr-rows-unnamed
  - [fencei-six-cycles](#fencei-six-cycles-fencei-costs-6-cycles-not-the-cycle-tables-5): fence.i costs 6 cycles, not the cycle table's 5
  - [divisor-leading-ones](#divisor-leading-ones-division-by-a-negative-divisor-the-cycle-count-is-not-the-divisors-leading-zeros): Division by a negative divisor: the cycle count is not the divisor's leading zeros
  - [jump-behind-divider](#jump-behind-divider-a-jal-behind-a-busy-divider-is-taken-at-once-its-cycle-hides-under-the-divide): A jal behind a busy divider is taken at once: its cycle hides under the divide
  - [counter-read-stall](#counter-read-stall-a-counter-read-costs-one-cycle-more-while-an-instruction-is-in-wb): A counter read costs one cycle more while an instruction is in WB
  - [irq-enable-stall](#irq-enable-stall-a-load-or-store-behind-a-csr-write-of-mstatus-or-mie-costs-one-cycle-more): A load or store behind a CSR write of mstatus or mie costs one cycle more
  - [mhpmcounter3h-read-stall](#mhpmcounter3h-read-stall-a-read-of-mhpmcounter3h-costs-one-cycle-more-while-an-instruction-is-in-wb): A read of mhpmcounter3h costs one cycle more while an instruction is in WB
  - [mem-address-phase](#mem-address-phase-the-data-bus-accepts-the-next-request-only-the-cycle-after-the-previous-grant): The data bus accepts the next request only the cycle after the previous grant
  - [mem-response-frees-slot](#mem-response-frees-slot-a-response-frees-its-outstanding-slot-the-cycle-after-it-is-on-the-wire): A response frees its outstanding slot the cycle after it is on the wire
  - [mem-responses-in-order](#mem-responses-in-order-responses-return-in-order-at-most-one-per-cycle): Responses return in order, at most one per cycle
  - [mem-split-second-half](#mem-split-second-half-a-split-access-requests-its-second-half-from-wb-the-cycle-after-the-first-grant): A split access requests its second half from WB, the cycle after the first grant
  - [mem-late-data-forward](#mem-late-data-forward-a-jalr-two-behind-a-load-waits-a-cycle-even-at-zero-wait): A jalr two behind a load waits a cycle, even at zero wait
  - [mem-wbuf-fence-drain](#mem-wbuf-fence-drain-a-fence-or-fencetso-behind-a-buffered-store-waits-for-the-stores-response-first): A fence or fence.tso behind a buffered store waits for the store's response first
  - [mem-pma-split-first-half](#mem-pma-split-first-half-a-misaligned-load-refused-on-its-second-half-has-already-read-its-first): A misaligned load refused on its second half has already read its first
  - [mem-wbuf-third-store](#mem-wbuf-third-store-a-store-the-write-buffer-could-take-still-waits-while-two-transfers-are-outstanding): A store the write buffer could take still waits while two transfers are outstanding
  - [mem-atomic-misaligned-cause](#mem-atomic-misaligned-cause-a-misaligned-atomic-raises-an-access-fault-5-7-not-a-misaligned-one-4-6): A misaligned atomic raises an access fault (5, 7), not a misaligned one (4, 6)
  - [nmi-taken-kill](#nmi-taken-kill-a-bus-errors-nmi-is-taken-the-cycle-after-the-faulting-access-retires-every-stage-killed): A bus error's NMI is taken the cycle after the faulting access retires, every stage killed
  - [jvt-write-flush](#jvt-write-flush-jvt-write-a-flush-of-the-next-instruction-costing-5-cycles-not-the-tables-4): jvt write: a flush of the next instruction costing 5 cycles, not the table's 4
  - [clic-implicit-csr-read-stall](#clic-implicit-csr-read-stall-clic-an-access-of-mnxti-or-mscratchcswl-behind-any-csr-instruction-waits-a-cycle): CLIC: an access of mnxti or mscratchcswl behind any CSR instruction waits a cycle
  - [clic-mie-write-no-stall](#clic-mie-write-no-stall-clic-a-load-or-store-behind-a-write-of-mie-does-not-wait-unlike-the-clint-core): CLIC: a load or store behind a write of mie does not wait, unlike the CLINT core
  - [clic-mintthresh-write-stall](#clic-mintthresh-write-stall-clic-a-load-or-store-behind-a-write-of-mintthresh-waits-a-cycle): CLIC: a load or store behind a write of mintthresh waits a cycle
  - [clic-mcause-write-irq-enable-stall](#clic-mcause-write-irq-enable-stall-clic-a-load-or-store-one-behind-an-mcause-write-waits-a-cycle): CLIC: a load or store one behind an mcause write waits a cycle
  - [jvt-mode-warl-zero-vs-udb-trap](#jvt-mode-warl-zero-vs-udb-trap-jvt-mode-warl-zero-vs-udb-trap): jvt-mode-warl-zero-vs-udb-trap
  - [mtvec-mode-2-reserved-keeps-legal](#mtvec-mode-2-reserved-keeps-legal-mtvec-mode-2-reserved-keeps-legal): mtvec-mode-2-reserved-keeps-legal
  - [mstatus-mpp-hardwired-3](#mstatus-mpp-hardwired-3-mstatus-mpp-hardwired-3): mstatus-mpp-hardwired-3
  - [irq-withdrawn-by-mie-clear-one-cycle](#irq-withdrawn-by-mie-clear-one-cycle-a-withdrawn-interrupt-costs-the-instruction-behind-the-clearing-write-a-cycle): A withdrawn interrupt costs the instruction behind the clearing write a cycle

## All of them

| anomaly | for | class | cost | found on | status | issue |
|---|---|---|---|---|---|---|
| An interrupt entry's CSR writes (mstatus, mepc, mcause) are not reported on RVFI | rtl | function | - | cv32e40x | closed; won't file: documented as intended (rvfi.rst 196) | [issues/rvfi-interrupt-entry-csrs-unreported/](issues/rvfi-interrupt-entry-csrs-unreported/) |
| mcause.minhv stays set after an mret restarts a faulted CLIC pointer fetch successfully | rtl | function | - | cv32e40x-clic | open; to file | [issues/clic-minhv-after-restart/](issues/clic-minhv-after-restart/) |
| An mret stalls behind any CSR access, including the CSRs it does not read | performance | over-wide | two cycles on an mret one behind any CSR access and one cycle two behind, mscratch and the other CSRs mret does not read included | cv32e40x | clarified; to file | [issues/csr-mret-rows-class-based/](issues/csr-mret-rows-class-based/) |
| Any CSR instruction naming a counter costs one cycle more while an instruction is in WB | performance | over-wide | one cycle on every CSR instruction that names any counter, machine-level or user alias, implemented or not, reading it or not, while an instruction is in WB | cv32e40x | clarified; to file | [issues/counter-access-stall/](issues/counter-access-stall/) |
| While a load or store waits in WB, nothing moves into ID or EX, even into an empty stage | performance | over-wide | the work a wait could hide, typically a jump's cycle, on every data-side wait; nothing at zero wait | cv32e40x | clarified; to file | [issues/mem-response-wait-freeze/](issues/mem-response-wait-freeze/) |
| An atomic transaction overlaps no other: a cycle lost on each side of an lr, sc or AMO | performance | over-wide | one cycle on every load, store, sc.w or AMO right behind an sc.w or an AMO, and on an atomic right behind a load or store | cv32e40x-pma-a | clarified; to file | [issues/mem-atomic-serial/](issues/mem-atomic-serial/) |
| a CSR instruction behind any access of tselect waits a cycle | performance | over-wide | one cycle on every CSR instruction one behind any access of tselect, a read included | cv32e40x | clarified; to file | [issues/tselect-access-stall/](issues/tselect-access-stall/) |
| CLIC: a CSR instruction one behind an mscratchcswl access waits a cycle | performance | over-wide | one cycle on every CSR instruction one behind an mscratchcswl access, in CLIC mode (an interrupt handler prologue does an mscratchcswl and then a CSR access as a matter of course) | cv32e40x-clic | closed; won't file: documented (pipeline.rst 120); the over-wide case for a write without a read not shown by a run | [issues/clic-csr-after-implicit-write-stall/](issues/clic-csr-after-implicit-write-stall/) |
| An empty ID stage takes no instruction while a multi-cycle instruction holds EX | performance | over-wide | one cycle on the instruction behind a divide, remainder or mulh whose instruction word arrives only in the multi-cycle instruction's last cycle in ID or later (an instruction-side wait state before it); nothing on a zero-wait instruction bus, where it is already in ID when the stall begins | cv32e40x | open; to file | [issues/occupancy-freezes-empty-id/](issues/occupancy-freezes-empty-id/) |
| A jump in the last word before an I/O region puts its target's fetch a cycle late | performance | over-wide | one cycle on a jump in the last word of main memory before an I/O region (measured on jalr; other distances from the region, and branches, not measured); nothing on the same jump 256 bytes below the region | cv32e40x-pma | open; to file | [issues/fetch-refused-at-io-window-costs-return/](issues/fetch-refused-at-io-window-costs-return/) |
| An empty ID stage stalls on a load-use hazard with the load's own stale register fields | performance | over-wide | one cycle on the instruction behind a load whose destination is one of its own source registers (rd = rs1; an AMO or sc.w with rd = rs2) when that instruction's word arrives from the instruction bus only as the load enters EX (an instruction-side wait state before it); nothing on a zero-wait instruction bus, where the follower is already in ID | cv32e40x | open; to file | [issues/stale-load-use-check/](issues/stale-load-use-check/) |
| csr-rows-unnamed | document | intent | none observed: the rows name no instruction this core has; an ecall or mret behind a CSR write pays the flush alone | cv32e40x | clarified; to file | [issues/csr-rows-unnamed/](issues/csr-rows-unnamed/) |
| fence.i costs 6 cycles, not the cycle table's 5 | document | intent | one cycle on every fence.i beyond the cycle table's five | cv32e40x | clarified; to file | [issues/fencei-six-cycles/](issues/fencei-six-cycles/) |
| Division by a negative divisor: the cycle count is not the divisor's leading zeros | document | intent | none beyond the document's rule read right: a signed divide by a negative divisor costs 3 plus its leading ones less one | cv32e40x | clarified; to file | [issues/divisor-leading-ones/](issues/divisor-leading-ones/) |
| A jal behind a busy divider is taken at once: its cycle hides under the divide | document | intent | a saving: a jump behind a busy divider pays no bubble of its own, one cycle fewer than the table | cv32e40x | clarified; to file | [issues/jump-behind-divider/](issues/jump-behind-divider/) |
| A counter read costs one cycle more while an instruction is in WB | document | intent | one cycle on every read of a counter while an instruction is in WB | cv32e40x | clarified; to file | [issues/counter-read-stall/](issues/counter-read-stall/) |
| A load or store behind a CSR write of mstatus or mie costs one cycle more | document | intent | one cycle on every load or store right behind a write of mstatus or mie, whatever value the write carries | cv32e40x | clarified; to file | [issues/irq-enable-stall/](issues/irq-enable-stall/) |
| A read of mhpmcounter3h costs one cycle more while an instruction is in WB | document | intent | one cycle on every read of mhpmcounter3h while an instruction is in WB | cv32e40x | clarified; to file | [issues/mhpmcounter3h-read-stall/](issues/mhpmcounter3h-read-stall/) |
| The data bus accepts the next request only the cycle after the previous grant | document | intent | one cycle between consecutive data requests: the next issues the cycle after the previous grant | cv32e40x | closed; won't file: documented (load_store_unit.rst 84-87, 22-23) | [issues/mem-address-phase/](issues/mem-address-phase/) |
| A response frees its outstanding slot the cycle after it is on the wire | document | intent | one cycle before a third request may issue once two are outstanding: the slot frees the cycle after the response | cv32e40x | closed; won't file: documented (load_store_unit.rst 120-125, the Multiple Outstanding figure) | [issues/mem-response-frees-slot/](issues/mem-response-frees-slot/) |
| Responses return in order, at most one per cycle | document | intent | one cycle on a response due with or before the previous one | cv32e40x | clarified; to file | [issues/mem-responses-in-order/](issues/mem-responses-in-order/) |
| A split access requests its second half from WB, the cycle after the first grant | document | intent | a misaligned access pays its second half's grant and response wait from WB, one cycle more than a single access | cv32e40x | closed; won't file: documented (pipeline.rst 48-52) | [issues/mem-split-second-half/](issues/mem-split-second-half/) |
| A jalr two behind a load waits a cycle, even at zero wait | document | intent | one cycle on a jalr two behind the load that writes its rs1 | cv32e40x | clarified; to file | [issues/mem-late-data-forward/](issues/mem-late-data-forward/) |
| A fence or fence.tso behind a buffered store waits for the store's response first | document | intent | a fence or fence.tso behind a store the write buffer took waits for the store's response before its own two cycles | cv32e40x-pma | clarified; to file | [issues/mem-wbuf-fence-drain/](issues/mem-wbuf-fence-drain/) |
| A misaligned load refused on its second half has already read its first | document | function | - | cv32e40x-pma | clarified; to file | [issues/mem-pma-split-first-half/](issues/mem-pma-split-first-half/) |
| A store the write buffer could take still waits while two transfers are outstanding | document | intent | one cycle on a bufferable store when the buffer's transfer holds the last outstanding slot | cv32e40x-pma | clarified; to file | [issues/mem-wbuf-third-store/](issues/mem-wbuf-third-store/) |
| A misaligned atomic raises an access fault (5, 7), not a misaligned one (4, 6) | document | function | - | cv32e40x-pma-a | clarified; to file | [issues/mem-atomic-misaligned-cause/](issues/mem-atomic-misaligned-cause/) |
| A bus error's NMI is taken the cycle after the faulting access retires, every stage killed | document | intent | the NMI handler's first retirement 5 cycles after the carrier's (the faulting load or store); the instruction behind the carrier retires before the handler only when its data request was outstanding when the error was seen, otherwise it is killed and runs again after the handler's mret | cv32e40x | clarified; to file | [issues/nmi-taken-kill/](issues/nmi-taken-kill/) |
| jvt write: a flush of the next instruction costing 5 cycles, not the table's 4 | document | intent | five cycles on the instruction after every write of jvt (the write itself retires in one), and the interrupt taking blocked for the cycle after the write's retirement | cv32e40x | clarified; to file | [issues/jvt-write-flush/](issues/jvt-write-flush/) |
| CLIC: an access of mnxti or mscratchcswl behind any CSR instruction waits a cycle | document | intent | one cycle on every access of mnxti or mscratchcswl one behind any CSR instruction, in CLIC mode | cv32e40x-clic | clarified; to file | [issues/clic-implicit-csr-read-stall/](issues/clic-implicit-csr-read-stall/) |
| CLIC: a load or store behind a write of mie does not wait, unlike the CLINT core | document | intent | none: a saving of the cycle the core pays in CLINT mode on a load or store one behind a write of mie | cv32e40x-clic | clarified; to file | [issues/clic-mie-write-no-stall/](issues/clic-mie-write-no-stall/) |
| CLIC: a load or store behind a write of mintthresh waits a cycle | document | intent | one cycle on every load or store one behind a write of mintthresh, in CLIC mode | cv32e40x-clic | open; to file | [issues/clic-mintthresh-write-stall/](issues/clic-mintthresh-write-stall/) |
| CLIC: a load or store one behind an mcause write waits a cycle | document | intent | one cycle on every load or store one behind an mcause write, in CLIC mode (an interrupt handler that rewrites mcause before saving state pays it) | cv32e40x-clic | clarified; to file | [issues/clic-mcause-write-irq-enable-stall/](issues/clic-mcause-write-irq-enable-stall/) |
| jvt-mode-warl-zero-vs-udb-trap | document | - | - | cv32e40x | closed; no issue directory | - |
| mtvec-mode-2-reserved-keeps-legal | document | - | - | cv32e40x | closed; no issue directory | - |
| mstatus-mpp-hardwired-3 | document | - | - | cv32e40x | closed; no issue directory | - |
| A withdrawn interrupt costs the instruction behind the clearing write a cycle | document | intent | one cycle on the second instruction behind a csrrci of mstatus.MIE when an enabled interrupt line rises in the data cycle of a store right before the write, and the interrupt itself deferred until MIE is set again; a race one cycle wide, no cost at any other alignment of the line and the write | cv32e40x | clarified; to file | [issues/irq-withdrawn-by-mie-clear-one-cycle/](issues/irq-withdrawn-by-mie-clear-one-cycle/) |

## For the RTL's developers

### [rvfi-interrupt-entry-csrs-unreported](issues/rvfi-interrupt-entry-csrs-unreported/): An interrupt entry's CSR writes (mstatus, mepc, mcause) are not reported on RVFI

- Class: function -- not a timing finding: a value, a fault or a sequence
- Found on: cv32e40x
- Status: closed; won't file: documented as intended (rvfi.rst 196)
- Issue directory: [issues/rvfi-interrupt-entry-csrs-unreported/](issues/rvfi-interrupt-entry-csrs-unreported/)

an interrupt's (or NMI's) entry writes mstatus, mepc and mcause in a cycle no instruction retires in, and cv32e40x_rvfi samples its CSR write masks with retirements only (rvfi_csr_wmask <= rvfi_csr_wmask_d on a WB retirement), so the trace reports no CSR write for the entry: the handler's first retirement carries rvfi_intr but an empty CSR mask, while an exception's writes are reported on the trapping instruction.  A reference ISS reports mcause, mepc and mstatus at the entry, so a wrong interrupt cause or mepc would be invisible to a consumer comparing CSR writes.

**What the documentation says.**  the RVFI specification (riscv-formal) has no interrupt entry of its own: rvfi_intr marks the first instruction of a handler; cv32e40x's rvfi_intr_t adds cause, interrupt and exception fields but no CSR writes for the entry

### [clic-minhv-after-restart](issues/clic-minhv-after-restart/): mcause.minhv stays set after an mret restarts a faulted CLIC pointer fetch successfully

- Class: function -- not a timing finding: a value, a fault or a sequence
- Found on: cv32e40x-clic
- Status: open; to file
- Issue directory: [issues/clic-minhv-after-restart/](issues/clic-minhv-after-restart/)

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

**What the RTL does.**  csrrw with rd = x0 -- a write that reads nothing -- of mcycle, mcycleh, minstret, minstreth, mhpmcounter3, mhpmcounter3h, mhpmcounter4, mhpmcounter4h, mhpmcounter31 or mhpmcounter31h retires 2 cycles after the instruction before it, behind an ALU instruction, a load, a store, a CSR instruction, a multiply or a divide (116 of 116).  csrrs reading mhpmcounter4, mhpmcounter31 or their high halves, which read 0 with NUM_MHPMCOUNTERS = 1, does the same (80 of 84; the four that retire after the cycles expected are behind a write of the same counter, where the read waits for that write already).  Later, 15 Oct 2026 (after the capture of 4 Oct 2026 whose traces are here), two generated tests on cv32e40x reading every user-level counter with csrrs and with csrrc: every csrrs or csrrc of cycle, instret, hpmcounter3 to hpmcounter31 or their high halves behind an instruction in WB retires 2 cycles after it, 61 reads in each file, hpmcounter4 to 31 reading zero (not implemented) and stalling all the same

**From the RTL source (read, not measured).**  `rtl/cv32e40x_cs_registers.sv`, lines 302-304 (`csr_raddr`): the flag that holds a counter access in EX (csr_counter_read_o) is decoded from the address field of the CSR instruction alone, for mcycle, minstret, mhpmcounter3 to 31 and their high halves (lines 580-592, 632-644): it does not depend on the instruction reading, nor on NUM_MHPMCOUNTERS

### [mem-response-wait-freeze](issues/mem-response-wait-freeze/): While a load or store waits in WB, nothing moves into ID or EX, even into an empty stage

- Class: over-wide -- the stall fires in cases that have no cause for it: an interlock wider than needed, a performance flaw
- Cost: the work a wait could hide, typically a jump's cycle, on every data-side wait; nothing at zero wait
- Found on: cv32e40x
- Status: clarified; to file
- Issue directory: [issues/mem-response-wait-freeze/](issues/mem-response-wait-freeze/)

from the cycle after a load or store enters WB until its response is on the wire, no instruction enters EX from ID and none enters ID from IF, whether the stage ahead is occupied or empty; so a jump behind the waiting access pays its full cycle after the wait, where behind a busy divider its cycle hides under the stall, and a jalr whose operand has just arrived waits in ID until the response.

**What the documentation says.**  pipeline.rst 30-31: the cycle table assumes zero stall on the data-side interface; the Hazards list (114-126) and the stage descriptions (12-26) say nothing about what the pipeline's other stages do while WB waits for a response

**What the RTL does.**  a generated store test under a bus answering every request two cycles after its grant: jal zero, 8 (order 161) behind sw gp, 8(ra) with a late response: the jal retires +1 as always, its target lui +2 instead of +1 (the target fetched in the jal's ID cycle sat in IF); under a schedule that delays every second response by one cycle, the single-hazard suite shows 377 intervals in which an instruction waited for a stage that was empty, in 61 tests, 217 of them jump targets retiring at the table's +2 where a stalled EX would have hidden the jump's cycle; all 377 are this rule.  hzc-interleave-00 random:0-3: jalr s4, 0(a6) (order 663) behind lw a6 and lb s2 with late responses retires two cycles after the lb, not one: the waveform shows id_ready and ex_ready low in the two cycles the lb waits in WB.  Waveforms from a tracing build read with a VCD script, 9 Oct 2026

**From the RTL source (read, not measured).**  `rtl/cv32e40x_ex_stage.sv`, lines 469-472 (`ex_ready_o`): 'The late (data_rvalid_i based) downstream wb_ready_i signal fans into the ready signals of all functional units': ex_ready_o includes lsu_ready_i; id_stage.sv 674: id_ready_o = ex_ready_i && !halt_id; wb_stage.sv 157: wb_ready_o includes lsu_ready_i -- the chain is low while the LSU in WB waits for data_rvalid_i

### [mem-atomic-serial](issues/mem-atomic-serial/): An atomic transaction overlaps no other: a cycle lost on each side of an lr, sc or AMO

- Class: over-wide -- the stall fires in cases that have no cause for it: an interlock wider than needed, a performance flaw
- Cost: one cycle on every load, store, sc.w or AMO right behind an sc.w or an AMO, and on an atomic right behind a load or store
- Found on: cv32e40x-pma-a
- Status: clarified; to file
- Issue directory: [issues/mem-atomic-serial/](issues/mem-atomic-serial/)

on cv32e40x-pma-a (A_EXT=A), every load, store, sc.w or AMO right behind an sc.w or an AMO retires a cycle later than the rows give (+2 for +1), and every atomic right behind a load or store likewise; an ALU instruction behind an atomic is not delayed, and an atomic's rd reaches its consumer as a load's does (no extra cycle).

**What the documentation says.**  load_store_unit.rst 161-165 (Atomics): the core supports exclusive and atomic transactions with an external adapter that turns the OBI transactions into read-modify-write sequences; atomics.rst 60: AMO data timing 'the same as for non-AMOs'; nothing on their timing against the transactions before and after them, and the cycle table has no atomic row

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
- Status: closed; won't file: documented (pipeline.rst 120); the over-wide case for a write without a read not shown by a run
- Issue directory: [issues/clic-csr-after-implicit-write-stall/](issues/clic-csr-after-implicit-write-stall/)

in CLIC mode a CSR instruction (read or write form, of any CSR: mintthresh, mscratch, mscratchcswl itself) one behind csrrw rd, mscratchcswl, rs1 retires a cycle late; the mscratchcswl access writes mscratch implicitly and the core holds every explicit CSR access in the execute stage while that implicit write is in the write stage, whether or not the access names a register the swap touches.

**What the documentation says.**  pipeline.rst, Hazards, line 120: 'An instruction causing an explicit CSR read in EX while an instruction causing an implicit CSR write is in the WB stage' (the stall is listed); the CLIC chapter of control_status_registers.rst describes mscratchcswl's swap of mscratch and does not say the access makes an implicit CSR write

**What the RTL does.**  csrrw s4, mscratchcswl, s3 then csrrw s5, mintthresh, s2: the second retires 2 cycles after the first (1 behind any other CSR write); the same for csrrw s5, mscratch, s2 and for csrrs s5, mintthresh, x0 (cross clic5 of 21 Oct 2026, files 002 and 003; under bus waits the same, clic6); two back it costs 1

**From the RTL source (read, not measured).**  `rtl/cv32e40x_controller_bypass.sv`, lines 259-266 (`csr_impl_write_in_wb (csr_stall_ex, rule 2)`): read 21 Oct 2026 (ours, not the RTL pass's): 'an explicit CSR read is in EX while any implicit write is in WB (conservative stall)' -- the stall is keyed on any implicit write in WB, not on the CSR the read names; mscratchcswl sets csr_impl_wr for the mscratch swap

### [occupancy-freezes-empty-id](issues/occupancy-freezes-empty-id/): An empty ID stage takes no instruction while a multi-cycle instruction holds EX

- Class: over-wide -- the stall fires in cases that have no cause for it: an interlock wider than needed, a performance flaw
- Cost: one cycle on the instruction behind a divide, remainder or mulh whose instruction word arrives only in the multi-cycle instruction's last cycle in ID or later (an instruction-side wait state before it); nothing on a zero-wait instruction bus, where it is already in ID when the stall begins
- Found on: cv32e40x
- Status: open; to file
- Issue directory: [issues/occupancy-freezes-empty-id/](issues/occupancy-freezes-empty-id/)

when the instruction behind a divide (or a remainder, or mulh) reaches the IF stage only after the divide has entered EX, it is not moved into the empty ID stage during the divide: it waits in IF until EX is free, enters ID then, and retires 2 cycles after the divide instead of the 1 the cycle table gives a single-cycle instruction; the same instruction already in ID when the divide entered EX retires 1 cycle after it.

**What the documentation says.**  pipeline.rst 21 (Execute): 'Multi-cycle instructions will stall this stage until they are complete'; pipeline.rst 30-31: 'The cycle counts assume zero stall on the instruction-side interface and zero stall on the data-side memory interface'; instruction_fetch.rst 6-8: IF 'is able to supply one instruction to the Instruction Decode (ID ) stage per cycle if the external bus interface is able to serve one instruction per cycle'.  The cycle table (Division, Remainder '3 - 35'; Multiplication '4 (mulh, mulhsu, mulhu)') and the Hazards list (pipeline.rst 111-126) say nothing about whether an empty ID takes an instruction from IF while EX is stalled

**What the RTL does.**  the instruction bus granting every fetch one cycle after its request: div a2, a0, a1 at 0x80000140 (a1 = 7) retires 32 cycles after the instruction before it (3 + 29 leading zeros, as the table gives); the word holding c.li t5, 15 (0x80000144) arrives in the div's last cycle in ID; no instruction fetch is issued during the divide and the next is issued as it ends; c.li t5, 15 retires 2 cycles after the div.  In the same run div a2, a0, a1 at 0x80000152 (a1 = 0) has c.li t5, 16 in the same word as its upper half, so it is in ID when the divide begins: it retires 1 cycle after the div; mulh a2, a0, a1 at 0x8000012e with c.li t5, 14 in its second word likewise, 1 cycle.  A second program under an instruction bus with single wait cycles on some grants: lui t3, 0x8 behind div gp, s0, s1 retires 2 cycles after the div in 8 of 48 such pairs and 1 in the other 40; in the one read (div at 0x80000034, 33 cycles) the lui's word (0x80000038) was granted a cycle after its request and arrived in the div's last cycle in ID, and the next fetch was issued only as the divide ended

### [fetch-refused-at-io-window-costs-return](issues/fetch-refused-at-io-window-costs-return/): A jump in the last word before an I/O region puts its target's fetch a cycle late

- Class: over-wide -- the stall fires in cases that have no cause for it: an interlock wider than needed, a performance flaw
- Cost: one cycle on a jump in the last word of main memory before an I/O region (measured on jalr; other distances from the region, and branches, not measured); nothing on the same jump 256 bytes below the region
- Found on: cv32e40x-pma
- Status: open; to file
- Issue directory: [issues/fetch-refused-at-io-window-costs-return/](issues/fetch-refused-at-io-window-costs-return/)

jalr zero, 0(ra) in the last word of main memory before an I/O region (at 0x803efffc, the region from 0x803f0000) puts its target's fetch on the instruction bus one cycle after the cycle it is in ID, where the cycle table says the request appears the same cycle, so the instruction at the target retires 3 cycles after the jump instead of the 2 the table gives a jump; the prefetch of the word after it, in the I/O region, is not issued, as the PMA chapter says, and the same jump 256 bytes below the region costs 2.

**What the documentation says.**  pipeline.rst 66-70 (Cycle counts per instruction type, row Jump): 'Jumps are performed in the ID stage' (the row's cycles 2, and its text: the IF stage and the prefetch buffer are flushed and the new PC request appears on the instruction-side interface the same cycle the jump is in ID); pma.rst 38: 'I/O regions are considered to be non-idempotent and therefore the PMA will prevent speculative accesses to such regions.'; instruction_fetch.rst 16-20: the prefetcher 'can fetch up to three words outside of the code region'.  Nothing says that a speculative fetch the PMA prevents delays a following jump

**What the RTL does.**  PMA regions: I/O 0x803f0000-0x803f7fff (main 0), main 0x80000000-0x803fffff; the instruction bus granting every request in its own cycle and answering it the next.  The program writes addi t4, zero, 7 and jalr zero, 0(ra) at 0x803efff8 and 0x803efffc, runs fence.i and jalr ra, 0(gp) to them: jalr ra retires 4 cycles after the fence.i, addi t4 2 after it, jalr zero 1 after that, and addi s1, zero, 1 at the target 0x80000070 3 after the jalr zero.  On the instruction bus: 0x803efff8 requested at cycle 45, 0x803efffc at 46 (answered at 47), no request at 47 or 48 (none at or above 0x803f0000 in the whole run), 0x80000070 at 49.  The same program with the two words at 0x803eff00 and 0x803eff04: 0x803eff04 answered at 47 as well, the prefetch of 0x803eff08 requested at 47, 0x80000070 at 48, and addi s1 retires 2 cycles after the jalr zero; the three retirements before it take 4, 2 and 1 cycles in both runs

### [stale-load-use-check](issues/stale-load-use-check/): An empty ID stage stalls on a load-use hazard with the load's own stale register fields

- Class: over-wide -- the stall fires in cases that have no cause for it: an interlock wider than needed, a performance flaw
- Cost: one cycle on the instruction behind a load whose destination is one of its own source registers (rd = rs1; an AMO or sc.w with rd = rs2) when that instruction's word arrives from the instruction bus only as the load enters EX (an instruction-side wait state before it); nothing on a zero-wait instruction bus, where the follower is already in ID
- Found on: cv32e40x
- Status: open; to file
- Issue directory: [issues/stale-load-use-check/](issues/stale-load-use-check/)

with a load in EX and the ID stage empty, its next instruction waiting to arrive from the instruction bus, the load-use stall fires when the load's destination register equals one of its own source registers (lw x19, 0(x19); an AMO or sc.w with rd = rs2): the arriving instruction waits a cycle in IF and retires 3 cycles after the load instead of 2, whether or not it reads the load's result.  The same load into another register (lw x20, 0(x19)) lets the same instruction in at once, 2 cycles.  Nothing fires when the next instruction is already in ID as the load enters EX.

**What the documentation says.**  pipeline.rst 114-116: 'The |corev| experiences a 1 cycle penalty on the following hazards.' ... 'Load data hazard (in case the instruction immediately following a load uses the result of that load).'; pipeline.rst 30-31: 'The cycle counts assume zero stall on the instruction-side interface and zero stall on the data-side memory interface'.  The Hazards list gives the penalty to an instruction that uses the load's result and nothing else; it says nothing of an empty ID stage or of the register fields a stall is judged on

**What the RTL does.**  a hand-written program under an instruction bus granting every fetch one cycle after its request (every instruction otherwise retiring 2 cycles after the one before, the data bus without waits): lw s3, 0(s3) at 0x80000020 then lui t3, 0x5: the lui retires 3 cycles after the load (order 9, cycle 36 after 33); lw s4, 0(s3) at 0x80000034 then lui t4, 0x9: 2 cycles (order 14, 45 after 43); lw s3, 0(s3) at 0x80000048 then addi s5, s3, 1, the manual's load data hazard: 3 cycles (order 19, 56 after 53), the same cycle from the same check since the addi too is not yet in ID.  The instruction words: the lui's requested at 29, granted 30, answered 31, the load in EX then.  In the generated scheduled suite (hzs-shape-01-zmmul-00, 8 Nov 2026, a waveform of the regression's run read per cycle): lw s3, 0(s3) in EX at RTL cycle 483 with if_id_pipe.instr_valid 0, rf_waddr_ex = rf_raddr_id[0] = x19, rf_re_id[0] 1, load_stall 1, id_ready 0; the lui t3 behind it, its word on the wire that cycle, enters ID at the edge of 485 and retires at 489, 3 cycles after the load; the five pma-a files of the same suite with an AMO or sc.w with rd = rs2 before a scheduled fetch (amoadd.w.aqrl s9, s9, (tp); amoswap.w gp, gp, (tp); sc.w.aq s0, s0, (tp)) show the same cycle, 15 intervals in all

**From the RTL source (read, not measured).**  `rtl/cv32e40x_controller_bypass.sv`, lines 181-187, 216-220 (`load_stall`): 'assign rf_rd_ex_match[i] = (rf_waddr_ex == rf_raddr_id_i[i]) && |rf_raddr_id_i[i] && rf_re_id_i[i];' (181) and 'assign rf_rd_ex_hz[i] = rf_rd_ex_match[i];' (187): the match has no instr_valid term; the stall '((id_ex_pipe_i.lsu_en || id_ex_pipe_i.xif_en) && rf_we_ex && |rf_rd_ex_hz) || // load-use hazard (EX)' (216) sets load_stall (220).  The fields it reads are the IF/ID register's word decoded whether or not it is valid: cv32e40x_id_stage.sv 216 'assign instr = if_id_pipe_i.instr.bus_resp.rdata;', 231-232 rf_raddr_o from instr, cv32e40x_decoder.sv 272 rf_re_o from the decoded word.  load_stall halts ID (cv32e40x_controller_fsm.sv 653) and so lowers id_ready_o (cv32e40x_id_stage.sv 674 'assign id_ready_o = ctrl_fsm_i.kill_id || (ex_ready_i && !ctrl_fsm_i.halt_id && !xif_waiting);'), which holds the IF to ID handover (cv32e40x_if_stage.sv 389 'if (if_valid_o && id_ready_i)')

## For the documentation

### [csr-rows-unnamed](issues/csr-rows-unnamed/): csr-rows-unnamed

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: none observed: the rows name no instruction this core has; an ecall or mret behind a CSR write pays the flush alone
- Found on: cv32e40x
- Status: clarified; to file
- Issue directory: [issues/csr-rows-unnamed/](issues/csr-rows-unnamed/)

the Hazards rows of pipeline.rst 119-126, 'an instruction causing an implicit CSR read in EX' (119) and 'an instruction causing an implicit CSR write' (120) name no instruction; on the RTL an ecall 1 after a CSR write, and a CSR read of mstatus 1 after an mret, cost the flush alone, so neither is the row's instruction; an mret 1 after any CSR instruction is held in ID by another row, line 126's ('an instruction causing an implicit CSR read in ID (mret or table jump) while a CSR access instruction ... is in the EX stage'; controller_bypass.sv 252), measured at 3 cycles (the issue csr-mret-rows-class-based) (a trap or an mret resolves before the next instruction reads).

**What the documentation says.**  pipeline.rst, Hazards: line 119, 'an instruction causing an implicit CSR read in EX while a CSR access instruction or an instruction causing an implicit CSR access is in the WB stage'; line 120, 'an instruction causing an explicit CSR read in EX while an instruction causing an implicit CSR write is in the WB stage'; the note at line 129 defines an implicit read as one 'performed by non-CSR instructions or CSR instructions reading CSR values from another CSR'.  No instruction is named for either row

**What the RTL does.**  an ecall one after a CSR write, and a CSR read of mstatus one after an mret, retire with the flush's cycles alone (an mret one after a CSR instruction is line 126's stall in ID, 3 cycles): neither pair overlaps in EX and WB, so neither is what the rows mean

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

### [jump-behind-divider](issues/jump-behind-divider/): A jal behind a busy divider is taken at once: its cycle hides under the divide

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: a saving: a jump behind a busy divider pays no bubble of its own, one cycle fewer than the table
- Found on: cv32e40x
- Status: clarified; to file
- Issue directory: [issues/jump-behind-divider/](issues/jump-behind-divider/)

a jal, or a jalr that does not read the divider's result, sitting in ID behind a divide or remainder in EX redirects fetch in its first ID cycle, so its target is fetched during the divide and the jump adds no cycle of its own; a jalr that reads the divider's result waits for it (the jalr data hazard) and pays its bubble after the divide.

**What the documentation says.**  pipeline.rst line 21 ('Multi-cycle instructions will stall this stage until they are complete') and the cycle table's Jump row (66-70: 'The new PC request will appear on the instruction-side memory interface the same cycle the jump instruction is in the ID stage') together imply the overlap, but neither says it; a reader adding the Division and Jump rows counts one cycle too many.  One sentence would say it: a jump in ID behind a stalled EX is taken during the stall

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
- Status: closed; won't file: documented (load_store_unit.rst 84-87, 22-23)
- Issue directory: [issues/mem-address-phase/](issues/mem-address-phase/)

the data bus accepts a new request no earlier than the cycle after the previous one was granted: the address phase holds the bus for a cycle, so the next load or store issues its request the cycle after the grant before it, whatever its response has done.

**What the documentation says.**  load_store_unit.rst 'Protocol' (lines 76-95): the memory may grant 'at any time', the response comes 'one or more cycles after', up to two transactions outstanding (74-75); nothing about when the next request may be presented

**What the RTL does.**  with the testbench memory holding grants by a per-request schedule, request k+1 appears on data_req_o in the cycle after request k's grant: Misalign-lw-00 random:0-3 seed 7, k27 requested 388 = k26 granted 387 + 1 while k26's response was still open (390); k24 requested 363 = k23 granted 360... no: k24 waited for the outstanding slot (see mem-response-frees-slot) and then issued 363, k22 and k23 (the two halves of a split) 359 and 360 = grant + 1

**From the RTL source (read, not measured).**  `rtl/cv32e40x_load_store_unit.sv`, lines 194, 512-516 (`trans_valid_q`): 'trans_valid got clocked without trans_ready': the request stays presented until granted; the generation comment: 'Assumes that corresponding response is at least 1 cycle after request'

### [mem-response-frees-slot](issues/mem-response-frees-slot/): A response frees its outstanding slot the cycle after it is on the wire

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle before a third request may issue once two are outstanding: the slot frees the cycle after the response
- Found on: cv32e40x
- Status: closed; won't file: documented (load_store_unit.rst 120-125, the Multiple Outstanding figure)
- Issue directory: [issues/mem-response-frees-slot/](issues/mem-response-frees-slot/)

a response frees its outstanding-transaction slot the cycle after it is on the wire, not in it: with two responses open, the next request issues the cycle after the older response at the earliest.

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

**What the documentation says.**  load_store_unit.rst 93-95: with several granted requests outstanding 'the memory requests will be kept in-order and one data_rvalid_i will be signaled for each of them, in the order they were issued'; the one-per-cycle spacing is the OBI protocol's (one response phase per cycle) and the harness's

**What the RTL does.**  Misalign-lw-00 random:0-3 seed 7: k33 granted 454 with respond 2 -> 456; k34 granted 455 with respond 1 -> due 456, answered 457; a cycle model that gave k34 its response at 456 was a cycle early on the following instruction until it spaced responses as the memory does

### [mem-split-second-half](issues/mem-split-second-half/): A split access requests its second half from WB, the cycle after the first grant

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: a misaligned access pays its second half's grant and response wait from WB, one cycle more than a single access
- Found on: cv32e40x
- Status: closed; won't file: documented (pipeline.rst 48-52)
- Issue directory: [issues/mem-split-second-half/](issues/mem-split-second-half/)

the second transaction of a misaligned (split) access is requested the cycle after the first was granted, while the instruction is already in WB: the split's extra cycle is spent there, and the second half's grant and response delays are paid from there.

**What the documentation says.**  pipeline.rst Load/Store row (48-52): 'For misaligned word transfers and for halfword transfers that cross a word boundary 2 bus transactions are performed using EX and WB stages for 2 cycles each'; load_store_unit.rst 56-64: the lower address first

**What the RTL does.**  Misalign-lw-00 random:0-3 seed 7: lw a3, 1(a1) (order 296) is k22 and k23: requested 359 and 360, granted 359 and 360, answered 362 and 363; the instruction retires at 364 = the second response + 1, and the next instruction's request waits for the slot (mem-response-frees-slot).  With accept on the second half (k40 of the every:4 run: granted 434, one cycle held) the instruction retires one later

**From the RTL source (read, not measured).**  `rtl/cv32e40x_load_store_unit.sv`, lines 453, 400-410 (`lsu_split_0_o / split_q`): 'Output will be valid (valid_1_o) only for the last phase of split access'; rdata_q keeps the first half's data while the second is outstanding

### [mem-late-data-forward](issues/mem-late-data-forward/): A jalr two behind a load waits a cycle, even at zero wait

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle on a jalr two behind the load that writes its rs1
- Found on: cv32e40x
- Status: clarified; to file
- Issue directory: [issues/mem-late-data-forward/](issues/mem-late-data-forward/)

a jalr whose rs1 is written by a load two instructions before it waits one cycle in ID while the load is in WB, at zero wait on the data bus as with a late response; the Hazards list charges a jalr after a load only when the load immediately precedes it.

**What the documentation says.**  pipeline.rst Hazards (114-126): '2 cycle penalty ... Jump register (jalr) data hazard (in case that a jalr depends on the result of an immediately preceding load instruction)' (125); nothing for a load two before the jalr

**What the RTL does.**  at zero wait on the data bus (the test jalr-two-behind-load.S on cv32e40x, 7 Nov 2026): lw x10, 0(x9) (order 8) retires at cycle 24, the independent addi at 25, jalr x0, 0(x10) at 27 and its target at 29; with a jal in the jalr's place (orders 16-19) 34, 35, 36 and 38: the jalr waits one cycle and its target retires one cycle later than the jal's.  controller_bypass.sv 227-231: a jalr is stalled while a load writing its rs1 is in WB, with no term on the response

**From the RTL source (read, not measured).**  `rtl/cv32e40x_wb_stage.sv`, lines 157 (`lsu_valid_o / wb_ready_o`): wb_ready_o follows the LSU's response for a load (line 157) (lsu_ready_i, 'The late (data_rvalid_i based) downstream wb_ready_i signal', ex_stage.sv 469-472): the register-file write and the forwarding path carry the data from that cycle; the stalls are cv32e40x_controller_bypass.sv 217 (load_stall: the load-use hazard in WB during a wait state, !wb_ready_i) and 229 (the jalr path: a load in WB whose rd the jalr reads)

### [mem-wbuf-fence-drain](issues/mem-wbuf-fence-drain/): A fence or fence.tso behind a buffered store waits for the store's response first

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: a fence or fence.tso behind a store the write buffer took waits for the store's response before its own two cycles
- Found on: cv32e40x-pma
- Status: clarified; to file
- Issue directory: [issues/mem-wbuf-fence-drain/](issues/mem-wbuf-fence-drain/)

on a configuration with a bufferable region, a fence or fence.tso behind a store the write buffer absorbed begins its own two cycles in WB only once that store's response is on the wire: the wait and the fence's cycles add, they do not overlap.

**What the documentation says.**  load_store_unit.rst 154-156 ('Transactions in the write buffer must be completed before the' the core 'is able to:', then 'Retire a ``fence`` instruction'), with 90-91 and 152 making completed mean answered; for fence.i, fencei.rst 8-11 says its handshake starts only once earlier stores have fully completed, the write buffer emptied, so fence.i's own sequence follows the completion; for fence and fence.tso nothing says their own cycles follow it.  One sentence would say it

**What the RTL does.**  the scheduled hazard suite on cv32e40x-pma, 9 Oct 2026 (the first run of the configuration under a bus schedule): 9 intervals differ in 4 tests, every one a fence behind a bufferable store with a wait: hzs-occupancy-00 orders 13866 and 17000 (sb accept 3: fence RTL +5, the grant rule +2), hzs-shape-05-01 order 3055 (c.sb respond 4: fence.i +6 against +3), hzs-shape-06-01 order 2305 (c.sw respond 2: fence.i +4 against +3), hzs-shape-17-00 order 796 (sb accept 2: fence.tso +4 against +2); the extra equals rsp - req - 1 of the harness log in every case; with the hold ending the cycle after the response and the occupancy counted from there, all four at 0 differ, and the instruction after the fence (its jump target) retires when the sequence ends

**From the RTL source (read, not measured).**  `rtl/cv32e40x_controller_fsm.sv`, lines 891-893 (`lsu_busy_i`): fence_req_q is set only once the LSU has no outstanding transfer (the RTL question fence_lsu_busy_wait, answered by this finding)

### [mem-pma-split-first-half](issues/mem-pma-split-first-half/): A misaligned load refused on its second half has already read its first

- Class: function -- not a timing finding: a value, a fault or a sequence
- Found on: cv32e40x-pma
- Status: clarified; to file
- Issue directory: [issues/mem-pma-split-first-half/](issues/mem-pma-split-first-half/)

on a configuration with PMA regions, a misaligned load whose first half is in main memory and whose second falls into I/O issues the first read on the bus before the PMA refuses the second, and takes the access fault (code 5) with the second operation, one cycle after a fault on the first; the store row says the same of a store (first store visible), the load row says only 'no state updates'.

**What the documentation says.**  pma.rst 92-94 and the table row 'Misaligned load | 2 | Exception taken, no state updates.' (105-107), with load_store_unit.rst 64 (the lowest address first): the bus read of the first half follows by combining them but is not said, as it is for the store (111); one sentence on the load row would say it

**What the RTL does.**  hzp-pma-00 on cv32e40x-pma, 10 Oct 2026: blocks pma_load_split_hole and pma_store_split_hole (lw / sw at 0x803ffffe, the memory's last two bytes, the hole from 0x80400000): the harness log shows one request each (k6 read 0x803ffffe, k8 write 0x803ffffe of 0x11c, 2 bytes), the RTL trace carries that transaction as the instruction's memory record where Spike's carries none, and the RTL retires each of the two one cycle later (+2) than a fault on the first transaction costs (+1); the misaligned blocks wholly in the hole (lw / sw at 0x80400001) issue nothing and agree at +1

**From the RTL source (read, not measured).**  `rtl/cv32e40x_load_store_unit.sv`, lines 336-342, 479-492 (`split_q / lsu_split_0_o`): the first phase of a split access is issued before the second is checked (split_q at 336-342, lsu_split_0_o at 479-492); the per-phase check is cv32e40x_pma.sv 125-127 (a misaligned or modified access to I/O raises pma_err_o); the MPU (cv32e40x_mpu.sv, pma_err) refuses the second transaction alone

### [mem-wbuf-third-store](issues/mem-wbuf-third-store/): A store the write buffer could take still waits while two transfers are outstanding

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle on a bufferable store when the buffer's transfer holds the last outstanding slot
- Found on: cv32e40x-pma
- Status: clarified; to file
- Issue directory: [issues/mem-wbuf-third-store/](issues/mem-wbuf-third-store/)

on a configuration with a bufferable region, a bufferable store waits in EX while two transactions are outstanding on the data interface, even when the write buffer is empty: a store the buffer has passed on counts against the two-transaction limit until its response, so three stores in a row with a withheld grant make the third wait a cycle.

**What the documentation says.**  load_store_unit.rst 74-75 (up to two outstanding), 148 (the buffer, when not full, lets the core proceed), 152 (gnt and rvalid still signaled for bufferable transfers) and the Multiple Outstanding figure (120-125): together they give the cycle, but no sentence says that a buffered store counts against the limit, so an empty buffer does not let a store through when two are open

**What the RTL does.**  hzs-shape-01-zmmul-00 on cv32e40x-pma, 12 Oct 2026, block 60 (shape s3_mem14_mem25_struct03: mulh, sw accept 1, sw, sb accept 2, lb accept 3, lb): the harness log k71 sw req 2177 gnt 2178 rsp 2179, k72 sw req 2179 gnt 2179 rsp 2180, k73 sb req 2180 gnt 2182 rsp 2183, k74 lb req 2183 gnt 2186 rsp 2187; retirements mulh 2178, sw 2179, sw 2180, sb 2182, lb 2188: the sb takes two cycles where the rule gives one; the memory-kind blocks with a single absorbed store (cp_f3_wbuf absorbed_a2) are at 0 differ, so it is the sequence, not the absorption; traced with the harness's VCD, cycles as the harness log counts them: 2177 the first sw at the filter, its bus-side count 0 and the buffer empty -- taken (count 1); 2178 the first sw granted, the second sw taken by the buffer as it frees (count 2), the first's response given to the core the same cycle; 2179 the sb in EX with the count at 2 (the first sw's response on the wire this cycle, the second sw granted this cycle) -- the filter's ready_o low, the sb held one cycle; 2180 count 1, the buffer empty -- the sb taken, on the bus; 2181 its response given to the core (the oldest open transfer is bufferable), retired 2182; the lb behind it held by the full buffer (2181) and the sb's grant cycle (2182), on the bus 2183, granted 2186, retired 2188 -- the same cycle the rule gave it, so only the sb moves

**From the RTL source (read, not measured).**  `rtl/cv32e40x_lsu_response_filter.sv`, lines 116-117, 158, 165 (`bus_cnt_q, ready_o, resp_valid_o`): the filter sits between the MPU and the write buffer (cv32e40x_load_store_unit.sv 873-899); bus_cnt_q counts a transfer from the buffer taking it (bus_trans_accepted = ready_i && valid_o, ready_i the buffer's ready) to its response (resp_valid_i), so a transfer the buffer holds counts as outstanding; ready_o = ready_i && bus_cnt_q < DEPTH (2) holds the core's next transfer, bufferable or not, while two are open; resp_valid_o = bus_resp_is_bufferable ? core_resp_is_bufferable : resp_valid_i gives a bufferable store its response the cycle after the buffer takes it (outstanding_q and bus_cnt_q are registered) when the oldest open transfer is bufferable -- traced cycle by cycle (the rtl field)

### [mem-atomic-misaligned-cause](issues/mem-atomic-misaligned-cause/): A misaligned atomic raises an access fault (5, 7), not a misaligned one (4, 6)

- Class: function -- not a timing finding: a value, a fault or a sequence
- Found on: cv32e40x-pma-a
- Status: clarified; to file
- Issue directory: [issues/mem-atomic-misaligned-cause/](issues/mem-atomic-misaligned-cause/)

on cv32e40x-pma-a (A_EXT=A), an lr.w, sc.w or amoadd.w whose address is not word-aligned (tdata + 2, main memory) traps with mcause 5 (lr.w) or 7 (sc.w, the AMO): the access faults; the exception table (exceptions_interrupts.rst) says a non-naturally aligned Load-Reserved address raises 'Load address misaligned' (4) and a non-naturally aligned Store-Conditional / AMO address 'Store/AMO address misaligned' (6).  No request goes on the bus; no EXC_CAUSE_*_MISALIGNED is selected anywhere in the RTL.  What the reference raises is unchecked here (the corner catalog declares mcause against the reference's misaligned cause, 6 Nov 2026).

**What the documentation says.**  exceptions_interrupts.rst 30 and 36 (the exception table): code 4 'Load address misaligned' for a 'Non-naturally aligned Load-Reserved address', code 6 'Store/AMO address misaligned' for a 'Non-naturally aligned Store-Conditional / AMO address'; codes 5 and 7 list only the I/O-region and no-atomic-support cases; the note under the table (71-72) repeats that the address misaligned exceptions 4 and 6 are triggered when Load-Reserved, Store-Conditional or AMO instructions use non-naturally aligned addresses and the access is not blocked by a higher-priority PMA access fault.  load_store_unit.rst 56: 'Misaligned transactions (by non-atomics instructions) are supported in hardware for Main memory regions'; pma.rst 60-65 says nothing on alignment

**What the RTL does.**  the probe's run, 13 Oct 2026: lr.w s7, (s5) at tdata + 2 traps with mcause 5, sc.w s10, s6, (s5) and amoadd.w s0, s6, (s5) with mcause 7; mepc the atomic's pc; no data request on the bus for any of the three; the aligned control amoadd.w completes

**From the RTL source (read, not measured).**  `rtl/cv32e40x_controller_fsm.sv`, lines 343, 356-357 (`exception_cause_wb`): an atomic's alignment error reaching WB (align_status_wb_i != ALIGN_OK, from cv32e40x_align_check.sv: the check runs when atop[5] is set, cv32e40x_load_store_unit.sv 833) is an exception whose cause is EXC_CAUSE_STORE_FAULT for ALIGN_WR_ERR and EXC_CAUSE_LOAD_FAULT otherwise; no EXC_CAUSE_*_MISALIGNED is ever selected by that chain

### [nmi-taken-kill](issues/nmi-taken-kill/): A bus error's NMI is taken the cycle after the faulting access retires, every stage killed

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: the NMI handler's first retirement 5 cycles after the carrier's (the faulting load or store); the instruction behind the carrier retires before the handler only when its data request was outstanding when the error was seen, otherwise it is killed and runs again after the handler's mret
- Found on: cv32e40x
- Status: clarified; to file
- Issue directory: [issues/nmi-taken-kill/](issues/nmi-taken-kill/)

a bus error on a load or store is taken as an NMI the cycle after the faulting access retires: every stage is killed and the pc set to the NMI vector; one more load or store retires first when its request was already outstanding (two retirements after the error at most, as the exceptions chapter says), and a pending interrupt is taken after the NMI handler's mret, not before the NMI.

**What the documentation says.**  exceptions_interrupts.rst line 103 ('the instruction that causes the fault is allowed to retire and the associated NMI is taken afterward') and line 105 ('Once the NMI is visible to the core, at most two instructions will retire before the NMI is taken'); pipeline.rst says nothing of an NMI's taking, its kills or what is abandoned

**What the RTL does.**  hze-nmi-00: the carrier retires with the error response, the handler's first retirement (the NMI vector's jump, rvfi_intr) comes 5 cycles later, the instructions behind the carrier abandoned and re-executed after the mret; with a lw or sw right behind the carrier that one retires too (its request was outstanding), the handler then 5 cycles after it; with line 17 pending at the same time the NMI's handler runs first and the interrupt's right after its mret

**From the RTL source (read, not measured).**  `rtl/cv32e40x_controller_fsm.sv`, lines 729-742 (`nmi_allowed`): a pending NMI (nmi_pending_q, set at lines 1214-1230 by a bus error on a data response in WB) that is allowed (lines 562-563: the interrupt's conditions without the blanking, and not the cycle after waking to a debug request or an interrupt) kills IF, ID, EX and WB, sets the pc to PC_TRAP_NMI and saves the cause 1024 (load) or 1025 (store)

### [jvt-write-flush](issues/jvt-write-flush/): jvt write: a flush of the next instruction costing 5 cycles, not the table's 4

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: five cycles on the instruction after every write of jvt (the write itself retires in one), and the interrupt taking blocked for the cycle after the write's retirement
- Found on: cv32e40x
- Status: clarified; to file
- Issue directory: [issues/jvt-write-flush/](issues/jvt-write-flush/)

the cycle-count table gives a CSR access 4 cycles for jvt; on the RTL a write of jvt retires in one cycle and the instructions behind it are flushed and refetched, so the next instruction retires 5 cycles after the write (6 cycles from the instruction before the write to the one after it, where the table's 4 gives 5 in all, counted as the table's fence.i row is: a cost of 5, one more than the table's 4), and an interrupt pending in the cycle after the write's retirement is taken one cycle later than after any other CSR write; the document states neither the flush nor the interrupt's cycle, and a read of jvt costs 1.

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

**What the documentation says.**  pipeline.rst, Hazards (lines 114-126): no row for a load or store behind a write that may enable an interrupt, in either mode; control_status_registers.rst's CLIC section: mie in CLIC mode (the section 'Machine Interrupt Enable Register (mie) - CLIC == 1'): 'Reserved. Hardwired to 0.' with no word on the interlock

**What the RTL does.**  c.lbu, c.lh, c.lhu, c.lw, c.sb, c.sh, c.sw, c.swsp each one behind csrrs x0, mie, rs1: 1 cycle on cv32e40x-clic (own-cv32e40x-clic-00: 8 of 8 blocks) against the 2 the core's statement irq_enable_lsu_d1 gives, measured on cv32e40x (own-cv32e40x-00, 4 Oct 2026)

**From the RTL source (read, not measured).**  `rtl/cv32e40x_cs_registers.sv`, lines 1550-1557 (`csr_irq_enable_write_o`): the clic_irq_en branch (line 1553): csr_irq_enable_write_o is mstatus_we, priv_lvl_we, mintthresh_we or mintstatus_we -- mie_we is in the CLINT branch only; irq_enable_stall (controller_bypass.sv 275-278) holds a load or store in EX for the cycle the writer is in WB

### [clic-mintthresh-write-stall](issues/clic-mintthresh-write-stall/): CLIC: a load or store behind a write of mintthresh waits a cycle

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle on every load or store one behind a write of mintthresh, in CLIC mode
- Found on: cv32e40x-clic
- Status: open; to file
- Issue directory: [issues/clic-mintthresh-write-stall/](issues/clic-mintthresh-write-stall/)

in CLIC mode a load or store one behind a write of mintthresh retires a cycle late: the write may enable an interrupt (it lowers the threshold) and the core holds the load or store in EX while the writer is in the write stage, as it does behind a write of mstatus; the Hazards list has no row for it.  A write through mnxti (csrrsi x0, mnxti, 8) also writes mstatus (mstatus_we, cv32e40x_cs_registers.sv 936-937, one of the four terms of 1553), and a load or store behind it retires 2 cycles after it in one capture (clic-mie-write-no-stall, 6 Nov reading) against 1 in this entry's first measurement; the RTL answers it: mnxti_id_stall (cv32e40x_controller_bypass.sv 170) holds the next instruction in ID while mnxti is in EX, so a load or store behind the mnxti write costs 2 cycles.

**What the documentation says.**  pipeline.rst, Hazards (lines 114-126): no row for a load or store behind a write that may enable an interrupt; control_status_registers.rst's mintthresh section gives no cycle

**What the RTL does.**  c.lbu and c.sb each one behind csrrs x0, mintthresh, rs1: 2 cycles (own-cv32e40x-clic-00: 2 of 2 blocks, RTL +1); c.lh and c.sh each one behind csrrsi x0, mnxti, 8: 2 cycles in the capture clic-mie-write-no-stall (its rtl.rvvi.txt, lines 5186-5187 and 5205-5206; this entry's first measurement had read 1 cycle); the published traces, from the confirming run of the same test, show it on c.lhu a2, 0(a3) one behind csrrs zero, mintthresh, s5 (order 5051: 2 cycles)

**From the RTL source (read, not measured).**  `rtl/cv32e40x_cs_registers.sv`, lines 1550-1557 (`csr_irq_enable_write_o`): the clic_irq_en branch (line 1553): csr_irq_enable_write_o includes mintthresh_we; an mnxti write sets mstatus_we (936-937), which is one of the four terms the branch names; the next instruction behind an mnxti write is held in ID while mnxti is in EX (mnxti_id_stall, cv32e40x_controller_bypass.sv 170), 2 cycles in the capture

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

### jvt-mode-warl-zero-vs-udb-trap: jvt-mode-warl-zero-vs-udb-trap

- Found on: cv32e40x
- Status: closed; no issue directory
- Issue directory: -

jvt.MODE is WARL with the single legal value 0 on this core: a write of 1 to 63 reads back 0 and raises nothing, where the UDB's rule for jvt.MODE (the Zcmt specification's reading) raises an illegal instruction on a non-zero MODE; the specification's text and the core differ on what a reserved MODE write does, and the document states the WARL 0 without naming the specification's alternative.

**What the documentation says.**  control_status_registers.rst, the jvt row: MODE WARL with the legal value 0

**What the RTL does.**  a write of MODE 1 to 63 reads back 0 and raises nothing, where the UDB's rule for jvt.MODE (the Zcmt specification's reading) raises an illegal instruction on a non-zero MODE

### mtvec-mode-2-reserved-keeps-legal: mtvec-mode-2-reserved-keeps-legal

- Found on: cv32e40x
- Status: closed; no issue directory
- Issue directory: -

the privileged specification reserves mtvec.MODE 2 and 3; on this core a write of 2 keeps the legal value (0 or 1) the field held: legal (WARL), but the document states the two modes without saying what a write of a reserved value does.

**What the documentation says.**  control_status_registers.rst, the mtvec row: MODE 0 (direct) or 1 (vectored); nothing on a write of a reserved MODE value

**What the RTL does.**  a write of MODE 2 keeps the legal value (0 or 1) the field held (WARL, legal)

### mstatus-mpp-hardwired-3: mstatus-mpp-hardwired-3

- Found on: cv32e40x
- Status: closed; no issue directory
- Issue directory: -

mstatus.MPP is hardwired to 3 (M only, no U mode), so a write of the reserved value 2 reads back 3: legal (WARL); the document states the hardwiring without saying how a write of a reserved value resolves; recorded so that family G's read-back is read against it.

**What the documentation says.**  control_status_registers.rst, the mstatus row: MPP hardwired to 3 (M only); nothing on how a write of a reserved value resolves

**What the RTL does.**  a write of MPP 2 reads back 3

### [irq-withdrawn-by-mie-clear-one-cycle](issues/irq-withdrawn-by-mie-clear-one-cycle/): A withdrawn interrupt costs the instruction behind the clearing write a cycle

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle on the second instruction behind a csrrci of mstatus.MIE when an enabled interrupt line rises in the data cycle of a store right before the write, and the interrupt itself deferred until MIE is set again; a race one cycle wide, no cost at any other alignment of the line and the write
- Found on: cv32e40x
- Status: clarified; to file
- Issue directory: [issues/irq-withdrawn-by-mie-clear-one-cycle/](issues/irq-withdrawn-by-mie-clear-one-cycle/)

an enabled interrupt line that rises in the data cycle of a store, with a csrrci clearing mstatus.MIE right behind the store, is not taken (MIE is clear before it could be) and costs one cycle on the second instruction after the csrrci, which retires 2 cycles after its predecessor where the cycle table gives 1; the same line rising one cycle later costs nothing, and with the clearing write one instruction further from the store the interrupt is taken before the write; the interrupt chapter gives no timing for a line's recognition against a write that disables it, and names no cycle an instruction pays while an interrupt is pending and not taken.

**What the documentation says.**  exceptions_interrupts.rst line 186 ('To enable any of the irq_i[31:0] interrupts, both the global interrupt enable (MIE) bit in the mstatus CSR and the corresponding individual interrupt enable bit in the mie CSR need to be set') and line 202 ('The irq_i[31:0] interrupt lines are level-sensitive'): nothing on when a rising line is recognized against a write that clears MIE, nor on a cycle an instruction pays while an interrupt is pending and not taken; pipeline.rst's cycle table gives an integer computational instruction 1 cycle (line 41) and a CSR access 1 (line 46), and its Hazards list (lines 114-126) names no hazard behind a write of mstatus

**What the RTL does.**  the reproducer (78 retirements): the line is raised in the cycle of the store's bus request (the testbench's record) and the store retires with its response; the csrrci retires one cycle after the store, the first lui one cycle after the csrrci and the second lui two cycles after the first, with no interrupt taken; the csrrsi that restores MIE twelve instructions later retires at one-cycle spacing and the handler's first retirement (mcause 0x80000011, line 17) comes 5 cycles after it.  In the sweep's file the same block with the line one to eight cycles later (phases 1 to 8) retires every instruction one cycle apart and takes the interrupt after the restoring write; the mie.MSIE form at phase 0, whose csrrc stands two behind the store (an addi supplies its mask), takes the interrupt before the csrrc: the handler's jal 5 cycles after the addi, the mret returning to the csrrc


© 2026 processor-timing-anomalies, Apache License 2.0
