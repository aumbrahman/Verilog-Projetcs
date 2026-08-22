`timescale 1ns/1ps

module alu #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire [2:0]       op,
    output reg  [WIDTH-1:0] result,
    output wire             zero,
    output reg              carry,
    output reg              overflow,
    output wire             negative
);
    reg [WIDTH:0] full_result;

    always @(*) begin
        full_result = {(WIDTH+1){1'b0}};
        overflow    = 1'b0;
        carry       = 1'b0;

        case (op)

            3'b000: begin  // ADD
                full_result = {1'b0, a} + {1'b0, b};
                carry       = full_result[WIDTH];
                overflow    = (a[WIDTH-1] == b[WIDTH-1]) &&
                              (full_result[WIDTH-1] != a[WIDTH-1]);
            end

            3'b001: begin  // SUB
                full_result = {1'b0, a} - {1'b0, b};
                carry       = full_result[WIDTH];
                overflow    = (a[WIDTH-1] != b[WIDTH-1]) &&
                              (full_result[WIDTH-1] != a[WIDTH-1]);
            end

            3'b010: begin  // AND
                full_result = {1'b0, a & b};
            end

            3'b011: begin  // OR
                full_result = {1'b0, a | b};
            end

            3'b100: begin  // XOR
                full_result = {1'b0, a ^ b};
            end

            3'b101: begin  // NOT
                full_result = {1'b0, ~a};
            end

            3'b110: begin  // SHL
                full_result = {a, 1'b0};
                carry       = a[WIDTH-1];
            end

            3'b111: begin  // SHR
                full_result = {1'b0, a[WIDTH-1:0]} >> 1;
                carry       = a[0];
            end

        endcase

        result = full_result[WIDTH-1:0];
    end

    assign zero     = (result == {WIDTH{1'b0}});
    assign negative = result[WIDTH-1];

endmodule
