// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

module tcdm_interface (
    input efpga_rst,
    input efpga_clk,
    input efpga_req,
    output efpga_gnt,
    output efpga_fmo,
    output efpga_valid,
    input [56:0] efpga_req_data,  // 20 addr + 4 be, + 32 data + wen
    output [56:0] soc_req_data,  // 20 addr + 4 be, + 32 data + wen
    output [31:0] efpga_rdata,

    input soc_rst,
    input soc_clk,
    output soc_req,
    input soc_gnt,
    input soc_valid,
    input [31:0] soc_rdata
);


  logic req_push;
  logic req_empty;
  logic req_full;
  logic resp_empty;


  assign req_push = efpga_req & !req_full;
  assign efpga_gnt = !req_full;

  assign soc_req = !req_empty;
  assign efpga_valid = !resp_empty;




  A2_fifo #(
      .FIFO_DEPTH(4),
      .WIDTH(57)
  )  // Addr, BE, Wdata, Wen
      req_fifo (
      .wclk(efpga_clk),
      .rclk(soc_clk),
      .fflush(efpga_rst),
      .empty(req_empty),
      .rdata(soc_req_data),
      .full(req_full),
      .wdata(efpga_req_data),
      .almost_empty(),
      .almost_full(efpga_fmo),
      .pop(soc_gnt),
      .push(req_push)
  );

  A2_fifo #(
      .FIFO_DEPTH(4),
      .WIDTH(32)
  )  // rdata
      resp_fifo (
      .wclk(soc_clk),
      .rclk(efpga_clk),
      .fflush(soc_rst),
      .empty(resp_empty),
      .rdata(efpga_rdata),
      .full(),
      .wdata(soc_rdata),
      .almost_empty(),
      .almost_full(),
      .pop(efpga_valid),
      .push(soc_valid)
  );

endmodule  // tcdm_interface
