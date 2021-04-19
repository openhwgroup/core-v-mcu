// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

module fcbfsr #(
    parameter [15:0] PAR_RAMFIFO_CFG  = 16'b0000_0000_0000_0000   //Define the RAMFIFO which Read back data
) (
    //------------------------------------------------------------------------//
    //-- INPUT PORT                                                         --//
    //------------------------------------------------------------------------//
    input  logic        fcb_sys_clk,  //Main Clock for FCB except SPI Slave Int
    input  logic        fcb_sys_rst_n,  //Main Reset for FCB except SPI Slave int
    input  logic        fcb_sys_stm,  //1'b1 : Put the module into Test Mode
    input  logic [31:0] fcb_bl_dout,  //Fabric BL Read Data
    input  logic [17:0] fcb_apbm_prdata_0,  //APB Read Data, the RAMFIFO will impleme
    input  logic [17:0] fcb_apbm_prdata_1,  //APB Read Data, the RAMFIFO will impleme
    input  logic [ 7:0] frfu_ffsr_fb_cfg_cmd,  //0x1E
    input  logic        frfu_ffsr_fb_cfg_kickoff,  //Level Signal
    input  logic [ 7:0] frfu_ffsr_ram_cfg_0,  //RAM Cfg
    input  logic [ 7:0] frfu_ffsr_ram_cfg_1,  //RAM Cfg
    input  logic [ 7:0] frfu_wrd_cnt_b0,  //Cfg/Ram FIFO Data Count
    input  logic [ 7:0] frfu_wrd_cnt_b1,  //Cfg/Ram FIFO Data Count
    input  logic [ 7:0] frfu_wrd_cnt_b2,  //Cfg/Ram FIFO Data Count
    input  logic [ 7:0] frfu_ffsr_bl_cnt_l,  //BitLine CNT
    input  logic [ 7:0] frfu_ffsr_bl_cnt_h,  //BitLine CNT
    input  logic [ 7:0] frfu_ffsr_wl_cnt_l,  //WordLine CNT
    input  logic [ 7:0] frfu_ffsr_wl_cnt_h,  //WordLine CNT
    input  logic [ 7:0] frfu_ffsr_col_cnt,  //Column CNT
    input  logic [ 7:0] frfu_ffsr_ram_size_b0,  //RAM Size
    input  logic [ 7:0] frfu_ffsr_ram_size_b1,  //RAM Size
    input  logic [ 7:0] frfu_ffsr_ram_data_width,  //RAM Data Widht
    input  logic [ 3:0] frfu_ffsr_cfg_wrp_ccnt,  //Cfg Ctl Signal Cycle
    input  logic [ 3:0] frfu_ffsr_rcfg_wrp_ccnt,  //Cfg Ctl Signal Cycle
    input  logic [ 7:0] frfu_bl_pw_cfg_0,  //BL Power Gate
    input  logic [ 7:0] frfu_bl_pw_cfg_1,  //BL Power Gate
    input  logic [ 7:0] frfu_wl_pw_cfg,  //WL Power Gate
    input  logic        frfu_ffsr_rfifo_rd_en,  //Read Enable of Read FIFO
    input  logic [31:0] frfu_ffsr_wfifo_wdata,  //Write Data of Write FIFO
    input  logic        frfu_ffsr_wfifo_wr_en,  //Write Enable of Write FIFO
    input  logic [ 1:0] frfu_ffsr_wlblclk_cfg,  // JC 01302017
    input  logic [ 1:0] frfu_ffsr_blclk_sut,  //JC 07
    input  logic [ 1:0] frfu_ffsr_wlclk_sut,  //JC 07
    input  logic [ 1:0] frfu_ffsr_wlen_sut,  //JC 07
    //------------------------------------------------------------------------//
    //-- OUTPUT PORT                                                        --//
    //------------------------------------------------------------------------//
    output logic        fcb_blclk,  //Fabric Bit Line Clock, Does not need to
    output logic        fcb_re,  //Fabric Read Enable
    output logic        fcb_we,  //Fabric Write Enable
    output logic        fcb_we_int,  //Fabric Write Enable Left/write Interfac
    output logic        fcb_pchg_b,  //Fabric Pre-Charge, Low active
    output logic [31:0] fcb_bl_din,  //Fabric BL Write Data
    output logic        fcb_cload_din_sel,  //Fabric Column Load Data in Select
    output logic        fcb_din_slc_tb_int,  //Fabric Bit Line Shift Register Data In
    output logic        fcb_din_int_l_only,  //Fabric Bit line shift register Data in
    output logic        fcb_din_int_r_only,  //Fabric Bit Line Shift Register Data in
    output logic [15:0] fcb_bl_pwrgate,  //Fabric Bit Line Cfg Shift Register Powe
    output logic        fcb_wlclk,  //Fabric Word Line Clock, Does not need t
    output logic        fcb_wl_resetb,  //Fabric Word Line Shift Register Bank Re
    output logic        fcb_wl_en,  //Fabric Word Line enable
    output logic [15:0] fcb_wl_sel,  //Fabric Word Line Select
    output logic [ 2:0] fcb_wl_cload_sel,  //Fabric Word Line Column Load Select
    output logic [ 7:0] fcb_wl_pwrgate,  //Fabric Word Line Power Gate Control. 1'
    output logic [ 5:0] fcb_wl_din,  //Fabric Word Line Shfit Register Data In
    output logic        fcb_wl_int_din_sel,  //Fabric Word Line interface Data in Sele
    //output logic [15:0]             fcb_prog ,      	//Fabric Configuration Enable for Quads,
    //output logic                    fcb_prog_ifx ,  	//Fabric Configuration Enable for IFX, Hi
    output logic        fcb_wl_sel_tb_int,  //Disable the TB Configuration during Qua
    output logic [11:0] fcb_apbm_paddr,  //APB Address in byte Resolution, Bit 11
    output logic [ 7:0] fcb_apbm_psel,  //APB Slave Select Signals. Bit 0 is used
    output logic        fcb_apbm_penable,  //APB Enable signal for data transfer
    output logic        fcb_apbm_pwrite,  //APB write Enable Signal
    output logic [17:0] fcb_apbm_pwdata,  //APB Write Data
    output logic        fcb_apbm_ramfifo_sel,  //1'b1 : RAMFIFO APB Interface Enable.	//
    output logic        fcb_apbm_mclk,  // APB Master Clock
    output logic        ffsr_frfu_clr_fb_cfg_kickoff,  //Clear Kick-Off Register
    output logic [31:0] ffsr_frfu_rfifo_rdata,  //Read Data of Read FIFO
    output logic        ffsr_frfu_rfifo_empty,  //Empty Flag of Read FIFO
    output logic        ffsr_frfu_rfifo_empty_p1,  //Empty Plus 1 Flag of Read FIFO
    output logic        ffsr_frfu_wfifo_full,  //Full Flag of Write FIFO
    output logic        ffsr_frfu_wfifo_full_m1,  //Full minus 1 Flag of Write FIFO
    output logic        ffsr_fsr_busy,  //Indicate the FSR is busy
    //output logic [15:0]             fcb_rst ,       	//Fabric Reset
    output logic        fcb_rst  //For Tamar Only
    //output logic                    fcb_tb_rst ,    	//TB Reset
    //output logic                    fcb_lr_rst ,    	//LR Reset
    //output logic                    fcb_iso_rst    	//LR Reset

);

  //------------------------------------------------------------------------//
  //-- Local Parameter                                                    --//
  //------------------------------------------------------------------------//
  localparam PAR_DLY = 1'b1;

  //------------------------------------------------------------------------//
  //-- EMUN/Flops                                                         --//
  //------------------------------------------------------------------------//
  typedef enum logic [7:0] {
    MAIN_S0 = 8'h00,
    MAIN_S1 = 8'h01,
    MAIN_S2 = 8'h02,
    MAIN_S3 = 8'h03,
    MAIN_S4 = 8'h04,
    MAIN_S5 = 8'h05,
    MAIN_S6 = 8'h06,
    MAIN_S7 = 8'h07,
    MAIN_S8 = 8'h08,
    MAIN_S9 = 8'h09,
    MAIN_SA = 8'h0A,
    MAIN_SB = 8'h0B,
    MAIN_SC = 8'h0C,
    MAIN_SD = 8'h0D,
    MAIN_SE = 8'h0E,
    MAIN_SF = 8'h0F,
    //
    NOR_S00 = 8'h10,
    NOR_S01 = 8'h11,
    NOR_S02 = 8'h12,
    NOR_S03 = 8'h13,
    NOR_S04 = 8'h14,
    NOR_S05 = 8'h15,
    NOR_S06 = 8'h16,

    NOR_S06A = 8'hD0,
    NOR_S06B = 8'hD1,
    NOR_S06C = 8'hD2,


    NOR_S07 = 8'h17,

    NOR_S07A = 8'hC0,  //JC
    NOR_S07B = 8'hC1,  //JC

    NOR_S08  = 8'h18,
    NOR_S08A = 8'hD6,
    NOR_S08B = 8'hD7,
    NOR_S08C = 8'hD8,

    NOR_S09 = 8'h19,

    NOR_S09A = 8'hB0,  //JC 01302017
    NOR_S09B = 8'hB1,  //JC 01302017

    NOR_S0A = 8'h1A,
    NOR_S0B = 8'h1B,
    NOR_S0C = 8'h1C,
    NOR_S0D = 8'h1D,
    NOR_S0E = 8'h1E,
    NOR_S0F = 8'h1F,
    NOR_S10 = 8'h20,
    NOR_S11 = 8'h21,
    NOR_S12 = 8'h22,
    NOR_S13 = 8'h23,
    NOR_S14 = 8'h24,
    NOR_S15 = 8'h25,
    NOR_S16 = 8'h26,
    NOR_S17 = 8'h27,
    NOR_S18 = 8'h28,
    NOR_S19 = 8'h29,
    NOR_S1A = 8'h2A,
    NOR_S1B = 8'h2B,
    NOR_S1C = 8'h2C,
    NOR_S1D = 8'h2D,
    NOR_S1E = 8'h2E,
    NOR_S1F = 8'h2F,
    //
    SLC_S00 = 8'h30,
    SLC_S01 = 8'h31,
    SLC_S02 = 8'h32,
    SLC_S03 = 8'h33,
    SLC_S04 = 8'h34,
    SLC_S05 = 8'h35,
    SLC_S06 = 8'h36,

    SLC_S06A = 8'hD3,
    SLC_S06B = 8'hD4,
    SLC_S06C = 8'hD5,

    SLC_S07 = 8'h37,

    SLC_S07A = 8'hC2,  //JC
    SLC_S07B = 8'hC3,  //JC

    SLC_S08 = 8'h38,

    SLC_S08A = 8'hD9,
    SLC_S08B = 8'hDA,
    SLC_S08C = 8'hDB,

    SLC_S09 = 8'h39,

    SLC_S09A = 8'hB2,  //JC 01302017
    SLC_S09B = 8'hB3,  //JC 01302017

    SLC_S0A  = 8'h3A,
    SLC_S0B  = 8'h3B,
    SLC_S0C  = 8'h3C,
    SLC_S0D  = 8'h3D,
    SLC_S0DA = 8'h4F,
    SLC_S0E  = 8'h3E,
    SLC_S0F  = 8'h3F,
    SLC_S10  = 8'h40,
    SLC_S11  = 8'h41,
    SLC_S12  = 8'h42,
    SLC_S13  = 8'h43,
    SLC_S14  = 8'h44,
    SLC_S15  = 8'h45,
    SLC_S16  = 8'h46,
    SLC_S17  = 8'h47,
    SLC_S18  = 8'h48,
    SLC_S19  = 8'h49,
    SLC_S1A  = 8'h4A,
    SLC_S1B  = 8'h4B,
    SLC_S1C  = 8'h4C,
    SLC_S1D  = 8'h4D,
    SLC_S1E  = 8'h4E,
    //		SLC_S1F		=	8'h4F ,
    //
    SCS_S00  = 8'h50,
    SCS_S01  = 8'h51,
    SCS_S02  = 8'h52,
    SCS_S03  = 8'h53,

    SCS_S03A = 8'hB4,  //JC 01302017
    SCS_S03B = 8'hB5,  //JC 01302017

    SCS_S04 = 8'h54,
    SCS_S05 = 8'h55,
    SCS_S06 = 8'h56,
    SCS_S07 = 8'h57,
    SCS_S08 = 8'h58,
    SCS_S09 = 8'h59,
    SCS_S0A = 8'h5A,
    SCS_S0B = 8'h5B,
    SCS_S0C = 8'h5C,
    SCS_S0D = 8'h5D,
    SCS_S0E = 8'h5E,
    SCS_S0F = 8'h5F,
    //
    FCR_S00 = 8'h60,
    FCR_S01 = 8'h61,
    FCR_S02 = 8'h62,
    FCR_S03 = 8'h63,
    FCR_S04 = 8'h64,
    FCR_S05 = 8'h65,
    FCR_S06 = 8'h66,

    FCR_S06A = 8'hDC,
    FCR_S06B = 8'hDD,
    FCR_S06C = 8'hDE,

    FCR_S07 = 8'h67,

    FCR_S07A = 8'hB6,  //JC 01302017
    FCR_S07B = 8'hB7,  //JC 01302017

    FCR_S08  = 8'h68,
    FCR_S09  = 8'h69,
    FCR_S09A = 8'h7F,
    FCR_S0A  = 8'h6A,
    FCR_S0B  = 8'h6B,
    FCR_S0C  = 8'h6C,

    FCR_S0CA = 8'hC4,  //JC 01302017
    FCR_S0CB = 8'hC5,  //JC 01302017

    FCR_S0D  = 8'h6D,
    FCR_S0DA = 8'h7E,

    FCR_S0E = 8'h6E,

    FCR_S0EA = 8'hC6,
    FCR_S0EB = 8'hC7,
    FCR_S0EC = 8'hC8,
    FCR_S0ED = 8'hC9,

    FCR_S0F  = 8'h6F,
    FCR_S10  = 8'h70,
    FCR_S11  = 8'h71,
    FCR_S12  = 8'h72,
    FCR_S13  = 8'h73,
    FCR_S14  = 8'h74,
    FCR_S15  = 8'h75,
    FCR_S16  = 8'h76,
    FCR_S17  = 8'h77,
    FCR_S18  = 8'h78,
    FCR_S19  = 8'h79,
    FCR_S1A  = 8'h7A,
    FCR_S1B  = 8'h7B,
    FCR_S1C  = 8'h7C,
    FCR_S1D  = 8'h7D,
    //		FCR_S1E		=	8'h7E ,
    //		FCR_S1F		=	8'h7F ,
    //
    ARR_S00  = 8'h80,
    ARR_S01  = 8'h81,
    ARR_S02  = 8'h82,
    ARR_S03  = 8'h83,
    ARR_S04  = 8'h84,
    ARR_S05  = 8'h85,
    ARR_S06  = 8'h86,
    ARR_S07  = 8'h87,
    ARR_S08  = 8'h88,
    ARR_S09  = 8'h89,
    ARR_S0A  = 8'h8A,
    ARR_S0B  = 8'h8B,
    ARR_S0C  = 8'h8C,
    ARR_S0D  = 8'h8D,
    ARR_S0E  = 8'h8E,
    ARR_S0F  = 8'h8F,
    ARW_S00  = 8'h90,
    ARW_S01  = 8'h91,
    ARW_S02  = 8'h92,
    ARW_S03  = 8'h93,
    ARW_S04  = 8'h94,
    ARW_S05  = 8'h95,
    ARW_S06  = 8'h96,
    ARW_S07  = 8'h97,
    ARW_S07A = 8'h9E,
    ARW_S07B = 8'h9F,
    ARW_S08  = 8'h98,
    ARW_S09  = 8'h99,
    ARW_S0A  = 8'h9A,
    ARW_S0B  = 8'h9B,
    ARW_S0C  = 8'h9C,
    ARW_S0D  = 8'h9D,
    //	ARW_S0E		=	8'h9E ,
    //	ARW_S0F		=	8'h9F ,
    END_S00  = 8'hA0,
    END_S01  = 8'hA1,
    END_S02  = 8'hA2,
    END_S03  = 8'hA3,
    END_S04  = 8'hA4,
    END_S05  = 8'hA5,
    END_S06  = 8'hA6,
    END_S07  = 8'hA7
  } EN_STATE;

  //------------------------------------------------------------------------//
  //-- Wire/Flops                                                         --//
  //------------------------------------------------------------------------//
  EN_STATE        fsr_stm_cs;
  EN_STATE        fsr_stm_ns;
  EN_STATE        fsr_return_stm_cs;
  EN_STATE        fsr_return_stm_ns;

  logic    [ 7:0] fsr_timer_cs;
  logic    [ 7:0] fsr_timer_ns;
  logic           fsr_timer_kickoff;
  logic    [ 7:0] fsr_timer_ini_value;
  logic           fsr_timer_timeout;

  logic           fcb_blclk_cs;
  logic           fcb_re_cs;

  logic           fcb_re_cs_dly1cyc;

  logic           fcb_we_cs;
  logic           fcb_we_int_cs;
  logic           fcb_pchg_b_cs;
  logic           fcb_cload_din_sel_cs;
  logic    [15:0] fcb_bl_pwrgate_cs;
  logic           fcb_wlclk_cs;
  logic           fcb_wl_resetb_cs;
  logic           fcb_wl_en_cs;
  logic    [15:0] fcb_wl_sel_cs;
  logic    [ 7:0] fcb_wl_pwrgate_cs;
  logic    [ 5:0] fcb_wl_din_cs;
  logic           fcb_wl_int_din_sel_cs;
  logic    [15:0] fcb_prog_cs;
  logic           fcb_prog_ifx_cs;
  logic           fcb_wl_sel_tb_int_cs;
  logic    [11:0] fcb_apbm_paddr_cs;
  logic    [ 7:0] fcb_apbm_psel_cs;
  logic           fcb_apbm_penable_cs;
  logic           fcb_apbm_pwrite_cs;
  //logic [17:0]          fcb_apbm_pwdata_cs ;       
  logic           fcb_apbm_ramfifo_sel_cs;
  //logic [15:0]          fcb_rst_cs ;               
  logic           fcb_rst_cs;
  logic           fcb_tb_rst_cs;
  logic           fcb_lr_rst_cs;
  logic           fcb_iso_rst_cs;

  logic           fcb_blclk_ns;
  logic           fcb_re_ns;
  logic           fcb_we_ns;
  logic           fcb_we_int_ns;
  logic           fcb_pchg_b_ns;
  logic           fcb_cload_din_sel_ns;
  logic    [15:0] fcb_bl_pwrgate_ns;
  logic           fcb_wlclk_ns;
  logic           fcb_wl_resetb_ns;
  logic           fcb_wl_en_ns;
  logic    [15:0] fcb_wl_sel_ns;
  logic    [ 7:0] fcb_wl_pwrgate_ns;
  logic    [ 5:0] fcb_wl_din_ns;
  logic           fcb_wl_int_din_sel_ns;
  logic    [15:0] fcb_prog_ns;
  logic           fcb_prog_ifx_ns;
  logic           fcb_wl_sel_tb_int_ns;
  logic    [11:0] fcb_apbm_paddr_ns;
  logic    [ 7:0] fcb_apbm_psel_ns;
  logic           fcb_apbm_penable_ns;
  logic           fcb_apbm_pwrite_ns;
  //logic [17:0]          fcb_apbm_pwdata_ns ;
  logic           fcb_apbm_ramfifo_sel_ns;
  //logic [15:0]          fcb_rst_ns ;  
  logic           fcb_rst_ns;
  logic           fcb_tb_rst_ns;
  logic           fcb_lr_rst_ns;
  logic           fcb_iso_rst_ns;

  logic    [23:0] frfu_wrd_cnt_cs;
  logic    [15:0] frfu_ffsr_bl_cnt_cs;
  logic    [15:0] frfu_ffsr_wl_cnt_cs;
  logic    [ 7:0] frfu_ffsr_col_cnt_cs;
  logic    [15:0] frfu_bl_pw_cfg_cs;
  logic    [ 7:0] frfu_wl_pw_cfg_cs;

  logic    [23:0] frfu_wrd_cnt_ns;
  logic    [15:0] frfu_ffsr_bl_cnt_ns;
  logic    [15:0] frfu_ffsr_wl_cnt_ns;
  logic    [ 7:0] frfu_ffsr_col_cnt_ns;
  logic    [15:0] frfu_bl_pw_cfg_ns;
  logic    [ 7:0] frfu_wl_pw_cfg_ns;

  logic           fcb_apbm_mclk_cs;
  logic           fcb_apbm_mclk_ns;

  logic    [15:0] frfu_ffsr_ram_cfg;
  logic    [15:0] frfu_ffsr_ram_size;


  logic           wff_rd_en;
  logic           wff_wr_en;
  logic           wff_empty;
  logic           wff_full;
  logic    [31:0] wff_rdata;
  logic    [31:0] wff_wdata;

  logic           rff_rd_en;
  logic           rff_wr_en;
  logic           rff_empty;
  logic           rff_full;
  logic    [31:0] rff_rdata;
  logic    [31:0] rff_wdata;


  logic    [ 4:0] ramfifo_index_cs;
  logic    [ 4:0] ramfifo_index_ns;


  logic           fcb_apbm_mclk_fe;

  logic           bl_din_sel_cs;

  logic           fcb_wl_en_cs_dly1cyc;
  logic           fcb_wl_en_cs_dly2cyc;
  logic           fcb_wl_en_cs_dly3cyc;

  //--------------------------------------------------------------------------------//
  //-- Start Functional Description                                               --//
  //--------------------------------------------------------------------------------//
  //------------------------------------------------------------------------//
  //-- Fix the BL DIN MUX Selection  					--//
  //-- 									--//
  //------------------------------------------------------------------------//
  //assign fcb_wl_en = ( bl_din_sel_cs == 1'b1 )			// Read,  WL Edge is same as pchg_b
  //		 ? fcb_wl_en_cs : fcb_wl_en_cs_dly1cyc ;	// Write, WL Edge is delay 1 Cycle


  always_comb begin
    if (bl_din_sel_cs == 1'b1) begin
      fcb_wl_en = fcb_wl_en_cs;
    end else begin
      //----------------------------------------------------------------//
      //-- IF WL_EN is 2 Cycles 					--//
      //-- WL_EN cna only delay 1 Cycle regardless configuration	--//
      //----------------------------------------------------------------//
      if ( frfu_ffsr_cfg_wrp_ccnt == 4'b0000 || frfu_ffsr_cfg_wrp_ccnt == 4'b0001 || frfu_ffsr_cfg_wrp_ccnt == 4'b0010 ) // 2 Cycles
	begin
        fcb_wl_en = fcb_wl_en_cs_dly1cyc;
      end
        	//----------------------------------------------------------------//
        	//-- IF WL_EN is 3 Cycles 					--//
      //-- WL_EN cna only delay 1 Cycle or 2 Cycles			--//
      //----------------------------------------------------------------//
      else
      if ( frfu_ffsr_cfg_wrp_ccnt == 4'b0011 ) // 3 Cycles
	begin
        if (frfu_ffsr_wlen_sut == 2'b00) begin
          fcb_wl_en = fcb_wl_en_cs_dly1cyc;
        end else begin
          fcb_wl_en = fcb_wl_en_cs_dly2cyc;
        end
      end
        	//----------------------------------------------------------------//
        	//-- IF WL_EN is 4 Cycles or longer 				--//
      //-- WL_EN cna only delay 1, 2 or 3 Cycles			--//
      //----------------------------------------------------------------//
      else
      begin
        if (frfu_ffsr_wlen_sut == 2'b00) begin
          fcb_wl_en = fcb_wl_en_cs_dly1cyc;
        end else if (frfu_ffsr_wlen_sut == 2'b01) begin
          fcb_wl_en = fcb_wl_en_cs_dly2cyc;
        end else begin
          fcb_wl_en = fcb_wl_en_cs_dly3cyc;
        end
      end
    end
  end


  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      fcb_wl_en_cs_dly1cyc <= #PAR_DLY 1'b0;
      fcb_wl_en_cs_dly2cyc <= #PAR_DLY 1'b0;
      fcb_wl_en_cs_dly3cyc <= #PAR_DLY 1'b0;
    end else begin
      fcb_wl_en_cs_dly1cyc <= #PAR_DLY fcb_wl_en_cs;
      fcb_wl_en_cs_dly2cyc <= #PAR_DLY fcb_wl_en_cs_dly1cyc;
      fcb_wl_en_cs_dly3cyc <= #PAR_DLY fcb_wl_en_cs_dly2cyc;
    end
  end
  //------------------------------------------------------------------------//
  //-- Fix the BL DIN MUX Selection  					--//
  //------------------------------------------------------------------------//
  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      bl_din_sel_cs <= #PAR_DLY 1'b0;
    end else begin
      if (fsr_stm_cs == FCR_S00) begin
        bl_din_sel_cs <= #PAR_DLY 1'b1;
      end else if (fsr_stm_cs == FCR_S0F) begin
        bl_din_sel_cs <= #PAR_DLY 1'b0;
      end else begin
        bl_din_sel_cs <= #PAR_DLY bl_din_sel_cs;
      end
    end
  end
  //----------------------------------------------------------------//
  //----------------------------------------------------------------//
  //----------------------------------------------------------------//
  //assign fcb_apbm_pwdata = fcb_apbm_pwdata ;
  //------------------------------------------------------------------------//
  //-- COMB                                                               --//
  //------------------------------------------------------------------------//
  always_ff @(negedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      fcb_apbm_mclk_fe  <= #PAR_DLY 1'b0;
      fcb_re_cs_dly1cyc <= #PAR_DLY 'b0;
    end else begin
      fcb_apbm_mclk_fe  <= #PAR_DLY fcb_apbm_mclk_cs;
      fcb_re_cs_dly1cyc <= #PAR_DLY fcb_re_cs;  // 
    end
  end
  //----------------------------------------------------------------//
  //-- External 							--//
  //----------------------------------------------------------------//
  assign fcb_blclk             = fcb_blclk_cs;
  assign fcb_re                = fcb_re_cs | fcb_re_cs_dly1cyc;  //
  assign fcb_we                = fcb_we_cs;
  assign fcb_we_int            = fcb_we_int_cs;
  assign fcb_pchg_b            = fcb_pchg_b_cs;
  assign fcb_cload_din_sel     = fcb_cload_din_sel_cs;
  assign fcb_wl_sel_tb_int     = fcb_wl_sel_tb_int_cs;
  assign fcb_bl_pwrgate        = fcb_bl_pwrgate_cs;
  assign fcb_wlclk             = fcb_wlclk_cs;
  assign fcb_wl_resetb         = fcb_wl_resetb_cs;
  //assign fcb_wl_en                        =       fcb_wl_en_cs ;
  assign fcb_wl_sel            = fcb_wl_sel_cs;
  assign fcb_wl_cload_sel      = frfu_ffsr_col_cnt_cs[2:0];  //NOTE
  assign fcb_wl_pwrgate        = fcb_wl_pwrgate_cs;
  assign fcb_wl_int_din_sel    = fcb_wl_int_din_sel_cs;
  //assign fcb_prog                         =       fcb_prog_cs ;
  //assign fcb_prog_ifx                     =       fcb_prog_ifx_cs ;          
  assign fcb_apbm_paddr        = fcb_apbm_paddr_cs;
  assign fcb_apbm_psel         = fcb_apbm_psel_cs;
  assign fcb_apbm_penable      = fcb_apbm_penable_cs;
  assign fcb_apbm_pwrite       = fcb_apbm_pwrite_cs;
  assign fcb_apbm_ramfifo_sel  = fcb_apbm_ramfifo_sel_cs;
  assign fcb_apbm_mclk         = fcb_apbm_mclk_fe;  //Falling Edge
  assign fcb_rst               = fcb_rst_cs;
  //assign fcb_tb_rst                       =       fcb_tb_rst_cs ;             
  //assign fcb_lr_rst                       =       fcb_lr_rst_cs ;             
  //assign fcb_iso_rst                      =       fcb_iso_rst_cs ;             
  assign fcb_wl_din            = fcb_wl_din_cs;

  assign ffsr_frfu_rfifo_empty = rff_empty;
  assign ffsr_fsr_busy         = (fsr_stm_cs == MAIN_S0) ? 1'b0 : 1'b1;

  //----------------------------------------------------------------//
  //-- MUX 							--//
  //----------------------------------------------------------------//
  always_comb begin
    if ( frfu_ffsr_fb_cfg_cmd[7:0] == 8'h00 ||
       frfu_ffsr_fb_cfg_cmd[7:0] == 8'h01 ||
       frfu_ffsr_fb_cfg_cmd[7:0] == 8'h10 ||
       frfu_ffsr_fb_cfg_cmd[7:0] == 8'h11  )
    begin
      fcb_bl_din[31:0]   = wff_rdata[31:0];
      fcb_din_slc_tb_int = 'b0;
      fcb_din_int_l_only = 'b0;
      fcb_din_int_r_only = 'b0;
    end else if (frfu_ffsr_fb_cfg_cmd[7:0] == 8'h02) begin
      if ( bl_din_sel_cs == 1'b0 )	// Write
	begin
        fcb_bl_din[31:0]   = wff_rdata[31:0];
        fcb_din_slc_tb_int = 'b0;
        fcb_din_int_l_only = 'b0;
        fcb_din_int_r_only = 'b0;
      end
      else				// Read
	begin
        fcb_bl_din[31:0]   = 'b0;
        fcb_din_slc_tb_int = 'b0;
        fcb_din_int_l_only = 'b0;
        fcb_din_int_r_only = 'b0;
      end
    end else begin
      fcb_bl_din[31:0]   = 'b0;
      fcb_din_slc_tb_int = wff_rdata[2];
      fcb_din_int_l_only = wff_rdata[1];
      fcb_din_int_r_only = wff_rdata[0];
    end
  end

  assign fcb_apbm_pwdata = (fcb_apbm_ramfifo_sel == 1'b1) ? wff_rdata[17:0] : 'b0;

  always_comb begin
    if (fcb_apbm_ramfifo_sel == 1'b1) begin
      if (PAR_RAMFIFO_CFG[ramfifo_index_cs[3:0]] == 1'b1) begin
        rff_wdata = {14'b0, fcb_apbm_prdata_1[17:0]};
      end else begin
        rff_wdata = {14'b0, fcb_apbm_prdata_0[17:0]};
      end
    end else begin
      rff_wdata = fcb_bl_dout;
    end
  end
  //----------------------------------------------------------------//
  //-- FIFO Component 						--//
  //----------------------------------------------------------------//
  //--------------------------------------------------------//
  //-- qf_sff Instance 					--//
  //-- rff -- 2 Entries					--//
  //--------------------------------------------------------//
  qf_sff #(
      .PAR_FIFO_DATA_WIDTH(32),
      .PAR_FIFO_DEPTH_BITS(1)
  ) qf_sff_INST_0  // RFF
  (
      //------------------------------------------------------------//
      //-- INPUT	                                                --//
      //------------------------------------------------------------//
      .fifo_clk			(fcb_sys_clk	) ,
      .fifo_rst_n			(fcb_sys_rst_n	) ,
      .fifo_rd_en			(frfu_ffsr_rfifo_rd_en ) ,
      .fifo_wr_data			(rff_wdata) ,
      .fifo_wr_en			(rff_wr_en) ,
      //------------------------------------------------------------//
      //-- OUTPUT	                                                --//
      //------------------------------------------------------------//
      .fifo_empty_flag		(rff_empty)  ,
      .fifo_empty_p1_flag		(ffsr_frfu_rfifo_empty_p1)  ,
      .fifo_full_flag			(rff_full)  ,
      .fifo_full_m1_flag		()  ,
      .fifo_rd_data			(ffsr_frfu_rfifo_rdata)
  );
  //--------------------------------------------------------//
  //-- qf_sff Instance                                    --//
  //-- wff -- 4 Entries                                   --//
  //--------------------------------------------------------//
  logic DEBUG;
  assign DEBUG = (frfu_ffsr_wfifo_wr_en == 1'b1 && ffsr_frfu_wfifo_full == 1'b1) ? 1'b1 : 1'b0;

  qf_sff #(
      .PAR_FIFO_DATA_WIDTH(32),
      .PAR_FIFO_DEPTH_BITS(2)
  ) qf_sff_INST_1  // WFF
  (
      //------------------------------------------------------------//
      //-- INPUT                                                  --//
      //------------------------------------------------------------//
      .fifo_clk          (fcb_sys_clk),
      .fifo_rst_n        (fcb_sys_rst_n),
      .fifo_rd_en        (wff_rd_en),
      .fifo_wr_data      (frfu_ffsr_wfifo_wdata),
      .fifo_wr_en        (frfu_ffsr_wfifo_wr_en),
      //------------------------------------------------------------//
      //-- OUTPUT                                                 --//
      //------------------------------------------------------------//
      .fifo_empty_flag   (wff_empty),
      .fifo_empty_p1_flag(),
      .fifo_full_flag    (ffsr_frfu_wfifo_full),
      .fifo_full_m1_flag (ffsr_frfu_wfifo_full_m1),
      .fifo_rd_data      (wff_rdata)
  );

  //----------------------------------------------------------------//
  //-- Internal 							--//
  //----------------------------------------------------------------//
  assign frfu_ffsr_ram_cfg = {frfu_ffsr_ram_cfg_1, frfu_ffsr_ram_cfg_0};

  //------------------------------------------------------------------------//
  //-- Timer, 1 base                                                      --//
  //------------------------------------------------------------------------//
  assign fsr_timer_timeout = (fsr_timer_cs == 8'h01) ? 1'b1 : 1'b0;

  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      fsr_timer_cs <= #PAR_DLY 8'h00;
    end else begin
      fsr_timer_cs <= #PAR_DLY fsr_timer_ns;
    end
  end

  always_comb begin
    if (fsr_timer_kickoff == 1'b1) begin
      fsr_timer_ns = fsr_timer_ini_value;
    end else if (fsr_timer_cs == 8'h00) begin
      fsr_timer_ns = fsr_timer_cs;
    end else begin
      fsr_timer_ns = fsr_timer_cs - 1'b1;
    end
  end

  //------------------------------------------------------------------------//
  //-- STATE                                                              --//
  //------------------------------------------------------------------------//
  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      fcb_blclk_cs            <= #PAR_DLY 'b0;
      fcb_re_cs               <= #PAR_DLY 'b0;
      fcb_we_cs               <= #PAR_DLY 'b0;
      fcb_we_int_cs           <= #PAR_DLY 'b0;
      //fcb_pchg_b_cs 			<= #PAR_DLY 1'b1 ; JC
      fcb_pchg_b_cs           <= #PAR_DLY 1'b0;
      fcb_cload_din_sel_cs    <= #PAR_DLY 'b0;
      fcb_bl_pwrgate_cs       <= #PAR_DLY 'b0;
      fcb_wlclk_cs            <= #PAR_DLY 'b0;
      fcb_wl_resetb_cs        <= #PAR_DLY 'b1;
      fcb_wl_en_cs            <= #PAR_DLY 'b0;
      fcb_wl_sel_cs           <= #PAR_DLY 'b0;
      fcb_wl_pwrgate_cs       <= #PAR_DLY 'b0;
      fcb_wl_int_din_sel_cs   <= #PAR_DLY 'b0;
      //fcb_prog_cs 			<= #PAR_DLY 16'b1 ; 
      //fcb_prog_ifx_cs 		<= #PAR_DLY 1'b1 ; 
      fcb_wl_sel_tb_int_cs    <= #PAR_DLY 'b0;
      fcb_apbm_paddr_cs       <= #PAR_DLY 'b0;
      fcb_apbm_psel_cs        <= #PAR_DLY 'b0;
      fcb_apbm_penable_cs     <= #PAR_DLY 'b0;
      fcb_apbm_pwrite_cs      <= #PAR_DLY 'b0;
      //fcb_apbm_pwdata_cs 		<= #PAR_DLY 'b0 ; 
      fcb_apbm_ramfifo_sel_cs <= #PAR_DLY 'b0;
      //fcb_rst_cs 			<= #PAR_DLY 16'h0000 ; 
      fcb_rst_cs              <= #PAR_DLY 1'b0;
      fcb_tb_rst_cs           <= #PAR_DLY 1'b0;
      fcb_lr_rst_cs           <= #PAR_DLY 1'b0;
      fcb_iso_rst_cs          <= #PAR_DLY 1'b0;
      //fcb_rst_cs 			<= #PAR_DLY 16'hffff ; 	// 20170620 JC
      //fcb_tb_rst_cs 			<= #PAR_DLY 1'b1 ; 	// 20170620 JC
      //fcb_lr_rst_cs 			<= #PAR_DLY 1'b1 ; 	// 20170620 JC
      //fcb_iso_rst_cs 			<= #PAR_DLY 1'b1 ; 	// 20170620 JC
      frfu_ffsr_bl_cnt_cs     <= #PAR_DLY 'b0;
      frfu_ffsr_wl_cnt_cs     <= #PAR_DLY 'b0;
      frfu_ffsr_col_cnt_cs    <= #PAR_DLY 'b0;
      ramfifo_index_cs        <= #PAR_DLY 'b0;
      fcb_apbm_mclk_cs        <= #PAR_DLY 'b0;
      fcb_wl_din_cs           <= #PAR_DLY 'b0;
    end else begin
      fcb_blclk_cs            <= #PAR_DLY fcb_blclk_ns;
      fcb_re_cs               <= #PAR_DLY fcb_re_ns;
      fcb_we_cs               <= #PAR_DLY fcb_we_ns;
      fcb_we_int_cs           <= #PAR_DLY fcb_we_int_ns;
      fcb_pchg_b_cs           <= #PAR_DLY fcb_pchg_b_ns;
      fcb_cload_din_sel_cs    <= #PAR_DLY fcb_cload_din_sel_ns;
      fcb_bl_pwrgate_cs       <= #PAR_DLY fcb_bl_pwrgate_ns;
      fcb_wlclk_cs            <= #PAR_DLY fcb_wlclk_ns;
      fcb_wl_resetb_cs        <= #PAR_DLY fcb_wl_resetb_ns;
      fcb_wl_en_cs            <= #PAR_DLY fcb_wl_en_ns;
      fcb_wl_sel_cs           <= #PAR_DLY fcb_wl_sel_ns;
      fcb_wl_pwrgate_cs       <= #PAR_DLY fcb_wl_pwrgate_ns;
      fcb_wl_din_cs           <= #PAR_DLY fcb_wl_din_ns;
      fcb_wl_int_din_sel_cs   <= #PAR_DLY fcb_wl_int_din_sel_ns;
      //fcb_prog_cs                       <= #PAR_DLY fcb_prog_ns                 ;
      //fcb_prog_ifx_cs                   <= #PAR_DLY fcb_prog_ifx_ns             ; 
      fcb_wl_sel_tb_int_cs    <= #PAR_DLY fcb_wl_sel_tb_int_ns;
      fcb_apbm_paddr_cs       <= #PAR_DLY fcb_apbm_paddr_ns;
      fcb_apbm_psel_cs        <= #PAR_DLY fcb_apbm_psel_ns;
      fcb_apbm_penable_cs     <= #PAR_DLY fcb_apbm_penable_ns;
      fcb_apbm_pwrite_cs      <= #PAR_DLY fcb_apbm_pwrite_ns;
      //fcb_apbm_pwdata_cs                <= #PAR_DLY fcb_apbm_pwdata_ns          ;
      fcb_apbm_ramfifo_sel_cs <= #PAR_DLY fcb_apbm_ramfifo_sel_ns;
      fcb_rst_cs              <= #PAR_DLY fcb_rst_ns;
      fcb_tb_rst_cs           <= #PAR_DLY fcb_tb_rst_ns;
      fcb_lr_rst_cs           <= #PAR_DLY fcb_lr_rst_ns;
      fcb_iso_rst_cs          <= #PAR_DLY fcb_iso_rst_ns;
      frfu_ffsr_bl_cnt_cs     <= #PAR_DLY frfu_ffsr_bl_cnt_ns;
      frfu_ffsr_wl_cnt_cs     <= #PAR_DLY frfu_ffsr_wl_cnt_ns;
      frfu_ffsr_col_cnt_cs    <= #PAR_DLY frfu_ffsr_col_cnt_ns;
      ramfifo_index_cs        <= #PAR_DLY ramfifo_index_ns;
      fcb_apbm_mclk_cs        <= #PAR_DLY fcb_apbm_mclk_ns;
    end
  end
  //------------------------------------------------------------------------//
  //-- STATE                                                              --//
  //------------------------------------------------------------------------//
  always_ff @(posedge fcb_sys_clk or negedge fcb_sys_rst_n) begin
    if (fcb_sys_rst_n == 1'b0) begin
      fsr_stm_cs <= #PAR_DLY MAIN_S0;
    end else begin
      fsr_stm_cs <= #PAR_DLY fsr_stm_ns;
    end
  end

  always_comb begin
    fsr_stm_ns                   = fsr_stm_cs;

    fcb_blclk_ns                 = fcb_blclk_cs;
    fcb_re_ns                    = fcb_re_cs;
    fcb_we_ns                    = fcb_we_cs;
    fcb_we_int_ns                = fcb_we_int_cs;
    fcb_pchg_b_ns                = fcb_pchg_b_cs;
    fcb_cload_din_sel_ns         = fcb_cload_din_sel_cs;
    fcb_bl_pwrgate_ns            = fcb_bl_pwrgate_cs;
    fcb_wlclk_ns                 = fcb_wlclk_cs;
    fcb_wl_resetb_ns             = fcb_wl_resetb_cs;
    fcb_wl_en_ns                 = fcb_wl_en_cs;
    fcb_wl_sel_ns                = fcb_wl_sel_cs;
    fcb_wl_pwrgate_ns            = fcb_wl_pwrgate_cs;
    fcb_wl_din_ns                = fcb_wl_din_cs;
    fcb_wl_int_din_sel_ns        = fcb_wl_int_din_sel_cs;
    //fcb_prog_ns                       = fcb_prog_cs                 ;
    //fcb_prog_ifx_ns                   = fcb_prog_ifx_cs             ;
    fcb_wl_sel_tb_int_ns         = fcb_wl_sel_tb_int_cs;
    fcb_apbm_paddr_ns            = fcb_apbm_paddr_cs;
    fcb_apbm_psel_ns             = fcb_apbm_psel_cs;
    fcb_apbm_penable_ns          = fcb_apbm_penable_cs;
    fcb_apbm_pwrite_ns           = fcb_apbm_pwrite_cs;
    //fcb_apbm_pwdata_ns                = fcb_apbm_pwdata_cs          ;
    fcb_apbm_ramfifo_sel_ns      = fcb_apbm_ramfifo_sel_cs;
    fcb_rst_ns                   = fcb_rst_cs;
    fcb_tb_rst_ns                = fcb_tb_rst_cs;
    fcb_lr_rst_ns                = fcb_lr_rst_cs;
    fcb_iso_rst_ns               = fcb_iso_rst_cs;
    frfu_ffsr_bl_cnt_ns          = frfu_ffsr_bl_cnt_cs;
    frfu_ffsr_wl_cnt_ns          = frfu_ffsr_wl_cnt_cs;
    frfu_ffsr_col_cnt_ns         = frfu_ffsr_col_cnt_cs;
    ramfifo_index_ns             = ramfifo_index_cs;
    fcb_apbm_mclk_ns             = 1'b0;
    //--------------------------------------------------------//
    //-- Comb 						--//
    //--------------------------------------------------------//
    ffsr_frfu_clr_fb_cfg_kickoff = 1'b0;
    fsr_timer_kickoff            = 1'b0;
    fsr_timer_ini_value          = 8'h00;
    wff_rd_en                    = 1'b0;
    rff_wr_en                    = 1'b0;

    unique case (fsr_stm_cs)
      //----------------------------------------------------------------//
      //-- MAIN State                                                 --//
      //----------------------------------------------------------------//
      MAIN_S0: begin
        if (frfu_ffsr_fb_cfg_kickoff == 1'b1) begin
          fsr_stm_ns = MAIN_S1;
        end
      end
      MAIN_S1: begin
        if (frfu_ffsr_fb_cfg_cmd[7:0] == 8'h00 ||  // Normal
            frfu_ffsr_fb_cfg_cmd[7:0] == 8'h01 ||  // Normal
            frfu_ffsr_fb_cfg_cmd[7:0] == 8'h02 ||  // Normal
            frfu_ffsr_fb_cfg_cmd[7:0] == 8'h10 ||  // Quad Cfg
            frfu_ffsr_fb_cfg_cmd[7:0] == 8'h11 ||  // Quad Normal
            frfu_ffsr_fb_cfg_cmd[7:0] == 8'h22  )	// TB 
          begin
          fsr_stm_ns = NOR_S00;
        end else if (frfu_ffsr_fb_cfg_cmd[7:0] == 8'h20 || frfu_ffsr_fb_cfg_cmd[7:0] == 8'h21) begin
          fsr_stm_ns = SLC_S00;
        end
        else if ( frfu_ffsr_fb_cfg_cmd[7:0] == 8'h23  ) // This Mode Removed
          begin
          fsr_stm_ns = SCS_S00;
        end else begin
          fsr_stm_ns = FCR_S00;
        end
      end
      //----------------------------------------------------------------//
      //-- Normal, Quad Cfg, T/B IFX Cfg	         	        --//
      //----------------------------------------------------------------//
      NOR_S00: begin
        fsr_stm_ns           = NOR_S01;
        fcb_bl_pwrgate_ns    = {frfu_bl_pw_cfg_1, frfu_bl_pw_cfg_0};
        fcb_wl_pwrgate_ns    = {frfu_wl_pw_cfg};
        fcb_wl_sel_ns        = {frfu_bl_pw_cfg_1, frfu_bl_pw_cfg_0};
        //fcb_prog_ns        	= 16'hffff  ;
        frfu_ffsr_bl_cnt_ns  = 'b0;
        frfu_ffsr_wl_cnt_ns  = 'b0;
        frfu_ffsr_col_cnt_ns = 'b0;
        if ( frfu_ffsr_fb_cfg_cmd[7:0] == 8'h00 ||
             frfu_ffsr_fb_cfg_cmd[7:0] == 8'h01 ||
             frfu_ffsr_fb_cfg_cmd[7:0] == 8'h02 ||
             frfu_ffsr_fb_cfg_cmd[7:0] == 8'h22 )
	  begin
          fcb_wl_sel_tb_int_ns = 1'b1;
          //fcb_prog_ifx_ns     	= 1'b1 ;
        end
        if (frfu_ffsr_fb_cfg_cmd[7:0] == 8'h22) begin
          fcb_cload_din_sel_ns  = 1'b1;
          fcb_wl_int_din_sel_ns = 1'b1;
        end
      end
      NOR_S01: begin
        fsr_stm_ns = NOR_S02;
      end
      NOR_S02: begin
        fsr_stm_ns = NOR_S03;
      end
      NOR_S03: begin
        fsr_stm_ns          = NOR_S04;
        fsr_timer_kickoff   = 1'b1;
        fsr_timer_ini_value = 8'h80;  // 128 Cycles
        fcb_wl_resetb_ns    = 1'b0;
        fcb_rst_ns          = fcb_bl_pwrgate_cs;
        if ( frfu_ffsr_fb_cfg_cmd[7:0] == 8'h00 ||
             frfu_ffsr_fb_cfg_cmd[7:0] == 8'h01 ||
             frfu_ffsr_fb_cfg_cmd[7:0] == 8'h02 )
          begin
          fcb_iso_rst_ns = 1'b1;
          fcb_tb_rst_ns  = 1'b1;
          fcb_lr_rst_ns  = 1'b1;
        end else if (frfu_ffsr_fb_cfg_cmd[7:0] == 8'h22) begin
          fcb_tb_rst_ns = 1'b1;
        end
      end
      NOR_S04: begin
        if (fsr_timer_timeout == 1'b0) begin
          fsr_stm_ns = NOR_S04;
        end else begin
          fsr_stm_ns       = NOR_S05;
          fcb_wl_resetb_ns = 1'b1;
          fcb_rst_ns       = 'b0;
          fcb_iso_rst_ns   = 1'b0;
          fcb_tb_rst_ns    = 1'b0;
          fcb_lr_rst_ns    = 1'b0;
        end
      end
      NOR_S05: begin
        fsr_stm_ns = NOR_S06;
      end
      NOR_S06: begin
        fsr_stm_ns = NOR_S06A;
      end

      NOR_S06A: begin
        if (wff_empty == 1'b0) begin
          frfu_ffsr_bl_cnt_ns = frfu_ffsr_bl_cnt_cs + 1'b1;
          if (frfu_ffsr_blclk_sut[1:0] == 2'b00) begin
            fcb_blclk_ns = 1'b1;
            //------------------------------------------------//
            //-- frfu_ffsr_wlblclk_cfg                      --//
            //-- 2'b00 : 1 Cycle                            --//
            //-- 2'b01 : 2 Cycles                           --//
            //-- Others: 3 Cycles                           --//
            //------------------------------------------------//
            if (frfu_ffsr_wlblclk_cfg == 2'b00) begin
              fsr_stm_ns = NOR_S08;
            end else if (frfu_ffsr_wlblclk_cfg == 2'b01) begin
              fsr_stm_ns = NOR_S07B;
            end else begin
              fsr_stm_ns = NOR_S07A;
            end
          end else if (frfu_ffsr_blclk_sut[1:0] == 2'b01) begin
            fsr_stm_ns = NOR_S07;
          end else begin
            fsr_stm_ns = NOR_S06B;
          end
        end else begin
          fsr_stm_ns = fsr_stm_cs;
        end
      end

      NOR_S06B: begin
        fsr_stm_ns = NOR_S07;
      end

      NOR_S07: begin
        fcb_blclk_ns = 1'b1;
        //------------------------------------------------//
        //-- frfu_ffsr_wlblclk_cfg                      --//
        //-- 2'b00 : 1 Cycle                            --//
        //-- 2'b01 : 2 Cycles                           --//
        //-- Others: 3 Cycles                           --//
        //------------------------------------------------//
        if (frfu_ffsr_wlblclk_cfg == 2'b00) begin
          fsr_stm_ns = NOR_S08;
        end else if (frfu_ffsr_wlblclk_cfg == 2'b01) begin
          fsr_stm_ns = NOR_S07B;
        end else begin
          fsr_stm_ns = NOR_S07A;
        end
      end

      NOR_S07A :		//JC
      begin
        fcb_blclk_ns = 1'b0;
        fsr_stm_ns   = NOR_S07B;
      end
      NOR_S07B :		//JC
      begin
        fcb_blclk_ns = 1'b0;
        fsr_stm_ns   = NOR_S08;
      end

      NOR_S08: begin
        fcb_blclk_ns = 1'b0;
        wff_rd_en    = 1'b1;
        if (frfu_ffsr_bl_cnt_cs == {frfu_ffsr_bl_cnt_h, frfu_ffsr_bl_cnt_l}) begin
          if (frfu_ffsr_wlclk_sut == 2'b00) begin
            fsr_stm_ns = NOR_S09;
          end else if (frfu_ffsr_wlclk_sut == 2'b01) begin
            fsr_stm_ns = NOR_S08B;
          end else begin
            fsr_stm_ns = NOR_S08A;
          end

          frfu_ffsr_bl_cnt_ns = 'b0;
          frfu_ffsr_wl_cnt_ns = frfu_ffsr_wl_cnt_cs + 1'b1;
          if (frfu_ffsr_wl_cnt_cs == 'b0) begin
            if( frfu_ffsr_fb_cfg_cmd[7:0] == 8'h22 ) // TB
		  begin
              fcb_wl_din_ns = 6'b0_0_1_1_0_0;
            end else begin
              fcb_wl_din_ns = 6'b1_0_1_0_1_1;
            end
          end else begin
            fcb_wl_din_ns = 6'b0_0_0_0_0_0;
          end
        end else begin
          //fsr_stm_ns 		= NOR_S07 ;
          fsr_stm_ns = NOR_S06A;
        end
      end

      NOR_S08A :		//JC
      begin
        fsr_stm_ns = NOR_S08B;
      end

      NOR_S08B :		//JC
      begin
        fsr_stm_ns = NOR_S09;
      end

      NOR_S09: begin
        fcb_wlclk_ns = 1'b1;
        //------------------------------------------------//
        //-- frfu_ffsr_wlblclk_cfg			--//
        //-- 2'b00 : 1 Cycle				--//
        //-- 2'b01 : 2 Cycles				--//
        //-- Others: 3 Cycles				--//
        //------------------------------------------------//
        if (frfu_ffsr_wlblclk_cfg == 2'b00) begin
          fsr_stm_ns = NOR_S0A;
        end else if (frfu_ffsr_wlblclk_cfg == 2'b01) begin
          fsr_stm_ns = NOR_S09B;
        end else begin
          fsr_stm_ns = NOR_S09A;
        end
      end
      //------------------------------------------------//
      //-- New Added Cycles, JC 01302017		--//
      //------------------------------------------------//
      NOR_S09A: begin
        fcb_wlclk_ns = 1'b0;
        fsr_stm_ns   = NOR_S09B;
      end

      NOR_S09B: begin
        fcb_wlclk_ns = 1'b0;
        fsr_stm_ns   = NOR_S0A;
      end

      NOR_S0A: begin
        fsr_stm_ns        = NOR_S0B;
        fcb_wlclk_ns      = 1'b0;
        fcb_we_ns         = 1'b1;
        //fcb_pchg_b_ns           = 1'b0 ; JC
        fcb_pchg_b_ns     = 1'b1;
        fcb_wl_en_ns      = 1'b1;
        fsr_timer_kickoff = 1'b1;
        if ( frfu_ffsr_fb_cfg_cmd[7:0] == 8'h00 ||
             frfu_ffsr_fb_cfg_cmd[7:0] == 8'h01 ||
             frfu_ffsr_fb_cfg_cmd[7:0] == 8'h02 ||
             frfu_ffsr_fb_cfg_cmd[7:0] == 8'h10 ||	//
            frfu_ffsr_fb_cfg_cmd[7:0] == 8'h11 )	//
          begin
          fcb_we_int_ns = 1'b1;
        end
        if (frfu_ffsr_cfg_wrp_ccnt == 4'b0000 || frfu_ffsr_cfg_wrp_ccnt == 4'b0001) begin
          fsr_timer_ini_value = 8'h02;
        end else begin
          fsr_timer_ini_value = {4'b0, frfu_ffsr_cfg_wrp_ccnt};
        end
      end
      NOR_S0B: begin
        if (fsr_timer_timeout == 1'b0) begin
          fsr_stm_ns = fsr_stm_cs;
        end else begin
          fcb_wl_en_ns      = 1'b0;
          fsr_timer_kickoff = 1'b1;
          if (frfu_ffsr_cfg_wrp_ccnt == 4'b0000 || frfu_ffsr_cfg_wrp_ccnt == 4'b0001) begin
            fsr_timer_ini_value = 8'h02;
          end else begin
            fsr_timer_ini_value = {4'b0, frfu_ffsr_cfg_wrp_ccnt};
          end
          fsr_stm_ns = NOR_S0C;
        end
      end
      NOR_S0C: begin
        if (fsr_timer_timeout == 1'b0) begin
          fsr_stm_ns = fsr_stm_cs;
        end else begin
          fcb_we_ns     = 1'b0;
          fcb_we_int_ns = 1'b0;
          //fcb_pchg_b_ns       = 1'b1 ;	JC
          fcb_pchg_b_ns = 1'b0;
          if (frfu_ffsr_wl_cnt_cs == {frfu_ffsr_wl_cnt_h, frfu_ffsr_wl_cnt_l}) begin
            fsr_stm_ns = NOR_S0D;
          end else begin
            //fsr_stm_ns	= NOR_S07 ;
            fsr_stm_ns = NOR_S06A;
          end
        end
      end
      NOR_S0D: begin
        fsr_stm_ns = NOR_S0E;
      end
      NOR_S0E: begin
        fsr_stm_ns            = NOR_S0F;
        fcb_bl_pwrgate_ns     = 'b0;
        fcb_wl_pwrgate_ns     = 'b0;
        fcb_wl_sel_ns         = 'b0;
        //fcb_prog_ns             =  'b0 ;
        frfu_ffsr_bl_cnt_ns   = 'b0;
        frfu_ffsr_wl_cnt_ns   = 'b0;
        frfu_ffsr_col_cnt_ns  = 'b0;
        //fcb_prog_ifx_ns     	=  'b0 ;
        fcb_cload_din_sel_ns  = 1'b0;
        fcb_wl_sel_tb_int_ns  = 'b0;
        fcb_wl_int_din_sel_ns = 'b0;
      end
      NOR_S0F: begin
        if ( frfu_ffsr_fb_cfg_cmd[7:0] == 8'h00 ||
             frfu_ffsr_fb_cfg_cmd[7:0] == 8'h01 ||
             frfu_ffsr_fb_cfg_cmd[7:0] == 8'h02 )
	  begin
          fsr_stm_ns = ARW_S00;
        end else begin
          fsr_stm_ns = END_S00;
        end
      end
      //----------------------------------------------------------------//
      //-- SLC Column Cfg and L/R IFX Cfg 				--//
      //----------------------------------------------------------------//
      SLC_S00: begin
        fsr_stm_ns           = SLC_S01;
        fcb_bl_pwrgate_ns    = {frfu_bl_pw_cfg_1, frfu_bl_pw_cfg_0};
        fcb_wl_pwrgate_ns    = {frfu_wl_pw_cfg};
        fcb_wl_sel_ns        = {frfu_bl_pw_cfg_1, frfu_bl_pw_cfg_0};
        //fcb_prog_ns        	= 16'hffff  ;
        frfu_ffsr_bl_cnt_ns  = 'b0;
        frfu_ffsr_wl_cnt_ns  = 'b0;
        frfu_ffsr_col_cnt_ns = 'b0;
        fcb_cload_din_sel_ns = 1'b1;
        if (frfu_ffsr_fb_cfg_cmd[7:0] == 8'h20) begin
          //fcb_prog_ifx_ns     	= 1'b0 ;
        end else if (frfu_ffsr_fb_cfg_cmd[7:0] == 8'h21) begin
          //fcb_prog_ifx_ns     	= 1'b1 ;

          //fcb_prog_ifx_ns     	= 1'b0 ;
        end
      end
      SLC_S01: begin
        fsr_stm_ns = SLC_S02;
      end
      SLC_S02: begin
        fsr_stm_ns = SLC_S03;
      end
      SLC_S03: begin
        fsr_stm_ns 		= SLC_S04 ;
        fsr_timer_kickoff 	= 1'b1 ;
        fsr_timer_ini_value 	= 8'h80 ;	// 128 Cycles
        fcb_wl_resetb_ns   	= 1'b0  ;
        if (frfu_ffsr_fb_cfg_cmd[7:0] == 8'h20) begin
          //fcb_rst_ns		= fcb_bl_pwrgate_cs ;
        end else if (frfu_ffsr_fb_cfg_cmd[7:0] == 8'h21) begin
          fcb_lr_rst_ns = 1'b1;
        end
      end
      SLC_S04: begin
        if (fsr_timer_timeout == 1'b0) begin
          fsr_stm_ns = SLC_S04;
        end else begin
          fsr_stm_ns       = SLC_S05;
          fcb_wl_resetb_ns = 1'b1;
          fcb_rst_ns       = 'b0;
          fcb_tb_rst_ns    = 1'b0;
          fcb_lr_rst_ns    = 1'b0;
        end
      end
      SLC_S05: begin
        fsr_stm_ns = SLC_S06;
      end
      SLC_S06: begin
        fsr_stm_ns = SLC_S06A;
      end

      SLC_S06A: begin
        if (wff_empty == 1'b0) begin
          frfu_ffsr_bl_cnt_ns = frfu_ffsr_bl_cnt_cs + 1'b1;
          if (frfu_ffsr_blclk_sut[1:0] == 2'b00) begin
            fcb_blclk_ns = 1'b1;
            //------------------------------------------------//
            //-- frfu_ffsr_wlblclk_cfg                      --//
            //-- 2'b00 : 1 Cycle                            --//
            //-- 2'b01 : 2 Cycles                           --//
            //-- Others: 3 Cycles                           --//
            //------------------------------------------------//
            if (frfu_ffsr_wlblclk_cfg == 2'b00) begin
              fsr_stm_ns = SLC_S08;
            end else if (frfu_ffsr_wlblclk_cfg == 2'b01) begin
              fsr_stm_ns = SLC_S07B;
            end else begin
              fsr_stm_ns = SLC_S07A;
            end
          end else if (frfu_ffsr_blclk_sut[1:0] == 2'b01) begin
            fsr_stm_ns = SLC_S07;
          end else begin
            fsr_stm_ns = SLC_S06B;
          end
        end else begin
          fsr_stm_ns = fsr_stm_cs;
        end
      end

      SLC_S06B: begin
        fsr_stm_ns = SLC_S07;
      end

      SLC_S07 :	//JC_TODO
      begin
        fcb_blclk_ns = 1'b1;
        //------------------------------------------------//
        //-- frfu_ffsr_wlblclk_cfg                      --//
        //-- 2'b00 : 1 Cycle                            --//
        //-- 2'b01 : 2 Cycles                           --//
        //-- Others: 3 Cycles                           --//
        //------------------------------------------------//
        if (frfu_ffsr_wlblclk_cfg == 2'b00) begin
          fsr_stm_ns = SLC_S08;
        end else if (frfu_ffsr_wlblclk_cfg == 2'b01) begin
          fsr_stm_ns = SLC_S07B;
        end else begin
          fsr_stm_ns = SLC_S07A;
        end
      end

      SLC_S07A :	//JC_TODO
      begin
        fcb_blclk_ns = 1'b0;
        fsr_stm_ns   = SLC_S07B;
      end
      SLC_S07B :	//JC_TODO
      begin
        fcb_blclk_ns = 1'b0;
        fsr_stm_ns   = SLC_S08;
      end

      SLC_S08: begin
        fcb_blclk_ns = 1'b0;
        wff_rd_en    = 1'b1;
        if (frfu_ffsr_bl_cnt_cs == {frfu_ffsr_bl_cnt_h, frfu_ffsr_bl_cnt_l}) begin
          if (frfu_ffsr_wlclk_sut == 2'b00) begin
            fsr_stm_ns = SLC_S09;
          end else if (frfu_ffsr_wlclk_sut == 2'b01) begin
            fsr_stm_ns = SLC_S08B;
          end else begin
            fsr_stm_ns = SLC_S08A;
          end
          frfu_ffsr_bl_cnt_ns = 'b0;
          frfu_ffsr_wl_cnt_ns = frfu_ffsr_wl_cnt_cs + 1'b1;
          if (frfu_ffsr_wl_cnt_cs == 'b0) begin
            fcb_wl_din_ns = 6'b1_1_0_0_1_1;
          end else begin
            fcb_wl_din_ns = 6'b0_0_0_0_0_0;
          end
        end else begin
          //fsr_stm_ns 	= SLC_S07 ;
          fsr_stm_ns = SLC_S06A;
        end
      end

      SLC_S08A :		//JC
      begin
        fsr_stm_ns = SLC_S08B;
      end

      SLC_S08B :		//JC
      begin
        fsr_stm_ns = SLC_S09;
      end

      SLC_S09: begin
        fcb_wlclk_ns = 1'b1;
        //------------------------------------------------//
        //-- frfu_ffsr_wlblclk_cfg                      --//
        //-- 2'b00 : 1 Cycle                            --//
        //-- 2'b01 : 2 Cycles                           --//
        //-- Others: 3 Cycles                           --//
        //------------------------------------------------//
        if (frfu_ffsr_wlblclk_cfg == 2'b00) begin
          fsr_stm_ns = SLC_S0A;
        end else if (frfu_ffsr_wlblclk_cfg == 2'b01) begin
          fsr_stm_ns = SLC_S09B;
        end else begin
          fsr_stm_ns = SLC_S09A;
        end
      end
      //------------------------------------------------//
      //-- New Added Cycles, JC 01302017		--//
      //------------------------------------------------//
      SLC_S09A: begin
        fcb_wlclk_ns = 1'b0;
        fsr_stm_ns   = SLC_S09B;
      end
      SLC_S09B: begin
        fcb_wlclk_ns = 1'b0;
        fsr_stm_ns   = SLC_S0A;
      end

      SLC_S0A: begin
        fsr_stm_ns        = SLC_S0B;
        fcb_wlclk_ns      = 1'b0;
        //fcb_we_ns		= 1'b1 ;
        //fcb_pchg_b_ns           = 1'b0 ;	JC
        fcb_pchg_b_ns     = 1'b1;
        fsr_timer_kickoff = 1'b1;
        fcb_wl_en_ns      = 1'b1;
        fcb_we_int_ns     = 1'b1;  //
        //if ( frfu_ffsr_fb_cfg_cmd[7:0] == 8'h20 )
        if ( frfu_ffsr_fb_cfg_cmd[7:0] == 8'h20 )	// L/C
          begin
          fcb_we_ns = 1'b1;
        end
	else						// Column,T/B
          begin
          fcb_we_ns = 1'b0;
        end
        if (frfu_ffsr_cfg_wrp_ccnt == 4'b0000 || frfu_ffsr_cfg_wrp_ccnt == 4'b0001) begin
          fsr_timer_ini_value = 8'h02;
        end else begin
          fsr_timer_ini_value = {4'b0, frfu_ffsr_cfg_wrp_ccnt};
        end
      end
      SLC_S0B: begin
        if (fsr_timer_timeout == 1'b0) begin
          fsr_stm_ns = fsr_stm_cs;
        end else begin
          fcb_wl_en_ns      = 1'b0;
          fsr_timer_kickoff = 1'b1;
          if (frfu_ffsr_cfg_wrp_ccnt == 4'b0000 || frfu_ffsr_cfg_wrp_ccnt == 4'b0001) begin
            fsr_timer_ini_value = 8'h02;
          end else begin
            fsr_timer_ini_value = {4'b0, frfu_ffsr_cfg_wrp_ccnt};
          end
          fsr_stm_ns = SLC_S0C;
        end
      end
      SLC_S0C: begin
        if (fsr_timer_timeout == 1'b0) begin
          fsr_stm_ns = fsr_stm_cs;
        end else begin
          fcb_we_ns     = 1'b0;
          fcb_we_int_ns = 1'b0;
          //fcb_pchg_b_ns       = 1'b1 ; JC
          fcb_pchg_b_ns = 1'b0;
          fsr_stm_ns    = SLC_S0D;
        end
      end
      SLC_S0D: begin
        if (frfu_ffsr_col_cnt_cs == (frfu_ffsr_col_cnt - 1'b1)) begin
          frfu_ffsr_col_cnt_ns = 'b0;  //JC
          if (frfu_ffsr_wl_cnt_cs == {frfu_ffsr_wl_cnt_h, frfu_ffsr_wl_cnt_l}) begin
            fsr_stm_ns = SLC_S0E;  // JUMP To Finish  
          end else begin
            fsr_stm_ns = SLC_S07;  // Start from BitLine
            fsr_stm_ns = SLC_S06A;  // Start from BitLine
          end
        end else begin
          frfu_ffsr_col_cnt_ns = frfu_ffsr_col_cnt_cs + 1'b1;
          //fsr_stm_ns		= SLC_S0DA ;
          fsr_stm_ns = SLC_S0A;
        end
      end
      //SLC_S0DA :
      //  begin
      //    fsr_stm_ns		= SLC_S0A ;
      //  end
      SLC_S0E: begin
        fsr_stm_ns            = SLC_S0F;
        fcb_bl_pwrgate_ns     = 'b0;
        fcb_wl_pwrgate_ns     = 'b0;
        fcb_wl_sel_ns         = 'b0;
        //fcb_prog_ns             =  'b0 ;
        frfu_ffsr_bl_cnt_ns   = 'b0;
        frfu_ffsr_wl_cnt_ns   = 'b0;
        frfu_ffsr_col_cnt_ns  = 'b0;
        //fcb_prog_ifx_ns     	=  'b0 ;
        fcb_cload_din_sel_ns  = 1'b0;
        fcb_wl_sel_tb_int_ns  = 'b0;
        fcb_wl_int_din_sel_ns = 'b0;
      end
      SLC_S0F: begin
        fsr_stm_ns = END_S00;
      end
      //----------------------------------------------------------------//
      //-- SLC Column Shifting					--//
      //----------------------------------------------------------------//
      SCS_S00: begin
        fsr_stm_ns = SCS_S01;
        fcb_bl_pwrgate_ns = {frfu_bl_pw_cfg_1, frfu_bl_pw_cfg_0};
        //fcb_prog_ns        	= { frfu_bl_pw_cfg_1, frfu_bl_pw_cfg_0 } ;
        frfu_ffsr_bl_cnt_ns = 'b0;
        frfu_ffsr_wl_cnt_ns = 'b0;
        frfu_ffsr_col_cnt_ns = 'b0;
        fcb_we_ns = 1'b1;
        fcb_we_int_ns = 1'b1;
        fcb_cload_din_sel_ns = 1'b1;
      end
      SCS_S01: begin
        fsr_stm_ns = SCS_S02;
      end
      SCS_S02: begin
        fsr_stm_ns = SCS_S03;
      end
      SCS_S03: begin
        if (wff_empty == 1'b0) begin
          frfu_ffsr_bl_cnt_ns = frfu_ffsr_bl_cnt_cs + 1'b1;
          fcb_wlclk_ns        = 1'b1;
          //------------------------------------------------//
          //-- frfu_ffsr_wlblclk_cfg                      --//
          //-- 2'b00 : 1 Cycle                            --//
          //-- 2'b01 : 2 Cycles                           --//
          //-- Others: 3 Cycles                           --//
          //------------------------------------------------//
          if (frfu_ffsr_wlblclk_cfg == 2'b00) begin
            fsr_stm_ns = SCS_S04;
          end else if (frfu_ffsr_wlblclk_cfg == 2'b01) begin
            fsr_stm_ns = SCS_S03B;
          end else begin
            fsr_stm_ns = SCS_S03A;
          end
        end else begin
          fsr_stm_ns = fsr_stm_cs;
        end
      end
      //------------------------------------------------//
      //-- New Added Cycles, JC 01302017		--//
      //------------------------------------------------//
      SCS_S03A: begin
        fcb_wlclk_ns = 1'b0;
        fsr_stm_ns   = SCS_S03B;
      end
      SCS_S03B: begin
        fcb_wlclk_ns = 1'b0;
        fsr_stm_ns   = SCS_S04;
      end


      SCS_S04: begin
        fcb_wlclk_ns = 1'b0;
        wff_rd_en    = 1'b1;
        if (frfu_ffsr_bl_cnt_cs == {frfu_ffsr_bl_cnt_h, frfu_ffsr_bl_cnt_l}) begin
          fsr_stm_ns = SCS_S05;
        end else begin
          fsr_stm_ns = SCS_S03;
        end
      end
      SCS_S05: begin
        fsr_stm_ns = SCS_S06;
      end
      SCS_S06: begin
        fsr_stm_ns = SCS_S07;
      end
      SCS_S07: begin
        fsr_stm_ns            = SCS_S08;
        fcb_bl_pwrgate_ns     = 'b0;
        fcb_wl_pwrgate_ns     = 'b0;
        fcb_wl_sel_ns         = 'b0;
        //fcb_prog_ns             =  'b0 ;
        frfu_ffsr_bl_cnt_ns   = 'b0;
        frfu_ffsr_wl_cnt_ns   = 'b0;
        frfu_ffsr_col_cnt_ns  = 'b0;
        //fcb_prog_ifx_ns     	=  'b0 ;
        fcb_cload_din_sel_ns  = 1'b0;
        fcb_wl_sel_tb_int_ns  = 'b0;
        fcb_wl_int_din_sel_ns = 'b0;
      end
      SCS_S08: begin
        fsr_stm_ns = END_S00;
      end
      //----------------------------------------------------------------//
      //-- Normal Cfg Read						--//
      //----------------------------------------------------------------//
      FCR_S00: begin
        fsr_stm_ns           = FCR_S01;
        fcb_bl_pwrgate_ns    = {frfu_bl_pw_cfg_1, frfu_bl_pw_cfg_0};
        fcb_wl_pwrgate_ns    = {frfu_wl_pw_cfg};
        fcb_wl_sel_ns        = {frfu_bl_pw_cfg_1, frfu_bl_pw_cfg_0};
        fcb_wl_sel_tb_int_ns = 1'b1;
        //fcb_prog_ns        	= { frfu_bl_pw_cfg_1, frfu_bl_pw_cfg_0 }  ;
        frfu_ffsr_bl_cnt_ns  = 'b0;
        frfu_ffsr_wl_cnt_ns  = 'b0;
        frfu_ffsr_col_cnt_ns = 'b0;
      end
      FCR_S01: begin
        fsr_stm_ns = FCR_S02;
      end
      FCR_S02: begin
        fsr_stm_ns = FCR_S03;
      end
      FCR_S03: begin
        fsr_stm_ns 		= FCR_S04 ;
        fsr_timer_kickoff 	= 1'b1 ;
        fsr_timer_ini_value 	= 8'h80 ;	// 128 Cycles
        fcb_wl_resetb_ns   	= 1'b0  ;
        //fcb_rst_ns         	= fcb_bl_pwrgate_cs ; // NEW ADDED 20170710 20180411
      end
      FCR_S04 :		// Wait until FIFO is NOT full, 11-22
      begin
        if (fsr_timer_timeout == 1'b0) begin
          fsr_stm_ns = FCR_S04;
        end else begin
          fsr_stm_ns       = FCR_S05;
          fcb_wl_resetb_ns = 1'b1;
          fcb_rst_ns       = 'b0;  //JC 20180411
        end
      end
      FCR_S05: begin
        if (rff_full == 1'b0) begin
          fsr_stm_ns = FCR_S06;
        end else begin
          fsr_stm_ns = fsr_stm_cs;
        end
      end
      FCR_S06: begin
        if (frfu_ffsr_wlclk_sut == 2'b00) begin
          fsr_stm_ns = FCR_S07;
        end else if (frfu_ffsr_wlclk_sut == 2'b01) begin
          fsr_stm_ns = FCR_S06B;
        end else begin
          fsr_stm_ns = FCR_S06A;
        end

        frfu_ffsr_wl_cnt_ns = frfu_ffsr_wl_cnt_cs + 1'b1;
        if (frfu_ffsr_wl_cnt_cs == 'b0) begin
          fcb_wl_din_ns = 6'b1_0_1_0_1_1;
        end else begin
          fcb_wl_din_ns = 6'b0_0_0_0_0_0;
        end
      end

      FCR_S06A: begin
        fsr_stm_ns = FCR_S06B;
      end

      FCR_S06B: begin
        fsr_stm_ns = FCR_S07;
      end

      FCR_S07: begin
        fcb_wlclk_ns = 1'b1;
        //------------------------------------------------//
        //-- frfu_ffsr_wlblclk_cfg                      --//
        //-- 2'b00 : 1 Cycle                            --//
        //-- 2'b01 : 2 Cycles                           --//
        //-- Others: 3 Cycles                           --//
        //------------------------------------------------//
        if (frfu_ffsr_wlblclk_cfg == 2'b00) begin
          fsr_stm_ns = FCR_S08;
        end else if (frfu_ffsr_wlblclk_cfg == 2'b01) begin
          fsr_stm_ns = FCR_S07B;
        end else begin
          fsr_stm_ns = FCR_S07A;
        end
      end
      //------------------------------------------------//
      //-- New Added Cycles, JC 01302017              --//
      //------------------------------------------------//
      FCR_S07A: begin
        fcb_wlclk_ns = 1'b0;
        fsr_stm_ns   = FCR_S07B;
      end
      FCR_S07B: begin
        fcb_wlclk_ns = 1'b0;
        fsr_stm_ns   = FCR_S08;
      end

      FCR_S08: begin
        fsr_stm_ns        = FCR_S09;
        fcb_wlclk_ns      = 1'b0;
        //fcb_pchg_b_ns         = 1'b0 ; JC
        fcb_pchg_b_ns     = 1'b1;
        fcb_wl_en_ns      = 1'b1;
        fcb_re_ns         = 1'b1;
        fsr_timer_kickoff = 1'b1;
        //--------------------------------------------------------//
        //-- Cfg Read 11-22					--//
        //--------------------------------------------------------//
        if (frfu_ffsr_rcfg_wrp_ccnt == 4'b0000 || frfu_ffsr_rcfg_wrp_ccnt == 4'b0001) begin
          fsr_timer_ini_value = 8'h01;
        end else begin
          fsr_timer_ini_value = {4'b0, {frfu_ffsr_rcfg_wrp_ccnt - 1'b1}};
        end
      end
      FCR_S09: begin
        if (fsr_timer_timeout == 1'b0) begin
          fsr_stm_ns = fsr_stm_cs;
        end else begin
          frfu_ffsr_bl_cnt_ns = frfu_ffsr_bl_cnt_cs + 1'b1;
          fcb_blclk_ns        = 1'b1;
          fsr_stm_ns          = FCR_S09A;
        end
      end
      //--------------------------------------------------------//
      //-- Cfg Read						--//
      //--------------------------------------------------------//
      FCR_S09A: begin
        fcb_blclk_ns      = 1'b0;
        //rff_wr_en 		= 1'b1 ;
        fcb_wl_en_ns      = 1'b0;
        fcb_re_ns         = 1'b0;
        fsr_stm_ns        = FCR_S0A;  // 11-30-2016
        fsr_timer_kickoff = 1'b1;

        if (frfu_ffsr_rcfg_wrp_ccnt == 4'b0000 || frfu_ffsr_rcfg_wrp_ccnt == 4'b0001) begin
          fsr_timer_ini_value = 8'h02;
        end else begin
          fsr_timer_ini_value = {4'b0, frfu_ffsr_rcfg_wrp_ccnt};
        end

      end

      FCR_S0A :	// Since TImer min CNT is 2 Cycle, so it is OK to have this state
      begin
        //rff_wr_en 		= 1'b1 ;
        fsr_stm_ns = FCR_S0B;
      end

      FCR_S0B: begin
        if (fsr_timer_timeout == 1'b0) begin
          fsr_stm_ns = fsr_stm_cs;
        end else begin
          //rff_wr_en 	= 1'b1 ;	// Min. 2 CYCLES//JC
          //fcb_pchg_b_ns       = 1'b1 ; JC
          fcb_pchg_b_ns = 1'b0;
          fsr_stm_ns    = FCR_S0C;
        end
      end

      FCR_S0C: begin
        if (rff_full == 1'b0) begin
          rff_wr_en           = 1'b1;  //JC
          frfu_ffsr_bl_cnt_ns = frfu_ffsr_bl_cnt_cs + 1'b1;
          fcb_blclk_ns        = 1'b1;
          //fsr_stm_ns 		= FCR_S0DA ;
          fsr_stm_ns          = FCR_S0D;

          //------------------------------------------------//
          //-- frfu_ffsr_wlblclk_cfg                      --//
          //-- 2'b00 : 1 Cycle                            --//
          //-- 2'b01 : 2 Cycles                           --//
          //-- Others: 3 Cycles                           --//
          //------------------------------------------------//
          if (frfu_ffsr_wlblclk_cfg == 2'b00) begin
            //fsr_stm_ns          = FCR_S0DA ;
            fsr_stm_ns = FCR_S0D;
          end else if (frfu_ffsr_wlblclk_cfg == 2'b01) begin
            fsr_stm_ns = FCR_S0CB;
          end else begin
            fsr_stm_ns = FCR_S0CA;
          end
        end else begin
          fsr_stm_ns = fsr_stm_cs;
        end
      end
      //------------------------------------------------//
      //-- New Added Cycles, JC 01302017              --//
      //------------------------------------------------//
      FCR_S0CA: begin
        fcb_blclk_ns = 1'b0;
        fsr_stm_ns   = FCR_S0CB;
      end
      FCR_S0CB: begin
        fcb_blclk_ns = 1'b0;
        fsr_stm_ns   = FCR_S0D;
      end


      FCR_S0D: begin
        fcb_blclk_ns = 1'b0;
        //rff_wr_en 		= 1'b1 ;
        if (frfu_ffsr_bl_cnt_cs == {
              frfu_ffsr_bl_cnt_h, frfu_ffsr_bl_cnt_l
            })  // Bit Line
                begin
          frfu_ffsr_bl_cnt_ns = 'b0;
          if (frfu_ffsr_wl_cnt_cs == {
                frfu_ffsr_wl_cnt_h, frfu_ffsr_wl_cnt_l
              })  // WL 
                  begin
            frfu_ffsr_wl_cnt_ns = 'b0;
            fsr_stm_ns = FCR_S0E;
          end else begin
            fsr_stm_ns = FCR_S0DA;
          end
        end else begin
          fsr_stm_ns = FCR_S0C;
        end
      end

      FCR_S0DA :	// 11-29-2016
      begin
        if (rff_full == 1'b0) begin
          rff_wr_en  = 1'b1;
          //fcb_blclk_ns	= 1'b0 ;
          fsr_stm_ns = FCR_S05;
        end else begin
          fcb_blclk_ns = 1'b0;
          fsr_stm_ns   = fsr_stm_cs;
        end
      end

      FCR_S0E: begin
        if (rff_full == 1'b0) begin
          rff_wr_en  = 1'b1;  // JC, Last BL Write	01302017
          fsr_stm_ns = FCR_S0EA;
        end else begin
          fsr_stm_ns = fsr_stm_cs;
        end
      end

      FCR_S0EA :				//JC	01302017
      begin
        fcb_bl_pwrgate_ns     = 'b0;
        fcb_wl_pwrgate_ns     = 'b0;
        fcb_wl_sel_ns         = 'b0;
        //fcb_prog_ns             =  'b0 ;
        //fcb_prog_ifx_ns         =  'b0 ;
        frfu_ffsr_bl_cnt_ns   = 'b0;
        frfu_ffsr_wl_cnt_ns   = 'b0;
        frfu_ffsr_col_cnt_ns  = 'b0;
        fcb_cload_din_sel_ns  = 1'b0;
        fcb_wl_sel_tb_int_ns  = 'b0;
        fcb_wl_int_din_sel_ns = 'b0;
        fsr_stm_ns            = FCR_S0EB;
      end
      FCR_S0EB :				//JC	01302017
      begin
        fsr_stm_ns = FCR_S0EC;
      end
      FCR_S0EC :				//JC	01302017
      begin
        fsr_stm_ns = FCR_S0ED;
      end

      FCR_S0ED :				//JC	01302017
      begin
        fsr_stm_ns = FCR_S0F;
      end

      FCR_S0F: begin
        if ( frfu_ffsr_fb_cfg_cmd[7:0] == 8'h02 ||
	     frfu_ffsr_fb_cfg_cmd[7:0] == 8'h30 ||
	     frfu_ffsr_fb_cfg_cmd[7:0] == 8'h40  )
	  begin
          fsr_stm_ns = ARR_S00;
        end else begin
          fsr_stm_ns = END_S00;
        end
      end
      //----------------------------------------------------------------//
      //-- APB READ 							--//
      //----------------------------------------------------------------//
      ARR_S00: begin
        if (frfu_ffsr_ram_cfg == 'b0) begin
          fsr_stm_ns = ARR_S08;
        end else begin
          fcb_apbm_ramfifo_sel_ns = 1'b1;
          fsr_stm_ns              = ARR_S01;
        end
      end
      ARR_S01: begin
        if (ramfifo_index_cs[4] == 1'b1) begin
          fcb_apbm_ramfifo_sel_ns = 1'b0;
          ramfifo_index_ns        = 'b0;
          fsr_stm_ns              = ARR_S08;
        end else if (frfu_ffsr_ram_cfg[ramfifo_index_cs[3:0]] == 1'b0) begin
          fsr_stm_ns = ARR_S01;
          ramfifo_index_ns = ramfifo_index_cs + 1'b1;
        end else begin
          fsr_stm_ns = ARR_S02;
          fcb_apbm_paddr_ns = {ramfifo_index_cs[0], 11'b0};
          fcb_apbm_psel_ns = 'b0;
        end
      end
      ARR_S02: begin
        fsr_stm_ns = ARR_S03;
      end
      ARR_S03: begin
        if (((fcb_apbm_paddr_cs[11:2] == {
              frfu_ffsr_ram_size_b1[1:0], frfu_ffsr_ram_size_b0[7:0]
            }) && ramfifo_index_cs[0] == 1'b0) || ((fcb_apbm_paddr_cs[11:2] == {
              2'b00, frfu_ffsr_ram_size_b0[7:0]
            }) && ramfifo_index_cs[0] == 1'b1))  // JC
                begin
          ramfifo_index_ns = ramfifo_index_cs + 1'b1;
          fcb_apbm_psel_ns = 'b0;
          fsr_stm_ns = ARR_S01;
        end else if (rff_full == 1'b0) begin
          fcb_apbm_psel_ns[ramfifo_index_cs[3:1]] = 1'b1  ;
          fsr_stm_ns				= ARR_S04 ;
        end else begin
          fsr_stm_ns = fsr_stm_cs;
        end
      end
      ARR_S04: begin
        fcb_apbm_psel_ns[ramfifo_index_cs[3:1]] = 1'b1 ;
        fcb_apbm_mclk_ns 			= 1'b1 ;
        fsr_stm_ns				= ARR_S05 ;
      end
      ARR_S05: begin
        fcb_apbm_psel_ns[ramfifo_index_cs[3:1]] = 1'b1 ;
        fcb_apbm_mclk_ns 			= 1'b0 ;
        fcb_apbm_penable_ns			= 1'b1 ;
        fsr_stm_ns				= ARR_S06 ;
      end
      ARR_S06: begin
        fcb_apbm_psel_ns[ramfifo_index_cs[3:1]] = 1'b1;
        fcb_apbm_mclk_ns                        = 1'b1;
        fcb_apbm_penable_ns                     = 1'b1;
        fsr_stm_ns                              = ARR_S07;
      end
      ARR_S07: begin
        rff_wr_en           = 1'b1;
        fcb_apbm_psel_ns    = 'b0;
        fcb_apbm_mclk_ns    = 1'b0;
        fcb_apbm_penable_ns = 1'b0;
        fcb_apbm_paddr_ns   = fcb_apbm_paddr_cs + 3'b100;  // JC
        fsr_stm_ns          = ARR_S0A;
      end
      // 11-29-2016
      ARR_S0A: begin
        fcb_apbm_mclk_ns = 1'b1;
        fsr_stm_ns       = ARR_S0B;
      end
      // 11-29-2016
      ARR_S0B: begin
        fcb_apbm_mclk_ns = 1'b0;
        fsr_stm_ns       = ARR_S03;
      end

      ARR_S08: begin
        fsr_stm_ns = ARR_S09;
      end
      ARR_S09: begin
        fsr_stm_ns = END_S00;
      end
      //----------------------------------------------------------------//
      //-- APB WRITE 							--//
      //----------------------------------------------------------------//
      ARW_S00: begin
        if (frfu_ffsr_ram_cfg == 'b0) begin
          fsr_stm_ns = ARW_S08;
        end else begin
          fcb_apbm_ramfifo_sel_ns = 1'b1;
          fsr_stm_ns              = ARW_S01;
        end
      end
      ARW_S01: begin
        if (ramfifo_index_cs[4] == 1'b1) begin
          fcb_apbm_ramfifo_sel_ns = 1'b0;
          ramfifo_index_ns        = 'b0;
          fsr_stm_ns              = ARW_S08;
        end else if (frfu_ffsr_ram_cfg[ramfifo_index_cs[3:0]] == 1'b0) begin
          fsr_stm_ns = ARW_S01;
          ramfifo_index_ns = ramfifo_index_cs + 1'b1;
        end else begin
          fsr_stm_ns = ARW_S02;
          fcb_apbm_paddr_ns = {ramfifo_index_cs[0], 11'b0};
          fcb_apbm_psel_ns = 'b0;
        end
      end
      ARW_S02: begin
        fsr_stm_ns = ARW_S03;
      end
      ARW_S03: begin
        if (((fcb_apbm_paddr_cs[11:2] == {
              frfu_ffsr_ram_size_b1[1:0], frfu_ffsr_ram_size_b0[7:0]
            }) && ramfifo_index_cs[0] == 1'b0) || ((fcb_apbm_paddr_cs[11:2] == {
              2'b00, frfu_ffsr_ram_size_b0[7:0]
            }) && ramfifo_index_cs[0] == 1'b1))  // JC
                begin
          ramfifo_index_ns = ramfifo_index_cs + 1'b1;
          fcb_apbm_psel_ns = 'b0;
          fsr_stm_ns = ARW_S01;
        end else if (wff_empty == 1'b0) begin
          fcb_apbm_pwrite_ns                      = 1'b1;
          fcb_apbm_psel_ns[ramfifo_index_cs[3:1]] = 1'b1;
          fsr_stm_ns                              = ARW_S04;
        end else begin
          fsr_stm_ns = fsr_stm_cs;
        end
      end
      ARW_S04: begin
        fcb_apbm_pwrite_ns                      = 1'b1;
        fcb_apbm_psel_ns[ramfifo_index_cs[3:1]] = 1'b1;
        fcb_apbm_mclk_ns                        = 1'b1;
        fsr_stm_ns                              = ARW_S05;
      end
      ARW_S05: begin
        fcb_apbm_pwrite_ns                      = 1'b1;
        fcb_apbm_psel_ns[ramfifo_index_cs[3:1]] = 1'b1;
        fcb_apbm_mclk_ns                        = 1'b0;
        fcb_apbm_penable_ns                     = 1'b1;
        fsr_stm_ns                              = ARW_S06;
      end
      ARW_S06: begin
        fcb_apbm_pwrite_ns                      = 1'b1;
        fcb_apbm_psel_ns[ramfifo_index_cs[3:1]] = 1'b1;
        fcb_apbm_mclk_ns                        = 1'b1;
        fcb_apbm_penable_ns                     = 1'b1;
        fsr_stm_ns                              = ARW_S07A;
      end
      ARW_S07A: begin
        wff_rd_en           = 1'b1;
        fcb_apbm_pwrite_ns  = 'b0;
        fcb_apbm_psel_ns    = 'b0;
        fcb_apbm_mclk_ns    = 1'b0;
        fcb_apbm_penable_ns = 1'b0;
        fcb_apbm_paddr_ns   = fcb_apbm_paddr_cs + 3'b100;
        fsr_stm_ns          = ARW_S07B;
      end
      ARW_S07B: begin
        fcb_apbm_mclk_ns = 1'b1;
        fsr_stm_ns       = ARW_S07;
      end
      ARW_S07: begin
        fcb_apbm_mclk_ns = 1'b0;
        fsr_stm_ns       = ARW_S03;
      end
      ARW_S08: begin
        fsr_stm_ns = ARW_S09;
      end
      ARW_S09: begin
        if (frfu_ffsr_fb_cfg_cmd[7:0] == 8'h02) begin
          fsr_stm_ns = FCR_S00;
        end else begin
          fsr_stm_ns = END_S00;
        end
      end
      //----------------------------------------------------------------//
      //-- END 							--//
      //----------------------------------------------------------------//
      END_S00: begin
        if (rff_empty == 1'b1 && wff_empty == 1'b1) begin
          fsr_stm_ns = END_S01;
        end else begin
          fsr_stm_ns = fsr_stm_cs;
        end
      end
      END_S01: begin
        if (rff_empty == 1'b1 && wff_empty == 1'b1) begin
          fsr_stm_ns = END_S02;
        end else begin
          fsr_stm_ns = fsr_stm_cs;
        end
      end
      END_S02: begin
        fsr_stm_ns = END_S03;
      end
      END_S03: begin
        fsr_stm_ns = END_S04;
      end
      END_S04: begin
        fsr_stm_ns = END_S05;
      end
      END_S05: begin
        fsr_stm_ns = END_S06;
      end
      END_S06: begin
        ffsr_frfu_clr_fb_cfg_kickoff = 1'b1;
        fsr_stm_ns = END_S07;
      end
      END_S07: begin
        fsr_stm_ns = MAIN_S0;
      end

      //----------------------------------------------------------------//
      //-- Default State                                              --//
      //----------------------------------------------------------------//
      default: begin
        fsr_stm_ns = MAIN_S0;
      end
    endcase
  end
  //------------------------------------------------------------------------//
  //-- Comment                                                            --//
  //------------------------------------------------------------------------//


  //--------------------------------------------------------------------------------//
  //-- END                                                                        --//
  //--------------------------------------------------------------------------------//
endmodule


