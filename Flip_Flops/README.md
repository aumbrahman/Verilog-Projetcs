# Project Flip Flop — D, T, JK, SR Flip-Flops

## What this project covers

The four fundamental sequential building blocks. This is the gateway to Phase 2
of the roadmap — every counter, register, FSM, and pipeline is made of these.

| Module | Key feature |
|--------|-------------|
| D flip-flop | Q captures D on clock edge — most used in real silicon |
| T flip-flop | Q toggles when T=1 — foundation of counters and dividers |
| SR flip-flop | Set/Reset — foundational concept, forbidden state introduced |
| JK flip-flop | SR with toggle instead of forbidden — the most general FF |

---

## New Verilog concepts introduced

| Concept | What it means |
|---------|--------------|
| `always @(posedge clk)` | Block fires ONLY on rising clock edge — sequential logic |
| `<=` (non-blocking assignment) | Used inside clocked always blocks; all RHS values sampled simultaneously before any LHS updates |
| `initial clk = 0;` | Sets the starting value of the clock before simulation begins |
| `always #5 clk = ~clk;` | Clock generator — inverts clk every 5ns → 10ns period, 100 MHz |
| `@(posedge clk)` in TB | Stimulus waits for the next rising edge before proceeding |
| `#1` after edge in TB | Small settling delay to let the FF output propagate before checking |
| `q <= 1'bx` | Assigns unknown/undefined state — used for SR forbidden case |
| `repeat(N)` | Loop that runs a block N times |

---

## The `<=` vs `=` distinction (critical)

Inside a clocked `always @(posedge clk)` block, always use `<=` (non-blocking):

```verilog
// CORRECT — non-blocking
always @(posedge clk)
    q <= d;

// WRONG — blocking (can cause incorrect simulation in multi-FF designs)
always @(posedge clk)
    q = d;    // ← don't do this in clocked blocks
```

**Why?** Non-blocking (`<=`) means: "sample the RHS now, but update the LHS
only after all non-blocking assignments in this time step are evaluated."
This models real flip-flop behaviour where all FFs sample simultaneously at
the clock edge. Blocking (`=`) updates immediately, which breaks pipelines and
shift registers — the output of FF1 would feed FF2 in the same clock edge,
which is not how silicon works.

**Rule:** `=` inside `always @(*)` (combinational). `<=` inside `always @(posedge clk)` (sequential). No exceptions.

---

## Flip-flop comparison

```
        D  →  Q_next
        ─────────────
        0  →  0
        1  →  1

        T  Q  →  Q_next
        ───────────────
        0  x  →  Q (hold)
        1  x  →  ~Q (toggle)

        S  R  →  Q_next
        ───────────────
        0  0  →  Q (hold)
        1  0  →  1 (set)
        0  1  →  0 (reset)
        1  1  →  X (FORBIDDEN)

        J  K  →  Q_next
        ───────────────
        0  0  →  Q (hold)
        1  0  →  1 (set)
        0  1  →  0 (reset)
        1  1  →  ~Q (TOGGLE) ← this is the fix over SR
```

---

## File structure

```
Flip_Flops/
├── src/
│   ├── dff.v     ← D flip-flop (synchronous reset)
│   ├── tff.v     ← T flip-flop
│   ├── srff.v    ← SR flip-flop (forbidden state → X)
│   └── jkff.v    ← JK flip-flop
├── tb/
│   ├── tb_dff.v  ← 10 tests
│   ├── tb_tff.v  ← 18 tests (hold + toggle + alternating)
│   ├── tb_srff.v ← 11 tests (incl. forbidden state)
│   └── tb_jkff.v ← 18 tests (incl. 8-edge toggle run)
├── sim/
│   ├── dff.vcd / tff.vcd / srff.vcd / jkff.vcd
└── README.md
```

---

## How to simulate

```bash
cd project06_flipflops

iverilog -o sim/tb_dff  src/dff.v  tb/tb_dff.v  && vvp sim/tb_dff
iverilog -o sim/tb_tff  src/tff.v  tb/tb_tff.v  && vvp sim/tb_tff
iverilog -o sim/tb_srff src/srff.v tb/tb_srff.v && vvp sim/tb_srff
iverilog -o sim/tb_jkff src/jkff.v tb/tb_jkff.v && vvp sim/tb_jkff
```

### Expected results

```
D  FF: 10 PASSED, 0 FAILED  *** ALL TESTS PASSED ***
T  FF: 18 PASSED, 0 FAILED  *** ALL TESTS PASSED ***
SR FF: 11 PASSED, 0 FAILED  *** ALL TESTS PASSED ***
JK FF: 18 PASSED, 0 FAILED  *** ALL TESTS PASSED ***
```

### Viewing waveforms in GTKWave

```bash
gtkwave sim/dff.vcd
```

After opening:
1. Expand `tb_dff` → `DUT` in the signal tree (left panel)
2. Select `clk`, `rst`, `d`, `q`, `q_bar` → click **Append**
3. Press **Ctrl+Shift+F** to zoom to full width

On the waveform you will see:
- `Q` only changes on `clk` rising edges, never between them
- `Q` follows `D` exactly one clock cycle later
- When `rst=1` at an edge, `Q` snaps to 0 regardless of `D`

For `tff.vcd`: add `t` and `q` — you'll see Q invert exactly at each
rising edge when T is high.

---

## Key concepts to remember

**`always @(posedge clk)` is the most important line in sequential Verilog.**
Every register, counter, FSM, and pipeline stage you'll ever write starts here.

**Synchronous reset is preferred in industry.** It only activates at a clock
edge, making it clean to synthesise. Asynchronous reset (`always @(posedge clk
or posedge rst)`) activates immediately — useful for power-on init but harder
to time.

**JK is the most general flip-flop.** D is `JK with K=~J`. T is `JK with J=K`.
SR is `JK without the toggle case`. All flip-flops are related.

**In real silicon, only D flip-flops exist.** Tools synthesise everything as D
FFs with additional combinational logic at the input. Understanding T, SR, and
JK is about understanding the logic, not the implementation.

---


