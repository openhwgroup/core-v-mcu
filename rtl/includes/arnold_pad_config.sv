// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

////////////////////////////////////////////////////////////////////////////////
// Engineer:       Pasquale Schiavone - pschiavo@iis.ee.ethz.ch               //
//                                                                            //
// Design Name:    Pad Frame configurations                                   //
// Project Name:   Arnold                                                     //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Defines for various constants used by the pad frame     .  //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

package arnold_pad_config;


    parameter PAD_CFG_spim_sdio0  = 0;
    parameter PAD_CFG_spim_sdio1  = 1;
    parameter PAD_CFG_spim_sdio2  = 2;
    parameter PAD_CFG_spim_sdio3  = 3;
    parameter PAD_CFG_spim_csn0   = 4;
    parameter PAD_CFG_spim_csn1   = 5;
    parameter PAD_CFG_spim_sck    = 6;
    parameter PAD_CFG_uart_rx     = 7;
    parameter PAD_CFG_uart_tx     = 8;
    parameter PAD_CFG_cam_pclk    = 9;
    parameter PAD_CFG_cam_hsync   = 10;
    parameter PAD_CFG_cam_data0   = 11;
    parameter PAD_CFG_cam_data1   = 12;
    parameter PAD_CFG_cam_data2   = 13;
    parameter PAD_CFG_cam_data3   = 14;
    parameter PAD_CFG_cam_data4   = 15;
    parameter PAD_CFG_cam_data5   = 16;
    parameter PAD_CFG_cam_data6   = 17;
    parameter PAD_CFG_cam_data7   = 18;
    parameter PAD_CFG_cam_vsync   = 19;
    parameter PAD_CFG_hyper_ckn   = 20;
    parameter PAD_CFG_hyper_ck    = 21;
    parameter PAD_CFG_hyper_dq0   = 22;
    parameter PAD_CFG_hyper_dq1   = 23;
    parameter PAD_CFG_hyper_dq2   = 24;
    parameter PAD_CFG_hyper_dq3   = 25;
    parameter PAD_CFG_hyper_dq4   = 26;
    parameter PAD_CFG_hyper_dq5   = 27;
    parameter PAD_CFG_hyper_dq6   = 28;
    parameter PAD_CFG_hyper_dq7   = 29;
    parameter PAD_CFG_hyper_csn0  = 30;
    parameter PAD_CFG_hyper_csn1  = 31;
    parameter PAD_CFG_hyper_rwds  = 32;
    parameter PAD_CFG_i2c0_sda    = 33;
    parameter PAD_CFG_i2c0_scl    = 34;
    parameter PAD_CFG_mlatch      = 35;
    parameter PAD_CFG_fpga_gpio36 = 36;
    parameter PAD_CFG_fpga_gpio37 = 37;
    parameter PAD_CFG_fpga_gpio38 = 38;
    parameter PAD_CFG_fpga_gpio39 = 39;
    parameter PAD_CFG_fpga_gpio40 = 40;

    //TEST
    parameter PAD_CFGTEST_fcb_pif_vldi     = PAD_CFG_spim_sdio3;
    parameter PAD_CFGTEST_fcb_pif_di_l_0   = PAD_CFG_spim_csn1 ;
    parameter PAD_CFGTEST_fcb_pif_di_l_1   = PAD_CFG_spim_csn0 ;
    parameter PAD_CFGTEST_fcb_pif_di_l_2   = PAD_CFG_spim_sck  ;
    parameter PAD_CFGTEST_fcb_pif_di_l_3   = PAD_CFG_uart_rx   ;
    parameter PAD_CFGTEST_fcb_pif_di_h_0   = PAD_CFG_uart_tx   ;
    parameter PAD_CFGTEST_fcb_pif_di_h_1   = PAD_CFG_cam_pclk  ;
    parameter PAD_CFGTEST_fcb_pif_di_h_2   = PAD_CFG_cam_hsync ;
    parameter PAD_CFGTEST_fcb_pif_di_h_3   = PAD_CFG_cam_data0 ;
    parameter PAD_CFGTEST_fcb_pif_vldo_en  = PAD_CFG_cam_data1 ;
    parameter PAD_CFGTEST_fcb_pif_vldo     = PAD_CFG_cam_data2 ;
    parameter PAD_CFGTEST_fcb_pif_do_l_en  = PAD_CFG_cam_data3 ;
    parameter PAD_CFGTEST_fcb_pif_do_l_0   = PAD_CFG_cam_data4 ;
    parameter PAD_CFGTEST_fcb_pif_do_l_1   = PAD_CFG_cam_data5 ;
    parameter PAD_CFGTEST_fcb_pif_do_l_2   = PAD_CFG_cam_data6 ;
    parameter PAD_CFGTEST_fcb_pif_do_l_3   = PAD_CFG_cam_data7 ;
    parameter PAD_CFGTEST_fcb_pif_do_h_en  = PAD_CFG_cam_vsync ;
    parameter PAD_CFGTEST_fcb_pif_do_h_0   = PAD_CFG_hyper_ckn ;
    parameter PAD_CFGTEST_fcb_pif_do_h_1   = PAD_CFG_hyper_ck  ;
    parameter PAD_CFGTEST_fcb_pif_do_h_2   = PAD_CFG_hyper_dq0 ;
    parameter PAD_CFGTEST_fcb_pif_do_h_3   = PAD_CFG_hyper_dq1 ;
    parameter PAD_CFGTEST_FB_SPE_OUT_0     = PAD_CFG_hyper_dq2 ;
    parameter PAD_CFGTEST_FB_SPE_OUT_1     = PAD_CFG_hyper_dq3 ;
    parameter PAD_CFGTEST_FB_SPE_OUT_2     = PAD_CFG_hyper_dq4 ;
    parameter PAD_CFGTEST_FB_SPE_OUT_3     = PAD_CFG_hyper_dq5 ;
    parameter PAD_CFGTEST_FB_SPE_IN_0      = PAD_CFG_hyper_dq6 ;
    parameter PAD_CFGTEST_FB_SPE_IN_1      = PAD_CFG_hyper_dq7 ;
    parameter PAD_CFGTEST_FB_SPE_IN_2      = PAD_CFG_hyper_csn0;
    parameter PAD_CFGTEST_FB_SPE_IN_3      = PAD_CFG_hyper_csn1;
    parameter PAD_CFGTEST_M_0              = PAD_CFG_hyper_rwds;
    parameter PAD_CFGTEST_M_1              = PAD_CFG_i2c0_sda  ;
    parameter PAD_CFGTEST_M_2              = PAD_CFG_i2c0_scl  ;
    parameter PAD_CFGTEST_M_3              = PAD_CFG_spim_sdio0;
    parameter PAD_CFGTEST_M_4              = PAD_CFG_spim_sdio1;
    parameter PAD_CFGTEST_M_5              = PAD_CFG_spim_sdio2;
    parameter PAD_CFGTEST_MLATCH           = PAD_CFG_mlatch    ;

    //PAD SW Mode
    parameter PAD_PERIPHERAL      = 2'b00;
    parameter PAD_GPIO            = 2'b01;
    parameter PAD_EFPGA           = 2'b10;

    //PAD HW Mode
    parameter MODE_FUNCTIONAL_ASIC       = 2'b00;
    parameter MODE_FUNCTIONAL_FPGA_SPIS  = 2'b01;
    parameter MODE_TEST_MODE             = 2'b10;

endpackage
