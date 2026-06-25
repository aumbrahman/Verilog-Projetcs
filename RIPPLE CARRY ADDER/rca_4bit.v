module full_adder(
    input a,
    input b,
    input cin,
    output sum,
    output cout
);

assign sum  = a ^ b ^ cin;
assign cout = (a & b) | (b & cin) | (a & cin);

endmodule

module rca_4bit (
        input wire [3:0] a,
        input wire [3:0] b,
        input wire cin,
        output wire [3:0] sum,
        output wire cout
);

//internal wirs
wire c1, c2, c3;

//instantiating 4 full adders, because 4 bit ripple carry adderhas 4 full adders, summing each bit it requires a adder

full_adder FA0 (
        .a (a[0]),
        .b (b[0]),
        .cin (cin),
        .sum (sum[0]),
        .cout (c1)
);

full_adder FA1 (
        .a (a[1]),
        .b (b[1]),
        .cin (c1),
        .sum (sum[1]),
        .cout (c2)
);

full_adder FA2 (
        .a (a[2]),
        .b (b[2]),
        .cin (c2),
        .sum (sum[2]),
        .cout (c3)
);

full_adder FA3 (
        .a (a[3]),
        .b (b[3]),
        .cin (c3),
        .sum (sum[3]),
        .cout (cout)
);

endmodule
