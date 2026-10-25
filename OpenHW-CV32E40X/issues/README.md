# The issues: one directory per reproducible anomaly

Each directory here is one anomaly of the CV32E40X with a program that reproduces it: its `README.md` (the issue: what the
documentation says, what the RTL does, how to run it), `repro.S` with its `env/` and `Makefile`, the two RVVI traces
(`rtl.rvvi.txt`, `spike.rvvi.txt`) and `run.json`, the facts of the capture.  The directory's name is the anomaly's id
as the findings page and the timing specification cite it.  `make` then `make spike` in a directory builds and runs
the program; the core's README says what you need installed.

© 2026 processor-timing-anomalies, Apache License 2.0
