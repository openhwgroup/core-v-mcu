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

module pulpissimo #(
    parameter logic [1:0] CORE_TYPE   = 3, // 0 for RISCY, 1 for IBEX RV32IMC (formerly ZERORISCY), 2 for IBEX RV32EC (formerly MICRORISCY)
    parameter USE_FPU = 1,
    parameter USE_HWPE = 1
) (
    inout wire [`N_IO-1:0] io
);

  localparam AXI_ADDR_WIDTH = 32;
  localparam AXI_CLUSTER_SOC_DATA_WIDTH = 64;
  localparam AXI_SOC_CLUSTER_DATA_WIDTH = 32;
  localparam AXI_CLUSTER_SOC_ID_WIDTH = 6;

  localparam AXI_USER_WIDTH = 6;

  localparam BUFFER_WIDTH = 8;
  localparam EVENT_WIDTH = 8;

  localparam CVP_ADDR_WIDTH = 32;
  localparam CVP_DATA_WIDTH = 32;

  //
  // PAD FRAME TO PAD CONTROL SIGNALS
  //

  logic [       `N_IO-1:0][`NBIT_PADCFG-1:0] s_pad_cfg;

  logic [       `N_IO-1:0]                   s_io_out;
  logic [       `N_IO-1:0]                   s_io_oe;
  logic [       `N_IO-1:0]                   s_io_in;


  //
  // OTHER PAD FRAME SIGNALS
  //

  logic                                      s_ref_clk;
  logic                                      s_rstn;

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
  //GPIO
  logic [     `N_GPIO-1:0]                   s_gpio_out;
  logic [     `N_GPIO-1:0]                   s_gpio_in;
  logic [     `N_GPIO-1:0]                   s_gpio_oe;
  // FPGAIO
  logic [   `N_FPGAIO-1:0]                   s_fpgaio_out;
  logic [   `N_FPGAIO-1:0]                   s_fpgaio_in;
  logic [   `N_FPGAIO-1:0]                   s_fpgaio_oe;

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
  logic [             3:0]                   s_timer0;
  logic [             3:0]                   s_timer1;
  logic [             3:0]                   s_timer2;
  logic [             3:0]                   s_timer3;

  logic                                      s_jtag_shift_dr;
  logic                                      s_jtag_update_dr;
  logic                                      s_jtag_capture_dr;

  logic                                      s_axireg_sel;
  logic                                      s_axireg_tdi;
  logic                                      s_axireg_tdo;

  logic [             7:0]                   s_soc_jtag_regi;
  logic [             7:0]                   s_soc_jtag_rego;

  logic                                      s_rstn_por;
  logic                                      s_cluster_pow;
  logic                                      s_cluster_byp;

  logic                                      s_dma_pe_irq_ack;
  logic                                      s_dma_pe_irq_valid;

  logic [       `N_IO-1:0][`NBIT_PADMUX-1:0] s_pad_mux_soc;
  logic [       `N_IO-1:0][`NBIT_PADCFG-1:0] s_pad_cfg_soc;
  logic [             1:0]                   s_selected_pad_mode;

  logic                                      efpga_test_fcb_pif_vldi;
  logic                                      efpga_test_fcb_pif_di_l_0;
  logic                                      efpga_test_fcb_pif_di_l_1;
  logic                                      efpga_test_fcb_pif_di_l_2;
  logic                                      efpga_test_fcb_pif_di_l_3;
  logic                                      efpga_test_fcb_pif_di_h_0;
  logic                                      efpga_test_fcb_pif_di_h_1;
  logic                                      efpga_test_fcb_pif_di_h_2;
  logic                                      efpga_test_fcb_pif_di_h_3;
  logic                                      efpga_test_fcb_pif_vldo_en;
  logic                                      efpga_test_fcb_pif_vldo;
  logic                                      efpga_test_fcb_pif_do_l_en;
  logic                                      efpga_test_fcb_pif_do_l_0;
  logic                                      efpga_test_fcb_pif_do_l_1;
  logic                                      efpga_test_fcb_pif_do_l_2;
  logic                                      efpga_test_fcb_pif_do_l_3;
  logic                                      efpga_test_fcb_pif_do_h_en;
  logic                                      efpga_test_fcb_pif_do_h_0;
  logic                                      efpga_test_fcb_pif_do_h_1;
  logic                                      efpga_test_fcb_pif_do_h_2;
  logic                                      efpga_test_fcb_pif_do_h_3;
  logic                                      efpga_test_FB_SPE_OUT_0;
  logic                                      efpga_test_FB_SPE_OUT_1;
  logic                                      efpga_test_FB_SPE_OUT_2;
  logic                                      efpga_test_FB_SPE_OUT_3;
  logic                                      efpga_test_FB_SPE_IN_0;
  logic                                      efpga_test_FB_SPE_IN_1;
  logic                                      efpga_test_FB_SPE_IN_2;
  logic                                      efpga_test_FB_SPE_IN_3;
  logic                                      efpga_test_M_0;
  logic                                      efpga_test_M_1;
  logic                                      efpga_test_M_2;
  logic                                      efpga_test_M_3;
  logic                                      efpga_test_M_4;
  logic                                      efpga_test_M_5;
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
  logic                                      s_cluster_irq;


  //
  // OTHER PAD FRAME SIGNALS
  //
  logic                                      s_bootsel;
  logic                                      s_fc_fetch_en_valid;
  logic                                      s_fc_fetch_en;

  logic                                      debug1;
  logic                                      debug0;

  //
  // PAD FRAME
  //
  pad_frame i_pad_frame (
      .pad_cfg_i(s_pad_cfg),
      .bootsel_o(s_bootsel),

      .ref_clk_o  (s_ref_clk),
      .rstn_o     (s_rstn),
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

  //
  // SAFE DOMAIN
  //
  safe_domain #(
      .FLL_DATA_WIDTH(32),
      .FLL_ADDR_WIDTH(2)
  ) i_safe_domain (

      .ref_clk_i (s_ref_clk),
      .slow_clk_o(s_slow_clk),
      .bootsel_i (s_bootsel),
      .rst_ni    (s_rstn),

      .rst_no(s_rstn_por),

      .test_clk_o     (s_test_clk),
      .test_mode_o    (s_test_mode),
      .mode_select_o  (s_mode_select),
      .dft_cg_enable_o(s_dft_cg_enable),
      // PAD control signals
      .pad_cfg_o      (s_pad_cfg),
      .pad_cfg_i      (s_pad_cfg_soc),
      .pad_mux_i      (s_pad_mux_soc),
      // IO signals
      .io_out_o       (s_io_out),
      .io_in_i        (s_io_in),
      .io_oe_o        (s_io_oe),
      // PERIO signals
      .perio_out_i    (s_perio_out),
      .perio_in_o     (s_perio_in),
      .perio_oe_i     (s_perio_oe),
      // GPIO signals
      .gpio_out_i     (s_gpio_out),
      .gpio_in_o      (s_gpio_in),
      .gpio_oe_i      (s_gpio_oe),
      // FPGAIO signals
      .fpgaio_out_i   (s_fpgaio_out),
      .fpgaio_in_o    (s_fpgaio_in),
      .fpgaio_oe_i    (s_fpgaio_oe),
      // Timer signals
      .timer0_i       (s_timer0),
      .timer1_i       (s_timer1),
      .timer2_i       (s_timer2),
      .timer3_i       (s_timer3),
      .debug0         (s_debug0),
      .debug1         (s_debug1)
  );

  //
  // SOC DOMAIN
  //
  soc_domain #(
      .CORE_TYPE         (CORE_TYPE),
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

      .ref_clk_i (s_ref_clk),
      .slow_clk_i(s_slow_clk),
      .test_clk_i(s_test_clk),

      .rstn_glob_i(s_rstn_por),

      .mode_select_i  (s_mode_select),
      .dft_cg_enable_i(s_dft_cg_enable),
      .dft_test_mode_i(s_test_mode),

      .bootsel_i(s_bootsel),

      // we immediately start booting in the default setup
      .fc_fetch_en_valid_i(1'b1),
      .fc_fetch_en_i      (1'b1),

      .jtag_tck_i  (s_jtag_tck),
      .jtag_trst_ni(s_jtag_trst),
      .jtag_tms_i  (s_jtag_tms),
      .jtag_tdi_i  (s_jtag_tdi),
      .jtag_tdo_o  (s_jtag_tdo),
      // Pad control signals
      .pad_cfg_o   (s_pad_cfg_soc),
      .pad_mux_o   (s_pad_mux_soc),
      // PERIO signals
      .perio_in_i  (s_perio_in),
      .perio_out_o (s_perio_out),
      .perio_oe_o  (s_perio_oe),
      // GPIO signals
      .gpio_in_i   (s_gpio_in),
      .gpio_out_o  (s_gpio_out),
      .gpio_oe_o   (s_gpio_oe),
      // FPGAIO signals
      .fpgaio_out_o(s_fpgaio_out),
      .fpgaio_in_i (s_fpgaio_in),
      .fpgaio_oe_o (s_fpgaio_oe),

      .fpga_clk_1_i(s_fpga_clk_1_i),
      .fpga_clk_2_i(s_fpga_clk_2_i),
      .fpga_clk_3_i(s_fpga_clk_3_i),
      .fpga_clk_4_i(s_fpga_clk_4_i),
      .fpga_clk_5_i(s_fpga_clk_5_i),

      .timer_ch0_o(s_timer0),
      .timer_ch1_o(s_timer1),
      .timer_ch2_o(s_timer2),
      .timer_ch3_o(s_timer3),

      .cluster_busy_i(s_cluster_busy),

      .cluster_events_wt_o(s_event_writetoken),
      .cluster_events_rp_i(s_event_readpointer),
      .cluster_events_da_o(s_event_dataasync),

      .cluster_irq_o(s_cluster_irq),

      .dma_pe_evt_ack_o  (s_dma_pe_evt_ack),
      .dma_pe_evt_valid_i(s_dma_pe_evt_valid),
      .dma_pe_irq_ack_o  (s_dma_pe_irq_ack),
      .dma_pe_irq_valid_i(s_dma_pe_irq_valid),
      .pf_evt_ack_o      (s_pf_evt_ack),
      .pf_evt_valid_i    (s_pf_evt_valid),

      //eFPGA SPIS
      .efpga_fcb_spis_rst_n_i    (efpga_fcb_spis_rst_n),
      .efpga_fcb_spis_mosi_i     (efpga_fcb_spis_mosi),
      .efpga_fcb_spis_cs_n_i     (efpga_fcb_spis_cs_n),
      .efpga_fcb_spis_clk_i      (efpga_fcb_spis_clk),
      .efpga_fcb_spi_mode_en_bo_i(efpga_fcb_spi_mode_en_bo),
      .efpga_fcb_spis_miso_en_o  (efpga_fcb_spis_miso_en),
      .efpga_fcb_spis_miso_o     (efpga_fcb_spis_miso),

      //eFPGA TEST MODE
      .efpga_STM_i                 (s_in_stm),
      .efpga_test_fcb_pif_vldo_en_o(efpga_test_fcb_pif_vldo_en),
      .efpga_test_fcb_pif_vldo_o   (efpga_test_fcb_pif_vldo),
      .efpga_test_fcb_pif_do_l_en_o(efpga_test_fcb_pif_do_l_en),
      .efpga_test_fcb_pif_do_l_0_o (efpga_test_fcb_pif_do_l_0),
      .efpga_test_fcb_pif_do_l_1_o (efpga_test_fcb_pif_do_l_1),
      .efpga_test_fcb_pif_do_l_2_o (efpga_test_fcb_pif_do_l_2),
      .efpga_test_fcb_pif_do_l_3_o (efpga_test_fcb_pif_do_l_3),
      .efpga_test_fcb_pif_do_h_en_o(efpga_test_fcb_pif_do_h_en),
      .efpga_test_fcb_pif_do_h_0_o (efpga_test_fcb_pif_do_h_0),
      .efpga_test_fcb_pif_do_h_1_o (efpga_test_fcb_pif_do_h_1),
      .efpga_test_fcb_pif_do_h_2_o (efpga_test_fcb_pif_do_h_2),
      .efpga_test_fcb_pif_do_h_3_o (efpga_test_fcb_pif_do_h_3),
      .efpga_test_FB_SPE_OUT_0_o   (efpga_test_FB_SPE_OUT_0),
      .efpga_test_FB_SPE_OUT_1_o   (efpga_test_FB_SPE_OUT_1),
      .efpga_test_FB_SPE_OUT_2_o   (efpga_test_FB_SPE_OUT_2),
      .efpga_test_FB_SPE_OUT_3_o   (efpga_test_FB_SPE_OUT_3),

      .efpga_test_fcb_pif_vldi_i  (efpga_test_fcb_pif_vldi),
      .efpga_test_fcb_pif_di_l_0_i(efpga_test_fcb_pif_di_l_0),
      .efpga_test_fcb_pif_di_l_1_i(efpga_test_fcb_pif_di_l_1),
      .efpga_test_fcb_pif_di_l_2_i(efpga_test_fcb_pif_di_l_2),
      .efpga_test_fcb_pif_di_l_3_i(efpga_test_fcb_pif_di_l_3),
      .efpga_test_fcb_pif_di_h_0_i(efpga_test_fcb_pif_di_h_0),
      .efpga_test_fcb_pif_di_h_1_i(efpga_test_fcb_pif_di_h_1),
      .efpga_test_fcb_pif_di_h_2_i(efpga_test_fcb_pif_di_h_2),
      .efpga_test_fcb_pif_di_h_3_i(efpga_test_fcb_pif_di_h_3),
      .efpga_test_FB_SPE_IN_0_i   (efpga_test_FB_SPE_IN_0),
      .efpga_test_FB_SPE_IN_1_i   (efpga_test_FB_SPE_IN_1),
      .efpga_test_FB_SPE_IN_2_i   (efpga_test_FB_SPE_IN_2),
      .efpga_test_FB_SPE_IN_3_i   (efpga_test_FB_SPE_IN_3),
      .efpga_test_M_0_i           (efpga_test_M_0),
      .efpga_test_M_1_i           (efpga_test_M_1),
      .efpga_test_M_2_i           (efpga_test_M_2),
      .efpga_test_M_3_i           (efpga_test_M_3),
      .efpga_test_M_4_i           (efpga_test_M_4),
      .efpga_test_M_5_i           (efpga_test_M_5),
      .efpga_test_MLATCH_i        (efpga_test_MLATCH),

      .cluster_pow_o(s_cluster_pow),
      .cluster_byp_o(s_cluster_byp)
  );

  assign s_dma_pe_evt_valid = '0;
  assign s_dma_pe_irq_valid = '0;
  assign s_pf_evt_valid     = '0;
  assign s_cluster_busy     = '0;

endmodule
