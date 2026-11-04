# The issues: one directory per anomaly

Each directory here is one anomaly of the Ibex, named by the anomaly's id as the findings page and the timing
specification cite it.  Every directory holds `README.md`, the issue: what the documentation says, what the RTL does, how
to run it.  Where a program reproduces the anomaly the directory also holds `repro.S` with its `env/` and `Makefile`, the
two RVVI traces of its run (`rtl.rvvi.txt`, `spike.rvvi.txt`) and `run.json`, the facts of the capture; `make` then
`make spike` in such a directory builds and runs the program, and the core's README says what you need installed.  The
table says what each directory holds.

<!-- generated: issues -->
| directory | for | the anomaly | holds |
|---|---|---|---|
| [csr-write-flush-two-cycles](csr-write-flush-two-cycles/) | documentation | A CSR write's flush costs two cycles; the manual gives no count | the issue, the program, the two traces, `run.json` |
| [divider-37-cycles](divider-37-cycles/) | documentation | The division row's '1 or 37' counts cycles, not the stalls its rule means | the issue, the program, the two traces, `run.json` |
| [flush-redirect-extra-cycle](flush-redirect-extra-cycle/) | documentation | A trap entry and an mret cost a cycle more than a jump; no row says so | the issue, the program, the two traces, `run.json` |
| [interrupt-and-wake-latency-unstated](interrupt-and-wake-latency-unstated/) | documentation | No cycle count for an interrupt's entry or a wake from wfi | the issue, the program, the two traces, `run.json` |
| [rvfi-jalr-target-bit0-btalu](rvfi-jalr-target-bit0-btalu/) | RTL | The RVFI's pc_wdata of an odd jalr target keeps bit 0 under the branch target ALU | the issue, the program, the two traces, `run.json` |
| [pmp-fault-two-cycles](pmp-fault-two-cycles/) | documentation | A PMP-refused load or store faults after two cycles, no bus request | the issue, the program, the two traces, `run.json` |
| [pmp-fault-wb-entry-four-cycles](pmp-fault-wb-entry-four-cycles/) | documentation | A writeback-raised trap enters its handler a cycle after an ID/EX one | the issue, the program, the two traces, `run.json` |
| [pmp-misaligned-store-second-half-written](pmp-misaligned-store-second-half-written/) | RTL | A misaligned store the PMP refuses still writes its second half | the issue, the program, the two traces, `run.json` |
| [pmp-disabled-csrs-illegal](pmp-disabled-csrs-illegal/) | documentation | With PMPEnable 0 the PMP CSRs trap as illegal, not read as zero | the issue, the program, the two traces, `run.json` |
| [pmp-w-without-r-under-mml](pmp-w-without-r-under-mml/) | documentation | The manual's W=1 R=0 rule holds only while mseccfg.MML is clear | the issue, the program, the two traces, `run.json` |
| [interrupts-in-user-whatever-mie](interrupts-in-user-whatever-mie/) | documentation | In U-mode an interrupt is taken with mstatus.MIE clear; the manual's enable rule omits it | the issue, the program, the two traces, `run.json` |
| [user-mode-costs-as-machine-mode](user-mode-costs-as-machine-mode/) | documentation | Instructions cost the same cycles in U-mode as in M-mode, unstated | the issue, the program, the two traces, `run.json` |
| [csr-write-flush-any-csr](csr-write-flush-any-csr/) | performance | Any CSR write but mscratch and mepc flushes the pipeline, harmless ones too | the issue, the program, the two traces, `run.json` |

In all, 13 directories: 13 hold a program that reproduces the anomaly and the two traces of its run.
<!-- end -->

© 2026 processor-timing-anomalies, Apache License 2.0
