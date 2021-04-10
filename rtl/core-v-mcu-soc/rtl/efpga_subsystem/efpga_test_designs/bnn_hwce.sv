// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


module bnn_hwce (
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

    output logic apb_hwce_ready_o,

    output logic gpio_oe_5_o,
    output logic gpio_data_5_o,
    output logic events_0_o,
    output logic events_1_o
);

  localparam NFILTERS = 8;
  localparam LOG_NFILTERS = 3;

  logic [31:0] apb_pwdata;
  logic [ 6:0] apb_hwce_addr;
  logic [31:0] apb_hwce_prdata;

  logic [19:0] read_address_q, originalread_address_q;
  logic [19:0] store_address_q;
  logic [19:0] filter_address_q;
  logic [19:0] real_address3, real_address2, real_address1, real_address0;
  logic [3:0] tcdm_be;
  logic start_q, done_q;
  logic sw_event_q;

  logic is_tcdm_address_input, is_tcdm_address_output, is_tcdm_address_filter, is_start;
  logic is_done, is_num_elem, is_loop, is_next_row;
  logic is_configuration_sel;
  logic is_gpio;
  logic is_sw_event_sel;
  logic is_threshold;
  logic start_lsu0, start_lsu1, start_lsu2, start_lsu3, start_write1;
  logic store_data, store_out_int;

  logic
      incaddr_read,
      incaddr_write,
      incaddr_filter,
      resetaddr_filter,
      resetaddr_read,
      copyaddr_read,
      incaddr_store;

  logic data_valid0, data_valid1, data_valid2, data_valid3, all_data_valid;
  logic [3:0] data_valid;
  logic reset_data_valid;
  logic [15:0] num_elem_q, num_elem_n;
  logic [8:0] loop_col_q, loop_row_q, loop_user_q;
  logic
      last_iteration,
      store_num_elem,
      store_xor_intput,
      decrease_col_loop,
      decrease_row_loop,
      reset_col_loop;
  logic        nextrowaddr_read;
  logic [ 9:0] next_row_q;
  logic [31:0] data_input_q;
  logic [31:0] data_input_xor_q;
  logic [10:0] out_int_q        [NFILTERS];
  logic [10:0] out_int_n;
  logic [10:0] out_int_n_1;
  logic [10:0] threshold;
  logic [LOG_NFILTERS:0] sel_out_int_q, sel_out_int_n;
  logic [2:0] pixel_pos_q, pixel_pos_n;

  logic [31:0] filter_q     [NFILTERS];

  logic [ 3:0] store_filter;
  logic [31:0] tcdm_r_rdata_p0, tcdm_r_rdata_p1, tcdm_r_rdata_p2, tcdm_r_rdata_p3;
  logic [2:0] gpio_val;

  logic [15:0] configuration_sel;

  logic [31:0] data_to_store;

  logic [31:0] xored_val;
  logic [6:0] pop_count;

  logic [31:0] xored_val_1;
  logic [6:0] pop_count_1;

  logic reset_out_int;


  enum logic [2:0] {
    IDLE,
    READ_INPUT_FIRST,
    READ_INPUT,
    READ_FILTERS,
    READ_FINISH,
    COMPARISON,
    STORE,
    END
  }
      state_read_n, state_read_q;


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
  assign tcdm_wen_p0_o = state_read_q != STORE;

  assign tcdm_be_p1_0_o = tcdm_be[0];
  assign tcdm_be_p1_1_o = tcdm_be[1];
  assign tcdm_be_p1_2_o = tcdm_be[2];
  assign tcdm_be_p1_3_o = tcdm_be[3];
  assign tcdm_wen_p1_o = state_read_q != STORE;

  assign tcdm_be_p2_0_o = tcdm_be[0];
  assign tcdm_be_p2_1_o = tcdm_be[1];
  assign tcdm_be_p2_2_o = tcdm_be[2];
  assign tcdm_be_p2_3_o = tcdm_be[3];
  assign tcdm_wen_p2_o = state_read_q != STORE;

  assign tcdm_be_p3_0_o = tcdm_be[0];
  assign tcdm_be_p3_1_o = tcdm_be[1];
  assign tcdm_be_p3_2_o = tcdm_be[2];
  assign tcdm_be_p3_3_o = tcdm_be[3];
  assign tcdm_wen_p3_o = state_read_q != STORE;


  assign all_data_valid = data_valid[0] & data_valid[1] & data_valid[2] & data_valid[3];

  assign last_iteration = num_elem_q == 0;

  always_comb begin
    out_int_n   = out_int_q[0][10:0];
    out_int_n_1 = out_int_q[0][10:0];
    if (state_read_q == READ_INPUT || state_read_q == READ_FINISH) begin
      /*
                    As the data_input_q is 32bits and there are 4 filter_q[0], filter_q[3], each 32bits
                    We need to do 128 XOR and accumulate them in a 4x32 4bits accumulator --> 128 filters = 128 partial results
                    128 partial results, each orgaized as 4x32x4bits
            */
      out_int_n[10:0] = out_int_q[sel_out_int_q[LOG_NFILTERS-1:0]][10:0] + $unsigned(pop_count);
      out_int_n_1[10:0] = out_int_q[sel_out_int_q[LOG_NFILTERS-1:0]+1][10:0] + $unsigned(
          pop_count_1
      );
    end else if (state_read_q == COMPARISON) begin
      /*
                    each partial result is 4bits into out_int_q, of those, we have to reduce them to 1 bits
                    We use 32 i comparators in 4 cycles as before
                    Fixed Threshold for the moment
            */
      out_int_n[0] = $unsigned(
          out_int_q[sel_out_int_q[LOG_NFILTERS-1:0]][10:0]
      ) > $unsigned(
          threshold
      );
      out_int_n[10:1] = '0;

      out_int_n_1[0] = $unsigned(
          out_int_q[sel_out_int_q[LOG_NFILTERS-1:0]+1][10:0]
      ) > $unsigned(
          threshold
      );
      out_int_n_1[10:1] = '0;

    end else begin
      out_int_n   = out_int_q[0][10:0];
      out_int_n_1 = out_int_q[0][10:0];
    end
  end



  assign xored_val   = $unsigned((data_input_xor_q ^ filter_q[sel_out_int_q[LOG_NFILTERS-1:0]]));
  assign xored_val_1 = $unsigned((data_input_xor_q ^ filter_q[sel_out_int_q[LOG_NFILTERS-1:0]+1]));

  pop_count pc0 (
      .input_val_i(xored_val),
      .pop_count_o(pop_count)
  );
  pop_count pc1 (
      .input_val_i(xored_val_1),
      .pop_count_o(pop_count_1)
  );


  assign data_to_store[31:NFILTERS] = '0;

  generate

    for (genvar k = 0; k < NFILTERS; k = k + 1) begin
      //for(genvar j=0;j<32;j=j+1)
      assign data_to_store[k] = $unsigned(out_int_q[k][0]);
    end

  endgenerate

  /*
    READ FSM
*/
  always_comb begin

    state_read_n                                     = state_read_q;
    reset_data_valid                                 = 1'b0;
    {start_lsu0, start_lsu1, start_lsu2, start_lsu3} = 4'b0000;
    store_num_elem                                   = 1'b0;
    num_elem_n                                       = num_elem_q;
    store_data                                       = 1'b0;
    store_out_int                                    = 1'b0;
    incaddr_read                                     = 1'b0;
    incaddr_filter                                   = 1'b0;
    pixel_pos_n                                      = pixel_pos_q;
    sel_out_int_n                                    = sel_out_int_q;
    store_filter                                     = 4'b0;
    events_1_o                                       = 1'b0;
    store_xor_intput                                 = 1'b0;
    decrease_col_loop                                = 1'b0;
    decrease_row_loop                                = 1'b0;
    reset_col_loop                                   = 1'b0;
    copyaddr_read                                    = 1'b0;
    resetaddr_filter                                 = 1'b0;
    resetaddr_read                                   = 1'b0;
    incaddr_store                                    = 1'b0;
    reset_out_int                                    = 1'b0;
    nextrowaddr_read                                 = 1'b0;
    unique case (state_read_q)

      IDLE: begin
        if (start_q) begin
          state_read_n     = READ_INPUT_FIRST;
          reset_data_valid = 1'b1;
          num_elem_n       = 9;
          store_num_elem   = 1'b1;
          copyaddr_read    = 1'b1;
        end
      end


      READ_INPUT_FIRST: begin
        state_read_n     = data_valid0 ? READ_FILTERS : state_read_q;
        reset_data_valid = data_valid0;
        start_lsu0       = ~data_valid[0];
        num_elem_n       = num_elem_q - 1;
        store_num_elem   = data_valid0;
        store_data       = data_valid0;
        sel_out_int_n    = 0;
        incaddr_read     = data_valid0;
        pixel_pos_n      = 1;
      end

      /*  32 channel input on the z-axis
                make out_int(i)+=popcount(input(i)^filter(i)) while fetching input(i+1))
            */
      READ_INPUT: begin
        //                state_read_n                                                     = sel_out_int_q == NFILTERS ? READ_FILTERS :  state_read_q;
        //                reset_data_valid                                                 = sel_out_int_q == NFILTERS;

        state_read_n = state_read_q;
        reset_data_valid = 1'b0;
        store_out_int = 1'b0;
        if (data_valid0) begin
          if (sel_out_int_q == NFILTERS) begin
            sel_out_int_n = '0;
            state_read_n = READ_FILTERS;
            reset_data_valid = 1'b1;
            incaddr_read = 1'b1;
          end else begin
            store_out_int = 1'b1;
            sel_out_int_n = sel_out_int_q + 2;
          end
        end else begin
          if (data_valid[0]) begin
            if (sel_out_int_q == NFILTERS) begin
              sel_out_int_n = '0;
              state_read_n = READ_FILTERS;
              reset_data_valid = 1'b1;
              incaddr_read = 1'b1;
            end else begin
              store_out_int = 1'b1;
              sel_out_int_n = sel_out_int_q + 2;
            end
          end else begin
            sel_out_int_n = sel_out_int_q == NFILTERS ? sel_out_int_q : sel_out_int_q + 2;
            store_out_int = sel_out_int_q != NFILTERS;
          end
        end

        //                state_read_n                                                     = sel_out_int_q == NFILTERS ? READ_FILTERS :  state_read_q;
        //                reset_data_valid                                                 = data_valid0 | data_valid[0])
        start_lsu0     = ~data_valid[0];
        num_elem_n     = num_elem_q - 1;
        store_num_elem = data_valid0;
        store_data     = data_valid0;
        //                sel_out_int_n                                                    = sel_out_int_q == NFILTERS ? 0 : sel_out_int_q + 2;
        //                store_out_int                                                    = sel_out_int_q != NFILTERS;
        //                incaddr_read                                                     = sel_out_int_q == NFILTERS;
        //if it reaches 2, next read address is read_address + ROW for the 3x3 convolution
        pixel_pos_n    = pixel_pos_q == 2 ? 0 : pixel_pos_q + 1;
      end


      //128 filters on the z-axis
      READ_FILTERS: begin
        sel_out_int_n = sel_out_int_q;
        {start_lsu0, start_lsu1, start_lsu2, start_lsu3} = ~{
          data_valid[0], data_valid[1], data_valid[2], data_valid[3]
        };
        if (last_iteration) begin
          if (all_data_valid) begin
            sel_out_int_n = sel_out_int_q == NFILTERS-4 ? 0 : sel_out_int_q + 4;
            state_read_n  = sel_out_int_q == NFILTERS-4 ? READ_FINISH : READ_FILTERS;
            store_xor_intput    = 1'b1;
          end
        end else begin
          if (all_data_valid) begin
            sel_out_int_n = sel_out_int_q == NFILTERS-4 ? 0 : sel_out_int_q + 4;
            state_read_n  = sel_out_int_q == NFILTERS-4 ? READ_INPUT : READ_FILTERS;
            store_xor_intput    = 1'b1;
          end
        end
        reset_data_valid = all_data_valid;
        store_filter     = {data_valid0, data_valid1, data_valid2, data_valid3};
        incaddr_filter   = all_data_valid;
      end


      READ_FINISH: begin
        state_read_n     = sel_out_int_q == NFILTERS ? COMPARISON : READ_FINISH;
        reset_data_valid = 1'b1;
        sel_out_int_n    = sel_out_int_q == NFILTERS ? '0 : sel_out_int_q + 2;
        store_out_int    = sel_out_int_q != NFILTERS;
      end


      /*  each partial result is 4bits into out_int_q, of those, we have to reduce them to 1 bits
                We use 32 i comparators in 4 cycles as before
                Fixed Threshold for the moment
                1 cycle:                 for each i of the 32 comparators: out_int_n[i][0]   = out_int_q[0][i][3:0] > 4'b0111;
                ....
                4 cycle:                 for each i of the 32 comparators: out_int_n[i][0]   = out_int_q[3][i][3:0] > 4'b0111;
            */
      COMPARISON: begin
        state_read_n     = sel_out_int_q == NFILTERS ? STORE : COMPARISON;
        reset_data_valid = 1'b1;
        sel_out_int_n    = sel_out_int_q == NFILTERS ? '0 : sel_out_int_q + 2;
        store_out_int    = sel_out_int_q != NFILTERS;
        resetaddr_read   = sel_out_int_q == NFILTERS && loop_col_q != 1;
        nextrowaddr_read = sel_out_int_q == NFILTERS && loop_col_q == 1;
      end

      STORE: begin
        //{start_lsu0, start_lsu1, start_lsu2, start_lsu3}                 = ~{data_valid[0], data_valid[1], data_valid[2], data_valid[3]};
        start_lsu1       = ~data_valid[1];
        //                if(data_valid0)
        //assume both grant and valid being 1 soon or later
        state_read_n     = END;
        reset_data_valid = data_valid1;

        //New state
        if (loop_col_q != 1) begin
          reset_data_valid  = 1'b1;
          state_read_n      = READ_INPUT_FIRST;
          num_elem_n        = 9;
          store_num_elem    = 1'b1;
          copyaddr_read     = 1'b1;
          resetaddr_filter  = 1'b1;
          incaddr_store     = 1'b1;
          decrease_col_loop = 1'b1;
          reset_out_int     = 1'b1;
        end else begin
          if (loop_row_q != 1) begin
            decrease_row_loop = 1'b1;
            reset_data_valid  = 1'b1;
            state_read_n      = READ_INPUT_FIRST;
            num_elem_n        = 9;
            store_num_elem    = 1'b1;
            copyaddr_read     = 1'b1;
            resetaddr_filter  = 1'b1;
            incaddr_store     = 1'b1;
            reset_col_loop    = 1'b1;
            reset_out_int     = 1'b1;
          end
        end
      end

      END: begin
        if (~start_q) begin
          state_read_n = IDLE;
        end else events_1_o = 1'b1;
      end

      default: begin
      end

    endcase
  end


  tcdm_streamer tdcm0_str (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .tcdm_req_o    (tcdm_req_p0_o),
      .tcdm_gnt_i    (tcdm_gnt_p0_i),
      .tcdm_r_valid_i(tcdm_r_valid_p0_i),
      .start_i       (start_lsu0),
      .data_valid_o  (data_valid0)
  );

  tcdm_streamer tdcm1_str (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .tcdm_req_o    (tcdm_req_p1_o),
      .tcdm_gnt_i    (tcdm_gnt_p1_i),
      .tcdm_r_valid_i(tcdm_r_valid_p1_i),
      .start_i       (start_lsu1),
      .data_valid_o  (data_valid1)
  );

  tcdm_streamer tdcm2_str (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .tcdm_req_o    (tcdm_req_p2_o),
      .tcdm_gnt_i    (tcdm_gnt_p2_i),
      .tcdm_r_valid_i(tcdm_r_valid_p2_i),
      .start_i       (start_lsu2),
      .data_valid_o  (data_valid2)
  );

  tcdm_streamer tdcm3_str (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .tcdm_req_o    (tcdm_req_p3_o),
      .tcdm_gnt_i    (tcdm_gnt_p3_i),
      .tcdm_r_valid_i(tcdm_r_valid_p3_i),
      .start_i       (start_lsu3),
      .data_valid_o  (data_valid3)
  );


  always_comb begin

    real_address0 = read_address_q + {pixel_pos_q, 2'b00};
    real_address1 = read_address_q;
    real_address2 = read_address_q;
    real_address3 = read_address_q;
    if (state_read_q == READ_FILTERS) begin
      real_address0 = filter_address_q + 0;
      real_address1 = filter_address_q + 4;
      real_address2 = filter_address_q + 8;
      real_address3 = filter_address_q + 12;
    end else if (state_read_q == STORE) begin
      real_address0 = store_address_q + 0;
      real_address1 = store_address_q + 0;
      real_address2 = store_address_q + 0;
      real_address3 = store_address_q + 0;
    end

  end


  genvar i;
  generate
    for (i = 0; i < NFILTERS; i = i + 2) begin
      always_ff @(posedge clk_i or negedge rst_ni) begin
        if (~rst_ni) begin
          out_int_q[i][10:0]   <= '0;
          out_int_q[i+1][10:0] <= '0;
        end else begin
          if (store_out_int) begin
            if (sel_out_int_q[LOG_NFILTERS-1:0] == i) begin
              out_int_q[i][10:0]   <= out_int_n[10:0];
              out_int_q[i+1][10:0] <= out_int_n_1[10:0];
            end
          end
          if ((apb_hwce_psel_i && apb_hwce_enable_i && apb_hwce_pwrite_i) | reset_out_int) begin
            if (is_start) begin
              out_int_q[i][10:0]   <= '0;
              out_int_q[i+1][10:0] <= '0;
            end
          end
        end
      end
    end
  endgenerate

  generate
    for (i = 0; i < NFILTERS; i = i + 4) begin
      always_ff @(posedge clk_i or negedge rst_ni) begin
        if (~rst_ni) begin
          filter_q[i+0] <= '0;
          filter_q[i+1] <= '0;
          filter_q[i+2] <= '0;
          filter_q[i+3] <= '0;
        end else begin
          if (store_filter[0] && sel_out_int_q[LOG_NFILTERS-1:0] == i)
            filter_q[i+0] <= tcdm_r_rdata_p0;
          if (store_filter[1] && sel_out_int_q[LOG_NFILTERS-1:0] == i)
            filter_q[i+1] <= tcdm_r_rdata_p1;
          if (store_filter[2] && sel_out_int_q[LOG_NFILTERS-1:0] == i)
            filter_q[i+2] <= tcdm_r_rdata_p2;
          if (store_filter[3] && sel_out_int_q[LOG_NFILTERS-1:0] == i)
            filter_q[i+3] <= tcdm_r_rdata_p3;
          if (apb_hwce_psel_i && apb_hwce_enable_i && apb_hwce_pwrite_i) begin
            if (is_start) begin
              filter_q[i+0] <= '0;
              filter_q[i+1] <= '0;
              filter_q[i+2] <= '0;
              filter_q[i+3] <= '0;
            end
          end
        end
      end
    end
  endgenerate


  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      state_read_q <= IDLE;

      num_elem_q   <= '0;
      start_q = 1'b0;

      data_input_q           <= '0;

      sel_out_int_q          <= '0;
      data_valid             <= '0;

      read_address_q         <= '0;
      filter_address_q       <= '0;
      store_address_q        <= '0;
      pixel_pos_q            <= '0;
      next_row_q             <= '0;
      threshold              <= '0;
      configuration_sel      <= '0;
      data_input_xor_q       <= '0;
      gpio_val               <= '0;
      sw_event_q             <= '0;
      loop_col_q             <= '0;
      loop_row_q             <= '0;
      loop_user_q            <= '0;
      originalread_address_q <= '0;

    end else begin

      state_read_q <= state_read_n;

      if (store_num_elem) num_elem_q <= num_elem_n;

      if (decrease_col_loop) loop_col_q <= loop_col_q - 1;

      if (decrease_row_loop) begin
        loop_row_q <= loop_row_q - 1;
        loop_col_q <= loop_user_q;
      end

      if (store_data) data_input_q <= tcdm_r_rdata_p0;

      if (store_xor_intput) data_input_xor_q <= data_input_q;
      sel_out_int_q <= sel_out_int_n;

      if (reset_data_valid) data_valid <= '0;
      else begin
        if (data_valid3) data_valid[3] <= 1'b1;
        if (data_valid2) data_valid[2] <= 1'b1;
        if (data_valid1) data_valid[1] <= 1'b1;
        if (data_valid0) data_valid[0] <= 1'b1;
      end



      if (incaddr_read) begin
        pixel_pos_q <= pixel_pos_n;
        if (pixel_pos_q == 2) begin
          read_address_q <= read_address_q + next_row_q;
        end
      end

      if (resetaddr_read) begin
        originalread_address_q <= originalread_address_q + 4;
      end
      if (nextrowaddr_read) begin
        originalread_address_q <= originalread_address_q + next_row_q;
        ;
      end

      if (copyaddr_read) begin
        read_address_q <= originalread_address_q;
      end

      if (incaddr_filter) filter_address_q <= filter_address_q + 4 * 4;
      if (resetaddr_filter) filter_address_q <= filter_address_q - 2 * 9 * 4 * 4;

      if (incaddr_store) store_address_q = store_address_q + 4;

      if (apb_hwce_psel_i && apb_hwce_enable_i && apb_hwce_pwrite_i) begin
        if (is_tcdm_address_input) originalread_address_q <= apb_pwdata[19:0];
        if (is_tcdm_address_filter) filter_address_q <= apb_pwdata[19:0];
        if (is_tcdm_address_output) store_address_q <= apb_pwdata[19:0];
        if (is_start) begin
          start_q      <= apb_pwdata[0];
          data_input_q <= '0;
          pixel_pos_q  <= '0;
        end
        if (is_loop) begin
          loop_col_q  <= apb_pwdata[8:0];
          loop_row_q  <= apb_pwdata[8:0];
          loop_user_q <= apb_pwdata[8:0];
        end
        if (is_done) done_q <= apb_pwdata[0];
        if (is_next_row) next_row_q <= apb_pwdata[9:0];
        if (is_configuration_sel) begin
          configuration_sel <= apb_pwdata[15:0];
        end
        if (is_sw_event_sel) sw_event_q <= apb_pwdata[0];
        if (is_gpio) gpio_val <= apb_pwdata[2:0];
        if (is_threshold) threshold <= apb_pwdata[10:0];
      end

    end
  end

  //DECODER

  assign is_tcdm_address_input  = apb_hwce_addr == 7'h00;  //0x00
  assign is_tcdm_address_output = apb_hwce_addr == 7'h01;  //0x04
  assign is_tcdm_address_filter = apb_hwce_addr == 7'h02;  //0x08
  assign is_start               = apb_hwce_addr == 7'h03;  //0x0C
  assign is_done                = apb_hwce_addr == 7'h04;  //0x10
  assign is_next_row            = apb_hwce_addr == 7'h05;  //0x14
  assign is_configuration_sel   = apb_hwce_addr == 7'h06;  //0x18

  assign is_sw_event_sel        = apb_hwce_addr == 7'h08;  //0x20

  assign is_gpio                = apb_hwce_addr == 7'h09;  //0x24
  assign is_reset_data_store    = apb_hwce_addr == 7'h0A;  //0x28

  assign is_threshold           = apb_hwce_addr == 7'h0B;  //0x2C
  assign is_loop                = apb_hwce_addr == 7'h0C;  //0x30


  always_comb begin
    apb_hwce_prdata = '0;
    if (apb_hwce_psel_i & apb_hwce_enable_i & ~apb_hwce_pwrite_i) begin


      if (is_tcdm_address_input) apb_hwce_prdata = $unsigned(read_address_q);
      else if (is_tcdm_address_output) apb_hwce_prdata = $unsigned(store_address_q);
      else if (is_tcdm_address_filter) apb_hwce_prdata = $unsigned(filter_address_q);
      else if (is_start) apb_hwce_prdata = $unsigned(start_q);
      else if (is_num_elem) apb_hwce_prdata = $unsigned(num_elem_q);
      else if (is_loop) apb_hwce_prdata = $unsigned(loop_col_q);
      else if (is_done) apb_hwce_prdata = $unsigned(done_q);
      else if (is_sw_event_sel) apb_hwce_prdata = $unsigned(sw_event_q);
      else if (is_configuration_sel) apb_hwce_prdata = {16'hFFFF, configuration_sel};
      else apb_hwce_prdata = '0;
    end

  end


  assign apb_pwdata = $unsigned(
      {

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
      }
  );

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


  assign events_0_o = sw_event_q;

  assign tcdm_wdata_p1_0_o = data_to_store[0];
  assign tcdm_wdata_p1_1_o = data_to_store[1];
  assign tcdm_wdata_p1_2_o = data_to_store[2];
  assign tcdm_wdata_p1_3_o = data_to_store[3];
  assign tcdm_wdata_p1_4_o = data_to_store[4];
  assign tcdm_wdata_p1_5_o = data_to_store[5];
  assign tcdm_wdata_p1_6_o = data_to_store[6];
  assign tcdm_wdata_p1_7_o = data_to_store[7];
  assign tcdm_wdata_p1_8_o = data_to_store[8];
  assign tcdm_wdata_p1_9_o = data_to_store[9];
  assign tcdm_wdata_p1_10_o = data_to_store[10];
  assign tcdm_wdata_p1_11_o = data_to_store[11];
  assign tcdm_wdata_p1_12_o = data_to_store[12];
  assign tcdm_wdata_p1_13_o = data_to_store[13];
  assign tcdm_wdata_p1_14_o = data_to_store[14];
  assign tcdm_wdata_p1_15_o = data_to_store[15];
  assign tcdm_wdata_p1_16_o = data_to_store[16];
  assign tcdm_wdata_p1_17_o = data_to_store[17];
  assign tcdm_wdata_p1_18_o = data_to_store[18];
  assign tcdm_wdata_p1_19_o = data_to_store[19];
  assign tcdm_wdata_p1_20_o = data_to_store[20];
  assign tcdm_wdata_p1_21_o = data_to_store[21];
  assign tcdm_wdata_p1_22_o = data_to_store[22];
  assign tcdm_wdata_p1_23_o = data_to_store[23];
  assign tcdm_wdata_p1_24_o = data_to_store[24];
  assign tcdm_wdata_p1_25_o = data_to_store[25];
  assign tcdm_wdata_p1_26_o = data_to_store[26];
  assign tcdm_wdata_p1_27_o = data_to_store[27];
  assign tcdm_wdata_p1_28_o = data_to_store[28];
  assign tcdm_wdata_p1_29_o = data_to_store[29];
  assign tcdm_wdata_p1_30_o = data_to_store[30];
  assign tcdm_wdata_p1_31_o = data_to_store[31];


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

  assign tcdm_be = configuration_sel[15:12];

  assign gpio_oe_5_o = gpio_val[1];
  assign gpio_data_5_o = gpio_val[0];


endmodule
