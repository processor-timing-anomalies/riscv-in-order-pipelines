# Ibex: the anomalies found

This document lists every timing anomaly we found on the Ibex: each place where the core's RTL, measured cycle by cycle, does not do what its documentation says, or does something the documentation does not mention.  An anomaly is found by running a program on the RTL and on our cycle-accurate timing reference simulator and comparing the cycle each instruction retires in with the cycle the documentation predicts; it is kept here once a developer has read the RTL source or the manual and confirmed it.  None of them is a functional bug: the programs compute the right results.  They are cycles the documentation does not account for.

Each anomaly has a **class** (the table below: how the hardware's trigger compares with the cause it exists for), a **cost** in cycles, **whom it concerns** (the RTL's developers, the core's performance, or the documentation), a **status**, and, for most, an **issue directory** under `issues/` with the issue's text and, when a small program reproduces it, that program, the two RVVI traces (the RTL's and the reference's) and the capture's facts; `issues/README.md` says what each directory holds.  The timing specification beside this document (`timing.md`) carries the same anomalies as rows of its section 9, in the context of the rules they break.

Generated from our record on 9 November 2026: 25 anomalies -- 3 in the RTL, 1 on performance, 21 in the documentation.

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
  - [mpp-unsupported-reads-user](#mpp-unsupported-reads-user-an-unsupported-mpp-value-is-kept-as-user-mode-not-machine-mode): An unsupported MPP value is kept as User mode, not Machine mode
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
  - [icache-disabled-is-not-the-prefetch-buffer](#icache-disabled-is-not-the-prefetch-buffer-with-the-cache-disabled-the-fetch-stream-is-the-caches-own-not-the-prefetch-buffers): With the cache disabled the fetch stream is the cache's own, not the prefetch buffer's
  - [icache-fence-i-walk-258-cycles](#icache-fence-i-walk-258-cycles-a-fencei-on-the-cached-build-costs-a-258-cycle-walk-of-bus-fetches-the-table-says-1---n): A fence.i on the cached build costs a 258-cycle walk of bus fetches; the table says 1 - N
  - [icache-reset-walk](#icache-reset-walk-the-first-258-cycles-after-reset-are-an-invalidation-walk-every-fetch-a-bus-request): The first 258 cycles after reset are an invalidation walk: every fetch a bus request
  - [icache-fill-buffer-frees-a-cycle-late](#icache-fill-buffer-frees-a-cycle-late-a-fill-buffer-frees-the-cycle-after-its-last-word-so-the-next-lookup-waits-a-cycle): A fill buffer frees the cycle after its last word, so the next lookup waits a cycle
  - [split-access-holds-until-both-halves-accepted](#split-access-holds-until-both-halves-accepted-a-misaligned-access-holds-idex-until-both-halves-are-accepted-and-its-first-response): A misaligned access holds ID/EX until both halves are accepted and its first response
  - [mcause-read-only-but-written](#mcause-read-only-but-written-mcause-read-only-but-written): mcause-read-only-but-written
  - [mtvec-mode-2-reserved-reads-vectored](#mtvec-mode-2-reserved-reads-vectored-mtvec-mode-2-reserved-reads-vectored): mtvec-mode-2-reserved-reads-vectored
  - [mstatus-mpp-2-reads-machine](#mstatus-mpp-2-reads-machine-mstatus-mpp-2-reads-machine): mstatus-mpp-2-reads-machine
  - [load-use-hold-unstated](#load-use-hold-unstated-load-use-hold-unstated): load-use-hold-unstated
  - [multdiv-behind-load-waits-load-use-first](#multdiv-behind-load-waits-load-use-first-multdiv-behind-load-waits-load-use-first): multdiv-behind-load-waits-load-use-first
  - [unlisted-csrs-read-zero](#unlisted-csrs-read-zero-three-implemented-csrs-missing-from-the-csr-table): Three implemented CSRs missing from the CSR table

## All of them

| anomaly | for | class | cost | found on | status | issue |
|---|---|---|---|---|---|---|
| The RVFI's pc_wdata of an odd jalr target keeps bit 0 under the branch target ALU | rtl | function | none in execution; a trace consumer that trusts rvfi_pc_wdata (a cosimulation comparing the next pc, as ours) sees a mismatch on every odd-target jalr under BranchTargetALU = 1 | ibex-maxperf | open; to file | [issues/rvfi-jalr-target-bit0-btalu/](issues/rvfi-jalr-target-bit0-btalu/) |
| A misaligned store the PMP refuses still writes its second half | rtl | function | none in cycles; a store that faults leaves half its data in memory, which software handling the fault may not expect | ibex-pmp | clarified; to file | [issues/pmp-misaligned-store-second-half-written/](issues/pmp-misaligned-store-second-half-written/) |
| An unsupported MPP value is kept as User mode, not Machine mode | rtl | function | no cycles; software that writes an unsupported value to mstatus.MPP and then executes mret would continue in User mode, without access to the machine-mode CSRs, where the manual promises Machine mode (the mret itself not run) | ibex-maxperf | open; to file | [issues/mpp-unsupported-reads-user/](issues/mpp-unsupported-reads-user/) |
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
| With the cache disabled the fetch stream is the cache's own, not the prefetch buffer's | document | intent | under instruction-side wait states, a different cycle on most redirects and sequential fetches than the uncached build's: a user who turns the cache off to get the documented uncached timing does not get it | ibex-icache | confirmed; to file | [issues/icache-disabled-is-not-the-prefetch-buffer/](issues/icache-disabled-is-not-the-prefetch-buffer/) |
| A fence.i on the cached build costs a 258-cycle walk of bus fetches; the table says 1 - N | document | intent | 258 cycles of fetch at the bus's miss cost after every fence.i on a cached build, against the table's '1 - N' | ibex-icache | confirmed; to file | [issues/icache-fence-i-walk-258-cycles/](issues/icache-fence-i-walk-258-cycles/) |
| The first 258 cycles after reset are an invalidation walk: every fetch a bus request | document | intent | 258 cycles at the start of every run at the bus's miss cost; a short program's cycles per instruction on the cached build say more about the walk than the cache (caches-PLAN decision 17) | ibex-icache | confirmed; to file | [issues/icache-reset-walk/](issues/icache-reset-walk/) |
| A fill buffer frees the cycle after its last word, so the next lookup waits a cycle | document | intent | one cycle on a lookup that waits for a buffer to free, under instruction-side wait states | ibex-icache | confirmed; to file | [issues/icache-fill-buffer-frees-a-cycle-late/](issues/icache-fill-buffer-frees-a-cycle-late/) |
| A misaligned access holds ID/EX until both halves are accepted and its first response | document | intent | under data-side wait states, the cycles of the second half's grant and the first half's response, on every misaligned access | ibex-icache | confirmed; to file | [issues/split-access-holds-until-both-halves-accepted/](issues/split-access-holds-until-both-halves-accepted/) |
| mcause-read-only-but-written | document | - | - | ibex | clarified; no issue directory | - |
| mtvec-mode-2-reserved-reads-vectored | document | - | - | ibex | clarified; no issue directory | - |
| mstatus-mpp-2-reads-machine | document | - | - | ibex | closed; no issue directory | - |
| load-use-hold-unstated | document | - | - | ibex-maxperf | clarified; no issue directory | - |
| multdiv-behind-load-waits-load-use-first | document | - | - | ibex-maxperf | clarified; no issue directory | - |
| Three implemented CSRs missing from the CSR table | document | - | - | ibex | clarified; no issue directory | - |

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

### [mpp-unsupported-reads-user](issues/mpp-unsupported-reads-user/): An unsupported MPP value is kept as User mode, not Machine mode

- Class: function -- not a timing finding: a value, a fault or a sequence
- Cost: no cycles; software that writes an unsupported value to mstatus.MPP and then executes mret would continue in User mode, without access to the machine-mode CSRs, where the manual promises Machine mode (the mret itself not run)
- Found on: ibex-maxperf
- Status: open; to file
- Issue directory: [issues/mpp-unsupported-reads-user/](issues/mpp-unsupported-reads-user/)

a write of the reserved value 2 to mstatus.MPP reads back 0 (User mode), where cs_registers.rst says 'Any write to mstatus.MPP of an unsupported value will be interpreted as Machine Mode' and no other part of the manual says otherwise: the core keeps an unsupported MPP value as User mode, the opposite of the manual's sentence, so an mret after such a write would return to User mode where the manual says Machine mode.

**What the documentation says.**  cs_registers.rst 168-169: 'Only Machine Mode and User Mode are supported. Any write to ``mstatus``.MPP of an unsupported value will be interpreted as Machine Mode.'; the CSR table marks mstatus WARL (15) without naming the legal value, and exception_interrupts.rst 25: 'On execution of an MRET instruction, the core will return to the Privilege Mode stored in ``mstatus``.MPP.'

**What the RTL does.**  repro.S on ibex-maxperf, 6 Nov 2026: MPP cleared (csrc mstatus, 0x1800), then csrrs mstatus with 0x1000 (MPP = 2), then csrr mstatus 3 cycles later: mstatus reads 0x00000080, MPP = 0 (User mode), and Spike reads the same; the write itself leaves mstatus 0x00000080 in the trace, and the restoring write of MPP = 3 leaves it 0x00001880

**From the RTL source (read, not measured).**  `rtl/ibex_cs_registers.sv`, lines 781-784 (`mstatus_d.mpp`): '// Convert illegal values to U-mode': if ((mstatus_d.mpp != PRIV_LVL_M) && (mstatus_d.mpp != PRIV_LVL_U)) mstatus_d.mpp = PRIV_LVL_U

## Performance: a cycle paid without a cause

### [csr-write-flush-any-csr](issues/csr-write-flush-any-csr/): Any CSR write but mscratch and mepc flushes the pipeline, harmless ones too

- Class: over-wide -- the stall fires in cases that have no cause for it: an interlock wider than needed, a performance flaw
- Cost: two cycles on every write of a CSR that changes nothing in flight: the counters and their inhibit, the event selectors, mtval, mcause, mcounteren; a trap handler that writes mcause or mtval pays it, and a counter-reading loop that resets a counter
- Found on: ibex
- Status: clarified; to file
- Issue directory: [issues/csr-write-flush-any-csr/](issues/csr-write-flush-any-csr/)

a CSR write of any CSR but mscratch and mepc flushes the pipeline, two cycles on the instruction behind it, whatever the CSR: a write of mcycle, minstret, mcountinhibit, mhpmevent3, mtval, mcause or mcounteren costs the same two cycles as a write of mstatus or mtvec, though it changes nothing an instruction already in flight could depend on.  The exemption list is two CSRs; a list of the CSRs whose write must flush would be the smaller set.

**What the documentation says.**  pipeline_details.rst, the pipeline table's CSR Access cell (46-51): 'Note that most CSR writes flush the pipeline, so the instruction immediately following a CSR write incurs an additional fetch-latency. This is mainly to ensure ePMP updates are taken into account for the next instruction fetch check. Writes to mscratch and mepc are exempt and do not flush the pipeline.' The rule and its stated reason are there; a write that cannot affect a fetch check (the counters, mtval, mcause, mcounteren) pays the flush all the same

**What the RTL does.**  the probe csr-write-flush-any-csr.S on ibex, 1 Nov 2026: one CSR access per block with three independent addi behind it; behind csrrw x0, mscratch the first addi retires 1 cycle after the write; behind csrrw x0 of mcycle, minstret, mcountinhibit, mhpmevent3, mtval, mcause or mcounteren it retires 3 cycles after it, every one; behind csrrs x0, csrrsi 0 and csrrc x0 of mstatus or mie, and a csrr of mscratch, 1 cycle.  Spike and the RTL agree on every compared value; the same on the three-stage builds ibex-maxperf and ibex-pmp, whose generated CSR-write tests pay the same two cycles

**From the RTL source (read, not measured).**  `rtl/ibex_id_stage.sv`, lines 586-593 (`csr_pipe_flush`): csr_pipe_flush is raised for a CSR instruction with a write (csr_op_en_o and CSR_OP_WRITE, SET or CLEAR) of any address but the two of no_flush_csr_addr (mscratch, mepc): the address alone decides, and the controller's special_req_flush_only takes DECODE through FLUSH

## For the documentation

### [csr-write-flush-two-cycles](issues/csr-write-flush-two-cycles/): A CSR write's flush costs two cycles; the manual gives no count

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: two cycles on the instruction after a CSR write (csrrw, csrrs, csrrc and the immediate forms) of any CSR but mscratch and mepc, where the table's wording suggests one
- Found on: ibex
- Status: clarified; to file
- Issue directory: [issues/csr-write-flush-two-cycles/](issues/csr-write-flush-two-cycles/)

the instruction after a CSR write of any CSR but mscratch and mepc retires 3 cycles after it, two more than after a one-cycle instruction: the pipeline table (pipeline_details.rst 46-48) says of such a write 'Note that most CSR *writes* flush the pipeline, so the instruction immediately following a CSR write incurs an additional fetch-latency' without the count, and the count is two (the controller's FLUSH cycle, then the reload of the IF/ID register; no new fetch address is set for a CSR flush, ibex_controller.sv 819-823, 955-971), not the one that 'an additional fetch-latency' suggests; it is also every CSR but the two named, the counters included; a write to a read-only CSR (address bits 11:10 = 11) is an illegal instruction instead (ibex_cs_registers.sv 402).

**What the documentation says.**  pipeline_details.rst, the table row 'CSR Access | 0 | ... Note that most CSR writes flush the pipeline, so the instruction immediately following a CSR write incurs an additional fetch-latency.  This is mainly to ensure ePMP updates are taken into account for the next instruction fetch check.  Writes to mscratch and mepc are exempt and do not flush the pipeline'

**What the RTL does.**  a csrrw of mtvec, mie, mcause or mtval, or a csrrs/csrrc/csrrwi/csrrsi/csrrci of them, retires 1 cycle after the instruction before it, and the instruction after it 3 cycles later (after a one-cycle FLUSH and the IF/ID reload); our model written from the table predicted 2

**From the RTL source (read, not measured).**  `rtl/ibex_id_stage.sv`, lines 586-593 (`csr_pipe_flush`): every CSR write except of mscratch and mepc (no_flush_csr_addr) raises csr_pipe_flush, a special request the controller answers with its FLUSH state (one cycle: IF halted, ID flushed) before DECODE reloads the IF/ID register: two cycles before the next instruction executes

### [divider-37-cycles](issues/divider-37-cycles/): The division row's '1 or 37' counts cycles, not the stalls its rule means

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: none: one cycle on every division and remainder with a non-zero divisor, as a count the two pages disagree on (37 against 38), not a stall the core pays or saves
- Found on: ibex
- Status: clarified; to file
- Issue directory: [issues/divider-37-cycles/](issues/divider-37-cycles/)

a div, divu, rem or remu with a non-zero divisor holds the pipeline 37 cycles; the pipeline table's Division and Remainder rows ('1 or 37') give the 37 as a count of cycles, not of the stall cycles its rule 'when an instruction stalls for X cycles X + 1 cycles pass' would make it (the '1' for a divide by zero does follow the rule: 1 stall cycle, 2 cycles, as the RTL takes), while the decode-execute page says 37 cycles outright: the two pages read together give 38, the core takes 37.

**What the documentation says.**  pipeline_details.rst, the table 'Multi- and Single-Cycle Instructions': the rows 'Division' and 'Remainder' (lines 68-70): cycles '1 or 37', description '1 stall cycle if divide by 0, otherwise full long division.', under the rule at line 35, 'when an instruction stalls for X cycles X + 1 cycles pass before a new instruction enters the ID/EX stage'; instruction_decode_execute.rst line 137: 'it takes 37 cycles to compute (though only requires 2 cycles when there is a divide by 0)'

**What the RTL does.**  the instruction behind a div with a non-zero divisor retires 37 cycles after it (380 of 412 such pairs in the add blocks, every mnemonic alike), 2 after a divide by zero; our model written from the table's rule predicted 38

**From the RTL source (read, not measured).**  `rtl/ibex_multdiv_fast.sv`, lines 391-520 (`md_state_q`): the divider's sequence is MD_IDLE, MD_ABS_A, MD_ABS_B, 31 cycles of MD_COMP (the counter from 31 to 1), MD_LAST, MD_CHANGE_SIGN and MD_FINISH: 37 states, 2 for a zero divisor (MD_IDLE to MD_FINISH); the table's 37 is this count

### [flush-redirect-extra-cycle](issues/flush-redirect-extra-cycle/): A trap entry and an mret cost a cycle more than a jump; no row says so

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle more than a jump on every trap entry and every mret, the FLUSH state's own; the document gives no count for either
- Found on: ibex
- Status: clarified; to file
- Issue directory: [issues/flush-redirect-extra-cycle/](issues/flush-redirect-extra-cycle/)

an exception's handler and an mret's return start executing 3 cycles after the trapping instruction or the mret, one cycle later than a jump's target, because the redirect is made in a flush state the cycle after the instruction's own; the documentation gives no cycle count for traps or mret.

**What the documentation says.**  pipeline_details.rst's table has no row for a trap entry or mret; exception_interrupts.rst lines 9-13 describe the jump to the vector and the return through mepc without cycles

**What the RTL does.**  an ecall's handler's first instruction retires 4 cycles after the ecall's record and an mret's target 3 cycles after the mret (hz-I-add-zicsr-00, the jal subjects' trap blocks: +4 against our model's +3, six of six); a jump's target follows in 2

**From the RTL source (read, not measured).**  `rtl/ibex_controller.sv`, lines 667-681, 818-836, 955-961 (`special_req`): an exception request or an mret is a special request: DECODE retains ID and enters FLUSH, which sets the pc (the exception vector with csr_save_cause, mepc with csr_restore_mret) and flushes ID; the target is fetched from FLUSH, a cycle after a jump's would be

### [interrupt-and-wake-latency-unstated](issues/interrupt-and-wake-latency-unstated/): No cycle count for an interrupt's entry or a wake from wfi

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: an interrupt's entry costs 3 cycles beyond the pipeline's own (DECODE's decision, IRQ_TAKEN, the fetch) plus the vector table's jal; a wfi costs 4 cycles with the line already up; a request withdrawn in the IRQ_TAKEN cycle costs 2 and is dropped; none of it is in the document
- Found on: ibex
- Status: clarified; to file
- Issue directory: [issues/interrupt-and-wake-latency-unstated/](issues/interrupt-and-wake-latency-unstated/)

the documentation gives no cycle count for an interrupt's entry nor for a wfi's wake, where a core's manual can give both, an entry latency and a wake latency in cycles: on the small configuration the handler's first instruction retires 5 cycles after the instruction that was in ID/EX when the request arrived (its own 2-cycle vector jal included), 6 after a flushing CSR write, and a wfi costs the instruction behind it 4 cycles when the line is already up (FLUSH, WAIT_SLEEP, SLEEP, FIRST_FETCH), the stream resuming 2 cycles after a later rise.

**What the documentation says.**  exception_interrupts.rst describes the vector jump (lines 9-13, 28-62) and the enables without cycles; integration.rst 483-487 describes core_sleep_o without the states or their count; pipeline_details.rst's table has no row for an interrupt or a wfi

**What the RTL does.**  hze-alu_nosrc-00 (29 Oct 2026, the event suite): the SET store's RVFI at 61, the vector table's jal at 66 (+5), on every subject class alike; hze-wfi-00: wfi +1 after the store, the csrrsi behind it +5, the handler's jal +6 after the csrrsi (its flush first); the withdrawn file's koff 1: the next instruction 3 cycles after the store, no handler, Spike alike

**From the RTL source (read, not measured).**  `rtl/ibex_controller.sv`, lines 601-650, 702-724, 728-764 (`handle_irq`): DECODE halts IF while handle_irq and (stall or id_wb_pending) and enters IRQ_TAKEN once ID/EX is empty with no special request; IRQ_TAKEN sets the pc (the prefetch buffer requests in that cycle) and checks handle_irq again; a wfi goes FLUSH, WAIT_SLEEP, SLEEP, and SLEEP leaves to FIRST_FETCH the cycle after irq_pending_i, where the instruction in IF enters ID/EX

### [pmp-fault-two-cycles](issues/pmp-fault-two-cycles/): A PMP-refused load or store faults after two cycles, no bus request

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: two cycles on every load or store the PMP refuses, before the trap's own entry; a zero-wait memory's permitted access pays one
- Found on: ibex-pmp
- Status: clarified; to file
- Issue directory: [issues/pmp-fault-two-cycles/](issues/pmp-fault-two-cycles/)

a load or store whose word-aligned address the PMP denies is held two cycles in the LSU and then faults from the writeback stage, without any bus request: cycle 0 the request is suppressed and pmp_err_q set, cycle 1 the error stands in for the grant, cycle 2 the response with load_err_o / store_err_o.  The manual says the units 'progress with their request as if it was granted externally' and the error 'is registered and consumed by the core when the data would have been consumed' (pmp.rst 31-32), which on a zero-wait memory suggests one cycle, the response's; it is two, one more than the memory's own response would have taken.

**What the documentation says.**  pmp.rst, 'PMP Integration': the check gates the LSU's external request; (lines 31-32) 'the instruction fetch unit and load-store unit progress with their request as if it was granted externally. The PMP error is registered and consumed by the core when the data would have been consumed.'; no cycle count anywhere in the manual

**What the RTL does.**  with memory.pmp.fault_cycles 2 every refused load and store of the four PMP files retires where the RTL does (0 differ); with the memory's one cycle our model was one short on each (the first run of 31 Oct 2026, 01:08: 21 of 21 refused accesses)

**From the RTL source (read, not measured).**  `rtl/ibex_load_store_unit.sv`, lines 436-490, 540-550, 703-709, 762-763 (`pmp_err_q`): IDLE: data_req_o is data_req_out & ~pmp_req_err[PMP_D] (ibex_core.sv 1062), pmp_err_q <= pmp_err; WAIT_GNT: the error counts as the grant (pmp_err_q | data_gnt_i) and the FSM returns to IDLE; the next cycle lsu_resp_valid_o with load_err_o / store_err_o: two cycles from the suppressed request to the error response

### [pmp-fault-wb-entry-four-cycles](issues/pmp-fault-wb-entry-four-cycles/): A writeback-raised trap enters its handler a cycle after an ID/EX one

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle more on the entry of every handler of a load or store fault than of an ID/EX exception
- Found on: ibex-pmp
- Status: clarified; to file
- Issue directory: [issues/pmp-fault-wb-entry-four-cycles/](issues/pmp-fault-wb-entry-four-cycles/)

the handler's first instruction retires 4 cycles after the trap entry of a load or store the PMP refused (the exception raised from WB by exc_req_lsu), where an ecall's or an illegal instruction's handler (raised from ID/EX) retires 3 cycles after its trap entry: the error response arrives a cycle after the load or store has left ID/EX, the controller goes to FLUSH in the cycle it raises the exception (as it does for an exception raised in ID/EX), and the handler is fetched from it; measured on ibex-pmp, where the branch target ALU makes the vector's jal one cycle.  The manual names neither path (exception_interrupts.rst and load_store_unit.rst say nothing of it, and pipeline_details.rst 28-29 says the writeback stage's effects are not yet documented) and gives no cycles for either; only the RTL's comments name the writeback path.

**What the documentation says.**  exception_interrupts.rst, 'Exceptions': the load and store access faults with their mcause, nothing on the stage that raises them; pipeline_details.rst 28-29: 'The details of its impact are not yet documented here' (the writeback stage); the RTL's comments name the path: ibex_controller.sv 283-284 ('exc_req_lsu which can come from the Writeback stage with no instr_valid_i from the ID stage') and 312-314 (with the writeback stage store/load errors occur on the instruction in writeback and take priority)

**What the RTL does.**  21 of 21 refused loads and stores of hzpmp-pmp-00 on the first run (31 Oct 2026, 01:08): RTL +4 from the trap entry to the handler's jal, our model's ID/EX rule +3; the one fetch fault of the file (raised at issue in ID/EX) +3 on both

**From the RTL source (read, not measured).**  `rtl/ibex_controller.sv`, lines 283-284, 291, 312-314, 679-680, 819-836 (`exc_req_lsu`): exc_req_lsu = store_err_i | load_err_i, 'from the Writeback stage with no instr_valid_i from the ID stage' (283-284): both paths decide FLUSH in the cycle they raise the exception (exc_req_lsu here, exc_req_d for an ID/EX exception); the extra cycle is the error response arriving a cycle after the load or store leaves ID/EX; the handler's fetch follows FLUSH in both

### [pmp-disabled-csrs-illegal](issues/pmp-disabled-csrs-illegal/): With PMPEnable 0 the PMP CSRs trap as illegal, not read as zero

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: none in cycles; an illegal-instruction trap where software expects a zero
- Found on: ibex
- Status: clarified; to file
- Issue directory: [issues/pmp-disabled-csrs-illegal/](issues/pmp-disabled-csrs-illegal/)

pmp.rst 19 says that with PMPEnable zero 'the PMP module is not instantiated and all PMP registers read as zero (regardless of the value of PMPNumRegions)'; the RTL makes every access to pmpcfg0-3 and pmpaddr0-15 an illegal instruction on such a build (ibex and ibex-maxperf here), so software that probes the registers traps instead of reading 0.  For mseccfg and mseccfgh the manual agrees with the RTL (cs_registers.rst 395: any access without PMP traps); the disagreement is the pmpcfg and pmpaddr registers'.

**What the documentation says.**  pmp.rst 19: 'When PMPEnable is zero, the PMP module is not instantiated and all PMP registers read as zero (regardless of the value of PMPNumRegions)'; cs_registers.rst 395: 'Any access to mseccfg or mseccfgh when using an Ibex configuration without PMP (PMPEnable is 0) will trigger an illegal instruction exception'.  The sentence the manual should carry: with PMPEnable = 0 the PMP CSRs are not implemented and any access of them raises an illegal-instruction exception, as it already says for mseccfg

**What the RTL does.**  ibex_cs_registers.sv: the PMP CSR addresses are legal only with PMPEnable; without it illegal_csr is set for them

**From the RTL source (read, not measured).**  `rtl/ibex_cs_registers.sv`, lines 501-517, 705-713 (`illegal_csr`): pmpcfg0-3 and pmpaddr0-15 set illegal_csr when !PMPEnable (705-713, a check after the address case); mseccfg and mseccfgh are decoded under if (PMPEnable) with the else branch illegal (501-519), and illegal_csr_insn_o raises the illegal instruction exception

### [pmp-w-without-r-under-mml](issues/pmp-w-without-r-under-mml/): The manual's W=1 R=0 rule holds only while mseccfg.MML is clear

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: none in cycles; a permission reading software would get wrong from the manual under MML
- Found on: ibex-pmp
- Status: clarified; to file
- Issue directory: [issues/pmp-w-without-r-under-mml/](issues/pmp-w-without-r-under-mml/)

cs_registers.rst says a pmpcfg byte with W = 1 and R = 0 'will be treated by the core as Read/Write permission = 0' (cs_registers.rst 357: 'Note that the combination of Write permission = 1, Read permission = 0 is reserved, and will be treated by the core as Read/Write permission = 0.'); the RTL stores W = 0 in that case (R stays as written) while MML is clear, and with MML set stores the byte as written (except that, with MML set and RLB clear, a write that would add a locked M-mode-executable configuration, a locked W = 1, R = 0 among them, is suppressed outright: is_mml_m_exec_cfg, ibex_cs_registers.sv 164-170, and pmp_cfg_wr_suppress, 1465-1467), since Smepmp gives W = 1, R = 0 the shared-region meanings (a locked region executable by both modes, an unlocked one readable by U and writable by M).  The sentence is the pre-Smepmp rule and says nothing of MML.

**What the documentation says.**  cs_registers.rst, pmpcfgx: line 357, 'Note that the combination of Write permission = 1, Read permission = 0 is reserved, and will be treated by the core as Read/Write permission = 0.'; pmp.rst 'PMP Enhancements' (lines 48-52): Smepmp always included, its configurations named as superseding the old ones ('These new configurations supersede the original ones'), though cs_registers.rst 357 itself names no MML case

**What the RTL does.**  the four PMP files on ibex-pmp, 31 Oct 2026: under MML a region written W = 1, R = 0 reads back as written and decides as a shared region, as the model predicts; under MML clear it reads back W = 0

**From the RTL source (read, not measured).**  `rtl/ibex_cs_registers.sv`, lines 1442 (`pmp_cfg_wdata`): the W bit is kept only with R set or mseccfg.mml set; R is stored as written; with MML set and RLB clear a write of a locked M-mode-executable configuration (a locked W = 1, R = 0 among them) is suppressed (pmp_cfg_wr_suppress, 1465-1467; is_mml_m_exec_cfg, 164-170)

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

### [icache-disabled-is-not-the-prefetch-buffer](issues/icache-disabled-is-not-the-prefetch-buffer/): With the cache disabled the fetch stream is the cache's own, not the prefetch buffer's

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: under instruction-side wait states, a different cycle on most redirects and sequential fetches than the uncached build's: a user who turns the cache off to get the documented uncached timing does not get it
- Found on: ibex-icache
- Status: confirmed; to file
- Issue directory: [issues/icache-disabled-is-not-the-prefetch-buffer/](issues/icache-disabled-is-not-the-prefetch-buffer/)

icache.rst says the cache 'integrates into the CPU by replacing the prefetch buffer' (line 10) and that with icache_enable_i low it 'operates in pass-through mode, where every requested instruction is fetched from memory and no results are cached' (line 24).  It does not say what the fetch timing is in pass-through mode: the request stream stays the cache's own (its fill buffers, and with the enable low a speculative request on every lookup, not only after a branch), so a build with the cache off does not have the prefetch-buffer build's timing under instruction-side wait states; it differs from the first redirect.

**What the documentation says.**  icache.rst 10 ('The I$ integrates into the CPU by replacing the prefetch buffer'), 24 (pass-through mode with icache_enable_i low), 20 (the interface matches the IF stage); ibex_if_stage.sv 299-349: gen_icache or gen_prefetch_buffer, one or the other

**What the RTL does.**  the scheduled suite with the cache off, 4 Nov 2026: 0 differ with the cache's request rules, 175,077 differ with the prefetch buffer's

**From the RTL source (read, not measured).**  `rtl/ibex_icache.sv`, lines 222-231, 248-253, 699-711, 764-782, 805-808, 846, 1033-1036 (`fill_alloc_cnt, fill_ext_req, branch_or_lookup`): the lookup is granted while a buffer is free; the speculative request goes out in the lookup's own cycle unless an older buffer still requests; each buffer requests beat by beat to the line's end; the speculative request depends on the enable: 'Speculative requests are only made for branches, or if the cache is disabled' (709-710: fill_spec_req = (~icache_enable_i | branch_i) & ~|fill_ext_req), and fill_cache_new reads it too (690)

### [icache-fence-i-walk-258-cycles](issues/icache-fence-i-walk-258-cycles/): A fence.i on the cached build costs a 258-cycle walk of bus fetches; the table says 1 - N

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: 258 cycles of fetch at the bus's miss cost after every fence.i on a cached build, against the table's '1 - N'
- Found on: ibex-icache
- Status: confirmed; to file
- Issue directory: [issues/icache-fence-i-walk-258-cycles/](issues/icache-fence-i-walk-258-cycles/)

pipeline_details.rst's cycle table gives the instruction fence as '1 - N' and icache.rst says lookups miss until the invalidation completes, without a count.  The walk writes one set a cycle, 256 sets plus about two, and from the fence.i's own cycle every fetch is a bus request answered at T+2 with nothing allocated; a second fence.i during the walk restarts it.

**What the documentation says.**  pipeline_details.rst 96 (Instruction Fence, 1 - N); icache.rst 26-27, 117-119 (the invalidation, lookups miss until it completes)

**What the RTL does.**  the cache file and the smoke tests with the cache on, 4 Nov 2026, 0 differ

**From the RTL source (read, not measured).**  `rtl/ibex_icache.sv`, lines 1215-1287 (`inval_block_cache, inval_index_q`): the invalidation writes one set per cycle from the fence.i's cycle; lookups cannot hit and nothing allocates while it runs

### [icache-reset-walk](issues/icache-reset-walk/): The first 258 cycles after reset are an invalidation walk: every fetch a bus request

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: 258 cycles at the start of every run at the bus's miss cost; a short program's cycles per instruction on the cached build say more about the walk than the cache (caches-PLAN decision 17)
- Found on: ibex-icache
- Status: confirmed; to file
- Issue directory: [issues/icache-reset-walk/](issues/icache-reset-walk/)

icache.rst says the whole cache is invalidated after reset and that nothing is allocated while the invalidation runs (lines 233-235), but not how long it takes: the walk covers the 256 sets plus about two cycles, so the first 258 cycles of every program fetch through the bus with nothing allocated, cache enabled or not.

**What the documentation says.**  icache.rst 233: 'After reset, and when requested by the core (due to a FENCE.I instruction), the whole cache is invalidated'; 235: 'While the invalidation is in-progress, lookups and instruction fetches can proceed, but nothing will be allocated to the cache'; no cycle count

**What the RTL does.**  the cached build's runs of 4 Nov 2026: the first 258 cycles blocked on every one

**From the RTL source (read, not measured).**  `rtl/ibex_icache.sv`, lines 1215-1287 (`inval_block_cache`): the invalidation state machine runs from reset as it does after icache_inval_i

### [icache-fill-buffer-frees-a-cycle-late](issues/icache-fill-buffer-frees-a-cycle-late/): A fill buffer frees the cycle after its last word, so the next lookup waits a cycle

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: one cycle on a lookup that waits for a buffer to free, under instruction-side wait states
- Found on: ibex-icache
- Status: confirmed; to file
- Issue directory: [issues/icache-fill-buffer-frees-a-cycle-late/](issues/icache-fill-buffer-frees-a-cycle-late/)

a fill buffer's done state is registered: a word arriving or a beat popped in cycle c makes the buffer done in c + 1 and free from c + 2, so a lookup that needs that buffer is granted one cycle later than a buffer freed at once would allow.  icache.rst says a buffer is released once all its actions are complete (171) but not in which cycle.

**What the documentation says.**  icache.rst 158-174 (the fill buffers): line 171 says a buffer is released 'once all required actions are complete', with no cycle

**What the RTL does.**  the VCD of firstTest-imc under FSCHED=all, 4 Nov 2026; the scheduled suite at 0 differ with the rule

**From the RTL source (read, not measured).**  `rtl/ibex_icache.sv`, lines 734-741 (`fill_done, fill_out_done, fill_rvd_done`): fill_done is combinational from registered terms (fill_rvd_cnt_q, fill_out_cnt_q, fill_ram_done_q), so the buffer is busy for the cycle after its last pop or arrival

### [split-access-holds-until-both-halves-accepted](issues/split-access-holds-until-both-halves-accepted/): A misaligned access holds ID/EX until both halves are accepted and its first response

- Class: intent -- the core behaves as it was designed to and the documentation is behind: the stall has a cause and fires only with it
- Cost: under data-side wait states, the cycles of the second half's grant and the first half's response, on every misaligned access
- Found on: ibex-icache
- Status: confirmed; to file
- Issue directory: [issues/split-access-holds-until-both-halves-accepted/](issues/split-access-holds-until-both-halves-accepted/)

load_store_unit.rst says a misaligned access is split into two and needs at least two cycles.  Under a bus schedule that withholds a grant or a response, the hold is longer and has a shape: ID/EX is held until the second half's request is accepted and the first half's response is on the wire (the LSU's WAIT_RVALID_MIS and GNTS_DONE states), so the fixed misaligned occupancy the specification carried is wrong under waits.  On the builds with the writeback stage (ibex-maxperf, ibex-pmp, ibex-icache).  On the two-stage build (ibex) ID/EX is held longer still, until the second half's response (stall_mem, ibex_id_stage.sv 1141-1143; lsu_resp_valid_o only in IDLE, the LSU 709).

**What the documentation says.**  load_store_unit.rst 81-86 (Misaligned Accesses: at least two cycles)

**What the RTL does.**  the scheduled suites of the three Ibex builds on 4 Nov 2026 at 0 differ with the hold

**From the RTL source (read, not measured).**  `rtl/ibex_load_store_unit.sv`, lines 509-538, 553-571 (`ls_fsm_cs, addr_incr_req_o`): the LSU holds the stage through the second half's request and the first half's response (WAIT_RVALID_MIS at 509-538, WAIT_RVALID_MIS_GNTS_DONE at 553-571)

### mcause-read-only-but-written: mcause-read-only-but-written

- Found on: ibex
- Status: clarified; no issue directory
- Issue directory: -

the document contradicts itself on mcause: the CSR table's Access column marks it WLRL (cs_registers.rst 37), while the bit table of the mcause section marks both fields R (274, 277); the core takes a write within 0x8000001f and reads it back (ibex_cs_registers.sv 729-731, 798), as the table's WLRL says.

**What the documentation says.**  cs_registers.rst 37 (the CSR table: mcause, Access WLRL) against 274 and 277 (the mcause section's bit table: Interrupt R, Exception Code R)

**What the RTL does.**  a write of any value within 0x8000001f is taken and read back (every generated test's scratch use of mcause, the pipeline model scratch_csrs, agrees with Spike on the read-back)

### mtvec-mode-2-reserved-reads-vectored: mtvec-mode-2-reserved-reads-vectored

- Found on: ibex
- Status: clarified; no issue directory
- Issue directory: -

the privileged specification reserves mtvec.MODE 2 and 3; on this core MODE is read-only 1 (always vectored), so a write of the reserved value 2 reads back 1 and the write has no effect: legal (WARL), but the document states the read-only MODE without saying what a write of a reserved value does.

**What the documentation says.**  cs_registers.rst, the mtvec row: MODE read-only 1 (vectored); nothing on a write of a reserved MODE value

**What the RTL does.**  a write of MODE 2 reads back 1; the write has no effect (WARL, legal)

### mstatus-mpp-2-reads-machine: mstatus-mpp-2-reads-machine

- Found on: ibex
- Status: closed; no issue directory
- Issue directory: -

a write of the reserved value 2 to mstatus.MPP reads back 3 (M): cs_registers.rst says any write of an unsupported MPP value is interpreted as Machine mode, a legal WARL resolution stated by the document; recorded so that family G's read-back is read against the sentence.

**What the documentation says.**  cs_registers.rst 168-169: 'Only Machine Mode and User Mode are supported. Any write to mstatus.MPP of an unsupported value will be interpreted as Machine Mode'

**What the RTL does.**  a write of MPP 2 reads back 3 (M), as the sentence says

### load-use-hold-unstated: load-use-hold-unstated

- Found on: ibex-maxperf
- Status: clarified; no issue directory
- Issue directory: -

a reader of a load's rd at distance 1 waits one cycle (stall_ld_hz: the load's data arrives from WB the cycle after the reader would read it); pipeline_details.rst gives the load's own cycles (1 - N for the memory) and says nothing of the instruction after it, so the one-cycle hold is in the specification only as an RTL reading (ibex-maxperf/the statements raw_*_load_d1 `stall 1`, grade rtl, from the RTL pass of 29 Oct 2026); every suite measures it (43 rules at limit 1 in the windows of 5 Nov 2026) and the RTL agrees on every interval.  On the builds with the writeback stage only (ibex-maxperf, ibex-pmp, ibex-icache): on the two-stage build there is no load-use cycle (stall_ld_hz tied to 0, ibex_id_stage.sv 1145-1146), and pipeline_details.rst 28-30 limits its table to the two-stage pipeline and says the writeback stage's effects are not yet documented.

**What the documentation says.**  pipeline_details.rst 28-30: 'The details of its impact are not yet documented here. All of the information presented below applies only to the two stage pipeline'; the table's load and multiplier/divider rows give their own cycles only

**What the RTL does.**  a reader of a load's rd at distance 1 retires one cycle later than after a one-cycle producer (stall_ld_hz, rtl/ibex_id_stage.sv 1102-1111): the load-use hold of one cycle, in every suite's measurement

### multdiv-behind-load-waits-load-use-first: multdiv-behind-load-waits-load-use-first

- Found on: ibex-maxperf
- Status: clarified; no issue directory
- Issue directory: -

a multiplier or divider instruction reading a load's rd at distance 1 waits the load-use cycle first and only then starts its sequence (the multdiv start is gated by instr_executing, which the stall clears): a mulh retires 3 cycles after the load and a divide 38, not 2 and 37; the document states the multiplier's and divider's cycles alone and nothing of their start behind a load; the specification carries it as ibex-maxperf/the pipeline model control.occupancy_during_hold `waits` from the loop round of 29 Oct 2026.  On the builds with the writeback stage only (ibex-maxperf, ibex-pmp, ibex-icache): on the two-stage build there is no load-use cycle (stall_ld_hz tied to 0, ibex_id_stage.sv 1145-1146), and pipeline_details.rst 28-30 limits its table to the two-stage pipeline and says the writeback stage's effects are not yet documented.

**What the documentation says.**  pipeline_details.rst 28-30: 'The details of its impact are not yet documented here. All of the information presented below applies only to the two stage pipeline'; the table's load and multiplier/divider rows give their own cycles only

**What the RTL does.**  a mulh or a divide reading a load's rd at distance 1 waits the load-use cycle first and then runs its sequence (the multdiv start is gated by instr_executing, which the stall clears): a mulh retires 3 cycles after the load and a divide 38, not 2 and 37

### unlisted-csrs-read-zero: Three implemented CSRs missing from the CSR table

- Found on: ibex
- Status: clarified; no issue directory
- Issue directory: -

mstatush (0x310), menvcfg (0x30A) and menvcfgh (0x31A) are implemented and read as all zeros, but the CSR table of cs_registers.rst does not list them, and the chapter does not say what an access to a CSR it does not list does: a reader of the document would expect these three accesses to raise an illegal instruction exception, as the chapter states for mseccfg without PMP.

**What the documentation says.**  cs_registers.rst, the CSR table (20 addresses from mstatus 0x300 to mseccfgh 0x757; no mstatush, menvcfg or menvcfgh) and no sentence on an unlisted CSR; the illegal-instruction sentences cover mseccfg and mseccfgh without PMP, the U-mode counters, the RV32I-mode accesses and CHERIoT's mtvec and mepc

**What the RTL does.**  ibex_cs_registers.sv 442-447: CSR_MSTATUSH reads '0 ('mstatush: All zeros for Ibex (fixed little endian and all other bits reserved)'); CSR_MENVCFG and CSR_MENVCFGH read '0 ('menvcfg: machine environment configuration, all zeros for Ibex (none of the relevant features are implemented)'); no exception on the read


© 2026 processor-timing-anomalies, Apache License 2.0
