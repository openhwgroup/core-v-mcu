//-----------------------------------------------------------------------------
// Title         : AXI64 to 32-bit TCDM Bridge Wrapper
//-----------------------------------------------------------------------------
// File          : axi64_to_lint_wrap.sv
// Author        : Manuel Eggimann  <meggimann@iis.ee.ethz.ch>
// Created       : 01.11.2020
//-----------------------------------------------------------------------------
// Description :
// This is a wrapper for the legacy 64-bit AXI to TCDM bridge that accepts
// interfaces at the inputs
//-----------------------------------------------------------------------------
// Copyright (C) 2013-2020 ETH Zurich, University of Bologna
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//-----------------------------------------------------------------------------

`include "tcdm_macros.svh"

module axi64_2_lint32_wrap #(
    parameter int unsigned AXI_USER_WIDTH,
    parameter int unsigned AXI_ID_WIDTH
) (
    input logic                clk_i,
    input logic                rst_ni,
    input logic                test_en_i,
          AXI_BUS.Slave        axi_master,
          XBAR_TCDM_BUS.Master tcdm_slaves[4]
);

  // *Do not change* The legacy wrapper was never tested for other bitwidths.
  localparam int unsigned AXI_ADDR_WIDTH = 32;
  localparam int unsigned AXI_DATA_WIDTH = 64;
  localparam int unsigned AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8;
  localparam int unsigned TCDM_DATA_WIDTH = 32;
  localparam int unsigned TCDM_ADDR_WIDTH = 32;
  localparam int unsigned TCDM_BE_WIDTH = TCDM_DATA_WIDTH / 8;

  //Explode the output TCDM interface into arrays of individual signals
  `TCDM_EXPLODE_ARRAY_DECLARE(tcdm_slaves, 4)
  for (genvar i = 0; i < 4; i++) begin
    `TCDM_SLAVE_EXPLODE(tcdm_slaves[i], tcdm_slaves, [i])
  end



  axi64_2_lint32 #(
      .AXI_ADDR_WIDTH   (AXI_ADDR_WIDTH),  //= 32,
      .AXI_DATA_WIDTH   (AXI_DATA_WIDTH),  //= 64,
      .AXI_STRB_WIDTH   (AXI_STRB_WIDTH),  //= 8,
      .AXI_USER_WIDTH   (AXI_USER_WIDTH),  //= 6,
      .AXI_ID_WIDTH     (AXI_ID_WIDTH),  //= 7,
      .BUFF_DEPTH_SLICES(4),  //= 4,
      .DATA_WIDTH       (TCDM_DATA_WIDTH),  //= 64,
      .BE_WIDTH         (TCDM_BE_WIDTH),  //= DATA_WIDTH/8,
      .ADDR_WIDTH       (TCDM_ADDR_WIDTH)  //= 10
  ) axi64_2_lint32_i (
      // AXI GLOBAL SIGNALS
      .clk        (clk_i),
      .rst_n      (rst_ni),
      .test_en_i  (test_en_i),
      // AXI INTERFACE
      .AW_ADDR_i  (axi_master.aw_addr),
      .AW_PROT_i  (axi_master.aw_prot),
      .AW_REGION_i(axi_master.aw_region),
      .AW_LEN_i   (axi_master.aw_len),
      .AW_SIZE_i  (axi_master.aw_size),
      .AW_BURST_i (axi_master.aw_burst),
      .AW_LOCK_i  (axi_master.aw_lock),
      .AW_CACHE_i (axi_master.aw_cache),
      .AW_QOS_i   (axi_master.aw_qos),
      .AW_ID_i    (axi_master.aw_id),
      .AW_USER_i  (axi_master.aw_user),
      .AW_VALID_i (axi_master.aw_valid),
      .AW_READY_o (axi_master.aw_ready),
      // ADDRESS READ CHANNEL
      .AR_ADDR_i  (axi_master.ar_addr),
      .AR_PROT_i  (axi_master.ar_prot),
      .AR_REGION_i(axi_master.ar_region),
      .AR_LEN_i   (axi_master.ar_len),
      .AR_SIZE_i  (axi_master.ar_size),
      .AR_BURST_i (axi_master.ar_burst),
      .AR_LOCK_i  (axi_master.ar_lock),
      .AR_CACHE_i (axi_master.ar_cache),
      .AR_QOS_i   (axi_master.ar_qos),
      .AR_ID_i    (axi_master.ar_id),
      .AR_USER_i  (axi_master.ar_user),
      .AR_VALID_i (axi_master.ar_valid),
      .AR_READY_o (axi_master.ar_ready),
      // WRITE CHANNEL
      .W_USER_i   (axi_master.w_user),
      .W_DATA_i   (axi_master.w_data),
      .W_STRB_i   (axi_master.w_strb),
      .W_LAST_i   (axi_master.w_last),
      .W_VALID_i  (axi_master.w_valid),
      .W_READY_o  (axi_master.w_ready),
      // WRITE RESPONSE CHANNEL
      .B_ID_o     (axi_master.b_id),
      .B_RESP_o   (axi_master.b_resp),
      .B_USER_o   (axi_master.b_user),
      .B_VALID_o  (axi_master.b_valid),
      .B_READY_i  (axi_master.b_ready),
      // READ CHANNEL
      .R_ID_o     (axi_master.r_id),
      .R_USER_o   (axi_master.r_user),
      .R_DATA_o   (axi_master.r_data),
      .R_RESP_o   (axi_master.r_resp),
      .R_LAST_o   (axi_master.r_last),
      .R_VALID_o  (axi_master.r_valid),
      .R_READY_i  (axi_master.r_ready),

      // LINT Interface - WRITE Request
      .data_W_req_o  (tcdm_slaves_req[1:0]),
      .data_W_gnt_i  (tcdm_slaves_gnt[1:0]),
      .data_W_wdata_o(tcdm_slaves_wdata[1:0]),
      .data_W_add_o  (tcdm_slaves_add[1:0]),
      .data_W_wen_o  (tcdm_slaves_wen[1:0]),
      .data_W_be_o   (tcdm_slaves_be[1:0]),
      .data_W_aux_o  (),  // We don't need this signal

      // LINT Interface - Response
      .data_W_r_valid_i(tcdm_slaves_r_valid[1:0]),
      .data_W_r_rdata_i(tcdm_slaves_r_rdata[1:0]),
      .data_W_r_opc_i  (tcdm_slaves_r_opc[1:0]),
      .data_W_r_aux_i  ('0),  // We don't need this signal

      // LINT Interface - READ Request
      .data_R_req_o  (tcdm_slaves_req[3:2]),
      .data_R_gnt_i  (tcdm_slaves_gnt[3:2]),
      .data_R_wdata_o(tcdm_slaves_wdata[3:2]),
      .data_R_add_o  (tcdm_slaves_add[3:2]),
      .data_R_wen_o  (tcdm_slaves_wen[3:2]),
      .data_R_be_o   (tcdm_slaves_be[3:2]),
      .data_R_aux_o  (),  // We don't need this signal

      // LINT Interface - Responseesponse
      .data_R_r_valid_i(tcdm_slaves_r_valid[3:2]),
      .data_R_r_rdata_i(tcdm_slaves_r_rdata[3:2]),
      .data_R_r_opc_i  (tcdm_slaves_r_opc[3:2]),
      .data_R_r_aux_i  ('0)  // We don't need this signal
  );

endmodule
