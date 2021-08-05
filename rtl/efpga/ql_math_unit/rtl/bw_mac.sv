// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

/******************************************************************************
 *
 * Bw multiplier wrapper with accumulator
 *
 ******************************************************************************/

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
  wire [A_width+B_width-1:0] Z;

  bw_multiplier #(
      .NBitsA(A_width),
      .NBitsB(B_width)
  ) i_bw (
      .a_i(A),
      .a_is_signed_i(TC),
      .b_i(B),
      .b_is_signed_i(TC),
      .z_o(Z)
  );

  assign MAC = Z + C;
endmodule
