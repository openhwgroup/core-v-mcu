// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

import arnold_pad_config::*;

module pad_arnold_physical_mux
  #(
    parameter NGPIO        = 43,
    parameter NPAD         = 64,
    parameter NBIT_PADCFG  = 4
  )
  (

        input  logic             stm_i                ,
        input  logic             iomux_i              ,
        output logic [1:0]       selected_mode_o      ,
/*
        ARNOLD --> PAD
*/

        //MUXED VALUES TO PADFRAME
        output logic             oe_spim_sdio0_o      ,
        output logic             oe_spim_sdio1_o      ,
        output logic             oe_spim_sdio2_o      ,
        output logic             oe_spim_sdio3_o      ,
        output logic             oe_spim_csn0_o       ,
        output logic             oe_spim_csn1_o       ,
        output logic             oe_spim_sck_o        ,
        output logic             oe_uart_rx_o         ,
        output logic             oe_uart_tx_o         ,
        output logic             oe_cam_pclk_o        ,
        output logic             oe_cam_hsync_o       ,
        output logic             oe_cam_data0_o       ,
        output logic             oe_cam_data1_o       ,
        output logic             oe_cam_data2_o       ,
        output logic             oe_cam_data3_o       ,
        output logic             oe_cam_data4_o       ,
        output logic             oe_cam_data5_o       ,
        output logic             oe_cam_data6_o       ,
        output logic             oe_cam_data7_o       ,
        output logic             oe_cam_vsync_o       ,
        output logic             oe_hyper_ckn_o       ,
        output logic             oe_hyper_ck_o        ,
        output logic             oe_hyper_dq0_o       ,
        output logic             oe_hyper_dq1_o       ,
        output logic             oe_hyper_dq2_o       ,
        output logic             oe_hyper_dq3_o       ,
        output logic             oe_hyper_dq4_o       ,
        output logic             oe_hyper_dq5_o       ,
        output logic             oe_hyper_dq6_o       ,
        output logic             oe_hyper_dq7_o       ,
        output logic             oe_hyper_csn0_o      ,
        output logic             oe_hyper_csn1_o      ,
        output logic             oe_hyper_rwds_o      ,
        output logic             oe_i2c0_sda_o        ,
        output logic             oe_i2c0_scl_o        ,
        output logic             oe_mlatch_o          ,
        output logic             oe_fpga_gpio36_o     ,
        output logic             oe_fpga_gpio37_o     ,
        output logic             oe_fpga_gpio38_o     ,
        output logic             oe_fpga_gpio39_o     ,
        output logic             oe_fpga_gpio40_o     ,

        output logic             out_spim_sdio0_o     ,
        output logic             out_spim_sdio1_o     ,
        output logic             out_spim_sdio2_o     ,
        output logic             out_spim_sdio3_o     ,
        output logic             out_spim_csn0_o      ,
        output logic             out_spim_csn1_o      ,
        output logic             out_spim_sck_o       ,
        output logic             out_uart_rx_o        ,
        output logic             out_uart_tx_o        ,
        output logic             out_cam_pclk_o       ,
        output logic             out_cam_hsync_o      ,
        output logic             out_cam_data0_o      ,
        output logic             out_cam_data1_o      ,
        output logic             out_cam_data2_o      ,
        output logic             out_cam_data3_o      ,
        output logic             out_cam_data4_o      ,
        output logic             out_cam_data5_o      ,
        output logic             out_cam_data6_o      ,
        output logic             out_cam_data7_o      ,
        output logic             out_cam_vsync_o      ,
        output logic             out_hyper_ckn_o      ,
        output logic             out_hyper_ck_o       ,
        output logic             out_hyper_dq0_o      ,
        output logic             out_hyper_dq1_o      ,
        output logic             out_hyper_dq2_o      ,
        output logic             out_hyper_dq3_o      ,
        output logic             out_hyper_dq4_o      ,
        output logic             out_hyper_dq5_o      ,
        output logic             out_hyper_dq6_o      ,
        output logic             out_hyper_dq7_o      ,
        output logic             out_hyper_csn0_o     ,
        output logic             out_hyper_csn1_o     ,
        output logic             out_hyper_rwds_o     ,
        output logic             out_i2c0_sda_o       ,
        output logic             out_i2c0_scl_o       ,
        output logic             out_mlatch_o         ,
        output logic             out_fpga_gpio36_o    ,
        output logic             out_fpga_gpio37_o    ,
        output logic             out_fpga_gpio38_o    ,
        output logic             out_fpga_gpio39_o    ,
        output logic             out_fpga_gpio40_o    ,

/*
        PAD --> ARNOLD
*/

        //INPUT VALUES FROM PADFRAME - TO BE DEMUXED
        input  logic             in_spim_sdio0_i      ,
        input  logic             in_spim_sdio1_i      ,
        input  logic             in_spim_sdio2_i      ,
        input  logic             in_spim_sdio3_i      ,
        input  logic             in_spim_csn0_i       ,
        input  logic             in_spim_csn1_i       ,
        input  logic             in_spim_sck_i        ,
        input  logic             in_uart_rx_i         ,
        input  logic             in_uart_tx_i         ,
        input  logic             in_cam_pclk_i        ,
        input  logic             in_cam_hsync_i       ,
        input  logic             in_cam_data0_i       ,
        input  logic             in_cam_data1_i       ,
        input  logic             in_cam_data2_i       ,
        input  logic             in_cam_data3_i       ,
        input  logic             in_cam_data4_i       ,
        input  logic             in_cam_data5_i       ,
        input  logic             in_cam_data6_i       ,
        input  logic             in_cam_data7_i       ,
        input  logic             in_cam_vsync_i       ,
        input  logic             in_hyper_ckn_i       ,
        input  logic             in_hyper_ck_i        ,
        input  logic             in_hyper_dq0_i       ,
        input  logic             in_hyper_dq1_i       ,
        input  logic             in_hyper_dq2_i       ,
        input  logic             in_hyper_dq3_i       ,
        input  logic             in_hyper_dq4_i       ,
        input  logic             in_hyper_dq5_i       ,
        input  logic             in_hyper_dq6_i       ,
        input  logic             in_hyper_dq7_i       ,
        input  logic             in_hyper_csn0_i      ,
        input  logic             in_hyper_csn1_i      ,
        input  logic             in_hyper_rwds_i      ,
        input  logic             in_i2c0_sda_i        ,
        input  logic             in_i2c0_scl_i        ,
        input  logic             in_mlatch_i          ,
        input  logic             in_fpga_gpio36_i     ,
        input  logic             in_fpga_gpio37_i     ,
        input  logic             in_fpga_gpio38_i     ,
        input  logic             in_fpga_gpio39_i     ,
        input  logic             in_fpga_gpio40_i     ,

/*
        ARNOLD --> PAD
*/

        // PAD CONTROL REGISTER -- TEST MODE?
        input  logic [NPAD-1:0][NBIT_PADCFG-1:0] pad_cfg_i,
        output logic [NPAD-1:0][NBIT_PADCFG-1:0] pad_cfg_o,

        //ASIC FUNCT MODE OUTPUT
        input  logic             oe_spim_sdio0_i      ,
        input  logic             oe_spim_sdio1_i      ,
        input  logic             oe_spim_sdio2_i      ,
        input  logic             oe_spim_sdio3_i      ,
        input  logic             oe_spim_csn0_i       ,
        input  logic             oe_spim_csn1_i       ,
        input  logic             oe_spim_sck_i        ,
        input  logic             oe_uart_rx_i         ,
        input  logic             oe_uart_tx_i         ,
        input  logic             oe_cam_pclk_i        ,
        input  logic             oe_cam_hsync_i       ,
        input  logic             oe_cam_data0_i       ,
        input  logic             oe_cam_data1_i       ,
        input  logic             oe_cam_data2_i       ,
        input  logic             oe_cam_data3_i       ,
        input  logic             oe_cam_data4_i       ,
        input  logic             oe_cam_data5_i       ,
        input  logic             oe_cam_data6_i       ,
        input  logic             oe_cam_data7_i       ,
        input  logic             oe_cam_vsync_i       ,
        input  logic             oe_hyper_ckn_i       ,
        input  logic             oe_hyper_ck_i        ,
        input  logic             oe_hyper_dq0_i       ,
        input  logic             oe_hyper_dq1_i       ,
        input  logic             oe_hyper_dq2_i       ,
        input  logic             oe_hyper_dq3_i       ,
        input  logic             oe_hyper_dq4_i       ,
        input  logic             oe_hyper_dq5_i       ,
        input  logic             oe_hyper_dq6_i       ,
        input  logic             oe_hyper_dq7_i       ,
        input  logic             oe_hyper_csn0_i      ,
        input  logic             oe_hyper_csn1_i      ,
        input  logic             oe_hyper_rwds_i      ,
        input  logic             oe_i2c0_sda_i        ,
        input  logic             oe_i2c0_scl_i        ,
        input  logic             oe_mlatch_i          ,
        input  logic             oe_fpga_gpio36_i     ,
        input  logic             oe_fpga_gpio37_i     ,
        input  logic             oe_fpga_gpio38_i     ,
        input  logic             oe_fpga_gpio39_i     ,
        input  logic             oe_fpga_gpio40_i     ,

        input  logic             out_spim_sdio0_i     ,
        input  logic             out_spim_sdio1_i     ,
        input  logic             out_spim_sdio2_i     ,
        input  logic             out_spim_sdio3_i     ,
        input  logic             out_spim_csn0_i      ,
        input  logic             out_spim_csn1_i      ,
        input  logic             out_spim_sck_i       ,
        input  logic             out_uart_rx_i        ,
        input  logic             out_uart_tx_i        ,
        input  logic             out_cam_pclk_i       ,
        input  logic             out_cam_hsync_i      ,
        input  logic             out_cam_data0_i      ,
        input  logic             out_cam_data1_i      ,
        input  logic             out_cam_data2_i      ,
        input  logic             out_cam_data3_i      ,
        input  logic             out_cam_data4_i      ,
        input  logic             out_cam_data5_i      ,
        input  logic             out_cam_data6_i      ,
        input  logic             out_cam_data7_i      ,
        input  logic             out_cam_vsync_i      ,
        input  logic             out_hyper_ckn_i      ,
        input  logic             out_hyper_ck_i       ,
        input  logic             out_hyper_dq0_i      ,
        input  logic             out_hyper_dq1_i      ,
        input  logic             out_hyper_dq2_i      ,
        input  logic             out_hyper_dq3_i      ,
        input  logic             out_hyper_dq4_i      ,
        input  logic             out_hyper_dq5_i      ,
        input  logic             out_hyper_dq6_i      ,
        input  logic             out_hyper_dq7_i      ,
        input  logic             out_hyper_csn0_i     ,
        input  logic             out_hyper_csn1_i     ,
        input  logic             out_hyper_rwds_i     ,
        input  logic             out_i2c0_sda_i       ,
        input  logic             out_i2c0_scl_i       ,
        input  logic             out_mlatch_i         ,
        input  logic             out_fpga_gpio36_i    ,
        input  logic             out_fpga_gpio37_i    ,
        input  logic             out_fpga_gpio38_i    ,
        input  logic             out_fpga_gpio39_i    ,
        input  logic             out_fpga_gpio40_i    ,


        //eFPGA FUNCT SPIS OUTPUT
        input  logic [NGPIO-1:0] fpga_hw_oe_i         ,
        input  logic [NGPIO-1:0] fpga_hw_out_i        ,


        //eFPGA SPIS OUTPUT
        input  logic             out_fcb_spis_miso_en_i  ,
        input  logic             out_fcb_spis_miso_i     ,

        //TEST MODE OUTPUT
        //OE signals for testmode defined internally as they are static
        input  logic             out_fcb_pif_vldo_en_i ,
        input  logic             out_fcb_pif_vldo_i    ,
        input  logic             out_fcb_pif_do_l_en_i ,
        input  logic             out_fcb_pif_do_l_0_i  ,
        input  logic             out_fcb_pif_do_l_1_i  ,
        input  logic             out_fcb_pif_do_l_2_i  ,
        input  logic             out_fcb_pif_do_l_3_i  ,
        input  logic             out_fcb_pif_do_h_en_i ,
        input  logic             out_fcb_pif_do_h_0_i  ,
        input  logic             out_fcb_pif_do_h_1_i  ,
        input  logic             out_fcb_pif_do_h_2_i  ,
        input  logic             out_fcb_pif_do_h_3_i  ,
        input  logic             out_FB_SPE_OUT_0_i    ,
        input  logic             out_FB_SPE_OUT_1_i    ,
        input  logic             out_FB_SPE_OUT_2_i    ,
        input  logic             out_FB_SPE_OUT_3_i    ,

/*
        PAD --> ARNOLD INPUT DEMUXED
*/

        //ASIC FUNCT MODE INPUT
        output logic             in_spim_sdio0_o       ,
        output logic             in_spim_sdio1_o       ,
        output logic             in_spim_sdio2_o       ,
        output logic             in_spim_sdio3_o       ,
        output logic             in_spim_csn0_o        ,
        output logic             in_spim_csn1_o        ,
        output logic             in_spim_sck_o         ,
        output logic             in_uart_rx_o          ,
        output logic             in_uart_tx_o          ,
        output logic             in_cam_pclk_o         ,
        output logic             in_cam_hsync_o        ,
        output logic             in_cam_data0_o        ,
        output logic             in_cam_data1_o        ,
        output logic             in_cam_data2_o        ,
        output logic             in_cam_data3_o        ,
        output logic             in_cam_data4_o        ,
        output logic             in_cam_data5_o        ,
        output logic             in_cam_data6_o        ,
        output logic             in_cam_data7_o        ,
        output logic             in_cam_vsync_o        ,
        output logic             in_hyper_ckn_o        ,
        output logic             in_hyper_ck_o         ,
        output logic             in_hyper_dq0_o        ,
        output logic             in_hyper_dq1_o        ,
        output logic             in_hyper_dq2_o        ,
        output logic             in_hyper_dq3_o        ,
        output logic             in_hyper_dq4_o        ,
        output logic             in_hyper_dq5_o        ,
        output logic             in_hyper_dq6_o        ,
        output logic             in_hyper_dq7_o        ,
        output logic             in_hyper_csn0_o       ,
        output logic             in_hyper_csn1_o       ,
        output logic             in_hyper_rwds_o       ,
        output logic             in_i2c0_sda_o         ,
        output logic             in_i2c0_scl_o         ,
        output logic             in_mlatch_o           ,
        output logic             in_fpga_gpio36_o      ,
        output logic             in_fpga_gpio37_o      ,
        output logic             in_fpga_gpio38_o      ,
        output logic             in_fpga_gpio39_o      ,
        output logic             in_fpga_gpio40_o      ,

        //ASIC FUNCT MODE CLK

        output logic             fpga_clk_1_o          ,
        output logic             fpga_clk_2_o          ,
        output logic             fpga_clk_3_o          ,
        output logic             fpga_clk_4_o          ,
        output logic             fpga_clk_5_o          ,


        //eFPGA FUNCT SPIS INPUT
        output logic [NGPIO-1:0] fpga_hw_in_o          ,


        //eFPGA SPIS
        output logic             in_fcb_spis_rst_n_o    ,
        output logic             in_fcb_spis_mosi_o     ,
        output logic             in_fcb_spis_cs_n_o     ,
        output logic             in_fcb_spis_clk_o      ,
        output logic             in_fcb_spi_mode_en_bo_o,

        //TEST MODE INPUT
        output logic             in_fcb_pif_vldi_o     ,
        output logic             in_fcb_pif_di_l_0_o   ,
        output logic             in_fcb_pif_di_l_1_o   ,
        output logic             in_fcb_pif_di_l_2_o   ,
        output logic             in_fcb_pif_di_l_3_o   ,
        output logic             in_fcb_pif_di_h_0_o   ,
        output logic             in_fcb_pif_di_h_1_o   ,
        output logic             in_fcb_pif_di_h_2_o   ,
        output logic             in_fcb_pif_di_h_3_o   ,
        output logic             in_FB_SPE_IN_0_o      ,
        output logic             in_FB_SPE_IN_1_o      ,
        output logic             in_FB_SPE_IN_2_o      ,
        output logic             in_FB_SPE_IN_3_o      ,
        output logic             in_M_0_o              ,
        output logic             in_M_1_o              ,
        output logic             in_M_2_o              ,
        output logic             in_M_3_o              ,
        output logic             in_M_4_o              ,
        output logic             in_M_5_o              ,
        output logic             in_MLATCH_o

    );

    logic oe_fcb_pif_vldi    ;
    logic oe_fcb_pif_di_l_0  ;
    logic oe_fcb_pif_di_l_1  ;
    logic oe_fcb_pif_di_l_2  ;
    logic oe_fcb_pif_di_l_3  ;
    logic oe_fcb_pif_di_h_0  ;
    logic oe_fcb_pif_di_h_1  ;
    logic oe_fcb_pif_di_h_2  ;
    logic oe_fcb_pif_di_h_3  ;
    logic oe_fcb_pif_vldo_en ;
    logic oe_fcb_pif_vldo    ;
    logic oe_fcb_pif_do_l_en ;
    logic oe_fcb_pif_do_l_0  ;
    logic oe_fcb_pif_do_l_1  ;
    logic oe_fcb_pif_do_l_2  ;
    logic oe_fcb_pif_do_l_3  ;
    logic oe_fcb_pif_do_h_en ;
    logic oe_fcb_pif_do_h_0  ;
    logic oe_fcb_pif_do_h_1  ;
    logic oe_fcb_pif_do_h_2  ;
    logic oe_fcb_pif_do_h_3  ;
    logic oe_FB_SPE_OUT_0    ;
    logic oe_FB_SPE_OUT_1    ;
    logic oe_FB_SPE_OUT_2    ;
    logic oe_FB_SPE_OUT_3    ;
    logic oe_FB_SPE_IN_0     ;
    logic oe_FB_SPE_IN_1     ;
    logic oe_FB_SPE_IN_2     ;
    logic oe_FB_SPE_IN_3     ;
    logic oe_M_0             ;
    logic oe_M_1             ;
    logic oe_M_2             ;
    logic oe_M_3             ;
    logic oe_M_4             ;
    logic oe_M_5             ;
    logic oe_MLATCH          ;

    logic oe_fcb_spis_miso_en;
    logic oe_fcb_spis_miso   ;
    logic oe_fcb_spis_rst_n  ;
    logic oe_fcb_spis_mosi   ;
    logic oe_fcb_spis_cs_n   ;
    logic oe_fcb_spis_clk    ;
    logic [NPAD-1:0][NBIT_PADCFG-1:0] pad_cfg_testmode;


    localparam PUEN_TESTMODE = 1'b1;//they are negated in the padframe, so 0 means ENABLE
    localparam PDEN_TESTMODE = 1'b0;//they are negated in the padframe, so 0 means ENABLE

    genvar i;
    generate
    for(i=0;i<NPAD;i++) begin : pad_cfg_testmode_config
            if (i != PAD_CFG_fpga_gpio38)
                assign pad_cfg_testmode[i] = pad_cfg_i[i];
            else
                assign pad_cfg_testmode[i] = {2'b11, PUEN_TESTMODE, PDEN_TESTMODE};
    end
    endgenerate

    always_comb
    begin
      if(stm_i) begin
        selected_mode_o = MODE_TEST_MODE;
      end else begin
        if(iomux_i) begin
          selected_mode_o = MODE_FUNCTIONAL_FPGA_SPIS;
        end else begin
          selected_mode_o = MODE_FUNCTIONAL_ASIC;
        end
      end
    end

/*
    MUXING THE OUTPUT SIGNALS (from PULPissimo/FPGA FUNCT/TEST to external WORD)

*/


  //PAD CONFIGURATION
  assign pad_cfg_o         = selected_mode_o == MODE_FUNCTIONAL_ASIC ? pad_cfg_i : pad_cfg_testmode;

  //OUTPUT ENABLE
  assign oe_spim_sdio0_o   = selected_mode_o == MODE_FUNCTIONAL_ASIC ? oe_spim_sdio0_i   : (selected_mode_o == MODE_TEST_MODE ? oe_M_3                                  : fpga_hw_oe_i[PAD_CFG_spim_sdio0 ] );
  assign oe_spim_sdio1_o   = selected_mode_o == MODE_FUNCTIONAL_ASIC ? oe_spim_sdio1_i   : (selected_mode_o == MODE_TEST_MODE ? oe_M_4                                  : fpga_hw_oe_i[PAD_CFG_spim_sdio1 ] );
  assign oe_spim_sdio2_o   = selected_mode_o == MODE_FUNCTIONAL_ASIC ? oe_spim_sdio2_i   : (selected_mode_o == MODE_TEST_MODE ? oe_M_5                                  : fpga_hw_oe_i[PAD_CFG_spim_sdio2 ] );
  assign oe_spim_sdio3_o   = selected_mode_o == MODE_FUNCTIONAL_ASIC ? oe_spim_sdio3_i   : (selected_mode_o == MODE_TEST_MODE ? oe_fcb_pif_vldi                         : fpga_hw_oe_i[PAD_CFG_spim_sdio3 ] );
  assign oe_spim_csn0_o    = selected_mode_o == MODE_FUNCTIONAL_ASIC ? oe_spim_csn0_i    : (selected_mode_o == MODE_TEST_MODE ? oe_fcb_pif_di_l_0                       : fpga_hw_oe_i[PAD_CFG_spim_csn0  ] );
  assign oe_spim_csn1_o    = selected_mode_o == MODE_FUNCTIONAL_ASIC ? oe_spim_csn1_i    : (selected_mode_o == MODE_TEST_MODE ? oe_fcb_pif_di_l_1                       : fpga_hw_oe_i[PAD_CFG_spim_csn1  ] );
  assign oe_spim_sck_o     = selected_mode_o == MODE_FUNCTIONAL_ASIC ? oe_spim_sck_i     : (selected_mode_o == MODE_TEST_MODE ? oe_fcb_pif_di_l_2                       : fpga_hw_oe_i[PAD_CFG_spim_sck   ] );
  assign oe_uart_rx_o      = selected_mode_o == MODE_FUNCTIONAL_ASIC ? oe_uart_rx_i      : (selected_mode_o == MODE_TEST_MODE ? oe_fcb_pif_di_l_3                       : fpga_hw_oe_i[PAD_CFG_uart_rx    ] );
  assign oe_uart_tx_o      = selected_mode_o == MODE_FUNCTIONAL_ASIC ? oe_uart_tx_i      : (selected_mode_o == MODE_TEST_MODE ? oe_fcb_pif_di_h_0                       : fpga_hw_oe_i[PAD_CFG_uart_tx    ] );
  assign oe_cam_pclk_o     = selected_mode_o == MODE_FUNCTIONAL_ASIC ? oe_cam_pclk_i     : (selected_mode_o == MODE_TEST_MODE ? oe_fcb_pif_di_h_1                       : fpga_hw_oe_i[PAD_CFG_cam_pclk   ] );
  assign oe_cam_hsync_o    = selected_mode_o == MODE_FUNCTIONAL_ASIC ? oe_cam_hsync_i    : (selected_mode_o == MODE_TEST_MODE ? oe_fcb_pif_di_h_2                       : fpga_hw_oe_i[PAD_CFG_cam_hsync  ] );
  assign oe_cam_data0_o    = selected_mode_o == MODE_FUNCTIONAL_ASIC ? oe_cam_data0_i    : (selected_mode_o == MODE_TEST_MODE ? oe_fcb_pif_di_h_3                       : fpga_hw_oe_i[PAD_CFG_cam_data0  ] );
  assign oe_cam_data1_o    = selected_mode_o == MODE_FUNCTIONAL_ASIC ? oe_cam_data1_i    : (selected_mode_o == MODE_TEST_MODE ? oe_fcb_pif_vldo_en                      : fpga_hw_oe_i[PAD_CFG_cam_data1  ] );
  assign oe_cam_data2_o    = selected_mode_o == MODE_FUNCTIONAL_ASIC ? oe_cam_data2_i    : (selected_mode_o == MODE_TEST_MODE ? oe_fcb_pif_vldo                         : fpga_hw_oe_i[PAD_CFG_cam_data2  ] );
  assign oe_cam_data3_o    = selected_mode_o == MODE_FUNCTIONAL_ASIC ? oe_cam_data3_i    : (selected_mode_o == MODE_TEST_MODE ? oe_fcb_pif_do_l_en                      : fpga_hw_oe_i[PAD_CFG_cam_data3  ] );
  assign oe_cam_data4_o    = selected_mode_o == MODE_FUNCTIONAL_ASIC ? oe_cam_data4_i    : (selected_mode_o == MODE_TEST_MODE ? oe_fcb_pif_do_l_0                       : fpga_hw_oe_i[PAD_CFG_cam_data4  ] );
  assign oe_cam_data5_o    = selected_mode_o == MODE_FUNCTIONAL_ASIC ? oe_cam_data5_i    : (selected_mode_o == MODE_TEST_MODE ? oe_fcb_pif_do_l_1                       : fpga_hw_oe_i[PAD_CFG_cam_data5  ] );
  assign oe_cam_data6_o    = selected_mode_o == MODE_FUNCTIONAL_ASIC ? oe_cam_data6_i    : (selected_mode_o == MODE_TEST_MODE ? oe_fcb_pif_do_l_2                       : fpga_hw_oe_i[PAD_CFG_cam_data6  ] );
  assign oe_cam_data7_o    = selected_mode_o == MODE_FUNCTIONAL_ASIC ? oe_cam_data7_i    : (selected_mode_o == MODE_TEST_MODE ? oe_fcb_pif_do_l_3                       : fpga_hw_oe_i[PAD_CFG_cam_data7  ] );
  assign oe_cam_vsync_o    = selected_mode_o == MODE_FUNCTIONAL_ASIC ? oe_cam_vsync_i    : (selected_mode_o == MODE_TEST_MODE ? oe_fcb_pif_do_h_en                      : fpga_hw_oe_i[PAD_CFG_cam_vsync  ] );
  assign oe_hyper_ckn_o    = selected_mode_o == MODE_FUNCTIONAL_ASIC ? 1'b0              : (selected_mode_o == MODE_TEST_MODE ? oe_fcb_pif_do_h_0                       : fpga_hw_oe_i[PAD_CFG_hyper_ckn  ] );
  assign oe_hyper_ck_o     = selected_mode_o == MODE_FUNCTIONAL_ASIC ? 1'b0              : (selected_mode_o == MODE_TEST_MODE ? oe_fcb_pif_do_h_1                       : fpga_hw_oe_i[PAD_CFG_hyper_ck   ] );
  assign oe_hyper_dq0_o    = selected_mode_o == MODE_FUNCTIONAL_ASIC ? 1'b0              : (selected_mode_o == MODE_TEST_MODE ? oe_fcb_pif_do_h_2                       : fpga_hw_oe_i[PAD_CFG_hyper_dq0  ] );
  assign oe_hyper_dq1_o    = selected_mode_o == MODE_FUNCTIONAL_ASIC ? 1'b0              : (selected_mode_o == MODE_TEST_MODE ? oe_fcb_pif_do_h_3                       : fpga_hw_oe_i[PAD_CFG_hyper_dq1  ] );
  assign oe_hyper_dq2_o    = selected_mode_o == MODE_FUNCTIONAL_ASIC ? 1'b0              : (selected_mode_o == MODE_TEST_MODE ? oe_FB_SPE_OUT_0                         : fpga_hw_oe_i[PAD_CFG_hyper_dq2  ] );
  assign oe_hyper_dq3_o    = selected_mode_o == MODE_FUNCTIONAL_ASIC ? 1'b0              : (selected_mode_o == MODE_TEST_MODE ? oe_FB_SPE_OUT_1                         : fpga_hw_oe_i[PAD_CFG_hyper_dq3  ] );
  assign oe_hyper_dq4_o    = selected_mode_o == MODE_FUNCTIONAL_ASIC ? 1'b0              : (selected_mode_o == MODE_TEST_MODE ? oe_FB_SPE_OUT_2                         : fpga_hw_oe_i[PAD_CFG_hyper_dq4  ] );
  assign oe_hyper_dq5_o    = selected_mode_o == MODE_FUNCTIONAL_ASIC ? 1'b0              : (selected_mode_o == MODE_TEST_MODE ? oe_FB_SPE_OUT_3                         : fpga_hw_oe_i[PAD_CFG_hyper_dq5  ] );
  assign oe_hyper_dq6_o    = selected_mode_o == MODE_FUNCTIONAL_ASIC ? 1'b0              : (selected_mode_o == MODE_TEST_MODE ? oe_FB_SPE_IN_0                          : fpga_hw_oe_i[PAD_CFG_hyper_dq6  ] );
  assign oe_hyper_dq7_o    = selected_mode_o == MODE_FUNCTIONAL_ASIC ? 1'b0              : (selected_mode_o == MODE_TEST_MODE ? oe_FB_SPE_IN_1                          : fpga_hw_oe_i[PAD_CFG_hyper_dq7  ] );
  assign oe_hyper_csn0_o   = selected_mode_o == MODE_FUNCTIONAL_ASIC ? 1'b0              : (selected_mode_o == MODE_TEST_MODE ? oe_FB_SPE_IN_2                          : fpga_hw_oe_i[PAD_CFG_hyper_csn0 ] );
  assign oe_hyper_csn1_o   = selected_mode_o == MODE_FUNCTIONAL_ASIC ? 1'b0              : (selected_mode_o == MODE_TEST_MODE ? oe_FB_SPE_IN_3                          : fpga_hw_oe_i[PAD_CFG_hyper_csn1 ] );
  assign oe_hyper_rwds_o   = selected_mode_o == MODE_FUNCTIONAL_ASIC ? 1'b0              : (selected_mode_o == MODE_TEST_MODE ? oe_M_0                                  : fpga_hw_oe_i[PAD_CFG_hyper_rwds ] );
  assign oe_i2c0_sda_o     = selected_mode_o == MODE_FUNCTIONAL_ASIC ? oe_i2c0_sda_i     : (selected_mode_o == MODE_TEST_MODE ? oe_M_1                                  : fpga_hw_oe_i[PAD_CFG_i2c0_sda   ] );
  assign oe_i2c0_scl_o     = selected_mode_o == MODE_FUNCTIONAL_ASIC ? oe_i2c0_scl_i     : (selected_mode_o == MODE_TEST_MODE ? oe_M_2                                  : fpga_hw_oe_i[PAD_CFG_i2c0_scl   ] );
  assign oe_mlatch_o       = selected_mode_o == MODE_FUNCTIONAL_ASIC ? oe_mlatch_i       : (selected_mode_o == MODE_TEST_MODE ? oe_MLATCH                               : oe_fcb_spis_miso                  );
  assign oe_fpga_gpio36_o  = selected_mode_o == MODE_FUNCTIONAL_ASIC ? oe_fpga_gpio36_i  : (selected_mode_o == MODE_TEST_MODE ? fpga_hw_oe_i[PAD_CFG_fpga_gpio36]       : oe_fcb_spis_rst_n                 );
  assign oe_fpga_gpio37_o  = selected_mode_o == MODE_FUNCTIONAL_ASIC ? oe_fpga_gpio37_i  : (selected_mode_o == MODE_TEST_MODE ? fpga_hw_oe_i[PAD_CFG_fpga_gpio37]       : oe_fcb_spis_mosi                  );
  assign oe_fpga_gpio38_o  = selected_mode_o == MODE_FUNCTIONAL_ASIC ? oe_fpga_gpio38_i  : (selected_mode_o == MODE_TEST_MODE ? oe_fcb_spis_cs_n                        : oe_fcb_spis_cs_n                  );
  assign oe_fpga_gpio39_o  = selected_mode_o == MODE_FUNCTIONAL_ASIC ? oe_fpga_gpio39_i  : (selected_mode_o == MODE_TEST_MODE ? fpga_hw_oe_i[PAD_CFG_fpga_gpio39]       : oe_fcb_spis_clk                   );
  assign oe_fpga_gpio40_o  = selected_mode_o == MODE_FUNCTIONAL_ASIC ? oe_fpga_gpio40_i  : (selected_mode_o == MODE_TEST_MODE ? fpga_hw_oe_i[PAD_CFG_fpga_gpio40]       : oe_fcb_spis_miso_en               );

  //OUTPUT VOLTAGE
  assign out_spim_sdio0_o  = selected_mode_o == MODE_FUNCTIONAL_ASIC ? out_spim_sdio0_i  : (selected_mode_o == MODE_TEST_MODE ? 1'b0                                     : fpga_hw_out_i[PAD_CFG_spim_sdio0 ] );
  assign out_spim_sdio1_o  = selected_mode_o == MODE_FUNCTIONAL_ASIC ? out_spim_sdio1_i  : (selected_mode_o == MODE_TEST_MODE ? 1'b0                                     : fpga_hw_out_i[PAD_CFG_spim_sdio1 ] );
  assign out_spim_sdio2_o  = selected_mode_o == MODE_FUNCTIONAL_ASIC ? out_spim_sdio2_i  : (selected_mode_o == MODE_TEST_MODE ? 1'b0                                     : fpga_hw_out_i[PAD_CFG_spim_sdio2 ] );
  assign out_spim_sdio3_o  = selected_mode_o == MODE_FUNCTIONAL_ASIC ? out_spim_sdio3_i  : (selected_mode_o == MODE_TEST_MODE ? 1'b0                                     : fpga_hw_out_i[PAD_CFG_spim_sdio3 ] );
  assign out_spim_csn0_o   = selected_mode_o == MODE_FUNCTIONAL_ASIC ? out_spim_csn0_i   : (selected_mode_o == MODE_TEST_MODE ? 1'b0                                     : fpga_hw_out_i[PAD_CFG_spim_csn0  ] );
  assign out_spim_csn1_o   = selected_mode_o == MODE_FUNCTIONAL_ASIC ? out_spim_csn1_i   : (selected_mode_o == MODE_TEST_MODE ? 1'b0                                     : fpga_hw_out_i[PAD_CFG_spim_csn1  ] );
  assign out_spim_sck_o    = selected_mode_o == MODE_FUNCTIONAL_ASIC ? out_spim_sck_i    : (selected_mode_o == MODE_TEST_MODE ? 1'b0                                     : fpga_hw_out_i[PAD_CFG_spim_sck   ] );
  assign out_uart_rx_o     = selected_mode_o == MODE_FUNCTIONAL_ASIC ? out_uart_rx_i     : (selected_mode_o == MODE_TEST_MODE ? 1'b0                                     : fpga_hw_out_i[PAD_CFG_uart_rx    ] );
  assign out_uart_tx_o     = selected_mode_o == MODE_FUNCTIONAL_ASIC ? out_uart_tx_i     : (selected_mode_o == MODE_TEST_MODE ? 1'b0                                     : fpga_hw_out_i[PAD_CFG_uart_tx    ] );
  assign out_cam_pclk_o    = selected_mode_o == MODE_FUNCTIONAL_ASIC ? out_cam_pclk_i    : (selected_mode_o == MODE_TEST_MODE ? 1'b0                                     : fpga_hw_out_i[PAD_CFG_cam_pclk   ] );
  assign out_cam_hsync_o   = selected_mode_o == MODE_FUNCTIONAL_ASIC ? out_cam_hsync_i   : (selected_mode_o == MODE_TEST_MODE ? 1'b0                                     : fpga_hw_out_i[PAD_CFG_cam_hsync  ] );
  assign out_cam_data0_o   = selected_mode_o == MODE_FUNCTIONAL_ASIC ? out_cam_data0_i   : (selected_mode_o == MODE_TEST_MODE ? 1'b0                                     : fpga_hw_out_i[PAD_CFG_cam_data0  ] );
  assign out_cam_data1_o   = selected_mode_o == MODE_FUNCTIONAL_ASIC ? out_cam_data1_i   : (selected_mode_o == MODE_TEST_MODE ? out_fcb_pif_vldo_en_i                    : fpga_hw_out_i[PAD_CFG_cam_data1  ] );
  assign out_cam_data2_o   = selected_mode_o == MODE_FUNCTIONAL_ASIC ? out_cam_data2_i   : (selected_mode_o == MODE_TEST_MODE ? out_fcb_pif_vldo_i                       : fpga_hw_out_i[PAD_CFG_cam_data2  ] );
  assign out_cam_data3_o   = selected_mode_o == MODE_FUNCTIONAL_ASIC ? out_cam_data3_i   : (selected_mode_o == MODE_TEST_MODE ? out_fcb_pif_do_l_en_i                    : fpga_hw_out_i[PAD_CFG_cam_data3  ] );
  assign out_cam_data4_o   = selected_mode_o == MODE_FUNCTIONAL_ASIC ? out_cam_data4_i   : (selected_mode_o == MODE_TEST_MODE ? out_fcb_pif_do_l_0_i                     : fpga_hw_out_i[PAD_CFG_cam_data4  ] );
  assign out_cam_data5_o   = selected_mode_o == MODE_FUNCTIONAL_ASIC ? out_cam_data5_i   : (selected_mode_o == MODE_TEST_MODE ? out_fcb_pif_do_l_1_i                     : fpga_hw_out_i[PAD_CFG_cam_data5  ] );
  assign out_cam_data6_o   = selected_mode_o == MODE_FUNCTIONAL_ASIC ? out_cam_data6_i   : (selected_mode_o == MODE_TEST_MODE ? out_fcb_pif_do_l_2_i                     : fpga_hw_out_i[PAD_CFG_cam_data6  ] );
  assign out_cam_data7_o   = selected_mode_o == MODE_FUNCTIONAL_ASIC ? out_cam_data7_i   : (selected_mode_o == MODE_TEST_MODE ? out_fcb_pif_do_l_3_i                     : fpga_hw_out_i[PAD_CFG_cam_data7  ] );
  assign out_cam_vsync_o   = selected_mode_o == MODE_FUNCTIONAL_ASIC ? out_cam_vsync_i   : (selected_mode_o == MODE_TEST_MODE ? out_fcb_pif_do_h_en_i                    : fpga_hw_out_i[PAD_CFG_cam_vsync  ] );
  assign out_hyper_ckn_o   = selected_mode_o == MODE_FUNCTIONAL_ASIC ? 1'b0              : (selected_mode_o == MODE_TEST_MODE ? out_fcb_pif_do_h_0_i                     : fpga_hw_out_i[PAD_CFG_hyper_ckn  ] );
  assign out_hyper_ck_o    = selected_mode_o == MODE_FUNCTIONAL_ASIC ? 1'b0              : (selected_mode_o == MODE_TEST_MODE ? out_fcb_pif_do_h_1_i                     : fpga_hw_out_i[PAD_CFG_hyper_ck   ] );
  assign out_hyper_dq0_o   = selected_mode_o == MODE_FUNCTIONAL_ASIC ? 1'b0              : (selected_mode_o == MODE_TEST_MODE ? out_fcb_pif_do_h_2_i                     : fpga_hw_out_i[PAD_CFG_hyper_dq0  ] );
  assign out_hyper_dq1_o   = selected_mode_o == MODE_FUNCTIONAL_ASIC ? 1'b0              : (selected_mode_o == MODE_TEST_MODE ? out_fcb_pif_do_h_3_i                     : fpga_hw_out_i[PAD_CFG_hyper_dq1  ] );
  assign out_hyper_dq2_o   = selected_mode_o == MODE_FUNCTIONAL_ASIC ? 1'b0              : (selected_mode_o == MODE_TEST_MODE ? out_FB_SPE_OUT_0_i                       : fpga_hw_out_i[PAD_CFG_hyper_dq2  ] );
  assign out_hyper_dq3_o   = selected_mode_o == MODE_FUNCTIONAL_ASIC ? 1'b0              : (selected_mode_o == MODE_TEST_MODE ? out_FB_SPE_OUT_1_i                       : fpga_hw_out_i[PAD_CFG_hyper_dq3  ] );
  assign out_hyper_dq4_o   = selected_mode_o == MODE_FUNCTIONAL_ASIC ? 1'b0              : (selected_mode_o == MODE_TEST_MODE ? out_FB_SPE_OUT_2_i                       : fpga_hw_out_i[PAD_CFG_hyper_dq4  ] );
  assign out_hyper_dq5_o   = selected_mode_o == MODE_FUNCTIONAL_ASIC ? 1'b0              : (selected_mode_o == MODE_TEST_MODE ? out_FB_SPE_OUT_3_i                       : fpga_hw_out_i[PAD_CFG_hyper_dq5  ] );
  assign out_hyper_dq6_o   = selected_mode_o == MODE_FUNCTIONAL_ASIC ? 1'b0              : (selected_mode_o == MODE_TEST_MODE ? 1'b0                                     : fpga_hw_out_i[PAD_CFG_hyper_dq6  ] );
  assign out_hyper_dq7_o   = selected_mode_o == MODE_FUNCTIONAL_ASIC ? 1'b0              : (selected_mode_o == MODE_TEST_MODE ? 1'b0                                     : fpga_hw_out_i[PAD_CFG_hyper_dq7  ] );
  assign out_hyper_csn0_o  = selected_mode_o == MODE_FUNCTIONAL_ASIC ? 1'b0              : (selected_mode_o == MODE_TEST_MODE ? 1'b0                                     : fpga_hw_out_i[PAD_CFG_hyper_csn0 ] );
  assign out_hyper_csn1_o  = selected_mode_o == MODE_FUNCTIONAL_ASIC ? 1'b0              : (selected_mode_o == MODE_TEST_MODE ? 1'b0                                     : fpga_hw_out_i[PAD_CFG_hyper_csn1 ] );
  assign out_hyper_rwds_o  = selected_mode_o == MODE_FUNCTIONAL_ASIC ? 1'b0              : (selected_mode_o == MODE_TEST_MODE ? 1'b0                                     : fpga_hw_out_i[PAD_CFG_hyper_rwds ] );
  assign out_i2c0_sda_o    = selected_mode_o == MODE_FUNCTIONAL_ASIC ? out_i2c0_sda_i    : (selected_mode_o == MODE_TEST_MODE ? 1'b0                                     : fpga_hw_out_i[PAD_CFG_i2c0_sda   ] );
  assign out_i2c0_scl_o    = selected_mode_o == MODE_FUNCTIONAL_ASIC ? out_i2c0_scl_i    : (selected_mode_o == MODE_TEST_MODE ? 1'b0                                     : fpga_hw_out_i[PAD_CFG_i2c0_scl   ] );
  assign out_mlatch_o      = selected_mode_o == MODE_FUNCTIONAL_ASIC ? out_mlatch_i      : (selected_mode_o == MODE_TEST_MODE ? 1'b0                                     : out_fcb_spis_miso_i                );
  assign out_fpga_gpio36_o = selected_mode_o == MODE_FUNCTIONAL_ASIC ? out_fpga_gpio36_i : (selected_mode_o == MODE_TEST_MODE ? fpga_hw_out_i[PAD_CFG_fpga_gpio36]       : 1'b0                               );
  assign out_fpga_gpio37_o = selected_mode_o == MODE_FUNCTIONAL_ASIC ? out_fpga_gpio37_i : (selected_mode_o == MODE_TEST_MODE ? fpga_hw_out_i[PAD_CFG_fpga_gpio37]       : 1'b0                               );
  assign out_fpga_gpio38_o = selected_mode_o == MODE_FUNCTIONAL_ASIC ? out_fpga_gpio38_i : (selected_mode_o == MODE_TEST_MODE ? 1'b0                                     : 1'b0                               );
  assign out_fpga_gpio39_o = selected_mode_o == MODE_FUNCTIONAL_ASIC ? out_fpga_gpio39_i : (selected_mode_o == MODE_TEST_MODE ? fpga_hw_out_i[PAD_CFG_fpga_gpio39]       : 1'b0                               );
  assign out_fpga_gpio40_o = selected_mode_o == MODE_FUNCTIONAL_ASIC ? out_fpga_gpio40_i : (selected_mode_o == MODE_TEST_MODE ? fpga_hw_out_i[PAD_CFG_fpga_gpio40]       : out_fcb_spis_miso_en_i             );


/*
    DEMUXING THE INPUT SIGNALS (from external WORLD to PULPissimo, eFPGA Func or TEST)

*/

  //INPUT VOLTAGE for PULPissimo
  assign in_spim_sdio0_o                   = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_spim_sdio0_i   ;
  assign in_spim_sdio1_o                   = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_spim_sdio1_i   ;
  assign in_spim_sdio2_o                   = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_spim_sdio2_i   ;
  assign in_spim_sdio3_o                   = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_spim_sdio3_i   ;
  assign in_spim_csn0_o                    = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_spim_csn0_i    ;
  assign in_spim_csn1_o                    = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_spim_csn1_i    ;
  assign in_spim_sck_o                     = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_spim_sck_i     ;
  assign in_uart_rx_o                      = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_uart_rx_i      ;
  assign in_uart_tx_o                      = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_uart_tx_i      ;
  assign in_cam_pclk_o                     = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_cam_pclk_i     ;
  assign in_cam_hsync_o                    = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_cam_hsync_i    ;
  assign in_cam_data0_o                    = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_cam_data0_i    ;
  assign in_cam_data1_o                    = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_cam_data1_i    ;
  assign in_cam_data2_o                    = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_cam_data2_i    ;
  assign in_cam_data3_o                    = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_cam_data3_i    ;
  assign in_cam_data4_o                    = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_cam_data4_i    ;
  assign in_cam_data5_o                    = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_cam_data5_i    ;
  assign in_cam_data6_o                    = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_cam_data6_i    ;
  assign in_cam_data7_o                    = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_cam_data7_i    ;
  assign in_cam_vsync_o                    = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_cam_vsync_i    ;
  assign in_hyper_ckn_o                    = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_hyper_ckn_i    ;
  assign in_hyper_ck_o                     = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_hyper_ck_i     ;
  assign in_hyper_dq0_o                    = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_hyper_dq0_i    ;
  assign in_hyper_dq1_o                    = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_hyper_dq1_i    ;
  assign in_hyper_dq2_o                    = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_hyper_dq2_i    ;
  assign in_hyper_dq3_o                    = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_hyper_dq3_i    ;
  assign in_hyper_dq4_o                    = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_hyper_dq4_i    ;
  assign in_hyper_dq5_o                    = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_hyper_dq5_i    ;
  assign in_hyper_dq6_o                    = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_hyper_dq6_i    ;
  assign in_hyper_dq7_o                    = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_hyper_dq7_i    ;
  assign in_hyper_csn0_o                   = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_hyper_csn0_i   ;
  assign in_hyper_csn1_o                   = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_hyper_csn1_i   ;
  assign in_hyper_rwds_o                   = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_hyper_rwds_i   ;
  assign in_i2c0_sda_o                     = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_i2c0_sda_i     ;
  assign in_i2c0_scl_o                     = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_i2c0_scl_i     ;
  assign in_mlatch_o                       = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_mlatch_i       ;
  assign in_fpga_gpio36_o                  = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_fpga_gpio36_i  ;
  assign in_fpga_gpio37_o                  = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_fpga_gpio37_i  ;
  assign in_fpga_gpio38_o                  = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_fpga_gpio38_i  ;
  assign in_fpga_gpio39_o                  = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_fpga_gpio39_i  ;
  assign in_fpga_gpio40_o                  = (selected_mode_o == MODE_FUNCTIONAL_ASIC)      && in_fpga_gpio40_i  ;
  assign in_fcb_spi_mode_en_bo_o           = (selected_mode_o == MODE_FUNCTIONAL_ASIC)       ? 1'b0 : 1'b1       ;

  logic sel_mux_mode;

  assign sel_mux_mode = selected_mode_o == MODE_FUNCTIONAL_ASIC;

  //duplicate signals for CLOCK, they do not go throuth the MUX
  assign fpga_clk_1_o = in_hyper_csn0_i;
  assign fpga_clk_2_o = in_hyper_csn1_i;

  pulp_clock_mux2 clk_mux_fpga_clk_3_i (
      .clk0_i    ( in_hyper_rwds_i      ),
      .clk1_i    ( in_fpga_gpio37_i     ),
      .clk_sel_i ( sel_mux_mode         ),
      .clk_o     ( fpga_clk_3_o         )
  );//fpga_clk3

  pulp_clock_mux2 clk_mux_fpga_clk_4_i (
      .clk0_i    ( in_i2c0_sda_i        ),
      .clk1_i    ( in_fpga_gpio39_i     ),
      .clk_sel_i ( sel_mux_mode         ),
      .clk_o     ( fpga_clk_4_o         )
  );//fpga_clk4

  pulp_clock_mux2 clk_mux_fpga_clk_5_i (
      .clk0_i    ( in_i2c0_scl_i        ),
      .clk1_i    ( in_fpga_gpio40_i     ),
      .clk_sel_i ( sel_mux_mode         ),
      .clk_o     ( fpga_clk_5_o         )
  );//fpga_clk5

  //INPUT VOLTAGE for FPGA FUNCT SPIS
  assign fpga_hw_in_o[PAD_CFG_spim_sdio0 ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_spim_sdio0_i   ;
  assign fpga_hw_in_o[PAD_CFG_spim_sdio1 ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_spim_sdio1_i   ;
  assign fpga_hw_in_o[PAD_CFG_spim_sdio2 ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_spim_sdio2_i   ;
  assign fpga_hw_in_o[PAD_CFG_spim_sdio3 ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_spim_sdio3_i   ;
  assign fpga_hw_in_o[PAD_CFG_spim_csn0  ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_spim_csn0_i    ;
  assign fpga_hw_in_o[PAD_CFG_spim_csn1  ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_spim_csn1_i    ;
  assign fpga_hw_in_o[PAD_CFG_spim_sck   ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_spim_sck_i     ;
  assign fpga_hw_in_o[PAD_CFG_uart_rx    ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_uart_rx_i      ;
  assign fpga_hw_in_o[PAD_CFG_uart_tx    ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_uart_tx_i      ;
  assign fpga_hw_in_o[PAD_CFG_cam_pclk   ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_cam_pclk_i     ;
  assign fpga_hw_in_o[PAD_CFG_cam_hsync  ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_cam_hsync_i    ;
  assign fpga_hw_in_o[PAD_CFG_cam_data0  ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_cam_data0_i    ;
  assign fpga_hw_in_o[PAD_CFG_cam_data1  ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_cam_data1_i    ;
  assign fpga_hw_in_o[PAD_CFG_cam_data2  ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_cam_data2_i    ;
  assign fpga_hw_in_o[PAD_CFG_cam_data3  ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_cam_data3_i    ;
  assign fpga_hw_in_o[PAD_CFG_cam_data4  ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_cam_data4_i    ;
  assign fpga_hw_in_o[PAD_CFG_cam_data5  ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_cam_data5_i    ;
  assign fpga_hw_in_o[PAD_CFG_cam_data6  ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_cam_data6_i    ;
  assign fpga_hw_in_o[PAD_CFG_cam_data7  ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_cam_data7_i    ;
  assign fpga_hw_in_o[PAD_CFG_cam_vsync  ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_cam_vsync_i    ;
  assign fpga_hw_in_o[PAD_CFG_hyper_ckn  ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_hyper_ckn_i    ;
  assign fpga_hw_in_o[PAD_CFG_hyper_ck   ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_hyper_ck_i     ;
  assign fpga_hw_in_o[PAD_CFG_hyper_dq0  ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_hyper_dq0_i    ;
  assign fpga_hw_in_o[PAD_CFG_hyper_dq1  ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_hyper_dq1_i    ;
  assign fpga_hw_in_o[PAD_CFG_hyper_dq2  ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_hyper_dq2_i    ;
  assign fpga_hw_in_o[PAD_CFG_hyper_dq3  ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_hyper_dq3_i    ;
  assign fpga_hw_in_o[PAD_CFG_hyper_dq4  ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_hyper_dq4_i    ;
  assign fpga_hw_in_o[PAD_CFG_hyper_dq5  ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_hyper_dq5_i    ;
  assign fpga_hw_in_o[PAD_CFG_hyper_dq6  ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_hyper_dq6_i    ;
  assign fpga_hw_in_o[PAD_CFG_hyper_dq7  ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_hyper_dq7_i    ;
  assign fpga_hw_in_o[PAD_CFG_hyper_csn0 ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_hyper_csn0_i   ;
  assign fpga_hw_in_o[PAD_CFG_hyper_csn1 ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_hyper_csn1_i   ;
  assign fpga_hw_in_o[PAD_CFG_hyper_rwds ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_hyper_rwds_i   ;
  assign fpga_hw_in_o[PAD_CFG_i2c0_sda   ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_i2c0_sda_i     ;
  assign fpga_hw_in_o[PAD_CFG_i2c0_scl   ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_i2c0_scl_i     ; //not usable for the eFPGA as this pad are in OUTPUT mode for miso and miso_en
  assign fpga_hw_in_o[PAD_CFG_mlatch     ] = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_mlatch_i       ; //not usable for the eFPGA as this pad are in OUTPUT mode for miso and miso_en
  assign in_fcb_spis_rst_n_o               = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_fpga_gpio36_i  ;
  assign in_fcb_spis_mosi_o                = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_fpga_gpio37_i  ;
  assign in_fcb_spis_cs_n_o                = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS || selected_mode_o == MODE_TEST_MODE) && in_fpga_gpio38_i  ;
  assign in_fcb_spis_clk_o                 = (selected_mode_o == MODE_FUNCTIONAL_FPGA_SPIS) && in_fpga_gpio39_i  ;


  //INPUT VOLTAGE for TEST
  assign in_fcb_pif_vldi_o                 = (selected_mode_o == MODE_TEST_MODE)            && in_spim_sdio3_i   ;
  assign in_fcb_pif_di_l_0_o               = (selected_mode_o == MODE_TEST_MODE)            && in_spim_csn0_i    ;
  assign in_fcb_pif_di_l_1_o               = (selected_mode_o == MODE_TEST_MODE)            && in_spim_csn1_i    ;
  assign in_fcb_pif_di_l_2_o               = (selected_mode_o == MODE_TEST_MODE)            && in_spim_sck_i     ;
  assign in_fcb_pif_di_l_3_o               = (selected_mode_o == MODE_TEST_MODE)            && in_uart_rx_i      ;
  assign in_fcb_pif_di_h_0_o               = (selected_mode_o == MODE_TEST_MODE)            && in_uart_tx_i      ;
  assign in_fcb_pif_di_h_1_o               = (selected_mode_o == MODE_TEST_MODE)            && in_cam_pclk_i     ;
  assign in_fcb_pif_di_h_2_o               = (selected_mode_o == MODE_TEST_MODE)            && in_cam_hsync_i    ;
  assign in_fcb_pif_di_h_3_o               = (selected_mode_o == MODE_TEST_MODE)            && in_cam_data0_i    ;
  assign in_FB_SPE_IN_0_o                  = (selected_mode_o == MODE_TEST_MODE)            && in_hyper_dq6_i    ;
  assign in_FB_SPE_IN_1_o                  = (selected_mode_o == MODE_TEST_MODE)            && in_hyper_dq7_i    ;
  assign in_FB_SPE_IN_2_o                  = (selected_mode_o == MODE_TEST_MODE)            && in_hyper_csn0_i   ;
  assign in_FB_SPE_IN_3_o                  = (selected_mode_o == MODE_TEST_MODE)            && in_hyper_csn1_i   ;
  assign in_M_0_o                          = (selected_mode_o == MODE_TEST_MODE)            && in_hyper_rwds_i   ;
  assign in_M_1_o                          = (selected_mode_o == MODE_TEST_MODE)            && in_i2c0_sda_i     ;
  assign in_M_2_o                          = (selected_mode_o == MODE_TEST_MODE)            && in_i2c0_scl_i     ;
  assign in_M_3_o                          = (selected_mode_o == MODE_TEST_MODE)            && in_spim_sdio0_i   ;
  assign in_M_4_o                          = (selected_mode_o == MODE_TEST_MODE)            && in_spim_sdio1_i   ;
  assign in_M_5_o                          = (selected_mode_o == MODE_TEST_MODE)            && in_spim_sdio2_i   ;
  assign in_MLATCH_o                       = (selected_mode_o == MODE_TEST_MODE)            && in_mlatch_i       ;
  assign fpga_hw_in_o[PAD_CFG_fpga_gpio36] = (selected_mode_o == MODE_TEST_MODE)            && in_fpga_gpio36_i  ;
  assign fpga_hw_in_o[PAD_CFG_fpga_gpio37] = (selected_mode_o == MODE_TEST_MODE)            && in_fpga_gpio37_i  ;
  assign fpga_hw_in_o[PAD_CFG_fpga_gpio39] = (selected_mode_o == MODE_TEST_MODE)            && in_fpga_gpio39_i  ;
  assign fpga_hw_in_o[PAD_CFG_fpga_gpio40] = (selected_mode_o == MODE_TEST_MODE)            && in_fpga_gpio40_i  ;

  assign oe_fcb_pif_vldi                   =  1'b0; //input
  assign oe_fcb_pif_di_l_0                 =  1'b0; //input
  assign oe_fcb_pif_di_l_1                 =  1'b0; //input
  assign oe_fcb_pif_di_l_2                 =  1'b0; //input
  assign oe_fcb_pif_di_l_3                 =  1'b0; //input
  assign oe_fcb_pif_di_h_0                 =  1'b0; //input
  assign oe_fcb_pif_di_h_1                 =  1'b0; //input
  assign oe_fcb_pif_di_h_2                 =  1'b0; //input
  assign oe_fcb_pif_di_h_3                 =  1'b0; //input
  assign oe_fcb_pif_vldo_en                =  1'b1; //output
  assign oe_fcb_pif_vldo                   =  1'b1; //output
  assign oe_fcb_pif_do_l_en                =  1'b1; //output
  assign oe_fcb_pif_do_l_0                 =  1'b1; //output
  assign oe_fcb_pif_do_l_1                 =  1'b1; //output
  assign oe_fcb_pif_do_l_2                 =  1'b1; //output
  assign oe_fcb_pif_do_l_3                 =  1'b1; //output
  assign oe_fcb_pif_do_h_en                =  1'b1; //output
  assign oe_fcb_pif_do_h_0                 =  1'b1; //output
  assign oe_fcb_pif_do_h_1                 =  1'b1; //output
  assign oe_fcb_pif_do_h_2                 =  1'b1; //output
  assign oe_fcb_pif_do_h_3                 =  1'b1; //output
  assign oe_FB_SPE_OUT_0                   =  1'b1; //output
  assign oe_FB_SPE_OUT_1                   =  1'b1; //output
  assign oe_FB_SPE_OUT_2                   =  1'b1; //output
  assign oe_FB_SPE_OUT_3                   =  1'b1; //output
  assign oe_FB_SPE_IN_0                    =  1'b0; //input
  assign oe_FB_SPE_IN_1                    =  1'b0; //input
  assign oe_FB_SPE_IN_2                    =  1'b0; //input
  assign oe_FB_SPE_IN_3                    =  1'b0; //input
  assign oe_M_0                            =  1'b0; //input
  assign oe_M_1                            =  1'b0; //input
  assign oe_M_2                            =  1'b0; //input
  assign oe_M_3                            =  1'b0; //input
  assign oe_M_4                            =  1'b0; //input
  assign oe_M_5                            =  1'b0; //input
  assign oe_MLATCH                         =  1'b0; //input

  assign oe_fcb_spis_miso_en               =  1'b1; //output
  assign oe_fcb_spis_miso                  =  1'b1; //output
  assign oe_fcb_spis_rst_n                 =  1'b0; //input
  assign oe_fcb_spis_mosi                  =  1'b0; //input
  assign oe_fcb_spis_cs_n                  =  1'b0; //input
  assign oe_fcb_spis_clk                   =  1'b0; //input

endmodule
