# The issues: one directory per anomaly

Each directory here is one anomaly of the CV32E40X, named by the anomaly's id as the findings page and the timing
specification cite it.  Every directory holds `README.md`, the issue: what the documentation says, what the RTL does, how
to run it.  Where a program reproduces the anomaly the directory also holds `repro.S` with its `env/` and `Makefile`, the
two RVVI traces of its run (`rtl.rvvi.txt`, `spike.rvvi.txt`) and `run.json`, the facts of the capture; `make` then
`make spike` in such a directory builds and runs the program, and the core's README says what you need installed.  The
table says what each directory holds.

<!-- generated: issues -->
| directory | for | the anomaly | holds |
|---|---|---|---|
| [csr-rows-unnamed](csr-rows-unnamed/) | documentation | the Hazards rows of pipeline.rst 119-126, 'an instruction causing an implicit CSR read in EX' (119) and 'an instruction causing an implicit CSR write' (120) name no instruction; on the RTL an ecall 1 after a CSR write, and a CSR read of mstatus 1 after an mret, cost the flush alone, so neither is the row's instruction; an mret 1 after any CSR instruction is held in ID by another row, line 126's ('an instruction causing an implicit CSR read in ID (mret or table jump) while a CSR access instruction ... is in the EX stage'; controller_bypass.sv 252), measured at 3 cycles (the issue csr-mret-rows-class-based) (a trap or an mret resolves before the next instruction reads) | the issue, the program, the two traces, `run.json` |
| [csr-mret-rows-class-based](csr-mret-rows-class-based/) | performance | An mret stalls behind any CSR access, including the CSRs it does not read | the issue, the program, the two traces, `run.json` |
| [fencei-six-cycles](fencei-six-cycles/) | documentation | fence.i costs 6 cycles, not the cycle table's 5 | the issue, the program, the two traces, `run.json` |
| [divisor-leading-ones](divisor-leading-ones/) | documentation | Division by a negative divisor: the cycle count is not the divisor's leading zeros | the issue, the program, the two traces, `run.json` |
| [jump-behind-divider](jump-behind-divider/) | documentation | A jal behind a busy divider is taken at once: its cycle hides under the divide | the issue, the program, the two traces, `run.json` |
| [counter-read-stall](counter-read-stall/) | documentation | A counter read costs one cycle more while an instruction is in WB | the issue, the program, the two traces, `run.json` |
| [irq-enable-stall](irq-enable-stall/) | documentation | A load or store behind a CSR write of mstatus or mie costs one cycle more | the issue, the program, the two traces, `run.json` |
| [mhpmcounter3h-read-stall](mhpmcounter3h-read-stall/) | documentation | A read of mhpmcounter3h costs one cycle more while an instruction is in WB | the issue, the program, the two traces, `run.json` |
| [counter-access-stall](counter-access-stall/) | performance | Any CSR instruction naming a counter costs one cycle more while an instruction is in WB | the issue, the program, the two traces, `run.json` |
| [mem-address-phase](mem-address-phase/) | documentation | The data bus accepts the next request only the cycle after the previous grant | the issue alone |
| [mem-response-frees-slot](mem-response-frees-slot/) | documentation | A response frees its outstanding slot the cycle after it is on the wire | the issue alone |
| [mem-responses-in-order](mem-responses-in-order/) | documentation | Responses return in order, at most one per cycle | the issue alone |
| [mem-split-second-half](mem-split-second-half/) | documentation | A split access requests its second half from WB, the cycle after the first grant | the issue alone |
| [mem-late-data-forward](mem-late-data-forward/) | documentation | A jalr two behind a load waits a cycle, even at zero wait | the issue alone |
| [mem-response-wait-freeze](mem-response-wait-freeze/) | performance | While a load or store waits in WB, nothing moves into ID or EX, even into an empty stage | the issue, the program, the two traces, `run.json` |
| [mem-wbuf-fence-drain](mem-wbuf-fence-drain/) | documentation | A fence or fence.tso behind a buffered store waits for the store's response first | the issue alone |
| [mem-pma-split-first-half](mem-pma-split-first-half/) | documentation | A misaligned load refused on its second half has already read its first | the issue alone |
| [mem-wbuf-third-store](mem-wbuf-third-store/) | documentation | A store the write buffer could take still waits while two transfers are outstanding | the issue, the program, the two traces, `run.json` |
| [mem-atomic-serial](mem-atomic-serial/) | performance | An atomic transaction overlaps no other: a cycle lost on each side of an lr, sc or AMO | the issue, the program, the two traces, `run.json` |
| [mem-atomic-misaligned-cause](mem-atomic-misaligned-cause/) | documentation | A misaligned atomic raises an access fault (5, 7), not a misaligned one (4, 6) | the issue, the program, the two traces, `run.json` |
| [rvfi-interrupt-entry-csrs-unreported](rvfi-interrupt-entry-csrs-unreported/) | RTL | An interrupt entry's CSR writes (mstatus, mepc, mcause) are not reported on RVFI | the issue, the program, the two traces, `run.json` |
| [nmi-taken-kill](nmi-taken-kill/) | documentation | A bus error's NMI is taken the cycle after the faulting access retires, every stage killed | the issue, the program, the two traces, `run.json` |
| [clic-minhv-after-restart](clic-minhv-after-restart/) | RTL | mcause.minhv stays set after an mret restarts a faulted CLIC pointer fetch successfully | the issue, the program, the two traces, `run.json` |
| [jvt-write-flush](jvt-write-flush/) | documentation | jvt write: a flush of the next instruction costing 5 cycles, not the table's 4 | the issue, the program, the two traces, `run.json` |
| [tselect-access-stall](tselect-access-stall/) | performance | a CSR instruction behind any access of tselect waits a cycle | the issue, the program, the two traces, `run.json` |
| [clic-implicit-csr-read-stall](clic-implicit-csr-read-stall/) | documentation | CLIC: an access of mnxti or mscratchcswl behind any CSR instruction waits a cycle | the issue, the program, the two traces, `run.json` |
| [clic-mie-write-no-stall](clic-mie-write-no-stall/) | documentation | CLIC: a load or store behind a write of mie does not wait, unlike the CLINT core | the issue, the program, the two traces, `run.json` |
| [clic-mintthresh-write-stall](clic-mintthresh-write-stall/) | documentation | CLIC: a load or store behind a write of mintthresh waits a cycle | the issue, the program, the two traces, `run.json` |
| [clic-csr-after-implicit-write-stall](clic-csr-after-implicit-write-stall/) | performance | CLIC: a CSR instruction one behind an mscratchcswl access waits a cycle | the issue, the program, the two traces, `run.json` |
| [clic-mcause-write-irq-enable-stall](clic-mcause-write-irq-enable-stall/) | documentation | CLIC: a load or store one behind an mcause write waits a cycle | the issue, the program, the two traces, `run.json` |
| [irq-withdrawn-by-mie-clear-one-cycle](irq-withdrawn-by-mie-clear-one-cycle/) | documentation | A withdrawn interrupt costs the instruction behind the clearing write a cycle | the issue, the program, the two traces, `run.json` |
| [occupancy-freezes-empty-id](occupancy-freezes-empty-id/) | performance | An empty ID stage takes no instruction while a multi-cycle instruction holds EX | the issue, the program, the two traces, `run.json` |
| [fetch-refused-at-io-window-costs-return](fetch-refused-at-io-window-costs-return/) | performance | A jump in the last word before an I/O region puts its target's fetch a cycle late | the issue, the program, the two traces, `run.json` |
| [stale-load-use-check](stale-load-use-check/) | performance | An empty ID stage stalls on a load-use hazard with the load's own stale register fields | the issue, the program, the two traces, `run.json` |

In all, 34 directories: 27 hold a program that reproduces the anomaly and the two traces of its run; 7 (`mem-address-phase`, `mem-late-data-forward`, `mem-pma-split-first-half`, `mem-response-frees-slot`, `mem-responses-in-order`, `mem-split-second-half`, `mem-wbuf-fence-drain`) hold the issue text alone, the anomaly read in the RTL source or seen in a run no small program repeats yet.  The other 3 (`jvt-mode-warl-zero-vs-udb-trap`, `mtvec-mode-2-reserved-keeps-legal`, `mstatus-mpp-hardwired-3`) have no directory; the findings page states each.
<!-- end -->

© 2026 processor-timing-anomalies, Apache License 2.0
