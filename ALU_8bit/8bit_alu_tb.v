`timescale 1ns/1ps

module tb_alu;

    localparam ADD = 3'b000;
    localparam SUB = 3'b001;
    localparam AND = 3'b010;
    localparam OR  = 3'b011;
    localparam XOR = 3'b100;
    localparam NOT = 3'b101;
    localparam SHL = 3'b110;
    localparam SHR = 3'b111;

    reg  [7:0] a, b;
    reg  [2:0] op;
    wire [7:0] result;
    wire       zero, carry, overflow, negative;

    alu #(.WIDTH(8)) DUT (
        .a        (a),
        .b        (b),
        .op       (op),
        .result   (result),
        .zero     (zero),
        .carry    (carry),
        .overflow (overflow),
        .negative (negative)
    );

    initial begin
        $dumpfile("8bit_alu.vcd");
        $dumpvars(0, tb_alu);
    end

    integer pass_count, fail_count;

    task check_result;
        input [7:0]  exp_result;
        input        exp_zero;
        input        exp_carry;
        input        exp_overflow;
        input        exp_negative;
        input [63:0] test_name;
        begin
            if (result   === exp_result   &&
                zero     === exp_zero     &&
                carry    === exp_carry    &&
                overflow === exp_overflow &&
                negative === exp_negative) begin
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL [%s] a=%0d b=%0d op=%b",
                         test_name, a, b, op);
                $display("       result:   got=%0d  exp=%0d",   result,   exp_result);
                $display("       zero:     got=%b    exp=%b",   zero,     exp_zero);
                $display("       carry:    got=%b    exp=%b",   carry,    exp_carry);
                $display("       overflow: got=%b    exp=%b",   overflow, exp_overflow);
                $display("       negative: got=%b    exp=%b",   negative, exp_negative);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        pass_count = 0;
        fail_count = 0;

        $display("================================================");
        $display("  8-bit ALU Testbench — Directed Corner Cases   ");
        $display("================================================");

        // ADD
        $display("\n  [ADD]");
        op = ADD;
        a=8'd1;   b=8'd1;   #10; check_result(8'd2,   0,0,0,0, "ADD 1+1 ");
        a=8'd0;   b=8'd0;   #10; check_result(8'd0,   1,0,0,0, "ADD 0+0 ");
        a=8'd255; b=8'd1;   #10; check_result(8'd0,   1,1,0,0, "ADD OvfU");
        a=8'd127; b=8'd1;   #10; check_result(8'd128, 0,0,1,1, "ADD OvfS");
        a=8'd200; b=8'd100; #10; check_result(8'd44,  0,1,0,0, "ADD crry");

        // SUB
        $display("\n  [SUB]");
        op = SUB;
        a=8'd5;   b=8'd3;   #10; check_result(8'd2,   0,0,0,0, "SUB 5-3 ");
        a=8'd7;   b=8'd7;   #10; check_result(8'd0,   1,0,0,0, "SUB 7-7 ");
        a=8'd0;   b=8'd1;   #10; check_result(8'd255, 0,1,0,1, "SUB brw ");
        a=8'h80;  b=8'd1;   #10; check_result(8'h7F, 0,0,1,0,  "SUB OvfS");

        // AND
        $display("\n  [AND]");
        op = AND;
        a=8'hFF; b=8'hAA; #10; check_result(8'hAA, 0,0,0,1, "AND FFA ");
        a=8'hFF; b=8'h00; #10; check_result(8'h00, 1,0,0,0, "AND FF0 ");
        a=8'hF0; b=8'h0F; #10; check_result(8'h00, 1,0,0,0, "AND mask");

        // OR
        $display("\n  [OR]");
        op = OR;
        a=8'hF0; b=8'h0F; #10; check_result(8'hFF, 0,0,0,1, "OR F00F ");
        a=8'h00; b=8'h00; #10; check_result(8'h00, 1,0,0,0, "OR  0+0 ");
        a=8'hAA; b=8'h55; #10; check_result(8'hFF, 0,0,0,1, "OR AA55 ");

        // XOR
        $display("\n  [XOR]");
        op = XOR;
        a=8'hFF; b=8'hFF; #10; check_result(8'h00, 1,0,0,0, "XOR same");
        a=8'hAA; b=8'h55; #10; check_result(8'hFF, 0,0,0,1, "XOR AA55");
        a=8'hF0; b=8'h0F; #10; check_result(8'hFF, 0,0,0,1, "XOR F00F");

        // NOT
        $display("\n  [NOT]");
        op = NOT;
        a=8'h00; b=8'h00; #10; check_result(8'hFF, 0,0,0,1, "NOT 00  ");
        a=8'hFF; b=8'h00; #10; check_result(8'h00, 1,0,0,0, "NOT FF  ");
        a=8'hAA; b=8'h00; #10; check_result(8'h55, 0,0,0,0, "NOT AA  ");

        // SHL
        $display("\n  [SHL]");
        op = SHL;
        a=8'b00000001; b=8'h00; #10; check_result(8'b00000010, 0,0,0,0, "SHL 01  ");
        a=8'b10000000; b=8'h00; #10; check_result(8'b00000000, 1,1,0,0, "SHL MSB ");
        a=8'b01010101; b=8'h00; #10; check_result(8'b10101010, 0,0,0,1, "SHL 55  ");

        // SHR
        $display("\n  [SHR]");
        op = SHR;
        a=8'b10000000; b=8'h00; #10; check_result(8'b01000000, 0,0,0,0, "SHR 80  ");
        a=8'b00000001; b=8'h00; #10; check_result(8'b00000000, 1,1,0,0, "SHR LSB ");
        a=8'b10101010; b=8'h00; #10; check_result(8'b01010101, 0,0,0,0, "SHR AA  ");

        $display("\n================================================");
        $display("  Results: %0d PASSED, %0d FAILED", pass_count, fail_count);
        if (fail_count == 0)
            $display("  *** ALL TESTS PASSED ***");
        else
            $display("  *** FAILURES DETECTED — check above ***");
        $display("================================================");

        $finish;
    end

endmodule
