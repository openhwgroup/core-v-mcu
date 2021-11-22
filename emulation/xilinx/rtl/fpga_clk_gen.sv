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


module clk_gen (
                     input logic         ref_clk_i,
                input logic emul_clk_i,
                     input logic         rstn_glob_i,
                     input logic         test_mode_i,
                     input logic         shift_enable_i,
                     output logic        soc_clk_o,
                     output logic        per_clk_o,
                     output logic        cluster_clk_o,
                     output logic        soc_cfg_lock_o,
                     input logic         soc_cfg_req_i,
                     output logic        soc_cfg_ack_o,
                     input logic [1:0]   soc_cfg_add_i,
                     input logic [31:0]  soc_cfg_data_i,
                     output logic [31:0] soc_cfg_r_data_o,
                     input logic         soc_cfg_wrn_i,
                     output logic        per_cfg_lock_o,
                     input logic         per_cfg_req_i,
                     output logic        per_cfg_ack_o,
                     input logic [1:0]   per_cfg_add_i,
                     input logic [31:0]  per_cfg_data_i,
                     output logic [31:0] per_cfg_r_data_o,
                     input logic         per_cfg_wrn_i,
                     output logic        cluster_cfg_lock_o,
                     input logic         cluster_cfg_req_i,
                     output logic        cluster_cfg_ack_o,
                     input logic [1:0]   cluster_cfg_add_i,
                     input logic [31:0]  cluster_cfg_data_i,
                     output logic [31:0] cluster_cfg_r_data_o,
                     input logic         cluster_cfg_wrn_i
                     );

  logic                                  s_locked;
  clk_and_control i_fll_soc (
                             .clk(soc_clk_o),
      .FLLCLK(),
      .FLLOE(1'b1),
      .REFCLK(ref_clk_i),
      .LOCK(soc_cfg_lock_o),
      .CFGREQ(soc_cfg_req_i),
      .CFGACK(soc_cfg_ack_o),
      .CFGAD(soc_cfg_add_i[1:0]),
      .CFGD(soc_cfg_data_i),
      .CFGQ(soc_cfg_r_data_o),
      .CFGWEB(soc_cfg_wrn_i),
      .RSTB(rstn_glob_i),
      .PWD(1'b0),
      .RET(1'b0),
      .TM(test_mode_i),
      .TE(shift_enable_i),
      .TD(1'b0),  //TO FIX.DF()T
      .TQ(),  //TO FIX.DF()T
      .JTD(1'b0),  //TO FIX.DF()T
      .JTQ()  //TO FIX.DF()T
  );
  clk_and_control i_fll_cluster (
                                 .clk(soc_clk_o),
      .FLLCLK(),
      .FLLOE(1'b1),
      .REFCLK(ref_clk_i),
      .LOCK(cluster_cfg_lock_o),
      .CFGREQ(cluster_cfg_req_i),
      .CFGACK(cluster_cfg_ack_o),
      .CFGAD(cluster_cfg_add_i[1:0]),
      .CFGD(cluster_cfg_data_i),
      .CFGQ(cluster_cfg_r_data_o),
      .CFGWEB(cluster_cfg_wrn_i),
      .RSTB(rstn_glob_i),
      .PWD(1'b0),
      .RET(1'b0),
      .TM(test_mode_i),
      .TE(shift_enable_i),
      .TD(1'b0),  //TO FIX.DF()T
      .TQ(),  //TO FIX.DF()T
      .JTD(1'b0),  //TO FIX.DF()T
      .JTQ()  //TO FIX.DF()T
  );
  clk_and_control i_fll_per (
                                                          .clk(soc_clk_o),
      .FLLCLK(),
      .FLLOE(1'b1),
      .REFCLK(ref_clk_i),
      .LOCK(per_cfg_lock_o),
      .CFGREQ(per_cfg_req_i),
      .CFGACK(per_cfg_ack_o),
      .CFGAD(per_cfg_add_i[1:0]),
      .CFGD(per_cfg_data_i),
      .CFGQ(per_cfg_r_data_o),
      .CFGWEB(per_cfg_wrn_i),
      .RSTB(rstn_glob_i),
      .PWD(1'b0),
      .RET(1'b0),
      .TM(test_mode_i),
      .TE(shift_enable_i),
      .TD(1'b0),  //TO FIX.DF()T
      .TQ(),  //TO FIX.DF()T
      .JTD(1'b0),  //TO FIX.DF()T
      .JTQ()  //TO FIX.DF()T
  );

  xilinx_clk_mngr i_clk_manager
    (
     .resetn(rstn_glob_i),
     .clk_in1(emul_clk_i),
     .clk_out1(soc_clk_o),
     .clk_out2(per_clk_o),
     .clk_out3(cluster_clk_o),
     .locked(s_locked)
     );

endmodule : clk_gen
