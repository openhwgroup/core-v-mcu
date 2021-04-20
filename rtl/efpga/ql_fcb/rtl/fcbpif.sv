// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

module fcbpif (
    //------------------------------------------------------------------------//
    //-- INPUT PORT                                                         --//
    //------------------------------------------------------------------------//
    input  logic        fcb_sys_clk,  //Main Clock for FCB except SPI Slave Int
    input  logic        fcb_sys_rst_n,  //Main Reset for FCB except SPI Slave int
    input  logic        fcb_sys_stm,  //1'b1 : Put the module into Test Mode
    input  logic        fcb_pif_vldi,  //PIF Input Data Valid
    input  logic [ 3:0] fcb_pif_di_l,  //PIF Input Data, Lower 4 Bits
    input  logic [ 3:0] fcb_pif_di_h,  //PIF Input Data, Higher 4 Bits
    input  logic        fcb_pif_en,  //1'b1 : Enable the PIF mode. Note this b
    input  logic        fcb_pif_8b_mode_bo,  //1'b1 : PIF DI/DO are 8 bits and in Simp
    input  logic        frwf_wff_full,  //Full Flag of Write FIFO
    input  logic        frwf_wff_full_m1,  //Full minus 1 Flag of Write FIFO
    input  logic        frwf_crf_empty,  //Empty Flag of Cfg Read FIFO
    input  logic        frwf_crf_empty_p1,  //Empty Flag plus 1 of Cfg Read FIFO
    input  logic [31:0] frwf_crf_rd_data,  //Cfg Read FIFO Data
    //------------------------------------------------------------------------//
    //-- OUTPUT PORT                                                        --//
    //------------------------------------------------------------------------//
    output logic        fcb_pif_vldo,  //PIF Output Data Valid
    output logic        fcb_pif_vldo_en,  //PIF Output Data Valid Output Enable
    output logic [ 3:0] fcb_pif_do_l,  //PIF Output Data, Lower 4 Bits
    output logic        fcb_pif_do_l_en,  //PIF Output Data Output Enable for Lower
    output logic [ 3:0] fcb_pif_do_h,  //PIF Output Data, Higher 4 Bits
    output logic        fcb_pif_do_h_en,  //PIF Output Data Output Enable for Highe
    output logic        fpif_frwf_pif_on,  //PIF Mode Enable
    output logic [39:0] fpif_frwf_wff_wr_data,  //Bit 31:0 : Write Data, Bit 38:32 : SFR
    output logic        fpif_frwf_wff_wr_en,  //Write enable of Write FIFO
    output logic        fpif_frwf_crf_rd_en  //Read Enable of Cfg Read FIFO
);

  //------------------------------------------------------------------------//
  //-- Local Parameter                                                    --//
  //------------------------------------------------------------------------//
  localparam PAR_DLY = 1'b1;

  //------------------------------------------------------------------------//
  //-- EMUN/Flops                                                         --//
  //------------------------------------------------------------------------//
  typedef enum logic [4:0] {
    PWM_S00 = 5'h00,
    PWM_S01 = 5'h01,
    PWM_S02 = 5'h02,
    PWM_S03 = 5'h03,
    PWM_S04 = 5'h04,
    PWM_S05 = 5'h05,
    PWM_S06 = 5'h06,
    PWM_S07 = 5'h07,
    PW8_S00 = 5'h08,
    PW8_S01 = 5'h09,
    PW8_S02 = 5'h0A,
    PW8_S03 = 5'h0B,
    PW8_S04 = 5'h0C,
    PW8_S05 = 5'h0D,
    PW8_S06 = 5'h0E,
    PW8_S07 = 5'h0F,
    PW4_S00 = 5'h10,
    PW4_S01 = 5'h11,
    PW4_S02 = 5'h12,
    PW4_S03 = 5'h13,
    PW4_S04 = 5'h14,
    PW4_S05 = 5'h15,
    PW4_S06 = 5'h16,
    PW4_S07 = 5'h17,
    PW4_S08 = 5'h18,
    PW4_S09 = 5'h19,
    PW4_S0A = 5'h1A,
    PW4_S0B = 5'h1B,
    PW4_S0C = 5'h1C,
    PW4_S0D = 5'h1D,
    PW4_S0E = 5'h1E,
    PW4_S0F = 5'h1F
  } EN_WR_STATE;

  typedef enum logic [4:0] {
    PRM_S00 = 5'h00,
    PRM_S01 = 5'h01,
    PRM_S02 = 5'h02,
    PRM_S03 = 5'h03,
    PRM_S04 = 5'h04,
    PRM_S05 = 5'h05,
    PRM_S06 = 5'h06,
    PRM_S07 = 5'h07,
    PR8_S00 = 5'h08,
    PR8_S01 = 5'h09,
    PR8_S02 = 5'h0A,
    PR8_S03 = 5'h0B,
    PR8_S04 = 5'h0C,
    PR8_S05 = 5'h0D,
    PR8_S06 = 5'h0E,
    PR8_S07 = 5'h0F,
    PR4_S00 = 5'h10,
    PR4_S01 = 5'h11,
    PR4_S02 = 5'h12,
    PR4_S03 = 5'h13,
    PR4_S04 = 5'h14,
    PR4_S05 = 5'h15,
    PR4_S06 = 5'h16,
    PR4_S07 = 5'h17,
    PR4_S08 = 5'h18,
    PR4_S09 = 5'h19,
    PR4_S0A = 5'h1A,
    PR4_S0B = 5'h1B,
    PR4_S0C = 5'h1C,
    PR4_S0D = 5'h1D,
    PR4_S0E = 5'h1E,
    PR4_S0F = 5'h1F
  } EN_RD_STATE;

  //------------------------------------------------------------------------//
  //-- Wire/Flops                                                         --//
  //------------------------------------------------------------------------//
  EN_WR_STATE       pif_wr_stm_cs;
  EN_WR_STATE       pif_wr_stm_ns;
  EN_RD_STATE       pif_rd_stm_cs;
  EN_RD_STATE       pif_rd_stm_ns;

  logic             fcb_pif_vldo_cs;
  logic             fcb_pif_vldo_en_cs;
  logic       [3:0] fcb_pif_do_l_cs;
  logic             fcb_pif_do_l_en_cs;
  logic       [3:0] fcb_pif_do_h_cs;
  logic             fcb_pif_do_h_en_cs;
  logic             fpif_frwf_pif_on_cs;

  logic             fcb_pif_vldo_ns;
  logic             fcb_pif_vldo_en_ns;
  logic       [3:0] fcb_pif_do_l_ns;
  logic             fcb_pif_do_l_en_ns;
  logic       [3:0] fcb_pif_do_h_ns;
  logic             fcb_pif_do_h_en_ns;
  logic             fpif_frwf_pif_on_ns;

  logic       [3:0] pif_addr_h_cs;
  logic       [3:0] pif_addr_h_ns;

  logic             pif_addr_h_wr_en;

  logic       [3:0] pif_addr_l_cs;
  logic       [3:0] pif_addr_l_ns;

  logic             pif_addr_l_wr_en;


  logic       [3:0] pif_data_b0_h_cs;
  logic       [3:0] pif_data_b0_l_cs;
  logic       [3:0] pif_data_b1_h_cs;
  logic       [3:0] pif_data_b1_l_cs;
  logic       [3:0] pif_data_b2_h_cs;
  logic       [3:0] pif_data_b2_l_cs;
  logic       [3:0] pif_data_b3_h_cs;

  logic       [3:0] pif_data_b0_h_ns;
  logic       [3:0] pif_data_b0_l_ns;
  logic       [3:0] pif_data_b1_h_ns;
  logic       [3:0] pif_data_b1_l_ns;
  logic       [3:0] pif_data_b2_h_ns;
  logic       [3:0] pif_data_b2_l_ns;
  logic       [3:0] pif_data_b3_h_ns;

  logic             pif_data_b0_h_wr_en;
  logic             pif_data_b0_l_wr_en;
  logic             pif_data_b1_h_wr_en;
  logic             pif_data_b1_l_wr_en;
  logic             pif_data_b2_h_wr_en;
  logic             pif_data_b2_l_wr_en;
  logic             pif_data_b3_h_wr_en;

  logic             pif_addr_inc;


  logic       [2:0] pif_do_mux;

  //--------------------------------------------------------------------------------//
  //-- Start Functional Description                                               --//
  //--------------------------------------------------------------------------------//
  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  assign fcb_pif_vldo_en  = (fcb_sys_stm == 1'b1 && fcb_pif_en == 1'b1) ? 1'b1 : 1'b0;

  assign fpif_frwf_pif_on = (fcb_sys_stm == 1'b1 && fcb_pif_en == 1'b1) ? 1'b1 : 1'b0;

  always_comb begin
    if (fcb_sys_stm == 1'b1 && fcb_pif_en == 1'b1) begin
      if (fcb_pif_8b_mode_bo == 1'b1) begin
        fcb_pif_do_l_en = fcb_pif_vldo;
      end else begin
        fcb_pif_do_l_en = 1'b0;
      end
    end else begin
      fcb_pif_do_l_en = 1'b1;
    end
  end

  always_comb begin
    if (fcb_sys_stm == 1'b1 && fcb_pif_en == 1'b1) begin
      if (fcb_pif_8b_mode_bo == 1'b1) begin
        fcb_pif_do_h_en = fcb_pif_vldo;
      end else begin
        fcb_pif_do_h_en = 1'b0;
      end
    end else begin
      fcb_pif_do_h_en = 1'b0;
    end
  end

  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  always_comb begin
    if (fcb_pif_8b_mode_bo == 1'b1) begin
      fpif_frwf_wff_wr_data = {
        pif_addr_h_cs,
        pif_addr_l_cs,
        fcb_pif_di_h,
        fcb_pif_di_l,
        pif_data_b2_h_cs,
        pif_data_b2_l_cs,
        pif_data_b1_h_cs,
        pif_data_b1_l_cs,
        pif_data_b0_h_cs,
        pif_data_b0_l_cs
      };
    end else begin
      fpif_frwf_wff_wr_data = {
        pif_addr_h_cs,
        pif_addr_l_cs,
        pif_data_b3_h_cs,
        fcb_pif_di_l,
        pif_data_b2_h_cs,
        pif_data_b2_l_cs,
        pif_data_b1_h_cs,
        pif_data_b1_l_cs,
        pif_data_b0_h_cs,
        pif_data_b0_l_cs
      };
    end
  end

  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      pif_addr_h_cs <= #PAR_DLY 'b0;
      pif_addr_l_cs <= #PAR_DLY 'b0;
      pif_data_b0_h_cs <= #PAR_DLY 'b0;
      pif_data_b0_l_cs <= #PAR_DLY 'b0;
      pif_data_b1_h_cs <= #PAR_DLY 'b0;
      pif_data_b1_l_cs <= #PAR_DLY 'b0;
      pif_data_b2_h_cs <= #PAR_DLY 'b0;
      pif_data_b2_l_cs <= #PAR_DLY 'b0;
      pif_data_b3_h_cs <= #PAR_DLY 'b0;
    end else begin
      if ( fcb_sys_stm == 1'b1 && fcb_pif_en == 1'b1 )	// JC
	begin
        pif_addr_h_cs    <= #PAR_DLY pif_addr_h_ns;
        pif_addr_l_cs    <= #PAR_DLY pif_addr_l_ns;
        pif_data_b0_h_cs <= #PAR_DLY pif_data_b0_h_ns;
        pif_data_b0_l_cs <= #PAR_DLY pif_data_b0_l_ns;
        pif_data_b1_h_cs <= #PAR_DLY pif_data_b1_h_ns;
        pif_data_b1_l_cs <= #PAR_DLY pif_data_b1_l_ns;
        pif_data_b2_h_cs <= #PAR_DLY pif_data_b2_h_ns;
        pif_data_b2_l_cs <= #PAR_DLY pif_data_b2_l_ns;
        pif_data_b3_h_cs <= #PAR_DLY pif_data_b3_h_ns;
      end
    end
  end

  always_comb begin
    pif_addr_h_ns    = pif_addr_h_cs;
    pif_addr_l_ns    = pif_addr_l_cs;
    pif_data_b0_h_ns = pif_data_b0_h_cs;
    pif_data_b0_l_ns = pif_data_b0_l_cs;
    pif_data_b1_h_ns = pif_data_b1_h_cs;
    pif_data_b1_l_ns = pif_data_b1_l_cs;
    pif_data_b2_h_ns = pif_data_b2_h_cs;
    pif_data_b2_l_ns = pif_data_b2_l_cs;
    pif_data_b3_h_ns = pif_data_b3_h_cs;
    //----------------------------------------//
    //-- Addr				--//
    //----------------------------------------//
    if (pif_addr_inc == 1'b1) begin
      {pif_addr_h_ns, pif_addr_l_ns} = {pif_addr_h_cs, pif_addr_l_cs} + 1'b1;
    end else begin
      if (pif_addr_h_wr_en == 1'b1) begin
        if ( fcb_pif_8b_mode_bo == 1'b1 ) // 8 Bits
	    begin
          pif_addr_h_ns = fcb_pif_di_h[3:0];
        end else begin
          pif_addr_h_ns = fcb_pif_di_l[3:0];
        end
      end
      if (pif_addr_l_wr_en == 1'b1) begin
        pif_addr_l_ns = fcb_pif_di_l;
      end
    end
    //----------------------------------------//
    //-- Byte 0				--//
    //----------------------------------------//
    if (pif_data_b0_h_wr_en == 1'b1) begin
      if ( fcb_pif_8b_mode_bo == 1'b1 ) // 8 Bits
        begin
        pif_data_b0_h_ns = fcb_pif_di_h[3:0];
      end else begin
        pif_data_b0_h_ns = fcb_pif_di_l[3:0];
      end
    end

    if (pif_data_b0_l_wr_en == 1'b1) begin
      pif_data_b0_l_ns = fcb_pif_di_l;
    end
    //----------------------------------------//
    //-- Byte 1				--//
    //----------------------------------------//
    if (pif_data_b1_h_wr_en == 1'b1) begin
      if ( fcb_pif_8b_mode_bo == 1'b1 ) // 8 Bits
        begin
        pif_data_b1_h_ns = fcb_pif_di_h[3:0];
      end else begin
        pif_data_b1_h_ns = fcb_pif_di_l[3:0];
      end
    end

    if (pif_data_b1_l_wr_en == 1'b1) begin
      pif_data_b1_l_ns = fcb_pif_di_l;
    end
    //----------------------------------------//
    //-- Byte 2				--//
    //----------------------------------------//
    if (pif_data_b2_h_wr_en == 1'b1) begin
      if ( fcb_pif_8b_mode_bo == 1'b1 ) // 8 Bits
        begin
        pif_data_b2_h_ns = fcb_pif_di_h[3:0];
      end else begin
        pif_data_b2_h_ns = fcb_pif_di_l[3:0];
      end
    end

    if (pif_data_b2_l_wr_en == 1'b1) begin
      pif_data_b2_l_ns = fcb_pif_di_l;
    end
    //----------------------------------------//
    //-- Byte 3				--//
    //----------------------------------------//
    if (pif_data_b3_h_wr_en == 1'b1) begin
      if ( fcb_pif_8b_mode_bo == 1'b1 ) // 8 Bits
        begin
        pif_data_b3_h_ns = fcb_pif_di_h[3:0];
      end else begin
        pif_data_b3_h_ns = fcb_pif_di_l[3:0];
      end
    end
  end

  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      pif_wr_stm_cs <= #PAR_DLY PWM_S00;
    end
  else if ( fcb_sys_stm == 1'b1 && fcb_pif_en == 1'b1 )	// JC
    begin
      pif_wr_stm_cs <= #PAR_DLY pif_wr_stm_ns;
    end else begin
      pif_wr_stm_cs <= #PAR_DLY PWM_S00;
    end
  end
  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  always_comb begin
    pif_wr_stm_ns = pif_wr_stm_cs;
    fpif_frwf_wff_wr_en = 1'b0;
    pif_addr_inc = 1'b0;
    pif_addr_h_wr_en = 1'b0;
    pif_addr_l_wr_en = 1'b0;
    pif_data_b0_h_wr_en = 1'b0;
    pif_data_b0_l_wr_en = 1'b0;
    pif_data_b1_h_wr_en = 1'b0;
    pif_data_b1_l_wr_en = 1'b0;
    pif_data_b2_h_wr_en = 1'b0;
    pif_data_b2_l_wr_en = 1'b0;
    pif_data_b3_h_wr_en = 1'b0;

    unique case (pif_wr_stm_cs)
      PWM_S00: begin
        if (fcb_sys_stm == 1'b1 && fcb_pif_en == 1'b1) begin
          if (fcb_pif_8b_mode_bo == 1'b0) begin
            pif_wr_stm_ns = PW4_S00;
          end else begin
            pif_wr_stm_ns = PW8_S00;
          end
        end else begin
          pif_wr_stm_ns = pif_wr_stm_cs;
        end
      end

      PW4_S00: begin
        if (fcb_pif_vldi == 1'b1) begin
          pif_wr_stm_ns = PW4_S01;
          pif_addr_h_wr_en = 1'b1;
        end
      end
      PW4_S01: begin
        if (fcb_pif_vldi == 1'b1) begin
          if (pif_addr_h_cs[3] == 1'b1) begin
            pif_wr_stm_ns = PW4_S03;
            pif_addr_l_wr_en = 1'b1;
          end else begin
            pif_wr_stm_ns = PW4_S02;
            pif_addr_l_wr_en = 1'b1;
          end
        end
      end

      PW4_S02: begin
        fpif_frwf_wff_wr_en = 1'b1;
        pif_wr_stm_ns = PW4_S00;
      end

      PW4_S03 :	// Byte 0-H
      begin
        if (fcb_pif_vldi == 1'b1) begin
          pif_wr_stm_ns       = PW4_S04;
          pif_data_b0_h_wr_en = 1'b1;
        end
      end
      PW4_S04 :	// Byte 0-L
      begin
        if (fcb_pif_vldi == 1'b1) begin
          pif_wr_stm_ns       = PW4_S05;
          pif_data_b0_l_wr_en = 1'b1;
        end
      end
      PW4_S05 :	// Byte 1-H
      begin
        if (fcb_pif_vldi == 1'b1) begin
          pif_wr_stm_ns       = PW4_S06;
          pif_data_b1_h_wr_en = 1'b1;
        end
      end
      PW4_S06 :	// Byte 1-L
      begin
        if (fcb_pif_vldi == 1'b1) begin
          pif_wr_stm_ns       = PW4_S07;
          pif_data_b1_l_wr_en = 1'b1;
        end
      end
      PW4_S07 :	// Byte 2-H
      begin
        if (fcb_pif_vldi == 1'b1) begin
          pif_wr_stm_ns       = PW4_S08;
          pif_data_b2_h_wr_en = 1'b1;
        end
      end
      PW4_S08 :	// Byte 2-L
      begin
        if (fcb_pif_vldi == 1'b1) begin
          pif_wr_stm_ns       = PW4_S09;
          pif_data_b2_l_wr_en = 1'b1;
        end
      end
      PW4_S09 :	// Byte 3-H
      begin
        if (fcb_pif_vldi == 1'b1) begin
          pif_wr_stm_ns       = PW4_S0A;
          pif_data_b3_h_wr_en = 1'b1;
        end
      end
      PW4_S0A :	// Byte 3-L
      begin
        if (fcb_pif_vldi == 1'b1) begin
          pif_wr_stm_ns       = PW4_S0B;
          fpif_frwf_wff_wr_en = 1'b1;
        end
      end
      PW4_S0B: begin
        if (fcb_pif_vldi == 1'b1) begin
          if ({
                pif_addr_h_cs, pif_addr_l_cs
              } == 8'hA0)  // Address Not Change, Hit 0x20
                  begin
            pif_addr_inc = 1'b0;
          end else begin
            pif_addr_inc = 1'b1;
          end
          pif_data_b0_h_wr_en = 1'b1;
          pif_wr_stm_ns       = PW4_S04;
        end else begin
          pif_wr_stm_ns = PW4_S00;
        end
      end

      PW8_S00: begin
        if (fcb_pif_vldi == 1'b1) begin
          pif_addr_h_wr_en = 1'b1;
          pif_addr_l_wr_en = 1'b1;
          if (fcb_pif_di_h[3] == 1'b0) begin
            pif_wr_stm_ns = PW8_S01;
          end else begin
            pif_wr_stm_ns = PW8_S02;
          end
        end
      end
      PW8_S01: begin
        fpif_frwf_wff_wr_en = 1'b1;
        pif_wr_stm_ns       = PW8_S00;
      end

      PW8_S02: begin
        if (fcb_pif_vldi == 1'b1) begin
          pif_data_b0_h_wr_en = 1'b1;
          pif_data_b0_l_wr_en = 1'b1;
          pif_wr_stm_ns       = PW8_S03;
        end
      end

      PW8_S03: begin
        if (fcb_pif_vldi == 1'b1) begin
          pif_data_b1_h_wr_en = 1'b1;
          pif_data_b1_l_wr_en = 1'b1;
          pif_wr_stm_ns       = PW8_S04;
        end
      end

      PW8_S04: begin
        if (fcb_pif_vldi == 1'b1) begin
          pif_data_b2_h_wr_en = 1'b1;
          pif_data_b2_l_wr_en = 1'b1;
          pif_wr_stm_ns       = PW8_S05;
        end
      end

      PW8_S05: begin
        if (fcb_pif_vldi == 1'b1) begin
          pif_wr_stm_ns       = PW8_S06;
          fpif_frwf_wff_wr_en = 1'b1;
        end
      end

      PW8_S06: begin
        if (fcb_pif_vldi == 1'b1) begin
          if ({
                pif_addr_h_cs, pif_addr_l_cs
              } == 8'hA0)  // Address Not Change, Hit 0x20
                  begin
            pif_addr_inc = 1'b0;
          end else begin
            pif_addr_inc = 1'b1;
          end
          pif_data_b0_h_wr_en = 1'b1;
          pif_data_b0_l_wr_en = 1'b1;
          pif_wr_stm_ns       = PW8_S03;
        end else begin
          pif_wr_stm_ns = PW8_S00;
        end
      end
      default: begin
        pif_wr_stm_ns = PWM_S00;
      end
    endcase
  end
  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  always_comb begin
    if (fcb_pif_8b_mode_bo == 1'b1) begin
      case (pif_do_mux[2:1])
        2'b00: begin
          {fcb_pif_do_h, fcb_pif_do_l} = frwf_crf_rd_data[7:0];
        end
        2'b01: begin
          {fcb_pif_do_h, fcb_pif_do_l} = frwf_crf_rd_data[15:8];
        end
        2'b10: begin
          {fcb_pif_do_h, fcb_pif_do_l} = frwf_crf_rd_data[23:16];
        end
        2'b11: begin
          {fcb_pif_do_h, fcb_pif_do_l} = frwf_crf_rd_data[31:24];
        end
      endcase
    end else begin
      fcb_pif_do_h = 4'h0;
      case (pif_do_mux[2:0])
        3'b000: begin
          fcb_pif_do_l = frwf_crf_rd_data[3:0];
        end
        3'b001: begin
          fcb_pif_do_l = frwf_crf_rd_data[7:4];
        end
        3'b010: begin
          fcb_pif_do_l = frwf_crf_rd_data[11:8];
        end
        3'b011: begin
          fcb_pif_do_l = frwf_crf_rd_data[15:12];
        end
        3'b100: begin
          fcb_pif_do_l = frwf_crf_rd_data[19:16];
        end
        3'b101: begin
          fcb_pif_do_l = frwf_crf_rd_data[23:20];
        end
        3'b110: begin
          fcb_pif_do_l = frwf_crf_rd_data[27:24];
        end
        3'b111: begin
          fcb_pif_do_l = frwf_crf_rd_data[31:28];
        end
      endcase
    end
  end
  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      pif_rd_stm_cs <= #PAR_DLY PRM_S00;
    end
  else if ( fcb_sys_stm == 1'b1 && fcb_pif_en == 1'b1 )	// JC
    begin
      pif_rd_stm_cs <= #PAR_DLY pif_rd_stm_ns;
    end else begin
      pif_rd_stm_cs <= #PAR_DLY PRM_S00;
    end
  end
  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  always_comb begin
    pif_rd_stm_ns       = pif_rd_stm_cs;
    fpif_frwf_crf_rd_en = 1'b0;
    pif_do_mux          = 3'b000;
    fcb_pif_vldo        = 1'b0;

    unique case (pif_rd_stm_cs)
      PRM_S00: begin
        if (fcb_sys_stm == 1'b1 && fcb_pif_en == 1'b1) begin
          if (fcb_pif_8b_mode_bo == 1'b0) begin
            pif_rd_stm_ns = PR4_S00;
          end else begin
            pif_rd_stm_ns = PR8_S00;
          end
        end else begin
          pif_rd_stm_ns = pif_rd_stm_cs;
        end
      end

      PR4_S00: begin
        if (frwf_crf_empty == 1'b0) begin
          pif_rd_stm_ns = PR4_S01;
          pif_do_mux = 3'b001;
          fcb_pif_vldo = 1'b1;
        end
      end
      PR4_S01: begin
        pif_rd_stm_ns = PR4_S02;
        pif_do_mux = 3'b000;
        fcb_pif_vldo = 1'b1;
      end
      PR4_S02: begin
        pif_rd_stm_ns = PR4_S03;
        pif_do_mux = 3'b011;
        fcb_pif_vldo = 1'b1;
      end
      PR4_S03: begin
        pif_rd_stm_ns = PR4_S04;
        pif_do_mux = 3'b010;
        fcb_pif_vldo = 1'b1;
      end
      PR4_S04: begin
        pif_rd_stm_ns = PR4_S05;
        pif_do_mux = 3'b101;
        fcb_pif_vldo = 1'b1;
      end
      PR4_S05: begin
        pif_rd_stm_ns = PR4_S06;
        pif_do_mux = 3'b100;
        fcb_pif_vldo = 1'b1;
      end
      PR4_S06: begin
        pif_rd_stm_ns = PR4_S07;
        pif_do_mux = 3'b111;
        fcb_pif_vldo = 1'b1;
      end
      PR4_S07: begin
        fpif_frwf_crf_rd_en = 1'b1;
        pif_rd_stm_ns = PR4_S00;
        pif_do_mux = 3'b110;
        fcb_pif_vldo = 1'b1;
      end

      PR8_S00: begin
        if (frwf_crf_empty == 1'b0) begin
          pif_rd_stm_ns = PR8_S01;
          pif_do_mux    = 3'b000;
          fcb_pif_vldo  = 1'b1;
        end
      end
      PR8_S01: begin
        pif_rd_stm_ns = PR8_S02;
        pif_do_mux    = 3'b010;
        fcb_pif_vldo  = 1'b1;
      end
      PR8_S02: begin
        pif_rd_stm_ns = PR8_S03;
        pif_do_mux    = 3'b100;
        fcb_pif_vldo  = 1'b1;
      end
      PR8_S03: begin
        pif_rd_stm_ns       = PR8_S00;
        pif_do_mux          = 3'b110;
        fcb_pif_vldo        = 1'b1;
        fpif_frwf_crf_rd_en = 1'b1;
      end
      default: begin
        pif_rd_stm_ns = PRM_S00;
      end
    endcase
  end

  //--------------------------------------------------------------------------------//
  //-- END                                                                        --//
  //--------------------------------------------------------------------------------//
endmodule


