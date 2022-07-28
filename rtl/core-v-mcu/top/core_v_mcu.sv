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
`include "pulp_peripheral_defines.svh"

module core_v_mcu #(
    parameter USE_FPU  = 0,
    parameter USE_HWPE = 0
) (
    input                                jtag_tck_i,
    input                                jtag_tdi_i,
    output                               jtag_tdo_o,
    input                                jtag_tms_i,
    input                                jtag_trst_i,
    input                                ref_clk_i,
    input                                rstn_i,
    input                                bootsel_i,
    input                                stm_i,
    input  [`N_IO-1:0]                   io_in_i,
    output [`N_IO-1:0]                   io_out_o,
    output [`N_IO-1:0][`NBIT_PADCFG-1:0] pad_cfg_o,
    output [`N_IO-1:0]                   io_oe_o
);

  localparam AXI_ADDR_WIDTH = 32;
  localparam AXI_CLUSTER_SOC_DATA_WIDTH = 64;
  localparam AXI_SOC_CLUSTER_DATA_WIDTH = 32;
  localparam AXI_CLUSTER_SOC_ID_WIDTH = 6;

  localparam AXI_USER_WIDTH = 6;
  localparam AXI_CLUSTER_SOC_STRB_WIDTH = AXI_CLUSTER_SOC_DATA_WIDTH / 8;
  localparam AXI_SOC_CLUSTER_STRB_WIDTH = AXI_SOC_CLUSTER_DATA_WIDTH / 8;

  localparam BUFFER_WIDTH = 8;
  localparam EVENT_WIDTH = 8;

  localparam CVP_ADDR_WIDTH = 32;
  localparam CVP_DATA_WIDTH = 32;


  //
  // OTHER PAD FRAME SIGNALS
  //



  logic                                   s_clk_in;  // clock in from pad
  logic                                   s_rstn;
  logic                                   s_pad_rstn;

  logic                                   s_jtag_tck;
  logic                                   s_jtag_tdi;
  logic                                   s_jtag_tdo;
  logic                                   s_jtag_tms;
  logic                                   s_jtag_trst;
  logic [    `N_IO-1:0]                   s_io_in;
  logic [    `N_IO-1:0]                   s_io_out;
  logic [    `N_IO-1:0]                   s_io_oe;


  //
  // SOC TO SAFE DOMAINS SIGNALS
  //

  logic                                   s_test_clk;
  logic                                   s_soc_tck;
  logic                                   s_soc_trstn;
  logic                                   s_soc_tms;
  logic                                   s_soc_tdi;

  logic                                   s_test_mode;
  logic                                   s_dft_cg_enable;

  //PERIO
  logic [ `N_PERIO-1:0]                   s_perio_out;
  logic [ `N_PERIO-1:0]                   s_perio_in;
  logic [ `N_PERIO-1:0]                   s_perio_oe;
  //APBIO
  logic [ `N_APBIO-1:0]                   s_apbio_out;
  logic [ `N_APBIO-1:0]                   s_apbio_in;
  logic [ `N_APBIO-1:0]                   s_apbio_oe;
  // FPGAIO
  logic [`N_FPGAIO-1:0]                   s_fpgaio_out;
  logic [`N_FPGAIO-1:0]                   s_fpgaio_in;
  logic [`N_FPGAIO-1:0]                   s_fpgaio_oe;

  logic                                   s_rstn_por;

  logic [    `N_IO-1:0][`NBIT_PADMUX-1:0] s_pad_mux_soc;

  logic [          1:0]                   s_selected_pad_mode;

  logic [          5:0]                   efpga_test_M;
  logic                                   efpga_test_fcb_pif_vldi;
  logic [          3:0]                   efpga_test_fcb_pif_di_l;
  logic [          3:0]                   efpga_test_fcb_pif_di_h;
  logic                                   efpga_test_fcb_pif_vldo_en;
  logic                                   efpga_test_fcb_pif_vldo;
  logic                                   efpga_test_fcb_pif_do_l_en;
  logic [          3:0]                   efpga_test_fcb_pif_do_l;
  logic                                   efpga_test_fcb_pif_do_h_en;
  logic [          3:0]                   efpga_test_fcb_pif_do_h;
  logic [          3:0]                   efpga_test_FB_SPE_OUT;
  logic [          3:0]                   efpga_test_FB_SPE_IN;
  logic                                   efpga_test_MLATCH;

  logic                                   s_bootsel;
  //
  // SAFE DOMAIN
  //
  safe_domain i_safe_domain (
      .rst_ni(rstn_i),
      .rst_no(s_rstn_por),

      // PAD control signals
      .pad_mux_i   (s_pad_mux_soc),
      // IO signals
      .io_out_o    (s_io_out),
      .io_in_i     (s_io_in),
      .io_oe_o     (s_io_oe),
      // PERIO signals
      .perio_out_i (s_perio_out),
      .perio_in_o  (s_perio_in),
      .perio_oe_i  (s_perio_oe),
      // GPIO signals
      .apbio_out_i (s_apbio_out),
      .apbio_in_o  (s_apbio_in),
      .apbio_oe_i  (s_apbio_oe),
      // FPGAIO signals
      .fpgaio_out_i(s_fpgaio_out),
      .fpgaio_in_o (s_fpgaio_in),
      .fpgaio_oe_i (s_fpgaio_oe)
  );

  //
  // SOC DOMAIN
  //

  logic [20:0] testio_i;  //
  logic [15:0] testio_o;  //


  assign io_out_o[20:0] = stm_i ? 0 : s_io_out[20:0];
  assign io_out_o[28:22] = stm_i ? 0 : s_io_out[28:22];
  assign io_out_o[38:37] = stm_i ? 0 : s_io_out[38:37];
  assign io_out_o[`N_IO-1:43] = stm_i ? 0 : s_io_out[`N_IO-1:43];
  assign io_oe_o[20:0] = stm_i ? 0 : s_io_oe[20:0];
  assign io_oe_o[28:22] = stm_i ? 0 : s_io_oe[28:22];
  assign io_oe_o[38:37] = stm_i ? 0 : s_io_oe[38:37];
  assign io_oe_o[`N_IO-1:43] = stm_i ? 0 : s_io_oe[`N_IO-1:43];


  assign io_out_o[32:29] = stm_i ? testio_o[3:0] : s_io_out[32:29];  //  efpga_test_fcb_pif_do_l_o;
  assign io_out_o[36:33] = stm_i ? testio_o[7:4] : s_io_out[36:33];  //  efpga_test_fcb_pif_do_h_o;
  assign io_out_o[42:39] = stm_i ? testio_o[11:8] : s_io_out[42:39];  // efpga_test_FB_SPE_OUT_o;
  assign io_out_o[21] = stm_i ? testio_o[14] : s_io_out[21];  // efpga_fcb_pif_vldo_o;
  assign io_oe_o[32:29] = stm_i ? {4{testio_o[12]}} : s_io_oe[32:29];  //  efpga_test_fcb_pif_do_l_o;
  assign io_oe_o[36:33] = stm_i ? {4{testio_o[13]}} : s_io_oe[36:33];  //  efpga_test_fcb_pif_do_h_o;
  assign io_oe_o[42:39] = stm_i ? 1 : s_io_oe[42:39];  // efpga_test_FB_SPE_OUT_o;
  assign io_oe_o[21] = stm_i ? testio_o[15] : s_io_oe[21];  // efpga_fcb_pif_vldo_o;

  assign s_io_in[`N_IO-1:0] = stm_i ? 0 : io_in_i[`N_IO-1:0];

  assign testio_i[3:0] = stm_i ? io_in_i[32:29] : 4'b0;  // efpga_test_fcb_pif_di_l_i
  assign testio_i[7:4] = stm_i ? io_in_i[36:33] : 4'b0;  // efpga_test_fcb_pif_di_h_i
  assign testio_i[11:8] = stm_i ? io_in_i[28:25] : 4'b0;  //efpga_test_FB_SPE_IN_i =
  assign testio_i[17:12] = stm_i ? io_in_i[12:7] : 6'b0;  // io_efpga_test_M_i =
  assign testio_i[18] = stm_i ? io_in_i[23] : 0;  // efpga_test_MLATCH_i =
  assign testio_i[19] = stm_i ? io_in_i[21] : 0;  //efpga_test_fcb_pif_vldi_i =
  assign testio_i[20] = stm_i;  //efpga_STM_i = testio_i[20];


  soc_domain #(
      .USE_FPU           (USE_FPU),
      .USE_HWPE          (USE_HWPE),
      .AXI_ADDR_WIDTH    (AXI_ADDR_WIDTH),
      .AXI_DATA_IN_WIDTH (AXI_CLUSTER_SOC_DATA_WIDTH),
      .AXI_DATA_OUT_WIDTH(AXI_SOC_CLUSTER_DATA_WIDTH),
      .AXI_ID_IN_WIDTH   (AXI_CLUSTER_SOC_ID_WIDTH),
      .AXI_USER_WIDTH    (AXI_USER_WIDTH),
      .BUFFER_WIDTH      (BUFFER_WIDTH),
      .EVNT_WIDTH        (EVENT_WIDTH)
  ) i_soc_domain (
      .ref_clk_i  (ref_clk_i),
      .test_clk_i (s_test_clk),
      .rstn_glob_i(s_rstn_por),

      .dft_test_mode_i(s_test_mode),
      .dft_cg_enable_i(s_dft_cg_enable),
      .bootsel_i(bootsel_i),
      .jtag_tck_i  (jtag_tck_i),
      .jtag_trst_ni(jtag_trst_i),
      .jtag_tms_i  (jtag_tms_i),
      .jtag_tdi_i  (jtag_tdi_i),
      .jtag_tdo_o  (jtag_tdo_o),
      // Pad control signals
      .pad_cfg_o   (pad_cfg_o),
      .pad_mux_o   (s_pad_mux_soc),
      // PERIO signals
      .perio_in_i  (s_perio_in),
      .perio_out_o (s_perio_out),
      .perio_oe_o  (s_perio_oe),
      // GPIO signals
      .apbio_in_i   (s_apbio_in),
      .apbio_out_o  (s_apbio_out),
      .apbio_oe_o   (s_apbio_oe),
      // FPGAIO signals
      .fpgaio_out_o(s_fpgaio_out),
      .fpgaio_in_i (s_fpgaio_in),
      .fpgaio_oe_o (s_fpgaio_oe),

      //eFPGA TEST MODE
      .testio_i(testio_i),
      .testio_o(testio_o)

  );

  assign s_test_mode     = '0;
  assign s_dft_cg_enable = '0;
  assign s_test_clk      = '0;

endmodule
