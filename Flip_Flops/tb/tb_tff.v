`timescale 1ns/1ps
module tb_tff;

    reg  clk, rst, t;
    wire q, q_bar;

    tff DUT (.clk(clk), .rst(rst), .t(t), .q(q), .q_bar(q_bar));

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("tff.vcd");
        $dumpvars(0, tb_tff);
    end

    integer pass_count, fail_count;
    reg     prev_q;

    task check_q;
        input exp_q;
        input [79:0] label;
        begin
            #1;
            if (q === exp_q) begin
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL [%s] t=%b | got q=%b | exp q=%b",
                         label, t, q, exp_q);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        pass_count = 0; fail_count = 0;
        rst = 1; t = 0;

        $display("==============================================");
        $display("  T Flip-Flop Testbench");
        $display("==============================================");

        // reset → Q=0
        @(posedge clk); #1;
        if (q===1'b0) begin pass_count=pass_count+1;
            $display("  PASS [reset] Q=0"); end
        else begin fail_count=fail_count+1;
            $display("  FAIL [reset] Q=%b", q); end
        rst = 0;

        // T=0: Q must HOLD for 4 consecutive edges
        $display("\n  [T=0: hold for 4 edges]");
        t = 0;
        repeat(4) begin
            prev_q = q;
            @(posedge clk);
            check_q(prev_q, "T=0 hold  ");
        end

        // T=1: Q must TOGGLE on every edge
        $display("\n  [T=1: toggle for 8 edges]");
        t = 1;
        repeat(8) begin
            prev_q = q;
            @(posedge clk);
            check_q(~prev_q, "T=1 toggle");
        end

        // Alternate T=0/T=1 to confirm selective toggling
        $display("\n  [Alternating T]");
        t = 0; @(posedge clk); check_q(q, "alt T=0   ");
        t = 1; prev_q = q; @(posedge clk); check_q(~prev_q, "alt T=1   ");
        t = 0; @(posedge clk); check_q(q, "alt T=0   ");
        t = 1; prev_q = q; @(posedge clk); check_q(~prev_q, "alt T=1   ");

        // Reset clears Q regardless of T
        $display("\n  [Reset clears Q]");
        t = 1; rst = 1;
        @(posedge clk); #1;
        if (q===1'b0) begin pass_count=pass_count+1;
            $display("  PASS [rst mid-op] Q cleared"); end
        else begin fail_count=fail_count+1;
            $display("  FAIL [rst mid-op] Q=%b", q); end
        rst = 0;

        $display("\n==============================================");
        $display("  Results: %0d PASSED, %0d FAILED", pass_count, fail_count);
        if (fail_count==0) $display("  *** ALL TESTS PASSED ***");
        else               $display("  *** FAILURES DETECTED ***");
        $display("==============================================");
        $finish;
    end

endmodule
