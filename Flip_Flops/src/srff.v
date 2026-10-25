`timescale 1ns/1ps

module srff (
    input  wire clk,
    input  wire rst,
    input  wire s,
    input  wire r,
    output reg  q,
    output wire q_bar
);
    always @(posedge clk) begin
        if (rst) begin
            q <= 1'b0;
        end else begin
            case ({s, r})          // bundle s and r into 2-bit case
                2'b00: q <= q;     // hold: no change
                2'b10: q <= 1'b1;  // set
                2'b01: q <= 1'b0;  // reset
                2'b11: q <= 1'bx;  // forbidden: mark as unknown
            endcase
        end
    end

    assign q_bar = ~q;

endmodule
