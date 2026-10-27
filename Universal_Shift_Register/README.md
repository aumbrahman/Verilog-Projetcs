# Project 08 — Universal Shift Register

## What this project covers

An 8-bit Universal Shift Register (USR) with four modes: hold, shift-right,
shift-left, and parallel load. The fundamental building block inside every
SPI peripheral, UART transmitter, and serial interface.

---

## Mode select truth table

| `mode[1:0]` | Operation | data_next |
|-------------|-----------|-----------|
| `2'b00` | Hold | `data` (unchanged) |
| `2'b01` | Shift right | `{sin_r, data[7:1]}` |
| `2'b10` | Shift left | `{data[6:0], sin_l}` |
| `2'b11` | Parallel load | `din[7:0]` |

---

## New Verilog concepts introduced

| Concept | Example | Meaning |
|---------|---------|---------|
| Concatenation in shift | `{sin_r, data[7:1]}` | Bundle new serial bit with existing data minus LSB |
| Part-select | `data[7:1]` | Bits 7 down to 1 — excludes bit 0 |
| Combinational serial output | `assign sout_l = data[WIDTH-1]` | Reflects current MSB instantly, no clock |
| `localparam` for mode names | `localparam SHR = 2'b01` | Readable mode names in testbench |

---

## How shift-right works (the key operation)

```
Before: data = [b7][b6][b5][b4][b3][b2][b1][b0]
                                                ↓ disappears to sout_r
After:  data = [sin_r][b7][b6][b5][b4][b3][b2][b1]
               ↑ new bit from serial input
```

In Verilog: `data <= {sin_r, data[WIDTH-1:1]}`

`data[WIDTH-1:1]` is bits 7 down to 1 — that's the top 7 bits, shifted one
position to the right. `sin_r` fills the vacated MSB position. `data[0]`
(which appears on `sout_r`) is automatically discarded because the left side
is only WIDTH bits wide.

---

## SPI connection diagram

```
┌─────────────────────────────────┐
│   Universal Shift Register      │
│                                 │
│   din[7:0] ←── (parallel load) │◄── byte to transmit
│   mode ←── 11 (load), 10 (shl) │
│   sin_l ←── MISO ──────────────│◄── incoming SPI data
│   sout_l ──► MOSI ─────────────│──► outgoing SPI data
│   clk ←── SCK                  │
└─────────────────────────────────┘

Transmit sequence:
  1. mode=LOAD, din=byte_to_send  → one clock
  2. mode=SHL, sin_l=MISO         → 8 clocks, sample sout_l each cycle
  Result: byte transmitted MSB-first on sout_l; received byte in data[7:0]
```

---

## The sampling timing lesson (learned from a real bug)

`sout_l` is a combinational wire — it reflects `data[7]` instantly. When
shifting out a byte over SPI:

```verilog
// CORRECT — sample BEFORE the clock shift
captured[i] = sout_l;     // read current MSB
@(posedge clk);            // then shift (MSB lost, new bit enters from sin_l)

// WRONG — sample AFTER the clock shift
@(posedge clk);            // shift first — MSB is gone
captured[i] = sout_l;     // read new MSB — off by one bit!
```

Wrong order gives you the byte shifted left by 1 — everything looks
plausible but is completely wrong. This is the class of bug that causes
SPI protocol failures in embedded systems.

---

## File structure

```
project08_shift_reg/
├── src/
│   └── shift_reg.v      ← 8-bit USR, parameterized WIDTH
├── tb/
│   └── tb_shift_reg.v   ← 19 tests: shift, hold, load, SPI simulation
├── sim/
│   └── shift_reg.vcd
└── README.md
```

---

## How to simulate

```bash
cd project08_shift_reg
iverilog -o sim/tb_shift_reg src/shift_reg.v tb/tb_shift_reg.v
vvp sim/tb_shift_reg
```

Expected:
```
Results: 19 PASSED, 0 FAILED
*** ALL TESTS PASSED ***
```

---

## What's next

**Project 09** — Clock Divider and Frequency Counter.
Divide a 100 MHz clock down to 1 MHz, 50 kHz, 1 kHz using counters as
dividers. The clock divider is inside every microcontroller peripheral —
SPI baud rate, I²C SCL, PWM frequency are all produced this way.
