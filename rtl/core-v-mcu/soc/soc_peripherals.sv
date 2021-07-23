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

module soc_peripherals #(
    parameter MEM_ADDR_WIDTH = 13,
    parameter APB_ADDR_WIDTH = 32,
    parameter APB_DATA_WIDTH = 32,
    parameter NB_CORES       = 4,
    parameter NB_CLUSTERS    = 0,
    parameter EVNT_WIDTH     = 8
) (
    input logic       clk_i,
    input logic       periph_clk_i,
    input logic [5:0] fpga_clk_in,
    input logic       rst_ni,
    //check the reset
    input logic       ref_clk_i,
    input logic       slow_clk_i,

    input  logic        sel_fll_clk_i,
    input  logic        dft_test_mode_i,
    input  logic        dft_cg_enable_i,
    output logic [31:0] fc_bootaddr_o,
    output logic        fc_fetchen_o,
    input  logic [ 7:0] soc_jtag_reg_i,
    output logic [ 7:0] soc_jtag_reg_o,
    input  logic        stoptimer_i,
    input  logic        boot_l2_i,
    input  logic        bootsel_i,
    // fc fetch enable can be controlled through this signal or through an APB
    // write to the fc fetch enable register
    input  logic        fc_fetch_en_valid_i,
    input  logic        fc_fetch_en_i,

    // SLAVE PORTS
    // APB SLAVE PORT
    APB_BUS.Slave  apb_slave,
    APB_BUS.Master apb_eu_master,
    APB_BUS.Master apb_hwpe_master,
    APB_BUS.Master apb_debug_master,

    // FABRIC CONTROLLER MASTER REFILL PORT
    XBAR_TCDM_BUS.Master l2_rx_master,
    XBAR_TCDM_BUS.Master l2_tx_master,
    // MASTER PORT TO SOC FLL
    FLL_BUS.Master       soc_fll_master,
    // MASTER PORT TO PER FLL
    FLL_BUS.Master       per_fll_master,
    // MASTER PORT TO CLUSTER FLL
    FLL_BUS.Master       cluster_fll_master,
    // MASTER PORT TO L2 from eFPGA
    XBAR_TCDM_BUS.Master l2_efpga_tcdm_master[`N_EFPGA_TCDM_PORTS-1:0],

           XBAR_TCDM_BUS.Slave        efpga_apbt1_slave,
    /*
    input  logic                       jtag_req_valid_i,
    output logic                       debug_req_ready_o,
    input  logic                       jtag_resp_ready_i,
    output logic                       jtag_resp_valid_o,
    input  dm::dmi_req_t               jtag_dmi_req_i,
    output dm::dmi_resp_t              debug_resp_o,
    output logic                       ndmreset_o,
    output logic                       dm_debug_req_o,
*/
    input  logic                      dma_pe_evt_i,
    input  logic                      dma_pe_irq_i,
    input  logic                      pf_evt_i,
    input  logic               [ 1:0] fc_hwpe_events_i,
    output logic               [31:0] fc_events_o,

    // Pad control signals
    output logic [    `N_IO-1:0][`NBIT_PADMUX-1:0] pad_mux_o,
    output logic [    `N_IO-1:0][`NBIT_PADCFG-1:0] pad_cfg_o,
    // PERIO signals
    input  logic [ `N_PERIO-1:0]                   perio_in_i,
    output logic [ `N_PERIO-1:0]                   perio_out_o,
    output logic [ `N_PERIO-1:0]                   perio_oe_o,
    // GPIO signals
    input  logic [ `N_APBIO-1:0]                   apbio_in_i,
    output logic [ `N_APBIO-1:0]                   apbio_out_o,
    output logic [ `N_APBIO-1:0]                   apbio_oe_o,
    // FPGAIO signals
    input  logic [`N_FPGAIO-1:0]                   fpgaio_in_i,
    output logic [`N_FPGAIO-1:0]                   fpgaio_out_o,
    output logic [`N_FPGAIO-1:0]                   fpgaio_oe_o,
    // Timer signals
    //    output logic [          3:0]                   timer_ch0_o,
    //    output logic [          3:0]                   timer_ch1_o,
    //    output logic [          3:0]                   timer_ch2_o,
    //    output logic [          3:0]                   timer_ch3_o,

    // //CAMERA
    // input  logic                       cam_clk_i,
    // input  logic [7:0]                 cam_data_i,
    // input  logic                       cam_hsync_i,
    // input  logic                       cam_vsync_i,

    // //UART
    // // output logic [N_UART-1:0]          uart_tx,
    // // input  logic [N_UART-1:0]          uart_rx,
    // output logic           uart_tx,
    // input  logic           uart_rx,


    // //I2C
    // input  logic [N_I2C-1:0]           i2c_scl_i,
    // output logic [N_I2C-1:0]           i2c_scl_o,
    // output logic [N_I2C-1:0]           i2c_scl_oe_o,
    // input  logic [N_I2C-1:0]           i2c_sda_i,
    // output logic [N_I2C-1:0]           i2c_sda_o,
    // output logic [N_I2C-1:0]           i2c_sda_oe_o,

    // //I2S
    // input  logic                       i2s_slave_sd0_i,
    // input  logic                       i2s_slave_sd1_i,
    // input  logic                       i2s_slave_ws_i,
    // output logic                       i2s_slave_ws_o,
    // output logic                       i2s_slave_ws_oe,
    // input  logic                       i2s_slave_sck_i,
    // output logic                       i2s_slave_sck_o,
    // output logic                       i2s_slave_sck_oe,

    // //SPI
    // output logic [N_SPI-1:0]           spi_clk_o,
    // output logic [N_SPI-1:0][3:0]      spi_csn_o,
    // output logic [N_SPI-1:0][3:0]      spi_oen_o,
    // output logic [N_SPI-1:0][3:0]      spi_sdo_o,
    // input  logic [N_SPI-1:0][3:0]      spi_sdi_i,

    // //SDIO
    // output logic                       sdclk_o,
    // output logic                       sdcmd_o,
    // input  logic                       sdcmd_i,
    // output logic                       sdcmd_oen_o,
    // output logic                 [3:0] sddata_o,
    // input  logic                 [3:0] sddata_i,
    // output logic                 [3:0] sddata_oen_o,


    //eFPGA SPIS
    input  logic efpga_fcb_spis_rst_n_i,
    input  logic efpga_fcb_spis_mosi_i,
    input  logic efpga_fcb_spis_cs_n_i,
    input  logic efpga_fcb_spis_clk_i,
    input  logic efpga_fcb_spi_mode_en_bo_i,
    output logic efpga_fcb_spis_miso_en_o,
    output logic efpga_fcb_spis_miso_o,

    //eFPGA TEST MODE
    input  logic efpga_STM_i,
    output logic efpga_test_fcb_pif_vldo_en_o,
    output logic efpga_test_fcb_pif_vldo_o,
    output logic efpga_test_fcb_pif_do_l_en_o,
    output logic efpga_test_fcb_pif_do_l_0_o,
    output logic efpga_test_fcb_pif_do_l_1_o,
    output logic efpga_test_fcb_pif_do_l_2_o,
    output logic efpga_test_fcb_pif_do_l_3_o,
    output logic efpga_test_fcb_pif_do_h_en_o,
    output logic efpga_test_fcb_pif_do_h_0_o,
    output logic efpga_test_fcb_pif_do_h_1_o,
    output logic efpga_test_fcb_pif_do_h_2_o,
    output logic efpga_test_fcb_pif_do_h_3_o,
    output logic efpga_test_FB_SPE_OUT_0_o,
    output logic efpga_test_FB_SPE_OUT_1_o,
    output logic efpga_test_FB_SPE_OUT_2_o,
    output logic efpga_test_FB_SPE_OUT_3_o,
    input  logic efpga_test_fcb_pif_vldi_i,
    input  logic efpga_test_fcb_pif_di_l_0_i,
    input  logic efpga_test_fcb_pif_di_l_1_i,
    input  logic efpga_test_fcb_pif_di_l_2_i,
    input  logic efpga_test_fcb_pif_di_l_3_i,
    input  logic efpga_test_fcb_pif_di_h_0_i,
    input  logic efpga_test_fcb_pif_di_h_1_i,
    input  logic efpga_test_fcb_pif_di_h_2_i,
    input  logic efpga_test_fcb_pif_di_h_3_i,
    input  logic efpga_test_FB_SPE_IN_0_i,
    input  logic efpga_test_FB_SPE_IN_1_i,
    input  logic efpga_test_FB_SPE_IN_2_i,
    input  logic efpga_test_FB_SPE_IN_3_i,
    input  logic efpga_test_M_0_i,
    input  logic efpga_test_M_1_i,
    input  logic efpga_test_M_2_i,
    input  logic efpga_test_M_3_i,
    input  logic efpga_test_M_4_i,
    input  logic efpga_test_M_5_i,
    input  logic efpga_test_MLATCH_i,

    output logic [EVNT_WIDTH-1:0] cl_event_data_o,
    output logic                  cl_event_valid_o,
    input  logic                  cl_event_ready_i,
    output logic [EVNT_WIDTH-1:0] fc_event_data_o,
    output logic                  fc_event_valid_o,
    input  logic                  fc_event_ready_i,

    output logic        cluster_pow_o,
    output logic        cluster_byp_o,  // bypass cluster
    output logic [63:0] cluster_boot_addr_o,
    output logic        cluster_fetch_enable_o,
    output logic        cluster_rstn_o,
    output logic        cluster_irq_o
);


  //eFPGA parameters
  localparam APB_EFPGA_HWCE_ADDR_WIDTH = 20;
  localparam TCDM_EFPGA_ADDR_WIDTH = 32;
  localparam N_EFPGA_EVENTS = 16;

  localparam UDMA_EVENTS = 16 * 8;
  localparam SOC_EVENTS = 3;

  genvar i;


  APB_BUS s_fll_bus ();

  APB_BUS s_gpio_bus ();
  APB_BUS s_udma_bus ();
  APB_BUS s_soc_ctrl_bus ();
  APB_BUS s_adv_timer_bus ();
  APB_BUS s_soc_evnt_gen_bus ();
  APB_BUS s_stdout_bus ();
  APB_BUS s_apb_timer_bus ();
  APB_BUS s_apb_fcb_bus ();
  APB_BUS s_apb_i2cs_bus ();

  logic [            `N_GPIO-1:0]                            s_gpio_sync;
  logic                                                      s_sel_hyper_axi;

  logic [            `N_GPIO-1:0]                            s_gpio_events;
  logic [                    1:0]                            s_spim_event;
  logic                                                      s_uart_event;
  logic                                                      s_i2c_event;
  logic                                                      s_i2s_event;
  logic                                                      s_i2s_cam_event;
  logic                                                      s_i2cs_event;

  logic [                    3:0]                            s_adv_timer_events;
  logic [                    1:0]                            s_fc_hp_events;
  logic                                                      s_fc_err_events;
  logic                                                      s_ref_rise_event;
  logic                                                      s_ref_fall_event;
  logic                                                      s_timer_hi_event;
  logic                                                      s_timer_lo_event;

  logic                                                      s_pr_event_valid;
  logic [                    7:0]                            s_pr_event_data;
  logic                                                      s_pr_event_ready;

  logic [        UDMA_EVENTS-1:0]                            s_udma_events;
  logic [                  159:0]                            s_events;


  logic [     N_EFPGA_EVENTS-1:0]                            s_efpga_events;
  logic [`N_EFPGA_TCDM_PORTS-1:0]                            tcdm_req;
  logic [`N_EFPGA_TCDM_PORTS-1:0][TCDM_EFPGA_ADDR_WIDTH-1:0] tcdm_addr;
  logic [`N_EFPGA_TCDM_PORTS-1:0]                            tcdm_wen;
  logic [`N_EFPGA_TCDM_PORTS-1:0][                     31:0] tcdm_wdata;
  logic [`N_EFPGA_TCDM_PORTS-1:0][                      3:0] tcdm_be;
  logic [`N_EFPGA_TCDM_PORTS-1:0]                            tcdm_gnt;
  logic [`N_EFPGA_TCDM_PORTS-1:0][                     31:0] tcdm_r_rdata;
  logic [`N_EFPGA_TCDM_PORTS-1:0]                            tcdm_r_valid;
  logic                                                      enable_udma_efpga;
  logic                                                      enable_events_efpga;
  logic                                                      enable_apb_efpga;
  logic                                                      enable_tcdm3_efpga;
  logic                                                      enable_tcdm2_efpga;
  logic                                                      enable_tcdm1_efpga;
  logic                                                      enable_tcdm0_efpga;


  logic                                                      s_timer_in_lo_event;
  logic                                                      s_timer_in_hi_event;

  logic                                                      clk_gating_dc_fifo_efpga;
  logic [                    3:0]                            reset_type1_efpga;
  logic                                                      s_efpga_clk;
  logic [                   31:0]                            udma2efpga_cfg_data;
  logic [                   31:0]                            efpga2udma_cfg_data;
  logic                                                      efpga_udma_tx_lin_valid;
  logic [                   31:0]                            efpga_udma_tx_lin_data;
  logic                                                      efpga_udma_tx_lin_ready;
  logic                                                      efpga_udma_rx_lin_valid;
  logic [                   31:0]                            efpga_udma_rx_lin_data;
  logic                                                      efpga_udma_rx_lin_ready;

  logic                                                      enable_perf_counter_efpga_x;
  logic                                                      reset_perf_counter_efpga_x;
  logic [                   31:0]                            perf_counter_value_x;

  logic [31:0] control_in, status_out;
  logic [7:0] version;



  assign s_events[UDMA_EVENTS-N_EFPGA_EVENTS-1:0] = s_udma_events[UDMA_EVENTS-N_EFPGA_EVENTS-1:0]; // ToDo: Hack that grabs top 16 events (equiv to 4 udma peripherals)
  assign s_events[UDMA_EVENTS-1:UDMA_EVENTS-N_EFPGA_EVENTS] = s_efpga_events;
  assign s_events[UDMA_EVENTS-1+`N_GPIO:UDMA_EVENTS] = s_gpio_events;



  assign fc_events_o[6:0] = 7'h0;  //RESERVED for sw events all routed to irq3
  assign fc_events_o[7] = s_timer_lo_event;  // MTIME irq
  assign fc_events_o[8] = 0;  //dma_pe_evt_i; // unused core-v-mcu
  assign fc_events_o[9] = 0;  //dma_pe_irq_i; // unused core-v-mcu
  assign fc_events_o[10] = 0;  //pf_evt_i;  // unused core-v-mcu
  assign fc_events_o[11] = 1'b0;  // Machine irq - from event_fifo
  assign fc_events_o[15:12] = 4'b0000;

  assign fc_events_o[16] = s_timer_lo_event;
  assign fc_events_o[17] = s_timer_hi_event;
  assign fc_events_o[18] = s_i2cs_event;
  assign fc_events_o[19] = s_adv_timer_events[0];
  assign fc_events_o[20] = s_adv_timer_events[1];
  assign fc_events_o[21] = s_adv_timer_events[2];
  assign fc_events_o[22] = s_adv_timer_events[3];
  assign fc_events_o[23] = s_ref_rise_event | s_ref_fall_event;
  assign fc_events_o[24] = 1'b0;
  assign fc_events_o[25] = 1'b0;
  assign fc_events_o[26] = 1'b0;
  assign fc_events_o[27] = 1'b0;
  assign fc_events_o[28] = 1'b0;
  assign fc_events_o[29] = s_fc_err_events;
  assign fc_events_o[30] = s_fc_hp_events[0];
  assign fc_events_o[31] = s_fc_hp_events[1];
  pulp_sync_wedge i_ref_clk_sync (
      .clk_i   (clk_i),
      .rstn_i  (rst_ni),
      .en_i    (1'b1),
      .serial_i(slow_clk_i),
      .r_edge_o(s_ref_rise_event),
      .f_edge_o(s_ref_fall_event),
      .serial_o()
  );


  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // ██████╗ ███████╗██████╗ ██╗██████╗ ██╗  ██╗    ██████╗ ██╗   ██╗███████╗    ██╗    ██╗██████╗  █████╗ ██████╗  //
  // ██╔══██╗██╔════╝██╔══██╗██║██╔══██╗██║  ██║    ██╔══██╗██║   ██║██╔════╝    ██║    ██║██╔══██╗██╔══██╗██╔══██╗ //
  // ██████╔╝█████╗  ██████╔╝██║██████╔╝███████║    ██████╔╝██║   ██║███████╗    ██║ █╗ ██║██████╔╝███████║██████╔╝ //
  // ██╔═══╝ ██╔══╝  ██╔══██╗██║██╔═══╝ ██╔══██║    ██╔══██╗██║   ██║╚════██║    ██║███╗██║██╔══██╗██╔══██║██╔═══╝  //
  // ██║     ███████╗██║  ██║██║██║     ██║  ██║    ██████╔╝╚██████╔╝███████║    ╚███╔███╔╝██║  ██║██║  ██║██║      //
  // ╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝╚═╝     ╚═╝  ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝     ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝      //
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  periph_bus_wrap #(
      .APB_ADDR_WIDTH(32),
      .APB_DATA_WIDTH(32)
  ) periph_bus_i (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .apb_slave(apb_slave),

      .fll_master         (s_fll_bus),
      .gpio_master        (s_gpio_bus),
      .udma_master        (s_udma_bus),
      .soc_ctrl_master    (s_soc_ctrl_bus),
      .adv_timer_master   (s_adv_timer_bus),
      .soc_evnt_gen_master(s_soc_evnt_gen_bus),
      .eu_master          (apb_eu_master),
      .mmap_debug_master  (apb_debug_master),
      .hwpe_master        (apb_hwpe_master),
      .timer_master       (s_apb_timer_bus),
      .stdout_master      (s_stdout_bus),
      .fcb_master         (s_apb_fcb_bus),
      .i2cs_master        (s_apb_i2cs_bus)
  );

`ifdef SYNTHESIS
  assign s_stdout_bus.pready  = 'h0;
  assign s_stdout_bus.pslverr = 'h0;
  assign s_stdout_bus.prdata  = 'h0;
`endif


  /////////////////////////////////////////////////////////////////////////
  //  █████╗ ██████╗ ██████╗     ███████╗██╗     ██╗         ██╗███████╗ //
  // ██╔══██╗██╔══██╗██╔══██╗    ██╔════╝██║     ██║         ██║██╔════╝ //
  // ███████║██████╔╝██████╔╝    █████╗  ██║     ██║         ██║█████╗   //
  // ██╔══██║██╔═══╝ ██╔══██╗    ██╔══╝  ██║     ██║         ██║██╔══╝   //
  // ██║  ██║██║     ██████╔╝    ██║     ███████╗███████╗    ██║██║      //
  // ╚═╝  ╚═╝╚═╝     ╚═════╝     ╚═╝     ╚══════╝╚══════╝    ╚═╝╚═╝      //
  /////////////////////////////////////////////////////////////////////////
  apb_fll_if #(
      .APB_ADDR_WIDTH(APB_ADDR_WIDTH)
  ) apb_fll_if_i (
      .HCLK   (clk_i),
      .HRESETn(rst_ni),

      .PADDR  (s_fll_bus.paddr),
      .PWDATA (s_fll_bus.pwdata),
      .PWRITE (s_fll_bus.pwrite),
      .PSEL   (s_fll_bus.psel),
      .PENABLE(s_fll_bus.penable),
      .PRDATA (s_fll_bus.prdata),
      .PREADY (s_fll_bus.pready),
      .PSLVERR(s_fll_bus.pslverr),

      .fll1_req   (soc_fll_master.req),
      .fll1_wrn   (soc_fll_master.wrn),
      .fll1_add   (soc_fll_master.add[1:0]),
      .fll1_data  (soc_fll_master.data),
      .fll1_ack   (soc_fll_master.ack),
      .fll1_r_data(soc_fll_master.r_data),
      .fll1_lock  (soc_fll_master.lock),

      .fll2_req   (per_fll_master.req),
      .fll2_wrn   (per_fll_master.wrn),
      .fll2_add   (per_fll_master.add[1:0]),
      .fll2_data  (per_fll_master.data),
      .fll2_ack   (per_fll_master.ack),
      .fll2_r_data(per_fll_master.r_data),
      .fll2_lock  (per_fll_master.lock),

      .fll3_req   (cluster_fll_master.req),
      .fll3_wrn   (cluster_fll_master.wrn),
      .fll3_add   (cluster_fll_master.add[1:0]),
      .fll3_data  (cluster_fll_master.data),
      .fll3_ack   (cluster_fll_master.ack),
      .fll3_r_data(cluster_fll_master.r_data),
      .fll3_lock  (cluster_fll_master.lock)
  );

  ///////////////////////////////////////////////////////////////
  //  █████╗ ██████╗ ██████╗      ██████╗ ██████╗ ██╗ ██████╗  //
  // ██╔══██╗██╔══██╗██╔══██╗    ██╔════╝ ██╔══██╗██║██╔═══██╗ //
  // ███████║██████╔╝██████╔╝    ██║  ███╗██████╔╝██║██║   ██║ //
  // ██╔══██║██╔═══╝ ██╔══██╗    ██║   ██║██╔═══╝ ██║██║   ██║ //
  // ██║  ██║██║     ██████╔╝    ╚██████╔╝██║     ██║╚██████╔╝ //
  // ╚═╝  ╚═╝╚═╝     ╚═════╝      ╚═════╝ ╚═╝     ╚═╝ ╚═════╝  //
  ///////////////////////////////////////////////////////////////

  apb_gpiov2 #(
      .APB_ADDR_WIDTH(APB_ADDR_WIDTH)
  ) i_apb_gpio (
      .HCLK   (clk_i),
      .HRESETn(rst_ni),

      .dft_cg_enable_i(dft_cg_enable_i),

      .PADDR  (s_gpio_bus.paddr),
      .PWDATA (s_gpio_bus.pwdata),
      .PWRITE (s_gpio_bus.pwrite),
      .PSEL   (s_gpio_bus.psel),
      .PENABLE(s_gpio_bus.penable),
      .PRDATA (s_gpio_bus.prdata),
      .PREADY (s_gpio_bus.pready),
      .PSLVERR(s_gpio_bus.pslverr),

      .gpio_in_sync(s_gpio_sync),

      .gpio_in  (apbio_in_i[`N_GPIO-1:0]),
      .gpio_out (apbio_out_o[`N_GPIO-1:0]),
      .gpio_dir (apbio_oe_o[`N_GPIO-1:0]),
      .interrupt(s_gpio_events)
  );

  ////////////////////////////////////////////////////////////////////////////////////////////////
  // ██╗   ██╗██████╗ ███╗   ███╗ █████╗     ███████╗██╗   ██╗██████╗ ███████╗██╗   ██╗███████╗ //
  // ██║   ██║██╔══██╗████╗ ████║██╔══██╗    ██╔════╝██║   ██║██╔══██╗██╔════╝╚██╗ ██╔╝██╔════╝ //
  // ██║   ██║██║  ██║██╔████╔██║███████║    ███████╗██║   ██║██████╔╝███████╗ ╚████╔╝ ███████╗ //
  // ██║   ██║██║  ██║██║╚██╔╝██║██╔══██║    ╚════██║██║   ██║██╔══██╗╚════██║  ╚██╔╝  ╚════██║ //
  // ╚██████╔╝██████╔╝██║ ╚═╝ ██║██║  ██║    ███████║╚██████╔╝██████╔╝███████║   ██║   ███████║ //
  //  ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝    ╚══════╝ ╚═════╝ ╚═════╝ ╚══════╝   ╚═╝   ╚══════╝ //
  ////////////////////////////////////////////////////////////////////////////////////////////////

  udma_subsystem #(
      .APB_ADDR_WIDTH(APB_ADDR_WIDTH),
      .L2_ADDR_WIDTH (MEM_ADDR_WIDTH)
  ) i_udma (
      .L2_ro_req_o   (l2_tx_master.req),
      .L2_ro_gnt_i   (l2_tx_master.gnt),
      .L2_ro_wen_o   (l2_tx_master.wen),
      .L2_ro_addr_o  (l2_tx_master.add),
      .L2_ro_wdata_o (l2_tx_master.wdata),
      .L2_ro_be_o    (l2_tx_master.be),
      .L2_ro_rdata_i (l2_tx_master.r_rdata),
      .L2_ro_rvalid_i(l2_tx_master.r_valid),

      .L2_wo_req_o   (l2_rx_master.req),
      .L2_wo_gnt_i   (l2_rx_master.gnt),
      .L2_wo_wen_o   (l2_rx_master.wen),
      .L2_wo_addr_o  (l2_rx_master.add),
      .L2_wo_wdata_o (l2_rx_master.wdata),
      .L2_wo_be_o    (l2_rx_master.be),
      .L2_wo_rdata_i (l2_rx_master.r_rdata),
      .L2_wo_rvalid_i(l2_rx_master.r_valid),

      .dft_test_mode_i(dft_test_mode_i),
      .dft_cg_enable_i(1'b0),

      .sys_clk_i   (clk_i),
      .periph_clk_i(periph_clk_i),
      .efpga_clk_i (periph_clk_i),  // FIXME if udma stays
      .sys_resetn_i(rst_ni),

      .udma_apb_paddr  (s_udma_bus.paddr),
      .udma_apb_pwdata (s_udma_bus.pwdata),
      .udma_apb_pwrite (s_udma_bus.pwrite),
      .udma_apb_psel   (s_udma_bus.psel),
      .udma_apb_penable(s_udma_bus.penable),
      .udma_apb_prdata (s_udma_bus.prdata),
      .udma_apb_pready (s_udma_bus.pready),
      .udma_apb_pslverr(s_udma_bus.pslverr),

      .events_o(s_udma_events),

      .event_valid_i(s_pr_event_valid),
      .event_data_i (s_pr_event_data),
      .event_ready_o(s_pr_event_ready),

      .efpga_data_tx_valid_o(efpga_udma_tx_lin_valid),
      .efpga_data_tx_o      (efpga_udma_tx_lin_data),
      .efpga_data_tx_ready_i(efpga_udma_tx_lin_ready),
      .efpga_data_rx_valid_i(efpga_udma_rx_lin_valid),
      .efpga_data_rx_i      (efpga_udma_rx_lin_data),
      .efpga_data_rx_ready_o(efpga_udma_rx_lin_ready),
      .efpga_setup_i        (efpga2udma_cfg_data),
      .efpga_setup_o        (udma2efpga_cfg_data),

      .perio_in_i (perio_in_i),
      .perio_out_o(perio_out_o),
      .perio_oe_o (perio_oe_o)

      // .spi_clk          ( spi_clk_o            ),
      // .spi_csn          ( spi_csn_o            ),
      // .spi_oen          ( spi_oen_o            ),
      // .spi_sdo          ( spi_sdo_o            ),
      // .spi_sdi          ( spi_sdi_i            ),

      // .sdio_clk_o       ( sdclk_o              ),
      // .sdio_cmd_o       ( sdcmd_o              ),
      // .sdio_cmd_i       ( sdcmd_i              ),
      // .sdio_cmd_oen_o   ( sdcmd_oen_o          ),
      // .sdio_data_o      ( sddata_o             ),
      // .sdio_data_i      ( sddata_i             ),
      // .sdio_data_oen_o  ( sddata_oen_o         ),

      // .cam_clk_i        ( cam_clk_i            ),
      // .cam_data_i       ( cam_data_i           ),
      // .cam_hsync_i      ( cam_hsync_i          ),
      // .cam_vsync_i      ( cam_vsync_i          ),

      // .i2s_slave_sd0_i  ( i2s_slave_sd0_i      ),
      // .i2s_slave_sd1_i  ( i2s_slave_sd1_i      ),
      // .i2s_slave_ws_i   ( i2s_slave_ws_i       ),
      // .i2s_slave_ws_o   ( i2s_slave_ws_o       ),
      // .i2s_slave_ws_oe  ( i2s_slave_ws_oe      ),
      // .i2s_slave_sck_i  ( i2s_slave_sck_i      ),
      // .i2s_slave_sck_o  ( i2s_slave_sck_o      ),
      // .i2s_slave_sck_oe ( i2s_slave_sck_oe     ),

      // .uart_rx_i        ( uart_rx              ),
      // .uart_tx_o        ( uart_tx              ),

      // .i2c_scl_i        ( i2c_scl_i            ),
      // .i2c_scl_o        ( i2c_scl_o            ),
      // .i2c_scl_oe       ( i2c_scl_oe_o         ),
      // .i2c_sda_i        ( i2c_sda_i            ),
      // .i2c_sda_o        ( i2c_sda_o            ),
      // .i2c_sda_oe       ( i2c_sda_oe_o         )

  );

  ////////////////////////////////////////////////////////////////////////////////////////////////
  //  █████╗ ██████╗ ██████╗     ███████╗ ██████╗  ██████╗     ██████╗████████╗██████╗ ██╗      //
  // ██╔══██╗██╔══██╗██╔══██╗    ██╔════╝██╔═══██╗██╔════╝    ██╔════╝╚══██╔══╝██╔══██╗██║      //
  // ███████║██████╔╝██████╔╝    ███████╗██║   ██║██║         ██║        ██║   ██████╔╝██║      //
  // ██╔══██║██╔═══╝ ██╔══██╗    ╚════██║██║   ██║██║         ██║        ██║   ██╔══██╗██║      //
  // ██║  ██║██║     ██████╔╝    ███████║╚██████╔╝╚██████╗    ╚██████╗   ██║   ██║  ██║███████╗ //
  // ╚═╝  ╚═╝╚═╝     ╚═════╝     ╚══════╝ ╚═════╝  ╚═════╝     ╚═════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝ //
  ////////////////////////////////////////////////////////////////////////////////////////////////
  logic [`N_IO-1:0][`NBIT_PADMUX-1:0] s_pad_mux_local;
  logic [  `N_IO:0][`NBIT_PADCFG-1:0] s_pad_cfg_local;
  apb_soc_ctrl #(
      .NB_CORES      (NB_CORES),
      .NB_CLUSTERS   (NB_CLUSTERS),
      .APB_ADDR_WIDTH(APB_ADDR_WIDTH),
      .NBIT_PADCFG   (`NBIT_PADCFG)
  ) i_apb_soc_ctrl (
      .HCLK   (clk_i),
      .HRESETn(rst_ni),

      .PADDR  (s_soc_ctrl_bus.paddr),
      .PWDATA (s_soc_ctrl_bus.pwdata),
      .PWRITE (s_soc_ctrl_bus.pwrite),
      .PSEL   (s_soc_ctrl_bus.psel),
      .PENABLE(s_soc_ctrl_bus.penable),
      .PRDATA (s_soc_ctrl_bus.prdata),
      .PREADY (s_soc_ctrl_bus.pready),
      .PSLVERR(s_soc_ctrl_bus.pslverr),

      .sel_fll_clk_i      (sel_fll_clk_i),
      .boot_l2_i          (boot_l2_i),
      .bootsel_i          (bootsel_i),
      .fc_fetch_en_valid_i(fc_fetch_en_valid_i),
      .fc_fetch_en_i      (fc_fetch_en_i),
      .status_out         (status_out),
      .version            (version),
      .control_in         (control_in),

      .pad_cfg_o(pad_cfg_o),
      .pad_mux_o(pad_mux_o),

      .soc_jtag_reg_i(soc_jtag_reg_i),
      .soc_jtag_reg_o(soc_jtag_reg_o),

      .fc_bootaddr_o(fc_bootaddr_o),

      // eFPGA connections

      .clk_gating_dc_fifo_o (clk_gating_dc_fifo_efpga),
      .reset_type1_efpga_o  (reset_type1_efpga),
      .enable_udma_efpga_o  (enable_udma_efpga),
      .enable_events_efpga_o(enable_events_efpga),
      .enable_apb_efpga_o   (enable_apb_efpga),
      .enable_tcdm3_efpga_o (enable_tcdm3_efpga),
      .enable_tcdm2_efpga_o (enable_tcdm2_efpga),
      .enable_tcdm1_efpga_o (enable_tcdm1_efpga),
      .enable_tcdm0_efpga_o (enable_tcdm0_efpga),

      .fc_fetchen_o          (fc_fetchen_o),
      .sel_hyper_axi_o       (s_sel_hyper_axi),
      .cluster_pow_o         (cluster_pow_o),
      .cluster_byp_o         (cluster_byp_o),
      .cluster_boot_addr_o   (cluster_boot_addr_o),
      .cluster_fetch_enable_o(cluster_fetch_enable_o),
      .cluster_rstn_o        (cluster_rstn_o),
      .cluster_irq_o         (cluster_irq_o)
  );

  apb_adv_timer #(
      .APB_ADDR_WIDTH(APB_ADDR_WIDTH),
      .EXTSIG_NUM    (32)
  ) i_apb_adv_timer (
      .HCLK   (clk_i),
      .HRESETn(rst_ni),

      .dft_cg_enable_i(dft_cg_enable_i),

      .PADDR  (s_adv_timer_bus.paddr),
      .PWDATA (s_adv_timer_bus.pwdata),
      .PWRITE (s_adv_timer_bus.pwrite),
      .PSEL   (s_adv_timer_bus.psel),
      .PENABLE(s_adv_timer_bus.penable),
      .PRDATA (s_adv_timer_bus.prdata),
      .PREADY (s_adv_timer_bus.pready),
      .PSLVERR(s_adv_timer_bus.pslverr),

      .low_speed_clk_i(slow_clk_i),
      .ext_sig_i      (s_gpio_sync),

      .events_o(s_adv_timer_events),

      .ch_0_o(apbio_out_o[`N_GPIO+3:`N_GPIO]),  // (timer_ch0_o),
      .ch_1_o(apbio_out_o[`N_GPIO+7:`N_GPIO+4]),  // (timer_ch1_o),
      .ch_2_o(apbio_out_o[`N_GPIO+11:`N_GPIO+8]),  // (timer_ch2_o),
      .ch_3_o(apbio_out_o[`N_GPIO+15:`N_GPIO+12])  // (timer_ch3_o)
  );
  assign apbio_oe_o[`N_GPIO+3:`N_GPIO] = 4'b1111;  // timer_ch0 oe
  assign apbio_oe_o[`N_GPIO+7:`N_GPIO+4] = 4'b1111;  // timer_ch1 oe
  assign apbio_oe_o[`N_GPIO+11:`N_GPIO+8] = 4'b1111;  // timer_ch2 oe
  assign apbio_oe_o[`N_GPIO+15:`N_GPIO+12] = 4'b1111;  // timer_ch3 oe

  /////////////////////////////////////////////////////////////////////////////////
  // ███████╗██╗   ██╗███████╗███╗   ██╗████████╗     ██████╗ ███████╗███╗   ██╗ //
  // ██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝    ██╔════╝ ██╔════╝████╗  ██║ //
  // █████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║       ██║  ███╗█████╗  ██╔██╗ ██║ //
  // ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║       ██║   ██║██╔══╝  ██║╚██╗██║ //
  // ███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║       ╚██████╔╝███████╗██║ ╚████║ //
  // ╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝        ╚═════╝ ╚══════╝╚═╝  ╚═══╝ //
  /////////////////////////////////////////////////////////////////////////////////

  soc_event_generator #(
      .APB_ADDR_WIDTH(APB_ADDR_WIDTH),
      .APB_EVNT_NUM  (8),
      .PER_EVNT_NUM  (160),
      .EVNT_WIDTH    (EVNT_WIDTH),
      .FC_EVENT_POS  (7)
  ) u_evnt_gen (
      .HCLK   (clk_i),
      .HRESETn(rst_ni),

      .PADDR  (s_soc_evnt_gen_bus.paddr),
      .PWDATA (s_soc_evnt_gen_bus.pwdata),
      .PWRITE (s_soc_evnt_gen_bus.pwrite),
      .PSEL   (s_soc_evnt_gen_bus.psel),
      .PENABLE(s_soc_evnt_gen_bus.penable),
      .PRDATA (s_soc_evnt_gen_bus.prdata),
      .PREADY (s_soc_evnt_gen_bus.pready),
      .PSLVERR(s_soc_evnt_gen_bus.pslverr),

      .low_speed_clk_i (slow_clk_i),
      .timer_event_lo_o(s_timer_in_lo_event),
      .timer_event_hi_o(s_timer_in_hi_event),
      .per_events_i    (s_events),
      .err_event_o     (s_fc_err_events),
      .fc_events_o     (s_fc_hp_events),

      .fc_event_valid_o(fc_event_valid_o),
      .fc_event_data_o (fc_event_data_o),
      .fc_event_ready_i(fc_event_ready_i),
      .cl_event_valid_o(cl_event_valid_o),
      .cl_event_data_o (cl_event_data_o),
      .cl_event_ready_i(cl_event_ready_i),
      .pr_event_valid_o(s_pr_event_valid),
      .pr_event_data_o (s_pr_event_data),
      .pr_event_ready_i(s_pr_event_ready)
  );

  /////////////////////////////////////////////////////////////////////////
  //  █████╗ ██████╗ ██████╗     ████████╗██╗███╗   ███╗███████╗██████╗  //
  // ██╔══██╗██╔══██╗██╔══██╗    ╚══██╔══╝██║████╗ ████║██╔════╝██╔══██╗ //
  // ███████║██████╔╝██████╔╝       ██║   ██║██╔████╔██║█████╗  ██████╔╝ //
  // ██╔══██║██╔═══╝ ██╔══██╗       ██║   ██║██║╚██╔╝██║██╔══╝  ██╔══██╗ //
  // ██║  ██║██║     ██████╔╝       ██║   ██║██║ ╚═╝ ██║███████╗██║  ██║ //
  // ╚═╝  ╚═╝╚═╝     ╚═════╝        ╚═╝   ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝ //
  /////////////////////////////////////////////////////////////////////////

  apb_timer_unit #(
      .APB_ADDR_WIDTH(APB_ADDR_WIDTH)
  ) i_apb_timer_unit (
      .HCLK       (clk_i),
      .HRESETn    (rst_ni),
      .PADDR      (s_apb_timer_bus.paddr),
      .PWDATA     (s_apb_timer_bus.pwdata),
      .PWRITE     (s_apb_timer_bus.pwrite),
      .PSEL       (s_apb_timer_bus.psel),
      .PENABLE    (s_apb_timer_bus.penable),
      .PRDATA     (s_apb_timer_bus.prdata),
      .PREADY     (s_apb_timer_bus.pready),
      .PSLVERR    (s_apb_timer_bus.pslverr),
      .ref_clk_i  (slow_clk_i),
      .event_lo_i (s_timer_in_lo_event),
      .event_hi_i (s_timer_in_hi_event),
      .irq_lo_o   (s_timer_lo_event),
      .irq_hi_o   (s_timer_hi_event),
      .stoptimer_i(stoptimer_i),
      .busy_o     ()
  );

  ////////////////////////////////////////////////
  //  ███████╗███████╗██████╗  ██████╗  █████╗  //
  //  ██╔════╝██╔════╝██╔══██╗██╔════╝ ██╔══██╗ //
  //  █████╗  █████╗  ██████╔╝██║  ███╗███████║ //
  //  ██╔══╝  ██╔══╝  ██╔═══╝ ██║   ██║██╔══██║ //
  //  ███████╗██║     ██║     ╚██████╔╝██║  ██║ //
  //  ╚══════╝╚═╝     ╚═╝      ╚═════╝ ╚═╝  ╚═╝ //
  ////////////////////////////////////////////////



  efpga_subsystem #(
      .L2_ADDR_WIDTH      (TCDM_EFPGA_ADDR_WIDTH),
      .APB_FPGA_ADDR_WIDTH(APB_EFPGA_HWCE_ADDR_WIDTH)
  ) i_efpga_subsystem (
      .asic_clk_i (clk_i),
      .fpga_clk0_i(fpga_clk_in[0]),
      .fpga_clk1_i(fpga_clk_in[1]),
      .fpga_clk2_i(fpga_clk_in[2]),
      .fpga_clk3_i(fpga_clk_in[3]),
      .fpga_clk4_i(fpga_clk_in[4]),
      .fpga_clk5_i(fpga_clk_in[5]),



      .clk_gating_dc_fifo_i (clk_gating_dc_fifo_efpga),
      .reset_type1_efpga_i  (reset_type1_efpga),
      .enable_udma_efpga_i  (enable_udma_efpga),
      .enable_events_efpga_i(enable_events_efpga),
      .enable_apb_efpga_i   (enable_apb_efpga),
      .enable_tcdm3_efpga_i (enable_tcdm3_efpga),
      .enable_tcdm2_efpga_i (enable_tcdm2_efpga),
      .enable_tcdm1_efpga_i (enable_tcdm1_efpga),
      .enable_tcdm0_efpga_i (enable_tcdm0_efpga),

      .rst_n(rst_ni),


      .l2_asic_tcdm_o(l2_efpga_tcdm_master),
      .apbprogram_i  (s_apb_fcb_bus),
      .apbt1_i       (efpga_apbt1_slave),
      .control_in    (control_in),
      .status_out    (status_out),
      .version       (version),

      .fpgaio_oe_o (fpgaio_oe_o),
      .fpgaio_in_i (fpgaio_in_i),
      .fpgaio_out_o(fpgaio_out_o),

      .efpga_event_o(s_efpga_events),

      //eFPGA SPIS
      .efpga_fcb_spis_rst_n_i    (efpga_fcb_spis_rst_n_i),
      .efpga_fcb_spis_mosi_i     (efpga_fcb_spis_mosi_i),
      .efpga_fcb_spis_cs_n_i     (efpga_fcb_spis_cs_n_i),
      .efpga_fcb_spis_clk_i      (efpga_fcb_spis_clk_i),
      .efpga_fcb_spi_mode_en_bo_i(efpga_fcb_spi_mode_en_bo_i),
      .efpga_fcb_spis_miso_en_o  (efpga_fcb_spis_miso_en_o),
      .efpga_fcb_spis_miso_o     (efpga_fcb_spis_miso_o),

      //eFPGA TEST MODE
      .efpga_STM_i(efpga_STM_i),

      .efpga_test_FB_SPE_OUT_0_o  (efpga_test_FB_SPE_OUT_0_o),
      .efpga_test_FB_SPE_OUT_1_o  (efpga_test_FB_SPE_OUT_1_o),
      .efpga_test_FB_SPE_OUT_2_o  (efpga_test_FB_SPE_OUT_2_o),
      .efpga_test_FB_SPE_OUT_3_o  (efpga_test_FB_SPE_OUT_3_o),
      .efpga_test_fcb_pif_vldi_i  (efpga_test_fcb_pif_vldi_i),
      .efpga_test_fcb_pif_di_l_0_i(efpga_test_fcb_pif_di_l_0_i),
      .efpga_test_fcb_pif_di_l_1_i(efpga_test_fcb_pif_di_l_1_i),
      .efpga_test_fcb_pif_di_l_2_i(efpga_test_fcb_pif_di_l_2_i),
      .efpga_test_fcb_pif_di_l_3_i(efpga_test_fcb_pif_di_l_3_i),
      .efpga_test_fcb_pif_di_h_0_i(efpga_test_fcb_pif_di_h_0_i),
      .efpga_test_fcb_pif_di_h_1_i(efpga_test_fcb_pif_di_h_1_i),
      .efpga_test_fcb_pif_di_h_2_i(efpga_test_fcb_pif_di_h_2_i),
      .efpga_test_fcb_pif_di_h_3_i(efpga_test_fcb_pif_di_h_3_i),
      .efpga_test_FB_SPE_IN_0_i   (efpga_test_FB_SPE_IN_0_i),
      .efpga_test_FB_SPE_IN_1_i   (efpga_test_FB_SPE_IN_1_i),
      .efpga_test_FB_SPE_IN_2_i   (efpga_test_FB_SPE_IN_2_i),
      .efpga_test_FB_SPE_IN_3_i   (efpga_test_FB_SPE_IN_3_i),
      .efpga_test_M_0_i           (efpga_test_M_0_i),
      .efpga_test_M_1_i           (efpga_test_M_1_i),
      .efpga_test_M_2_i           (efpga_test_M_2_i),
      .efpga_test_M_3_i           (efpga_test_M_3_i),
      .efpga_test_M_4_i           (efpga_test_M_4_i),
      .efpga_test_M_5_i           (efpga_test_M_5_i),
      .efpga_test_MLATCH_i        (efpga_test_MLATCH_i)
  );

  ///////////////////////////////////////////////////////////////
  //  █████╗ ██████╗ ██████╗                                   //
  // ██╔══██╗██╔══██╗██╔══██╗                                  //
  // ███████║██████╔╝██████╔╝                                  //
  // ██╔══██║██╔═══╝ ██╔══██╗                                  //
  // ██║  ██║██║     ██████╔╝                                  //
  // ╚═╝  ╚═╝╚═╝     ╚═════╝                                   //
  ///////////////////////////////////////////////////////////////

  apb_i2cs i_apb_i2cs (
      .apb_pclk_i   (clk_i),
      .apb_presetn_i(rst_ni),

      .apb_paddr_i  (s_apb_i2cs_bus.paddr[11:0]),
      .apb_pwdata_i (s_apb_i2cs_bus.pwdata),
      .apb_pwrite_i (s_apb_i2cs_bus.pwrite),
      .apb_psel_i   (s_apb_i2cs_bus.psel),
      .apb_penable_i(s_apb_i2cs_bus.penable),
      .apb_prdata_o (s_apb_i2cs_bus.prdata),
      .apb_pready_o (s_apb_i2cs_bus.pready),
      .apb_interrupt_o(),
      // .PSLVERR(s_apb_i2cs_bus.pslverr),

      .i2c_scl_i(apbio_in_i[`N_GPIO+16]),
      .i2c_sda_i(apbio_in_i[`N_GPIO+17]),
      .i2c_sda_o(apbio_out_o[`N_GPIO+17]),
      .i2c_sda_oe(apbio_oe_o[`N_GPIO+17]),
      .i2c_interrupt_o(s_i2cs_event)
  );

endmodule
