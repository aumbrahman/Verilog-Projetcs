`timescale 1ns/1ps
module mux4to1_dataflow (
        input wire i0, i1, i2, i3,
        input wire [1:0] sel,
        output wire y
);

        assign y = (sel == 2'b00) ? i0 :
                   (sel == 2'b01) ? i1 :
                   (sel == 2'b10) ? i2 :
                                    i3 :
endmodule
