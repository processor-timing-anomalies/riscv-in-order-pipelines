# OpenHW CV32E40X: timing behaviour validated versus RTL

<!-- generated: core -->
| | |
|---|---|
| core | CV32E40X, OpenHW Group: a 4-stage in-order RV32 core |
| RTL | [openhwgroup/cv32e40x](https://github.com/openhwgroup/cv32e40x) at commit [d952cd63bc1b4eb58cd893c28ef8283c781e345e](https://github.com/openhwgroup/cv32e40x/tree/d952cd63bc1b4eb58cd893c28ef8283c781e345e) |
| documentation | the user manual in that repository at that commit (`docs/user_manual/`), its pipeline chapter above all |
| base build | RV32IMC with Zba, Zbb, Zbs, Zcb, Zcmt, Zicsr, Zifencei and the counters (`RV32=RV32I A_EXT=A_NONE B_EXT=ZBA_ZBB_ZBS M_EXT=M X_EXT=0 NUM_MHPMCOUNTERS=1`) |
<!-- end -->

The RTL was built and measured in six configurations.  The base build is the one above.  The CLIC build turns on the
core-local interrupt controller mode (`CLIC=1 CLIC_ID_WIDTH=5`), which changes how interrupts are taken and adds the
CLIC CSRs.  The PMA build configures physical memory attributes: a hole past the memory, an I/O window, and
bufferable and non-bufferable regions, so that accesses fault, wait or are buffered as the attributes say.  The PMA
with A build adds the A extension to that (`A_EXT=A`), putting atomic transactions on the bus.  The RV32I build is
the integer base alone, with no M and no B extension (`M_EXT=M_NONE B_EXT=B_NONE`).  The Zbc build adds Zbc to the
base's bit-manipulation set (`B_EXT=ZBA_ZBB_ZBC_ZBS`).  Every issue names the configuration it was found on.


## What we found

<!-- generated: found -->
**Comparing the RTL against the timing its documentation promises, on the base build and the 5 configurations, we
found 30 anomalies: 2 in the RTL, 6 on performance, 22 in the documentation.**  28 of them have an issue directory
with a program that reproduces them; the other 2 were read in the RTL source or seen in a run no small program repeats yet.

| | |
|---|---|
| RTL, 2 | An interrupt entry's CSR writes (mstatus, mepc, mcause) are not reported on RVFI; mcause.minhv stays set after an mret restarts a faulted CLIC pointer fetch successfully |
| performance, 6 | stalls that fire wider than their cause: a cycle paid in cases that have no reason to pay it |
| documentation, 22 | places where the manual is silent, behind the hardware, or wrong about a stall or a cost |

Everywhere else the core's timing was as predicted.  Our predictions for this core, built from its documentation and
corrected by the issues above, agreed with the RTL on every other instruction:

| | |
|---|---|
| the focused test suites | 4,421 tests (4,267 generated in 7 suites, plus the RISC-V architecture certification tests), 8,454,387 instruction intervals compared on the base build, 0 disagreeing |
| the benchmarks | 105 programs (Dhrystone, CoreMark, riscv-tests, Embench-IoT, Mälardalen, TACLeBench), 66,570,521 instruction intervals, 0 disagreeing |
| the search beyond the suites | 463,409 distinct instruction shapes, 0 disagreeing |
| the documentation's own timing statements | 19 of 19 proved on the RTL |
<!-- end -->

## What is in this repository

| path | what it holds |
|---|---|
| [timing.md](timing.md) | our accurate, complete timing specification for the CV32E40X: what the core promises in time, every statement with its source (the manual, the RTL source, or a measurement) and its grade |
| [findings.md](findings.md) | every anomaly we found with the core: its class, its cost, whom it concerns, its status and the issue directory it points at |
| [issues/](issues/) | one directory per finding: its `README.md` (the issue), the reproducer program with its `env/` and `Makefile`, the two traces, `run.json` (the capture's facts, machine-readable) |

## The numbers

<!-- generated: numbers -->
As of the regression recorded on 24 October 2026, our tree at commit `fa369b1`.

| | |
|---|---|
| statements of the documentation, each proved against the RTL | 19 of 19 |
| instruction intervals compared, RTL against the documented timing | 8,454,387 over 9 suites, 0 disagreeing |
| instruction sequences searched beyond the suites | 463,409 distinct shapes, 0 disagreeing |
| anomalies | 30: 20 where the documentation is behind the hardware, 6 where a stall fires wider than its cause, 4 not a timing matter |
| issue directories | 28: 21 for the documentation, 6 on performance, 1 on the RTL |
| injected timing and functional mutation faults the programs catch | 46 of 49 caught; the 3 survivors equivalent to the original, each explained |
| instruction shapes of real programs that the generated suites also exercise | 97.8% of their retirements; the remaining 2.2% are shapes no suite makes yet |
| cycles per instruction over the benchmarks' timed parts | CPI 1.233, IPC 0.811, over 59,646,454 instructions in 105 programs (per suite in the results page) |
<!-- end -->

## The runs behind the numbers

<!-- generated: runs -->
| our test suites | tests | passed | skipped | intervals compared | disagreeing |
|---|---:|---:|---:|---:|---:|
| the generated suites (7) and the RISC-V architecture certification tests | 4,421 | 2,014 | 2,407 | 8,454,387 | 0 |

A skipped test is one the core cannot run as built (an extension it lacks, a case the generator could not place); it is counted, not hidden.

| benchmark suite | programs | intervals compared | disagreeing | instructions (timed part) | cycles | CPI | IPC |
|---|---:|---:|---:|---:|---:|---:|---:|
| Dhrystone | 1 | 41,941 | 0 | 762 | 1,035 | 1.358 | 0.736 |
| CoreMark | 1 | 333,418 | 0 | 303,752 | 403,470 | 1.328 | 0.753 |
| riscv-tests | 7 | 1,222,232 | 0 | 1,114,729 | 1,293,683 | 1.161 | 0.862 |
| Embench-IoT | 18 | 3,121,053 | 0 | 2,857,345 | 3,725,143 | 1.304 | 0.767 |
| Mälardalen | 32 | 6,374,105 | 0 | 6,010,971 | 7,665,702 | 1.275 | 0.784 |
| TACLeBench | 46 | 55,477,772 | 0 | 49,358,895 | 60,472,824 | 1.225 | 0.816 |
| **all** | **105** | **66,570,521** | **0** | **59,646,454** | **73,561,857** | **1.233** | **0.811** |

An interval is the cycles between one retirement and the one before it; every retirement of every run, start-up and check included, is compared against our prediction.  Instructions and cycles are the timed part of each program, between its own two timer marks, on the RTL; CPI is cycles per instruction there, IPC its inverse.
<!-- end -->

## Are we done yet?

What "no timing anomaly left" rests on, in eight parts, each with its state:

<!-- generated: closure -->
| part | state |
|---|---|
| the documented statements, each proved | closed |
| everything generated, compared against the documented timing | closed |
| the RTL's own stall and flush mechanisms, read from its source: each exercised by a test or named unreachable with its reason | closed, except 3 terms not yet exercised (`sys_wfe_insn`, `wfe_in_wb`, `mintthresh_we`), each awaiting a feature of ours; the specification's section 10 says which |
| bus timing under a schedule | the scheduled suite: 857,223 intervals, 0 disagreeing; the survey does not yet read the schedule |
| state interactions: CSR side effects, modes, reserved forms | 19 crosses of 41,918 blocks on the core and its configurations, 0 disagreeing |
| real programs' shapes, covered by the suites | 97.8% covered; the rest open |
| detection power: injected timing and functional mutation faults | closed (the 3 survivors explained) |
| timing conditions in the RTL that the manual says nothing about, each answered by reading the source and measuring | 31 found; 27 answered and now stated in the specification; 4 open: `fencei_ack_wait`, `tbljmp_behind_mret`, `jalr_after_mnxti_d1`, `clic_ptr_csr_impl_write` |
<!-- end -->

## How to read an issue

Every issue directory's `README.md` has the same parts, in this order:

| part | what it says |
|---|---|
| the title line and the header | the finding in one sentence; its id, its class, its cost in cycles, the core, the configuration it was found on |
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
  It is reported to whoever owns the behaviour, as an issue in its own right.

A cycle count is the cycles between a retirement and the one before it: the `CYCLE` field of `rtl.rvvi.txt`.

## Running a reproducer, and how the traces were made

You need the RISC-V GNU toolchain (`riscv64-unknown-elf-gcc` and binutils) and Spike (`riscv-isa-sim`).  In an
issue's directory:

    make           build repro.elf with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Each `Makefile` names the `-march` it was built with, the ISA string Spike is given and the memory map, so the same
binary runs anywhere those are honoured.  `env/` carries the few lines of start-up and the linker script.

The reproducers of interrupt, NMI and CLIC findings raise the event through a test device of ours.  The upstream Spike has
no such device, so those programs build but do not reproduce the event on Spike; their published traces are the
evidence, and each such issue says so.  Open an issue on this repository if you need to re-run one.

<!-- generated: tools -->
The RTL traces were captured on the RTL at the commit above, simulated under Verilator 5.020 2024-01-01 rev (Debian 5.020-1); the reference traces on
Spike RISC-V ISA Simulator 1.1.1-dev; the programs built with riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0.  Each issue's `README.md` and `run.json`
repeat the versions of its own capture.
<!-- end -->

Running a program on the RTL yourself is through OpenHW's own testbench, which this repository does not carry.  All
traces are RVVI-TEXT 0.5 and pass the official RVVI-TEXT checker.

© 2026 processor-timing-anomalies, Apache License 2.0
