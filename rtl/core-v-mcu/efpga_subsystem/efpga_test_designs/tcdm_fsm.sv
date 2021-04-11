// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


module tcdm_fsm (
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

    output logic tcdm_be_p0_0_o,
    output logic tcdm_be_p0_1_o,
    output logic tcdm_be_p0_2_o,
    output logic tcdm_be_p0_3_o,

    input logic tcdm_gnt_p0_i,

    input logic tcdm_r_valid_p0_i,

    input  logic apb_hwce_psel_i,
    input  logic apb_hwce_penable_i,
    input  logic apb_hwce_pwrite_i,
    input  logic apb_hwce_addr_i,
    output logic apb_hwce_prdata_o,
    input  logic apb_hwce_pwdata_0_i,
    input  logic apb_hwce_pwdata_1_i,
    input  logic apb_hwce_pwdata_2_i,
    input  logic apb_hwce_pwdata_3_i,
    input  logic apb_hwce_pwdata_4_i,
    input  logic apb_hwce_pwdata_5_i,
    input  logic apb_hwce_pwdata_6_i,
    input  logic apb_hwce_pwdata_7_i,
    input  logic apb_hwce_pwdata_8_i,
    input  logic apb_hwce_pwdata_9_i,
    input  logic apb_hwce_pwdata_10_i,
    input  logic apb_hwce_pwdata_11_i,
    input  logic apb_hwce_pwdata_12_i,
    input  logic apb_hwce_pwdata_13_i,
    input  logic apb_hwce_pwdata_14_i,
    input  logic apb_hwce_pwdata_15_i,
    input  logic apb_hwce_pwdata_16_i,
    input  logic apb_hwce_pwdata_17_i,
    input  logic apb_hwce_pwdata_18_i,
    input  logic apb_hwce_pwdata_19_i,

    output logic apb_hwce_ready_o

);


  logic [3:0] counter_n, counter_q;
  logic [19:0] address_q, address_n;
  logic increase_counter, done_n, done_q;
  logic [19:0] real_address;

  enum logic [1:0] {
    IDLE,
    WAIT_GNT,
    WAIT_RVALID
  }
      state_n, state_q;

  assign counter_n        = counter_q + 1;

  assign apb_hwce_ready_o = 1'b1;  //pragma attribute apb_hwce_ready_o pad out_buff
  assign tcdm_be_p0_0_o   = 1'b1;  //pragma attribute tcdm_be_p0_0_o   pad out_buff
  assign tcdm_be_p0_1_o   = 1'b1;  //pragma attribute tcdm_be_p0_1_o   pad out_buff
  assign tcdm_be_p0_2_o   = 1'b1;  //pragma attribute tcdm_be_p0_2_o   pad out_buff
  assign tcdm_be_p0_3_o   = 1'b1;  //pragma attribute tcdm_be_p0_3_o   pad out_buff
  assign tcdm_wen_p0_o    = 1'b0;  //pragma attribute tcdm_wen_p0_o    pad out_buff

  always_comb begin

    state_n          = state_q;
    tcdm_req_p0_o    = 1'b0;
    increase_counter = 1'b0;
    done_n           = 1'b0;

    unique case (state_q)

      IDLE: begin
        done_n = 1'b1;
        if (apb_hwce_psel_i && apb_hwce_penable_i && apb_hwce_pwrite_i & ~apb_hwce_addr_i) begin
          done_n  = 1'b0;
          state_n = WAIT_GNT;
        end
      end

      WAIT_GNT: begin
        tcdm_req_p0_o    = 1'b1;
        increase_counter = 1'b1;
        if (tcdm_gnt_p0_i) begin
          increase_counter = 1'b1;
          state_n          = WAIT_RVALID;
        end
      end

      WAIT_RVALID: begin
        if (tcdm_r_valid_p0_i) begin
          tcdm_req_p0_o    = counter_q != '1 ? 1'b1 : 1'b0;
          increase_counter = counter_q != '1 ? 1'b1 : 1'b0;
          if (tcdm_req_p0_o) begin
            if (~tcdm_gnt_p0_i) begin
              state_n = WAIT_GNT;
            end
          end else begin
            state_n = IDLE;
            done_n  = 1'b1;
          end
        end
      end

    endcase  // state_q

  end



  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      counter_q <= '0;
      state_q   <= IDLE;
      address_q <= address_q;
      done_q    <= 1'b1;
    end else begin
      state_q   <= state_n;
      counter_q <= increase_counter ? counter_n : counter_q;
      if (apb_hwce_psel_i && apb_hwce_penable_i && apb_hwce_pwrite_i) address_q <= address_n;
      done_q <= done_n;
    end
  end

  assign address_n = {
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

  assign apb_hwce_prdata_o     = (apb_hwce_psel_i & apb_hwce_penable_i & ~apb_hwce_pwrite_i & apb_hwce_addr_i) ? done_q : 1'b0;

  assign real_address = address_q + $unsigned({counter_q, 2'b00});

  assign tcdm_addr_p0_0_o = real_address[0];
  assign tcdm_addr_p0_1_o = real_address[1];
  assign tcdm_addr_p0_2_o = real_address[2];
  assign tcdm_addr_p0_3_o = real_address[3];
  assign tcdm_addr_p0_4_o = real_address[4];
  assign tcdm_addr_p0_5_o = real_address[5];
  assign tcdm_addr_p0_6_o = real_address[6];
  assign tcdm_addr_p0_7_o = real_address[7];
  assign tcdm_addr_p0_8_o = real_address[8];
  assign tcdm_addr_p0_9_o = real_address[9];
  assign tcdm_addr_p0_10_o = real_address[10];
  assign tcdm_addr_p0_11_o = real_address[11];
  assign tcdm_addr_p0_12_o = real_address[12];
  assign tcdm_addr_p0_13_o = real_address[13];
  assign tcdm_addr_p0_14_o = real_address[14];
  assign tcdm_addr_p0_15_o = real_address[15];
  assign tcdm_addr_p0_16_o = real_address[16];
  assign tcdm_addr_p0_17_o = real_address[17];
  assign tcdm_addr_p0_18_o = real_address[18];
  assign tcdm_addr_p0_19_o = real_address[19];

  assign tcdm_wdata_p0_0_o = counter_q[0];
  assign tcdm_wdata_p0_1_o = counter_q[1];
  assign tcdm_wdata_p0_2_o = counter_q[2];
  assign tcdm_wdata_p0_3_o = counter_q[3];
  assign tcdm_wdata_p0_4_o = 1'b0;  //pragma attribute tcdm_wdata_p0_4_o  pad out_buff
  assign tcdm_wdata_p0_5_o = 1'b0;  //pragma attribute tcdm_wdata_p0_5_o  pad out_buff
  assign tcdm_wdata_p0_6_o = 1'b0;  //pragma attribute tcdm_wdata_p0_6_o  pad out_buff
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

endmodule
