// Copyright 2021 QuickLogic.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

/* ----------------------------------------------------------------------------
FIFO_sync_256x8.v

This is a synchronous FIFO (wr_clk == rd_clk).
There is underflow/overflow protection: writing when full does nothing,
reading when empty does nothing.


empty  rd_flags:
-------------
 0      000  0 items, empty
 1      001  1 item
 1      010  2-3 items
 1      011  4-7 items
 1      100  8-31 items
 1      101  32-63 items
 1      110  64-127 items
 1      111  128+ items

full  wr_flags:
-------------
 0      000  128+ spaces left
 0      001  64-127 spaces left
 0      010  32-63 spaces left
 0      011  8-31 spaces left
 0      100  4-7 spaces left
 0      101  2-3 spaces left
 0      110  1 space left
 1      111  0 spaces left, full



---------------------------------------------------------------------------- */

module FIFO_sync_256x8 (
    rst_i,
    clk_i,
    push_i,
    wr_data_i,
    full_o,
    wr_flags_o,
    pop_i,
    rd_data_o,
    empty_o,
    rd_flags_o
);


  input rst_i;
  input clk_i;
  input push_i;
  input [7:0] wr_data_i;
  output full_o;
  output [2:0] wr_flags_o;
  input pop_i;
  output [7:0] rd_data_o;
  output empty_o;
  output [2:0] rd_flags_o;

  wire       rst_i;
  wire       clk_i;
  wire       push_i;
  wire [7:0] wr_data_i;
  wire       full_o;
  wire [2:0] wr_flags_o;
  wire       pop_i;
  wire [7:0] rd_data_o;
  wire       empty_o;
  wire [2:0] rd_flags_o;


  // internal signals
  localparam FIFO_DEPTH = 256;
  wire       ram_clk;
  reg  [7:0] ram_wr_addr;
  wire       ram_wr_enable;
  wire [7:0] ram_wr_data;
  reg  [7:0] ram_rd_addr;
  wire [7:0] ram_rd_data;
  reg  [2:0] rd_flags_reg;
  reg  [2:0] wr_flags_reg;
  reg        full_reg;
  reg        empty_reg;
  reg  [8:0] fifo_cnt;

  wire       clk;
  wire       rst;
  wire       push;
  wire [7:0] wr_data;
  wire       pop;


  assign rst = rst_i;
  assign clk = clk_i;
  assign push = push_i;
  assign wr_data = wr_data_i;
  assign pop = pop_i;

  always @(posedge rst or posedge clk)
    if (rst) ram_wr_addr <= 0;
    else if (push && !full_reg) ram_wr_addr <= ram_wr_addr + 1;
    else ram_wr_addr <= ram_wr_addr;

  always @(posedge rst or posedge clk)
    if (rst) ram_rd_addr <= 0;
    else if (pop && !empty_reg) ram_rd_addr <= ram_rd_addr + 1;
    else ram_rd_addr <= ram_rd_addr;

  // FIFO count, used to generate the flags
  always @(posedge rst or posedge clk)
    if (rst) fifo_cnt <= 0;
    else
      case ({
        push, pop
      })
        2'b00: fifo_cnt <= fifo_cnt;
        2'b01:
        if (empty_reg)  // ignore pop when empty
          fifo_cnt <= fifo_cnt;
        else  // cnt - 1
          fifo_cnt <= fifo_cnt - 1;
        2'b10:
        if (full_reg)  // ignore push when full
          fifo_cnt <= fifo_cnt;
        else  // cnt + 1
          fifo_cnt <= fifo_cnt + 1;
        2'b11:
        if (empty_reg)  // ignore pop when empty
          fifo_cnt <= fifo_cnt + 1;
        else if (full_reg)  // ignore push when full
          fifo_cnt <= fifo_cnt - 1;
        else  // do both, cnt doesn't change
          fifo_cnt <= fifo_cnt;
        default: fifo_cnt <= fifo_cnt;
      endcase

  // FIFO write flags
  /*
full  wr_flags:
-------------
 0      000  128+ spaces left
 0      001  64-127 spaces left
 0      010  32-63 spaces left
 0      011  8-31 spaces left
 0      100  4-7 spaces left
 0      101  2-3 spaces left
 0      110  1 space left
 1      111  0 spaces left, full
*/

  always @(posedge rst or posedge clk)
    if (rst) begin
      wr_flags_reg <= 3'b000;
      full_reg <= 0;
    end else begin
      case (wr_flags_reg)
        3'b000:  // 128+ spaces left
        if (fifo_cnt == (FIFO_DEPTH - 128) && push && !pop) wr_flags_reg <= 3'b001;
        else wr_flags_reg <= 3'b000;
        3'b001:  // 64-127 spaces left
        if (fifo_cnt == (FIFO_DEPTH - 64) && push && !pop) wr_flags_reg <= 3'b010;
        else if (fifo_cnt == (FIFO_DEPTH - 127) && !push && pop) wr_flags_reg <= 3'b000;
        else wr_flags_reg <= 3'b001;
        3'b010:  // 32-63 spaces left
        if (fifo_cnt == (FIFO_DEPTH - 32) && push && !pop) wr_flags_reg <= 3'b011;
        else if (fifo_cnt == (FIFO_DEPTH - 63) && !push && pop) wr_flags_reg <= 3'b001;
        else wr_flags_reg <= 3'b010;
        3'b011:  // 8-31 spaces left
        if (fifo_cnt == (FIFO_DEPTH - 8) && push && !pop) wr_flags_reg <= 3'b100;
        else if (fifo_cnt == (FIFO_DEPTH - 31) && !push && pop) wr_flags_reg <= 3'b010;
        else wr_flags_reg <= 3'b011;
        3'b100:  // 4-7 spaces left
        if (fifo_cnt == (FIFO_DEPTH - 4) && push && !pop) wr_flags_reg <= 3'b101;
        else if (fifo_cnt == (FIFO_DEPTH - 7) && !push && pop) wr_flags_reg <= 3'b011;
        else wr_flags_reg <= 3'b100;
        3'b101:  // 2-3 spaces left
        if (fifo_cnt == (FIFO_DEPTH - 2) && push && !pop) wr_flags_reg <= 3'b110;
        else if (fifo_cnt == (FIFO_DEPTH - 3) && !push && pop) wr_flags_reg <= 3'b100;
        else wr_flags_reg <= 3'b101;
        3'b110:  // 1 space left
        if (push && !pop) wr_flags_reg <= 3'b111;
        else if (!push && pop) wr_flags_reg <= 3'b101;
        else wr_flags_reg <= 3'b110;
        3'b111:  // 0 spaces left, full
        if (pop) wr_flags_reg <= 3'b110;
        else wr_flags_reg <= 3'b111;

        default: wr_flags_reg <= wr_flags_reg;
      endcase

      case (full_reg)
        1'b0:    if (wr_flags_reg == 3'b110 && push && !pop) full_reg <= 1;
 else full_reg <= 0;
        1'b1:    if (pop) full_reg <= 0;
 else full_reg <= 1;
        default: full_reg <= full_reg;
      endcase

    end

  assign wr_flags_o = wr_flags_reg;
  assign full_o = full_reg;

  /*
empty  rd_flags:
-------------
 0      000  0 items, empty
 1      001  1 item
 1      010  2-3 items
 1      011  4-7 items
 1      100  8-31 items
 1      101  32-63 items
 1      110  64-127 items
 1      111  128+ items
*/
  always @(posedge rst or posedge clk)
    if (rst) begin
      rd_flags_reg <= 0;
      empty_reg <= 1;
    end else begin
      case (rd_flags_reg)
        3'b000:  // 0 items, empty
        if (push) rd_flags_reg <= 3'b001;
        else rd_flags_reg <= 3'b000;
        3'b001:  // 1 item
        if (push && !pop) rd_flags_reg <= 3'b010;
        else if (!push && pop) rd_flags_reg <= 3'b000;
        else rd_flags_reg <= 3'b001;
        3'b010:  // 2-3 items
        if (fifo_cnt == 3 && push && !pop) rd_flags_reg <= 3'b011;
        else if (fifo_cnt == 2 && !push && pop) rd_flags_reg <= 3'b001;
        else rd_flags_reg <= 3'b010;
        3'b011:  // 4-7 items
        if (fifo_cnt == 7 && push && !pop) rd_flags_reg <= 3'b100;
        else if (fifo_cnt == 4 && !push && pop) rd_flags_reg <= 3'b010;
        else rd_flags_reg <= 3'b011;
        3'b100:  // 8-31 items
        if (fifo_cnt == 31 && push && !pop) rd_flags_reg <= 3'b101;
        else if (fifo_cnt == 8 && !push && pop) rd_flags_reg <= 3'b011;
        else rd_flags_reg <= 3'b100;
        3'b101:  // 32-63 items
        if (fifo_cnt == 63 && push && !pop) rd_flags_reg <= 3'b110;
        else if (fifo_cnt == 32 && !push && pop) rd_flags_reg <= 3'b100;
        else rd_flags_reg <= 3'b101;
        3'b110:  // 64-127 items
        if (fifo_cnt == 127 && push && !pop) rd_flags_reg <= 3'b111;
        else if (fifo_cnt == 64 && !push && pop) rd_flags_reg <= 3'b101;
        else rd_flags_reg <= 3'b110;
        3'b111:  // 128 items
        if (fifo_cnt == 128 && !push && pop) rd_flags_reg <= 3'b110;
        else rd_flags_reg <= 3'b111;
        default: rd_flags_reg <= rd_flags_reg;
      endcase

      case (empty_reg)
        1'b0:
        if (rd_flags_reg == 3'b001 && !push && pop) empty_reg <= 1'b1;
        else empty_reg <= 1'b0;
        1'b1:
        if (push) empty_reg <= 1'b0;
        else empty_reg <= 1'b1;
        default: empty_reg <= empty_reg;
      endcase
    end


  assign rd_flags_o = rd_flags_reg;
  assign empty_o = empty_reg;


  assign ram_clk = clk_i;
  assign ram_wr_enable = (full_reg) ? 1'b0 : push;
  assign ram_wr_data = wr_data;


  RAM_256x8_behavioral RAM_256x8_behavioral_0 (
      .wr_clk   (ram_clk),
      .wr_addr  (ram_wr_addr),
      .wr_enable(ram_wr_enable),
      .wr_data  (ram_wr_data),
      .rd_clk   (ram_clk),
      .rd_addr  (ram_rd_addr),
      .rd_data  (ram_rd_data)
  );

  assign rd_data_o = ram_rd_data;


endmodule
