`timescale 1ns/1ps
// ============================================================
//  Testbench — Universal Shift Register
//
//  Test plan:
//    1. Reset clears all bits to 0
//    2. Parallel load — load a known pattern
//    3. Shift right — verify each bit moves right, sin_r feeds MSB
//    4. sout_r captures the bit shifted out of LSB
//    5. Shift left — verify each bit moves left, sin_l feeds LSB
//    6. sout_l captures the bit shifted out of MSB
//    7. Hold — data unchanged across multiple cycles
//    8. SPI simulation — load 0xA5, shift out MSB-first (8 clocks)
//    9. Reset mid-operation clears everything
// ============================================================
module tb_shift_reg;

    // ── DUT signals ──────────────────────────────────────────
    reg        clk, rst, sin_r, sin_l;
    reg  [1:0] mode;
    reg  [7:0] din;
    wire [7:0] data;
    wire       sout_r, sout_l;

    // ── Mode encoding — local params for readability ──────────
    localparam HOLD = 2'b00,
               SHR  = 2'b01,
               SHL  = 2'b10,
               LOAD = 2'b11;

    // ── Instantiate ──────────────────────────────────────────
    shift_reg #(.WIDTH(8)) DUT (
        .clk    (clk),
        .rst    (rst),
        .mode   (mode),
        .sin_r  (sin_r),
        .sin_l  (sin_l),
        .din    (din),
        .data   (data),
        .sout_r (sout_r),
        .sout_l (sout_l)
    );

    // ── Clock ────────────────────────────────────────────────
    initial clk = 0;
    always #5 clk = ~clk;

    // ── VCD ──────────────────────────────────────────────────
    initial begin
        $dumpfile("sim/shift_reg.vcd");
        $dumpvars(0, tb_shift_reg);
    end

    // ── Counters ─────────────────────────────────────────────
    integer pass_count, fail_count;

    // ── Task: tick one clock, then check data ────────────────
    task tick_check_data;
        input [7:0] exp_data;
        input [79:0] label;
        begin
            @(posedge clk); #1;
            if (data === exp_data) begin
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL [%s] got=8'b%b (%h) | exp=8'b%b (%h)",
                         label, data, data, exp_data, exp_data);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // ── Task: tick one clock, check data AND serial outs ─────
    task tick_check_full;
        input [7:0] exp_data;
        input       exp_sout_r, exp_sout_l;
        input [79:0] label;
        begin
            @(posedge clk); #1;
            if (data === exp_data &&
                sout_r === exp_sout_r &&
                sout_l === exp_sout_l) begin
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL [%s] data=%b sr=%b sl=%b | exp data=%b sr=%b sl=%b",
                         label, data, sout_r, sout_l,
                         exp_data, exp_sout_r, exp_sout_l);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // ── Stimulus ─────────────────────────────────────────────
    initial begin
        pass_count = 0; fail_count = 0;
        rst = 1; mode = HOLD; sin_r = 0; sin_l = 0; din = 8'h00;

        $display("==============================================");
        $display("  Universal Shift Register Testbench");
        $display("==============================================");

        // ── 1. Reset ─────────────────────────────────────────
        $display("\n  [1. Reset]");
        tick_check_data(8'h00, "reset      ");
        rst = 0;

        // ── 2. Parallel load ──────────────────────────────────
        $display("\n  [2. Parallel load]");
        mode = LOAD; din = 8'b10110001;
        tick_check_full(8'b10110001, 1'b1, 1'b1, "load B1    ");
        // sout_r = data[0] = 1, sout_l = data[7] = 1
        mode = HOLD;

        // ── 3. Shift right ────────────────────────────────────
        // Start: data = 10110001
        // sin_r = 0 → new MSB is 0 each time
        // After 1 shift right: 0_1011000 → 01011000
        // After 2: 0_0101100  → 00101100
        // After 3: 0_0010110  → 00010110
        // After 4: 0_0001011  → 00001011
        $display("\n  [3. Shift right (sin_r=0)]");
        mode = SHR; sin_r = 0;
        tick_check_full(8'b01011000, 1'b0, 1'b0, "shr x1     ");
        tick_check_full(8'b00101100, 1'b0, 1'b0, "shr x2     ");
        tick_check_full(8'b00010110, 1'b0, 1'b0, "shr x3     ");
        tick_check_full(8'b00001011, 1'b1, 1'b0, "shr x4     ");
        // sout_r = data[0] = 1 after 4th shift

        // ── 4. Shift right with sin_r = 1 ────────────────────
        $display("\n  [4. Shift right, sin_r=1 (1s fill from left)]");
        mode = LOAD; din = 8'b00001111;
        @(posedge clk); #1;         // reload without checking
        mode = SHR; sin_r = 1;
        tick_check_full(8'b10000111, 1'b1, 1'b1, "shr sin1 x1");
        tick_check_full(8'b11000011, 1'b1, 1'b1, "shr sin1 x2");
        tick_check_full(8'b11100001, 1'b1, 1'b1, "shr sin1 x3");

        // ── 5. Shift left ─────────────────────────────────────
        // Load: 10110001, sin_l=0
        // After 1 shl: 0110001_0 → 01100010
        // After 2 shl: 1100010_0 → 11000100
        // After 3 shl: 1000100_0 → 10001000
        $display("\n  [5. Shift left (sin_l=0)]");
        mode = LOAD; din = 8'b10110001;
        @(posedge clk); #1;
        mode = SHL; sin_l = 0;
        tick_check_full(8'b01100010, 1'b0, 1'b0, "shl x1     ");
        tick_check_full(8'b11000100, 1'b0, 1'b1, "shl x2     ");
        // sout_l = data[7] = 1 after x2
        tick_check_full(8'b10001000, 1'b0, 1'b1, "shl x3     ");

        // ── 6. Hold ───────────────────────────────────────────
        $display("\n  [6. Hold — data unchanged for 4 cycles]");
        mode = LOAD; din = 8'hA5;
        @(posedge clk); #1;   // load 0xA5
        mode = HOLD;
        tick_check_data(8'hA5, "hold cy1   ");
        tick_check_data(8'hA5, "hold cy2   ");
        tick_check_data(8'hA5, "hold cy3   ");
        tick_check_data(8'hA5, "hold cy4   ");

        // ── 7. SPI simulation ─────────────────────────────────
        // Load 0xA5 = 10100101, then shift out MSB-first
        // (shift LEFT, sin_l=0, read sout_l each cycle)
        // Expected sout_l sequence: 1,0,1,0,0,1,0,1
        $display("\n  [7. SPI sim: transmit 0xA5 MSB-first via sout_l]");
        mode = LOAD; din = 8'hA5;   // 10100101
        @(posedge clk); #1;
        mode = SHL; sin_l = 0;

        begin : spi_loop
            integer bit_idx;
            reg [7:0] captured;

            // SPI transmit: read sout_l BEFORE each shift edge.
            // sout_l = data[7] combinationally — it reflects the current MSB.
            // The shift moves data on the posedge, so sample BEFORE the edge.
            // We already loaded 0xA5; now sample, then tick, 8 times.
            captured = 8'h00;
            for (bit_idx = 7; bit_idx >= 0; bit_idx = bit_idx - 1) begin
                // 1. Sample sout_l NOW (before the edge) — this is the bit to send
                captured[bit_idx] = sout_l;
                // 2. Clock the shift register — shifts data left, sout_l updates
                @(posedge clk); #1;
            end
            // After 8 shifts, data = 8'h00 (all shifted out, sin_l=0 filled zeros)
            if (data === 8'h00)
                pass_count = pass_count + 1;
            else begin
                $display("  FAIL [SPI] after 8 shifts data=%h, exp 00", data);
                fail_count = fail_count + 1;
            end
            $display("  INFO [SPI] transmitted byte (MSB-first sout_l): %b = 8'h%h",
                     captured, captured);
            if (captured === 8'hA5) begin
                pass_count = pass_count + 1;
                $display("  PASS [SPI] captured byte matches 0xA5");
            end else begin
                fail_count = fail_count + 1;
                $display("  FAIL [SPI] captured=%h, expected A5", captured);
            end
        end

        // ── 8. Reset mid-operation ────────────────────────────
        $display("\n  [8. Reset mid-operation]");
        mode = LOAD; din = 8'hFF;
        @(posedge clk); #1;   // load FF
        rst = 1; mode = SHL;
        tick_check_data(8'h00, "rst mid-op ");
        rst = 0;

        // ── Results ──────────────────────────────────────────
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
