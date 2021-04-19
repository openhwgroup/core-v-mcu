// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

module fcbmic (
    //------------------------------------------------------------------------//
    //-- INPUT PORT                                                         --//
    //------------------------------------------------------------------------//
    input logic       fcb_sys_clk,  //Main Clock for FCB except SPI Slave Int
    input logic       fcb_sys_rst_n,  //Main Reset for FCB except SPI Slave int
    input logic       fcb_spis_clk,  //Clock for SPIS Slave Interface
    input logic       fcb_sys_stm,  //1'b1 : Put the module into Test Mode
    input logic       fcb_spis_cs_n,  //SPI Slave Chip Select
    input logic       fcb_vlp,  //1'b1 Put the FB Macro into VLP Mode. 1'
    input logic       fcb_spi_mode_en_bo,  //1'b1 : SPI Master/Slave is Enable. 1'b0
    input logic       fcb_pif_en,  //1'b1 : Enable the PIF mode. Note this b
    input logic       fcb_pif_8b_mode_bo,  //1'b1 : PIF DI/DO are 8 bits and in Simp
    input logic       fcb_spi_master_en,  //1'b1: Enable SPI Master Mode, 1'b0: Ena
    input logic       fsmc_fmic_clr_spi_master_en,  //Clear SPI_MASTER_EN and Switch the mode
    input logic       frfu_fmic_done_op_mask_n,  //CFG Flag, 0x0 Mask the Cfg Output
    input logic       ffsr_fmic_fsr_busy,  //Indicate the FSR is Busy
    input logic       fpmu_fmic_pmu_busy,  //Indicate the PMU is Busy
    input logic [3:0] frfu_fmic_io_sv_180,  //
    input logic       fsmc_fmic_fsmc_busy,  //FSMC Busy
    input logic       frfu_fmic_rc_clk_en,  //RC Clock Enable
    input logic       fcb_fb_cfg_done,
    input logic       frfu_fmic_vlp_pin_en,
    input logic       frfu_fmic_fb_cfg_done,
    input logic       fclp_clp_busy,
    input logic       frfu_fpmu_pmu_chip_vlp_en,  //JC
    input logic       frfu_fpmu_pmu_chip_vlp_wu_en,  //JC
    input logic [1:0] fclp_frfu_clp_pw_sta,  //JC
    input logic       fcb_clp_mode_en_bo,  //JC
    input logic       frfu_fclp_clp_vlp_wu_en,  //JC 01262017
    input logic       frfu_fclp_clp_vlp_en,  //JC 01262017
    input logic       fcb_vlp_pwrdis_ifx,  //JC 01262017
    input logic       fsmc_fmic_seq_done,  //JC

    //------------------------------------------------------------------------//
    //-- OUTPUT PORT                                                        --//
    //------------------------------------------------------------------------//

    output logic       fmic_frfu_set_rc_clk_en,  //Set RC Clock Enable Register
    output logic       fmic_frfu_set_pmu_chip_wu_en,  //SET Whole Chip WakeUp Enable
    output logic       fmic_frfu_set_pmu_chip_vlp_en,  //SET Whole Chip VLP Enable
    output logic       fmic_spi_master_en,  //1'b1: Enable SPI Master Mode, 1'b0: Ena
    output logic       fcb_cfg_done,  //Cfg Done
    output logic       fcb_cfg_done_en,  //Cfg Done Output Enable
    output logic       fcb_sysclk_en,  //1'b1 : Turn on the RC/SYS clock. Note:
    output logic [3:0] fcb_io_sv_180  //Select the IO Supply Voltage, 0x0 : 3.3
);

  //------------------------------------------------------------------------//
  //-- Local Parameter                                                    --//
  //------------------------------------------------------------------------//
  localparam PAR_DLY = 1'b1;
  localparam PAR_DDY = 1'b1;

  //------------------------------------------------------------------------//
  //-- EMUN/Flops                                                         --//
  //------------------------------------------------------------------------//
  //------------------------------------------------------------------------//
  //-- EMUN/Flops                                                         --//
  //------------------------------------------------------------------------//
  typedef enum logic [3:0] {
    MIC_VLP_S0 = 4'h0,
    MIC_VLP_S1 = 4'h1,
    MIC_VLP_S2 = 4'h2,
    MIC_VLP_S3 = 4'h3,
    MIC_VLP_S4 = 4'h4,
    MIC_VLP_S5 = 4'h5,
    MIC_VLP_S6 = 4'h6,
    MIC_VLP_S7 = 4'h7,
    MIC_VLP_S8 = 4'h8,
    MIC_VLP_S9 = 4'h9,
    MIC_VLP_SA = 4'hA,
    MIC_VLP_SB = 4'hB,
    MIC_VLP_SC = 4'hC,
    MIC_VLP_SD = 4'hD,
    MIC_VLP_SE = 4'hE,
    MIC_VLP_SF = 4'hF
  } EN_STATE;

  //------------------------------------------------------------------------//
  //-- Wire/Flops                                                         --//
  //------------------------------------------------------------------------//
  EN_STATE mic_vlp_stm_cs;
  EN_STATE mic_vlp_stm_ns;

  logic    fcb_spi_master_en_syncff1;
  logic    fsmc_fmic_clr_spi_master_en_latch;

  logic    frfu_fmic_rc_clk_en_dly1;
  logic    frfu_fmic_rc_clk_en_dly2;
  logic    frfu_fmic_rc_clk_en_dly3;
  logic    frfu_fmic_rc_clk_en_dly4;
  logic    frfu_fmic_rc_clk_en_dly5;
  logic    frfu_fmic_rc_clk_en_dly6;
  logic    frfu_fmic_rc_clk_en_dly7;
  logic    frfu_fmic_rc_clk_en_dly8;

  logic    fmic_frfu_set_rc_clk_en_cs;
  logic    fcb_vlp_dly1;
  logic    fcb_vlp_dly2;
  logic    fcb_vlp_dly3;

  logic    fcb_vlp_0;
  logic    fcb_vlp_1;

  logic    fcb_vlp_temp;

  //--------------------------------------------------------------------------------//
  //-- Start Functional Description                                               --//
  //--------------------------------------------------------------------------------//
  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //-- Assumption is the Clock Needs to be always runnig 			--//
  //------------------------------------------------------------------------//
  assign fcb_vlp_temp = ( ( fcb_vlp & fcb_clp_mode_en_bo ) | ( fcb_vlp_pwrdis_ifx & (~fcb_clp_mode_en_bo )));

  assign fcb_vlp_0 = ~(fcb_vlp_temp | fcb_vlp_dly1 | fcb_vlp_dly2 | fcb_vlp_dly3);
  assign fcb_vlp_1 = (fcb_vlp_temp & fcb_vlp_dly1 & fcb_vlp_dly2 & fcb_vlp_dly3);

  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      fcb_vlp_dly1 <= #PAR_DLY 1'b0;
      fcb_vlp_dly2 <= #PAR_DLY 1'b0;
      fcb_vlp_dly3 <= #PAR_DLY 1'b0;
    end else begin
      if (frfu_fmic_vlp_pin_en == 1'b1) begin
        fcb_vlp_dly1 <= #PAR_DLY fcb_vlp_temp;
        fcb_vlp_dly2 <= #PAR_DLY fcb_vlp_dly1;
        fcb_vlp_dly3 <= #PAR_DLY fcb_vlp_dly2;
      end else begin
        fcb_vlp_dly1 <= #PAR_DLY 1'b0;
        fcb_vlp_dly2 <= #PAR_DLY 1'b0;
        fcb_vlp_dly3 <= #PAR_DLY 1'b0;
      end
    end
  end


  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      mic_vlp_stm_cs <= #PAR_DLY MIC_VLP_S0;
    end else begin
      if (frfu_fmic_vlp_pin_en == 1'b1 && frfu_fmic_fb_cfg_done == 1'b1) begin
        mic_vlp_stm_cs <= #PAR_DLY mic_vlp_stm_ns;
      end else begin
        mic_vlp_stm_cs <= #PAR_DLY MIC_VLP_S0;
      end
    end
  end

  always_comb begin

    fmic_frfu_set_pmu_chip_wu_en = 1'b0;
    fmic_frfu_set_pmu_chip_vlp_en = 1'b0;
    mic_vlp_stm_ns = mic_vlp_stm_cs;

    unique case (mic_vlp_stm_cs)
      //----------------------------------------------------------------//
      //-- MAIN State                                                 --//
      //----------------------------------------------------------------//
      MIC_VLP_S0: begin
        mic_vlp_stm_ns = MIC_VLP_S1;
      end
      MIC_VLP_S1: begin
        //--------------------------------------------------------//
        //-- Assumption is Chip is not in VLP mode when Turn on	--//
        //-- the PIN level VLP control				--//
        //--------------------------------------------------------//
        if (fcb_vlp_0 == 1'b1) begin
          mic_vlp_stm_ns = MIC_VLP_S6;
        end else if (fcb_vlp_1 == 1'b1) begin
          mic_vlp_stm_ns = MIC_VLP_SA;
        end else begin
          mic_vlp_stm_ns = mic_vlp_stm_cs;
        end
      end
      MIC_VLP_SA: begin
        fmic_frfu_set_pmu_chip_vlp_en = 1'b1;
        mic_vlp_stm_ns = MIC_VLP_SB;
      end
      MIC_VLP_SB: begin
        mic_vlp_stm_ns = MIC_VLP_SC;
      end
      MIC_VLP_SC: begin
        mic_vlp_stm_ns = MIC_VLP_SD;
      end
      MIC_VLP_SD: begin
        //----------------------------------------------------------------//
        //-- QUAD							--//
        //----------------------------------------------------------------//
        if (frfu_fpmu_pmu_chip_vlp_en == 1'b0 && fcb_clp_mode_en_bo == 1'b0) begin
          mic_vlp_stm_ns = MIC_VLP_SE;
        end
		//----------------------------------------------------------------//
		//-- CLP							--//
        //----------------------------------------------------------------//
        else
        if (frfu_fclp_clp_vlp_en == 1'b0 && fcb_clp_mode_en_bo == 1'b1) begin
          mic_vlp_stm_ns = MIC_VLP_SE;
        end else begin
          mic_vlp_stm_ns = mic_vlp_stm_cs;
        end
      end
      MIC_VLP_SE: begin
        if (fcb_vlp_0 == 1'b1) begin
          mic_vlp_stm_ns = MIC_VLP_S2;
        end else begin
          mic_vlp_stm_ns = mic_vlp_stm_cs;
        end
      end
      MIC_VLP_S2: begin
        mic_vlp_stm_ns = MIC_VLP_S3;
        fmic_frfu_set_pmu_chip_wu_en = 1'b1;
      end
      MIC_VLP_S3: begin
        mic_vlp_stm_ns = MIC_VLP_S4;
      end
      MIC_VLP_S4: begin
        mic_vlp_stm_ns = MIC_VLP_S5;
      end
      MIC_VLP_S5: begin
        //----------------------------------------------------------------//
        //-- QUAD							--//
        //----------------------------------------------------------------//
        if (frfu_fpmu_pmu_chip_vlp_wu_en == 1'b0 && fcb_clp_mode_en_bo == 1'b0) begin
          mic_vlp_stm_ns = MIC_VLP_S6;
        end
		//----------------------------------------------------------------//
		//-- VLP							--//
        //----------------------------------------------------------------//
        else
        if (frfu_fclp_clp_vlp_wu_en == 1'b0 && fcb_clp_mode_en_bo == 1'b1) begin
          mic_vlp_stm_ns = MIC_VLP_S6;
        end else begin
          mic_vlp_stm_ns = mic_vlp_stm_cs;
        end
      end
      MIC_VLP_S6: begin
        if (fcb_vlp_1 == 1'b1) begin
          mic_vlp_stm_ns = MIC_VLP_SA;
        end else begin
          mic_vlp_stm_ns = mic_vlp_stm_cs;
        end
      end
      //----------------------------------------------------------------//
      //-- Default State                                              --//
      //----------------------------------------------------------------//
      default: begin
        mic_vlp_stm_ns = MIC_VLP_S0;
      end
    endcase
  end


  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  always_comb begin
    if (fcb_spi_mode_en_bo == 1'b1 && fcb_sys_stm == 1'b0 && fcb_pif_en == 1'b0) begin
      if (frfu_fmic_done_op_mask_n == 1'b0) begin
        fcb_cfg_done = 1'b0;
        fcb_cfg_done_en = 1'b1;
      end else begin
        if (fmic_spi_master_en == 1'b1) begin
          fcb_cfg_done = frfu_fmic_fb_cfg_done & fsmc_fmic_seq_done;
          fcb_cfg_done_en = 1'b1;
        end else begin
          fcb_cfg_done = ~(ffsr_fmic_fsr_busy | fpmu_fmic_pmu_busy | fclp_clp_busy);
          fcb_cfg_done_en = 1'b1;
        end
      end
    end else begin
      fcb_cfg_done = 1'b0;
      fcb_cfg_done_en = 1'b0;
    end
  end
  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  assign fmic_frfu_set_rc_clk_en = fmic_frfu_set_rc_clk_en_cs;

  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      fmic_frfu_set_rc_clk_en_cs <= #PAR_DLY 1'b0;
    end else begin
      if (fmic_spi_master_en == 1'b0) begin
        fmic_frfu_set_rc_clk_en_cs <= #PAR_DLY((~fcb_spis_cs_n) & (~frfu_fmic_rc_clk_en));
      end
    end
  end
  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  always_comb begin
    if (fmic_spi_master_en == 1'b1) begin
      fcb_sysclk_en =  	frfu_fmic_rc_clk_en |
			frfu_fmic_rc_clk_en_dly1 |
			frfu_fmic_rc_clk_en_dly2 |
			frfu_fmic_rc_clk_en_dly3 |
			frfu_fmic_rc_clk_en_dly4 |
			frfu_fmic_rc_clk_en_dly5 |
			frfu_fmic_rc_clk_en_dly6 |
			frfu_fmic_rc_clk_en_dly7 |
			frfu_fmic_rc_clk_en_dly8 ;
    end else begin
      fcb_sysclk_en =  	frfu_fmic_rc_clk_en |
			frfu_fmic_rc_clk_en_dly1 |
			frfu_fmic_rc_clk_en_dly2 |
			frfu_fmic_rc_clk_en_dly3 |
			frfu_fmic_rc_clk_en_dly4 |
			frfu_fmic_rc_clk_en_dly5 |
			frfu_fmic_rc_clk_en_dly6 |
			frfu_fmic_rc_clk_en_dly7 |
			frfu_fmic_rc_clk_en_dly8 |
			( ~fcb_spis_cs_n	);
    end
  end

  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      frfu_fmic_rc_clk_en_dly1 <= #PAR_DLY 1'b1;
      frfu_fmic_rc_clk_en_dly2 <= #PAR_DLY 1'b1;
      frfu_fmic_rc_clk_en_dly3 <= #PAR_DLY 1'b1;
      frfu_fmic_rc_clk_en_dly4 <= #PAR_DLY 1'b1;
      frfu_fmic_rc_clk_en_dly5 <= #PAR_DLY 1'b1;
      frfu_fmic_rc_clk_en_dly6 <= #PAR_DLY 1'b1;
      frfu_fmic_rc_clk_en_dly7 <= #PAR_DLY 1'b1;
      frfu_fmic_rc_clk_en_dly8 <= #PAR_DLY 1'b1;
    end else begin
      frfu_fmic_rc_clk_en_dly1 <= #PAR_DLY frfu_fmic_rc_clk_en;
      frfu_fmic_rc_clk_en_dly2 <= #PAR_DLY frfu_fmic_rc_clk_en_dly1;
      frfu_fmic_rc_clk_en_dly3 <= #PAR_DLY frfu_fmic_rc_clk_en_dly2;
      frfu_fmic_rc_clk_en_dly4 <= #PAR_DLY frfu_fmic_rc_clk_en_dly3;
      frfu_fmic_rc_clk_en_dly5 <= #PAR_DLY frfu_fmic_rc_clk_en_dly4;
      frfu_fmic_rc_clk_en_dly6 <= #PAR_DLY frfu_fmic_rc_clk_en_dly5;
      frfu_fmic_rc_clk_en_dly7 <= #PAR_DLY frfu_fmic_rc_clk_en_dly6;
      frfu_fmic_rc_clk_en_dly8 <= #PAR_DLY frfu_fmic_rc_clk_en_dly7;
    end
  end
  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  assign fcb_io_sv_180 = frfu_fmic_io_sv_180;

  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  assign fmic_spi_master_en = ( fcb_spi_master_en_syncff1 == 1'b1 )
			  ? ~fsmc_fmic_clr_spi_master_en_latch : 1'b0 ;

  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      fcb_spi_master_en_syncff1 <= #PAR_DLY 1'b0;
    end else begin
      fcb_spi_master_en_syncff1 <= #PAR_DLY fcb_spi_master_en;
    end
  end

  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      fsmc_fmic_clr_spi_master_en_latch <= #PAR_DLY 1'b0;
    end else begin
      if (fsmc_fmic_clr_spi_master_en == 1'b1) begin
        fsmc_fmic_clr_spi_master_en_latch <= #PAR_DLY 1'b1;
      end
    end
  end

  //--------------------------------------------------------------------------------//
  //-- END                                                                        --//
  //--------------------------------------------------------------------------------//
endmodule


