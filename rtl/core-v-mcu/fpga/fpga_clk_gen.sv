//-----------------------------------------------------------------------------
// Title : FPGA CLK Gen for PULPissimo
// -----------------------------------------------------------------------------
// File : fpga_clk_gen.sv Author : Manuel Eggimann <meggimann@iis.ee.ethz.ch>
// Created : 17.05.2019
// -----------------------------------------------------------------------------
// Description : Instantiates Xilinx clocking wizard IP to generate 2 output
// clocks. Currently, the clock is not dynamicly reconfigurable and all
// configuration requests are acknowledged without any effect.
// -----------------------------------------------------------------------------
// Copyright (C) 2013-2019 ETH Zurich, University of Bologna Copyright and
// related rights are licensed under the Solderpad Hardware License, Version
// 0.51 (the "License"); you may not use this file except in compliance with the
// License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law or
// agreed to in writing, software, hardware and materials distributed under this
// License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS
// OF ANY KIND, either express or implied. See the License for the specific
// language governing permissions and limitations under the License.
// -----------------------------------------------------------------------------


module fpga_clk_gen (
    input  logic        ref_clk_i,
    input  logic        rstn_glob_i,
    input  logic        test_mode_i,
    input  logic        shift_enable_i,
    output logic        soc_clk_o,
    output logic        per_clk_o,
    output logic        cluster_clk_o,
    output logic        soc_cfg_lock_o,
    input  logic        soc_cfg_req_i,
    output logic        soc_cfg_ack_o,
    input  logic [ 1:0] soc_cfg_add_i,
    input  logic [31:0] soc_cfg_data_i,
    output logic [31:0] soc_cfg_r_data_o,
    input  logic        soc_cfg_wrn_i,
    output logic        per_cfg_lock_o,
    input  logic        per_cfg_req_i,
    output logic        per_cfg_ack_o,
    input  logic [ 1:0] per_cfg_add_i,
    input  logic [31:0] per_cfg_data_i,
    output logic [31:0] per_cfg_r_data_o,
    input  logic        per_cfg_wrn_i,
    output logic        cluster_cfg_lock_o,
    input  logic        cluster_cfg_req_i,
    output logic        cluster_cfg_ack_o,
    input  logic [ 1:0] cluster_cfg_add_i,
    input  logic [31:0] cluster_cfg_data_i,
    output logic [31:0] cluster_cfg_r_data_o,
    input  logic        cluster_cfg_wrn_i
);

  logic s_locked;

  xilinx_clk_mngr i_clk_manager (
      .resetn  (rstn_glob_i),
      .clk_in1 (ref_clk_i),
      .clk_out1(soc_clk_o),
      .clk_out2(per_clk_o),
      .locked  (s_locked)
  );

  assign soc_cfg_lock_o = s_locked;
  assign per_cfg_lock_o = s_locked;

  // assign soc_cfg_ack_o = 1'b1; //Always acknowledge without doing anything for now
  // assign per_cfg_ack_o = 1'b1;

  always_comb begin
    soc_cfg_ack_o     = 1'b0;
    per_cfg_ack_o     = 1'b0;
    cluster_cfg_ack_o = 1'b0;
    if (soc_cfg_req_i) begin
      soc_cfg_ack_o = 1'b1;
    end
    if (per_cfg_req_i) begin
      per_cfg_ack_o = 1'b1;
    end
    if (cluster_cfg_req_i) begin
      cluster_cfg_ack_o = 1'b1;
    end
  end

  assign soc_cfg_r_data_o = (soc_cfg_add_i == 2'b00 ? 32'hbeef0001 : (soc_cfg_add_i == 2'b01 ? 32'hbeef0003 : (soc_cfg_add_i == 2'b00 ? 32'hbeef0005 : 32'hbeef0007)));
  assign per_cfg_r_data_o = 32'hdeadda7a;

endmodule : fpga_clk_gen
