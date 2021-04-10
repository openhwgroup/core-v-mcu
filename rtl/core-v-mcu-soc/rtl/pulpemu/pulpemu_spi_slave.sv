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

module pulpemu_spi_slave #(
    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_USER_WIDTH = 1,
    parameter AXI_ID_WIDTH   = 16,
    parameter BUFFER_DEPTH   = 8,
    parameter DUMMY_CYCLES   = 32
) (
    input  logic        clk,
    input  logic        rst_n,
    // mode
    input  logic        mode_fmc_zynqn_i,
    // APB port (from Zynq PS)
    input  logic [31:0] zynq2pulp_apb_paddr,
    input  logic        zynq2pulp_apb_penable,
    output logic [31:0] zynq2pulp_apb_prdata,
    output logic [ 0:0] zynq2pulp_apb_pready,
    input  logic [ 0:0] zynq2pulp_apb_psel,
    output logic [ 0:0] zynq2pulp_apb_pslverr,
    input  logic [31:0] zynq2pulp_apb_pwdata,
    input  logic        zynq2pulp_apb_pwrite,
    // SPI port (to PULP)
    output logic        pulp_spi_clk_o,
    output logic        pulp_spi_csn0_o,
    output logic        pulp_spi_csn1_o,
    output logic        pulp_spi_csn2_o,
    output logic        pulp_spi_csn3_o,
    input  logic        pulp_spi_mode_i,  // SPI mode for pads
    input  logic        pulp_spi_sdo0_i,  // miso
    input  logic        pulp_spi_sdo1_i,  // miso
    input  logic        pulp_spi_sdo2_i,  // miso
    input  logic        pulp_spi_sdo3_i,  // miso
    output logic        pulp_spi_sdi0_o,  // mosi
    output logic        pulp_spi_sdi1_o,  // mosi
    output logic        pulp_spi_sdi2_o,  // mosi
    output logic        pulp_spi_sdi3_o,  // mosi
    // SPI port (from/to padframe)
    input  logic        pads2pulp_spi_clk_i,
    input  logic        pads2pulp_spi_csn_i,
    output logic        pads2pulp_spi_mode_o,  // SPI mode for pads
    output logic        pads2pulp_spi_sdo0_o,  // miso
    output logic        pads2pulp_spi_sdo1_o,  // miso
    output logic        pads2pulp_spi_sdo2_o,  // miso
    output logic        pads2pulp_spi_sdo3_o,  // miso
    input  logic        pads2pulp_spi_sdi0_i,  // mosi
    input  logic        pads2pulp_spi_sdi1_i,  // mosi
    input  logic        pads2pulp_spi_sdi2_i,  // mosi
    input  logic        pads2pulp_spi_sdi3_i  // mosi
);

  // zynq-spi signals
  logic zynq_pulp_spi_clk;
  logic zynq_pulp_spi_csn0;
  logic zynq_pulp_spi_csn1;
  logic zynq_pulp_spi_csn2;
  logic zynq_pulp_spi_csn3;
  logic zynq_pulp_spi_sdo0;
  logic zynq_pulp_spi_sdo1;
  logic zynq_pulp_spi_sdo2;
  logic zynq_pulp_spi_sdo3;
  logic zynq_pulp_spi_sdi0;
  logic zynq_pulp_spi_sdi1;
  logic zynq_pulp_spi_sdi2;
  logic zynq_pulp_spi_sdi3;

  apb_spi_master #(
      .BUFFER_DEPTH  (64),
      .APB_ADDR_WIDTH(12)
  ) apb_spi_master_i (
      .HCLK    (clk),
      .HRESETn (rst_n),
      .PADDR   (zynq2pulp_apb_paddr[11:0]),
      .PENABLE (zynq2pulp_apb_penable),
      .PRDATA  (zynq2pulp_apb_prdata),
      .PREADY  (zynq2pulp_apb_pready),
      .PSEL    (zynq2pulp_apb_psel),
      .PSLVERR (zynq2pulp_apb_pslverr),
      .PWDATA  (zynq2pulp_apb_pwdata),
      .PWRITE  (zynq2pulp_apb_pwrite),
      .events_o(),
      .spi_clk (zynq_pulp_spi_clk),
      .spi_csn0(zynq_pulp_spi_csn0),
      .spi_csn1(zynq_pulp_spi_csn1),
      .spi_csn2(zynq_pulp_spi_csn2),
      .spi_csn3(zynq_pulp_spi_csn3),
      .spi_mode(),  // we don't care about this as zynq doesn't go to pads
      .spi_sdo0(zynq_pulp_spi_sdo0),  // FIXME ?
      .spi_sdo1(zynq_pulp_spi_sdo1),
      .spi_sdo2(zynq_pulp_spi_sdo2),
      .spi_sdo3(zynq_pulp_spi_sdo3),
      .spi_sdi0(zynq_pulp_spi_sdi0),
      .spi_sdi1(zynq_pulp_spi_sdi1),
      .spi_sdi2(zynq_pulp_spi_sdi2),
      .spi_sdi3(zynq_pulp_spi_sdi3)
  );

  // -----------
  // biasing (muxing to pads/zynq)
  // -----------
  // zynq/pads ->> PULP
  assign pulp_spi_clk_o = (mode_fmc_zynqn_i == 1'b0) ? zynq_pulp_spi_clk : pads2pulp_spi_clk_i;
  assign pulp_spi_csn0_o = (mode_fmc_zynqn_i == 1'b0) ? zynq_pulp_spi_csn0 : pads2pulp_spi_csn_i;
  assign pulp_spi_csn1_o = (mode_fmc_zynqn_i == 1'b0) ? zynq_pulp_spi_csn1 : 1'b1;
  assign pulp_spi_csn2_o = (mode_fmc_zynqn_i == 1'b0) ? zynq_pulp_spi_csn2 : 1'b1;
  assign pulp_spi_csn3_o = (mode_fmc_zynqn_i == 1'b0) ? zynq_pulp_spi_csn3 : 1'b1;
  assign pulp_spi_sdi0_o = (mode_fmc_zynqn_i == 1'b0) ? zynq_pulp_spi_sdo0 : pads2pulp_spi_sdi0_i;
  assign pulp_spi_sdi1_o = (mode_fmc_zynqn_i == 1'b0) ? zynq_pulp_spi_sdo1 : pads2pulp_spi_sdi1_i;
  assign pulp_spi_sdi2_o = (mode_fmc_zynqn_i == 1'b0) ? zynq_pulp_spi_sdo2 : pads2pulp_spi_sdi2_i;
  assign pulp_spi_sdi3_o = (mode_fmc_zynqn_i == 1'b0) ? zynq_pulp_spi_sdo3 : pads2pulp_spi_sdi3_i;
  // PULP ->> zynq/pads (muxed, other one muted)
  assign zynq_pulp_spi_sdi0 = (mode_fmc_zynqn_i == 1'b0) ? pulp_spi_sdo0_i : 1'b0;
  assign zynq_pulp_spi_sdi1 = (mode_fmc_zynqn_i == 1'b0) ? pulp_spi_sdo1_i : 1'b0;
  assign zynq_pulp_spi_sdi2 = (mode_fmc_zynqn_i == 1'b0) ? pulp_spi_sdo2_i : 1'b0;
  assign zynq_pulp_spi_sdi3 = (mode_fmc_zynqn_i == 1'b0) ? pulp_spi_sdo3_i : 1'b0;
  assign pads2pulp_spi_mode_o = (mode_fmc_zynqn_i==1'b0) ? 'h0                : pulp_spi_mode_i;    // assign the padframe the mode from PULP
  assign pads2pulp_spi_sdo0_o = (mode_fmc_zynqn_i == 1'b0) ? 1'b0 : pulp_spi_sdo0_i;
  assign pads2pulp_spi_sdo1_o = (mode_fmc_zynqn_i == 1'b0) ? 1'b0 : pulp_spi_sdo1_i;
  assign pads2pulp_spi_sdo2_o = (mode_fmc_zynqn_i == 1'b0) ? 1'b0 : pulp_spi_sdo2_i;
  assign pads2pulp_spi_sdo3_o = (mode_fmc_zynqn_i == 1'b0) ? 1'b0 : pulp_spi_sdo3_i;

endmodule  // pulpemu_spi_slave
