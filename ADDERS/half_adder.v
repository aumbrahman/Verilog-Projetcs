//half adder
// add two 1 bit no.
// sum = A XOR B
// CARRY = A AND B

module half_add (
	input wire a,
	input wire b,
	output wire sum,
	output wire carry
	);

	// gate level style

	xor a_sum (sum, a,b);
	and a_carry (carry, a,b);

endmodule
