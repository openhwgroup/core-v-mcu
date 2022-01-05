// Copyright 2021 QuickLogic.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module apb_slave_interface  # (parameter APB_ADDR_WIDTH = 12)
  (
  input apb_pclk_i,
  input apb_preset_i,
  input [11:0] apb_paddr_i,
  input apb_psel_i,
  input apb_penable_i,
  input apb_pwrite_i,
  input [31:0] apb_pwdata_i,
  output wire apb_pready_o,
  output wire [31:0] apb_prdata_o,

  // interface to register module
  output wire [11:0] apb_reg_waddr_o,
  output wire [31:0] apb_reg_wdata_o,
  output wire apb_reg_wrenable_o,
  output wire [11:0] apb_reg_raddr_o,
  input [31:0] apb_reg_rdata_i,
  output wire apb_reg_rd_byte_complete_o
);

  wire        clk;
  wire        rst;
  assign clk = apb_pclk_i;
  assign rst = apb_preset_i;

  reg         pready_reg;

  reg  [11:0] apb_reg_waddr;
  reg  [31:0] apb_reg_wdata;
  reg         apb_reg_wrenable;
  wire [11:0] apb_reg_raddr;
  reg         apb_reg_rd_byte_complete;


  // output assignments
  assign apb_pready_o               = pready_reg;
  assign apb_prdata_o               = apb_reg_rdata_i;

  assign apb_reg_waddr_o            = apb_reg_waddr;
  assign apb_reg_wdata_o            = apb_reg_wdata;
  assign apb_reg_wrenable_o         = apb_reg_wrenable;
  assign apb_reg_raddr_o            = apb_paddr_i;
  assign apb_reg_rd_byte_complete_o = apb_reg_rd_byte_complete;


  // interface to the register module

  always @(posedge rst or posedge clk) begin
    if (rst) begin
      apb_reg_waddr <= 0;
      apb_reg_wdata <= 0;
      apb_reg_wrenable <= 1'b0;
      apb_reg_rd_byte_complete <= 1'b0;
    end else begin
      apb_reg_waddr <= apb_paddr_i;
      apb_reg_wdata <= apb_pwdata_i;
      apb_reg_wrenable <= apb_psel_i & apb_penable_i & apb_pwrite_i & pready_reg;
      pready_reg <= apb_psel_i & apb_penable_i;
      apb_reg_rd_byte_complete <= apb_psel_i & apb_penable_i & !apb_pwrite_i;
    end
  end


endmodule
