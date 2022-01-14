// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1


/*module clk_and_control #(
parameter PLLNUM = 1)*/
module clk_and_control (
    input               clk,
    output logic        FLLCLK,
    input  logic        FLLOE,
    input  logic        REFCLK,
    output logic        LOCK,
    input  logic        CFGREQ,
    output logic        CFGACK,
    input  logic [ 4:0] CFGAD,
    input  logic [31:0] CFGD,
    output logic [31:0] CFGQ,
    input  logic        CFGWEB,
    input  logic        RSTB,
    input  logic        PWD,
    input  logic        RET,
    input  logic        TM,
    input  logic        TE,
    input  logic        TD,  //TO FIX DFT
    output logic        TQ,  //TO FIX DFT
    input  logic        JTD,  //TO FIX DFT
    output logic        JTQ  //TO FIX DFT

);

  logic [31:0] config0;
  logic [31:0] config1;
  logic [31:0] config2;
  logic [31:0] config3;
  logic [31:0] config4;
  logic [31:0] config5;
  logic [31:0] config6;
  logic [31:0] config7;

  logic [ 1:0] s_PS0_L1;
  logic [ 1:0] s_PS1_L1;
  logic [ 7:0] s_PS0_L2;
  logic [ 5:0] s_PS0_L2_FRAC;
  logic [ 7:0] s_PS1_L2;
  logic [ 5:0] s_PS1_L2_FRAC;

  logic        s_PS0_EN;
  logic        s_PS1_EN;
  logic        s_PS0_BYPASS;
  logic        s_PS1_BYPASS;
  logic [10:0] s_MUL_INT;
  logic [11:0] s_MUL_FRAC;
  logic        s_INTEGER_MODE;
  logic [ 3:0] s_PRESCALE;

  logic [ 8:0] s_LDET_CONFIG;
  logic        s_SSC_EN;
  logic [ 7:0] s_SSC_STEP;
  logic [10:0] s_SSC_PERIOD;

  logic [34:0] s_LF_CONFIG;
  logic [ 2:0] r_tmp;
  logic        pll_clk;
  logic        pll_rstn;

  assign pll_rstn = RSTB & config0[2];

  /*
  pulp_clock_mux2 ck_i (
      .clk0_i   (pll_clk),
      .clk1_i   (REFCLK),
      .clk_sel_i(s_PS0_BYPASS),
      .clk_o    (FLLCLK)
  );
 */
  //generate
  //if ( PLLNUM == 1 )
  pPLL02F u0 (
      .RST_N(pll_rstn),
      .CK_XTAL_IN(REFCLK),
      .CK_AUX_IN(REFCLK),
      .PRESCALE(s_PRESCALE),
      .SSC_EN(s_SSC_EN),
      .SSC_STEP(s_SSC_STEP),
      .SSC_PERIOD(s_SSC_PERIOD),
      .INTEGER_MODE(s_INTEGER_MODE),
      .MUL_INT(s_MUL_INT),
      .MUL_FRAC(s_MUL_FRAC),
      .LOCKED(LOCK),
      .LDET_CONFIG(s_LDET_CONFIG),
      .LF_CONFIG(s_LF_CONFIG),
      .PS0_EN(s_PS0_EN),
      .PS0_BYPASS(s_PS0_BYPASS),
      .PS0_L1(s_PS0_L1),
      .PS0_L2(s_PS0_L2),
      .CK_PLL_OUT0(FLLCLK),
      .PS1_EN(s_PS1_EN),
      .PS1_BYPASS(s_PS1_BYPASS),
      .PS1_L1(s_PS1_L1),
      .PS1_L2(s_PS1_L2),
      .CK_PLL_OUT1(),
      .SCAN_IN(TD),
      .SCAN_CK(1'b0),
      .SCAN_EN(TE),
      .SCAN_MODE(TM),
      .SCAN_OUT(TQ)
  );
  /*else
   pPLL02F_x u0 (
	       .RST_N(pll_rstn),
	       .CK_XTAL_IN(REFCLK),
	       .CK_AUX_IN(REFCLK),
	       .PRESCALE(s_PRESCALE),
	       .SSC_EN(s_SSC_EN),
	       .SSC_STEP(s_SSC_STEP),
	       .SSC_PERIOD(s_SSC_PERIOD),
	       .INTEGER_MODE(s_INTEGER_MODE),
	       .MUL_INT(s_MUL_INT),
	       .MUL_FRAC(s_MUL_FRAC),
	       .LOCKED(LOCK),
	       .LDET_CONFIG(s_LDET_CONFIG),
	       .LF_CONFIG(s_LF_CONFIG),
	       .PS0_EN(s_PS0_EN),
	       .PS0_BYPASS(s_PS0_BYPASS),
	       .PS0_L1(s_PS0_L1),
	       .PS0_L2(s_PS0_L2),
	       .CK_PLL_OUT0(FLLCLK),
	       .PS1_EN(1'b0),
	       .PS1_BYPASS(1'b1),
	       .PS1_L1(2'b00),
	       .PS1_L2(8'h0),
	       .CK_PLL_OUT1(),
	       .SCAN_IN(TD),
	       .SCAN_CK(1'b0),
	       .SCAN_EN(TE),
	       .SCAN_MODE(TM),
	       .SCAN_OUT(TQ)
	       );
endgenerate*/
  //Set initial values for config 0
  localparam PS0_L1 = 2'b00;  //config0[1:0]
  localparam PS0_RSTN = 1'b0;  // config0[2]
  //Dummy config0[3]
  localparam PS0_L2 = 8'b00000000;  // config0[11:4]
  localparam PS0_L2_FRAC = 6'b000000;  // config0[17:12]
  localparam PS0_EN = 1'b0;  // config0[18]
  localparam PS0_BYPASS = 1'b1;  // config0[19]

  localparam PS1_L1 = 2'b00;  //config1[1:0]
  localparam PS1_RSTN = 1'b0;  // config1[2]
  //Dummy config1[3]
  localparam PS1_L2 = 8'b00000000;  // config1[11:4]
  localparam PS1_L2_FRAC = 6'b000000;  // config1[17:12]
  localparam PS1_EN = 1'b0;  // config1[18]
  localparam PS1_BYPASS = 1'b1;  // config1[19]

  localparam MUL_INT = 11'b00000101000;
  localparam MUL_FRAC = 12'b0;
  localparam INTEGER_MODE = 1'b1;
  localparam PRESCALE = 4'b1;

  assign s_PS0_L1 = config0[1:0];    //2
  assign s_PS0_L2 = config0[11:4]; //8
  assign s_PS0_L2_FRAC = config0[17:12];    //6
  assign s_PS0_EN = config0[18];  //1
  assign s_PS0_BYPASS = config0[19];  //1

  assign s_PS1_L1 = config1[1:0];    //2
  assign s_PS1_L2 = config1[11:4]; //8
  assign s_PS1_L2_FRAC = config1[17:12];    //6
  assign s_PS1_EN = config1[18];  //1
  assign s_PS1_BYPASS = config1[19];  //1

  assign s_MUL_INT = config2[14:4];    //11
  assign s_MUL_FRAC = config2[26:15];   //12
  assign s_INTEGER_MODE = config2[27];     //1
  assign s_PRESCALE = config2[31:28];    //4

  assign s_SSC_EN = config3[9];     //1
  assign s_SSC_STEP = config3[17:10];  //8
  assign s_SSC_PERIOD = config3[28:18];   //11

  assign s_LDET_CONFIG = config4[8:0]; //9
  assign s_LF_CONFIG[34:32] = r_tmp[2:0]; //3

  assign s_LF_CONFIG[31:0] = config5[31:0];   //32

  always_ff @(posedge clk, negedge RSTB) begin
    if (RSTB == 1'b0) begin
      config0 <= {
        12'b0, PS0_BYPASS, PS0_EN, PS0_L2_FRAC, PS0_L2, 1'b0  /*Dummy bit*/, PS0_RSTN, PS0_L1
      };
      config1 <= {
        12'b0, PS1_BYPASS, PS1_EN, PS1_L2_FRAC, PS1_L2, 1'b0  /*Dummy bit*/, PS1_RSTN, PS1_L1
      };
      config2 <= {PRESCALE, INTEGER_MODE, MUL_FRAC, MUL_INT, 4'b0};
      config3 <= 32'h0;
      config4 <= 32'h64;  //LDET intial value as per datasheet
      config5 <= 32'h269;  //LF_CONFIG initial value as per datasheet
      CFGACK <= 1'b0;
    end else begin
      if (CFGREQ == 1'b1) begin
        if (CFGWEB == 0) begin
          if (CFGAD == 0) config0 <= CFGD;
          else if (CFGAD == 4) config1 <= CFGD;
          else if (CFGAD == 8) config2 <= CFGD;
          else if (CFGAD == 12) config3 <= CFGD;
          else if (CFGAD == 16) config4 <= CFGD;
          else if (CFGAD == 20) begin
            config5 <= CFGD;
            r_tmp[2:0] <= config4[11:9];
          end else if (CFGAD == 24) config6 <= CFGD;
          else if (CFGAD == 28) config7 <= CFGD;
          CFGACK <= 1'b1;
        end else begin
          if (CFGAD == 0) CFGQ <= config0;
          else if (CFGAD == 4) CFGQ <= config1;
          else if (CFGAD == 8) CFGQ <= config2;
          else if (CFGAD == 12) CFGQ <= config3;
          else if (CFGAD == 16) CFGQ <= {LOCK, config4[30:0]};
          else if (CFGAD == 20) CFGQ <= config5;
          else if (CFGAD == 24) CFGQ <= config6;
          else if (CFGAD == 28) CFGQ <= config7;

          CFGACK <= 1'b1;
        end  // else: !if(CFGWEB)
      end // if (CFGREQ == 1'b1)
	 else begin
        CFGACK <= 1'b0;
      end  // else: !if(CFGREQ == 1'b1)
    end  // else: !if(RSTB == 1'b0)
  end  // always_ff @ (posedge clk, negedge RSTB)
endmodule
