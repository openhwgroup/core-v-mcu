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
RAM_256x8_behavioaral.v

Synchronous RAM behavioral model. Can be synthesized but may not produce
optimal results for the targeted technology. May be replaced with an
instantiated RAM block for the technology/device being targetd.

This RAM block has been designed to mimic a RAM block for QuickLogic's S3B
device (with no registered output). Write data is clocked in on the positive
edge of the write clock. The read address is clocked in on the positive
edge of the read clock, and read data is available after that clock edge.

---------------------------------------------------------------------------- */

module RAM_256x8_behavioral (
    wr_clk,
    wr_addr,
    wr_enable,
    wr_data,
    rd_clk,
    rd_addr,
    rd_data
);

  input wr_clk;
  input [7:0] wr_addr;
  input wr_enable;
  input [7:0] wr_data;
  input rd_clk;
  input [7:0] rd_addr;
  output [7:0] rd_data;

  wire [7:0] rd_data;

  reg  [7:0] ram          [255:0];

  reg  [7:0] rd_addr_reg;
  wire [7:0] ram_data_out;


  always @(posedge wr_clk) if (wr_enable) ram[wr_addr] <= wr_data;

  always @(posedge rd_clk) begin
    rd_addr_reg <= rd_addr;
  end

  assign ram_data_out = ram[rd_addr];

  assign rd_data = ram_data_out;

endmodule
