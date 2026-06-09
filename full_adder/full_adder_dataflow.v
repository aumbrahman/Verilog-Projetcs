// DATA FLOW STYLE for full adder
// using assign statements

// here we rather think in equation than gates


module full_adder_dataflow (
	input wire a,
	input wire b,
	input wire c_in,
	output wire sum,
	output wire c_out
	);

	assign sum = a ^ b ^ c_in;
	assign c_out = (a & b) | (b & c_in) | (a & c_in);

endmodule
