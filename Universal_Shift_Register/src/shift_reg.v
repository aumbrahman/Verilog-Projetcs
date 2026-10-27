`timescale 1ns/1ps
// ============================================================
//  Universal Shift Register — 8-bit, 4-mode
//
//  This register can do four things each clock cycle, selected
//  by the 2-bit mode input:
//
//    mode = 2'b00  HOLD         — data stays unchanged
//    mode = 2'b01  SHIFT RIGHT  — {sin_r, data[7:1]} → data
//    mode = 2'b10  SHIFT LEFT   — {data[6:0], sin_l} → data
//    mode = 2'b11  PARALLEL LOAD— din[7:0] → data
//
//  Serial ports:
//    sin_r  — bit fed in from the LEFT on a right-shift
//    sin_l  — bit fed in from the RIGHT on a left-shift
//    sout_r — rightmost bit (bit 0), serial output for right-shift
//    sout_l — leftmost bit (bit 7), serial output for left-shift
//
//  Real-world use:
//    SPI peripheral: load byte (mode=11), then shift out MSB-first
//    (mode=10, sin_l=0) for 8 clocks. sout_l is MOSI.
//    Simultaneously, MISO feeds sin_r and shifts right.
//
//  Parameter:
//    WIDTH — default 8. Change to 16/32 at instantiation.
// ============================================================
module shift_reg #(
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             rst,          // synchronous reset → all zeros
    input  wire [1:0]       mode,         // 00=hold, 01=shr, 10=shl, 11=load
    input  wire             sin_r,        // serial in (enters at MSB on shift-right)
    input  wire             sin_l,        // serial in (enters at LSB on shift-left)
    input  wire [WIDTH-1:0] din,          // parallel data input (used when mode=11)
    output reg  [WIDTH-1:0] data,         // registered contents
    output wire             sout_r,       // serial out right — always data[0]
    output wire             sout_l        // serial out left  — always data[WIDTH-1]
);

    // ── Sequential: update data register each clock edge ─────
    always @(posedge clk) begin
        if (rst) begin
            data <= {WIDTH{1'b0}};

        end else begin
            case (mode)
                // ── HOLD ──────────────────────────────────────
                2'b00: data <= data;
                //      ^^^^ explicit hold — synthesiser may
                //      optimise this away (same as no assignment),
                //      but it makes intent crystal clear

                // ── SHIFT RIGHT ───────────────────────────────
                // {sin_r, data[WIDTH-1:1]}
                //   ↑new MSB             ↑old [7:1] move to [6:0]
                // Old bit 0 is lost (it appears on sout_r)
                2'b01: data <= {sin_r, data[WIDTH-1:1]};

                // ── SHIFT LEFT ────────────────────────────────
                // {data[WIDTH-2:0], sin_l}
                //   ↑old [6:0] move to [7:1]      ↑new LSB
                // Old MSB is lost (it appears on sout_l)
                2'b10: data <= {data[WIDTH-2:0], sin_l};

                // ── PARALLEL LOAD ─────────────────────────────
                2'b11: data <= din;
            endcase
        end
    end

    // ── Combinational: serial outputs always visible ──────────
    // These are wires, not registered — they reflect data instantly.
    // No clock needed to read what's currently at the ends.
    assign sout_r = data[0];           // rightmost bit
    assign sout_l = data[WIDTH-1];     // leftmost bit

endmodule
