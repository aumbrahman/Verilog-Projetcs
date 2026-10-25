`timescale 1ns/1ps

module tb_dff;


    reg  clk, rst, d;
    wire q, q_bar;


    dff DUT (
        .clk   (clk),
        .rst   (rst),
        .d     (d),
        .q     (q),
        .q_bar (q_bar)
    );


    initial clk = 0;
    always #5 clk = ~clk;

    // ── VCD waveform ─────────────────────────────────────────
    initial begin
        $dumpfile("dff.vcd");
        $dumpvars(0, tb_dff);
    end

    // ── Counters ─────────────────────────────────────────────
    integer pass_count, fail_count;

    // ── Task: apply d, wait one edge, check q ────────────────
    task apply_and_check;
        input test_d;
        input exp_q;
        input [79:0] label;
        begin
            d = test_d;
            @(posedge clk);   // wait for the rising edge
            #1;               // tiny delay: let the flip-flop output settle
            if (q === exp_q && q_bar === ~exp_q) begin
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL [%s] d=%b | got q=%b q_bar=%b | exp q=%b",
                         label, test_d, q, q_bar, exp_q);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // ── Stimulus ─────────────────────────────────────────────
    initial begin
        pass_count = 0;
        fail_count = 0;
        rst = 1; d = 0;

        $display("==============================================");
        $display("  D Flip-Flop Testbench");
        $display("==============================================");

        // ── Reset behaviour ──────────────────────────────────
        $display("\n  [Synchronous reset]");
        d = 1;
        @(posedge clk); #1;    // first edge: rst=1 → Q must be 0
        if (q === 1'b0) begin
            pass_count = pass_count + 1;
            $display("  PASS [rst active] q=0 as expected");
        end else begin
            fail_count = fail_count + 1;
            $display("  FAIL [rst active] q=%b, expected 0", q);
        end

        rst = 0;   // release reset

        // ── Normal D→Q capture ───────────────────────────────
        $display("\n  [D captures into Q]");
        apply_and_check(1'b0, 1'b0, "D=0       ");
        apply_and_check(1'b1, 1'b1, "D=1       ");
        apply_and_check(1'b1, 1'b1, "D=1 hold  ");
        apply_and_check(1'b0, 1'b0, "D=0 again ");
        apply_and_check(1'b1, 1'b1, "D=1 again ");

        // ── Q holds between edges ────────────────────────────
        // Set Q=1, then change D between edges — Q must not change
        $display("\n  [Q holds between edges]");
        d = 1;
        @(posedge clk); #1;    // Q = 1
        d = 0;                 // change D BETWEEN edges
        #3;                    // wait 3ns (well before next edge)
        if (q === 1'b1) begin
            pass_count = pass_count + 1;
            $display("  PASS [hold] D changed mid-cycle, Q stayed 1");
        end else begin
            fail_count = fail_count + 1;
            $display("  FAIL [hold] Q changed when it shouldn't have");
        end

        // ── Reset in the middle of operation ─────────────────
        $display("\n  [Reset mid-operation]");
        d = 1;
        @(posedge clk); #1;   // Q = 1
        rst = 1;
        @(posedge clk); #1;   // reset active: Q must go to 0
        if (q === 1'b0) begin
            pass_count = pass_count + 1;
            $display("  PASS [mid-reset] Q cleared to 0");
        end else begin
            fail_count = fail_count + 1;
            $display("  FAIL [mid-reset] Q=%b, expected 0", q);
        end
        rst = 0;

        // ── q_bar is always complement ────────────────────────
        $display("\n  [q_bar verification]");
        apply_and_check(1'b0, 1'b0, "qbar D=0  ");
        apply_and_check(1'b1, 1'b1, "qbar D=1  ");

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
