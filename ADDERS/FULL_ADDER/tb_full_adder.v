// ============================================================
//  Testbench — tests all three full adder implementations
//  exhaustively and cross-checks their outputs.
//
//  A good testbench:
//    1. Applies every possible input (exhaustive for small designs)
//    2. Checks outputs automatically (self-checking)
//    3. Reports PASS/FAIL clearly
//    4. Dumps a VCD waveform for GTKWave
// ============================================================
`timescale 1ns/1ps

module tb_full_adder;

    // ── Inputs (reg because we drive them from initial block) ──
    reg a, b, cin;

    // ── Outputs (wire because they are driven by the DUT) ──
    wire sum_s,  cout_s;   // structural
    wire sum_df, cout_df;  // dataflow
    wire sum_bh, cout_bh;  // behavioral

    // ── Instantiate all three designs under test (DUT) ──
    full_adder_structural  DUT_S  (.a(a), .b(b), .cin(cin), .sum(sum_s),  .cout(cout_s));
    full_adder_dataflow    DUT_DF (.a(a), .b(b), .cin(cin), .sum(sum_df), .cout(cout_df));
    full_adder_behavioral  DUT_BH (.a(a), .b(b), .cin(cin), .sum(sum_bh), .cout(cout_bh));

    // ── Waveform dump ──
    initial begin
        $dumpfile("sim/full_adder.vcd");
        $dumpvars(0, tb_full_adder);
    end

    // ── Test variables ──
    integer pass_count;
    integer fail_count;
    integer i;
    reg [1:0] expected;

    // ── Stimulus + self-checking ──
    initial begin
        pass_count = 0;
        fail_count = 0;

        $display("==============================================");
        $display("  Full Adder Exhaustive Testbench");
        $display("  Testing: Structural | Dataflow | Behavioral");
        $display("==============================================");
        $display("  A  B Cin | Sum Cout | Status");
        $display("  --------+---------+--------");

        for (i = 0; i < 8; i = i + 1) begin
            {a, b, cin} = i[2:0];
            #10;  // wait for all combinational paths to settle

            expected = a + b + cin;

            if ({cout_s, sum_s}   === expected &&
                {cout_df, sum_df} === expected &&
                {cout_bh, sum_bh} === expected) begin
                $display("  %b  %b  %b  |   %b    %b   | PASS",
                         a, b, cin, expected[0], expected[1]);
                pass_count = pass_count + 1;
            end else begin
                $display("  %b  %b  %b  |   %b    %b   | FAIL  struct=%b%b  df=%b%b  bh=%b%b",
                         a, b, cin, expected[0], expected[1],
                         sum_s, cout_s, sum_df, cout_df, sum_bh, cout_bh);
                fail_count = fail_count + 1;
            end
        end

        $display("==============================================");
        $display("  Results: %0d PASSED, %0d FAILED", pass_count, fail_count);
        if (fail_count == 0)
            $display("  *** ALL TESTS PASSED ***");
        else
            $display("  *** FAILURES DETECTED — check above ***");
        $display("==============================================");
        $finish;
    end

endmodule
