`timescale 1ns / 1ps

module tb_half_adder;

    // declare ports
    reg  A;
    reg  B;
    wire Sum;
    wire Carry;
		// instantiation
        .A(a),
        .B(b),
        .Sum(sum),
        .Carry(carry)
    );

    // track vcd
        $dumpfile("half_adder_wave.vcd"); // Creates the VCD file
        $dumpvars(0, tb_half_adder);       // Records all variables in this testbench
        
        // test cases
        $display("Time\t A \t B \t Sum \t Carry");
        $monitor("%0t\t %b \t %b \t  %b  \t   %b", $time, A, B, Sum, Carry);

        // Case 1, 0 + 0
        A = 0; B = 0;
        #10; 
        
        // Case 2, 0 + 1
        A = 0; B = 1;
        #10;
        
        // Case 3: 1 + 0
        A = 1; B = 0;
        #10;
        
        // Case 4: 1 + 1
        A = 1; B = 1;
        #10;
        
        $finish;
    end

endmodule

