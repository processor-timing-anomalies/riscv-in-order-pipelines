# An empty ID stage stalls on a load-use hazard with the load's own stale register fields

- Title: stale-load-use-check
- Class: over-wide -- the stall fires in cases that have no cause for it: an interlock wider than needed, a performance flaw. The cause is a load-use dependency: the instruction in ID reads the register the load in EX will write, and must wait for the data.  The RTL's check reads the register fields of the IF/ID register whether or not it holds an instruction (if_id_pipe.instr_valid is not a term), so with ID empty it compares the load's own source register, left there from the load's decode, against the load's destination: a load with rd equal to rs1 (an AMO or sc.w with rd equal to rs2) matches itself.  The stall then holds the ID stage with nothing in it to protect, and the instruction arriving from IF, whatever it reads, enters ID a cycle later.  With the cause removed (the follower independent of the load) the stall still fires; with the follower already in ID when the load enters EX (a zero-wait instruction bus) the check reads the follower's real fields and nothing fires
- Cost: one cycle on the instruction behind a load whose destination is one of its own source registers (rd = rs1; an AMO or sc.w with rd = rs2) when that instruction's word arrives from the instruction bus only as the load enters EX (an instruction-side wait state before it); nothing on a zero-wait instruction bus, where the follower is already in ID
- Core: cv32e40x
- Found while running: cv32e40x (the base build)

## Issue

with a load in EX and the ID stage empty, its next instruction waiting to arrive from the instruction bus, the load-use stall fires when the load's destination register equals one of its own source registers (lw x19, 0(x19); an AMO or sc.w with rd = rs2): the arriving instruction waits a cycle in IF and retires 3 cycles after the load instead of 2, whether or not it reads the load's result.  The same load into another register (lw x20, 0(x19)) lets the same instruction in at once, 2 cycles.  Nothing fires when the next instruction is already in ID as the load enters EX.

## What the documentation says

pipeline.rst 114-116: 'The |corev| experiences a 1 cycle penalty on the following hazards.' ... 'Load data hazard (in case the instruction immediately following a load uses the result of that load).'; pipeline.rst 30-31: 'The cycle counts assume zero stall on the instruction-side interface and zero stall on the data-side memory interface'.  The Hazards list gives the penalty to an instruction that uses the load's result and nothing else; it says nothing of an empty ID stage or of the register fields a stall is judged on

## What the RTL does

a hand-written program under an instruction bus granting every fetch one cycle after its request (every instruction otherwise retiring 2 cycles after the one before, the data bus without waits): lw s3, 0(s3) at 0x80000020 then lui t3, 0x5: the lui retires 3 cycles after the load (order 9, cycle 36 after 33); lw s4, 0(s3) at 0x80000034 then lui t4, 0x9: 2 cycles (order 14, 45 after 43); lw s3, 0(s3) at 0x80000048 then addi s5, s3, 1, the manual's load data hazard: 3 cycles (order 19, 56 after 53), the same cycle from the same check since the addi too is not yet in ID.  The instruction words: the lui's requested at 29, granted 30, answered 31, the load in EX then.  In the generated scheduled suite (hzs-shape-01-zmmul-00, 8 Nov 2026, a waveform of the regression's run read per cycle): lw s3, 0(s3) in EX at RTL cycle 483 with if_id_pipe.instr_valid 0, rf_waddr_ex = rf_raddr_id[0] = x19, rf_re_id[0] 1, load_stall 1, id_ready 0; the lui t3 behind it, its word on the wire that cycle, enters ID at the edge of 485 and retires at 489, 3 cycles after the load; the five pma-a files of the same suite with an AMO or sc.w with rd = rs2 before a scheduled fetch (amoadd.w.aqrl s9, s9, (tp); amoswap.w gp, gp, (tp); sc.w.aq s0, s0, (tp)) show the same cycle, 15 intervals in all

## The bus timing of the run

The instruction bus granted every fetch one cycle after its request (FSCHED all); the data bus granted every request in its own cycle and answered it in the next.  The issue shows only under such waits; a testbench that answers every request in the next cycle will not see it.

## From the RTL source (read, not measured)

`rtl/cv32e40x_controller_bypass.sv`, lines 181-187, 216-220 (`load_stall`): 'assign rf_rd_ex_match[i] = (rf_waddr_ex == rf_raddr_id_i[i]) && |rf_raddr_id_i[i] && rf_re_id_i[i];' (181) and 'assign rf_rd_ex_hz[i] = rf_rd_ex_match[i];' (187): the match has no instr_valid term; the stall '((id_ex_pipe_i.lsu_en || id_ex_pipe_i.xif_en) && rf_we_ex && |rf_rd_ex_hz) || // load-use hazard (EX)' (216) sets load_stall (220).  The fields it reads are the IF/ID register's word decoded whether or not it is valid: cv32e40x_id_stage.sv 216 'assign instr = if_id_pipe_i.instr.bus_resp.rdata;', 231-232 rf_raddr_o from instr, cv32e40x_decoder.sv 272 rf_re_o from the decoded word.  load_stall halts ID (cv32e40x_controller_fsm.sv 653) and so lowers id_ready_o (cv32e40x_id_stage.sv 674 'assign id_ready_o = ctrl_fsm_i.kill_id || (ex_ready_i && !ctrl_fsm_i.halt_id && !xif_waiting);'), which holds the IF to ID handover (cv32e40x_if_stage.sv 389 'if (if_valid_o && id_ready_i)')

## The core's configuration

The RTL was built with these parameters of its top module (the names and values are the RTL's own; the build named under "Found while running" is what they define):

| parameter | value |
|---|---|
| `RV32` | `RV32I` |
| `A_EXT` | `A_NONE` |
| `B_EXT` | `ZBA_ZBB_ZBS` |
| `M_EXT` | `M` |
| `X_EXT` | `0` |
| `NUM_MHPMCOUNTERS` | `1` |

## To reproduce

The program in this directory, built with the RISC-V GNU toolchain and run on Spike (`env/` carries the few lines of start-up and the linker script it needs; the RTL traces here were captured on the core's RTL under Verilator with our own testbench, which is not published):

- `repro.S`

    make           build repro.elf (and the probes) with the toolchain
    make spike     run it on Spike: exit 0 is the program finding what it expects
    make dasm      the disassembly, to read beside the traces

Observed on the RTL (the run this was captured from):

- orders 8..9 (lui t3, 0x5: 3 cycles after the previous retirement): lui t3, 0x5 behind lw s3, 0(s3) with the ID stage empty: 3 cycles after the load, where the same lui behind lw s4, 0(s3) (order 14) takes 2; the load-use check fired on the load's own stale register fields

## Trace

RVVI-TEXT 0.5 traces of the run: `rtl.rvvi.txt`, `spike.rvvi.txt`.  A `META 2 ISSUE "..."` line follows each retirement that matters, saying what was seen there.

## Found by

RTL https://github.com/openhwgroup/cv32e40x.git at d952cd63bc1b4eb58cd893c28ef8283c781e345e; spike: Spike RISC-V ISA Simulator 1.1.1-dev; verilator: Verilator 5.020 2024-01-01 rev (Debian 5.020-1); gcc: riscv64-unknown-elf-gcc (13.2.0-11ubuntu1+12) 13.2.0; captured 2026-11-09

---

© 2026 processor-timing-anomalies, Apache License 2.0
