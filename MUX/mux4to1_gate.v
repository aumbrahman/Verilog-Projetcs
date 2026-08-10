`timescale 1ns/1ps
module mux4to1_gate (
        input wire i0, i1, i2, i3,
        input wire [1:0] sel,'
        output wire y
);

        wire sel0_n, sel1_n:
        not g_inv0 (sel0_n, sel[0]);
        not g_inv1 (sel1_n, sel[1]);
        
        wire t0, t1, t2, t3;
        and g_and0 (t0, sel1_n, sel0_n, i0);
        and g_and1 (t1, sel1_n, sel[0], i1);
        and g_and2 (t2, sel[1], sel0_n, i2);
        and g_and3 (t3, sel[1], sel0_n, i3);

        or g_or (y, t0, t1, t2, t3);

        endmodule
         

