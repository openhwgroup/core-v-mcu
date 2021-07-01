// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

module qf_rfm_f #(
    parameter PAR_MEMORY_WIDTH_BIT = 64,
    parameter PAR_MEMORY_DEPTH_BIT = 4
) (
    //----------------------------------------------------------------//
    //-- INPUT                                                      --//
    //----------------------------------------------------------------//
    input  wire                            rfm_clk,
    input  wire                            rfm_wr_en,
    input  wire [PAR_MEMORY_DEPTH_BIT-1:0] rfm_wr_addr,
    input  wire [PAR_MEMORY_WIDTH_BIT-1:0] rfm_wr_data,
    input  wire [PAR_MEMORY_DEPTH_BIT-1:0] rfm_rd_addr,
    //----------------------------------------------------------------//
    //--  Output                                                    --//
    //----------------------------------------------------------------//
    output wire [PAR_MEMORY_WIDTH_BIT-1:0] rfm_rd_data
);


  localparam PAR_DLY = 1'b1;
  reg [PAR_MEMORY_WIDTH_BIT-1:0] memory_data[2**PAR_MEMORY_DEPTH_BIT-1:0];

  //----------------------------------------------------------------//
  //--  Read                                                      --//
  //----------------------------------------------------------------//
  assign rfm_rd_data = memory_data[rfm_rd_addr];
  //----------------------------------------------------------------//
  //--  Write                                                     --//
  //----------------------------------------------------------------//
  always @(negedge rfm_clk) begin
    if (rfm_wr_en == 1'b1) begin
      memory_data[rfm_wr_addr] <= #PAR_DLY rfm_wr_data;
    end
  end

endmodule
