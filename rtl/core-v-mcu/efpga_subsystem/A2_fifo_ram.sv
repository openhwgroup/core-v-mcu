// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
module fifo_ram #(
    parameter WIDTH = 32,
    FIFO_DEPTH = 4,
    A_WIDTH = $clog2(FIFO_DEPTH)
) (
    input        [A_WIDTH-1:0] raddr,
    input        [A_WIDTH-1:0] waddr,
    input                      ren,
    input                      wen,
    input        [  WIDTH-1:0] wdata,
    output logic [  WIDTH-1:0] rdata,
    input                      rclk,
    input                      wclk
);
  logic [FIFO_DEPTH-1:0][WIDTH-1:0] data_ram;
  logic [A_WIDTH-1:0] latched_raddr;

  always @(posedge wclk) begin
    if (wen == 1) data_ram[waddr] <= wdata;
  end
  always @(posedge rclk) begin
    if (ren == 1) latched_raddr <= raddr;
  end
  always @(*) begin
    rdata <= data_ram[latched_raddr];
  end


endmodule  // A2_fifo_ram
