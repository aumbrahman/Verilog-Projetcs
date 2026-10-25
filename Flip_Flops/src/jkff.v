`timescale 1ns/1ps

module jkff (
    input  wire clk,
    input  wire rst,
    input  wire j,
    input  wire k,
    output reg  q,
    output wire q_bar
);
    always @(posedge clk) begin
        if (rst) begin
            q <= 1'b0;
        end else begin
            case ({j, k})
                2'b00: q <= q;     // hold
                2'b10: q <= 1'b1;  // set
                2'b01: q <= 1'b0;  // reset
                2'b11: q <= ~q;    // toggle — the key difference from SR
            endcase
        end
    end

    assign q_bar = ~q;

endmodule
