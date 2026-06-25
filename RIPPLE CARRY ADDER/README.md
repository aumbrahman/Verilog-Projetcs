<ScrollWheelUp># Project 02 — 4-bit Ripple Carry Adder

## Theory

A **ripple carry adder** chains N full adders together to add two N-bit numbers.
The carry-out of each stage feeds directly into the carry-in of the next — it
"ripples" from LSB to MSB.

```
        Cin=0
          │
  A[0],B[0] ──►[FA0]──► Sum[0],  c0
                                   │
  A[1],B[1] ──►[FA1]──► Sum[1],  c1
                                   │
  A[2],B[2] ──►[FA2]──► Sum[2],  c2
                                   │
  A[3],B[3] ──►[FA3]──► Sum[3],  Cout
```

### The ripple delay problem

With `#1` gate delay per full adder, the **worst-case path** is:

```
Cin → FA0.cout → FA1.cout → FA2.cout → FA3.cout
     = 4 × 1ns = 4ns total
```

For a 32-bit adder: 32ns. For a 64-bit adder: 64ns. At 1 GHz, one clock cycle
is 1ns — so a ripple carry adder is impossibly slow at scale.

This is why real CPUs use **carry-lookahead adders (CLA)**, which compute all
carries in parallel using generate (G) and propagate (P) logic. We build that
in a later project — but you need to understand the ripple problem first.

### Overflow behavior

The adder is unsigned. When the result exceeds 4 bits (> 15), `cout` goes high
and `sum[3:0]` wraps around. Example: 15 + 1 = 16 → `sum=0000, cout=1`.

---

## New Verilog concepts introduced

| Concept | Example | Meaning |
|---------|---------|---------|
| Multi-bit port | `input [3:0] a` | A 4-bit wide input bus |
| Bit select | `a[0]` | Access individual bit of a bus |
| `assign #1` | `assign #1 sum = ...` | Add a 1ns propagation delay |
| `` `timescale `` | `` `timescale 1ns/1ps `` | Set simulation time unit/precision |
| Nested for loops | `for(i=0; i<16; ...)` | Sweep all A×B combinations |
| 5-bit expected | `reg [4:0] expected` | Holds {cout, sum[3:0]} together |
| `%d` format | `$display("%0d", sum)` | Print signal as decimal number |

---

## File structure

```
project02_rca/
├── src/
│   ├── full_adder.v       ← reused from Project 01 (with timescale + #1 delay)
│   └── rca_4bit.v         ← 4-bit ripple carry adder (structural)
├── tb/
│   └── tb_rca_4bit.v      ← exhaustive 512-vector self-checking testbench
├── sim/
│   └── rca_4bit.vcd       ← waveform (generated on run)
└── README.md
```

---

## How to simulate

### Requirements
- Icarus Verilog: `sudo apt install iverilog`
- GTKWave: `sudo apt install gtkwave`

### Compile and run

```bash
cd project02_rca

iverilog -o sim/tb_rca_4bit \
    src/full_adder.v \
    src/rca_4bit.v \
    tb/tb_rca_4bit.v

vvp sim/tb_rca_4bit
```

### Expected output

```
============================================
  4-bit Ripple Carry Adder — Exhaustive TB
  Testing all 256x2 = 512 input vectors
============================================
============================================
  Results: 512 PASSED, 0 FAILED
  *** ALL 512 TESTS PASSED ***
============================================

  Corner case spot-check:
  ----------------------
  15 + 1  = sum=0, cout=1  (expect sum=0, cout=1)
  15 + 15 = sum=14, cout=1  (expect sum=14, cout=1)
  7  + 1  = sum=8, cout=0  (expect sum=8, cout=0)
  0  + 0  = sum=0, cout=0  (expect sum=0, cout=0)
```

### View ripple delay in GTKWave

```bash
gtkwave sim/rca_4bit.vcd
```

Add these signals in order to see the carry ripple:
`cin` → `DUT.FA0.cout` → `DUT.FA1.cout` → `DUT.FA2.cout` → `cout`

You will see each carry arrive 1ns after the previous — that's the ripple.

---

## Key concepts to remember

**`[3:0]` bus notation** — `[MSB:LSB]`. So `[3:0]` is a 4-bit bus where
bit 3 is the most significant. Always write `[N-1:0]` for an N-bit signal.

**`#1` delay** — Adds a 1 time-unit (here 1ns) delay before the output
updates. This models real gate propagation delay. Without it, all outputs
update at time 0 and you can't see the ripple in waveforms.

**`` `timescale `` must be consistent** — Every file that uses `#delays` needs
a `` `timescale `` directive, or the simulator uses a default that may not match
your testbench. Always add it to every source file.

**5-bit expected** — `a + b + cin` on 4-bit signals can produce a 5-bit result
(max = 15+15+1 = 31 = `11111`). Using `reg [4:0] expected` lets you capture
both `cout` (bit 4) and `sum[3:0]` (bits 3:0) in one comparison.

---

## What's next

**Project 03** introduces the `case` statement and the `4-to-1 multiplexer` —
the first time you'll choose between inputs based on a selector signal.
The MUX is a building block inside every ALU, datapath, and bus arbiter you'll
ever design.
