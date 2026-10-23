`timescale 1ns/1ps
// ============================================================
//  8-to-3 Priority Encoder
//
//  Takes 8 input lines. Outputs the 3-bit binary index of the
//  HIGHEST active (logic-1) input. If multiple inputs are high
//  simultaneously, the highest-numbered one wins (highest priority).
//
//  Ports:
//    in    [7:0]  — 8 input request lines
//    out   [2:0]  — binary index of highest active input
//    valid        — 1 if any input is active, 0 if in==8'b00000000
//
//  New concept: casez
//    Like case, but '?' in a branch label means "don't care" —
//    that bit can be 0 or 1 and still match.
//    This is perfect for priority encoding: once we find the
//    highest set bit, we don't care what the lower bits are.
//
//  Real-world use:
//    CPU interrupt controllers (Intel 8259A PIC),
//    bus arbiters, memory arbiter priority logic.
// ============================================================
module priority_encoder (
    input  wire [7:0] in,
    output reg  [2:0] out,
    output reg        valid
);
    always @(*) begin
        // Default: no valid input
        out   = 3'b000;
        valid = 1'b0;

        // casez checks in from top to bottom.
        // First matching branch wins — that is the priority.
        // '?' means "don't care" — match 0 or 1 for that bit.
        // So 8'b1??????? means "bit 7 is 1, rest don't matter."
        casez (in)
            8'b1???????: begin out = 3'd7; valid = 1'b1; end  // bit 7 highest
            8'b01??????: begin out = 3'd6; valid = 1'b1; end
            8'b001?????: begin out = 3'd5; valid = 1'b1; end
            8'b0001????: begin out = 3'd4; valid = 1'b1; end
            8'b00001???: begin out = 3'd3; valid = 1'b1; end
            8'b000001??: begin out = 3'd2; valid = 1'b1; end
            8'b0000001?: begin out = 3'd1; valid = 1'b1; end
            8'b00000001: begin out = 3'd0; valid = 1'b1; end
            // 8'b00000000 — no match → defaults (out=0, valid=0)
        endcase
    end

endmodule
