//  Testbench — 4-bit Ripple Carry Adder
//
//  Strategy:
//    - Exhaustive: all 256 combinations of A and B (4-bit each)
//    - tested with cin=0 AND cin=1 → 512 total test vectors



`timescale 1ns/1ps

module tb_rca_4bit;

    // Inputs 
    reg  [3:0] a;
    reg  [3:0] b;
    reg        cin;

    // Outputs
    wire [3:0] sum;
    wire       cout;

    // DUT instantiation
    rca_4bit DUT (
        .a   (a),
        .b   (b),
        .cin (cin),
        .sum (sum),
        .cout(cout)
    );

    // Waveform dump 
    initial begin
        $dumpfile("rca_4bit.vcd");
        $dumpvars(0, tb_rca_4bit);
    end

    // Test variables 
    integer i, j;
    integer pass_count, fail_count;
    reg [4:0] expected;   // bit[4]=cout, bits[3]=sum

    // Main stimulus 
    initial begin
        pass_count = 0;
        fail_count = 0;

        $display("-------------------------------------------");
        $display("  4-bit Ripple Carry Adder, exhaustive TB ");
        $display("  Testing all 256x2 that is 512 input vectors");
        $display("--------------------------------------------");

        // Sweep all A, B combinations for both cin values
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin

                // Test with cin = 0
                a   = i[3:0];
                b   = j[3:0];
                cin = 0;
                #20;  // delay

                expected = a + b + cin;  

                if ({cout, sum} === expected) begin
                    pass_count = pass_count + 1;
                end else begin
                    $display("  FAIL: %0d + %0d + cin=%b | got cout=%b sum=%0d | expected cout=%b sum=%0d",
                             a, b, cin, cout, sum, expected[4], expected[3:0]);
                    fail_count = fail_count + 1;
                end

                // Test with cin = 1 
                cin = 1;
                #20;

                expected = a + b + cin;

                if ({cout, sum} === expected) begin
                    pass_count = pass_count + 1;
                end else begin
                    $display("  FAIL: %0d + %0d + cin=%b | got cout=%b sum=%0d | expected cout=%b sum=%0d",
                             a, b, cin, cout, sum, expected[4], expected[3:0]);
                    fail_count = fail_count + 1;
                end

            end
        end

        $display("----------------------------------------------");
        $display("  Results: %0d PASSED, %0d FAILED", pass_count, fail_count);
        if (fail_count == 0)
            $display("  *** ALL 512 TESTS PASSED ***");
        else
            $display("  *** FAILURES DETECTED recheck ***");
        $display("------------------------------------------------");

        // ── Interesting corner cases: print these explicitly ──
        $display("");
        $display("  Corner case spot-check:");
        $display("  ----------------------");

        a = 4'b1111; b = 4'b0001; cin = 0; #20;  // 15 + 1 = 16 → sum=0, cout=1
        $display("  15 + 1  = sum=%0d, cout=%b  (expect sum=0, cout=1)", sum, cout);

        a = 4'b1111; b = 4'b1111; cin = 0; #20;  // 15 + 15 = 30 → sum=14, cout=1
        $display("  15 + 15 = sum=%0d, cout=%b  (expect sum=14, cout=1)", sum, cout);

        a = 4'b0111; b = 4'b0001; cin = 0; #20;  // 7 + 1 = 8 → no overflow
        $display("  7  + 1  = sum=%0d, cout=%b  (expect sum=8, cout=0)", sum, cout);

        a = 4'b0000; b = 4'b0000; cin = 0; #20;  // 0 + 0 = 0
        $display("  0  + 0  = sum=%0d, cout=%b  (expect sum=0, cout=0)", sum, cout);

        $finish;
    end

endmodule
