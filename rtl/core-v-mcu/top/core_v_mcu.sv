// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`include "pulp_soc_defines.sv"
`include "pulp_peripheral_defines.svh"

module core_v_mcu #(
    parameter USE_FPU  = 1,
    parameter USE_HWPE = 1
) (
   input              jtag_tck_i,
   input              jtag_tdi_i,
   output             jtag_tdo_o,
   input              jtag_tms_i,
   input              jtag_trst_i,
   input              ref_clk_i,
   input              rstn_i,
   input              bootsel_i,
   input [`N_IO-1:0]  io_in_i,
   output [`N_IO-1:0] io_out_o,
   output [`N_IO-1:0][`NBIT_PADCFG-1:0] pad_cfg_o,
   output [`N_IO-1:0] io_oe_o
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
  // PAD FRAME TO PAD CONTROL SIGNALS
  //

//  logic [       `N_IO-1:0][`NBIT_PADCFG-1:0] s_pad_cfg;

//  logic [       `N_IO-1:0]                   s_io_out;
//  logic [       `N_IO-1:0]                   s_io_oe;
//  logic [       `N_IO-1:0]                   s_io_in;


  //
  // OTHER PAD FRAME SIGNALS
  //

  logic                                      s_ref_clk;
  logic                                      s_clk_in;  // clock in from pad
  logic                                      s_rstn;
  logic                                      s_pad_rstn;

  logic                                      s_jtag_tck;
  logic                                      s_jtag_tdi;
  logic                                      s_jtag_tdo;
  logic                                      s_jtag_tms;
  logic                                      s_jtag_trst;

  //
  // SOC TO SAFE DOMAINS SIGNALS
  //

  logic                                      s_test_clk;
  logic                                      s_slow_clk;

  logic                                      s_sel_fll_clk;

  logic [            11:0]                   s_pm_cfg_data;
  logic                                      s_pm_cfg_req;
  logic                                      s_pm_cfg_ack;

  logic                                      s_cluster_busy;

  logic                                      s_soc_tck;
  logic                                      s_soc_trstn;
  logic                                      s_soc_tms;
  logic                                      s_soc_tdi;

  logic                                      s_test_mode;
  logic                                      s_dft_cg_enable;
  logic                                      s_mode_select;
  //PERIO
  logic [    `N_PERIO-1:0]                   s_perio_out;
  logic [    `N_PERIO-1:0]                   s_perio_in;
  logic [    `N_PERIO-1:0]                   s_perio_oe;
  //APBIO
  logic [    `N_APBIO-1:0]                   s_apbio_out;
  logic [    `N_APBIO-1:0]                   s_apbio_in;
  logic [    `N_APBIO-1:0]                   s_apbio_oe;
  // FPGAIO
  logic [   `N_FPGAIO-1:0]                   s_fpgaio_out;
  logic [   `N_FPGAIO-1:0]                   s_fpgaio_in;
  logic [   `N_FPGAIO-1:0]                   s_fpgaio_oe;

  logic                                      s_efpga_clk;
  logic                                      s_fpga_clk_1_i;
  logic                                      s_fpga_clk_2_i;
  logic                                      s_fpga_clk_3_i;
  logic                                      s_fpga_clk_4_i;
  logic                                      s_fpga_clk_5_i;

  logic                                      s_rf_tx_clk;
  logic                                      s_rf_tx_oeb;
  logic                                      s_rf_tx_enb;
  logic                                      s_rf_tx_mode;
  logic                                      s_rf_tx_vsel;
  logic                                      s_rf_tx_data;
  logic                                      s_rf_rx_clk;
  logic                                      s_rf_rx_enb;
  logic                                      s_rf_rx_data;

  logic                                      s_uart_tx;
  logic                                      s_uart_rx;

  logic                                      s_i2c0_scl_out;
  logic                                      s_i2c0_scl_in;
  logic                                      s_i2c0_scl_oe;
  logic                                      s_i2c0_sda_out;
  logic                                      s_i2c0_sda_in;
  logic                                      s_i2c0_sda_oe;
  logic                                      s_i2c1_scl_out;
  logic                                      s_i2c1_scl_in;
  logic                                      s_i2c1_scl_oe;
  logic                                      s_i2c1_sda_out;
  logic                                      s_i2c1_sda_in;
  logic                                      s_i2c1_sda_oe;
  logic                                      s_i2s_sd0_in;
  logic                                      s_i2s_sd1_in;
  logic                                      s_i2s_sck_in;
  logic                                      s_i2s_ws_in;
  logic                                      s_i2s_sck0_out;
  logic                                      s_i2s_ws0_out;
  logic [             1:0]                   s_i2s_mode0_out;
  logic                                      s_i2s_sck1_out;
  logic                                      s_i2s_ws1_out;
  logic [             1:0]                   s_i2s_mode1_out;
  logic                                      s_i2s_slave_sck_oe;
  logic                                      s_i2s_slave_ws_oe;
  logic                                      s_spi_master0_csn0;
  logic                                      s_spi_master0_csn1;
  logic                                      s_spi_master0_sck;
  logic                                      s_spi_master0_sdi0;
  logic                                      s_spi_master0_sdi1;
  logic                                      s_spi_master0_sdi2;
  logic                                      s_spi_master0_sdi3;
  logic                                      s_spi_master0_sdo0;
  logic                                      s_spi_master0_sdo1;
  logic                                      s_spi_master0_sdo2;
  logic                                      s_spi_master0_sdo3;
  logic                                      s_spi_master0_oen0;
  logic                                      s_spi_master0_oen1;
  logic                                      s_spi_master0_oen2;
  logic                                      s_spi_master0_oen3;

  logic                                      s_spi_master1_csn0;
  logic                                      s_spi_master1_csn1;
  logic                                      s_spi_master1_sck;
  logic                                      s_spi_master1_sdi;
  logic                                      s_spi_master1_sdo;
  logic [             1:0]                   s_spi_master1_mode;

  logic                                      s_sdio_clk;
  logic                                      s_sdio_cmdi;
  logic                                      s_sdio_cmdo;
  logic                                      s_sdio_cmd_oen;
  logic [             3:0]                   s_sdio_datai;
  logic [             3:0]                   s_sdio_datao;
  logic [             3:0]                   s_sdio_data_oen;


  logic                                      s_cam_pclk;
  logic [             7:0]                   s_cam_data;
  logic                                      s_cam_hsync;
  logic                                      s_cam_vsync;

  logic                                      s_jtag_shift_dr;
  logic                                      s_jtag_update_dr;
  logic                                      s_jtag_capture_dr;

  logic                                      s_axireg_sel;
  logic                                      s_axireg_tdi;
  logic                                      s_axireg_tdo;

  logic [             7:0]                   s_soc_jtag_regi;
  logic [             7:0]                   s_soc_jtag_rego;

  logic                                      s_rstn_por;

  logic                                      s_dma_pe_irq_ack;
  logic                                      s_dma_pe_irq_valid;

  logic [       `N_IO-1:0][`NBIT_PADMUX-1:0] s_pad_mux_soc;
//  logic [       `N_IO-1:0][`NBIT_PADCFG-1:0] s_pad_cfg_soc;
  logic [             1:0]                   s_selected_pad_mode;

  logic [             5:0]                   efpga_test_M;
  logic                                      efpga_test_fcb_pif_vldi;
  logic [             3:0]                   efpga_test_fcb_pif_di_l;
  logic [             3:0]                   efpga_test_fcb_pif_di_h;
  logic                                      efpga_test_fcb_pif_vldo_en;
  logic                                      efpga_test_fcb_pif_vldo;
  logic                                      efpga_test_fcb_pif_do_l_en;
  logic [             3:0]                   efpga_test_fcb_pif_do_l;
  logic                                      efpga_test_fcb_pif_do_h_en;
  logic [             3:0]                   efpga_test_fcb_pif_do_h;
  logic [             3:0]                   efpga_test_FB_SPE_OUT;
  logic [             3:0]                   efpga_test_FB_SPE_IN;
  logic                                      efpga_test_MLATCH;

  logic [      `N_SPI-1:0]                   s_spi_clk;
  logic [      `N_SPI-1:0][             3:0] s_spi_csn;
  logic [      `N_SPI-1:0][             3:0] s_spi_oen;
  logic [      `N_SPI-1:0][             3:0] s_spi_sdo;
  logic [      `N_SPI-1:0][             3:0] s_spi_sdi;

  logic [      `N_I2C-1:0]                   s_i2c_scl_in;
  logic [      `N_I2C-1:0]                   s_i2c_scl_out;
  logic [      `N_I2C-1:0]                   s_i2c_scl_oe;
  logic [      `N_I2C-1:0]                   s_i2c_sda_in;
  logic [      `N_I2C-1:0]                   s_i2c_sda_out;
  logic [      `N_I2C-1:0]                   s_i2c_sda_oe;


  //
  // SOC TO CLUSTER DOMAINS SIGNALS
  //
  // PULPissimo doens't have a cluster so we ignore them

  logic                                      s_dma_pe_evt_ack;
  logic                                      s_dma_pe_evt_valid;
  logic                                      s_dma_pe_int_ack;
  logic                                      s_dma_pe_int_valid;
  logic                                      s_pf_evt_ack;
  logic                                      s_pf_evt_valid;

  logic [BUFFER_WIDTH-1:0]                   s_event_writetoken;
  logic [BUFFER_WIDTH-1:0]                   s_event_readpointer;
  logic [ EVENT_WIDTH-1:0]                   s_event_dataasync;
  logic                                      s_wd_expired;



  //
  // OTHER PAD FRAME SIGNALS
  //
  logic                                      s_bootsel;
  logic                                      debug1;
  logic                                      debug0;
/*
`ifdef VERILATOR
  logic [`N_IO-1:0] io_pos;

  assign s_clk_in = io[6];
  assign s_rstn = (io[6] == 1) ? io[7] : io_pos[7];
  assign s_jtag_tck = (io[6] == 1) ? io[8] : io_pos[8];
  assign s_jtag_tdi = (io[6] == 1) ? io[9] : io_pos[9];
  assign io[10] = s_jtag_tdo;
  assign s_jtag_tms = (io[6] == 1) ? io[11] : io_pos[11];
  assign s_jtag_trst = (io[6] == 1) ? io[12] : io_pos[12];
  assign s_bootsel = (io[6] == 1) ? io[15] : io_pos[15];

  always @(posedge io[6]) io_pos <= io;
`else
  //
  // PAD FRAME
  //
  assign s_rstn = ~(~s_pad_rstn | s_wd_expired);

  pad_frame i_pad_frame (
      .pad_cfg_i(s_pad_cfg),
      .bootsel_o(s_bootsel),

      .ref_clk_o  (s_clk_in),
      .rstn_o     (s_pad_rstn),
      .jtag_tdo_i (s_jtag_tdo),
      .jtag_tck_o (s_jtag_tck),
      .jtag_tdi_o (s_jtag_tdi),
      .jtag_tms_o (s_jtag_tms),
      .jtag_trst_o(s_jtag_trst),

      // internal io signals
      .io_out_i(s_io_out),  // data going to pads
      .io_oe_i (s_io_oe),  // enable going to pads
      .io_in_o (s_io_in),  // data coming from pads

      // pad signals
      .io(io)  // pad wires
  );
`endif
*/
  //
  // SAFE DOMAIN
  //
  safe_domain #(
      .FLL_DATA_WIDTH(32),
      .FLL_ADDR_WIDTH(2)
  ) i_safe_domain (

      .ref_clk_i  (ref_clk_i),
      .slow_clk_o (s_ref_clk),
      .efpga_clk_o(s_efpga_clk),
      .bootsel_i  (bootsel_i),
      .rst_ni     (rstn_i),
      .rst_no     (s_rstn_por),

      .test_clk_o     (s_test_clk),
      .test_mode_o    (s_test_mode),
      .mode_select_o  (s_mode_select),
      .dft_cg_enable_o(s_dft_cg_enable),
      // PAD control signals
//      .pad_cfg_o      (s_pad_cfg),
//      .pad_cfg_i      (s_pad_cfg_soc),
      .pad_mux_i      (s_pad_mux_soc),
      // IO signals
      .io_out_o       (io_out_o),
      .io_in_i        (io_in_i),
      .io_oe_o        (io_oe_o),
      // PERIO signals
      .perio_out_i    (s_perio_out),
      .perio_in_o     (s_perio_in),
      .perio_oe_i     (s_perio_oe),
      // GPIO signals
      .apbio_out_i    (s_apbio_out),
      .apbio_in_o     (s_apbio_in),
      .apbio_oe_i     (s_apbio_oe),
      // FPGAIO signals
      .fpgaio_out_i   (s_fpgaio_out),
      .fpgaio_in_o    (s_fpgaio_in),
      .fpgaio_oe_i    (s_fpgaio_oe)
  );

  //
  // SOC DOMAIN
  //

  logic [20:0] testio_i;  //
  logic [15:0] testio_o;  //
  assign testio_i = '0;
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
      .ref_clk_i  (s_ref_clk),
                  .sclk_in(ref_clk_i),
      .test_clk_i (s_test_clk),
      .rstn_glob_i(s_rstn_por),

      .dft_test_mode_i(s_test_mode),
      .dft_cg_enable_i(s_dft_cg_enable),
      .mode_select_i(s_mode_select),
      .bootsel_i(bootsel_i),

      .data_slave_aw_writetoken_i('0),
      .data_slave_aw_addr_i('0),
      .data_slave_aw_prot_i('0),
      .data_slave_aw_region_i('0),
      .data_slave_aw_len_i('0),
      .data_slave_aw_size_i('0),
      .data_slave_aw_burst_i('0),
      .data_slave_aw_lock_i('0),
      .data_slave_aw_cache_i('0),
      .data_slave_aw_qos_i('0),
      .data_slave_aw_id_i('0),
      .data_slave_aw_user_i('0),
      .data_slave_aw_readpointer_o(),
      .data_slave_ar_writetoken_i('0),
      .data_slave_ar_addr_i('0),
      .data_slave_ar_prot_i('0),
      .data_slave_ar_region_i('0),
      .data_slave_ar_len_i('0),
      .data_slave_ar_size_i('0),
      .data_slave_ar_burst_i('0),
      .data_slave_ar_lock_i('0),
      .data_slave_ar_cache_i('0),
      .data_slave_ar_qos_i('0),
      .data_slave_ar_id_i('0),
      .data_slave_ar_user_i('0),
      .data_slave_ar_readpointer_o(),
      .data_slave_w_writetoken_i('0),
      .data_slave_w_data_i('0),
      .data_slave_w_strb_i('0),
      .data_slave_w_user_i('0),
      .data_slave_w_last_i('0),
      .data_slave_w_readpointer_o(),
      .data_slave_r_writetoken_o(),
      .data_slave_r_data_o(),
      .data_slave_r_resp_o(),
      .data_slave_r_last_o(),
      .data_slave_r_id_o(),
      .data_slave_r_user_o(),
      .data_slave_r_readpointer_i('0),
      .data_slave_b_writetoken_o(),
      .data_slave_b_resp_o(),
      .data_slave_b_id_o(),
      .data_slave_b_user_o(),
      .data_slave_b_readpointer_i('0),

      .data_master_aw_writetoken_o(),
      .data_master_aw_addr_o(),
      .data_master_aw_prot_o(),
      .data_master_aw_region_o(),
      .data_master_aw_len_o(),
      .data_master_aw_size_o(),
      //.data_master_aw_atop_o(),
      .data_master_aw_burst_o(),
      .data_master_aw_lock_o(),
      .data_master_aw_cache_o(),
      .data_master_aw_qos_o(),
      .data_master_aw_id_o(),
      .data_master_aw_user_o(),
      .data_master_aw_readpointer_i('0),
      .data_master_ar_writetoken_o(),
      .data_master_ar_addr_o(),
      .data_master_ar_prot_o(),
      .data_master_ar_region_o(),
      .data_master_ar_len_o(),
      .data_master_ar_size_o(),
      .data_master_ar_burst_o(),
      .data_master_ar_lock_o(),
      .data_master_ar_cache_o(),
      .data_master_ar_qos_o(),
      .data_master_ar_id_o(),
      .data_master_ar_user_o(),
      .data_master_ar_readpointer_i('0),
      .data_master_w_writetoken_o(),
      .data_master_w_data_o(),
      .data_master_w_strb_o(),
      .data_master_w_user_o(),
      .data_master_w_last_o(),
      .data_master_w_readpointer_i('0),
      .data_master_r_writetoken_i('0),
      .data_master_r_data_i('0),
      .data_master_r_resp_i('0),
      .data_master_r_last_i('0),
      .data_master_r_id_i('0),
      .data_master_r_user_i('0),
      .data_master_r_readpointer_o(),
      .data_master_b_writetoken_i('0),
      .data_master_b_resp_i('0),
      .data_master_b_id_i('0),
      .data_master_b_user_i('0),
      .data_master_b_readpointer_o(),


      .jtag_tck_i  (jtag_tck_i),
      .jtag_trst_ni(jtag_trst_i),
      .jtag_tms_i  (jtag_tms_i),
      .jtag_tdi_i  (jtag_tdi_i),
      .jtag_tdo_o  (jtag_tdo_o),
      .wd_expired_o(s_wd_expired),
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

      .fpga_clk_in       ({s_fpgaio_in[5:2], s_slow_clk, s_efpga_clk}),
      .selected_mode_i   ('0),
      .dma_pe_evt_ack_o  (s_dma_pe_evt_ack),
      .dma_pe_evt_valid_i(s_dma_pe_evt_valid),
      .dma_pe_irq_ack_o  (s_dma_pe_irq_ack),
      .dma_pe_irq_valid_i(s_dma_pe_irq_valid),
      .pf_evt_ack_o      (s_pf_evt_ack),
      .pf_evt_valid_i    (s_pf_evt_valid),

      //eFPGA TEST MODE
      .testio_i(testio_i),
      .testio_o(testio_o)

  );

  assign s_dma_pe_evt_valid = '0;
  assign s_dma_pe_irq_valid = '0;
  assign s_pf_evt_valid     = '0;
  assign s_cluster_busy     = '0;

endmodule
