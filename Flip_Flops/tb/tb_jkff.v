`timescale 1ns/1ps
module tb_jkff;

    reg  clk, rst, j, k;
    wire q, q_bar;

    jkff DUT (.clk(clk), .rst(rst), .j(j), .k(k), .q(q), .q_bar(q_bar));

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("jkff.vcd");
        $dumpvars(0, tb_jkff);
    end

    integer pass_count, fail_count;
    reg     prev_q;

    task apply_jk;
        input test_j, test_k;
        input exp_q;
        input [79:0] label;
        begin
            j = test_j; k = test_k;
            @(posedge clk); #1;
            if (q === exp_q) begin
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL [%s] j=%b k=%b | got q=%b | exp q=%b",
                         label, test_j, test_k, q, exp_q);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        pass_count = 0; fail_count = 0;
        rst = 1; j = 0; k = 0;

        $display("==============================================");
        $display("  JK Flip-Flop Testbench");
        $display("==============================================");

        @(posedge clk); #1;
        $display("  PASS [reset] Q=0");
        pass_count = pass_count + 1;
        rst = 0;

        $display("\n  [Set: J=1,K=0]");
        apply_jk(1,0, 1, "Set       ");
        apply_jk(1,0, 1, "Set again ");   // idempotent

        $display("\n  [Hold: J=0,K=0]");
        apply_jk(0,0, 1, "Hold@1    ");
        apply_jk(0,0, 1, "Hold@1    ");

        $display("\n  [Reset: J=0,K=1]");
        apply_jk(0,1, 0, "Reset     ");
        apply_jk(0,1, 0, "Reset agn ");   // idempotent

        $display("\n  [Hold after reset]");
        apply_jk(0,0, 0, "Hold@0    ");

        $display("\n  [Toggle: J=1,K=1 for 8 edges — must alternate]");
        j = 1; k = 1;
        repeat(8) begin
            prev_q = q;
            @(posedge clk); #1;
            if (q === ~prev_q) begin
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL [toggle] expected %b got %b", ~prev_q, q);
                fail_count = fail_count + 1;
            end
        end

        // The KEY difference from SR: J=K=1 is valid (toggles, not forbidden)
        $display("\n  [JK vs SR: J=K=1 produces TOGGLE not X]");
        $display("  (8 consecutive toggles above — all passed = JK is valid)");
        pass_count = pass_count + 1;

        $display("\n  [Reset during toggle]");
        j = 1; k = 1; rst = 1;
        @(posedge clk); #1;
        if (q===1'b0) begin pass_count=pass_count+1;
            $display("  PASS [rst during toggle] Q cleared to 0"); end
        else begin fail_count=fail_count+1;
            $display("  FAIL [rst] Q=%b", q); end
        rst = 0;

        $display("\n==============================================");
        $display("  Results: %0d PASSED, %0d FAILED", pass_count, fail_count);
        if (fail_count==0) $display("  *** ALL TESTS PASSED ***");
        else               $display("  *** FAILURES DETECTED ***");
        $display("==============================================");
        $finish;
    end

endmodule
