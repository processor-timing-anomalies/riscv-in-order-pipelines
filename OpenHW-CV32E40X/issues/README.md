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
| [csr-mret-rows-class-based](csr-mret-rows-class-based/) | performance | An mret stalls behind any CSR access, including the CSRs it does not read | the issue, the program, the two traces, `run.json` |
| [fencei-six-cycles](fencei-six-cycles/) | documentation | fence.i costs 6 cycles, not the cycle table's 5 | the issue, the program, the two traces, `run.json` |
| [divisor-leading-ones](divisor-leading-ones/) | documentation | Division by a negative divisor: the cycle count is not the divisor's leading zeros | the issue, the program, the two traces, `run.json` |
| [jump-behind-divider](jump-behind-divider/) | documentation | A jump behind a busy divider resolves at once, its bubble hidden | the issue, the program, the two traces, `run.json` |
| [counter-read-stall](counter-read-stall/) | documentation | A counter read costs one cycle more while an instruction is in WB | the issue, the program, the two traces, `run.json` |
| [irq-enable-stall](irq-enable-stall/) | documentation | A load or store behind a CSR write of mstatus or mie costs one cycle more | the issue, the program, the two traces, `run.json` |
| [mhpmcounter3h-read-stall](mhpmcounter3h-read-stall/) | documentation | A read of mhpmcounter3h costs one cycle more while an instruction is in WB | the issue, the program, the two traces, `run.json` |
| [counter-access-stall](counter-access-stall/) | performance | Any CSR instruction naming a counter costs one cycle more while an instruction is in WB | the issue, the program, the two traces, `run.json` |
| [mem-address-phase](mem-address-phase/) | documentation | The data bus accepts the next request only the cycle after the previous grant | the issue alone |
| [mem-response-frees-slot](mem-response-frees-slot/) | documentation | A response frees its outstanding slot the cycle after it is on the wire | the issue alone |
| [mem-responses-in-order](mem-responses-in-order/) | documentation | Responses return in order, at most one per cycle | the issue alone |
| [mem-split-second-half](mem-split-second-half/) | documentation | A split access requests its second half from WB, the cycle after the first grant | the issue alone |
| [mem-late-data-forward](mem-late-data-forward/) | documentation | A load's result is not forwarded before its response is on the wire | the issue alone |
| [mem-response-wait-freeze](mem-response-wait-freeze/) | performance | IF and ID freeze while a load or store in WB waits for its response | the issue, the program, the two traces, `run.json` |
| [mem-wbuf-fence-drain](mem-wbuf-fence-drain/) | documentation | A fence behind a buffered store waits for the store's response, then runs its own cycles | the issue alone |
| [mem-pma-split-first-half](mem-pma-split-first-half/) | documentation | A split access into I/O issues its legal first half, then faults a cycle later | the issue alone |
| [mem-wbuf-third-store](mem-wbuf-third-store/) | documentation | A bufferable store whose grant is withheld, third behind a mulh, stalls one cycle | the issue, the program, the two traces, `run.json` |
| [mem-atomic-serial](mem-atomic-serial/) | performance | An atomic transaction overlaps no other: a cycle lost on each side of an lr, sc or AMO | the issue, the program, the two traces, `run.json` |
| [mem-atomic-misaligned-cause](mem-atomic-misaligned-cause/) | documentation | A misaligned atomic raises an access fault (5, 7), not a misaligned one (4, 6) | the issue, the program, the two traces, `run.json` |
| [rvfi-interrupt-entry-csrs-unreported](rvfi-interrupt-entry-csrs-unreported/) | RTL | An interrupt entry's CSR writes (mstatus, mepc, mcause) are not reported on RVFI | the issue, the program, the two traces, `run.json` |
| [nmi-taken-kill](nmi-taken-kill/) | documentation | A bus error's NMI is taken the cycle after the faulting access retires, every stage killed | the issue, the program, the two traces, `run.json` |
| [jvt-write-flush](jvt-write-flush/) | documentation | jvt write: the table's 4 cycles are a flush of the next instruction | the issue, the program, the two traces, `run.json` |
| [tselect-access-stall](tselect-access-stall/) | performance | a CSR instruction behind any access of tselect waits a cycle | the issue, the program, the two traces, `run.json` |
| [clic-implicit-csr-read-stall](clic-implicit-csr-read-stall/) | documentation | CLIC: an access of mnxti or mscratchcswl behind any CSR instruction waits a cycle | the issue, the program, the two traces, `run.json` |
| [clic-mie-write-no-stall](clic-mie-write-no-stall/) | documentation | CLIC: a load or store behind a write of mie does not wait, unlike the CLINT core | the issue, the program, the two traces, `run.json` |
| [clic-mintthresh-write-stall](clic-mintthresh-write-stall/) | documentation | CLIC: a load or store behind a write of mintthresh waits a cycle | the issue, the program, the two traces, `run.json` |
| [clic-csr-after-implicit-write-stall](clic-csr-after-implicit-write-stall/) | performance | CLIC: a CSR instruction one behind an mscratchcswl access waits a cycle | the issue, the program, the two traces, `run.json` |
| [clic-mcause-write-irq-enable-stall](clic-mcause-write-irq-enable-stall/) | documentation | CLIC: a load or store one behind an mcause write waits a cycle | the issue, the program, the two traces, `run.json` |

In all, 28 directories: 21 hold a program that reproduces the anomaly and the two traces of its run; 7 (`mem-address-phase`, `mem-late-data-forward`, `mem-pma-split-first-half`, `mem-response-frees-slot`, `mem-responses-in-order`, `mem-split-second-half`, `mem-wbuf-fence-drain`) hold the issue text alone, the anomaly read in the RTL source or seen in a run no small program repeats yet.  The other 2 (`csr-rows-unnamed`, `clic-minhv-after-restart`) have no directory; the findings page states each.
<!-- end -->

© 2026 processor-timing-anomalies, Apache License 2.0
