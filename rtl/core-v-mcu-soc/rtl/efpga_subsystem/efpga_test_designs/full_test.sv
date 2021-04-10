// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


module full_test_rtl (
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
    input  logic tcdm_rdata_p0_0_i,  //pragma attribute tcdm_rdata_p0_0_i  pad in_buff
    input  logic tcdm_rdata_p0_1_i,  //pragma attribute tcdm_rdata_p0_1_i  pad in_buff
    input  logic tcdm_rdata_p0_2_i,  //pragma attribute tcdm_rdata_p0_2_i  pad in_buff
    input  logic tcdm_rdata_p0_3_i,  //pragma attribute tcdm_rdata_p0_3_i  pad in_buff
    input  logic tcdm_rdata_p0_4_i,  //pragma attribute tcdm_rdata_p0_4_i  pad in_buff
    input  logic tcdm_rdata_p0_5_i,  //pragma attribute tcdm_rdata_p0_5_i  pad in_buff
    input  logic tcdm_rdata_p0_6_i,  //pragma attribute tcdm_rdata_p0_6_i  pad in_buff
    input  logic tcdm_rdata_p0_7_i,  //pragma attribute tcdm_rdata_p0_7_i  pad in_buff
    input  logic tcdm_rdata_p0_8_i,  //pragma attribute tcdm_rdata_p0_8_i  pad in_buff
    input  logic tcdm_rdata_p0_9_i,  //pragma attribute tcdm_rdata_p0_9_i  pad in_buff
    input  logic tcdm_rdata_p0_10_i,  //pragma attribute tcdm_rdata_p0_10_i  pad in_buff
    input  logic tcdm_rdata_p0_11_i,  //pragma attribute tcdm_rdata_p0_11_i  pad in_buff
    input  logic tcdm_rdata_p0_12_i,  //pragma attribute tcdm_rdata_p0_12_i  pad in_buff
    input  logic tcdm_rdata_p0_13_i,  //pragma attribute tcdm_rdata_p0_13_i  pad in_buff
    input  logic tcdm_rdata_p0_14_i,  //pragma attribute tcdm_rdata_p0_14_i  pad in_buff
    input  logic tcdm_rdata_p0_15_i,  //pragma attribute tcdm_rdata_p0_15_i  pad in_buff
    input  logic tcdm_rdata_p0_16_i,  //pragma attribute tcdm_rdata_p0_16_i  pad in_buff
    input  logic tcdm_rdata_p0_17_i,  //pragma attribute tcdm_rdata_p0_17_i  pad in_buff
    input  logic tcdm_rdata_p0_18_i,  //pragma attribute tcdm_rdata_p0_18_i  pad in_buff
    input  logic tcdm_rdata_p0_19_i,  //pragma attribute tcdm_rdata_p0_19_i  pad in_buff
    input  logic tcdm_rdata_p0_20_i,  //pragma attribute tcdm_rdata_p0_20_i  pad in_buff
    input  logic tcdm_rdata_p0_21_i,  //pragma attribute tcdm_rdata_p0_21_i  pad in_buff
    input  logic tcdm_rdata_p0_22_i,  //pragma attribute tcdm_rdata_p0_22_i  pad in_buff
    input  logic tcdm_rdata_p0_23_i,  //pragma attribute tcdm_rdata_p0_23_i  pad in_buff
    input  logic tcdm_rdata_p0_24_i,  //pragma attribute tcdm_rdata_p0_24_i  pad in_buff
    input  logic tcdm_rdata_p0_25_i,  //pragma attribute tcdm_rdata_p0_25_i  pad in_buff
    input  logic tcdm_rdata_p0_26_i,  //pragma attribute tcdm_rdata_p0_26_i  pad in_buff
    input  logic tcdm_rdata_p0_27_i,  //pragma attribute tcdm_rdata_p0_27_i  pad in_buff
    input  logic tcdm_rdata_p0_28_i,  //pragma attribute tcdm_rdata_p0_28_i  pad in_buff
    input  logic tcdm_rdata_p0_29_i,  //pragma attribute tcdm_rdata_p0_29_i  pad in_buff
    input  logic tcdm_rdata_p0_30_i,  //pragma attribute tcdm_rdata_p0_30_i  pad in_buff
    input  logic tcdm_rdata_p0_31_i,  //pragma attribute tcdm_rdata_p0_31_i  pad in_buff
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
    output logic tcdm_wdata_p1_0_o,  //pragma attribute tcdm_wdata_p1_0_o pad out_buff
    output logic tcdm_wdata_p1_1_o,  //pragma attribute tcdm_wdata_p1_1_o pad out_buff
    output logic tcdm_wdata_p1_2_o,  //pragma attribute tcdm_wdata_p1_2_o pad out_buff
    output logic tcdm_wdata_p1_3_o,  //pragma attribute tcdm_wdata_p1_3_o pad out_buff
    output logic tcdm_wdata_p1_4_o,  //pragma attribute tcdm_wdata_p1_4_o pad out_buff
    output logic tcdm_wdata_p1_5_o,  //pragma attribute tcdm_wdata_p1_5_o pad out_buff
    output logic tcdm_wdata_p1_6_o,  //pragma attribute tcdm_wdata_p1_6_o pad out_buff
    output logic tcdm_wdata_p1_7_o,  //pragma attribute tcdm_wdata_p1_7_o pad out_buff
    output logic tcdm_wdata_p1_8_o,  //pragma attribute tcdm_wdata_p1_8_o pad out_buff
    output logic tcdm_wdata_p1_9_o,  //pragma attribute tcdm_wdata_p1_9_o pad out_buff
    output logic tcdm_wdata_p1_10_o,  //pragma attribute tcdm_wdata_p1_10_o pad out_buff
    output logic tcdm_wdata_p1_11_o,  //pragma attribute tcdm_wdata_p1_11_o pad out_buff
    output logic tcdm_wdata_p1_12_o,  //pragma attribute tcdm_wdata_p1_12_o pad out_buff
    output logic tcdm_wdata_p1_13_o,  //pragma attribute tcdm_wdata_p1_13_o pad out_buff
    output logic tcdm_wdata_p1_14_o,  //pragma attribute tcdm_wdata_p1_14_o pad out_buff
    output logic tcdm_wdata_p1_15_o,  //pragma attribute tcdm_wdata_p1_15_o pad out_buff
    output logic tcdm_wdata_p1_16_o,  //pragma attribute tcdm_wdata_p1_16_o pad out_buff
    output logic tcdm_wdata_p1_17_o,  //pragma attribute tcdm_wdata_p1_17_o pad out_buff
    output logic tcdm_wdata_p1_18_o,  //pragma attribute tcdm_wdata_p1_18_o pad out_buff
    output logic tcdm_wdata_p1_19_o,  //pragma attribute tcdm_wdata_p1_19_o pad out_buff
    output logic tcdm_wdata_p1_20_o,  //pragma attribute tcdm_wdata_p1_20_o pad out_buff
    output logic tcdm_wdata_p1_21_o,  //pragma attribute tcdm_wdata_p1_21_o pad out_buff
    output logic tcdm_wdata_p1_22_o,  //pragma attribute tcdm_wdata_p1_22_o pad out_buff
    output logic tcdm_wdata_p1_23_o,  //pragma attribute tcdm_wdata_p1_23_o pad out_buff
    output logic tcdm_wdata_p1_24_o,  //pragma attribute tcdm_wdata_p1_24_o pad out_buff
    output logic tcdm_wdata_p1_25_o,  //pragma attribute tcdm_wdata_p1_25_o pad out_buff
    output logic tcdm_wdata_p1_26_o,  //pragma attribute tcdm_wdata_p1_26_o pad out_buff
    output logic tcdm_wdata_p1_27_o,  //pragma attribute tcdm_wdata_p1_27_o pad out_buff
    output logic tcdm_wdata_p1_28_o,  //pragma attribute tcdm_wdata_p1_28_o pad out_buff
    output logic tcdm_wdata_p1_29_o,  //pragma attribute tcdm_wdata_p1_29_o pad out_buff
    output logic tcdm_wdata_p1_30_o,  //pragma attribute tcdm_wdata_p1_30_o pad out_buff
    output logic tcdm_wdata_p1_31_o,  //pragma attribute tcdm_wdata_p1_31_o pad out_buff
    input  logic tcdm_rdata_p1_0_i,
    input  logic tcdm_rdata_p1_1_i,
    input  logic tcdm_rdata_p1_2_i,
    input  logic tcdm_rdata_p1_3_i,
    input  logic tcdm_rdata_p1_4_i,
    input  logic tcdm_rdata_p1_5_i,
    input  logic tcdm_rdata_p1_6_i,
    input  logic tcdm_rdata_p1_7_i,
    input  logic tcdm_rdata_p1_8_i,
    input  logic tcdm_rdata_p1_9_i,
    input  logic tcdm_rdata_p1_10_i,
    input  logic tcdm_rdata_p1_11_i,
    input  logic tcdm_rdata_p1_12_i,
    input  logic tcdm_rdata_p1_13_i,
    input  logic tcdm_rdata_p1_14_i,
    input  logic tcdm_rdata_p1_15_i,
    input  logic tcdm_rdata_p1_16_i,
    input  logic tcdm_rdata_p1_17_i,
    input  logic tcdm_rdata_p1_18_i,
    input  logic tcdm_rdata_p1_19_i,
    input  logic tcdm_rdata_p1_20_i,
    input  logic tcdm_rdata_p1_21_i,
    input  logic tcdm_rdata_p1_22_i,
    input  logic tcdm_rdata_p1_23_i,
    input  logic tcdm_rdata_p1_24_i,
    input  logic tcdm_rdata_p1_25_i,
    input  logic tcdm_rdata_p1_26_i,
    input  logic tcdm_rdata_p1_27_i,
    input  logic tcdm_rdata_p1_28_i,
    input  logic tcdm_rdata_p1_29_i,
    input  logic tcdm_rdata_p1_30_i,
    input  logic tcdm_rdata_p1_31_i,
    output logic tcdm_be_p1_0_o,
    output logic tcdm_be_p1_1_o,
    output logic tcdm_be_p1_2_o,
    output logic tcdm_be_p1_3_o,
    input  logic tcdm_gnt_p1_i,
    input  logic tcdm_r_valid_p1_i,


    output logic tcdm_req_p2_o,  //pragma attribute tcdm_req_p2_o  pad out_buff
    output logic tcdm_addr_p2_0_o,  //pragma attribute tcdm_addr_p2_0_o  pad out_buff
    output logic tcdm_addr_p2_1_o,  //pragma attribute tcdm_addr_p2_1_o  pad out_buff
    output logic tcdm_addr_p2_2_o,  //pragma attribute tcdm_addr_p2_2_o  pad out_buff
    output logic tcdm_addr_p2_3_o,  //pragma attribute tcdm_addr_p2_3_o  pad out_buff
    output logic tcdm_addr_p2_4_o,  //pragma attribute tcdm_addr_p2_4_o  pad out_buff
    output logic tcdm_addr_p2_5_o,  //pragma attribute tcdm_addr_p2_5_o  pad out_buff
    output logic tcdm_addr_p2_6_o,  //pragma attribute tcdm_addr_p2_6_o  pad out_buff
    output logic tcdm_addr_p2_7_o,  //pragma attribute tcdm_addr_p2_7_o  pad out_buff
    output logic tcdm_addr_p2_8_o,  //pragma attribute tcdm_addr_p2_8_o  pad out_buff
    output logic tcdm_addr_p2_9_o,  //pragma attribute tcdm_addr_p2_9_o  pad out_buff
    output logic tcdm_addr_p2_10_o,  //pragma attribute tcdm_addr_p2_10_o  pad out_buff
    output logic tcdm_addr_p2_11_o,  //pragma attribute tcdm_addr_p2_11_o  pad out_buff
    output logic tcdm_addr_p2_12_o,  //pragma attribute tcdm_addr_p2_12_o  pad out_buff
    output logic tcdm_addr_p2_13_o,  //pragma attribute tcdm_addr_p2_13_o  pad out_buff
    output logic tcdm_addr_p2_14_o,  //pragma attribute tcdm_addr_p2_14_o  pad out_buff
    output logic tcdm_addr_p2_15_o,  //pragma attribute tcdm_addr_p2_15_o  pad out_buff
    output logic tcdm_addr_p2_16_o,  //pragma attribute tcdm_addr_p2_16_o  pad out_buff
    output logic tcdm_addr_p2_17_o,  //pragma attribute tcdm_addr_p2_17_o  pad out_buff
    output logic tcdm_addr_p2_18_o,  //pragma attribute tcdm_addr_p2_18_o  pad out_buff
    output logic tcdm_addr_p2_19_o,  //pragma attribute tcdm_addr_p2_19_o  pad out_buff
    output logic tcdm_wen_p2_o,  //pragma attribute tcdm_wen_p2_o  pad out_buff
    output logic tcdm_wdata_p2_0_o,  //pragma attribute tcdm_wdata_p2_0_o  pad out_buff
    output logic tcdm_wdata_p2_1_o,  //pragma attribute tcdm_wdata_p2_1_o  pad out_buff
    output logic tcdm_wdata_p2_2_o,  //pragma attribute tcdm_wdata_p2_2_o  pad out_buff
    output logic tcdm_wdata_p2_3_o,  //pragma attribute tcdm_wdata_p2_3_o  pad out_buff
    output logic tcdm_wdata_p2_4_o,  //pragma attribute tcdm_wdata_p2_4_o  pad out_buff
    output logic tcdm_wdata_p2_5_o,  //pragma attribute tcdm_wdata_p2_5_o  pad out_buff
    output logic tcdm_wdata_p2_6_o,  //pragma attribute tcdm_wdata_p2_6_o  pad out_buff
    output logic tcdm_wdata_p2_7_o,  //pragma attribute tcdm_wdata_p2_7_o  pad out_buff
    output logic tcdm_wdata_p2_8_o,  //pragma attribute tcdm_wdata_p2_8_o  pad out_buff
    output logic tcdm_wdata_p2_9_o,  //pragma attribute tcdm_wdata_p2_9_o  pad out_buff
    output logic tcdm_wdata_p2_10_o,  //pragma attribute tcdm_wdata_p2_10_o  pad out_buff
    output logic tcdm_wdata_p2_11_o,  //pragma attribute tcdm_wdata_p2_11_o  pad out_buff
    output logic tcdm_wdata_p2_12_o,  //pragma attribute tcdm_wdata_p2_12_o  pad out_buff
    output logic tcdm_wdata_p2_13_o,  //pragma attribute tcdm_wdata_p2_13_o  pad out_buff
    output logic tcdm_wdata_p2_14_o,  //pragma attribute tcdm_wdata_p2_14_o  pad out_buff
    output logic tcdm_wdata_p2_15_o,  //pragma attribute tcdm_wdata_p2_15_o  pad out_buff
    output logic tcdm_wdata_p2_16_o,  //pragma attribute tcdm_wdata_p2_16_o  pad out_buff
    output logic tcdm_wdata_p2_17_o,  //pragma attribute tcdm_wdata_p2_17_o  pad out_buff
    output logic tcdm_wdata_p2_18_o,  //pragma attribute tcdm_wdata_p2_18_o  pad out_buff
    output logic tcdm_wdata_p2_19_o,  //pragma attribute tcdm_wdata_p2_19_o  pad out_buff
    output logic tcdm_wdata_p2_20_o,  //pragma attribute tcdm_wdata_p2_20_o  pad out_buff
    output logic tcdm_wdata_p2_21_o,  //pragma attribute tcdm_wdata_p2_21_o  pad out_buff
    output logic tcdm_wdata_p2_22_o,  //pragma attribute tcdm_wdata_p2_22_o  pad out_buff
    output logic tcdm_wdata_p2_23_o,  //pragma attribute tcdm_wdata_p2_23_o  pad out_buff
    output logic tcdm_wdata_p2_24_o,  //pragma attribute tcdm_wdata_p2_24_o  pad out_buff
    output logic tcdm_wdata_p2_25_o,  //pragma attribute tcdm_wdata_p2_25_o  pad out_buff
    output logic tcdm_wdata_p2_26_o,  //pragma attribute tcdm_wdata_p2_26_o  pad out_buff
    output logic tcdm_wdata_p2_27_o,  //pragma attribute tcdm_wdata_p2_27_o  pad out_buff
    output logic tcdm_wdata_p2_28_o,  //pragma attribute tcdm_wdata_p2_28_o  pad out_buff
    output logic tcdm_wdata_p2_29_o,  //pragma attribute tcdm_wdata_p2_29_o  pad out_buff
    output logic tcdm_wdata_p2_30_o,  //pragma attribute tcdm_wdata_p2_30_o  pad out_buff
    output logic tcdm_wdata_p2_31_o,  //pragma attribute tcdm_wdata_p2_31_o  pad out_buff
    output logic tcdm_be_p2_0_o,  //pragma attribute tcdm_be_p2_0_o  pad out_buff
    output logic tcdm_be_p2_1_o,  //pragma attribute tcdm_be_p2_1_o  pad out_buff
    output logic tcdm_be_p2_2_o,  //pragma attribute tcdm_be_p2_2_o  pad out_buff
    output logic tcdm_be_p2_3_o,  //pragma attribute tcdm_be_p2_3_o  pad out_buff
    input  logic tcdm_rdata_p2_0_i,  //pragma attribute tcdm_rdata_p2_0_i  pad in_buff
    input  logic tcdm_rdata_p2_1_i,  //pragma attribute tcdm_rdata_p2_1_i  pad in_buff
    input  logic tcdm_rdata_p2_2_i,  //pragma attribute tcdm_rdata_p2_2_i  pad in_buff
    input  logic tcdm_rdata_p2_3_i,  //pragma attribute tcdm_rdata_p2_3_i  pad in_buff
    input  logic tcdm_rdata_p2_4_i,  //pragma attribute tcdm_rdata_p2_4_i  pad in_buff
    input  logic tcdm_rdata_p2_5_i,  //pragma attribute tcdm_rdata_p2_5_i  pad in_buff
    input  logic tcdm_rdata_p2_6_i,  //pragma attribute tcdm_rdata_p2_6_i  pad in_buff
    input  logic tcdm_rdata_p2_7_i,  //pragma attribute tcdm_rdata_p2_7_i  pad in_buff
    input  logic tcdm_rdata_p2_8_i,  //pragma attribute tcdm_rdata_p2_8_i  pad in_buff
    input  logic tcdm_rdata_p2_9_i,  //pragma attribute tcdm_rdata_p2_9_i  pad in_buff
    input  logic tcdm_rdata_p2_10_i,  //pragma attribute tcdm_rdata_p2_10_i  pad in_buff
    input  logic tcdm_rdata_p2_11_i,  //pragma attribute tcdm_rdata_p2_11_i  pad in_buff
    input  logic tcdm_rdata_p2_12_i,  //pragma attribute tcdm_rdata_p2_12_i  pad in_buff
    input  logic tcdm_rdata_p2_13_i,  //pragma attribute tcdm_rdata_p2_13_i  pad in_buff
    input  logic tcdm_rdata_p2_14_i,  //pragma attribute tcdm_rdata_p2_14_i  pad in_buff
    input  logic tcdm_rdata_p2_15_i,  //pragma attribute tcdm_rdata_p2_15_i  pad in_buff
    input  logic tcdm_rdata_p2_16_i,  //pragma attribute tcdm_rdata_p2_16_i  pad in_buff
    input  logic tcdm_rdata_p2_17_i,  //pragma attribute tcdm_rdata_p2_17_i  pad in_buff
    input  logic tcdm_rdata_p2_18_i,  //pragma attribute tcdm_rdata_p2_18_i  pad in_buff
    input  logic tcdm_rdata_p2_19_i,  //pragma attribute tcdm_rdata_p2_19_i  pad in_buff
    input  logic tcdm_rdata_p2_20_i,  //pragma attribute tcdm_rdata_p2_20_i  pad in_buff
    input  logic tcdm_rdata_p2_21_i,  //pragma attribute tcdm_rdata_p2_21_i  pad in_buff
    input  logic tcdm_rdata_p2_22_i,  //pragma attribute tcdm_rdata_p2_22_i  pad in_buff
    input  logic tcdm_rdata_p2_23_i,  //pragma attribute tcdm_rdata_p2_23_i  pad in_buff
    input  logic tcdm_rdata_p2_24_i,  //pragma attribute tcdm_rdata_p2_24_i  pad in_buff
    input  logic tcdm_rdata_p2_25_i,  //pragma attribute tcdm_rdata_p2_25_i  pad in_buff
    input  logic tcdm_rdata_p2_26_i,  //pragma attribute tcdm_rdata_p2_26_i  pad in_buff
    input  logic tcdm_rdata_p2_27_i,  //pragma attribute tcdm_rdata_p2_27_i  pad in_buff
    input  logic tcdm_rdata_p2_28_i,  //pragma attribute tcdm_rdata_p2_28_i  pad in_buff
    input  logic tcdm_rdata_p2_29_i,  //pragma attribute tcdm_rdata_p2_29_i  pad in_buff
    input  logic tcdm_rdata_p2_30_i,  //pragma attribute tcdm_rdata_p2_30_i  pad in_buff
    input  logic tcdm_rdata_p2_31_i,  //pragma attribute tcdm_rdata_p2_31_i  pad in_buff
    input  logic tcdm_gnt_p2_i,  //pragma attribute tcdm_gnt_p2_i  pad in_buff
    input  logic tcdm_r_valid_p2_i,  //pragma attribute tcdm_r_valid_p2_i  pad in_buff


    output logic tcdm_req_p3_o,  //pragma attribute tcdm_req_p3_o  pad out_buff
    output logic tcdm_addr_p3_0_o,  //pragma attribute tcdm_addr_p3_0_o  pad out_buff
    output logic tcdm_addr_p3_1_o,  //pragma attribute tcdm_addr_p3_1_o  pad out_buff
    output logic tcdm_addr_p3_2_o,  //pragma attribute tcdm_addr_p3_2_o  pad out_buff
    output logic tcdm_addr_p3_3_o,  //pragma attribute tcdm_addr_p3_3_o  pad out_buff
    output logic tcdm_addr_p3_4_o,  //pragma attribute tcdm_addr_p3_4_o  pad out_buff
    output logic tcdm_addr_p3_5_o,  //pragma attribute tcdm_addr_p3_5_o  pad out_buff
    output logic tcdm_addr_p3_6_o,  //pragma attribute tcdm_addr_p3_6_o  pad out_buff
    output logic tcdm_addr_p3_7_o,  //pragma attribute tcdm_addr_p3_7_o  pad out_buff
    output logic tcdm_addr_p3_8_o,  //pragma attribute tcdm_addr_p3_8_o  pad out_buff
    output logic tcdm_addr_p3_9_o,  //pragma attribute tcdm_addr_p3_9_o  pad out_buff
    output logic tcdm_addr_p3_10_o,  //pragma attribute tcdm_addr_p3_10_o  pad out_buff
    output logic tcdm_addr_p3_11_o,  //pragma attribute tcdm_addr_p3_11_o  pad out_buff
    output logic tcdm_addr_p3_12_o,  //pragma attribute tcdm_addr_p3_12_o  pad out_buff
    output logic tcdm_addr_p3_13_o,  //pragma attribute tcdm_addr_p3_13_o  pad out_buff
    output logic tcdm_addr_p3_14_o,  //pragma attribute tcdm_addr_p3_14_o  pad out_buff
    output logic tcdm_addr_p3_15_o,  //pragma attribute tcdm_addr_p3_15_o  pad out_buff
    output logic tcdm_addr_p3_16_o,  //pragma attribute tcdm_addr_p3_16_o  pad out_buff
    output logic tcdm_addr_p3_17_o,  //pragma attribute tcdm_addr_p3_17_o  pad out_buff
    output logic tcdm_addr_p3_18_o,  //pragma attribute tcdm_addr_p3_18_o  pad out_buff
    output logic tcdm_addr_p3_19_o,  //pragma attribute tcdm_addr_p3_19_o  pad out_buff
    output logic tcdm_wen_p3_o,  //pragma attribute tcdm_wen_p3_o  pad out_buff
    output logic tcdm_wdata_p3_0_o,  //pragma attribute tcdm_wdata_p3_0_o  pad out_buff
    output logic tcdm_wdata_p3_1_o,  //pragma attribute tcdm_wdata_p3_1_o  pad out_buff
    output logic tcdm_wdata_p3_2_o,  //pragma attribute tcdm_wdata_p3_2_o  pad out_buff
    output logic tcdm_wdata_p3_3_o,  //pragma attribute tcdm_wdata_p3_3_o  pad out_buff
    output logic tcdm_wdata_p3_4_o,  //pragma attribute tcdm_wdata_p3_4_o  pad out_buff
    output logic tcdm_wdata_p3_5_o,  //pragma attribute tcdm_wdata_p3_5_o  pad out_buff
    output logic tcdm_wdata_p3_6_o,  //pragma attribute tcdm_wdata_p3_6_o  pad out_buff
    output logic tcdm_wdata_p3_7_o,  //pragma attribute tcdm_wdata_p3_7_o  pad out_buff
    output logic tcdm_wdata_p3_8_o,  //pragma attribute tcdm_wdata_p3_8_o  pad out_buff
    output logic tcdm_wdata_p3_9_o,  //pragma attribute tcdm_wdata_p3_9_o  pad out_buff
    output logic tcdm_wdata_p3_10_o,  //pragma attribute tcdm_wdata_p3_10_o  pad out_buff
    output logic tcdm_wdata_p3_11_o,  //pragma attribute tcdm_wdata_p3_11_o  pad out_buff
    output logic tcdm_wdata_p3_12_o,  //pragma attribute tcdm_wdata_p3_12_o  pad out_buff
    output logic tcdm_wdata_p3_13_o,  //pragma attribute tcdm_wdata_p3_13_o  pad out_buff
    output logic tcdm_wdata_p3_14_o,  //pragma attribute tcdm_wdata_p3_14_o  pad out_buff
    output logic tcdm_wdata_p3_15_o,  //pragma attribute tcdm_wdata_p3_15_o  pad out_buff
    output logic tcdm_wdata_p3_16_o,  //pragma attribute tcdm_wdata_p3_16_o  pad out_buff
    output logic tcdm_wdata_p3_17_o,  //pragma attribute tcdm_wdata_p3_17_o  pad out_buff
    output logic tcdm_wdata_p3_18_o,  //pragma attribute tcdm_wdata_p3_18_o  pad out_buff
    output logic tcdm_wdata_p3_19_o,  //pragma attribute tcdm_wdata_p3_19_o  pad out_buff
    output logic tcdm_wdata_p3_20_o,  //pragma attribute tcdm_wdata_p3_20_o  pad out_buff
    output logic tcdm_wdata_p3_21_o,  //pragma attribute tcdm_wdata_p3_21_o  pad out_buff
    output logic tcdm_wdata_p3_22_o,  //pragma attribute tcdm_wdata_p3_22_o  pad out_buff
    output logic tcdm_wdata_p3_23_o,  //pragma attribute tcdm_wdata_p3_23_o  pad out_buff
    output logic tcdm_wdata_p3_24_o,  //pragma attribute tcdm_wdata_p3_24_o  pad out_buff
    output logic tcdm_wdata_p3_25_o,  //pragma attribute tcdm_wdata_p3_25_o  pad out_buff
    output logic tcdm_wdata_p3_26_o,  //pragma attribute tcdm_wdata_p3_26_o  pad out_buff
    output logic tcdm_wdata_p3_27_o,  //pragma attribute tcdm_wdata_p3_27_o  pad out_buff
    output logic tcdm_wdata_p3_28_o,  //pragma attribute tcdm_wdata_p3_28_o  pad out_buff
    output logic tcdm_wdata_p3_29_o,  //pragma attribute tcdm_wdata_p3_29_o  pad out_buff
    output logic tcdm_wdata_p3_30_o,  //pragma attribute tcdm_wdata_p3_30_o  pad out_buff
    output logic tcdm_wdata_p3_31_o,  //pragma attribute tcdm_wdata_p3_31_o  pad out_buff
    input  logic tcdm_rdata_p3_0_i,  //pragma attribute tcdm_rdata_p3_0_i  pad in_buff
    input  logic tcdm_rdata_p3_1_i,  //pragma attribute tcdm_rdata_p3_1_i  pad in_buff
    input  logic tcdm_rdata_p3_2_i,  //pragma attribute tcdm_rdata_p3_2_i  pad in_buff
    input  logic tcdm_rdata_p3_3_i,  //pragma attribute tcdm_rdata_p3_3_i  pad in_buff
    input  logic tcdm_rdata_p3_4_i,  //pragma attribute tcdm_rdata_p3_4_i  pad in_buff
    input  logic tcdm_rdata_p3_5_i,  //pragma attribute tcdm_rdata_p3_5_i  pad in_buff
    input  logic tcdm_rdata_p3_6_i,  //pragma attribute tcdm_rdata_p3_6_i  pad in_buff
    input  logic tcdm_rdata_p3_7_i,  //pragma attribute tcdm_rdata_p3_7_i  pad in_buff
    input  logic tcdm_rdata_p3_8_i,  //pragma attribute tcdm_rdata_p3_8_i  pad in_buff
    input  logic tcdm_rdata_p3_9_i,  //pragma attribute tcdm_rdata_p3_9_i  pad in_buff
    input  logic tcdm_rdata_p3_10_i,  //pragma attribute tcdm_rdata_p3_10_i  pad in_buff
    input  logic tcdm_rdata_p3_11_i,  //pragma attribute tcdm_rdata_p3_11_i  pad in_buff
    input  logic tcdm_rdata_p3_12_i,  //pragma attribute tcdm_rdata_p3_12_i  pad in_buff
    input  logic tcdm_rdata_p3_13_i,  //pragma attribute tcdm_rdata_p3_13_i  pad in_buff
    input  logic tcdm_rdata_p3_14_i,  //pragma attribute tcdm_rdata_p3_14_i  pad in_buff
    input  logic tcdm_rdata_p3_15_i,  //pragma attribute tcdm_rdata_p3_15_i  pad in_buff
    input  logic tcdm_rdata_p3_16_i,  //pragma attribute tcdm_rdata_p3_16_i  pad in_buff
    input  logic tcdm_rdata_p3_17_i,  //pragma attribute tcdm_rdata_p3_17_i  pad in_buff
    input  logic tcdm_rdata_p3_18_i,  //pragma attribute tcdm_rdata_p3_18_i  pad in_buff
    input  logic tcdm_rdata_p3_19_i,  //pragma attribute tcdm_rdata_p3_19_i  pad in_buff
    input  logic tcdm_rdata_p3_20_i,  //pragma attribute tcdm_rdata_p3_20_i  pad in_buff
    input  logic tcdm_rdata_p3_21_i,  //pragma attribute tcdm_rdata_p3_21_i  pad in_buff
    input  logic tcdm_rdata_p3_22_i,  //pragma attribute tcdm_rdata_p3_22_i  pad in_buff
    input  logic tcdm_rdata_p3_23_i,  //pragma attribute tcdm_rdata_p3_23_i  pad in_buff
    input  logic tcdm_rdata_p3_24_i,  //pragma attribute tcdm_rdata_p3_24_i  pad in_buff
    input  logic tcdm_rdata_p3_25_i,  //pragma attribute tcdm_rdata_p3_25_i  pad in_buff
    input  logic tcdm_rdata_p3_26_i,  //pragma attribute tcdm_rdata_p3_26_i  pad in_buff
    input  logic tcdm_rdata_p3_27_i,  //pragma attribute tcdm_rdata_p3_27_i  pad in_buff
    input  logic tcdm_rdata_p3_28_i,  //pragma attribute tcdm_rdata_p3_28_i  pad in_buff
    input  logic tcdm_rdata_p3_29_i,  //pragma attribute tcdm_rdata_p3_29_i  pad in_buff
    input  logic tcdm_rdata_p3_30_i,  //pragma attribute tcdm_rdata_p3_30_i  pad in_buff
    input  logic tcdm_rdata_p3_31_i,  //pragma attribute tcdm_rdata_p3_31_i  pad in_buff
    output logic tcdm_be_p3_0_o,  //pragma attribute tcdm_be_p3_0_o  pad out_buff
    output logic tcdm_be_p3_1_o,  //pragma attribute tcdm_be_p3_1_o  pad out_buff
    output logic tcdm_be_p3_2_o,  //pragma attribute tcdm_be_p3_2_o  pad out_buff
    output logic tcdm_be_p3_3_o,  //pragma attribute tcdm_be_p3_3_o  pad out_buff
    input  logic tcdm_gnt_p3_i,  //pragma attribute tcdm_gnt_p3_i  pad in_buff
    input  logic tcdm_r_valid_p3_i,  //pragma attribute tcdm_r_valid_p3_i  pad in_buff

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
    output logic events_15_o

);


  logic [6:0] counter_n0, counter_q0;
  logic [6:0] counter_n1, counter_q1;
  logic [19:0] address0_q, real_address0;
  logic [19:0] address1_q, real_address1;
  logic [19:0] address2_q, real_address2;
  logic [19:0] address3_q, real_address3;
  logic [31:0] apb_pwdata;
  logic increase_counter0, done_n0, done_q0;
  logic increase_counter1, done_n1, done_q1;
  logic [ 6:0] apb_hwce_addr;
  logic [31:0] apb_hwce_prdata;
  logic [40:0] gpio_oe_reg;
  logic [40:0] gpio_val_reg;
  logic [40:0] gpio_in;

  logic [13:0] sw_event_q;
  logic [31:0] accum_q1;
  logic [31:0] tcdm_rdata_p1;
  logic        store_addition_1;
  logic is_accum0, is_accum1;
  logic is_sw_event;
  logic last_iteration0, last_iteration1;
  logic is_tcdm_start_fsm0, is_tcdm_start_fsm1, is_tcdm_start_fsm2, is_tcdm_start_fsm3;
  logic is_tcdm_done_fsm0, is_tcdm_done_fsm1, is_tcdm_done_fsm2, is_tcdm_done_fsm3;
  logic is_gpio_rego_l_val, is_gpio_rego_h_val;
  logic is_gpio_rego_l_oe, is_gpio_rego_h_oe;
  logic is_gpio_sample_regi;

  assign apb_hwce_addr = {
    apb_hwce_addr_6_i,
    apb_hwce_addr_5_i,
    apb_hwce_addr_4_i,
    apb_hwce_addr_3_i,
    apb_hwce_addr_2_i,
    apb_hwce_addr_1_i,
    apb_hwce_addr_0_i
  };

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

  assign is_tcdm_start_fsm0 = apb_hwce_addr == 7'h0;  //0x00
  assign is_tcdm_start_fsm1 = apb_hwce_addr == 7'h1;  //0x04
  assign is_tcdm_start_fsm2 = apb_hwce_addr == 7'h2;  //0x08
  assign is_tcdm_start_fsm3 = apb_hwce_addr == 7'h3;  //0x0C

  assign is_tcdm_done_fsm0 = apb_hwce_addr == 7'h4;  //0x10
  assign is_tcdm_done_fsm1 = apb_hwce_addr == 7'h5;  //0x14
  assign is_tcdm_done_fsm2 = apb_hwce_addr == 7'h6;  //0x18
  assign is_tcdm_done_fsm3 = apb_hwce_addr == 7'h7;  //0x1C

  assign is_gpio_rego_l_val = apb_hwce_addr == 7'h8;  //0x20
  assign is_gpio_rego_h_val = apb_hwce_addr == 7'h9;  //0x24

  assign is_gpio_rego_l_oe = apb_hwce_addr == 7'hA;  //0x28
  assign is_gpio_rego_h_oe = apb_hwce_addr == 7'hB;  //0x2C

  assign is_gpio_sample_regi = apb_hwce_addr == 7'hC;  //0x30


  assign is_accum0 = apb_hwce_addr == 7'hD;  //0x34
  assign is_accum1 = apb_hwce_addr == 7'hE;  //0x38

  assign is_sw_event = apb_hwce_addr == 7'hF;  //0x3C


  enum logic [1:0] {
    IDLE,
    WAIT_GNT,
    WAIT_RVALID
  }
      state_n0, state_q0, state_n1, state_q1;

  assign counter_n0       = counter_q0 + 1;
  assign counter_n1       = counter_q1 + 1;

  assign apb_hwce_ready_o = 1'b1;  //pragma attribute apb_hwce_ready_o pad out_buff

  assign tcdm_be_p0_0_o   = 1'b1;  //pragma attribute tcdm_be_p0_0_o   pad out_buff
  assign tcdm_be_p0_1_o   = 1'b1;  //pragma attribute tcdm_be_p0_1_o   pad out_buff
  assign tcdm_be_p0_2_o   = 1'b1;  //pragma attribute tcdm_be_p0_2_o   pad out_buff
  assign tcdm_be_p0_3_o   = 1'b1;  //pragma attribute tcdm_be_p0_3_o   pad out_buff
  assign tcdm_wen_p0_o    = 1'b0;  //pragma attribute tcdm_wen_p0_o    pad out_buff

  assign tcdm_be_p1_0_o   = 1'b1;  //pragma attribute tcdm_be_p1_0_o   pad out_buff
  assign tcdm_be_p1_1_o   = 1'b1;  //pragma attribute tcdm_be_p1_1_o   pad out_buff
  assign tcdm_be_p1_2_o   = 1'b1;  //pragma attribute tcdm_be_p1_2_o   pad out_buff
  assign tcdm_be_p1_3_o   = 1'b1;  //pragma attribute tcdm_be_p1_3_o   pad out_buff
  assign tcdm_wen_p1_o    = 1'b1;  //pragma attribute tcdm_wen_p1_o    pad out_buff


  always_comb begin

    state_n0          = state_q0;
    tcdm_req_p0_o     = 1'b0;
    increase_counter0 = 1'b0;
    done_n0           = 1'b0;
    events_0_o        = 1'b0;

    unique case (state_q0)

      IDLE: begin
        done_n0 = 1'b1;
        if (apb_hwce_psel_i && apb_hwce_penable_i && apb_hwce_pwrite_i & is_tcdm_start_fsm0) begin
          done_n0  = 1'b0;
          state_n0 = WAIT_GNT;
        end
      end

      WAIT_GNT: begin
        tcdm_req_p0_o = 1'b1;
        if (tcdm_gnt_p0_i) begin
          state_n0          = WAIT_RVALID;
          increase_counter0 = 1'b1;
        end
      end

      WAIT_RVALID: begin
        if (tcdm_r_valid_p0_i) begin
          tcdm_req_p0_o = last_iteration0 ? 1'b0 : 1'b1;
          if (~last_iteration0) begin  //~last_iteration0
            if (~tcdm_gnt_p0_i) begin
              state_n0 = WAIT_GNT;
            end else begin
              //grant received
              increase_counter0 = 1'b1;
              state_n0          = WAIT_RVALID;
            end
          end else begin
            //go back to IDLE and set the DONE flag
            state_n0   = IDLE;
            done_n0    = 1'b1;
            events_0_o = 1'b1;
            //the counter MSB has to go back to 0
          end
        end
      end

      default: begin
      end

    endcase  // state_q0
  end

  always_comb begin

    state_n1          = state_q1;
    tcdm_req_p1_o     = 1'b0;
    increase_counter1 = 1'b0;
    done_n1           = 1'b0;
    events_1_o        = 1'b0;
    store_addition_1  = 1'b0;

    unique case (state_q1)

      IDLE: begin
        done_n1 = 1'b1;
        if (apb_hwce_psel_i && apb_hwce_penable_i && apb_hwce_pwrite_i & is_tcdm_start_fsm1) begin
          done_n1  = 1'b0;
          state_n1 = WAIT_GNT;
        end
      end

      WAIT_GNT: begin
        tcdm_req_p1_o = 1'b1;
        if (tcdm_gnt_p1_i) begin
          state_n1          = WAIT_RVALID;
          increase_counter1 = 1'b1;
        end
      end

      WAIT_RVALID: begin
        if (tcdm_r_valid_p1_i) begin
          tcdm_req_p1_o    = last_iteration1 ? 1'b0 : 1'b1;
          store_addition_1 = 1'b1;
          if (~last_iteration1) begin  //~last_iteration1
            if (~tcdm_gnt_p1_i) begin
              state_n1 = WAIT_GNT;
            end else begin
              //grant received
              increase_counter1 = 1'b1;
              state_n1          = WAIT_RVALID;
            end
          end else begin
            //go back to IDLE and set the DONE flag
            state_n1   = IDLE;
            done_n1    = 1'b1;
            events_1_o = 1'b1;
            //the counter MSB has to go back to 0
          end
        end
      end

      default: begin
      end


    endcase  // state_q1
  end

  assign last_iteration0 = counter_q0[6] == 1'b1;
  assign last_iteration1 = counter_q1[6] == 1'b1;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      counter_q0 <= '0;
      state_q0   <= IDLE;
      done_q0    <= 1'b1;

      counter_q1 <= '0;
      state_q1   <= IDLE;
      done_q1    <= 1'b1;

      accum_q1   <= '0;

    end else begin
      state_q0        <= state_n0;
      counter_q0[5:0] <= increase_counter0 ? counter_n0[5:0] : counter_q0[5:0];
      counter_q0[6]   <= done_n0 ? 1'b0 : (increase_counter0 ? counter_n0[6] : counter_q0[6]);
      done_q0         <= done_n0;

      state_q1        <= state_n1;
      counter_q1[5:0] <= increase_counter1 ? counter_n1[5:0] : counter_q1[5:0];
      counter_q1[6]   <= done_n1 ? 1'b0 : (increase_counter1 ? counter_n1[6] : counter_q1[6]);
      done_q1         <= done_n1;

      if (store_addition_1) begin
        accum_q1 <= accum_q1 + tcdm_rdata_p1;
      end
      if (apb_hwce_psel_i && apb_hwce_penable_i && apb_hwce_pwrite_i && is_accum1) begin
        accum_q1 <= apb_pwdata[31:0];
      end

    end
  end


  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      address0_q   <= '0;
      address1_q   <= '0;
      gpio_oe_reg  <= '0;
      gpio_val_reg <= '0;
      sw_event_q   <= '0;
    end else begin
      if (apb_hwce_psel_i && apb_hwce_penable_i && apb_hwce_pwrite_i && is_tcdm_start_fsm0)
        address0_q <= apb_pwdata[19:0];

      if (apb_hwce_psel_i && apb_hwce_penable_i && apb_hwce_pwrite_i && is_tcdm_start_fsm1)
        address1_q <= apb_pwdata[19:0];

      if (apb_hwce_psel_i && apb_hwce_penable_i && apb_hwce_pwrite_i && is_gpio_rego_l_val)
        gpio_val_reg[31:0] <= apb_pwdata[31:0];

      if (apb_hwce_psel_i && apb_hwce_penable_i && apb_hwce_pwrite_i && is_gpio_rego_h_val)
        gpio_val_reg[40:32] <= apb_pwdata[8:0];

      if (apb_hwce_psel_i && apb_hwce_penable_i && apb_hwce_pwrite_i && is_gpio_rego_l_oe)
        gpio_oe_reg[31:0] <= apb_pwdata[31:0];

      if (apb_hwce_psel_i && apb_hwce_penable_i && apb_hwce_pwrite_i && is_gpio_rego_h_oe)
        gpio_oe_reg[40:32] <= apb_pwdata[8:0];

      if (apb_hwce_psel_i && apb_hwce_penable_i && apb_hwce_pwrite_i && is_gpio_sample_regi)
        gpio_val_reg <= gpio_in[40:0];

      if (apb_hwce_psel_i && apb_hwce_penable_i && apb_hwce_pwrite_i && is_sw_event)
        sw_event_q <= apb_pwdata[15:2];


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
                        events_2_o
                        } =  sw_event_q;


  always_comb begin
    apb_hwce_prdata = '0;
    if (apb_hwce_psel_i & apb_hwce_penable_i & ~apb_hwce_pwrite_i) begin

      if (is_tcdm_done_fsm0) apb_hwce_prdata = $unsigned(done_q0);
      else if (is_tcdm_done_fsm1) apb_hwce_prdata = $unsigned(done_q1);
      else if (is_gpio_rego_l_val) apb_hwce_prdata = gpio_val_reg[31:0];
      else if (is_gpio_rego_h_val) apb_hwce_prdata = $unsigned(gpio_val_reg[40:32]);
      else if (is_gpio_rego_l_oe) apb_hwce_prdata = gpio_oe_reg[31:0];
      else if (is_gpio_rego_h_oe) apb_hwce_prdata = $unsigned(gpio_oe_reg[40:32]);
      else if (is_accum1) begin
        apb_hwce_prdata = accum_q1;
      end else if (is_sw_event) begin
        apb_hwce_prdata = $unsigned({sw_event_q, 2'b00});
      end else apb_hwce_prdata = '0;
    end

  end



  assign tcdm_rdata_p1 = {
    tcdm_rdata_p1_31_i,
    tcdm_rdata_p1_30_i,
    tcdm_rdata_p1_29_i,
    tcdm_rdata_p1_28_i,
    tcdm_rdata_p1_27_i,
    tcdm_rdata_p1_26_i,
    tcdm_rdata_p1_25_i,
    tcdm_rdata_p1_24_i,
    tcdm_rdata_p1_23_i,
    tcdm_rdata_p1_22_i,
    tcdm_rdata_p1_21_i,
    tcdm_rdata_p1_20_i,
    tcdm_rdata_p1_19_i,
    tcdm_rdata_p1_18_i,
    tcdm_rdata_p1_17_i,
    tcdm_rdata_p1_16_i,
    tcdm_rdata_p1_15_i,
    tcdm_rdata_p1_14_i,
    tcdm_rdata_p1_13_i,
    tcdm_rdata_p1_12_i,
    tcdm_rdata_p1_11_i,
    tcdm_rdata_p1_10_i,
    tcdm_rdata_p1_9_i,
    tcdm_rdata_p1_8_i,
    tcdm_rdata_p1_7_i,
    tcdm_rdata_p1_6_i,
    tcdm_rdata_p1_5_i,
    tcdm_rdata_p1_4_i,
    tcdm_rdata_p1_3_i,
    tcdm_rdata_p1_2_i,
    tcdm_rdata_p1_1_i,
    tcdm_rdata_p1_0_i
  };



  assign real_address0 = address0_q + $unsigned({counter_q0, 2'b00});
  assign real_address1 = address1_q + $unsigned({counter_q1, 2'b00});

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

  assign tcdm_wdata_p0_0_o = counter_q0[0];
  assign tcdm_wdata_p0_1_o = counter_q0[1];
  assign tcdm_wdata_p0_2_o = counter_q0[2];
  assign tcdm_wdata_p0_3_o = counter_q0[3];
  assign tcdm_wdata_p0_4_o = counter_q0[4];
  assign tcdm_wdata_p0_5_o = counter_q0[5];
  assign tcdm_wdata_p0_6_o = counter_q0[6];
  assign tcdm_wdata_p0_7_o = 1'b0;  //pragma attribute tcdm_wdata_p0_7_o  pad out_buff
  assign tcdm_wdata_p0_8_o = 1'b0;  //pragma attribute tcdm_wdata_p0_8_o  pad out_buff
  assign tcdm_wdata_p0_9_o = 1'b0;  //pragma attribute tcdm_wdata_p0_9_o  pad out_buff
  assign tcdm_wdata_p0_10_o = 1'b0;  //pragma attribute tcdm_wdata_p0_10_o pad out_buff
  assign tcdm_wdata_p0_11_o = 1'b0;  //pragma attribute tcdm_wdata_p0_11_o pad out_buff
  assign tcdm_wdata_p0_12_o = 1'b0;  //pragma attribute tcdm_wdata_p0_12_o pad out_buff
  assign tcdm_wdata_p0_13_o = 1'b0;  //pragma attribute tcdm_wdata_p0_13_o pad out_buff
  assign tcdm_wdata_p0_14_o = 1'b0;  //pragma attribute tcdm_wdata_p0_14_o pad out_buff
  assign tcdm_wdata_p0_15_o = 1'b0;  //pragma attribute tcdm_wdata_p0_15_o pad out_buff
  assign tcdm_wdata_p0_16_o = 1'b0;  //pragma attribute tcdm_wdata_p0_16_o pad out_buff
  assign tcdm_wdata_p0_17_o = 1'b0;  //pragma attribute tcdm_wdata_p0_17_o pad out_buff
  assign tcdm_wdata_p0_18_o = 1'b0;  //pragma attribute tcdm_wdata_p0_18_o pad out_buff
  assign tcdm_wdata_p0_19_o = 1'b0;  //pragma attribute tcdm_wdata_p0_19_o pad out_buff
  assign tcdm_wdata_p0_20_o = 1'b0;  //pragma attribute tcdm_wdata_p0_20_o pad out_buff
  assign tcdm_wdata_p0_21_o = 1'b0;  //pragma attribute tcdm_wdata_p0_21_o pad out_buff
  assign tcdm_wdata_p0_22_o = 1'b0;  //pragma attribute tcdm_wdata_p0_22_o pad out_buff
  assign tcdm_wdata_p0_23_o = 1'b0;  //pragma attribute tcdm_wdata_p0_23_o pad out_buff
  assign tcdm_wdata_p0_24_o = 1'b0;  //pragma attribute tcdm_wdata_p0_24_o pad out_buff
  assign tcdm_wdata_p0_25_o = 1'b0;  //pragma attribute tcdm_wdata_p0_25_o pad out_buff
  assign tcdm_wdata_p0_26_o = 1'b0;  //pragma attribute tcdm_wdata_p0_26_o pad out_buff
  assign tcdm_wdata_p0_27_o = 1'b0;  //pragma attribute tcdm_wdata_p0_27_o pad out_buff
  assign tcdm_wdata_p0_28_o = 1'b0;  //pragma attribute tcdm_wdata_p0_28_o pad out_buff
  assign tcdm_wdata_p0_29_o = 1'b0;  //pragma attribute tcdm_wdata_p0_29_o pad out_buff
  assign tcdm_wdata_p0_30_o = 1'b0;  //pragma attribute tcdm_wdata_p0_30_o pad out_buff
  assign tcdm_wdata_p0_31_o = 1'b0;  //pragma attribute tcdm_wdata_p0_31_o pad out_buff



  assign tcdm_wdata_p1_0_o = 1'b0;
  assign tcdm_wdata_p1_1_o = 1'b0;
  assign tcdm_wdata_p1_2_o = 1'b0;
  assign tcdm_wdata_p1_3_o = 1'b0;
  assign tcdm_wdata_p1_4_o = 1'b0;
  assign tcdm_wdata_p1_5_o = 1'b0;
  assign tcdm_wdata_p1_6_o = 1'b0;
  assign tcdm_wdata_p1_7_o = 1'b0;
  assign tcdm_wdata_p1_8_o = 1'b0;
  assign tcdm_wdata_p1_9_o = 1'b0;
  assign tcdm_wdata_p1_10_o = 1'b0;
  assign tcdm_wdata_p1_11_o = 1'b0;
  assign tcdm_wdata_p1_12_o = 1'b0;
  assign tcdm_wdata_p1_13_o = 1'b0;
  assign tcdm_wdata_p1_14_o = 1'b0;
  assign tcdm_wdata_p1_15_o = 1'b0;
  assign tcdm_wdata_p1_16_o = 1'b0;
  assign tcdm_wdata_p1_17_o = 1'b0;
  assign tcdm_wdata_p1_18_o = 1'b0;
  assign tcdm_wdata_p1_19_o = 1'b0;
  assign tcdm_wdata_p1_20_o = 1'b0;
  assign tcdm_wdata_p1_21_o = 1'b0;
  assign tcdm_wdata_p1_22_o = 1'b0;
  assign tcdm_wdata_p1_23_o = 1'b0;
  assign tcdm_wdata_p1_24_o = 1'b0;
  assign tcdm_wdata_p1_25_o = 1'b0;
  assign tcdm_wdata_p1_26_o = 1'b0;
  assign tcdm_wdata_p1_27_o = 1'b0;
  assign tcdm_wdata_p1_28_o = 1'b0;
  assign tcdm_wdata_p1_29_o = 1'b0;
  assign tcdm_wdata_p1_30_o = 1'b0;
  assign tcdm_wdata_p1_31_o = 1'b0;


  assign tcdm_req_p2_o = 1'b0;
  assign tcdm_addr_p2_0_o = 1'b0;
  assign tcdm_addr_p2_1_o = 1'b0;
  assign tcdm_addr_p2_2_o = 1'b0;
  assign tcdm_addr_p2_3_o = 1'b0;
  assign tcdm_addr_p2_4_o = 1'b0;
  assign tcdm_addr_p2_5_o = 1'b0;
  assign tcdm_addr_p2_6_o = 1'b0;
  assign tcdm_addr_p2_7_o = 1'b0;
  assign tcdm_addr_p2_8_o = 1'b0;
  assign tcdm_addr_p2_9_o = 1'b0;
  assign tcdm_addr_p2_10_o = 1'b0;
  assign tcdm_addr_p2_11_o = 1'b0;
  assign tcdm_addr_p2_12_o = 1'b0;
  assign tcdm_addr_p2_13_o = 1'b0;
  assign tcdm_addr_p2_14_o = 1'b0;
  assign tcdm_addr_p2_15_o = 1'b0;
  assign tcdm_addr_p2_16_o = 1'b0;
  assign tcdm_addr_p2_17_o = 1'b0;
  assign tcdm_addr_p2_18_o = 1'b0;
  assign tcdm_addr_p2_19_o = 1'b0;
  assign tcdm_wen_p2_o = 1'b0;
  assign tcdm_wdata_p2_0_o = 1'b0;
  assign tcdm_wdata_p2_1_o = 1'b0;
  assign tcdm_wdata_p2_2_o = 1'b0;
  assign tcdm_wdata_p2_3_o = 1'b0;
  assign tcdm_wdata_p2_4_o = 1'b0;
  assign tcdm_wdata_p2_5_o = 1'b0;
  assign tcdm_wdata_p2_6_o = 1'b0;
  assign tcdm_wdata_p2_7_o = 1'b0;
  assign tcdm_wdata_p2_8_o = 1'b0;
  assign tcdm_wdata_p2_9_o = 1'b0;
  assign tcdm_wdata_p2_10_o = 1'b0;
  assign tcdm_wdata_p2_11_o = 1'b0;
  assign tcdm_wdata_p2_12_o = 1'b0;
  assign tcdm_wdata_p2_13_o = 1'b0;
  assign tcdm_wdata_p2_14_o = 1'b0;
  assign tcdm_wdata_p2_15_o = 1'b0;
  assign tcdm_wdata_p2_16_o = 1'b0;
  assign tcdm_wdata_p2_17_o = 1'b0;
  assign tcdm_wdata_p2_18_o = 1'b0;
  assign tcdm_wdata_p2_19_o = 1'b0;
  assign tcdm_wdata_p2_20_o = 1'b0;
  assign tcdm_wdata_p2_21_o = 1'b0;
  assign tcdm_wdata_p2_22_o = 1'b0;
  assign tcdm_wdata_p2_23_o = 1'b0;
  assign tcdm_wdata_p2_24_o = 1'b0;
  assign tcdm_wdata_p2_25_o = 1'b0;
  assign tcdm_wdata_p2_26_o = 1'b0;
  assign tcdm_wdata_p2_27_o = 1'b0;
  assign tcdm_wdata_p2_28_o = 1'b0;
  assign tcdm_wdata_p2_29_o = 1'b0;
  assign tcdm_wdata_p2_30_o = 1'b0;
  assign tcdm_wdata_p2_31_o = 1'b0;
  assign tcdm_be_p2_0_o = 1'b0;
  assign tcdm_be_p2_1_o = 1'b0;
  assign tcdm_be_p2_2_o = 1'b0;
  assign tcdm_be_p2_3_o = 1'b0;

  assign tcdm_req_p3_o = 1'b0;
  assign tcdm_addr_p3_0_o = 1'b0;
  assign tcdm_addr_p3_1_o = 1'b0;
  assign tcdm_addr_p3_2_o = 1'b0;
  assign tcdm_addr_p3_3_o = 1'b0;
  assign tcdm_addr_p3_4_o = 1'b0;
  assign tcdm_addr_p3_5_o = 1'b0;
  assign tcdm_addr_p3_6_o = 1'b0;
  assign tcdm_addr_p3_7_o = 1'b0;
  assign tcdm_addr_p3_8_o = 1'b0;
  assign tcdm_addr_p3_9_o = 1'b0;
  assign tcdm_addr_p3_10_o = 1'b0;
  assign tcdm_addr_p3_11_o = 1'b0;
  assign tcdm_addr_p3_12_o = 1'b0;
  assign tcdm_addr_p3_13_o = 1'b0;
  assign tcdm_addr_p3_14_o = 1'b0;
  assign tcdm_addr_p3_15_o = 1'b0;
  assign tcdm_addr_p3_16_o = 1'b0;
  assign tcdm_addr_p3_17_o = 1'b0;
  assign tcdm_addr_p3_18_o = 1'b0;
  assign tcdm_addr_p3_19_o = 1'b0;
  assign tcdm_wen_p3_o = 1'b0;
  assign tcdm_wdata_p3_0_o = 1'b0;
  assign tcdm_wdata_p3_1_o = 1'b0;
  assign tcdm_wdata_p3_2_o = 1'b0;
  assign tcdm_wdata_p3_3_o = 1'b0;
  assign tcdm_wdata_p3_4_o = 1'b0;
  assign tcdm_wdata_p3_5_o = 1'b0;
  assign tcdm_wdata_p3_6_o = 1'b0;
  assign tcdm_wdata_p3_7_o = 1'b0;
  assign tcdm_wdata_p3_8_o = 1'b0;
  assign tcdm_wdata_p3_9_o = 1'b0;
  assign tcdm_wdata_p3_10_o = 1'b0;
  assign tcdm_wdata_p3_11_o = 1'b0;
  assign tcdm_wdata_p3_12_o = 1'b0;
  assign tcdm_wdata_p3_13_o = 1'b0;
  assign tcdm_wdata_p3_14_o = 1'b0;
  assign tcdm_wdata_p3_15_o = 1'b0;
  assign tcdm_wdata_p3_16_o = 1'b0;
  assign tcdm_wdata_p3_17_o = 1'b0;
  assign tcdm_wdata_p3_18_o = 1'b0;
  assign tcdm_wdata_p3_19_o = 1'b0;
  assign tcdm_wdata_p3_20_o = 1'b0;
  assign tcdm_wdata_p3_21_o = 1'b0;
  assign tcdm_wdata_p3_22_o = 1'b0;
  assign tcdm_wdata_p3_23_o = 1'b0;
  assign tcdm_wdata_p3_24_o = 1'b0;
  assign tcdm_wdata_p3_25_o = 1'b0;
  assign tcdm_wdata_p3_26_o = 1'b0;
  assign tcdm_wdata_p3_27_o = 1'b0;
  assign tcdm_wdata_p3_28_o = 1'b0;
  assign tcdm_wdata_p3_29_o = 1'b0;
  assign tcdm_wdata_p3_30_o = 1'b0;
  assign tcdm_wdata_p3_31_o = 1'b0;
  assign tcdm_be_p3_0_o = 1'b0;
  assign tcdm_be_p3_1_o = 1'b0;
  assign tcdm_be_p3_2_o = 1'b0;
  assign tcdm_be_p3_3_o = 1'b0;

endmodule
