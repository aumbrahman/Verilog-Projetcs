`timescale 1ns/1ps

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
