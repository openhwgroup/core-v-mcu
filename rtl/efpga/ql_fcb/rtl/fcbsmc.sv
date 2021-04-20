// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

module fcbsmc #(
    parameter [7:0] PAR_FLASH_READ_CMD = 8'b0000_0011,  //Flash Read Command
    parameter [7:0] PAR_FLASH_DEEP_PWR_EN = 8'b1011_1001,  //Flash Deep Power Down Enable Command
    parameter [7:0] PAR_FLASH_DEEP_PWR_DIS = 8'b1010_1011,  //Flash Wake Up Command
    parameter [10:0]        PAR_FLASH_PWR_UP_TIME   = 11'b100_1100_0000 ,  //Power Up Wait Time, Need to be at least 32 Cycles	//737, bring to top,JC
    parameter [10:0]        PAR_FLASH_TRES1_TIME    = 11'b111_1111_1111 ,  //Power Down Wake Up time, Need to be at least 32 Cycles	//737, bring to top,JC
    parameter [7:0] PAR_SPI_ADR_0 = 8'b0000_0000,  //
    parameter [7:0] PAR_SPI_ADR_1 = 8'b0000_0001,  //
    parameter [7:0] PAR_SPI_ADR_2 = 8'b0000_0010,  //
    parameter [7:0] PAR_SPI_ADR_3 = 8'b0000_0011,  //
    parameter [7:0] PAR_SPI_ADR_4 = 8'b0000_0100,  //
    parameter [7:0] PAR_SPI_ADR_5 = 8'b0000_0101,  //
    parameter [7:0] PAR_SPI_ADR_6 = 8'b0000_0110,  //
    parameter [7:0] PAR_SPI_ADR_7 = 8'b0000_0111,  //
    parameter [7:0] PAR_SPI_ADR_0_CFG = 8'b0001_0100,  //	Divided By 20
    parameter [7:0] PAR_SPI_ADR_2_CFG = 8'b1000_0000,  //	Enable SPI
    parameter [7:0] PAR_SPI_ADR_5_CFG = 8'b0000_0001,  //	Select Chip Select
    parameter [7:0] PAR_SPI_WR_CYC = 8'b0000_0101,  //
    parameter [7:0] PAR_SPI_READ_CYC = 8'b0000_1001,  //
    parameter [7:0] PAR_SPI_END_CYC = 8'b0000_0010
) (
    //------------------------------------------------------------------------//
    //-- INPUT PORT                                                         --//
    //------------------------------------------------------------------------//
    input  logic       fcb_sys_clk,  //Main Clock for FCB except SPI Slave Int
    input  logic       fcb_sys_rst_n,  //Main Reset for FCB except SPI Slave int
    input  logic       fcb_sys_stm,  //1'b1 : Put the module into Test Mode
    input  logic       fcb_spim_ckout_in,  //SPI Master Loop Back Clock
    input  logic       fcb_spi_mode_en_bo,  //1'b1 : SPI Master/Slave is Enable. 1'b0
    input  logic       fmic_spi_master_en,  //1'b1: Enable SPI Master Mode, 1'b0: Ena
    input  logic [7:0] frfu_spim_baud_rate,  //
    input  logic       frfu_fsmc_sw2_spis,  //
    input  logic       frfu_fsmc_rc_clk_dis_cfg,  //
    input  logic       fcb_spim_miso,  //SPI Master MISO
    input  logic [7:0] frfu_sfr_rd_data,  //SFR Read Data
    input  logic       frfu_cwf_full,  //Full Flag of Cfg Write FIFO
    input  logic [7:0] frfu_fsmc_spim_ckb_0,  //
    input  logic [7:0] frfu_fsmc_spim_ckb_1,  //
    input  logic [7:0] frfu_fsmc_spim_device_id,  //
    input  logic       fpmu_pmu_busy,  //
    input  logic       fclp_clp_busy,  // 05182017 // JC // CLP BUSY
    input  logic       fcb_clp_mode_en_bo,  // 05182017 // JC // CLP MODE
    input  logic       ffsr_fsr_busy,  //
    input  logic       frfu_fsmc_checksum_status,  //CheckSum Status
    input  logic       frfu_fsmc_checksum_enable,  //
    input  logic [7:0] frfu_wrd_cnt_b0,  //
    input  logic [7:0] frfu_wrd_cnt_b1,  //
    input  logic [7:0] frfu_wrd_cnt_b2,  //
    input  logic       frfu_fsmc_pending_pd_req,  //Pending Power Down Request
    //------------------------------------------------------------------------//
    //-- OUTPUT PORT                                                        --//
    //------------------------------------------------------------------------//
    output logic       fsmc_frfu_set_quad_pd,  //Set Whole Chip Power Down // JC // 05182017
    output logic       fsmc_fmic_clr_spi_master_en,  //Clear SPI_MASTER_EN and Switch the mode
    output logic       fsmc_frfu_clr_rcclk_en,  //Clear RC clock
    output logic       fsmc_frfu_set_pd,  //Set Whole Chip Power Down // JC // 05182017
    output logic       fsmc_frfu_set_clp_pd,  //Set Whole Chip Power Down // JC // 05182017
    output logic       fcb_spim_mosi,  //SPI Master MOSI
    output logic       fcb_spim_mosi_en,  //SPI Master MOSI output enable
    output logic       fcb_spim_cs_n,  //SPI Master Chip Select
    output logic       fcb_spim_cs_n_en,  //SPI Master Chip Select enable
    output logic       fcb_spim_ckout,  //SPI Master Clock Output
    output logic       fcb_spim_ckout_en,  //SPI Master Clock Output Enable
    output logic [6:0] fsmc_frfu_rd_addr,  //SFR Read Address
    output logic [6:0] fsmc_frfu_wr_addr,  //SFR Write Address
    output logic       fsmc_frfu_wr_en,  //SFR Write Enable
    output logic       fsmc_frfu_rd_en,  //SFR Read Enable
    output logic [7:0] fsmc_frfu_wr_data,  //SFR Write Data
    output logic       fsmc_frfu_spim_on,  //SPI Master is ON
    output logic [7:0] fsmc_frfu_cwf_wr_data,  //Write Data of Cfg Write FIFO
    output logic       fsmc_frfu_cwf_wr_en,  //Write Enable to indicate the whole 32-B
    output logic       fsmc_fmic_fsmc_busy,  //FSMC Busy
    output logic       fsmc_fmic_seq_done,  //FSM
    output logic       fsmc_frfu_set_fb_cfg_done  //Set FB Cfg Done Bit
);

  //------------------------------------------------------------------------//
  //-- Local Parameter                                                    --//
  //------------------------------------------------------------------------//
  localparam PAR_DLY = 1'b1;

  //------------------------------------------------------------------------//
  //-- EMUN/Flops                                                         --//
  //------------------------------------------------------------------------//
  typedef enum logic [7:0] {
    MAIN_S00 = 8'h00,
    MAIN_S01 = 8'h01,
    MAIN_S02 = 8'h02,
    MAIN_S03 = 8'h03,
    MAIN_S04 = 8'h04,
    MAIN_S05 = 8'h05,
    MAIN_S06 = 8'h06,
    MAIN_S07 = 8'h07,
    MAIN_S08 = 8'h08,
    MAIN_S09 = 8'h09,
    MAIN_S0A = 8'h0A,
    MAIN_S0B = 8'h0B,
    MAIN_S0C = 8'h0C,
    MAIN_S0D = 8'h0D,
    MAIN_S0E = 8'h0E,
    MAIN_S0F = 8'h0F,
    MAIN_S10 = 8'h10,
    MAIN_S11 = 8'h11,
    MAIN_S12 = 8'h12,
    MAIN_S13 = 8'h13,
    MAIN_S14 = 8'h14,
    MAIN_S15 = 8'h15,
    MAIN_S16 = 8'h16,
    MAIN_S17 = 8'h17,
    MAIN_S18 = 8'h18,
    MAIN_S19 = 8'h19,
    MAIN_S1A = 8'h1A,
    MAIN_S1B = 8'h1B,
    MAIN_S1C = 8'h1C,
    MAIN_S1D = 8'h1D,
    MAIN_S1E = 8'h1E,
    MAIN_S1F = 8'h1F,
    MAIN_S20 = 8'h20,
    MAIN_S21 = 8'h21,
    MAIN_S22 = 8'h22,
    MAIN_S23 = 8'h23,
    MAIN_S24 = 8'h24,
    MAIN_S25 = 8'h25,
    MAIN_S26 = 8'h26,
    MAIN_S27 = 8'h27,
    MAIN_S28 = 8'h28,
    MAIN_S29 = 8'h29,
    MAIN_S2A = 8'h2A,
    MAIN_S2B = 8'h2B,
    MAIN_S2C = 8'h2C,
    MAIN_S2D = 8'h2D,
    MAIN_S2E = 8'h2E,
    MAIN_S2F = 8'h2F,
    //
    // 05182016 JC --> New Added MAIN_S30 --> MAIN_S4F
    //
    MAIN_S30 = 8'h30,
    MAIN_S31 = 8'h31,
    MAIN_S32 = 8'h32,
    MAIN_S33 = 8'h33,
    MAIN_S34 = 8'h34,
    MAIN_S35 = 8'h35,
    MAIN_S36 = 8'h36,
    MAIN_S37 = 8'h37,
    MAIN_S38 = 8'h38,
    MAIN_S39 = 8'h39,
    MAIN_S3A = 8'h3A,
    MAIN_S3B = 8'h3B,
    MAIN_S3C = 8'h3C,
    MAIN_S3D = 8'h3D,
    MAIN_S3E = 8'h3E,
    MAIN_S3F = 8'h3F,
    MAIN_S40 = 8'h40,
    MAIN_S41 = 8'h41,
    MAIN_S42 = 8'h42,
    MAIN_S43 = 8'h43,
    MAIN_S44 = 8'h44,
    MAIN_S45 = 8'h45,
    MAIN_S46 = 8'h46,
    MAIN_S47 = 8'h47,
    MAIN_S48 = 8'h48,
    MAIN_S49 = 8'h49,
    MAIN_S4A = 8'h4A,
    MAIN_S4B = 8'h4B,
    MAIN_S4C = 8'h4C,
    MAIN_S4D = 8'h4D,
    MAIN_S4E = 8'h4E,
    MAIN_S4F = 8'h4F,

    WCP_S00 = 8'hC0,
    WCP_S01 = 8'hC1,
    WCP_S02 = 8'hC2,
    WCP_S03 = 8'hC3,
    WCP_S04 = 8'hC4,
    WCP_S05 = 8'hC5,
    WCP_S06 = 8'hC6,
    WCP_S07 = 8'hC7,
    WCP_S08 = 8'hC8,
    WCP_S09 = 8'hC9,
    WCP_S0A = 8'hCA,
    WCP_S0B = 8'hCB,
    WCP_S0C = 8'hCC,
    WCP_S0D = 8'hCD,
    WCP_S0E = 8'hCE,
    WCP_S0F = 8'hCF,

    //
    CMD_S00 = 8'h50,
    CMD_S01 = 8'h51,
    CMD_S02 = 8'h52,
    CMD_S03 = 8'h53,
    CMD_S04 = 8'h54,
    CMD_S05 = 8'h55,
    CMD_S06 = 8'h56,
    CMD_S07 = 8'h57,
    CMD_S08 = 8'h58,
    CMD_S09 = 8'h59,
    CMD_S0A = 8'h5A,
    CMD_S0B = 8'h5B,
    CMD_S0C = 8'h5C,
    CMD_S0D = 8'h5D,
    CMD_S0E = 8'h5E,
    CMD_S0F = 8'h5F,

    READ_S00 = 8'h60,
    READ_S01 = 8'h61,
    READ_S02 = 8'h62,
    READ_S03 = 8'h63,
    READ_S04 = 8'h64,
    READ_S05 = 8'h65,
    READ_S06 = 8'h66,
    READ_S07 = 8'h67,
    READ_S08 = 8'h68,
    READ_S09 = 8'h69,
    READ_S0A = 8'h6A,
    READ_S0B = 8'h6B,
    READ_S0C = 8'h6C,
    READ_S0D = 8'h6D,
    READ_S0E = 8'h6E,
    READ_S0F = 8'h6F,

    END_S00 = 8'h70,
    END_S01 = 8'h71,
    END_S02 = 8'h72,
    END_S03 = 8'h73,
    END_S04 = 8'h74,
    END_S05 = 8'h75,
    END_S06 = 8'h76,
    END_S07 = 8'h77,
    END_S08 = 8'h78,
    END_S09 = 8'h79,
    END_S0A = 8'h7A,
    END_S0B = 8'h7B,
    END_S0C = 8'h7C,
    END_S0D = 8'h7D,
    END_S0E = 8'h7E,
    END_S0F = 8'h7F,

    CMP_S00 = 8'h80,
    CMP_S01 = 8'h81,
    CMP_S02 = 8'h82,
    CMP_S03 = 8'h83,
    CMP_S04 = 8'h84,
    CMP_S05 = 8'h85,
    CMP_S06 = 8'h86,
    CMP_S07 = 8'h87,
    CMP_S08 = 8'h88,
    CMP_S09 = 8'h89,
    CMP_S0A = 8'h8A,
    CMP_S0B = 8'h8B,
    CMP_S0C = 8'h8C,
    CMP_S0D = 8'h8D,
    CMP_S0E = 8'h8E,
    CMP_S0F = 8'h8F,

    RWS_S00 = 8'h90,
    RWS_S01 = 8'h91,
    RWS_S02 = 8'h92,
    RWS_S03 = 8'h93,
    RWS_S04 = 8'h94,
    RWS_S05 = 8'h95,
    RWS_S06 = 8'h96,
    RWS_S07 = 8'h97,
    RWS_S08 = 8'h98,
    RWS_S09 = 8'h99,
    RWS_S0A = 8'h9A,
    RWS_S0B = 8'h9B,
    RWS_S0C = 8'h9C,
    RWS_S0D = 8'h9D,
    RWS_S0E = 8'h9E,
    RWS_S0F = 8'h9F,

    PD_S00 = 8'hB0,
    PD_S01 = 8'hB1,
    PD_S02 = 8'hB2,
    PD_S03 = 8'hB3,
    PD_S04 = 8'hB4,
    PD_S05 = 8'hB5,
    PD_S06 = 8'hB6,
    PD_S07 = 8'hB7,
    PD_S08 = 8'hB8,
    PD_S09 = 8'hB9,
    PD_S0A = 8'hBA,
    PD_S0B = 8'hBB,
    PD_S0C = 8'hBC,
    PD_S0D = 8'hBD,
    PD_S0E = 8'hBE,
    PD_S0F = 8'hBF,

    WRF_S00 = 8'hA0,
    WRF_S01 = 8'hA1,
    WRF_S02 = 8'hA2,
    WRF_S03 = 8'hA3,
    WRF_S04 = 8'hA4,
    WRF_S05 = 8'hA5,
    WRF_S06 = 8'hA6,
    WRF_S07 = 8'hA7,
    WRF_S08 = 8'hA8,
    WRF_S09 = 8'hA9,
    WRF_S0A = 8'hAA,
    WRF_S0B = 8'hAB,
    WRF_S0C = 8'hAC,
    WRF_S0D = 8'hAD,
    WRF_S0E = 8'hAE,
    WRF_S0F = 8'hAF
  } EN_STATE;

  //------------------------------------------------------------------------//
  //-- Wire/Flops                                                         --//
  //------------------------------------------------------------------------//
  EN_STATE        smc_stm_cs;
  EN_STATE        smc_stm_ns;
  EN_STATE        smc_return_stm_cs;
  EN_STATE        smc_return_stm_ns;
  EN_STATE        smc_return_x_stm_cs;
  EN_STATE        smc_return_x_stm_ns;

  logic           wb_inta_o_nc;
  logic           MOSI_OEn_o_nc;  //Output enable, active low
  logic           SSn1_o_nc;
  logic           SSn2_o_nc;
  logic           SSn3_o_nc;
  logic           SSn4_o_nc;
  logic           SSn5_o_nc;
  logic           SSn6_o_nc;
  logic           SSn7_o_nc;
  logic           TIP_o;  // transfer in progress

  logic    [ 2:0] wbm_wbs_addr_cs;
  logic    [ 7:0] wbm_wbs_wr_data_cs;
  logic           wbm_wbs_we_cs;
  logic           wbm_wbs_stb_cs;
  logic           wbm_wbs_cyc_cs;

  logic    [ 2:0] wbm_wbs_addr_ns;
  logic    [ 7:0] wbm_wbs_wr_data_ns;
  logic           wbm_wbs_we_ns;
  logic           wbm_wbs_stb_ns;
  logic           wbm_wbs_cyc_ns;

  logic    [23:0] spif_address_cs;
  logic    [23:0] spif_address_ns;
  logic    [ 7:0] spif_wr_data_cs;
  logic    [ 7:0] spif_wr_data_ns;

  logic    [ 8:0] spif_exp_data_cs;
  logic    [ 8:0] spif_exp_data_ns;

  logic    [23:0] spif_rd_cnt_cs;
  logic    [23:0] spif_rd_cnt_ns;
  logic           rfu_path_en_cs;
  logic           rfu_path_en_ns;

  logic           error_flag_cs;
  logic           error_flag_ns;


  logic    [ 7:0] spi_rd_data;

  logic    [ 7:0] wbs_wbm_rd_data;
  logic           wbs_wbm_ack;

  logic    [10:0] smc_timer_cs;
  logic    [10:0] smc_timer_ns;
  logic    [10:0] smc_timer_ini_value;
  logic           smc_timer_timeout;
  logic           smc_timer_kickoff;

  logic           Baud_rate_re_o;

  logic           smc_clear_br_cnt;

  // 05182017 JC
  logic    [ 2:0] smc_cs_error_cnt_cs;
  logic    [ 2:0] smc_cs_error_cnt_ns;

  logic           fsmc_fmic_seq_done_cs;
  logic           fsmc_fmic_seq_done_ns;

  //--------------------------------------------------------------------------------//
  //-- Start Functional Description                                               --//
  //--------------------------------------------------------------------------------//
  //------------------------------------------------------------------------//
  //-- Comb								--//
  //------------------------------------------------------------------------//
  assign fcb_spim_mosi_en 		=  ( fcb_sys_stm == 1'b0 && fcb_spi_mode_en_bo == 1'b1 && fmic_spi_master_en == 1'b1 ) 
					?  1'b1 : 1'b0 	;

  assign fcb_spim_cs_n_en 		=  ( fcb_sys_stm == 1'b0 && fcb_spi_mode_en_bo == 1'b1 && fmic_spi_master_en == 1'b1 )  
                                        ?  1'b1 : 1'b0  ;

  assign fcb_spim_ckout_en 		=  ( fcb_sys_stm == 1'b0 && fcb_spi_mode_en_bo == 1'b1 && fmic_spi_master_en == 1'b1 )  
                                        ?  1'b1 : 1'b0  ;

  assign fsmc_frfu_rd_addr = 'b0;

  assign fsmc_frfu_rd_en = 'b0;

  assign fsmc_frfu_spim_on 		=  ( fcb_sys_stm == 1'b0 && fcb_spi_mode_en_bo == 1'b1 && fmic_spi_master_en == 1'b1 )
					? 1'b1 : 1'b0 ;

  assign fsmc_fmic_fsmc_busy 		=  ( smc_stm_cs == MAIN_S00 || smc_stm_cs == PD_S03 || smc_stm_cs == PD_S06 )
					? 1'b0 : 1'b1 ;

  assign fsmc_fmic_seq_done = fsmc_fmic_seq_done_cs;
  //------------------------------------------------------------------------//
  //-- Timer, 1 base                                                      --//
  //------------------------------------------------------------------------//
  assign smc_timer_timeout = (smc_timer_cs == 11'h01) ? 1'b1 : 1'b0;

  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      smc_timer_cs <= #PAR_DLY 11'h000;
    end else begin
      smc_timer_cs <= #PAR_DLY smc_timer_ns;
    end
  end

  always_comb begin
    if (smc_timer_kickoff == 1'b1) begin
      smc_timer_ns = smc_timer_ini_value;
    end else if (smc_timer_cs == 'b0) begin
      smc_timer_ns = smc_timer_cs;
    end else begin
      smc_timer_ns = smc_timer_cs - 1'b1;
    end
  end

  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      wbm_wbs_addr_cs       <= #PAR_DLY 'b0;
      wbm_wbs_wr_data_cs    <= #PAR_DLY 'b0;
      wbm_wbs_we_cs         <= #PAR_DLY 'b0;
      wbm_wbs_stb_cs        <= #PAR_DLY 'b0;
      wbm_wbs_cyc_cs        <= #PAR_DLY 'b0;
      spif_address_cs       <= #PAR_DLY 'b0;
      spif_wr_data_cs       <= #PAR_DLY 'b0;
      spif_exp_data_cs      <= #PAR_DLY 'b0;
      spif_rd_cnt_cs        <= #PAR_DLY 'b0;
      rfu_path_en_cs        <= #PAR_DLY 'b1;
      error_flag_cs         <= #PAR_DLY 'b0;
      smc_cs_error_cnt_cs   <= #PAR_DLY 'b0;
      fsmc_fmic_seq_done_cs <= #PAR_DLY 'b0;
    end else begin
      wbm_wbs_addr_cs       <= #PAR_DLY wbm_wbs_addr_ns;
      wbm_wbs_wr_data_cs    <= #PAR_DLY wbm_wbs_wr_data_ns;
      wbm_wbs_we_cs         <= #PAR_DLY wbm_wbs_we_ns;
      wbm_wbs_stb_cs        <= #PAR_DLY wbm_wbs_stb_ns;
      wbm_wbs_cyc_cs        <= #PAR_DLY wbm_wbs_cyc_ns;
      spif_address_cs       <= #PAR_DLY spif_address_ns;
      spif_wr_data_cs       <= #PAR_DLY spif_wr_data_ns;
      spif_exp_data_cs      <= #PAR_DLY spif_exp_data_ns;
      spif_rd_cnt_cs        <= #PAR_DLY spif_rd_cnt_ns;
      rfu_path_en_cs        <= #PAR_DLY rfu_path_en_ns;
      error_flag_cs         <= #PAR_DLY error_flag_ns;
      smc_cs_error_cnt_cs   <= #PAR_DLY smc_cs_error_cnt_ns;  //JC
      fsmc_fmic_seq_done_cs <= #PAR_DLY fsmc_fmic_seq_done_ns;
    end
  end


  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      smc_stm_cs <= #PAR_DLY MAIN_S00;
      smc_return_stm_cs <= #PAR_DLY MAIN_S00;
      smc_return_x_stm_cs <= #PAR_DLY MAIN_S00;
    end else begin
      smc_stm_cs <= #PAR_DLY smc_stm_ns;
      smc_return_stm_cs <= #PAR_DLY smc_return_stm_ns;
      smc_return_x_stm_cs <= #PAR_DLY smc_return_x_stm_ns;
    end
  end
  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  always_comb begin
    smc_stm_ns                  = smc_stm_cs;
    smc_return_stm_ns           = smc_return_stm_cs;
    smc_return_x_stm_ns         = smc_return_x_stm_cs;
    wbm_wbs_addr_ns             = wbm_wbs_addr_cs;
    wbm_wbs_wr_data_ns          = wbm_wbs_wr_data_cs;
    wbm_wbs_we_ns               = wbm_wbs_we_cs;
    wbm_wbs_stb_ns              = wbm_wbs_stb_cs;
    wbm_wbs_cyc_ns              = wbm_wbs_cyc_cs;
    spif_address_ns             = spif_address_cs;
    spif_wr_data_ns             = spif_wr_data_cs;
    spif_exp_data_ns            = spif_exp_data_cs;
    spif_rd_cnt_ns              = spif_rd_cnt_cs;
    rfu_path_en_ns              = rfu_path_en_cs;

    error_flag_ns               = error_flag_cs;
    smc_timer_ini_value         = 'b0;
    smc_timer_kickoff           = 'b0;

    fsmc_frfu_wr_addr           = 'b0;
    fsmc_frfu_wr_en             = 'b0;
    fsmc_frfu_wr_data           = 'b0;
    fsmc_frfu_cwf_wr_data       = 'b0;
    fsmc_frfu_cwf_wr_en         = 'b0;
    fsmc_frfu_set_fb_cfg_done   = 'b0;
    fsmc_fmic_clr_spi_master_en = 'b0;
    fsmc_frfu_clr_rcclk_en      = 'b0;

    fsmc_frfu_set_pd            = 'b0;
    fsmc_frfu_set_clp_pd        = 'b0;
    fsmc_frfu_set_quad_pd       = 'b0;

    smc_clear_br_cnt            = 'b0;
    smc_cs_error_cnt_ns         = smc_cs_error_cnt_cs;  // JC
    fsmc_fmic_seq_done_ns       = fsmc_fmic_seq_done_cs;

    unique case (smc_stm_cs)
      MAIN_S00: begin
        if (fcb_sys_stm == 1'b0 && fcb_spi_mode_en_bo == 1'b1 && fmic_spi_master_en == 1'b1) begin
          smc_stm_ns = MAIN_S01;
        end else begin
          smc_stm_ns = MAIN_S00;
        end
      end
      MAIN_S01: begin
        smc_timer_ini_value = PAR_FLASH_PWR_UP_TIME;
        smc_timer_kickoff = 1'b1;
        smc_stm_ns = MAIN_S02;
      end
      MAIN_S02: begin
        wbm_wbs_addr_ns    = PAR_SPI_ADR_0;
        wbm_wbs_wr_data_ns = PAR_SPI_ADR_0_CFG;
        wbm_wbs_we_ns      = 1'b1;
        wbm_wbs_stb_ns     = 1'b1;
        wbm_wbs_cyc_ns     = 1'b1;
        smc_stm_ns         = MAIN_S03;
      end
      MAIN_S03: begin
        wbm_wbs_addr_ns    = PAR_SPI_ADR_2;
        wbm_wbs_wr_data_ns = PAR_SPI_ADR_2_CFG;
        wbm_wbs_we_ns      = 1'b1;
        wbm_wbs_stb_ns     = 1'b1;
        wbm_wbs_cyc_ns     = 1'b1;
        smc_stm_ns         = MAIN_S04;
      end
      MAIN_S04: begin
        wbm_wbs_addr_ns    = PAR_SPI_ADR_5;
        wbm_wbs_wr_data_ns = PAR_SPI_ADR_5_CFG;
        wbm_wbs_we_ns      = 1'b1;
        wbm_wbs_stb_ns     = 1'b1;
        wbm_wbs_cyc_ns     = 1'b1;
        smc_stm_ns         = MAIN_S05;
      end
      MAIN_S05: begin
        wbm_wbs_we_ns  = 1'b0;
        wbm_wbs_stb_ns = 1'b0;
        wbm_wbs_cyc_ns = 1'b0;
        smc_stm_ns     = MAIN_S06;
      end
      MAIN_S06: begin
        if (smc_timer_timeout == 1'b1) begin
          smc_stm_ns = MAIN_S07;
        end else begin
          smc_stm_ns = smc_stm_cs;
        end
      end
      MAIN_S07: begin
        smc_stm_ns = CMD_S00;
        smc_return_stm_ns = MAIN_S08;
        spif_address_ns = spif_address_cs;
        spif_wr_data_ns = PAR_FLASH_DEEP_PWR_DIS;
      end
      MAIN_S08: begin
        smc_stm_ns = END_S00;
        smc_return_stm_ns = MAIN_S09;
      end
      MAIN_S09: begin
        spif_rd_cnt_ns      = spif_rd_cnt_cs + 1'b1;
        smc_timer_ini_value = PAR_FLASH_TRES1_TIME;
        smc_timer_kickoff   = 1'b1;
        smc_stm_ns          = MAIN_S0A;
      end
      MAIN_S0A: begin
        if (smc_timer_timeout == 1'b1) begin
          smc_stm_ns = MAIN_S0B;
        end else begin
          smc_stm_ns = smc_stm_cs;
        end
      end
      MAIN_S0B: begin
        smc_stm_ns = MAIN_S0C;
      end
      MAIN_S0C: begin
        smc_stm_ns = READ_S00;
        smc_return_stm_ns = MAIN_S0D;
        spif_address_ns = 'b0;
        spif_wr_data_ns = PAR_FLASH_READ_CMD;
      end
      MAIN_S0D: begin
        spif_exp_data_ns[8] = 1'b1;
        spif_exp_data_ns[7:0] = frfu_fsmc_spim_ckb_0;
        smc_stm_ns = CMP_S00;
        smc_return_stm_ns = MAIN_S0E;
      end
      MAIN_S0E: begin
        spif_exp_data_ns[8] = 1'b1;
        spif_exp_data_ns[7:0] = frfu_fsmc_spim_ckb_1;
        smc_stm_ns = CMP_S00;
        smc_return_stm_ns = MAIN_S0F;
      end
      MAIN_S0F: begin
        spif_exp_data_ns[8] = 1'b1;
        spif_exp_data_ns[7:0] = frfu_fsmc_spim_device_id;
        smc_stm_ns = CMP_S00;
        smc_return_stm_ns = MAIN_S10;
      end
      MAIN_S10: begin
        spif_exp_data_ns[8] = 1'b1;  // No need to check?
        spif_exp_data_ns[7:0] = 8'h01;
        smc_stm_ns = CMP_S00;
        smc_return_stm_ns = MAIN_S11;
      end
      MAIN_S11: begin
        if (error_flag_cs == 1'b1) begin
          if (spif_rd_cnt_cs >= 24'h005) begin
            smc_stm_ns = END_S00;  // END
            smc_return_stm_ns = PD_S00;
            //smc_stm_ns		= PD_S00 ;
          end else begin
            error_flag_ns = 1'b0;  // Clear and Re-Do
            //smc_stm_ns		= MAIN_S09 ;
            smc_stm_ns = END_S00;  // END
            smc_return_stm_ns = MAIN_S09;
          end
        end else begin
          smc_stm_ns = END_S00;  // END
          smc_return_stm_ns = MAIN_S12;
        end
      end
      //
      // 05182017
      // JC
      //
      MAIN_S12: begin
        spif_rd_cnt_ns = 24'h003;
        spif_address_ns = 24'h00_00_04;
        spif_wr_data_ns = PAR_FLASH_READ_CMD;
        rfu_path_en_ns = 1'b1;
        smc_stm_ns = WRF_S00;
        smc_return_stm_ns = MAIN_S13;
      end
      MAIN_S13: begin
        smc_stm_ns = MAIN_S14;
      end
      MAIN_S14: begin
        wbm_wbs_addr_ns    = PAR_SPI_ADR_0;
        wbm_wbs_wr_data_ns = frfu_spim_baud_rate;
        wbm_wbs_we_ns      = 1'b1;
        wbm_wbs_stb_ns     = 1'b1;
        wbm_wbs_cyc_ns     = 1'b1;
        smc_stm_ns         = MAIN_S15;
      end
      MAIN_S15: begin
        wbm_wbs_we_ns    = 1'b0;
        wbm_wbs_stb_ns   = 1'b0;
        wbm_wbs_cyc_ns   = 1'b0;
        smc_clear_br_cnt = 1'b1;
        smc_stm_ns       = MAIN_S16;
      end
      MAIN_S16: begin
        smc_stm_ns = MAIN_S17;
      end
      MAIN_S17: begin
        spif_rd_cnt_ns = 24'h019;
        spif_address_ns = 24'h00_00_07;
        spif_wr_data_ns = PAR_FLASH_READ_CMD;
        rfu_path_en_ns = 1'b1;
        smc_stm_ns = WRF_S00;
        smc_return_stm_ns = MAIN_S18;
      end
      MAIN_S18: begin
        smc_stm_ns = MAIN_S19;
      end
      MAIN_S19: begin
        spif_rd_cnt_ns = {frfu_wrd_cnt_b2, frfu_wrd_cnt_b1, frfu_wrd_cnt_b0};
        spif_address_ns = 24'h00_00_20;
        spif_wr_data_ns = PAR_FLASH_READ_CMD;
        rfu_path_en_ns = 1'b0;
        smc_stm_ns = WRF_S00;
        smc_return_stm_ns = MAIN_S1A;
      end
      MAIN_S1A: begin
        smc_stm_ns = MAIN_S1B;
      end
      MAIN_S1B: begin
        if (ffsr_fsr_busy == 1'b0) begin
          smc_stm_ns = MAIN_S1C;
        end else begin
          smc_stm_ns = smc_stm_cs;
        end
      end
      MAIN_S1C: begin
        smc_stm_ns = MAIN_S1D;
      end
      MAIN_S1D: begin
        //smc_stm_ns		= MAIN_S1E ;
        smc_stm_ns = MAIN_S30;  // 20170608
      end
      //
      //
      // JC
      // Add State Machine Here 20170518
      // 
      // STATE 0~15 	: Additional Wait States To Ensure The Checksum Caculation Is Done. 
      // CHECK STATE 	: Check the Checksum Caculation Result 
      // 		  1) If the Result is OK, jump to the SPI Quad Power Down Sequence 	
      //		  2) If the Result is Not OK and the Failure Time is less than 5, Restart the SPI Master sequences, Address 0x04, MAIN_S12
      //		  3) If the Result is Not OK and the Failure Time is equal 5, Power down eFPGA -- New Added State Flow
      //
      //
      MAIN_S30: begin
        smc_timer_ini_value = 11'b000_0001_0000;  // 16 Cycles
        smc_timer_kickoff = 1'b1;
        smc_stm_ns = MAIN_S31;
      end
      MAIN_S31: begin
        smc_stm_ns = MAIN_S32;
      end
      MAIN_S32: begin
        if (smc_timer_timeout == 1'b1) begin
          smc_stm_ns = MAIN_S33;
        end else begin
          smc_stm_ns = smc_stm_cs;
        end
      end
      MAIN_S33: begin
        if (frfu_fsmc_checksum_enable == 1'b1) begin
          if (frfu_fsmc_checksum_status == 1'b1) begin
            error_flag_ns = 1'b0;
            smc_stm_ns    = MAIN_S1E;  // Jump to Quad Power Down, MAIN_S1E
          end
            else if ( smc_cs_error_cnt_cs >= 3'b100 ) // Reach 4 times and this time is fail as well.
              begin
            error_flag_ns = 1'b1;
            smc_stm_ns    = MAIN_S40;  // Jump to Power Down State --> New Added
          end else begin
            error_flag_ns       = 1'b0;  // Fail, but less than 5 times
            smc_stm_ns          = MAIN_S12;  // Restart the test
            smc_cs_error_cnt_ns = smc_cs_error_cnt_cs + 3'b001;  // JC
          end
        end else begin
          error_flag_ns = 1'b0;  // 
          smc_stm_ns    = MAIN_S1E;  // Jump to Quad Power Down, MAIN_S1E
        end
      end
      //----------------------------------------------------------------//
      //--								--//
      //-- Whole Chip Power Down					--//
      //--								--//
      //-- Set Power Down Register					--//
      //-- Wait for BUSY signal is De-asserted			--//
      //-- PD, Jump to PD_S00						--//
      //--								--//
      //----------------------------------------------------------------//
      MAIN_S40: begin
        smc_stm_ns = MAIN_S41;
        if (fcb_clp_mode_en_bo == 1'b0) begin
          fsmc_frfu_set_pd = 1'b1;  // JC
        end else begin
          fsmc_frfu_set_clp_pd = 1'b1;
        end
      end
      MAIN_S41: begin
        smc_stm_ns = MAIN_S42;
      end
      MAIN_S42: begin
        if (fpmu_pmu_busy == 1'b1 || fclp_clp_busy == 1'b1) begin
          smc_stm_ns = MAIN_S43;
        end else begin
          smc_stm_ns = smc_stm_cs;
        end
      end
      MAIN_S43: begin
        smc_stm_ns = MAIN_S44;
      end
      MAIN_S44: begin
        if (fpmu_pmu_busy == 1'b0 && fclp_clp_busy == 1'b0) begin
          smc_stm_ns = MAIN_S45;
        end else begin
          smc_stm_ns = smc_stm_cs;
        end
      end
      MAIN_S45: begin
        smc_stm_ns = MAIN_S46;
      end
      MAIN_S46 :	// Power Down
      begin
        smc_stm_ns = PD_S00;  //17
      end
      //
      //
      //
      //
      //
      MAIN_S1E: begin
        smc_stm_ns = READ_S00;
        smc_return_stm_ns = MAIN_S1F;
        spif_address_ns = {frfu_wrd_cnt_b2, frfu_wrd_cnt_b1, frfu_wrd_cnt_b0} + 24'h000020;
        spif_wr_data_ns = PAR_FLASH_READ_CMD;
      end
      MAIN_S1F: begin
        smc_stm_ns = MAIN_S20;
      end
      MAIN_S20: begin
        smc_stm_ns = RWS_S00;
        smc_return_stm_ns = MAIN_S21;
        spif_address_ns = 24'h00_00_30;
        rfu_path_en_ns = 1'b1;
      end

      MAIN_S21: begin
        smc_stm_ns = MAIN_S22;
      end
      MAIN_S22: begin
        smc_stm_ns = MAIN_S23;
      end
      MAIN_S23: begin
        smc_stm_ns = MAIN_S24;
      end
      MAIN_S24: begin
        smc_stm_ns = RWS_S00;
        smc_return_stm_ns = MAIN_S25;
        spif_address_ns = 24'h00_00_31;
        rfu_path_en_ns = 1'b1;
      end
      MAIN_S25: begin
        smc_stm_ns = MAIN_S26;
      end
      MAIN_S26: begin
        smc_stm_ns = MAIN_S27;
        fsmc_frfu_set_fb_cfg_done = 1'b1;  // 20170612
      end

      MAIN_S27: begin
        smc_stm_ns = MAIN_S28;
      end

      MAIN_S28: begin
        smc_stm_ns = MAIN_S29;
      end

      MAIN_S29: begin
        if ( fpmu_pmu_busy == 1'b1 && fcb_clp_mode_en_bo == 1'b0 ) // PMU mode
	  begin
          smc_stm_ns = smc_stm_cs;
        end else begin
          smc_stm_ns = MAIN_S2A;
        end
      end

      MAIN_S2A: begin
        smc_stm_ns = MAIN_S2B;
      end

      MAIN_S2B: begin
        smc_stm_ns = MAIN_S2C;
        fsmc_frfu_set_quad_pd = 1'b1;
      end

      MAIN_S2C: begin
        smc_stm_ns = MAIN_S2D;
      end

      MAIN_S2D: begin
        smc_stm_ns = MAIN_S2E;
      end

      MAIN_S2E: begin
        if ( fpmu_pmu_busy == 1'b1 || fclp_clp_busy == 1'b1 || frfu_fsmc_pending_pd_req == 1'b1 )
	  begin
          smc_stm_ns = smc_stm_cs;
        end else begin
          smc_stm_ns = MAIN_S2F;
        end
      end
      MAIN_S2F :	// Need to update --> JC --> 05182017
      begin
        smc_stm_ns = PD_S00;  // Jump to Power Down State
      end
      //------------------------------------------------------------------------//
      //-- END	                                                        --//
      //------------------------------------------------------------------------//
      END_S00: begin
        wbm_wbs_addr_ns    = PAR_SPI_ADR_4;
        wbm_wbs_wr_data_ns = PAR_SPI_END_CYC;
        wbm_wbs_we_ns      = 1'b1;
        wbm_wbs_stb_ns     = 1'b1;
        wbm_wbs_cyc_ns     = 1'b1;
        smc_stm_ns         = END_S01;
      end
      END_S01: begin
        wbm_wbs_we_ns  = 1'b0;
        wbm_wbs_stb_ns = 1'b0;
        wbm_wbs_cyc_ns = 1'b0;
        smc_stm_ns     = END_S02;
      end
      END_S02: begin
        if (Baud_rate_re_o == 1'b1) begin
          smc_stm_ns = END_S03;
        end else begin
          smc_stm_ns = END_S02;
        end
      end
      END_S03: begin
        smc_stm_ns = smc_return_stm_cs;
      end
      //------------------------------------------------------------------------//
      //-- READ	                                                        --//
      //------------------------------------------------------------------------//
      READ_S00: begin
        wbm_wbs_addr_ns    = PAR_SPI_ADR_3;
        wbm_wbs_wr_data_ns = spif_wr_data_cs;
        wbm_wbs_we_ns      = 1'b1;
        wbm_wbs_stb_ns     = 1'b1;
        wbm_wbs_cyc_ns     = 1'b1;
        smc_stm_ns         = READ_S01;
      end
      READ_S01: begin
        wbm_wbs_addr_ns    = PAR_SPI_ADR_4;
        wbm_wbs_wr_data_ns = PAR_SPI_WR_CYC;
        wbm_wbs_we_ns      = 1'b1;
        wbm_wbs_stb_ns     = 1'b1;
        wbm_wbs_cyc_ns     = 1'b1;
        smc_stm_ns         = READ_S02;
      end
      READ_S02: begin
        wbm_wbs_we_ns  = 1'b0;
        wbm_wbs_stb_ns = 1'b0;
        wbm_wbs_cyc_ns = 1'b0;
        if (TIP_o == 1'b1) begin
          smc_stm_ns = READ_S03;
        end else begin
          smc_stm_ns = smc_stm_cs;
        end
      end
      READ_S03: begin
        if (TIP_o == 1'b0) begin
          smc_stm_ns = READ_S04;
        end else begin
          smc_stm_ns = smc_stm_cs;
        end
      end
      READ_S04: begin
        wbm_wbs_addr_ns    = PAR_SPI_ADR_3;
        wbm_wbs_wr_data_ns = spif_address_cs[23:16];
        wbm_wbs_we_ns      = 1'b1;
        wbm_wbs_stb_ns     = 1'b1;
        wbm_wbs_cyc_ns     = 1'b1;
        smc_stm_ns         = READ_S05;
      end
      READ_S05: begin
        wbm_wbs_addr_ns    = PAR_SPI_ADR_4;
        wbm_wbs_wr_data_ns = PAR_SPI_WR_CYC;
        wbm_wbs_we_ns      = 1'b1;
        wbm_wbs_stb_ns     = 1'b1;
        wbm_wbs_cyc_ns     = 1'b1;
        smc_stm_ns         = READ_S06;
      end
      READ_S06: begin
        wbm_wbs_we_ns  = 1'b0;
        wbm_wbs_stb_ns = 1'b0;
        wbm_wbs_cyc_ns = 1'b0;
        if (TIP_o == 1'b1) begin
          smc_stm_ns = READ_S07;
        end else begin
          smc_stm_ns = smc_stm_cs;
        end
      end
      READ_S07: begin
        if (TIP_o == 1'b0) begin
          smc_stm_ns = READ_S08;
        end else begin
          smc_stm_ns = smc_stm_cs;
        end
      end
      READ_S08: begin
        wbm_wbs_addr_ns    = PAR_SPI_ADR_3;
        wbm_wbs_wr_data_ns = spif_address_cs[15:8];
        wbm_wbs_we_ns      = 1'b1;
        wbm_wbs_stb_ns     = 1'b1;
        wbm_wbs_cyc_ns     = 1'b1;
        smc_stm_ns         = READ_S09;
      end
      READ_S09: begin
        wbm_wbs_addr_ns    = PAR_SPI_ADR_4;
        wbm_wbs_wr_data_ns = PAR_SPI_WR_CYC;
        wbm_wbs_we_ns      = 1'b1;
        wbm_wbs_stb_ns     = 1'b1;
        wbm_wbs_cyc_ns     = 1'b1;
        smc_stm_ns         = READ_S0A;
      end
      READ_S0A: begin
        wbm_wbs_we_ns  = 1'b0;
        wbm_wbs_stb_ns = 1'b0;
        wbm_wbs_cyc_ns = 1'b0;
        if (TIP_o == 1'b1) begin
          smc_stm_ns = READ_S0B;
        end else begin
          smc_stm_ns = smc_stm_cs;
        end
      end
      READ_S0B: begin
        if (TIP_o == 1'b0) begin
          smc_stm_ns = READ_S0C;
        end else begin
          smc_stm_ns = smc_stm_cs;
        end
      end
      READ_S0C: begin
        wbm_wbs_addr_ns    = PAR_SPI_ADR_3;
        wbm_wbs_wr_data_ns = spif_address_cs[7:0];
        wbm_wbs_we_ns      = 1'b1;
        wbm_wbs_stb_ns     = 1'b1;
        wbm_wbs_cyc_ns     = 1'b1;
        smc_stm_ns         = READ_S0D;
      end
      READ_S0D: begin
        wbm_wbs_addr_ns    = PAR_SPI_ADR_4;
        wbm_wbs_wr_data_ns = PAR_SPI_WR_CYC;
        wbm_wbs_we_ns      = 1'b1;
        wbm_wbs_stb_ns     = 1'b1;
        wbm_wbs_cyc_ns     = 1'b1;
        smc_stm_ns         = READ_S0E;
      end
      READ_S0E: begin
        wbm_wbs_we_ns  = 1'b0;
        wbm_wbs_stb_ns = 1'b0;
        wbm_wbs_cyc_ns = 1'b0;
        if (TIP_o == 1'b1) begin
          smc_stm_ns = READ_S0F;
        end else begin
          smc_stm_ns = smc_stm_cs;
        end
      end
      READ_S0F: begin
        if (TIP_o == 1'b0) begin
          smc_stm_ns = smc_return_stm_cs;
        end else begin
          smc_stm_ns = smc_stm_cs;
        end
      end
      //------------------------------------------------------------------------//
      //-- CMD	                                                        --//
      //------------------------------------------------------------------------//
      CMD_S00: begin
        wbm_wbs_addr_ns    = PAR_SPI_ADR_3;
        wbm_wbs_wr_data_ns = spif_wr_data_cs;
        wbm_wbs_we_ns      = 1'b1;
        wbm_wbs_stb_ns     = 1'b1;
        wbm_wbs_cyc_ns     = 1'b1;
        smc_stm_ns         = CMD_S01;
      end
      CMD_S01: begin
        wbm_wbs_addr_ns    = PAR_SPI_ADR_4;
        wbm_wbs_wr_data_ns = PAR_SPI_WR_CYC;
        wbm_wbs_we_ns      = 1'b1;
        wbm_wbs_stb_ns     = 1'b1;
        wbm_wbs_cyc_ns     = 1'b1;
        smc_stm_ns         = CMD_S02;
      end
      CMD_S02: begin
        wbm_wbs_we_ns  = 1'b0;
        wbm_wbs_stb_ns = 1'b0;
        wbm_wbs_cyc_ns = 1'b0;
        if (TIP_o == 1'b1) begin
          smc_stm_ns = CMD_S03;
        end else begin
          smc_stm_ns = smc_stm_cs;
        end
      end
      CMD_S03: begin
        if (TIP_o == 1'b0) begin
          smc_stm_ns = CMD_S04;
        end else begin
          smc_stm_ns = smc_stm_cs;
        end
      end
      CMD_S04: begin
        smc_stm_ns = smc_return_stm_cs;
      end
      //------------------------------------------------------------------------//
      //-- CMP	                                                        --//
      //------------------------------------------------------------------------//
      CMP_S00: begin
        wbm_wbs_addr_ns    = PAR_SPI_ADR_4;
        wbm_wbs_wr_data_ns = PAR_SPI_READ_CYC;
        wbm_wbs_we_ns      = 1'b1;
        wbm_wbs_stb_ns     = 1'b1;
        wbm_wbs_cyc_ns     = 1'b1;
        smc_stm_ns         = CMP_S01;
      end
      CMP_S01: begin
        wbm_wbs_we_ns  = 1'b0;
        wbm_wbs_stb_ns = 1'b0;
        wbm_wbs_cyc_ns = 1'b0;
        if (TIP_o == 1'b1) begin
          smc_stm_ns = CMP_S02;
        end else begin
          smc_stm_ns = smc_stm_cs;
        end
      end
      CMP_S02: begin
        if (TIP_o == 1'b0) begin
          smc_stm_ns = CMP_S03;
        end else begin
          smc_stm_ns = smc_stm_cs;
        end
      end
      CMP_S03: begin
        smc_stm_ns = smc_return_stm_cs;
        if (spif_exp_data_cs[8] == 1'b1 && (spif_exp_data_cs[7:0] != spi_rd_data)) begin
          error_flag_ns = 1'b1;
        end
      end
      //------------------------------------------------------------------------//
      //-- PD  	                                                        --//
      //------------------------------------------------------------------------//
      PD_S00: begin
        smc_stm_ns = CMD_S00;
        smc_return_stm_ns = PD_S01;
        spif_address_ns = 'b0;
        spif_wr_data_ns = PAR_FLASH_DEEP_PWR_EN;
      end
      PD_S01: begin
        smc_stm_ns = END_S00;
        smc_return_stm_ns = PD_S02;
      end
      PD_S02: begin
        if (error_flag_cs == 1'b1) begin
          smc_stm_ns = PD_S03;
        end else begin
          smc_stm_ns = PD_S04;
        end
      end
      PD_S03: begin
        smc_stm_ns = smc_stm_cs;  // Error End
      end
      PD_S04: begin
        //fsmc_frfu_set_fb_cfg_done 	= 1'b1 ;	
        fsmc_fmic_seq_done_ns = 1'b1;
        smc_stm_ns = PD_S05;
      end
      PD_S05: begin
        smc_stm_ns = PD_S06;
        if (frfu_fsmc_sw2_spis == 1'b1) begin
          fsmc_fmic_clr_spi_master_en = 1'b1;
        end else if (frfu_fsmc_rc_clk_dis_cfg == 1'b1) begin
          fsmc_frfu_clr_rcclk_en = 1'b1;
        end
      end
      PD_S06: begin
        smc_stm_ns = smc_stm_cs;  // Correct End
      end
      //------------------------------------------------------------------------//
      //-- Write Flow                                                         --//
      //------------------------------------------------------------------------//
      WRF_S00: begin
        smc_stm_ns = READ_S00;
        smc_return_stm_ns = WRF_S01;
        smc_return_x_stm_ns = smc_return_stm_cs;
      end
      WRF_S01: begin
        smc_stm_ns        = RWS_S00;
        smc_return_stm_ns = WRF_S02;
      end
      WRF_S02: begin
        if (spif_rd_cnt_cs <= 24'h00_00_01) begin
          smc_stm_ns = WRF_S03;
        end else begin
          smc_stm_ns        = RWS_S00;  // 17
          smc_return_stm_ns = WRF_S02;  // 17 
          spif_rd_cnt_ns    = spif_rd_cnt_cs - 1'b1;
          spif_address_ns   = spif_address_cs + 1'b1;
        end
      end
      WRF_S03: begin
        smc_stm_ns = END_S00;
        smc_return_stm_ns = WRF_S04;
      end
      WRF_S04: begin
        smc_stm_ns = smc_return_x_stm_cs;
      end
      //------------------------------------------------------------------------//
      //-- READ Write Seq                                                     --//
      //------------------------------------------------------------------------//
      RWS_S00: begin
        wbm_wbs_addr_ns    = PAR_SPI_ADR_4;
        wbm_wbs_wr_data_ns = PAR_SPI_READ_CYC;
        wbm_wbs_we_ns      = 1'b1;
        wbm_wbs_stb_ns     = 1'b1;
        wbm_wbs_cyc_ns     = 1'b1;
        smc_stm_ns         = RWS_S01;
      end
      RWS_S01: begin
        wbm_wbs_we_ns  = 1'b0;
        wbm_wbs_stb_ns = 1'b0;
        wbm_wbs_cyc_ns = 1'b0;
        if (TIP_o == 1'b1) begin
          smc_stm_ns = RWS_S02;
        end else begin
          smc_stm_ns = smc_stm_cs;
        end
      end
      RWS_S02: begin
        if (TIP_o == 1'b0) begin
          smc_stm_ns = smc_return_stm_cs;
          smc_stm_ns = RWS_S03;
        end else begin
          smc_stm_ns = smc_stm_cs;
        end
      end
      RWS_S03: begin
        smc_stm_ns = smc_return_stm_cs;
        if (rfu_path_en_cs == 1'b1) begin
          fsmc_frfu_wr_addr = spif_address_cs[6:0];
          fsmc_frfu_wr_data = spi_rd_data;
          fsmc_frfu_wr_en   = 1'b1;
        end else begin
          fsmc_frfu_cwf_wr_data = spi_rd_data;
          fsmc_frfu_cwf_wr_en   = 1'b1;
        end
      end

      //------------------------------------------------------------------------//
      //-- Default	                                                        --//
      //------------------------------------------------------------------------//
      default: begin
        smc_stm_ns = MAIN_S00;
      end
    endcase
  end
  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  spi_master_top spi_master_top_INST (
      .smc_clear_br_cnt(smc_clear_br_cnt),
      .Baud_rate_re_o(Baud_rate_re_o),
      .spi_rd_data(spi_rd_data),
      .Baud_Clk_i(fcb_spim_ckout_in),
      .wb_clk_i(fcb_sys_clk),
      .wb_rst_i(1'b0),  // Not a good approach//No Use
      .arst_i(~fcb_sys_rst_n),  // Not a good approach
      .wb_adr_i(wbm_wbs_addr_cs),
      .wb_dat_i(wbm_wbs_wr_data_cs),
      .wb_dat_o(wbs_wbm_rd_data),
      .wb_we_i(wbm_wbs_we_cs),
      .wb_stb_i(wbm_wbs_stb_cs),
      .wb_cyc_i(wbm_wbs_cyc_cs),
      .wb_ack_o(wbs_wbm_ack),  // Slave to Master
      .wb_inta_o(wb_inta_o_nc),
      .TIP_o(TIP_o),
      .test_mode_en(1'b0),
      .test_clk(1'b0),
      .MISO_i(fcb_spim_miso),
      .MOSI_i(1'b0),  // No Loop Back
      .MOSI_o(fcb_spim_mosi),
      .MOSI_OEn_o(MOSI_OEn_o_nc),
      .SCLK_o(fcb_spim_ckout),
      .SSn0_o(fcb_spim_cs_n),
      .SSn1_o(SSn1_o_nc),
      .SSn2_o(SSn2_o_nc),
      .SSn3_o(SSn3_o_nc),
      .SSn4_o(SSn4_o_nc),
      .SSn5_o(SSn5_o_nc),
      .SSn6_o(SSn6_o_nc),
      .SSn7_o(SSn7_o_nc)
  );

  //--------------------------------------------------------------------------------//
  //-- END                                                                        --//
  //--------------------------------------------------------------------------------//
endmodule


