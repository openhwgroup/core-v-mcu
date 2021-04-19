// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1


module fcbrfu #(
    parameter PAR_ADDR_BITS = 7
) (
    //----------------------------------------------------------------------------//
    //--	INPUT Signals							    --//
    //----------------------------------------------------------------------------//	
    input logic fcb_sys_clk,  //Main Clock for FCB except SPI Slave Int
    input logic fcb_sys_rst_n,  //Main Reset for FCB except SPI Slave int
    input logic fcb_sys_stm,  //1'b1 : Put the module into Test Mode
    input logic ffsr_frfu_clr_fb_cfg_kickoff,  //Clear Kick-Off Register
    input logic [31:0] ffsr_frfu_rfifo_rdata,  //Read Data of Read FIFO
    input logic ffsr_frfu_rfifo_empty,  //Empty Flag of Read FIFO
    input logic ffsr_frfu_wfifo_full,  //Full Flag of Write FIFO
    input logic ffsr_frfu_wfifo_full_m1,  //Full Flag minus 1 Flag of Write FIFO
    input logic [6:0] frwf_frfu_rd_addr,  //SFR Read Address
    input logic [6:0] frwf_frfu_wr_addr,  //SFR Write Address
    input logic frwf_frfu_wr_en,  //SFR Write Enable
    input logic frwf_frfu_rd_en,  //SFR Read Enable
    input logic [7:0] frwf_frfu_wr_data,  //SFR Write Data
    input logic frwf_frfu_frwf_on,  //APB/PIF is ON
    input logic [31:0] frwf_frfu_cwf_wr_data,  //Write Data Of Cfg Write FIFO
    input logic frwf_frfu_cwf_wr_en,  //Write Enable to indicate the whole 32-B
    input logic frwf_frfu_crf_full,  //Full Flag of Cfg Read FIFO
    input logic frwf_frfu_crf_full_m1,  //Full Flag minus 1 of Cfg Read FIFO
    input logic [6:0] fsmc_frfu_rd_addr,  //SFR Read Address
    input logic [6:0] fsmc_frfu_wr_addr,  //SFR Write Address
    input logic fsmc_frfu_wr_en,  //SFR Write Enable
    input logic fsmc_frfu_rd_en,  //SFR Read Enable
    input logic [7:0] fsmc_frfu_wr_data,  //SFR Write Data
    input logic fsmc_frfu_spim_on,  //SPI Master is ON
    input logic [7:0] fsmc_frfu_cwf_wr_data,  //Write Data Of Cfg Write FIFO
    input logic fsmc_frfu_cwf_wr_en,  //If Whole Word data are valid.
    input logic [6:0] fssc_frfu_wr_addr,  //SFR Write Address
    input logic fssc_frfu_wr_en,  //SFR Write Enable
    input logic [7:0] fssc_frfu_wr_data,  //SFR Write Data
    input logic fssc_frfu_spis_on,  //SPI Slave is ON
    input logic [6:0] fssc_frfu_rd_addr,  //SFR Read Address
    input logic fssc_frfu_rd_en,  //SFR Read Enable
    input logic [7:0] fssc_frfu_cwf_wr_data,  //Write Data Of Cfg Write FIFO
    input logic fssc_frfu_cwf_wr_en,
    //input logic [7:0]             fpmu_frfu_clr_quad_pd_en_b0 ,   //Clear Quad PD Enable, bit 0->Quad00, Bi
    //input logic [7:0]             fpmu_frfu_clr_quad_pd_en_b1 ,   //Clear Quad PD Enable, bit 0->Quad20, Bi
    //input logic [7:0]             fpmu_frfu_clr_quad_wu_en_b0 ,   //Clear Quad Wake Up Enable, bit 0->Quad0
    //input logic [7:0]             fpmu_frfu_clr_quad_wu_en_b1 ,   //Clear Quad Wake Up Enable, bit 0->Quad2
    //input logic                   fpmu_frfu_clr_quad_wu_wr_en_b0 ,   //Clear Enable, Once Asserted, the corres
    input logic fpmu_frfu_clr_quads,  //JC  //Clear Enable, Once Asserted, the corres
    //input logic                   fpmu_frfu_clr_quad_pd_wr_en_b0 ,   //Clear Enable, Once Asserted, the corres
    //input logic                   fpmu_frfu_clr_quad_pd_wr_en_b1 ,   //Clear Enable, Once Asserted, the corres

    input logic [7:0] fcb_device_id_bo,
    input logic       fcb_clp_mode_en_bo,  //JC 01262017
    input logic       fcb_vlp,
    input logic       fmic_frfu_set_pmu_chip_vlp_en,
    input logic       fmic_frfu_set_pmu_chip_wu_en,
    input logic       fmic_frfu_set_rc_clk_en,
    //input logic 			fpmu_frfu_clr_pmu_chip_vlp_en ,
    //input logic 			fpmu_frfu_clr_pmu_chip_wu_en ,
    input logic [1:0] fpmu_frfu_pw_sta_00,
    input logic [1:0] fpmu_frfu_pw_sta_01,
    input logic [1:0] fpmu_frfu_pw_sta_02,
    input logic [1:0] fpmu_frfu_pw_sta_03,
    input logic [1:0] fpmu_frfu_pw_sta_10,
    input logic [1:0] fpmu_frfu_pw_sta_11,
    input logic [1:0] fpmu_frfu_pw_sta_12,
    input logic [1:0] fpmu_frfu_pw_sta_13,
    input logic [1:0] fpmu_frfu_pw_sta_20,
    input logic [1:0] fpmu_frfu_pw_sta_21,
    input logic [1:0] fpmu_frfu_pw_sta_22,
    input logic [1:0] fpmu_frfu_pw_sta_23,
    input logic [1:0] fpmu_frfu_pw_sta_30,
    input logic [1:0] fpmu_frfu_pw_sta_31,
    input logic [1:0] fpmu_frfu_pw_sta_32,
    input logic [1:0] fpmu_frfu_pw_sta_33,
    input logic       fsmc_frfu_set_fb_cfg_done,
    input logic       fsmc_frfu_clr_rcclk_en,  //Clear RC CLK Enable
    input logic       ffsr_frfu_rfifo_empty_p1,  //Empty Plus 1 Flag of Read FIFO

    input  logic       fclp_frfu_clear_vlp_en,  //Clear VLP EN Bit
    input  logic       fclp_frfu_clear_vlp_wu_en,  //Clear VLP WU EN Bit
    input  logic       fclp_frfu_clear_pd_en,  //Clear PD Enable
    input  logic       fclp_frfu_clear_pd_wu_en,  //Clear PD WU Enable
    input  logic [1:0] fclp_frfu_clp_pw_sta,  //Macro's Power Status
    input  logic       fclp_frfu_clear_cfg_done,  //Clear the CFG Done.
    input  logic       fsmc_frfu_set_pd,  //JC
    input  logic       fsmc_frfu_set_clp_pd,  //JC
    //input logic			fpmu_frfu_clr_pmu_chip_pd_en ,	//JC
    input  logic [1:0] fpmu_frfu_chip_pw_sta,  //JC 05232017
    input  logic       fpmu_frfu_clr_cfg_done,  //JC
    input  logic       fpmu_frfu_clr_pmu_chip_cmd,  //JC, Latest One
    input  logic       fpmu_frfu_pmu_busy,
    input  logic       fsmc_frfu_set_quad_pd,
    input  logic       fpmu_frfu_fb_cfg_cleanup,
    input  logic       fclp_frfu_fb_cfg_cleanup,
    input  logic       frwf_frfu_ff0_of,
    //----------------------------------------------------------------------------//
    //--	Output Signals						            --//
    //----------------------------------------------------------------------------//	
    output logic       frfu_fpmu_fb_iso_enb_sd,
    output logic       frfu_fpmu_pwr_gate_sd,
    output logic       frfu_fpmu_prog_ifx_sd,
    output logic       frfu_fpmu_set_por_sd,
    output logic [7:0] frfu_fpmu_prog_sd_0,
    output logic [7:0] frfu_fpmu_prog_sd_1,

    output logic        frfu_fpmu_fb_cfg_done,  // JC
    output logic        frfu_fpmu_prog_pmu_chip_cmd,  //JC
    output logic [ 3:0] frfu_fpmu_pmu_chip_cmd,  //JC
    output logic        frfu_fpmu_prog_cfg_done,  //JC
    output logic        frfu_fpmu_clr_cfg_done,
    //output logic			frfu_fpmu_prog_pmu_quad_pd_en, 	//JC
    //output logic			frfu_fpmu_prog_pmu_quad_wu_en, 	//JC
    //output logic			frfu_fpmu_pmu_chip_pd_en ,	//JC
    output logic [ 7:0] frfu_fsmc_spim_ckb_0,
    output logic [ 7:0] frfu_fsmc_spim_ckb_1,
    output logic [ 7:0] frfu_bl_pw_cfg_0,  //
    output logic [ 7:0] frfu_bl_pw_cfg_1,  //
    output logic [ 7:0] frfu_wl_pw_cfg,  //
    output logic        frfu_ffsr_rfifo_rd_en,  //Read Enable of Read FIFO
    output logic [31:0] frfu_ffsr_wfifo_wdata,  //Write Data Of write FIFO
    output logic        frfu_ffsr_wfifo_wr_en,  //Write Enable Of Write FIFO
    output logic [ 1:0] frfu_ffsr_blclk_sut,  //JC 07
    output logic [ 1:0] frfu_ffsr_wlclk_sut,  //JC 07
    output logic [ 1:0] frfu_ffsr_wlen_sut,  //JC 07
    output logic [ 7:0] frfu_sfr_rd_data,  //SFR Read Data
    output logic        frfu_cwf_full,  //Full Flag of Cfg Write FIFO
    output logic [31:0] frfu_frwf_crf_wr_data,  //Write Data of Cfg Read FIFO
    output logic        frfu_frwf_crf_wr_en,  //Write Enable of Cfg Read FIFO
    output logic [ 7:0] frfu_fsmc_spim_device_id,  //
    output logic        frfu_fsmc_checksum_status,  //CheckSum Status
    output logic        fcb_fb_cfg_done,  //Indicate the Fabric Configuration is do
    output logic        frfu_fsmc_pending_pd_req,  //Pending Power Down Request
    output logic [ 7:0] frfu_ffsr_bl_cnt_h,
    output logic [ 7:0] frfu_ffsr_bl_cnt_l,
    output logic [ 3:0] frfu_ffsr_cfg_wrp_ccnt,
    output logic [ 3:0] frfu_ffsr_rcfg_wrp_ccnt,
    output logic [ 7:0] frfu_ffsr_col_cnt,
    output logic [ 7:0] frfu_ffsr_fb_cfg_cmd,
    output logic        frfu_ffsr_fb_cfg_kickoff,
    output logic [ 7:0] frfu_ffsr_ram_cfg_0_en,
    output logic [ 7:0] frfu_ffsr_ram_cfg_1_en,
    output logic [ 7:0] frfu_ffsr_ram_data_width,
    output logic [ 7:0] frfu_ffsr_ram_size_b0,
    output logic [ 7:0] frfu_ffsr_ram_size_b1,
    output logic [ 7:0] frfu_ffsr_wl_cnt_h,
    output logic [ 7:0] frfu_ffsr_wl_cnt_l,
    output logic        frfu_fmic_done_op_mask_n,
    output logic        frfu_fmic_fb_cfg_done,
    output logic [ 3:0] frfu_fmic_io_sv_180,
    output logic        frfu_fmic_rc_clk_en,
    output logic        frfu_fmic_vlp_pin_en,
    output logic [ 7:0] frfu_fpmu_iso_en_sd_0,
    output logic [ 7:0] frfu_fpmu_iso_en_sd_1,
    output logic [ 7:0] frfu_fpmu_pi_pwr_sd_0,
    output logic [ 7:0] frfu_fpmu_pi_pwr_sd_1,

    //output logic 			frfu_fpmu_pmu_chip_vlp_en ,
    //output logic 			frfu_fpmu_pmu_chip_vlp_wu_en ,
    output logic 			frfu_fpmu_pmu_mux_sel_sd ,
    output logic [5:0]		frfu_fpmu_pmu_pwr_gate_ccnt ,
    output logic [7:0]		frfu_fpmu_pmu_timer_ccnt ,
    //output logic [7:0]		frfu_fpmu_quad_pd_en_b0 ,
    //output logic [7:0]		frfu_fpmu_quad_pd_en_b1 ,
    //output logic [1:0]		frfu_fpmu_quad_pd_mode , //JC
    //output logic [7:0]		frfu_fpmu_quad_wu_en_b0 ,
    //output logic [7:0]		frfu_fpmu_quad_wu_en_b1 ,
    //output logic [1:0]		frfu_fpmu_quad_wu_mode ,//JC
    output logic [7:0]		frfu_fpmu_quad_cfg_b1 , //JC
    output logic [7:0]		frfu_fpmu_quad_cfg_b0 , //JC

    output logic 			frfu_fpmu_vlp_clkdis_ifx_sd ,
    output logic [7:0]		frfu_fpmu_vlp_clkdis_sd_0 ,
    output logic [7:0]		frfu_fpmu_vlp_clkdis_sd_1 ,
    output logic 			frfu_fpmu_vlp_pwrdis_ifx_sd ,

    output logic [7:0] frfu_fpmu_vlp_pwrdis_sd_0,
    output logic [7:0] frfu_fpmu_vlp_pwrdis_sd_1,
    output logic       frfu_fpmu_vlp_srdis_ifx_sd,
    output logic [7:0] frfu_fpmu_vlp_srdis_sd_0,
    output logic [7:0] frfu_fpmu_vlp_srdis_sd_1,
    output logic       frfu_fsmc_rc_clk_dis_cfg,
    output logic [7:0] frfu_fsmc_spim_baud_rate,
    output logic       frfu_fsmc_sw2_spis,
    //output logic [7:0]		frfu_wr_data_port ,
    output logic [7:0] frfu_wrd_cnt_b0,
    output logic [7:0] frfu_wrd_cnt_b1,
    output logic [7:0] frfu_wrd_cnt_b2,
    //----------------------------------------------------------------//
    //--								--//
    //----------------------------------------------------------------//
    output logic [1:0] frfu_ffsr_wlblclk_cfg,
    output logic       frfu_fsmc_checksum_enable,  // How to generate it
    //output logic 	                frfu_fpmu_prog_quad_wu_en_b1 ,  //Pulse
    //output logic 	                frfu_fpmu_prog_quad_wu_en_b1 ,  //Pulse
    //output logic                  frfu_fpmu_prog_pmu_chip_wu_en ,     //Pulse for both VLP and PD JC
    //output logic                  frfu_fpmu_prog_pmu_chip_vlp_en ,        //Pulse
    //output logic                  frfu_fpmu_prog_pmu_chip_pd_en ,         //Pulse JC
    output logic       frfu_fclp_cfg_done,  //Configure Done Signal, Used to Clear LT
    output logic       frfu_fclp_clp_vlp_wu_en,  //VLP WU enable
    output logic       frfu_fclp_clp_vlp_en,  //VLP Enable
    output logic       frfu_fclp_clp_pd_wu_en,  //PD WU enable
    output logic       frfu_fclp_clp_pd_en,  //PD enable
    output logic [1:0] frfu_fpmu_pmu_time_ctl,  //Internal Timing Configure 
    output logic [1:0] frfu_fclp_clp_time_ctl  //Internal Timing Configure 
);

  //--------------------------------------------------------------------------------//
  //-- Internal Signal and Parameter 						--//
  //--------------------------------------------------------------------------------// 
  //------------------------------------------------------------------------//
  //-- Parameter					       			--//
  //------------------------------------------------------------------------//
  localparam PAR_DLY = 1'b1;

  //------------------------------------------------------------------------//
  //-- Internal Signals							--//
  //------------------------------------------------------------------------// 
  logic                     addr_00_rd_en;
  logic                     addr_00_wr_en;
  logic                     addr_01_rd_en;
  logic                     addr_01_wr_en;
  logic                     addr_02_rd_en;
  logic                     addr_02_wr_en;
  logic                     addr_03_rd_en;
  logic                     addr_03_wr_en;
  logic                     addr_04_rd_en;
  logic                     addr_04_wr_en;
  logic                     addr_05_rd_en;
  logic                     addr_05_wr_en;
  logic                     addr_06_rd_en;
  logic                     addr_06_wr_en;
  logic                     addr_07_rd_en;
  logic                     addr_07_wr_en;
  logic                     addr_08_rd_en;
  logic                     addr_08_wr_en;
  logic                     addr_09_rd_en;
  logic                     addr_09_wr_en;
  logic                     addr_0a_rd_en;
  logic                     addr_0a_wr_en;
  logic                     addr_0b_rd_en;
  logic                     addr_0b_wr_en;
  logic                     addr_0c_rd_en;
  logic                     addr_0c_wr_en;
  logic                     addr_0d_rd_en;
  logic                     addr_0d_wr_en;
  logic                     addr_0e_rd_en;
  logic                     addr_0e_wr_en;
  logic                     addr_0f_rd_en;
  logic                     addr_0f_wr_en;
  logic                     addr_10_rd_en;
  logic                     addr_10_wr_en;
  logic                     addr_11_rd_en;
  logic                     addr_11_wr_en;
  logic                     addr_12_rd_en;
  logic                     addr_12_wr_en;
  logic                     addr_13_rd_en;
  logic                     addr_13_wr_en;
  logic                     addr_14_rd_en;
  logic                     addr_14_wr_en;
  logic                     addr_15_rd_en;
  logic                     addr_15_wr_en;
  logic                     addr_16_rd_en;
  logic                     addr_16_wr_en;
  logic                     addr_17_rd_en;
  logic                     addr_17_wr_en;
  logic                     addr_18_rd_en;
  logic                     addr_18_wr_en;
  logic                     addr_19_rd_en;
  logic                     addr_19_wr_en;
  logic                     addr_1a_rd_en;
  logic                     addr_1a_wr_en;
  logic                     addr_1b_rd_en;
  logic                     addr_1b_wr_en;
  logic                     addr_1c_rd_en;
  logic                     addr_1c_wr_en;
  logic                     addr_1d_rd_en;
  logic                     addr_1d_wr_en;
  logic                     addr_1e_rd_en;
  logic                     addr_1e_wr_en;
  logic                     addr_1f_rd_en;
  logic                     addr_1f_wr_en;
  logic                     addr_20_rd_en;
  logic                     addr_20_wr_en;
  logic                     addr_21_rd_en;
  logic                     addr_21_wr_en;
  logic                     addr_30_rd_en;
  logic                     addr_30_wr_en;
  logic                     addr_31_rd_en;
  logic                     addr_31_wr_en;
  logic                     addr_32_rd_en;
  logic                     addr_32_wr_en;
  logic                     addr_33_rd_en;
  logic                     addr_33_wr_en;
  logic                     addr_34_rd_en;
  logic                     addr_34_wr_en;
  logic                     addr_35_rd_en;
  logic                     addr_35_wr_en;
  logic                     addr_36_rd_en;
  logic                     addr_36_wr_en;
  logic                     addr_37_rd_en;
  logic                     addr_37_wr_en;
  logic                     addr_38_rd_en;
  logic                     addr_38_wr_en;
  logic                     addr_39_rd_en;
  logic                     addr_39_wr_en;
  logic                     addr_3a_rd_en;
  logic                     addr_3a_wr_en;
  logic                     addr_3b_rd_en;
  logic                     addr_3b_wr_en;
  logic                     addr_3c_rd_en;
  logic                     addr_3c_wr_en;
  logic                     addr_3d_rd_en;
  logic                     addr_3d_wr_en;
  logic                     addr_3e_rd_en;
  logic                     addr_3e_wr_en;
  logic                     addr_40_rd_en;
  logic                     addr_40_wr_en;
  logic                     addr_41_rd_en;
  logic                     addr_41_wr_en;
  logic                     addr_42_rd_en;
  logic                     addr_42_wr_en;
  logic                     addr_43_rd_en;
  logic                     addr_43_wr_en;
  logic                     addr_44_rd_en;
  logic                     addr_44_wr_en;
  logic                     addr_45_rd_en;
  logic                     addr_45_wr_en;
  logic                     addr_46_rd_en;
  logic                     addr_46_wr_en;
  logic                     addr_47_rd_en;
  logic                     addr_47_wr_en;
  logic                     addr_48_rd_en;
  logic                     addr_48_wr_en;
  logic                     addr_49_rd_en;
  logic                     addr_49_wr_en;
  logic                     addr_4a_rd_en;
  logic                     addr_4a_wr_en;
  logic                     addr_4b_rd_en;
  logic                     addr_4b_wr_en;
  logic                     addr_4c_rd_en;
  logic                     addr_4c_wr_en;
  logic                     addr_4d_rd_en;
  logic                     addr_4d_wr_en;
  logic                     addr_4e_rd_en;
  logic                     addr_4e_wr_en;
  logic                     addr_4f_rd_en;
  logic                     addr_4f_wr_en;
  logic                     addr_50_rd_en;
  logic                     addr_50_wr_en;
  logic                     addr_51_rd_en;
  logic                     addr_51_wr_en;
  logic                     addr_52_rd_en;
  logic                     addr_52_wr_en;
  logic                     addr_53_rd_en;
  logic                     addr_53_wr_en;
  logic                     addr_54_rd_en;
  logic                     addr_54_wr_en;
  logic                     addr_55_rd_en;
  logic                     addr_55_wr_en;
  logic                     addr_56_rd_en;
  logic                     addr_56_wr_en;
  logic                     addr_57_rd_en;
  logic                     addr_57_wr_en;
  logic                     addr_58_rd_en;
  logic                     addr_58_wr_en;
  logic                     addr_59_rd_en;
  logic                     addr_59_wr_en;
  logic                     addr_5a_rd_en;
  logic                     addr_5a_wr_en;
  logic                     addr_5b_rd_en;
  logic                     addr_5b_wr_en;
  logic                     addr_5c_rd_en;
  logic                     addr_5c_wr_en;
  logic                     addr_5d_rd_en;
  logic                     addr_5d_wr_en;
  logic                     addr_5e_rd_en;
  logic                     addr_5e_wr_en;
  logic                     addr_60_rd_en;
  logic                     addr_60_wr_en;
  logic                     addr_61_rd_en;
  logic                     addr_61_wr_en;
  logic                     addr_62_rd_en;
  logic                     addr_62_wr_en;
  logic                     addr_27_rd_en;
  logic                     addr_27_wr_en;
  logic                     addr_28_rd_en;
  logic                     addr_28_wr_en;
  logic                     addr_29_rd_en;
  logic                     addr_29_wr_en;
  logic                     addr_2a_rd_en;
  logic                     addr_2a_wr_en;
  logic                     addr_2b_rd_en;
  logic                     addr_2b_wr_en;
  logic                     addr_2c_rd_en;
  logic                     addr_2c_wr_en;

  logic                     addr_2d_rd_en;
  logic                     addr_2d_wr_en;
  logic                     addr_2e_rd_en;
  logic                     addr_2e_wr_en;
  logic                     addr_2f_rd_en;
  logic                     addr_2f_wr_en;

  logic [              7:0] frfu_csum_w0_b0;
  logic [              7:0] frfu_csum_w0_b1;
  logic [              7:0] frfu_csum_w1_b0;
  logic [              7:0] frfu_csum_w1_b1;
  logic                     frfu_fpmu_up_sd;
  logic [              7:0] frfu_fpmu_vlp_0;
  logic [              7:0] frfu_fpmu_vlp_1;
  logic [              7:0] frfu_fpmu_vlp_clkdis_0;
  logic [              7:0] frfu_fpmu_vlp_clkdis_1;
  logic                     frfu_fpmu_vlp_clkdis_ifx;
  logic                     frfu_fpmu_vlp_ifx;
  logic                     frfu_fpmu_vlp_pin_value;
  logic [              7:0] frfu_fpmu_vlp_pwrdis_0;
  logic [              7:0] frfu_fpmu_vlp_pwrdis_1;
  logic                     frfu_fpmu_vlp_pwrdis_ifx;
  logic [              7:0] frfu_fpmu_vlp_srdis_0;
  logic [              7:0] frfu_fpmu_vlp_srdis_1;
  logic                     frfu_fpmu_vlp_srdis_ifx;

  logic                     frfu_fpmu_fb_iso_enb;
  logic                     frfu_fpmu_pwr_gate;
  logic                     frfu_fpmu_prog_ifx;
  logic                     frfu_fpmu_set_por;
  logic [              7:0] frfu_fpmu_prog_0;
  logic [              7:0] frfu_fpmu_prog_1;

  //				JC
  //
  logic                     frfu_fpmu_vlp_ifx_sd;
  //logic [7:0]			frfu_fpmu_vlp_sd_0 ;
  //logic [7:0]			frfu_fpmu_vlp_sd_1 ;
  logic [              7:0] frfu_fpmu_pi_pwr_0;
  logic [              7:0] frfu_fpmu_pi_pwr_1;
  logic [              7:0] frfu_fpmu_iso_en_0;
  logic [              7:0] frfu_fpmu_iso_en_1;
  logic                     frfu_fpmu_pmu_mux_up_sd;
  //
  //


  logic [              1:0] frfu_quad_pw_sta_00;
  logic [              1:0] frfu_quad_pw_sta_01;
  logic [              1:0] frfu_quad_pw_sta_02;
  logic [              1:0] frfu_quad_pw_sta_03;
  logic [              1:0] frfu_quad_pw_sta_10;
  logic [              1:0] frfu_quad_pw_sta_11;
  logic [              1:0] frfu_quad_pw_sta_12;
  logic [              1:0] frfu_quad_pw_sta_13;
  logic [              1:0] frfu_quad_pw_sta_20;
  logic [              1:0] frfu_quad_pw_sta_22;
  logic [              1:0] frfu_quad_pw_sta_21;
  logic [              1:0] frfu_quad_pw_sta_23;
  logic [              1:0] frfu_quad_pw_sta_30;
  logic [              1:0] frfu_quad_pw_sta_31;
  logic [              1:0] frfu_quad_pw_sta_32;
  logic [              1:0] frfu_quad_pw_sta_33;
  logic [              7:0] frfu_scratch_byte;
  logic                     frfu_fpmu_pmu_mux_sel;

  logic [PAR_ADDR_BITS-1:0] sfr_addr;
  logic [             31:0] sfr_rddata;
  logic                     sfr_sel;
  logic [             31:0] sfr_wrdata;
  logic                     sfr_write;
  logic [              6:0] fssc_frfu_rd_addr_syncff1;

  logic [              1:0] byte_cnt_cs;
  logic [              1:0] byte_cnt_ns;
  logic [             31:0] fcbrfuwff_wr_data;
  logic                     fcbrfuwff_wr_en;
  logic [              3:0] fcbrfuwff_wr_byte;
  logic                     fcbrfuwff_empty_flag;
  logic [              1:0] fcbrffwff_stm_cs;
  logic [              1:0] fcbrffwff_stm_ns;
  logic                     fcbrffwff_rd_en;


  logic                     post_cksum_en;
  logic                     pre_cksum_en;
  logic                     read_back_en;
  logic [              1:0] rd_stm_cs;
  logic [              1:0] rd_stm_ns;
  logic                     fcbrfuwff_chksum_b0_en;
  logic                     fcbrfuwff_chksum_b1_en;
  logic                     rdback_data_b0_en;
  logic                     rdback_data_b1_en;

  logic [             15:0] chksum_c0;
  logic [             15:0] chksum_c1;
  logic                     ffsr_frfu_clr_fb_cfg_kickoff_dly1cyc;
  logic                     ffsr_frfu_clr_fb_cfg_kickoff_dly2cyc;
  logic                     fssc_set_cfg_done;

  logic [              1:0] frfu_chip_pwr_Sta;

  logic                     frfu_fsmc_checksum_status_cs;
  logic                     frfu_fsmc_checksum_status_ns;

  logic                     fifo_wff_of;
  logic                     fb_cfg_cleanup;

  //logic				clr_quad_pd ;
  //logic				clr_quad_wu ;
  //
  //logic				clr_chip_pd ;
  //logic				clr_chip_vlp ;
  //logic				clr_chip_wu ;

  //--------------------------------------------------------------------------------//
  //-- Main Program Start								--//
  //--------------------------------------------------------------------------------//
  assign frfu_fpmu_fb_cfg_done = fcb_fb_cfg_done;  // JC
  assign frfu_fpmu_pmu_time_ctl = frfu_fclp_clp_time_ctl;

  assign frfu_fclp_cfg_done = fcb_fb_cfg_done;

  assign frfu_fpmu_prog_cfg_done 		= (  sfr_wrdata[0] & addr_21_wr_en ) | fsmc_frfu_set_fb_cfg_done | fssc_set_cfg_done ;
  assign frfu_fpmu_clr_cfg_done = (~sfr_wrdata[0] & addr_21_wr_en);

  assign frfu_fpmu_prog_pmu_chip_cmd	= ( addr_2f_wr_en & |(sfr_wrdata[3:0])) | fsmc_frfu_set_quad_pd | fsmc_frfu_set_pd ;	// Not IDLE

  // Ignore if program 00	and None of the Quads are enable
  //assign frfu_fpmu_prog_pmu_quad_pd_en		= addr_32_wr_en & ( sfr_wrdata[1:0] != 2'b00 ) & ( |{frfu_fpmu_quad_pd_en_b1,frfu_fpmu_quad_pd_en_b0} );
  //assign frfu_fpmu_prog_pmu_quad_wu_en		= addr_35_wr_en & ( sfr_wrdata[1:0] != 2'b00 ) & ( |{frfu_fpmu_quad_wu_en_b1,frfu_fpmu_quad_wu_en_b0} );
  //assign clr_quad_pd 				= ( frfu_fpmu_prog_pmu_quad_pd_en == 1'b0 ) & ( addr_32_wr_en == 1'b1 )  ;
  //assign clr_quad_wu 				= ( frfu_fpmu_prog_pmu_quad_pd_en == 1'b0 ) & ( addr_35_wr_en == 1'b1 )  ;
  //assign frfu_fpmu_prog_pmu_chip_vlp_en         	= ( addr_2d_wr_en | ( fmic_frfu_set_pmu_chip_vlp_en & (~fcb_clp_mode_en_bo) )) & ( fpmu_frfu_chip_pw_sta == 2'b00 ) ;
  //assign frfu_fpmu_prog_pmu_chip_pd_en		= addr_2e_wr_en & ( fpmu_frfu_chip_pw_sta == 2'b00 || fpmu_frfu_chip_pw_sta == 2'b01 ) ;
  //assign frfu_fpmu_prog_pmu_chip_wu_en 		= ( addr_2f_wr_en | ( fmic_frfu_set_pmu_chip_wu_en  & (~fcb_clp_mode_en_bo) )) & ( fpmu_frfu_chip_pw_sta != 2'b00 ) ;
  //assign clr_chip_vlp 				= ( frfu_fpmu_prog_pmu_chip_vlp_en == 1'b0 ) & ( addr_2d_wr_en == 1'b1 ) ;
  //assign clr_chip_pd 				= ( frfu_fpmu_prog_pmu_chip_pd_en  == 1'b0 ) & ( addr_2e_wr_en == 1'b1 ) ;
  //assign clr_chip_wu 				= ( frfu_fpmu_prog_pmu_chip_wu_en  == 1'b0 ) & ( addr_2f_wr_en == 1'b1 ) ;
  // ???
  //assign frfu_fsmc_pending_pd_req 	= |{frfu_fpmu_quad_cfg_b1,frfu_fpmu_quad_pd_en_b0} | ( frfu_fpmu_quad_pd_mode != 2'b00 ) ;

  assign frfu_fsmc_pending_pd_req = |frfu_fpmu_pmu_chip_cmd[3:0];

  assign frfu_fsmc_checksum_enable = post_cksum_en | pre_cksum_en;

  assign post_cksum_en 		= ( 	frfu_ffsr_fb_cfg_cmd == 8'h02 || frfu_ffsr_fb_cfg_cmd == 8'h30 )
				? 1'b1 : 1'b0 ;

  assign pre_cksum_en = (frfu_ffsr_fb_cfg_cmd == 8'h01 ||
      //                                      frfu_ffsr_fb_cfg_cmd == 8'h30 ||
      frfu_ffsr_fb_cfg_cmd == 8'h11) ? 1'b1 : 1'b0;

  assign read_back_en = (frfu_ffsr_fb_cfg_cmd == 8'h40) ? 1'b1 : 1'b0;

  //--------------------------------------------------------------------------------//
  //-- Main Program Start								--//
  //--------------------------------------------------------------------------------//
  assign fcb_fb_cfg_done = frfu_fmic_fb_cfg_done;


  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      fssc_frfu_rd_addr_syncff1 <= #PAR_DLY 'b0;
    end else begin
      fssc_frfu_rd_addr_syncff1 <= #PAR_DLY fssc_frfu_rd_addr;
    end
  end

  //----------------------------------------------------------------------------//
  //-- ICG								--//
  //----------------------------------------------------------------------------//
  assign frfu_sfr_rd_data = sfr_rddata[7:0];

  always_comb begin
    if (frwf_frfu_wr_en == 1'b1 || frwf_frfu_rd_en == 1'b1) begin
      sfr_addr = frwf_frfu_wr_addr;
      sfr_wrdata = {24'b0, frwf_frfu_wr_data};
      sfr_sel = frwf_frfu_wr_en | frwf_frfu_rd_en;
      sfr_write = frwf_frfu_wr_en;
    end else if (fssc_frfu_spis_on == 1'b1) begin
      if (fssc_frfu_wr_en == 1'b1) begin
        sfr_addr = fssc_frfu_wr_addr;
      end else begin
        sfr_addr = fssc_frfu_rd_addr_syncff1;
      end
      sfr_wrdata = {24'b0, fssc_frfu_wr_data};
      sfr_sel = 1'b1;
      sfr_write = fssc_frfu_wr_en;
    end else if (fsmc_frfu_spim_on == 1'b1) begin
      sfr_addr = fsmc_frfu_wr_addr;
      sfr_wrdata = {24'b0, fsmc_frfu_wr_data};
      sfr_sel = 1'b1;
      sfr_write = fsmc_frfu_wr_en;
    end else begin
      sfr_addr = frwf_frfu_wr_addr;
      sfr_wrdata = {24'b0, frwf_frfu_wr_data};
      sfr_sel = frwf_frfu_wr_en | frwf_frfu_rd_en;
      sfr_write = frwf_frfu_wr_en;
    end
  end
  //----------------------------------------------------------------------------//
  //-- Decoding								--//
  //----------------------------------------------------------------------------// 
  always_comb begin
    addr_00_wr_en = 0;
    addr_00_rd_en = 0;
    addr_01_wr_en = 0;
    addr_01_rd_en = 0;
    addr_02_wr_en = 0;
    addr_02_rd_en = 0;
    addr_03_wr_en = 0;
    addr_03_rd_en = 0;
    addr_04_wr_en = 0;
    addr_04_rd_en = 0;
    addr_05_wr_en = 0;
    addr_05_rd_en = 0;
    addr_06_wr_en = 0;
    addr_06_rd_en = 0;
    addr_07_wr_en = 0;
    addr_07_rd_en = 0;
    addr_08_wr_en = 0;
    addr_08_rd_en = 0;
    addr_09_wr_en = 0;
    addr_09_rd_en = 0;
    addr_0a_wr_en = 0;
    addr_0a_rd_en = 0;
    addr_0b_wr_en = 0;
    addr_0b_rd_en = 0;
    addr_0c_wr_en = 0;
    addr_0c_rd_en = 0;
    addr_0d_wr_en = 0;
    addr_0d_rd_en = 0;
    addr_0e_wr_en = 0;
    addr_0e_rd_en = 0;
    addr_0f_wr_en = 0;
    addr_0f_rd_en = 0;
    addr_10_wr_en = 0;
    addr_10_rd_en = 0;
    addr_11_wr_en = 0;
    addr_11_rd_en = 0;
    addr_12_wr_en = 0;
    addr_12_rd_en = 0;
    addr_13_wr_en = 0;
    addr_13_rd_en = 0;
    addr_14_wr_en = 0;
    addr_14_rd_en = 0;
    addr_15_wr_en = 0;
    addr_15_rd_en = 0;
    addr_16_wr_en = 0;
    addr_16_rd_en = 0;
    addr_17_wr_en = 0;
    addr_17_rd_en = 0;
    addr_18_wr_en = 0;
    addr_18_rd_en = 0;
    addr_19_wr_en = 0;
    addr_19_rd_en = 0;
    addr_1a_wr_en = 0;
    addr_1a_rd_en = 0;
    addr_1b_wr_en = 0;
    addr_1b_rd_en = 0;
    addr_1c_wr_en = 0;
    addr_1c_rd_en = 0;
    addr_1d_wr_en = 0;
    addr_1d_rd_en = 0;
    addr_1e_wr_en = 0;
    addr_1e_rd_en = 0;
    addr_1f_wr_en = 0;
    addr_1f_rd_en = 0;
    addr_20_wr_en = 0;
    addr_20_rd_en = 0;
    addr_21_wr_en = 0;
    addr_21_rd_en = 0;
    addr_30_wr_en = 0;
    addr_30_rd_en = 0;
    addr_31_wr_en = 0;
    addr_31_rd_en = 0;
    addr_32_wr_en = 0;
    addr_32_rd_en = 0;
    addr_33_wr_en = 0;
    addr_33_rd_en = 0;
    addr_34_wr_en = 0;
    addr_34_rd_en = 0;
    addr_35_wr_en = 0;
    addr_35_rd_en = 0;
    addr_36_wr_en = 0;
    addr_36_rd_en = 0;
    addr_37_wr_en = 0;
    addr_37_rd_en = 0;
    addr_38_wr_en = 0;
    addr_38_rd_en = 0;
    addr_39_wr_en = 0;
    addr_39_rd_en = 0;
    addr_3a_wr_en = 0;
    addr_3a_rd_en = 0;
    addr_3b_wr_en = 0;
    addr_3b_rd_en = 0;
    addr_3c_wr_en = 0;
    addr_3c_rd_en = 0;
    addr_3d_wr_en = 0;
    addr_3d_rd_en = 0;
    addr_3e_wr_en = 0;
    addr_3e_rd_en = 0;
    addr_40_wr_en = 0;
    addr_40_rd_en = 0;
    addr_41_wr_en = 0;
    addr_41_rd_en = 0;
    addr_42_wr_en = 0;
    addr_42_rd_en = 0;
    addr_43_wr_en = 0;
    addr_43_rd_en = 0;
    addr_44_wr_en = 0;
    addr_44_rd_en = 0;
    addr_45_wr_en = 0;
    addr_45_rd_en = 0;
    addr_46_wr_en = 0;
    addr_46_rd_en = 0;
    addr_47_wr_en = 0;
    addr_47_rd_en = 0;
    addr_48_wr_en = 0;
    addr_48_rd_en = 0;
    addr_49_wr_en = 0;
    addr_49_rd_en = 0;
    addr_4a_wr_en = 0;
    addr_4a_rd_en = 0;
    addr_4b_wr_en = 0;
    addr_4b_rd_en = 0;
    addr_4c_wr_en = 0;
    addr_4c_rd_en = 0;
    addr_4d_wr_en = 0;
    addr_4d_rd_en = 0;
    addr_4e_wr_en = 0;
    addr_4e_rd_en = 0;
    addr_4f_wr_en = 0;
    addr_4f_rd_en = 0;
    addr_50_wr_en = 0;
    addr_50_rd_en = 0;
    addr_51_wr_en = 0;
    addr_51_rd_en = 0;
    addr_52_wr_en = 0;
    addr_52_rd_en = 0;
    addr_53_wr_en = 0;
    addr_53_rd_en = 0;
    addr_54_wr_en = 0;
    addr_54_rd_en = 0;
    addr_55_wr_en = 0;
    addr_55_rd_en = 0;
    addr_56_wr_en = 0;
    addr_56_rd_en = 0;
    addr_57_wr_en = 0;
    addr_57_rd_en = 0;
    addr_58_wr_en = 0;
    addr_58_rd_en = 0;
    addr_59_wr_en = 0;
    addr_59_rd_en = 0;
    addr_5a_wr_en = 0;
    addr_5a_rd_en = 0;
    addr_5b_wr_en = 0;
    addr_5b_rd_en = 0;
    addr_5c_wr_en = 0;
    addr_5c_rd_en = 0;
    addr_5d_wr_en = 0;
    addr_5d_rd_en = 0;
    addr_5e_wr_en = 0;
    addr_5e_rd_en = 0;
    addr_60_wr_en = 0;
    addr_60_rd_en = 0;
    addr_61_wr_en = 0;
    addr_61_rd_en = 0;
    addr_62_wr_en = 0;
    addr_62_rd_en = 0;
    addr_27_wr_en = 0;
    addr_27_rd_en = 0;
    addr_28_wr_en = 0;
    addr_28_rd_en = 0;
    addr_29_wr_en = 0;
    addr_29_rd_en = 0;
    addr_2a_wr_en = 0;
    addr_2a_rd_en = 0;
    addr_2b_wr_en = 0;
    addr_2b_rd_en = 0;
    addr_2c_wr_en = 0;
    addr_2c_rd_en = 0;
    addr_2d_wr_en = 0;
    addr_2d_rd_en = 0;
    addr_2e_wr_en = 0;
    addr_2e_rd_en = 0;
    addr_2f_wr_en = 0;
    addr_2f_rd_en = 0;

    case (sfr_addr)
      'h00: begin
        addr_00_wr_en = sfr_sel & sfr_write;
        addr_00_rd_en = sfr_sel & (~sfr_write);
      end
      'h01: begin
        addr_01_wr_en = sfr_sel & sfr_write;
        addr_01_rd_en = sfr_sel & (~sfr_write);
      end
      'h02: begin
        addr_02_wr_en = sfr_sel & sfr_write;
        addr_02_rd_en = sfr_sel & (~sfr_write);
      end
      'h03: begin
        addr_03_wr_en = sfr_sel & sfr_write;
        addr_03_rd_en = sfr_sel & (~sfr_write);
      end
      'h04: begin
        addr_04_wr_en = sfr_sel & sfr_write;
        addr_04_rd_en = sfr_sel & (~sfr_write);
      end
      'h05: begin
        addr_05_wr_en = sfr_sel & sfr_write;
        addr_05_rd_en = sfr_sel & (~sfr_write);
      end
      'h06: begin
        addr_06_wr_en = sfr_sel & sfr_write;
        addr_06_rd_en = sfr_sel & (~sfr_write);
      end
      'h07: begin
        addr_07_wr_en = sfr_sel & sfr_write;
        addr_07_rd_en = sfr_sel & (~sfr_write);
      end
      'h08: begin
        addr_08_wr_en = sfr_sel & sfr_write;
        addr_08_rd_en = sfr_sel & (~sfr_write);
      end
      'h09: begin
        addr_09_wr_en = sfr_sel & sfr_write;
        addr_09_rd_en = sfr_sel & (~sfr_write);
      end
      'h0a: begin
        addr_0a_wr_en = sfr_sel & sfr_write;
        addr_0a_rd_en = sfr_sel & (~sfr_write);
      end
      'h0b: begin
        addr_0b_wr_en = sfr_sel & sfr_write;
        addr_0b_rd_en = sfr_sel & (~sfr_write);
      end
      'h0c: begin
        addr_0c_wr_en = sfr_sel & sfr_write;
        addr_0c_rd_en = sfr_sel & (~sfr_write);
      end
      'h0d: begin
        addr_0d_wr_en = sfr_sel & sfr_write;
        addr_0d_rd_en = sfr_sel & (~sfr_write);
      end
      'h0e: begin
        addr_0e_wr_en = sfr_sel & sfr_write;
        addr_0e_rd_en = sfr_sel & (~sfr_write);
      end
      'h0f: begin
        addr_0f_wr_en = sfr_sel & sfr_write;
        addr_0f_rd_en = sfr_sel & (~sfr_write);
      end
      'h10: begin
        addr_10_wr_en = sfr_sel & sfr_write;
        addr_10_rd_en = sfr_sel & (~sfr_write);
      end
      'h11: begin
        addr_11_wr_en = sfr_sel & sfr_write;
        addr_11_rd_en = sfr_sel & (~sfr_write);
      end
      'h12: begin
        addr_12_wr_en = sfr_sel & sfr_write;
        addr_12_rd_en = sfr_sel & (~sfr_write);
      end
      'h13: begin
        addr_13_wr_en = sfr_sel & sfr_write;
        addr_13_rd_en = sfr_sel & (~sfr_write);
      end
      'h14: begin
        addr_14_wr_en = sfr_sel & sfr_write;
        addr_14_rd_en = sfr_sel & (~sfr_write);
      end
      'h15: begin
        addr_15_wr_en = sfr_sel & sfr_write;
        addr_15_rd_en = sfr_sel & (~sfr_write);
      end
      'h16: begin
        addr_16_wr_en = sfr_sel & sfr_write;
        addr_16_rd_en = sfr_sel & (~sfr_write);
      end
      'h17: begin
        addr_17_wr_en = sfr_sel & sfr_write;
        addr_17_rd_en = sfr_sel & (~sfr_write);
      end
      'h18: begin
        addr_18_wr_en = sfr_sel & sfr_write;
        addr_18_rd_en = sfr_sel & (~sfr_write);
      end
      'h19: begin
        addr_19_wr_en = sfr_sel & sfr_write;
        addr_19_rd_en = sfr_sel & (~sfr_write);
      end
      'h1a: begin
        addr_1a_wr_en = sfr_sel & sfr_write;
        addr_1a_rd_en = sfr_sel & (~sfr_write);
      end
      'h1b: begin
        addr_1b_wr_en = sfr_sel & sfr_write;
        addr_1b_rd_en = sfr_sel & (~sfr_write);
      end
      'h1c: begin
        addr_1c_wr_en = sfr_sel & sfr_write;
        addr_1c_rd_en = sfr_sel & (~sfr_write);
      end
      'h1d: begin
        addr_1d_wr_en = sfr_sel & sfr_write;
        addr_1d_rd_en = sfr_sel & (~sfr_write);
      end
      'h1e: begin
        addr_1e_wr_en = sfr_sel & sfr_write;
        addr_1e_rd_en = sfr_sel & (~sfr_write);
      end
      'h1f: begin
        addr_1f_wr_en = sfr_sel & sfr_write;
        addr_1f_rd_en = sfr_sel & (~sfr_write);
      end
      'h20: begin
        addr_20_wr_en = sfr_sel & sfr_write;
        addr_20_rd_en = sfr_sel & (~sfr_write);
      end
      'h21: begin
        addr_21_wr_en = sfr_sel & sfr_write;
        addr_21_rd_en = sfr_sel & (~sfr_write);
      end
      'h30: begin
        addr_30_wr_en = sfr_sel & sfr_write;
        addr_30_rd_en = sfr_sel & (~sfr_write);
      end
      'h31: begin
        addr_31_wr_en = sfr_sel & sfr_write;
        addr_31_rd_en = sfr_sel & (~sfr_write);
      end
      'h32: begin
        addr_32_wr_en = sfr_sel & sfr_write;
        addr_32_rd_en = sfr_sel & (~sfr_write);
      end
      'h33: begin
        addr_33_wr_en = sfr_sel & sfr_write;
        addr_33_rd_en = sfr_sel & (~sfr_write);
      end
      'h34: begin
        addr_34_wr_en = sfr_sel & sfr_write;
        addr_34_rd_en = sfr_sel & (~sfr_write);
      end
      'h35: begin
        addr_35_wr_en = sfr_sel & sfr_write;
        addr_35_rd_en = sfr_sel & (~sfr_write);
      end
      'h36: begin
        addr_36_wr_en = sfr_sel & sfr_write;
        addr_36_rd_en = sfr_sel & (~sfr_write);
      end
      'h37: begin
        addr_37_wr_en = sfr_sel & sfr_write;
        addr_37_rd_en = sfr_sel & (~sfr_write);
      end
      'h38: begin
        addr_38_wr_en = sfr_sel & sfr_write;
        addr_38_rd_en = sfr_sel & (~sfr_write);
      end
      'h39: begin
        addr_39_wr_en = sfr_sel & sfr_write;
        addr_39_rd_en = sfr_sel & (~sfr_write);
      end
      'h3a: begin
        addr_3a_wr_en = sfr_sel & sfr_write;
        addr_3a_rd_en = sfr_sel & (~sfr_write);
      end
      'h3b: begin
        addr_3b_wr_en = sfr_sel & sfr_write;
        addr_3b_rd_en = sfr_sel & (~sfr_write);
      end
      'h3c: begin
        addr_3c_wr_en = sfr_sel & sfr_write;
        addr_3c_rd_en = sfr_sel & (~sfr_write);
      end
      'h3d: begin
        addr_3d_wr_en = sfr_sel & sfr_write;
        addr_3d_rd_en = sfr_sel & (~sfr_write);
      end
      'h3e: begin
        addr_3e_wr_en = sfr_sel & sfr_write;
        addr_3e_rd_en = sfr_sel & (~sfr_write);
      end
      'h40: begin
        addr_40_wr_en = sfr_sel & sfr_write;
        addr_40_rd_en = sfr_sel & (~sfr_write);
      end
      'h41: begin
        addr_41_wr_en = sfr_sel & sfr_write;
        addr_41_rd_en = sfr_sel & (~sfr_write);
      end
      'h42: begin
        addr_42_wr_en = sfr_sel & sfr_write;
        addr_42_rd_en = sfr_sel & (~sfr_write);
      end
      'h43: begin
        addr_43_wr_en = sfr_sel & sfr_write;
        addr_43_rd_en = sfr_sel & (~sfr_write);
      end
      'h44: begin
        addr_44_wr_en = sfr_sel & sfr_write;
        addr_44_rd_en = sfr_sel & (~sfr_write);
      end
      'h45: begin
        addr_45_wr_en = sfr_sel & sfr_write;
        addr_45_rd_en = sfr_sel & (~sfr_write);
      end
      'h46: begin
        addr_46_wr_en = sfr_sel & sfr_write;
        addr_46_rd_en = sfr_sel & (~sfr_write);
      end
      'h47: begin
        addr_47_wr_en = sfr_sel & sfr_write;
        addr_47_rd_en = sfr_sel & (~sfr_write);
      end
      'h48: begin
        addr_48_wr_en = sfr_sel & sfr_write;
        addr_48_rd_en = sfr_sel & (~sfr_write);
      end
      'h49: begin
        addr_49_wr_en = sfr_sel & sfr_write;
        addr_49_rd_en = sfr_sel & (~sfr_write);
      end
      'h4a: begin
        addr_4a_wr_en = sfr_sel & sfr_write;
        addr_4a_rd_en = sfr_sel & (~sfr_write);
      end
      'h4b: begin
        addr_4b_wr_en = sfr_sel & sfr_write;
        addr_4b_rd_en = sfr_sel & (~sfr_write);
      end
      'h4c: begin
        addr_4c_wr_en = sfr_sel & sfr_write;
        addr_4c_rd_en = sfr_sel & (~sfr_write);
      end
      'h4d: begin
        addr_4d_wr_en = sfr_sel & sfr_write;
        addr_4d_rd_en = sfr_sel & (~sfr_write);
      end
      'h4e: begin
        addr_4e_wr_en = sfr_sel & sfr_write;
        addr_4e_rd_en = sfr_sel & (~sfr_write);
      end
      'h4f: begin
        addr_4f_wr_en = sfr_sel & sfr_write;
        addr_4f_rd_en = sfr_sel & (~sfr_write);
      end
      'h50: begin
        addr_50_wr_en = sfr_sel & sfr_write;
        addr_50_rd_en = sfr_sel & (~sfr_write);
      end
      'h51: begin
        addr_51_wr_en = sfr_sel & sfr_write;
        addr_51_rd_en = sfr_sel & (~sfr_write);
      end
      'h52: begin
        addr_52_wr_en = sfr_sel & sfr_write;
        addr_52_rd_en = sfr_sel & (~sfr_write);
      end
      'h53: begin
        addr_53_wr_en = sfr_sel & sfr_write;
        addr_53_rd_en = sfr_sel & (~sfr_write);
      end
      'h54: begin
        addr_54_wr_en = sfr_sel & sfr_write;
        addr_54_rd_en = sfr_sel & (~sfr_write);
      end
      'h55: begin
        addr_55_wr_en = sfr_sel & sfr_write;
        addr_55_rd_en = sfr_sel & (~sfr_write);
      end
      'h56: begin
        addr_56_wr_en = sfr_sel & sfr_write;
        addr_56_rd_en = sfr_sel & (~sfr_write);
      end
      'h57: begin
        addr_57_wr_en = sfr_sel & sfr_write;
        addr_57_rd_en = sfr_sel & (~sfr_write);
      end
      'h58: begin
        addr_58_wr_en = sfr_sel & sfr_write;
        addr_58_rd_en = sfr_sel & (~sfr_write);
      end
      'h59: begin
        addr_59_wr_en = sfr_sel & sfr_write;
        addr_59_rd_en = sfr_sel & (~sfr_write);
      end
      'h5a: begin
        addr_5a_wr_en = sfr_sel & sfr_write;
        addr_5a_rd_en = sfr_sel & (~sfr_write);
      end
      'h5b: begin
        addr_5b_wr_en = sfr_sel & sfr_write;
        addr_5b_rd_en = sfr_sel & (~sfr_write);
      end
      'h5c: begin
        addr_5c_wr_en = sfr_sel & sfr_write;
        addr_5c_rd_en = sfr_sel & (~sfr_write);
      end
      'h5d: begin
        addr_5d_wr_en = sfr_sel & sfr_write;
        addr_5d_rd_en = sfr_sel & (~sfr_write);
      end
      'h5e: begin
        addr_5e_wr_en = sfr_sel & sfr_write;
        addr_5e_rd_en = sfr_sel & (~sfr_write);
      end
      'h60: begin
        addr_60_wr_en = sfr_sel & sfr_write;
        addr_60_rd_en = sfr_sel & (~sfr_write);
      end
      'h61: begin
        addr_61_wr_en = sfr_sel & sfr_write;
        addr_61_rd_en = sfr_sel & (~sfr_write);
      end
      'h62: begin
        addr_62_wr_en = sfr_sel & sfr_write;
        addr_62_rd_en = sfr_sel & (~sfr_write);
      end
      'h27: begin
        addr_27_wr_en = sfr_sel & sfr_write;
        addr_27_rd_en = sfr_sel & (~sfr_write);
      end
      'h28: begin
        addr_28_wr_en = sfr_sel & sfr_write;
        addr_28_rd_en = sfr_sel & (~sfr_write);
      end
      'h29: begin
        addr_29_wr_en = sfr_sel & sfr_write;
        addr_29_rd_en = sfr_sel & (~sfr_write);
      end
      'h2a: begin
        addr_2a_wr_en = sfr_sel & sfr_write;
        addr_2a_rd_en = sfr_sel & (~sfr_write);
      end
      'h2b: begin
        addr_2b_wr_en = sfr_sel & sfr_write;
        addr_2b_rd_en = sfr_sel & (~sfr_write);
      end
      'h2c: begin
        addr_2c_wr_en = sfr_sel & sfr_write;
        addr_2c_rd_en = sfr_sel & (~sfr_write);
      end
      'h2d :	//JC
      begin
        addr_2d_wr_en = sfr_sel & sfr_write;
        addr_2d_rd_en = sfr_sel & (~sfr_write);
      end
      'h2e :	//JC
      begin
        addr_2e_wr_en = sfr_sel & sfr_write;
        addr_2e_rd_en = sfr_sel & (~sfr_write);
      end
      'h2f :	//JC
      begin
        addr_2f_wr_en = sfr_sel & sfr_write;
        addr_2f_rd_en = sfr_sel & (~sfr_write);
      end
      default: begin
      end
    endcase
  end

  //----------------------------------------------------------------------------//
  //-- READ BACK DATA															--//
  //----------------------------------------------------------------------------// 
  assign sfr_rddata = (({
    24'h0, {frfu_fsmc_spim_ckb_0}
  } & {32{addr_00_rd_en}}) | ({
    24'h0, {frfu_fsmc_spim_ckb_1}
  } & {32{addr_01_rd_en}}) | ({
    24'h0, {frfu_fsmc_spim_device_id}
  } & {32{addr_02_rd_en}}) | ({
    31'h0, {frfu_fsmc_checksum_status}
  } & {32{addr_03_rd_en}}) |
  //( {24'h0 , { frfu_fclp_clp_time_ctl }, { frfu_fmic_vlp_pin_en } ,{ frfu_fmic_done_op_mask_n } ,{ frfu_fmic_io_sv_180 } }  & {32{ addr_04_rd_en } })  | 
  ({
    24'h0, {frfu_fclp_clp_time_ctl}, {1'b0}, {frfu_fmic_done_op_mask_n}, {frfu_fmic_io_sv_180}
  } & {32{addr_04_rd_en}}) | ({
    30'h0, {frfu_fsmc_rc_clk_dis_cfg}, {frfu_fsmc_sw2_spis}
  } & {32{addr_05_rd_en}}) | ({
    24'h0, {frfu_fsmc_spim_baud_rate}
  } & {32{addr_06_rd_en}}) | ({
    26'h0, {frfu_ffsr_wlen_sut, frfu_ffsr_wlclk_sut, frfu_ffsr_blclk_sut}
  } & {32{addr_07_rd_en}}) |  // JC 07
  ({
    24'h0, {frfu_bl_pw_cfg_0}
  } & {32{addr_08_rd_en}}) | ({
    24'h0, {frfu_bl_pw_cfg_1}
  } & {32{addr_09_rd_en}}) | ({
    24'h0, {frfu_wl_pw_cfg}
  } & {32{addr_0a_rd_en}}) | ({
    24'h0, {frfu_ffsr_ram_cfg_0_en}
  } & {32{addr_0b_rd_en}}) | ({
    24'h0, {frfu_ffsr_ram_cfg_1_en}
  } & {32{addr_0c_rd_en}}) | ({
    24'h0, {frfu_wrd_cnt_b0}
  } & {32{addr_0d_rd_en}}) | ({
    24'h0, {frfu_wrd_cnt_b1}
  } & {32{addr_0e_rd_en}}) | ({
    24'h0, {frfu_wrd_cnt_b2}
  } & {32{addr_0f_rd_en}}) | ({
    24'h0, {frfu_ffsr_bl_cnt_l}
  } & {32{addr_10_rd_en}}) | ({
    24'h0, {frfu_ffsr_bl_cnt_h}
  } & {32{addr_11_rd_en}}) | ({
    24'h0, {frfu_ffsr_wl_cnt_l}
  } & {32{addr_12_rd_en}}) | ({
    24'h0, {frfu_ffsr_wl_cnt_h}
  } & {32{addr_13_rd_en}}) | ({
    24'h0, {frfu_ffsr_col_cnt}
  } & {32{addr_14_rd_en}}) | ({
    24'h0, {frfu_ffsr_ram_size_b0}
  } & {32{addr_15_rd_en}}) | ({
    24'h0, {frfu_ffsr_ram_size_b1}
  } & {32{addr_16_rd_en}}) | ({
    24'h0, {frfu_ffsr_ram_data_width}
  } & {32{addr_17_rd_en}}) | ({
    24'h0, {frfu_ffsr_rcfg_wrp_ccnt, frfu_ffsr_cfg_wrp_ccnt}
  } & {32{addr_18_rd_en}}) | ({
    24'h0, {frfu_scratch_byte}
  } & {32{addr_19_rd_en}}) | ({
    24'h0, {frfu_csum_w0_b0}
  } & {32{addr_1a_rd_en}}) | ({
    24'h0, {frfu_csum_w0_b1}
  } & {32{addr_1b_rd_en}}) | ({
    24'h0, {frfu_csum_w1_b0}
  } & {32{addr_1c_rd_en}}) | ({
    24'h0, {frfu_csum_w1_b1}
  } & {32{addr_1d_rd_en}}) | ({
    24'h0, {frfu_ffsr_fb_cfg_cmd}
  } & {32{addr_1e_rd_en}}) | ({
    31'h0, {frfu_ffsr_fb_cfg_kickoff}
  } & {32{addr_1f_rd_en}}) |
  //( {24'h0 , { frfu_wr_data_port } } 	 & 	{32{ addr_20_rd_en } })  | 
  ({
    24'h0, {8'h00}
  } & {32{addr_20_rd_en}}) | ({
    30'h0, {fb_cfg_cleanup, frfu_fmic_fb_cfg_done}
  } & {32{addr_21_rd_en}}) | ({
    24'h0, {frfu_fpmu_quad_cfg_b0}
  } & {32{addr_30_rd_en}}) | ({
    24'h0, {frfu_fpmu_quad_cfg_b1}
  } & {32{addr_31_rd_en}}) |
  //( {30'h0 , { frfu_fpmu_quad_pd_mode } } 	 & 	{32{ addr_32_rd_en } })  | //JC
  //( {24'h0 , { frfu_fpmu_quad_wu_en_b0 } } 	 & 	{32{ addr_33_rd_en } })  | 
  //( {24'h0 , { frfu_fpmu_quad_wu_en_b1 } } 	 & 	{32{ addr_34_rd_en } })  | 
  //( {30'h0 , { frfu_fpmu_quad_wu_mode } } 	 & 	{32{ addr_35_rd_en } })  | //JC
  ({
    24'h0,
    {frfu_quad_pw_sta_03},
    {frfu_quad_pw_sta_02},
    {frfu_quad_pw_sta_01},
    {frfu_quad_pw_sta_00}
  } & {32{addr_36_rd_en}}) | ({
    24'h0,
    {frfu_quad_pw_sta_13},
    {frfu_quad_pw_sta_12},
    {frfu_quad_pw_sta_11},
    {frfu_quad_pw_sta_10}
  } & {32{addr_37_rd_en}}) | ({
    24'h0,
    {frfu_quad_pw_sta_23},
    {frfu_quad_pw_sta_22},
    {frfu_quad_pw_sta_21},
    {frfu_quad_pw_sta_20}
  } & {32{addr_38_rd_en}}) | ({
    24'h0,
    {frfu_quad_pw_sta_33},
    {frfu_quad_pw_sta_32},
    {frfu_quad_pw_sta_31},
    {frfu_quad_pw_sta_30}
  } & {32{addr_39_rd_en}}) | ({
    24'h0, {frfu_fpmu_pmu_timer_ccnt}
  } & {32{addr_3a_rd_en}}) | ({
    26'h0, {frfu_fpmu_pmu_pwr_gate_ccnt}
  } & {32{addr_3b_rd_en}}) |
  //( {31'h0 , { frfu_fpmu_pmu_chip_vlp_wu_en } }  & 	{32{ addr_3c_rd_en } })  |  // JC
  //( {30'h0 , { fpmu_frfu_chip_pw_sta } }  & 	{32{ addr_3c_rd_en } })  |  // JC 05232017
  //( {31'h0 , { frfu_fpmu_pmu_chip_vlp_en } } 	 & 	{32{ addr_3d_rd_en } })  |  // JC
  //( {32'h0 } 	 				 & 	{32{ addr_3c_rd_en } })  |  // JC
  ({
    32'h0
  } & {32{addr_3d_rd_en}}) |  // JC
  ({
    30'h0, {frfu_fpmu_vlp_pin_value}, {fpmu_frfu_pmu_busy}
  } & {32{addr_3e_rd_en}}) | ({
    24'h0, {frfu_fpmu_iso_en_0}
  } & {32{addr_40_rd_en}}) | ({
    24'h0, {frfu_fpmu_iso_en_1}
  } & {32{addr_41_rd_en}}) | ({
    24'h0, {frfu_fpmu_pi_pwr_0}
  } & {32{addr_42_rd_en}}) | ({
    24'h0, {frfu_fpmu_pi_pwr_1}
  } & {32{addr_43_rd_en}}) |
  //( {24'h0 , { frfu_fpmu_vlp_0 } } 	 & 	{32{ addr_44_rd_en } })  | 
  //( {24'h0 , { frfu_fpmu_vlp_1 } } 	 & 	{32{ addr_45_rd_en } })  | 
  ({
    24'h0, {frfu_fpmu_vlp_clkdis_0}
  } & {32{addr_46_rd_en}}) | ({
    24'h0, {frfu_fpmu_vlp_clkdis_1}
  } & {32{addr_47_rd_en}}) | ({
    24'h0, {frfu_fpmu_vlp_srdis_0}
  } & {32{addr_48_rd_en}}) | ({
    24'h0, {frfu_fpmu_vlp_srdis_1}
  } & {32{addr_49_rd_en}}) | ({
    24'h0, {frfu_fpmu_vlp_pwrdis_0}
  } & {32{addr_4a_rd_en}}) | ({
    24'h0, {frfu_fpmu_vlp_pwrdis_1}
  } & {32{addr_4b_rd_en}}) | ({
    24'h0,
    {frfu_fpmu_set_por},
    {frfu_fpmu_prog_ifx},
    {frfu_fpmu_pwr_gate},
    {frfu_fpmu_fb_iso_enb},
    {frfu_fpmu_vlp_pwrdis_ifx},
    {frfu_fpmu_vlp_srdis_ifx},
    {frfu_fpmu_vlp_clkdis_ifx},
    {frfu_fpmu_vlp_ifx}
  } & {32{addr_4c_rd_en}}) | ({
    31'h0, {frfu_fpmu_prog_0}
  } & {32{addr_4d_rd_en}}) | ({
    31'h0, {frfu_fpmu_prog_1}
  } & {32{addr_4e_rd_en}}) | ({
    31'h0, {frfu_fpmu_up_sd}
  } & {32{addr_4f_rd_en}}) | ({
    24'h0, {frfu_fpmu_iso_en_sd_0}
  } & {32{addr_50_rd_en}}) | ({
    24'h0, {frfu_fpmu_iso_en_sd_1}
  } & {32{addr_51_rd_en}}) | ({
    24'h0, {frfu_fpmu_pi_pwr_sd_0}
  } & {32{addr_52_rd_en}}) | ({
    24'h0, {frfu_fpmu_pi_pwr_sd_1}
  } & {32{addr_53_rd_en}}) |
  //( {24'h0 , { frfu_fpmu_vlp_sd_0 } } 	 & 	{32{ addr_54_rd_en } })  | 
  //( {24'h0 , { frfu_fpmu_vlp_sd_1 } } 	 & 	{32{ addr_55_rd_en } })  | 
  ({
    24'h0, {frfu_fpmu_vlp_clkdis_sd_0}
  } & {32{addr_56_rd_en}}) | ({
    24'h0, {frfu_fpmu_vlp_clkdis_sd_1}
  } & {32{addr_57_rd_en}}) | ({
    24'h0, {frfu_fpmu_vlp_srdis_sd_0}
  } & {32{addr_58_rd_en}}) | ({
    24'h0, {frfu_fpmu_vlp_srdis_sd_1}
  } & {32{addr_59_rd_en}}) | ({
    24'h0, {frfu_fpmu_vlp_pwrdis_sd_0}
  } & {32{addr_5a_rd_en}}) | ({
    24'h0, {frfu_fpmu_vlp_pwrdis_sd_1}
  } & {32{addr_5b_rd_en}}) | ({
    24'h0,
    {frfu_fpmu_set_por_sd},
    {frfu_fpmu_prog_ifx_sd},
    {frfu_fpmu_pwr_gate_sd},
    {frfu_fpmu_fb_iso_enb_sd},
    {frfu_fpmu_vlp_pwrdis_ifx_sd},
    {frfu_fpmu_vlp_srdis_ifx_sd},
    {frfu_fpmu_vlp_clkdis_ifx_sd},
    {frfu_fpmu_vlp_ifx_sd}
  } & {32{addr_5c_rd_en}}) | ({
    31'h0, {frfu_fpmu_prog_sd_0}
  } & {32{addr_5d_rd_en}}) | ({
    31'h0, {frfu_fpmu_prog_sd_1}
  } & {32{addr_5e_rd_en}}) | ({
    31'h0, {frfu_fpmu_pmu_mux_sel}
  } & {32{addr_60_rd_en}}) | ({
    31'h0, {frfu_fpmu_pmu_mux_up_sd}
  } & {32{addr_61_rd_en}}) | ({
    31'h0, {frfu_fpmu_pmu_mux_sel_sd}
  } & {32{addr_62_rd_en}}) | ({
    29'h0, {fcbrfuwff_empty_flag, frfu_cwf_full, fifo_wff_of}
  } & {32{addr_27_rd_en}}) | ({
    31'h0, {frfu_fclp_clp_vlp_wu_en}
  } & {32{addr_28_rd_en}}) | ({
    31'h0, {frfu_fclp_clp_vlp_en}
  } & {32{addr_29_rd_en}}) | ({
    31'h0, {frfu_fclp_clp_pd_wu_en}
  } & {32{addr_2a_rd_en}}) | ({
    31'h0, {frfu_fclp_clp_pd_en}
  } & {32{addr_2b_rd_en}}) |
  //( {31'h0 , {frfu_fpmu_pmu_chip_vlp_en }    &    {32{ addr_2d_rd_en } })  |				//JC
  //( {31'h0 , {frfu_fpmu_pmu_chip_pd_en }     &    {32{ addr_2e_rd_en } })  |				//JC
  ({
    28'h0, {frfu_fpmu_pmu_chip_cmd}
  } & {32{addr_2f_rd_en}}) |  //JC
  ({
    30'h0, {frfu_chip_pwr_Sta}
  } & {32{addr_2c_rd_en}}));


  assign fb_cfg_cleanup = ( fcb_clp_mode_en_bo == 1'b1 )
		      ? fclp_frfu_fb_cfg_cleanup : fpmu_frfu_fb_cfg_cleanup ;

  //========================================================//
  //==	REG 0x00										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 7:0							==//
  //====================================================//
  assign frfu_fsmc_spim_ckb_0 = 8'ha5;
  //========================================================//
  //==	REG 0x01										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 7:0							==//
  //====================================================//
  assign frfu_fsmc_spim_ckb_1 = 8'h5a;
  //========================================================//
  //==	REG 0x02										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 7:0								==//
  //====================================================//
  assign frfu_fsmc_spim_device_id = fcb_device_id_bo;
  //========================================================//
  //==	REG 0x03										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 0								==//
  //====================================================//
  always @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      frfu_fsmc_checksum_status_cs <= #PAR_DLY 1'b0;
    end else if (ffsr_frfu_clr_fb_cfg_kickoff == 1'b1) begin
      frfu_fsmc_checksum_status_cs <= #PAR_DLY frfu_fsmc_checksum_status_ns;
    end
  end

  assign frfu_fsmc_checksum_status = frfu_fsmc_checksum_status_cs;

  assign frfu_fsmc_checksum_status_ns = ~(|(chksum_c0 +{
    frfu_csum_w0_b1, frfu_csum_w0_b0
  } +{
    frfu_csum_w1_b1, frfu_csum_w1_b0
  }) || |(chksum_c1 -{
    frfu_csum_w1_b1, frfu_csum_w1_b0
  }));

  //========================================================//
  //==	REG 0x04										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{2'h1}, {1'h0}, {1'h0}, {4'h0}})
  ) qf_rw_INST_04 (
      .sys_clk(fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata(sfr_wrdata[7:0]),
      .wr_en(addr_04_wr_en),
      .rddata({
        {frfu_fclp_clp_time_ctl},
        {frfu_fmic_vlp_pin_en},
        {frfu_fmic_done_op_mask_n},
        {frfu_fmic_io_sv_180}
      })
  );
  //========================================================//
  //==	REG 0x05										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(2),
      .PAR_DEFAULT_VALUE({{1'h0}, {1'h0}})
  ) qf_rw_INST_05 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[1:0]),
      .wr_en    (addr_05_wr_en),
      .rddata   ({{frfu_fsmc_rc_clk_dis_cfg}, {frfu_fsmc_sw2_spis}})
  );
  //========================================================//
  //==	REG 0x06										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h1f}})
  ) qf_rw_INST_06 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_06_wr_en),
      .rddata   ({{frfu_fsmc_spim_baud_rate}})
  );
  //========================================================//
  //==	REG 0x07										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 0								==//
  //====================================================//
  assign frfu_fmic_rc_clk_en = 1'b1;

  qf_rwhwsc  // R_W_HS
  #(
      .PAR_BIT_WIDTH(6),
      .PAR_DEFAULT_VALUE(6'h00)
  ) qf_rwhwsc_INST_07_0 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wr_en (1'b0),
      .hw_wrdata(6'h00),
      .wrdata   (sfr_wrdata[5:0]),
      .wr_en    (addr_07_wr_en),
      .rddata   ({frfu_ffsr_wlen_sut[1:0], frfu_ffsr_wlclk_sut[1:0], frfu_ffsr_blclk_sut[1:0]})
  );

  //qf_rwhwsc 			// R_W_HS
  //# (
  //.PAR_BIT_WIDTH		( 1 ),
  //.PAR_DEFAULT_VALUE	( 1'h1 )
  //)
  //qf_rwhwsc_INST_07_0
  //(
  //.sys_clk			( fcb_sys_clk ),
  //.sys_rst_n 			( fcb_sys_rst_n ),
  //.hw_wr_en 			( fmic_frfu_set_rc_clk_en | fsmc_frfu_clr_rcclk_en),	// JC
  //.hw_wrdata			( { 1{ fmic_frfu_set_rc_clk_en }}),	// The assumption is fmic_frfu_set_rc_clk_en and fsmc_frfu_clr_rcclk_en will not toggle at same time
  //.wrdata 			( sfr_wrdata[0] ),
  //.wr_en 				( addr_07_wr_en ),
  //.rddata 			( frfu_fmic_rc_clk_en )
  //) ;  

  //========================================================//
  //==	REG 0x08										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h0}})
  ) qf_rw_INST_08 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_08_wr_en),
      .rddata   ({{frfu_bl_pw_cfg_0}})
  );
  //========================================================//
  //==	REG 0x09										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h0}})
  ) qf_rw_INST_09 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_09_wr_en),
      .rddata   ({{frfu_bl_pw_cfg_1}})
  );
  //========================================================//
  //==	REG 0x0a										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h0}})
  ) qf_rw_INST_0a (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_0a_wr_en),
      .rddata   ({{frfu_wl_pw_cfg}})
  );
  //========================================================//
  //==	REG 0x0b										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h00}})
  ) qf_rw_INST_0b (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_0b_wr_en),
      .rddata   ({{frfu_ffsr_ram_cfg_0_en}})
  );
  //========================================================//
  //==	REG 0x0c										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h00}})
  ) qf_rw_INST_0c (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_0c_wr_en),
      .rddata   ({{frfu_ffsr_ram_cfg_1_en}})
  );
  //========================================================//
  //==	REG 0x0d										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h00}})
  ) qf_rw_INST_0d (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_0d_wr_en),
      .rddata   ({{frfu_wrd_cnt_b0}})
  );
  //========================================================//
  //==	REG 0x0e										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h00}})
  ) qf_rw_INST_0e (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_0e_wr_en),
      .rddata   ({{frfu_wrd_cnt_b1}})
  );
  //========================================================//
  //==	REG 0x0f										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h00}})
  ) qf_rw_INST_0f (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_0f_wr_en),
      .rddata   ({{frfu_wrd_cnt_b2}})
  );
  //========================================================//
  //==	REG 0x10										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h00}})
  ) qf_rw_INST_10 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_10_wr_en),
      .rddata   ({{frfu_ffsr_bl_cnt_l}})
  );
  //========================================================//
  //==	REG 0x11										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h00}})
  ) qf_rw_INST_11 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_11_wr_en),
      .rddata   ({{frfu_ffsr_bl_cnt_h}})
  );
  //========================================================//
  //==	REG 0x12										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h00}})
  ) qf_rw_INST_12 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_12_wr_en),
      .rddata   ({{frfu_ffsr_wl_cnt_l}})
  );
  //========================================================//
  //==	REG 0x13										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h00}})
  ) qf_rw_INST_13 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_13_wr_en),
      .rddata   ({{frfu_ffsr_wl_cnt_h}})
  );
  //========================================================//
  //==	REG 0x14										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h0}})
  ) qf_rw_INST_14 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_14_wr_en),
      .rddata   ({{frfu_ffsr_col_cnt}})
  );
  //========================================================//
  //==	REG 0x15										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 7:0							==//
  //====================================================//
  assign frfu_ffsr_ram_size_b0 = 8'h00;
  //========================================================//
  //==	REG 0x16										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 7:0							==//
  //====================================================//
  assign frfu_ffsr_ram_size_b1 = 8'h02;
  //========================================================//
  //==	REG 0x17										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 7:0							==//
  //====================================================//
  assign frfu_ffsr_ram_data_width = 8'h12;
  //========================================================//
  //==	REG 0x18										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h0}})
  ) qf_rw_INST_18 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_18_wr_en),
      .rddata   ({{frfu_ffsr_rcfg_wrp_ccnt, frfu_ffsr_cfg_wrp_ccnt}})
  );
  //========================================================//
  //==	REG 0x19										==//
  //========================================================// 
  assign frfu_ffsr_wlblclk_cfg[1:0] = frfu_scratch_byte[7:6];

  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h00}})
  ) qf_rw_INST_19 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_19_wr_en),
      .rddata   ({{frfu_scratch_byte}})
  );
  //========================================================//
  //==	REG 0x1a										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 7:0								==//
  //====================================================//
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h00}})
  ) qf_rw_INST_1a (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_1a_wr_en),
      .rddata   ({{frfu_csum_w0_b0}})
  );
  //========================================================//
  //==	REG 0x1b										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 7:0								==//
  //====================================================//
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h00}})
  ) qf_rw_INST_1b (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_1b_wr_en),
      .rddata   ({{frfu_csum_w0_b1}})
  );
  //========================================================//
  //==	REG 0x1c										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 7:0								==//
  //====================================================//
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h00}})
  ) qf_rw_INST_1c (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_1c_wr_en),
      .rddata   ({{frfu_csum_w1_b0}})
  );
  //========================================================//
  //==	REG 0x1d										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 7:0								==//
  //====================================================//
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h00}})
  ) qf_rw_INST_1d (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_1d_wr_en),
      .rddata   ({{frfu_csum_w1_b1}})
  );
  //========================================================//
  //==	REG 0x1e										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h00}})
  ) qf_rw_INST_1e (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_1e_wr_en),
      .rddata   ({{frfu_ffsr_fb_cfg_cmd}})
  );
  //========================================================//
  //==	REG 0x1f										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 0								==//
  //====================================================//
  qf_rwhwsc  // R_W_HC
  #(
      .PAR_BIT_WIDTH(1),
      .PAR_DEFAULT_VALUE(1'b0)
  ) qf_rwhwsc_INST_1f_0 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wr_en (ffsr_frfu_clr_fb_cfg_kickoff),
      .hw_wrdata({1{1'b0}}),
      .wrdata   (sfr_wrdata[0]),
      .wr_en    (addr_1f_wr_en),
      .rddata   (frfu_ffsr_fb_cfg_kickoff)
  );
  //========================================================//
  //==	REG 0x21										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 0								==//
  //====================================================//
  always_comb begin
    fssc_set_cfg_done = 1'b0;
    //if ( fssc_frfu_spis_on == 1'b1 )
    if ( fssc_frfu_spis_on == 1'b1 && fcb_sys_stm == 1'b0 )	// JC 20170830
    begin
      if (frfu_ffsr_fb_cfg_cmd == 8'h02 || frfu_ffsr_fb_cfg_cmd == 8'h01) begin
        if (frfu_fsmc_checksum_status_cs == 1'b1) begin
          fssc_set_cfg_done = ffsr_frfu_clr_fb_cfg_kickoff_dly1cyc;  // Use Delay 1 Cycle
        end
      end else if (frfu_ffsr_fb_cfg_cmd == 8'h00) begin
        fssc_set_cfg_done = ffsr_frfu_clr_fb_cfg_kickoff_dly1cyc;  // Use Delay 1 Cycle
      end
    end
  end


  qf_rwhwsc  // R_W_HS
  #(
      .PAR_BIT_WIDTH(1),
      .PAR_DEFAULT_VALUE(1'h0)
  ) qf_rwhwsc_INST_21_0 (
      .sys_clk(fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wrdata((~fclp_frfu_clear_cfg_done) & (~fpmu_frfu_clr_cfg_done)),
      .hw_wr_en			( fsmc_frfu_set_fb_cfg_done | fssc_set_cfg_done | fclp_frfu_clear_cfg_done | fpmu_frfu_clr_cfg_done ),
      .wrdata(sfr_wrdata[0]),
      .wr_en(addr_21_wr_en),
      .rddata(frfu_fmic_fb_cfg_done)
  );

  //.hw_wr_en 			( 1'b1 & (~fclp_frfu_clear_cfg_done) ),
  //.hw_wrdata			( fsmc_frfu_set_fb_cfg_done | fssc_set_cfg_done | fclp_frfu_clear_cfg_done ),
  //========================================================//
  //==	REG 0x30										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 7:0								==//
  //====================================================//
  qf_rwhwsc  // R_W_HW
  #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE(8'h0)
  ) qf_rwhwsc_INST_30_0 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wrdata(8'b0000_0000),
      //.hw_wr_en 			( fpmu_frfu_clr_quad_pd_wr_en_b0 | clr_quad_pd ),
      .hw_wr_en (fpmu_frfu_clr_quads),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_30_wr_en),
      //.rddata 			( frfu_fpmu_quad_pd_en_b0 )
      .rddata   (frfu_fpmu_quad_cfg_b0)
  );
  //========================================================//
  //==	REG 0x31										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 7:0								==//
  //====================================================//
  qf_rwhwsc  // R_W_HW
  #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE(8'h0)
  ) qf_rwhwsc_INST_31_0 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wrdata(8'b0000_0000),
      //.hw_wr_en 			( fpmu_frfu_clr_quad_pd_wr_en_b1 | clr_quad_pd  ),
      .hw_wr_en (fpmu_frfu_clr_quads),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_31_wr_en),
      //.rddata 			( frfu_fpmu_quad_pd_en_b1 )
      .rddata   (frfu_fpmu_quad_cfg_b1)
  );
  //========================================================//
  //==	REG 0x32										==//
  //========================================================// 
  //qf_rw 
  //# (
  //.PAR_BIT_WIDTH		( 2 ),
  //.PAR_DEFAULT_VALUE	( {{2'h00}} )
  //)
  //qf_rw_INST_32
  //(
  //.sys_clk			( fcb_sys_clk ),
  //.sys_rst_n 			( fcb_sys_rst_n ),
  //.wrdata 			( sfr_wrdata[1:0] ),
  //.wr_en 				( addr_32_wr_en ),
  //.rddata 			( { {frfu_fpmu_quad_pd_mode} } )	//JC
  //) ; 

  //qf_rwhwsc                       // R_W_HW
  //# (
  //.PAR_BIT_WIDTH          ( 2 ),
  //.PAR_DEFAULT_VALUE      ( 2'h0 )
  //)
  //qf_rwhwsc_INST_32
  //(
  //.sys_clk                        ( fcb_sys_clk ),
  //.sys_rst_n                      ( fcb_sys_rst_n ),
  //.hw_wrdata                      ( 2'b00 ),
  //.hw_wr_en                       ( fpmu_frfu_clr_quad_pd_wr_en_b1 | fpmu_frfu_clr_quad_pd_wr_en_b0 | clr_quad_pd ),
  //.wrdata                         ( sfr_wrdata[1:0] ),
  //.wr_en                          ( addr_32_wr_en ),
  //.rddata                         ( frfu_fpmu_quad_pd_mode )
  //) ;



  //========================================================//
  //==	REG 0x33										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 7:0								==//
  //====================================================//
  //qf_rwhwsc			// R_W_HW
  //# (
  //.PAR_BIT_WIDTH		( 8 ),
  //.PAR_DEFAULT_VALUE	( 8'h0 )
  //)
  //qf_rwhwsc_INST_33_0
  //(
  //.sys_clk			( fcb_sys_clk ),
  //.sys_rst_n 			( fcb_sys_rst_n ),
  //.hw_wrdata 			( 8'h00 ),
  //.hw_wr_en 			( fpmu_frfu_clr_quad_wu_wr_en_b0 | clr_quad_wu ),
  //.wrdata 			( sfr_wrdata[7:0] ),
  //.wr_en 				( addr_33_wr_en ),
  //.rddata 			( frfu_fpmu_quad_wu_en_b0 )
  //) ; 
  //========================================================//
  //==	REG 0x34					==//
  //========================================================// 
  //====================================================//
  //==	RANGE 7:0				    ==//
  //====================================================//
  //qf_rwhwsc			// R_W_HW
  //# (
  //.PAR_BIT_WIDTH		( 8 ),
  //.PAR_DEFAULT_VALUE	( 8'h0 )
  //)
  //qf_rwhwsc_INST_34_0
  //(
  //.sys_clk			( fcb_sys_clk ),
  //.sys_rst_n 			( fcb_sys_rst_n ),
  //.hw_wrdata 			( 8'h00 ),
  //.hw_wr_en 			( fpmu_frfu_clr_quad_wu_wr_en_b1 | clr_quad_wu ),
  //.wrdata 			( sfr_wrdata[7:0] ),
  //.wr_en 				( addr_34_wr_en ),
  //.rddata 			( frfu_fpmu_quad_wu_en_b1 )
  //) ; 
  //========================================================//
  //==	REG 0x35										==//
  //========================================================// 
  //qf_rw 
  //# (
  //.PAR_BIT_WIDTH		( 2 ),
  //.PAR_DEFAULT_VALUE	( {{2'h00}} )
  //)
  //qf_rw_INST_35
  //(
  //.sys_clk			( fcb_sys_clk ),
  //.sys_rst_n 			( fcb_sys_rst_n ),
  //.wrdata 			( sfr_wrdata[1:0] ),
  //.wr_en 				( addr_35_wr_en ),
  //.rddata 			( { {frfu_fpmu_quad_wu_mode} } )	// JC
  //) ; 

  //qf_rwhwsc                       // R_W_HW
  //# (
  //.PAR_BIT_WIDTH          ( 2 ),
  //.PAR_DEFAULT_VALUE      ( 2'h0 )
  //)
  //qf_rwhwsc_INST_32
  //(
  //.sys_clk                        ( fcb_sys_clk ),
  //.sys_rst_n                      ( fcb_sys_rst_n ),
  //.hw_wrdata                      ( 2'b00 ),
  //.hw_wr_en                       ( fpmu_frfu_clr_quad_wu_wr_en_b1 | fpmu_frfu_clr_quad_wu_wr_en_b0 | clr_quad_wu ),
  //.wrdata                         ( sfr_wrdata[1:0] ),
  //.wr_en                          ( addr_35_wr_en ),
  //.rddata                         ( frfu_fpmu_quad_pd_mode )
  //) ;
  //========================================================//
  //==	REG 0x36										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 1:0								==//
  //====================================================//
  assign frfu_quad_pw_sta_00 = fpmu_frfu_pw_sta_00;
  //====================================================//
  //==	RANGE 3:2								==//
  //====================================================//
  assign frfu_quad_pw_sta_01 = fpmu_frfu_pw_sta_01;
  //====================================================//
  //==	RANGE 5:4								==//
  //====================================================//
  assign frfu_quad_pw_sta_02 = fpmu_frfu_pw_sta_02;
  //====================================================//
  //==	RANGE 7:6								==//
  //====================================================//
  assign frfu_quad_pw_sta_03 = fpmu_frfu_pw_sta_03;
  //========================================================//
  //==	REG 0x37										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 1:0								==//
  //====================================================//
  assign frfu_quad_pw_sta_10 = fpmu_frfu_pw_sta_10;
  //====================================================//
  //==	RANGE 3:2								==//
  //====================================================//
  assign frfu_quad_pw_sta_11 = fpmu_frfu_pw_sta_11;
  //====================================================//
  //==	RANGE 5:4								==//
  //====================================================//
  assign frfu_quad_pw_sta_12 = fpmu_frfu_pw_sta_12;
  //====================================================//
  //==	RANGE 7:6								==//
  //====================================================//
  assign frfu_quad_pw_sta_13 = fpmu_frfu_pw_sta_13;
  //========================================================//
  //==	REG 0x38										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 1:0								==//
  //====================================================//
  assign frfu_quad_pw_sta_20 = fpmu_frfu_pw_sta_20;
  //====================================================//
  //==	RANGE 3:2								==//
  //====================================================//
  assign frfu_quad_pw_sta_21 = fpmu_frfu_pw_sta_21;
  //====================================================//
  //==	RANGE 5:4								==//
  //====================================================//
  assign frfu_quad_pw_sta_22 = fpmu_frfu_pw_sta_22;
  //====================================================//
  //==	RANGE 7:6								==//
  //====================================================//
  assign frfu_quad_pw_sta_23 = fpmu_frfu_pw_sta_23;
  //========================================================//
  //==	REG 0x39										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 1:0								==//
  //====================================================//
  assign frfu_quad_pw_sta_30 = fpmu_frfu_pw_sta_30;
  //====================================================//
  //==	RANGE 3:2								==//
  //====================================================//
  assign frfu_quad_pw_sta_31 = fpmu_frfu_pw_sta_31;
  //====================================================//
  //==	RANGE 5:4								==//
  //====================================================//
  assign frfu_quad_pw_sta_32 = fpmu_frfu_pw_sta_32;
  //====================================================//
  //==	RANGE 7:6								==//
  //====================================================//
  assign frfu_quad_pw_sta_33 = fpmu_frfu_pw_sta_33;
  //========================================================//
  //==	REG 0x3a										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'hff}})
  ) qf_rw_INST_3a (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_3a_wr_en),
      .rddata   ({{frfu_fpmu_pmu_timer_ccnt}})
  );
  //========================================================//
  //==	REG 0x3b										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(6),
      .PAR_DEFAULT_VALUE({{6'h5}})
  ) qf_rw_INST_3b (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[5:0]),
      .wr_en    (addr_3b_wr_en),
      .rddata   ({{frfu_fpmu_pmu_pwr_gate_ccnt}})
  );
  //========================================================//
  //==	REG 0x3c					==//		//JC
  //========================================================// 
  //====================================================//
  //==	RANGE 0					==//
  //====================================================//
  //	qf_rwhwsc			// R_W_HW
  //	# (
  //	.PAR_BIT_WIDTH		( 1 ),
  //	.PAR_DEFAULT_VALUE	( 1'h0 )
  //	)
  //	qf_rwhwsc_INST_3c_0
  //	(
  //	.sys_clk			( fcb_sys_clk ),
  //	.sys_rst_n 			( fcb_sys_rst_n ),
  //	.hw_wrdata 			( fmic_frfu_set_pmu_chip_wu_en & (~fpmu_frfu_clr_pmu_chip_wu_en)),
  //	.hw_wr_en 			( ( fmic_frfu_set_pmu_chip_wu_en & (~fcb_clp_mode_en_bo )) | fpmu_frfu_clr_pmu_chip_wu_en ),
  //	.wrdata 			( sfr_wrdata[0] ),
  //	.wr_en 				( addr_3c_wr_en ),
  //	.rddata 			( frfu_fpmu_pmu_chip_vlp_wu_en )
  //	) ; 
  //========================================================//
  //==	REG 0x3d					==//		//JC
  //========================================================// 
  //====================================================//
  //==	RANGE 0					==//
  //====================================================//
  //	qf_rwhwsc			// R_W_HW
  //	# (
  //	.PAR_BIT_WIDTH		( 1 ),
  //	.PAR_DEFAULT_VALUE	( 1'h0 )
  //	)
  //	qf_rwhwsc_INST_3d_0
  //	(
  //	.sys_clk			( fcb_sys_clk ),
  //	.sys_rst_n 			( fcb_sys_rst_n ),
  //	.hw_wrdata 			( fmic_frfu_set_pmu_chip_vlp_en & (~fpmu_frfu_clr_pmu_chip_vlp_en)),
  //	.hw_wr_en 			( ( fmic_frfu_set_pmu_chip_vlp_en & (~fcb_clp_mode_en_bo )) | fpmu_frfu_clr_pmu_chip_vlp_en ),
  //	.wrdata 			( sfr_wrdata[0] ),
  //	.wr_en 				( addr_3d_wr_en ),
  //	.rddata 			( frfu_fpmu_pmu_chip_vlp_en )
  //	) ; 
  //========================================================//
  //==	REG 0x3e										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 0								==//
  //====================================================//
  assign frfu_fpmu_vlp_pin_value = fcb_vlp;
  //========================================================//
  //==	REG 0x40										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h0}})
  ) qf_rw_INST_40 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_40_wr_en),
      .rddata   ({{frfu_fpmu_iso_en_0}})
  );
  //========================================================//
  //==	REG 0x41										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h0}})
  ) qf_rw_INST_41 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_41_wr_en),
      .rddata   ({{frfu_fpmu_iso_en_1}})
  );
  //========================================================//
  //==	REG 0x42										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h0}})
  ) qf_rw_INST_42 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_42_wr_en),
      .rddata   ({{frfu_fpmu_pi_pwr_0}})
  );
  //========================================================//
  //==	REG 0x43										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h0}})
  ) qf_rw_INST_43 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_43_wr_en),
      .rddata   ({{frfu_fpmu_pi_pwr_1}})
  );
  //========================================================//
  //==	REG 0x44										==//
  //========================================================// 
  //qf_rw 
  //# (
  //.PAR_BIT_WIDTH		( 8 ),
  //.PAR_DEFAULT_VALUE	( {{8'h0}} )
  //)
  //qf_rw_INST_44
  //(
  //.sys_clk			( fcb_sys_clk ),
  //.sys_rst_n 			( fcb_sys_rst_n ),
  //.wrdata 			( sfr_wrdata[7:0] ),
  //.wr_en 				( addr_44_wr_en ),
  //.rddata 			( { {frfu_fpmu_vlp_0} } )
  //) ; 
  //========================================================//
  //==	REG 0x45										==//
  //========================================================// 
  //qf_rw 
  //# (
  //.PAR_BIT_WIDTH		( 8 ),
  //.PAR_DEFAULT_VALUE	( {{8'h0}} )
  //)
  //qf_rw_INST_45
  //(
  //.sys_clk			( fcb_sys_clk ),
  //.sys_rst_n 			( fcb_sys_rst_n ),
  //.wrdata 			( sfr_wrdata[7:0] ),
  //.wr_en 				( addr_45_wr_en ),
  //.rddata 			( { {frfu_fpmu_vlp_1} } )
  //) ; 
  //========================================================//
  //==	REG 0x46										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h0}})
  ) qf_rw_INST_46 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_46_wr_en),
      .rddata   ({{frfu_fpmu_vlp_clkdis_0}})
  );
  //========================================================//
  //==	REG 0x47										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h0}})
  ) qf_rw_INST_47 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_47_wr_en),
      .rddata   ({{frfu_fpmu_vlp_clkdis_1}})
  );
  //========================================================//
  //==	REG 0x48										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h0}})
  ) qf_rw_INST_48 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_48_wr_en),
      .rddata   ({{frfu_fpmu_vlp_srdis_0}})
  );
  //========================================================//
  //==	REG 0x49										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h0}})
  ) qf_rw_INST_49 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_49_wr_en),
      .rddata   ({{frfu_fpmu_vlp_srdis_1}})
  );
  //========================================================//
  //==	REG 0x4a										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h0}})
  ) qf_rw_INST_4a (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_4a_wr_en),
      .rddata   ({{frfu_fpmu_vlp_pwrdis_0}})
  );
  //========================================================//
  //==	REG 0x4b										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE({{8'h0}})
  ) qf_rw_INST_4b (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_4b_wr_en),
      .rddata   ({{frfu_fpmu_vlp_pwrdis_1}})
  );
  //========================================================//
  //==	REG 0x4c										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE(8'h00)
  ) qf_rw_INST_4c (
      .sys_clk(fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata(sfr_wrdata[7:0]),
      .wr_en(addr_4c_wr_en),
      .rddata({
        {frfu_fpmu_set_por},
        {frfu_fpmu_prog_ifx},
        {frfu_fpmu_pwr_gate},
        {frfu_fpmu_fb_iso_enb},
        {frfu_fpmu_vlp_pwrdis_ifx},
        {frfu_fpmu_vlp_srdis_ifx},
        {frfu_fpmu_vlp_clkdis_ifx},
        {frfu_fpmu_vlp_ifx}
      })
  );
  //========================================================//
  //==    REG 0x4d                                                                                ==//
  //========================================================//
  qf_rw #(
      .PAR_BIT_WIDTH    (8),
      .PAR_DEFAULT_VALUE({{8'h0}})
  ) qf_rw_INST_4d (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_4d_wr_en),
      .rddata   ({{frfu_fpmu_prog_0}})
  );
  //========================================================//
  //==    REG 0x4e                                                                                ==//
  //========================================================//
  qf_rw #(
      .PAR_BIT_WIDTH    (8),
      .PAR_DEFAULT_VALUE({{8'h0}})
  ) qf_rw_INST_4e (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[7:0]),
      .wr_en    (addr_4e_wr_en),
      .rddata   ({{frfu_fpmu_prog_1}})
  );
  //========================================================//
  //==	REG 0x4f					==//
  //========================================================// 
  //====================================================//
  //==	RANGE 0					==//
  //====================================================//
  qf_rwhwsc  // R_W_HC
  #(
      .PAR_BIT_WIDTH(1),
      .PAR_DEFAULT_VALUE(1'h0)
  ) qf_rwhwsc_INST_4f_0 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wr_en (frfu_fpmu_up_sd),
      .hw_wrdata({1{1'b0}}),
      .wrdata   (sfr_wrdata[0]),
      .wr_en    (addr_4f_wr_en),
      .rddata   (frfu_fpmu_up_sd)
  );
  //========================================================//
  //==	REG 0x50					==//
  //========================================================// 
  //====================================================//
  //==	RANGE 7:0				==//
  //====================================================//
  qf_rhw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE(8'h0)
  ) qf_rhw_INST_50_0 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wrdata(frfu_fpmu_iso_en_0),
      .hw_wr_en (frfu_fpmu_up_sd),
      .rddata   (frfu_fpmu_iso_en_sd_0)
  );
  //========================================================//
  //==	REG 0x51					==//
  //========================================================// 
  //====================================================//
  //==	RANGE 7:0				==//
  //====================================================//
  qf_rhw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE(8'h0)
  ) qf_rhw_INST_51_0 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wrdata(frfu_fpmu_iso_en_1),
      .hw_wr_en (frfu_fpmu_up_sd),
      .rddata   (frfu_fpmu_iso_en_sd_1)
  );
  //========================================================//
  //==	REG 0x52										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 7:0								==//
  //====================================================//
  qf_rhw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE(8'h0)
  ) qf_rhw_INST_52_0 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wrdata(frfu_fpmu_pi_pwr_0),
      .hw_wr_en (frfu_fpmu_up_sd),
      .rddata   (frfu_fpmu_pi_pwr_sd_0)
  );
  //========================================================//
  //==	REG 0x53										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 7:0								==//
  //====================================================//
  qf_rhw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE(8'h0)
  ) qf_rhw_INST_53_0 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wrdata(frfu_fpmu_pi_pwr_1),
      .hw_wr_en (frfu_fpmu_up_sd),
      .rddata   (frfu_fpmu_pi_pwr_sd_1)
  );
  //========================================================//
  //==	REG 0x54										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 7:0								==//
  //====================================================//
  //qf_rhw 
  //# (
  //.PAR_BIT_WIDTH		( 8 ),
  //.PAR_DEFAULT_VALUE	( 8'h0 )
  //)
  //qf_rhw_INST_54_0
  //(
  //.sys_clk			( fcb_sys_clk ),
  //.sys_rst_n 			( fcb_sys_rst_n ),
  //.hw_wrdata 			( frfu_fpmu_vlp_0 ),
  //.hw_wr_en 			( frfu_fpmu_up_sd ),
  //.rddata 			( frfu_fpmu_vlp_sd_0 )
  //) ; 
  //========================================================//
  //==	REG 0x55					==//
  //========================================================// 
  //====================================================//
  //==	RANGE 7:0				==//
  //====================================================//
  //qf_rhw 
  //# (
  //.PAR_BIT_WIDTH		( 8 ),
  //.PAR_DEFAULT_VALUE	( 8'h0 )
  //)
  //qf_rhw_INST_55_0
  //(
  //.sys_clk			( fcb_sys_clk ),
  //.sys_rst_n 			( fcb_sys_rst_n ),
  //.hw_wrdata 			( frfu_fpmu_vlp_1 ),
  //.hw_wr_en 			( frfu_fpmu_up_sd ),
  //.rddata 			( frfu_fpmu_vlp_sd_1 )
  //) ; 
  //========================================================//
  //==	REG 0x56										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 7:0								==//
  //====================================================//
  qf_rhw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE(8'h0)
  ) qf_rhw_INST_56_0 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wrdata(frfu_fpmu_vlp_clkdis_0),
      .hw_wr_en (frfu_fpmu_up_sd),
      .rddata   (frfu_fpmu_vlp_clkdis_sd_0)
  );
  //========================================================//
  //==	REG 0x57										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 7:0								==//
  //====================================================//
  qf_rhw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE(8'h0)
  ) qf_rhw_INST_57_0 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wrdata(frfu_fpmu_vlp_clkdis_1),
      .hw_wr_en (frfu_fpmu_up_sd),
      .rddata   (frfu_fpmu_vlp_clkdis_sd_1)
  );
  //========================================================//
  //==	REG 0x58										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 7:0								==//
  //====================================================//
  qf_rhw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE(8'h0)
  ) qf_rhw_INST_58_0 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wrdata(frfu_fpmu_vlp_srdis_0),
      .hw_wr_en (frfu_fpmu_up_sd),
      .rddata   (frfu_fpmu_vlp_srdis_sd_0)
  );
  //========================================================//
  //==	REG 0x59										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 7:0								==//
  //====================================================//
  qf_rhw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE(8'h0)
  ) qf_rhw_INST_59_0 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wrdata(frfu_fpmu_vlp_srdis_1),
      .hw_wr_en (frfu_fpmu_up_sd),
      .rddata   (frfu_fpmu_vlp_srdis_sd_1)
  );
  //========================================================//
  //==	REG 0x5a										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 7:0								==//
  //====================================================//
  qf_rhw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE(8'h0)
  ) qf_rhw_INST_5a_0 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wrdata(frfu_fpmu_vlp_pwrdis_0),
      .hw_wr_en (frfu_fpmu_up_sd),
      .rddata   (frfu_fpmu_vlp_pwrdis_sd_0)
  );
  //========================================================//
  //==	REG 0x5b										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 7:0								==//
  //====================================================//
  qf_rhw #(
      .PAR_BIT_WIDTH(8),
      .PAR_DEFAULT_VALUE(8'h0)
  ) qf_rhw_INST_5b_0 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wrdata(frfu_fpmu_vlp_pwrdis_1),
      .hw_wr_en (frfu_fpmu_up_sd),
      .rddata   (frfu_fpmu_vlp_pwrdis_sd_1)
  );
  //========================================================//
  //==	REG 0x5c										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 0								==//
  //====================================================//
  qf_rhw #(
      .PAR_BIT_WIDTH(1),
      .PAR_DEFAULT_VALUE(1'h0)
  ) qf_rhw_INST_5c_0 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wrdata(frfu_fpmu_vlp_ifx),
      .hw_wr_en (frfu_fpmu_up_sd),
      .rddata   (frfu_fpmu_vlp_ifx_sd)
  );
  //====================================================//
  //==	RANGE 1								==//
  //====================================================//
  qf_rhw #(
      .PAR_BIT_WIDTH(1),
      .PAR_DEFAULT_VALUE(1'h0)
  ) qf_rhw_INST_5c_1 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wrdata(frfu_fpmu_vlp_clkdis_ifx),
      .hw_wr_en (frfu_fpmu_up_sd),
      .rddata   (frfu_fpmu_vlp_clkdis_ifx_sd)
  );
  //====================================================//
  //==	RANGE 2								==//
  //====================================================//
  qf_rhw #(
      .PAR_BIT_WIDTH(1),
      .PAR_DEFAULT_VALUE(1'h0)
  ) qf_rhw_INST_5c_2 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wrdata(frfu_fpmu_vlp_srdis_ifx),
      .hw_wr_en (frfu_fpmu_up_sd),
      .rddata   (frfu_fpmu_vlp_srdis_ifx_sd)
  );
  //====================================================//
  //==	RANGE 3								==//
  //====================================================//
  qf_rhw #(
      .PAR_BIT_WIDTH(1),
      .PAR_DEFAULT_VALUE(1'h0)
  ) qf_rhw_INST_5c_3 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wrdata(frfu_fpmu_vlp_pwrdis_ifx),
      .hw_wr_en (frfu_fpmu_up_sd),
      .rddata   (frfu_fpmu_vlp_pwrdis_ifx_sd)
  );

  //====================================================//
  //==    RANGE 4                                                         ==//
  //====================================================//
  qf_rhw #(
      .PAR_BIT_WIDTH    (1),
      .PAR_DEFAULT_VALUE(1'h0)
  ) qf_rhw_INST_5c_4 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wrdata(frfu_fpmu_fb_iso_enb),
      .hw_wr_en (frfu_fpmu_up_sd),
      .rddata   (frfu_fpmu_fb_iso_enb_sd)
  );
  //====================================================//
  //==    RANGE 5                                                         ==//
  //====================================================//
  qf_rhw #(
      .PAR_BIT_WIDTH    (1),
      .PAR_DEFAULT_VALUE(1'h0)
  ) qf_rhw_INST_5c_5 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wrdata(frfu_fpmu_pwr_gate),
      .hw_wr_en (frfu_fpmu_up_sd),
      .rddata   (frfu_fpmu_pwr_gate_sd)
  );
  //====================================================//
  //==    RANGE 6                                                         ==//
  //====================================================//
  qf_rhw #(
      .PAR_BIT_WIDTH    (1),
      .PAR_DEFAULT_VALUE(1'h0)
  ) qf_rhw_INST_5c_6 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wrdata(frfu_fpmu_prog_ifx),
      .hw_wr_en (frfu_fpmu_up_sd),
      .rddata   (frfu_fpmu_prog_ifx_sd)
  );

  //====================================================//
  //==    RANGE 7                                                         ==//
  //====================================================//
  qf_rhw #(
      .PAR_BIT_WIDTH    (1),
      .PAR_DEFAULT_VALUE(1'h0)
  ) qf_rhw_INST_5c_7 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wrdata(frfu_fpmu_set_por),
      .hw_wr_en (frfu_fpmu_up_sd),
      .rddata   (frfu_fpmu_set_por_sd)
  );
  //========================================================//
  //==    REG 0x5d                                                                                ==//
  //========================================================//
  qf_rhw #(
      .PAR_BIT_WIDTH    (8),
      .PAR_DEFAULT_VALUE(8'h00)
  ) qf_rhw_INST_5d (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wrdata(frfu_fpmu_prog_0),
      .hw_wr_en (frfu_fpmu_up_sd),
      .rddata   (frfu_fpmu_prog_sd_0)
  );
  //========================================================//
  //==    REG 0x5e                                                                                ==//
  //========================================================//
  qf_rhw #(
      .PAR_BIT_WIDTH    (8),
      .PAR_DEFAULT_VALUE(8'h00)
  ) qf_rhw_INST_5e (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wrdata(frfu_fpmu_prog_1),
      .hw_wr_en (frfu_fpmu_up_sd),
      .rddata   (frfu_fpmu_prog_sd_1)
  );
  //========================================================//
  //==	REG 0x60										==//
  //========================================================// 
  qf_rw #(
      .PAR_BIT_WIDTH(1),
      .PAR_DEFAULT_VALUE({{1'h0}})
  ) qf_rw_INST_60 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .wrdata   (sfr_wrdata[0:0]),
      .wr_en    (addr_60_wr_en),
      .rddata   ({{frfu_fpmu_pmu_mux_sel}})
  );
  //========================================================//
  //==	REG 0x61										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 0								==//
  //====================================================//
  qf_rwhwsc  // R_W_HC
  #(
      .PAR_BIT_WIDTH(1),
      .PAR_DEFAULT_VALUE(1'h0)
  ) qf_rwhwsc_INST_61_0 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wr_en (frfu_fpmu_pmu_mux_up_sd),
      .hw_wrdata({1{1'b0}}),
      .wrdata   (sfr_wrdata[0]),
      .wr_en    (addr_61_wr_en),
      .rddata   (frfu_fpmu_pmu_mux_up_sd)
  );
  //========================================================//
  //==	REG 0x62										==//
  //========================================================// 
  //====================================================//
  //==	RANGE 0								==//
  //====================================================//
  qf_rhw #(
      .PAR_BIT_WIDTH(1),
      .PAR_DEFAULT_VALUE(1'h0)
  ) qf_rhw_INST_62_0 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wrdata(frfu_fpmu_pmu_mux_sel),
      .hw_wr_en (frfu_fpmu_pmu_mux_up_sd),
      .rddata   (frfu_fpmu_pmu_mux_sel_sd)
  );


  //========================================================//
  //==    REG 0x27                                        ==//
  //========================================================//

  qf_rwhwsc  // R_W_HS
  #(
      .PAR_BIT_WIDTH    (1),
      .PAR_DEFAULT_VALUE(1'h0)
  ) qf_rwhwsc_INST_27_0 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wr_en ((fcbrfuwff_wr_en & frfu_cwf_full) | frwf_frfu_ff0_of),  // JC
      .hw_wrdata(1'b1),
      .wrdata   (sfr_wrdata[0]),
      .wr_en    (addr_27_wr_en),
      .rddata   (fifo_wff_of)
  );




  //========================================================//
  //==    REG 0x28                                        ==//
  //========================================================//
  //====================================================//
  //==    RANGE 0       				==//
  //====================================================//
  qf_rwhwsc  // R_W_HW
  #(
      .PAR_BIT_WIDTH    (1),
      .PAR_DEFAULT_VALUE(1'h0)
  ) qf_rwhwsc_INST_28_0 (
      .sys_clk(fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wrdata((~fclp_frfu_clear_vlp_wu_en) & fmic_frfu_set_pmu_chip_wu_en),  // VLP PIN 
      .hw_wr_en(fclp_frfu_clear_vlp_wu_en | (fmic_frfu_set_pmu_chip_wu_en & fcb_clp_mode_en_bo)),
      .wrdata(sfr_wrdata[0]),
      .wr_en(addr_28_wr_en),
      .rddata(frfu_fclp_clp_vlp_wu_en)
  );


  //========================================================//
  //==    REG 0x29                                        ==//
  //========================================================//
  //====================================================//
  //==    RANGE 0                                     ==//
  //====================================================//
  qf_rwhwsc  // R_W_HW
  #(
      .PAR_BIT_WIDTH    (1),
      .PAR_DEFAULT_VALUE(1'h0)
  ) qf_rwhwsc_INST_29_0 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wrdata(fmic_frfu_set_pmu_chip_vlp_en & (~fclp_frfu_clear_vlp_en)),
      .hw_wr_en (fclp_frfu_clear_vlp_en | (fmic_frfu_set_pmu_chip_vlp_en & fcb_clp_mode_en_bo)),
      .wrdata   (sfr_wrdata[0]),
      .wr_en    (addr_29_wr_en),
      .rddata   (frfu_fclp_clp_vlp_en)
  );
  //========================================================//
  //==    REG 0x2a                                        ==//
  //========================================================//
  //====================================================//
  //==    RANGE 0                                     ==//
  //====================================================//
  qf_rwhwsc  // R_W_HW
  #(
      .PAR_BIT_WIDTH    (1),
      .PAR_DEFAULT_VALUE(1'h0)
  ) qf_rwhwsc_INST_2a_0 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wrdata(~fclp_frfu_clear_pd_wu_en),
      .hw_wr_en (fclp_frfu_clear_pd_wu_en),
      .wrdata   (sfr_wrdata[0]),
      .wr_en    (addr_2a_wr_en),
      .rddata   (frfu_fclp_clp_pd_wu_en)
  );
  //========================================================//
  //==    REG 0x2b                                                                                ==//
  //========================================================//
  //====================================================//
  //==    RANGE 0                                                         ==//
  //====================================================//
  qf_rwhwsc  // R_W_HW
  #(
      .PAR_BIT_WIDTH    (1),
      .PAR_DEFAULT_VALUE(1'h0)
  ) qf_rwhwsc_INST_2b_0 (
      .sys_clk(fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      //.hw_wrdata                      ( ~fclp_frfu_clear_pd_en ),
      //.hw_wr_en                       ( fclp_frfu_clear_pd_en ),
      .hw_wrdata                      (  fsmc_frfu_set_clp_pd ),	// fclp_frfu_clear_pd_en and fsmc_frfu_set_clp_pd will not active at same time.
      .hw_wr_en(fclp_frfu_clear_pd_en | fsmc_frfu_set_clp_pd),
      .wrdata(sfr_wrdata[0]),
      .wr_en(addr_2b_wr_en),
      .rddata(frfu_fclp_clp_pd_en)
  );
  //========================================================//
  //==    REG 0x2c                                        ==//
  //========================================================//
  //====================================================//
  //==    RANGE 1:0                                   ==//
  //====================================================//
  assign frfu_chip_pwr_Sta = ( fcb_clp_mode_en_bo == 1'b1 )
			 ? fclp_frfu_clp_pw_sta : fpmu_frfu_chip_pw_sta ;

  //========================================================//
  //==    REG 0x2D                                    	==//	//JC
  //========================================================//
  //====================================================//
  //==    RANGE 0                                	==//
  //====================================================//
  //qf_rwhwsc                       // R_W_HW
  //# ( 
  //.PAR_BIT_WIDTH          ( 1 ),  
  //.PAR_DEFAULT_VALUE      ( 1'h0 )
  //)
  //qf_rwhwsc_INST_2d_0
  //(
  //.sys_clk                        ( fcb_sys_clk ),
  //.sys_rst_n                      ( fcb_sys_rst_n ),
  ////.hw_wrdata                      ( fmic_frfu_set_pmu_chip_vlp_en & (~fpmu_frfu_clr_pmu_chip_vlp_en)),
  //.hw_wrdata                      ( fmic_frfu_set_pmu_chip_vlp_en ),
  //.hw_wr_en                       ( ( fmic_frfu_set_pmu_chip_vlp_en & (~fcb_clp_mode_en_bo )) | fpmu_frfu_clr_pmu_chip_vlp_en | clr_chip_vlp ),
  //.wrdata                         ( sfr_wrdata[0] ),
  //.wr_en                          ( addr_2d_wr_en ),
  //.rddata                         ( frfu_fpmu_pmu_chip_vlp_en )
  //) ;
  //========================================================//
  //==    REG 0x2E                                     	==//	//JC
  //========================================================//
  //====================================================//
  //==    RANGE 0                                	==//
  //====================================================//

  //qf_rwhwsc                       // R_W_HW
  //# (
  //.PAR_BIT_WIDTH          ( 1 ),
  //.PAR_DEFAULT_VALUE      ( 1'h0 )
  //)
  //qf_rwhwsc_INST_2e_0
  //(
  //.sys_clk                        ( fcb_sys_clk ),
  //.sys_rst_n                      ( fcb_sys_rst_n ),
  //.hw_wr_en                       (  fpmu_frfu_clr_pmu_chip_pd_en | fsmc_frfu_set_pd | clr_chip_pd ),
  //.hw_wrdata                      (  fsmc_frfu_set_pd ),		// set_pd and clear pd will not toggle at same time
  //.wrdata                         ( sfr_wrdata[0] ),
  //.wr_en                          ( addr_2e_wr_en ),
  //.rddata                         ( frfu_fpmu_pmu_chip_pd_en )
  //) ;

  //========================================================//
  //==    REG 0x2F                                      	==//	//JC
  //========================================================//
  //====================================================//
  //==    RANGE 0                                	==//
  //====================================================//
  //qf_rwhwsc                       // R_W_HW
  //# (
  //.PAR_BIT_WIDTH          ( 1 ),
  //.PAR_DEFAULT_VALUE      ( 1'h0 )
  //)
  //qf_rwhwsc_INST_2f_0
  //(
  ////.sys_clk                        ( fcb_sys_clk ),
  //.sys_rst_n                      ( fcb_sys_rst_n ),
  //.hw_wrdata                      ( fmic_frfu_set_pmu_chip_wu_en & (~fpmu_frfu_clr_pmu_chip_wu_en)),
  //.hw_wrdata                      ( fmic_frfu_set_pmu_chip_wu_en ), 
  //.hw_wr_en                       ( ( fmic_frfu_set_pmu_chip_wu_en & (~fcb_clp_mode_en_bo )) | fpmu_frfu_clr_pmu_chip_wu_en | clr_chip_wu ),
  //.wrdata                         ( sfr_wrdata[0] ),
  //.wr_en                          ( addr_3d_wr_en ),
  //.rddata                         ( frfu_fpmu_pmu_chip_vlp_wu_en )
  //) ;


  qf_rwhwsc  // R_W_HW
  #(
      .PAR_BIT_WIDTH    (4),
      .PAR_DEFAULT_VALUE(4'h0)
  ) qf_rwhwsc_INST_2f_0 (
      .sys_clk  (fcb_sys_clk),
      .sys_rst_n(fcb_sys_rst_n),
      .hw_wrdata({1'b0, fsmc_frfu_set_pd, 2'b00} | {fsmc_frfu_set_quad_pd, 3'b000}),
      .hw_wr_en (fpmu_frfu_clr_pmu_chip_cmd | fsmc_frfu_set_pd | fsmc_frfu_set_quad_pd),
      .wrdata   (sfr_wrdata[3:0]),
      .wr_en    (addr_2f_wr_en),
      .rddata   (frfu_fpmu_pmu_chip_cmd)
  );


  //========================================================================//
  //==	WR FIFO								--//
  //========================================================================// 
  //----------------------------------------------------------------//
  //-- FIFO Component                                             --//
  //----------------------------------------------------------------//
  assign frfu_ffsr_wfifo_wr_en = fcbrffwff_rd_en;


  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      fcbrffwff_stm_cs <= #PAR_DLY 'b0;
      byte_cnt_cs <= #PAR_DLY 'b0;
    end else begin
      fcbrffwff_stm_cs <= #PAR_DLY fcbrffwff_stm_ns;
      byte_cnt_cs <= #PAR_DLY byte_cnt_ns;
    end
  end

  always_comb begin
    fcbrffwff_stm_ns = fcbrffwff_stm_cs;
    fcbrffwff_rd_en = 1'b0;
    fcbrfuwff_chksum_b0_en = 1'b0;
    fcbrfuwff_chksum_b1_en = 1'b0;
    case (fcbrffwff_stm_cs)
      2'b00: begin
        if (fcbrfuwff_empty_flag == 1'b0) begin
          fcbrffwff_stm_ns = 2'b01;
          fcbrfuwff_chksum_b0_en = 1'b1;
        end
      end
      2'b01: begin
        if (ffsr_frfu_wfifo_full == 1'b0) begin
          fcbrffwff_stm_ns = 2'b00;
          fcbrffwff_rd_en = 1'b1;
          fcbrfuwff_chksum_b1_en = 1'b1;
        end
      end
      default: begin
        fcbrffwff_stm_ns = 2'b00;
      end
    endcase
  end

  always_comb begin
    if ( 	( fssc_frfu_spis_on == 1'b1 && fssc_frfu_cwf_wr_en == 1'b1 ) ||
	( fsmc_frfu_spim_on == 1'b1 && fsmc_frfu_cwf_wr_en == 1'b1 ) )
    begin
      byte_cnt_ns = byte_cnt_cs + 1'b1;
    end else if (frwf_frfu_frwf_on == 1'b1) begin
      byte_cnt_ns = 'b0;
    end else begin
      byte_cnt_ns = byte_cnt_cs;
    end
  end

  always_comb begin
    fcbrfuwff_wr_en   = 1'b0;
    fcbrfuwff_wr_byte = 4'b0;
    fcbrfuwff_wr_data = 32'b0;
    if ( frwf_frfu_cwf_wr_en == 1'b1 )				//JC 09132017
    begin
      fcbrfuwff_wr_byte[3:0] = {4{frwf_frfu_cwf_wr_en}};
      fcbrfuwff_wr_en        = frwf_frfu_cwf_wr_en;
      fcbrfuwff_wr_data      = frwf_frfu_cwf_wr_data;
    end else if (fssc_frfu_spis_on == 1'b1) begin
      if (byte_cnt_cs == 2'b00 && fssc_frfu_cwf_wr_en == 1'b1) begin
        fcbrfuwff_wr_byte[0] = 1'b1;
        fcbrfuwff_wr_data = {24'b0, fssc_frfu_cwf_wr_data};
      end else if (byte_cnt_cs == 2'b01 && fssc_frfu_cwf_wr_en == 1'b1) begin
        fcbrfuwff_wr_byte[1] = 1'b1;
        fcbrfuwff_wr_data = {16'b0, fssc_frfu_cwf_wr_data, 8'b0};
      end else if (byte_cnt_cs == 2'b10 && fssc_frfu_cwf_wr_en == 1'b1) begin
        fcbrfuwff_wr_byte[2] = 1'b1;
        fcbrfuwff_wr_data = {8'b0, fssc_frfu_cwf_wr_data, 16'b0};
      end else if (byte_cnt_cs == 2'b11 && fssc_frfu_cwf_wr_en == 1'b1) begin
        fcbrfuwff_wr_data 	= {fssc_frfu_cwf_wr_data,24'b0} ;
        fcbrfuwff_wr_byte[3] 	= 1'b1 ;
        fcbrfuwff_wr_en   	= 1'b1 ;
      end
    end else if (fsmc_frfu_spim_on == 1'b1) begin
      if (byte_cnt_cs == 2'b00 && fsmc_frfu_cwf_wr_en == 1'b1) begin
        fcbrfuwff_wr_byte[0] = 1'b1;
        fcbrfuwff_wr_data = {24'b0, fsmc_frfu_cwf_wr_data};
      end else if (byte_cnt_cs == 2'b01 && fsmc_frfu_cwf_wr_en == 1'b1) begin
        fcbrfuwff_wr_data = {16'b0, fsmc_frfu_cwf_wr_data, 8'b0};
        fcbrfuwff_wr_byte[1] = 1'b1;
      end else if (byte_cnt_cs == 2'b10 && fsmc_frfu_cwf_wr_en == 1'b1) begin
        fcbrfuwff_wr_byte[2] = 1'b1;
        fcbrfuwff_wr_data = {8'b0, fsmc_frfu_cwf_wr_data, 16'b0};
      end else if (byte_cnt_cs == 2'b11 && fsmc_frfu_cwf_wr_en == 1'b1) begin
        fcbrfuwff_wr_byte[3] = 1'b1;
        fcbrfuwff_wr_en      = 1'b1;
        fcbrfuwff_wr_data    = {fsmc_frfu_cwf_wr_data, 24'b0};
      end
    end else begin
      fcbrfuwff_wr_byte[3:0] = {4{frwf_frfu_cwf_wr_en}};
      fcbrfuwff_wr_en        = frwf_frfu_cwf_wr_en;
      fcbrfuwff_wr_data      = frwf_frfu_cwf_wr_data;
    end
  end
  //--------------------------------------------------------//
  //-- qf_sff Instance                                    --//
  //-- rff -- 2 Entries                                   --//
  //--------------------------------------------------------//
  fcbrfuwff fcbrfuwff_INST  // WFF
  (
      //------------------------------------------------------------//
      //-- INPUT                                                  --//
      //------------------------------------------------------------//
      .fifo_clk          (fcb_sys_clk),
      .fifo_rst_n        (fcb_sys_rst_n),
      .fifo_rd_en        (fcbrffwff_rd_en),
      .fifo_wr_data      (fcbrfuwff_wr_data),
      .fifo_wr_en        (fcbrfuwff_wr_en),
      .fifo_wr_byte      (fcbrfuwff_wr_byte),
      //------------------------------------------------------------//
      //-- OUTPUT                                                 --//
      //------------------------------------------------------------//
      .fifo_empty_flag   (fcbrfuwff_empty_flag),
      .fifo_empty_p1_flag(),
      .fifo_full_flag    (frfu_cwf_full),
      .fifo_full_m1_flag (),
      .fifo_rd_data      (frfu_ffsr_wfifo_wdata)
  );
  //========================================================================//
  //==	RD STM								--//
  //========================================================================// 


  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      rd_stm_cs <= #PAR_DLY 'b0;
    end else begin
      rd_stm_cs <= #PAR_DLY rd_stm_ns;
    end
  end

  always_comb begin
    rd_stm_ns             = rd_stm_cs;
    frfu_ffsr_rfifo_rd_en = 1'b0;
    frfu_frwf_crf_wr_en   = 1'b0;
    rdback_data_b0_en     = 1'b0;
    rdback_data_b1_en     = 1'b0;
    case (rd_stm_cs)
      2'b00: begin
        if (ffsr_frfu_rfifo_empty == 1'b0) begin
          rd_stm_ns    = 2'b01 ;
          rdback_data_b0_en 	= 1'b1 ;
        end
      end
      2'b01: begin
        if (frwf_frfu_crf_full == 1'b0) begin
          if ( post_cksum_en == 1'b1 )		//JC
	      begin
            frfu_ffsr_rfifo_rd_en = 1'b1;
            //frfu_frwf_crf_wr_en	= 1'b1 ;	//JC
            rdback_data_b1_en     = 1'b1;
            rd_stm_ns             = 2'b00;
          end else begin
            frfu_ffsr_rfifo_rd_en = 1'b1;
            frfu_frwf_crf_wr_en   = 1'b1;
            rdback_data_b1_en     = 1'b1;
            rd_stm_ns             = 2'b00;
          end
        end
      end
      default: begin
        rd_stm_ns = 2'b00;
      end
    endcase
  end

  //========================================================================//
  //==	CHECKSUM 							--//
  //========================================================================// 
  assign frfu_frwf_crf_wr_data[31:0] = ffsr_frfu_rfifo_rdata[31:0];

  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      ffsr_frfu_clr_fb_cfg_kickoff_dly1cyc <= #PAR_DLY 1'b0;
      ffsr_frfu_clr_fb_cfg_kickoff_dly2cyc <= #PAR_DLY 1'b0;
    end else begin
      ffsr_frfu_clr_fb_cfg_kickoff_dly1cyc <= #PAR_DLY ffsr_frfu_clr_fb_cfg_kickoff;
      ffsr_frfu_clr_fb_cfg_kickoff_dly2cyc <= #PAR_DLY ffsr_frfu_clr_fb_cfg_kickoff_dly1cyc;
    end
  end

  always @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      chksum_c0 <= #PAR_DLY 16'h0;
      chksum_c1 <= #PAR_DLY 16'h0;
    end
  else if (ffsr_frfu_clr_fb_cfg_kickoff_dly1cyc==1'b1 && ffsr_frfu_clr_fb_cfg_kickoff_dly2cyc==1'b0 )
    begin
      chksum_c0 <= #PAR_DLY 16'h0;
      chksum_c1 <= #PAR_DLY 16'h0;
    end else if (pre_cksum_en == 1'b1 && fcbrfuwff_chksum_b0_en == 1'b1) begin
      chksum_c0 <= chksum_c0 + frfu_ffsr_wfifo_wdata[15:0];
      chksum_c1 <= chksum_c1 + chksum_c0 + frfu_ffsr_wfifo_wdata[15:0];
    end else if (pre_cksum_en == 1'b1 && fcbrfuwff_chksum_b1_en == 1'b1) begin
      chksum_c0 <= chksum_c0 + frfu_ffsr_wfifo_wdata[31:16];
      chksum_c1 <= chksum_c1 + chksum_c0 + frfu_ffsr_wfifo_wdata[31:16];
    end else if (post_cksum_en == 1'b1 && rdback_data_b0_en == 1'b1) begin
      chksum_c0 <= chksum_c0 + ffsr_frfu_rfifo_rdata[15:0];
      chksum_c1 <= chksum_c1 + chksum_c0 + ffsr_frfu_rfifo_rdata[15:0];
    end else if (post_cksum_en == 1'b1 && rdback_data_b1_en == 1'b1) begin
      chksum_c0 <= chksum_c0 + ffsr_frfu_rfifo_rdata[31:16];
      chksum_c1 <= chksum_c1 + chksum_c0 + ffsr_frfu_rfifo_rdata[31:16];
    end
  end

  //--------------------------------------------------------------------------------//
  //-- END									--//
  //--------------------------------------------------------------------------------//
endmodule
