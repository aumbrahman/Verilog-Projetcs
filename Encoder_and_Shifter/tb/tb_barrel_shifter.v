`timescale 1ns/1ps

module tb_barrel_shifter;

    reg  [7:0] in;
    reg  [2:0] shamt;
    reg        mode;
    wire [7:0] out;

    barrel_shifter DUT (
        .in    (in),
        .shamt (shamt),
        .mode  (mode),
        .out   (out)
    );

    initial begin
        $dumpfile("barrel_shifter.vcd");
        $dumpvars(0, tb_barrel_shifter);
    end

    integer   i;
    integer   pass_count, fail_count;
    reg [7:0] expected;

    task check;
        input [7:0]  test_in;
        input [2:0]  test_shamt;
        input        test_mode;
        input [7:0]  exp;
        input [79:0] label;
        begin
            in    = test_in;
            shamt = test_shamt;
            mode  = test_mode;
            #10;
            if (out === exp) begin
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL [%s] in=%b shamt=%0d mode=%b | got=%b | exp=%b",
                         label, test_in, test_shamt, test_mode, out, exp);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        pass_count = 0;
        fail_count = 0;

        $display("==============================================");
        $display("  Barrel Shifter 8-bit Testbench");
        $display("==============================================");

        // ── Shift LEFT: all amounts on 8'b00000001 ────────────
        $display("\n  [Shift LEFT — in=00000001]");
        check(8'b00000001, 3'd0, 0, 8'b00000001, "SHL 1<<0  ");
        check(8'b00000001, 3'd1, 0, 8'b00000010, "SHL 1<<1  ");
        check(8'b00000001, 3'd2, 0, 8'b00000100, "SHL 1<<2  ");
        check(8'b00000001, 3'd3, 0, 8'b00001000, "SHL 1<<3  ");
        check(8'b00000001, 3'd4, 0, 8'b00010000, "SHL 1<<4  ");
        check(8'b00000001, 3'd5, 0, 8'b00100000, "SHL 1<<5  ");
        check(8'b00000001, 3'd6, 0, 8'b01000000, "SHL 1<<6  ");
        check(8'b00000001, 3'd7, 0, 8'b10000000, "SHL 1<<7  ");

        // ── Shift LEFT: pattern test ──────────────────────────
        $display("\n  [Shift LEFT — in=10110011]");
        check(8'b10110011, 3'd0, 0, 8'b10110011, "SHL B3<<0 ");
        check(8'b10110011, 3'd1, 0, 8'b01100110, "SHL B3<<1 ");
        check(8'b10110011, 3'd2, 0, 8'b11001100, "SHL B3<<2 ");
        check(8'b10110011, 3'd4, 0, 8'b00110000, "SHL B3<<4 ");
        check(8'b10110011, 3'd7, 0, 8'b10000000, "SHL B3<<7 ");

        // ── Shift RIGHT: all amounts on 8'b10000000 ───────────
        $display("\n  [Shift RIGHT — in=10000000]");
        check(8'b10000000, 3'd0, 1, 8'b10000000, "SHR 80>>0 ");
        check(8'b10000000, 3'd1, 1, 8'b01000000, "SHR 80>>1 ");
        check(8'b10000000, 3'd2, 1, 8'b00100000, "SHR 80>>2 ");
        check(8'b10000000, 3'd3, 1, 8'b00010000, "SHR 80>>3 ");
        check(8'b10000000, 3'd4, 1, 8'b00001000, "SHR 80>>4 ");
        check(8'b10000000, 3'd5, 1, 8'b00000100, "SHR 80>>5 ");
        check(8'b10000000, 3'd6, 1, 8'b00000010, "SHR 80>>6 ");
        check(8'b10000000, 3'd7, 1, 8'b00000001, "SHR 80>>7 ");

        // ── Shift RIGHT: pattern test ─────────────────────────
        $display("\n  [Shift RIGHT — in=10110011]");
        check(8'b10110011, 3'd0, 1, 8'b10110011, "SHR B3>>0 ");
        check(8'b10110011, 3'd1, 1, 8'b01011001, "SHR B3>>1 ");
        check(8'b10110011, 3'd2, 1, 8'b00101100, "SHR B3>>2 ");
        check(8'b10110011, 3'd4, 1, 8'b00001011, "SHR B3>>4 ");
        check(8'b10110011, 3'd7, 1, 8'b00000001, "SHR B3>>7 ");

        // ── Corner: shift by 0 = identity ────────────────────
        $display("\n  [Corner: shift by 0]");
        check(8'hAA, 3'd0, 0, 8'hAA, "SHL AA<<0 ");
        check(8'hAA, 3'd0, 1, 8'hAA, "SHR AA>>0 ");
        check(8'hFF, 3'd0, 0, 8'hFF, "SHL FF<<0 ");

        // ── Corner: shift by 7 = 1 bit survives ──────────────
        $display("\n  [Corner: shift by 7]");
        check(8'hFF, 3'd7, 0, 8'b10000000, "SHL FF<<7 ");
        check(8'hFF, 3'd7, 1, 8'b00000001, "SHR FF>>7 ");

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
