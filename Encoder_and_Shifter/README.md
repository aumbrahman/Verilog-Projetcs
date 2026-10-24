# Encoder And Shifter

## What this project covers

Two combinational building blocks that appear inside almost every real CPU:

| Module | Role |
|--------|------|
| 8-to-3 Priority Encoder | Finds the highest active bit — used in interrupt controllers, bus arbiters |
| 8-bit Barrel Shifter | Shifts by any amount in one cycle — used in every shift/rotate CPU instruction |

---

## New Verilog concepts introduced

| Concept | Where used | What it does |
|---------|-----------|--------------|
| `casez` | Priority encoder | Like `case` but `?` in a branch label means "don't care — match 0 or 1" |
| `8'b1???????` | casez branch | Bit 7 is 1; lower 7 bits can be anything |
| `<<` / `>>` | Barrel shifter | Left / right logical shift operators |
| `mode` select | Barrel shifter | Single control bit chooses direction |
| `valid` flag | Priority encoder | Output that tells you whether any input was active |

---

## Theory

### Priority Encoder

Takes 8 input lines. When multiple are high at once, **the highest-numbered one wins**.
The binary index of that winner is the 3-bit output.

```
  in = 8'b00101100   (bits 5, 3, 2 are high)
                  ↓
  Highest active = bit 5
  out = 3'd5,  valid = 1
```

Real-world use: the Intel 8259A interrupt controller is essentially a priority
encoder. When two devices interrupt the CPU simultaneously, the higher-priority
one is serviced first.

#### How `casez` encodes priority

```
casez (in)
    8'b1???????: out = 7;   // bit 7 set → highest priority
    8'b01??????: out = 6;   // bit 7 clear, bit 6 set → next
    ...
```

`casez` checks branches **top-to-bottom and stops at the first match**.
That ordering IS the priority. The `?` wildcards mean lower bits are irrelevant
once a higher bit is confirmed set.

---

### Barrel Shifter

A regular shift register moves data one bit per clock cycle — to shift by 5
you'd need 5 clock cycles. A barrel shifter does it in **one cycle** using a
tree of multiplexers.

```
  in = 8'b00000001, shamt = 3'd5, mode = 0 (left)
  out = 8'b00100000   (shifted left by 5)
```

#### The MUX tree inside

For an 8-bit shifter with 3-bit shift amount:

```
Stage 0: shamt[0]=1 → shift by 1,  else pass through
Stage 1: shamt[1]=1 → shift by 2,  else pass through
Stage 2: shamt[2]=1 → shift by 4,  else pass through
```

Any combination gives 0–7 in one gate delay through three MUX stages.
Example: shamt=5 (101₂) → shift-4 stage + shift-1 stage = shift 5.

We write this behaviorally with `<<`/`>>` and the synthesiser generates the
MUX tree automatically.

Real-world use: RISC-V `SLL`, `SRL`, `SRA` instructions; AES/SHA bit rotation;
floating-point exponent alignment.

---

## File structure

```
Encoder_and_Shifter/
├── src/
│   ├── priority_encoder.v    ← 8-to-3 priority encoder (casez)
│   └── barrel_shifter.v      ← 8-bit barrel shifter (behavioral)
├── tb/
│   ├── tb_priority_encoder.v ← 16 directed tests, task-based
│   └── tb_barrel_shifter.v   ← 31 directed tests, task-based
├── sim/
│   ├── priority_encoder.vcd  ← waveform (generated on run)
│   └── barrel_shifter.vcd
└── README.md
```

---

## How to simulate

```bash
cd project05_enc_shift

# Priority Encoder
iverilog -o sim/tb_priority_encoder \
    src/priority_encoder.v \
    tb/tb_priority_encoder.v
vvp sim/tb_priority_encoder

# Barrel Shifter
iverilog -o sim/tb_barrel_shifter \
    src/barrel_shifter.v \
    tb/tb_barrel_shifter.v
vvp sim/tb_barrel_shifter
```

### Expected output — Priority Encoder

<img width="1366" height="768" alt="Screenshot from 2026-10-24 22-56-56" src="https://github.com/user-attachments/assets/15dc8392-5f43-4523-94c9-d985f54f5a63" />


```
==============================================
  Priority Encoder 8-to-3 Testbench
==============================================

  [Single bit active]
  [Multiple bits — highest must win]
  [No input active]
  [Corner cases]

==============================================
  Results: 16 PASSED, 0 FAILED
  *** ALL TESTS PASSED ***
==============================================
```

### Expected output — Barrel Shifter

<img width="1366" height="768" alt="Screenshot from 2026-10-24 23-38-29" src="https://github.com/user-attachments/assets/eec01749-b00d-45b4-ba4e-c0191dbd0c45" />


```
==============================================
  Barrel Shifter 8-bit Testbench
==============================================

  [Shift LEFT — in=00000001]
  [Shift LEFT — in=10110011]
  [Shift RIGHT — in=10000000]
  [Shift RIGHT — in=10110011]
  [Corner: shift by 0]
  [Corner: shift by 7]

==============================================
  Results: 31 PASSED, 0 FAILED
  *** ALL TESTS PASSED ***
==============================================
```

---

## Key concepts to remember

**`casez` top-to-bottom ordering IS the priority** — Verilog evaluates branches
in the order they are written and takes the first match. Putting the highest bit
first means it always wins over lower bits. If you reversed the order, bit 0
would steal priority from bit 7.

**`?` is a wildcard for `0` or `1` only** — it does NOT match `X` (unknown)
or `Z` (high-impedance). Use `casex` if you need that, but `casez` is safer
and is what industry uses for priority encoders.

**`valid = 0` when in = 0** — No branch in the `casez` matches all-zeros,
so the default assignments at the top of the `always` block take effect.
This is why setting defaults before `case/casez` is critical — it prevents
latch inference and handles the "no active input" case cleanly.

**Barrel shifter is O(1) in time** — It takes the same number of gate delays
whether you shift by 1 or by 7. A shift register takes O(n) clock cycles.
This is why barrel shifters are in every CPU and FPGA fabric.# Project 05 — Priority Encoder + Barrel Shifter

## What this project covers

Two combinational building blocks that appear inside almost every real CPU:

| Module | Role |
|--------|------|
| 8-to-3 Priority Encoder | Finds the highest active bit — used in interrupt controllers, bus arbiters |
| 8-bit Barrel Shifter | Shifts by any amount in one cycle — used in every shift/rotate CPU instruction |

---

## New Verilog concepts introduced

| Concept | Where used | What it does |
|---------|-----------|--------------|
| `casez` | Priority encoder | Like `case` but `?` in a branch label means "don't care — match 0 or 1" |
| `8'b1???????` | casez branch | Bit 7 is 1; lower 7 bits can be anything |
| `<<` / `>>` | Barrel shifter | Left / right logical shift operators |
| `mode` select | Barrel shifter | Single control bit chooses direction |
| `valid` flag | Priority encoder | Output that tells you whether any input was active |

---

## Theory

### Priority Encoder

Takes 8 input lines. When multiple are high at once, **the highest-numbered one wins**.
The binary index of that winner is the 3-bit output.

```
  in = 8'b00101100   (bits 5, 3, 2 are high)
                  ↓
  Highest active = bit 5
  out = 3'd5,  valid = 1
```

Real-world use: the Intel 8259A interrupt controller is essentially a priority
encoder. When two devices interrupt the CPU simultaneously, the higher-priority
one is serviced first.

#### How `casez` encodes priority

```
casez (in)
    8'b1???????: out = 7;   // bit 7 set → highest priority
    8'b01??????: out = 6;   // bit 7 clear, bit 6 set → next
    ...
```

`casez` checks branches **top-to-bottom and stops at the first match**.
That ordering IS the priority. The `?` wildcards mean lower bits are irrelevant
once a higher bit is confirmed set.

---

### Barrel Shifter

A regular shift register moves data one bit per clock cycle — to shift by 5
you'd need 5 clock cycles. A barrel shifter does it in **one cycle** using a
tree of multiplexers.

```
  in = 8'b00000001, shamt = 3'd5, mode = 0 (left)
  out = 8'b00100000   (shifted left by 5)
```

#### The MUX tree inside

For an 8-bit shifter with 3-bit shift amount:

```
Stage 0: shamt[0]=1 → shift by 1,  else pass through
Stage 1: shamt[1]=1 → shift by 2,  else pass through
Stage 2: shamt[2]=1 → shift by 4,  else pass through
```

Any combination gives 0–7 in one gate delay through three MUX stages.
Example: shamt=5 (101₂) → shift-4 stage + shift-1 stage = shift 5.

We write this behaviorally with `<<`/`>>` and the synthesiser generates the
MUX tree automatically.

Real-world use: RISC-V `SLL`, `SRL`, `SRA` instructions; AES/SHA bit rotation;
floating-point exponent alignment.

---

## File structure

```
project05_enc_shift/
├── src/
│   ├── priority_encoder.v    ← 8-to-3 priority encoder (casez)
│   └── barrel_shifter.v      ← 8-bit barrel shifter (behavioral)
├── tb/
│   ├── tb_priority_encoder.v ← 16 directed tests, task-based
│   └── tb_barrel_shifter.v   ← 31 directed tests, task-based
├── sim/
│   ├── priority_encoder.vcd  ← waveform (generated on run)
│   └── barrel_shifter.vcd
└── README.md
```

---

## How to simulate

```bash
cd project05_enc_shift

# Priority Encoder
iverilog -o sim/tb_priority_encoder \
    src/priority_encoder.v \
    tb/tb_priority_encoder.v
vvp sim/tb_priority_encoder

# Barrel Shifter
iverilog -o sim/tb_barrel_shifter \
    src/barrel_shifter.v \
    tb/tb_barrel_shifter.v
vvp sim/tb_barrel_shifter
```

### Expected output — Priority Encoder

```
==============================================
  Priority Encoder 8-to-3 Testbench
==============================================

  [Single bit active]
  [Multiple bits — highest must win]
  [No input active]
  [Corner cases]

==============================================
  Results: 16 PASSED, 0 FAILED
  *** ALL TESTS PASSED ***
==============================================
```

### Expected output — Barrel Shifter

```
==============================================
  Barrel Shifter 8-bit Testbench
==============================================

  [Shift LEFT — in=00000001]
  [Shift LEFT — in=10110011]
  [Shift RIGHT — in=10000000]
  [Shift RIGHT — in=10110011]
  [Corner: shift by 0]
  [Corner: shift by 7]

==============================================
  Results: 31 PASSED, 0 FAILED
  *** ALL TESTS PASSED ***
==============================================
```

---

## Key concepts to remember

**`casez` top-to-bottom ordering IS the priority** — Verilog evaluates branches
in the order they are written and takes the first match. Putting the highest bit
first means it always wins over lower bits. If you reversed the order, bit 0
would steal priority from bit 7.

**`?` is a wildcard for `0` or `1` only** — it does NOT match `X` (unknown)
or `Z` (high-impedance). Use `casex` if you need that, but `casez` is safer
and is what industry uses for priority encoders.

**`valid = 0` when in = 0** — No branch in the `casez` matches all-zeros,
so the default assignments at the top of the `always` block take effect.
This is why setting defaults before `case/casez` is critical — it prevents
latch inference and handles the "no active input" case cleanly.

**Barrel shifter is O(1) in time** — It takes the same number of gate delays
whether you shift by 1 or by 7. A shift register takes O(n) clock cycles.
This is why barrel shifters are in every CPU and FPGA fabric.
