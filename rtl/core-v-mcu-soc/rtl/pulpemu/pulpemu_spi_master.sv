// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


`define SPI_STD 2'b00
`define SPI_QUAD_TX 2'b01
`define SPI_QUAD_RX 2'b10

module pulpemu_spi_master #(
    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_USER_WIDTH = 0,
    parameter AXI_ID_WIDTH = 16,
    parameter BUFFER_DEPTH = 8,
    parameter DUMMY_CYCLES = 32,
    parameter SWITCH_ENDIANNESS = 1
) (
    // mode
    input  logic                        mode_fmc_zynqn_i,
    // AXI port (to Zynq PS)
    input  logic                        zynq_clk,
    input  logic                        zynq_rst_n,
    output logic                        zynq_axi_aw_valid_o,
    output logic [  AXI_ADDR_WIDTH-1:0] zynq_axi_aw_addr_o,
    output logic [                 2:0] zynq_axi_aw_prot_o,
    output logic [                 3:0] zynq_axi_aw_region_o,
    output logic [                 7:0] zynq_axi_aw_len_o,
    output logic [                 2:0] zynq_axi_aw_size_o,
    output logic [                 1:0] zynq_axi_aw_burst_o,
    output logic                        zynq_axi_aw_lock_o,
    output logic [                 3:0] zynq_axi_aw_cache_o,
    output logic [                 3:0] zynq_axi_aw_qos_o,
    output logic [    AXI_ID_WIDTH-1:0] zynq_axi_aw_id_o,
    output logic [  AXI_USER_WIDTH-1:0] zynq_axi_aw_user_o,
    input  logic                        zynq_axi_aw_ready_i,
    output logic                        zynq_axi_ar_valid_o,
    output logic [  AXI_ADDR_WIDTH-1:0] zynq_axi_ar_addr_o,
    output logic [                 2:0] zynq_axi_ar_prot_o,
    output logic [                 3:0] zynq_axi_ar_region_o,
    output logic [                 7:0] zynq_axi_ar_len_o,
    output logic [                 2:0] zynq_axi_ar_size_o,
    output logic [                 1:0] zynq_axi_ar_burst_o,
    output logic                        zynq_axi_ar_lock_o,
    output logic [                 3:0] zynq_axi_ar_cache_o,
    output logic [                 3:0] zynq_axi_ar_qos_o,
    output logic [    AXI_ID_WIDTH-1:0] zynq_axi_ar_id_o,
    output logic [  AXI_USER_WIDTH-1:0] zynq_axi_ar_user_o,
    input  logic                        zynq_axi_ar_ready_i,
    output logic                        zynq_axi_w_valid_o,
    output logic [  AXI_DATA_WIDTH-1:0] zynq_axi_w_data_o,
    output logic [AXI_DATA_WIDTH/8-1:0] zynq_axi_w_strb_o,
    output logic [  AXI_USER_WIDTH-1:0] zynq_axi_w_user_o,
    output logic                        zynq_axi_w_last_o,
    input  logic                        zynq_axi_w_ready_i,
    input  logic                        zynq_axi_r_valid_i,
    input  logic [  AXI_DATA_WIDTH-1:0] zynq_axi_r_data_i,
    input  logic [                 1:0] zynq_axi_r_resp_i,
    input  logic                        zynq_axi_r_last_i,
    input  logic [    AXI_ID_WIDTH-1:0] zynq_axi_r_id_i,
    input  logic [  AXI_USER_WIDTH-1:0] zynq_axi_r_user_i,
    output logic                        zynq_axi_r_ready_o,
    input  logic                        zynq_axi_b_valid_i,
    input  logic [                 1:0] zynq_axi_b_resp_i,
    input  logic [    AXI_ID_WIDTH-1:0] zynq_axi_b_id_i,
    input  logic [  AXI_USER_WIDTH-1:0] zynq_axi_b_user_i,
    output logic                        zynq_axi_b_ready_o,
    // SPI port (from PULP)
    input  logic                        pulp_spi_clk_i,
    input  logic                        pulp_spi_csn_i,
    input  logic [                 1:0] pulp_spi_mode_i,
    input  logic                        pulp_spi_sdo0_i,  // mosi
    input  logic                        pulp_spi_sdo1_i,  // mosi
    input  logic                        pulp_spi_sdo2_i,  // mosi
    input  logic                        pulp_spi_sdo3_i,  // mosi
    output logic                        pulp_spi_sdi0_o,  // miso
    output logic                        pulp_spi_sdi1_o,  // miso
    output logic                        pulp_spi_sdi2_o,  // miso
    output logic                        pulp_spi_sdi3_o,  // miso
    // SPI port (from/to padframe)
    output logic                        pads2pulp_spi_clk_o,
    output logic                        pads2pulp_spi_csn_o,
    output logic [                 1:0] pads2pulp_spi_mode_o,
    output logic                        pads2pulp_spi_sdo0_o,  // mosi
    output logic                        pads2pulp_spi_sdo1_o,  // mosi
    output logic                        pads2pulp_spi_sdo2_o,  // mosi
    output logic                        pads2pulp_spi_sdo3_o,  // mosi
    input  logic                        pads2pulp_spi_sdi0_i,  // miso
    input  logic                        pads2pulp_spi_sdi1_i,  // miso
    input  logic                        pads2pulp_spi_sdi2_i,  // miso
    input  logic                        pads2pulp_spi_sdi3_i  // miso
);

  // AXI valid internal signals
  logic zynq_axi_aw_valid_s;
  logic zynq_axi_ar_valid_s;
  logic zynq_axi_w_valid_s;
  logic zynq_axi_b_ready_s;
  logic zynq_axi_r_ready_s;

  // zynq to/from pulp signals
  logic zynq_pulp_spi_clk;
  logic zynq_pulp_spi_csn;
  logic zynq_pulp_spi_sdi0;
  logic zynq_pulp_spi_sdi1;
  logic zynq_pulp_spi_sdi2;
  logic zynq_pulp_spi_sdi3;
  logic zynq_pulp_spi_sdo0;
  logic zynq_pulp_spi_sdo1;
  logic zynq_pulp_spi_sdo2;
  logic zynq_pulp_spi_sdo3;

  // endianness conversion signals
  logic [AXI_ADDR_WIDTH-1:0] zynq_axi_aw_addr_int;
  logic [AXI_ADDR_WIDTH-1:0] zynq_axi_ar_addr_int;
  logic [AXI_ADDR_WIDTH-1:0] zynq_axi_w_data_int;
  logic [AXI_ADDR_WIDTH-1:0] zynq_axi_r_data_int;

  axi_spi_slave #(
      .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
      .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
      .AXI_USER_WIDTH(AXI_USER_WIDTH),
      .AXI_ID_WIDTH  (AXI_ID_WIDTH),
      .DUMMY_CYCLES  (DUMMY_CYCLES)
  ) axi_spi_slave_i (
      .test_mode           (1'b0),
      .spi_sclk            (zynq_pulp_spi_clk),
      .spi_cs              (zynq_pulp_spi_csn),
      .spi_mode            (),
      .spi_sdi0            (zynq_pulp_spi_sdi0),
      .spi_sdi1            (zynq_pulp_spi_sdi1),
      .spi_sdi2            (zynq_pulp_spi_sdi2),
      .spi_sdi3            (zynq_pulp_spi_sdi3),
      .spi_sdo0            (zynq_pulp_spi_sdo0),
      .spi_sdo1            (zynq_pulp_spi_sdo1),
      .spi_sdo2            (zynq_pulp_spi_sdo2),
      .spi_sdo3            (zynq_pulp_spi_sdo3),
      .axi_aclk            (zynq_clk),
      .axi_aresetn         (zynq_rst_n),
      .axi_master_aw_valid (zynq_axi_aw_valid_s),
      .axi_master_aw_addr  (zynq_axi_aw_addr_int),
      .axi_master_aw_prot  (zynq_axi_aw_prot_o),
      .axi_master_aw_region(zynq_axi_aw_region_o),
      .axi_master_aw_len   (zynq_axi_aw_len_o),
      .axi_master_aw_size  (zynq_axi_aw_size_o),
      .axi_master_aw_burst (zynq_axi_aw_burst_o),
      .axi_master_aw_lock  (zynq_axi_aw_lock_o),
      .axi_master_aw_cache (zynq_axi_aw_cache_o),
      .axi_master_aw_qos   (zynq_axi_aw_qos_o),
      .axi_master_aw_id    (zynq_axi_aw_id_o),
      .axi_master_aw_user  (zynq_axi_aw_user_o),
      .axi_master_aw_ready (zynq_axi_aw_ready_i),
      .axi_master_ar_valid (zynq_axi_ar_valid_s),
      .axi_master_ar_addr  (zynq_axi_ar_addr_int),
      .axi_master_ar_prot  (zynq_axi_ar_prot_o),
      .axi_master_ar_region(zynq_axi_ar_region_o),
      .axi_master_ar_len   (zynq_axi_ar_len_o),
      .axi_master_ar_size  (zynq_axi_ar_size_o),
      .axi_master_ar_burst (zynq_axi_ar_burst_o),
      .axi_master_ar_lock  (zynq_axi_ar_lock_o),
      .axi_master_ar_cache (zynq_axi_ar_cache_o),
      .axi_master_ar_qos   (zynq_axi_ar_qos_o),
      .axi_master_ar_id    (zynq_axi_ar_id_o),
      .axi_master_ar_user  (zynq_axi_ar_user_o),
      .axi_master_ar_ready (zynq_axi_ar_ready_i),
      .axi_master_w_valid  (zynq_axi_w_valid_s),
      .axi_master_w_data   (zynq_axi_w_data_int),
      .axi_master_w_strb   (zynq_axi_w_strb_o),
      .axi_master_w_user   (zynq_axi_w_user_o),
      .axi_master_w_last   (zynq_axi_w_last_o),
      .axi_master_w_ready  (zynq_axi_w_ready_i),
      .axi_master_r_valid  (zynq_axi_r_valid_i),
      .axi_master_r_data   (zynq_axi_r_data_int),
      .axi_master_r_resp   (zynq_axi_r_resp_i),
      .axi_master_r_last   (zynq_axi_r_last_i),
      .axi_master_r_id     (zynq_axi_r_id_i),
      .axi_master_r_user   (zynq_axi_r_user_i),
      .axi_master_r_ready  (zynq_axi_r_ready_s),
      .axi_master_b_valid  (zynq_axi_b_valid_i),
      .axi_master_b_resp   (zynq_axi_b_resp_i),
      .axi_master_b_id     (zynq_axi_b_id_i),
      .axi_master_b_user   (zynq_axi_b_user_i),
      .axi_master_b_ready  (zynq_axi_b_ready_s)
  );

  // endianness conversion
  generate
    if (SWITCH_ENDIANNESS) begin : switch_endianness_gen
      assign zynq_axi_r_data_int = {
        zynq_axi_r_data_i[7:0],
        zynq_axi_r_data_i[15:8],
        zynq_axi_r_data_i[23:16],
        zynq_axi_r_data_i[31:24]
      };
      assign zynq_axi_w_data_o = {
        zynq_axi_w_data_int[7:0],
        zynq_axi_w_data_int[15:8],
        zynq_axi_w_data_int[23:16],
        zynq_axi_w_data_int[31:24]
      };
      assign zynq_axi_aw_addr_o = {
        zynq_axi_aw_addr_int[7:0],
        zynq_axi_aw_addr_int[15:8],
        zynq_axi_aw_addr_int[23:16],
        zynq_axi_aw_addr_int[31:24]
      };
      assign zynq_axi_ar_addr_o = {
        zynq_axi_ar_addr_int[7:0],
        zynq_axi_ar_addr_int[15:8],
        zynq_axi_ar_addr_int[23:16],
        zynq_axi_ar_addr_int[31:24]
      };
    end else begin : no_switch_endianness_gen
      assign zynq_axi_r_data_int = zynq_axi_r_data_i;
      assign zynq_axi_w_data_o   = zynq_axi_w_data_int;
      assign zynq_axi_aw_addr_o  = zynq_axi_aw_addr_int;
      assign zynq_axi_ar_addr_o  = zynq_axi_ar_addr_int;
    end
  endgenerate

  // ----------
  // mux to zynq/pads
  // ----------
  // zynq / pads ->> PULP
  assign zynq_axi_aw_valid_o = (mode_fmc_zynqn_i == 1'b0) ? zynq_axi_aw_valid_s : 1'b0;
  assign zynq_axi_ar_valid_o = (mode_fmc_zynqn_i == 1'b0) ? zynq_axi_ar_valid_s : 1'b0;
  assign zynq_axi_w_valid_o = (mode_fmc_zynqn_i == 1'b0) ? zynq_axi_w_valid_s : 1'b0;
  assign zynq_axi_b_ready_o = (mode_fmc_zynqn_i == 1'b0) ? zynq_axi_b_ready_s : 1'b0;
  assign zynq_axi_r_ready_o = (mode_fmc_zynqn_i == 1'b0) ? zynq_axi_r_ready_s : 1'b0;
  assign pulp_spi_sdi0_o = (mode_fmc_zynqn_i == 1'b0) ? zynq_pulp_spi_sdo0 : pads2pulp_spi_sdi0_i;
  assign pulp_spi_sdi1_o = (mode_fmc_zynqn_i == 1'b0) ? zynq_pulp_spi_sdo1 : pads2pulp_spi_sdi1_i;
  assign pulp_spi_sdi2_o = (mode_fmc_zynqn_i == 1'b0) ? zynq_pulp_spi_sdo2 : pads2pulp_spi_sdi2_i;
  assign pulp_spi_sdi3_o = (mode_fmc_zynqn_i == 1'b0) ? zynq_pulp_spi_sdo3 : pads2pulp_spi_sdi3_i;
  // PULP ->> zynq / pads
  assign zynq_pulp_spi_clk = (mode_fmc_zynqn_i == 1'b0) ? pulp_spi_clk_i : 1'b0;
  assign zynq_pulp_spi_csn    = (mode_fmc_zynqn_i==1'b0) ? pulp_spi_csn_i      : 1'b1; //leave cs high for off
  assign zynq_pulp_spi_sdi0 = (mode_fmc_zynqn_i == 1'b0) ? pulp_spi_sdo0_i : 1'b0;
  assign zynq_pulp_spi_sdi1 = (mode_fmc_zynqn_i == 1'b0) ? pulp_spi_sdo1_i : 1'b0;
  assign zynq_pulp_spi_sdi2 = (mode_fmc_zynqn_i == 1'b0) ? pulp_spi_sdo2_i : 1'b0;
  assign zynq_pulp_spi_sdi3 = (mode_fmc_zynqn_i == 1'b0) ? pulp_spi_sdo3_i : 1'b0;
  assign pads2pulp_spi_clk_o = (mode_fmc_zynqn_i == 1'b0) ? 1'b0 : pulp_spi_clk_i;
  assign pads2pulp_spi_csn_o = (mode_fmc_zynqn_i == 1'b0) ? 1'b1 : pulp_spi_csn_i;
  assign pads2pulp_spi_mode_o = (mode_fmc_zynqn_i==1'b0) ? 'h0                 : pulp_spi_mode_i;    // assign the padframe the mode from PULP
  assign pads2pulp_spi_sdo0_o = (mode_fmc_zynqn_i == 1'b0) ? 1'b0 : pulp_spi_sdo0_i;
  assign pads2pulp_spi_sdo1_o = (mode_fmc_zynqn_i == 1'b0) ? 1'b0 : pulp_spi_sdo1_i;
  assign pads2pulp_spi_sdo2_o = (mode_fmc_zynqn_i == 1'b0) ? 1'b0 : pulp_spi_sdo2_i;
  assign pads2pulp_spi_sdo3_o = (mode_fmc_zynqn_i == 1'b0) ? 1'b0 : pulp_spi_sdo3_i;

endmodule  // pulpemu_spi_slave
