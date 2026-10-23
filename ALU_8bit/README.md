# Parameterized ALU in Verilog

A simple, parameterized Arithmetic Logic Unit (ALU) designed using Verilog HDL. The ALU supports arithmetic, logical, and shift operations on configurable-width binary operands.

This project is part of my journey into **digital design, RTL development, and VLSI design**.

## Features

- Configurable data width using Verilog parameters.
- Arithmetic operations: Addition and Subtraction.
- Logical operations: AND, OR, XOR, and NOT.
- Shift operations: Logical Shift Left and Logical Shift Right.
- Status flags: Zero, Carry, Overflow, and Negative.
- Combinational logic implemented using `always @(*)`.
- Compatible with Icarus Verilog for simulation.

## Supported Operations

The ALU uses a 3-bit opcode (`op`) to select an operation.

| Opcode | Operation | Description |
|:---:|---|---|
| `000` | ADD | Adds operands `a` and `b` |
| `001` | SUB | Subtracts `b` from `a` |
| `010` | AND | Performs bitwise AND |
| `011` | OR | Performs bitwise OR |
| `100` | XOR | Performs bitwise XOR |
| `101` | NOT | Performs bitwise NOT on `a` |
| `110` | SHL | Shifts `a` left by one bit |
| `111` | SHR | Shifts `a` right by one bit |

## Module Interface

### Parameters

| Parameter | Default Value | Description |
|---|:---:|---|
| `WIDTH` | 8 | Width of the input operands and result |

### Inputs

| Signal | Width | Description |
|---|---|---|
| `a` | `WIDTH` bits | First operand |
| `b` | `WIDTH` bits | Second operand |
| `op` | 3 bits | Operation selector |

### Outputs

| Signal | Width | Description |
|---|---|---|
| `result` | `WIDTH` bits | Result of the selected operation |
| `zero` | 1 bit | High when the result is zero |
| `carry` | 1 bit | Carry or shift-out bit, depending on the operation |
| `overflow` | 1 bit | Signed arithmetic overflow indicator |
| `negative` | 1 bit | Most significant bit of the result |

## Status Flags

### 1. Zero Flag (`zero`)

Set to `1` when the result is zero.

```verilog
assign zero = (result == {WIDTH{1'b0}});
```

### 2. Negative Flag (`negative`)

Indicates the most significant bit of the result.

```verilog
assign negative = result[WIDTH-1];
```

For two's-complement signed interpretation, this bit indicates whether the result is negative.

### 3. Carry Flag (`carry`)

- **ADD:** Indicates the carry-out bit.
- **SUB:** Takes the most significant bit of the extended subtraction result. This is not the conventional no-borrow carry flag used by every processor.
- **SHL:** Captures the original most significant bit of `a`.
- **SHR:** Captures the original least significant bit of `a`.
- **Logical operations:** Cleared to `0`.

**Note:** The subtraction carry convention differs between architectures. For example, some processors define the subtraction carry flag as indicating *no borrow*, while this implementation directly uses the extended subtraction's most significant bit.

### 4. Overflow Flag (`overflow`)

Indicates signed arithmetic overflow during addition and subtraction.

- **Addition:** Overflow occurs when the operands have the same sign but the result has a different sign.
- **Subtraction:** Overflow occurs when the operands have different signs and the result's sign differs from the sign of `a`.

The overflow flag is cleared for logical and shift operations.

## Example

Consider an 8-bit ALU with the following inputs:

```verilog
a  = 8'd10;
b  = 8'd5;
op = 3'b000;
```

The selected operation is addition.

**Calculation:**

```text
a      = 00001010  (10)
b      = 00000101  (5)
---------------------
result = 00001111  (15)
```

Expected outputs:

| Signal | Value |
|---|---|
| `result` | `8'd15` |
| `zero` | `0` |
| `carry` | `0` |
| `overflow` | `0` |
| `negative` | `0` |

## Simulation Using Icarus Verilog

You can simulate the ALU using Icarus Verilog on Linux.

### Prerequisites

Install Icarus Verilog and GTKWave on Ubuntu:

```bash
sudo apt update
sudo apt install iverilog gtkwave
```

### Project Structure

```text
ALU/
├── alu.v
├── alu_tb.v
└── README.md
```

- `alu.v` — ALU RTL implementation.
- `alu_tb.v` — Testbench for verifying ALU operations.
- `README.md` — Project documentation.

### Compile the Design

After creating your testbench, run:

```bash
iverilog -g2012 -o alu_sim alu.v alu_tb.v
```

### Run the Simulation

```bash
vvp alu_sim
```

### Generate and View Waveforms

If your testbench generates a VCD file, such as `alu.vcd`, open it with:

```bash
gtkwave alu.vcd
```

A waveform viewer helps you inspect input operands, opcodes, results, and status flags over simulation time.

## Design Methodology

The ALU is implemented using combinational logic.

1. Default values are assigned to internal registers and flags.
2. A `case` statement selects the operation using the opcode.
3. The selected operation computes the extended result.
4. The lower `WIDTH` bits are assigned to the output.
5. Continuous assignments generate the zero and negative flags.

The internal `full_result` register is `WIDTH+1` bits wide, allowing the design to retain an additional bit for arithmetic carry or shift operations.

## Possible Improvements

Future improvements to this project include:

- Developing a self-checking testbench for all eight operations.
- Testing parameter configurations such as 8-bit, 16-bit, and 32-bit ALUs.
- Adding comparison operations such as equality and less-than.
- Adding arithmetic right shift.
- Standardizing subtraction carry and borrow behavior.
- Integrating the ALU into a processor datapath.
- Synthesizing the design for FPGA implementation.

## Learning Outcomes

Through this project, I am exploring:

- Combinational RTL design using Verilog.
- Parameterized hardware modules.
- Arithmetic and bitwise operations.
- Signed overflow detection.
- Status flag generation.
- RTL simulation and waveform analysis.

## Tools Used

- **Language:** Verilog HDL
- **Simulator:** Icarus Verilog
- **Waveform Viewer:** GTKWave
- **Operating System:** Ubuntu Linux

## Author

Developed as part of my learning journey in digital electronics, Verilog HDL, and VLSI design.
