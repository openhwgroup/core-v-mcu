/*********************************************************************************
 *
 * Emulation of DW02
 *
 *********************************************************************************/

module bw_mac #(
    parameter A_width = 8,
    parameter B_width = 8
) (
    input  wire [        A_width-1:0] A,
    input  wire [        B_width-1:0] B,
    input  wire [A_width+B_width-1:0] C,
    input  wire                       TC,
    output wire [A_width+B_width-1:0] MAC
);
  wire signed [A_width+B_width-1:0] SMAC;

  assign SMAC = signed'(A) * signed'(B) + signed'(C);
  assign MAC  = (TC) ? SMAC : (A * B + C);

endmodule
