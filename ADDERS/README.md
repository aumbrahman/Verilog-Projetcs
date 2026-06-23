# Project 01 — Half Adder & Full Adder

## Theory

### Half adder
Adds two 1-bit numbers. No carry input.

```
Sum   = A XOR B
Carry = A AND B
```

| A | B | Sum | Carry |
|---|---|-----|-------|
| 0 | 0 |  0  |   0   |
| 0 | 1 |  1  |   0   |
| 1 | 0 |  1  |   0   |
| 1 | 1 |  0  |   1   |

### Full adder
Adds three 1-bit numbers (A, B, carry-in). Carry-in allows chaining multiple adders.

```
Sum  = A XOR B XOR Cin
Cout = (A AND B) OR (B AND Cin) OR (A AND Cin)
```

### Full adder from two half adders

```
A, B ──► [HA1] ──► sum1, c1
              sum1, Cin ──► [HA2] ──► Sum, c2
                                  c1, c2 ──► [OR] ──► Cout
```

---

## Three coding styles demonstrated

| Style      | File                        | Key concept               |
|------------|-----------------------------|---------------------------|
| Gate-level | `half_adder.v`              | `xor`, `and` primitives   |
| Structural | `full_adder_structural.v`   | Module instantiation, wires |
| Dataflow   | `full_adder_dataflow.v`     | `assign`, continuous eval |
| Behavioral | `full_adder_behavioral.v`   | `always`, `reg`, `{,}` concat |

**Why learn all three?**
- Gate-level: how synthesis tools think. Helps you predict timing.
- Structural: the language of SoC design. Real chips are hierarchies of instantiated modules.
- Dataflow: clean for combinational logic. Reads like a Boolean equation.
- Behavioral: the most common in modern RTL. Synthesisers convert it to gates automatically.

---

## File structure

```
project01_adders/
├── src/
│   ├── half_adder.v               ← gate-level half adder
    └── tb_half_adder.v        ← testbench for half adder|     
│   ├── full_adder_structural.v    ← structural (uses half_adder)
│   ├── full_adder_dataflow.v      ← dataflow (assign)
│   └── full_adder_behavioral.v    ← behavioral (always block)
├── tb/
│   └── tb_full_adder.v            ← self-checking exhaustive testbench
├── sim/
│   └── full_adder.vcd             ← waveform (generated on run)
└── README.md
```

---

## How to simulate

### Requirements
- [Icarus Verilog](https://bleyer.org/icarus/) (`sudo apt install iverilog`)
- [GTKWave](http://gtkwave.sourceforge.net/) (`sudo apt install gtkwave`) for waveforms

### Compile and run

```bash
cd project01_adders

iverilog -o sim/tb_full_adder \
    src/half_adder.v \
    src/full_adder_structural.v \
    src/full_adder_dataflow.v \
    src/full_adder_behavioral.v \
    tb/tb_full_adder.v

vvp sim/tb_full_adder
```

### Expected output

```
==============================================
  Full Adder Exhaustive Testbench
  Testing: Structural | Dataflow | Behavioral
==============================================
  A  B Cin | Sum Cout | Status
  --------+---------+--------
  0  0  0  |   0    0   | PASS
  0  0  1  |   1    0   | PASS
  0  1  0  |   1    0   | PASS
  0  1  1  |   0    1   | PASS
  1  0  0  |   1    0   | PASS
  1  0  1  |   0    1   | PASS
  1  1  0  |   0    1   | PASS
  1  1  1  |   1    1   | PASS
==============================================
  Results: 8 PASSED, 0 FAILED
  *** ALL TESTS PASSED ***
==============================================
```

### Open waveform in GTKWave

```bash
gtkwave sim/full_adder.vcd
```

Add signals: `a`, `b`, `cin`, `sum_s`, `cout_s` (and df/bh variants to compare all three).

---

## Key Verilog concepts learned

- `module` / `endmodule` — the fundamental unit of design
- `input wire` / `output wire` — port declarations
- `output reg` — needed when assigning inside `always`
- `xor`, `and`, `or` — built-in gate primitives
- Named port mapping (`.port(signal)`) — the correct way to instantiate
- `assign` — continuous assignment, re-evaluates whenever RHS changes
- `always @(...)` — sensitivity list, procedural block
- `{cout, sum} = a + b + cin` — concatenation to capture multi-bit result
- `$dumpfile` / `$dumpvars` — VCD waveform generation
- `$display` — simulation console output
- `$finish` — end simulation

- ---

