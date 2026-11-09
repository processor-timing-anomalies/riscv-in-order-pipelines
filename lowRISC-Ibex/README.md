# lowRISC Ibex: timing behavior validated versus RTL

<!-- generated: core -->
| | |
|---|---|
| core | Ibex, lowRISC: a configurable in-order RV32 core, 2-stage in its default build and 3-stage with the writeback stage; measured here in four builds (the default, the maxperf build, maxperf with B full and PMP, and that with the instruction cache), each with its own page below |
| RTL | [lowRISC/ibex](https://github.com/lowRISC/ibex) at commit [c0c07085791e4d16a0f2d9a753b2fb79d72e5ffa](https://github.com/lowRISC/ibex/tree/c0c07085791e4d16a0f2d9a753b2fb79d72e5ffa) |
| documentation | the documentation in that repository at that commit (`doc/`), its pipeline details page above all |
| base build | RV32IMC (Zca) with Zicsr, Zifencei and the counters (`RV32E=0 RV32M=RV32MFast RV32B=RV32BNone RV32ZC=RV32Zca BranchTargetALU=0 WritebackStage=0 ICache=0 ICacheECC=0 ICacheScramble=0 BranchPredictor=0 DbgTriggerEn=0 SecureIbex=0 PMPEnable=0 PMPGranularity=0 PMPNumRegions=4 MHPMCounterNum=10 MHPMCounterWidth=40`) |
| the maxperf build with B full, PMP and the instruction cache | RV32IMC (Zca, Zcb, Zcmp) with B full (Zba, Zbb, Zbs, Zbc, Zbkb, Zbkc, Zbkx), PMP (16 regions, Smepmp), the 4 kB two-way instruction cache with ECC, Zicsr, Zifencei and the counters (`RV32E=0 RV32M=RV32MSingleCycle RV32B=RV32BFull RV32ZC=RV32ZcaZcbZcmp BranchTargetALU=1 WritebackStage=1 ICache=1 ICacheECC=1 ICacheScramble=0 BranchPredictor=0 DbgTriggerEn=0 SecureIbex=0 PMPEnable=1 PMPGranularity=0 PMPNumRegions=16 MHPMCounterNum=10 MHPMCounterWidth=40`) |
| the maxperf build | RV32IMC (Zca, Zcb, Zcmp) with Zicsr, Zifencei and the counters (`RV32E=0 RV32M=RV32MSingleCycle RV32B=RV32BNone RV32ZC=RV32ZcaZcbZcmp BranchTargetALU=1 WritebackStage=1 ICache=0 ICacheECC=0 ICacheScramble=0 BranchPredictor=0 DbgTriggerEn=0 SecureIbex=0 PMPEnable=0 PMPGranularity=0 PMPNumRegions=4 MHPMCounterNum=10 MHPMCounterWidth=40`) |
| the maxperf build with B full and PMP | RV32IMC (Zca, Zcb, Zcmp) with B full (Zba, Zbb, Zbs, Zbc, Zbkb, Zbkc, Zbkx), PMP (16 regions, Smepmp), Zicsr, Zifencei and the counters (`RV32E=0 RV32M=RV32MSingleCycle RV32B=RV32BFull RV32ZC=RV32ZcaZcbZcmp BranchTargetALU=1 WritebackStage=1 ICache=0 ICacheECC=0 ICacheScramble=0 BranchPredictor=0 DbgTriggerEn=0 SecureIbex=0 PMPEnable=1 PMPGranularity=0 PMPNumRegions=16 MHPMCounterNum=10 MHPMCounterWidth=40`) |
<!-- end -->

One RTL, two pipelines, four builds.  Ibex's parameters select the pipeline itself, not only the extensions, so the RTL
was built and measured as four builds, each with a timing specification of its own.  The base build is lowRISC's `small`
configuration: two stages, instruction fetch and a combined decode-execute stage, with the register file read and written
in that one stage, a prefetch buffer in front of it, the fast multiplier (3 cycles for `mul`, 4 for `mulh`) and no branch
target ALU.  The maxperf build is lowRISC's `maxperf` configuration: a third stage, writeback, so that a load's data lands
a stage later and the instruction that reads it stalls instead of the load; the branch target ALU, which makes jumps and
taken branches a cycle shorter; the single-cycle multiplier; and Zcb and Zcmp.  The third build adds to maxperf the full
bit-manipulation set and the PMP with sixteen regions and Smepmp (the `maxperf-pmp-bmfull` configuration), and the fourth
adds the 4 kB two-way instruction cache with ECC (`maxperf-pmp-bmfull-icache`), which replaces the prefetch buffer in
front of the fetch stage.  All four carry ten performance counters where lowRISC's named configurations carry none, so
that the counters can be read; the counters do not change the pipeline.

The documentation describes one of the two pipelines.  Its pipeline details page gives a stall table per instruction class
and says that it applies to the two-stage pipeline, the writeback stage's effects being "not yet documented".  So the
specifications differ in kind: the base build's ([timing.md](timing.md)) was written from the manual's statements and each
statement was then checked against the RTL; the maxperf build's ([timing-maxperf.md](timing-maxperf.md)) was written from
the RTL source, every statement graded `read` and cited to a file and lines of the RTL, since no document states it; the
PMP build's ([timing-pmp.md](timing-pmp.md)) and the cache build's ([timing-icache.md](timing-icache.md)) extend the
maxperf specification with what the PMP and the cache add, from the manual's PMP and cache pages and the RTL where those
pages stop.  The anomalies below name the build they were found on.

## What we found

<!-- generated: found -->
**Comparing the RTL against the timing its documentation promises, on the base build, the maxperf build with B full, PMP and the instruction cache, the maxperf build and the maxperf build with B full and PMP, we
found 25 anomalies: 3 in the RTL, 1 on performance, 21 in the documentation.**  19 of them have an issue directory: 19 hold a program that reproduces the anomaly and the two traces of its run.  The other 6 (`mcause-read-only-but-written`, `mtvec-mode-2-reserved-reads-vectored`, `mstatus-mpp-2-reads-machine`, `load-use-hold-unstated`, `multdiv-behind-load-waits-load-use-first`, `unlisted-csrs-read-zero`) have no directory; the findings page states each.

| | |
|---|---|
| RTL, 3 | The RVFI's pc_wdata of an odd jalr target keeps bit 0 under the branch target ALU; A misaligned store the PMP refuses still writes its second half; An unsupported MPP value is kept as User mode, not Machine mode |
| performance, 1 | stalls that fire wider than their cause: a cycle paid in cases that have no reason to pay it |
| documentation, 21 | places where the manual is silent, behind the hardware, or wrong about a stall or a cost |

Everywhere else the core's timing was as predicted.  Our predictions for this core, built from its documentation and
corrected by the issues above, agreed with the RTL on every other instruction:

| | |
|---|---|
| the focused test suites | 8,182 tests (7,502 generated in 10 suites, the RISC-V architecture certification tests and a smoke program), 36,863,577 instruction intervals compared on the base build and the maxperf build with B full, PMP and the instruction cache and the maxperf build and the maxperf build with B full and PMP, 0 disagreeing |
| the benchmarks | 107 programs (CoreMark, Dhrystone, Embench-IoT, Mälardalen, riscv-tests, TACLeBench), 41,100,262 instruction intervals, 0 disagreeing |
| the search beyond the suites | not yet run on this core |
| the documentation's own timing statements | 18 of 18 proved on the RTL (the statement rows of sections 4.2 and 4.3 of the specification of the base build and the maxperf build with B full, PMP and the instruction cache and the maxperf build and the maxperf build with B full and PMP, as its record groups them) |
<!-- end -->

The documentation anomalies are of two kinds, counted in the table above.  Gaps, a cost the manual states without its
count or does not state at all, are the four below and the five of the instruction cache after them.  Rules the manual states that the hardware does not follow as
written came with the PMP and user-mode rounds: the PMP CSRs trap as illegal instructions on a build without PMP where
the manual says they read as zero; the manual's rule that a region may be writable without being readable holds only
while `mseccfg.MML` is clear; and an interrupt in user mode is taken whatever `mstatus.MIE` says, where the manual's
enable rule reads as if it were not.  Each has its issue directory.  A CSR write flushes the pipeline, as the stall table says, but the instruction after it pays two cycles,
not the one its "additional fetch-latency" suggests, and the two exempt CSRs (`mscratch`, `mepc`) are the whole rule.  A
division or remainder with a non-zero divisor takes 37 cycles, the count the decode-execute page gives, where the stall
table's "1 or 37" read under its own rule would make 38.  A trap entry and an `mret` each cost one cycle more than a jump,
the redirect being made in a flush state the cycle after the instruction's own; the manual gives no count for either.  An
interrupt's entry and a `wfi`'s wake have no stated latency; both were measured and are now rows of the specification.
The instruction cache build added five gaps (4 November 2026): after reset and after every `fence.i` the cache walks its
256 sets for 258 cycles, during which no lookup hits and every fetch goes to the bus, where the manual's cycle table gives
the instruction fence as "1 - N" and says nothing of the walk after reset; with the cache disabled the fetch stream is the
cache's own (four fill buffers requesting a line at a time) and not the prefetch buffer's, so disabling the cache does not
restore the uncached build's timing under instruction-side waits; a fill buffer frees the cycle after its last word, so a
lookup that needs it is granted a cycle late; and a misaligned access holds the pipeline until both halves are accepted
and the first half's response is on the wire, longer than the manual's "at least two cycles" under data-side waits.
The two RTL anomalies are a trace-port fault and a memory-write fault.  With the branch target ALU on (the maxperf build),
the RVFI's next-pc value of a `jalr` whose target is odd keeps bit 0, where the fetch clears it; a trace consumer that
compares the next pc sees a mismatch on every such jump.  On the PMP build, a misaligned store whose first half the PMP
refuses still writes its second half to memory before the fault is taken, so the faulting store leaves half its data
behind, where the architecture leaves the word untouched.

## What is in this repository

| path | what it holds |
|---|---|
| [timing.md](timing.md) | our timing specification for the base build (the two-stage pipeline): what the core promises in time, every statement with its source (the manual, the RTL source, or a measurement) and its grade |
| [timing-maxperf.md](timing-maxperf.md) | the same for the maxperf build (the three-stage pipeline): written from the RTL source, every statement cited to its file and lines, the manual having none for it |
| [findings.md](findings.md) | every anomaly we found with the core, on either build: its class, its cost, whom it concerns, its status and the issue directory it points at |
| [issues/](issues/) | one directory per finding that has one: its `README.md` (the issue) and, where a program was captured, the reproducer with its `env/` and `Makefile`, the two traces and `run.json` (the capture's facts, machine-readable); [issues/README.md](issues/README.md) says what each directory holds |

## The numbers

<!-- generated: numbers -->
As of the regression recorded on 9 November 2026, at commit `dfdfcc8` of our tree (the commit that recorded it); the test and interval counts are
summed from the per-test tables of the records of the base build and the maxperf build with B full, PMP and the instruction cache and the maxperf build and the maxperf build with B full and PMP.

| | |
|---|---|
| statements of the documentation, each proved against the RTL | 18 of 18 (the statement rows of sections 4.2 and 4.3 of the specification of the base build and the maxperf build with B full, PMP and the instruction cache and the maxperf build and the maxperf build with B full and PMP, as its record groups them) |
| instruction intervals compared, RTL against the documented timing | 36,863,577 over 10 generated suites, the RISC-V architecture certification tests and a smoke program, 0 disagreeing |
| instruction sequences searched beyond the suites | not yet run on this core |
| anomalies | 25: 15 where the documentation is behind the hardware, 1 where a stall fires wider than its cause, 3 not a timing matter |
| issue directories | 19: 15 for the documentation, 1 on performance, 3 on the RTL |
| injected timing and functional mutation faults the programs catch | not yet run on this core |
| instruction shapes of real programs that the generated suites also exercise | 78.3% of their retirements; the remaining 21.7% are shapes no suite makes yet |
| cycles per instruction over the benchmarks' timed parts | CPI 1.517, IPC 0.659, over 41,100,369 instructions in 107 programs (per suite in the runs table below) |
<!-- end -->

## The runs behind the numbers

<!-- generated: runs -->
| our test suites | tests | passed | skipped | intervals compared | disagreeing |
|---|---:|---:|---:|---:|---:|
| the base build: 10 generated suites, the RISC-V architecture certification tests and a smoke program | 1,492 | 1,409 | 83 | 5,524,138 | 0 |
| the maxperf build with B full, PMP and the instruction cache: 10 generated suites, the RISC-V architecture certification tests and a smoke program | 2,443 | 2,416 | 27 | 11,937,286 | 0 |
| the maxperf build: 10 generated suites, the RISC-V architecture certification tests and a smoke program | 1,797 | 1,721 | 76 | 7,432,699 | 0 |
| the maxperf build with B full and PMP: 10 generated suites, the RISC-V architecture certification tests and a smoke program | 2,450 | 2,422 | 28 | 11,969,454 | 0 |
| **all** | **8,182** | **7,968** | **214** | **36,863,577** | **0** |

A skipped test is one the core cannot run as built (an extension it lacks, a case the generator could not place); it is counted, not hidden.

| benchmark suite | programs | intervals compared | disagreeing | instructions (timed part) | cycles | CPI | IPC |
|---|---:|---:|---:|---:|---:|---:|---:|
| CoreMark | 1 | 313,228 | 0 | 313,229 | 478,213 | 1.527 | 0.655 |
| Dhrystone | 5 | 59,560 | 0 | 59,565 | 101,971 | 1.712 | 0.584 |
| Embench-IoT | 19 | 6,526,916 | 0 | 6,526,935 | 9,797,175 | 1.501 | 0.666 |
| Mälardalen | 33 | 9,092,735 | 0 | 9,092,768 | 14,164,361 | 1.558 | 0.642 |
| riscv-tests | 7 | 1,143,998 | 0 | 1,144,005 | 1,612,676 | 1.410 | 0.709 |
| TACLeBench | 42 | 23,963,825 | 0 | 23,963,867 | 36,214,110 | 1.511 | 0.662 |
| **all** | **107** | **41,100,262** | **0** | **41,100,369** | **62,368,506** | **1.517** | **0.659** |

An interval is the cycles between one retirement and the one before it; every retirement of every run, start-up and check included, is compared against our prediction.  Instructions and cycles are the timed part of each program, between its own two timer marks, on the RTL; CPI is cycles per instruction there, IPC its inverse.
<!-- end -->

## Are we done yet?

What "no timing anomaly left" rests on, in eight parts, each with its state:

<!-- generated: closure -->
| part | state |
|---|---|
| the documented statements, each proved | closed |
| everything generated, compared against the documented timing | closed |
| the RTL's own stall and flush mechanisms, read from its source: each exercised by a test or named unreachable with its reason | closed, except 7 terms not yet exercised (`data_ind_timing_i`, `INSTR_EXPANDED_COMMIT`, `icache_enable_i`, `instr_intg_err`, `irq_nm_int`, `ic_scr_key_valid_i`, `illegal_csr`), each awaiting a feature of ours; the specification's section 10 says which |
| bus timing under a schedule | the scheduled suite: 3,504,118 intervals, 0 disagreeing; the survey does not yet read the schedule |
| state interactions: CSR side effects, modes, reserved forms | open: the search has not run on this core yet |
| real programs' shapes, covered by the suites | 78.3% covered; the rest open |
| detection power: injected timing and functional mutation faults | open: no mutation campaign on this core yet |
| timing conditions in the RTL that the manual says nothing about, each a question answered by reading the source and measuring | 28 questions (6 on the base build, 8 on the maxperf build with B full, PMP and the instruction cache, 9 on the maxperf build, 5 on the maxperf build with B full and PMP); 16 answered and now stated in the specification; 12 open: `data_err_fault`, `fetch_err_trap`, `ebreak_debug_entry`, `debug_req_entry` (the base build); `fetch_ecc_error_refetch` (the maxperf build with B full, PMP and the instruction cache); `data_err_fault`, `fetch_err_trap`, `ebreak_debug_entry`, `debug_req_entry` (the maxperf build); `pmp_fault_lsu_misaligned_first`, `pmp_fault_lsu_misaligned_second`, `pmp_fault_zcmp_uop` (the maxperf build with B full and PMP) |
<!-- end -->

What is not here yet, and is planned: the benchmark programs on the PMP build (they are in the tables above for the
small and the maxperf builds since 30 October 2026); the mutation campaign, which proves the suites see the faults they
claim to see; and the search beyond the suites.  Each appears in the tables above with its first recorded run.  The
PMP build (the maxperf pipeline with physical memory protection and the full bit-manipulation set) is measured since
31 October 2026, in machine mode and, since 1 November, in user mode; the instruction cache build (the PMP build with the
4 kB two-way cache and its ECC) since 4 November 2026, every test run with the cache on; lowRISC's `opentitan`
configuration adds the cache's scrambling and the security features and is the next build to be measured.

## How to read an issue

Every issue directory's `README.md` has these parts, in this order; a part is left out when there is nothing for it (no
sentence of the manual to quote, no measurement beyond the one under Issue, no program captured yet):

| part | what it says |
|---|---|
| the title line and the header | the finding in one sentence; its id, its class, its cost in cycles, the core, the build it was found on |
| Issue | what happens, in the terms of the instructions involved |
| What the documentation says | the sentence of the manual, with its file and line, or that there is none |
| What the RTL does | what was measured, with the program and the cycle counts |
| From the RTL source | the file and lines in the RTL that make it so, read, not measured; present when the source was read |
| To reproduce | the program, the three `make` lines, and the retirements to look at (their order numbers and cycle counts) |
| Trace | the two traces; a `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there |
| Found by | the RTL repository and commit, the tool versions, the capture date |
| Status | to file, filed (with the link), answered, closed |

The classes.  Every stall or flush in a pipeline exists for a reason, its cause: a register read racing the write
that produces it, a counter read racing its update, an interrupt that must be re-evaluated, a resource still held.
The class of an anomaly says how the hardware's trigger compares with that cause, and so whose problem it is:

- **intent**: the stall has a cause and fires exactly when the cause is present; the core behaves as its designers
  meant and only the documentation is behind.  The fix is a sentence in the manual.
- **over-wide**: the stall also fires in cases that have no cause for it, because the hardware checks something
  cruder than the cause (any CSR instead of the two it reads, any counter instead of the one being updated).  Every
  such case pays a cycle for nothing: a performance flaw, measured by control programs that remove the cause and
  still pay.
- **narrower**: the cause is present and nothing stalls, so a value could be read before it is written or a
  side effect missed.  This is a functional risk for the core's developers, not a documentation matter.
- **unexplained**: a stall was measured and no cause has been named for it yet; it stays a question until the RTL
  source or a further program explains it.
- **function**: not a timing finding at all: a wrong value, an unexpected fault, a trace that omits something.
  It is reported to whoever owns the behavior, as an issue in its own right.

A cycle count is the cycles between a retirement and the one before it: the `CYCLE` field of `rtl.rvvi.txt`.

## Running a reproducer, and how the traces were made

You need the RISC-V GNU toolchain (`riscv64-unknown-elf-gcc` and binutils) and Spike (`riscv-isa-sim`).  In an
issue's directory:

    make           build repro.elf with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Each `Makefile` names the `-march` it was built with, the ISA string Spike is given and the memory map, so the same
binary runs anywhere those are honored.  `env/` carries the few lines of start-up and the linker script.  Ibex fetches
its first instruction from the boot address plus `0x80` and keeps its reset vector table at the boot address, so the
programs here start at `0x80000080`, and the linker script places them there.

Ibex differs from a stock Spike in a few conventions, and our reference was configured to the core's: `mtvec` reads
vectored whatever mode bit is written to it; `mcounteren`, `mcause` and `mie` keep only the bits the core implements;
`mstatus` comes out of reset with `MPIE` set; and interrupt line 31 is the core's non-maskable interrupt, taken whatever
the enables say, with its own return path.  A reproducer whose outcome depends on one of these may behave differently on
an unmodified Spike; the published traces are the record of what each engine did.

The reproducer of the interrupt finding raises its interrupts through a test device of ours.  The upstream Spike has no
such device, so that program builds but does not reproduce the event on Spike; its published traces are the evidence,
and the issue says so.  Open an issue on this repository if you need to re-run it.

<!-- generated: tools -->
The RTL traces were captured on the RTL at the commit above, simulated under Verilator 5.020 2024-01-01 rev (Debian 5.020-1); the reference traces on
Spike RISC-V ISA Simulator 1.1.1-dev; the programs built with riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0.  Each issue's `README.md` and `run.json`
repeat the versions of its own capture.
<!-- end -->

Running a program on the RTL yourself is through lowRISC's own simulation environment, which this repository does not
carry.  Our testbench, which is not published, gives the core a memory that answers its request, grant and
response-valid handshakes under a stated schedule, loads the program, ends the test by the same convention Spike uses,
and drives the core's interrupt inputs (software, timer, external, the fifteen fast lines and the non-maskable line)
from the test device.  All traces are RVVI-TEXT 0.5 and pass the official RVVI-TEXT checker.

© 2026 processor-timing-anomalies, Apache License 2.0
