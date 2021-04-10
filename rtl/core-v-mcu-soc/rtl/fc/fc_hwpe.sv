// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


module fc_hwpe #(
    parameter N_MASTER_PORT = 4,
    parameter ID_WIDTH = 8,
    parameter APB_ADDR_WIDTH = 32
) (
    input logic clk_i,
    input logic rst_ni,
    input logic test_mode_i,

    XBAR_TCDM_BUS.Master hwacc_xbar_master[N_MASTER_PORT-1:0],
    APB_BUS.Slave        hwacc_cfg_slave,

    output logic [1:0] evt_o,
    output logic       busy_o
);

  logic [N_MASTER_PORT-1:0]         tcdm_req;
  logic [N_MASTER_PORT-1:0]         tcdm_gnt;
  logic [N_MASTER_PORT-1:0][32-1:0] tcdm_add;
  logic [N_MASTER_PORT-1:0]         tcdm_wen;
  logic [N_MASTER_PORT-1:0][4 -1:0] tcdm_be;
  logic [N_MASTER_PORT-1:0][32-1:0] tcdm_wdata;
  logic [N_MASTER_PORT-1:0][32-1:0] tcdm_r_rdata;
  logic [N_MASTER_PORT-1:0]         tcdm_r_valid;

  logic                             periph_req;
  logic                             periph_gnt;
  logic [           32-1:0]         periph_add;
  logic                             periph_we;
  logic [           4 -1:0]         periph_be;
  logic [           32-1:0]         periph_wdata;
  logic [     ID_WIDTH-1:0]         periph_id;
  logic [           32-1:0]         periph_r_rdata;
  logic                             periph_r_valid;
  logic [     ID_WIDTH-1:0]         periph_r_id;

  logic [              3:0]         s_evt;

  apb2per #(
      .PER_ADDR_WIDTH(32),
      .APB_ADDR_WIDTH(APB_ADDR_WIDTH)
  ) i_apb2per (
      .clk_i               (clk_i),
      .rst_ni              (rst_ni),
      .PADDR               (hwacc_cfg_slave.paddr),
      .PWDATA              (hwacc_cfg_slave.pwdata),
      .PWRITE              (hwacc_cfg_slave.pwrite),
      .PSEL                (hwacc_cfg_slave.psel),
      .PENABLE             (hwacc_cfg_slave.penable),
      .PRDATA              (hwacc_cfg_slave.prdata),
      .PREADY              (hwacc_cfg_slave.pready),
      .PSLVERR             (hwacc_cfg_slave.pslverr),
      .per_master_req_o    (periph_req),
      .per_master_add_o    (periph_add),
      .per_master_we_o     (periph_we),
      .per_master_wdata_o  (periph_wdata),
      .per_master_be_o     (periph_be),
      .per_master_gnt_i    (periph_gnt),
      .per_master_r_valid_i(periph_r_valid),
      .per_master_r_opc_i  (periph_r_opc),
      .per_master_r_rdata_i(periph_r_rdata)
  );

  mac_top_wrap #(
      .ID(ID_WIDTH)
  ) i_mac_top_wrap (
      .clk_i         (clk_i),
      .rst_ni        (rst_ni),
      .test_mode_i   (test_mode_i),
      .tcdm_req      (tcdm_req),
      .tcdm_gnt      (tcdm_gnt),
      .tcdm_add      (tcdm_add),
      .tcdm_wen      (tcdm_wen),
      .tcdm_be       (tcdm_be),
      .tcdm_data     (tcdm_wdata),
      .tcdm_r_data   (tcdm_r_rdata),
      .tcdm_r_valid  (tcdm_r_valid),
      .periph_req    (periph_req),
      .periph_gnt    (periph_gnt),
      .periph_add    (periph_add),
      .periph_wen    (~periph_we),
      .periph_be     (periph_be),
      .periph_data   (periph_wdata),
      .periph_id     ('0),
      .periph_r_data (periph_r_rdata),
      .periph_r_valid(periph_r_valid),
      .periph_r_id   (periph_r_id),
      .evt_o         (s_evt)
  );
  assign busy_o = 1'b1;
  assign evt_o  = s_evt[0];

  genvar i;
  generate
    for (i = 0; i < 4; i++) begin : hwacc_binding
      assign hwacc_xbar_master[i].req   = tcdm_req[i];
      assign hwacc_xbar_master[i].add   = tcdm_add[i];
      assign hwacc_xbar_master[i].wen   = tcdm_wen[i];
      assign hwacc_xbar_master[i].wdata = tcdm_wdata[i];
      assign hwacc_xbar_master[i].be    = tcdm_be[i];
      // response channel
      assign tcdm_gnt[i]                = hwacc_xbar_master[i].gnt;
      assign tcdm_r_rdata[i]            = hwacc_xbar_master[i].r_rdata;
      assign tcdm_r_valid[i]            = hwacc_xbar_master[i].r_valid;
    end
  endgenerate

endmodule  // acc_subsystem
