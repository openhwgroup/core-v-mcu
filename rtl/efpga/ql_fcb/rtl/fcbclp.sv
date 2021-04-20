// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

module fcbclp #(
    parameter [10:0] PAR_QLFCB_11BIT_100NS = 11'h00A,  // 1: Default ON, 0: Default Off
    parameter [10:0] PAR_QLFCB_11BIT_200NS = 11'h014,  // Default Assume 100MHz
    parameter [10:0] PAR_QLFCB_11BIT_1US   = 11'h064,  // Default Assume 100MHz
    parameter [10:0] PAR_QLFCB_11BIT_10US  = 11'h3E8  // Default Assume 100MHz
) (
    //------------------------------------------------------------------------//
    //-- INPUT PORT                                                         --//
    //------------------------------------------------------------------------//
    //----------------------------------------------------------------//
    //-- CLK							--//
    //----------------------------------------------------------------//
    input  logic       fcb_sys_clk,  //Main Clock for FCB except SPI Slave Int
    input  logic       fcb_sys_rst_n,  //Main Reset for FCB except SPI Slave int
    //----------------------------------------------------------------//
    //-- Comment							--//
    //----------------------------------------------------------------//
    input  logic       fcb_clp_mode_en_bo,  //Enable Chip Level 
    input  logic       frfu_fclp_cfg_done,  //Configure Done Signal, Used to Clear LT
    input  logic       frfu_fclp_clp_vlp_wu_en,  //VLP WU enable
    input  logic       frfu_fclp_clp_vlp_en,  //VLP Enable
    input  logic       frfu_fclp_clp_pd_wu_en,  //PD WU enable
    input  logic       frfu_fclp_clp_pd_en,  //PD enable
    input  logic [1:0] frfu_fclp_clp_time_ctl,  //Internal Timing Configure
    input  logic       fcb_sys_stm,  //JC
    input  logic       fcb_pif_en,  //JC
    input  logic       fcb_fb_default_on_bo,  //eFPGA Macro Default Power State
    //------------------------------------------------------------------------//
    //-- OUTPUT PORT                                                        --//
    //------------------------------------------------------------------------//
    //----------------------------------------------------------------//
    //-- Comment							--//
    //----------------------------------------------------------------//
    output logic       fcb_clp_set_por,  //POR Signal
    output logic       fcb_clp_lth_enb,  //LTH_ENB Signal
    output logic       fcb_clp_cfg_enb,  //CFG_ENB Signal
    output logic       fcb_clp_pwr_gate,  //Chip Level Power Gate Control
    output logic       fcb_clp_vlp,  //Chip Level VLP Control
    output logic       fcb_clp_cfg_done,  //Chip Level Configure Done
    output logic       fcb_clp_cfg_done_n,  //Inverse signal of FCB_CLP_CFG_DONE
    output logic       fclp_frfu_clear_vlp_en,  //Clear VLP EN Bit
    output logic       fclp_frfu_clear_vlp_wu_en,  //Clear VLP WU EN Bit
    output logic       fclp_frfu_clear_pd_en,  //Clear PD Enable
    output logic       fclp_frfu_clear_pd_wu_en,  //Clear PD WU Enable
    output logic [1:0] fclp_frfu_clp_pw_sta,  //Macro's Power Status
    output logic       fclp_clp_busy,  //CLP Busy
    output logic       fclp_frfu_fb_cfg_cleanup,
    output logic       fclp_frfu_clear_cfg_done  //Clear the CFG Done.
);

  //------------------------------------------------------------------------//
  //-- Local Parameter                                                    --//
  //------------------------------------------------------------------------//
  localparam PAR_DLY = 1'b1;
  localparam PAR_PWR_ACTIVE = 2'b00;
  localparam PAR_PWR_VLP = 2'b01;
  localparam PAR_PWR_PSD = 2'b10;

  //------------------------------------------------------------------------//
  //-- EMUN/Flops                                                         --//
  //------------------------------------------------------------------------//
  typedef enum logic [5:0] {
    VLP_E0  = 6'h10,
    VLP_E1  = 6'h11,
    VLP_E2  = 6'h12,
    VLP_E3  = 6'h13,
    VLP_E4  = 6'h14,
    VLP_E5  = 6'h15,
    VLP_E6  = 6'h16,
    VLP_W0  = 6'h17,
    VLP_W1  = 6'h18,
    VLP_W2  = 6'h19,
    VLP_W3  = 6'h1A,
    VLP_W4  = 6'h1B,
    VLP_W5  = 6'h1C,
    VLP_W6  = 6'h1D,
    PSD_E0  = 6'h20,
    PSD_E1  = 6'h21,
    PSD_E2  = 6'h22,
    PSD_E3  = 6'h23,
    PSD_E4  = 6'h24,
    PSD_E5  = 6'h25,
    PSD_E6  = 6'h26,
    PSD_W0  = 6'h27,
    PSD_W1  = 6'h28,
    PSD_W2  = 6'h29,
    PSD_W3  = 6'h2A,
    PSD_W4  = 6'h2B,
    PSD_W5  = 6'h2C,
    PSD_W6  = 6'h2D,
    PSD_W7  = 6'h2E,
    PSD_W8  = 6'h2F,
    END_S0  = 6'h30,
    END_S1  = 6'h31,
    MAIN_S0 = 6'h00,
    MAIN_S1 = 6'h01,
    MAIN_S2 = 6'h02,
    MAIN_S3 = 6'h03
  } EN_STATE;

  //------------------------------------------------------------------------//
  //-- Wire/Flops                                                         --//
  //------------------------------------------------------------------------//
  EN_STATE        clp_stm_cs;
  EN_STATE        clp_stm_ns;

  logic    [12:0] clp_timer_cs;
  logic    [12:0] clp_timer_ns;
  logic           clp_timer_kickoff;
  logic    [12:0] clp_timer_ini_value;
  logic           clp_timer_timeout;

  logic           clear_lth_enb;
  logic           set_lth_enb;
  logic           fcb_clp_lth_enb_cs;

  logic           clear_cfg_enb;
  logic           set_cfg_enb;
  logic           fcb_clp_cfg_enb_cs;

  logic           clear_pwr_gate;
  logic           set_pwr_gate;
  logic           fcb_clp_pwr_gate_cs;

  logic           clear_vlp;
  logic           set_vlp;
  logic           fcb_clp_vlp_cs;

  logic    [ 1:0] fclp_frfu_clp_pw_sta_cs;
  logic    [ 1:0] fclp_frfu_clp_pw_sta_ns;


  logic           frfu_fclp_cfg_done_dly0;
  logic           frfu_fclp_cfg_done_dly1;
  logic           frfu_fclp_cfg_done_dly2;
  logic           frfu_fclp_cfg_done_dly3;
  logic           frfu_fclp_cfg_done_dly4;
  logic           frfu_fclp_cfg_done_dly5;
  logic           frfu_fclp_cfg_done_dly6;
  logic           frfu_fclp_cfg_done_dly7;
  logic           frfu_fclp_cfg_done_dly8;

  logic           cfg_done_clear_ltch_enb;

  logic           fcb_clp_set_por_cs;
  logic           fcb_clp_set_por_ns;

  logic    [12:0] timer_100ns_value;
  logic    [12:0] timer_200ns_value;
  logic    [12:0] timer_1us_value;
  logic    [12:0] timer_10us_value;

  //--------------------------------------------------------------------------------//
  //-- Start Functional Description                                               --//
  //--------------------------------------------------------------------------------//
  assign fclp_clp_busy = (clp_stm_cs == MAIN_S0) ? 1'b0 : 1'b1;
  assign fcb_clp_cfg_done = frfu_fclp_cfg_done;
  assign fcb_clp_cfg_done_n = ~frfu_fclp_cfg_done;

  //assign fcb_clp_lth_enb 		= fcb_clp_lth_enb_cs ;
  assign fcb_clp_cfg_enb = fcb_clp_cfg_enb_cs;
  assign fcb_clp_pwr_gate = fcb_clp_pwr_gate_cs;
  assign fcb_clp_vlp = fcb_clp_vlp_cs;
  assign fclp_frfu_clp_pw_sta = fclp_frfu_clp_pw_sta_cs;

  //------------------------------------------------------------------------//
  //-- Default								--//
  //------------------------------------------------------------------------//
  assign fclp_frfu_fb_cfg_cleanup = frfu_fclp_cfg_done_dly8;

  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      frfu_fclp_cfg_done_dly0 <= #PAR_DLY 1'b0;
      frfu_fclp_cfg_done_dly1 <= #PAR_DLY 1'b0;
      frfu_fclp_cfg_done_dly2 <= #PAR_DLY 1'b0;
      frfu_fclp_cfg_done_dly3 <= #PAR_DLY 1'b0;
      frfu_fclp_cfg_done_dly4 <= #PAR_DLY 1'b0;
      frfu_fclp_cfg_done_dly5 <= #PAR_DLY 1'b0;
      frfu_fclp_cfg_done_dly6 <= #PAR_DLY 1'b0;
      frfu_fclp_cfg_done_dly7 <= #PAR_DLY 1'b0;
      frfu_fclp_cfg_done_dly8 <= #PAR_DLY 1'b0;
    end else begin
      frfu_fclp_cfg_done_dly0 <= #PAR_DLY frfu_fclp_cfg_done & (~fclp_frfu_clear_cfg_done);
      frfu_fclp_cfg_done_dly1 <= #PAR_DLY frfu_fclp_cfg_done_dly0 & (~fclp_frfu_clear_cfg_done);
      frfu_fclp_cfg_done_dly2 <= #PAR_DLY frfu_fclp_cfg_done_dly1 & (~fclp_frfu_clear_cfg_done);
      frfu_fclp_cfg_done_dly3 <= #PAR_DLY frfu_fclp_cfg_done_dly2 & (~fclp_frfu_clear_cfg_done);
      frfu_fclp_cfg_done_dly4 <= #PAR_DLY frfu_fclp_cfg_done_dly3 & (~fclp_frfu_clear_cfg_done);
      frfu_fclp_cfg_done_dly5 <= #PAR_DLY frfu_fclp_cfg_done_dly4 & (~fclp_frfu_clear_cfg_done);
      frfu_fclp_cfg_done_dly6 <= #PAR_DLY frfu_fclp_cfg_done_dly5 & (~fclp_frfu_clear_cfg_done);
      frfu_fclp_cfg_done_dly7 <= #PAR_DLY frfu_fclp_cfg_done_dly6 & (~fclp_frfu_clear_cfg_done);
      frfu_fclp_cfg_done_dly8 <= #PAR_DLY frfu_fclp_cfg_done_dly7 & (~fclp_frfu_clear_cfg_done);
    end
  end

  always_comb begin
    if ( frfu_fclp_clp_time_ctl == 2'b00 ) // 80
    begin
      cfg_done_clear_ltch_enb = (frfu_fclp_cfg_done_dly7 & (~frfu_fclp_cfg_done_dly8));
    end
  else if ( frfu_fclp_clp_time_ctl == 2'b01 ) // 40
    begin
      cfg_done_clear_ltch_enb = (frfu_fclp_cfg_done_dly5 & (~frfu_fclp_cfg_done_dly6));
    end
  else if ( frfu_fclp_clp_time_ctl == 2'b10 ) // 20
    begin
      cfg_done_clear_ltch_enb = (frfu_fclp_cfg_done_dly3 & (~frfu_fclp_cfg_done_dly4));
    end
  else // 10
    begin
      cfg_done_clear_ltch_enb = (frfu_fclp_cfg_done_dly1 & (~frfu_fclp_cfg_done_dly2));
    end
  end
  //------------------------------------------------------------------------//
  //-- Default								--//
  //------------------------------------------------------------------------//
  assign fcb_clp_set_por = fcb_clp_set_por_cs;
  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      fcb_clp_set_por_cs <= #PAR_DLY 1'b0;
    end else begin
      fcb_clp_set_por_cs <= #PAR_DLY fcb_clp_set_por_ns;
    end
  end


  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      if ( fcb_fb_default_on_bo == 1'b1 ) 				//JC
	begin
        fcb_clp_lth_enb_cs <= #PAR_DLY 1'b1;  // Base on 1/23/2017 Spec
        fcb_clp_cfg_enb_cs <= #PAR_DLY 1'b0;
        fcb_clp_pwr_gate_cs <= #PAR_DLY 1'b0;
        fcb_clp_vlp_cs <= #PAR_DLY 1'b0;
      end else begin
        fcb_clp_lth_enb_cs <= #PAR_DLY 1'b1;  // Base on 1/23/2017 Spec
        fcb_clp_cfg_enb_cs <= #PAR_DLY 1'b1;
        fcb_clp_pwr_gate_cs <= #PAR_DLY 1'b1;
        fcb_clp_vlp_cs <= #PAR_DLY 1'b0;
      end
    end else begin
      //----------------------------------------------------------------//
      //-- LTH_ENB							--//
      //----------------------------------------------------------------//
      if (set_lth_enb == 1'b1) begin
        fcb_clp_lth_enb_cs <= #PAR_DLY 1'b1;
      end
      else if ( clear_lth_enb == 1'b1 || cfg_done_clear_ltch_enb == 1'b1 )	// 01-23-2017
	begin
        fcb_clp_lth_enb_cs <= #PAR_DLY 1'b0;
      end
      //----------------------------------------------------------------//
      //-- CFG_ENB							--//
      //----------------------------------------------------------------//
      if (set_cfg_enb == 1'b1) begin
        fcb_clp_cfg_enb_cs <= #PAR_DLY 1'b1;
      end else if (clear_cfg_enb == 1'b1) begin
        fcb_clp_cfg_enb_cs <= #PAR_DLY 1'b0;
      end
      //----------------------------------------------------------------//
      //-- PWR GATE							--//
      //----------------------------------------------------------------//
      if (set_pwr_gate == 1'b1) begin
        fcb_clp_pwr_gate_cs <= #PAR_DLY 1'b1;
      end else if (clear_pwr_gate == 1'b1) begin
        fcb_clp_pwr_gate_cs <= #PAR_DLY 1'b0;
      end
      //----------------------------------------------------------------//
      //-- LTH_ENB							--//
      //----------------------------------------------------------------//
      if (set_vlp == 1'b1) begin
        fcb_clp_vlp_cs <= #PAR_DLY 1'b1;
      end else if (clear_vlp == 1'b1) begin
        fcb_clp_vlp_cs <= #PAR_DLY 1'b0;
      end
    end
  end
  //------------------------------------------------------------------------//
  //-- Timer, 1 base                                                      --//
  //------------------------------------------------------------------------//
  assign clp_timer_timeout = (clp_timer_cs == 13'h0001) ? 1'b1 : 1'b0;

  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      clp_timer_cs <= #PAR_DLY 13'h0000;
    end else begin
      clp_timer_cs <= #PAR_DLY clp_timer_ns;
    end
  end

  always_comb begin
    if (clp_timer_kickoff == 1'b1) begin
      clp_timer_ns = clp_timer_ini_value;
    end else if (clp_timer_cs == 13'h0000) begin
      clp_timer_ns = clp_timer_cs;
    end else begin
      clp_timer_ns = clp_timer_cs - 1'b1;
    end
  end

  //------------------------------------------------------------------------//
  //-- STM                                                                --//
  //------------------------------------------------------------------------//
  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      clp_stm_cs <= #PAR_DLY MAIN_S0;
      if ( fcb_fb_default_on_bo == 1'b1 ) 				//JC
	  begin
        fclp_frfu_clp_pw_sta_cs <= #PAR_DLY PAR_PWR_ACTIVE;
      end else begin
        fclp_frfu_clp_pw_sta_cs <= #PAR_DLY PAR_PWR_PSD;
      end
    end else if (fcb_clp_mode_en_bo == 1'b0) begin
      clp_stm_cs <= #PAR_DLY MAIN_S0;
      fclp_frfu_clp_pw_sta_cs <= #PAR_DLY PAR_PWR_ACTIVE;
    end else begin
      clp_stm_cs <= #PAR_DLY clp_stm_ns;
      fclp_frfu_clp_pw_sta_cs <= #PAR_DLY fclp_frfu_clp_pw_sta_ns;
    end
  end
  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  always_comb begin
    clp_timer_kickoff         = 1'b0;
    clp_timer_ini_value       = 11'h000;
    clear_lth_enb             = 1'b0;
    set_lth_enb               = 1'b0;
    clear_cfg_enb             = 1'b0;
    set_cfg_enb               = 1'b0;
    clear_pwr_gate            = 1'b0;
    set_pwr_gate              = 1'b0;
    clear_vlp                 = 1'b0;
    set_vlp                   = 1'b0;
    fclp_frfu_clear_vlp_en    = 1'b0;
    fclp_frfu_clear_vlp_wu_en = 1'b0;
    fclp_frfu_clear_pd_en     = 1'b0;
    fclp_frfu_clear_pd_wu_en  = 1'b0;
    fclp_frfu_clear_cfg_done  = 1'b0;
    clp_stm_ns                = clp_stm_cs;
    fclp_frfu_clp_pw_sta_ns   = fclp_frfu_clp_pw_sta_cs;
    fcb_clp_set_por_ns        = fcb_clp_set_por_cs;


    //----------------------------------------------------------------//
    //-- CASE START							--//
    //----------------------------------------------------------------//
    unique case (clp_stm_cs)
      //----------------------------------------------------------------//
      //-- MAIN							--//
      //----------------------------------------------------------------//
      MAIN_S0: begin
        //--------------------------------------------------------//
        //-- PD WU Request and PD EN REQ			--// 
        //--------------------------------------------------------//
        if (frfu_fclp_clp_pd_wu_en == 1'b1 && frfu_fclp_clp_pd_en == 1'b1) begin
          fclp_frfu_clear_vlp_en = 1'b1;
          fclp_frfu_clear_vlp_wu_en = 1'b1;
          fclp_frfu_clear_pd_en = 1'b1;
          fclp_frfu_clear_pd_wu_en = 1'b1;
          clp_stm_ns = END_S0;
        end
        //--------------------------------------------------------//
        //-- PD WU Request OR in PD EN REQ			--// 
        //--------------------------------------------------------//
        else
        if (frfu_fclp_clp_pd_wu_en == 1'b1 || frfu_fclp_clp_pd_en == 1'b1) begin
          //------------------------------------------------//
          //-- PD EN REQ					--// 
          //------------------------------------------------//
          if (frfu_fclp_clp_pd_en == 1'b1) begin
            if (fclp_frfu_clp_pw_sta_cs == PAR_PWR_ACTIVE) begin
              clp_stm_ns = PSD_E0;
            end else begin
              fclp_frfu_clear_pd_en = 1'b1;
              clp_stm_ns            = END_S0;
            end
          end
        //------------------------------------------------//
        //-- PD WU REQ					--// 
          //------------------------------------------------//
          else  // frfu_fclp_clp_pd_wu_en
          begin
            if (fclp_frfu_clp_pw_sta_cs == PAR_PWR_PSD) begin
              clp_stm_ns = PSD_W0;
            end else begin
              fclp_frfu_clear_pd_wu_en = 1'b1;
              clp_stm_ns = END_S0;
            end
          end
        end
        	//----------------------------------------------------------------//
        	//-- VLP WU Request and VLP EN REQ				--// 
        //----------------------------------------------------------------//
        else
        if (frfu_fclp_clp_vlp_wu_en == 1'b1 && frfu_fclp_clp_vlp_en == 1'b1) begin
          fclp_frfu_clear_vlp_en = 1'b1;
          fclp_frfu_clear_vlp_wu_en = 1'b1;
          clp_stm_ns = END_S0;
        end
        		//--------------------------------------------------------//
        		//-- VLP WU Request OR in VLP EN REQ			--// 
        //--------------------------------------------------------//
        else
        if (frfu_fclp_clp_vlp_wu_en == 1'b1 || frfu_fclp_clp_vlp_en == 1'b1) begin
          //------------------------------------------------//
          //-- VLP EN REQ					--// 
          //------------------------------------------------//
          if (frfu_fclp_clp_vlp_en == 1'b1) begin
            if (fclp_frfu_clp_pw_sta_cs == PAR_PWR_ACTIVE) begin
              clp_stm_ns = VLP_E0;
            end else begin
              fclp_frfu_clear_pd_en = 1'b1;
              clp_stm_ns            = END_S0;
            end
          end
        			//------------------------------------------------//
        			//-- VLP WU REQ					--// 
          //------------------------------------------------//
          else  // frfu_fclp_clp_vlp_wu_en == 1'b1 
          begin
            if (fclp_frfu_clp_pw_sta_cs == PAR_PWR_VLP) begin
              clp_stm_ns = VLP_W0;
            end else begin
              fclp_frfu_clear_pd_wu_en = 1'b1;
              clp_stm_ns               = END_S0;
            end
          end
        end else begin
          clp_stm_ns = clp_stm_cs;
        end
      end
      //----------------------------------------------------------------//
      //-- Waking Up From SD Mode					--//
      //----------------------------------------------------------------//
      PSD_W0: begin
        clear_pwr_gate = 1'b1;  // Clera Power Gate
        clp_stm_ns     = PSD_W1;
      end
      PSD_W1: begin
        clp_timer_kickoff   = 1'b1;
        clp_stm_ns          = PSD_W2;
        clp_timer_ini_value = timer_1us_value;
      end
      PSD_W2: begin
        if ( clp_timer_timeout == 1'b0 )		// Wait for 1uS
          begin
          clp_stm_ns = clp_stm_cs;
        end else begin
          clp_stm_ns = PSD_W3;
        end
      end

      PSD_W3: begin
        fcb_clp_set_por_ns = 1'b1;  // Assert POR
        clp_stm_ns         = PSD_W4;
      end
      PSD_W4: begin
        clp_timer_kickoff   = 1'b1;
        clp_stm_ns          = PSD_W5;
        clp_timer_ini_value = {timer_100ns_value[10:0], 2'b00};
      end
      PSD_W5: begin
        if ( clp_timer_timeout == 1'b0 )	// Wait 400ns
          begin
          clp_stm_ns = clp_stm_cs;
        end else begin
          fcb_clp_set_por_ns = 1'b0;  // De-Assert POR
          clp_stm_ns         = PSD_W6;
        end
      end
      PSD_W6: begin
        clear_cfg_enb = 1'b1;  // De-Assert CFG_ENB
        clp_stm_ns    = PSD_W7;
      end
      PSD_W7 :					// Wait 100nS
      begin
        clp_timer_kickoff   = 1'b1;
        clp_stm_ns          = PSD_W8;
        clp_timer_ini_value = timer_100ns_value;
      end
      PSD_W8: begin
        if (clp_timer_timeout == 1'b0) begin
          clp_stm_ns = clp_stm_cs;
        end else begin
          fclp_frfu_clp_pw_sta_ns  = PAR_PWR_ACTIVE;
          fclp_frfu_clear_pd_wu_en = 1'b1;
          clp_stm_ns               = END_S0;
        end
      end
      //----------------------------------------------------------------//
      //-- Entering SD Mode						--//
      //----------------------------------------------------------------//
      PSD_E0: begin
        set_lth_enb              = 1'b1;
        set_cfg_enb              = 1'b1;
        fclp_frfu_clear_cfg_done = 1'b1;
        clp_stm_ns               = PSD_E1;
      end
      PSD_E1: begin
        clp_timer_kickoff   = 1'b1;
        clp_stm_ns          = PSD_E2;
        clp_timer_ini_value = timer_100ns_value;
      end
      PSD_E2: begin
        if (clp_timer_timeout == 1'b0) begin
          clp_stm_ns = clp_stm_cs;
        end else begin
          set_pwr_gate = 1'b1;
          clp_stm_ns   = PSD_E3;
        end
      end
      PSD_E3: begin
        clp_timer_kickoff   = 1'b1;
        clp_stm_ns          = PSD_E4;
        clp_timer_ini_value = timer_200ns_value;
      end
      PSD_E4: begin
        if (clp_timer_timeout == 1'b0) begin
          clp_stm_ns = clp_stm_cs;
        end else begin
          fclp_frfu_clp_pw_sta_ns = PAR_PWR_PSD;
          fclp_frfu_clear_pd_en   = 1'b1;
          clp_stm_ns              = END_S0;
        end
      end
      //----------------------------------------------------------------//
      //-- Waking Up From VLP Mode					--//
      //----------------------------------------------------------------//
      VLP_W0: begin
        clear_vlp  = 1'b1;
        clp_stm_ns = VLP_W1;
      end
      VLP_W1: begin
        clp_timer_kickoff   = 1'b1;
        clp_stm_ns          = VLP_W2;
        clp_timer_ini_value = timer_10us_value;
      end
      VLP_W2: begin
        if (clp_timer_timeout == 1'b0) begin
          clp_stm_ns = clp_stm_cs;
        end else begin
          clear_lth_enb	= 1'b1 ;
          clear_cfg_enb	= 1'b1 ;
          clp_stm_ns   	= VLP_W3 ;
        end
      end
      VLP_W3: begin
        clp_timer_kickoff   = 1'b1;
        clp_stm_ns          = VLP_W4;
        clp_timer_ini_value = timer_200ns_value;
      end
      VLP_W4: begin
        if (clp_timer_timeout == 1'b0) begin
          clp_stm_ns = clp_stm_cs;
        end else begin
          fclp_frfu_clp_pw_sta_ns   = PAR_PWR_ACTIVE;
          fclp_frfu_clear_vlp_wu_en = 1'b1;
          clp_stm_ns                = END_S0;
        end
      end
      //----------------------------------------------------------------//
      //-- Entering VLP Mode						--//
      //----------------------------------------------------------------//
      VLP_E0: begin
        set_lth_enb = 1'b1;
        set_cfg_enb = 1'b1;
        clp_stm_ns  = VLP_E1;
      end
      VLP_E1: begin
        clp_timer_kickoff   = 1'b1;
        clp_stm_ns          = VLP_E2;
        clp_timer_ini_value = timer_200ns_value;
      end
      VLP_E2: begin
        if (clp_timer_timeout == 1'b0) begin
          clp_stm_ns = clp_stm_cs;
        end else begin
          set_vlp		= 1'b1 ;
          clp_stm_ns   	= VLP_E3 ;
        end
      end
      VLP_E3: begin
        clp_timer_kickoff   = 1'b1;
        clp_stm_ns          = VLP_E4;
        clp_timer_ini_value = timer_10us_value;
      end
      VLP_E4: begin
        if (clp_timer_timeout == 1'b0) begin
          clp_stm_ns = clp_stm_cs;
        end else begin
          fclp_frfu_clp_pw_sta_ns = PAR_PWR_VLP;
          fclp_frfu_clear_vlp_en  = 1'b1;
          clp_stm_ns              = END_S0;
        end
      end
      //----------------------------------------------------------------//
      //-- END Cycle 							--//
      //----------------------------------------------------------------//
      END_S0: begin
        clp_stm_ns = MAIN_S0;
      end
      default: begin
        clp_stm_ns = MAIN_S0;
      end
    endcase
  end
  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//
  always_comb begin
    if (frfu_fclp_clp_time_ctl == 2'b00) begin
      timer_100ns_value = {1'b0, PAR_QLFCB_11BIT_100NS, 1'b0};
      timer_200ns_value = {1'b0, PAR_QLFCB_11BIT_200NS, 1'b0};
      timer_1us_value   = {1'b0, PAR_QLFCB_11BIT_1US, 1'b0};
      timer_10us_value  = {1'b0, PAR_QLFCB_11BIT_10US, 1'b0};
    end else if (frfu_fclp_clp_time_ctl == 2'b01) begin
      timer_100ns_value = {2'b00, PAR_QLFCB_11BIT_100NS};
      timer_200ns_value = {2'b00, PAR_QLFCB_11BIT_200NS};
      timer_1us_value   = {2'b00, PAR_QLFCB_11BIT_1US};
      timer_10us_value  = {2'b00, PAR_QLFCB_11BIT_10US};
    end else if (frfu_fclp_clp_time_ctl == 2'b10) begin
      if (PAR_QLFCB_11BIT_100NS >= 11'h04) begin
        timer_100ns_value = {2'b00, PAR_QLFCB_11BIT_100NS} >> 1;
      end else begin
        timer_100ns_value = {2'b0, PAR_QLFCB_11BIT_100NS};
      end

      if (PAR_QLFCB_11BIT_200NS >= 11'h04) begin
        timer_200ns_value = {2'b00, PAR_QLFCB_11BIT_200NS} >> 1;
      end else begin
        timer_200ns_value = {2'b00, PAR_QLFCB_11BIT_200NS};
      end

      if (PAR_QLFCB_11BIT_1US >= 11'h04) begin
        timer_1us_value = {2'b00, PAR_QLFCB_11BIT_1US} >> 1;
      end else begin
        timer_1us_value = {2'b00, PAR_QLFCB_11BIT_1US};
      end

      if (PAR_QLFCB_11BIT_10US >= 11'h04) begin
        timer_10us_value = {2'b00, PAR_QLFCB_11BIT_1US} >> 1;
      end else begin
        timer_10us_value = {2'b00, PAR_QLFCB_11BIT_1US};
      end
    end else begin
      if (PAR_QLFCB_11BIT_100NS >= 11'h08) begin
        timer_100ns_value = {2'b00, PAR_QLFCB_11BIT_100NS} >> 2;
      end else if (PAR_QLFCB_11BIT_100NS >= 11'h04) begin
        timer_100ns_value = {2'b00, PAR_QLFCB_11BIT_100NS} >> 1;
      end else begin
        timer_100ns_value = {2'b00, PAR_QLFCB_11BIT_100NS};
      end

      if (PAR_QLFCB_11BIT_200NS >= 11'h08) begin
        timer_200ns_value = {2'b00, PAR_QLFCB_11BIT_200NS} >> 2;
      end else if (PAR_QLFCB_11BIT_200NS >= 11'h04) begin
        timer_200ns_value = {2'b00, PAR_QLFCB_11BIT_200NS} >> 1;
      end else begin
        timer_200ns_value = {2'b0, PAR_QLFCB_11BIT_200NS};
      end

      if (PAR_QLFCB_11BIT_1US >= 11'h08) begin
        timer_1us_value = {2'b00, PAR_QLFCB_11BIT_1US} >> 2;
      end else if (PAR_QLFCB_11BIT_1US >= 11'h04) begin
        timer_1us_value = {2'b00, PAR_QLFCB_11BIT_1US} >> 1;
      end else begin
        timer_1us_value = {2'b00, PAR_QLFCB_11BIT_1US};
      end

      if (PAR_QLFCB_11BIT_10US >= 11'h08) begin
        timer_10us_value = {2'b00, PAR_QLFCB_11BIT_1US} >> 2;
      end else if (PAR_QLFCB_11BIT_10US >= 11'h04) begin
        timer_10us_value = {2'b00, PAR_QLFCB_11BIT_1US} >> 1;
      end else begin
        timer_10us_value = {2'b00, PAR_QLFCB_11BIT_1US};
      end
    end
  end

  //----------------------------------------------------------------//
  //-- BUG FIX -- 1                                               --//
  //--                                                            --//
  //-- if STM==1 and PIF==1, LTH_ENB_MUX=1                        --//
  //-- if STM==1 and PIF==0, LTH_ENB_MUX=0                        --//
  //-- if STM==0             LTH_ENB_MUX=LTH_ENB                  --//
  //--                                                            --//
  //----------------------------------------------------------------//
  always_comb begin
    if (fcb_sys_stm == 1'b1) begin
      if (fcb_pif_en == 1'b1) begin
        fcb_clp_lth_enb = 1'b1;
      end else begin
        fcb_clp_lth_enb = 1'b0;
      end
    end else begin
      fcb_clp_lth_enb = fcb_clp_lth_enb_cs;
    end
  end
  //-------------------------------------------------------------------------//
  //-- END                                                                 --//
  //-------------------------------------------------------------------------//
endmodule


