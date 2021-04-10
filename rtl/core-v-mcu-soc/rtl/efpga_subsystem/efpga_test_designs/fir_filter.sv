// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


module fir_test (
    input logic clk_i,
    input logic rst_ni,

    output logic tcdm_req_p0_o,
    output logic tcdm_addr_p0_0_o,
    output logic tcdm_addr_p0_1_o,
    output logic tcdm_addr_p0_2_o,
    output logic tcdm_addr_p0_3_o,
    output logic tcdm_addr_p0_4_o,
    output logic tcdm_addr_p0_5_o,
    output logic tcdm_addr_p0_6_o,
    output logic tcdm_addr_p0_7_o,
    output logic tcdm_addr_p0_8_o,
    output logic tcdm_addr_p0_9_o,
    output logic tcdm_addr_p0_10_o,
    output logic tcdm_addr_p0_11_o,
    output logic tcdm_addr_p0_12_o,
    output logic tcdm_addr_p0_13_o,
    output logic tcdm_addr_p0_14_o,
    output logic tcdm_addr_p0_15_o,
    output logic tcdm_addr_p0_16_o,
    output logic tcdm_addr_p0_17_o,
    output logic tcdm_addr_p0_18_o,
    output logic tcdm_addr_p0_19_o,
    output logic tcdm_wen_p0_o,
    output logic tcdm_wdata_p0_0_o,
    output logic tcdm_wdata_p0_1_o,
    output logic tcdm_wdata_p0_2_o,
    output logic tcdm_wdata_p0_3_o,
    output logic tcdm_wdata_p0_4_o,
    output logic tcdm_wdata_p0_5_o,
    output logic tcdm_wdata_p0_6_o,
    output logic tcdm_wdata_p0_7_o,
    output logic tcdm_wdata_p0_8_o,
    output logic tcdm_wdata_p0_9_o,
    output logic tcdm_wdata_p0_10_o,
    output logic tcdm_wdata_p0_11_o,
    output logic tcdm_wdata_p0_12_o,
    output logic tcdm_wdata_p0_13_o,
    output logic tcdm_wdata_p0_14_o,
    output logic tcdm_wdata_p0_15_o,
    output logic tcdm_wdata_p0_16_o,
    output logic tcdm_wdata_p0_17_o,
    output logic tcdm_wdata_p0_18_o,
    output logic tcdm_wdata_p0_19_o,
    output logic tcdm_wdata_p0_20_o,
    output logic tcdm_wdata_p0_21_o,
    output logic tcdm_wdata_p0_22_o,
    output logic tcdm_wdata_p0_23_o,
    output logic tcdm_wdata_p0_24_o,
    output logic tcdm_wdata_p0_25_o,
    output logic tcdm_wdata_p0_26_o,
    output logic tcdm_wdata_p0_27_o,
    output logic tcdm_wdata_p0_28_o,
    output logic tcdm_wdata_p0_29_o,
    output logic tcdm_wdata_p0_30_o,
    output logic tcdm_wdata_p0_31_o,
    input  logic tcdm_r_rdata_p0_0_i,
    input  logic tcdm_r_rdata_p0_1_i,
    input  logic tcdm_r_rdata_p0_2_i,
    input  logic tcdm_r_rdata_p0_3_i,
    input  logic tcdm_r_rdata_p0_4_i,
    input  logic tcdm_r_rdata_p0_5_i,
    input  logic tcdm_r_rdata_p0_6_i,
    input  logic tcdm_r_rdata_p0_7_i,
    input  logic tcdm_r_rdata_p0_8_i,
    input  logic tcdm_r_rdata_p0_9_i,
    input  logic tcdm_r_rdata_p0_10_i,
    input  logic tcdm_r_rdata_p0_11_i,
    input  logic tcdm_r_rdata_p0_12_i,
    input  logic tcdm_r_rdata_p0_13_i,
    input  logic tcdm_r_rdata_p0_14_i,
    input  logic tcdm_r_rdata_p0_15_i,
    input  logic tcdm_r_rdata_p0_16_i,
    input  logic tcdm_r_rdata_p0_17_i,
    input  logic tcdm_r_rdata_p0_18_i,
    input  logic tcdm_r_rdata_p0_19_i,
    input  logic tcdm_r_rdata_p0_20_i,
    input  logic tcdm_r_rdata_p0_21_i,
    input  logic tcdm_r_rdata_p0_22_i,
    input  logic tcdm_r_rdata_p0_23_i,
    input  logic tcdm_r_rdata_p0_24_i,
    input  logic tcdm_r_rdata_p0_25_i,
    input  logic tcdm_r_rdata_p0_26_i,
    input  logic tcdm_r_rdata_p0_27_i,
    input  logic tcdm_r_rdata_p0_28_i,
    input  logic tcdm_r_rdata_p0_29_i,
    input  logic tcdm_r_rdata_p0_30_i,
    input  logic tcdm_r_rdata_p0_31_i,
    output logic tcdm_be_p0_0_o,
    output logic tcdm_be_p0_1_o,
    output logic tcdm_be_p0_2_o,
    output logic tcdm_be_p0_3_o,
    input  logic tcdm_gnt_p0_i,
    input  logic tcdm_r_valid_p0_i,

    output logic tcdm_req_p1_o,
    output logic tcdm_addr_p1_0_o,
    output logic tcdm_addr_p1_1_o,
    output logic tcdm_addr_p1_2_o,
    output logic tcdm_addr_p1_3_o,
    output logic tcdm_addr_p1_4_o,
    output logic tcdm_addr_p1_5_o,
    output logic tcdm_addr_p1_6_o,
    output logic tcdm_addr_p1_7_o,
    output logic tcdm_addr_p1_8_o,
    output logic tcdm_addr_p1_9_o,
    output logic tcdm_addr_p1_10_o,
    output logic tcdm_addr_p1_11_o,
    output logic tcdm_addr_p1_12_o,
    output logic tcdm_addr_p1_13_o,
    output logic tcdm_addr_p1_14_o,
    output logic tcdm_addr_p1_15_o,
    output logic tcdm_addr_p1_16_o,
    output logic tcdm_addr_p1_17_o,
    output logic tcdm_addr_p1_18_o,
    output logic tcdm_addr_p1_19_o,
    output logic tcdm_wen_p1_o,
    output logic tcdm_wdata_p1_0_o,
    output logic tcdm_wdata_p1_1_o,
    output logic tcdm_wdata_p1_2_o,
    output logic tcdm_wdata_p1_3_o,
    output logic tcdm_wdata_p1_4_o,
    output logic tcdm_wdata_p1_5_o,
    output logic tcdm_wdata_p1_6_o,
    output logic tcdm_wdata_p1_7_o,
    output logic tcdm_wdata_p1_8_o,
    output logic tcdm_wdata_p1_9_o,
    output logic tcdm_wdata_p1_10_o,
    output logic tcdm_wdata_p1_11_o,
    output logic tcdm_wdata_p1_12_o,
    output logic tcdm_wdata_p1_13_o,
    output logic tcdm_wdata_p1_14_o,
    output logic tcdm_wdata_p1_15_o,
    output logic tcdm_wdata_p1_16_o,
    output logic tcdm_wdata_p1_17_o,
    output logic tcdm_wdata_p1_18_o,
    output logic tcdm_wdata_p1_19_o,
    output logic tcdm_wdata_p1_20_o,
    output logic tcdm_wdata_p1_21_o,
    output logic tcdm_wdata_p1_22_o,
    output logic tcdm_wdata_p1_23_o,
    output logic tcdm_wdata_p1_24_o,
    output logic tcdm_wdata_p1_25_o,
    output logic tcdm_wdata_p1_26_o,
    output logic tcdm_wdata_p1_27_o,
    output logic tcdm_wdata_p1_28_o,
    output logic tcdm_wdata_p1_29_o,
    output logic tcdm_wdata_p1_30_o,
    output logic tcdm_wdata_p1_31_o,
    input  logic tcdm_r_rdata_p1_0_i,
    input  logic tcdm_r_rdata_p1_1_i,
    input  logic tcdm_r_rdata_p1_2_i,
    input  logic tcdm_r_rdata_p1_3_i,
    input  logic tcdm_r_rdata_p1_4_i,
    input  logic tcdm_r_rdata_p1_5_i,
    input  logic tcdm_r_rdata_p1_6_i,
    input  logic tcdm_r_rdata_p1_7_i,
    input  logic tcdm_r_rdata_p1_8_i,
    input  logic tcdm_r_rdata_p1_9_i,
    input  logic tcdm_r_rdata_p1_10_i,
    input  logic tcdm_r_rdata_p1_11_i,
    input  logic tcdm_r_rdata_p1_12_i,
    input  logic tcdm_r_rdata_p1_13_i,
    input  logic tcdm_r_rdata_p1_14_i,
    input  logic tcdm_r_rdata_p1_15_i,
    input  logic tcdm_r_rdata_p1_16_i,
    input  logic tcdm_r_rdata_p1_17_i,
    input  logic tcdm_r_rdata_p1_18_i,
    input  logic tcdm_r_rdata_p1_19_i,
    input  logic tcdm_r_rdata_p1_20_i,
    input  logic tcdm_r_rdata_p1_21_i,
    input  logic tcdm_r_rdata_p1_22_i,
    input  logic tcdm_r_rdata_p1_23_i,
    input  logic tcdm_r_rdata_p1_24_i,
    input  logic tcdm_r_rdata_p1_25_i,
    input  logic tcdm_r_rdata_p1_26_i,
    input  logic tcdm_r_rdata_p1_27_i,
    input  logic tcdm_r_rdata_p1_28_i,
    input  logic tcdm_r_rdata_p1_29_i,
    input  logic tcdm_r_rdata_p1_30_i,
    input  logic tcdm_r_rdata_p1_31_i,
    output logic tcdm_be_p1_0_o,
    output logic tcdm_be_p1_1_o,
    output logic tcdm_be_p1_2_o,
    output logic tcdm_be_p1_3_o,
    input  logic tcdm_gnt_p1_i,
    input  logic tcdm_r_valid_p1_i,

    output logic tcdm_req_p2_o,
    output logic tcdm_addr_p2_0_o,
    output logic tcdm_addr_p2_1_o,
    output logic tcdm_addr_p2_2_o,
    output logic tcdm_addr_p2_3_o,
    output logic tcdm_addr_p2_4_o,
    output logic tcdm_addr_p2_5_o,
    output logic tcdm_addr_p2_6_o,
    output logic tcdm_addr_p2_7_o,
    output logic tcdm_addr_p2_8_o,
    output logic tcdm_addr_p2_9_o,
    output logic tcdm_addr_p2_10_o,
    output logic tcdm_addr_p2_11_o,
    output logic tcdm_addr_p2_12_o,
    output logic tcdm_addr_p2_13_o,
    output logic tcdm_addr_p2_14_o,
    output logic tcdm_addr_p2_15_o,
    output logic tcdm_addr_p2_16_o,
    output logic tcdm_addr_p2_17_o,
    output logic tcdm_addr_p2_18_o,
    output logic tcdm_addr_p2_19_o,
    output logic tcdm_wen_p2_o,
    output logic tcdm_wdata_p2_0_o,
    output logic tcdm_wdata_p2_1_o,
    output logic tcdm_wdata_p2_2_o,
    output logic tcdm_wdata_p2_3_o,
    output logic tcdm_wdata_p2_4_o,
    output logic tcdm_wdata_p2_5_o,
    output logic tcdm_wdata_p2_6_o,
    output logic tcdm_wdata_p2_7_o,
    output logic tcdm_wdata_p2_8_o,
    output logic tcdm_wdata_p2_9_o,
    output logic tcdm_wdata_p2_10_o,
    output logic tcdm_wdata_p2_11_o,
    output logic tcdm_wdata_p2_12_o,
    output logic tcdm_wdata_p2_13_o,
    output logic tcdm_wdata_p2_14_o,
    output logic tcdm_wdata_p2_15_o,
    output logic tcdm_wdata_p2_16_o,
    output logic tcdm_wdata_p2_17_o,
    output logic tcdm_wdata_p2_18_o,
    output logic tcdm_wdata_p2_19_o,
    output logic tcdm_wdata_p2_20_o,
    output logic tcdm_wdata_p2_21_o,
    output logic tcdm_wdata_p2_22_o,
    output logic tcdm_wdata_p2_23_o,
    output logic tcdm_wdata_p2_24_o,
    output logic tcdm_wdata_p2_25_o,
    output logic tcdm_wdata_p2_26_o,
    output logic tcdm_wdata_p2_27_o,
    output logic tcdm_wdata_p2_28_o,
    output logic tcdm_wdata_p2_29_o,
    output logic tcdm_wdata_p2_30_o,
    output logic tcdm_wdata_p2_31_o,
    input  logic tcdm_r_rdata_p2_0_i,
    input  logic tcdm_r_rdata_p2_1_i,
    input  logic tcdm_r_rdata_p2_2_i,
    input  logic tcdm_r_rdata_p2_3_i,
    input  logic tcdm_r_rdata_p2_4_i,
    input  logic tcdm_r_rdata_p2_5_i,
    input  logic tcdm_r_rdata_p2_6_i,
    input  logic tcdm_r_rdata_p2_7_i,
    input  logic tcdm_r_rdata_p2_8_i,
    input  logic tcdm_r_rdata_p2_9_i,
    input  logic tcdm_r_rdata_p2_10_i,
    input  logic tcdm_r_rdata_p2_11_i,
    input  logic tcdm_r_rdata_p2_12_i,
    input  logic tcdm_r_rdata_p2_13_i,
    input  logic tcdm_r_rdata_p2_14_i,
    input  logic tcdm_r_rdata_p2_15_i,
    input  logic tcdm_r_rdata_p2_16_i,
    input  logic tcdm_r_rdata_p2_17_i,
    input  logic tcdm_r_rdata_p2_18_i,
    input  logic tcdm_r_rdata_p2_19_i,
    input  logic tcdm_r_rdata_p2_20_i,
    input  logic tcdm_r_rdata_p2_21_i,
    input  logic tcdm_r_rdata_p2_22_i,
    input  logic tcdm_r_rdata_p2_23_i,
    input  logic tcdm_r_rdata_p2_24_i,
    input  logic tcdm_r_rdata_p2_25_i,
    input  logic tcdm_r_rdata_p2_26_i,
    input  logic tcdm_r_rdata_p2_27_i,
    input  logic tcdm_r_rdata_p2_28_i,
    input  logic tcdm_r_rdata_p2_29_i,
    input  logic tcdm_r_rdata_p2_30_i,
    input  logic tcdm_r_rdata_p2_31_i,
    output logic tcdm_be_p2_0_o,
    output logic tcdm_be_p2_1_o,
    output logic tcdm_be_p2_2_o,
    output logic tcdm_be_p2_3_o,
    input  logic tcdm_gnt_p2_i,
    input  logic tcdm_r_valid_p2_i,

    output logic tcdm_req_p3_o,
    output logic tcdm_addr_p3_0_o,
    output logic tcdm_addr_p3_1_o,
    output logic tcdm_addr_p3_2_o,
    output logic tcdm_addr_p3_3_o,
    output logic tcdm_addr_p3_4_o,
    output logic tcdm_addr_p3_5_o,
    output logic tcdm_addr_p3_6_o,
    output logic tcdm_addr_p3_7_o,
    output logic tcdm_addr_p3_8_o,
    output logic tcdm_addr_p3_9_o,
    output logic tcdm_addr_p3_10_o,
    output logic tcdm_addr_p3_11_o,
    output logic tcdm_addr_p3_12_o,
    output logic tcdm_addr_p3_13_o,
    output logic tcdm_addr_p3_14_o,
    output logic tcdm_addr_p3_15_o,
    output logic tcdm_addr_p3_16_o,
    output logic tcdm_addr_p3_17_o,
    output logic tcdm_addr_p3_18_o,
    output logic tcdm_addr_p3_19_o,
    output logic tcdm_wen_p3_o,
    output logic tcdm_wdata_p3_0_o,
    output logic tcdm_wdata_p3_1_o,
    output logic tcdm_wdata_p3_2_o,
    output logic tcdm_wdata_p3_3_o,
    output logic tcdm_wdata_p3_4_o,
    output logic tcdm_wdata_p3_5_o,
    output logic tcdm_wdata_p3_6_o,
    output logic tcdm_wdata_p3_7_o,
    output logic tcdm_wdata_p3_8_o,
    output logic tcdm_wdata_p3_9_o,
    output logic tcdm_wdata_p3_10_o,
    output logic tcdm_wdata_p3_11_o,
    output logic tcdm_wdata_p3_12_o,
    output logic tcdm_wdata_p3_13_o,
    output logic tcdm_wdata_p3_14_o,
    output logic tcdm_wdata_p3_15_o,
    output logic tcdm_wdata_p3_16_o,
    output logic tcdm_wdata_p3_17_o,
    output logic tcdm_wdata_p3_18_o,
    output logic tcdm_wdata_p3_19_o,
    output logic tcdm_wdata_p3_20_o,
    output logic tcdm_wdata_p3_21_o,
    output logic tcdm_wdata_p3_22_o,
    output logic tcdm_wdata_p3_23_o,
    output logic tcdm_wdata_p3_24_o,
    output logic tcdm_wdata_p3_25_o,
    output logic tcdm_wdata_p3_26_o,
    output logic tcdm_wdata_p3_27_o,
    output logic tcdm_wdata_p3_28_o,
    output logic tcdm_wdata_p3_29_o,
    output logic tcdm_wdata_p3_30_o,
    output logic tcdm_wdata_p3_31_o,
    input  logic tcdm_r_rdata_p3_0_i,
    input  logic tcdm_r_rdata_p3_1_i,
    input  logic tcdm_r_rdata_p3_2_i,
    input  logic tcdm_r_rdata_p3_3_i,
    input  logic tcdm_r_rdata_p3_4_i,
    input  logic tcdm_r_rdata_p3_5_i,
    input  logic tcdm_r_rdata_p3_6_i,
    input  logic tcdm_r_rdata_p3_7_i,
    input  logic tcdm_r_rdata_p3_8_i,
    input  logic tcdm_r_rdata_p3_9_i,
    input  logic tcdm_r_rdata_p3_10_i,
    input  logic tcdm_r_rdata_p3_11_i,
    input  logic tcdm_r_rdata_p3_12_i,
    input  logic tcdm_r_rdata_p3_13_i,
    input  logic tcdm_r_rdata_p3_14_i,
    input  logic tcdm_r_rdata_p3_15_i,
    input  logic tcdm_r_rdata_p3_16_i,
    input  logic tcdm_r_rdata_p3_17_i,
    input  logic tcdm_r_rdata_p3_18_i,
    input  logic tcdm_r_rdata_p3_19_i,
    input  logic tcdm_r_rdata_p3_20_i,
    input  logic tcdm_r_rdata_p3_21_i,
    input  logic tcdm_r_rdata_p3_22_i,
    input  logic tcdm_r_rdata_p3_23_i,
    input  logic tcdm_r_rdata_p3_24_i,
    input  logic tcdm_r_rdata_p3_25_i,
    input  logic tcdm_r_rdata_p3_26_i,
    input  logic tcdm_r_rdata_p3_27_i,
    input  logic tcdm_r_rdata_p3_28_i,
    input  logic tcdm_r_rdata_p3_29_i,
    input  logic tcdm_r_rdata_p3_30_i,
    input  logic tcdm_r_rdata_p3_31_i,
    output logic tcdm_be_p3_0_o,
    output logic tcdm_be_p3_1_o,
    output logic tcdm_be_p3_2_o,
    output logic tcdm_be_p3_3_o,
    input  logic tcdm_gnt_p3_i,
    input  logic tcdm_r_valid_p3_i,

    input logic apb_hwce_psel_i,
    input logic apb_hwce_enable_i,
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

    output logic apb_hwce_ready_o,

    output logic gpio_oe_0_o,
    output logic gpio_data_0_o,
    input  logic gpio_data_0_i,
    output logic gpio_oe_1_o,
    output logic gpio_data_1_o,
    input  logic gpio_data_1_i,
    output logic gpio_oe_2_o,
    output logic gpio_data_2_o,
    input  logic gpio_data_2_i,
    output logic gpio_oe_3_o,
    output logic gpio_data_3_o,
    input  logic gpio_data_3_i,
    output logic gpio_oe_4_o,
    output logic gpio_data_4_o,
    input  logic gpio_data_4_i,
    output logic gpio_oe_5_o,
    output logic gpio_data_5_o,
    input  logic gpio_data_5_i,
    output logic gpio_oe_6_o,
    output logic gpio_data_6_o,
    input  logic gpio_data_6_i,
    output logic gpio_oe_7_o,
    output logic gpio_data_7_o,
    input  logic gpio_data_7_i,
    output logic gpio_oe_8_o,
    output logic gpio_data_8_o,
    input  logic gpio_data_8_i,
    output logic gpio_oe_9_o,
    output logic gpio_data_9_o,
    input  logic gpio_data_9_i,
    output logic gpio_oe_10_o,
    output logic gpio_data_10_o,
    input  logic gpio_data_10_i,
    output logic gpio_oe_11_o,
    output logic gpio_data_11_o,
    input  logic gpio_data_11_i,
    output logic gpio_oe_12_o,
    output logic gpio_data_12_o,
    input  logic gpio_data_12_i,
    output logic gpio_oe_13_o,
    output logic gpio_data_13_o,
    input  logic gpio_data_13_i,
    output logic gpio_oe_14_o,
    output logic gpio_data_14_o,
    input  logic gpio_data_14_i,
    output logic gpio_oe_15_o,
    output logic gpio_data_15_o,
    input  logic gpio_data_15_i,
    output logic gpio_oe_16_o,
    output logic gpio_data_16_o,
    input  logic gpio_data_16_i,
    output logic gpio_oe_17_o,
    output logic gpio_data_17_o,
    input  logic gpio_data_17_i,
    output logic gpio_oe_18_o,
    output logic gpio_data_18_o,
    input  logic gpio_data_18_i,
    output logic gpio_oe_19_o,
    output logic gpio_data_19_o,
    input  logic gpio_data_19_i,
    output logic gpio_oe_20_o,
    output logic gpio_data_20_o,
    input  logic gpio_data_20_i,
    output logic gpio_oe_21_o,
    output logic gpio_data_21_o,
    input  logic gpio_data_21_i,
    output logic gpio_oe_22_o,
    output logic gpio_data_22_o,
    input  logic gpio_data_22_i,
    output logic gpio_oe_23_o,
    output logic gpio_data_23_o,
    input  logic gpio_data_23_i,
    output logic gpio_oe_24_o,
    output logic gpio_data_24_o,
    input  logic gpio_data_24_i,
    output logic gpio_oe_25_o,
    output logic gpio_data_25_o,
    input  logic gpio_data_25_i,
    output logic gpio_oe_26_o,
    output logic gpio_data_26_o,
    input  logic gpio_data_26_i,
    output logic gpio_oe_27_o,
    output logic gpio_data_27_o,
    input  logic gpio_data_27_i,
    output logic gpio_oe_28_o,
    output logic gpio_data_28_o,
    input  logic gpio_data_28_i,
    output logic gpio_oe_29_o,
    output logic gpio_data_29_o,
    input  logic gpio_data_29_i,
    output logic gpio_oe_30_o,
    output logic gpio_data_30_o,
    input  logic gpio_data_30_i,
    output logic gpio_oe_31_o,
    output logic gpio_data_31_o,
    input  logic gpio_data_31_i,
    output logic gpio_oe_32_o,
    output logic gpio_data_32_o,
    input  logic gpio_data_32_i,
    output logic gpio_oe_33_o,
    output logic gpio_data_33_o,
    input  logic gpio_data_33_i,
    output logic gpio_oe_34_o,
    output logic gpio_data_34_o,
    input  logic gpio_data_34_i,
    output logic gpio_oe_35_o,
    output logic gpio_data_35_o,
    input  logic gpio_data_35_i,
    output logic gpio_oe_36_o,
    output logic gpio_data_36_o,
    input  logic gpio_data_36_i,
    output logic gpio_oe_37_o,
    output logic gpio_data_37_o,
    input  logic gpio_data_37_i,
    output logic gpio_oe_38_o,
    output logic gpio_data_38_o,
    input  logic gpio_data_38_i,
    output logic gpio_oe_39_o,
    output logic gpio_data_39_o,
    input  logic gpio_data_39_i,
    output logic gpio_oe_40_o,
    output logic gpio_data_40_o,
    input  logic gpio_data_40_i,

    output logic events_0_o,
    output logic events_1_o,
    output logic events_2_o,
    output logic events_3_o,
    output logic events_4_o,
    output logic events_5_o,
    output logic events_6_o,
    output logic events_7_o,
    output logic events_8_o,
    output logic events_9_o,
    output logic events_10_o,
    output logic events_11_o,
    output logic events_12_o,
    output logic events_13_o,
    output logic events_14_o,
    output logic events_15_o,


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
    input logic MU0_MATHB_EFPGA_MAC_OUT_31_



);


  logic [31:0] apb_pwdata;
  logic [ 6:0] apb_hwce_addr;
  logic [31:0] apb_hwce_prdata;

  logic [1:0] fir_counter_n, fir_counter_q;

  logic [19:0] read_address_q;
  logic [19:0] real_address3, real_address2, real_address1, real_address0;
  logic [19:0] store_address_q;
  logic [ 3:0] tcdm_be;
  logic start_q, done_q;
  logic [14:0] sw_event_q;


  logic is_tcdm_address_read, is_tcdm_address_store, is_coef, is_start;
  logic is_done, is_num_elem;
  logic is_configuration_sel;
  logic is_gpio_rego_l_val, is_gpio_rego_h_val;
  logic is_gpio_rego_l_oe, is_gpio_rego_h_oe;
  logic is_gpio_sample_regi;
  logic is_sw_event_sel;

  logic start0, start1, start2, start3;
  logic write0, write1, write2, write3;
  logic store_data0, store_data1, store_data2, store_data3, store_data4;
  logic make_shuffle;

  logic ld_st_ack, mac_ready, mac_ack, mac_start;
  logic [1:0] ld_st_counter_q;
  logic [2:0] ld_st_counter_n;
  logic incaddr_read, incaddr_store;
  logic data_valid0, data_valid1, data_valid2, data_valid3, all_data_valid;
  logic [3:0] data_valid;
  logic [3:0] address_offset0, address_offset1, address_offset2, address_offset3;

  logic [7:0] coef3_q, coef2_q, coef1_q, coef0_q;
  logic [7:0] sel_coef3, sel_coef2, sel_coef1, sel_coef0;

  logic reset_accumulator, reset_accumulator_q, reset_data_valid;
  logic increase_counter_shuffle, reset_counter_shuffle;
  logic [3:0] counter_shuffle;
  logic [3:0] sel_counter;
  logic [1:0] index3, index2, index1, index0;

  logic [7:0] num_elem_q, num_elem_n;
  logic last_iteration, store_num_elem, store_mac;
  logic [2:0] store_mac_q;

  logic [31:0] data_read[4:0];
  logic [31:0] mac_result[3:0];

  logic [31:0] tcdm_r_rdata_p0, tcdm_r_rdata_p1, tcdm_r_rdata_p2, tcdm_r_rdata_p3;

  logic [31:0] result0, selected_data;
  logic [40:0] gpio_oe_reg;
  logic [40:0] gpio_val_reg;
  logic [40:0] gpio_in;

  logic [15:0] configuration_sel;
  logic [4:0] read_addr_inc, store_addr_inc;

  `define MODE8 2'b11
  `define MODE16 2'b10
  `define MODE32 2'b01

  enum logic [2:0] {
    IDLE,
    READ_FIRST_TIME,
    READ_NEXT,
    WAIT_MAC,
    STORE,
    READ
  }
      state_n, state_q;
  enum logic [1:0] {
    START,
    COMPUTE,
    NEXT_ITERATION,
    WAIT_LD_ST
  }
      state_fir_n, state_fir_q;


  assign apb_hwce_addr = {
    apb_hwce_addr_6_i,
    apb_hwce_addr_5_i,
    apb_hwce_addr_4_i,
    apb_hwce_addr_3_i,
    apb_hwce_addr_2_i,
    apb_hwce_addr_1_i,
    apb_hwce_addr_0_i
  };




  assign apb_hwce_ready_o = 1'b1;  //pragma attribute apb_hwce_ready_o pad out_buff

  assign tcdm_be_p0_0_o = tcdm_be[0];
  assign tcdm_be_p0_1_o = tcdm_be[1];
  assign tcdm_be_p0_2_o = tcdm_be[2];
  assign tcdm_be_p0_3_o = tcdm_be[3];
  assign tcdm_wen_p0_o = ~write0;

  assign tcdm_be_p1_0_o = tcdm_be[0];
  assign tcdm_be_p1_1_o = tcdm_be[1];
  assign tcdm_be_p1_2_o = tcdm_be[2];
  assign tcdm_be_p1_3_o = tcdm_be[3];
  assign tcdm_wen_p1_o = ~write1;

  assign tcdm_be_p2_0_o = tcdm_be[0];
  assign tcdm_be_p2_1_o = tcdm_be[1];
  assign tcdm_be_p2_2_o = tcdm_be[2];
  assign tcdm_be_p2_3_o = tcdm_be[3];
  assign tcdm_wen_p2_o = ~write2;

  assign tcdm_be_p3_0_o = tcdm_be[0];
  assign tcdm_be_p3_1_o = tcdm_be[1];
  assign tcdm_be_p3_2_o = tcdm_be[2];
  assign tcdm_be_p3_3_o = tcdm_be[3];
  assign tcdm_wen_p3_o = ~write3;


  assign all_data_valid = data_valid[0] & data_valid[1] & data_valid[2] & data_valid[3];

  assign last_iteration = num_elem_q == 0;

  /*  SHUFFLE */
  always_comb begin

    index0 = sel_counter[3:2] + 0;
    index1 = sel_counter[3:2] + 1;
    index2 = sel_counter[3:2] + 2;
    index3 = sel_counter[3:2] + 3;

    case (sel_counter[1:0])

      2'b00:
      selected_data = {
        data_read[index3][7:0],
        data_read[index2][7:0],
        data_read[index1][7:0],
        data_read[index0][7:0]
      };
      2'b01:
      selected_data = {
        data_read[index3][15:8],
        data_read[index2][15:8],
        data_read[index1][15:8],
        data_read[index0][15:8]
      };
      2'b10:
      selected_data = {
        data_read[index3][23:16],
        data_read[index2][23:16],
        data_read[index1][23:16],
        data_read[index0][23:16]
      };
      2'b11:
      selected_data = {
        data_read[index3][31:24],
        data_read[index2][31:24],
        data_read[index1][31:24],
        data_read[index0][31:24]
      };

    endcase

    case (fir_counter_q[1:0])

      2'b00: begin
        sel_coef0 = coef0_q;
        sel_coef1 = coef0_q;
        sel_coef2 = coef0_q;
        sel_coef3 = coef0_q;
      end

      2'b01: begin
        sel_coef0 = coef1_q;
        sel_coef1 = coef1_q;
        sel_coef2 = coef1_q;
        sel_coef3 = coef1_q;
      end

      2'b10: begin
        sel_coef0 = coef2_q;
        sel_coef1 = coef2_q;
        sel_coef2 = coef2_q;
        sel_coef3 = coef2_q;
      end

      2'b11: begin
        sel_coef0 = coef3_q;
        sel_coef1 = coef3_q;
        sel_coef2 = coef3_q;
        sel_coef3 = coef3_q;
      end

    endcase

  end





  always_comb begin

    state_n                                                           = state_q;
    {start0, start1, start2, start3}                                  = 4'b0000;
    {write0, write1, write2, write3}                                  = 4'b0000;
    {incaddr_read, incaddr_store}                                     = 2'b00;
    address_offset0                                                   = 0;
    address_offset1                                                   = 4;
    address_offset2                                                   = 8;
    address_offset3                                                   = 12;
    reset_data_valid                                                  = 1'b0;
    store_num_elem                                                    = 1'b0;
    {store_data0, store_data1, store_data2, store_data3, store_data4} = 5'b0;
    ld_st_counter_n                                                   = '0;
    mac_ack                                                           = 1'b0;
    mac_start                                                         = 1'b0;
    num_elem_n                                                        = num_elem_q;
    read_addr_inc                                                     = 16;
    store_addr_inc                                                    = 16;

    unique case (state_q)

      IDLE: begin
        if (start_q) begin
          state_n          = READ_FIRST_TIME;
          reset_data_valid = 1'b1;
        end
      end


      //it requires minim 5 reads so 4+4+4+4+4 = 20 elements
      READ_FIRST_TIME: begin
        {start0, start1, start2, start3} = ~{
          data_valid[0], data_valid[1], data_valid[2], data_valid[3]
        };
        {write0, write1, write2, write3} = 4'b0000;
        reset_data_valid = all_data_valid;
        num_elem_n = num_elem_q - 16;
        store_num_elem = all_data_valid;
        {store_data0, store_data1, store_data2, store_data3, store_data4} = {
          data_valid0, data_valid1, data_valid2, data_valid3, 1'b0
        };
        {incaddr_read, incaddr_store} = all_data_valid ? 2'b10 : 2'b00;
        state_n = all_data_valid ? READ_NEXT : state_q;
      end

      WAIT_MAC: begin
        mac_start = 1'b1;
        state_n   = ld_st_ack ? READ_NEXT : state_q;
      end


      READ_NEXT: begin
        {start0, start1, start2, start3} = ~{data_valid[0], 3'b111};
        {write0, write1, write2, write3} = 4'b0000;
        state_n = data_valid0 ? STORE : state_q;
        reset_data_valid = data_valid0;
        num_elem_n = num_elem_q - 4;
        store_num_elem = data_valid0;
        {store_data0, store_data1, store_data2, store_data3, store_data4} = {4'b0, data_valid0};
        {incaddr_read, incaddr_store} = data_valid0 ? 2'b10 : 2'b00;
        read_addr_inc = 4;
        mac_start = data_valid0;
      end

      STORE: begin
        {write0, write1, write2, write3} = 4'b1111;
        if (mac_ready) begin
          {start0, start1, start2, start3} = ~{
            data_valid[0], data_valid[1], data_valid[2], data_valid[3]
          };
          mac_ack = 1'b1;
        end
        ld_st_counter_n = all_data_valid ? $unsigned(ld_st_counter_q) + 1 : ld_st_counter_q;
        state_n                            = all_data_valid ? (last_iteration ? IDLE : (ld_st_counter_q[1:0] == 2'b11 ? READ : STORE)) : STORE;
        {incaddr_read, incaddr_store}      = all_data_valid  && ld_st_counter_q[1:0] == 2'b11 ? 2'b01 : 2'b00;
        reset_data_valid = all_data_valid;
      end

      READ: begin
        {start0, start1, start2, start3} = ~{
          data_valid[0], data_valid[1], data_valid[2], data_valid[3]
        };
        {write0, write1, write2, write3} = 4'b0000;
        reset_data_valid = all_data_valid;
        num_elem_n = num_elem_q - 16;
        if (num_elem_n[6] == 1)  //negative number
          num_elem_n = '0;
        store_num_elem = all_data_valid;
        {store_data0, store_data1, store_data2, store_data3, store_data4} = {
          1'b0, data_valid0, data_valid1, data_valid2, data_valid3
        };
        {incaddr_read, incaddr_store} = all_data_valid ? 2'b10 : 2'b00;
        mac_start = all_data_valid;
        state_n = all_data_valid ? STORE : state_q;
        //I am assuming the other FSM is in START
      end

      default: begin
      end

    endcase  // state_q
  end


  always_comb begin

    reset_accumulator        = 1'b0;
    store_mac                = 1'b0;
    increase_counter_shuffle = 1'b0;
    fir_counter_n            = '0;
    reset_counter_shuffle    = 1'b0;
    mac_ready                = 1'b0;
    state_fir_n              = state_fir_q;
    make_shuffle             = 1'b0;
    ld_st_ack                = 1'b0;

    unique case (state_fir_q)

      START: begin
        mac_ready = 1'b1;
        if (mac_start) begin
          state_fir_n           = COMPUTE;
          reset_accumulator     = 1'b1;
          ld_st_ack             = 1'b1;
          reset_counter_shuffle = 1'b1;
        end
      end

      COMPUTE: begin
        store_mac     = fir_counter_q[1:0] == 2'b11;
        fir_counter_n = fir_counter_q[1:0] == 2'b11 ? fir_counter_q : fir_counter_q + 1;
        if (store_mac) begin
          reset_accumulator = 1'b1;
          fir_counter_n     = '0;
          state_fir_n       = NEXT_ITERATION;
        end

      end

      NEXT_ITERATION: begin
        reset_accumulator        = 1'b1;
        increase_counter_shuffle = 1'b1;
        make_shuffle             = 1'b1;
        state_fir_n              = counter_shuffle[1:0] == 2'b11 ? WAIT_LD_ST : COMPUTE;
      end

      WAIT_LD_ST: begin
        mac_ready   = store_mac_q[2];
        state_fir_n = mac_ack ? START : WAIT_LD_ST;
      end


      default: begin
      end

    endcase  // state_q
  end

  assign sel_counter[3:0] = {2'b0, fir_counter_q[1:0]} + counter_shuffle;


  tcdm_streamer tdcm0_str (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .tcdm_req_o    (tcdm_req_p0_o),
      .tcdm_gnt_i    (tcdm_gnt_p0_i),
      .tcdm_r_valid_i(tcdm_r_valid_p0_i),
      .start_i       (start0),
      .data_valid_o  (data_valid0)
  );

  tcdm_streamer tdcm1_str (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .tcdm_req_o    (tcdm_req_p1_o),
      .tcdm_gnt_i    (tcdm_gnt_p1_i),
      .tcdm_r_valid_i(tcdm_r_valid_p1_i),
      .start_i       (start1),
      .data_valid_o  (data_valid1)
  );

  tcdm_streamer tdcm2_str (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .tcdm_req_o    (tcdm_req_p2_o),
      .tcdm_gnt_i    (tcdm_gnt_p2_i),
      .tcdm_r_valid_i(tcdm_r_valid_p2_i),
      .start_i       (start2),
      .data_valid_o  (data_valid2)
  );

  tcdm_streamer tdcm3_str (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .tcdm_req_o    (tcdm_req_p3_o),
      .tcdm_gnt_i    (tcdm_gnt_p3_i),
      .tcdm_r_valid_i(tcdm_r_valid_p3_i),
      .start_i       (start3),
      .data_valid_o  (data_valid3)
  );

  assign real_address0 = address_offset0 + (write0 ? store_address_q : read_address_q);
  assign real_address1 = address_offset1 + (write1 ? store_address_q : read_address_q);
  assign real_address2 = address_offset2 + (write2 ? store_address_q : read_address_q);
  assign real_address3 = address_offset3 + (write3 ? store_address_q : read_address_q);

  logic [1:0] mac_res_sel;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      read_address_q                       <= '0;
      store_address_q                      <= '0;
      {coef3_q, coef2_q, coef1_q, coef0_q} <= '0;
      gpio_oe_reg                          <= '0;
      gpio_val_reg                         <= '0;
      sw_event_q                           <= '0;
      counter_shuffle                      <= '0;
      fir_counter_q                        <= '0;
      data_valid                           <= '0;
      configuration_sel                    <= '0;
      start_q                              <= 1'b0;
      done_q                               <= 1'b0;
      num_elem_q                           <= '0;
      data_read[0]                         <= '0;
      data_read[1]                         <= '0;
      data_read[2]                         <= '0;
      data_read[3]                         <= '0;
      data_read[4]                         <= '0;
      mac_result[0]                        <= '0;
      mac_result[1]                        <= '0;
      mac_result[2]                        <= '0;
      mac_result[3]                        <= '0;
      ld_st_counter_q                      <= '0;
      store_mac_q                          <= 3'b0;
      state_q                              <= IDLE;
      state_fir_q                          <= START;
      reset_accumulator_q                  <= 1'b0;
      mac_res_sel                          <= 2'b0;
    end else begin

      if (incaddr_read) read_address_q <= read_address_q + read_addr_inc;

      if (incaddr_store) store_address_q <= store_address_q + store_addr_inc;

      if (increase_counter_shuffle) counter_shuffle <= counter_shuffle + 1;

      if (reset_counter_shuffle) counter_shuffle <= '0;

      if (store_num_elem) num_elem_q <= num_elem_n;

      reset_accumulator_q <= reset_accumulator;


      fir_counter_q <= fir_counter_n;
      store_mac_q <= {store_mac_q[1], store_mac_q[0], store_mac};
      if (store_mac) mac_res_sel <= counter_shuffle[1:0];

      if (store_mac_q[1]) begin
        case (mac_res_sel)
          2'b00: mac_result[0] <= result0;
          2'b01: mac_result[1] <= result0;
          2'b10: mac_result[2] <= result0;
          2'b11: mac_result[3] <= result0;
        endcase
      end


      ld_st_counter_q <= ld_st_counter_n[1:0];

      if (state_q == READ) begin
        if (store_data3) data_read[3] <= tcdm_r_rdata_p2;
        if (store_data2) data_read[2] <= tcdm_r_rdata_p1;
        if (store_data1) data_read[1] <= tcdm_r_rdata_p0;
        if (store_data0) data_read[0] <= tcdm_r_rdata_p0;
        if (store_data4) data_read[4] <= tcdm_r_rdata_p3;
      end else begin
        if (store_data3) data_read[3] <= tcdm_r_rdata_p3;
        if (store_data2) data_read[2] <= tcdm_r_rdata_p2;
        if (store_data1) data_read[1] <= tcdm_r_rdata_p1;
        if (store_data0) data_read[0] <= tcdm_r_rdata_p0;
        if (store_data4) data_read[4] <= tcdm_r_rdata_p0;
      end
      if (make_shuffle) begin
        case (counter_shuffle[1:0])
          2'b00: data_read[0] <= {data_read[0][31:8], data_read[4][7:0]};
          2'b01: data_read[0] <= {data_read[0][31:16], data_read[4][15:0]};
          2'b10: data_read[0] <= {data_read[0][31:24], data_read[4][23:0]};
          2'b11: data_read[0] <= data_read[4];
        endcase
      end


      if (reset_data_valid) data_valid <= '0;
      else begin
        if (data_valid3) data_valid[3] <= 1'b1;
        if (data_valid2) data_valid[2] <= 1'b1;
        if (data_valid1) data_valid[1] <= 1'b1;
        if (data_valid0) data_valid[0] <= 1'b1;
      end

      if (last_iteration && state_q == STORE && all_data_valid) begin
        start_q <= 1'b0;
        done_q  <= 1'b1;
      end

      state_q     <= state_n;
      state_fir_q <= state_fir_n;

      if (apb_hwce_psel_i && apb_hwce_enable_i && apb_hwce_pwrite_i) begin
        if (is_tcdm_address_read) read_address_q <= apb_pwdata[19:0];
        if (is_tcdm_address_store) store_address_q <= apb_pwdata[19:0];
        if (is_coef) {coef3_q, coef2_q, coef1_q, coef0_q} <= apb_pwdata[31:0];
        if (is_start) start_q <= apb_pwdata[0];
        if (is_done) done_q <= apb_pwdata[0];
        if (is_num_elem) num_elem_q <= {1'b0, apb_pwdata[6:0]};
        if (is_configuration_sel) begin
          configuration_sel <= apb_pwdata[15:0];
        end
        if (is_sw_event_sel) sw_event_q <= apb_pwdata[16:2];
        if (is_gpio_rego_l_val) gpio_val_reg[31:0] <= apb_pwdata[31:0];
        if (is_gpio_rego_h_val) gpio_val_reg[40:32] <= apb_pwdata[8:0];
        if (is_gpio_rego_l_oe) gpio_oe_reg[31:0] <= apb_pwdata[31:0];
        if (is_gpio_rego_h_oe) gpio_oe_reg[40:32] <= apb_pwdata[8:0];
        if (is_gpio_sample_regi) gpio_val_reg <= gpio_in[40:0];
      end

    end
  end

  //DECODER

  assign is_tcdm_address_read  = apb_hwce_addr == 7'h00;  //0x00
  assign is_tcdm_address_store = apb_hwce_addr == 7'h01;  //0x04
  assign is_coef               = apb_hwce_addr == 7'h02;  //0x08
  assign is_start              = apb_hwce_addr == 7'h03;  //0x0C

  assign is_done               = apb_hwce_addr == 7'h04;  //0x10
  assign is_num_elem           = apb_hwce_addr == 7'h05;  //0x14

  assign is_configuration_sel  = apb_hwce_addr == 7'h06;  //0x18

  assign is_sw_event_sel       = apb_hwce_addr == 7'h08;  //0x20

  assign is_gpio_rego_l_val    = apb_hwce_addr == 7'h09;  //0x24
  assign is_gpio_rego_h_val    = apb_hwce_addr == 7'h0A;  //0x28

  assign is_gpio_rego_l_oe     = apb_hwce_addr == 7'h0B;  //0x2C
  assign is_gpio_rego_h_oe     = apb_hwce_addr == 7'h0C;  //0x30

  assign is_gpio_sample_regi   = apb_hwce_addr == 7'h0D;  //0x34



  always_comb begin
    apb_hwce_prdata = '0;
    if (apb_hwce_psel_i & apb_hwce_enable_i & ~apb_hwce_pwrite_i) begin


      if (is_tcdm_address_read) apb_hwce_prdata = $unsigned(read_address_q);
      else if (is_tcdm_address_store) apb_hwce_prdata = $unsigned(store_address_q);
      else if (is_coef) apb_hwce_prdata = $unsigned({coef3_q, coef2_q, coef1_q, coef0_q});
      else if (is_start) apb_hwce_prdata = $unsigned(start_q);
      else if (is_num_elem) apb_hwce_prdata = $unsigned(num_elem_q);
      else if (is_done) apb_hwce_prdata = $unsigned(done_q);
      else if (is_sw_event_sel) apb_hwce_prdata = $unsigned(sw_event_q);
      else apb_hwce_prdata = '0;
    end

  end

  assign events_0_o = done_q;

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


  assign             {
                        events_15_o,
                        events_14_o,
                        events_13_o,
                        events_12_o,
                        events_11_o,
                        events_10_o,
                        events_9_o,
                        events_8_o,
                        events_7_o,
                        events_6_o,
                        events_5_o,
                        events_4_o,
                        events_3_o,
                        events_2_o,
                        events_1_o
                        } =  sw_event_q;

  assign tcdm_wdata_p0_0_o = mac_result[0][0];
  assign tcdm_wdata_p0_1_o = mac_result[0][1];
  assign tcdm_wdata_p0_2_o = mac_result[0][2];
  assign tcdm_wdata_p0_3_o = mac_result[0][3];
  assign tcdm_wdata_p0_4_o = mac_result[0][4];
  assign tcdm_wdata_p0_5_o = mac_result[0][5];
  assign tcdm_wdata_p0_6_o = mac_result[0][6];
  assign tcdm_wdata_p0_7_o = mac_result[0][7];
  assign tcdm_wdata_p0_8_o = mac_result[1][0];
  assign tcdm_wdata_p0_9_o = mac_result[1][1];
  assign tcdm_wdata_p0_10_o = mac_result[1][2];
  assign tcdm_wdata_p0_11_o = mac_result[1][3];
  assign tcdm_wdata_p0_12_o = mac_result[1][4];
  assign tcdm_wdata_p0_13_o = mac_result[1][5];
  assign tcdm_wdata_p0_14_o = mac_result[1][6];
  assign tcdm_wdata_p0_15_o = mac_result[1][7];
  assign tcdm_wdata_p0_16_o = mac_result[2][0];
  assign tcdm_wdata_p0_17_o = mac_result[2][1];
  assign tcdm_wdata_p0_18_o = mac_result[2][2];
  assign tcdm_wdata_p0_19_o = mac_result[2][3];
  assign tcdm_wdata_p0_20_o = mac_result[2][4];
  assign tcdm_wdata_p0_21_o = mac_result[2][5];
  assign tcdm_wdata_p0_22_o = mac_result[2][6];
  assign tcdm_wdata_p0_23_o = mac_result[2][7];
  assign tcdm_wdata_p0_24_o = mac_result[3][0];
  assign tcdm_wdata_p0_25_o = mac_result[3][1];
  assign tcdm_wdata_p0_26_o = mac_result[3][2];
  assign tcdm_wdata_p0_27_o = mac_result[3][3];
  assign tcdm_wdata_p0_28_o = mac_result[3][4];
  assign tcdm_wdata_p0_29_o = mac_result[3][5];
  assign tcdm_wdata_p0_30_o = mac_result[3][6];
  assign tcdm_wdata_p0_31_o = mac_result[3][7];

  assign tcdm_wdata_p1_0_o = mac_result[0][8];
  assign tcdm_wdata_p1_1_o = mac_result[0][9];
  assign tcdm_wdata_p1_2_o = mac_result[0][10];
  assign tcdm_wdata_p1_3_o = mac_result[0][11];
  assign tcdm_wdata_p1_4_o = mac_result[0][12];
  assign tcdm_wdata_p1_5_o = mac_result[0][13];
  assign tcdm_wdata_p1_6_o = mac_result[0][14];
  assign tcdm_wdata_p1_7_o = mac_result[0][15];
  assign tcdm_wdata_p1_8_o = mac_result[1][8];
  assign tcdm_wdata_p1_9_o = mac_result[1][9];
  assign tcdm_wdata_p1_10_o = mac_result[1][10];
  assign tcdm_wdata_p1_11_o = mac_result[1][11];
  assign tcdm_wdata_p1_12_o = mac_result[1][12];
  assign tcdm_wdata_p1_13_o = mac_result[1][13];
  assign tcdm_wdata_p1_14_o = mac_result[1][14];
  assign tcdm_wdata_p1_15_o = mac_result[1][15];
  assign tcdm_wdata_p1_16_o = mac_result[2][8];
  assign tcdm_wdata_p1_17_o = mac_result[2][9];
  assign tcdm_wdata_p1_18_o = mac_result[2][10];
  assign tcdm_wdata_p1_19_o = mac_result[2][11];
  assign tcdm_wdata_p1_20_o = mac_result[2][12];
  assign tcdm_wdata_p1_21_o = mac_result[2][13];
  assign tcdm_wdata_p1_22_o = mac_result[2][14];
  assign tcdm_wdata_p1_23_o = mac_result[2][15];
  assign tcdm_wdata_p1_24_o = mac_result[3][8];
  assign tcdm_wdata_p1_25_o = mac_result[3][9];
  assign tcdm_wdata_p1_26_o = mac_result[3][10];
  assign tcdm_wdata_p1_27_o = mac_result[3][11];
  assign tcdm_wdata_p1_28_o = mac_result[3][12];
  assign tcdm_wdata_p1_29_o = mac_result[3][13];
  assign tcdm_wdata_p1_30_o = mac_result[3][14];
  assign tcdm_wdata_p1_31_o = mac_result[3][15];

  assign tcdm_wdata_p2_0_o = mac_result[0][16];
  assign tcdm_wdata_p2_1_o = mac_result[0][17];
  assign tcdm_wdata_p2_2_o = mac_result[0][18];
  assign tcdm_wdata_p2_3_o = mac_result[0][19];
  assign tcdm_wdata_p2_4_o = mac_result[0][20];
  assign tcdm_wdata_p2_5_o = mac_result[0][21];
  assign tcdm_wdata_p2_6_o = mac_result[0][22];
  assign tcdm_wdata_p2_7_o = mac_result[0][23];
  assign tcdm_wdata_p2_8_o = mac_result[1][16];
  assign tcdm_wdata_p2_9_o = mac_result[1][17];
  assign tcdm_wdata_p2_10_o = mac_result[1][18];
  assign tcdm_wdata_p2_11_o = mac_result[1][19];
  assign tcdm_wdata_p2_12_o = mac_result[1][20];
  assign tcdm_wdata_p2_13_o = mac_result[1][21];
  assign tcdm_wdata_p2_14_o = mac_result[1][22];
  assign tcdm_wdata_p2_15_o = mac_result[1][23];
  assign tcdm_wdata_p2_16_o = mac_result[2][16];
  assign tcdm_wdata_p2_17_o = mac_result[2][17];
  assign tcdm_wdata_p2_18_o = mac_result[2][18];
  assign tcdm_wdata_p2_19_o = mac_result[2][19];
  assign tcdm_wdata_p2_20_o = mac_result[2][20];
  assign tcdm_wdata_p2_21_o = mac_result[2][21];
  assign tcdm_wdata_p2_22_o = mac_result[2][22];
  assign tcdm_wdata_p2_23_o = mac_result[2][23];
  assign tcdm_wdata_p2_24_o = mac_result[3][16];
  assign tcdm_wdata_p2_25_o = mac_result[3][17];
  assign tcdm_wdata_p2_26_o = mac_result[3][18];
  assign tcdm_wdata_p2_27_o = mac_result[3][19];
  assign tcdm_wdata_p2_28_o = mac_result[3][20];
  assign tcdm_wdata_p2_29_o = mac_result[3][21];
  assign tcdm_wdata_p2_30_o = mac_result[3][22];
  assign tcdm_wdata_p2_31_o = mac_result[3][23];

  assign tcdm_wdata_p3_0_o = mac_result[0][24];
  assign tcdm_wdata_p3_1_o = mac_result[0][25];
  assign tcdm_wdata_p3_2_o = mac_result[0][26];
  assign tcdm_wdata_p3_3_o = mac_result[0][27];
  assign tcdm_wdata_p3_4_o = mac_result[0][28];
  assign tcdm_wdata_p3_5_o = mac_result[0][29];
  assign tcdm_wdata_p3_6_o = mac_result[0][30];
  assign tcdm_wdata_p3_7_o = mac_result[0][31];
  assign tcdm_wdata_p3_8_o = mac_result[1][24];
  assign tcdm_wdata_p3_9_o = mac_result[1][25];
  assign tcdm_wdata_p3_10_o = mac_result[1][26];
  assign tcdm_wdata_p3_11_o = mac_result[1][27];
  assign tcdm_wdata_p3_12_o = mac_result[1][28];
  assign tcdm_wdata_p3_13_o = mac_result[1][29];
  assign tcdm_wdata_p3_14_o = mac_result[1][30];
  assign tcdm_wdata_p3_15_o = mac_result[1][31];
  assign tcdm_wdata_p3_16_o = mac_result[2][24];
  assign tcdm_wdata_p3_17_o = mac_result[2][25];
  assign tcdm_wdata_p3_18_o = mac_result[2][26];
  assign tcdm_wdata_p3_19_o = mac_result[2][27];
  assign tcdm_wdata_p3_20_o = mac_result[2][28];
  assign tcdm_wdata_p3_21_o = mac_result[2][29];
  assign tcdm_wdata_p3_22_o = mac_result[2][30];
  assign tcdm_wdata_p3_23_o = mac_result[2][31];
  assign tcdm_wdata_p3_24_o = mac_result[3][24];
  assign tcdm_wdata_p3_25_o = mac_result[3][25];
  assign tcdm_wdata_p3_26_o = mac_result[3][26];
  assign tcdm_wdata_p3_27_o = mac_result[3][27];
  assign tcdm_wdata_p3_28_o = mac_result[3][28];
  assign tcdm_wdata_p3_29_o = mac_result[3][29];
  assign tcdm_wdata_p3_30_o = mac_result[3][30];
  assign tcdm_wdata_p3_31_o = mac_result[3][31];

  assign tcdm_r_rdata_p0 = {
    tcdm_r_rdata_p0_31_i,
    tcdm_r_rdata_p0_30_i,
    tcdm_r_rdata_p0_29_i,
    tcdm_r_rdata_p0_28_i,
    tcdm_r_rdata_p0_27_i,
    tcdm_r_rdata_p0_26_i,
    tcdm_r_rdata_p0_25_i,
    tcdm_r_rdata_p0_24_i,
    tcdm_r_rdata_p0_23_i,
    tcdm_r_rdata_p0_22_i,
    tcdm_r_rdata_p0_21_i,
    tcdm_r_rdata_p0_20_i,
    tcdm_r_rdata_p0_19_i,
    tcdm_r_rdata_p0_18_i,
    tcdm_r_rdata_p0_17_i,
    tcdm_r_rdata_p0_16_i,
    tcdm_r_rdata_p0_15_i,
    tcdm_r_rdata_p0_14_i,
    tcdm_r_rdata_p0_13_i,
    tcdm_r_rdata_p0_12_i,
    tcdm_r_rdata_p0_11_i,
    tcdm_r_rdata_p0_10_i,
    tcdm_r_rdata_p0_9_i,
    tcdm_r_rdata_p0_8_i,
    tcdm_r_rdata_p0_7_i,
    tcdm_r_rdata_p0_6_i,
    tcdm_r_rdata_p0_5_i,
    tcdm_r_rdata_p0_4_i,
    tcdm_r_rdata_p0_3_i,
    tcdm_r_rdata_p0_2_i,
    tcdm_r_rdata_p0_1_i,
    tcdm_r_rdata_p0_0_i
  };

  assign tcdm_r_rdata_p1 = {
    tcdm_r_rdata_p1_31_i,
    tcdm_r_rdata_p1_30_i,
    tcdm_r_rdata_p1_29_i,
    tcdm_r_rdata_p1_28_i,
    tcdm_r_rdata_p1_27_i,
    tcdm_r_rdata_p1_26_i,
    tcdm_r_rdata_p1_25_i,
    tcdm_r_rdata_p1_24_i,
    tcdm_r_rdata_p1_23_i,
    tcdm_r_rdata_p1_22_i,
    tcdm_r_rdata_p1_21_i,
    tcdm_r_rdata_p1_20_i,
    tcdm_r_rdata_p1_19_i,
    tcdm_r_rdata_p1_18_i,
    tcdm_r_rdata_p1_17_i,
    tcdm_r_rdata_p1_16_i,
    tcdm_r_rdata_p1_15_i,
    tcdm_r_rdata_p1_14_i,
    tcdm_r_rdata_p1_13_i,
    tcdm_r_rdata_p1_12_i,
    tcdm_r_rdata_p1_11_i,
    tcdm_r_rdata_p1_10_i,
    tcdm_r_rdata_p1_9_i,
    tcdm_r_rdata_p1_8_i,
    tcdm_r_rdata_p1_7_i,
    tcdm_r_rdata_p1_6_i,
    tcdm_r_rdata_p1_5_i,
    tcdm_r_rdata_p1_4_i,
    tcdm_r_rdata_p1_3_i,
    tcdm_r_rdata_p1_2_i,
    tcdm_r_rdata_p1_1_i,
    tcdm_r_rdata_p1_0_i
  };

  assign tcdm_r_rdata_p2 = {
    tcdm_r_rdata_p2_31_i,
    tcdm_r_rdata_p2_30_i,
    tcdm_r_rdata_p2_29_i,
    tcdm_r_rdata_p2_28_i,
    tcdm_r_rdata_p2_27_i,
    tcdm_r_rdata_p2_26_i,
    tcdm_r_rdata_p2_25_i,
    tcdm_r_rdata_p2_24_i,
    tcdm_r_rdata_p2_23_i,
    tcdm_r_rdata_p2_22_i,
    tcdm_r_rdata_p2_21_i,
    tcdm_r_rdata_p2_20_i,
    tcdm_r_rdata_p2_19_i,
    tcdm_r_rdata_p2_18_i,
    tcdm_r_rdata_p2_17_i,
    tcdm_r_rdata_p2_16_i,
    tcdm_r_rdata_p2_15_i,
    tcdm_r_rdata_p2_14_i,
    tcdm_r_rdata_p2_13_i,
    tcdm_r_rdata_p2_12_i,
    tcdm_r_rdata_p2_11_i,
    tcdm_r_rdata_p2_10_i,
    tcdm_r_rdata_p2_9_i,
    tcdm_r_rdata_p2_8_i,
    tcdm_r_rdata_p2_7_i,
    tcdm_r_rdata_p2_6_i,
    tcdm_r_rdata_p2_5_i,
    tcdm_r_rdata_p2_4_i,
    tcdm_r_rdata_p2_3_i,
    tcdm_r_rdata_p2_2_i,
    tcdm_r_rdata_p2_1_i,
    tcdm_r_rdata_p2_0_i
  };

  assign tcdm_r_rdata_p3 = {
    tcdm_r_rdata_p3_31_i,
    tcdm_r_rdata_p3_30_i,
    tcdm_r_rdata_p3_29_i,
    tcdm_r_rdata_p3_28_i,
    tcdm_r_rdata_p3_27_i,
    tcdm_r_rdata_p3_26_i,
    tcdm_r_rdata_p3_25_i,
    tcdm_r_rdata_p3_24_i,
    tcdm_r_rdata_p3_23_i,
    tcdm_r_rdata_p3_22_i,
    tcdm_r_rdata_p3_21_i,
    tcdm_r_rdata_p3_20_i,
    tcdm_r_rdata_p3_19_i,
    tcdm_r_rdata_p3_18_i,
    tcdm_r_rdata_p3_17_i,
    tcdm_r_rdata_p3_16_i,
    tcdm_r_rdata_p3_15_i,
    tcdm_r_rdata_p3_14_i,
    tcdm_r_rdata_p3_13_i,
    tcdm_r_rdata_p3_12_i,
    tcdm_r_rdata_p3_11_i,
    tcdm_r_rdata_p3_10_i,
    tcdm_r_rdata_p3_9_i,
    tcdm_r_rdata_p3_8_i,
    tcdm_r_rdata_p3_7_i,
    tcdm_r_rdata_p3_6_i,
    tcdm_r_rdata_p3_5_i,
    tcdm_r_rdata_p3_4_i,
    tcdm_r_rdata_p3_3_i,
    tcdm_r_rdata_p3_2_i,
    tcdm_r_rdata_p3_1_i,
    tcdm_r_rdata_p3_0_i
  };


  assign tcdm_addr_p0_0_o = real_address0[0];
  assign tcdm_addr_p0_1_o = real_address0[1];
  assign tcdm_addr_p0_2_o = real_address0[2];
  assign tcdm_addr_p0_3_o = real_address0[3];
  assign tcdm_addr_p0_4_o = real_address0[4];
  assign tcdm_addr_p0_5_o = real_address0[5];
  assign tcdm_addr_p0_6_o = real_address0[6];
  assign tcdm_addr_p0_7_o = real_address0[7];
  assign tcdm_addr_p0_8_o = real_address0[8];
  assign tcdm_addr_p0_9_o = real_address0[9];
  assign tcdm_addr_p0_10_o = real_address0[10];
  assign tcdm_addr_p0_11_o = real_address0[11];
  assign tcdm_addr_p0_12_o = real_address0[12];
  assign tcdm_addr_p0_13_o = real_address0[13];
  assign tcdm_addr_p0_14_o = real_address0[14];
  assign tcdm_addr_p0_15_o = real_address0[15];
  assign tcdm_addr_p0_16_o = real_address0[16];
  assign tcdm_addr_p0_17_o = real_address0[17];
  assign tcdm_addr_p0_18_o = real_address0[18];
  assign tcdm_addr_p0_19_o = real_address0[19];

  assign tcdm_addr_p1_0_o = real_address1[0];
  assign tcdm_addr_p1_1_o = real_address1[1];
  assign tcdm_addr_p1_2_o = real_address1[2];
  assign tcdm_addr_p1_3_o = real_address1[3];
  assign tcdm_addr_p1_4_o = real_address1[4];
  assign tcdm_addr_p1_5_o = real_address1[5];
  assign tcdm_addr_p1_6_o = real_address1[6];
  assign tcdm_addr_p1_7_o = real_address1[7];
  assign tcdm_addr_p1_8_o = real_address1[8];
  assign tcdm_addr_p1_9_o = real_address1[9];
  assign tcdm_addr_p1_10_o = real_address1[10];
  assign tcdm_addr_p1_11_o = real_address1[11];
  assign tcdm_addr_p1_12_o = real_address1[12];
  assign tcdm_addr_p1_13_o = real_address1[13];
  assign tcdm_addr_p1_14_o = real_address1[14];
  assign tcdm_addr_p1_15_o = real_address1[15];
  assign tcdm_addr_p1_16_o = real_address1[16];
  assign tcdm_addr_p1_17_o = real_address1[17];
  assign tcdm_addr_p1_18_o = real_address1[18];
  assign tcdm_addr_p1_19_o = real_address1[19];

  assign tcdm_addr_p2_0_o = real_address2[0];
  assign tcdm_addr_p2_1_o = real_address2[1];
  assign tcdm_addr_p2_2_o = real_address2[2];
  assign tcdm_addr_p2_3_o = real_address2[3];
  assign tcdm_addr_p2_4_o = real_address2[4];
  assign tcdm_addr_p2_5_o = real_address2[5];
  assign tcdm_addr_p2_6_o = real_address2[6];
  assign tcdm_addr_p2_7_o = real_address2[7];
  assign tcdm_addr_p2_8_o = real_address2[8];
  assign tcdm_addr_p2_9_o = real_address2[9];
  assign tcdm_addr_p2_10_o = real_address2[10];
  assign tcdm_addr_p2_11_o = real_address2[11];
  assign tcdm_addr_p2_12_o = real_address2[12];
  assign tcdm_addr_p2_13_o = real_address2[13];
  assign tcdm_addr_p2_14_o = real_address2[14];
  assign tcdm_addr_p2_15_o = real_address2[15];
  assign tcdm_addr_p2_16_o = real_address2[16];
  assign tcdm_addr_p2_17_o = real_address2[17];
  assign tcdm_addr_p2_18_o = real_address2[18];
  assign tcdm_addr_p2_19_o = real_address2[19];

  assign tcdm_addr_p3_0_o = real_address3[0];
  assign tcdm_addr_p3_1_o = real_address3[1];
  assign tcdm_addr_p3_2_o = real_address3[2];
  assign tcdm_addr_p3_3_o = real_address3[3];
  assign tcdm_addr_p3_4_o = real_address3[4];
  assign tcdm_addr_p3_5_o = real_address3[5];
  assign tcdm_addr_p3_6_o = real_address3[6];
  assign tcdm_addr_p3_7_o = real_address3[7];
  assign tcdm_addr_p3_8_o = real_address3[8];
  assign tcdm_addr_p3_9_o = real_address3[9];
  assign tcdm_addr_p3_10_o = real_address3[10];
  assign tcdm_addr_p3_11_o = real_address3[11];
  assign tcdm_addr_p3_12_o = real_address3[12];
  assign tcdm_addr_p3_13_o = real_address3[13];
  assign tcdm_addr_p3_14_o = real_address3[14];
  assign tcdm_addr_p3_15_o = real_address3[15];
  assign tcdm_addr_p3_16_o = real_address3[16];
  assign tcdm_addr_p3_17_o = real_address3[17];
  assign tcdm_addr_p3_18_o = real_address3[18];
  assign tcdm_addr_p3_19_o = real_address3[19];


  assign MU0_EFPGA_MATHB_OPER_defPin_1_ = 1'b0;
  assign MU0_EFPGA_MATHB_OPER_defPin_0_ = 1'b0;
  assign MU0_EFPGA_MATHB_OPER_SEL = configuration_sel[2];

  assign MU0_EFPGA_MATHB_COEF_defPin_1_ = 1'b0;
  assign MU0_EFPGA_MATHB_COEF_defPin_0_ = 1'b0;
  assign MU0_EFPGA_MATHB_COEF_SEL = configuration_sel[2];

  assign { MU0_EFPGA_MATHB_MAC_OUT_SEL_5_, MU0_EFPGA_MATHB_MAC_OUT_SEL_4_, MU0_EFPGA_MATHB_MAC_OUT_SEL_3_, MU0_EFPGA_MATHB_MAC_OUT_SEL_2_, MU0_EFPGA_MATHB_MAC_OUT_SEL_1_ ,MU0_EFPGA_MATHB_MAC_OUT_SEL_0_ } = configuration_sel[11:6];

  assign MU0_EFPGA_MATHB_DATAOUT_SEL_1_ = configuration_sel[1];
  assign MU0_EFPGA_MATHB_DATAOUT_SEL_0_ = configuration_sel[0];


  assign MU0_EFPGA_MATHB_MAC_ACC_CLEAR = reset_accumulator_q;
  assign MU0_EFPGA_MATHB_MAC_ACC_RND = configuration_sel[4];
  assign MU0_EFPGA_MATHB_MAC_ACC_SAT = configuration_sel[3];
  assign MU0_EFPGA_MATHB_TC_defPin = 1'b1;

  assign MU0_EFPGA_MATHB_CLK_EN = configuration_sel[5];

  assign MU0_EFPGA2MATHB_CLK = clk_i;  //pragma attribute clk_i pad ck_buff

  assign tcdm_be = configuration_sel[15:12];

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


  assign MU0_EFPGA_MATHB_OPER_DATA_0_ = selected_data[0];
  assign MU0_EFPGA_MATHB_OPER_DATA_1_ = selected_data[1];
  assign MU0_EFPGA_MATHB_OPER_DATA_2_ = selected_data[2];
  assign MU0_EFPGA_MATHB_OPER_DATA_3_ = selected_data[3];
  assign MU0_EFPGA_MATHB_OPER_DATA_4_ = selected_data[4];
  assign MU0_EFPGA_MATHB_OPER_DATA_5_ = selected_data[5];
  assign MU0_EFPGA_MATHB_OPER_DATA_6_ = selected_data[6];
  assign MU0_EFPGA_MATHB_OPER_DATA_7_ = selected_data[7];
  assign MU0_EFPGA_MATHB_OPER_DATA_8_ = selected_data[8];
  assign MU0_EFPGA_MATHB_OPER_DATA_9_ = selected_data[9];
  assign MU0_EFPGA_MATHB_OPER_DATA_10_ = selected_data[10];
  assign MU0_EFPGA_MATHB_OPER_DATA_11_ = selected_data[11];
  assign MU0_EFPGA_MATHB_OPER_DATA_12_ = selected_data[12];
  assign MU0_EFPGA_MATHB_OPER_DATA_13_ = selected_data[13];
  assign MU0_EFPGA_MATHB_OPER_DATA_14_ = selected_data[14];
  assign MU0_EFPGA_MATHB_OPER_DATA_15_ = selected_data[15];
  assign MU0_EFPGA_MATHB_OPER_DATA_16_ = selected_data[16];
  assign MU0_EFPGA_MATHB_OPER_DATA_17_ = selected_data[17];
  assign MU0_EFPGA_MATHB_OPER_DATA_18_ = selected_data[18];
  assign MU0_EFPGA_MATHB_OPER_DATA_19_ = selected_data[19];
  assign MU0_EFPGA_MATHB_OPER_DATA_20_ = selected_data[20];
  assign MU0_EFPGA_MATHB_OPER_DATA_21_ = selected_data[21];
  assign MU0_EFPGA_MATHB_OPER_DATA_22_ = selected_data[22];
  assign MU0_EFPGA_MATHB_OPER_DATA_23_ = selected_data[23];
  assign MU0_EFPGA_MATHB_OPER_DATA_24_ = selected_data[24];
  assign MU0_EFPGA_MATHB_OPER_DATA_25_ = selected_data[25];
  assign MU0_EFPGA_MATHB_OPER_DATA_26_ = selected_data[26];
  assign MU0_EFPGA_MATHB_OPER_DATA_27_ = selected_data[27];
  assign MU0_EFPGA_MATHB_OPER_DATA_28_ = selected_data[28];
  assign MU0_EFPGA_MATHB_OPER_DATA_29_ = selected_data[29];
  assign MU0_EFPGA_MATHB_OPER_DATA_30_ = selected_data[30];
  assign MU0_EFPGA_MATHB_OPER_DATA_31_ = selected_data[31];

  assign MU0_EFPGA_MATHB_COEF_DATA_0_ = sel_coef0[0];
  assign MU0_EFPGA_MATHB_COEF_DATA_1_ = sel_coef0[1];
  assign MU0_EFPGA_MATHB_COEF_DATA_2_ = sel_coef0[2];
  assign MU0_EFPGA_MATHB_COEF_DATA_3_ = sel_coef0[3];
  assign MU0_EFPGA_MATHB_COEF_DATA_4_ = sel_coef0[4];
  assign MU0_EFPGA_MATHB_COEF_DATA_5_ = sel_coef0[5];
  assign MU0_EFPGA_MATHB_COEF_DATA_6_ = sel_coef0[6];
  assign MU0_EFPGA_MATHB_COEF_DATA_7_ = sel_coef0[7];
  assign MU0_EFPGA_MATHB_COEF_DATA_8_ = sel_coef1[0];
  assign MU0_EFPGA_MATHB_COEF_DATA_9_ = sel_coef1[1];
  assign MU0_EFPGA_MATHB_COEF_DATA_10_ = sel_coef1[2];
  assign MU0_EFPGA_MATHB_COEF_DATA_11_ = sel_coef1[3];
  assign MU0_EFPGA_MATHB_COEF_DATA_12_ = sel_coef1[4];
  assign MU0_EFPGA_MATHB_COEF_DATA_13_ = sel_coef1[5];
  assign MU0_EFPGA_MATHB_COEF_DATA_14_ = sel_coef1[6];
  assign MU0_EFPGA_MATHB_COEF_DATA_15_ = sel_coef1[7];
  assign MU0_EFPGA_MATHB_COEF_DATA_16_ = sel_coef2[0];
  assign MU0_EFPGA_MATHB_COEF_DATA_17_ = sel_coef2[1];
  assign MU0_EFPGA_MATHB_COEF_DATA_18_ = sel_coef2[2];
  assign MU0_EFPGA_MATHB_COEF_DATA_19_ = sel_coef2[3];
  assign MU0_EFPGA_MATHB_COEF_DATA_20_ = sel_coef2[4];
  assign MU0_EFPGA_MATHB_COEF_DATA_21_ = sel_coef2[5];
  assign MU0_EFPGA_MATHB_COEF_DATA_22_ = sel_coef2[6];
  assign MU0_EFPGA_MATHB_COEF_DATA_23_ = sel_coef2[7];
  assign MU0_EFPGA_MATHB_COEF_DATA_24_ = sel_coef3[0];
  assign MU0_EFPGA_MATHB_COEF_DATA_25_ = sel_coef3[1];
  assign MU0_EFPGA_MATHB_COEF_DATA_26_ = sel_coef3[2];
  assign MU0_EFPGA_MATHB_COEF_DATA_27_ = sel_coef3[3];
  assign MU0_EFPGA_MATHB_COEF_DATA_28_ = sel_coef3[4];
  assign MU0_EFPGA_MATHB_COEF_DATA_29_ = sel_coef3[5];
  assign MU0_EFPGA_MATHB_COEF_DATA_30_ = sel_coef3[6];
  assign MU0_EFPGA_MATHB_COEF_DATA_31_ = sel_coef3[7];

  assign {
    gpio_oe_40_o,
    gpio_oe_39_o, gpio_oe_38_o, gpio_oe_37_o, gpio_oe_36_o, gpio_oe_35_o,
    gpio_oe_34_o, gpio_oe_33_o, gpio_oe_32_o, gpio_oe_31_o, gpio_oe_30_o,
    gpio_oe_29_o, gpio_oe_28_o, gpio_oe_27_o, gpio_oe_26_o, gpio_oe_25_o,
    gpio_oe_24_o, gpio_oe_23_o, gpio_oe_22_o, gpio_oe_21_o, gpio_oe_20_o,
    gpio_oe_19_o, gpio_oe_18_o, gpio_oe_17_o, gpio_oe_16_o, gpio_oe_15_o,
    gpio_oe_14_o, gpio_oe_13_o, gpio_oe_12_o, gpio_oe_11_o, gpio_oe_10_o,
    gpio_oe_9_o,  gpio_oe_8_o,  gpio_oe_7_o,  gpio_oe_6_o,  gpio_oe_5_o,
    gpio_oe_4_o,  gpio_oe_3_o,  gpio_oe_2_o,  gpio_oe_1_o,  gpio_oe_0_o  }   = gpio_oe_reg[40:0];


  assign {
    gpio_data_40_o,
    gpio_data_39_o, gpio_data_38_o, gpio_data_37_o, gpio_data_36_o, gpio_data_35_o,
    gpio_data_34_o, gpio_data_33_o, gpio_data_32_o, gpio_data_31_o, gpio_data_30_o,
    gpio_data_29_o, gpio_data_28_o, gpio_data_27_o, gpio_data_26_o, gpio_data_25_o,
    gpio_data_24_o, gpio_data_23_o, gpio_data_22_o, gpio_data_21_o, gpio_data_20_o,
    gpio_data_19_o, gpio_data_18_o, gpio_data_17_o, gpio_data_16_o, gpio_data_15_o,
    gpio_data_14_o, gpio_data_13_o, gpio_data_12_o, gpio_data_11_o, gpio_data_10_o,
    gpio_data_9_o,  gpio_data_8_o,  gpio_data_7_o,  gpio_data_6_o,  gpio_data_5_o,
    gpio_data_4_o,  gpio_data_3_o,  gpio_data_2_o,  gpio_data_1_o,  gpio_data_0_o  }   = gpio_val_reg[40:0];



  assign gpio_in[40:0] = {
    gpio_data_40_i,
    gpio_data_39_i,
    gpio_data_38_i,
    gpio_data_37_i,
    gpio_data_36_i,
    gpio_data_35_i,
    gpio_data_34_i,
    gpio_data_33_i,
    gpio_data_32_i,
    gpio_data_31_i,
    gpio_data_30_i,
    gpio_data_29_i,
    gpio_data_28_i,
    gpio_data_27_i,
    gpio_data_26_i,
    gpio_data_25_i,
    gpio_data_24_i,
    gpio_data_23_i,
    gpio_data_22_i,
    gpio_data_21_i,
    gpio_data_20_i,
    gpio_data_19_i,
    gpio_data_18_i,
    gpio_data_17_i,
    gpio_data_16_i,
    gpio_data_15_i,
    gpio_data_14_i,
    gpio_data_13_i,
    gpio_data_12_i,
    gpio_data_11_i,
    gpio_data_10_i,
    gpio_data_9_i,
    gpio_data_8_i,
    gpio_data_7_i,
    gpio_data_6_i,
    gpio_data_5_i,
    gpio_data_4_i,
    gpio_data_3_i,
    gpio_data_2_i,
    gpio_data_1_i,
    gpio_data_0_i
  };


endmodule
