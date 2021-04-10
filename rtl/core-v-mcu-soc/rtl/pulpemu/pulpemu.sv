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

`ifndef PULP_FPGA_SIM
  `define PULP_FPGA_NETLIST
`endif

`ifdef PULP_FPGA_SIM
  `ifndef PULP_FPGA_SIM_MCU
    `define PULP_FPGA_SIM_ZYNQ
  `endif
`endif

module pulpemu
(
  // Zynq pins
  inout  [14:0] DDR_addr,
  inout  [2:0]  DDR_ba,
  inout         DDR_cas_n,
  inout         DDR_ck_n,
  inout         DDR_ck_p,
  inout         DDR_cke,
  inout         DDR_cs_n,
  inout  [3:0]  DDR_dm,
  inout  [31:0] DDR_dq,
  inout  [3:0]  DDR_dqs_n,
  inout  [3:0]  DDR_dqs_p,
  inout         DDR_odt,
  inout         DDR_ras_n,
  inout         DDR_reset_n,
  inout         DDR_we_n,
  inout         FIXED_IO_ddr_vrn,
  inout         FIXED_IO_ddr_vrp,
  inout  [53:0] FIXED_IO_mio,
  inout         FIXED_IO_ps_clk,
  inout         FIXED_IO_ps_porb,
  inout         FIXED_IO_ps_srstb,
  // FMC pins
  inout         FMC_mspi_sck,
  inout         FMC_mspi_sdio3,
  inout         FMC_mspi_sdio2,
  inout         FMC_mspi_sdio1,
  inout         FMC_mspi_sdio0,
  inout         FMC_mspi_ncs0,
  inout         FMC_mspi_ncs1,
  inout         FMC_mspi_ncs2,
  inout         FMC_sspi_sck,
  inout         FMC_sspi_ncs,
  inout         FMC_sspi_sdio3,
  inout         FMC_sspi_sdio2,
  inout         FMC_sspi_sdio1,
  inout         FMC_sspi_sdio0,
  inout         FMC_sens_int0,
  inout         FMC_sens_int1,
  inout         FMC_sens_int2,
  inout         FMC_i2s_sck0,
  inout         FMC_i2s_sdi0,
  inout         FMC_i2s_sdi1,
  inout         FMC_i2s_sdi2,
  inout         FMC_i2s_sdi3,
  inout         FMC_i2c_scl,
  inout         FMC_i2c_sda,
  inout         FMC_adc_sdi0,
  inout         FMC_adc_sdi1,
  inout         FMC_adc_sdi2,
  inout         FMC_adc_sdi3,
  inout         FMC_adc_sck,
  inout         FMC_adc_ncs,
  inout         FMC_gpio0,
  inout         FMC_gpio1,
  inout         FMC_gpio2,
  inout         FMC_gpio3,
  inout         FMC_gpio4,
  inout         FMC_gpio5,
  inout         FMC_gpio6,
  inout         FMC_gpio7,
  inout         FMC_loop0_o,
  inout         FMC_loop0_i,
  inout         FMC_loop1_o,
  inout         FMC_loop1_i,
  inout         FMC_loop2_o,
  inout         FMC_loop2_i,
  inout         FMC_loop3_o,
  inout         FMC_loop3_i,
  inout         FMC_loop4_o,
  inout         FMC_loop4_i,
  inout         FMC_cam_pclk,
  inout         FMC_cam_href,
  inout         FMC_cam_vsync,
  inout         FMC_cam_d0,
  inout         FMC_cam_d1,
  inout         FMC_cam_d2,
  inout         FMC_cam_d3,
  inout         FMC_cam_d4,
  inout         FMC_cam_d5,
  inout         FMC_cam_d6,
  inout         FMC_cam_d7,
  inout         FMC_cam_sck,
  inout         FMC_cam_mosi,
  inout         FMC_cam_miso,
  inout         FMC_cam_ncs,
  // chartreuse board
  inout         FMC_CHART_atreb215_cs1,
  inout         FMC_CHART_atreb215_spi2_miso,
  inout         FMC_CHART_atreb215_spi2_mosi,
  inout         FMC_CHART_atreb215_spi2_sclk,
  inout         FMC_CHART_enable_sky,
  inout         FMC_CHART_pa0900_ant_sel,
  inout         FMC_CHART_pa0900_ctx,
  inout         FMC_CHART_pa0900_cps,
  inout         FMC_CHART_pa0900_csd,
  inout         FMC_CHART_rf_switch_1,
  inout         FMC_CHART_rf_switch_2,
  inout         FMC_CHART_sata1_ap,
  inout         FMC_CHART_sata1_an,
  inout         FMC_CHART_sata1_bp,
  inout         FMC_CHART_sata1_bn,
  inout         FMC_CHART_sata2_ap,
  inout         FMC_CHART_sata2_an,
  inout         FMC_CHART_sata3_ap,
  inout         FMC_CHART_sata3_an,
  inout         FMC_CHART_sata3_bp,
  inout         FMC_CHART_sata3_bn,
  inout         FMC_CHART_vdd_3v3_en,
  inout         FMC_CHART_sky_spi_sdo,
  inout         FMC_CHART_sky_spi_sck,
  inout         FMC_CHART_sky_spi_sdi,
  inout         FMC_CHART_sky_spi_ncs,
  inout         FMC_CHART_user_led1,
  inout         FMC_CHART_user_led2,
  inout         FMC_CHART_user_led3,
  inout         PAD_jtag_tdi,
  inout         PAD_jtag_tdo,
  inout         PAD_jtag_tms,
  inout         PAD_jtag_trst,
  inout         PAD_jtag_tck,
  inout         PAD_reset_n
`ifdef PULP_FPGA_SIM_MCU
  ,
  input  logic tb_clk,
  input  logic tb_rst_n,
  output logic tb_eoc,
  input  logic tb_mode_fmc_zynqn,
  input  logic [31:0] zynq2pulp_apb_paddr,
  input  logic        zynq2pulp_apb_penable,
  output logic [31:0] zynq2pulp_apb_prdata,
  output logic [0:0]  zynq2pulp_apb_pready,
  input  logic [0:0]  zynq2pulp_apb_psel,
  output logic [0:0]  zynq2pulp_apb_pslverr,
  input  logic [31:0] zynq2pulp_apb_pwdata,
  input  logic        zynq2pulp_apb_pwrite
`endif
);

  localparam NB_CORES = 8;
  localparam AXI_ADDR_WIDTH           = 32;
  localparam AXI_DATA_WIDTH           = 64;
  localparam AXI_ID_WIDTH = 7;
  localparam AXI_USER_WIDTH           = 6;
  localparam AXI_STRB_WIDTH           = AXI_DATA_WIDTH/8;

  // zynq mode
  logic mode_fmc_zynqn;

  // pulpemu top signals
  logic zynq_clk;
  logic zynq_rst_n;
  logic pulp_soc_clk;
  logic pulp_cluster_clk;
  logic pulp_cluster_clk_gated;
  logic pulp_soc_rst_n;
  logic [31:0] pulp2zynq_gpio;
  logic [31:0] zynq2pulp_gpio;

  // unmapped pads
  wire pad_xtal_in;
  wire pad_xtal_out;
  wire pad_bootmode;

  // pulp_soc generic signals
  logic pulp_eoc;

  // clk rst gen signals

  // pulp_soc jtag signals

  // pulp_soc gpio
  // pulp_soc pad
  // pulp_soc uart
  //pulp_soc cam
  // pulp_soc rf
  // pulp_soc i2c0
  // pulp_soc i2c1
  // pulp_soc i2s
  // pulp_soc spi master0
  logic       pulp_spi_master0_clk;
  logic [1:0] pulp_spi_master0_csn;
  logic [1:0] pulp_spi_master0_mode;
  logic       pulp_spi_master0_sdo0;
  logic       pulp_spi_master0_sdo1;
  logic       pulp_spi_master0_sdo2;
  logic       pulp_spi_master0_sdo3;
  logic       pulp_spi_master0_sdi0;
  logic       pulp_spi_master0_sdi1;
  logic       pulp_spi_master0_sdi2;
  logic       pulp_spi_master0_sdi3;
  // pulp_soc spi master1
  // pulp_soc spi master2
  // pulp_soc spi slave
  logic       pulp_spi_slave_clk;
  logic       pulp_spi_slave_csn;
  logic [1:0] pulp_spi_slave_mode;
  logic       pulp_spi_slave_sdo0;
  logic       pulp_spi_slave_sdo1;
  logic       pulp_spi_slave_sdo2;
  logic       pulp_spi_slave_sdo3;
  logic       pulp_spi_slave_sdi0;
  logic       pulp_spi_slave_sdi1;
  logic       pulp_spi_slave_sdi2;
  logic       pulp_spi_slave_sdi3;

  // signals for the interposer between safe domain and soc domain in FPGA emulator
  logic       s_zynq_safen_spis; // if 1, use SPI slave from Zynq and not safe domain
  logic       s_zynq_safen_spim; // if 1, use SPI master to Zynq and not safe domain
  logic       s_zynq_safen_uart; // if 1, use UART to Zynq and not safe domain
  logic       s_zynq2soc_spis_sck;
  logic       s_zynq2soc_spis_csn;
  logic       s_zynq2soc_spis_sdo0;
  logic       s_zynq2soc_spis_sdo1;
  logic       s_zynq2soc_spis_sdo2;
  logic       s_zynq2soc_spis_sdo3;
  logic       s_zynq2soc_spis_sdi0;
  logic       s_zynq2soc_spis_sdi1;
  logic       s_zynq2soc_spis_sdi2;
  logic       s_zynq2soc_spis_sdi3;
  logic       s_zynq2soc_spim_sck;
  logic       s_zynq2soc_spim_csn;
  logic       s_zynq2soc_spim_sdo0;
  logic       s_zynq2soc_spim_sdo1;
  logic       s_zynq2soc_spim_sdo2;
  logic       s_zynq2soc_spim_sdo3;
  logic       s_zynq2soc_spim_sdi0;
  logic       s_zynq2soc_spim_sdi1;
  logic       s_zynq2soc_spim_sdi2;
  logic       s_zynq2soc_spim_sdi3;
  logic       s_zynq2soc_uart_rx;
  logic       s_zynq2soc_uart_tx;

  // others
  logic fetch_en;
  logic fault_en;
  logic cg_clken;

  // trace master
  logic [15:0] trace_master_addr;
  logic        trace_master_clk;
  logic [31:0] trace_master_din;
  logic [31:0] trace_master_dout;
  logic        trace_master_en;
  logic        trace_master_rst;
  logic        trace_master_we;
  // instr trace
  logic [NB_CORES*64-1:0] instr_trace_cycles;
  logic [NB_CORES*32-1:0] instr_trace_instr;
  logic [NB_CORES*32-1:0] instr_trace_pc;
  logic [NB_CORES-1:0]    instr_trace_valid;
  logic trace_flushed;
  logic trace_wait;
  // stdout signals
  logic stdout_flushed;
  logic stdout_wait;

`ifndef PULP_FPGA_SIM_MCU
  // APB zynq2pulp signals
  logic [31:0] zynq2pulp_apb_paddr;   // output
  logic        zynq2pulp_apb_penable; // output
  logic [31:0] zynq2pulp_apb_prdata;  // input
  logic [0:0]  zynq2pulp_apb_pready;  // input
  logic [0:0]  zynq2pulp_apb_psel;    // output
  logic [0:0]  zynq2pulp_apb_pslverr; // input
  logic [31:0] zynq2pulp_apb_pwdata;  // output
  logic        zynq2pulp_apb_pwrite;  // output
`endif

  // APB zynq2pulp interfaces to peripherals
  logic [31:0] zynq2pulp_spi_slave_paddr;
  logic        zynq2pulp_spi_slave_penable;
  logic [31:0] zynq2pulp_spi_slave_prdata;
  logic        zynq2pulp_spi_slave_pready;
  logic        zynq2pulp_spi_slave_psel;
  logic        zynq2pulp_spi_slave_pslverr;
  logic [31:0] zynq2pulp_spi_slave_pwdata;
  logic        zynq2pulp_spi_slave_pwrite;
  logic [31:0] zynq2pulp_uart_paddr;
  logic        zynq2pulp_uart_penable;
  logic [31:0] zynq2pulp_uart_prdata;
  logic        zynq2pulp_uart_pready;
  logic        zynq2pulp_uart_psel;
  logic        zynq2pulp_uart_pslverr;
  logic [31:0] zynq2pulp_uart_pwdata;
  logic        zynq2pulp_uart_pwrite;

  // AXI pulp2zynq signals
  logic                        pulp2zynq_axi_aw_valid;
  logic [AXI_ADDR_WIDTH-1:0]   pulp2zynq_axi_aw_addr;
  logic [2:0]                  pulp2zynq_axi_aw_prot;
  logic [3:0]                  pulp2zynq_axi_aw_region;
  logic [7:0]                  pulp2zynq_axi_aw_len;
  logic [2:0]                  pulp2zynq_axi_aw_size;
  logic [1:0]                  pulp2zynq_axi_aw_burst;
  logic                        pulp2zynq_axi_aw_lock;
  logic [3:0]                  pulp2zynq_axi_aw_cache;
  logic [3:0]                  pulp2zynq_axi_aw_qos;
  logic [AXI_ID_WIDTH-1:0]     pulp2zynq_axi_aw_id;
  logic [AXI_USER_WIDTH-1:0]   pulp2zynq_axi_aw_user;
  logic                        pulp2zynq_axi_aw_ready;
  logic                        pulp2zynq_axi_ar_valid;
  logic [AXI_ADDR_WIDTH-1:0]   pulp2zynq_axi_ar_addr;
  logic [2:0]                  pulp2zynq_axi_ar_prot;
  logic [3:0]                  pulp2zynq_axi_ar_region;
  logic [7:0]                  pulp2zynq_axi_ar_len;
  logic [2:0]                  pulp2zynq_axi_ar_size;
  logic [1:0]                  pulp2zynq_axi_ar_burst;
  logic                        pulp2zynq_axi_ar_lock;
  logic [3:0]                  pulp2zynq_axi_ar_cache;
  logic [3:0]                  pulp2zynq_axi_ar_qos;
  logic [AXI_ID_WIDTH-1:0]     pulp2zynq_axi_ar_id;
  logic [AXI_USER_WIDTH-1:0]   pulp2zynq_axi_ar_user;
  logic                        pulp2zynq_axi_ar_ready;
  logic                        pulp2zynq_axi_w_valid;
  logic [AXI_DATA_WIDTH-1:0]   pulp2zynq_axi_w_data;
  logic [AXI_DATA_WIDTH/8-1:0] pulp2zynq_axi_w_strb;
  logic [AXI_USER_WIDTH-1:0]   pulp2zynq_axi_w_user;
  logic                        pulp2zynq_axi_w_last;
  logic                        pulp2zynq_axi_w_ready;
  logic                        pulp2zynq_axi_r_valid;
  logic [AXI_DATA_WIDTH-1:0]   pulp2zynq_axi_r_data;
  logic [1:0]                  pulp2zynq_axi_r_resp;
  logic                        pulp2zynq_axi_r_last;
  logic [AXI_ID_WIDTH-1:0]     pulp2zynq_axi_r_id;
  logic [AXI_USER_WIDTH-1:0]   pulp2zynq_axi_r_user;
  logic                        pulp2zynq_axi_r_ready;
  logic                        pulp2zynq_axi_b_valid;
  logic [1:0]                  pulp2zynq_axi_b_resp;
  logic [AXI_ID_WIDTH-1:0]     pulp2zynq_axi_b_id;
  logic [AXI_USER_WIDTH-1:0]   pulp2zynq_axi_b_user;
  logic                        pulp2zynq_axi_b_ready;

  pulp_chip pulp_chip_i (
    .zynq_safen_spis_i     ( s_zynq_safen_spis                 ), // input  logic
    .zynq_safen_spim_i     ( s_zynq_safen_spim                 ), // input  logic
    .zynq_safen_uart_i     ( s_zynq_safen_uart                 ), // input  logic
    .zynq2soc_spis_sck_i   ( s_zynq2soc_spis_sck               ), // input  logic
    .zynq2soc_spis_csn_i   ( s_zynq2soc_spis_csn               ), // input  logic
    .zynq2soc_spis_sdo0_i  ( s_zynq2soc_spis_sdo0              ), // input  logic
    .zynq2soc_spis_sdo1_i  ( s_zynq2soc_spis_sdo1              ), // input  logic
    .zynq2soc_spis_sdo2_i  ( s_zynq2soc_spis_sdo2              ), // input  logic
    .zynq2soc_spis_sdo3_i  ( s_zynq2soc_spis_sdo3              ), // input  logic
    .zynq2soc_spis_sdi0_o  ( s_zynq2soc_spis_sdi0              ), // output logic
    .zynq2soc_spis_sdi1_o  ( s_zynq2soc_spis_sdi1              ), // output logic
    .zynq2soc_spis_sdi2_o  ( s_zynq2soc_spis_sdi2              ), // output logic
    .zynq2soc_spis_sdi3_o  ( s_zynq2soc_spis_sdi3              ), // output logic
    .zynq2soc_spim_sck_o   ( s_zynq2soc_spim_sck               ), // output logic
    .zynq2soc_spim_csn_o   ( s_zynq2soc_spim_csn               ), // output logic
    .zynq2soc_spim_sdo0_o  ( s_zynq2soc_spim_sdo0              ), // output logic
    .zynq2soc_spim_sdo1_o  ( s_zynq2soc_spim_sdo1              ), // output logic
    .zynq2soc_spim_sdo2_o  ( s_zynq2soc_spim_sdo2              ), // output logic
    .zynq2soc_spim_sdo3_o  ( s_zynq2soc_spim_sdo3              ), // output logic
    .zynq2soc_spim_sdi0_i  ( s_zynq2soc_spim_sdi0              ), // input  logic
    .zynq2soc_spim_sdi1_i  ( s_zynq2soc_spim_sdi1              ), // input  logic
    .zynq2soc_spim_sdi2_i  ( s_zynq2soc_spim_sdi2              ), // input  logic
    .zynq2soc_spim_sdi3_i  ( s_zynq2soc_spim_sdi3              ), // input  logic
    .zynq2soc_uart_tx_o    ( s_zynq2soc_uart_tx                ), // output logic
    .zynq2soc_uart_rx_i    ( s_zynq2soc_uart_rx                ), // input  logic
    .zynq_clk_i            ( zynq_clk                          ),
    .zynq_soc_clk_i        ( pulp_soc_clk                      ),
    .zynq_cluster_clk_i    ( pulp_cluster_clk                  ),
    .zynq_rst_n_i          ( zynq_rst_n                        ),
    .pad_rf_txd_p          ( FMC_CHART_sata1_ap                ),
    .pad_rf_txd_n          ( FMC_CHART_sata1_an                ),
    .pad_rf_txclk_p        ( FMC_CHART_sata1_bp                ),
    .pad_rf_txclk_n        ( FMC_CHART_sata1_bn                ),
    .pad_rf_rxd_p          ( FMC_CHART_sata2_ap                ), //use sata3_an/p for other lvds in
    .pad_rf_rxd_n          ( FMC_CHART_sata2_an                ),
    .pad_rf_rxclk_p        ( FMC_CHART_sata3_bp                ),
    .pad_rf_rxclk_n        ( FMC_CHART_sata3_bn                ),
    .pad_rf_miso           ( FMC_CHART_atreb215_spi2_miso      ),
    .pad_rf_mosi           ( FMC_CHART_atreb215_spi2_mosi      ),
    .pad_rf_cs             ( FMC_CHART_atreb215_cs1            ),
    .pad_rf_sck            ( FMC_CHART_atreb215_spi2_sclk      ),
    .pad_rf_pactrl0        ( FMC_CHART_pa0900_ant_sel          ),
    .pad_rf_pactrl1        ( FMC_CHART_pa0900_ctx              ),
    .pad_rf_pactrl2        ( FMC_CHART_pa0900_cps              ),
    .pad_rf_pactrl3        ( FMC_CHART_pa0900_csd              ),
    .pad_cam_pclk          ( FMC_cam_pclk                      ),
    .pad_cam_valid         ( FMC_CHART_enable_sky              ),
    .pad_cam_data0         ( FMC_cam_d0                        ),
    .pad_cam_data1         ( FMC_cam_d1                        ),
    .pad_cam_data2         ( FMC_cam_d2                        ),
    .pad_cam_data3         ( FMC_cam_d3                        ),
    .pad_cam_data4         ( FMC_cam_d4                        ),
    .pad_cam_data5         ( FMC_cam_d5                        ),
    .pad_cam_data6         ( FMC_cam_d6                        ),
    .pad_cam_data7         ( FMC_cam_d7                        ),
    .pad_cam_hsync         ( FMC_cam_href                      ),
    .pad_cam_vsync         ( FMC_cam_vsync                     ),
    .pad_cam_miso          ( FMC_CHART_sky_spi_sdi             ),
    .pad_cam_mosi          ( FMC_CHART_sky_spi_sdo             ),
    .pad_cam_cs            ( FMC_CHART_sky_spi_ncs             ),
    .pad_cam_sck           ( FMC_CHART_sky_spi_sck             ),
    .pad_i2c0_sda          ( FMC_i2c_sda                       ),
    .pad_i2c0_scl          ( FMC_i2c_scl                       ),
    .pad_i2c1_sda          ( FMC_CHART_rf_switch_1             ),
    .pad_i2c1_scl          ( FMC_CHART_rf_switch_2             ),
    .pad_timer0_ch0        ( FMC_CHART_user_led1               ),
    .pad_timer0_ch1        ( FMC_CHART_user_led2               ),
    .pad_timer0_ch2        ( FMC_CHART_user_led3               ),
    .pad_timer0_ch3        ( FMC_CHART_vdd_3v3_en              ),
    .pad_i2s0_sck          ( FMC_i2s_sck0                      ),
    .pad_i2s0_ws           ( FMC_adc_ncs                       ),
    .pad_i2s0_sdi          ( FMC_i2s_sdi0                      ),
    .pad_i2s1_sck          ( FMC_adc_sck                       ),
    .pad_i2s1_ws           ( FMC_adc_sdi0                      ),
    .pad_i2s1_sdi          ( FMC_i2s_sdi1                      ),
    .pad_uart_rx           ( FMC_loop2_i                       ),
    .pad_uart_tx           ( FMC_loop3_o                       ),
    .pad_spim_sdio0        ( FMC_mspi_sdio0                    ),
    .pad_spim_sdio1        ( FMC_mspi_sdio1                    ),
    .pad_spim_sdio2        ( FMC_mspi_sdio2                    ),
    .pad_spim_sdio3        ( FMC_mspi_sdio3                    ),
    .pad_spim_csn0         ( FMC_mspi_ncs0                     ),
    .pad_spim_csn1         ( FMC_mspi_ncs1                     ),
    .pad_spim_sck          ( FMC_mspi_sck                      ),
    .pad_jtag_tdi          ( PAD_jtag_tdi                      ), // inout  wire
    .pad_jtag_tdo          ( PAD_jtag_tdo                      ), // inout  wire
    .pad_jtag_tms          ( PAD_jtag_tms                      ), // inout  wire
    .pad_jtag_trst         ( PAD_jtag_trst                     ), // inout  wire
    .pad_jtag_tck          ( PAD_jtag_tck                      ), // inout  wire
    .pad_reset_n           ( PAD_reset_n                       ), // inout  wire
    .pad_xtal_in           ( pad_xtal_in                       ), // inout  wire
    .pad_xtal_out          ( pad_xtal_out                      ), // inout  wire
    .pad_bootmode          ( pad_bootmode                      )  // inout  wire
  );

`ifndef PULP_FPGA_SIM_MCU
  zynq_wrapper zynq_wrapper_i (
    // Zynq fixed I/O
    .DDR_addr           (DDR_addr          ),
    .DDR_ba             (DDR_ba            ),
    .DDR_cas_n          (DDR_cas_n         ),
    .DDR_ck_n           (DDR_ck_n          ),
    .DDR_ck_p           (DDR_ck_p          ),
    .DDR_cke            (DDR_cke           ),
    .DDR_cs_n           (DDR_cs_n          ),
    .DDR_dm             (DDR_dm            ),
    .DDR_dq             (DDR_dq            ),
    .DDR_dqs_n          (DDR_dqs_n         ),
    .DDR_dqs_p          (DDR_dqs_p         ),
    .DDR_odt            (DDR_odt           ),
    .DDR_ras_n          (DDR_ras_n         ),
    .DDR_reset_n        (DDR_reset_n       ),
    .DDR_we_n           (DDR_we_n          ),
    .FIXED_IO_ddr_vrn   (FIXED_IO_ddr_vrn  ),
    .FIXED_IO_ddr_vrp   (FIXED_IO_ddr_vrp  ),
    .FIXED_IO_mio       (FIXED_IO_mio      ),
    .FIXED_IO_ps_clk    (FIXED_IO_ps_clk   ),
    .FIXED_IO_ps_porb   (FIXED_IO_ps_porb  ),
    .FIXED_IO_ps_srstb  (FIXED_IO_ps_srstb ),
    // zynq clock (FCLK0)
    .zynq_clk           (zynq_clk  ),
    .zynq_rst_n         (zynq_rst_n),
    // pulp clocks (FCLK1->soc, FCLK2->cluster)
    .pulp_soc_clk       (pulp_soc_clk    ),
    .pulp_cluster_clk   (pulp_cluster_clk),
    // fault-generation (if enabled) - should share other apb interface
  `ifdef PULP_FAULTY_CLUSTER
      .fg_cfg_paddr   (),
      .fg_cfg_penable (),
      .fg_cfg_prdata  (),
      .fg_cfg_pready  (),
      .fg_cfg_psel    (),
      .fg_cfg_pslverr (),
      .fg_cfg_pwdata  (),
      .fg_cfg_pwrite  (),
  `endif
    // pulp2zynq axi
    .pulp2zynq_axi_araddr   (pulp2zynq_axi_ar_addr   ),
    .pulp2zynq_axi_arburst  (pulp2zynq_axi_ar_burst  ),
    .pulp2zynq_axi_arcache  (pulp2zynq_axi_ar_cache  ),
    .pulp2zynq_axi_arlen    (pulp2zynq_axi_ar_len    ),
    .pulp2zynq_axi_arlock   (pulp2zynq_axi_ar_lock   ),
    .pulp2zynq_axi_arprot   (pulp2zynq_axi_ar_prot   ),
    .pulp2zynq_axi_arqos    (pulp2zynq_axi_ar_qos    ),
    .pulp2zynq_axi_arready  (pulp2zynq_axi_ar_ready  ),
    .pulp2zynq_axi_arregion (pulp2zynq_axi_ar_region ),
    .pulp2zynq_axi_arsize   (pulp2zynq_axi_ar_size   ),
    .pulp2zynq_axi_arvalid  (pulp2zynq_axi_ar_valid  ),
    .pulp2zynq_axi_awaddr   (pulp2zynq_axi_aw_addr   ),
    .pulp2zynq_axi_awburst  (pulp2zynq_axi_aw_burst  ),
    .pulp2zynq_axi_awcache  (pulp2zynq_axi_aw_cache  ),
    .pulp2zynq_axi_awlen    (pulp2zynq_axi_aw_len    ),
    .pulp2zynq_axi_awlock   (pulp2zynq_axi_aw_lock   ),
    .pulp2zynq_axi_awprot   (pulp2zynq_axi_aw_prot   ),
    .pulp2zynq_axi_awqos    (pulp2zynq_axi_aw_qos    ),
    .pulp2zynq_axi_awready  (pulp2zynq_axi_aw_ready  ),
    .pulp2zynq_axi_awregion (pulp2zynq_axi_aw_region ),
    .pulp2zynq_axi_awsize   (pulp2zynq_axi_aw_size   ),
    .pulp2zynq_axi_awvalid  (pulp2zynq_axi_aw_valid  ),
    .pulp2zynq_axi_bready   (pulp2zynq_axi_b_ready   ),
    .pulp2zynq_axi_bresp    (pulp2zynq_axi_b_resp    ),
    .pulp2zynq_axi_bvalid   (pulp2zynq_axi_b_valid   ),
    .pulp2zynq_axi_rdata    (pulp2zynq_axi_r_data    ),
    .pulp2zynq_axi_rlast    (pulp2zynq_axi_r_last    ),
    .pulp2zynq_axi_rready   (pulp2zynq_axi_r_ready   ),
    .pulp2zynq_axi_rresp    (pulp2zynq_axi_r_resp    ),
    .pulp2zynq_axi_rvalid   (pulp2zynq_axi_r_valid   ),
    .pulp2zynq_axi_wdata    (pulp2zynq_axi_w_data    ),
    .pulp2zynq_axi_wlast    (pulp2zynq_axi_w_last    ),
    .pulp2zynq_axi_wready   (pulp2zynq_axi_w_ready   ),
    .pulp2zynq_axi_wstrb    (pulp2zynq_axi_w_strb    ),
    .pulp2zynq_axi_wvalid   (pulp2zynq_axi_w_valid   ),
    // pulp2zynq gpio
    .pulp2zynq_gpio         (pulp2zynq_gpio          ),
    // zynq2pulp apb
    .zynq2pulp_apb_paddr    (zynq2pulp_apb_paddr     ),
    .zynq2pulp_apb_penable  (zynq2pulp_apb_penable   ),
    .zynq2pulp_apb_prdata   (zynq2pulp_apb_prdata    ),
    .zynq2pulp_apb_pready   (zynq2pulp_apb_pready    ),
    .zynq2pulp_apb_psel     (zynq2pulp_apb_psel      ),
    .zynq2pulp_apb_pslverr  (zynq2pulp_apb_pslverr   ),
    .zynq2pulp_apb_pwdata   (zynq2pulp_apb_pwdata    ),
    .zynq2pulp_apb_pwrite   (zynq2pulp_apb_pwrite    ),
    // zynq2pulp gpio
    .zynq2pulp_gpio         (zynq2pulp_gpio          )
  );
`else
    assign zynq_clk         = tb_clk;
    assign zynq_rst_n       = tb_rst_n;
    assign pulp_soc_clk     = tb_clk;
    assign pulp_soc_rst_n   = tb_rst_n;
    assign pulp_cluster_clk = tb_clk;
`endif

  /* cluster clock gating */
  pulpemu_clk_gating pulpemu_clk_gating_i (
    .pulp_cluster_clk        ( pulp_cluster_clk        ),
    .pulp_soc_rst_n          ( pulp_soc_rst_n          ),
    .pulp_cluster_clk_enable ( cg_clken                ),
    .pulp_cluster_clk_gated  ( pulp_cluster_clk_gated  )
  );

  /* pulpemu apb demuxing */
  pulpemu_apb_demux pulpemu_apb_demux_i (
    .clk                         (zynq_clk                   ),
    .rst_n                       (zynq_rst_n                 ),
    .zynq2pulp_apb_paddr         (zynq2pulp_apb_paddr        ),
    .zynq2pulp_apb_penable       (zynq2pulp_apb_penable      ),
    .zynq2pulp_apb_prdata        (zynq2pulp_apb_prdata       ),
    .zynq2pulp_apb_pready        (zynq2pulp_apb_pready       ),
    .zynq2pulp_apb_psel          (zynq2pulp_apb_psel         ),
    .zynq2pulp_apb_pslverr       (zynq2pulp_apb_pslverr      ),
    .zynq2pulp_apb_pwdata        (zynq2pulp_apb_pwdata       ),
    .zynq2pulp_apb_pwrite        (zynq2pulp_apb_pwrite       ),
    .zynq2pulp_spi_slave_paddr   (zynq2pulp_spi_slave_paddr  ),
    .zynq2pulp_spi_slave_penable (zynq2pulp_spi_slave_penable),
    .zynq2pulp_spi_slave_prdata  (zynq2pulp_spi_slave_prdata ),
    .zynq2pulp_spi_slave_pready  (zynq2pulp_spi_slave_pready ),
    .zynq2pulp_spi_slave_psel    (zynq2pulp_spi_slave_psel   ),
    .zynq2pulp_spi_slave_pslverr (zynq2pulp_spi_slave_pslverr),
    .zynq2pulp_spi_slave_pwdata  (zynq2pulp_spi_slave_pwdata ),
    .zynq2pulp_spi_slave_pwrite  (zynq2pulp_spi_slave_pwrite ),
    .zynq2pulp_uart_paddr        (zynq2pulp_uart_paddr       ),
    .zynq2pulp_uart_penable      (zynq2pulp_uart_penable     ),
    .zynq2pulp_uart_prdata       (zynq2pulp_uart_prdata      ),
    .zynq2pulp_uart_pready       (zynq2pulp_uart_pready      ),
    .zynq2pulp_uart_psel         (zynq2pulp_uart_psel        ),
    .zynq2pulp_uart_pslverr      (zynq2pulp_uart_pslverr     ),
    .zynq2pulp_uart_pwdata       (zynq2pulp_uart_pwdata      ),
    .zynq2pulp_uart_pwrite       (zynq2pulp_uart_pwrite      )
  );

  /* pulpemu spi slave */
  pulpemu_spi_slave pulpemu_spi_slave_i (
    .mode_fmc_zynqn_i      ( mode_fmc_zynqn              ),
    .clk                   ( zynq_clk                    ),
    .rst_n                 ( zynq_rst_n                  ),
    .zynq2pulp_apb_paddr   ( zynq2pulp_spi_slave_paddr   ),
    .zynq2pulp_apb_penable ( zynq2pulp_spi_slave_penable ),
    .zynq2pulp_apb_prdata  ( zynq2pulp_spi_slave_prdata  ),
    .zynq2pulp_apb_pready  ( zynq2pulp_spi_slave_pready  ),
    .zynq2pulp_apb_psel    ( zynq2pulp_spi_slave_psel    ),
    .zynq2pulp_apb_pslverr ( zynq2pulp_spi_slave_pslverr ),
    .zynq2pulp_apb_pwdata  ( zynq2pulp_spi_slave_pwdata  ),
    .zynq2pulp_apb_pwrite  ( zynq2pulp_spi_slave_pwrite  ),
    .pulp_spi_clk_o        ( s_zynq2soc_spis_sck       ),
    .pulp_spi_csn0_o       ( s_zynq2soc_spis_csn       ),
    .pulp_spi_csn1_o       (                             ),
    .pulp_spi_csn2_o       (                              ),
    .pulp_spi_csn3_o       (                              ),
    .pulp_spi_mode_i       (                               ),
    .pulp_spi_sdo0_i       ( s_zynq2soc_spis_sdi0          ), // SWAPPED!!!
    .pulp_spi_sdo1_i       ( s_zynq2soc_spis_sdi1          ),
    .pulp_spi_sdo2_i       ( s_zynq2soc_spis_sdi2          ),
    .pulp_spi_sdo3_i       ( s_zynq2soc_spis_sdi3          ),
    .pulp_spi_sdi0_o       ( s_zynq2soc_spis_sdo0          ),
    .pulp_spi_sdi1_o       ( s_zynq2soc_spis_sdo1          ),
    .pulp_spi_sdi2_o       ( s_zynq2soc_spis_sdo2          ),
    .pulp_spi_sdi3_o       ( s_zynq2soc_spis_sdo3          ),
    .pads2pulp_spi_clk_i   ( pulp_spi_slave_clk           ),
    .pads2pulp_spi_csn_i   ( pulp_spi_slave_csn           ),
    .pads2pulp_spi_mode_o  ( pulp_spi_slave_mode    ),
    .pads2pulp_spi_sdo0_o  ( pulp_spi_slave_sdo0    ),
    .pads2pulp_spi_sdo1_o  ( pulp_spi_slave_sdo1    ),
    .pads2pulp_spi_sdo2_o  ( pulp_spi_slave_sdo2    ),
    .pads2pulp_spi_sdo3_o  ( pulp_spi_slave_sdo3    ),
    .pads2pulp_spi_sdi0_i  ( pulp_spi_slave_sdi0    ),
    .pads2pulp_spi_sdi1_i  ( pulp_spi_slave_sdi1    ),
    .pads2pulp_spi_sdi2_i  ( pulp_spi_slave_sdi2    ),
    .pads2pulp_spi_sdi3_i  ( pulp_spi_slave_sdi3    )
  );

  /* pulpemu spi master */
  pulpemu_spi_master pulpemu_spi_master_i (
    .mode_fmc_zynqn_i     ( mode_fmc_zynqn          ),
    .zynq_clk             ( zynq_clk                ),
    .zynq_rst_n           ( zynq_rst_n              ),
    .zynq_axi_aw_valid_o  ( pulp2zynq_axi_aw_valid  ),
    .zynq_axi_aw_addr_o   ( pulp2zynq_axi_aw_addr   ),
    .zynq_axi_aw_prot_o   ( pulp2zynq_axi_aw_prot   ),
    .zynq_axi_aw_region_o ( pulp2zynq_axi_aw_region ),
    .zynq_axi_aw_len_o    ( pulp2zynq_axi_aw_len    ),
    .zynq_axi_aw_size_o   ( pulp2zynq_axi_aw_size   ),
    .zynq_axi_aw_burst_o  ( pulp2zynq_axi_aw_burst  ),
    .zynq_axi_aw_lock_o   ( pulp2zynq_axi_aw_lock   ),
    .zynq_axi_aw_cache_o  ( pulp2zynq_axi_aw_cache  ),
    .zynq_axi_aw_qos_o    ( pulp2zynq_axi_aw_qos    ),
    .zynq_axi_aw_id_o     ( pulp2zynq_axi_aw_id     ),
    .zynq_axi_aw_user_o   ( pulp2zynq_axi_aw_user   ),
    .zynq_axi_aw_ready_i  ( pulp2zynq_axi_aw_ready  ),
    .zynq_axi_ar_valid_o  ( pulp2zynq_axi_ar_valid  ),
    .zynq_axi_ar_addr_o   ( pulp2zynq_axi_ar_addr   ),
    .zynq_axi_ar_prot_o   ( pulp2zynq_axi_ar_prot   ),
    .zynq_axi_ar_region_o ( pulp2zynq_axi_ar_region ),
    .zynq_axi_ar_len_o    ( pulp2zynq_axi_ar_len    ),
    .zynq_axi_ar_size_o   ( pulp2zynq_axi_ar_size   ),
    .zynq_axi_ar_burst_o  ( pulp2zynq_axi_ar_burst  ),
    .zynq_axi_ar_lock_o   ( pulp2zynq_axi_ar_lock   ),
    .zynq_axi_ar_cache_o  ( pulp2zynq_axi_ar_cache  ),
    .zynq_axi_ar_qos_o    ( pulp2zynq_axi_ar_qos    ),
    .zynq_axi_ar_id_o     ( pulp2zynq_axi_ar_id     ),
    .zynq_axi_ar_user_o   ( pulp2zynq_axi_ar_user   ),
    .zynq_axi_ar_ready_i  ( pulp2zynq_axi_ar_ready  ),
    .zynq_axi_w_valid_o   ( pulp2zynq_axi_w_valid   ),
    .zynq_axi_w_data_o    ( pulp2zynq_axi_w_data    ),
    .zynq_axi_w_strb_o    ( pulp2zynq_axi_w_strb    ),
    .zynq_axi_w_user_o    ( pulp2zynq_axi_w_user    ),
    .zynq_axi_w_last_o    ( pulp2zynq_axi_w_last    ),
    .zynq_axi_w_ready_i   ( pulp2zynq_axi_w_ready   ),
    .zynq_axi_r_valid_i   ( pulp2zynq_axi_r_valid   ),
    .zynq_axi_r_data_i    ( pulp2zynq_axi_r_data    ),
    .zynq_axi_r_resp_i    ( pulp2zynq_axi_r_resp    ),
    .zynq_axi_r_last_i    ( pulp2zynq_axi_r_last    ),
    .zynq_axi_r_id_i      ( pulp2zynq_axi_r_id      ),
    .zynq_axi_r_user_i    ( pulp2zynq_axi_r_user    ),
    .zynq_axi_r_ready_o   ( pulp2zynq_axi_r_ready   ),
    .zynq_axi_b_valid_i   ( pulp2zynq_axi_b_valid   ),
    .zynq_axi_b_resp_i    ( pulp2zynq_axi_b_resp    ),
    .zynq_axi_b_id_i      ( pulp2zynq_axi_b_id      ),
    .zynq_axi_b_user_i    ( pulp2zynq_axi_b_user    ),
    .zynq_axi_b_ready_o   ( pulp2zynq_axi_b_ready   ),
    .pulp_spi_clk_i       ( s_zynq2soc_spim_sck   ),
    .pulp_spi_csn_i       ( s_zynq2soc_spim_csn   ),
    .pulp_spi_mode_i      (                      ),
    .pulp_spi_sdo0_i      ( s_zynq2soc_spim_sdo0 ),
    .pulp_spi_sdo1_i      ( s_zynq2soc_spim_sdo1 ),
    .pulp_spi_sdo2_i      ( s_zynq2soc_spim_sdo2 ),
    .pulp_spi_sdo3_i      ( s_zynq2soc_spim_sdo3 ),
    .pulp_spi_sdi0_o      ( s_zynq2soc_spim_sdi0 ),
    .pulp_spi_sdi1_o      ( s_zynq2soc_spim_sdi1 ),
    .pulp_spi_sdi2_o      ( s_zynq2soc_spim_sdi2 ),
    .pulp_spi_sdi3_o      ( s_zynq2soc_spim_sdi3 ),
    .pads2pulp_spi_clk_o  ( pulp_spi_master0_clk    ),
    .pads2pulp_spi_csn_o  ( pulp_spi_master0_csn[0] ),
    .pads2pulp_spi_mode_o ( pulp_spi_master0_mode    ),
    .pads2pulp_spi_sdo0_o ( pulp_spi_master0_sdo0    ),
    .pads2pulp_spi_sdo1_o ( pulp_spi_master0_sdo1    ),
    .pads2pulp_spi_sdo2_o ( pulp_spi_master0_sdo2    ),
    .pads2pulp_spi_sdo3_o ( pulp_spi_master0_sdo3    ),
    .pads2pulp_spi_sdi0_i ( pulp_spi_master0_sdi0    ),
    .pads2pulp_spi_sdi1_i ( pulp_spi_master0_sdi1    ),
    .pads2pulp_spi_sdi2_i ( pulp_spi_master0_sdi2    ),
    .pads2pulp_spi_sdi3_i ( pulp_spi_master0_sdi3    )
  );

  /* pulpemu uart interface (currently only for stdout) */
  pulpemu_uart pulpemu_uart_i (
    .mode_fmc_zynqn_i    ( mode_fmc_zynqn         ),
    .clk                 ( zynq_clk               ),
    .rst_n               ( zynq_rst_n             ),
    .apb_paddr           ( zynq2pulp_uart_paddr   ),
    .apb_penable         ( zynq2pulp_uart_penable ),
    .apb_prdata          ( zynq2pulp_uart_prdata  ),
    .apb_pready          ( zynq2pulp_uart_pready  ),
    .apb_psel            ( zynq2pulp_uart_psel    ),
    .apb_pslverr         ( zynq2pulp_uart_pslverr ),
    .apb_pwdata          ( zynq2pulp_uart_pwdata  ),
    .apb_pwrite          ( zynq2pulp_uart_pwrite  ),
    .uart_int_o          (                        ),
    .uart_rx_o (),
    .uart_tx_i (),
    .pads2pulp_uart_rx_i ( s_zynq2soc_uart_tx     ),
    .pads2pulp_uart_tx_o ( s_zynq2soc_uart_rx     )
  );

`ifndef PULP_FPGA_SIM_MCU
  /* zynq<->pulp control signals */
  pulpemu_zynq2pulp_gpio pulpemu_zynq2pulp_gpio_i (
    .clk            ( zynq_clk       ),
    .rst_n          ( zynq_rst_n     ),
    .pulp2zynq_gpio ( pulp2zynq_gpio ),
    .zynq2pulp_gpio ( zynq2pulp_gpio ),
    .stdout_flushed ( stdout_flushed ),
    .trace_flushed  ( trace_flushed  ),
    .cg_clken       ( cg_clken       ),
    .fetch_en       ( fetch_en       ), // vestigial
    .mode_fmc_zynqn ( mode_fmc_zynqn ),
    .fault_en       ( fault_en       ),
    .stdout_wait    ( stdout_wait    ),
    .trace_wait     ( trace_wait     ),
    .eoc            ( pulp_eoc       ),
    .pulp_soc_rst_n ( pulp_soc_rst_n ),
    .zynq_safen_spis_o ( s_zynq_safen_spis ), // input  logic
    .zynq_safen_spim_o ( s_zynq_safen_spim ), // input  logic
    .zynq_safen_uart_o ( s_zynq_safen_uart )  // input  logic
  );
`else
  assign cg_clken = '1;
  assign fetch_en = '0;
  assign mode_fmc_zynqn = tb_mode_fmc_zynqn;
  assign fault_en = '0;
  assign trace_flushed = '0;
  assign stdout_flushed = '0;
`endif

  /* trace module */
`ifdef TRACE_EXECUTION
  pulpemu_trace trace_i (
    .ref_clk_i          (pulp_soc_clk   ),
    .rst_ni             (pulp_soc_rst_n ),
    .fetch_en_i         (cg_clken       ),
    .instr_trace_cycles (instr_trace_cycles  ),
    .instr_trace_instr  (instr_trace_instr   ),
    .instr_trace_pc     (instr_trace_pc      ),
    .instr_trace_valid  (instr_trace_valid   ),
    .trace_flushed      (trace_flushed       ),
    .trace_wait         (trace_wait          ),
    .cg_clken           (cg_clken            ),
    .trace_master_clk   (trace_master_clk    ),
    .trace_master_addr  (trace_master_addr   ),
    .trace_master_din   (trace_master_din    ),
    .trace_master_dout  (trace_master_dout   ),
    .trace_master_we    (trace_master_we     )
  );
`endif

//   /* biasing of ports not (yet) used in emulator */
// `ifdef PULP_FPGA_SIM //use interface that is otherwise unrolled
//   assign soc_fll_master.ack   = '0;
//   assign soc_fll_master.r_data = '0;
//   assign soc_fll_master.lock  = '0;
//   assign cluster_fll_master.ack   = '0;
//   assign cluster_fll_master.r_data = '0;
//   assign cluster_fll_master.lock  = '0;
// `else
//   assign soc_fll_master_ack   = '0;
//   assign soc_fll_master_rdata = '0;
//   assign soc_fll_master_lock  = '0;
//   assign cluster_fll_master_ack   = '0;
//   assign cluster_fll_master_rdata = '0;
//   assign cluster_fll_master_lock  = '0;
// `endif

//   // jtag
//   // uart
// //assign pulp_uart_rx   = '0; //removed due to driving conflict
//   assign pulp_uart_cts  = '1;
//   assign pulp_uart_dsr  = '0;
//   //cam
//   // i2s

// `ifndef PULP_FPGA_SIM
  // unused pads
  // PULLDOWN pd_cam_valid  (.O(pad_cam_valid) );
  // assign pad_reset_n  = '1;
  assign pad_xtal_in  = '0;
  //assign pad_xtal_out = '0;
  assign pad_bootmode = '0;
// `endif

//   /* biasing of clocks and resets of AXI interfaces */

//   /* biasing of now unused, but still necessarily present (and dont_touch'ed), stdout stuff */

endmodule // pulpemu
