# 4-bit Synchronous Binary Counter

## What this project covers

A parameterized synchronous counter with reset, enable, parallel load, and
terminal count. The same architecture as the **program counter** in the
RISC-V CPU we're building toward.

---

## New Verilog concepts introduced

| Concept | Example | Meaning |
|---------|---------|---------|
| Priority chain in clocked block | `if rst … else if load … else if en` | Ordered precedence: rst > load > en > hold |
| Implicit hold in clocked block | no else branch needed | Unassigned `reg` in `always @(posedge clk)` retains its value — not a latch |
| Terminal count | `assign tc = (count == MAX) && en` | Combinational overflow pulse; used to chain counters |
| `{WIDTH{1'b1}}` | replication operator | Generates `4'b1111` for WIDTH=4 — avoids magic numbers |
| `count + 1'b1` | 1-bit literal in addition | Verilog zero-extends it; result wraps at `2^WIDTH` automatically |
| `begin : label` | named block | Lets you declare `integer i` inside a for loop scope |

---

## Counter behaviour

```
Priority (highest → lowest):
  rst=1              → count = 0         (synchronous reset)
  load=1             → count = data      (parallel load)
  en=1               → count = count+1   (increment)
  (all low)          → count holds

Terminal count:
  tc = (count == 4'b1111) AND (en == 1)
  tc is HIGH for exactly one cycle, right as count is at 15
  and about to roll over to 0 on the next edge.
```

---

## The connection to RISC-V

The **Program Counter (PC)** in a CPU is a counter with:
- `rst` → PC = reset vector (e.g. 0x00000000)
- `en` → always 1 (fetch every cycle)
- `load` → branch/jump: PC = target address
- `data` → branch target or jump destination

This is literally Project 07. When you build the RV32I core, you will
instantiate a version of this module as the PC.

---

## Chaining counters (cascading)

Connect `tc` of one stage to `en` of the next for wider counters:

```
stage0: counter4 (.en(1'b1),    .tc(tc0))  // always counting
stage1: counter4 (.en(tc0),     .tc(tc1))  // counts every 16 cycles
stage2: counter4 (.en(tc1),     .tc(tc2))  // counts every 256 cycles
→ 12-bit counter from three 4-bit stages
```

This is how real hardware timers work (e.g. the 8253 PIT in the original IBM PC).

---

## File structure

```
counter_4bit/
├── src/
│   └── counter4.v       ← parameterized counter (WIDTH=4 default)
├── tb/
│   └── tb_counter4.v    ← 30 tests across 8 test groups
├── sim/
│   └── counter4.vcd     ← waveform
└── README.md
```

---

## How to simulate

```bash
cd project07_counter
iverilog -o sim/counter4.vvp src/counter4.v tb/tb_counter4.v
vvp sim/tb_counter4
```

Expected:
```
Results: 30 PASSED, 0 FAILED
*** ALL TESTS PASSED ***
```

### What to look at in GTKWave

```bash
gtkwave sim/counter4.vcd
```

Add signals: `clk  rst  en  load  data[3:0]  count[3:0]  tc`

Things to observe:
- `count` steps 0→1→2→...→15→0 when `en=1`
- `count` freezes when `en=0`
- `tc` is a one-cycle pulse right at count=15
- `load` causes an instant jump to `data` value
- `rst` overrides everything — count→0 even when load+en are both high

---


