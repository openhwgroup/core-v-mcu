// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1


module clk_and_control (
    input        [ 2:0] num,
    output logic        FLLCLK,
    input  logic        FLLOE,
    input  logic        REFCLK,
    output logic        LOCK,
    input  logic        CFGREQ,
    output logic        CFGACK,
    input  logic [ 1:0] CFGAD,
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

  logic [1:0] s_PS0_L1;
  logic [1:0] s_PS1_L1;
  logic [7:0] s_PS0_L2_INT;
  logic [5:0] s_PS0_L2_FRAC;
  logic [7:0] s_PS1_L2_INT;
  logic [5:0] s_PS1_L2_FRAC;

  logic s_PS0_EN;
  logic s_PS1_EN;
  logic s_PS0_BYPASS;
  logic s_PS1_BYPASS;
  logic [10:0] s_MUL_INT;
  logic [11:0] s_MUL_FRAC;
  logic s_INTEGER_MODE;
  logic [3:0] s_PRESCALE;

  logic [9:0] s_LDET_CONFIG;
  logic s_SSC_EN;
  logic [7:0] s_SSC_STEP;
  logic [10:0] s_SSC_PERIOD;

  logic [32:0] s_LF_CONFIG;
  logic r_tmp;

  pPLL02F u0 (
      .num(num),
      .rstn(RSTB),
      .PWRDN(PWD),
      .CK_XTAL_IN(REFCLK),
      .CK_AUX_IN(REFCLK),
      .CK_PLL_OUT(),
      .CK_PLL_DIV0(FLLCLK),
      .CK_PLL_DIV1(),
      .PS0_EN(s_PS0_EN),
      .PS1_EN(s_PS1_EN),
      .PS0_BYPASS(s_PS0_BYPASS),
      .PS1_BYPASS(s_PS1_BYPASS),
      .PS0_L1(s_PS0_L1),
      .PS1_L1(s_PS1_L1),
      .PS0_L2_INT(s_PS0_L2_INT),
      .PS0_L2_FRAC(s_PS0_L2_FRAC),
      .PS1_L2_INT(s_PS1_L2_INT),
      .PS1_L2_FRAC(s_PS1_L2_FRAC),
      .SSC_EN(s_SSC_EN),
      .SSC_STEP(s_SSC_STEP),
      .SSC_PERIOD(s_SSC_PERIOD),
      .MUL_INT(s_MUL_INT),
      .MUL_FRAC(s_MUL_FRAC),
      .INTEGER_MODE(s_INTEGER_MODE),
      .PRESCALE(s_PRESCALE),
      .LDET_CONFIG(s_LDET_CONFIG),
      .LF_CONFIG(s_LF_CONFIG),
      .LOCKED(LOCK),
      .TEST_OUT(),
      .SCAN_CK(),
      .SCAN_IN(TD),
      .SCAN_MODE(TM),
      .SCAN_EN(TE),
      .SCAN_OUT(TQ)
  );

  assign s_PS0_L1 = config0[1:0];    //2
  assign s_PS1_L1 = config0[3:2];    //2
  assign s_PS0_L2_INT = config0[11:4]; //8
  assign s_PS0_L2_FRAC = config0[17:12];    //6
  assign s_PS1_L2_INT = config0[25:18];    //8
  assign s_PS1_L2_FRAC = config0[31:26];   //6

  assign s_PS0_EN = config1[0];  //1
  assign s_PS1_EN = config1[1];  //1
  assign s_PS0_BYPASS = config1[2];  //1
  assign s_PS1_BYPASS = config1[3];  //1
  assign s_MUL_INT = config1[14:4];    //11
  assign s_MUL_FRAC = config1[26:15];   //12
  assign s_INTEGER_MODE = config1[27];     //1
  assign s_PRESCALE = config1[31:28];    //4

  assign s_LDET_CONFIG = config2[9:0]; //10
  assign s_SSC_EN = config2[10];     //1
  assign s_SSC_STEP = config2[18:11];  //8
  assign s_SSC_PERIOD = config2[29:19];   //11

  assign s_LF_CONFIG[31:0] = config3[31:0];   //32
  assign s_LF_CONFIG[32] = r_tmp;   //1

  always_ff @(posedge REFCLK, negedge RSTB) begin
    if (RSTB == 1'b0) begin
      config0 <= 0;
      config1 <= 32'h0000000C;
      config2 <= 0;
      config3 <= 0;
    end else begin
      if (CFGWEB) begin
        if (CFGAD == 2'b00) config0 <= CFGD;
        else if (CFGAD == 2'b01) config1 <= CFGD;
        else if (CFGAD == 2'b10) config2 <= CFGD;
        else if (CFGAD == 2'b11) begin
          config3 <= CFGD;
          r_tmp   <= config2[30];
        end
      end
      if (CFGREQ) begin
        if (CFGAD == 2'b00) CFGQ <= config0;
        else if (CFGAD == 2'b01) CFGQ <= config1;
        else if (CFGAD == 2'b10) CFGQ <= {LOCK, s_LF_CONFIG[32], config2[29:0]};
        else if (CFGAD == 2'b11) CFGQ <= config3;
      end
    end
  end
endmodule
