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

module soc_domain #(
    parameter logic [1:0] CORE_TYPE            = 0,
    parameter USE_FPU              = 1,
    parameter USE_HWPE             = 1,
    parameter NB_CL_CORES          = 8,
    parameter AXI_ADDR_WIDTH       = 32,
    parameter AXI_DATA_IN_WIDTH    = 64,
    parameter AXI_DATA_OUT_WIDTH   = 32,
    parameter AXI_ID_IN_WIDTH      = 4,
    localparam AXI_ID_OUT_WIDTH    = pkg_soc_interconnect::AXI_ID_OUT_WIDTH, //Must be large enough to accomodate the additional
                                                                  //bits for the axi XBAR ($clog2(nr_master), rightnow
                                                                  //we have 9 masters 5 for fc_data, fc_instr, udma_rx,
                                                                  //udma_tx, debug_access and 4 for the 64-bit
                                                                  //cluster2soc axi plug
    parameter AXI_USER_WIDTH       = 6,
    parameter AXI_STRB_IN_WIDTH    = AXI_DATA_IN_WIDTH/8,
    parameter AXI_STRB_OUT_WIDTH   = AXI_DATA_OUT_WIDTH/8,

    parameter BUFFER_WIDTH         = 8,
    parameter EVNT_WIDTH           = 8
)(

    
    input logic                              ref_clk_i,
    input logic                              slow_clk_i,
    input logic                              test_clk_i,

    input  logic                             rstn_glob_i,

    input  logic                             dft_test_mode_i,
    input  logic                             dft_cg_enable_i,

    input  logic                             mode_select_i,

    input logic                              bootsel_i,

    input  logic                             fc_fetch_en_valid_i,
    input  logic                             fc_fetch_en_i,

    input  logic                             jtag_tck_i,
    input  logic                             jtag_trst_ni,
    input  logic                             jtag_tms_i,
    input  logic                             jtag_tdi_i,
    output logic                             jtag_tdo_o,

    output logic [NB_CL_CORES-1:0]           cluster_dbg_irq_valid_o,
	
	// PAD CONTROL signals
	output logic [`N_IO-1:0][`NBIT_PADMUX-1:0]	pad_mux_o,
	output logic [`N_IO-1:0][`NBIT_PADCFG-1:0]	pad_cfg_o,

    // PERIO signals
	output logic [`N_PERIO-1:0]      perio_out_o,
	input  logic [`N_PERIO-1:0]      perio_in_i,
	output logic [`N_PERIO-1:0]      perio_oe_o,

	// GPIOS
	output logic [`N_GPIO-1:0]      gpio_out_o           ,
	input  logic [`N_GPIO-1:0]      gpio_in_i            ,
	output logic [`N_GPIO-1:0]      gpio_oe_o           ,
	
	// FPGAIOS
	output logic [`N_FPGAIO-1:0]   	fpgaio_out_o          ,
	input  logic [`N_FPGAIO-1:0]   	fpgaio_in_i           ,
	output logic [`N_FPGAIO-1:0]   	fpgaio_oe_o           ,

    input  logic                             fpga_clk_1_i,
    input  logic                             fpga_clk_2_i,
    input  logic                             fpga_clk_3_i,
    input  logic                             fpga_clk_4_i,
    input  logic                             fpga_clk_5_i,
	
	output logic [3:0]						timer_ch0_o,
	output logic [3:0]						timer_ch1_o,
	output logic [3:0]						timer_ch2_o,
	output logic [3:0]						timer_ch3_o,


    //eFPGA SPIS
    input  logic                             efpga_fcb_spis_rst_n_i       ,
    input  logic                             efpga_fcb_spis_mosi_i        ,
    input  logic                             efpga_fcb_spis_cs_n_i        ,
    input  logic                             efpga_fcb_spis_clk_i         ,
    input  logic                             efpga_fcb_spi_mode_en_bo_i   ,
    output logic                             efpga_fcb_spis_miso_en_o     ,
    output logic                             efpga_fcb_spis_miso_o        ,


    //eFPGA TEST MODE
    input  logic                             efpga_STM_i                  ,
    output logic                             efpga_test_fcb_pif_vldo_en_o ,
    output logic                             efpga_test_fcb_pif_vldo_o    ,
    output logic                             efpga_test_fcb_pif_do_l_en_o ,
    output logic                             efpga_test_fcb_pif_do_l_0_o  ,
    output logic                             efpga_test_fcb_pif_do_l_1_o  ,
    output logic                             efpga_test_fcb_pif_do_l_2_o  ,
    output logic                             efpga_test_fcb_pif_do_l_3_o  ,
    output logic                             efpga_test_fcb_pif_do_h_en_o ,
    output logic                             efpga_test_fcb_pif_do_h_0_o  ,
    output logic                             efpga_test_fcb_pif_do_h_1_o  ,
    output logic                             efpga_test_fcb_pif_do_h_2_o  ,
    output logic                             efpga_test_fcb_pif_do_h_3_o  ,
    output logic                             efpga_test_FB_SPE_OUT_0_o    ,
    output logic                             efpga_test_FB_SPE_OUT_1_o    ,
    output logic                             efpga_test_FB_SPE_OUT_2_o    ,
    output logic                             efpga_test_FB_SPE_OUT_3_o    ,
    input  logic                             efpga_test_fcb_pif_vldi_i    ,
    input  logic                             efpga_test_fcb_pif_di_l_0_i  ,
    input  logic                             efpga_test_fcb_pif_di_l_1_i  ,
    input  logic                             efpga_test_fcb_pif_di_l_2_i  ,
    input  logic                             efpga_test_fcb_pif_di_l_3_i  ,
    input  logic                             efpga_test_fcb_pif_di_h_0_i  ,
    input  logic                             efpga_test_fcb_pif_di_h_1_i  ,
    input  logic                             efpga_test_fcb_pif_di_h_2_i  ,
    input  logic                             efpga_test_fcb_pif_di_h_3_i  ,
    input  logic                             efpga_test_FB_SPE_IN_0_i     ,
    input  logic                             efpga_test_FB_SPE_IN_1_i     ,
    input  logic                             efpga_test_FB_SPE_IN_2_i     ,
    input  logic                             efpga_test_FB_SPE_IN_3_i     ,
    input  logic                             efpga_test_M_0_i             ,
    input  logic                             efpga_test_M_1_i             ,
    input  logic                             efpga_test_M_2_i             ,
    input  logic                             efpga_test_M_3_i             ,
    input  logic                             efpga_test_M_4_i             ,
    input  logic                             efpga_test_M_5_i             ,
    input  logic                             efpga_test_MLATCH_i          ,

    // CLUSTER
    output logic                             cluster_clk_o,
    output logic                             cluster_rstn_o,
    input  logic                             cluster_busy_i,
    output logic                             cluster_irq_o,

    output logic                             cluster_rtc_o,
    output logic                             cluster_fetch_enable_o,
    output logic [63:0]                      cluster_boot_addr_o,
    output logic                             cluster_test_en_o,
    output logic                             cluster_pow_o,
    output logic                             cluster_byp_o,

    // EVENT BUS
    output logic [BUFFER_WIDTH-1:0]          cluster_events_wt_o,
    input  logic [BUFFER_WIDTH-1:0]          cluster_events_rp_i,
    output logic [EVNT_WIDTH-1:0]            cluster_events_da_o,

    output logic                             dma_pe_evt_ack_o,
    input  logic                             dma_pe_evt_valid_i,

    output logic                             dma_pe_irq_ack_o,
    input  logic                             dma_pe_irq_valid_i,

    output logic                             pf_evt_ack_o,
    input logic                              pf_evt_valid_i,

    // AXI4 SLAVE
    input  logic [7:0]                       data_slave_aw_writetoken_i,
    input  logic [AXI_ADDR_WIDTH-1:0]        data_slave_aw_addr_i,
    input  logic [2:0]                       data_slave_aw_prot_i,
    input  logic [3:0]                       data_slave_aw_region_i,
    input  logic [7:0]                       data_slave_aw_len_i,
    input  logic [2:0]                       data_slave_aw_size_i,
    input  logic [1:0]                       data_slave_aw_burst_i,
    input  logic                             data_slave_aw_lock_i,
    input  logic [3:0]                       data_slave_aw_cache_i,
    input  logic [3:0]                       data_slave_aw_qos_i,
    input  logic [AXI_ID_IN_WIDTH-1:0]       data_slave_aw_id_i,
    input  logic [AXI_USER_WIDTH-1:0]        data_slave_aw_user_i,
    output logic [7:0]                       data_slave_aw_readpointer_o,

    input  logic [7:0]                       data_slave_ar_writetoken_i,
    input  logic [AXI_ADDR_WIDTH-1:0]        data_slave_ar_addr_i,
    input  logic [2:0]                       data_slave_ar_prot_i,
    input  logic [3:0]                       data_slave_ar_region_i,
    input  logic [7:0]                       data_slave_ar_len_i,
    input  logic [2:0]                       data_slave_ar_size_i,
    input  logic [1:0]                       data_slave_ar_burst_i,
    input  logic                             data_slave_ar_lock_i,
    input  logic [3:0]                       data_slave_ar_cache_i,
    input  logic [3:0]                       data_slave_ar_qos_i,
    input  logic [AXI_ID_IN_WIDTH-1:0]       data_slave_ar_id_i,
    input  logic [AXI_USER_WIDTH-1:0]        data_slave_ar_user_i,
    output logic [7:0]                       data_slave_ar_readpointer_o,

    input  logic [7:0]                       data_slave_w_writetoken_i,
    input  logic [AXI_DATA_IN_WIDTH-1:0]     data_slave_w_data_i,
    input  logic [AXI_STRB_IN_WIDTH-1:0]     data_slave_w_strb_i,
    input  logic [AXI_USER_WIDTH-1:0]        data_slave_w_user_i,
    input  logic                             data_slave_w_last_i,
    output logic [7:0]                       data_slave_w_readpointer_o,

    output logic [7:0]                       data_slave_r_writetoken_o,
    output logic [AXI_DATA_IN_WIDTH-1:0]     data_slave_r_data_o,
    output logic [1:0]                       data_slave_r_resp_o,
    output logic                             data_slave_r_last_o,
    output logic [AXI_ID_IN_WIDTH-1:0]       data_slave_r_id_o,
    output logic [AXI_USER_WIDTH-1:0]        data_slave_r_user_o,
    input  logic [7:0]                       data_slave_r_readpointer_i,

    output logic [7:0]                       data_slave_b_writetoken_o,
    output logic [1:0]                       data_slave_b_resp_o,
    output logic [AXI_ID_IN_WIDTH-1:0]       data_slave_b_id_o,
    output logic [AXI_USER_WIDTH-1:0]        data_slave_b_user_o,
    input  logic [7:0]                       data_slave_b_readpointer_i,

    // AXI4 MASTER
    output logic [7:0]                       data_master_aw_writetoken_o,
    output logic [AXI_ADDR_WIDTH-1:0]        data_master_aw_addr_o,
    output logic [2:0]                       data_master_aw_prot_o,
    output logic [3:0]                       data_master_aw_region_o,
    output logic [7:0]                       data_master_aw_len_o,
    output logic [2:0]                       data_master_aw_size_o,
    output logic [1:0]                       data_master_aw_burst_o,
    output logic                             data_master_aw_lock_o,
    output logic [3:0]                       data_master_aw_cache_o,
    output logic [3:0]                       data_master_aw_qos_o,
    output logic [AXI_ID_OUT_WIDTH-1:0]      data_master_aw_id_o,
    output logic [AXI_USER_WIDTH-1:0]        data_master_aw_user_o,
    input  logic [7:0]                       data_master_aw_readpointer_i,

    output logic [7:0]                       data_master_ar_writetoken_o,
    output logic [AXI_ADDR_WIDTH-1:0]        data_master_ar_addr_o,
    output logic [2:0]                       data_master_ar_prot_o,
    output logic [3:0]                       data_master_ar_region_o,
    output logic [7:0]                       data_master_ar_len_o,
    output logic [2:0]                       data_master_ar_size_o,
    output logic [1:0]                       data_master_ar_burst_o,
    output logic                             data_master_ar_lock_o,
    output logic [3:0]                       data_master_ar_cache_o,
    output logic [3:0]                       data_master_ar_qos_o,
    output logic [AXI_ID_OUT_WIDTH-1:0]      data_master_ar_id_o,
    output logic [AXI_USER_WIDTH-1:0]        data_master_ar_user_o,
    input  logic [7:0]                       data_master_ar_readpointer_i,

    output logic [7:0]                       data_master_w_writetoken_o,
    output logic [AXI_DATA_OUT_WIDTH-1:0]    data_master_w_data_o,
    output logic [AXI_STRB_OUT_WIDTH-1:0]    data_master_w_strb_o,
    output logic [AXI_USER_WIDTH-1:0]        data_master_w_user_o,
    output logic                             data_master_w_last_o,
    input  logic [7:0]                       data_master_w_readpointer_i,

    input  logic [7:0]                       data_master_r_writetoken_i,
    input  logic [AXI_DATA_OUT_WIDTH-1:0]    data_master_r_data_i,
    input  logic [1:0]                       data_master_r_resp_i,
    input  logic                             data_master_r_last_i,
    input  logic [AXI_ID_OUT_WIDTH-1:0]      data_master_r_id_i,
    input  logic [AXI_USER_WIDTH-1:0]        data_master_r_user_i,
    output logic [7:0]                       data_master_r_readpointer_o,

    input  logic [7:0]                       data_master_b_writetoken_i,
    input  logic [1:0]                       data_master_b_resp_i,
    input  logic [AXI_ID_OUT_WIDTH-1:0]      data_master_b_id_i,
    input  logic [AXI_USER_WIDTH-1:0]        data_master_b_user_i,
    output logic [7:0]                       data_master_b_readpointer_o
);

    pulp_soc #(/*AUTOINSTPARAM*/
      // Parameters
      .CORE_TYPE                        ( CORE_TYPE          ),
      .USE_FPU                          ( USE_FPU            ),
      .USE_HWPE                         ( USE_HWPE           ),
      // .USE_CLUSTER_EVENT                (USE_CLUSTER_EVENT),
      .AXI_ADDR_WIDTH                   ( AXI_ADDR_WIDTH     ),
      .AXI_DATA_IN_WIDTH                ( AXI_DATA_IN_WIDTH  ),
      .AXI_DATA_OUT_WIDTH               ( AXI_DATA_OUT_WIDTH ),
      .AXI_ID_IN_WIDTH                  ( AXI_ID_IN_WIDTH    ),
      .AXI_USER_WIDTH                   ( AXI_USER_WIDTH     ),
      .AXI_STRB_WIDTH_IN                ( AXI_STRB_IN_WIDTH  ),
      .AXI_STRB_WIDTH_OUT               ( AXI_STRB_OUT_WIDTH ),
      .BUFFER_WIDTH                     ( BUFFER_WIDTH       ),
      .EVNT_WIDTH                       ( EVNT_WIDTH         ),
      .NB_CORES                         ( NB_CL_CORES        ),
      // .NB_HWPE_PORTS                    ( 4                   ),
      .ISOLATE_CLUSTER_CDC              ( 1                  ),
      .USE_ZFINX                        ( 0                  )
    ) pulp_soc_i (
		// sysio
		.ref_clk_i                   (ref_clk_i),
		.slow_clk_i                  (slow_clk_i),
        .test_clk_i                  (test_clk_i),
		
        .rstn_glob_i                 (rstn_glob_i),
		
		.mode_select_i               (mode_select_i),
		.dft_cg_enable_i             (dft_cg_enable_i),
		.dft_test_mode_i             (dft_test_mode_i),
        
        .bootsel_i                   (bootsel_i),
		
        .fc_fetch_en_valid_i         (fc_fetch_en_valid_i),
        .fc_fetch_en_i               (fc_fetch_en_i),
		
		.jtag_tck_i                  (jtag_tck_i),
        .jtag_tdi_i                  (jtag_tdi_i),
		.jtag_tdo_o                  (jtag_tdo_o),
		.jtag_tms_i                  (jtag_tms_i),
		.jtag_trst_ni                (jtag_trst_ni),
		// pad control
		.pad_mux_o                   (pad_mux_o),
        .pad_cfg_o                   (pad_cfg_o),
		// PERIOS
		.perio_in_i                  (perio_in_i),
        .perio_out_o                 (perio_out_o),
        .perio_oe_o                  (perio_oe_o),
		// GPIOS
		.gpio_in_i                   (gpio_in_i),
        .gpio_out_o                  (gpio_out_o),
        .gpio_oe_o                   (gpio_oe_o),
		//.gpio_cfg_o                  (gpio_cfg_o[191:0]),
		// FPGAIOS
		.fpgaio_in_i                 (fpgaio_in_i),
        .fpgaio_out_o                (fpgaio_out_o),
        .fpgaio_oe_o                 (fpgaio_oe_o),
        // Outputs
        .boot_l2_i                   (1'b0),
        .cluster_dbg_irq_valid_o     (cluster_dbg_irq_valid_o),
        .cluster_rtc_o               (cluster_rtc_o),
        .cluster_fetch_enable_o      (cluster_fetch_enable_o),
        .cluster_boot_addr_o         (cluster_boot_addr_o[63:0]),
        .cluster_test_en_o           (cluster_test_en_o),
        .cluster_pow_o               (cluster_pow_o),
        .cluster_byp_o               (cluster_byp_o),
        .cluster_rstn_o              (cluster_rstn_o),
        .cluster_irq_o               (cluster_irq_o),
        .data_slave_aw_readpointer_o (data_slave_aw_readpointer_o[7:0]),
        .data_slave_ar_readpointer_o (data_slave_ar_readpointer_o[7:0]),
        .data_slave_w_readpointer_o  (data_slave_w_readpointer_o[7:0]),
        .data_slave_r_writetoken_o   (data_slave_r_writetoken_o[7:0]),
        .data_slave_r_data_o         (data_slave_r_data_o[AXI_DATA_IN_WIDTH-1:0]),
        .data_slave_r_resp_o         (data_slave_r_resp_o[1:0]),
        .data_slave_r_last_o         (data_slave_r_last_o),
        .data_slave_r_id_o           (data_slave_r_id_o[AXI_ID_IN_WIDTH-1:0]),
        .data_slave_r_user_o         (data_slave_r_user_o[AXI_USER_WIDTH-1:0]),
        .data_slave_b_writetoken_o   (data_slave_b_writetoken_o[7:0]),
        .data_slave_b_resp_o         (data_slave_b_resp_o[1:0]),
        .data_slave_b_id_o           (data_slave_b_id_o[AXI_ID_IN_WIDTH-1:0]),
        .data_slave_b_user_o         (data_slave_b_user_o[AXI_USER_WIDTH-1:0]),
        .data_master_aw_writetoken_o (data_master_aw_writetoken_o[7:0]),
        .data_master_aw_addr_o       (data_master_aw_addr_o[AXI_ADDR_WIDTH-1:0]),
        .data_master_aw_prot_o       (data_master_aw_prot_o[2:0]),
        .data_master_aw_region_o     (data_master_aw_region_o[3:0]),
        .data_master_aw_len_o        (data_master_aw_len_o[7:0]),
        .data_master_aw_size_o       (data_master_aw_size_o[2:0]),
        .data_master_aw_burst_o      (data_master_aw_burst_o[1:0]),
        .data_master_aw_lock_o       (data_master_aw_lock_o),
        .data_master_aw_cache_o      (data_master_aw_cache_o[3:0]),
        .data_master_aw_qos_o        (data_master_aw_qos_o[3:0]),
        .data_master_aw_id_o         (data_master_aw_id_o[AXI_ID_OUT_WIDTH-1:0]),
        .data_master_aw_user_o       (data_master_aw_user_o[AXI_USER_WIDTH-1:0]),
        .data_master_ar_writetoken_o (data_master_ar_writetoken_o[7:0]),
        .data_master_ar_addr_o       (data_master_ar_addr_o[AXI_ADDR_WIDTH-1:0]),
        .data_master_ar_prot_o       (data_master_ar_prot_o[2:0]),
        .data_master_ar_region_o     (data_master_ar_region_o[3:0]),
        .data_master_ar_len_o        (data_master_ar_len_o[7:0]),
        .data_master_ar_size_o       (data_master_ar_size_o[2:0]),
        .data_master_ar_burst_o      (data_master_ar_burst_o[1:0]),
        .data_master_ar_lock_o       (data_master_ar_lock_o),
        .data_master_ar_cache_o      (data_master_ar_cache_o[3:0]),
        .data_master_ar_qos_o        (data_master_ar_qos_o[3:0]),
        .data_master_ar_id_o         (data_master_ar_id_o[AXI_ID_OUT_WIDTH-1:0]),
        .data_master_ar_user_o       (data_master_ar_user_o[AXI_USER_WIDTH-1:0]),
        .data_master_w_writetoken_o  (data_master_w_writetoken_o[7:0]),
        .data_master_w_data_o        (data_master_w_data_o[AXI_DATA_OUT_WIDTH-1:0]),
        .data_master_w_strb_o        (data_master_w_strb_o[AXI_STRB_OUT_WIDTH-1:0]),
        .data_master_w_user_o        (data_master_w_user_o[AXI_USER_WIDTH-1:0]),
        .data_master_w_last_o        (data_master_w_last_o),
        .data_master_r_readpointer_o (data_master_r_readpointer_o[7:0]),
        .data_master_b_readpointer_o (data_master_b_readpointer_o[7:0]),
        .cluster_events_wt_o         (cluster_events_wt_o[BUFFER_WIDTH-1:0]),
        .cluster_events_da_o         (cluster_events_da_o[EVNT_WIDTH-1:0]),
        .cluster_clk_o               (cluster_clk_o),
        .dma_pe_evt_ack_o            (dma_pe_evt_ack_o),
        .dma_pe_irq_ack_o            (dma_pe_irq_ack_o),
        .pf_evt_ack_o                (pf_evt_ack_o),
        
        
        
        //.uart_tx_o                   (uart_tx_o),
        .timer_ch0_o                 (timer_ch0_o[3:0]),
        .timer_ch1_o                 (timer_ch1_o[3:0]),
        .timer_ch2_o                 (timer_ch2_o[3:0]),
        .timer_ch3_o                 (timer_ch3_o[3:0]),
        // .i2c_scl_o                   (i2c_scl_o[`N_I2C-1:0]),
        // .i2c_scl_oe_o                (i2c_scl_oe_o[`N_I2C-1:0]),
        // .i2c_sda_o                   (i2c_sda_o[`N_I2C-1:0]),
        // .i2c_sda_oe_o                (i2c_sda_oe_o[`N_I2C-1:0]),
        // .i2s_slave_ws_o              (i2s_slave_ws_o),
        // .i2s_slave_ws_oe             (i2s_slave_ws_oe),
        // .i2s_slave_sck_o             (i2s_slave_sck_o),
        // .i2s_slave_sck_oe            (i2s_slave_sck_oe),
        // .spi_clk_o                   (spi_clk_o[`N_SPI-1:0]),
        // .spi_csn_o                   (spi_csn_o/*[`N_SPI-1:0][3:0]*/),
        // .spi_oen_o                   (spi_oen_o/*[`N_SPI-1:0][3:0]*/),
        // .spi_sdo_o                   (spi_sdo_o/*[`N_SPI-1:0][3:0]*/),
        // .sdio_clk_o                  (sdio_clk_o),
        // .sdio_cmd_o                  (sdio_cmd_o),
        // .sdio_cmd_oen_o              (sdio_cmd_oen_o),
        // .sdio_data_o                 (sdio_data_o[3:0]),
        // .sdio_data_oen_o             (sdio_data_oen_o[3:0]),
        
        // Inputs
        
        
        
        .data_slave_aw_writetoken_i  (data_slave_aw_writetoken_i[7:0]),
        .data_slave_aw_addr_i        (data_slave_aw_addr_i[AXI_ADDR_WIDTH-1:0]),
        .data_slave_aw_prot_i        (data_slave_aw_prot_i[2:0]),
        .data_slave_aw_region_i      (data_slave_aw_region_i[3:0]),
        .data_slave_aw_len_i         (data_slave_aw_len_i[7:0]),
        .data_slave_aw_size_i        (data_slave_aw_size_i[2:0]),
        .data_slave_aw_burst_i       (data_slave_aw_burst_i[1:0]),
        .data_slave_aw_lock_i        (data_slave_aw_lock_i),
        .data_slave_aw_cache_i       (data_slave_aw_cache_i[3:0]),
        .data_slave_aw_qos_i         (data_slave_aw_qos_i[3:0]),
        .data_slave_aw_id_i          (data_slave_aw_id_i[AXI_ID_IN_WIDTH-1:0]),
        .data_slave_aw_user_i        (data_slave_aw_user_i[AXI_USER_WIDTH-1:0]),
        .data_slave_ar_writetoken_i  (data_slave_ar_writetoken_i[7:0]),
        .data_slave_ar_addr_i        (data_slave_ar_addr_i[AXI_ADDR_WIDTH-1:0]),
        .data_slave_ar_prot_i        (data_slave_ar_prot_i[2:0]),
        .data_slave_ar_region_i      (data_slave_ar_region_i[3:0]),
        .data_slave_ar_len_i         (data_slave_ar_len_i[7:0]),
        .data_slave_ar_size_i        (data_slave_ar_size_i[2:0]),
        .data_slave_ar_burst_i       (data_slave_ar_burst_i[1:0]),
        .data_slave_ar_lock_i        (data_slave_ar_lock_i),
        .data_slave_ar_cache_i       (data_slave_ar_cache_i[3:0]),
        .data_slave_ar_qos_i         (data_slave_ar_qos_i[3:0]),
        .data_slave_ar_id_i          (data_slave_ar_id_i[AXI_ID_IN_WIDTH-1:0]),
        .data_slave_ar_user_i        (data_slave_ar_user_i[AXI_USER_WIDTH-1:0]),
        .data_slave_w_writetoken_i   (data_slave_w_writetoken_i[7:0]),
        .data_slave_w_data_i         (data_slave_w_data_i[AXI_DATA_IN_WIDTH-1:0]),
        .data_slave_w_strb_i         (data_slave_w_strb_i[AXI_STRB_IN_WIDTH-1:0]),
        .data_slave_w_user_i         (data_slave_w_user_i[AXI_USER_WIDTH-1:0]),
        .data_slave_w_last_i         (data_slave_w_last_i),
        .data_slave_r_readpointer_i  (data_slave_r_readpointer_i[7:0]),
        .data_slave_b_readpointer_i  (data_slave_b_readpointer_i[7:0]),
        .data_master_aw_readpointer_i(data_master_aw_readpointer_i[7:0]),
        .data_master_ar_readpointer_i(data_master_ar_readpointer_i[7:0]),
        .data_master_w_readpointer_i (data_master_w_readpointer_i[7:0]),
        .data_master_r_writetoken_i  (data_master_r_writetoken_i[7:0]),
        .data_master_r_data_i        (data_master_r_data_i[AXI_DATA_OUT_WIDTH-1:0]),
        .data_master_r_resp_i        (data_master_r_resp_i[1:0]),
        .data_master_r_last_i        (data_master_r_last_i),
        .data_master_r_id_i          (data_master_r_id_i[AXI_ID_OUT_WIDTH-1:0]),
        .data_master_r_user_i        (data_master_r_user_i[AXI_USER_WIDTH-1:0]),
        .data_master_b_writetoken_i  (data_master_b_writetoken_i[7:0]),
        .data_master_b_resp_i        (data_master_b_resp_i[1:0]),
        .data_master_b_id_i          (data_master_b_id_i[AXI_ID_OUT_WIDTH-1:0]),
        .data_master_b_user_i        (data_master_b_user_i[AXI_USER_WIDTH-1:0]),
        .cluster_events_rp_i         (cluster_events_rp_i[BUFFER_WIDTH-1:0]),
        .cluster_busy_i              (cluster_busy_i),
        .dma_pe_evt_valid_i          (dma_pe_evt_valid_i),
        .dma_pe_irq_valid_i          (dma_pe_irq_valid_i),
        .pf_evt_valid_i              (pf_evt_valid_i)
        
        // .uart_rx_i                   (uart_rx_i),
        // .cam_clk_i                   (cam_clk_i),
        // .cam_data_i                  (cam_data_i[7:0]),
        // .cam_hsync_i                 (cam_hsync_i),
        // .cam_vsync_i                 (cam_vsync_i),
        // .i2c_scl_i                   (i2c_scl_i[`N_I2C-1:0]),
        // .i2c_sda_i                   (i2c_sda_i[`N_I2C-1:0]),
        // .i2s_slave_sd0_i             (i2s_slave_sd0_i),
        // .i2s_slave_sd1_i             (i2s_slave_sd1_i),
        // .i2s_slave_ws_i              (i2s_slave_ws_i),
        // .i2s_slave_sck_i             (i2s_slave_sck_i),
        // .spi_sdi_i                   (spi_sdi_i/*[`N_SPI-1:0][3:0]*/),
        // .sdio_cmd_i                  (sdio_cmd_i),
        // .sdio_data_i                 (sdio_data_i[3:0]),
        
     );

endmodule
