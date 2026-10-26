# RISC-V in-order processors accurate timing behavior - validated versus RTL

A processor's documentation says how long things take: which instruction pairs stall, what a taken branch costs,
when a CSR write flushes the pipeline.  Hidden timing behavior is what the hardware does that the documentation
does not state, understates or states wrongly: a stall with no sentence behind it, an interlock that fires without
its cause, a cost one cycle off the table.  None of it is a functional bug.  All of it is paid by every program
that runs on the core, and none of it can be seen without comparing the RTL, cycle by cycle, against what the
documentation promises.

Most RISC-V processor documentation, when talking about timing, is sadly either inaccurate or woefully missing
detail.  This project addresses that.

This repository provides the results where our research project gives the cores the timing specification they
never had.  AI agents distil the RISC-V ISA, the core's
manual and its RTL into machine-readable layers with every entry cited or graded.  From it our flow generates test
suites the layers imply, runs them on the Verilated RTL and on Spike under a stated bus schedule, predicts every
retirement's cycle, compares, and classifies each disagreement: intended, wider than its cause, or unexplained.
Interrupts are checked the same way, triggered from the harnesses used by both engines; a survey of 54 million
retirements of real programs says what the suites never exercise.

Each disagreement/issue is reproduced by a small program anyone can build and run, and each comes with the two RVVI traces
that show it: the reference and the RTL.  Our research method itself is not here; its results are.

Currently our focus is on in-order RISC-V cores and we have started with open source cores from OpenHW.  The first
core we have looked at is the open source OpenHW CV32E40X: an in-order, 4-stage core, developed within OpenHW by
Silicon Labs and NXP with lock-step verification using [Synopsys ImperasDV](https://www.synopsys.com/verification/imperasdv.html).  An example of its use is in the European
TRISTAN project (https://tristan-project.eu/), where NXP's software-defined radio prototype uses the CV32E40X processor
as the heart of its embedded platform
([Research to reality: how OpenHW Foundation cores are building Europe's open RISC-V](https://blogs.eclipse.org/post/charley-mann/research-reality-how-openhw-foundation-cores-are-building-europes-open-risc-v)).

## The cores

<!-- generated: cores -->
| core | vendor | RTL | findings | issues | recorded |
|---|---|---|---|---|---|
| [CV32E40X](OpenHW-CV32E40X/) | OpenHW Group | [openhwgroup/cv32e40x](https://github.com/openhwgroup/cv32e40x) at [d952cd6](https://github.com/openhwgroup/cv32e40x/tree/d952cd63bc1b4eb58cd893c28ef8283c781e345e) | 30 | 28 | 24 October 2026 |
<!-- end -->

Each core has its own directory, named vendor and core as the vendor writes them, with its results in it:

| path | what it holds |
|---|---|
| `<Vendor-CORE>/README.md` | the core: its ISA and configurations, the RTL commit and the documentation read, the numbers, how its issues read |
| `<Vendor-CORE>/timing.md` | our generated timing specification for the core: what it promises in time, every statement with its source and grade |
| `<Vendor-CORE>/findings.md` | every finding on the core: class, cost, whom it concerns, status, the issue directory |
| `<Vendor-CORE>/issues/<id>/` | one directory per finding: its README (the issue), the reproducer program, the two traces |

## Reproducing a timing issue (the reproducers)

You need the RISC-V GNU toolchain (`riscv64-unknown-elf-gcc` and binutils) and Spike, the RISC-V ISA simulator.
In an issue's directory:

    make           build repro.elf with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

The RTL traces were captured under Verilator at the RTL commit each issue names; running a program on the RTL
yourself is through the vendor's own testbench.  We used the RISC-V Verification Interface (RVVI) text trace format
for every trace ([riscv-verification/RVVI](https://github.com/riscv-verification/RVVI)).  Each core's README has the
detail: the tool versions, the trace format's version, and which reproducers need more than the upstream Spike.

## Getting questions answered

For questions or corrections related to this processor-timing-anomalies project, or if you have a core you would like
us to look at: open an issue on this repository.

## The license

Everything in this repository (the programs, the traces, the documents) is under the Apache License 2.0
(`LICENSE`).  The cores' RTL and documentation are their vendors' under their own licenses and are not here; each
is referenced by repository and commit.

## Citing this repository

GitHub's "Cite this repository" reads `CITATION.cff`.  The forms we ask for:

The repository:

> processor-timing-anomalies. *RISC-V in-order processors accurate timing behavior - validated versus RTL.* 2026. https://github.com/processor-timing-anomalies/riscv-in-order-pipelines (accessed
> DD Month YYYY, commit `xxxxxxx`).

One issue:

> processor-timing-anomalies. "<the issue's title line>." Issue `<id>` in *RISC-V in-order pipelines*, 2026. https://github.com/processor-timing-anomalies/riscv-in-order-pipelines/tree/main/OpenHW-CV32E40X/issues/<id>

One core's timing specification:

> processor-timing-anomalies. *The timing specification of CV32E40X.* In *RISC-V in-order pipelines*, 2026. https://github.com/processor-timing-anomalies/riscv-in-order-pipelines/blob/main/OpenHW-CV32E40X/timing.md

© 2026 processor-timing-anomalies, Apache License 2.0
