// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


`include "pulp_soc_defines.svh"

module lint_jtag_wrap #(
    parameter ADDRESS_WIDTH = 32,
    parameter DATA_WIDTH    = 32
) (
    input  logic                tck_i,
    input  logic                tdi_i,
    input  logic                trstn_i,
    output logic                tdo_o,
    input  logic                shift_dr_i,
    input  logic                pause_dr_i,
    input  logic                update_dr_i,
    input  logic                capture_dr_i,
    input  logic                lint_select_i,
    input  logic                clk_i,
    input  logic                rst_ni,
           XBAR_TCDM_BUS.Master jtag_lint_master
);


  // Top module
  adbg_lintonly_top #(
      .ADDR_WIDTH(ADDRESS_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
  ) dbg_module_i (
      // JTAG signals
      .tck_i  (tck_i),
      .tdi_i  (tdi_i),
      .tdo_o  (tdo_o),
      .trstn_i(trstn_i),

      // TAP states
      .shift_dr_i  (shift_dr_i),
      .pause_dr_i  (pause_dr_i),
      .update_dr_i (update_dr_i),
      .capture_dr_i(capture_dr_i),

      // Instructions
      .debug_select_i(lint_select_i),

      .clk_i (clk_i),
      .rstn_i(rst_ni),

      .lint_req_o    (jtag_lint_master.req),
      .lint_add_o    (jtag_lint_master.add),
      .lint_wen_o    (jtag_lint_master.wen),
      .lint_wdata_o  (jtag_lint_master.wdata),
      .lint_be_o     (jtag_lint_master.be),
      .lint_aux_o    (),
      .lint_gnt_i    (jtag_lint_master.gnt),
      .lint_r_aux_i  (),
      .lint_r_valid_i(jtag_lint_master.r_valid),
      .lint_r_rdata_i(jtag_lint_master.r_rdata),
      .lint_r_opc_i  (jtag_lint_master.r_opc)
  );

endmodule  // jtag_wrap
