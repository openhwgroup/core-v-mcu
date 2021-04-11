// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


module iir_test
(
    input  logic         clk_i,
    input  logic         rst_ni,

    output logic         tcdm_req_p0_o,
    output logic         tcdm_addr_p0_0_o,
    output logic         tcdm_addr_p0_1_o,
    output logic         tcdm_addr_p0_2_o,
    output logic         tcdm_addr_p0_3_o,
    output logic         tcdm_addr_p0_4_o,
    output logic         tcdm_addr_p0_5_o,
    output logic         tcdm_addr_p0_6_o,
    output logic         tcdm_addr_p0_7_o,
    output logic         tcdm_addr_p0_8_o,
    output logic         tcdm_addr_p0_9_o,
    output logic         tcdm_addr_p0_10_o,
    output logic         tcdm_addr_p0_11_o,
    output logic         tcdm_addr_p0_12_o,
    output logic         tcdm_addr_p0_13_o,
    output logic         tcdm_addr_p0_14_o,
    output logic         tcdm_addr_p0_15_o,
    output logic         tcdm_addr_p0_16_o,
    output logic         tcdm_addr_p0_17_o,
    output logic         tcdm_addr_p0_18_o,
    output logic         tcdm_addr_p0_19_o,
    output logic         tcdm_wen_p0_o,
    output logic         tcdm_wdata_p0_0_o,
    output logic         tcdm_wdata_p0_1_o,
    output logic         tcdm_wdata_p0_2_o,
    output logic         tcdm_wdata_p0_3_o,
    output logic         tcdm_wdata_p0_4_o,
    output logic         tcdm_wdata_p0_5_o,
    output logic         tcdm_wdata_p0_6_o,
    output logic         tcdm_wdata_p0_7_o,
    output logic         tcdm_wdata_p0_8_o,
    output logic         tcdm_wdata_p0_9_o,
    output logic         tcdm_wdata_p0_10_o,
    output logic         tcdm_wdata_p0_11_o,
    output logic         tcdm_wdata_p0_12_o,
    output logic         tcdm_wdata_p0_13_o,
    output logic         tcdm_wdata_p0_14_o,
    output logic         tcdm_wdata_p0_15_o,
    output logic         tcdm_wdata_p0_16_o,
    output logic         tcdm_wdata_p0_17_o,
    output logic         tcdm_wdata_p0_18_o,
    output logic         tcdm_wdata_p0_19_o,
    output logic         tcdm_wdata_p0_20_o,
    output logic         tcdm_wdata_p0_21_o,
    output logic         tcdm_wdata_p0_22_o,
    output logic         tcdm_wdata_p0_23_o,
    output logic         tcdm_wdata_p0_24_o,
    output logic         tcdm_wdata_p0_25_o,
    output logic         tcdm_wdata_p0_26_o,
    output logic         tcdm_wdata_p0_27_o,
    output logic         tcdm_wdata_p0_28_o,
    output logic         tcdm_wdata_p0_29_o,
    output logic         tcdm_wdata_p0_30_o,
    output logic         tcdm_wdata_p0_31_o,
    input  logic         tcdm_r_rdata_p0_0_i,
    input  logic         tcdm_r_rdata_p0_1_i,
    input  logic         tcdm_r_rdata_p0_2_i,
    input  logic         tcdm_r_rdata_p0_3_i,
    input  logic         tcdm_r_rdata_p0_4_i,
    input  logic         tcdm_r_rdata_p0_5_i,
    input  logic         tcdm_r_rdata_p0_6_i,
    input  logic         tcdm_r_rdata_p0_7_i,
    input  logic         tcdm_r_rdata_p0_8_i,
    input  logic         tcdm_r_rdata_p0_9_i,
    input  logic         tcdm_r_rdata_p0_10_i,
    input  logic         tcdm_r_rdata_p0_11_i,
    input  logic         tcdm_r_rdata_p0_12_i,
    input  logic         tcdm_r_rdata_p0_13_i,
    input  logic         tcdm_r_rdata_p0_14_i,
    input  logic         tcdm_r_rdata_p0_15_i,
    input  logic         tcdm_r_rdata_p0_16_i,
    input  logic         tcdm_r_rdata_p0_17_i,
    input  logic         tcdm_r_rdata_p0_18_i,
    input  logic         tcdm_r_rdata_p0_19_i,
    input  logic         tcdm_r_rdata_p0_20_i,
    input  logic         tcdm_r_rdata_p0_21_i,
    input  logic         tcdm_r_rdata_p0_22_i,
    input  logic         tcdm_r_rdata_p0_23_i,
    input  logic         tcdm_r_rdata_p0_24_i,
    input  logic         tcdm_r_rdata_p0_25_i,
    input  logic         tcdm_r_rdata_p0_26_i,
    input  logic         tcdm_r_rdata_p0_27_i,
    input  logic         tcdm_r_rdata_p0_28_i,
    input  logic         tcdm_r_rdata_p0_29_i,
    input  logic         tcdm_r_rdata_p0_30_i,
    input  logic         tcdm_r_rdata_p0_31_i,
    output logic         tcdm_be_p0_0_o,
    output logic         tcdm_be_p0_1_o,
    output logic         tcdm_be_p0_2_o,
    output logic         tcdm_be_p0_3_o,
    input  logic         tcdm_gnt_p0_i,
    input  logic         tcdm_r_valid_p0_i,

    output logic         tcdm_req_p1_o,
    output logic         tcdm_addr_p1_0_o,
    output logic         tcdm_addr_p1_1_o,
    output logic         tcdm_addr_p1_2_o,
    output logic         tcdm_addr_p1_3_o,
    output logic         tcdm_addr_p1_4_o,
    output logic         tcdm_addr_p1_5_o,
    output logic         tcdm_addr_p1_6_o,
    output logic         tcdm_addr_p1_7_o,
    output logic         tcdm_addr_p1_8_o,
    output logic         tcdm_addr_p1_9_o,
    output logic         tcdm_addr_p1_10_o,
    output logic         tcdm_addr_p1_11_o,
    output logic         tcdm_addr_p1_12_o,
    output logic         tcdm_addr_p1_13_o,
    output logic         tcdm_addr_p1_14_o,
    output logic         tcdm_addr_p1_15_o,
    output logic         tcdm_addr_p1_16_o,
    output logic         tcdm_addr_p1_17_o,
    output logic         tcdm_addr_p1_18_o,
    output logic         tcdm_addr_p1_19_o,
    output logic         tcdm_wen_p1_o,
    output logic         tcdm_wdata_p1_0_o,
    output logic         tcdm_wdata_p1_1_o,
    output logic         tcdm_wdata_p1_2_o,
    output logic         tcdm_wdata_p1_3_o,
    output logic         tcdm_wdata_p1_4_o,
    output logic         tcdm_wdata_p1_5_o,
    output logic         tcdm_wdata_p1_6_o,
    output logic         tcdm_wdata_p1_7_o,
    output logic         tcdm_wdata_p1_8_o,
    output logic         tcdm_wdata_p1_9_o,
    output logic         tcdm_wdata_p1_10_o,
    output logic         tcdm_wdata_p1_11_o,
    output logic         tcdm_wdata_p1_12_o,
    output logic         tcdm_wdata_p1_13_o,
    output logic         tcdm_wdata_p1_14_o,
    output logic         tcdm_wdata_p1_15_o,
    output logic         tcdm_wdata_p1_16_o,
    output logic         tcdm_wdata_p1_17_o,
    output logic         tcdm_wdata_p1_18_o,
    output logic         tcdm_wdata_p1_19_o,
    output logic         tcdm_wdata_p1_20_o,
    output logic         tcdm_wdata_p1_21_o,
    output logic         tcdm_wdata_p1_22_o,
    output logic         tcdm_wdata_p1_23_o,
    output logic         tcdm_wdata_p1_24_o,
    output logic         tcdm_wdata_p1_25_o,
    output logic         tcdm_wdata_p1_26_o,
    output logic         tcdm_wdata_p1_27_o,
    output logic         tcdm_wdata_p1_28_o,
    output logic         tcdm_wdata_p1_29_o,
    output logic         tcdm_wdata_p1_30_o,
    output logic         tcdm_wdata_p1_31_o,
    input  logic         tcdm_r_rdata_p1_0_i,
    input  logic         tcdm_r_rdata_p1_1_i,
    input  logic         tcdm_r_rdata_p1_2_i,
    input  logic         tcdm_r_rdata_p1_3_i,
    input  logic         tcdm_r_rdata_p1_4_i,
    input  logic         tcdm_r_rdata_p1_5_i,
    input  logic         tcdm_r_rdata_p1_6_i,
    input  logic         tcdm_r_rdata_p1_7_i,
    input  logic         tcdm_r_rdata_p1_8_i,
    input  logic         tcdm_r_rdata_p1_9_i,
    input  logic         tcdm_r_rdata_p1_10_i,
    input  logic         tcdm_r_rdata_p1_11_i,
    input  logic         tcdm_r_rdata_p1_12_i,
    input  logic         tcdm_r_rdata_p1_13_i,
    input  logic         tcdm_r_rdata_p1_14_i,
    input  logic         tcdm_r_rdata_p1_15_i,
    input  logic         tcdm_r_rdata_p1_16_i,
    input  logic         tcdm_r_rdata_p1_17_i,
    input  logic         tcdm_r_rdata_p1_18_i,
    input  logic         tcdm_r_rdata_p1_19_i,
    input  logic         tcdm_r_rdata_p1_20_i,
    input  logic         tcdm_r_rdata_p1_21_i,
    input  logic         tcdm_r_rdata_p1_22_i,
    input  logic         tcdm_r_rdata_p1_23_i,
    input  logic         tcdm_r_rdata_p1_24_i,
    input  logic         tcdm_r_rdata_p1_25_i,
    input  logic         tcdm_r_rdata_p1_26_i,
    input  logic         tcdm_r_rdata_p1_27_i,
    input  logic         tcdm_r_rdata_p1_28_i,
    input  logic         tcdm_r_rdata_p1_29_i,
    input  logic         tcdm_r_rdata_p1_30_i,
    input  logic         tcdm_r_rdata_p1_31_i,
    output logic         tcdm_be_p1_0_o,
    output logic         tcdm_be_p1_1_o,
    output logic         tcdm_be_p1_2_o,
    output logic         tcdm_be_p1_3_o,
    input  logic         tcdm_gnt_p1_i,
    input  logic         tcdm_r_valid_p1_i,

    output logic         tcdm_req_p2_o,
    output logic         tcdm_addr_p2_0_o,
    output logic         tcdm_addr_p2_1_o,
    output logic         tcdm_addr_p2_2_o,
    output logic         tcdm_addr_p2_3_o,
    output logic         tcdm_addr_p2_4_o,
    output logic         tcdm_addr_p2_5_o,
    output logic         tcdm_addr_p2_6_o,
    output logic         tcdm_addr_p2_7_o,
    output logic         tcdm_addr_p2_8_o,
    output logic         tcdm_addr_p2_9_o,
    output logic         tcdm_addr_p2_10_o,
    output logic         tcdm_addr_p2_11_o,
    output logic         tcdm_addr_p2_12_o,
    output logic         tcdm_addr_p2_13_o,
    output logic         tcdm_addr_p2_14_o,
    output logic         tcdm_addr_p2_15_o,
    output logic         tcdm_addr_p2_16_o,
    output logic         tcdm_addr_p2_17_o,
    output logic         tcdm_addr_p2_18_o,
    output logic         tcdm_addr_p2_19_o,
    output logic         tcdm_wen_p2_o,
    output logic         tcdm_wdata_p2_0_o,
    output logic         tcdm_wdata_p2_1_o,
    output logic         tcdm_wdata_p2_2_o,
    output logic         tcdm_wdata_p2_3_o,
    output logic         tcdm_wdata_p2_4_o,
    output logic         tcdm_wdata_p2_5_o,
    output logic         tcdm_wdata_p2_6_o,
    output logic         tcdm_wdata_p2_7_o,
    output logic         tcdm_wdata_p2_8_o,
    output logic         tcdm_wdata_p2_9_o,
    output logic         tcdm_wdata_p2_10_o,
    output logic         tcdm_wdata_p2_11_o,
    output logic         tcdm_wdata_p2_12_o,
    output logic         tcdm_wdata_p2_13_o,
    output logic         tcdm_wdata_p2_14_o,
    output logic         tcdm_wdata_p2_15_o,
    output logic         tcdm_wdata_p2_16_o,
    output logic         tcdm_wdata_p2_17_o,
    output logic         tcdm_wdata_p2_18_o,
    output logic         tcdm_wdata_p2_19_o,
    output logic         tcdm_wdata_p2_20_o,
    output logic         tcdm_wdata_p2_21_o,
    output logic         tcdm_wdata_p2_22_o,
    output logic         tcdm_wdata_p2_23_o,
    output logic         tcdm_wdata_p2_24_o,
    output logic         tcdm_wdata_p2_25_o,
    output logic         tcdm_wdata_p2_26_o,
    output logic         tcdm_wdata_p2_27_o,
    output logic         tcdm_wdata_p2_28_o,
    output logic         tcdm_wdata_p2_29_o,
    output logic         tcdm_wdata_p2_30_o,
    output logic         tcdm_wdata_p2_31_o,
    input  logic         tcdm_r_rdata_p2_0_i,
    input  logic         tcdm_r_rdata_p2_1_i,
    input  logic         tcdm_r_rdata_p2_2_i,
    input  logic         tcdm_r_rdata_p2_3_i,
    input  logic         tcdm_r_rdata_p2_4_i,
    input  logic         tcdm_r_rdata_p2_5_i,
    input  logic         tcdm_r_rdata_p2_6_i,
    input  logic         tcdm_r_rdata_p2_7_i,
    input  logic         tcdm_r_rdata_p2_8_i,
    input  logic         tcdm_r_rdata_p2_9_i,
    input  logic         tcdm_r_rdata_p2_10_i,
    input  logic         tcdm_r_rdata_p2_11_i,
    input  logic         tcdm_r_rdata_p2_12_i,
    input  logic         tcdm_r_rdata_p2_13_i,
    input  logic         tcdm_r_rdata_p2_14_i,
    input  logic         tcdm_r_rdata_p2_15_i,
    input  logic         tcdm_r_rdata_p2_16_i,
    input  logic         tcdm_r_rdata_p2_17_i,
    input  logic         tcdm_r_rdata_p2_18_i,
    input  logic         tcdm_r_rdata_p2_19_i,
    input  logic         tcdm_r_rdata_p2_20_i,
    input  logic         tcdm_r_rdata_p2_21_i,
    input  logic         tcdm_r_rdata_p2_22_i,
    input  logic         tcdm_r_rdata_p2_23_i,
    input  logic         tcdm_r_rdata_p2_24_i,
    input  logic         tcdm_r_rdata_p2_25_i,
    input  logic         tcdm_r_rdata_p2_26_i,
    input  logic         tcdm_r_rdata_p2_27_i,
    input  logic         tcdm_r_rdata_p2_28_i,
    input  logic         tcdm_r_rdata_p2_29_i,
    input  logic         tcdm_r_rdata_p2_30_i,
    input  logic         tcdm_r_rdata_p2_31_i,
    output logic         tcdm_be_p2_0_o,
    output logic         tcdm_be_p2_1_o,
    output logic         tcdm_be_p2_2_o,
    output logic         tcdm_be_p2_3_o,
    input  logic         tcdm_gnt_p2_i,
    input  logic         tcdm_r_valid_p2_i,

    output logic         tcdm_req_p3_o,
    output logic         tcdm_addr_p3_0_o,
    output logic         tcdm_addr_p3_1_o,
    output logic         tcdm_addr_p3_2_o,
    output logic         tcdm_addr_p3_3_o,
    output logic         tcdm_addr_p3_4_o,
    output logic         tcdm_addr_p3_5_o,
    output logic         tcdm_addr_p3_6_o,
    output logic         tcdm_addr_p3_7_o,
    output logic         tcdm_addr_p3_8_o,
    output logic         tcdm_addr_p3_9_o,
    output logic         tcdm_addr_p3_10_o,
    output logic         tcdm_addr_p3_11_o,
    output logic         tcdm_addr_p3_12_o,
    output logic         tcdm_addr_p3_13_o,
    output logic         tcdm_addr_p3_14_o,
    output logic         tcdm_addr_p3_15_o,
    output logic         tcdm_addr_p3_16_o,
    output logic         tcdm_addr_p3_17_o,
    output logic         tcdm_addr_p3_18_o,
    output logic         tcdm_addr_p3_19_o,
    output logic         tcdm_wen_p3_o,
    output logic         tcdm_wdata_p3_0_o,
    output logic         tcdm_wdata_p3_1_o,
    output logic         tcdm_wdata_p3_2_o,
    output logic         tcdm_wdata_p3_3_o,
    output logic         tcdm_wdata_p3_4_o,
    output logic         tcdm_wdata_p3_5_o,
    output logic         tcdm_wdata_p3_6_o,
    output logic         tcdm_wdata_p3_7_o,
    output logic         tcdm_wdata_p3_8_o,
    output logic         tcdm_wdata_p3_9_o,
    output logic         tcdm_wdata_p3_10_o,
    output logic         tcdm_wdata_p3_11_o,
    output logic         tcdm_wdata_p3_12_o,
    output logic         tcdm_wdata_p3_13_o,
    output logic         tcdm_wdata_p3_14_o,
    output logic         tcdm_wdata_p3_15_o,
    output logic         tcdm_wdata_p3_16_o,
    output logic         tcdm_wdata_p3_17_o,
    output logic         tcdm_wdata_p3_18_o,
    output logic         tcdm_wdata_p3_19_o,
    output logic         tcdm_wdata_p3_20_o,
    output logic         tcdm_wdata_p3_21_o,
    output logic         tcdm_wdata_p3_22_o,
    output logic         tcdm_wdata_p3_23_o,
    output logic         tcdm_wdata_p3_24_o,
    output logic         tcdm_wdata_p3_25_o,
    output logic         tcdm_wdata_p3_26_o,
    output logic         tcdm_wdata_p3_27_o,
    output logic         tcdm_wdata_p3_28_o,
    output logic         tcdm_wdata_p3_29_o,
    output logic         tcdm_wdata_p3_30_o,
    output logic         tcdm_wdata_p3_31_o,
    input  logic         tcdm_r_rdata_p3_0_i,
    input  logic         tcdm_r_rdata_p3_1_i,
    input  logic         tcdm_r_rdata_p3_2_i,
    input  logic         tcdm_r_rdata_p3_3_i,
    input  logic         tcdm_r_rdata_p3_4_i,
    input  logic         tcdm_r_rdata_p3_5_i,
    input  logic         tcdm_r_rdata_p3_6_i,
    input  logic         tcdm_r_rdata_p3_7_i,
    input  logic         tcdm_r_rdata_p3_8_i,
    input  logic         tcdm_r_rdata_p3_9_i,
    input  logic         tcdm_r_rdata_p3_10_i,
    input  logic         tcdm_r_rdata_p3_11_i,
    input  logic         tcdm_r_rdata_p3_12_i,
    input  logic         tcdm_r_rdata_p3_13_i,
    input  logic         tcdm_r_rdata_p3_14_i,
    input  logic         tcdm_r_rdata_p3_15_i,
    input  logic         tcdm_r_rdata_p3_16_i,
    input  logic         tcdm_r_rdata_p3_17_i,
    input  logic         tcdm_r_rdata_p3_18_i,
    input  logic         tcdm_r_rdata_p3_19_i,
    input  logic         tcdm_r_rdata_p3_20_i,
    input  logic         tcdm_r_rdata_p3_21_i,
    input  logic         tcdm_r_rdata_p3_22_i,
    input  logic         tcdm_r_rdata_p3_23_i,
    input  logic         tcdm_r_rdata_p3_24_i,
    input  logic         tcdm_r_rdata_p3_25_i,
    input  logic         tcdm_r_rdata_p3_26_i,
    input  logic         tcdm_r_rdata_p3_27_i,
    input  logic         tcdm_r_rdata_p3_28_i,
    input  logic         tcdm_r_rdata_p3_29_i,
    input  logic         tcdm_r_rdata_p3_30_i,
    input  logic         tcdm_r_rdata_p3_31_i,
    output logic         tcdm_be_p3_0_o,
    output logic         tcdm_be_p3_1_o,
    output logic         tcdm_be_p3_2_o,
    output logic         tcdm_be_p3_3_o,
    input  logic         tcdm_gnt_p3_i,
    input  logic         tcdm_r_valid_p3_i,

    input  logic         apb_hwce_psel_i,
    input  logic         apb_hwce_enable_i,
    input  logic         apb_hwce_pwrite_i,
    input  logic         apb_hwce_addr_0_i,
    input  logic         apb_hwce_addr_1_i,
    input  logic         apb_hwce_addr_2_i,
    input  logic         apb_hwce_addr_3_i,
    input  logic         apb_hwce_addr_4_i,
    input  logic         apb_hwce_addr_5_i,
    input  logic         apb_hwce_addr_6_i,

    output logic         apb_hwce_prdata_0_o,
    output logic         apb_hwce_prdata_1_o,
    output logic         apb_hwce_prdata_2_o,
    output logic         apb_hwce_prdata_3_o,
    output logic         apb_hwce_prdata_4_o,
    output logic         apb_hwce_prdata_5_o,
    output logic         apb_hwce_prdata_6_o,
    output logic         apb_hwce_prdata_7_o,
    output logic         apb_hwce_prdata_8_o,
    output logic         apb_hwce_prdata_9_o,
    output logic         apb_hwce_prdata_10_o,
    output logic         apb_hwce_prdata_11_o,
    output logic         apb_hwce_prdata_12_o,
    output logic         apb_hwce_prdata_13_o,
    output logic         apb_hwce_prdata_14_o,
    output logic         apb_hwce_prdata_15_o,
    output logic         apb_hwce_prdata_16_o,
    output logic         apb_hwce_prdata_17_o,
    output logic         apb_hwce_prdata_18_o,
    output logic         apb_hwce_prdata_19_o,
    output logic         apb_hwce_prdata_20_o,
    output logic         apb_hwce_prdata_21_o,
    output logic         apb_hwce_prdata_22_o,
    output logic         apb_hwce_prdata_23_o,
    output logic         apb_hwce_prdata_24_o,
    output logic         apb_hwce_prdata_25_o,
    output logic         apb_hwce_prdata_26_o,
    output logic         apb_hwce_prdata_27_o,
    output logic         apb_hwce_prdata_28_o,
    output logic         apb_hwce_prdata_29_o,
    output logic         apb_hwce_prdata_30_o,
    output logic         apb_hwce_prdata_31_o,

    input  logic         apb_hwce_pwdata_0_i,
    input  logic         apb_hwce_pwdata_1_i,
    input  logic         apb_hwce_pwdata_2_i,
    input  logic         apb_hwce_pwdata_3_i,
    input  logic         apb_hwce_pwdata_4_i,
    input  logic         apb_hwce_pwdata_5_i,
    input  logic         apb_hwce_pwdata_6_i,
    input  logic         apb_hwce_pwdata_7_i,
    input  logic         apb_hwce_pwdata_8_i,
    input  logic         apb_hwce_pwdata_9_i,
    input  logic         apb_hwce_pwdata_10_i,
    input  logic         apb_hwce_pwdata_11_i,
    input  logic         apb_hwce_pwdata_12_i,
    input  logic         apb_hwce_pwdata_13_i,
    input  logic         apb_hwce_pwdata_14_i,
    input  logic         apb_hwce_pwdata_15_i,
    input  logic         apb_hwce_pwdata_16_i,
    input  logic         apb_hwce_pwdata_17_i,
    input  logic         apb_hwce_pwdata_18_i,
    input  logic         apb_hwce_pwdata_19_i,
    input  logic         apb_hwce_pwdata_20_i,
    input  logic         apb_hwce_pwdata_21_i,
    input  logic         apb_hwce_pwdata_22_i,
    input  logic         apb_hwce_pwdata_23_i,
    input  logic         apb_hwce_pwdata_24_i,
    input  logic         apb_hwce_pwdata_25_i,
    input  logic         apb_hwce_pwdata_26_i,
    input  logic         apb_hwce_pwdata_27_i,
    input  logic         apb_hwce_pwdata_28_i,
    input  logic         apb_hwce_pwdata_29_i,
    input  logic         apb_hwce_pwdata_30_i,
    input  logic         apb_hwce_pwdata_31_i,

    output logic         apb_hwce_ready_o,

    output logic         gpio_oe_0_o,
    output logic         gpio_data_0_o,
    input  logic         gpio_data_0_i,
    output logic         gpio_oe_1_o,
    output logic         gpio_data_1_o,
    input  logic         gpio_data_1_i,
    output logic         gpio_oe_2_o,
    output logic         gpio_data_2_o,
    input  logic         gpio_data_2_i,
    output logic         gpio_oe_3_o,
    output logic         gpio_data_3_o,
    input  logic         gpio_data_3_i,
    output logic         gpio_oe_4_o,
    output logic         gpio_data_4_o,
    input  logic         gpio_data_4_i,
    output logic         gpio_oe_5_o,
    output logic         gpio_data_5_o,
    input  logic         gpio_data_5_i,
    output logic         gpio_oe_6_o,
    output logic         gpio_data_6_o,
    input  logic         gpio_data_6_i,
    output logic         gpio_oe_7_o,
    output logic         gpio_data_7_o,
    input  logic         gpio_data_7_i,
    output logic         gpio_oe_8_o,
    output logic         gpio_data_8_o,
    input  logic         gpio_data_8_i,
    output logic         gpio_oe_9_o,
    output logic         gpio_data_9_o,
    input  logic         gpio_data_9_i,
    output logic         gpio_oe_10_o,
    output logic         gpio_data_10_o,
    input  logic         gpio_data_10_i,
    output logic         gpio_oe_11_o,
    output logic         gpio_data_11_o,
    input  logic         gpio_data_11_i,
    output logic         gpio_oe_12_o,
    output logic         gpio_data_12_o,
    input  logic         gpio_data_12_i,
    output logic         gpio_oe_13_o,
    output logic         gpio_data_13_o,
    input  logic         gpio_data_13_i,
    output logic         gpio_oe_14_o,
    output logic         gpio_data_14_o,
    input  logic         gpio_data_14_i,
    output logic         gpio_oe_15_o,
    output logic         gpio_data_15_o,
    input  logic         gpio_data_15_i,
    output logic         gpio_oe_16_o,
    output logic         gpio_data_16_o,
    input  logic         gpio_data_16_i,
    output logic         gpio_oe_17_o,
    output logic         gpio_data_17_o,
    input  logic         gpio_data_17_i,
    output logic         gpio_oe_18_o,
    output logic         gpio_data_18_o,
    input  logic         gpio_data_18_i,
    output logic         gpio_oe_19_o,
    output logic         gpio_data_19_o,
    input  logic         gpio_data_19_i,
    output logic         gpio_oe_20_o,
    output logic         gpio_data_20_o,
    input  logic         gpio_data_20_i,
    output logic         gpio_oe_21_o,
    output logic         gpio_data_21_o,
    input  logic         gpio_data_21_i,
    output logic         gpio_oe_22_o,
    output logic         gpio_data_22_o,
    input  logic         gpio_data_22_i,
    output logic         gpio_oe_23_o,
    output logic         gpio_data_23_o,
    input  logic         gpio_data_23_i,
    output logic         gpio_oe_24_o,
    output logic         gpio_data_24_o,
    input  logic         gpio_data_24_i,
    output logic         gpio_oe_25_o,
    output logic         gpio_data_25_o,
    input  logic         gpio_data_25_i,
    output logic         gpio_oe_26_o,
    output logic         gpio_data_26_o,
    input  logic         gpio_data_26_i,
    output logic         gpio_oe_27_o,
    output logic         gpio_data_27_o,
    input  logic         gpio_data_27_i,
    output logic         gpio_oe_28_o,
    output logic         gpio_data_28_o,
    input  logic         gpio_data_28_i,
    output logic         gpio_oe_29_o,
    output logic         gpio_data_29_o,
    input  logic         gpio_data_29_i,
    output logic         gpio_oe_30_o,
    output logic         gpio_data_30_o,
    input  logic         gpio_data_30_i,
    output logic         gpio_oe_31_o,
    output logic         gpio_data_31_o,
    input  logic         gpio_data_31_i,
    output logic         gpio_oe_32_o,
    output logic         gpio_data_32_o,
    input  logic         gpio_data_32_i,
    output logic         gpio_oe_33_o,
    output logic         gpio_data_33_o,
    input  logic         gpio_data_33_i,
    output logic         gpio_oe_34_o,
    output logic         gpio_data_34_o,
    input  logic         gpio_data_34_i,
    output logic         gpio_oe_35_o,
    output logic         gpio_data_35_o,
    input  logic         gpio_data_35_i,
    output logic         gpio_oe_36_o,
    output logic         gpio_data_36_o,
    input  logic         gpio_data_36_i,
    output logic         gpio_oe_37_o,
    output logic         gpio_data_37_o,
    input  logic         gpio_data_37_i,
    output logic         gpio_oe_38_o,
    output logic         gpio_data_38_o,
    input  logic         gpio_data_38_i,
    output logic         gpio_oe_39_o,
    output logic         gpio_data_39_o,
    input  logic         gpio_data_39_i,
    output logic         gpio_oe_40_o,
    output logic         gpio_data_40_o,
    input  logic         gpio_data_40_i,

    output logic         events_0_o,
    output logic         events_1_o,
    output logic         events_2_o,
    output logic         events_3_o,
    output logic         events_4_o,
    output logic         events_5_o,
    output logic         events_6_o,
    output logic         events_7_o,
    output logic         events_8_o,
    output logic         events_9_o,
    output logic         events_10_o,
    output logic         events_11_o,
    output logic         events_12_o,
    output logic         events_13_o,
    output logic         events_14_o,
    output logic         events_15_o,


    output logic          MU0_EFPGA2MATHB_CLK,
    output logic          MU0_EFPGA_MATHB_CLK_EN,

    output logic          MU0_EFPGA_MATHB_OPER_DATA_0_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_1_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_2_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_3_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_4_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_5_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_6_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_7_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_8_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_9_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_10_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_11_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_12_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_13_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_14_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_15_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_16_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_17_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_18_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_19_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_20_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_21_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_22_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_23_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_24_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_25_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_26_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_27_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_28_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_29_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_30_,
    output logic          MU0_EFPGA_MATHB_OPER_DATA_31_,

    output logic          MU0_EFPGA_MATHB_OPER_SEL,

    output logic          MU0_EFPGA_MATHB_OPER_defPin_1_,
    output logic          MU0_EFPGA_MATHB_OPER_defPin_0_,

    output logic          MU0_EFPGA_MATHB_COEF_DATA_0_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_1_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_2_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_3_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_4_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_5_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_6_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_7_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_8_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_9_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_10_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_11_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_12_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_13_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_14_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_15_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_16_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_17_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_18_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_19_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_20_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_21_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_22_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_23_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_24_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_25_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_26_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_27_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_28_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_29_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_30_,
    output logic          MU0_EFPGA_MATHB_COEF_DATA_31_,

    output logic          MU0_EFPGA_MATHB_COEF_SEL,

    output logic          MU0_EFPGA_MATHB_COEF_defPin_1_,
    output logic          MU0_EFPGA_MATHB_COEF_defPin_0_,

    output logic          MU0_EFPGA_MATHB_DATAOUT_SEL_0_,
    output logic          MU0_EFPGA_MATHB_DATAOUT_SEL_1_,

    output logic          MU0_EFPGA_MATHB_MAC_ACC_CLEAR,

    output logic          MU0_EFPGA_MATHB_MAC_ACC_RND,
    output logic          MU0_EFPGA_MATHB_MAC_ACC_SAT,

    output logic          MU0_EFPGA_MATHB_MAC_OUT_SEL_0_,
    output logic          MU0_EFPGA_MATHB_MAC_OUT_SEL_1_,
    output logic          MU0_EFPGA_MATHB_MAC_OUT_SEL_2_,
    output logic          MU0_EFPGA_MATHB_MAC_OUT_SEL_3_,
    output logic          MU0_EFPGA_MATHB_MAC_OUT_SEL_4_,
    output logic          MU0_EFPGA_MATHB_MAC_OUT_SEL_5_,

    output logic          MU0_EFPGA_MATHB_TC_defPin,

    input  logic          MU0_MATHB_EFPGA_MAC_OUT_0_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_1_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_2_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_3_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_4_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_5_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_6_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_7_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_8_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_9_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_10_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_11_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_12_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_13_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_14_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_15_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_16_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_17_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_18_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_19_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_20_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_21_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_22_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_23_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_24_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_25_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_26_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_27_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_28_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_29_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_30_,
    input  logic          MU0_MATHB_EFPGA_MAC_OUT_31_,

    output logic          MU1_EFPGA2MATHB_CLK,
    output logic          MU1_EFPGA_MATHB_CLK_EN,

    output logic          MU1_EFPGA_MATHB_OPER_DATA_0_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_1_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_2_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_3_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_4_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_5_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_6_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_7_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_8_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_9_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_10_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_11_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_12_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_13_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_14_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_15_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_16_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_17_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_18_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_19_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_20_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_21_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_22_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_23_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_24_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_25_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_26_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_27_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_28_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_29_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_30_,
    output logic          MU1_EFPGA_MATHB_OPER_DATA_31_,

    output logic          MU1_EFPGA_MATHB_OPER_SEL,

    output logic          MU1_EFPGA_MATHB_OPER_defPin_1_,
    output logic          MU1_EFPGA_MATHB_OPER_defPin_0_,

    output logic          MU1_EFPGA_MATHB_COEF_DATA_0_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_1_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_2_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_3_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_4_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_5_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_6_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_7_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_8_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_9_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_10_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_11_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_12_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_13_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_14_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_15_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_16_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_17_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_18_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_19_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_20_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_21_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_22_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_23_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_24_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_25_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_26_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_27_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_28_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_29_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_30_,
    output logic          MU1_EFPGA_MATHB_COEF_DATA_31_,

    output logic          MU1_EFPGA_MATHB_COEF_SEL,

    output logic          MU1_EFPGA_MATHB_COEF_defPin_1_,
    output logic          MU1_EFPGA_MATHB_COEF_defPin_0_,

    output logic          MU1_EFPGA_MATHB_DATAOUT_SEL_0_,
    output logic          MU1_EFPGA_MATHB_DATAOUT_SEL_1_,

    output logic          MU1_EFPGA_MATHB_MAC_ACC_CLEAR,

    output logic          MU1_EFPGA_MATHB_MAC_ACC_RND,
    output logic          MU1_EFPGA_MATHB_MAC_ACC_SAT,

    output logic          MU1_EFPGA_MATHB_MAC_OUT_SEL_0_,
    output logic          MU1_EFPGA_MATHB_MAC_OUT_SEL_1_,
    output logic          MU1_EFPGA_MATHB_MAC_OUT_SEL_2_,
    output logic          MU1_EFPGA_MATHB_MAC_OUT_SEL_3_,
    output logic          MU1_EFPGA_MATHB_MAC_OUT_SEL_4_,
    output logic          MU1_EFPGA_MATHB_MAC_OUT_SEL_5_,

    output logic          MU1_EFPGA_MATHB_TC_defPin,

    input  logic          MU1_MATHB_EFPGA_MAC_OUT_0_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_1_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_2_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_3_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_4_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_5_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_6_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_7_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_8_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_9_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_10_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_11_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_12_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_13_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_14_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_15_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_16_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_17_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_18_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_19_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_20_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_21_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_22_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_23_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_24_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_25_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_26_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_27_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_28_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_29_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_30_,
    input  logic          MU1_MATHB_EFPGA_MAC_OUT_31_



);


    logic [31:0] apb_pwdata;
    logic [ 6:0] apb_hwce_addr;
    logic [31:0] apb_hwce_prdata;

    logic [2:0] iir_counter_n, iir_counter_q;
    logic [2:0] xindex0, xindex1, yindex0, yindex1;

    logic [19:0] read_address_q;
    logic [19:0] real_address3, real_address2, real_address1, real_address0;
    logic [19:0] store_address_q;
    logic [ 3:0] tcdm_be;
    logic        start_q,done_q;
    logic [14:0] sw_event_q;

    logic is_tcdm_address_read, is_tcdm_address_store, is_coef, is_start;
    logic is_done, is_num_elem;
    logic is_configuration_sel;
    logic is_gpio_rego_l_val, is_gpio_rego_h_val;
    logic is_gpio_rego_l_oe, is_gpio_rego_h_oe;
    logic is_gpio_sample_regi;
    logic is_sw_event_sel;
    logic is_coef_a0a1;
    logic is_coef_a2a3;
    logic is_coef_a4b0;
    logic is_coef_b1b2;
    logic is_coef_b3b4;
    logic is_constant, ff1, ff0;
    logic start_read0, start_read1, start_read2, start_read3, start_write1;
    logic write0, write1, write2, write3;
    logic store_data0, store_data1, store_data2, store_data3, store_data4;
    logic make_shuffle, is_reset_data_store;

    logic ld_st_ack, mac_load_ready, mac_ack ;
    logic [1:0] ld_st_counter_q;
    logic [2:0] ld_st_counter_n;
    logic incaddr_read, incaddr_write;
    logic data_valid0, data_valid1, data_valid2, data_valid3, all_data_valid;
    logic [3:0] data_valid;
    logic [3:0] address_offset0, address_offset1, address_offset2, address_offset3;

    logic [15:0] coef_a0_q, coef_a1_q, coef_a2_q, coef_a3_q, coef_a4_q, coef_b0_q, coef_b1_q, coef_b2_q, coef_b3_q, coef_b4_q;

    logic reset_accumulator, reset_accumulator_q, reset_data_valid;
    logic increase_counter_shuffle, reset_counter_shuffle;
    logic [3:0] counter_shuffle;
    logic [3:0] sel_counter;
    logic [1:0] index3, index2, index1, index0;

    logic [15:0] num_elem_q, num_elem_n, num_elem_st_q, num_elem_st_n;
    logic last_iteration, store_num_elem, store_num_elem_st, store_mac0, store_mac1;
    logic store_mac0q, store_mac1q;

    logic [31:0] data_read[4:0];
    logic [31:0] data_store[4:0];
    logic [31:0] mac_result[1:0];

    logic [31:0] tcdm_r_rdata_p0, tcdm_r_rdata_p1, tcdm_r_rdata_p2, tcdm_r_rdata_p3;

    logic [31:0] result0, result1, selected_data_mac0, selected_data_mac1, selected_coef_mac;
    logic [40:0] gpio_oe_reg;
    logic [40:0] gpio_val_reg;
    logic [40:0] gpio_in;

    logic [15:0] configuration_sel;
    logic [4:0] read_addr_inc, store_addr_inc;

    logic [31:0] data_to_store;
    logic [15:0] result_h, result_l;


    logic mac_load_ready_clean, ld_ready, st_ready, load_write, mac_load_ready_q, load_read, ld_ready_q;
    logic mac_store_ready_clean, mac_store_ready_q, mac_store_ready, ld_ready_clean, st_ready_clean;
    logic st_ready_q;

    `define MODE8  2'b11
    `define MODE16 2'b10
    `define MODE32 2'b01

    enum logic [1:0] {READ_IDLE, READ_FIRST_TIME, READ_NEXT,READ_END} state_read_n, state_read_q;
    enum logic       {WAIT_STORE, STORE_RESULT} state_write_n, state_write_q;
    enum logic [2:0] {IDLE, MAC0, MAC1_5, STORE_MAC0, WAIT_MAC1, WAIT_MAC2, ADD_MAC1, ADD_SHUFFLE} state_mac_n, state_mac_q;


    assign apb_hwce_addr = { apb_hwce_addr_6_i,
                             apb_hwce_addr_5_i,
                             apb_hwce_addr_4_i,
                             apb_hwce_addr_3_i,
                             apb_hwce_addr_2_i,
                             apb_hwce_addr_1_i,
                             apb_hwce_addr_0_i };




    assign apb_hwce_ready_o = 1'b1; //pragma attribute apb_hwce_ready_o pad out_buff

    assign tcdm_be_p0_0_o   = tcdm_be[0];
    assign tcdm_be_p0_1_o   = tcdm_be[1];
    assign tcdm_be_p0_2_o   = tcdm_be[2];
    assign tcdm_be_p0_3_o   = tcdm_be[3];
    assign tcdm_wen_p0_o    = ff1;

    assign tcdm_be_p1_0_o   = tcdm_be[0];
    assign tcdm_be_p1_1_o   = tcdm_be[1];
    assign tcdm_be_p1_2_o   = tcdm_be[2];
    assign tcdm_be_p1_3_o   = tcdm_be[3];
    assign tcdm_wen_p1_o    = ~write1;

    assign tcdm_be_p2_0_o   = tcdm_be[0];
    assign tcdm_be_p2_1_o   = tcdm_be[1];
    assign tcdm_be_p2_2_o   = tcdm_be[2];
    assign tcdm_be_p2_3_o   = tcdm_be[3];
    assign tcdm_wen_p2_o    = ff1;

    assign tcdm_be_p3_0_o   = tcdm_be[0];
    assign tcdm_be_p3_1_o   = tcdm_be[1];
    assign tcdm_be_p3_2_o   = tcdm_be[2];
    assign tcdm_be_p3_3_o   = tcdm_be[3];
    assign tcdm_wen_p3_o    = ff1;


    assign all_data_valid = data_valid[0] & data_valid[1] & data_valid[2] & data_valid[3];

    assign last_iteration = num_elem_q == 0;

    /*  SHUFFLE */
    always_comb
    begin

        xindex0 = iir_counter_q[2:0];
        xindex1 = xindex0 + 1;

        yindex0 = xindex0[2:0] - 3;
        yindex1 = yindex0 + 1;
        selected_data_mac0 = data_read[xindex0];
        selected_data_mac1 = {data_read[xindex1][15:0], data_read[xindex0][31:16]};
        selected_coef_mac  = {coef_b3_q, coef_b4_q};

        case(iir_counter_q[2:0])

            3'b000:  begin

                //counter_shuffle = 0
                /*
                    xindex0 = 0
                    MAC0: x0*b4 | x1*b3
                    MAC1: x1*b4 | x2*b3
                */

                selected_data_mac0 = data_read[xindex0];
                selected_data_mac1 = {data_read[xindex1][15:0], data_read[xindex0][31:16]};
                selected_coef_mac  = {coef_b3_q, coef_b4_q};
            end

            3'b001:  begin

                //counter_shuffle = 0
                /*
                    xindex0 = 1
                    MAC0: x2*b2 | x3*b1
                    MAC1: x3*b2 | x4*b1
                */

                selected_data_mac0 = data_read[xindex0];
                selected_data_mac1 = {data_read[xindex1][15:0], data_read[xindex0][31:16]};
                selected_coef_mac  = {coef_b1_q, coef_b2_q};
            end

            3'b010:  begin

                //counter_shuffle = 0
                /*
                    xindex0 = 2
                    MAC0: x4*b0 | 1*a0
                    MAC1: x5*b0 | 1*a0
                */

                selected_data_mac0 = {16'b01, data_read[xindex0][15:0]};
                selected_data_mac1 = {16'b01, data_read[xindex0][31:16]};
                selected_coef_mac  = {coef_a0_q, coef_b0_q};
            end

            3'b011:  begin

                //counter_shuffle = 0
                /*
                    xindex0 = 3, yindex0 = 0
                    MAC0: y0*a4 | y1*a3
                    MAC1: y1*a4 | y2*a3
                */

                selected_data_mac0 = data_store[yindex0];
                selected_data_mac1 = {data_store[yindex1][15:0], data_store[yindex0][31:16]};
                selected_coef_mac  = {coef_a3_q, coef_a4_q};
            end

            3'b100:  begin

                //counter_shuffle = 0
                /*
                    xindex0 = 4, yindex0 = 1
                    MAC0: y2*a2 | y3*a1
                    MAC1: y3*a2 | 0*a1
                */

                selected_data_mac0 = data_store[yindex0];
                selected_data_mac1 = {16'b0, data_store[yindex0][31:16]};
                selected_coef_mac  = {coef_a1_q, coef_a2_q};
            end

            3'b101:  begin

                //counter_shuffle = 0
                /*
                    xindex0 = 5, yindex0 = 2
                    MAC0: - | -
                    MAC1: y4*a1 | 0*a1
                */

                selected_data_mac0 = data_store[yindex0]; //default assignemt
                selected_data_mac1 = {16'b0, data_store[yindex0][15:0]};
                selected_coef_mac  = {coef_a1_q, coef_a1_q};
            end

            default:;
        endcase

    end


/*
    READ FSM
*/
    always_comb
    begin

        state_read_n                                                      = state_read_q;
        {start_read0, start_read1, start_read2, start_read3}              = 4'b0000;
        incaddr_read                                                      = 1'b0;
        address_offset0                                                   = 0;
        address_offset1                                                   = 4;
        address_offset2                                                   = 8;
        address_offset3                                                   = 12;
        reset_data_valid                                                  = 1'b0;
        store_num_elem                                                    = 1'b0;
        {store_data0, store_data1, store_data2, store_data3, store_data4} = 5'b0;
        num_elem_n                                                        = num_elem_q;
        read_addr_inc                                                     = 16;
        mac_load_ready_clean                                              = 1'b0;
        write0                                                            = 1'b0;
        write1                                                            = 1'b1;
        write2                                                            = 1'b0;
        write3                                                            = 1'b0;
        ld_ready                                                          = 1'b0;

        unique case(state_read_q)

            READ_IDLE:
            begin
                if(start_q) begin
                    state_read_n          = READ_FIRST_TIME;
                    reset_data_valid      = 1'b1;
                end
            end

            //it requires minim 5 reads so 4+4+4+4+4 = 20 elements
            READ_FIRST_TIME:
            begin
                {start_read0, start_read1, start_read2, start_read3}              = ~{data_valid[0], data_valid[1], data_valid[2], data_valid[3]};
                reset_data_valid                                                  = all_data_valid;
                num_elem_n                                                        = num_elem_q - 8;
                store_num_elem                                                    = all_data_valid;
                {store_data0, store_data1, store_data2, store_data3, store_data4} = {data_valid0, data_valid1, data_valid2, data_valid3, 1'b0};
                incaddr_read                                                      = all_data_valid;
                state_read_n                                                      = all_data_valid ? READ_NEXT :  state_read_q;
                ld_ready                                                          = all_data_valid;
                write1                                                            = 1'b0;
            end

            READ_NEXT:
            begin
                start_read0                                                      = ~data_valid[0] && mac_load_ready_q;
                mac_load_ready_clean                                             = mac_load_ready_q;
                state_read_n                                                     = data_valid0 && last_iteration ? READ_END :  state_read_q;
                reset_data_valid                                                 = data_valid0;
                num_elem_n                                                       = num_elem_q - 2;
                store_num_elem                                                   = data_valid0;
                store_data4                                                      = data_valid0;
                incaddr_read                                                     = data_valid0;
                read_addr_inc                                                    = 4;
                ld_ready                                                         = data_valid0;
            end

            READ_END:
            begin
                if(~start_q) begin
                    state_read_n          = READ_IDLE;
                end
            end

            default: begin end

        endcase
    end


/*
    WRITE FSM
*/
    always_comb
    begin

        state_write_n         = state_write_q;
        start_write1          = 1'b0;
        incaddr_write         = 1'b0;
        store_addr_inc        = 4;
        st_ready              = 1'b0;
        mac_store_ready_clean = 1'b0;

        unique case(state_write_q)

            WAIT_STORE:
            begin
                st_ready    = ~done_q;
                if(mac_store_ready_q && ~done_q) begin
                    state_write_n         = STORE_RESULT;
                    start_write1          = 1'b1;
                    mac_store_ready_clean = 1'b1;
                end
            end

            STORE_RESULT:
            begin
                state_write_n             = data_valid1 ? WAIT_STORE :  state_write_q;
                incaddr_write             = data_valid1;
            end

            default: begin end

        endcase
    end

/*
    IIR FSM
*/
    always_comb
    begin

        reset_accumulator                = 1'b1;
        store_mac0                       = 1'b0;
        store_mac1                       = 1'b0;
        increase_counter_shuffle         = 1'b0;
        iir_counter_n                    = iir_counter_q;
        reset_counter_shuffle            = 1'b0;
        mac_load_ready                   = 1'b0;
        mac_store_ready                  = 1'b0;
        ld_ready_clean                   = 1'b0;
        st_ready_clean                   = 1'b0;
        state_mac_n                      = state_mac_q;
        make_shuffle                     = 1'b0;
        store_num_elem_st                = 1'b0;
        num_elem_st_n                    = num_elem_st_q - 2;

        unique case(state_mac_q)

            IDLE:
            begin
                mac_load_ready            = 1'b1;
                if(ld_ready_q) begin
                    state_mac_n           = MAC1_5;
                    reset_counter_shuffle = 1'b1;
                    ld_ready_clean        = 1'b1;
                end
            end

            MAC0:
            begin
                reset_accumulator     = 1'b0;
                mac_load_ready        = 1'b1;
                state_mac_n           = MAC1_5;
                iir_counter_n         = iir_counter_q + 1;
            end

            MAC1_5:
            begin
               reset_accumulator                 = iir_counter_q[2:0] == 4;
               iir_counter_n                     = iir_counter_q + 1;
               if(reset_accumulator) begin
                  state_mac_n                    = STORE_MAC0;
               end

            end

            STORE_MAC0:
            //here we actually get from the multiplier y4
            begin
               state_mac_n                      = ADD_MAC1;
            end

            ADD_MAC1:
            //here we actually get from y4*a1
            begin
                store_mac0                       = 1'b1;
                state_mac_n                      = WAIT_MAC1;
            end

            WAIT_MAC1:
            //wat 1 cycle to have y5 ready at the next one in result1
            begin
                state_mac_n                      = WAIT_MAC2;
                iir_counter_n                    = '0;
            end

            WAIT_MAC2:
            //wat 1 cycle to have y5 ready at the next one in result1
            begin
                state_mac_n                      = ADD_SHUFFLE;
            end

            ADD_SHUFFLE:
            begin
                if(~start_q) begin
                    state_mac_n = IDLE;
                end else begin
                    if(st_ready_q && ld_ready_q) begin
                        mac_store_ready                  = 1'b1;
                        increase_counter_shuffle         = 1'b1;
                        make_shuffle                     = 1'b1;
                        state_mac_n                      = MAC0;
                        ld_ready_clean                   = 1'b1;
                        st_ready_clean                   = 1'b1;
                        store_num_elem_st                = 1'b1;
                    end
                    else if (state_read_q == READ_END && st_ready_q) begin
                        //finish loading
                        mac_store_ready                  = 1'b1;
                        increase_counter_shuffle         = 1'b1;
                        make_shuffle                     = 1'b1;
                        state_mac_n                      = MAC0;
                        st_ready_clean                   = 1'b1;
                        store_num_elem_st                = 1'b1;
                    end
                end
            end

            default: begin end

        endcase
    end

    //sync with the multiplier as the signal `mac_store_ready` guarantees this
    assign data_to_store  = data_store[1];

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(~rst_ni) begin
            st_ready_q        <= 1'b0;
            mac_store_ready_q <= 1'b0;
            ld_ready_q        <= 1'b0;
            mac_load_ready_q  <= 1'b0;
        end else begin

            if(st_ready)
                st_ready_q <= 1'b1;
            else if (~st_ready && st_ready_clean)
                st_ready_q <= 1'b0;

            if(ld_ready)
                ld_ready_q <= 1'b1;
            else if (~ld_ready && ld_ready_clean)
                ld_ready_q <= 1'b0;

            if(mac_store_ready)
                mac_store_ready_q <= 1'b1;
            else if (~mac_store_ready && mac_store_ready_clean)
                mac_store_ready_q <= 1'b0;

            if(mac_load_ready)
                mac_load_ready_q <= 1'b1;
            else if (~mac_load_ready && mac_load_ready_clean)
                mac_load_ready_q <= 1'b0;

            if(is_reset_data_store & apb_hwce_psel_i && apb_hwce_enable_i && apb_hwce_pwrite_i) begin
                st_ready_q        <= 1'b0;
                mac_store_ready_q <= 1'b0;
                ld_ready_q        <= 1'b0;
            end

        end
    end



    assign sel_counter[3:0] = {2'b0, iir_counter_q[1:0]} + counter_shuffle;


    tcdm_streamer tdcm0_str
    (
        .clk_i             (clk_i  ),
        .rst_ni            (rst_ni ),

        .tcdm_req_o        (tcdm_req_p0_o     ),
        .tcdm_gnt_i        (tcdm_gnt_p0_i     ),
        .tcdm_r_valid_i    (tcdm_r_valid_p0_i ),
        .start_i           (start_read0       ),
        .data_valid_o      (data_valid0       )
    );

    tcdm_streamer tdcm1_str
    (
        .clk_i             (clk_i  ),
        .rst_ni            (rst_ni ),

        .tcdm_req_o        (tcdm_req_p1_o     ),
        .tcdm_gnt_i        (tcdm_gnt_p1_i     ),
        .tcdm_r_valid_i    (tcdm_r_valid_p1_i ),
        .start_i           (start_read1 | start_write1 ),
        .data_valid_o      (data_valid1       )
    );

    tcdm_streamer tdcm2_str
    (
        .clk_i             (clk_i  ),
        .rst_ni            (rst_ni ),

        .tcdm_req_o        (tcdm_req_p2_o     ),
        .tcdm_gnt_i        (tcdm_gnt_p2_i     ),
        .tcdm_r_valid_i    (tcdm_r_valid_p2_i ),
        .start_i           (start_read2       ),
        .data_valid_o      (data_valid2       )
    );

    tcdm_streamer tdcm3_str
    (
        .clk_i             (clk_i  ),
        .rst_ni            (rst_ni ),

        .tcdm_req_o        (tcdm_req_p3_o     ),
        .tcdm_gnt_i        (tcdm_gnt_p3_i     ),
        .tcdm_r_valid_i    (tcdm_r_valid_p3_i ),
        .start_i           (start_read3       ),
        .data_valid_o      (data_valid3       )
    );




    assign real_address0 = address_offset0 + read_address_q;
    assign real_address1 = ( write1 ? store_address_q : read_address_q + address_offset1);
    assign real_address2 = address_offset2 + read_address_q;
    assign real_address3 = address_offset3 + read_address_q;

    assign result_h = data_store[2][31:16] + result1[15:0];
    assign result_l = data_store[2][15:0];

    logic [1:0] mac_res_sel;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(~rst_ni) begin
            read_address_q                     <= '0;
            store_address_q                    <= '0;

            ff0                                <= 1'b0;
            ff1                                <= 1'b1;

            {coef_a1_q, coef_a0_q}             <= '0;
            {coef_a3_q, coef_a2_q}             <= '0;
            {coef_a4_q, coef_b0_q}             <= '0;
            {coef_b2_q, coef_b1_q}             <= '0;
            {coef_b4_q, coef_b3_q}             <= '0;

            gpio_oe_reg                        <= '0;
            gpio_val_reg                       <= '0;
            sw_event_q                         <= '0;
            counter_shuffle                    <= '0;
            iir_counter_q                      <= '0;
            data_valid                         <= '0;
            configuration_sel                  <= '0;
            start_q                            <= 1'b0;
            done_q                             <= 1'b0;
            num_elem_q                         <= '0;
            num_elem_st_q                      <= '1;
            data_read[0]                       <= '0;
            data_read[1]                       <= '0;
            data_read[2]                       <= '0;
            data_read[3]                       <= '0;
            data_read[4]                       <= '0;
            data_store[0]                      <= '0;
            data_store[1]                      <= '0;
            data_store[2]                      <= '0;
            data_store[3]                      <= '0;
            data_store[4]                      <= '0;
            mac_result[0]                      <= '0;
            mac_result[1]                      <= '0;
            ld_st_counter_q                    <= '0;
            store_mac0q                        <= 1'b0;
            store_mac1q                        <= 1'b0;
            state_write_q                      <= WAIT_STORE;
            state_read_q                       <= READ_IDLE;
            state_mac_q                        <= IDLE;
            reset_accumulator_q                <= 1'b0;
            mac_res_sel                        <= 2'b0;
        end else begin

            if(incaddr_read)
                read_address_q     <= read_address_q + read_addr_inc;

            if(incaddr_write)
                store_address_q    <= store_address_q + store_addr_inc;

            if(increase_counter_shuffle)
                counter_shuffle <= counter_shuffle + 1;

            if(reset_counter_shuffle)
                counter_shuffle <= '0;

            if(store_num_elem)
                 num_elem_q <= num_elem_n;

            if(store_num_elem_st)
                 num_elem_st_q <= num_elem_st_n;

             reset_accumulator_q <= reset_accumulator;


            iir_counter_q <= iir_counter_n;
            store_mac0q   <= store_mac0;
            store_mac1q   <= store_mac1;

            ld_st_counter_q <= ld_st_counter_n[1:0];

            if(store_data3)
                data_read[3] <= tcdm_r_rdata_p3;
            if(store_data2)
                data_read[2] <= tcdm_r_rdata_p2;
            if(store_data1)
                data_read[1] <= tcdm_r_rdata_p1;
            if(store_data0)
                data_read[0] <= tcdm_r_rdata_p0;
            if(store_data4)
                data_read[4] <= tcdm_r_rdata_p0;

            if(store_mac0) begin
                data_store[2][15:0]  <= result0[31:16] + result0[15:0];
                data_store[2][31:16] <= result1[31:16] + result1[15:0];
            end

            if(make_shuffle) begin
               data_read[0]  <= data_read[1];
               data_read[1]  <= data_read[2];
               data_read[2]  <= data_read[3];
               data_read[3]  <= data_read[4];

               data_store[0] <= data_store[1];
               data_store[1] <= {result_h, result_l};
            end

            if(reset_data_valid)
                data_valid <= '0;
            else begin
                if(data_valid3)
                    data_valid[3] <= 1'b1;
                if(data_valid2)
                    data_valid[2] <= 1'b1;
                if(data_valid1)
                    data_valid[1] <= 1'b1;
                if(data_valid0)
                    data_valid[0] <= 1'b1;
            end

            if(num_elem_st_q == '0) begin
                done_q     <= 1'b1;
            end

            state_write_q  <= state_write_n;
            state_read_q   <= state_read_n;
            state_mac_q    <= state_mac_n;

            if(apb_hwce_psel_i && apb_hwce_enable_i && apb_hwce_pwrite_i) begin
                if(is_tcdm_address_read)
                  read_address_q     <= apb_pwdata[19:0];
                if(is_tcdm_address_store)
                  store_address_q     <= apb_pwdata[19:0];

                if(is_constant)
                    {ff0, ff1} <= apb_pwdata[1:0];

                if(is_coef_a0a1)
                  {coef_a1_q, coef_a0_q}  <= apb_pwdata[31:0];

                if(is_coef_a2a3)
                  {coef_a3_q, coef_a2_q}  <= apb_pwdata[31:0];

                if(is_coef_a4b0)
                  {coef_b0_q, coef_a4_q}  <= apb_pwdata[31:0];

                if(is_coef_b1b2)
                  {coef_b2_q, coef_b1_q}  <= apb_pwdata[31:0];

                if(is_coef_b3b4)
                  {coef_b4_q, coef_b3_q}  <= apb_pwdata[31:0];

                if(is_start)
                   start_q     <= apb_pwdata[0];
                if(is_done)
                   done_q      <= apb_pwdata[0];
                if(is_num_elem) begin
                   num_elem_q    <= {1'b0, apb_pwdata[14:0]};
                   num_elem_st_q <= {1'b0, apb_pwdata[14:0]} -4;
                end
                if(is_configuration_sel) begin
                    configuration_sel <= apb_pwdata[15:0];
                end
                if(is_sw_event_sel)
                    sw_event_q  <= apb_pwdata[16:2];
                if(is_gpio_rego_l_val)
                    gpio_val_reg[31:0]  <= apb_pwdata[31:0];
                if(is_gpio_rego_h_val)
                    gpio_val_reg[40:32] <= apb_pwdata[8:0];
                if(is_gpio_rego_l_oe)
                    gpio_oe_reg[31:0]   <= apb_pwdata[31:0];
                if(is_gpio_rego_h_oe)
                    gpio_oe_reg[40:32]   <= apb_pwdata[8:0];
                if(is_gpio_sample_regi)
                    gpio_val_reg  <= gpio_in[40:0];
                if(is_reset_data_store) begin
                    data_read[0]     <= '0;
                    data_read[1]     <= '0;
                    data_read[2]     <= '0;
                    data_read[3]     <= '0;
                    data_read[4]     <= '0;
                    data_store[0]    <= '0;
                    data_store[1]    <= '0;
                    data_store[2]    <= '0;
                    data_store[3]    <= '0;
                    data_store[4]    <= '0;
                end

            end

        end
    end

    //DECODER

    assign is_tcdm_address_read   = apb_hwce_addr == 7'h00;      //0x00
    assign is_tcdm_address_store  = apb_hwce_addr == 7'h01;      //0x04
//    assign is_coef                = apb_hwce_addr == 7'h02;      //0x08
    assign is_start               = apb_hwce_addr == 7'h03;      //0x0C

    assign is_done                = apb_hwce_addr == 7'h04;      //0x10
    assign is_num_elem            = apb_hwce_addr == 7'h05;      //0x14

    assign is_configuration_sel   = apb_hwce_addr == 7'h06;      //0x18

    assign is_sw_event_sel        = apb_hwce_addr == 7'h08;      //0x20

    assign is_gpio_rego_l_val     = apb_hwce_addr == 7'h09;      //0x24
    assign is_gpio_rego_h_val     = apb_hwce_addr == 7'h0A;      //0x28

    assign is_gpio_rego_l_oe      = apb_hwce_addr == 7'h0B;      //0x2C
    assign is_gpio_rego_h_oe      = apb_hwce_addr == 7'h0C;      //0x30

    assign is_gpio_sample_regi    = apb_hwce_addr == 7'h0D;      //0x34

    assign is_coef_a0a1           = apb_hwce_addr == 7'h10;      //0x40
    assign is_coef_a2a3           = apb_hwce_addr == 7'h11;      //0x44
    assign is_coef_a4b0           = apb_hwce_addr == 7'h12;      //0x48
    assign is_coef_b1b2           = apb_hwce_addr == 7'h13;      //0x4C
    assign is_coef_b3b4           = apb_hwce_addr == 7'h14;      //0x50

    assign is_reset_data_store    = apb_hwce_addr == 7'h15;      //0x54
    assign is_constant            = apb_hwce_addr == 7'h7F;


    always_comb
    begin
        apb_hwce_prdata = '0;
        if(apb_hwce_psel_i & apb_hwce_enable_i & ~apb_hwce_pwrite_i) begin


            if(is_tcdm_address_read)
                apb_hwce_prdata = $unsigned(read_address_q);
            else if(is_tcdm_address_store)
                apb_hwce_prdata = $unsigned(store_address_q);
//            else if(is_coef)
//                apb_hwce_prdata = $unsigned({coef3_q,coef2_q,coef1_q,coef0_q});
            else if(is_start)
                apb_hwce_prdata = $unsigned(start_q);
            else if(is_num_elem)
                apb_hwce_prdata = $unsigned(num_elem_q);
            else if(is_done)
                apb_hwce_prdata = $unsigned(done_q);
            else if(is_sw_event_sel)
                apb_hwce_prdata = $unsigned(sw_event_q);
            else if(is_constant)
                apb_hwce_prdata = {read_address_q[11:0], read_address_q};
            else
                apb_hwce_prdata = '0;
        end

    end

    assign events_1_o = done_q;

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
                        events_0_o
                        } =  sw_event_q;

    assign tcdm_wdata_p1_0_o   = data_to_store[0];
    assign tcdm_wdata_p1_1_o   = data_to_store[1];
    assign tcdm_wdata_p1_2_o   = data_to_store[2];
    assign tcdm_wdata_p1_3_o   = data_to_store[3];
    assign tcdm_wdata_p1_4_o   = data_to_store[4];
    assign tcdm_wdata_p1_5_o   = data_to_store[5];
    assign tcdm_wdata_p1_6_o   = data_to_store[6];
    assign tcdm_wdata_p1_7_o   = data_to_store[7];
    assign tcdm_wdata_p1_8_o   = data_to_store[8];
    assign tcdm_wdata_p1_9_o   = data_to_store[9];
    assign tcdm_wdata_p1_10_o  = data_to_store[10];
    assign tcdm_wdata_p1_11_o  = data_to_store[11];
    assign tcdm_wdata_p1_12_o  = data_to_store[12];
    assign tcdm_wdata_p1_13_o  = data_to_store[13];
    assign tcdm_wdata_p1_14_o  = data_to_store[14];
    assign tcdm_wdata_p1_15_o  = data_to_store[15];
    assign tcdm_wdata_p1_16_o  = data_to_store[16];
    assign tcdm_wdata_p1_17_o  = data_to_store[17];
    assign tcdm_wdata_p1_18_o  = data_to_store[18];
    assign tcdm_wdata_p1_19_o  = data_to_store[19];
    assign tcdm_wdata_p1_20_o  = data_to_store[20];
    assign tcdm_wdata_p1_21_o  = data_to_store[21];
    assign tcdm_wdata_p1_22_o  = data_to_store[22];
    assign tcdm_wdata_p1_23_o  = data_to_store[23];
    assign tcdm_wdata_p1_24_o  = data_to_store[24];
    assign tcdm_wdata_p1_25_o  = data_to_store[25];
    assign tcdm_wdata_p1_26_o  = data_to_store[26];
    assign tcdm_wdata_p1_27_o  = data_to_store[27];
    assign tcdm_wdata_p1_28_o  = data_to_store[28];
    assign tcdm_wdata_p1_29_o  = data_to_store[29];
    assign tcdm_wdata_p1_30_o  = data_to_store[30];
    assign tcdm_wdata_p1_31_o  = data_to_store[31];

    assign tcdm_wdata_p0_0_o   = data_to_store[0];
    assign tcdm_wdata_p0_1_o   = data_to_store[1];
    assign tcdm_wdata_p0_2_o   = data_to_store[2];
    assign tcdm_wdata_p0_3_o   = data_to_store[3];
    assign tcdm_wdata_p0_4_o   = data_to_store[4];
    assign tcdm_wdata_p0_5_o   = data_to_store[5];
    assign tcdm_wdata_p0_6_o   = data_to_store[6];
    assign tcdm_wdata_p0_7_o   = data_to_store[7];
    assign tcdm_wdata_p0_8_o   = data_to_store[8];
    assign tcdm_wdata_p0_9_o   = data_to_store[9];
    assign tcdm_wdata_p0_10_o  = data_to_store[10];
    assign tcdm_wdata_p0_11_o  = data_to_store[11];
    assign tcdm_wdata_p0_12_o  = data_to_store[12];
    assign tcdm_wdata_p0_13_o  = data_to_store[13];
    assign tcdm_wdata_p0_14_o  = data_to_store[14];
    assign tcdm_wdata_p0_15_o  = data_to_store[15];
    assign tcdm_wdata_p0_16_o  = data_to_store[16];
    assign tcdm_wdata_p0_17_o  = data_to_store[17];
    assign tcdm_wdata_p0_18_o  = data_to_store[18];
    assign tcdm_wdata_p0_19_o  = data_to_store[19];
    assign tcdm_wdata_p0_20_o  = data_to_store[20];
    assign tcdm_wdata_p0_21_o  = data_to_store[21];
    assign tcdm_wdata_p0_22_o  = data_to_store[22];
    assign tcdm_wdata_p0_23_o  = data_to_store[23];
    assign tcdm_wdata_p0_24_o  = data_to_store[24];
    assign tcdm_wdata_p0_25_o  = data_to_store[25];
    assign tcdm_wdata_p0_26_o  = data_to_store[26];
    assign tcdm_wdata_p0_27_o  = data_to_store[27];
    assign tcdm_wdata_p0_28_o  = data_to_store[28];
    assign tcdm_wdata_p0_29_o  = data_to_store[29];
    assign tcdm_wdata_p0_30_o  = data_to_store[30];
    assign tcdm_wdata_p0_31_o  = data_to_store[31];

    assign tcdm_wdata_p2_0_o   = data_to_store[0];
    assign tcdm_wdata_p2_1_o   = data_to_store[1];
    assign tcdm_wdata_p2_2_o   = data_to_store[2];
    assign tcdm_wdata_p2_3_o   = data_to_store[3];
    assign tcdm_wdata_p2_4_o   = data_to_store[4];
    assign tcdm_wdata_p2_5_o   = data_to_store[5];
    assign tcdm_wdata_p2_6_o   = data_to_store[6];
    assign tcdm_wdata_p2_7_o   = data_to_store[7];
    assign tcdm_wdata_p2_8_o   = data_to_store[8];
    assign tcdm_wdata_p2_9_o   = data_to_store[9];
    assign tcdm_wdata_p2_10_o  = data_to_store[10];
    assign tcdm_wdata_p2_11_o  = data_to_store[11];
    assign tcdm_wdata_p2_12_o  = data_to_store[12];
    assign tcdm_wdata_p2_13_o  = data_to_store[13];
    assign tcdm_wdata_p2_14_o  = data_to_store[14];
    assign tcdm_wdata_p2_15_o  = data_to_store[15];
    assign tcdm_wdata_p2_16_o  = data_to_store[16];
    assign tcdm_wdata_p2_17_o  = data_to_store[17];
    assign tcdm_wdata_p2_18_o  = data_to_store[18];
    assign tcdm_wdata_p2_19_o  = data_to_store[19];
    assign tcdm_wdata_p2_20_o  = data_to_store[20];
    assign tcdm_wdata_p2_21_o  = data_to_store[21];
    assign tcdm_wdata_p2_22_o  = data_to_store[22];
    assign tcdm_wdata_p2_23_o  = data_to_store[23];
    assign tcdm_wdata_p2_24_o  = data_to_store[24];
    assign tcdm_wdata_p2_25_o  = data_to_store[25];
    assign tcdm_wdata_p2_26_o  = data_to_store[26];
    assign tcdm_wdata_p2_27_o  = data_to_store[27];
    assign tcdm_wdata_p2_28_o  = data_to_store[28];
    assign tcdm_wdata_p2_29_o  = data_to_store[29];
    assign tcdm_wdata_p2_30_o  = data_to_store[30];
    assign tcdm_wdata_p2_31_o  = data_to_store[31];

    assign tcdm_wdata_p3_0_o   = data_to_store[0];
    assign tcdm_wdata_p3_1_o   = data_to_store[1];
    assign tcdm_wdata_p3_2_o   = data_to_store[2];
    assign tcdm_wdata_p3_3_o   = data_to_store[3];
    assign tcdm_wdata_p3_4_o   = data_to_store[4];
    assign tcdm_wdata_p3_5_o   = data_to_store[5];
    assign tcdm_wdata_p3_6_o   = data_to_store[6];
    assign tcdm_wdata_p3_7_o   = data_to_store[7];
    assign tcdm_wdata_p3_8_o   = data_to_store[8];
    assign tcdm_wdata_p3_9_o   = data_to_store[9];
    assign tcdm_wdata_p3_10_o  = data_to_store[10];
    assign tcdm_wdata_p3_11_o  = data_to_store[11];
    assign tcdm_wdata_p3_12_o  = data_to_store[12];
    assign tcdm_wdata_p3_13_o  = data_to_store[13];
    assign tcdm_wdata_p3_14_o  = data_to_store[14];
    assign tcdm_wdata_p3_15_o  = data_to_store[15];
    assign tcdm_wdata_p3_16_o  = data_to_store[16];
    assign tcdm_wdata_p3_17_o  = data_to_store[17];
    assign tcdm_wdata_p3_18_o  = data_to_store[18];
    assign tcdm_wdata_p3_19_o  = data_to_store[19];
    assign tcdm_wdata_p3_20_o  = data_to_store[20];
    assign tcdm_wdata_p3_21_o  = data_to_store[21];
    assign tcdm_wdata_p3_22_o  = data_to_store[22];
    assign tcdm_wdata_p3_23_o  = data_to_store[23];
    assign tcdm_wdata_p3_24_o  = data_to_store[24];
    assign tcdm_wdata_p3_25_o  = data_to_store[25];
    assign tcdm_wdata_p3_26_o  = data_to_store[26];
    assign tcdm_wdata_p3_27_o  = data_to_store[27];
    assign tcdm_wdata_p3_28_o  = data_to_store[28];
    assign tcdm_wdata_p3_29_o  = data_to_store[29];
    assign tcdm_wdata_p3_30_o  = data_to_store[30];
    assign tcdm_wdata_p3_31_o  = data_to_store[31];

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
                    tcdm_r_rdata_p0_0_i };

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
                    tcdm_r_rdata_p1_0_i };

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
                    tcdm_r_rdata_p2_0_i };

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
                    tcdm_r_rdata_p3_0_i };


    assign tcdm_addr_p0_0_o      = real_address0[0];
    assign tcdm_addr_p0_1_o      = real_address0[1];
    assign tcdm_addr_p0_2_o      = real_address0[2];
    assign tcdm_addr_p0_3_o      = real_address0[3];
    assign tcdm_addr_p0_4_o      = real_address0[4];
    assign tcdm_addr_p0_5_o      = real_address0[5];
    assign tcdm_addr_p0_6_o      = real_address0[6];
    assign tcdm_addr_p0_7_o      = real_address0[7];
    assign tcdm_addr_p0_8_o      = real_address0[8];
    assign tcdm_addr_p0_9_o      = real_address0[9];
    assign tcdm_addr_p0_10_o     = real_address0[10];
    assign tcdm_addr_p0_11_o     = real_address0[11];
    assign tcdm_addr_p0_12_o     = real_address0[12];
    assign tcdm_addr_p0_13_o     = real_address0[13];
    assign tcdm_addr_p0_14_o     = real_address0[14];
    assign tcdm_addr_p0_15_o     = real_address0[15];
    assign tcdm_addr_p0_16_o     = real_address0[16];
    assign tcdm_addr_p0_17_o     = real_address0[17];
    assign tcdm_addr_p0_18_o     = real_address0[18];
    assign tcdm_addr_p0_19_o     = real_address0[19];

    assign tcdm_addr_p1_0_o      = real_address1[0];
    assign tcdm_addr_p1_1_o      = real_address1[1];
    assign tcdm_addr_p1_2_o      = real_address1[2];
    assign tcdm_addr_p1_3_o      = real_address1[3];
    assign tcdm_addr_p1_4_o      = real_address1[4];
    assign tcdm_addr_p1_5_o      = real_address1[5];
    assign tcdm_addr_p1_6_o      = real_address1[6];
    assign tcdm_addr_p1_7_o      = real_address1[7];
    assign tcdm_addr_p1_8_o      = real_address1[8];
    assign tcdm_addr_p1_9_o      = real_address1[9];
    assign tcdm_addr_p1_10_o     = real_address1[10];
    assign tcdm_addr_p1_11_o     = real_address1[11];
    assign tcdm_addr_p1_12_o     = real_address1[12];
    assign tcdm_addr_p1_13_o     = real_address1[13];
    assign tcdm_addr_p1_14_o     = real_address1[14];
    assign tcdm_addr_p1_15_o     = real_address1[15];
    assign tcdm_addr_p1_16_o     = real_address1[16];
    assign tcdm_addr_p1_17_o     = real_address1[17];
    assign tcdm_addr_p1_18_o     = real_address1[18];
    assign tcdm_addr_p1_19_o     = real_address1[19];

    assign tcdm_addr_p2_0_o      = real_address2[0];
    assign tcdm_addr_p2_1_o      = real_address2[1];
    assign tcdm_addr_p2_2_o      = real_address2[2];
    assign tcdm_addr_p2_3_o      = real_address2[3];
    assign tcdm_addr_p2_4_o      = real_address2[4];
    assign tcdm_addr_p2_5_o      = real_address2[5];
    assign tcdm_addr_p2_6_o      = real_address2[6];
    assign tcdm_addr_p2_7_o      = real_address2[7];
    assign tcdm_addr_p2_8_o      = real_address2[8];
    assign tcdm_addr_p2_9_o      = real_address2[9];
    assign tcdm_addr_p2_10_o     = real_address2[10];
    assign tcdm_addr_p2_11_o     = real_address2[11];
    assign tcdm_addr_p2_12_o     = real_address2[12];
    assign tcdm_addr_p2_13_o     = real_address2[13];
    assign tcdm_addr_p2_14_o     = real_address2[14];
    assign tcdm_addr_p2_15_o     = real_address2[15];
    assign tcdm_addr_p2_16_o     = real_address2[16];
    assign tcdm_addr_p2_17_o     = real_address2[17];
    assign tcdm_addr_p2_18_o     = real_address2[18];
    assign tcdm_addr_p2_19_o     = real_address2[19];

    assign tcdm_addr_p3_0_o      = real_address3[0];
    assign tcdm_addr_p3_1_o      = real_address3[1];
    assign tcdm_addr_p3_2_o      = real_address3[2];
    assign tcdm_addr_p3_3_o      = real_address3[3];
    assign tcdm_addr_p3_4_o      = real_address3[4];
    assign tcdm_addr_p3_5_o      = real_address3[5];
    assign tcdm_addr_p3_6_o      = real_address3[6];
    assign tcdm_addr_p3_7_o      = real_address3[7];
    assign tcdm_addr_p3_8_o      = real_address3[8];
    assign tcdm_addr_p3_9_o      = real_address3[9];
    assign tcdm_addr_p3_10_o     = real_address3[10];
    assign tcdm_addr_p3_11_o     = real_address3[11];
    assign tcdm_addr_p3_12_o     = real_address3[12];
    assign tcdm_addr_p3_13_o     = real_address3[13];
    assign tcdm_addr_p3_14_o     = real_address3[14];
    assign tcdm_addr_p3_15_o     = real_address3[15];
    assign tcdm_addr_p3_16_o     = real_address3[16];
    assign tcdm_addr_p3_17_o     = real_address3[17];
    assign tcdm_addr_p3_18_o     = real_address3[18];
    assign tcdm_addr_p3_19_o     = real_address3[19];


    assign MU0_EFPGA_MATHB_OPER_defPin_1_ = 1'b0;
    assign MU0_EFPGA_MATHB_OPER_defPin_0_ = 1'b0;
    assign MU0_EFPGA_MATHB_OPER_SEL       = configuration_sel[2];

    assign MU0_EFPGA_MATHB_COEF_defPin_1_ = 1'b0;
    assign MU0_EFPGA_MATHB_COEF_defPin_0_ = 1'b0;
    assign MU0_EFPGA_MATHB_COEF_SEL       = configuration_sel[2];

    assign { MU0_EFPGA_MATHB_MAC_OUT_SEL_5_, MU0_EFPGA_MATHB_MAC_OUT_SEL_4_, MU0_EFPGA_MATHB_MAC_OUT_SEL_3_, MU0_EFPGA_MATHB_MAC_OUT_SEL_2_, MU0_EFPGA_MATHB_MAC_OUT_SEL_1_ ,MU0_EFPGA_MATHB_MAC_OUT_SEL_0_ } = configuration_sel[11:6];

    assign MU0_EFPGA_MATHB_DATAOUT_SEL_1_ = configuration_sel[1];
    assign MU0_EFPGA_MATHB_DATAOUT_SEL_0_ = configuration_sel[0];


    assign MU0_EFPGA_MATHB_MAC_ACC_CLEAR = reset_accumulator_q;
    assign MU0_EFPGA_MATHB_MAC_ACC_RND   = configuration_sel[4];
    assign MU0_EFPGA_MATHB_MAC_ACC_SAT   = configuration_sel[3];
    assign MU0_EFPGA_MATHB_TC_defPin     = 1'b1;

    assign MU0_EFPGA_MATHB_CLK_EN        = configuration_sel[5];

    assign MU0_EFPGA2MATHB_CLK           = clk_i; //pragma attribute clk_i pad ck_buff

    assign tcdm_be                       = configuration_sel[15:12];

    assign MU1_EFPGA_MATHB_OPER_defPin_1_ = 1'b0;
    assign MU1_EFPGA_MATHB_OPER_defPin_0_ = 1'b0;
    assign MU1_EFPGA_MATHB_OPER_SEL       = configuration_sel[2];

    assign MU1_EFPGA_MATHB_COEF_defPin_1_ = 1'b0;
    assign MU1_EFPGA_MATHB_COEF_defPin_0_ = 1'b0;
    assign MU1_EFPGA_MATHB_COEF_SEL       = configuration_sel[2];

    assign { MU1_EFPGA_MATHB_MAC_OUT_SEL_5_, MU1_EFPGA_MATHB_MAC_OUT_SEL_4_, MU1_EFPGA_MATHB_MAC_OUT_SEL_3_, MU1_EFPGA_MATHB_MAC_OUT_SEL_2_, MU1_EFPGA_MATHB_MAC_OUT_SEL_1_ ,MU1_EFPGA_MATHB_MAC_OUT_SEL_0_ } = configuration_sel[11:6];

    assign MU1_EFPGA_MATHB_DATAOUT_SEL_1_ = configuration_sel[1];
    assign MU1_EFPGA_MATHB_DATAOUT_SEL_0_ = configuration_sel[0];


    assign MU1_EFPGA_MATHB_MAC_ACC_CLEAR = reset_accumulator_q;
    assign MU1_EFPGA_MATHB_MAC_ACC_RND   = configuration_sel[4];
    assign MU1_EFPGA_MATHB_MAC_ACC_SAT   = configuration_sel[3];
    assign MU1_EFPGA_MATHB_TC_defPin     = 1'b1;

    assign MU1_EFPGA_MATHB_CLK_EN        = configuration_sel[5];

    assign MU1_EFPGA2MATHB_CLK           = clk_i; //pragma attribute clk_i pad ck_buff

    assign result0[0]  = MU0_MATHB_EFPGA_MAC_OUT_0_;
    assign result0[1]  = MU0_MATHB_EFPGA_MAC_OUT_1_;
    assign result0[2]  = MU0_MATHB_EFPGA_MAC_OUT_2_;
    assign result0[3]  = MU0_MATHB_EFPGA_MAC_OUT_3_;
    assign result0[4]  = MU0_MATHB_EFPGA_MAC_OUT_4_;
    assign result0[5]  = MU0_MATHB_EFPGA_MAC_OUT_5_;
    assign result0[6]  = MU0_MATHB_EFPGA_MAC_OUT_6_;
    assign result0[7]  = MU0_MATHB_EFPGA_MAC_OUT_7_;
    assign result0[8]  = MU0_MATHB_EFPGA_MAC_OUT_8_;
    assign result0[9]  = MU0_MATHB_EFPGA_MAC_OUT_9_;
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

    assign result1[0]  = MU1_MATHB_EFPGA_MAC_OUT_0_;
    assign result1[1]  = MU1_MATHB_EFPGA_MAC_OUT_1_;
    assign result1[2]  = MU1_MATHB_EFPGA_MAC_OUT_2_;
    assign result1[3]  = MU1_MATHB_EFPGA_MAC_OUT_3_;
    assign result1[4]  = MU1_MATHB_EFPGA_MAC_OUT_4_;
    assign result1[5]  = MU1_MATHB_EFPGA_MAC_OUT_5_;
    assign result1[6]  = MU1_MATHB_EFPGA_MAC_OUT_6_;
    assign result1[7]  = MU1_MATHB_EFPGA_MAC_OUT_7_;
    assign result1[8]  = MU1_MATHB_EFPGA_MAC_OUT_8_;
    assign result1[9]  = MU1_MATHB_EFPGA_MAC_OUT_9_;
    assign result1[10] = MU1_MATHB_EFPGA_MAC_OUT_10_;
    assign result1[11] = MU1_MATHB_EFPGA_MAC_OUT_11_;
    assign result1[12] = MU1_MATHB_EFPGA_MAC_OUT_12_;
    assign result1[13] = MU1_MATHB_EFPGA_MAC_OUT_13_;
    assign result1[14] = MU1_MATHB_EFPGA_MAC_OUT_14_;
    assign result1[15] = MU1_MATHB_EFPGA_MAC_OUT_15_;
    assign result1[16] = MU1_MATHB_EFPGA_MAC_OUT_16_;
    assign result1[17] = MU1_MATHB_EFPGA_MAC_OUT_17_;
    assign result1[18] = MU1_MATHB_EFPGA_MAC_OUT_18_;
    assign result1[19] = MU1_MATHB_EFPGA_MAC_OUT_19_;
    assign result1[20] = MU1_MATHB_EFPGA_MAC_OUT_20_;
    assign result1[21] = MU1_MATHB_EFPGA_MAC_OUT_21_;
    assign result1[22] = MU1_MATHB_EFPGA_MAC_OUT_22_;
    assign result1[23] = MU1_MATHB_EFPGA_MAC_OUT_23_;
    assign result1[24] = MU1_MATHB_EFPGA_MAC_OUT_24_;
    assign result1[25] = MU1_MATHB_EFPGA_MAC_OUT_25_;
    assign result1[26] = MU1_MATHB_EFPGA_MAC_OUT_26_;
    assign result1[27] = MU1_MATHB_EFPGA_MAC_OUT_27_;
    assign result1[28] = MU1_MATHB_EFPGA_MAC_OUT_28_;
    assign result1[29] = MU1_MATHB_EFPGA_MAC_OUT_29_;
    assign result1[30] = MU1_MATHB_EFPGA_MAC_OUT_30_;
    assign result1[31] = MU1_MATHB_EFPGA_MAC_OUT_31_;

    assign MU0_EFPGA_MATHB_OPER_DATA_0_   = selected_data_mac0[0];
    assign MU0_EFPGA_MATHB_OPER_DATA_1_   = selected_data_mac0[1];
    assign MU0_EFPGA_MATHB_OPER_DATA_2_   = selected_data_mac0[2];
    assign MU0_EFPGA_MATHB_OPER_DATA_3_   = selected_data_mac0[3];
    assign MU0_EFPGA_MATHB_OPER_DATA_4_   = selected_data_mac0[4];
    assign MU0_EFPGA_MATHB_OPER_DATA_5_   = selected_data_mac0[5];
    assign MU0_EFPGA_MATHB_OPER_DATA_6_   = selected_data_mac0[6];
    assign MU0_EFPGA_MATHB_OPER_DATA_7_   = selected_data_mac0[7];
    assign MU0_EFPGA_MATHB_OPER_DATA_8_   = selected_data_mac0[8];
    assign MU0_EFPGA_MATHB_OPER_DATA_9_   = selected_data_mac0[9];
    assign MU0_EFPGA_MATHB_OPER_DATA_10_  = selected_data_mac0[10];
    assign MU0_EFPGA_MATHB_OPER_DATA_11_  = selected_data_mac0[11];
    assign MU0_EFPGA_MATHB_OPER_DATA_12_  = selected_data_mac0[12];
    assign MU0_EFPGA_MATHB_OPER_DATA_13_  = selected_data_mac0[13];
    assign MU0_EFPGA_MATHB_OPER_DATA_14_  = selected_data_mac0[14];
    assign MU0_EFPGA_MATHB_OPER_DATA_15_  = selected_data_mac0[15];
    assign MU0_EFPGA_MATHB_OPER_DATA_16_  = selected_data_mac0[16];
    assign MU0_EFPGA_MATHB_OPER_DATA_17_  = selected_data_mac0[17];
    assign MU0_EFPGA_MATHB_OPER_DATA_18_  = selected_data_mac0[18];
    assign MU0_EFPGA_MATHB_OPER_DATA_19_  = selected_data_mac0[19];
    assign MU0_EFPGA_MATHB_OPER_DATA_20_  = selected_data_mac0[20];
    assign MU0_EFPGA_MATHB_OPER_DATA_21_  = selected_data_mac0[21];
    assign MU0_EFPGA_MATHB_OPER_DATA_22_  = selected_data_mac0[22];
    assign MU0_EFPGA_MATHB_OPER_DATA_23_  = selected_data_mac0[23];
    assign MU0_EFPGA_MATHB_OPER_DATA_24_  = selected_data_mac0[24];
    assign MU0_EFPGA_MATHB_OPER_DATA_25_  = selected_data_mac0[25];
    assign MU0_EFPGA_MATHB_OPER_DATA_26_  = selected_data_mac0[26];
    assign MU0_EFPGA_MATHB_OPER_DATA_27_  = selected_data_mac0[27];
    assign MU0_EFPGA_MATHB_OPER_DATA_28_  = selected_data_mac0[28];
    assign MU0_EFPGA_MATHB_OPER_DATA_29_  = selected_data_mac0[29];
    assign MU0_EFPGA_MATHB_OPER_DATA_30_  = selected_data_mac0[30];
    assign MU0_EFPGA_MATHB_OPER_DATA_31_  = selected_data_mac0[31];

    assign MU1_EFPGA_MATHB_OPER_DATA_0_   = selected_data_mac1[0];
    assign MU1_EFPGA_MATHB_OPER_DATA_1_   = selected_data_mac1[1];
    assign MU1_EFPGA_MATHB_OPER_DATA_2_   = selected_data_mac1[2];
    assign MU1_EFPGA_MATHB_OPER_DATA_3_   = selected_data_mac1[3];
    assign MU1_EFPGA_MATHB_OPER_DATA_4_   = selected_data_mac1[4];
    assign MU1_EFPGA_MATHB_OPER_DATA_5_   = selected_data_mac1[5];
    assign MU1_EFPGA_MATHB_OPER_DATA_6_   = selected_data_mac1[6];
    assign MU1_EFPGA_MATHB_OPER_DATA_7_   = selected_data_mac1[7];
    assign MU1_EFPGA_MATHB_OPER_DATA_8_   = selected_data_mac1[8];
    assign MU1_EFPGA_MATHB_OPER_DATA_9_   = selected_data_mac1[9];
    assign MU1_EFPGA_MATHB_OPER_DATA_10_  = selected_data_mac1[10];
    assign MU1_EFPGA_MATHB_OPER_DATA_11_  = selected_data_mac1[11];
    assign MU1_EFPGA_MATHB_OPER_DATA_12_  = selected_data_mac1[12];
    assign MU1_EFPGA_MATHB_OPER_DATA_13_  = selected_data_mac1[13];
    assign MU1_EFPGA_MATHB_OPER_DATA_14_  = selected_data_mac1[14];
    assign MU1_EFPGA_MATHB_OPER_DATA_15_  = selected_data_mac1[15];
    assign MU1_EFPGA_MATHB_OPER_DATA_16_  = selected_data_mac1[16];
    assign MU1_EFPGA_MATHB_OPER_DATA_17_  = selected_data_mac1[17];
    assign MU1_EFPGA_MATHB_OPER_DATA_18_  = selected_data_mac1[18];
    assign MU1_EFPGA_MATHB_OPER_DATA_19_  = selected_data_mac1[19];
    assign MU1_EFPGA_MATHB_OPER_DATA_20_  = selected_data_mac1[20];
    assign MU1_EFPGA_MATHB_OPER_DATA_21_  = selected_data_mac1[21];
    assign MU1_EFPGA_MATHB_OPER_DATA_22_  = selected_data_mac1[22];
    assign MU1_EFPGA_MATHB_OPER_DATA_23_  = selected_data_mac1[23];
    assign MU1_EFPGA_MATHB_OPER_DATA_24_  = selected_data_mac1[24];
    assign MU1_EFPGA_MATHB_OPER_DATA_25_  = selected_data_mac1[25];
    assign MU1_EFPGA_MATHB_OPER_DATA_26_  = selected_data_mac1[26];
    assign MU1_EFPGA_MATHB_OPER_DATA_27_  = selected_data_mac1[27];
    assign MU1_EFPGA_MATHB_OPER_DATA_28_  = selected_data_mac1[28];
    assign MU1_EFPGA_MATHB_OPER_DATA_29_  = selected_data_mac1[29];
    assign MU1_EFPGA_MATHB_OPER_DATA_30_  = selected_data_mac1[30];
    assign MU1_EFPGA_MATHB_OPER_DATA_31_  = selected_data_mac1[31];

    assign MU0_EFPGA_MATHB_COEF_DATA_0_   = selected_coef_mac[0];
    assign MU0_EFPGA_MATHB_COEF_DATA_1_   = selected_coef_mac[1];
    assign MU0_EFPGA_MATHB_COEF_DATA_2_   = selected_coef_mac[2];
    assign MU0_EFPGA_MATHB_COEF_DATA_3_   = selected_coef_mac[3];
    assign MU0_EFPGA_MATHB_COEF_DATA_4_   = selected_coef_mac[4];
    assign MU0_EFPGA_MATHB_COEF_DATA_5_   = selected_coef_mac[5];
    assign MU0_EFPGA_MATHB_COEF_DATA_6_   = selected_coef_mac[6];
    assign MU0_EFPGA_MATHB_COEF_DATA_7_   = selected_coef_mac[7];
    assign MU0_EFPGA_MATHB_COEF_DATA_8_   = selected_coef_mac[8];
    assign MU0_EFPGA_MATHB_COEF_DATA_9_   = selected_coef_mac[9];
    assign MU0_EFPGA_MATHB_COEF_DATA_10_  = selected_coef_mac[10];
    assign MU0_EFPGA_MATHB_COEF_DATA_11_  = selected_coef_mac[11];
    assign MU0_EFPGA_MATHB_COEF_DATA_12_  = selected_coef_mac[12];
    assign MU0_EFPGA_MATHB_COEF_DATA_13_  = selected_coef_mac[13];
    assign MU0_EFPGA_MATHB_COEF_DATA_14_  = selected_coef_mac[14];
    assign MU0_EFPGA_MATHB_COEF_DATA_15_  = selected_coef_mac[15];
    assign MU0_EFPGA_MATHB_COEF_DATA_16_  = selected_coef_mac[16];
    assign MU0_EFPGA_MATHB_COEF_DATA_17_  = selected_coef_mac[17];
    assign MU0_EFPGA_MATHB_COEF_DATA_18_  = selected_coef_mac[18];
    assign MU0_EFPGA_MATHB_COEF_DATA_19_  = selected_coef_mac[19];
    assign MU0_EFPGA_MATHB_COEF_DATA_20_  = selected_coef_mac[20];
    assign MU0_EFPGA_MATHB_COEF_DATA_21_  = selected_coef_mac[21];
    assign MU0_EFPGA_MATHB_COEF_DATA_22_  = selected_coef_mac[22];
    assign MU0_EFPGA_MATHB_COEF_DATA_23_  = selected_coef_mac[23];
    assign MU0_EFPGA_MATHB_COEF_DATA_24_  = selected_coef_mac[24];
    assign MU0_EFPGA_MATHB_COEF_DATA_25_  = selected_coef_mac[25];
    assign MU0_EFPGA_MATHB_COEF_DATA_26_  = selected_coef_mac[26];
    assign MU0_EFPGA_MATHB_COEF_DATA_27_  = selected_coef_mac[27];
    assign MU0_EFPGA_MATHB_COEF_DATA_28_  = selected_coef_mac[28];
    assign MU0_EFPGA_MATHB_COEF_DATA_29_  = selected_coef_mac[29];
    assign MU0_EFPGA_MATHB_COEF_DATA_30_  = selected_coef_mac[30];
    assign MU0_EFPGA_MATHB_COEF_DATA_31_  = selected_coef_mac[31];

    assign MU1_EFPGA_MATHB_COEF_DATA_0_   = selected_coef_mac[0];
    assign MU1_EFPGA_MATHB_COEF_DATA_1_   = selected_coef_mac[1];
    assign MU1_EFPGA_MATHB_COEF_DATA_2_   = selected_coef_mac[2];
    assign MU1_EFPGA_MATHB_COEF_DATA_3_   = selected_coef_mac[3];
    assign MU1_EFPGA_MATHB_COEF_DATA_4_   = selected_coef_mac[4];
    assign MU1_EFPGA_MATHB_COEF_DATA_5_   = selected_coef_mac[5];
    assign MU1_EFPGA_MATHB_COEF_DATA_6_   = selected_coef_mac[6];
    assign MU1_EFPGA_MATHB_COEF_DATA_7_   = selected_coef_mac[7];
    assign MU1_EFPGA_MATHB_COEF_DATA_8_   = selected_coef_mac[8];
    assign MU1_EFPGA_MATHB_COEF_DATA_9_   = selected_coef_mac[9];
    assign MU1_EFPGA_MATHB_COEF_DATA_10_  = selected_coef_mac[10];
    assign MU1_EFPGA_MATHB_COEF_DATA_11_  = selected_coef_mac[11];
    assign MU1_EFPGA_MATHB_COEF_DATA_12_  = selected_coef_mac[12];
    assign MU1_EFPGA_MATHB_COEF_DATA_13_  = selected_coef_mac[13];
    assign MU1_EFPGA_MATHB_COEF_DATA_14_  = selected_coef_mac[14];
    assign MU1_EFPGA_MATHB_COEF_DATA_15_  = selected_coef_mac[15];
    assign MU1_EFPGA_MATHB_COEF_DATA_16_  = selected_coef_mac[16];
    assign MU1_EFPGA_MATHB_COEF_DATA_17_  = selected_coef_mac[17];
    assign MU1_EFPGA_MATHB_COEF_DATA_18_  = selected_coef_mac[18];
    assign MU1_EFPGA_MATHB_COEF_DATA_19_  = selected_coef_mac[19];
    assign MU1_EFPGA_MATHB_COEF_DATA_20_  = selected_coef_mac[20];
    assign MU1_EFPGA_MATHB_COEF_DATA_21_  = selected_coef_mac[21];
    assign MU1_EFPGA_MATHB_COEF_DATA_22_  = selected_coef_mac[22];
    assign MU1_EFPGA_MATHB_COEF_DATA_23_  = selected_coef_mac[23];
    assign MU1_EFPGA_MATHB_COEF_DATA_24_  = selected_coef_mac[24];
    assign MU1_EFPGA_MATHB_COEF_DATA_25_  = selected_coef_mac[25];
    assign MU1_EFPGA_MATHB_COEF_DATA_26_  = selected_coef_mac[26];
    assign MU1_EFPGA_MATHB_COEF_DATA_27_  = selected_coef_mac[27];
    assign MU1_EFPGA_MATHB_COEF_DATA_28_  = selected_coef_mac[28];
    assign MU1_EFPGA_MATHB_COEF_DATA_29_  = selected_coef_mac[29];
    assign MU1_EFPGA_MATHB_COEF_DATA_30_  = selected_coef_mac[30];
    assign MU1_EFPGA_MATHB_COEF_DATA_31_  = selected_coef_mac[31];

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
    gpio_data_39_i, gpio_data_38_i, gpio_data_37_i, gpio_data_36_i, gpio_data_35_i,
    gpio_data_34_i, gpio_data_33_i, gpio_data_32_i, gpio_data_31_i, gpio_data_30_i,
    gpio_data_29_i, gpio_data_28_i, gpio_data_27_i, gpio_data_26_i, gpio_data_25_i,
    gpio_data_24_i, gpio_data_23_i, gpio_data_22_i, gpio_data_21_i, gpio_data_20_i,
    gpio_data_19_i, gpio_data_18_i, gpio_data_17_i, gpio_data_16_i, gpio_data_15_i,
    gpio_data_14_i, gpio_data_13_i, gpio_data_12_i, gpio_data_11_i, gpio_data_10_i,
    gpio_data_9_i,  gpio_data_8_i,  gpio_data_7_i,  gpio_data_6_i,  gpio_data_5_i,
    gpio_data_4_i,  gpio_data_3_i,  gpio_data_2_i,  gpio_data_1_i,  gpio_data_0_i  };


endmodule
