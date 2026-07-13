# Project 03 — 4-to-1 Multiplexer (3 coding styles)

## Theory

A **4-to-1 multiplexer** routes one of four inputs to the output
based on a 2-bit selector.

```
i0 ──┐
i1 ──┤──[MUX4:1]──► y
i2 ──┤      ▲
i3 ──┘      |
           sel[1:0]
```

Truth table:

| sel[1] | sel[0] | y  |
|--------|--------|----|
|   0    |   0    | i0 |
|   0    |   1    | i1 |
|   1    |   0    | i2 |
|   1    |   1    | i3 |

Gate-level Boolean expression:
```
y = (~sel[1] & ~sel[0] & i0)
  | (~sel[1] &  sel[0] & i1)
  | ( sel[1] & ~sel[0] & i2)
  | ( sel[1] &  sel[0] & i3)
```

---

## Three coding styles

| Style      | File                    | Key construct        |
|------------|-------------------------|----------------------|
| Gate-level | `mux4to1_gate.v`        | `and`, `or`, `not`   |
| Dataflow   | `mux4to1_dataflow.v`    | `assign` + `?:`      |
| Behavioral | `mux4to1_behavioral.v`  | `always @(*)` + `case` |

---

## New Verilog concepts introduced

### `always @(*)`
The `(*)` sensitivity list means "re-run this block whenever
ANY signal on the right-hand side of any assignment changes."
Equivalent to listing every input manually, but safer — you
can't forget one.

### `case` statement
```verilog
case (sel)
    2'b00: y = i0;
    2'b01: y = i1;
    2'b10: y = i2;
    2'b11: y = i3;
endcase
```
`case` checks `sel` against each label in order. When a match
is found, that branch executes and the rest are skipped.

**Critical rule:** for combinational `always` blocks, every
possible value of the case expression must be handled — either
with explicit branches or a `default` branch. If any value is
unhandled, the synthesiser infers a **latch** (unintended
memory). Latches are one of the most common RTL bugs.

### Ternary operator `? :`
```verilog
assign y = (sel == 2'b00) ? i0 :
           (sel == 2'b01) ? i1 :
           (sel == 2'b10) ? i2 : i3;
```
`condition ? value_if_true : value_if_false`  
Nesting them creates a priority chain — identical hardware to
the `case` statement, just written differently.

### `2'b00` literal
`2'b00` = 2-bit binary value 00.  
Always use sized literals when comparing against vectors to
avoid width-mismatch warnings.

---

## File structure

```
project03_mux/
├── src/
│   ├── mux4to1_gate.v        ← gate-level (AND/OR/NOT)
│   ├── mux4to1_dataflow.v    ← dataflow (assign + ternary)
│   └── mux4to1_behavioral.v  ← behavioral (always + case)
├── tb/
│   └── tb_mux4to1.v          ← 64-vector self-checking testbench
├── sim/
│   └── mux4to1.vcd           ← waveform
└── README.md
```

---

## How to simulate

```bash
cd project03_mux

iverilog -o sim/tb_mux4to1 \
    src/mux4to1_gate.v \
    src/mux4to1_dataflow.v \
    src/mux4to1_behavioral.v \
    tb/tb_mux4to1.v

vvp sim/tb_mux4to1
```

Expected output:
```
=====================================================
  4-to-1 MUX Exhaustive Testbench
  gate-level | dataflow | behavioral
  64 vectors: all sel × all data combinations
=====================================================

  Spot-check (i0=0 i1=1 i2=0 i3=1):
  sel | expected | gate | df | bh
  ----+----------+------+----+---
   00 |    0     |  0   |  0 |  0
   01 |    1     |  1   |  1 |  1
   10 |    0     |  0   |  0 |  0
   11 |    1     |  1   |  1 |  1

=====================================================
  Results: 64 PASSED, 0 FAILED
  *** ALL 64 TESTS PASSED ***
=====================================================
```

View waveform:
```bash
gtkwave sim/mux4to1.vcd
```

---
