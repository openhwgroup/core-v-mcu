// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

module A2_fifo #(
    parameter FIFO_DEPTH = 4,
    parameter WIDTH = 32,
    parameter A_WIDTH = $clog2(FIFO_DEPTH)
) (
    output logic [WIDTH-1:0] rdata,
    input  logic [WIDTH-1:0] wdata,
    output                   empty,
    almost_empty,
    output                   full,
    almost_full,
    input                    fflush,
    input                    rclk,
    input                    wclk,
    input                    pop,
    input                    push
);
  logic [A_WIDTH-1:0] raddr;
  logic [A_WIDTH-1:0] waddr;
  logic               pop_int;
  logic               push_int;

  always @(*) push_int = push & !full;

  fifo_ctl #(
      .FIFO_DEPTH(FIFO_DEPTH)
  ) fifo_ctl (
      .raddr(raddr),
      .waddr(waddr),
      .empty(empty),
      .almost_empty(almost_empty),
      .full(full),
      .almost_full(almost_full),
      .ren_o(pop_int),
      .fflush(fflush),
      .rclk(rclk),
      .wclk(wclk),
      .ren(pop),  // pop
      .req(push)  // push
  );
  fifo_ram #(
      .FIFO_DEPTH(FIFO_DEPTH),
      .WIDTH(WIDTH)
  ) fifo_ram (
      .raddr(raddr),
      .waddr(waddr),
      .ren  (pop_int),
      .wen  (push_int),
      .wdata(wdata),
      .rdata(rdata),
      .rclk (rclk),
      .wclk (wclk)
  );



endmodule  // A2_fifo






