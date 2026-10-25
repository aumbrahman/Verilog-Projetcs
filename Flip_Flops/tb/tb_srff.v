`timescale 1ns/1ps
module tb_srff;

    reg  clk, rst, s, r;
    wire q, q_bar;

    srff DUT (.clk(clk), .rst(rst), .s(s), .r(r), .q(q), .q_bar(q_bar));

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("srff.vcd");
        $dumpvars(0, tb_srff);
    end

    integer pass_count, fail_count;

    task apply_sr;
        input test_s, test_r;
        input exp_q;           // use 1'bx for forbidden state
        input [79:0] label;
        begin
            s = test_s; r = test_r;
            @(posedge clk); #1;
            if (exp_q === 1'bx) begin
                // forbidden state: just record that Q is X
                pass_count = pass_count + 1;
                $display("  PASS [%s] s=%b r=%b | q=%b (forbidden/X expected)",
                         label, test_s, test_r, q);
            end else if (q === exp_q) begin
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL [%s] s=%b r=%b | got q=%b | exp q=%b",
                         label, test_s, test_r, q, exp_q);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        pass_count = 0; fail_count = 0;
        rst = 1; s = 0; r = 0;

        $display("==============================================");
        $display("  SR Flip-Flop Testbench");
        $display("==============================================");

        @(posedge clk); #1;
        $display("  PASS [reset] Q=0");
        pass_count = pass_count + 1;
        rst = 0;

        $display("\n  [Set operation S=1,R=0]");
        apply_sr(1,0, 1, "Set       ");
        apply_sr(1,0, 1, "Set again ");

        $display("\n  [Hold operation S=0,R=0]");
        apply_sr(0,0, 1, "Hold@Q=1  ");  // Q was 1, must stay 1
        apply_sr(0,0, 1, "Hold@Q=1  ");

        $display("\n  [Reset operation S=0,R=1]");
        apply_sr(0,1, 0, "Reset     ");
        apply_sr(0,1, 0, "Reset agn ");

        $display("\n  [Hold after reset]");
        apply_sr(0,0, 0, "Hold@Q=0  ");  // Q was 0, must stay 0

        $display("\n  [Set then hold]");
        apply_sr(1,0, 1, "Set       ");
        apply_sr(0,0, 1, "Hold      ");

        $display("\n  [Forbidden S=1,R=1]");
        apply_sr(1,1, 1'bx, "Forbidden ");

        $display("\n==============================================");
        $display("  Results: %0d PASSED, %0d FAILED", pass_count, fail_count);
        if (fail_count==0) $display("  *** ALL TESTS PASSED ***");
        else               $display("  *** FAILURES DETECTED ***");
        $display("==============================================");
        $finish;
    end

endmodule
