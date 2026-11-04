# Ibex: the anomalies found

This document lists every timing anomaly we found on the Ibex: each place where the core's RTL, measured cycle by cycle, does not do what its documentation says, or does something the documentation does not mention.  An anomaly is found by running a program on the RTL and on our cycle-accurate timing reference simulator and comparing the cycle each instruction retires in with the cycle the documentation predicts; it is kept here once a developer has read the RTL source or the manual and confirmed it.  None of them is a functional bug: the programs compute the right results.  They are cycles the documentation does not account for.

Each anomaly has a **class** (the table below: how the hardware's trigger compares with the cause it exists for), a **cost** in cycles, **whom it concerns** (the RTL's developers, the core's performance, or the documentation), a **status**, and, for most, an **issue directory** under `issues/` with the issue's text and, when a small program reproduces it, that program, the two RVVI traces (the RTL's and the reference's) and the capture's facts; `issues/README.md` says what each directory holds.  The timing specification beside this document (`timing.md`) carries the same anomalies as rows of its section 9, in the context of the rules they break.

Generated from our record on 4 November 2026: 13 anomalies -- 2 in the RTL, 1 on performance, 10 in the documentation.

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
  - [rvfi-jalr-target-bit0-btalu](#rvfi-jalr-target-bit0-btalu-the-rvfis-pc_wdata-of-an-odd-jalr-target-keeps-bit-0-under-the-branch-target-alu): The RVFI's pc_wdata of an odd jalr target keeps bit 0 under the branch target ALU
  - [pmp-misaligned-store-second-half-written](#pmp-misaligned-store-second-half-written-a-misaligned-store-the-pmp-refuses-still-writes-its-second-half): A misaligned store the PMP refuses still writes its second half
- [Performance: a cycle paid without a cause](#performance-a-cycle-paid-without-a-cause)
  - [csr-write-flush-any-csr](#csr-write-flush-any-csr-any-csr-write-but-mscratch-and-mepc-flushes-the-pipeline-harmless-ones-too): Any CSR write but mscratch and mepc flushes the pipeline, harmless ones too
- [For the documentation](#for-the-documentation)
  - [csr-write-flush-two-cycles](#csr-write-flush-two-cycles-a-csr-writes-flush-costs-two-cycles-the-manual-gives-no-count): A CSR write's flush costs two cycles; the manual gives no count
  - [divider-37-cycles](#divider-37-cycles-the-division-rows-1-or-37-counts-cycles-not-the-stalls-its-rule-means): The division row's '1 or 37' counts cycles, not the stalls its rule means
  - [flush-redirect-extra-cycle](#flush-redirect-extra-cycle-a-trap-entry-and-an-mret-cost-a-cycle-more-than-a-jump-no-row-says-so): A trap entry and an mret cost a cycle more than a jump; no row says so
  - [interrupt-and-wake-latency-unstated](#interrupt-and-wake-latency-unstated-no-cycle-count-for-an-interrupts-entry-or-a-wake-from-wfi): No cycle count for an interrupt's entry or a wake from wfi
  - [pmp-fault-two-cycles](#pmp-fault-two-cycles-a-pmp-refused-load-or-store-faults-after-two-cycles-no-bus-request): A PMP-refused load or store faults after two cycles, no bus request
  - [pmp-fault-wb-entry-four-cycles](#pmp-fault-wb-entry-four-cycles-a-writeback-raised-trap-enters-its-handler-a-cycle-after-an-idex-one): A writeback-raised trap enters its handler a cycle after an ID/EX one
  - [pmp-disabled-csrs-illegal](#pmp-disabled-csrs-illegal-with-pmpenable-0-the-pmp-csrs-trap-as-illegal-not-read-as-zero): With PMPEnable 0 the PMP CSRs trap as illegal, not read as zero
  - [pmp-w-without-r-under-mml](#pmp-w-without-r-under-mml-the-manuals-w1-r0-rule-holds-only-while-mseccfgmml-is-clear): The manual's W=1 R=0 rule holds only while mseccfg.MML is clear
  - [interrupts-in-user-whatever-mie](#interrupts-in-user-whatever-mie-in-u-mode-an-interrupt-is-taken-with-mstatusmie-clear-the-manuals-enable-rule-omits-it): In U-mode an interrupt is taken with mstatus.MIE clear; the manual's enable rule omits it
  - [user-mode-costs-as-machine-mode](#user-mode-costs-as-machine-mode-instructions-cost-the-same-cycles-in-u-mode-as-in-m-mode-unstated): Instructions cost the same cycles in U-mode as in M-mode, unstated

## All of them

| anomaly | for | class | cost | found on | status | issue |
|---|---|---|---|---|---|---|
| The RVFI's pc_wdata of an odd jalr target keeps bit 0 under the branch target ALU | rtl | function | none in execution; a trace consumer that trusts rvfi_pc_wdata (a cosimulation comparing the next pc, as ours) sees a mismatch on every odd-target jalr under BranchTargetALU = 1 | ibex-maxperf | open; to file | [issues/rvfi-jalr-target-bit0-btalu/](issues/rvfi-jalr-target-bit0-btalu/) |
| A misaligned store the PMP refuses still writes its second half | rtl | function | none in cycles; a store that faults leaves half its data in memory, which software handling the fault may not expect | ibex-pmp | clarified; to file | [issues/pmp-misaligned-store-second-half-written/](issues/pmp-misaligned-store-second-half-written/) |
| Any CSR write but mscratch and mepc flushes the pipeline, harmless ones too | performance | over-wide | two cycles on every write of a CSR that changes nothing in flight: the counters and their inhibit, the event selectors, mtval, mcause, mcounteren; a trap handler that writes mcause or mtval pays it, and a counter-reading loop that resets a counter | ibex | clarified; to file | [issues/csr-write-flush-any-csr/](issues/csr-write-flush-any-csr/) |
| A CSR write's flush costs two cycles; the manual gives no count | document | intent | two cycles on the instruction after a CSR write (csrrw, csrrs, csrrc and the immediate forms) of any CSR but mscratch and mepc, where the table's wording suggests one | ibex | clarified; to file | [issues/csr-write-flush-two-cycles/](issues/csr-write-flush-two-cycles/) |
| The division row's '1 or 37' counts cycles, not the stalls its rule means | document | intent | none: one cycle on every division and remainder with a non-zero divisor, as a count the two pages disagree on (37 against 38), not a stall the core pays or saves | ibex | clarified; to file | [issues/divider-37-cycles/](issues/divider-37-cycles/) |
| A trap entry and an mret cost a cycle more than a jump; no row says so | document | intent | one cycle more than a jump on every trap entry and every mret, the FLUSH state's own; the document gives no count for either | ibex | clarified; to file | [issues/flush-redirect-extra-cycle/](issues/flush-redirect-extra-cycle/) |
| No cycle count for an interrupt's entry or a wake from wfi | document | intent | an interrupt's entry costs 3 cycles beyond the pipeline's own (DECODE's decision, IRQ_TAKEN, the fetch) plus the vector table's jal; a wfi costs 4 cycles with the line already up; a request withdrawn in the IRQ_TAKEN cycle costs 2 and is dropped; none of it is in the document | ibex | clarified; to file | [issues/interrupt-and-wake-latency-unstated/](issues/interrupt-and-wake-latency-unstated/) |
| A PMP-refused load or store faults after two cycles, no bus request | document | intent | two cycles on every load or store the PMP refuses, before the trap's own entry; a zero-wait memory's permitted access pays one | ibex-pmp | clarified; to file | [issues/pmp-fault-two-cycles/](issues/pmp-fault-two-cycles/) |
| A writeback-raised trap enters its handler a cycle after an ID/EX one | document | intent | one cycle more on the entry of every handler of a load or store fault than of an ID/EX exception | ibex-pmp | clarified; to file | [issues/pmp-fault-wb-entry-four-cycles/](issues/pmp-fault-wb-entry-four-cycles/) |
| With PMPEnable 0 the PMP CSRs trap as illegal, not read as zero | document | intent | none in cycles; an illegal-instruction trap where software expects a zero | ibex | clarified; to file | [issues/pmp-disabled-csrs-illegal/](issues/pmp-disabled-csrs-illegal/) |
| The manual's W=1 R=0 rule holds only while mseccfg.MML is clear | document | intent | none in cycles; a permission reading software would get wrong from the manual under MML | ibex-pmp | clarified; to file | [issues/pmp-w-without-r-under-mml/](issues/pmp-w-without-r-under-mml/) |
| In U-mode an interrupt is taken with mstatus.MIE clear; the manual's enable rule omits it | document | intent | none in cycles; software reading the manual would expect MIE to mask interrupts in U, which it does not | ibex | confirmed; to file | [issues/interrupts-in-user-whatever-mie/](issues/interrupts-in-user-whatever-mie/) |
| Instructions cost the same cycles in U-mode as in M-mode, unstated | document | intent | none; a statement the manual lacks | ibex | confirmed; to file | [issues/user-mode-costs-as-machine-mode/](issues/user-mode-costs-as-machine-mode/) |

## For the RTL's developers

### [rvfi-jalr-target-bit0-btalu](issues/rvfi-jalr-target-bit0-btalu/): The RVFI's pc_wdata of an odd jalr target keeps bit 0 under the branch target ALU

- Class: function -- not a timing finding: a value, a fault or a sequence
- Cost: none in execution; a trace consumer that trusts rvfi_pc_wdata (a cosimulation comparing the next pc, as ours) sees a mismatch on every odd-target jalr under BranchTargetALU = 1
- Found on: ibex-maxperf
- Status: open; to file
- Issue directory: [issues/rvfi-jalr-target-bit0-btalu/](issues/rvfi-jalr-target-bit0-btalu/)

with BranchTargetALU = 1 the RVFI's rvfi_pc_wdata of a jalr (and c.jalr, c.jr) whose rs1 + imm is odd carries bit 0 set: it is the branch target ALU's raw sum, where the fetch clears bit 0 as the ISA requires and the reference model reports the cleared address; the instruction executes correctly, the trace misreports its next pc.  With BranchTargetALU = 0 (the small configuration) the reported target is cleared.

**What the documentation says.**  the RVFI specification: pc_wdata is the pc of the next instruction architecturally; no Ibex page states the branch target ALU's output is reported raw

**What the RTL does.**  act4 I-jalr-00 on ibex-maxperf: 2 of 3,506 retirements differ from Spike in pc_wdata by bit 0, both jalr with an odd rs1 + imm; on ibex (small) 0 differ

**From the RTL source (read, not measured).**  `rtl/ibex_ex_block.sv`, lines 88-95, 103 (`branch_target_o`): with BranchTargetALU the target is bt_alu_result[31:0] = bt_a_operand_i + bt_b_operand_i, raw; without it alu_adder_result_ex_o.  ibex_core.sv 2093: rvfi_stage_pc_wdata <= pc_set ? branch_target_ex : pc_if; ibex_if_stage.sv 289: prefetch_addr = {fetch_addr_n[31:1], 1'b0} clears it for the fetch

### [pmp-misaligned-store-second-half-written](issues/pmp-misaligned-store-second-half-written/): A misaligned store the PMP refuses still writes its second half

- Class: function -- not a timing finding: a value, a fault or a sequence
- Cost: none in cycles; a store that faults leaves half its data in memory, which software handling the fault may not expect
- Found on: ibex-pmp
- Status: clarified; to file
- Issue directory: [issues/pmp-misaligned-store-second-half-written/](issues/pmp-misaligned-store-second-half-written/)

a misaligned store splits into two word-aligned transactions, each checked by the PMP on its own; when the first is refused the LSU goes WAIT_GNT_MIS to WAIT_RVALID_MIS without a transaction and then requests the second half when that half's own check passes, so the store faults (mcause 7) and the memory holds the second half's bytes.  The manual states the bus side of it ('the second part is still issued and its response ignored', for a first part the bus answered with an error); for a PMP refusal the same path writes memory under a faulting store.  Spike faults the whole access and writes nothing, so the two engines differ in memory, visible to the comparison only through a later load of that word.

**What the documentation says.**  load_store_unit.rst, 'Misaligned Accesses': if the first part of a misaligned access receives an error response, the second part is still issued and its response ignored; pmp.rst says nothing of misaligned accesses

**What the RTL does.**  ibex_load_store_unit.sv: the second half's request is gated by its own pmp_err, not the first's

**From the RTL source (read, not measured).**  `rtl/ibex_load_store_unit.sv`, lines 495-530 (`pmp_err_d`): WAIT_GNT_MIS with pmp_err_q: no request, WAIT_RVALID_MIS; there the second half's request goes out (data_req_o with addr_incr_req_o) unless its own check (pmp_err) refuses it; the first half's error is kept in pmp_err_q and the access faults when both halves are done

## Performance: a cycle paid without a cause

### [csr-write-flush-any-csr](issues/csr-write-flush-any-csr/): Any CSR write but mscratch and mepc flushes the pipeline, harmless ones too

- Class: over-wide -- the stall fires in cases that have no cause for it: an interlock wider than needed, a performance flaw
- Cost: two cycles on every write of a CSR that changes nothing in flight: the counters and their inhibit, the event selectors, mtval, mcause, mcounteren; a trap handler that writes mcause or mtval pays it, and a counter-reading loop that resets a counter
- Found on: ibex
- Status: clarified; to file
- Issue directory: [issues/csr-write-flush-any-csr/](issues/csr-write-flush-any-csr/)

a CSR write of any CSR but mscratch and mepc flushes the pipeline, two cycles on the instruction behind it, whatever the CSR: a write of mcycle, minstret, mcountinhibit, mhpmevent3, mtval, mcause or mcounteren costs the same two cycles as a write of mstatus or mtvec, though it changes nothing an instruction already in flight could depend on.  The exemption list is two CSRs; a list of the CSRs whose write must flush would be the smaller set.

**What the documentation says.**  pipeline_details.rst, the pipeline table: a CSR write 'flushes the pipeline, so the instruction immediately following a CSR write incurs an additional fetch-latency' (the count and the CSR set unsaid: the entry csr-write-flush-two-cycles, for the documentation)

**What the RTL does.**  the probe csr-write-flush-any-csr.S on ibex, 1 Nov 2026: one CSR access per block with three independent addi behind it; behind csrrw x0, mscratch the first addi retires 1 cycle after the write; behind csrrw x0 of mcycle, minstret, mcountinhibit, mhpmevent3, mtval, mcause or mcounteren it retires 3 cycles after it, every one; behind csrrs x0, csrrsi 0 and csrrc x0 of mstatus or mie, and a csrr of mscratch, 1 cycle.  Spike and the RTL agree on every compared value; the same on the three-stage builds ibex-maxperf and ibex-pmp, whose generated CSR-write tests pay the same two cycles

**From the RTL source (read, not measured).**  `rtl/ibex_id_stage.sv`, lines 586-593 (`csr_pipe_flush`): csr_pipe_flush is raised for a CSR instruction with a write (csr_op_en_o and CSR_OP_WRITE, SET or CLEAR) of any address but the two of no_flush_csr_addr (mscratch, mepc): the address alone decides, and the controller's special_req_flush_only takes DECODE through FLUSH

## For the documentation

### [csr-write-flush-two-cycles](issues/csr-write-flush-two-cycles/): A CSR write's flush costs two cycles; the manual gives no count

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: two cycles on the instruction after a CSR write (csrrw, csrrs, csrrc and the immediate forms) of any CSR but mscratch and mepc, where the table's wording suggests one
- Found on: ibex
- Status: clarified; to file
- Issue directory: [issues/csr-write-flush-two-cycles/](issues/csr-write-flush-two-cycles/)

the instruction after a CSR write of any CSR but mscratch and mepc retires 3 cycles after it, two more than after a one-cycle instruction: the pipeline table says such a write 'flushes the pipeline, so the instruction immediately following a CSR write incurs an additional fetch-latency' without the count, and the count is two (the flush, then the refetch), not the one that 'a fetch-latency' suggests; it is also every CSR but the two named, the counters and the read-only ones included.

**What the documentation says.**  pipeline_details.rst, the table row 'CSR Access | 0 | ... Note that most CSR writes flush the pipeline, so the instruction immediately following a CSR write incurs an additional fetch-latency.  This is mainly to ensure ePMP updates are taken into account for the next instruction fetch check.  Writes to mscratch and mepc are exempt and do not flush the pipeline'

**What the RTL does.**  a csrrw of mtvec, mie, mcause or mtval, or a csrrs/csrrc/csrrwi/csrrsi/csrrci of them, retires 1 cycle after the instruction before it, and the instruction after it 3 cycles later (its fetch restarted after a one-cycle flush); our model written from the table predicted 2

**From the RTL source (read, not measured).**  `rtl/ibex_id_stage.sv`, lines 586-593 (`csr_pipe_flush`): every CSR write except of mscratch and mepc (no_flush_csr_addr) raises csr_pipe_flush, a special request the controller answers with its FLUSH state (one cycle: IF halted, ID flushed) before DECODE reloads the IF/ID register: two cycles before the next instruction executes

### [divider-37-cycles](issues/divider-37-cycles/): The division row's '1 or 37' counts cycles, not the stalls its rule means

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: none: one cycle on every division and remainder with a non-zero divisor, as a count the two pages disagree on (37 against 38), not a stall the core pays or saves
- Found on: ibex
- Status: clarified; to file
- Issue directory: [issues/divider-37-cycles/](issues/divider-37-cycles/)

a div, divu, rem or remu with a non-zero divisor holds the pipeline 37 cycles; the pipeline table's row 'Division, Remainder: 1 or 37' is a count of cycles, not of the stall cycles its rule 'when an instruction stalls for X cycles X + 1 cycles pass' would make it, while the decode-execute page says 37 cycles outright: the two pages read together give 38, the core takes 37.

**What the documentation says.**  pipeline_details.rst, the table 'Multi- and Single-Cycle Instructions': 'Division / Remainder | 1 or 37 | 1 stall cycle if divide by 0, otherwise full long division', under the rule at line 35, 'when an instruction stalls for X cycles X + 1 cycles pass before a new instruction enters the ID/EX stage'; instruction_decode_execute.rst line 137: 'it takes 37 cycles to compute (though only requires 2 cycles when there is a divide by 0)'

**What the RTL does.**  the instruction behind a div with a non-zero divisor retires 37 cycles after it (380 of 412 such pairs in the add blocks, every mnemonic alike), 2 after a divide by zero; our model written from the table's rule predicted 38

**From the RTL source (read, not measured).**  `rtl/ibex_multdiv_fast.sv`, lines 391-520 (`md_state_q`): the divider's sequence is MD_IDLE, MD_ABS_A, MD_ABS_B, 31 cycles of MD_COMP (the counter from 31 to 1), MD_LAST, MD_CHANGE_SIGN and MD_FINISH: 37 states, 2 for a zero divisor (MD_IDLE to MD_FINISH); the table's 37 is this count

### [flush-redirect-extra-cycle](issues/flush-redirect-extra-cycle/): A trap entry and an mret cost a cycle more than a jump; no row says so

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle more than a jump on every trap entry and every mret, the FLUSH state's own; the document gives no count for either
- Found on: ibex
- Status: clarified; to file
- Issue directory: [issues/flush-redirect-extra-cycle/](issues/flush-redirect-extra-cycle/)

an exception's handler and an mret's return start executing 3 cycles after the trapping instruction or the mret, one cycle later than a jump's target, because the redirect is made in a flush state the cycle after the instruction's own; the documentation gives no cycle count for traps or mret.

**What the documentation says.**  pipeline_details.rst's table has no row for a trap entry or mret; exceptions_interrupts.rst lines 9-13 describe the jump to the vector and the return through mepc without cycles

**What the RTL does.**  an ecall's handler's first instruction retires 4 cycles after the ecall's record and an mret's target 3 cycles after the mret (hz-I-add-zicsr-00, the jal subjects' trap blocks: +4 against our model's +3, six of six); a jump's target follows in 2

**From the RTL source (read, not measured).**  `rtl/ibex_controller.sv`, lines 667-681, 818-836, 955-961 (`special_req`): an exception request or an mret is a special request: DECODE retains ID and enters FLUSH, which sets the pc (the exception vector with csr_save_cause, mepc with csr_restore_mret) and flushes ID; the target is fetched from FLUSH, a cycle after a jump's would be

### [interrupt-and-wake-latency-unstated](issues/interrupt-and-wake-latency-unstated/): No cycle count for an interrupt's entry or a wake from wfi

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: an interrupt's entry costs 3 cycles beyond the pipeline's own (DECODE's decision, IRQ_TAKEN, the fetch) plus the vector table's jal; a wfi costs 4 cycles with the line already up; a request withdrawn in the IRQ_TAKEN cycle costs 2 and is dropped; none of it is in the document
- Found on: ibex
- Status: clarified; to file
- Issue directory: [issues/interrupt-and-wake-latency-unstated/](issues/interrupt-and-wake-latency-unstated/)

the documentation gives no cycle count for an interrupt's entry nor for a wfi's wake, where a core's manual can give both, an entry latency and a wake latency in cycles: on the small configuration the handler's first instruction retires 5 cycles after the instruction that was in ID/EX when the request arrived (its own 2-cycle vector jal included), 6 after a flushing CSR write, and a wfi costs the instruction behind it 4 cycles when the line is already up (FLUSH, WAIT_SLEEP, SLEEP, FIRST_FETCH), the stream resuming 2 cycles after a later rise.

**What the documentation says.**  exceptions_interrupts.rst describes the vector jump (lines 9-13, 28-62) and the enables without cycles; integration.rst 483-487 describes core_sleep_o without the states or their count; pipeline_details.rst's table has no row for an interrupt or a wfi

**What the RTL does.**  hze-alu_nosrc-00 (29 Oct 2026, the event suite): the SET store's RVFI at 61, the vector table's jal at 66 (+5), on every subject class alike; hze-wfi-00: wfi +1 after the store, the csrrsi behind it +5, the handler's jal +6 after the csrrsi (its flush first); the withdrawn file's koff 1: the next instruction 3 cycles after the store, no handler, Spike alike

**From the RTL source (read, not measured).**  `rtl/ibex_controller.sv`, lines 601-650, 702-724, 728-764 (`handle_irq`): DECODE halts IF while handle_irq and (stall or id_wb_pending) and enters IRQ_TAKEN once ID/EX is empty with no special request; IRQ_TAKEN sets the pc (the prefetch buffer requests in that cycle) and checks handle_irq again; a wfi goes FLUSH, WAIT_SLEEP, SLEEP, and SLEEP leaves to FIRST_FETCH the cycle after irq_pending_i, where the instruction in IF enters ID/EX

### [pmp-fault-two-cycles](issues/pmp-fault-two-cycles/): A PMP-refused load or store faults after two cycles, no bus request

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: two cycles on every load or store the PMP refuses, before the trap's own entry; a zero-wait memory's permitted access pays one
- Found on: ibex-pmp
- Status: clarified; to file
- Issue directory: [issues/pmp-fault-two-cycles/](issues/pmp-fault-two-cycles/)

a load or store whose word-aligned address the PMP denies is held two cycles in the LSU and then faults from the writeback stage, without any bus request: cycle 0 the request is suppressed and pmp_err_q set, cycle 1 the error stands in for the grant, cycle 2 the response with load_err_o / store_err_o.  The manual says the request proceeds 'as if it was granted externally' and the error is 'consumed by the core when the data would have been consumed', which on a zero-wait memory suggests one cycle, the response's; it is two, one more than the memory's own response would have taken.

**What the documentation says.**  pmp.rst, 'PMP Integration': the check gates the LSU's external request; 'the request proceeds as if it was granted externally; the error is consumed by the core when the data would have been consumed'; no cycle count anywhere in the manual

**What the RTL does.**  with memory.pmp.fault_cycles 2 every refused load and store of the four PMP files retires where the RTL does (0 differ); with the memory's one cycle our model was one short on each (the first run of 31 Oct 2026, 01:08: 21 of 21 refused accesses)

**From the RTL source (read, not measured).**  `rtl/ibex_load_store_unit.sv`, lines 436-490, 540-550, 703-709, 762-763 (`pmp_err_q`): IDLE: data_req_o is data_req_out & ~pmp_req_err[PMP_D] (ibex_core.sv 1062), pmp_err_q <= pmp_err; WAIT_GNT: the error counts as the grant (pmp_err_q | data_gnt_i) and the FSM returns to IDLE; the next cycle lsu_resp_valid_o with load_err_o / store_err_o: two cycles from the suppressed request to the error response

### [pmp-fault-wb-entry-four-cycles](issues/pmp-fault-wb-entry-four-cycles/): A writeback-raised trap enters its handler a cycle after an ID/EX one

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle more on the entry of every handler of a load or store fault than of an ID/EX exception
- Found on: ibex-pmp
- Status: clarified; to file
- Issue directory: [issues/pmp-fault-wb-entry-four-cycles/](issues/pmp-fault-wb-entry-four-cycles/)

the handler's first instruction retires 4 cycles after the trap entry of a load or store the PMP refused (the exception raised from WB by exc_req_lsu), where an ecall's or an illegal instruction's handler (raised from ID/EX) retires 3 cycles after its trap entry: the response reaches WB, the controller goes to FLUSH the cycle after, the handler is fetched from it.  The manual names the WB path for load and store errors but gives no cycles for either path.

**What the documentation says.**  exception_interrupts.rst, 'Exceptions': the load and store access faults with their mcause; pipeline_details.rst: no row for a trap's entry; ibex_controller.sv's own comment (276-277): exceptions from the Writeback stage take priority over those from the ID/EX stage

**What the RTL does.**  21 of 21 refused loads and stores of hzpmp-pmp-00 on the first run (31 Oct 2026, 01:08): RTL +4 from the trap entry to the handler's jal, our model's ID/EX rule +3; the one fetch fault of the file (raised at issue in ID/EX) +3 on both

**From the RTL source (read, not measured).**  `rtl/ibex_controller.sv`, lines 276-277, 283-294, 315-322, 819-836 (`exc_req_lsu`): exc_req_lsu = store_err_i | load_err_i, 'from the Writeback stage with no instruction valid': it takes the controller to FLUSH in the cycle after the response, where an ID/EX exception (exc_req_d) does so in the instruction's own cycle; the handler's fetch follows FLUSH in both

### [pmp-disabled-csrs-illegal](issues/pmp-disabled-csrs-illegal/): With PMPEnable 0 the PMP CSRs trap as illegal, not read as zero

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: none in cycles; an illegal-instruction trap where software expects a zero
- Found on: ibex
- Status: clarified; to file
- Issue directory: [issues/pmp-disabled-csrs-illegal/](issues/pmp-disabled-csrs-illegal/)

pmp.rst says that with PMPEnable = 0 'all PMP registers read as zero (regardless of PMP CSR writes)'; the RTL makes every access to pmpcfg0-3, pmpaddr0-15, mseccfg and mseccfgh an illegal instruction on such a build (ibex and ibex-maxperf here).  The two differ for software that probes the registers: a read traps instead of returning 0.

**What the documentation says.**  pmp.rst, line 19: 'If PMPEnable is set to 0, all PMP registers read as zero (regardless of PMP CSR writes)'  The sentence the manual should carry: with PMPEnable = 0 the PMP CSRs are not implemented and any access of them raises an illegal-instruction exception.

**What the RTL does.**  ibex_cs_registers.sv: the PMP CSR addresses are legal only with PMPEnable; without it illegal_csr is set for them

**From the RTL source (read, not measured).**  `rtl/ibex_cs_registers.sv`, lines 501-517, 705-713 (`illegal_csr`): the pmpcfg / pmpaddr / mseccfg cases of the CSR address decode are under `if (PMPEnable)`; the else branch sets illegal_csr for them, and illegal_csr_insn_o raises the illegal instruction exception

### [pmp-w-without-r-under-mml](issues/pmp-w-without-r-under-mml/): The manual's W=1 R=0 rule holds only while mseccfg.MML is clear

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: none in cycles; a permission reading software would get wrong from the manual under MML
- Found on: ibex-pmp
- Status: clarified; to file
- Issue directory: [issues/pmp-w-without-r-under-mml/](issues/pmp-w-without-r-under-mml/)

cs_registers.rst says a pmpcfg byte with W = 1 and R = 0 'will be treated by the core as Read/Write permission = 0'; the RTL stores W = 0 in that case (R stays as written) while MML is clear, and with MML set stores the byte as written, since Smepmp gives W = 1, R = 0 the shared-region meanings (a locked region executable by both modes, an unlocked one readable by U and writable by M).  The sentence is the pre-Smepmp rule and says nothing of MML.

**What the documentation says.**  cs_registers.rst, pmpcfgx: 'W = 1, R = 0 ... will be treated by the core as Read/Write permission = 0'; pmp.rst 'PMP Enhancements': Smepmp always included

**What the RTL does.**  the four PMP files on ibex-pmp, 31 Oct 2026: under MML a region written W = 1, R = 0 reads back as written and decides as a shared region, as the model predicts; under MML clear it reads back W = 0

**From the RTL source (read, not measured).**  `rtl/ibex_cs_registers.sv`, lines 1442 (`pmp_cfg_wdata`): the W bit is kept only with R set or mseccfg.mml set; R is stored as written

### [interrupts-in-user-whatever-mie](issues/interrupts-in-user-whatever-mie/): In U-mode an interrupt is taken with mstatus.MIE clear; the manual's enable rule omits it

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: none in cycles; software reading the manual would expect MIE to mask interrupts in U, which it does not
- Found on: ibex
- Status: confirmed; to file
- Issue directory: [issues/interrupts-in-user-whatever-mie/](issues/interrupts-in-user-whatever-mie/)

exception_interrupts.rst states the enable rule as 'both the global interrupt enable (MIE) bit in the mstatus CSR and the corresponding individual interrupt enable bit in the mie CSR need to be set', with no word on the privilege mode.  The RTL follows the privileged specification: in U-mode an enabled line is taken whatever mstatus.MIE says (irq_enabled = mstatus.MIE | (priv == U)), and MIE only gates M-mode.

**What the documentation says.**  exception_interrupts.rst 47-49 (the enable rule), 23 (M-mode and U-mode supported); cs_registers.rst mstatus (MIE)

**What the RTL does.**  the U-mode event files on the three Ibex builds, 1 Nov 2026: every line raised with MIE clear in U is taken, at the M-mode taking latency

**From the RTL source (read, not measured).**  `rtl/ibex_controller.sv`, lines handle_irq (`irq_enabled`): irq_enabled = csr_mstatus_mie_i | (priv_mode_i == PRIV_LVL_U): the global enable gates M-mode alone

### [user-mode-costs-as-machine-mode](issues/user-mode-costs-as-machine-mode/): Instructions cost the same cycles in U-mode as in M-mode, unstated

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: none; a statement the manual lacks
- Found on: ibex
- Status: confirmed; to file
- Issue directory: [issues/user-mode-costs-as-machine-mode/](issues/user-mode-costs-as-machine-mode/)

pipeline_details.rst gives every instruction's cycles with no word on the privilege mode; nothing says a U-mode stream is timed as an M-mode one.  Measured: it is.  What differs in U is rules, not cycles: which instructions trap (the M-level CSRs, mret, wfi under mstatus.TW, a counter alias gated by mcounteren), the taking of interrupts (whatever MIE), the PMP's judgment of an access.

**What the documentation says.**  pipeline_details.rst (every instruction's cycles, no mode named); cs_registers.rst mstatus MPP, TW, MPRV

**What the RTL does.**  the U-mode event files and the PMP U files on ibex, ibex-maxperf and ibex-pmp, 1 Nov 2026: our model's M-mode rules predict every U retirement

**From the RTL source (read, not measured).**  `rtl/ibex_core.sv`, lines the privilege is a CSR state (ibex_cs_registers.sv priv_lvl_q), no timing path reads it but the PMP's and the controller's irq_enabled (`priv_mode_id_o`): the pipeline's stalls and bubbles take no privilege input


© 2026 processor-timing-anomalies, Apache License 2.0
