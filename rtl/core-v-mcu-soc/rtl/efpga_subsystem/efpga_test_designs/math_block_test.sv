// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


module math_block_test (
    input logic clk_i,
    input logic rst_ni,


    output logic MU0_EFPGA2MATHB_CLK,
    output logic MU0_EFPGA_MATHB_CLK_EN,

    output logic MU0_EFPGA_MATHB_OPER_DATA_0_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_1_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_2_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_3_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_4_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_5_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_6_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_7_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_8_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_9_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_10_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_11_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_12_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_13_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_14_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_15_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_16_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_17_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_18_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_19_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_20_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_21_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_22_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_23_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_24_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_25_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_26_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_27_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_28_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_29_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_30_,
    output logic MU0_EFPGA_MATHB_OPER_DATA_31_,

    output logic MU0_EFPGA_MATHB_OPER_SEL,

    output logic MU0_EFPGA_MATHB_OPER_defPin_1_,
    output logic MU0_EFPGA_MATHB_OPER_defPin_0_,

    output logic MU0_EFPGA_MATHB_COEF_DATA_0_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_1_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_2_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_3_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_4_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_5_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_6_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_7_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_8_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_9_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_10_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_11_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_12_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_13_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_14_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_15_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_16_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_17_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_18_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_19_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_20_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_21_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_22_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_23_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_24_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_25_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_26_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_27_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_28_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_29_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_30_,
    output logic MU0_EFPGA_MATHB_COEF_DATA_31_,

    output logic MU0_EFPGA_MATHB_COEF_SEL,

    output logic MU0_EFPGA_MATHB_COEF_defPin_1_,
    output logic MU0_EFPGA_MATHB_COEF_defPin_0_,

    output logic MU0_EFPGA_MATHB_DATAOUT_SEL_0_,
    output logic MU0_EFPGA_MATHB_DATAOUT_SEL_1_,

    output logic MU0_EFPGA_MATHB_MAC_ACC_CLEAR,

    output logic MU0_EFPGA_MATHB_MAC_ACC_RND,
    output logic MU0_EFPGA_MATHB_MAC_ACC_SAT,

    output logic MU0_EFPGA_MATHB_MAC_OUT_SEL_0_,
    output logic MU0_EFPGA_MATHB_MAC_OUT_SEL_1_,
    output logic MU0_EFPGA_MATHB_MAC_OUT_SEL_2_,
    output logic MU0_EFPGA_MATHB_MAC_OUT_SEL_3_,
    output logic MU0_EFPGA_MATHB_MAC_OUT_SEL_4_,
    output logic MU0_EFPGA_MATHB_MAC_OUT_SEL_5_,

    output logic MU0_EFPGA_MATHB_TC_defPin,

    input logic MU0_MATHB_EFPGA_MAC_OUT_0_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_1_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_2_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_3_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_4_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_5_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_6_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_7_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_8_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_9_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_10_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_11_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_12_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_13_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_14_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_15_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_16_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_17_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_18_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_19_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_20_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_21_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_22_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_23_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_24_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_25_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_26_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_27_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_28_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_29_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_30_,
    input logic MU0_MATHB_EFPGA_MAC_OUT_31_,

    input logic apb_hwce_psel_i,
    input logic apb_hwce_penable_i,
    input logic apb_hwce_pwrite_i,
    input logic apb_hwce_addr_0_i,
    input logic apb_hwce_addr_1_i,
    input logic apb_hwce_addr_2_i,
    input logic apb_hwce_addr_3_i,
    input logic apb_hwce_addr_4_i,
    input logic apb_hwce_addr_5_i,
    input logic apb_hwce_addr_6_i,

    output logic apb_hwce_prdata_0_o,
    output logic apb_hwce_prdata_1_o,
    output logic apb_hwce_prdata_2_o,
    output logic apb_hwce_prdata_3_o,
    output logic apb_hwce_prdata_4_o,
    output logic apb_hwce_prdata_5_o,
    output logic apb_hwce_prdata_6_o,
    output logic apb_hwce_prdata_7_o,
    output logic apb_hwce_prdata_8_o,
    output logic apb_hwce_prdata_9_o,
    output logic apb_hwce_prdata_10_o,
    output logic apb_hwce_prdata_11_o,
    output logic apb_hwce_prdata_12_o,
    output logic apb_hwce_prdata_13_o,
    output logic apb_hwce_prdata_14_o,
    output logic apb_hwce_prdata_15_o,
    output logic apb_hwce_prdata_16_o,
    output logic apb_hwce_prdata_17_o,
    output logic apb_hwce_prdata_18_o,
    output logic apb_hwce_prdata_19_o,
    output logic apb_hwce_prdata_20_o,
    output logic apb_hwce_prdata_21_o,
    output logic apb_hwce_prdata_22_o,
    output logic apb_hwce_prdata_23_o,
    output logic apb_hwce_prdata_24_o,
    output logic apb_hwce_prdata_25_o,
    output logic apb_hwce_prdata_26_o,
    output logic apb_hwce_prdata_27_o,
    output logic apb_hwce_prdata_28_o,
    output logic apb_hwce_prdata_29_o,
    output logic apb_hwce_prdata_30_o,
    output logic apb_hwce_prdata_31_o,

    input logic apb_hwce_pwdata_0_i,
    input logic apb_hwce_pwdata_1_i,
    input logic apb_hwce_pwdata_2_i,
    input logic apb_hwce_pwdata_3_i,
    input logic apb_hwce_pwdata_4_i,
    input logic apb_hwce_pwdata_5_i,
    input logic apb_hwce_pwdata_6_i,
    input logic apb_hwce_pwdata_7_i,
    input logic apb_hwce_pwdata_8_i,
    input logic apb_hwce_pwdata_9_i,
    input logic apb_hwce_pwdata_10_i,
    input logic apb_hwce_pwdata_11_i,
    input logic apb_hwce_pwdata_12_i,
    input logic apb_hwce_pwdata_13_i,
    input logic apb_hwce_pwdata_14_i,
    input logic apb_hwce_pwdata_15_i,
    input logic apb_hwce_pwdata_16_i,
    input logic apb_hwce_pwdata_17_i,
    input logic apb_hwce_pwdata_18_i,
    input logic apb_hwce_pwdata_19_i,
    input logic apb_hwce_pwdata_20_i,
    input logic apb_hwce_pwdata_21_i,
    input logic apb_hwce_pwdata_22_i,
    input logic apb_hwce_pwdata_23_i,
    input logic apb_hwce_pwdata_24_i,
    input logic apb_hwce_pwdata_25_i,
    input logic apb_hwce_pwdata_26_i,
    input logic apb_hwce_pwdata_27_i,
    input logic apb_hwce_pwdata_28_i,
    input logic apb_hwce_pwdata_29_i,
    input logic apb_hwce_pwdata_30_i,
    input logic apb_hwce_pwdata_31_i,

    output logic apb_hwce_ready_o

);


  logic [31:0] apb_pwdata;
  logic [ 6:0] apb_hwce_addr;
  logic [31:0] apb_hwce_prdata;

  logic [31:0] data0, coef0, result0, sampled_result0;
  logic clear_acc0, make_mul0, signed_mult, operator_sel;
  logic
      is_data0,
      is_coef0,
      is_result0,
      is_clear_acc0,
      is_makemul0,
      is_mac_out_sel,
      is_signed_mul,
      is_operator_sel;
  logic [5:0] mac_out_sel;
  logic       clk_q;

  assign MU0_EFPGA_MATHB_OPER_defPin_1_ = 1'b0;
  assign MU0_EFPGA_MATHB_OPER_defPin_0_ = 1'b0;
  assign MU0_EFPGA_MATHB_OPER_SEL = 1'b0;  //pragma attribute MU0_EFPGA_MATHB_OPER_SEL pad out_buff

  assign MU0_EFPGA_MATHB_COEF_defPin_1_ = 1'b0;
  assign MU0_EFPGA_MATHB_COEF_defPin_0_ = 1'b0;
  assign MU0_EFPGA_MATHB_COEF_SEL = operator_sel;

  assign { MU0_EFPGA_MATHB_MAC_OUT_SEL_5_, MU0_EFPGA_MATHB_MAC_OUT_SEL_4_, MU0_EFPGA_MATHB_MAC_OUT_SEL_3_, MU0_EFPGA_MATHB_MAC_OUT_SEL_2_, MU0_EFPGA_MATHB_MAC_OUT_SEL_1_ ,MU0_EFPGA_MATHB_MAC_OUT_SEL_0_ } = mac_out_sel;

  assign MU0_EFPGA_MATHB_DATAOUT_SEL_1_ = 1'b0; //pragma attribute MU0_EFPGA_MATHB_DATAOUT_SEL_1_ pad out_buff
  assign MU0_EFPGA_MATHB_DATAOUT_SEL_0_ = 1'b0; //pragma attribute MU0_EFPGA_MATHB_DATAOUT_SEL_0_ pad out_buff


  assign MU0_EFPGA_MATHB_MAC_ACC_CLEAR = clear_acc0;
  assign MU0_EFPGA_MATHB_MAC_ACC_RND   = 1'b0; //pragma attribute MU0_EFPGA_MATHB_MAC_ACC_RND pad out_buff
  assign MU0_EFPGA_MATHB_MAC_ACC_SAT   = 1'b0; //pragma attribute MU0_EFPGA_MATHB_MAC_ACC_SAT pad out_buff
  assign MU0_EFPGA_MATHB_TC_defPin = 1'b1;

  assign MU0_EFPGA2MATHB_CLK = clk_i;  //pragma attribute clk_i pad ck_buff
  assign MU0_EFPGA_MATHB_CLK_EN = make_mul0;

  assign result0[0] = MU0_MATHB_EFPGA_MAC_OUT_0_;
  assign result0[1] = MU0_MATHB_EFPGA_MAC_OUT_1_;
  assign result0[2] = MU0_MATHB_EFPGA_MAC_OUT_2_;
  assign result0[3] = MU0_MATHB_EFPGA_MAC_OUT_3_;
  assign result0[4] = MU0_MATHB_EFPGA_MAC_OUT_4_;
  assign result0[5] = MU0_MATHB_EFPGA_MAC_OUT_5_;
  assign result0[6] = MU0_MATHB_EFPGA_MAC_OUT_6_;
  assign result0[7] = MU0_MATHB_EFPGA_MAC_OUT_7_;
  assign result0[8] = MU0_MATHB_EFPGA_MAC_OUT_8_;
  assign result0[9] = MU0_MATHB_EFPGA_MAC_OUT_9_;
  assign result0[10] = MU0_MATHB_EFPGA_MAC_OUT_10_;
  assign result0[11] = MU0_MATHB_EFPGA_MAC_OUT_11_;
  assign result0[12] = MU0_MATHB_EFPGA_MAC_OUT_12_;
  assign result0[13] = MU0_MATHB_EFPGA_MAC_OUT_13_;
  assign result0[14] = MU0_MATHB_EFPGA_MAC_OUT_14_;
  assign result0[15] = MU0_MATHB_EFPGA_MAC_OUT_15_;
  assign result0[16] = MU0_MATHB_EFPGA_MAC_OUT_16_;
  assign result0[17] = MU0_MATHB_EFPGA_MAC_OUT_17_;
  assign result0[18] = MU0_MATHB_EFPGA_MAC_OUT_18_;
  assign result0[19] = MU0_MATHB_EFPGA_MAC_OUT_19_;
  assign result0[20] = MU0_MATHB_EFPGA_MAC_OUT_20_;
  assign result0[21] = MU0_MATHB_EFPGA_MAC_OUT_21_;
  assign result0[22] = MU0_MATHB_EFPGA_MAC_OUT_22_;
  assign result0[23] = MU0_MATHB_EFPGA_MAC_OUT_23_;
  assign result0[24] = MU0_MATHB_EFPGA_MAC_OUT_24_;
  assign result0[25] = MU0_MATHB_EFPGA_MAC_OUT_25_;
  assign result0[26] = MU0_MATHB_EFPGA_MAC_OUT_26_;
  assign result0[27] = MU0_MATHB_EFPGA_MAC_OUT_27_;
  assign result0[28] = MU0_MATHB_EFPGA_MAC_OUT_28_;
  assign result0[29] = MU0_MATHB_EFPGA_MAC_OUT_29_;
  assign result0[30] = MU0_MATHB_EFPGA_MAC_OUT_30_;
  assign result0[31] = MU0_MATHB_EFPGA_MAC_OUT_31_;


  assign MU0_EFPGA_MATHB_OPER_DATA_0_ = data0[0];
  assign MU0_EFPGA_MATHB_OPER_DATA_1_ = data0[1];
  assign MU0_EFPGA_MATHB_OPER_DATA_2_ = data0[2];
  assign MU0_EFPGA_MATHB_OPER_DATA_3_ = data0[3];
  assign MU0_EFPGA_MATHB_OPER_DATA_4_ = data0[4];
  assign MU0_EFPGA_MATHB_OPER_DATA_5_ = data0[5];
  assign MU0_EFPGA_MATHB_OPER_DATA_6_ = data0[6];
  assign MU0_EFPGA_MATHB_OPER_DATA_7_ = data0[7];
  assign MU0_EFPGA_MATHB_OPER_DATA_8_ = data0[8];
  assign MU0_EFPGA_MATHB_OPER_DATA_9_ = data0[9];
  assign MU0_EFPGA_MATHB_OPER_DATA_10_ = data0[10];
  assign MU0_EFPGA_MATHB_OPER_DATA_11_ = data0[11];
  assign MU0_EFPGA_MATHB_OPER_DATA_12_ = data0[12];
  assign MU0_EFPGA_MATHB_OPER_DATA_13_ = data0[13];
  assign MU0_EFPGA_MATHB_OPER_DATA_14_ = data0[14];
  assign MU0_EFPGA_MATHB_OPER_DATA_15_ = data0[15];
  assign MU0_EFPGA_MATHB_OPER_DATA_16_ = data0[16];
  assign MU0_EFPGA_MATHB_OPER_DATA_17_ = data0[17];
  assign MU0_EFPGA_MATHB_OPER_DATA_18_ = data0[18];
  assign MU0_EFPGA_MATHB_OPER_DATA_19_ = data0[19];
  assign MU0_EFPGA_MATHB_OPER_DATA_20_ = data0[20];
  assign MU0_EFPGA_MATHB_OPER_DATA_21_ = data0[21];
  assign MU0_EFPGA_MATHB_OPER_DATA_22_ = data0[22];
  assign MU0_EFPGA_MATHB_OPER_DATA_23_ = data0[23];
  assign MU0_EFPGA_MATHB_OPER_DATA_24_ = data0[24];
  assign MU0_EFPGA_MATHB_OPER_DATA_25_ = data0[25];
  assign MU0_EFPGA_MATHB_OPER_DATA_26_ = data0[26];
  assign MU0_EFPGA_MATHB_OPER_DATA_27_ = data0[27];
  assign MU0_EFPGA_MATHB_OPER_DATA_28_ = data0[28];
  assign MU0_EFPGA_MATHB_OPER_DATA_29_ = data0[29];
  assign MU0_EFPGA_MATHB_OPER_DATA_30_ = data0[30];
  assign MU0_EFPGA_MATHB_OPER_DATA_31_ = data0[31];

  assign MU0_EFPGA_MATHB_COEF_DATA_0_ = coef0[0];
  assign MU0_EFPGA_MATHB_COEF_DATA_1_ = coef0[1];
  assign MU0_EFPGA_MATHB_COEF_DATA_2_ = coef0[2];
  assign MU0_EFPGA_MATHB_COEF_DATA_3_ = coef0[3];
  assign MU0_EFPGA_MATHB_COEF_DATA_4_ = coef0[4];
  assign MU0_EFPGA_MATHB_COEF_DATA_5_ = coef0[5];
  assign MU0_EFPGA_MATHB_COEF_DATA_6_ = coef0[6];
  assign MU0_EFPGA_MATHB_COEF_DATA_7_ = coef0[7];
  assign MU0_EFPGA_MATHB_COEF_DATA_8_ = coef0[8];
  assign MU0_EFPGA_MATHB_COEF_DATA_9_ = coef0[9];
  assign MU0_EFPGA_MATHB_COEF_DATA_10_ = coef0[10];
  assign MU0_EFPGA_MATHB_COEF_DATA_11_ = coef0[11];
  assign MU0_EFPGA_MATHB_COEF_DATA_12_ = coef0[12];
  assign MU0_EFPGA_MATHB_COEF_DATA_13_ = coef0[13];
  assign MU0_EFPGA_MATHB_COEF_DATA_14_ = coef0[14];
  assign MU0_EFPGA_MATHB_COEF_DATA_15_ = coef0[15];
  assign MU0_EFPGA_MATHB_COEF_DATA_16_ = coef0[16];
  assign MU0_EFPGA_MATHB_COEF_DATA_17_ = coef0[17];
  assign MU0_EFPGA_MATHB_COEF_DATA_18_ = coef0[18];
  assign MU0_EFPGA_MATHB_COEF_DATA_19_ = coef0[19];
  assign MU0_EFPGA_MATHB_COEF_DATA_20_ = coef0[20];
  assign MU0_EFPGA_MATHB_COEF_DATA_21_ = coef0[21];
  assign MU0_EFPGA_MATHB_COEF_DATA_22_ = coef0[22];
  assign MU0_EFPGA_MATHB_COEF_DATA_23_ = coef0[23];
  assign MU0_EFPGA_MATHB_COEF_DATA_24_ = coef0[24];
  assign MU0_EFPGA_MATHB_COEF_DATA_25_ = coef0[25];
  assign MU0_EFPGA_MATHB_COEF_DATA_26_ = coef0[26];
  assign MU0_EFPGA_MATHB_COEF_DATA_27_ = coef0[27];
  assign MU0_EFPGA_MATHB_COEF_DATA_28_ = coef0[28];
  assign MU0_EFPGA_MATHB_COEF_DATA_29_ = coef0[29];
  assign MU0_EFPGA_MATHB_COEF_DATA_30_ = coef0[30];
  assign MU0_EFPGA_MATHB_COEF_DATA_31_ = coef0[31];

  assign apb_hwce_addr = {
    apb_hwce_addr_6_i,
    apb_hwce_addr_5_i,
    apb_hwce_addr_4_i,
    apb_hwce_addr_3_i,
    apb_hwce_addr_2_i,
    apb_hwce_addr_1_i,
    apb_hwce_addr_0_i
  };


  assign is_data0 = apb_hwce_addr == 7'h0;  //0x00
  assign is_coef0 = apb_hwce_addr == 7'h1;  //0x04
  assign is_result0 = apb_hwce_addr == 7'h2;  //0x08
  assign is_clear_acc0 = apb_hwce_addr == 7'h3;  //0x0C
  assign is_makemul0 = apb_hwce_addr == 7'h4;  //0x10
  assign is_mac_out_sel = apb_hwce_addr == 7'h5;  //0x14
  assign is_signed_mul = apb_hwce_addr == 7'h6;  //0x18
  assign is_operator_sel = apb_hwce_addr == 7'h7;  //0x1C

  assign apb_hwce_ready_o = 1'b1;  //pragma attribute apb_hwce_ready_o pad out_buff

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      data0        <= '0;
      coef0        <= '0;
      clear_acc0   <= '0;
      make_mul0    <= '0;
      mac_out_sel  <= '0;
      signed_mult  <= '0;
      operator_sel <= '0;
    end else begin
      if (apb_hwce_psel_i && apb_hwce_penable_i && apb_hwce_pwrite_i && is_data0) begin
        data0 <= apb_pwdata[31:0];
      end
      if (apb_hwce_psel_i && apb_hwce_penable_i && apb_hwce_pwrite_i && is_coef0) begin
        coef0 <= apb_pwdata[31:0];
      end
      if (apb_hwce_psel_i && apb_hwce_penable_i && apb_hwce_pwrite_i && is_clear_acc0) begin
        clear_acc0 <= apb_pwdata[0];
      end
      if (apb_hwce_psel_i && apb_hwce_penable_i && apb_hwce_pwrite_i && is_makemul0) begin
        make_mul0 <= apb_pwdata[0];
      end
      if (apb_hwce_psel_i && apb_hwce_penable_i && apb_hwce_pwrite_i && is_mac_out_sel) begin
        mac_out_sel <= apb_pwdata[5:0];
      end
      if (apb_hwce_psel_i && apb_hwce_penable_i && apb_hwce_pwrite_i && is_signed_mul) begin
        signed_mult <= apb_pwdata[0];
      end
      if (apb_hwce_psel_i && apb_hwce_penable_i && apb_hwce_pwrite_i && is_operator_sel) begin
        operator_sel <= apb_pwdata[0];
      end
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      sampled_result0 <= '0;
      clk_q           <= 1'b0;
    end else begin
      if (clear_acc0) begin
        sampled_result0 <= result0;
      end
      clk_q <= ~clk_q;
    end
  end

  always_comb begin
    apb_hwce_prdata = '0;
    if (apb_hwce_psel_i & apb_hwce_penable_i & ~apb_hwce_pwrite_i) begin

      if (is_data0) apb_hwce_prdata = data0;
      else if (is_coef0) apb_hwce_prdata = coef0;
      else if (is_result0) apb_hwce_prdata = sampled_result0;
      else apb_hwce_prdata = '0;
    end

  end

  assign apb_pwdata = {
    apb_hwce_pwdata_31_i,
    apb_hwce_pwdata_30_i,
    apb_hwce_pwdata_29_i,
    apb_hwce_pwdata_28_i,
    apb_hwce_pwdata_27_i,
    apb_hwce_pwdata_26_i,
    apb_hwce_pwdata_25_i,
    apb_hwce_pwdata_24_i,
    apb_hwce_pwdata_23_i,
    apb_hwce_pwdata_22_i,
    apb_hwce_pwdata_21_i,
    apb_hwce_pwdata_20_i,
    apb_hwce_pwdata_19_i,
    apb_hwce_pwdata_18_i,
    apb_hwce_pwdata_17_i,
    apb_hwce_pwdata_16_i,
    apb_hwce_pwdata_15_i,
    apb_hwce_pwdata_14_i,
    apb_hwce_pwdata_13_i,
    apb_hwce_pwdata_12_i,
    apb_hwce_pwdata_11_i,
    apb_hwce_pwdata_10_i,
    apb_hwce_pwdata_9_i,
    apb_hwce_pwdata_8_i,
    apb_hwce_pwdata_7_i,
    apb_hwce_pwdata_6_i,
    apb_hwce_pwdata_5_i,
    apb_hwce_pwdata_4_i,
    apb_hwce_pwdata_3_i,
    apb_hwce_pwdata_2_i,
    apb_hwce_pwdata_1_i,
    apb_hwce_pwdata_0_i
  };

  assign            {
                        apb_hwce_prdata_31_o,
                        apb_hwce_prdata_30_o,
                        apb_hwce_prdata_29_o,
                        apb_hwce_prdata_28_o,
                        apb_hwce_prdata_27_o,
                        apb_hwce_prdata_26_o,
                        apb_hwce_prdata_25_o,
                        apb_hwce_prdata_24_o,
                        apb_hwce_prdata_23_o,
                        apb_hwce_prdata_22_o,
                        apb_hwce_prdata_21_o,
                        apb_hwce_prdata_20_o,
                        apb_hwce_prdata_19_o,
                        apb_hwce_prdata_18_o,
                        apb_hwce_prdata_17_o,
                        apb_hwce_prdata_16_o,
                        apb_hwce_prdata_15_o,
                        apb_hwce_prdata_14_o,
                        apb_hwce_prdata_13_o,
                        apb_hwce_prdata_12_o,
                        apb_hwce_prdata_11_o,
                        apb_hwce_prdata_10_o,
                        apb_hwce_prdata_9_o,
                        apb_hwce_prdata_8_o,
                        apb_hwce_prdata_7_o,
                        apb_hwce_prdata_6_o,
                        apb_hwce_prdata_5_o,
                        apb_hwce_prdata_4_o,
                        apb_hwce_prdata_3_o,
                        apb_hwce_prdata_2_o,
                        apb_hwce_prdata_1_o,
                        apb_hwce_prdata_0_o
                       } = apb_hwce_prdata;


endmodule
