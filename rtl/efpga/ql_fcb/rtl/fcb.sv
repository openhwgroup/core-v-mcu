// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

module fcb #(
    parameter PAR_QLFCB_FB_TAMAR_CFG = 8'b0,  //
    parameter PAR_QLFCB_DEFAULT_ON = 1'b1,  //
    parameter [7:0] PAR_QLFCB_DEVICE_ID = 8'h21,  //
    parameter [10:0] PAR_QLFCB_11BIT_100NS = 11'h00A,  // 1: Default ON, 0: Default Off
    parameter [10:0] PAR_QLFCB_11BIT_200NS = 11'h014,  // Default Assume 100MHz
    parameter [10:0] PAR_QLFCB_11BIT_1US = 11'h064,  // Default Assume 100MHz
    parameter [10:0] PAR_QLFCB_11BIT_10US = 11'h3E8,  // Default Assume 100MHz
    parameter [5:0] PAR_QLFCB_6BIT_125NS = 6'h0d,  // Default Assume 100MHz
    parameter [5:0] PAR_QLFCB_6BIT_250NS = 6'h19,  // Default Assume 100MHz
    parameter [15:0] PAR_RAMFIFO_CFG  		= 16'b0000_0000_0000_0000     //Define the RAMFIFO which Read back data
) (
    //------------------------------------------------------------------------//
    //-- INPUT PORT                                                         --//
    //------------------------------------------------------------------------//
    input logic fcb_sys_clk,  //Main Clock for FCB except SPI Slave Int
    input logic fcb_sys_rst_n,  //Main Reset for FCB except SPI Slave int
    input logic fcb_spis_clk,  //Clock for SPIS Slave Interface
    input logic fcb_spis_rst_n,  //Reset for SPIS slave Interface, it is a
    input logic fcb_sys_stm,  //1'b1 : Put the module into Test Mode
    input logic fcb_spim_miso,  //SPI Master MISO
    input logic fcb_spim_ckout_in,  //SPI Master Loop Back Clock
    input logic fcb_spis_mosi,  //SPI Slave MOSI
    input logic fcb_spis_cs_n,  //SPI Slave Chip Select
    input logic fcb_pif_vldi,  //PIF Input Data Valid
    input logic [3:0] fcb_pif_di_l,  //PIF Input Data, Lower 4 Bits
    input logic [3:0] fcb_pif_di_h,  //PIF Input Data, Higher 4 Bits
    //input logic [7:0]             fcb_device_id_bo ,      //Device ID for Register 0x3
    //input logic                   fcb_vlp,      		//1'b1 Put the FB Macro into VLP Mode. 1'
    input logic fcb_spi_mode_en_bo,  //1'b1 : SPI Master/Slave is Enable. 1'b0
    input logic fcb_pif_en,  //1'b1 : Enable the PIF mode. Note this b
    input logic fcb_pif_8b_mode_bo,  //1'b1 : PIF DI/DO are 8 bits and in Simp
    input logic [19:0] fcb_apbs_paddr,  //APB Address in byte Resolution. Up to 1
    input logic [2:0] fcb_apbs_pprot,  //ABP PPROT, If FCB_APB_PROT_EN is 1, the
    input logic fcb_apbs_psel,  //APB Slave select signal
    input logic fcb_apbs_penable,  //APB Enable signal for data transfer
    input logic fcb_apbs_pwrite,  //APB write Enable Signal
    input logic [31:0] fcb_apbs_pwdata,  //APB Write Data
    input logic [3:0] fcb_apbs_pstrb,  //APB Byte Enable.
    input logic [31:0] fcb_bl_dout,  //Fabric BL Read Data
    input logic [17:0] fcb_apbm_prdata_0,  //APB Read Data, the RAMFIFO will impleme
    input logic [17:0] fcb_apbm_prdata_1,  //APB Read Data, the RAMFIFO will impleme
    input logic fcb_spi_master_en,  //FCB Master Enable form Boot Strap Pin.
    //input logic			fcb_fb_default_on_bo,	//eFPGA Macro Default Power State
    //input logic			fcb_clp_mode_en_bo, 	//1'b1 : Chip Level, 1'b0 Quardant
    //------------------------------------------------------------------------//
    //-- OUTPUT PORT                                                        --//
    //------------------------------------------------------------------------//
    output logic fcb_cfg_done,  //Cfg Done
    output logic fcb_cfg_done_en,  //Cfg Done Output Enable
    //output logic [3:0]            fcb_io_sv_180 , 	//Select the IO Supply Voltage, 0x0 : 3.3
    output logic fcb_spim_mosi,  //SPI Master MOSI
    output logic fcb_spim_mosi_en,  //SPI Master MOSI output enable
    output logic fcb_spim_cs_n,  //SPI Master Chip Select
    output logic fcb_spim_cs_n_en,  //SPI Master Chip Select enable
    output logic fcb_spim_ckout,  //SPI Master Clock Output
    output logic fcb_spim_ckout_en,  //SPI Master Clock Output Enable
    output logic fcb_spis_miso,  //SPI Slave MISO
    output logic fcb_spis_miso_en,  //SPI Slave MISO output enable
    output logic fcb_pif_vldo,  //PIF Output Data Valid
    output logic fcb_pif_vldo_en,  //PIF Output Data Valid Output Enable
    output logic [3:0] fcb_pif_do_l,  //PIF Output Data, Lower 4 Bits
    output logic fcb_pif_do_l_en,  //PIF Output Data Output Enable for Lower
    output logic [3:0] fcb_pif_do_h,  //PIF Output Data, Higher 4 Bits
    output logic fcb_pif_do_h_en,  //PIF Output Data Output Enable for Highe
    output logic fcb_apbs_pready,  //APB Slave Ready Signal
    output logic [31:0] fcb_apbs_prdata,  //APB READ Data
    output logic fcb_apbs_pslverr,  //ABP Error Response
    output logic fcb_blclk,  //Fabric Bit Line Clock, Does not need to
    output logic fcb_re,  //Fabric Read Enable
    output logic fcb_we,  //Fabric Write Enable
    output logic fcb_we_int,  //Fabric Write Enable Left/write Interfac
    output logic fcb_pchg_b,  //Fabric Pre-Charge, Low active
    output logic [31:0] fcb_bl_din,  //Fabric BL Write Data
    output logic fcb_cload_din_sel,  //Fabric Column Load Data in Select
    output logic fcb_din_slc_tb_int,  //Fabric Bit Line Shift Register Data In	//JC
    output logic fcb_din_int_l_only,  //Fabric Bit line shift register Data in
    output logic fcb_din_int_r_only,  //Fabric Bit Line Shift Register Data in
    output logic [15:0] fcb_bl_pwrgate,  //Fabric Bit Line Cfg Shift Register Powe
    output logic fcb_wlclk,  //Fabric Word Line Clock, Does not need t
    output logic fcb_wl_resetb,  //Fabric Word Line Shift Register Bank Re
    output logic fcb_wl_en,  //Fabric Word Line enable
    output logic [15:0] fcb_wl_sel,  //Fabric Word Line Select
    output logic [2:0] fcb_wl_cload_sel,  //Fabric Word Line Column Load Select
    output logic [7:0] fcb_wl_pwrgate,  //Fabric Word Line Power Gate Control. 1'
    output logic [5:0] fcb_wl_din,  //Fabric Word Line Shfit Register Data In
    output logic fcb_wl_int_din_sel,  //Fabric Word Line interface Data in Sele
    output logic [15:0] fcb_prog,  //Fabric Configuration Enable for Quads,
    output logic fcb_prog_ifx,  //Fabric Configuration Enable for IFX, Hi
    output logic fcb_wl_sel_tb_int,  //Disable the TB Configuration during Qua
    output logic [15:0] fcb_iso_en,  //Fabric ISO Enable, 0x1->Isolation Enabl
    output logic [15:0] fcb_pi_pwr,  //Fabric Power Down Enable, 0x1->Power Do
    output logic [15:0] fcb_vlp_clkdis,  //Fabric Clock Function Disable Signal fo
    output logic fcb_vlp_clkdis_ifx,  //Fabric Clock Function Disable signal fo
    output logic [15:0] fcb_vlp_srdis,  //Fabric Set/Reset Function Disable Signa
    output logic fcb_vlp_srdis_ifx,  //Fabric Set/Reset Function Disable signa
    output logic [15:0] fcb_vlp_pwrdis,  //Fabric VLP Power Down signals for Quads
    output logic fcb_vlp_pwrdis_ifx,  //Fabric VLP Power Down signals for Inter
    output logic [11:0] fcb_apbm_paddr,  //APB Address in byte Resolution, Bit 11
    output logic [7:0] fcb_apbm_psel,  //APB Slave Select Signals. Bit 0 is used
    output logic fcb_apbm_penable,  //APB Enable signal for data transfer
    output logic fcb_apbm_pwrite,  //APB write Enable Signal
    output logic [17:0] fcb_apbm_pwdata,  //APB Write Data
    output logic fcb_apbm_ramfifo_sel,  //1'b1 : RAMFIFO APB Interface Enable.
    output logic fcb_apbm_mclk,  //APB Master Clock
    output logic fcb_rst,  // Now this is for Tamar Only
    //output logic [15:0]           fcb_rst ,       	//Fabric Reset
    //output logic                  fcb_tb_rst ,    	//TB Reset
    //output logic                  fcb_lr_rst ,    	//LR Reset
    //output logic                  fcb_iso_rst ,   	//Isolation Reset
    output logic fcb_sysclk_en,  //1'b1 : Turn on the RC/SYS clock. Note:
    output logic fcb_fb_cfg_done,  //Indicate the Fabric Configuration is do
    //output logic                  fcb_clp_cfg_done ,	//New Added
    output logic fcb_clp_cfg_done_n,  //New Added
    output logic fcb_clp_cfg_enb,  //New Added
    output logic fcb_clp_lth_enb,  //New Added
    output logic fcb_clp_pwr_gate,  //New Added
    output logic fcb_clp_vlp,  //New Added
    output logic fcb_fb_iso_enb,  //JC
    output logic fcb_pwr_gate,  //JC
    output logic fcb_set_por,  //JC this signal need to be handle outside by customer's logic
    output logic fcb_clp_set_por,  //POR Signal JC
    output logic fcb_spi_master_status  //New Added
);
  `protect

  //------------------------------------------------------------------------//
  //-- Local Parameter                                                    --//
  //------------------------------------------------------------------------//
  localparam PAR_DLY = 1'b1;

  //------------------------------------------------------------------------//
  //-- Wire/Flops                                                         --//
  //------------------------------------------------------------------------//
  logic [ 7:0] fcb_device_id_bo;  //Device ID for Register 0x3
  logic        fcb_clp_mode_en_bo;  //1'b1 : Chip Level, 1'b0 Quardant
  logic        fcb_fb_default_on_bo;  //1'b1 : Default ON
  //----------------------------------------------------------------//
  //-- fcbrfu Instance                                      --//
  //----------------------------------------------------------------//
  logic [ 7:0] frfu_fsmc_spim_ckb_0;
  logic [ 7:0] frfu_fsmc_spim_ckb_1;
  logic [ 7:0] frfu_bl_pw_cfg_0;
  logic [ 7:0] frfu_bl_pw_cfg_1;
  logic        frfu_cwf_full;
  logic [ 7:0] frfu_ffsr_bl_cnt_h;
  logic [ 7:0] frfu_ffsr_bl_cnt_l;
  logic [ 3:0] frfu_ffsr_cfg_wrp_ccnt;
  logic [ 3:0] frfu_ffsr_rcfg_wrp_ccnt;
  logic [ 7:0] frfu_ffsr_col_cnt;
  logic [ 7:0] frfu_ffsr_fb_cfg_cmd;
  logic        frfu_ffsr_fb_cfg_kickoff;
  logic [ 7:0] frfu_ffsr_ram_cfg_0_en;
  logic [ 7:0] frfu_ffsr_ram_cfg_1_en;
  logic [ 7:0] frfu_ffsr_ram_data_width;
  logic [ 7:0] frfu_ffsr_ram_size_b0;
  logic [ 7:0] frfu_ffsr_ram_size_b1;
  logic        frfu_ffsr_rfifo_rd_en;
  logic [31:0] frfu_ffsr_wfifo_wdata;
  logic        frfu_ffsr_wfifo_wr_en;
  logic [ 7:0] frfu_ffsr_wl_cnt_h;
  logic [ 7:0] frfu_ffsr_wl_cnt_l;
  logic        frfu_fmic_done_op_mask_n;
  logic        frfu_fmic_fb_cfg_done;
  logic [ 3:0] frfu_fmic_io_sv_180;
  logic        frfu_fmic_rc_clk_en;
  logic        frfu_fmic_vlp_pin_en;
  //logic [7:0]             	frfu_fpmu_iso_en_0 ;
  //logic [7:0]             	frfu_fpmu_iso_en_1 ;
  logic [ 7:0] frfu_fpmu_iso_en_sd_0;
  logic [ 7:0] frfu_fpmu_iso_en_sd_1;
  //logic [7:0]             	frfu_fpmu_pi_pwr_0 ;
  //logic [7:0]             	frfu_fpmu_pi_pwr_1 ;
  logic [ 7:0] frfu_fpmu_pi_pwr_sd_0;
  logic [ 7:0] frfu_fpmu_pi_pwr_sd_1;
  //logic                           frfu_fpmu_pmu_chip_vlp_en ;
  //logic                           frfu_fpmu_pmu_chip_vlp_wu_en ;
  logic        frfu_fpmu_pmu_mux_sel_sd;
  //logic                           frfu_fpmu_pmu_mux_up_sd ;
  logic [ 5:0] frfu_fpmu_pmu_pwr_gate_ccnt;
  logic [ 7:0] frfu_fpmu_pmu_timer_ccnt;
  //logic                           frfu_fpmu_prog_pmu_chip_vlp_en ;
  //logic                           frfu_fpmu_prog_pmu_chip_wu_en ;
  //logic [7:0]             	frfu_fpmu_quad_pd_en_b0 ;
  //logic [7:0]             	frfu_fpmu_quad_pd_en_b1 ;
  //logic [1:0]                     frfu_fpmu_quad_pd_mode ;
  //logic [7:0]             	frfu_fpmu_quad_wu_en_b0 ;
  //logic [7:0]             	frfu_fpmu_quad_wu_en_b1 ;
  //logic [1:0]                     frfu_fpmu_quad_wu_mode ;
  logic        frfu_fpmu_vlp_clkdis_ifx_sd;
  logic [ 7:0] frfu_fpmu_vlp_clkdis_sd_0;
  logic [ 7:0] frfu_fpmu_vlp_clkdis_sd_1;
  logic        frfu_fpmu_vlp_pwrdis_ifx_sd;
  logic [ 7:0] frfu_fpmu_vlp_pwrdis_sd_0;
  logic [ 7:0] frfu_fpmu_vlp_pwrdis_sd_1;
  //logic [7:0]             	frfu_fpmu_vlp_sd_0 ;
  //logic [7:0]             	frfu_fpmu_vlp_sd_1 ;
  logic        frfu_fpmu_vlp_srdis_ifx_sd;
  logic [ 7:0] frfu_fpmu_vlp_srdis_sd_0;
  logic [ 7:0] frfu_fpmu_vlp_srdis_sd_1;
  logic [31:0] frfu_frwf_crf_wr_data;
  logic        frfu_frwf_crf_wr_en;
  logic        frfu_fsmc_checksum_enable;
  logic        frfu_fsmc_checksum_status;
  logic        frfu_fsmc_pending_pd_req;
  logic        frfu_fsmc_rc_clk_dis_cfg;
  logic [ 7:0] frfu_fsmc_spim_baud_rate;
  logic [ 7:0] frfu_fsmc_spim_device_id;
  logic        frfu_fsmc_sw2_spis;
  logic [ 7:0] frfu_sfr_rd_data;
  logic [ 7:0] frfu_wl_pw_cfg;
  //logic [7:0]             	frfu_wr_data_port ;
  logic [ 7:0] frfu_wrd_cnt_b0;
  logic [ 7:0] frfu_wrd_cnt_b1;
  logic [ 7:0] frfu_wrd_cnt_b2;

  //----------------------------------------------------------------//
  //-- fcbssc Instance                                      --//
  //----------------------------------------------------------------//
  logic [ 7:0] fssc_frfu_cwf_wr_data;
  logic        fssc_frfu_cwf_wr_en;
  logic [ 6:0] fssc_frfu_rd_addr;
  logic        fssc_frfu_rd_en;
  logic        fssc_frfu_spis_on;
  logic [ 6:0] fssc_frfu_wr_addr;
  logic [ 7:0] fssc_frfu_wr_data;
  logic        fssc_frfu_wr_en;

  //----------------------------------------------------------------//
  //-- fcbsmc Instance                                      --//
  //----------------------------------------------------------------//
  logic        fsmc_frfu_clr_rcclk_en;
  logic        fsmc_fmic_clr_spi_master_en;
  logic        fsmc_fmic_fsmc_busy;
  logic        fsmc_fmic_seq_done;
  logic [ 7:0] fsmc_frfu_cwf_wr_data;
  logic        fsmc_frfu_cwf_wr_en;
  logic [ 6:0] fsmc_frfu_rd_addr;
  logic        fsmc_frfu_rd_en;
  logic        fsmc_frfu_set_fb_cfg_done;
  logic        fsmc_frfu_spim_on;
  logic [ 6:0] fsmc_frfu_wr_addr;
  logic [ 7:0] fsmc_frfu_wr_data;
  logic        fsmc_frfu_wr_en;
  //----------------------------------------------------------------//
  //-- fcbrwf Instance                                      --//
  //----------------------------------------------------------------//
  logic        frwf_crf_empty;
  logic        frwf_crf_empty_p1;
  logic [31:0] frwf_crf_rd_data;
  logic        frwf_frfu_crf_full;
  logic        frwf_frfu_crf_full_m1;
  logic [31:0] frwf_frfu_cwf_wr_data;
  logic        frwf_frfu_cwf_wr_en;
  logic        frwf_frfu_frwf_on;
  logic [ 6:0] frwf_frfu_rd_addr;
  logic        frwf_frfu_rd_en;
  logic [ 6:0] frwf_frfu_wr_addr;
  logic [ 7:0] frwf_frfu_wr_data;
  logic        frwf_frfu_wr_en;
  logic        frwf_wff_full;
  logic        frwf_wff_full_m1;
  //----------------------------------------------------------------//
  //-- fcbpmu Instance                                      --//
  //----------------------------------------------------------------//

  //logic                         fpmu_frfu_clr_pmu_chip_vlp_en ;
  //logic                         fpmu_frfu_clr_pmu_chip_wu_en ;

  //logic [7:0]             	fpmu_frfu_clr_quad_pd_en_b0 ;
  //logic [7:0]             	fpmu_frfu_clr_quad_pd_en_b1 ;
  //logic                         fpmu_frfu_clr_quad_pd_wr_en_b0 ;
  //logic                         fpmu_frfu_clr_quad_pd_wr_en_b1 ;
  //logic [7:0]             	fpmu_frfu_clr_quad_wu_en_b0 ;
  //logic [7:0]             	fpmu_frfu_clr_quad_wu_en_b1 ;
  //logic                         fpmu_frfu_clr_quad_wu_wr_en_b0 ;
  //logic                         fpmu_frfu_clr_quad_wu_wr_en_b1 ;
  logic [ 1:0] fpmu_frfu_pw_sta_00;
  logic [ 1:0] fpmu_frfu_pw_sta_01;
  logic [ 1:0] fpmu_frfu_pw_sta_02;
  logic [ 1:0] fpmu_frfu_pw_sta_03;
  logic [ 1:0] fpmu_frfu_pw_sta_10;
  logic [ 1:0] fpmu_frfu_pw_sta_11;
  logic [ 1:0] fpmu_frfu_pw_sta_12;
  logic [ 1:0] fpmu_frfu_pw_sta_13;
  logic [ 1:0] fpmu_frfu_pw_sta_20;
  logic [ 1:0] fpmu_frfu_pw_sta_21;
  logic [ 1:0] fpmu_frfu_pw_sta_22;
  logic [ 1:0] fpmu_frfu_pw_sta_23;
  logic [ 1:0] fpmu_frfu_pw_sta_30;
  logic [ 1:0] fpmu_frfu_pw_sta_31;
  logic [ 1:0] fpmu_frfu_pw_sta_32;
  logic [ 1:0] fpmu_frfu_pw_sta_33;
  logic        fpmu_pmu_busy;


  logic        frfu_fclp_cfg_done;  //Configure Done Signal, Used to Clear LT
  logic        frfu_fclp_clp_vlp_wu_en;  //VLP WU enable
  logic        frfu_fclp_clp_vlp_en;  //VLP Enable
  logic        frfu_fclp_clp_pd_wu_en;  //PD WU enable
  logic        frfu_fclp_clp_pd_en;  //PD enable
  logic [ 1:0] frfu_fclp_clp_time_ctl;  //Internal Timing Configure
  logic [ 1:0] frfu_ffsr_wlblclk_cfg;


  //----------------------------------------------------------------//
  //-- fcbpif Instance                                      --//
  //----------------------------------------------------------------//
  logic        fpif_frwf_crf_rd_en;
  logic        fpif_frwf_pif_on;
  logic [39:0] fpif_frwf_wff_wr_data;
  logic        fpif_frwf_wff_wr_en;

  //----------------------------------------------------------------//
  //-- fcbmic Instance                                      --//
  //----------------------------------------------------------------//
  logic        fmic_frfu_set_pmu_chip_vlp_en;
  logic        fmic_frfu_set_pmu_chip_wu_en;
  logic        fmic_frfu_set_rc_clk_en;
  logic        fmic_spi_master_en;
  //----------------------------------------------------------------//
  //-- fcbfsr Instance                                      --//
  //----------------------------------------------------------------//
  logic        ffsr_frfu_clr_fb_cfg_kickoff;
  logic        ffsr_frfu_rfifo_empty;
  logic        ffsr_frfu_rfifo_empty_p1;
  logic [31:0] ffsr_frfu_rfifo_rdata;
  logic        ffsr_frfu_wfifo_full;
  logic        ffsr_frfu_wfifo_full_m1;
  logic        ffsr_fsr_busy;
  //----------------------------------------------------------------//
  //-- fcbaps Instance                                      --//
  //----------------------------------------------------------------//
  logic        faps_frwf_apb_on;
  logic        faps_frwf_crf_rd_en;
  logic [39:0] faps_frwf_wff_wr_data;
  logic        faps_frwf_wff_wr_en;
  //----------------------------------------------------------------//
  //-- fcbclp Instance                                      --//
  //----------------------------------------------------------------//
  logic        fclp_clp_busy;
  logic        fclp_frfu_clear_cfg_done;
  logic        fclp_frfu_clear_pd_en;
  logic        fclp_frfu_clear_pd_wu_en;
  logic        fclp_frfu_clear_vlp_en;
  logic        fclp_frfu_clear_vlp_wu_en;
  logic [ 1:0] fclp_frfu_clp_pw_sta;

  logic        fsmc_frfu_set_pd;
  logic        fsmc_frfu_set_clp_pd;

  //logic				frfu_fpmu_pmu_chip_pd_en ;
  //logic				frfu_fpmu_prog_pmu_chip_pd_en ;
  //logic				fpmu_frfu_clr_pmu_chip_pd_en ;
  logic [ 1:0] fpmu_frfu_chip_pw_sta;  //     // JC 05232017
  //logic				frfu_fpmu_prog_pmu_quad_pd_en ;
  //logic				frfu_fpmu_prog_pmu_quad_wu_en ;
  logic        frfu_fpmu_prog_cfg_done;
  logic        frfu_fpmu_clr_cfg_done;
  logic        fpmu_frfu_clr_cfg_done;
  logic        fpmu_frfu_clr_pmu_chip_cmd;
  logic        frfu_fpmu_prog_pmu_chip_cmd;
  logic [ 3:0] frfu_fpmu_pmu_chip_cmd;
  logic [ 7:0] frfu_fpmu_quad_cfg_b0;
  logic [ 7:0] frfu_fpmu_quad_cfg_b1;
  logic        fpmu_frfu_clr_quads;
  logic [ 1:0] frfu_fpmu_pmu_time_ctl;
  //logic				fcb_fb_iso_enb ;
  logic        frfu_fpmu_fb_cfg_done;

  logic        frfu_fpmu_fb_iso_enb_sd;
  logic        frfu_fpmu_pwr_gate_sd;
  logic        frfu_fpmu_prog_ifx_sd;
  logic        frfu_fpmu_set_por_sd;
  logic [ 7:0] frfu_fpmu_prog_sd_0;
  logic [ 7:0] frfu_fpmu_prog_sd_1;
  logic        fpmu_frfu_pmu_busy;
  logic        fsmc_frfu_set_quad_pd;

  logic        fcb_clp_cfg_done;  //New Added
  logic        fpmu_frfu_fb_cfg_cleanup;
  logic        fclp_frfu_fb_cfg_cleanup;

  logic [ 1:0] frfu_ffsr_blclk_sut;  //JC 07
  logic [ 1:0] frfu_ffsr_wlclk_sut;  //JC 07
  logic [ 1:0] frfu_ffsr_wlen_sut;  //JC 07

  logic        frwf_frfu_ff0_of;


  //--------------------------------------------------------------------------------//
  //-- Start Functional Description                                               --//
  //--------------------------------------------------------------------------------//
  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  assign fcb_device_id_bo = PAR_QLFCB_DEVICE_ID;  //Device ID for Register 0x3

  assign fcb_clp_mode_en_bo 	= ( PAR_QLFCB_FB_TAMAR_CFG == 8'b0000_0001 )
				? 1'b1 : 1'b0 ;	// 1'b1: Tamar Cfg, 1'b0: Cali Cfg

  assign fcb_fb_default_on_bo	= ( PAR_QLFCB_DEFAULT_ON == 1'b1 )
				? 1'b1 : 1'b0 ; // 1'b1: Default ON, 1'b0: Default OFF

  //----------------------------------------------------------------//
  //-- fcbrfu Instance                                      --//
  //----------------------------------------------------------------//
  fcbrfu fcbrfu_INST (
      //------------------------------------------------------------//
      //-- INPUT                                                  --//
      //------------------------------------------------------------//
      .fcb_clp_mode_en_bo           (fcb_clp_mode_en_bo),
      .fcb_device_id_bo             (fcb_device_id_bo[7:0]),
      .fcb_sys_clk                  (fcb_sys_clk),
      .fcb_sys_rst_n                (fcb_sys_rst_n),
      .fcb_sys_stm                  (fcb_sys_stm),
      //.fcb_vlp                        	(fcb_vlp	) ,
      .fcb_vlp                      (1'b0),
      .ffsr_frfu_clr_fb_cfg_kickoff (ffsr_frfu_clr_fb_cfg_kickoff),
      .ffsr_frfu_rfifo_empty        (ffsr_frfu_rfifo_empty),
      .ffsr_frfu_rfifo_rdata        (ffsr_frfu_rfifo_rdata[31:0]),
      .ffsr_frfu_wfifo_full         (ffsr_frfu_wfifo_full),
      .ffsr_frfu_wfifo_full_m1      (ffsr_frfu_wfifo_full_m1),
      .fmic_frfu_set_pmu_chip_vlp_en(fmic_frfu_set_pmu_chip_vlp_en),
      .fmic_frfu_set_pmu_chip_wu_en (fmic_frfu_set_pmu_chip_wu_en),
      .fmic_frfu_set_rc_clk_en      (fmic_frfu_set_rc_clk_en),
      .fsmc_frfu_clr_rcclk_en       (fsmc_frfu_clr_rcclk_en),
      //.fpmu_frfu_clr_pmu_chip_vlp_en          (fpmu_frfu_clr_pmu_chip_vlp_en  ) ,
      //.fpmu_frfu_clr_pmu_chip_wu_en           (fpmu_frfu_clr_pmu_chip_wu_en   ) ,
      //.fpmu_frfu_clr_quad_pd_en_b0            (fpmu_frfu_clr_quad_pd_en_b0[7:0]       ) ,
      //.fpmu_frfu_clr_quad_pd_en_b1            (fpmu_frfu_clr_quad_pd_en_b1[7:0]       ) ,
      //.fpmu_frfu_clr_quad_pd_wr_en_b0         (fpmu_frfu_clr_quad_pd_wr_en_b0 ) ,
      //.fpmu_frfu_clr_quad_pd_wr_en_b1         (fpmu_frfu_clr_quad_pd_wr_en_b1 ) ,
      //.fpmu_frfu_clr_quad_wu_en_b0            (fpmu_frfu_clr_quad_wu_en_b0[7:0]       ) ,
      //.fpmu_frfu_clr_quad_wu_en_b1            (fpmu_frfu_clr_quad_wu_en_b1[7:0]       ) ,
      //.fpmu_frfu_clr_quad_wu_wr_en_b0         (fpmu_frfu_clr_quad_wu_wr_en_b0 ) ,
      //.fpmu_frfu_clr_quad_wu_wr_en_b1         (fpmu_frfu_clr_quad_wu_wr_en_b1 ) ,
      .fpmu_frfu_pw_sta_00          (fpmu_frfu_pw_sta_00[1:0]),
      .fpmu_frfu_pw_sta_01          (fpmu_frfu_pw_sta_01[1:0]),
      .fpmu_frfu_pw_sta_02          (fpmu_frfu_pw_sta_02[1:0]),
      .fpmu_frfu_pw_sta_03          (fpmu_frfu_pw_sta_03[1:0]),
      .fpmu_frfu_pw_sta_10          (fpmu_frfu_pw_sta_10[1:0]),
      .fpmu_frfu_pw_sta_11          (fpmu_frfu_pw_sta_11[1:0]),
      .fpmu_frfu_pw_sta_12          (fpmu_frfu_pw_sta_12[1:0]),
      .fpmu_frfu_pw_sta_13          (fpmu_frfu_pw_sta_13[1:0]),
      .fpmu_frfu_pw_sta_20          (fpmu_frfu_pw_sta_20[1:0]),
      .fpmu_frfu_pw_sta_21          (fpmu_frfu_pw_sta_21[1:0]),
      .fpmu_frfu_pw_sta_22          (fpmu_frfu_pw_sta_22[1:0]),
      .fpmu_frfu_pw_sta_23          (fpmu_frfu_pw_sta_23[1:0]),
      .fpmu_frfu_pw_sta_30          (fpmu_frfu_pw_sta_30[1:0]),
      .fpmu_frfu_pw_sta_31          (fpmu_frfu_pw_sta_31[1:0]),
      .fpmu_frfu_pw_sta_32          (fpmu_frfu_pw_sta_32[1:0]),
      .fpmu_frfu_pw_sta_33          (fpmu_frfu_pw_sta_33[1:0]),
      .frwf_frfu_crf_full           (frwf_frfu_crf_full),
      .frwf_frfu_crf_full_m1        (frwf_frfu_crf_full_m1),
      .frwf_frfu_cwf_wr_data        (frwf_frfu_cwf_wr_data[31:0]),
      .frwf_frfu_cwf_wr_en          (frwf_frfu_cwf_wr_en),
      .frwf_frfu_frwf_on            (frwf_frfu_frwf_on),
      .frwf_frfu_rd_addr            (frwf_frfu_rd_addr[6:0]),
      .frwf_frfu_rd_en              (frwf_frfu_rd_en),
      .frwf_frfu_wr_addr            (frwf_frfu_wr_addr[6:0]),
      .frwf_frfu_wr_data            (frwf_frfu_wr_data[7:0]),
      .frwf_frfu_wr_en              (frwf_frfu_wr_en),
      .fsmc_frfu_cwf_wr_data        (fsmc_frfu_cwf_wr_data[7:0]),
      .fsmc_frfu_cwf_wr_en          (fsmc_frfu_cwf_wr_en),
      .fsmc_frfu_rd_addr            (fsmc_frfu_rd_addr[6:0]),
      .fsmc_frfu_rd_en              (fsmc_frfu_rd_en),
      .fsmc_frfu_set_fb_cfg_done    (fsmc_frfu_set_fb_cfg_done),
      .fsmc_frfu_spim_on            (fsmc_frfu_spim_on),
      .fsmc_frfu_wr_addr            (fsmc_frfu_wr_addr[6:0]),
      .fsmc_frfu_wr_data            (fsmc_frfu_wr_data[7:0]),
      .fsmc_frfu_wr_en              (fsmc_frfu_wr_en),
      .fssc_frfu_cwf_wr_data        (fssc_frfu_cwf_wr_data[7:0]),
      .fssc_frfu_cwf_wr_en          (fssc_frfu_cwf_wr_en),
      .fssc_frfu_rd_addr            (fssc_frfu_rd_addr[6:0]),
      .fssc_frfu_rd_en              (fssc_frfu_rd_en),
      .fssc_frfu_spis_on            (fssc_frfu_spis_on),
      .fssc_frfu_wr_addr            (fssc_frfu_wr_addr[6:0]),
      .fssc_frfu_wr_data            (fssc_frfu_wr_data[7:0]),
      .fssc_frfu_wr_en              (fssc_frfu_wr_en),
      .fclp_frfu_clear_vlp_en       (fclp_frfu_clear_vlp_en),
      .fclp_frfu_clear_vlp_wu_en    (fclp_frfu_clear_vlp_wu_en),
      .fclp_frfu_clear_pd_en        (fclp_frfu_clear_pd_en),
      .fclp_frfu_clear_pd_wu_en     (fclp_frfu_clear_pd_wu_en),
      .fclp_frfu_clp_pw_sta         (fclp_frfu_clp_pw_sta),
      .fclp_frfu_clear_cfg_done     (fclp_frfu_clear_cfg_done),
      .fsmc_frfu_set_pd             (fsmc_frfu_set_pd),  //JC
      .fsmc_frfu_set_clp_pd         (fsmc_frfu_set_clp_pd),  //JC
      //.fpmu_frfu_clr_pmu_chip_pd_en 		(fpmu_frfu_clr_pmu_chip_pd_en) , //JC
      .fpmu_frfu_chip_pw_sta        (fpmu_frfu_chip_pw_sta),  // JC 05232017
      .fpmu_frfu_pmu_busy           (fpmu_frfu_pmu_busy),
      .fpmu_frfu_clr_cfg_done       (fpmu_frfu_clr_cfg_done),  //JC
      .fpmu_frfu_clr_quads          (fpmu_frfu_clr_quads),  //JC 05242017
      .fpmu_frfu_clr_pmu_chip_cmd   (fpmu_frfu_clr_pmu_chip_cmd),  //JC
      .fpmu_frfu_fb_cfg_cleanup     (fpmu_frfu_fb_cfg_cleanup),
      .fclp_frfu_fb_cfg_cleanup     (fclp_frfu_fb_cfg_cleanup),
      .fsmc_frfu_set_quad_pd        (fsmc_frfu_set_quad_pd),
      .frwf_frfu_ff0_of             (frwf_frfu_ff0_of),
      //------------------------------------------------------------//
      //-- OUTPUT                                                 --//
      //------------------------------------------------------------//
      .frfu_ffsr_blclk_sut          (frfu_ffsr_blclk_sut),
      .frfu_ffsr_wlclk_sut          (frfu_ffsr_wlclk_sut),
      .frfu_ffsr_wlen_sut           (frfu_ffsr_wlen_sut),
      .frfu_fpmu_fb_iso_enb_sd      (frfu_fpmu_fb_iso_enb_sd),
      .frfu_fpmu_pwr_gate_sd        (frfu_fpmu_pwr_gate_sd),
      .frfu_fpmu_prog_ifx_sd        (frfu_fpmu_prog_ifx_sd),
      .frfu_fpmu_set_por_sd         (frfu_fpmu_set_por_sd),
      .frfu_fpmu_prog_sd_0          (frfu_fpmu_prog_sd_0),
      .frfu_fpmu_prog_sd_1          (frfu_fpmu_prog_sd_1),
      .frfu_fpmu_fb_cfg_done        (frfu_fpmu_fb_cfg_done),
      .frfu_fpmu_pmu_time_ctl       (frfu_fpmu_pmu_time_ctl),
      .frfu_fpmu_prog_pmu_chip_cmd  (frfu_fpmu_prog_pmu_chip_cmd),
      .frfu_fpmu_pmu_chip_cmd       (frfu_fpmu_pmu_chip_cmd[3:0]),
      .frfu_fpmu_quad_cfg_b0        (frfu_fpmu_quad_cfg_b0[7:0]),
      .frfu_fpmu_quad_cfg_b1        (frfu_fpmu_quad_cfg_b1[7:0]),
      .frfu_fpmu_prog_cfg_done      (frfu_fpmu_prog_cfg_done),  //JC
      .frfu_fpmu_clr_cfg_done       (frfu_fpmu_clr_cfg_done),  //JC
      //.frfu_fpmu_prog_pmu_quad_pd_en		(frfu_fpmu_prog_pmu_quad_pd_en	), 	//JC
      //.frfu_fpmu_prog_pmu_quad_wu_en		(frfu_fpmu_prog_pmu_quad_wu_en	), 	//JC
      //.frfu_fpmu_pmu_chip_pd_en		(frfu_fpmu_pmu_chip_pd_en	),	//JC
      //.frfu_fpmu_prog_pmu_chip_pd_en		(frfu_fpmu_prog_pmu_chip_pd_en 	),	//JC
      .frfu_fsmc_spim_ckb_0         (frfu_fsmc_spim_ckb_0[7:0]),
      .frfu_fsmc_spim_ckb_1         (frfu_fsmc_spim_ckb_1[7:0]),
      .fcb_fb_cfg_done              (fcb_fb_cfg_done),
      .ffsr_frfu_rfifo_empty_p1     (ffsr_frfu_rfifo_empty_p1),
      .frfu_bl_pw_cfg_0             (frfu_bl_pw_cfg_0[7:0]),
      .frfu_bl_pw_cfg_1             (frfu_bl_pw_cfg_1[7:0]),
      .frfu_cwf_full                (frfu_cwf_full),
      .frfu_ffsr_bl_cnt_h           (frfu_ffsr_bl_cnt_h[7:0]),
      .frfu_ffsr_bl_cnt_l           (frfu_ffsr_bl_cnt_l[7:0]),
      .frfu_ffsr_cfg_wrp_ccnt       (frfu_ffsr_cfg_wrp_ccnt[3:0]),
      .frfu_ffsr_rcfg_wrp_ccnt      (frfu_ffsr_rcfg_wrp_ccnt[3:0]),
      .frfu_ffsr_col_cnt            (frfu_ffsr_col_cnt[7:0]),
      .frfu_ffsr_fb_cfg_cmd         (frfu_ffsr_fb_cfg_cmd[7:0]),
      .frfu_ffsr_fb_cfg_kickoff     (frfu_ffsr_fb_cfg_kickoff),
      .frfu_ffsr_ram_cfg_0_en       (frfu_ffsr_ram_cfg_0_en[7:0]),
      .frfu_ffsr_ram_cfg_1_en       (frfu_ffsr_ram_cfg_1_en[7:0]),
      .frfu_ffsr_ram_data_width     (frfu_ffsr_ram_data_width[7:0]),
      .frfu_ffsr_ram_size_b0        (frfu_ffsr_ram_size_b0[7:0]),
      .frfu_ffsr_ram_size_b1        (frfu_ffsr_ram_size_b1[7:0]),
      .frfu_ffsr_rfifo_rd_en        (frfu_ffsr_rfifo_rd_en),
      .frfu_ffsr_wfifo_wdata        (frfu_ffsr_wfifo_wdata[31:0]),
      .frfu_ffsr_wfifo_wr_en        (frfu_ffsr_wfifo_wr_en),
      .frfu_ffsr_wl_cnt_h           (frfu_ffsr_wl_cnt_h[7:0]),
      .frfu_ffsr_wl_cnt_l           (frfu_ffsr_wl_cnt_l[7:0]),
      .frfu_fmic_done_op_mask_n     (frfu_fmic_done_op_mask_n),
      .frfu_fmic_fb_cfg_done        (frfu_fmic_fb_cfg_done),
      .frfu_fmic_io_sv_180          (frfu_fmic_io_sv_180[3:0]),
      .frfu_fmic_rc_clk_en          (frfu_fmic_rc_clk_en),
      .frfu_fmic_vlp_pin_en         (frfu_fmic_vlp_pin_en),
      //.frfu_fpmu_iso_en_0                     (frfu_fpmu_iso_en_0[7:0]        )  ,	//XXX
      //.frfu_fpmu_iso_en_1                     (frfu_fpmu_iso_en_1[7:0]        )  ,	//XXX
      .frfu_fpmu_iso_en_sd_0        (frfu_fpmu_iso_en_sd_0[7:0]),
      .frfu_fpmu_iso_en_sd_1        (frfu_fpmu_iso_en_sd_1[7:0]),
      //.frfu_fpmu_pi_pwr_0                  (frfu_fpmu_pi_pwr_0[7:0]     )  ,	//XXX
      //.frfu_fpmu_pi_pwr_1                  (frfu_fpmu_pi_pwr_1[7:0]     )  ,
      .frfu_fpmu_pi_pwr_sd_0        (frfu_fpmu_pi_pwr_sd_0[7:0]),  //XXX
      .frfu_fpmu_pi_pwr_sd_1        (frfu_fpmu_pi_pwr_sd_1[7:0]),  //XXX
      //.frfu_fpmu_pmu_chip_vlp_en              (frfu_fpmu_pmu_chip_vlp_en      )  ,
      //.frfu_fpmu_pmu_chip_vlp_wu_en           (frfu_fpmu_pmu_chip_vlp_wu_en   )  ,
      .frfu_fpmu_pmu_mux_sel_sd     (frfu_fpmu_pmu_mux_sel_sd),
      //.frfu_fpmu_pmu_mux_up_sd                (frfu_fpmu_pmu_mux_up_sd        )  ,
      .frfu_fpmu_pmu_pwr_gate_ccnt  (frfu_fpmu_pmu_pwr_gate_ccnt[5:0]),
      .frfu_fpmu_pmu_timer_ccnt     (frfu_fpmu_pmu_timer_ccnt[7:0]),
      //.frfu_fpmu_prog_pmu_chip_vlp_en         (frfu_fpmu_prog_pmu_chip_vlp_en )  ,
      //.frfu_fpmu_prog_pmu_chip_wu_en      	(frfu_fpmu_prog_pmu_chip_wu_en      )  ,
      //.frfu_fpmu_quad_pd_en_b0                (frfu_fpmu_quad_pd_en_b0[7:0]   )  ,
      //.frfu_fpmu_quad_pd_en_b1                (frfu_fpmu_quad_pd_en_b1[7:0]   )  ,
      //.frfu_fpmu_quad_pd_mode                 (frfu_fpmu_quad_pd_mode )  ,
      //.frfu_fpmu_quad_wu_en_b0                (frfu_fpmu_quad_wu_en_b0[7:0]   )  ,
      //.frfu_fpmu_quad_wu_en_b1                (frfu_fpmu_quad_wu_en_b1[7:0]   )  ,
      //.frfu_fpmu_quad_wu_mode                 (frfu_fpmu_quad_wu_mode )  ,
      .frfu_fpmu_vlp_clkdis_ifx_sd  (frfu_fpmu_vlp_clkdis_ifx_sd),
      .frfu_fpmu_vlp_clkdis_sd_0    (frfu_fpmu_vlp_clkdis_sd_0[7:0]),
      .frfu_fpmu_vlp_clkdis_sd_1    (frfu_fpmu_vlp_clkdis_sd_1[7:0]),
      //.frfu_fpmu_vlp_ifx_sd                   (frfu_fpmu_vlp_ifx_sd   )  ,
      .frfu_fpmu_vlp_pwrdis_ifx_sd  (frfu_fpmu_vlp_pwrdis_ifx_sd),
      .frfu_fpmu_vlp_pwrdis_sd_0    (frfu_fpmu_vlp_pwrdis_sd_0[7:0]),
      .frfu_fpmu_vlp_pwrdis_sd_1    (frfu_fpmu_vlp_pwrdis_sd_1[7:0]),
      //.frfu_fpmu_vlp_sd_0                     (frfu_fpmu_vlp_sd_0[7:0]        )  , //XXX
      //.frfu_fpmu_vlp_sd_1                     (frfu_fpmu_vlp_sd_1[7:0]        )  , //XXX
      .frfu_fpmu_vlp_srdis_ifx_sd   (frfu_fpmu_vlp_srdis_ifx_sd),
      .frfu_fpmu_vlp_srdis_sd_0     (frfu_fpmu_vlp_srdis_sd_0[7:0]),
      .frfu_fpmu_vlp_srdis_sd_1     (frfu_fpmu_vlp_srdis_sd_1[7:0]),
      .frfu_frwf_crf_wr_data        (frfu_frwf_crf_wr_data[31:0]),
      .frfu_frwf_crf_wr_en          (frfu_frwf_crf_wr_en),
      .frfu_fsmc_checksum_enable    (frfu_fsmc_checksum_enable),
      .frfu_fsmc_checksum_status    (frfu_fsmc_checksum_status),
      .frfu_fsmc_pending_pd_req     (frfu_fsmc_pending_pd_req),
      .frfu_fsmc_rc_clk_dis_cfg     (frfu_fsmc_rc_clk_dis_cfg),
      .frfu_fsmc_spim_baud_rate     (frfu_fsmc_spim_baud_rate[7:0]),
      .frfu_fsmc_spim_device_id     (frfu_fsmc_spim_device_id[7:0]),
      .frfu_fsmc_sw2_spis           (frfu_fsmc_sw2_spis),
      .frfu_sfr_rd_data             (frfu_sfr_rd_data[7:0]),
      .frfu_wl_pw_cfg               (frfu_wl_pw_cfg[7:0]),
      //.frfu_wr_data_port                      (frfu_wr_data_port[7:0] )  ,
      .frfu_wrd_cnt_b0              (frfu_wrd_cnt_b0[7:0]),
      .frfu_wrd_cnt_b1              (frfu_wrd_cnt_b1[7:0]),
      .frfu_wrd_cnt_b2              (frfu_wrd_cnt_b2[7:0]),
      .frfu_fclp_cfg_done           (frfu_fclp_cfg_done),
      .frfu_fclp_clp_vlp_wu_en      (frfu_fclp_clp_vlp_wu_en),
      .frfu_fclp_clp_vlp_en         (frfu_fclp_clp_vlp_en),
      .frfu_fclp_clp_pd_wu_en       (frfu_fclp_clp_pd_wu_en),
      .frfu_fclp_clp_pd_en          (frfu_fclp_clp_pd_en),
      .frfu_fclp_clp_time_ctl       (frfu_fclp_clp_time_ctl),
      .frfu_ffsr_wlblclk_cfg        (frfu_ffsr_wlblclk_cfg)
  );

  //----------------------------------------------------------------//
  //-- fcbssc Instance                                      --//
  //----------------------------------------------------------------//
  fcbssc fcbssc_INST (
      //------------------------------------------------------------//
      //-- INPUT                                                  --//
      //------------------------------------------------------------//
      .fcb_spi_mode_en_bo   (fcb_spi_mode_en_bo),
      .fcb_spis_clk         (fcb_spis_clk),
      .fcb_spis_cs_n        (fcb_spis_cs_n),
      .fcb_spis_mosi        (fcb_spis_mosi),
      .fcb_spis_rst_n       (fcb_spis_rst_n),
      .fcb_sys_clk          (fcb_sys_clk),
      .fcb_sys_rst_n        (fcb_sys_rst_n),
      .fcb_sys_stm          (fcb_sys_stm),
      .fmic_spi_master_en   (fmic_spi_master_en),
      .frfu_cwf_full        (frfu_cwf_full),
      .frfu_sfr_rd_data     (frfu_sfr_rd_data[7:0]),
      //------------------------------------------------------------//
      //-- OUTPUT                                                 --//
      //------------------------------------------------------------//
      .fcb_spis_miso        (fcb_spis_miso),
      .fcb_spis_miso_en     (fcb_spis_miso_en),
      .fssc_frfu_cwf_wr_data(fssc_frfu_cwf_wr_data[7:0]),
      .fssc_frfu_cwf_wr_en  (fssc_frfu_cwf_wr_en),
      .fssc_frfu_rd_addr    (fssc_frfu_rd_addr[6:0]),
      .fssc_frfu_rd_en      (fssc_frfu_rd_en),
      .fssc_frfu_spis_on    (fssc_frfu_spis_on),
      .fssc_frfu_wr_addr    (fssc_frfu_wr_addr[6:0]),
      .fssc_frfu_wr_data    (fssc_frfu_wr_data[7:0]),
      .fssc_frfu_wr_en      (fssc_frfu_wr_en)
  );

  //----------------------------------------------------------------//
  //-- fcbsmc Instance                                      --//
  //----------------------------------------------------------------//
  fcbsmc fcbsmc_INST (
      //------------------------------------------------------------//
      //-- INPUT                                                  --//
      //------------------------------------------------------------//
      .fcb_spi_mode_en_bo         (fcb_spi_mode_en_bo),
      .fcb_spim_ckout_in          (fcb_spim_ckout_in),
      .fcb_spim_miso              (fcb_spim_miso),
      .fcb_sys_clk                (fcb_sys_clk),
      .fcb_sys_rst_n              (fcb_sys_rst_n),
      .fcb_sys_stm                (fcb_sys_stm),
      .ffsr_fsr_busy              (ffsr_fsr_busy),
      .fmic_spi_master_en         (fmic_spi_master_en),
      .fpmu_pmu_busy              (fpmu_pmu_busy),
      .fclp_clp_busy              (fclp_clp_busy),  //JC
      .fcb_clp_mode_en_bo         (fcb_clp_mode_en_bo),  //JC
      .frfu_cwf_full              (frfu_cwf_full),
      .frfu_fsmc_checksum_enable  (frfu_fsmc_checksum_enable),
      .frfu_fsmc_checksum_status  (frfu_fsmc_checksum_status),
      .frfu_fsmc_pending_pd_req   (frfu_fsmc_pending_pd_req),
      //.frfu_fsmc_rc_clk_dis_cfg             (frfu_fsmc_rc_clk_dis_cfg       ) ,
      .frfu_fsmc_rc_clk_dis_cfg   (1'b0),
      .frfu_fsmc_spim_ckb_0       (frfu_fsmc_spim_ckb_0[7:0]),
      .frfu_fsmc_spim_ckb_1       (frfu_fsmc_spim_ckb_1[7:0]),
      .frfu_fsmc_spim_device_id   (frfu_fsmc_spim_device_id[7:0]),
      .frfu_fsmc_sw2_spis         (frfu_fsmc_sw2_spis),
      .frfu_sfr_rd_data           (frfu_sfr_rd_data[7:0]),
      .frfu_spim_baud_rate        (frfu_fsmc_spim_baud_rate[7:0]),
      .frfu_wrd_cnt_b0            (frfu_wrd_cnt_b0[7:0]),
      .frfu_wrd_cnt_b1            (frfu_wrd_cnt_b1[7:0]),
      .frfu_wrd_cnt_b2            (frfu_wrd_cnt_b2[7:0]),
      //------------------------------------------------------------//
      //-- OUTPUT                                                 --//
      //------------------------------------------------------------//
      .fsmc_frfu_set_quad_pd      (fsmc_frfu_set_quad_pd),
      .fsmc_frfu_set_pd           (fsmc_frfu_set_pd),  //JC
      .fsmc_frfu_set_clp_pd       (fsmc_frfu_set_clp_pd),  //JC
      .fcb_spim_ckout             (fcb_spim_ckout),
      .fcb_spim_ckout_en          (fcb_spim_ckout_en),
      .fcb_spim_cs_n              (fcb_spim_cs_n),
      .fcb_spim_cs_n_en           (fcb_spim_cs_n_en),
      .fcb_spim_mosi              (fcb_spim_mosi),
      .fcb_spim_mosi_en           (fcb_spim_mosi_en),
      .fsmc_frfu_clr_rcclk_en     (fsmc_frfu_clr_rcclk_en),
      .fsmc_fmic_clr_spi_master_en(fsmc_fmic_clr_spi_master_en),
      .fsmc_fmic_fsmc_busy        (fsmc_fmic_fsmc_busy),
      .fsmc_frfu_cwf_wr_data      (fsmc_frfu_cwf_wr_data[7:0]),
      .fsmc_frfu_cwf_wr_en        (fsmc_frfu_cwf_wr_en),
      .fsmc_frfu_rd_addr          (fsmc_frfu_rd_addr[6:0]),
      .fsmc_frfu_rd_en            (fsmc_frfu_rd_en),
      .fsmc_frfu_set_fb_cfg_done  (fsmc_frfu_set_fb_cfg_done),
      .fsmc_frfu_spim_on          (fsmc_frfu_spim_on),
      .fsmc_frfu_wr_addr          (fsmc_frfu_wr_addr[6:0]),
      .fsmc_frfu_wr_data          (fsmc_frfu_wr_data[7:0]),
      .fsmc_fmic_seq_done         (fsmc_fmic_seq_done),
      .fsmc_frfu_wr_en            (fsmc_frfu_wr_en)
  );


  //----------------------------------------------------------------//
  //-- fcbrwf Instance                                      --//
  //----------------------------------------------------------------//
  fcbrwf fcbrwf_INST (
      //------------------------------------------------------------//
      //-- INPUT                                                  --//
      //------------------------------------------------------------//
      .faps_frwf_apb_on     (faps_frwf_apb_on),
      .faps_frwf_crf_rd_en  (faps_frwf_crf_rd_en),
      .faps_frwf_wff_wr_data(faps_frwf_wff_wr_data[39:0]),
      .faps_frwf_wff_wr_en  (faps_frwf_wff_wr_en),
      .fcb_sys_clk          (fcb_sys_clk),
      .fcb_sys_rst_n        (fcb_sys_rst_n),
      .fcb_sys_stm          (fcb_sys_stm),
      .fpif_frwf_crf_rd_en  (fpif_frwf_crf_rd_en),
      .fpif_frwf_pif_on     (fpif_frwf_pif_on),
      .fpif_frwf_wff_wr_data(fpif_frwf_wff_wr_data[39:0]),
      .fpif_frwf_wff_wr_en  (fpif_frwf_wff_wr_en),
      .frfu_cwf_full        (frfu_cwf_full),
      .frfu_frwf_crf_wr_data(frfu_frwf_crf_wr_data[31:0]),
      .frfu_frwf_crf_wr_en  (frfu_frwf_crf_wr_en),
      .frfu_sfr_rd_data     (frfu_sfr_rd_data[7:0]),
      //------------------------------------------------------------//
      //-- OUTPUT                                                 --//
      //------------------------------------------------------------//
      .frwf_frfu_ff0_of     (frwf_frfu_ff0_of),
      .frwf_crf_empty       (frwf_crf_empty),
      .frwf_crf_empty_p1    (frwf_crf_empty_p1),
      .frwf_crf_rd_data     (frwf_crf_rd_data[31:0]),
      .frwf_frfu_crf_full   (frwf_frfu_crf_full),
      .frwf_frfu_crf_full_m1(frwf_frfu_crf_full_m1),
      .frwf_frfu_cwf_wr_data(frwf_frfu_cwf_wr_data[31:0]),
      .frwf_frfu_cwf_wr_en  (frwf_frfu_cwf_wr_en),
      .frwf_frfu_frwf_on    (frwf_frfu_frwf_on),
      .frwf_frfu_rd_addr    (frwf_frfu_rd_addr[6:0]),
      .frwf_frfu_rd_en      (frwf_frfu_rd_en),
      .frwf_frfu_wr_addr    (frwf_frfu_wr_addr[6:0]),
      .frwf_frfu_wr_data    (frwf_frfu_wr_data[7:0]),
      .frwf_frfu_wr_en      (frwf_frfu_wr_en),
      .frwf_wff_full        (frwf_wff_full),
      .frwf_wff_full_m1     (frwf_wff_full_m1)
  );

  //----------------------------------------------------------------//
  //-- fcbpmu Instance                                      --//
  //----------------------------------------------------------------//
  fcbpmu #(
      .PAR_QLFCB_6BIT_125NS(PAR_QLFCB_6BIT_125NS),
      .PAR_QLFCB_6BIT_250NS(PAR_QLFCB_6BIT_250NS)
  ) fcbpmu_INST (
      //------------------------------------------------------------//
      //-- INPUT                                                  --//
      //------------------------------------------------------------//
      .fcb_sys_clk(fcb_sys_clk),
      .fcb_sys_rst_n(fcb_sys_rst_n),
      .frfu_fpmu_iso_en_sd_0(frfu_fpmu_iso_en_sd_0[7:0]),
      .frfu_fpmu_iso_en_sd_1(frfu_fpmu_iso_en_sd_1[7:0]),
      .frfu_fpmu_pi_pwr_sd_0(frfu_fpmu_pi_pwr_sd_0[7:0]),
      .frfu_fpmu_pi_pwr_sd_1(frfu_fpmu_pi_pwr_sd_1[7:0]),
      //.frfu_fpmu_pmu_chip_vlp_en                      (frfu_fpmu_pmu_chip_vlp_en      ) ,
      //.frfu_fpmu_pmu_chip_vlp_wu_en                   (frfu_fpmu_pmu_chip_vlp_wu_en   ) ,
      .frfu_fpmu_pmu_mux_sel_sd(frfu_fpmu_pmu_mux_sel_sd),
      .frfu_fpmu_pmu_pwr_gate_ccnt(frfu_fpmu_pmu_pwr_gate_ccnt[5:0]),
      .frfu_fpmu_pmu_timer_ccnt(frfu_fpmu_pmu_timer_ccnt[7:0]),
      //.frfu_fpmu_prog_pmu_chip_vlp_en                 (frfu_fpmu_prog_pmu_chip_vlp_en ) ,
      //.frfu_fpmu_prog_pmu_chip_wu_en              	(frfu_fpmu_prog_pmu_chip_wu_en      ) ,
      //.frfu_fpmu_quad_pd_en_b0                        (frfu_fpmu_quad_pd_en_b0[7:0]   ) ,
      //.frfu_fpmu_quad_pd_en_b1                        (frfu_fpmu_quad_pd_en_b1[7:0]   ) ,
      //.frfu_fpmu_quad_pd_mode                 	(frfu_fpmu_quad_pd_mode ) ,
      //.frfu_fpmu_quad_wu_en_b0                        (frfu_fpmu_quad_wu_en_b0[7:0]   ) ,
      //.frfu_fpmu_quad_wu_en_b1                        (frfu_fpmu_quad_wu_en_b1[7:0]   ) ,
      //.frfu_fpmu_quad_wu_mode                 	(frfu_fpmu_quad_wu_mode ) ,
      .frfu_fpmu_vlp_clkdis_ifx_sd(frfu_fpmu_vlp_clkdis_ifx_sd),
      .frfu_fpmu_vlp_clkdis_sd_0(frfu_fpmu_vlp_clkdis_sd_0[7:0]),
      .frfu_fpmu_vlp_clkdis_sd_1(frfu_fpmu_vlp_clkdis_sd_1[7:0]),
      //.frfu_fpmu_vlp_ifx_sd                   	(frfu_fpmu_vlp_ifx_sd      ) ,
      .frfu_fpmu_vlp_pwrdis_ifx_sd(frfu_fpmu_vlp_pwrdis_ifx_sd),
      .frfu_fpmu_vlp_pwrdis_sd_0(frfu_fpmu_vlp_pwrdis_sd_0[7:0]),
      .frfu_fpmu_vlp_pwrdis_sd_1(frfu_fpmu_vlp_pwrdis_sd_1[7:0]),
      //.frfu_fpmu_vlp_sd_0                     	(frfu_fpmu_vlp_sd_0[7:0]        ) ,
      //.frfu_fpmu_vlp_sd_1                     	(frfu_fpmu_vlp_sd_1[7:0]        ) ,
      .frfu_fpmu_vlp_srdis_ifx_sd(frfu_fpmu_vlp_srdis_ifx_sd),
      .frfu_fpmu_vlp_srdis_sd_0(frfu_fpmu_vlp_srdis_sd_0[7:0]),
      .frfu_fpmu_vlp_srdis_sd_1(frfu_fpmu_vlp_srdis_sd_1[7:0]),
      .fcb_clp_mode_en_bo(fcb_clp_mode_en_bo),
      //.frfu_fpmu_pmu_chip_pd_en			(frfu_fpmu_pmu_chip_pd_en	),	//JC
      //.frfu_fpmu_prog_pmu_chip_pd_en			(frfu_fpmu_prog_pmu_chip_pd_en 	),	//JC
      //.frfu_fpmu_prog_pmu_quad_pd_en			(frfu_fpmu_prog_pmu_quad_pd_en	), 	//JC
      //.frfu_fpmu_prog_pmu_quad_wu_en			(frfu_fpmu_prog_pmu_quad_wu_en	), 	//JC
      .frfu_fpmu_prog_cfg_done(frfu_fpmu_prog_cfg_done),  // JC
      .frfu_fpmu_clr_cfg_done(frfu_fpmu_clr_cfg_done),  //JC
      .frfu_fpmu_prog_pmu_chip_cmd(frfu_fpmu_prog_pmu_chip_cmd),
      .frfu_fpmu_pmu_chip_cmd(frfu_fpmu_pmu_chip_cmd[3:0]),
      .frfu_fpmu_quad_cfg_b0(frfu_fpmu_quad_cfg_b0[7:0]),
      .frfu_fpmu_quad_cfg_b1(frfu_fpmu_quad_cfg_b1[7:0]),
      .frfu_fpmu_pmu_time_ctl(frfu_fpmu_pmu_time_ctl),
      .frfu_fpmu_fb_cfg_done(frfu_fpmu_fb_cfg_done),
      .frfu_fpmu_fb_iso_enb_sd(frfu_fpmu_fb_iso_enb_sd),
      .frfu_fpmu_pwr_gate_sd(frfu_fpmu_pwr_gate_sd),
      .frfu_fpmu_prog_ifx_sd(frfu_fpmu_prog_ifx_sd),
      .frfu_fpmu_set_por_sd(frfu_fpmu_set_por_sd),
      .frfu_fpmu_prog_sd_0(frfu_fpmu_prog_sd_0),
      .frfu_fpmu_prog_sd_1(frfu_fpmu_prog_sd_1),
      .fcb_fb_default_on_bo(fcb_fb_default_on_bo),  //eFPGA Macro Default Power State
      //------------------------------------------------------------//
      //-- OUTPUT                                                 --//
      //------------------------------------------------------------//
      .fpmu_frfu_fb_cfg_cleanup(fpmu_frfu_fb_cfg_cleanup),
      .fpmu_frfu_clr_pmu_chip_cmd(fpmu_frfu_clr_pmu_chip_cmd),  //JC
      .fpmu_frfu_clr_quads(fpmu_frfu_clr_quads),  //JC
      .fpmu_frfu_clr_cfg_done(fpmu_frfu_clr_cfg_done),
      .fcb_fb_iso_enb(fcb_fb_iso_enb),
      .fcb_iso_en(fcb_iso_en[15:0]),
      .fcb_pi_pwr(fcb_pi_pwr[15:0]),
      .fcb_vlp_clkdis(fcb_vlp_clkdis[15:0]),
      .fcb_vlp_clkdis_ifx(fcb_vlp_clkdis_ifx),
      .fcb_vlp_pwrdis(fcb_vlp_pwrdis[15:0]),
      .fcb_vlp_pwrdis_ifx(fcb_vlp_pwrdis_ifx),
      .fcb_vlp_srdis(fcb_vlp_srdis[15:0]),
      .fcb_vlp_srdis_ifx(fcb_vlp_srdis_ifx),
      .fcb_prog_ifx(fcb_prog_ifx),  //JC
      .fcb_prog(fcb_prog),  //JC
      .fcb_pwr_gate(fcb_pwr_gate),  //JC
      //.fpmu_frfu_clr_pmu_chip_vlp_en          	(fpmu_frfu_clr_pmu_chip_vlp_en  )  ,
      //.fpmu_frfu_clr_pmu_chip_wu_en           	(fpmu_frfu_clr_pmu_chip_wu_en   )  ,
      //.fpmu_frfu_clr_quad_pd_en_b0            	(fpmu_frfu_clr_quad_pd_en_b0[7:0]       ) ,
      //.fpmu_frfu_clr_pmu_chip_pd_en			(fpmu_frfu_clr_pmu_chip_pd_en		) ,	//JC
      //.fpmu_frfu_clr_quad_pd_en_b1            	(fpmu_frfu_clr_quad_pd_en_b1[7:0]       )  ,
      //.fpmu_frfu_clr_quad_pd_wr_en_b0         	(fpmu_frfu_clr_quad_pd_wr_en_b0 )  ,
      //.fpmu_frfu_clr_quad_pd_wr_en_b1         	(fpmu_frfu_clr_quad_pd_wr_en_b1 )  ,
      //.fpmu_frfu_clr_quad_wu_en_b0            	(fpmu_frfu_clr_quad_wu_en_b0[7:0]       )  ,
      //.fpmu_frfu_clr_quad_wu_en_b1            	(fpmu_frfu_clr_quad_wu_en_b1[7:0]       )  ,
      //.fpmu_frfu_clr_quad_wu_wr_en_b0         	(fpmu_frfu_clr_quad_wu_wr_en_b0 )  ,
      //.fpmu_frfu_clr_quad_wu_wr_en_b1         	(fpmu_frfu_clr_quad_wu_wr_en_b1 )  ,
      .fpmu_frfu_pw_sta_00(fpmu_frfu_pw_sta_00[1:0]),
      .fpmu_frfu_pw_sta_01(fpmu_frfu_pw_sta_01[1:0]),
      .fpmu_frfu_pw_sta_02(fpmu_frfu_pw_sta_02[1:0]),
      .fpmu_frfu_pw_sta_03(fpmu_frfu_pw_sta_03[1:0]),
      .fpmu_frfu_pw_sta_10(fpmu_frfu_pw_sta_10[1:0]),
      .fpmu_frfu_pw_sta_11(fpmu_frfu_pw_sta_11[1:0]),
      .fpmu_frfu_pw_sta_12(fpmu_frfu_pw_sta_12[1:0]),
      .fpmu_frfu_pw_sta_13(fpmu_frfu_pw_sta_13[1:0]),
      .fpmu_frfu_pw_sta_20(fpmu_frfu_pw_sta_20[1:0]),
      .fpmu_frfu_pw_sta_21(fpmu_frfu_pw_sta_21[1:0]),
      .fpmu_frfu_pw_sta_22(fpmu_frfu_pw_sta_22[1:0]),
      .fpmu_frfu_pw_sta_23(fpmu_frfu_pw_sta_23[1:0]),
      .fpmu_frfu_pw_sta_30(fpmu_frfu_pw_sta_30[1:0]),
      .fpmu_frfu_pw_sta_31(fpmu_frfu_pw_sta_31[1:0]),
      .fpmu_frfu_pw_sta_32(fpmu_frfu_pw_sta_32[1:0]),
      .fpmu_frfu_pw_sta_33(fpmu_frfu_pw_sta_33[1:0]),
      .fpmu_frfu_chip_pw_sta(fpmu_frfu_chip_pw_sta),  // JC 05232017
      .fcb_set_por(fcb_set_por),
      .fpmu_frfu_pmu_busy(fpmu_frfu_pmu_busy),
      .fpmu_pmu_busy(fpmu_pmu_busy)
  );

  //----------------------------------------------------------------//
  //-- fcbpif Instance                                      --//
  //----------------------------------------------------------------//
  fcbpif fcbpif_INST (
      //------------------------------------------------------------//
      //-- INPUT                                                  --//
      //------------------------------------------------------------//
      .fcb_pif_8b_mode_bo   (fcb_pif_8b_mode_bo),
      .fcb_pif_di_h         (fcb_pif_di_h[3:0]),
      .fcb_pif_di_l         (fcb_pif_di_l[3:0]),
      .fcb_pif_en           (fcb_pif_en),
      .fcb_pif_vldi         (fcb_pif_vldi),
      .fcb_sys_clk          (fcb_sys_clk),
      .fcb_sys_rst_n        (fcb_sys_rst_n),
      .fcb_sys_stm          (fcb_sys_stm),
      .frwf_crf_empty       (frwf_crf_empty),
      .frwf_crf_empty_p1    (frwf_crf_empty_p1),
      .frwf_crf_rd_data     (frwf_crf_rd_data[31:0]),
      .frwf_wff_full        (frwf_wff_full),
      .frwf_wff_full_m1     (frwf_wff_full_m1),
      //------------------------------------------------------------//
      //-- OUTPUT                                                 --//
      //------------------------------------------------------------//
      .fcb_pif_do_h         (fcb_pif_do_h[3:0]),
      .fcb_pif_do_h_en      (fcb_pif_do_h_en),
      .fcb_pif_do_l         (fcb_pif_do_l[3:0]),
      .fcb_pif_do_l_en      (fcb_pif_do_l_en),
      .fcb_pif_vldo         (fcb_pif_vldo),
      .fcb_pif_vldo_en      (fcb_pif_vldo_en),
      .fpif_frwf_crf_rd_en  (fpif_frwf_crf_rd_en),
      .fpif_frwf_pif_on     (fpif_frwf_pif_on),
      .fpif_frwf_wff_wr_data(fpif_frwf_wff_wr_data[39:0]),
      .fpif_frwf_wff_wr_en  (fpif_frwf_wff_wr_en)
  );
  //----------------------------------------------------------------//
  //-- fcbmic Instance                                      --//
  //----------------------------------------------------------------//
  assign fcb_spi_master_status = fmic_spi_master_en;  // New Added

  fcbmic fcbmic_INST (
      //------------------------------------------------------------//
      //-- INPUT                                                  --//
      //------------------------------------------------------------//
      .fcb_fb_cfg_done              (fcb_fb_cfg_done),
      .fcb_pif_8b_mode_bo           (fcb_pif_8b_mode_bo),
      .fcb_pif_en                   (fcb_pif_en),
      .fcb_spi_master_en            (fcb_spi_master_en),
      .fcb_spi_mode_en_bo           (fcb_spi_mode_en_bo),
      .fcb_spis_clk                 (fcb_spis_clk),
      .fcb_spis_cs_n                (fcb_spis_cs_n),
      .fcb_sys_clk                  (fcb_sys_clk),
      .fcb_sys_rst_n                (fcb_sys_rst_n),
      .fcb_sys_stm                  (fcb_sys_stm),
      .fcb_vlp                      (1'b0),
      .ffsr_fmic_fsr_busy           (ffsr_fsr_busy),
      .fpmu_fmic_pmu_busy           (fpmu_pmu_busy),
      .fclp_clp_busy                (fclp_clp_busy),  // New Added
      .frfu_fmic_done_op_mask_n     (frfu_fmic_done_op_mask_n),
      .frfu_fmic_io_sv_180          (frfu_fmic_io_sv_180[3:0]),
      //.frfu_fmic_rc_clk_en                  (frfu_fmic_rc_clk_en    ) ,
      .frfu_fmic_rc_clk_en          (1'b1),
      .frfu_fmic_vlp_pin_en         (frfu_fmic_vlp_pin_en),
      .fsmc_fmic_clr_spi_master_en  (fsmc_fmic_clr_spi_master_en),
      .fsmc_fmic_fsmc_busy          (fsmc_fmic_fsmc_busy),
      .frfu_fmic_fb_cfg_done        (frfu_fmic_fb_cfg_done),
      .frfu_fpmu_pmu_chip_vlp_en    (1'b0),  // VLP Pin is no used
      .frfu_fpmu_pmu_chip_vlp_wu_en (1'b0),  // VLP Pin is no used
      .fclp_frfu_clp_pw_sta         (fclp_frfu_clp_pw_sta),
      .fcb_clp_mode_en_bo           (fcb_clp_mode_en_bo),
      .frfu_fclp_clp_vlp_wu_en      (frfu_fclp_clp_vlp_wu_en),  //JC 01262017
      .frfu_fclp_clp_vlp_en         (frfu_fclp_clp_vlp_en),  //JC 01262017
      .fcb_vlp_pwrdis_ifx           (fcb_vlp_pwrdis_ifx),  //JC 01262017
      .fsmc_fmic_seq_done           (fsmc_fmic_seq_done),
      //------------------------------------------------------------//
      //-- OUTPUT                                                 --//
      //------------------------------------------------------------//
      .fcb_cfg_done                 (fcb_cfg_done),
      .fcb_cfg_done_en              (fcb_cfg_done_en),
      //.fcb_io_sv_180                  	(fcb_io_sv_180[3:0]     )  ,
      .fcb_io_sv_180                (),
      .fcb_sysclk_en                (fcb_sysclk_en),
      .fmic_frfu_set_pmu_chip_vlp_en(fmic_frfu_set_pmu_chip_vlp_en),
      .fmic_frfu_set_pmu_chip_wu_en (fmic_frfu_set_pmu_chip_wu_en),
      .fmic_frfu_set_rc_clk_en      (fmic_frfu_set_rc_clk_en),
      .fmic_spi_master_en           (fmic_spi_master_en)
  );

  //----------------------------------------------------------------//
  //-- fcbfsr Instance                                      --//
  //----------------------------------------------------------------//
  fcbfsr #(
      .PAR_RAMFIFO_CFG(PAR_RAMFIFO_CFG)
  ) fcbfsr_INST (

      //------------------------------------------------------------//
      //-- INPUT                                                  --//
      //------------------------------------------------------------//
      .fcb_apbm_prdata_0           (fcb_apbm_prdata_0[17:0]),
      .fcb_apbm_prdata_1           (fcb_apbm_prdata_1[17:0]),
      .fcb_bl_dout                 (fcb_bl_dout[31:0]),
      .fcb_sys_clk                 (fcb_sys_clk),
      .fcb_sys_rst_n               (fcb_sys_rst_n),
      .fcb_sys_stm                 (fcb_sys_stm),
      .frfu_bl_pw_cfg_0            (frfu_bl_pw_cfg_0[7:0]),
      .frfu_bl_pw_cfg_1            (frfu_bl_pw_cfg_1[7:0]),
      .frfu_ffsr_bl_cnt_h          (frfu_ffsr_bl_cnt_h[7:0]),
      .frfu_ffsr_bl_cnt_l          (frfu_ffsr_bl_cnt_l[7:0]),
      .frfu_ffsr_cfg_wrp_ccnt      (frfu_ffsr_cfg_wrp_ccnt[3:0]),
      .frfu_ffsr_rcfg_wrp_ccnt     (frfu_ffsr_rcfg_wrp_ccnt[3:0]),
      .frfu_ffsr_col_cnt           (frfu_ffsr_col_cnt[7:0]),
      .frfu_ffsr_fb_cfg_cmd        (frfu_ffsr_fb_cfg_cmd[7:0]),
      .frfu_ffsr_fb_cfg_kickoff    (frfu_ffsr_fb_cfg_kickoff),
      .frfu_ffsr_ram_cfg_0         (frfu_ffsr_ram_cfg_0_en[7:0]),
      .frfu_ffsr_ram_cfg_1         (frfu_ffsr_ram_cfg_1_en[7:0]),
      .frfu_ffsr_ram_data_width    (frfu_ffsr_ram_data_width[7:0]),
      .frfu_ffsr_ram_size_b0       (frfu_ffsr_ram_size_b0[7:0]),
      .frfu_ffsr_ram_size_b1       (frfu_ffsr_ram_size_b1[7:0]),
      .frfu_ffsr_rfifo_rd_en       (frfu_ffsr_rfifo_rd_en),
      .frfu_ffsr_wfifo_wdata       (frfu_ffsr_wfifo_wdata[31:0]),
      .frfu_ffsr_wfifo_wr_en       (frfu_ffsr_wfifo_wr_en),
      .frfu_ffsr_wl_cnt_h          (frfu_ffsr_wl_cnt_h[7:0]),
      .frfu_ffsr_wl_cnt_l          (frfu_ffsr_wl_cnt_l[7:0]),
      .frfu_wl_pw_cfg              (frfu_wl_pw_cfg[7:0]),
      .frfu_wrd_cnt_b0             (frfu_wrd_cnt_b0[7:0]),
      .frfu_wrd_cnt_b1             (frfu_wrd_cnt_b1[7:0]),
      .frfu_wrd_cnt_b2             (frfu_wrd_cnt_b2[7:0]),
      .frfu_ffsr_wlblclk_cfg       (frfu_ffsr_wlblclk_cfg),
      .frfu_ffsr_blclk_sut         (frfu_ffsr_blclk_sut),
      .frfu_ffsr_wlclk_sut         (frfu_ffsr_wlclk_sut),
      .frfu_ffsr_wlen_sut          (frfu_ffsr_wlen_sut),
      //------------------------------------------------------------//
      //-- OUTPUT                                                 --//
      //------------------------------------------------------------//
      .fcb_apbm_mclk               (fcb_apbm_mclk),
      .fcb_apbm_paddr              (fcb_apbm_paddr[11:0]),
      .fcb_apbm_penable            (fcb_apbm_penable),
      .fcb_apbm_psel               (fcb_apbm_psel[7:0]),
      .fcb_apbm_pwdata             (fcb_apbm_pwdata[17:0]),
      .fcb_apbm_pwrite             (fcb_apbm_pwrite),
      .fcb_apbm_ramfifo_sel        (fcb_apbm_ramfifo_sel),
      .fcb_bl_din                  (fcb_bl_din[31:0]),
      .fcb_bl_pwrgate              (fcb_bl_pwrgate[15:0]),
      .fcb_blclk                   (fcb_blclk),
      .fcb_cload_din_sel           (fcb_cload_din_sel),
      .fcb_din_int_l_only          (fcb_din_int_l_only),
      .fcb_din_int_r_only          (fcb_din_int_r_only),
      .fcb_din_slc_tb_int          (fcb_din_slc_tb_int),
      //.fcb_iso_rst                    	(fcb_iso_rst    )  ,
      //.fcb_lr_rst                     	(fcb_lr_rst     )  ,
      .fcb_pchg_b                  (fcb_pchg_b),
      //.fcb_prog                       	(fcb_prog[15:0] )  ,
      //.fcb_prog_ifx                   	(fcb_prog_ifx   )  ,
      .fcb_re                      (fcb_re),
      //.fcb_rst                        	(fcb_rst[15:0]  )  ,
      .fcb_rst                     (fcb_rst),  // One Bit now
      //.fcb_tb_rst                     	(fcb_tb_rst     )  ,
      .fcb_we                      (fcb_we),
      .fcb_we_int                  (fcb_we_int),
      .fcb_wl_cload_sel            (fcb_wl_cload_sel[2:0]),
      .fcb_wl_din                  (fcb_wl_din[5:0]),
      .fcb_wl_en                   (fcb_wl_en),
      .fcb_wl_int_din_sel          (fcb_wl_int_din_sel),
      .fcb_wl_pwrgate              (fcb_wl_pwrgate[7:0]),
      .fcb_wl_resetb               (fcb_wl_resetb),
      .fcb_wl_sel                  (fcb_wl_sel[15:0]),
      .fcb_wl_sel_tb_int           (fcb_wl_sel_tb_int),
      .fcb_wlclk                   (fcb_wlclk),
      .ffsr_frfu_clr_fb_cfg_kickoff(ffsr_frfu_clr_fb_cfg_kickoff),
      .ffsr_frfu_rfifo_empty       (ffsr_frfu_rfifo_empty),
      .ffsr_frfu_rfifo_empty_p1    (ffsr_frfu_rfifo_empty_p1),
      .ffsr_frfu_rfifo_rdata       (ffsr_frfu_rfifo_rdata[31:0]),
      .ffsr_frfu_wfifo_full        (ffsr_frfu_wfifo_full),
      .ffsr_frfu_wfifo_full_m1     (ffsr_frfu_wfifo_full_m1),
      .ffsr_fsr_busy               (ffsr_fsr_busy)
  );
  //----------------------------------------------------------------//
  //-- fcbaps Instance                                      --//
  //----------------------------------------------------------------//
  fcbaps fcbaps_INST (
      //------------------------------------------------------------//
      //-- INPUT                                                  --//
      //------------------------------------------------------------//
      .fcb_apbs_paddr       (fcb_apbs_paddr[19:0]),
      .fcb_apbs_pprot       (fcb_apbs_pprot[2:0]),
      .fcb_apbs_penable     (fcb_apbs_penable),
      .fcb_apbs_prot_en_bo  (1'b0),
      .fcb_apbs_psel        (fcb_apbs_psel),
      .fcb_apbs_pstrb       (fcb_apbs_pstrb[3:0]),
      .fcb_apbs_pwdata      (fcb_apbs_pwdata[31:0]),
      .fcb_apbs_pwrite      (fcb_apbs_pwrite),
      .fcb_spi_mode_en_bo   (fcb_spi_mode_en_bo),
      .fcb_sys_clk          (fcb_sys_clk),
      .fcb_sys_rst_n        (fcb_sys_rst_n),
      .fcb_sys_stm          (fcb_sys_stm),
      .frwf_crf_empty       (frwf_crf_empty),
      .frwf_crf_empty_p1    (frwf_crf_empty_p1),
      .frwf_crf_rd_data     (frwf_crf_rd_data[31:0]),
      .frwf_wff_full        (frwf_wff_full),
      .frwf_wff_full_m1     (frwf_wff_full_m1),
      //------------------------------------------------------------//
      //-- OUTPUT                                                 --//
      //------------------------------------------------------------//
      .faps_frwf_apb_on     (faps_frwf_apb_on),
      .faps_frwf_crf_rd_en  (faps_frwf_crf_rd_en),
      .faps_frwf_wff_wr_data(faps_frwf_wff_wr_data[39:0]),
      .faps_frwf_wff_wr_en  (faps_frwf_wff_wr_en),
      .fcb_apbs_prdata      (fcb_apbs_prdata[31:0]),
      .fcb_apbs_pready      (fcb_apbs_pready),
      .fcb_apbs_pslverr     (fcb_apbs_pslverr)
  );

  //----------------------------------------------------------------//
  //-- fcbclp Instance                                      	--//
  //----------------------------------------------------------------//
  fcbclp #(
      .PAR_QLFCB_11BIT_100NS(PAR_QLFCB_11BIT_100NS),  // 1: Default ON, 0: Default Off
      .PAR_QLFCB_11BIT_200NS(PAR_QLFCB_11BIT_200NS),  // Default Assume 100MHz
      .PAR_QLFCB_11BIT_1US  (PAR_QLFCB_11BIT_1US),  // Default Assume 100MHz
      .PAR_QLFCB_11BIT_10US (PAR_QLFCB_11BIT_10US)  // Default Assume 100MHz
  ) fcbclp_INST (
      //------------------------------------------------------------//
      //-- INPUT                                                  --//
      //------------------------------------------------------------//
      .fcb_clp_mode_en_bo       (fcb_clp_mode_en_bo),
      .fcb_sys_clk              (fcb_sys_clk),
      .fcb_sys_rst_n            (fcb_sys_rst_n),
      .frfu_fclp_cfg_done       (frfu_fclp_cfg_done),
      .frfu_fclp_clp_pd_en      (frfu_fclp_clp_pd_en),
      .frfu_fclp_clp_pd_wu_en   (frfu_fclp_clp_pd_wu_en),
      .frfu_fclp_clp_time_ctl   (frfu_fclp_clp_time_ctl[1:0]),
      .frfu_fclp_clp_vlp_en     (frfu_fclp_clp_vlp_en),
      .frfu_fclp_clp_vlp_wu_en  (frfu_fclp_clp_vlp_wu_en),
      .fcb_sys_stm              (fcb_sys_stm),
      .fcb_pif_en               (fcb_pif_en),
      .fcb_fb_default_on_bo     (fcb_fb_default_on_bo),  //eFPGA Macro Default Power State
      //------------------------------------------------------------//
      //-- OUTPUT                                                 --//
      //------------------------------------------------------------//
      .fclp_frfu_fb_cfg_cleanup (fclp_frfu_fb_cfg_cleanup),
      .fcb_clp_set_por          (fcb_clp_set_por),  //POR Signal
      .fcb_clp_cfg_done         (fcb_clp_cfg_done),
      .fcb_clp_cfg_done_n       (fcb_clp_cfg_done_n),
      .fcb_clp_cfg_enb          (fcb_clp_cfg_enb),
      .fcb_clp_lth_enb          (fcb_clp_lth_enb),
      .fcb_clp_pwr_gate         (fcb_clp_pwr_gate),
      .fcb_clp_vlp              (fcb_clp_vlp),
      .fclp_clp_busy            (fclp_clp_busy),
      .fclp_frfu_clear_cfg_done (fclp_frfu_clear_cfg_done),
      .fclp_frfu_clear_pd_en    (fclp_frfu_clear_pd_en),
      .fclp_frfu_clear_pd_wu_en (fclp_frfu_clear_pd_wu_en),
      .fclp_frfu_clear_vlp_en   (fclp_frfu_clear_vlp_en),
      .fclp_frfu_clear_vlp_wu_en(fclp_frfu_clear_vlp_wu_en),
      .fclp_frfu_clp_pw_sta     (fclp_frfu_clp_pw_sta[1:0])
  );

  //--------------------------------------------------------------------------------//
  //-- END                                                                        --//
  //--------------------------------------------------------------------------------//
  `endprotect
endmodule
