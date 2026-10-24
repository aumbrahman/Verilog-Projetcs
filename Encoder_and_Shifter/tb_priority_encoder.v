`timescale 1ns/1ps

module tb_priority_encoder;

    reg  [7:0] in;
    wire [2:0] out;
    wire       valid;

    priority_encoder DUT (
        .in    (in),
        .out   (out),
        .valid (valid)
    );

    initial begin
        $dumpfile("priority_encoder.vcd");
        $dumpvars(0, tb_priority_encoder);
    end

    integer i;
    integer pass_count, fail_count;
    reg [2:0] exp_out;
    reg       exp_valid;

    // Task: apply input, wait, check
    task check;
        input [7:0]  test_in;
        input [2:0]  exp_o;
        input        exp_v;
        input [79:0] label;   // 10-char label
        begin
            in = test_in;
            #10;
            if (out === exp_o && valid === exp_v) begin
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL [%s] in=%b | got out=%0d valid=%b | exp out=%0d valid=%b",
                         label, test_in, out, valid, exp_o, exp_v);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        pass_count = 0;
        fail_count = 0;

        $display("==============================================");
        $display("  Priority Encoder 8-to-3 Testbench");
        $display("==============================================");

        // ── Single bit tests ──────────────────────────────────
        $display("\n  [Single bit active]");
        check(8'b00000001, 3'd0, 1, "bit0      ");
        check(8'b00000010, 3'd1, 1, "bit1      ");
        check(8'b00000100, 3'd2, 1, "bit2      ");
        check(8'b00001000, 3'd3, 1, "bit3      ");
        check(8'b00010000, 3'd4, 1, "bit4      ");
        check(8'b00100000, 3'd5, 1, "bit5      ");
        check(8'b01000000, 3'd6, 1, "bit6      ");
        check(8'b10000000, 3'd7, 1, "bit7      ");

        // ── Multiple bits: highest wins ───────────────────────
        $display("\n  [Multiple bits — highest must win]");
        check(8'b00000011, 3'd1, 1, "bits 1,0  ");   // bit1 > bit0
        check(8'b00001111, 3'd3, 1, "bits 3-0  ");   // bit3 wins
        check(8'b10101010, 3'd7, 1, "bits7,5,3 ");   // bit7 wins
        check(8'b01111111, 3'd6, 1, "bits6-0   ");   // bit6 wins
        check(8'b11111111, 3'd7, 1, "all ones  ");   // bit7 wins

        // ── No input active ───────────────────────────────────
        $display("\n  [No input active]");
        check(8'b00000000, 3'd0, 0, "all zeros ");   // valid=0

        // ── Corner: only highest bit ──────────────────────────
        $display("\n  [Corner cases]");
        check(8'b10000000, 3'd7, 1, "only bit7 ");
        check(8'b00000001, 3'd0, 1, "only bit0 ");

        $display("\n==============================================");
        $display("  Results: %0d PASSED, %0d FAILED", pass_count, fail_count);
        if (fail_count == 0)
            $display("  *** ALL TESTS PASSED ***");
        else
            $display("  *** FAILURES DETECTED ***");
        $display("==============================================");

        $finish;
    end

endmodule
