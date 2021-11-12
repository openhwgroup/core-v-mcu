// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
module A2_MATH_UNIT (
    input         m0_clk,
    m0_clken,
    m0_tc,
    input         m0_osel,
    m0_csel,
    input         m0_clr,
    m0_rnd,
    m0_sat,
    m0_reset,
    input  [31:0] m0_oper_in,
    m0_coef_in,
    input  [ 1:0] m0_mode,
    input  [ 5:0] m0_outsel,
    output [31:0] m0_dataout,

    input         m1_clk,
    m1_clken,
    m1_tc,
    input         m1_osel,
    m1_csel,
    input         m1_clr,
    m1_rnd,
    m1_sat,
    m1_reset,
    input  [31:0] m1_oper_in,
    m1_coef_in,
    input  [ 1:0] m1_mode,
    input  [ 5:0] m1_outsel,
    output [31:0] m1_dataout,

    input         oper0_pwrdn,
    input         oper0_rclk,
    oper0_wclk,
    oper0_we,
    oper0_wdsel,
    input  [ 1:0] oper0_rmode,
    oper0_wmode,
    output [31:0] oper0_rdata,
    input  [31:0] oper0_wdata,
    input  [11:0] oper0_raddr,
    oper0_waddr,

    input              oper1_pwrdn,
    input              oper1_rclk,
    oper1_wclk,
    oper1_we,
    oper1_wdsel,
    input       [ 1:0] oper1_rmode,
    oper1_wmode,
    output      [31:0] oper1_rdata,
    input       [31:0] oper1_wdata,
           wire [11:0] oper1_raddr,
    oper1_waddr,

    input              coef_pwrdn,
    input              coef_rclk,
    coef_wclk,
    coef_we,
    coef_wdsel,
    input       [ 1:0] coef_rmode,
    coef_wmode,
    output      [31:0] coef_rdata,
    input       [31:0] coef_wdata,
           wire [11:0] coef_raddr,
    coef_waddr
);

  MATH_BLOCK U_MATH_BLOCK_0 (
      // output
      .FMATHB_EFPGA_MAC_OUT(m0_dataout),
      // Inputs
      .EFPGA2MATHB_CLK(m0_clk),
      .EFPGA_MATHB_CLK_EN(m0_clken),
      .TPRAM_MATHB_OPER_R_DATA(oper0_rdata),
      .EFPGA_MATHB_OPER_DATA(m0_oper_in),
      .EFPGA_MATHB_OPER_defPin(2'b11),
      .EFPGA_MATHB_OPER_SEL(m0_osel),
      .TPRAM_MATHB_COEF_R_DATA(coef_rdata),
      .EFPGA_MATHB_COEF_DATA(m0_coef_in),
      .EFPGA_MATHB_COEF_defPin(2'b11),
      .EFPGA_MATHB_COEF_SEL(m0_csel),
      .EFPGA_MATHB_TC_defPin(m0_tc),
      .EFPGA_MATHB_MAC_OUT_SEL(m0_outsel),
      .EFPGA_MATHB_MAC_ACC_SAT(m0_sat),
      .EFPGA_MATHB_MAC_ACC_CLEAR(m0_clr),
      .EFPGA_MATHB_MAC_ACC_RND(m0_rnd),
      .EFPGA_MATHB_DATAOUT_SEL(m0_mode),
      .reset(m0_reset)
  );
  MATH_BLOCK U_MATH_BLOCK_1 (
      // output
      .FMATHB_EFPGA_MAC_OUT(m1_dataout),
      // Inputs
      .EFPGA2MATHB_CLK(m1_clk),
      .EFPGA_MATHB_CLK_EN(m1_clken),
      .TPRAM_MATHB_OPER_R_DATA(oper1_rdata),
      .EFPGA_MATHB_OPER_DATA(m1_oper_in),
      .EFPGA_MATHB_OPER_defPin(2'b11),
      .EFPGA_MATHB_OPER_SEL(m1_osel),
      .TPRAM_MATHB_COEF_R_DATA(coef_rdata),
      .EFPGA_MATHB_COEF_DATA(m1_coef_in),
      .EFPGA_MATHB_COEF_defPin(2'b11),
      .EFPGA_MATHB_COEF_SEL(m1_csel),
      .EFPGA_MATHB_TC_defPin(m1_tc),
      .EFPGA_MATHB_MAC_OUT_SEL(m1_outsel),
      .EFPGA_MATHB_MAC_ACC_SAT(m1_sat),
      .EFPGA_MATHB_MAC_ACC_CLEAR(m1_clr),
      .EFPGA_MATHB_MAC_ACC_RND(m1_rnd),
      .EFPGA_MATHB_DATAOUT_SEL(m1_mode),
      .reset(m1_reset)
  );


  TPRAM_WRAP U_TPRAM_OPER_0 (

      // Outputs
      .TPRAM_MATHB_R_DATA (),
      .TPRAM_EFPGA_R_DATA (oper0_rdata),
      // Inputs
      .EFPGA_TPRAM_R_MODE (oper0_rmode),
      .EFPGA_TPRAM_W_MODE (oper0_wmode),
      .EFPGA_TPRAM_WDSEL  (oper0_wdsel),
      .EFPGA_TPRAM_WE     (oper0_we),
      .EFPGA_TPRAM_R_CLK  (oper0_rclk),
      .EFPGA_TPRAM_R_ADDR (oper0_raddr),
      .EFPGA_TPRAM_W_CLK  (oper0_wclk),
      .EFPGA_TPRAM_W_ADDR (oper0_waddr),
      .EFPGA_TPRAM_W_DATA (oper0_wdata),
      .MATHB_TPRAM_W_DATA (m0_dataout),
      .EFPGA_TPRAM_POWERDN(oper0_pwrdn)
  );

  TPRAM_WRAP U_TPRAM_OPER_1 (

      // Outputs
      .TPRAM_MATHB_R_DATA (),
      .TPRAM_EFPGA_R_DATA (oper1_rdata),
      // Inputs
      .EFPGA_TPRAM_R_MODE (oper1_rmode),
      .EFPGA_TPRAM_W_MODE (oper1_wmode),
      .EFPGA_TPRAM_WDSEL  (oper1_wdsel),
      .EFPGA_TPRAM_WE     (oper1_we),
      .EFPGA_TPRAM_R_CLK  (oper1_rclk),
      .EFPGA_TPRAM_R_ADDR (oper1_raddr),
      .EFPGA_TPRAM_W_CLK  (oper1_wclk),
      .EFPGA_TPRAM_W_ADDR (oper1_waddr),
      .EFPGA_TPRAM_W_DATA (oper1_wdata),
      .MATHB_TPRAM_W_DATA (m1_dataout),
      .EFPGA_TPRAM_POWERDN(oper1_pwrdn)
  );

  TPRAM_WRAP U_TPRAM_COEF (

      // Outputs
      .TPRAM_MATHB_R_DATA (),
      .TPRAM_EFPGA_R_DATA (coef_rdata),
      // Inputs
      .EFPGA_TPRAM_R_MODE (coef_rmode),
      .EFPGA_TPRAM_W_MODE (coef_wmode),
      .EFPGA_TPRAM_WDSEL  (coef_wdsel),
      .EFPGA_TPRAM_WE     (coef_we),
      .EFPGA_TPRAM_R_CLK  (coef_rclk),
      .EFPGA_TPRAM_R_ADDR (coef_raddr),
      .EFPGA_TPRAM_W_CLK  (coef_wclk),
      .EFPGA_TPRAM_W_ADDR (coef_waddr),
      .EFPGA_TPRAM_W_DATA (coef_wdata),
      .MATHB_TPRAM_W_DATA (m0_dataout),
      .EFPGA_TPRAM_POWERDN(coef_pwrdn)
  );



endmodule
