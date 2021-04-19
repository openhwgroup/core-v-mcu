// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

module qf_sff #(
    parameter PAR_FIFO_DEPTH_BITS = 3,
    parameter PAR_FIFO_DATA_WIDTH = 32
) (
    //------------------------------------------------------------------------//
    //-- INPUT PORT                                                         --//
    //------------------------------------------------------------------------//
    //----------------------------------------------------------------//
    //-- CLK							--//
    //----------------------------------------------------------------//
    input  logic                           fifo_clk,
    input  logic                           fifo_rst_n,
    input  logic [PAR_FIFO_DATA_WIDTH-1:0] fifo_wr_data,
    input  logic                           fifo_wr_en,
    input  logic                           fifo_rd_en,
    //------------------------------------------------------------------------//
    //-- OUTPUT PORT                                                        --//
    //------------------------------------------------------------------------//
    output logic [PAR_FIFO_DATA_WIDTH-1:0] fifo_rd_data,
    output logic                           fifo_empty_flag,
    output logic                           fifo_empty_p1_flag,
    output logic                           fifo_full_flag,
    output logic                           fifo_full_m1_flag
);
  //------------------------------------------------------------------------//
  //-- Local Parameter                                                    --//
  //------------------------------------------------------------------------//
  localparam PAR_DLY = 1'b1;

  //------------------------------------------------------------------------//
  //-- EMUN/Flops                                                         --//
  //------------------------------------------------------------------------//
  //------------------------------------------------------------------------//
  //-- Wire/Flops                                                         --//
  //------------------------------------------------------------------------//
  logic [  PAR_FIFO_DEPTH_BITS:0] fifo_cnt_cs;
  logic [  PAR_FIFO_DEPTH_BITS:0] fifo_cnt_ns;
  logic [PAR_FIFO_DEPTH_BITS-1:0] fifo_wr_ptr_cs;
  logic [PAR_FIFO_DEPTH_BITS-1:0] fifo_wr_ptr_ns;
  logic [PAR_FIFO_DEPTH_BITS-1:0] fifo_rd_ptr_cs;
  logic [PAR_FIFO_DEPTH_BITS-1:0] fifo_rd_ptr_ns;

  //--------------------------------------------------------------------------------//
  //-- Start Functional Description                                               --//
  //--------------------------------------------------------------------------------//
  //------------------------------------------------------------------------//
  //-- Flag                                                  		--//
  //------------------------------------------------------------------------//
  assign fifo_full_flag = (fifo_cnt_cs[PAR_FIFO_DEPTH_BITS:0] == {
    1'b1, {PAR_FIFO_DEPTH_BITS{1'b0}}
  }) ? 1'b1 : 1'b0;

  assign fifo_empty_flag = (fifo_cnt_cs[PAR_FIFO_DEPTH_BITS:0] == 'b0) ? 1'b1 : 1'b0;

  assign fifo_full_m1_flag = (fifo_cnt_cs[PAR_FIFO_DEPTH_BITS:0] == {
    1'b0, {PAR_FIFO_DEPTH_BITS{1'b1}}
  }) ? 1'b1 : 1'b0;

  assign fifo_empty_p1_flag = (fifo_cnt_cs[PAR_FIFO_DEPTH_BITS:0] == {
    {PAR_FIFO_DEPTH_BITS{1'b0}}, 1'b1
  }) ? 1'b1 : 1'b0;

  //------------------------------------------------------------------------//
  //-- COUNTER                                                  		--//
  //------------------------------------------------------------------------//
  //----------------------------------------------------------------//
  //-- SYNC      							--//
  //----------------------------------------------------------------//
  always_ff @(posedge fifo_clk or negedge fifo_rst_n) begin
    if (fifo_rst_n == 1'b0) begin
      fifo_cnt_cs <= #PAR_DLY 'b0;
    end else begin
      fifo_cnt_cs <= #PAR_DLY fifo_cnt_ns;
    end
  end
  //----------------------------------------------------------------//
  //-- COMB      							--//
  //----------------------------------------------------------------//
  always_comb begin
    if (fifo_wr_en == 1'b1 && fifo_rd_en == 1'b1) begin
      fifo_cnt_ns = fifo_cnt_cs;
    end else if (fifo_wr_en == 1'b1) begin
      fifo_cnt_ns = fifo_cnt_cs + 1'b1;
    end else if (fifo_rd_en == 1'b1) begin
      fifo_cnt_ns = fifo_cnt_cs - 1'b1;
    end else begin
      fifo_cnt_ns = fifo_cnt_cs;
    end
  end

  //------------------------------------------------------------------------//
  //-- WR PTR                                                             --//
  //------------------------------------------------------------------------//
  //----------------------------------------------------------------//
  //-- SYNC                                                       --//   
  //----------------------------------------------------------------//
  always_ff @(posedge fifo_clk or negedge fifo_rst_n) begin
    if (fifo_rst_n == 1'b0) begin
      fifo_wr_ptr_cs <= #PAR_DLY 'b0;
    end else begin
      fifo_wr_ptr_cs <= #PAR_DLY fifo_wr_ptr_ns;
    end
  end
  //----------------------------------------------------------------//
  //-- COMB                                                       --//
  //----------------------------------------------------------------//
  always_comb begin
    if (fifo_wr_en == 1'b1) begin
      fifo_wr_ptr_ns = fifo_wr_ptr_cs + 1'b1;
    end else begin
      fifo_wr_ptr_ns = fifo_wr_ptr_cs;
    end
  end

  //------------------------------------------------------------------------//
  //-- RD PTR                                                             --//
  //------------------------------------------------------------------------//
  //----------------------------------------------------------------//
  //-- SYNC                                                       --//
  //----------------------------------------------------------------//
  always_ff @(posedge fifo_clk or negedge fifo_rst_n) begin
    if (fifo_rst_n == 1'b0) begin
      fifo_rd_ptr_cs <= #PAR_DLY 'b0;
    end else begin
      fifo_rd_ptr_cs <= #PAR_DLY fifo_rd_ptr_ns;
    end
  end
  //----------------------------------------------------------------//
  //-- COMB                                                       --//
  //----------------------------------------------------------------//
  always_comb begin
    if (fifo_rd_en == 1'b1) begin
      fifo_rd_ptr_ns = fifo_rd_ptr_cs + 1'b1;
    end else begin
      fifo_rd_ptr_ns = fifo_rd_ptr_cs;
    end
  end


  //------------------------------------------------------------------------//
  //-- Register Body                                                      --//
  //------------------------------------------------------------------------//
  qf_rfm #(
      .PAR_MEMORY_WIDTH_BIT(PAR_FIFO_DATA_WIDTH),
      .PAR_MEMORY_DEPTH_BIT(PAR_FIFO_DEPTH_BITS)
  ) qf_rfm_INST (
      .rfm_clk(fifo_clk),
      .rfm_wr_en(fifo_wr_en),
      .rfm_wr_addr(fifo_wr_ptr_cs),
      .rfm_wr_data(fifo_wr_data),
      .rfm_rd_addr(fifo_rd_ptr_cs),
      .rfm_rd_data(fifo_rd_data)
  );

  //--------------------------------------------------------------------------------//
  //-- END                                                                        --//
  //--------------------------------------------------------------------------------//
endmodule


