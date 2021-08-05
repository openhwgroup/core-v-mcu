// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

module bw_multiplier #(
    parameter unsigned NBitsA = 4,
    parameter unsigned NBitsB = 4
) (
    input  logic [           NBitsA-1:0] a_i,
    input  logic                         a_is_signed_i,
    input  logic [           NBitsB-1:0] b_i,
    input  logic                         b_is_signed_i,
    output logic [NBitsA + NBitsB - 1:0] z_o
);
  logic [NBitsA-1:0] row_inputs[NBitsB];
  // verilator lint_off UNOPTFLAT
  logic [NBitsA-1:0] carry_inputs[NBitsB+1];
  logic [NBitsA-1:0] sum_inputs[NBitsB+1];
  // verilator lint_on UNOPTFLAT
  logic [NBitsB-1:0] partial_result;

  assign carry_inputs[0] = '0;
  assign sum_inputs[0]   = '0;

  genvar row;
  generate
    for (row = 0; row < NBitsB; row++) begin : g_gen_row
      assign row_inputs[row] = (row != (NBitsB - 1)) ? (b_i[row] ? {
        a_is_signed_i ^ a_i[NBitsA-1], a_i[NBitsA-2:0]
      } : {
        a_is_signed_i, {(NBitsA - 1) {1'b0}}
      }) : (b_i[row] ? {
        a_is_signed_i ^ b_is_signed_i ^ a_i[NBitsA-1],
        b_is_signed_i ? ~a_i[NBitsA-2:0] : a_i[NBitsA-2:0]
      } : {
        a_is_signed_i ^ b_is_signed_i, b_is_signed_i ? {(NBitsA - 1) {1'b1}} : {(NBitsA - 1) {1'b0}}
      });
      assign partial_result[row] = carry_inputs[row][0] ^ sum_inputs[row][0] ^ row_inputs[row][0];
      assign carry_inputs[row+1] = (sum_inputs[row] & row_inputs[row])
                                    | (carry_inputs[row] & (sum_inputs[row] ^ row_inputs[row]));
      assign sum_inputs[row+1] = {
        (row == NBitsB - 1) ? a_is_signed_i | b_is_signed_i : 1'b0,
        carry_inputs[row][NBitsA-1:1] ^ sum_inputs[row][NBitsA-1:1] ^ row_inputs[row][NBitsA-1:1]
      };
    end
  endgenerate
  assign z_o[NBitsA+NBitsB-1:0] = {
    {(NBitsA) {1'b0}}, partial_result
  } + {
    sum_inputs[NBitsB], {(NBitsB) {1'b0}}
  } + {
    carry_inputs[NBitsB], {(NBitsB) {1'b0}}
  } + {
    {(NBitsB) {1'b0}}, a_is_signed_i, {(NBitsA - 1) {1'b0}}
  } + {
    {(NBitsA) {1'b0}}, b_is_signed_i, {(NBitsB - 1) {1'b0}}
  };
endmodule  // bw_multiplier
