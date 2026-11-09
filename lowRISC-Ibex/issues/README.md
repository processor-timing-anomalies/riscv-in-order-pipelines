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
| [icache-disabled-is-not-the-prefetch-buffer](icache-disabled-is-not-the-prefetch-buffer/) | documentation | With the cache disabled the fetch stream is the cache's own, not the prefetch buffer's | the issue, the program, the two traces, `run.json` |
| [icache-fence-i-walk-258-cycles](icache-fence-i-walk-258-cycles/) | documentation | A fence.i on the cached build costs a 258-cycle walk of bus fetches; the table says 1 - N | the issue, the program, the two traces, `run.json` |
| [icache-reset-walk](icache-reset-walk/) | documentation | The first 258 cycles after reset are an invalidation walk: every fetch a bus request | the issue, the program, the two traces, `run.json` |
| [icache-fill-buffer-frees-a-cycle-late](icache-fill-buffer-frees-a-cycle-late/) | documentation | A fill buffer frees the cycle after its last word, so the next lookup waits a cycle | the issue, the program, the two traces, `run.json` |
| [split-access-holds-until-both-halves-accepted](split-access-holds-until-both-halves-accepted/) | documentation | A misaligned access holds ID/EX until both halves are accepted and its first response | the issue, the program, the two traces, `run.json` |
| [mpp-unsupported-reads-user](mpp-unsupported-reads-user/) | RTL | An unsupported MPP value is kept as User mode, not Machine mode | the issue, the program, the two traces, `run.json` |

In all, 19 directories: 19 hold a program that reproduces the anomaly and the two traces of its run.  The other 6 (`mcause-read-only-but-written`, `mtvec-mode-2-reserved-reads-vectored`, `mstatus-mpp-2-reads-machine`, `load-use-hold-unstated`, `multdiv-behind-load-waits-load-use-first`, `unlisted-csrs-read-zero`) have no directory; the findings page states each.
<!-- end -->

© 2026 processor-timing-anomalies, Apache License 2.0
