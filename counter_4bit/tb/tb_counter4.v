`timescale 1ns/1ps

module tb_counter4;

    // DUT signals
    reg        clk, rst, en, load;
    reg  [3:0] data;
    wire [3:0] count;
    wire       tc;

    // Instantiate DUT 
    counter4 #(.WIDTH(4)) DUT (
        .clk   (clk),
        .rst   (rst),
        .en    (en),
        .load  (load),
        .data  (data),
        .count (count),
        .tc    (tc)
    );

    // Clock: 10ns period (100 MHz) 
    initial clk = 0;
    always #5 clk = ~clk;

    // VCD 
    initial begin
        $dumpfile("sim/counter4.vcd");
        $dumpvars(0, tb_counter4);
    end

    //Helpers
    integer pass_count, fail_count;

    // Wait one clock edge, then check count and tc
    task tick_and_check;
        input [3:0] exp_count;
        input       exp_tc;
        input [79:0] label;
        begin
            @(posedge clk); #1;
            if (count === exp_count && tc === exp_tc) begin
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL [%s] | got count=%0d tc=%b | exp count=%0d tc=%b",
                         label, count, tc, exp_count, exp_tc);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // Stimulus
    initial begin
        pass_count = 0; fail_count = 0;
        rst = 1; en = 0; load = 0; data = 4'd0;

        $display("==============================================");
        $display("  4-bit Counter Testbench");
        $display("==============================================");

        // Reset
        $display("\n  [1. Synchronous reset]");
        tick_and_check(4'd0, 1'b0, "rst        ");
        rst = 0;

        // Free count 0→15 
        $display("\n  [2. Free count: 0 to 15]");
        en = 1;
        // count was 0 after reset; now tick 16 times
        // after tick 1: count=1, after tick 2: count=2 ...
        // after tick 15: count=15 (tc should be 1 because en=1)
        // after tick 16: count=0 (wrap)
        begin : count_loop
            integer i;
            for (i = 1; i <= 15; i = i + 1) begin
                // tc is high when count==15 AND en==1
                // that means tc goes high WHILE count IS 15 (before next edge)
                // so at tick that produces count=15, tc=1
                tick_and_check(i[3:0], (i==15) ? 1'b1 : 1'b0, "free count ");
            end
        end

        // Wrap-around 
        $display("\n  [3. Wrap-around: 15 → 0]");
        // count is now 15, tc=1; one more tick → count=0, tc=0
        tick_and_check(4'd0, 1'b0, "wrap 15→0  ");

        // ── 4. Terminal count details ─────────────────────────
        $display("\n  [4. Terminal count — tc only when en=1]");
        // Count up to 14
        begin : tc_loop
            integer j;
            for (j = 0; j < 14; j = j + 1)
                @(posedge clk);  // just advance, no check needed
        end
        #1;
        // count should now be 14; en still 1
        // one more tick → count=15, tc=1
        tick_and_check(4'd15, 1'b1, "tc at 15   ");

        // Now disable en — tc must go LOW even though count==15
        en = 0;
        #1;  // combinational: tc = count==15 AND en → should be 0 immediately
        if (tc === 1'b0) begin
            pass_count = pass_count + 1;
            $display("  PASS [tc gated] tc=0 when en=0 even at count=15");
        end else begin
            fail_count = fail_count + 1;
            $display("  FAIL [tc gated] tc=%b, expected 0", tc);
        end

        // Enable gate

        $display("\n  [5. Enable gate — count freezes when en=0]");
        // count is 15, en=0; tick 4 times — count must stay 15
        repeat(4) begin
            @(posedge clk); #1;
            if (count === 4'd15) pass_count = pass_count + 1;
            else begin
                fail_count = fail_count + 1;
                $display("  FAIL [en=0 hold] count=%0d, expected 15", count);
            end
        end
        $display("  PASS [en=0 hold] count stayed 15 for 4 cycles");

        //Parallel load
        $display("\n  [6. Parallel load]");
        load = 1; data = 4'd7; en = 0;
        tick_and_check(4'd7, 1'b0, "load=7     ");
        load = 0;

        load = 1; data = 4'd0;
        tick_and_check(4'd0, 1'b0, "load=0     ");
        load = 0;

        load = 1; data = 4'd15;
        tick_and_check(4'd15, 1'b0, "load=15    ");  // en=0 → tc=0 even at 15
        load = 0;

        $display("\n  [7. Load=5, then count up]");
        load = 1; data = 4'd5; en = 0;
        @(posedge clk); #1; load = 0;  // count = 5
        en = 1;
        tick_and_check(4'd6,  1'b0, "5+1=6      ");
        tick_and_check(4'd7,  1'b0, "6+1=7      ");
        tick_and_check(4'd8,  1'b0, "7+1=8      ");


        $display("\n  [8. Reset beats load and en simultaneously]");
        en = 1; load = 1; data = 4'd9; rst = 1;
        tick_and_check(4'd0, 1'b0, "rst wins   ");  // rst overrides load+en
        rst = 0; en = 0; load = 0;


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
