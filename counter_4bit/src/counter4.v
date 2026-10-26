`timescale 1ns/1ps

module counter4 #(
    parameter WIDTH = 4
)(
    input  wire             clk,
    input  wire             rst,    // synchronous reset
    input  wire             en,     // count enable
    input  wire             load,   // parallel load enable
    input  wire [WIDTH-1:0] data,   // parallel load value
    output reg  [WIDTH-1:0] count,  // current count value
    output wire             tc      // terminal count (overflow pulse)
);
    

    always @(posedge clk) begin
        if (rst)
            count <= {WIDTH{1'b0}};       
        else if (load)
            count <= data;                  
        else if (en)
            count <= count + 1'b1;          
    end


    assign tc = (count == {WIDTH{1'b1}}) && en;
 

endmodule
