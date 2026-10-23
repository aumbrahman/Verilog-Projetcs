`timescale 1ns/1ps
// ============================================================
//  8-bit Barrel Shifter
//
//  Shifts an 8-bit value by ANY amount (0–7) in ONE step.
//  A regular shift does one bit per clock cycle. A barrel
//  shifter uses a tree of multiplexers to do it all at once —
//  that's why CPUs use them. No matter how many bits you shift,
//  it takes the same single gate delay.
//
//  Ports:
//    in      [7:0]  — value to shift
//    shamt   [2:0]  — shift amount: 0 to 7
//    mode           — 0 = shift LEFT, 1 = shift RIGHT
//    out     [7:0]  — shifted result
//
//  How a barrel shifter works internally:
//    It's a 3-stage MUX tree. Each stage handles one bit of shamt:
//      Stage 0: shamt[0]=1 → shift by 1,  else no shift
//      Stage 1: shamt[1]=1 → shift by 2,  else no shift
//      Stage 2: shamt[2]=1 → shift by 4,  else no shift
//    Any combination of stages gives shifts from 0 to 7.
//    Example: shamt=5 (101) → shift 4 + shift 1 = shift 5.
//
//  We implement it behaviorally with << and >> here.
//  The synthesiser will produce the MUX tree automatically.
//
//  Real-world use:
//    RISC-V SLL/SRL/SRA instructions, floating-point exponent
//    alignment, cryptography (AES, SHA rotation).
// ============================================================
module barrel_shifter (
    input  wire [7:0] in,
    input  wire [2:0] shamt,   // shift amount, 0–7
    input  wire       mode,    // 0=left, 1=right
    output reg  [7:0] out
);
    always @(*) begin
        if (mode == 1'b0) begin
            // Logical shift LEFT: zeros fill from the right
            // << is Verilog's left shift operator
            // shamt is 3-bit so maximum shift is 7
            out = in << shamt;
        end else begin
            // Logical shift RIGHT: zeros fill from the left
            // >> is Verilog's logical right shift
            // Arithmetic right shift (>>>) would fill with sign bit
            // We implement logical here — arithmetic comes in the ALU
            out = in >> shamt;
        end
    end

endmodule
