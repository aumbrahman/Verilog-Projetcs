//  Full Adder — STRUCTURAL style
//  Built from two half adders and one OR gate.
//  Describing CONNECTIONS between modules, not logic.
//
//  Architecture:
//       A, B  ──► [HA1] ──► sum1, c1
//       sum1, Cin ──► [HA2] ──► Sum, c2
//       c1, c2 ──► [OR] ──► Cout


module full_adder_structural (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);
    // Internal wires connecting the two half adders
    wire sum1;   
    wire c1;     
    wire c2;     

    half_adder HA1 (
        .a     (a),
        .b     (b),
        .sum   (sum1),
        .carry (c1)
    );

    // Second half adder: adds intermediate sum with Cin
    half_adder HA2 (
        .a     (sum1),
        .b     (cin),
        .sum   (sum),
        .carry (c2)
    );
        
        or g_cout (cout, c1, c2);

endmodule
