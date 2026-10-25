`timescale 1ns/1ps

module dff (
    input  wire clk,
    input  wire rst,
    input  wire d,
    output reg  q,
    output wire q_bar
);

    always @(posedge clk) begin
        if (rst)
            q <= 1'b0;   // synchronous reset: clear Q to 0
        else
            q <= d;      // normal operation: Q captures D
    end

    // q_bar is the continuous complement — always the inverse of q
    assign q_bar = ~q;

endmodule
