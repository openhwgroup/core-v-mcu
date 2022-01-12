//-----------------------------------------------------------------------------
// Title         : Lint to Axi Bridge Wrapper
//-----------------------------------------------------------------------------
// File          : lint2axi_wrap.sv
// Author        : Manuel Eggimann  <meggimann@iis.ee.ethz.ch>
// Created       : 30.10.2020
//-----------------------------------------------------------------------------
// Description :
// This is a wrapper for the legacy TCDM to AXI protocol converter. The converter
// converts from a single 32-bit TCDM protocol to a 32-bit AXI4 bus. Since the TCDM
// port can only perform either a read or write operation per cycle, the AXI port
// is only 50% utilized, either read channel or write channel active.
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


module lint2axi_wrap #(
    parameter int unsigned AXI_ID_WIDTH   = 1,
    parameter int unsigned AXI_USER_WIDTH = 32
) (
    input logic clk_i,
    input logic rst_ni,
    XBAR_TCDM_BUS.Slave master,
    AXI_BUS.Master slave
);

  //Do *not* change. Correct behavior is not tested for other values.
  localparam int unsigned ADDR_WIDTH = 32;
  localparam int unsigned DATA_WIDTH = 32;
  localparam int unsigned BE_WIDTH = DATA_WIDTH / 8;

  //Assign atomic attributes to zero. Otherwise the axi to axi_lite atop_filter will not work properly since it
  //receives X on the atop signal
  assign slave.aw_atop = '0;

  lint_2_axi #(
      .ADDR_WIDTH      (ADDR_WIDTH),
      .DATA_WIDTH      (DATA_WIDTH),
      .BE_WIDTH        (BE_WIDTH),
      .USER_WIDTH      (AXI_USER_WIDTH),
      .AXI_ID_WIDTH    (AXI_ID_WIDTH),
      .REGISTERED_GRANT("FALSE")  // "TRUE"|"FALSE"
  ) i_lint_2_axi (
      // Clock and Reset
      .clk_i,
      .rst_ni,

      .data_req_i  (master.req),
      .data_addr_i (master.add),
      .data_we_i   (~master.wen),
      .data_wdata_i(master.wdata),
      .data_be_i   (master.be),
      .data_aux_i  ('0),  // We don't need this signal
      .data_ID_i   ('0),  // We don't need this signal
      .data_gnt_o  (master.gnt),

      .data_rvalid_o(master.r_valid),
      .data_rdata_o (master.r_rdata),
      .data_ropc_o  (master.r_opc),
      .data_raux_o  (),  // We don't need this signal
      .data_rID_o   (),  // We don't need this signal
      // ---------------------------------------------------------
      // AXI TARG Port Declarations ------------------------------
      // ---------------------------------------------------------
      //AXI write address bus -------------- // USED// -----------
      .aw_id_o      (slave.aw_id),
      .aw_addr_o    (slave.aw_addr),
      .aw_len_o     (slave.aw_len),
      .aw_size_o    (slave.aw_size),
      .aw_burst_o   (slave.aw_burst),
      .aw_lock_o    (slave.aw_lock),
      .aw_cache_o   (slave.aw_cache),
      .aw_prot_o    (slave.aw_prot),
      .aw_region_o  (slave.aw_region),
      .aw_user_o    (slave.aw_user),
      .aw_qos_o     (slave.aw_qos),
      .aw_valid_o   (slave.aw_valid),
      .aw_ready_i   (slave.aw_ready),
      // ---------------------------------------------------------

      //AXI write data bus -------------- // USED// --------------
      .w_data_o (slave.w_data),
      .w_strb_o (slave.w_strb),
      .w_last_o (slave.w_last),
      .w_user_o (slave.w_user),
      .w_valid_o(slave.w_valid),
      .w_ready_i(slave.w_ready),
      // ---------------------------------------------------------

      //AXI write response bus -------------- // USED// ----------
      .b_id_i   (slave.b_id),
      .b_resp_i (slave.b_resp),
      .b_valid_i(slave.b_valid),
      .b_user_i (slave.b_user),
      .b_ready_o(slave.b_ready),
      // ---------------------------------------------------------

      //AXI read address bus -------------------------------------
      .ar_id_o    (slave.ar_id),
      .ar_addr_o  (slave.ar_addr),
      .ar_len_o   (slave.ar_len),
      .ar_size_o  (slave.ar_size),
      .ar_burst_o (slave.ar_burst),
      .ar_lock_o  (slave.ar_lock),
      .ar_cache_o (slave.ar_cache),
      .ar_prot_o  (slave.ar_prot),
      .ar_region_o(slave.ar_region),
      .ar_user_o  (slave.ar_user),
      .ar_qos_o   (slave.ar_qos),
      .ar_valid_o (slave.ar_valid),
      .ar_ready_i (slave.ar_ready),
      // ---------------------------------------------------------

      //AXI read data bus ----------------------------------------
      .r_id_i   (slave.r_id),
      .r_data_i (slave.r_data),
      .r_resp_i (slave.r_resp),
      .r_last_i (slave.r_last),
      .r_user_i (slave.r_user),
      .r_valid_i(slave.r_valid),
      .r_ready_o(slave.r_ready)
      // ---------------------------------------------------------
  );

endmodule : lint2axi_wrap
