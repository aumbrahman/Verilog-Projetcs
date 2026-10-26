# Verilog HDL Portfolio — VLSI Interview Preparation

> A progressive series of 25 Verilog projects built from scratch, covering
> combinational logic → sequential logic → datapaths → CPU microarchitecture →
> a pipelined RISC-V RV32I core.

---

## Toolchain

| Tool | Purpose | Install |
|------|---------|---------|
| [Icarus Verilog](http://iverilog.icarus.com/) | Compile and simulate `.v` files | `sudo apt install iverilog` |
| [GTKWave](http://gtkwave.sourceforge.net/) | View `.vcd` waveform files | `sudo apt install gtkwave` |

No proprietary tools required. Every project runs on Linux/macOS/WSL.

---

## How to run any project

```bash
cd projectXX_name

# compile
iverilog -o sim/tb_name src/module.v tb/tb_module.v

# simulate
vvp sim/tb_name

# view waveform
gtkwave sim/module.vcd
```

Each project self-checks — the testbench prints `PASSED / FAILED` counts and
exits with `*** ALL TESTS PASSED ***` when everything is correct.

---

## Project Roadmap

### Phase 1 — Combinational Logic (Projects 01–05) ✅

Foundation: gates, adders, multiplexers, the ALU that goes inside the CPU,
and the combinational building blocks of every datapath.

| # | Project | Key concepts | Tests |
|---|---------|-------------|-------|
| 01 | [Half Adder & Full Adder](#project-01--half-adder--full-adder) | Gate-level, dataflow, behavioral styles; `xor`, `and`, `assign`, `always @(*)` | 8/8 |
| 02 | [4-bit Ripple Carry Adder](#project-02--4-bit-ripple-carry-adder) | Structural instantiation, `#delay`, `` `timescale ``, carry chain | 512/512 |
| 03 | [4-to-1 Multiplexer](#project-03--4-to-1-multiplexer) | Three styles side by side, `case` statement, ternary `?:` | 64/64 |
| 04 | [8-bit Parameterized ALU](#project-04--8-bit-parameterized-alu) | `parameter`, carry/overflow detection, `localparam`, `task` | 27/27 |
| 05 | [Priority Encoder + Barrel Shifter](#project-05--priority-encoder--barrel-shifter) | `casez`, `?` don't-care, `<<`/`>>` shift operators, `valid` flag | 16/16 + 31/31 |

---

### Phase 2 — Sequential Logic (Projects 06–10) 🔄 In Progress

Memory elements: flip-flops, counters, registers, FIFOs. Every clocked design
is built from these. The program counter of the RISC-V core is Project 07.

| # | Project | Key concepts | Tests |
|---|---------|-------------|-------|
| 06 | [D / T / JK / SR Flip-Flops](#project-06--d--t--jk--sr-flip-flops) | `always @(posedge clk)`, `<=` non-blocking, synchronous reset, clock generator | 57/57 |
| 07 | [4-bit Synchronous Counter](#project-07--4-bit-synchronous-counter) | Priority chain, terminal count, parallel load, implicit hold | 30/30 |
| 08 | Universal Shift Register | Serial/parallel in-out, mode select, SPI connection | — |
| 09 | Clock Divider | Frequency division, duty cycle, T flip-flop chain | — |
| 10 | Synchronous FIFO | Read/write pointers, full/empty flags, first real memory | — |

---

### Phase 3 — Datapath Components (Projects 11–15) 📋 Planned

The building blocks that plug directly into a CPU datapath.

| # | Project | Key concepts |
|---|---------|-------------|
| 11 | 32×32 Register File | Multi-port memory, simultaneous read/write, the register file of RV32I |
| 12 | Carry-Lookahead Adder | Parallel carry computation, generate/propagate logic, why CLA beats RCA |
| 13 | Booth Multiplier | Signed multiplication, partial products, shift-add algorithm |
| 14 | Array Divider | Restoring division algorithm, quotient/remainder |
| 15 | Floating-Point Adder (IEEE 754) | Exponent alignment, mantissa addition, normalization, rounding |

---

### Phase 4 — CPU Microarchitecture (Projects 16–20) 📋 Planned

Connecting datapath components into a working processor.

| # | Project | Key concepts |
|---|---------|-------------|
| 16 | Single-Cycle RISC-V Datapath | Fetch-decode-execute in one cycle, control signals |
| 17 | Control Unit | Instruction decode, opcode→control signal mapping |
| 18 | Branch & Jump Logic | PC mux, branch comparator, JAL/JALR |
| 19 | Memory Interface | Instruction memory, data memory, load/store alignment |
| 20 | Single-Cycle RV32I Core | Complete RV32I, runs real assembly programs in simulation |

---

### Phase 5 — Pipelined RISC-V (Projects 21–25) 📋 Planned

Industry-level CPU design: pipelining, hazard detection, forwarding.

| # | Project | Key concepts |
|---|---------|-------------|
| 21 | 5-Stage Pipeline Skeleton | IF/ID/EX/MEM/WB stages, pipeline registers |
| 22 | Data Hazard Detection | RAW hazards, stall logic, NOP insertion |
| 23 | Forwarding Unit | EX→EX and MEM→EX bypassing, eliminating most stalls |
| 24 | Branch Hazard & Prediction | Flush logic, static not-taken predictor |
| 25 | Pipelined RV32I Core | Full RV32I with forwarding and hazard control, FPGA-ready |

---

## Project Details

---

### Project 01 — Half Adder & Full Adder

**Files:** `ADDERS/src/` — `half_adder.v`, `full_adder_structural.v`,
`full_adder_dataflow.v`, `full_adder_behavioral.v`

The same full adder written three ways to show how all three Verilog coding
styles produce identical hardware:

```
Gate-level:   uses xor, and, or primitives directly
Dataflow:     uses assign with boolean expressions
Behavioral:   uses always @(*) with procedural code
```

Key insight: the synthesiser produces the same gate netlist from all three.
Style choice is about readability and intent, not the resulting circuit.

---

### Project 02 — 4-bit Ripple Carry Adder

**Files:** `'RIPPLE CARRY ADDER'/src/` — `full_adder.v`, `rca_4bit.v`

Four full adders chained structurally. Carries ripple from LSB to MSB —
each stage must wait for the previous carry to arrive.

```
Cin → [FA0] → c0 → [FA1] → c1 → [FA2] → c2 → [FA3] → Cout
```

Demonstrates the ripple delay problem: worst-case path = N × gate delay.
This motivates the carry-lookahead adder in Project 12.

---

### Project 03 — 4-to-1 Multiplexer

**Files:** `MUX/src/` — `mux4to1_gate.v`, `mux4to1_dataflow.v`,
`mux4to1_behavioral.v`

Three implementations of the same 4-to-1 MUX. The `case` statement version
is the natural way to write decoders, demultiplexers, and ALU operation
selection — it appears in every datapath you will ever design.

---

### Project 04 — 8-bit Parameterized ALU

**Files:** `ALU_8bit/src/alu.v`

Eight operations: ADD, SUB, AND, OR, XOR, NOT, SHL, SHR.
Signed overflow detection, carry-out capture, zero flag, negative flag.

```verilog
module alu #(parameter WIDTH = 8)(...)
```

The `parameter` makes this WIDTH-independent. The RISC-V CPU will use a
32-bit version: `alu #(.WIDTH(32)) cpu_alu(...)`.

---

### Project 05 — Priority Encoder + Barrel Shifter

**Files:** `Encoder_and_Shifter/src/` — `priority_encoder.v`, `barrel_shifter.v`

**Priority encoder:** `casez` with `?` wildcards encodes the highest active
input in a single always block. Used in interrupt controllers (8259A PIC).

**Barrel shifter:** shifts by any amount 0–7 in one gate delay using a 3-stage
MUX tree. The RISC-V SLL/SRL/SRA instructions are implemented with this.

---

### Project 06 — D / T / JK / SR Flip-Flops

**Files:** `Flip_Flops/src/` — `dff.v`, `tff.v`, `srff.v`, `jkff.v`

The four fundamental sequential elements. Key rule introduced here:

```verilog
// combinational — use blocking =
always @(*) result = a & b;

// sequential — use non-blocking <=
always @(posedge clk) q <= d;
```

Breaking the `<=`/`=` rule causes correct simulation but wrong silicon.

---

### Project 07 — 4-bit Synchronous Counter

**Files:** `counter_4bit/src/counter4.v`

```
Priority: rst > load > en > hold
```

Terminal count (`tc`) lets counters chain: `tc` of stage N → `en` of stage N+1.

**Direct RISC-V connection:** the Program Counter is this module with `en=1`
always and `load=1` on branch/jump with `data=branch_target`.

---

## Key Verilog Rules (learned the hard way)

```
1. `timescale must be in every file that uses #delay — not just the TB.

2. Never use `include in source files; list all files on the iverilog command.

3. = in always @(*)   (combinational)
   <= in always @(posedge clk)  (sequential)
   Mixing them causes subtle, hard-to-debug failures in multi-FF designs.

4. Always set default assignments at the TOP of always @(*) blocks
   before case/if — prevents latch inference.

5. Use === not == in testbenches — === detects X and Z, == treats them
   as false and hides uninitialized signal bugs.

6. In clocked blocks, unassigned reg HOLDS (not a latch).
   In combinational blocks, unassigned reg INFERS A LATCH (a bug).
```

---

## Interview relevance

| Company | What they test | Project that covers it |
|---------|---------------|----------------------|
| NVIDIA | Pipelined datapaths, hazard detection, parameterized RTL | 04, 21–25 |
| Texas Instruments | Serial interfaces (SPI/UART), counters, FIFOs | 07, 08, 10 |
| Intel | Full adder variants, CLA, register files, FSMs | 02, 12, 11 |
| All three | `<=` vs `=`, latch inference, synthesis-aware coding | 06, 07+ |

---

