//  Full Adder — BEHAVIORAL style
//  Uses an always block with a sensitivity list.
//  Outputs must be declared reg because they are assigned
//  inside a procedural block. The simulator re-runs this
//  block whenever a, b, or cin changes.
//  Note: {cout, sum} is concatenation — treats the two 1 bit reg as a 2-bit number


module full_adder_behavioral (
    input  wire a,
    input  wire b,
    input  wire cin,
    output reg  sum,
    output reg  cout
);
    always @(a or b or cin) begin
        {cout, sum} = a + b + cin;

        // The + operator on the RHS gives a 2-bit result.
        // Bit[1] is the carry, Bit[0] is the sum.
    end

endmodule
