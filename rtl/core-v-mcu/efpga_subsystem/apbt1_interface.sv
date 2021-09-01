// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

module apbt1_interface (
    input logic lint_rst,
    input logic lint_clk,
    input logic lint_req,
    output logic lint_gnt,
    output logic lint_fmo,
    output logic lint_valid,
    input logic [56:0] lint_req_data,  // 20 addr + 4 be, + 32 data + wen
    output logic [56:0] efpga_req_data,  // 20 addr + 4 be, + 32 data + wen
    output logic [31:0] lint_rdata,

    input logic efpga_rst,
    input logic efpga_clk,
    output logic efpga_req,
    input logic efpga_gnt,
    input logic efpga_valid,
    input [31:0] efpga_rdata
);


  logic req_push;
  logic req_empty;
  logic req_full;
  logic resp_empty;

  always @(posedge lint_clk or posedge lint_rst) begin
    if (lint_rst == 1'b1) lint_valid <= 0;
    else lint_valid <= lint_gnt;
  end

  assign req_push  = lint_req & !req_full;
  assign lint_gnt  = !resp_empty;  // !req_full;

  assign efpga_req = !req_empty;
  //assign lint_valid = !resp_empty;




  A2_fifo #(
      .FIFO_DEPTH(4),
      .WIDTH(57)
  )  // Addr, BE, Wdata, Wen
      req_fifo (
      .wclk(lint_clk),
      .rclk(efpga_clk),
      .fflush(lint_rst),
      .empty(req_empty),
      .rdata(efpga_req_data),
      .full(req_full),
      .wdata(lint_req_data),
      .almost_empty(),
      .almost_full(lint_fmo),
      .pop(efpga_gnt),
      .push(req_push)
  );

  A2_fifo #(
      .FIFO_DEPTH(4),
      .WIDTH(32)
  )  // rdata
      resp_fifo (
      .wclk(efpga_clk),
      .rclk(lint_clk),
      .fflush(efpga_rst),
      .empty(resp_empty),
      .rdata(lint_rdata),
      .full(),
      .wdata(efpga_rdata),
      .almost_empty(),
      .almost_full(),
      .pop(lint_valid),
      .push(efpga_valid)
  );

endmodule  // tcdm_interface
