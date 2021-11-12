// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

// Half size real ram withtop half inverted to make Ram
// comsume less resources for xilinx emulation

module sram512x64
(
 input         clkA,
 input         clkB,
 input         cenA,
 input         cenB,
 input         deepsleep, //vincent
 input         powergate,
 input [8:0]   aA,
 input [8:0]   aB,
 input [63:0]  d,
 input [63:0]  bw,
 output [63:0] q );

   reg [63:0]  out;
   reg [63:0]  storage [255:0];

   assign q = out;

   always @ (posedge clkA) begin
      if (cenA == 0)
        out <= aA[8] ? ~storage[aA[7:0]] :storage[aA[7:0]] ;
   end
   always @ (posedge clkB) begin
      if (cenB == 0) begin
        if (bw[7:0] == 8'hff)
          storage[aB[7:0]][7:0] <= aB[8] ? ~d[7:0] : d[7:0];
         if (bw[15:8] == 8'hff)
           storage[aB[7:0]][15:8] <= aB[8] ? ~d[15:8] :d[15:8];
         if (bw[23:16] == 8'hff)
           storage[aB[7:0]][23:16] <= aB[8] ? ~d[23:16] :d[23:16];
         if (bw[31:24] == 8'hff)
           storage[aB[7:0]][31:24] <= aB[8] ? ~d[31:24] :d[31:24];
         if (bw[39:32] == 8'hff)
           storage[aB[7:0]][39:32] <= aB[8] ? ~d[39:32] :d[39:32];
         if (bw[47:40] == 8'hff)
           storage[aB[7:0]][47:40] <= aB[8] ? ~d[47:40] :d[47:40];
         if (bw[55:48] == 8'hff)
           storage[aB[7:0]][55:48] <= aB[8] ? ~d[55:48] :d[55:48];
         if (bw[63:56] == 8'hff)
          storage[aB[7:0]][63:56] <= aB[8] ? ~d[63:56] :d[63:56];
      end

   end
endmodule
