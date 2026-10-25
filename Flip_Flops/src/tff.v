`timescale 1ns/1ps

module tff (
    input  wire clk,
    input  wire rst,
    input  wire t,
    output reg  q,
    output wire q_bar
);
    always @(posedge clk) begin
        if (rst)
            q <= 1'b0;
        else if (t)
            q <= ~q;    // toggle: flip the current value
        // implicit else: t=0, q holds (no assignment needed —
        // in a clocked always block, unassigned reg holds its value)
    end

    assign q_bar = ~q;

endmodule
