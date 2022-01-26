//-----------------------------------------------------------------------------
// This file is a generated file
//-----------------------------------------------------------------------------
// Title         : Core-v-mcu Verilog Wrapper
//-----------------------------------------------------------------------------
// Description :
// Verilog Wrapper of Core-v-mcu to use the module within Xilinx IP integrator.
//-----------------------------------------------------------------------------
// Copyright (C) 2013-2019 ETH Zurich, University of Bologna
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//-----------------------------------------------------------------------------

`include "pulp_soc_defines.svh"
`include "pulp_peripheral_defines.svh"

module core_v_mcu_genesys2
  (
    inout wire [`N_IO-1:0]  xilinx_io,
    input wire  sysclk_p,
    input wire  sysclk_n,
    input wire  ref_clk
  );

  wire private_net;
  wire s_slow_clk;
  wire [`N_IO-1:0]  s_io_out;
  wire [`N_IO-1:0]  s_io_oe;
  wire [`N_IO-1:0]  s_io_in;
  wire [`N_IO-1:0][`NBIT_PADCFG-1:0] s_pad_cfg;
  wire s_jtag_tck;
  wire s_jtag_tdi;
  wire s_jtag_tdo;
  wire s_jtag_tms;
  wire s_jtag_trst;
  wire s_sysclk_p;
  wire s_rstn;
  wire s_stm;
  wire s_bootsel;

  //JTAG TCK clock buffer (dedicated route is false in constraints)
  IBUF  i_tck_ibuf (
    .I(xilinx_io[0]),
    .O(s_tck)
  );

  BUFG i_tck_buf (
    .I(s_tck),
    .O(s_io_in[0])
  );

  pad_functional_pu i_pad_1   (.OEN(~s_io_oe[1]), .I(s_io_out[1]), .O(s_io_in[1]), .PAD(xilinx_io[1]), .PEN(~s_pad_cfg[1][0]));
  pad_functional_pu i_pad_2   (.OEN(~s_io_oe[2]), .I(s_jtag_tdo), .O(s_io_in[2]), .PAD(xilinx_io[2]), .PEN(~s_pad_cfg[2][0]));
  pad_functional_pu i_pad_3   (.OEN(~s_io_oe[3]), .I(s_io_out[3]), .O(s_io_in[3]), .PAD(xilinx_io[3]), .PEN(~s_pad_cfg[3][0]));
  pad_functional_pu i_pad_4   (.OEN(~s_io_oe[4]), .I(s_io_out[4]), .O(s_io_in[4]), .PAD(xilinx_io[4]), .PEN(~s_pad_cfg[4][0]));
  // Input clock buffer
  IBUFDS #(
    .IOSTANDARD("LVDS"),
    .IBUF_LOW_PWR("FALSE")
  ) i_sysclk_iobuf (
    .I(sysclk_p),
    .IB(sysclk_n),
    .O(s_io_in[5])
  );

  fpga_slow_clk_gen i_slow_clk_gen (
    .rst_ni(s_io_in[6]),
    .clk_i(s_slow_clk),
    .ref_clk_o(private_net)
    );
  IBUF rstn_buf (
    .I(xilinx_io[6]), .O(s_io_in[6]));
  pad_functional_pu i_pad_7   (.OEN(~s_io_oe[7]), .I(s_io_out[7]), .O(s_io_in[7]), .PAD(xilinx_io[7]), .PEN(~s_pad_cfg[7][0]));
  pad_functional_pu i_pad_8   (.OEN(~s_io_oe[8]), .I(s_io_out[8]), .O(s_io_in[8]), .PAD(xilinx_io[8]), .PEN(~s_pad_cfg[8][0]));
  pad_functional_pu i_pad_9   (.OEN(~s_io_oe[9]), .I(s_io_out[9]), .O(s_io_in[9]), .PAD(xilinx_io[9]), .PEN(~s_pad_cfg[9][0]));
  pad_functional_pu i_pad_10   (.OEN(~s_io_oe[10]), .I(s_io_out[10]), .O(s_io_in[10]), .PAD(xilinx_io[10]), .PEN(~s_pad_cfg[10][0]));
  pad_functional_pu i_pad_11   (.OEN(~s_io_oe[11]), .I(s_io_out[11]), .O(s_io_in[11]), .PAD(xilinx_io[11]), .PEN(~s_pad_cfg[11][0]));
  pad_functional_pu i_pad_12   (.OEN(~s_io_oe[12]), .I(s_io_out[12]), .O(s_io_in[12]), .PAD(xilinx_io[12]), .PEN(~s_pad_cfg[12][0]));
  pad_functional_pu i_pad_13   (.OEN(~s_io_oe[13]), .I(s_io_out[13]), .O(s_io_in[13]), .PAD(xilinx_io[13]), .PEN(~s_pad_cfg[13][0]));
  pad_functional_pu i_pad_14   (.OEN(~s_io_oe[14]), .I(s_io_out[14]), .O(s_io_in[14]), .PAD(xilinx_io[14]), .PEN(~s_pad_cfg[14][0]));
  pad_functional_pu i_pad_15   (.OEN(~s_io_oe[15]), .I(s_io_out[15]), .O(s_io_in[15]), .PAD(xilinx_io[15]), .PEN(~s_pad_cfg[15][0]));
  pad_functional_pu i_pad_16   (.OEN(~s_io_oe[16]), .I(s_io_out[16]), .O(s_io_in[16]), .PAD(xilinx_io[16]), .PEN(~s_pad_cfg[16][0]));
  pad_functional_pu i_pad_17   (.OEN(~s_io_oe[17]), .I(s_io_out[17]), .O(s_io_in[17]), .PAD(xilinx_io[17]), .PEN(~s_pad_cfg[17][0]));
  pad_functional_pu i_pad_18   (.OEN(~s_io_oe[18]), .I(s_io_out[18]), .O(s_io_in[18]), .PAD(xilinx_io[18]), .PEN(~s_pad_cfg[18][0]));
  pad_functional_pu i_pad_19   (.OEN(~s_io_oe[19]), .I(s_io_out[19]), .O(s_io_in[19]), .PAD(xilinx_io[19]), .PEN(~s_pad_cfg[19][0]));
  pad_functional_pu i_pad_20   (.OEN(~s_io_oe[20]), .I(s_io_out[20]), .O(s_io_in[20]), .PAD(xilinx_io[20]), .PEN(~s_pad_cfg[20][0]));
  pad_functional_pu i_pad_21   (.OEN(~s_io_oe[21]), .I(s_io_out[21]), .O(s_io_in[21]), .PAD(xilinx_io[21]), .PEN(~s_pad_cfg[21][0]));
  pad_functional_pu i_pad_22   (.OEN(~s_io_oe[22]), .I(s_io_out[22]), .O(s_io_in[22]), .PAD(xilinx_io[22]), .PEN(~s_pad_cfg[22][0]));
  pad_functional_pu i_pad_23   (.OEN(~s_io_oe[23]), .I(s_io_out[23]), .O(s_io_in[23]), .PAD(xilinx_io[23]), .PEN(~s_pad_cfg[23][0]));
  pad_functional_pu i_pad_24   (.OEN(~s_io_oe[24]), .I(s_io_out[24]), .O(s_io_in[24]), .PAD(xilinx_io[24]), .PEN(~s_pad_cfg[24][0]));
  pad_functional_pu i_pad_25   (.OEN(~s_io_oe[25]), .I(s_io_out[25]), .O(s_io_in[25]), .PAD(xilinx_io[25]), .PEN(~s_pad_cfg[25][0]));
  pad_functional_pu i_pad_26   (.OEN(~s_io_oe[26]), .I(s_io_out[26]), .O(s_io_in[26]), .PAD(xilinx_io[26]), .PEN(~s_pad_cfg[26][0]));
  pad_functional_pu i_pad_27   (.OEN(~s_io_oe[27]), .I(s_io_out[27]), .O(s_io_in[27]), .PAD(xilinx_io[27]), .PEN(~s_pad_cfg[27][0]));
  pad_functional_pu i_pad_28   (.OEN(~s_io_oe[28]), .I(s_io_out[28]), .O(s_io_in[28]), .PAD(xilinx_io[28]), .PEN(~s_pad_cfg[28][0]));
  pad_functional_pu i_pad_29   (.OEN(~s_io_oe[29]), .I(s_io_out[29]), .O(s_io_in[29]), .PAD(xilinx_io[29]), .PEN(~s_pad_cfg[29][0]));
  pad_functional_pu i_pad_30   (.OEN(~s_io_oe[30]), .I(s_io_out[30]), .O(s_io_in[30]), .PAD(xilinx_io[30]), .PEN(~s_pad_cfg[30][0]));
  pad_functional_pu i_pad_31   (.OEN(~s_io_oe[31]), .I(s_io_out[31]), .O(s_io_in[31]), .PAD(xilinx_io[31]), .PEN(~s_pad_cfg[31][0]));
  pad_functional_pu i_pad_32   (.OEN(~s_io_oe[32]), .I(s_io_out[32]), .O(s_io_in[32]), .PAD(xilinx_io[32]), .PEN(~s_pad_cfg[32][0]));
  pad_functional_pu i_pad_33   (.OEN(~s_io_oe[33]), .I(s_io_out[33]), .O(s_io_in[33]), .PAD(xilinx_io[33]), .PEN(~s_pad_cfg[33][0]));
  pad_functional_pu i_pad_34   (.OEN(~s_io_oe[34]), .I(s_io_out[34]), .O(s_io_in[34]), .PAD(xilinx_io[34]), .PEN(~s_pad_cfg[34][0]));
  pad_functional_pu i_pad_35   (.OEN(~s_io_oe[35]), .I(s_io_out[35]), .O(s_io_in[35]), .PAD(xilinx_io[35]), .PEN(~s_pad_cfg[35][0]));
  pad_functional_pu i_pad_36   (.OEN(~s_io_oe[36]), .I(s_io_out[36]), .O(s_io_in[36]), .PAD(xilinx_io[36]), .PEN(~s_pad_cfg[36][0]));
  pad_functional_pu i_pad_37   (.OEN(~s_io_oe[37]), .I(s_io_out[37]), .O(s_io_in[37]), .PAD(xilinx_io[37]), .PEN(~s_pad_cfg[37][0]));
  pad_functional_pu i_pad_38   (.OEN(~s_io_oe[38]), .I(s_io_out[38]), .O(s_io_in[38]), .PAD(xilinx_io[38]), .PEN(~s_pad_cfg[38][0]));
  pad_functional_pu i_pad_39   (.OEN(~s_io_oe[39]), .I(s_io_out[39]), .O(s_io_in[39]), .PAD(xilinx_io[39]), .PEN(~s_pad_cfg[39][0]));
  pad_functional_pu i_pad_40   (.OEN(~s_io_oe[40]), .I(s_io_out[40]), .O(s_io_in[40]), .PAD(xilinx_io[40]), .PEN(~s_pad_cfg[40][0]));
  pad_functional_pu i_pad_41   (.OEN(~s_io_oe[41]), .I(s_io_out[41]), .O(s_io_in[41]), .PAD(xilinx_io[41]), .PEN(~s_pad_cfg[41][0]));
  pad_functional_pu i_pad_42   (.OEN(~s_io_oe[42]), .I(s_io_out[42]), .O(s_io_in[42]), .PAD(xilinx_io[42]), .PEN(~s_pad_cfg[42][0]));
  pad_functional_pu i_pad_43   (.OEN(~s_io_oe[43]), .I(s_io_out[43]), .O(s_io_in[43]), .PAD(xilinx_io[43]), .PEN(~s_pad_cfg[43][0]));
  pad_functional_pd i_pad_44   (.OEN(~s_io_oe[44]), .I(s_io_out[44]), .O(s_io_in[44]), .PAD(xilinx_io[44]), .PEN(~s_pad_cfg[44][0]));
  pad_functional_pd i_pad_45   (.OEN(~s_io_oe[45]), .I(s_io_out[45]), .O(s_io_in[45]), .PAD(xilinx_io[45]), .PEN(~s_pad_cfg[45][0]));
  pad_functional_pu i_pad_46   (.OEN(~s_io_oe[46]), .I(s_io_out[46]), .O(s_io_in[46]), .PAD(xilinx_io[46]), .PEN(~s_pad_cfg[46][0]));
  pad_functional_pu i_pad_47   (.OEN(~s_io_oe[47]), .I(s_io_out[47]), .O(s_io_in[47]), .PAD(xilinx_io[47]), .PEN(~s_pad_cfg[47][0]));
      assign s_jtag_tck = s_io_in[0];
      assign s_jtag_tdi = s_io_in[1];
      assign s_jtag_tms = s_io_in[3];
      assign s_jtag_trst = s_io_in[4];
      assign s_sysclk_p = s_io_in[5];
      assign s_rstn = s_io_in[6];
      assign s_stm = s_io_in[44];
      assign s_bootsel = s_io_in[45];
  core_v_mcu i_core_v_mcu (
    .jtag_tck_i(s_jtag_tck),
    .jtag_tdi_i(s_jtag_tdi),
    .jtag_tdo_o(s_jtag_tdo),
    .jtag_tms_i(s_jtag_tms),
    .jtag_trst_i(s_jtag_trst),
    .ref_clk_i(private_net),
    .rstn_i(s_rstn),
    .stm_i(s_stm),
    .bootsel_i(s_bootsel),
    .slow_clk_o(s_slow_clk),
    .io_out_o(s_io_out),
    .io_oe_o(s_io_oe),
    .io_in_i(s_io_in),
    .pad_cfg_o(s_pad_cfg)
  );
endmodule
