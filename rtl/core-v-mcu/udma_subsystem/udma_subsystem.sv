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

module udma_subsystem #(
    parameter L2_DATA_WIDTH  = 32,
    parameter L2_ADDR_WIDTH  = 19,  //L2 addr space of 2MB
    parameter CAM_DATA_WIDTH = 8,
    parameter APB_ADDR_WIDTH = 12,  //APB slaves are 4KB by default
    parameter TRANS_SIZE     = 20  //max uDMA transaction size of 1MB
) (
    output logic                       L2_ro_wen_o,
    output logic                       L2_ro_req_o,
    input  logic                       L2_ro_gnt_i,
    output logic [               31:0] L2_ro_addr_o,
    output logic [L2_DATA_WIDTH/8-1:0] L2_ro_be_o,
    output logic [  L2_DATA_WIDTH-1:0] L2_ro_wdata_o,
    input  logic                       L2_ro_rvalid_i,
    input  logic [  L2_DATA_WIDTH-1:0] L2_ro_rdata_i,

    output logic                       L2_wo_wen_o,
    output logic                       L2_wo_req_o,
    input  logic                       L2_wo_gnt_i,
    output logic [               31:0] L2_wo_addr_o,
    output logic [  L2_DATA_WIDTH-1:0] L2_wo_wdata_o,
    output logic [L2_DATA_WIDTH/8-1:0] L2_wo_be_o,
    input  logic                       L2_wo_rvalid_i,
    input  logic [  L2_DATA_WIDTH-1:0] L2_wo_rdata_i,

    input logic dft_test_mode_i,
    input logic dft_cg_enable_i,

    input logic sys_clk_i,
    input logic efpga_clk_i,
    input logic sys_resetn_i,

    input logic periph_clk_i,

    input  logic [APB_ADDR_WIDTH-1:0] udma_apb_paddr,
    input  logic [              31:0] udma_apb_pwdata,
    input  logic                      udma_apb_pwrite,
    input  logic                      udma_apb_psel,
    input  logic                      udma_apb_penable,
    output logic [              31:0] udma_apb_prdata,
    output logic                      udma_apb_pready,
    output logic                      udma_apb_pslverr,

    output logic [32*4-1:0] events_o,  //4 events for each peripheral

    input  logic       event_valid_i,
    input  logic [7:0] event_data_i,
    output logic       event_ready_o,

    //TX side - uDMA <-> external Peripheral
    output logic        efpga_data_tx_valid_o,
    input  logic        efpga_data_tx_ready_i,
    output logic [31:0] efpga_data_tx_o,

    //RX side - uDMA <-> external Peripheral
    input  logic        efpga_data_rx_valid_i,
    output logic        efpga_data_rx_ready_o,
    input  logic [31:0] efpga_data_rx_i,

    //configuration external peripheral
    input  logic [31:0] efpga_setup_i,
    output logic [31:0] efpga_setup_o,

    input  logic [`N_PERIO-1:0] perio_in_i,
    output logic [`N_PERIO-1:0] perio_out_o,
    output logic [`N_PERIO-1:0] perio_oe_o

    // output logic     [`N_SPI-1:0]       spi_clk,
    // output logic     [`N_SPI-1:0] [3:0] spi_csn,
    // output logic     [`N_SPI-1:0] [3:0] spi_oen,
    // output logic     [`N_SPI-1:0] [3:0] spi_sdo,
    // input  logic     [`N_SPI-1:0] [3:0] spi_sdi,

    // input  logic           [`N_I2C-1:0] i2c_scl_i,
    // output logic           [`N_I2C-1:0] i2c_scl_o,
    // output logic           [`N_I2C-1:0] i2c_scl_oe,
    // input  logic           [`N_I2C-1:0] i2c_sda_i,
    // output logic           [`N_I2C-1:0] i2c_sda_o,
    // output logic           [`N_I2C-1:0] i2c_sda_oe,

    // input  logic                       cam_clk_i,
    // input  logic  [CAM_DATA_WIDTH-1:0] cam_data_i,
    // input  logic                       cam_hsync_i,
    // input  logic                       cam_vsync_i,

    // input  logic          [`N_UART-1:0] uart_rx_i,
    // output logic          [`N_UART-1:0] uart_tx_o,

    // output logic                       sdio_clk_o,
    // output logic                       sdio_cmd_o,
    // input  logic                       sdio_cmd_i,
    // output logic                       sdio_cmd_oen_o,
    // output logic                 [3:0] sdio_data_o,
    // input  logic                 [3:0] sdio_data_i,
    // output logic                 [3:0] sdio_data_oen_o,

    // input  logic                       i2s_slave_sd0_i,
    // input  logic                       i2s_slave_sd1_i,
    // input  logic                       i2s_slave_ws_i,
    // output logic                       i2s_slave_ws_o,
    // output logic                       i2s_slave_ws_oe,
    // input  logic                       i2s_slave_sck_i,
    // output logic                       i2s_slave_sck_o,
    // output logic                       i2s_slave_sck_oe
);

  localparam DEST_SIZE = 2;

  localparam L2_AWIDTH_NOAL = L2_ADDR_WIDTH + 2;

  if (`N_I2S != 0) $error("Requested number of I2S not supported. Only support 0");
`ifdef PULP_TRAINING
  localparam N_EXT_PER = 1;
`else
  localparam N_EXT_PER = 0;
`endif

  localparam N_RX_CHANNELS =   `N_SPI + `N_HYPER + `N_MRAM + `N_JTAG + `N_SDIO + `N_UART + `N_I2C + `N_I2S + `N_CAM + 2*`N_CSI2 + `N_FPGA + N_EXT_PER;
  localparam N_TX_CHANNELS = 2*`N_SPI + `N_HYPER + `N_MRAM + `N_JTAG + `N_SDIO + `N_UART + `N_I2C + `N_I2S + `N_FPGA + N_EXT_PER;

  if (`N_RX_CHANNELS != N_RX_CHANNELS) $error("N_RX_CHANNELS mismatch");
  if (`N_TX_CHANNELS != N_TX_CHANNELS) $error("N_TX_CHANNELS mismatch");

  localparam N_RX_EXT_CHANNELS = `N_FILTER;
  localparam N_TX_EXT_CHANNELS = 2 * `N_FILTER;
  localparam N_STREAMS = `N_FILTER;
  localparam STREAM_ID_WIDTH = 1;  //$clog2(N_STREAMS)

  localparam N_PERIPHS = `N_SPI + `N_HYPER + `N_UART + `N_MRAM + `N_I2C + `N_CAM + `N_I2S + `N_CSI2 + `N_SDIO + `N_JTAG + `N_FILTER + `N_FPGA + N_EXT_PER;
  if (N_PERIPHS > 28)
    $error("Too many udma periperals: limit is 28 (32 event channels - 4 for FPGA)");

  //TX Channels
  localparam CH_ID_TX_UART = 0;
  localparam CH_ID_TX_SPIM = CH_ID_TX_UART + `N_UART;
  localparam CH_ID_CMD_SPIM = CH_ID_TX_SPIM + `N_SPI;
  localparam CH_ID_TX_I2C = CH_ID_CMD_SPIM + `N_SPI;
  localparam CH_ID_TX_SDIO = CH_ID_TX_I2C + `N_I2C;
  localparam CH_ID_TX_I2S = CH_ID_TX_SDIO + `N_SDIO;
  localparam CH_ID_TX_FPGA = CH_ID_TX_I2S + `N_I2S;
  localparam CH_ID_TX_EXT_PER = CH_ID_TX_FPGA + `N_FPGA;
  if (`CH_ID_TX_EXT_PER != CH_ID_TX_EXT_PER) $error("CH_ID_TX_EXT_PER mismatch");

  //RX Channels
  localparam CH_ID_RX_UART = 0;
  localparam CH_ID_RX_SPIM = CH_ID_RX_UART + `N_UART;
  localparam CH_ID_RX_I2C = CH_ID_RX_SPIM + `N_SPI;
  localparam CH_ID_RX_SDIO = CH_ID_RX_I2C + `N_I2C;
  localparam CH_ID_RX_I2S = CH_ID_RX_SDIO + `N_SDIO;
  localparam CH_ID_RX_CAM = CH_ID_RX_I2S + `N_I2S;
  localparam CH_ID_RX_FPGA = CH_ID_RX_CAM + `N_CAM;
  localparam CH_ID_RX_EXT_PER = CH_ID_RX_FPGA + `N_FPGA;
  if (`CH_ID_RX_EXT_PER != CH_ID_RX_EXT_PER) $error("CH_ID_RX_EXT_PER mismatch");

  // PER_ID definitions
  localparam PER_ID_UART = 0;
  localparam PER_ID_SPIM = PER_ID_UART + `N_UART;
  localparam PER_ID_I2C = PER_ID_SPIM + `N_SPI;
  localparam PER_ID_SDIO = PER_ID_I2C + `N_I2C;
  localparam PER_ID_I2S = PER_ID_SDIO + `N_SDIO;
  localparam PER_ID_CAM = PER_ID_I2S + `N_I2S;
  localparam PER_ID_FILTER = PER_ID_CAM + `N_CAM;
  localparam PER_ID_FPGA = PER_ID_FILTER + `N_FILTER;
  localparam PER_ID_EXT_PER = PER_ID_FPGA + `N_FPGA;
  if (`PER_ID_EXT_PER != PER_ID_EXT_PER) $error("PER_ID_EXT_PER mismatch");


  localparam CH_ID_EXT_TX_FILTER = 0;
  localparam CH_ID_EXT_RX_FILTER = 0;

  localparam STREAM_ID_FILTER = 0;

  logic   [    N_TX_CHANNELS-1:0][ L2_AWIDTH_NOAL-1 : 0] s_tx_cfg_startaddr;
  logic   [    N_TX_CHANNELS-1:0][     TRANS_SIZE-1 : 0] s_tx_cfg_size;
  logic   [    N_TX_CHANNELS-1:0]                        s_tx_cfg_continuous;
  logic   [    N_TX_CHANNELS-1:0]                        s_tx_cfg_en;
  logic   [    N_TX_CHANNELS-1:0]                        s_tx_cfg_clr;

  logic   [    N_TX_CHANNELS-1:0]                        s_tx_ch_req;
  logic   [    N_TX_CHANNELS-1:0]                        s_tx_ch_gnt;
  logic   [    N_TX_CHANNELS-1:0][               31 : 0] s_tx_ch_data;
  logic   [    N_TX_CHANNELS-1:0]                        s_tx_ch_valid;
  logic   [    N_TX_CHANNELS-1:0]                        s_tx_ch_ready;
  logic   [    N_TX_CHANNELS-1:0][                1 : 0] s_tx_ch_datasize;
  logic   [    N_TX_CHANNELS-1:0][      DEST_SIZE-1 : 0] s_tx_ch_destination;
  logic   [    N_TX_CHANNELS-1:0]                        s_tx_ch_events;
  logic   [    N_TX_CHANNELS-1:0]                        s_tx_ch_en;
  logic   [    N_TX_CHANNELS-1:0]                        s_tx_ch_pending;
  logic   [    N_TX_CHANNELS-1:0][ L2_AWIDTH_NOAL-1 : 0] s_tx_ch_curr_addr;
  logic   [    N_TX_CHANNELS-1:0][     TRANS_SIZE-1 : 0] s_tx_ch_bytes_left;

  logic   [    N_RX_CHANNELS-1:0][ L2_AWIDTH_NOAL-1 : 0] s_rx_cfg_startaddr;
  logic   [    N_RX_CHANNELS-1:0][     TRANS_SIZE-1 : 0] s_rx_cfg_size;
  logic   [    N_RX_CHANNELS-1:0]                        s_rx_cfg_continuous;
  logic   [    N_RX_CHANNELS-1:0]                        s_rx_cfg_en;
  logic   [    N_RX_CHANNELS-1:0]                        s_rx_cfg_clr;
  logic   [    N_RX_CHANNELS-1:0][                1 : 0] s_rx_cfg_stream;
  logic   [    N_RX_CHANNELS-1:0][  STREAM_ID_WIDTH-1:0] s_rx_cfg_stream_id;

  logic   [    N_RX_CHANNELS-1:0][               31 : 0] s_rx_ch_data;
  logic   [    N_RX_CHANNELS-1:0]                        s_rx_ch_valid;
  logic   [    N_RX_CHANNELS-1:0]                        s_rx_ch_ready;
  logic   [    N_RX_CHANNELS-1:0][                1 : 0] s_rx_ch_datasize;
  logic   [    N_RX_CHANNELS-1:0][      DEST_SIZE-1 : 0] s_rx_ch_destination;
  logic   [    N_RX_CHANNELS-1:0]                        s_rx_ch_events;
  logic   [    N_RX_CHANNELS-1:0]                        s_rx_ch_en;
  logic   [    N_RX_CHANNELS-1:0]                        s_rx_ch_pending;
  logic   [    N_RX_CHANNELS-1:0][ L2_AWIDTH_NOAL-1 : 0] s_rx_ch_curr_addr;
  logic   [    N_RX_CHANNELS-1:0][     TRANS_SIZE-1 : 0] s_rx_ch_bytes_left;

  logic   [N_RX_EXT_CHANNELS-1:0][ L2_AWIDTH_NOAL-1 : 0] s_rx_ext_addr;
  logic   [N_RX_EXT_CHANNELS-1:0][                1 : 0] s_rx_ext_datasize;
  logic   [N_RX_EXT_CHANNELS-1:0][      DEST_SIZE-1 : 0] s_rx_ext_destination;
  logic   [N_RX_EXT_CHANNELS-1:0][                1 : 0] s_rx_ext_stream;
  logic   [N_RX_EXT_CHANNELS-1:0][STREAM_ID_WIDTH-1 : 0] s_rx_ext_stream_id;
  logic   [N_RX_EXT_CHANNELS-1:0]                        s_rx_ext_sot;
  logic   [N_RX_EXT_CHANNELS-1:0]                        s_rx_ext_eot;
  logic   [N_RX_EXT_CHANNELS-1:0]                        s_rx_ext_valid;
  logic   [N_RX_EXT_CHANNELS-1:0][               31 : 0] s_rx_ext_data;
  logic   [N_RX_EXT_CHANNELS-1:0]                        s_rx_ext_ready;

  logic   [N_TX_EXT_CHANNELS-1:0]                        s_tx_ext_req;
  logic   [N_TX_EXT_CHANNELS-1:0][                1 : 0] s_tx_ext_datasize;
  logic   [N_TX_EXT_CHANNELS-1:0][      DEST_SIZE-1 : 0] s_tx_ext_destination;
  logic   [N_TX_EXT_CHANNELS-1:0][ L2_AWIDTH_NOAL-1 : 0] s_tx_ext_addr;
  logic   [N_TX_EXT_CHANNELS-1:0]                        s_tx_ext_gnt;
  logic   [N_TX_EXT_CHANNELS-1:0]                        s_tx_ext_valid;
  logic   [N_TX_EXT_CHANNELS-1:0][               31 : 0] s_tx_ext_data;
  logic   [N_TX_EXT_CHANNELS-1:0]                        s_tx_ext_ready;

  logic   [        N_STREAMS-1:0][               31 : 0] s_stream_data;
  logic   [        N_STREAMS-1:0][                1 : 0] s_stream_datasize;
  logic   [        N_STREAMS-1:0]                        s_stream_valid;
  logic   [        N_STREAMS-1:0]                        s_stream_sot;
  logic   [        N_STREAMS-1:0]                        s_stream_eot;
  logic   [        N_STREAMS-1:0]                        s_stream_ready;

  logic   [             16*8-1:0]                        s_events;

  logic   [                  1:0]                        s_rf_event;

  logic   [        N_PERIPHS-1:0]                        s_clk_periphs_core;
  logic   [        N_PERIPHS-1:0]                        s_clk_periphs_per;

  logic   [                 31:0]                        s_periph_data_to;
  logic   [                  4:0]                        s_periph_addr;
  logic                                                  s_periph_rwn;
  logic   [        N_PERIPHS-1:0][                 31:0] s_periph_data_from;
  logic   [        N_PERIPHS-1:0]                        s_periph_valid;
  logic   [        N_PERIPHS-1:0]                        s_periph_ready;

  logic   [           `N_SPI-1:0]                        s_spi_eot;
  logic   [           `N_I2C-1:0]                        s_i2c_evt;
  logic   [          `N_UART-1:0]                        s_uart_evt;
  logic   [          `N_UART-1:0]                        s_uart_err;

  logic   [                  3:0]                        s_trigger_events;

  logic                                                  s_cam_evt;
  logic                                                  s_i2s_evt;
  logic                                                  s_i2c1_evt;

  logic                                                  s_filter_eot_evt;
  logic                                                  s_filter_act_evt;


  integer                                                i;

  assign s_cam_evt     = 1'b0;
  assign s_i2s_evt     = 1'b0;
  //assign s_uart_evt    = 1'b0;

  assign events_o      = s_events;

  assign L2_ro_wen_o   = 1'b1;
  assign L2_wo_wen_o   = 1'b0;

  assign L2_ro_be_o    = 'h0;
  assign L2_ro_wdata_o = 'h0;

  udma_core #(
      .L2_AWIDTH_NOAL   (L2_AWIDTH_NOAL),
      .L2_DATA_WIDTH    (L2_DATA_WIDTH),
      .DATA_WIDTH       (32),
      .N_RX_LIN_CHANNELS(N_RX_CHANNELS),
      .N_TX_LIN_CHANNELS(N_TX_CHANNELS),
      .N_RX_EXT_CHANNELS(N_RX_EXT_CHANNELS),
      .N_TX_EXT_CHANNELS(N_TX_EXT_CHANNELS),
      .N_STREAMS        (N_STREAMS),
      .STREAM_ID_WIDTH  (STREAM_ID_WIDTH),
      .TRANS_SIZE       (TRANS_SIZE),
      .N_PERIPHS        (N_PERIPHS),
      .APB_ADDR_WIDTH   (APB_ADDR_WIDTH)
  ) i_udmacore (
      .sys_clk_i(sys_clk_i),
      .per_clk_i(periph_clk_i),

      .dft_cg_enable_i(dft_cg_enable_i),

      .HRESETn(sys_resetn_i),

      .PADDR  (udma_apb_paddr),
      .PWDATA (udma_apb_pwdata),
      .PWRITE (udma_apb_pwrite),
      .PSEL   (udma_apb_psel),
      .PENABLE(udma_apb_penable),
      .PRDATA (udma_apb_prdata),
      .PREADY (udma_apb_pready),
      .PSLVERR(udma_apb_pslverr),

      .periph_per_clk_o(s_clk_periphs_per),
      .periph_sys_clk_o(s_clk_periphs_core),

      .event_valid_i(event_valid_i),
      .event_data_i (event_data_i),
      .event_ready_o(event_ready_o),

      .event_o(s_trigger_events),

      .periph_data_to_o  (s_periph_data_to),
      .periph_addr_o     (s_periph_addr),
      .periph_data_from_i(s_periph_data_from),
      .periph_ready_i    (s_periph_ready),
      .periph_valid_o    (s_periph_valid),
      .periph_rwn_o      (s_periph_rwn),

      .tx_l2_req_o   (L2_ro_req_o),
      .tx_l2_gnt_i   (L2_ro_gnt_i),
      .tx_l2_addr_o  (L2_ro_addr_o),
      .tx_l2_rdata_i (L2_ro_rdata_i),
      .tx_l2_rvalid_i(L2_ro_rvalid_i),

      .rx_l2_req_o  (L2_wo_req_o),
      .rx_l2_gnt_i  (L2_wo_gnt_i),
      .rx_l2_addr_o (L2_wo_addr_o),
      .rx_l2_be_o   (L2_wo_be_o),
      .rx_l2_wdata_o(L2_wo_wdata_o),

      .stream_data_o    (s_stream_data),
      .stream_datasize_o(s_stream_datasize),
      .stream_valid_o   (s_stream_valid),
      .stream_sot_o     (s_stream_sot),
      .stream_eot_o     (s_stream_eot),
      .stream_ready_i   (s_stream_ready),

      .tx_lin_req_i           (s_tx_ch_req),
      .tx_lin_gnt_o           (s_tx_ch_gnt),
      .tx_lin_valid_o         (s_tx_ch_valid),
      .tx_lin_data_o          (s_tx_ch_data),
      .tx_lin_ready_i         (s_tx_ch_ready),
      .tx_lin_datasize_i      (s_tx_ch_datasize),
      .tx_lin_destination_i   (s_tx_ch_destination),
      .tx_lin_events_o        (s_tx_ch_events),
      .tx_lin_en_o            (s_tx_ch_en),
      .tx_lin_pending_o       (s_tx_ch_pending),
      .tx_lin_curr_addr_o     (s_tx_ch_curr_addr),
      .tx_lin_bytes_left_o    (s_tx_ch_bytes_left),
      .tx_lin_cfg_startaddr_i (s_tx_cfg_startaddr),
      .tx_lin_cfg_size_i      (s_tx_cfg_size),
      .tx_lin_cfg_continuous_i(s_tx_cfg_continuous),
      .tx_lin_cfg_en_i        (s_tx_cfg_en),
      .tx_lin_cfg_clr_i       (s_tx_cfg_clr),

      .rx_lin_valid_i         (s_rx_ch_valid),
      .rx_lin_data_i          (s_rx_ch_data),
      .rx_lin_ready_o         (s_rx_ch_ready),
      .rx_lin_datasize_i      (s_rx_ch_datasize),
      .rx_lin_destination_i   (s_rx_ch_destination),
      .rx_lin_events_o        (s_rx_ch_events),
      .rx_lin_en_o            (s_rx_ch_en),
      .rx_lin_pending_o       (s_rx_ch_pending),
      .rx_lin_curr_addr_o     (s_rx_ch_curr_addr),
      .rx_lin_bytes_left_o    (s_rx_ch_bytes_left),
      .rx_lin_cfg_startaddr_i (s_rx_cfg_startaddr),
      .rx_lin_cfg_size_i      (s_rx_cfg_size),
      .rx_lin_cfg_continuous_i(s_rx_cfg_continuous),
      .rx_lin_cfg_stream_i    (s_rx_cfg_stream),
      .rx_lin_cfg_stream_id_i (s_rx_cfg_stream_id),
      .rx_lin_cfg_en_i        (s_rx_cfg_en),
      .rx_lin_cfg_clr_i       (s_rx_cfg_clr),

      .rx_ext_addr_i       (s_rx_ext_addr),
      .rx_ext_datasize_i   (s_rx_ext_datasize),
      .rx_ext_destination_i(s_rx_ext_destination),
      .rx_ext_stream_i     (s_rx_ext_stream),
      .rx_ext_stream_id_i  (s_rx_ext_stream_id),
      .rx_ext_sot_i        (s_rx_ext_sot),
      .rx_ext_eot_i        (s_rx_ext_eot),
      .rx_ext_valid_i      (s_rx_ext_valid),
      .rx_ext_data_i       (s_rx_ext_data),
      .rx_ext_ready_o      (s_rx_ext_ready),

      .tx_ext_req_i        (s_tx_ext_req),
      .tx_ext_datasize_i   (s_tx_ext_datasize),
      .tx_ext_destination_i(s_tx_ext_destination),
      .tx_ext_addr_i       (s_tx_ext_addr),
      .tx_ext_gnt_o        (s_tx_ext_gnt),
      .tx_ext_valid_o      (s_tx_ext_valid),
      .tx_ext_data_o       (s_tx_ext_data),
      .tx_ext_ready_i      (s_tx_ext_ready)

  );

  // UARTS
  generate
    genvar g_uart;
    for (g_uart = 0; g_uart < `N_UART; g_uart++) begin : i_uart_gen
      assign s_events[4*(PER_ID_UART+g_uart)+0] = s_rx_ch_events[CH_ID_RX_UART+g_uart];
      assign s_events[4*(PER_ID_UART+g_uart)+1] = s_tx_ch_events[CH_ID_TX_UART+g_uart];
      assign s_events[4*(PER_ID_UART+g_uart)+2] = s_uart_evt[g_uart];
      assign s_events[4*(PER_ID_UART+g_uart)+3] = s_uart_err[g_uart];

      assign s_rx_cfg_stream[CH_ID_RX_UART+g_uart] = 'h0;
      assign s_rx_cfg_stream_id[CH_ID_RX_UART+g_uart] = 'h0;
      assign s_rx_ch_destination[CH_ID_RX_UART+g_uart] = 'h0;
      assign s_tx_ch_destination[CH_ID_TX_UART+g_uart] = 'h0;

      udma_uart_top #(
          .L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
          .TRANS_SIZE(TRANS_SIZE)
      ) i_uart (
          .sys_clk_i   (s_clk_periphs_core[PER_ID_UART+g_uart]),
          .periph_clk_i(s_clk_periphs_per[PER_ID_UART+g_uart]),
          .rstn_i      (sys_resetn_i),

          // .uart_tx_o           ( uart_tx_o[g_uart]                       ),
          // .uart_rx_i           ( uart_rx_i[g_uart]                       ),

          // Signals to pads
          .uart_tx_o(perio_out_o[`PERIO_UART0_TX+`PERIO_UART_NPORTS*g_uart]),
          .uart_rx_i(perio_in_i[`PERIO_UART0_RX+`PERIO_UART_NPORTS*g_uart]),

          .rx_char_event_o(s_uart_evt[g_uart]),
          .err_event_o(s_uart_err[g_uart]),

          .cfg_data_i (s_periph_data_to),
          .cfg_addr_i (s_periph_addr),
          .cfg_valid_i(s_periph_valid[PER_ID_UART+g_uart]),
          .cfg_rwn_i  (s_periph_rwn),
          .cfg_data_o (s_periph_data_from[PER_ID_UART+g_uart]),
          .cfg_ready_o(s_periph_ready[PER_ID_UART+g_uart]),

          .cfg_rx_startaddr_o (s_rx_cfg_startaddr[CH_ID_RX_UART+g_uart]),
          .cfg_rx_size_o      (s_rx_cfg_size[CH_ID_RX_UART+g_uart]),
          .cfg_rx_continuous_o(s_rx_cfg_continuous[CH_ID_RX_UART+g_uart]),
          .cfg_rx_en_o        (s_rx_cfg_en[CH_ID_RX_UART+g_uart]),
          .cfg_rx_clr_o       (s_rx_cfg_clr[CH_ID_RX_UART+g_uart]),
          .cfg_rx_en_i        (s_rx_ch_en[CH_ID_RX_UART+g_uart]),
          .cfg_rx_pending_i   (s_rx_ch_pending[CH_ID_RX_UART+g_uart]),
          .cfg_rx_curr_addr_i (s_rx_ch_curr_addr[CH_ID_RX_UART+g_uart]),
          .cfg_rx_bytes_left_i(s_rx_ch_bytes_left[CH_ID_RX_UART+g_uart]),
          .cfg_rx_datasize_o  (),  // FIXME ANTONIO

          .cfg_tx_startaddr_o (s_tx_cfg_startaddr[CH_ID_TX_UART+g_uart]),
          .cfg_tx_size_o      (s_tx_cfg_size[CH_ID_TX_UART+g_uart]),
          .cfg_tx_continuous_o(s_tx_cfg_continuous[CH_ID_TX_UART+g_uart]),
          .cfg_tx_en_o        (s_tx_cfg_en[CH_ID_TX_UART+g_uart]),
          .cfg_tx_clr_o       (s_tx_cfg_clr[CH_ID_TX_UART+g_uart]),
          .cfg_tx_en_i        (s_tx_ch_en[CH_ID_TX_UART+g_uart]),
          .cfg_tx_pending_i   (s_tx_ch_pending[CH_ID_TX_UART+g_uart]),
          .cfg_tx_curr_addr_i (s_tx_ch_curr_addr[CH_ID_TX_UART+g_uart]),
          .cfg_tx_bytes_left_i(s_tx_ch_bytes_left[CH_ID_TX_UART+g_uart]),
          .cfg_tx_datasize_o  (),  // FIXME ANTONIO

          .data_tx_req_o     (s_tx_ch_req[CH_ID_TX_UART+g_uart]),
          .data_tx_gnt_i     (s_tx_ch_gnt[CH_ID_TX_UART+g_uart]),
          .data_tx_datasize_o(s_tx_ch_datasize[CH_ID_TX_UART+g_uart]),
          .data_tx_i         (s_tx_ch_data[CH_ID_TX_UART+g_uart]),
          .data_tx_valid_i   (s_tx_ch_valid[CH_ID_TX_UART+g_uart]),
          .data_tx_ready_o   (s_tx_ch_ready[CH_ID_TX_UART+g_uart]),

          .data_rx_datasize_o(s_rx_ch_datasize[CH_ID_RX_UART+g_uart]),
          .data_rx_o         (s_rx_ch_data[CH_ID_RX_UART+g_uart]),
          .data_rx_valid_o   (s_rx_ch_valid[CH_ID_RX_UART+g_uart]),
          .data_rx_ready_i   (s_rx_ch_ready[CH_ID_RX_UART+g_uart])
      );
    end
  endgenerate

  // SPIM
  generate
    for (genvar g_spi = 0; g_spi < `N_SPI; g_spi++) begin : i_spim_gen
      assign s_events[4*(PER_ID_SPIM+g_spi)+0] = s_rx_ch_events[CH_ID_RX_SPIM+g_spi];
      assign s_events[4*(PER_ID_SPIM+g_spi)+1] = s_tx_ch_events[CH_ID_TX_SPIM+g_spi];
      assign s_events[4*(PER_ID_SPIM+g_spi)+2] = s_tx_ch_events[CH_ID_CMD_SPIM+g_spi];
      assign s_events[4*(PER_ID_SPIM+g_spi)+3] = s_spi_eot[g_spi];

      assign s_rx_cfg_stream[CH_ID_RX_SPIM+g_spi] = 'h0;
      assign s_rx_cfg_stream_id[CH_ID_RX_SPIM+g_spi] = 'h0;
      assign s_rx_ch_destination[CH_ID_RX_SPIM+g_spi] = 'h0;
      assign s_tx_ch_destination[CH_ID_TX_SPIM+g_spi] = 'h0;
      assign s_tx_ch_destination[CH_ID_CMD_SPIM+g_spi] = 'h0;
      udma_spim_top #(
          .L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
          .TRANS_SIZE    (TRANS_SIZE)
      ) i_spim (
          .sys_clk_i      (s_clk_periphs_core[PER_ID_SPIM+g_spi]),
          .periph_clk_i   (s_clk_periphs_per[PER_ID_SPIM+g_spi]),
          .rstn_i         (sys_resetn_i),
          .dft_test_mode_i(dft_test_mode_i),
          .dft_cg_enable_i(dft_cg_enable_i),
          .spi_eot_o      (s_spi_eot[g_spi]),
          .spi_event_i    (s_trigger_events),

          // .spi_clk_o           ( spi_clk[g_spi]                           ),
          // .spi_csn0_o          ( spi_csn[g_spi][0]                        ),
          // .spi_csn1_o          ( spi_csn[g_spi][1]                        ),
          // .spi_csn2_o          ( spi_csn[g_spi][2]                        ),
          // .spi_csn3_o          ( spi_csn[g_spi][3]                        ),
          // .spi_oen0_o          ( spi_oen[g_spi][0]                        ),
          // .spi_oen1_o          ( spi_oen[g_spi][1]                        ),
          // .spi_oen2_o          ( spi_oen[g_spi][2]                        ),
          // .spi_oen3_o          ( spi_oen[g_spi][3]                        ),
          // .spi_sdo0_o          ( spi_sdo[g_spi][0]                        ),
          // .spi_sdo1_o          ( spi_sdo[g_spi][1]                        ),
          // .spi_sdo2_o          ( spi_sdo[g_spi][2]                        ),
          // .spi_sdo3_o          ( spi_sdo[g_spi][3]                        ),
          // .spi_sdi0_i          ( spi_sdi[g_spi][0]                        ),
          // .spi_sdi1_i          ( spi_sdi[g_spi][1]                        ),
          // .spi_sdi2_i          ( spi_sdi[g_spi][2]                        ),
          // .spi_sdi3_i          ( spi_sdi[g_spi][3]                        ),

          // Signals to pads
          .spi_clk_o (perio_out_o[`PERIO_QSPIM0_CLK+`PERIO_QSPIM_NPORTS*g_spi]),
          .spi_csn0_o(perio_out_o[`PERIO_QSPIM0_CSN0+`PERIO_QSPIM_NPORTS*g_spi]),
          .spi_csn1_o(perio_out_o[`PERIO_QSPIM0_CSN1+`PERIO_QSPIM_NPORTS*g_spi]),
          .spi_csn2_o(perio_out_o[`PERIO_QSPIM0_CSN2+`PERIO_QSPIM_NPORTS*g_spi]),
          .spi_csn3_o(perio_out_o[`PERIO_QSPIM0_CSN3+`PERIO_QSPIM_NPORTS*g_spi]),
          .spi_sdi0_i(perio_in_i[`PERIO_QSPIM0_DATA0+`PERIO_QSPIM_NPORTS*g_spi]),
          .spi_sdo0_o(perio_out_o[`PERIO_QSPIM0_DATA0+`PERIO_QSPIM_NPORTS*g_spi]),
          .spi_oe0_o (perio_oe_o[`PERIO_QSPIM0_DATA0+`PERIO_QSPIM_NPORTS*g_spi]),
          .spi_sdi1_i(perio_in_i[`PERIO_QSPIM0_DATA1+`PERIO_QSPIM_NPORTS*g_spi]),
          .spi_sdo1_o(perio_out_o[`PERIO_QSPIM0_DATA1+`PERIO_QSPIM_NPORTS*g_spi]),
          .spi_oe1_o (perio_oe_o[`PERIO_QSPIM0_DATA1+`PERIO_QSPIM_NPORTS*g_spi]),
          .spi_sdi2_i(perio_in_i[`PERIO_QSPIM0_DATA2+`PERIO_QSPIM_NPORTS*g_spi]),
          .spi_sdo2_o(perio_out_o[`PERIO_QSPIM0_DATA2+`PERIO_QSPIM_NPORTS*g_spi]),
          .spi_oe2_o (perio_oe_o[`PERIO_QSPIM0_DATA2+`PERIO_QSPIM_NPORTS*g_spi]),
          .spi_sdi3_i(perio_in_i[`PERIO_QSPIM0_DATA3+`PERIO_QSPIM_NPORTS*g_spi]),
          .spi_sdo3_o(perio_out_o[`PERIO_QSPIM0_DATA3+`PERIO_QSPIM_NPORTS*g_spi]),
          .spi_oe3_o (perio_oe_o[`PERIO_QSPIM0_DATA3+`PERIO_QSPIM_NPORTS*g_spi]),

          .cfg_data_i (s_periph_data_to),
          .cfg_addr_i (s_periph_addr),
          .cfg_valid_i(s_periph_valid[PER_ID_SPIM+g_spi]),
          .cfg_rwn_i  (s_periph_rwn),
          .cfg_data_o (s_periph_data_from[PER_ID_SPIM+g_spi]),
          .cfg_ready_o(s_periph_ready[PER_ID_SPIM+g_spi]),

          .cmd_req_o     (s_tx_ch_req[CH_ID_CMD_SPIM+g_spi]),
          .cmd_gnt_i     (s_tx_ch_gnt[CH_ID_CMD_SPIM+g_spi]),
          .cmd_datasize_o(s_tx_ch_datasize[CH_ID_CMD_SPIM+g_spi]),
          .cmd_i         (s_tx_ch_data[CH_ID_CMD_SPIM+g_spi]),
          .cmd_valid_i   (s_tx_ch_valid[CH_ID_CMD_SPIM+g_spi]),
          .cmd_ready_o   (s_tx_ch_ready[CH_ID_CMD_SPIM+g_spi]),

          .data_tx_req_o     (s_tx_ch_req[CH_ID_TX_SPIM+g_spi]),
          .data_tx_gnt_i     (s_tx_ch_gnt[CH_ID_TX_SPIM+g_spi]),
          .data_tx_datasize_o(s_tx_ch_datasize[CH_ID_TX_SPIM+g_spi]),
          .data_tx_i         (s_tx_ch_data[CH_ID_TX_SPIM+g_spi]),
          .data_tx_valid_i   (s_tx_ch_valid[CH_ID_TX_SPIM+g_spi]),
          .data_tx_ready_o   (s_tx_ch_ready[CH_ID_TX_SPIM+g_spi]),

          .data_rx_datasize_o(s_rx_ch_datasize[CH_ID_RX_SPIM+g_spi]),
          .data_rx_o         (s_rx_ch_data[CH_ID_RX_SPIM+g_spi]),
          .data_rx_valid_o   (s_rx_ch_valid[CH_ID_RX_SPIM+g_spi]),
          .data_rx_ready_i   (s_rx_ch_ready[CH_ID_RX_SPIM+g_spi]),

          .cfg_cmd_startaddr_o (s_tx_cfg_startaddr[CH_ID_CMD_SPIM+g_spi]),
          .cfg_cmd_size_o      (s_tx_cfg_size[CH_ID_CMD_SPIM+g_spi]),
          .cfg_cmd_continuous_o(s_tx_cfg_continuous[CH_ID_CMD_SPIM+g_spi]),
          .cfg_cmd_en_o        (s_tx_cfg_en[CH_ID_CMD_SPIM+g_spi]),
          .cfg_cmd_clr_o       (s_tx_cfg_clr[CH_ID_CMD_SPIM+g_spi]),
          .cfg_cmd_en_i        (s_tx_ch_en[CH_ID_CMD_SPIM+g_spi]),
          .cfg_cmd_pending_i   (s_tx_ch_pending[CH_ID_CMD_SPIM+g_spi]),
          .cfg_cmd_curr_addr_i (s_tx_ch_curr_addr[CH_ID_CMD_SPIM+g_spi]),
          .cfg_cmd_bytes_left_i(s_tx_ch_bytes_left[CH_ID_CMD_SPIM+g_spi]),

          .cfg_tx_startaddr_o (s_tx_cfg_startaddr[CH_ID_TX_SPIM+g_spi]),
          .cfg_tx_size_o      (s_tx_cfg_size[CH_ID_TX_SPIM+g_spi]),
          .cfg_tx_continuous_o(s_tx_cfg_continuous[CH_ID_TX_SPIM+g_spi]),
          .cfg_tx_en_o        (s_tx_cfg_en[CH_ID_TX_SPIM+g_spi]),
          .cfg_tx_clr_o       (s_tx_cfg_clr[CH_ID_TX_SPIM+g_spi]),
          .cfg_tx_en_i        (s_tx_ch_en[CH_ID_TX_SPIM+g_spi]),
          .cfg_tx_pending_i   (s_tx_ch_pending[CH_ID_TX_SPIM+g_spi]),
          .cfg_tx_curr_addr_i (s_tx_ch_curr_addr[CH_ID_TX_SPIM+g_spi]),
          .cfg_tx_bytes_left_i(s_tx_ch_bytes_left[CH_ID_TX_SPIM+g_spi]),

          .cfg_rx_startaddr_o (s_rx_cfg_startaddr[CH_ID_RX_SPIM+g_spi]),
          .cfg_rx_size_o      (s_rx_cfg_size[CH_ID_RX_SPIM+g_spi]),
          .cfg_rx_continuous_o(s_rx_cfg_continuous[CH_ID_RX_SPIM+g_spi]),
          .cfg_rx_en_o        (s_rx_cfg_en[CH_ID_RX_SPIM+g_spi]),
          .cfg_rx_clr_o       (s_rx_cfg_clr[CH_ID_RX_SPIM+g_spi]),
          .cfg_rx_en_i        (s_rx_ch_en[CH_ID_RX_SPIM+g_spi]),
          .cfg_rx_pending_i   (s_rx_ch_pending[CH_ID_RX_SPIM+g_spi]),
          .cfg_rx_curr_addr_i (s_rx_ch_curr_addr[CH_ID_RX_SPIM+g_spi]),
          .cfg_rx_bytes_left_i(s_rx_ch_bytes_left[CH_ID_RX_SPIM+g_spi])
      );
    end
  endgenerate

  // I2C
  generate
    for (genvar g_i2c = 0; g_i2c < `N_I2C; g_i2c++) begin : i_i2c_gen
      assign s_events[4*(PER_ID_I2C+g_i2c)+0] = s_rx_ch_events[CH_ID_RX_I2C+g_i2c];
      assign s_events[4*(PER_ID_I2C+g_i2c)+1] = s_tx_ch_events[CH_ID_TX_I2C+g_i2c];
      assign s_events[4*(PER_ID_I2C+g_i2c)+2] = 1'b0;
      assign s_events[4*(PER_ID_I2C+g_i2c)+3] = 1'b0;

      assign s_rx_cfg_stream[CH_ID_RX_I2C+g_i2c] = 'h0;
      assign s_rx_cfg_stream_id[CH_ID_RX_I2C+g_i2c] = 'h0;
      assign s_rx_ch_destination[CH_ID_RX_I2C+g_i2c] = 'h0;
      assign s_tx_ch_destination[CH_ID_TX_I2C+g_i2c] = 'h0;

      udma_i2c_top #(
          .L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
          .TRANS_SIZE(TRANS_SIZE)
      ) i_i2c (
          //
          // inputs & outputs
          //
          .sys_clk_i   (s_clk_periphs_core[PER_ID_I2C+g_i2c]),
          .periph_clk_i(s_clk_periphs_per[PER_ID_I2C+g_i2c]),
          .rstn_i      (sys_resetn_i),

          .cfg_data_i (s_periph_data_to),
          .cfg_addr_i (s_periph_addr),
          .cfg_valid_i(s_periph_valid[PER_ID_I2C+g_i2c]),
          .cfg_rwn_i  (s_periph_rwn),
          .cfg_data_o (s_periph_data_from[PER_ID_I2C+g_i2c]),
          .cfg_ready_o(s_periph_ready[PER_ID_I2C+g_i2c]),


          .cfg_tx_startaddr_o (s_tx_cfg_startaddr[CH_ID_TX_I2C+g_i2c]),
          .cfg_tx_size_o      (s_tx_cfg_size[CH_ID_TX_I2C+g_i2c]),
          .cfg_tx_continuous_o(s_tx_cfg_continuous[CH_ID_TX_I2C+g_i2c]),
          .cfg_tx_en_o        (s_tx_cfg_en[CH_ID_TX_I2C+g_i2c]),
          .cfg_tx_clr_o       (s_tx_cfg_clr[CH_ID_TX_I2C+g_i2c]),
          .cfg_tx_en_i        (s_tx_ch_en[CH_ID_TX_I2C+g_i2c]),
          .cfg_tx_pending_i   (s_tx_ch_pending[CH_ID_TX_I2C+g_i2c]),
          .cfg_tx_curr_addr_i (s_tx_ch_curr_addr[CH_ID_TX_I2C+g_i2c]),
          .cfg_tx_bytes_left_i(s_tx_ch_bytes_left[CH_ID_TX_I2C+g_i2c]),

          .cfg_rx_startaddr_o (s_rx_cfg_startaddr[CH_ID_RX_I2C+g_i2c]),
          .cfg_rx_size_o      (s_rx_cfg_size[CH_ID_RX_I2C+g_i2c]),
          .cfg_rx_continuous_o(s_rx_cfg_continuous[CH_ID_RX_I2C+g_i2c]),
          .cfg_rx_en_o        (s_rx_cfg_en[CH_ID_RX_I2C+g_i2c]),
          .cfg_rx_clr_o       (s_rx_cfg_clr[CH_ID_RX_I2C+g_i2c]),
          .cfg_rx_en_i        (s_rx_ch_en[CH_ID_RX_I2C+g_i2c]),
          .cfg_rx_pending_i   (s_rx_ch_pending[CH_ID_RX_I2C+g_i2c]),
          .cfg_rx_curr_addr_i (s_rx_ch_curr_addr[CH_ID_RX_I2C+g_i2c]),
          .cfg_rx_bytes_left_i(s_rx_ch_bytes_left[CH_ID_RX_I2C+g_i2c]),

          .data_tx_req_o     (s_tx_ch_req[CH_ID_TX_I2C+g_i2c]),
          .data_tx_gnt_i     (s_tx_ch_gnt[CH_ID_TX_I2C+g_i2c]),
          .data_tx_datasize_o(s_tx_ch_datasize[CH_ID_TX_I2C+g_i2c]),
          .data_tx_i         (s_tx_ch_data[CH_ID_TX_I2C+g_i2c][7:0]),
          .data_tx_valid_i   (s_tx_ch_valid[CH_ID_TX_I2C+g_i2c]),
          .data_tx_ready_o   (s_tx_ch_ready[CH_ID_TX_I2C+g_i2c]),

          .data_rx_datasize_o(s_rx_ch_datasize[CH_ID_RX_I2C+g_i2c]),
          .data_rx_o         (s_rx_ch_data[CH_ID_RX_I2C+g_i2c][7:0]),
          .data_rx_valid_o   (s_rx_ch_valid[CH_ID_RX_I2C+g_i2c]),
          .data_rx_ready_i   (s_rx_ch_ready[CH_ID_RX_I2C+g_i2c]),

          .err_o(s_i2c_evt[g_i2c]),

          // .scl_i               ( i2c_scl_i[g_i2c]                      ),
          // .scl_o               ( i2c_scl_o[g_i2c]                      ),
          // .scl_oe              ( i2c_scl_oe[g_i2c]                     ),
          // .sda_i               ( i2c_sda_i[g_i2c]                      ),
          // .sda_o               ( i2c_sda_o[g_i2c]                      ),
          // .sda_oe              ( i2c_sda_oe[g_i2c]                     ),

          // Signals to pads
          .scl_i (perio_in_i[`PERIO_I2CM0_SCL+`PERIO_I2CM_NPORTS*g_i2c]),
          .scl_o (perio_out_o[`PERIO_I2CM0_SCL+`PERIO_I2CM_NPORTS*g_i2c]),
          .scl_oe(perio_oe_o[`PERIO_I2CM0_SCL+`PERIO_I2CM_NPORTS*g_i2c]),
          .sda_i (perio_in_i[`PERIO_I2CM0_SDA+`PERIO_I2CM_NPORTS*g_i2c]),
          .sda_o (perio_out_o[`PERIO_I2CM0_SDA+`PERIO_I2CM_NPORTS*g_i2c]),
          .sda_oe(perio_oe_o[`PERIO_I2CM0_SDA+`PERIO_I2CM_NPORTS*g_i2c]),

          .ext_events_i(s_trigger_events)
      );
      assign s_rx_ch_data[CH_ID_RX_I2C+g_i2c][31:8] = 'h0;
    end
  endgenerate

  // SDIO
  generate
    for (genvar g_sdio = 0; g_sdio < `N_SDIO; g_sdio++) begin : i_sdio_gen
      logic       s_sdio_eot;
      logic       s_sdio_err;
      logic [3:0] s_sddata_oen;

      assign s_events[4*(PER_ID_SDIO+g_sdio)+0] = s_rx_ch_events[CH_ID_RX_SDIO+g_sdio];
      assign s_events[4*(PER_ID_SDIO+g_sdio)+1] = s_tx_ch_events[CH_ID_TX_SDIO+g_sdio];
      assign s_events[4*(PER_ID_SDIO+g_sdio)+2] = s_sdio_eot;
      assign s_events[4*(PER_ID_SDIO+g_sdio)+3] = s_sdio_err;
      assign s_rx_cfg_stream[CH_ID_RX_SDIO+g_sdio] = 'h0;
      assign s_rx_cfg_stream_id[CH_ID_RX_SDIO+g_sdio] = 'h0;
      assign s_rx_ch_destination[CH_ID_RX_SDIO+g_sdio] = 'h0;
      assign s_tx_ch_destination[CH_ID_TX_SDIO+g_sdio] = 'h0;

      assign perio_oe_o[`PERIO_SDIO_NPORTS * g_sdio + `PERIO_SDIO0_DATA3 : `PERIO_SDIO_NPORTS * g_sdio + `PERIO_SDIO0_DATA0] = ~s_sddata_oen;

      udma_sdio_top #(
          .L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
          .TRANS_SIZE    (TRANS_SIZE)
      ) i_sdio (
          .sys_clk_i   (s_clk_periphs_core[(PER_ID_SDIO+g_sdio)]),
          .periph_clk_i(s_clk_periphs_per[(PER_ID_SDIO+g_sdio)]),
          .rstn_i      (sys_resetn_i),

          .err_o(s_sdio_err),
          .eot_o(s_sdio_eot),

          .sdclk_o(perio_out_o[`PERIO_SDIO0_CLK+`PERIO_SDIO_NPORTS*g_sdio]),
          .sdcmd_i(perio_in_i[`PERIO_SDIO0_CMD+`PERIO_SDIO_NPORTS*g_sdio]),
          .sdcmd_o(perio_out_o[`PERIO_SDIO0_CMD+`PERIO_SDIO_NPORTS*g_sdio]),
          .sdcmd_oen_o(perio_oe_o[`PERIO_SDIO0_CMD+`PERIO_SDIO_NPORTS*g_sdio]),
          .sddata_i            ( perio_in_i[`PERIO_SDIO0_DATA3 + `PERIO_SDIO_NPORTS * g_sdio : `PERIO_SDIO0_DATA0 + `PERIO_SDIO_NPORTS * g_sdio]     ),
          .sddata_o            ( perio_out_o[`PERIO_SDIO0_DATA3 + `PERIO_SDIO_NPORTS * g_sdio : `PERIO_SDIO0_DATA0 + `PERIO_SDIO_NPORTS * g_sdio]     ),
          .sddata_oen_o(s_sddata_oen),

          .cfg_data_i (s_periph_data_to),
          .cfg_addr_i (s_periph_addr),
          .cfg_valid_i(s_periph_valid[(PER_ID_SDIO+g_sdio)]),
          .cfg_rwn_i  (s_periph_rwn),
          .cfg_data_o (s_periph_data_from[(PER_ID_SDIO+g_sdio)]),
          .cfg_ready_o(s_periph_ready[(PER_ID_SDIO+g_sdio)]),

          .cfg_rx_startaddr_o (s_rx_cfg_startaddr[CH_ID_RX_SDIO+g_sdio]),
          .cfg_rx_size_o      (s_rx_cfg_size[CH_ID_RX_SDIO+g_sdio]),
          .cfg_rx_continuous_o(s_rx_cfg_continuous[CH_ID_RX_SDIO+g_sdio]),
          .cfg_rx_en_o        (s_rx_cfg_en[CH_ID_RX_SDIO+g_sdio]),
          .cfg_rx_clr_o       (s_rx_cfg_clr[CH_ID_RX_SDIO+g_sdio]),
          .cfg_rx_en_i        (s_rx_ch_en[CH_ID_RX_SDIO+g_sdio]),
          .cfg_rx_pending_i   (s_rx_ch_pending[CH_ID_RX_SDIO+g_sdio]),
          .cfg_rx_curr_addr_i (s_rx_ch_curr_addr[CH_ID_RX_SDIO+g_sdio]),
          .cfg_rx_bytes_left_i(s_rx_ch_bytes_left[CH_ID_RX_SDIO+g_sdio]),

          .cfg_tx_startaddr_o (s_tx_cfg_startaddr[CH_ID_TX_SDIO+g_sdio]),
          .cfg_tx_size_o      (s_tx_cfg_size[CH_ID_TX_SDIO+g_sdio]),
          .cfg_tx_continuous_o(s_tx_cfg_continuous[CH_ID_TX_SDIO+g_sdio]),
          .cfg_tx_en_o        (s_tx_cfg_en[CH_ID_TX_SDIO+g_sdio]),
          .cfg_tx_clr_o       (s_tx_cfg_clr[CH_ID_TX_SDIO+g_sdio]),
          .cfg_tx_en_i        (s_tx_ch_en[CH_ID_TX_SDIO+g_sdio]),
          .cfg_tx_pending_i   (s_tx_ch_pending[CH_ID_TX_SDIO+g_sdio]),
          .cfg_tx_curr_addr_i (s_tx_ch_curr_addr[CH_ID_TX_SDIO+g_sdio]),
          .cfg_tx_bytes_left_i(s_tx_ch_bytes_left[CH_ID_TX_SDIO+g_sdio]),

          .data_tx_req_o     (s_tx_ch_req[CH_ID_TX_SDIO+g_sdio]),
          .data_tx_gnt_i     (s_tx_ch_gnt[CH_ID_TX_SDIO+g_sdio]),
          .data_tx_datasize_o(s_tx_ch_datasize[CH_ID_TX_SDIO+g_sdio]),
          .data_tx_i         (s_tx_ch_data[CH_ID_TX_SDIO+g_sdio]),
          .data_tx_valid_i   (s_tx_ch_valid[CH_ID_TX_SDIO+g_sdio]),
          .data_tx_ready_o   (s_tx_ch_ready[CH_ID_TX_SDIO+g_sdio]),

          .data_rx_datasize_o(s_rx_ch_datasize[CH_ID_RX_SDIO+g_sdio]),
          .data_rx_o         (s_rx_ch_data[CH_ID_RX_SDIO+g_sdio]),
          .data_rx_valid_o   (s_rx_ch_valid[CH_ID_RX_SDIO+g_sdio]),
          .data_rx_ready_i   (s_rx_ch_ready[CH_ID_RX_SDIO+g_sdio])
      );
    end
  endgenerate


  // I2S
  generate
    for (genvar g_i2s = 0; g_i2s < `N_I2S; g_i2s++) begin : i_i2s_gen
      assign s_events[4*(PER_ID_I2S + g_i2s)+0]    = s_rx_ch_events[CH_ID_RX_I2S + g_i2s];
      assign s_events[4*(PER_ID_I2S + g_i2s)+1]  = s_tx_ch_events[CH_ID_TX_I2S + g_i2s];
      assign s_events[4*(PER_ID_I2S + g_i2s)+2]  = 1'b0;
      assign s_events[4*(PER_ID_I2S + g_i2s)+3]  = 1'b0;
      assign s_rx_cfg_stream[CH_ID_RX_I2S + g_i2s] = 'h0;
      assign s_rx_cfg_stream_id[CH_ID_RX_I2S + g_i2s] = 'h0;
      assign s_rx_ch_destination[CH_ID_RX_I2S + g_i2s] = 'h0;
      assign s_tx_ch_destination[CH_ID_TX_I2S + g_i2s] = 'h0;
      udma_i2s_top #(
          .L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
          .TRANS_SIZE(TRANS_SIZE)
      ) i_i2s_udma (
          .sys_clk_i   (s_clk_periphs_core[PER_ID_I2S+g_i2s]),
          .periph_clk_i(s_clk_periphs_per[PER_ID_I2S+g_i2s]),
          .rstn_i      (sys_resetn_i),

          .dft_test_mode_i(dft_test_mode_i),
          .dft_cg_enable_i(dft_cg_enable_i),

          // .pad_slave_sd0_i     ( i2s_slave_sd0_i                 ),
          // .pad_slave_sd1_i     ( i2s_slave_sd1_i                 ),
          // .pad_slave_sck_i     ( i2s_slave_sck_i                 ),
          // .pad_slave_sck_o     ( i2s_slave_sck_o                 ),
          // .pad_slave_sck_oe    ( i2s_slave_sck_oe                ),
          // .pad_slave_ws_i      ( i2s_slave_ws_i                  ),
          // .pad_slave_ws_o      ( i2s_slave_ws_o                  ),
          // .pad_slave_ws_oe     ( i2s_slave_ws_oe                 ),
          // Pad signals
          .pad_slave_sd0_i (perio_in_i[`PERIO_I2SC0_SD0+`PERIO_I2SC_NPORTS*g_i2s]),
          .pad_slave_sd1_i (perio_in_i[`PERIO_I2SC0_SD1+`PERIO_I2SC_NPORTS*g_i2s]),
          .pad_slave_sck_i (perio_in_i[`PERIO_I2SC0_SCK+`PERIO_I2SC_NPORTS*g_i2s]),
          .pad_slave_sck_o (perio_out_o[`PERIO_I2SC0_SCK+`PERIO_I2SC_NPORTS*g_i2s]),
          .pad_slave_sck_oe(perio_oe_o[`PERIO_I2SC0_SCK+`PERIO_I2SC_NPORTS*g_i2s]),
          .pad_slave_ws_i  (perio_in_i[`PERIO_I2SC0_WS+`PERIO_I2SC_NPORTS*g_i2s]),
          .pad_slave_ws_o  (perio_out_o[`PERIO_I2SC0_WS+`PERIO_I2SC_NPORTS*g_i2s]),
          .pad_slave_ws_oe (perio_oe_o[`PERIO_I2SC0_WS+`PERIO_I2SC_NPORTS*g_i2s]),

          .pad_master_sd0_o (),
          .pad_master_sd1_o (),
          .pad_master_sck_i (),
          .pad_master_sck_o (),
          .pad_master_sck_oe(),
          .pad_master_ws_i  (1'b0),
          .pad_master_ws_o  (),
          .pad_master_ws_oe (),

          .cfg_data_i (s_periph_data_to),
          .cfg_addr_i (s_periph_addr),
          .cfg_valid_i(s_periph_valid[PER_ID_I2S+g_i2s]),
          .cfg_rwn_i  (s_periph_rwn),
          .cfg_data_o (s_periph_data_from[PER_ID_I2S+g_i2s]),
          .cfg_ready_o(s_periph_ready[PER_ID_I2S+g_i2s]),

          .cfg_rx_startaddr_o (s_rx_cfg_startaddr[CH_ID_RX_I2S+g_i2s]),
          .cfg_rx_size_o      (s_rx_cfg_size[CH_ID_RX_I2S+g_i2s]),
          .cfg_rx_continuous_o(s_rx_cfg_continuous[CH_ID_RX_I2S+g_i2s]),
          .cfg_rx_en_o        (s_rx_cfg_en[CH_ID_RX_I2S+g_i2s]),
          .cfg_rx_clr_o       (s_rx_cfg_clr[CH_ID_RX_I2S+g_i2s]),
          .cfg_rx_en_i        (s_rx_ch_en[CH_ID_RX_I2S+g_i2s]),
          .cfg_rx_pending_i   (s_rx_ch_pending[CH_ID_RX_I2S+g_i2s]),
          .cfg_rx_curr_addr_i (s_rx_ch_curr_addr[CH_ID_RX_I2S+g_i2s]),
          .cfg_rx_bytes_left_i(s_rx_ch_bytes_left[CH_ID_RX_I2S+g_i2s]),

          .cfg_tx_startaddr_o (s_tx_cfg_startaddr[CH_ID_TX_I2S+g_i2s]),
          .cfg_tx_size_o      (s_tx_cfg_size[CH_ID_TX_I2S+g_i2s]),
          .cfg_tx_continuous_o(s_tx_cfg_continuous[CH_ID_TX_I2S+g_i2s]),
          .cfg_tx_en_o        (s_tx_cfg_en[CH_ID_TX_I2S+g_i2s]),
          .cfg_tx_clr_o       (s_tx_cfg_clr[CH_ID_TX_I2S+g_i2s]),
          .cfg_tx_en_i        (s_tx_ch_en[CH_ID_TX_I2S+g_i2s]),
          .cfg_tx_pending_i   (s_tx_ch_pending[CH_ID_TX_I2S+g_i2s]),
          .cfg_tx_curr_addr_i (s_tx_ch_curr_addr[CH_ID_TX_I2S+g_i2s]),
          .cfg_tx_bytes_left_i(s_tx_ch_bytes_left[CH_ID_TX_I2S+g_i2s]),

          .data_rx_datasize_o(s_rx_ch_datasize[CH_ID_RX_I2S+g_i2s]),
          .data_rx_o         (s_rx_ch_data[CH_ID_RX_I2S+g_i2s]),
          .data_rx_valid_o   (s_rx_ch_valid[CH_ID_RX_I2S+g_i2s]),
          .data_rx_ready_i   (s_rx_ch_ready[CH_ID_RX_I2S+g_i2s]),

          .data_tx_req_o     (s_tx_ch_req[CH_ID_TX_I2S+g_i2s]),
          .data_tx_gnt_i     (s_tx_ch_gnt[CH_ID_TX_I2S+g_i2s]),
          .data_tx_datasize_o(s_tx_ch_datasize[CH_ID_TX_I2S+g_i2s]),
          .data_tx_i         (s_tx_ch_data[CH_ID_TX_I2S+g_i2s]),
          .data_tx_valid_i   (s_tx_ch_valid[CH_ID_TX_I2S+g_i2s]),
          .data_tx_ready_o   (s_tx_ch_ready[CH_ID_TX_I2S+g_i2s])
      );
    end
  endgenerate

  // CAM
  generate
    for (genvar g_cam = 0; g_cam < `N_CAM; g_cam++) begin : i_cam_gen
      logic [7:0] s_cam_data;
      assign s_cam_data = perio_in_i[`PERIO_CAM0_DATA7 + `PERIO_CAM_NPORTS * g_cam : `PERIO_CAM0_DATA0 + `PERIO_CAM_NPORTS * g_cam];
      assign s_events[4*(PER_ID_CAM+g_cam)+0] = s_rx_ch_events[CH_ID_RX_CAM+g_cam];
      assign s_events[4*(PER_ID_CAM+g_cam)+1] = 1'b0;
      assign s_events[4*(PER_ID_CAM+g_cam)+2] = 1'b0;
      assign s_events[4*(PER_ID_CAM+g_cam)+3] = 1'b0;
      assign s_rx_cfg_stream[CH_ID_RX_CAM+g_cam] = 'h0;
      assign s_rx_cfg_stream_id[CH_ID_RX_CAM+g_cam] = 'h0;
      assign s_rx_ch_destination[CH_ID_RX_CAM+g_cam] = 'h0;
      camera_if #(
          .L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
          .TRANS_SIZE(TRANS_SIZE),
          .DATA_WIDTH(8)
      ) i_camera_if (
          .clk_i (s_clk_periphs_core[PER_ID_CAM+g_cam]),
          .rstn_i(sys_resetn_i),

          .dft_test_mode_i(dft_test_mode_i),
          .dft_cg_enable_i(dft_cg_enable_i),

          .cfg_data_i (s_periph_data_to),
          .cfg_addr_i (s_periph_addr),
          .cfg_valid_i(s_periph_valid[PER_ID_CAM+g_cam]),
          .cfg_rwn_i  (s_periph_rwn),
          .cfg_data_o (s_periph_data_from[PER_ID_CAM+g_cam]),
          .cfg_ready_o(s_periph_ready[PER_ID_CAM+g_cam]),

          .cfg_rx_startaddr_o (s_rx_cfg_startaddr[CH_ID_RX_CAM+g_cam]),
          .cfg_rx_size_o      (s_rx_cfg_size[CH_ID_RX_CAM+g_cam]),
          .cfg_rx_continuous_o(s_rx_cfg_continuous[CH_ID_RX_CAM+g_cam]),
          .cfg_rx_en_o        (s_rx_cfg_en[CH_ID_RX_CAM+g_cam]),
          .cfg_rx_clr_o       (s_rx_cfg_clr[CH_ID_RX_CAM+g_cam]),
          .cfg_rx_en_i        (s_rx_ch_en[CH_ID_RX_CAM+g_cam]),
          .cfg_rx_pending_i   (s_rx_ch_pending[CH_ID_RX_CAM+g_cam]),
          .cfg_rx_curr_addr_i (s_rx_ch_curr_addr[CH_ID_RX_CAM+g_cam]),
          .cfg_rx_bytes_left_i(s_rx_ch_bytes_left[CH_ID_RX_CAM+g_cam]),

          .data_rx_datasize_o(s_rx_ch_datasize[CH_ID_RX_CAM+g_cam]),
          .data_rx_data_o    (s_rx_ch_data[CH_ID_RX_CAM+g_cam][15:0]),
          .data_rx_valid_o   (s_rx_ch_valid[CH_ID_RX_CAM+g_cam]),
          .data_rx_ready_i   (s_rx_ch_ready[CH_ID_RX_CAM+g_cam]),

          // Pad signals
          // .cam_clk_i           ( cam_clk_i                       ),
          // .cam_data_i          ( cam_data_i                      ),
          // .cam_hsync_i         ( cam_hsync_i                     ),
          // .cam_vsync_i         ( cam_vsync_i                     )

          .cam_clk_i(perio_in_i[`PERIO_CAM0_CLK+`PERIO_CAM_NPORTS*g_cam]),
          .cam_data_i          ( perio_in_i[`PERIO_CAM0_DATA7 + `PERIO_CAM_NPORTS * g_cam : `PERIO_CAM0_DATA0 + `PERIO_CAM_NPORTS * g_cam]),
          .cam_hsync_i(perio_in_i[`PERIO_CAM0_HSYNC+`PERIO_CAM_NPORTS*g_cam]),
          .cam_vsync_i(perio_in_i[`PERIO_CAM0_VSYNC+`PERIO_CAM_NPORTS*g_cam])
      );
      assign s_rx_ch_data[CH_ID_RX_CAM+g_cam][31:16] = 'h0;
    end
  endgenerate


  // FILTER
  generate
    for (genvar g_filter = 0; g_filter < `N_FILTER; g_filter++) begin : i_filter_gen
      assign s_events[4*(PER_ID_FILTER+g_filter)+0]               = s_filter_eot_evt;
      assign s_events[4*(PER_ID_FILTER+g_filter)+1]               = s_filter_act_evt;
      assign s_events[4*(PER_ID_FILTER+g_filter)+2]               = 1'b0;
      assign s_events[4*(PER_ID_FILTER+g_filter)+3]               = 1'b0;

      assign s_rx_ext_destination[CH_ID_EXT_RX_FILTER+g_filter]   = 'h0;
      assign s_rx_ext_stream[CH_ID_EXT_RX_FILTER+g_filter]        = 'h0;
      assign s_rx_ext_stream_id[CH_ID_EXT_RX_FILTER+g_filter]     = 'h0;
      assign s_rx_ext_sot[CH_ID_EXT_RX_FILTER+g_filter]           = 'h0;
      assign s_rx_ext_eot[CH_ID_EXT_RX_FILTER+g_filter]           = 'h0;

      assign s_tx_ext_destination[CH_ID_EXT_TX_FILTER+g_filter]   = 'h0;
      assign s_tx_ext_destination[CH_ID_EXT_TX_FILTER+g_filter+1] = 'h0;

      udma_filter #(
          .L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
          .TRANS_SIZE(TRANS_SIZE)
      ) i_filter (
          .clk_i(s_clk_periphs_core[PER_ID_FILTER+g_filter]),
          .resetn_i(sys_resetn_i),

          .cfg_data_i (s_periph_data_to),
          .cfg_addr_i (s_periph_addr),
          .cfg_valid_i(s_periph_valid[PER_ID_FILTER+g_filter]),
          .cfg_rwn_i  (s_periph_rwn),
          .cfg_data_o (s_periph_data_from[PER_ID_FILTER+g_filter]),
          .cfg_ready_o(s_periph_ready[PER_ID_FILTER+g_filter]),

          .eot_event_o(s_filter_eot_evt),
          .act_event_o(s_filter_act_evt),

          .filter_tx_ch0_req_o     (s_tx_ext_req[CH_ID_EXT_TX_FILTER+g_filter]),
          .filter_tx_ch0_addr_o    (s_tx_ext_addr[CH_ID_EXT_TX_FILTER+g_filter]),
          .filter_tx_ch0_datasize_o(s_tx_ext_datasize[CH_ID_EXT_TX_FILTER+g_filter]),
          .filter_tx_ch0_gnt_i     (s_tx_ext_gnt[CH_ID_EXT_TX_FILTER+g_filter]),

          .filter_tx_ch0_valid_i(s_tx_ext_valid[CH_ID_EXT_TX_FILTER+g_filter]),
          .filter_tx_ch0_data_i (s_tx_ext_data[CH_ID_EXT_TX_FILTER+g_filter]),
          .filter_tx_ch0_ready_o(s_tx_ext_ready[CH_ID_EXT_TX_FILTER+g_filter]),

          .filter_tx_ch1_req_o     (s_tx_ext_req[CH_ID_EXT_TX_FILTER+g_filter+1]),
          .filter_tx_ch1_addr_o    (s_tx_ext_addr[CH_ID_EXT_TX_FILTER+g_filter+1]),
          .filter_tx_ch1_datasize_o(s_tx_ext_datasize[CH_ID_EXT_TX_FILTER+g_filter+1]),
          .filter_tx_ch1_gnt_i     (s_tx_ext_gnt[CH_ID_EXT_TX_FILTER+g_filter+1]),

          .filter_tx_ch1_valid_i(s_tx_ext_valid[CH_ID_EXT_TX_FILTER+g_filter+1]),
          .filter_tx_ch1_data_i (s_tx_ext_data[CH_ID_EXT_TX_FILTER+g_filter+1]),
          .filter_tx_ch1_ready_o(s_tx_ext_ready[CH_ID_EXT_TX_FILTER+g_filter+1]),

          .filter_rx_ch_addr_o    (s_rx_ext_addr[CH_ID_EXT_RX_FILTER+g_filter]),
          .filter_rx_ch_datasize_o(s_rx_ext_datasize[CH_ID_EXT_RX_FILTER+g_filter]),
          .filter_rx_ch_valid_o   (s_rx_ext_valid[CH_ID_EXT_RX_FILTER+g_filter]),
          .filter_rx_ch_data_o    (s_rx_ext_data[CH_ID_EXT_RX_FILTER+g_filter]),
          .filter_rx_ch_ready_i   (s_rx_ext_ready[CH_ID_EXT_RX_FILTER+g_filter]),

          .filter_id_i      (),
          .filter_data_i    (s_stream_data[STREAM_ID_FILTER]),
          .filter_datasize_i(s_stream_datasize[STREAM_ID_FILTER]),
          .filter_valid_i   (s_stream_valid[STREAM_ID_FILTER]),
          .filter_sof_i     (s_stream_sot[STREAM_ID_FILTER]),
          .filter_eof_i     (s_stream_eot[STREAM_ID_FILTER]),
          .filter_ready_o   (s_stream_ready[STREAM_ID_FILTER])
      );
    end
  endgenerate

  // FPGA
  generate
    for (genvar g_fpga = 0; g_fpga < `N_FILTER; g_fpga++) begin : i_fpga_gen
      assign s_events[4*(PER_ID_FPGA+g_fpga)+0] = s_rx_ch_events[CH_ID_RX_FPGA+g_fpga];
      assign s_events[4*(PER_ID_FPGA+g_fpga)+1] = s_tx_ch_events[CH_ID_TX_FPGA+g_fpga];
      assign s_events[4*(PER_ID_FPGA+g_fpga)+2] = 1'b0;
      assign s_events[4*(PER_ID_FPGA+g_fpga)+3] = 1'b0;

      assign s_rx_cfg_stream[CH_ID_RX_FPGA+g_fpga] = 'h0;
      assign s_rx_cfg_stream_id[CH_ID_RX_FPGA+g_fpga] = 'h0;
      assign s_rx_ch_destination[CH_ID_RX_FPGA+g_fpga] = 'h0;
      assign s_tx_ch_destination[CH_ID_TX_FPGA+g_fpga] = 'h0;

      udma_external_per_top #(
          .L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
          .TRANS_SIZE(TRANS_SIZE)
      ) i_efpga (
          .sys_clk_i   (s_clk_periphs_core[PER_ID_FPGA+g_fpga]),
          .periph_clk_i(efpga_clk_i),
          .rstn_i      (sys_resetn_i),

          .cfg_data_i (s_periph_data_to),
          .cfg_addr_i (s_periph_addr),
          .cfg_valid_i(s_periph_valid[PER_ID_FPGA+g_fpga]),
          .cfg_rwn_i  (s_periph_rwn),
          .cfg_ready_o(s_periph_ready[PER_ID_FPGA+g_fpga]),
          .cfg_data_o (s_periph_data_from[PER_ID_FPGA+g_fpga]),

          .cfg_rx_startaddr_o (s_rx_cfg_startaddr[CH_ID_RX_FPGA+g_fpga]),
          .cfg_rx_size_o      (s_rx_cfg_size[CH_ID_RX_FPGA+g_fpga]),
          .cfg_rx_continuous_o(s_rx_cfg_continuous[CH_ID_RX_FPGA+g_fpga]),
          .cfg_rx_en_o        (s_rx_cfg_en[CH_ID_RX_FPGA+g_fpga]),
          .cfg_rx_clr_o       (s_rx_cfg_clr[CH_ID_RX_FPGA+g_fpga]),
          .cfg_rx_en_i        (s_rx_ch_en[CH_ID_RX_FPGA+g_fpga]),
          .cfg_rx_pending_i   (s_rx_ch_pending[CH_ID_RX_FPGA+g_fpga]),
          .cfg_rx_curr_addr_i (s_rx_ch_curr_addr[CH_ID_RX_FPGA+g_fpga]),
          .cfg_rx_bytes_left_i(s_rx_ch_bytes_left[CH_ID_RX_FPGA+g_fpga]),

          .cfg_tx_startaddr_o (s_tx_cfg_startaddr[CH_ID_TX_FPGA+g_fpga]),
          .cfg_tx_size_o      (s_tx_cfg_size[CH_ID_TX_FPGA+g_fpga]),
          .cfg_tx_continuous_o(s_tx_cfg_continuous[CH_ID_TX_FPGA+g_fpga]),
          .cfg_tx_en_o        (s_tx_cfg_en[CH_ID_TX_FPGA+g_fpga]),
          .cfg_tx_clr_o       (s_tx_cfg_clr[CH_ID_TX_FPGA+g_fpga]),
          .cfg_tx_en_i        (s_tx_ch_en[CH_ID_TX_FPGA+g_fpga]),
          .cfg_tx_pending_i   (s_tx_ch_pending[CH_ID_TX_FPGA+g_fpga]),
          .cfg_tx_curr_addr_i (s_tx_ch_curr_addr[CH_ID_TX_FPGA+g_fpga]),
          .cfg_tx_bytes_left_i(s_tx_ch_bytes_left[CH_ID_TX_FPGA+g_fpga]),

          .data_tx_req_o     (s_tx_ch_req[CH_ID_TX_FPGA+g_fpga]),
          .data_tx_gnt_i     (s_tx_ch_gnt[CH_ID_TX_FPGA+g_fpga]),
          .data_tx_datasize_o(s_tx_ch_datasize[CH_ID_TX_FPGA+g_fpga]),
          .data_tx_i         (s_tx_ch_data[CH_ID_TX_FPGA+g_fpga]),
          .data_tx_valid_i   (s_tx_ch_valid[CH_ID_TX_FPGA+g_fpga]),
          .data_tx_ready_o   (s_tx_ch_ready[CH_ID_TX_FPGA+g_fpga]),

          .data_rx_datasize_o(s_rx_ch_datasize[CH_ID_RX_FPGA+g_fpga]),
          .data_rx_o         (s_rx_ch_data[CH_ID_RX_FPGA+g_fpga]),
          .data_rx_valid_o   (s_rx_ch_valid[CH_ID_RX_FPGA+g_fpga]),
          .data_rx_ready_i   (s_rx_ch_ready[CH_ID_RX_FPGA+g_fpga]),

          .external_per_status_i(efpga_setup_i),
          .external_per_setup_o (efpga_setup_o),

          //TX side - uDMA <-> external Peripheral
          .data_tx_dc_valid_o(efpga_data_tx_valid_o),
          .data_tx_dc_ready_i(efpga_data_tx_ready_i),
          .data_tx_dc_o      (efpga_data_tx_o),

          //RX side - uDMA <-> external Peripheral
          .data_rx_dc_valid_i(efpga_data_rx_valid_i),
          .data_rx_dc_ready_o(efpga_data_rx_ready_o),
          .data_rx_dc_i      (efpga_data_rx_i)
      );
    end
  endgenerate

  //fills remaining events with 0s
  //generate
  //    for (genvar g_evt=N_PERIPHS;g_evt<32;g_evt++)
  //    begin: i_evt_assign
  //        assign s_events[4*g_evt]   = 1'b0;
  //        assign s_events[4*g_evt+1] = 1'b0;
  //        assign s_events[4*g_evt+2] = 1'b0;
  //        assign s_events[4*g_evt+3] = 1'b0;
  //   end
  //endgenerate

`ifdef PULP_TRAINING
  //PER_ID 8
  assign s_events[4*PER_ID_EXT_PER]            = s_rx_ch_events[CH_ID_RX_EXT_PER];
  assign s_events[4*PER_ID_EXT_PER+1]          = s_tx_ch_events[CH_ID_TX_EXT_PER];
  assign s_events[4*PER_ID_EXT_PER+2]          = 1'b0;
  assign s_events[4*PER_ID_EXT_PER+3]          = 1'b0;

  assign s_rx_cfg_stream[CH_ID_RX_EXT_PER]     = 'h0;
  assign s_rx_cfg_stream_id[CH_ID_RX_EXT_PER]  = 'h0;
  assign s_rx_ch_destination[CH_ID_RX_EXT_PER] = 'h0;
  assign s_tx_ch_destination[CH_ID_TX_EXT_PER] = 'h0;

  udma_external_per_wrapper #(
      .L2_AWIDTH_NOAL(L2_AWIDTH_NOAL),
      .TRANS_SIZE(TRANS_SIZE)
  ) i_external_per (
      .sys_clk_i   (s_clk_periphs_core[PER_ID_EXT_PER]),
      .periph_clk_i(s_clk_periphs_per[PER_ID_EXT_PER]),
      .rstn_i      (sys_resetn_i),

      .cfg_data_i (s_periph_data_to),
      .cfg_addr_i (s_periph_addr),
      .cfg_valid_i(s_periph_valid[PER_ID_EXT_PER]),
      .cfg_rwn_i  (s_periph_rwn),
      .cfg_ready_o(s_periph_ready[PER_ID_EXT_PER]),
      .cfg_data_o (s_periph_data_from[PER_ID_EXT_PER]),

      .cfg_rx_startaddr_o (s_rx_cfg_startaddr[CH_ID_RX_EXT_PER]),
      .cfg_rx_size_o      (s_rx_cfg_size[CH_ID_RX_EXT_PER]),
      .cfg_rx_continuous_o(s_rx_cfg_continuous[CH_ID_RX_EXT_PER]),
      .cfg_rx_en_o        (s_rx_cfg_en[CH_ID_RX_EXT_PER]),
      .cfg_rx_clr_o       (s_rx_cfg_clr[CH_ID_RX_EXT_PER]),
      .cfg_rx_en_i        (s_rx_ch_en[CH_ID_RX_EXT_PER]),
      .cfg_rx_pending_i   (s_rx_ch_pending[CH_ID_RX_EXT_PER]),
      .cfg_rx_curr_addr_i (s_rx_ch_curr_addr[CH_ID_RX_EXT_PER]),
      .cfg_rx_bytes_left_i(s_rx_ch_bytes_left[CH_ID_RX_EXT_PER]),

      .cfg_tx_startaddr_o (s_tx_cfg_startaddr[CH_ID_TX_EXT_PER]),
      .cfg_tx_size_o      (s_tx_cfg_size[CH_ID_TX_EXT_PER]),
      .cfg_tx_continuous_o(s_tx_cfg_continuous[CH_ID_TX_EXT_PER]),
      .cfg_tx_en_o        (s_tx_cfg_en[CH_ID_TX_EXT_PER]),
      .cfg_tx_clr_o       (s_tx_cfg_clr[CH_ID_TX_EXT_PER]),
      .cfg_tx_en_i        (s_tx_ch_en[CH_ID_TX_EXT_PER]),
      .cfg_tx_pending_i   (s_tx_ch_pending[CH_ID_TX_EXT_PER]),
      .cfg_tx_curr_addr_i (s_tx_ch_curr_addr[CH_ID_TX_EXT_PER]),
      .cfg_tx_bytes_left_i(s_tx_ch_bytes_left[CH_ID_TX_EXT_PER]),

      .data_tx_req_o     (s_tx_ch_req[CH_ID_TX_EXT_PER]),
      .data_tx_gnt_i     (s_tx_ch_gnt[CH_ID_TX_EXT_PER]),
      .data_tx_datasize_o(s_tx_ch_datasize[CH_ID_TX_EXT_PER]),
      .data_tx_i         (s_tx_ch_data[CH_ID_TX_EXT_PER]),
      .data_tx_valid_i   (s_tx_ch_valid[CH_ID_TX_EXT_PER]),
      .data_tx_ready_o   (s_tx_ch_ready[CH_ID_TX_EXT_PER]),

      .data_rx_datasize_o(s_rx_ch_datasize[CH_ID_RX_EXT_PER]),
      .data_rx_o         (s_rx_ch_data[CH_ID_RX_EXT_PER]),
      .data_rx_valid_o   (s_rx_ch_valid[CH_ID_RX_EXT_PER]),
      .data_rx_ready_i   (s_rx_ch_ready[CH_ID_RX_EXT_PER])

  );
`endif
endmodule
