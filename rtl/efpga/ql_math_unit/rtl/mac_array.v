// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

module MAC_ARRAY
  (
   //OUTPUT
   MAC0_OUT,
   MAC1_OUT,
   MAC2_OUT,
   MAC3_OUT,
   MAC4_OUT,
   MAC5_OUT,
   MAC6_OUT,
	 MAC_4_0_OUT,
	 MAC_4_1_OUT,
	 MAC_4_2_OUT,
	 MAC_4_3_OUT,
	 MAC_4_4_OUT,
	 MAC_4_5_OUT,
	 MAC_4_6_OUT,
	 MAC_4_7_OUT,
   //INPUT
   MAC_OPER_DATA,
   MAC_COEF_DATA,
   MAC_ACC_CLK,
   EFPGA_MATHB_CLK_EN,
   MAC_ACC_CLEAR,
   MAC_ACC_RND,
   MAC_ACC_SAT,
   MAC_OUT_SEL,
   MAC_TC,
   acc_ff_rstn
   );




  //OUTPUT
  output [31:0] MAC0_OUT;
  output [15:0] MAC1_OUT;
  output [15:0] MAC2_OUT;
  output [ 7:0] MAC3_OUT;
  output [ 7:0] MAC4_OUT;
  output [ 7:0] MAC5_OUT;
  output [ 7:0] MAC6_OUT;
  output [3:0]  MAC_4_0_OUT;
  output [3:0]  MAC_4_1_OUT;
  output [3:0]  MAC_4_2_OUT;
  output [3:0]  MAC_4_3_OUT;
  output [3:0]  MAC_4_4_OUT;
  output [3:0]  MAC_4_5_OUT;
  output [3:0]  MAC_4_6_OUT;
  output [3:0]  MAC_4_7_OUT;
  //INPUT
  input [31:0]  MAC_OPER_DATA;
  input [31:0]  MAC_COEF_DATA;
  input         MAC_ACC_CLK;
  input         EFPGA_MATHB_CLK_EN;
  input         MAC_ACC_CLEAR;
  input         MAC_ACC_RND;
  input         MAC_ACC_SAT;
  input [5:0]   MAC_OUT_SEL;
  input         MAC_TC;
  input         acc_ff_rstn;

  /*------------------------------*/
  /*        MAC_ARRAY             */
  /*------------------------------*/
  MAC_32BIT #(
              .MULTI_WIDTH(32)
              ) U_MAC_32BIT ( //32-bit
                              //OUTPUT
                              .MAC_OUT(MAC0_OUT[31:0]),
                              //INPUT
                              .MAC_ACC_CLK(MAC_ACC_CLK),
                              .EFPGA_MATHB_CLK_EN(EFPGA_MATHB_CLK_EN),
                              .MAC_OPER_DATA(MAC_OPER_DATA[31:0]),
                              .MAC_COEF_DATA(MAC_COEF_DATA[31:0]),
                              .MAC_ACC_RND(MAC_ACC_RND),
                              .MAC_ACC_CLEAR(MAC_ACC_CLEAR),
                              .MAC_ACC_SAT(MAC_ACC_SAT),
                              .MAC_OUT_SEL(MAC_OUT_SEL),
                              .MAC_TC(MAC_TC),
                              .acc_ff_rstn(acc_ff_rstn)
                              );

  MAC_16BIT #(
              .MULTI_WIDTH(16)
              ) U0_MAC_16BIT ( //16-bit
                               //OUTPUT
                               .MAC_OUT(MAC1_OUT[15:0]),
                               //INPUT
                               .MAC_ACC_CLK(MAC_ACC_CLK),
                               .EFPGA_MATHB_CLK_EN(EFPGA_MATHB_CLK_EN),
                               .MAC_OPER_DATA(MAC_OPER_DATA[31:16]),
                               .MAC_COEF_DATA(MAC_COEF_DATA[31:16]),
                               .MAC_ACC_RND(MAC_ACC_RND),
                               .MAC_ACC_CLEAR(MAC_ACC_CLEAR),
                               .MAC_ACC_SAT(MAC_ACC_SAT),
                               .MAC_OUT_SEL(MAC_OUT_SEL),
                               .MAC_TC(MAC_TC),
                               .acc_ff_rstn(acc_ff_rstn)
                               );

  MAC_16BIT #(
              .MULTI_WIDTH(16)
              ) U1_MAC_16BIT ( //16-bit
                               //OUTPUT
                               .MAC_OUT(MAC2_OUT[15:0]),
                               //INPUT
                               .MAC_ACC_CLK(MAC_ACC_CLK),
                               .EFPGA_MATHB_CLK_EN(EFPGA_MATHB_CLK_EN),
                               .MAC_OPER_DATA(MAC_OPER_DATA[15:0]),
                               .MAC_COEF_DATA(MAC_COEF_DATA[15:0]),
                               .MAC_ACC_RND(MAC_ACC_RND),
                               .MAC_ACC_CLEAR(MAC_ACC_CLEAR),
                               .MAC_ACC_SAT(MAC_ACC_SAT),
                               .MAC_OUT_SEL(MAC_OUT_SEL),
                               .MAC_TC(MAC_TC),
                               .acc_ff_rstn(acc_ff_rstn)
                               );

  MAC_8BIT #(
             .MULTI_WIDTH(8)
             ) U0_MAC_8BIT ( //8-bit
                             //OUTPUT
                             .MAC_OUT(MAC3_OUT[7:0]),
                             //INPUT
                             .MAC_ACC_CLK(MAC_ACC_CLK),
                             .EFPGA_MATHB_CLK_EN(EFPGA_MATHB_CLK_EN),
                             .MAC_OPER_DATA(MAC_OPER_DATA[31:24]),
                             .MAC_COEF_DATA(MAC_COEF_DATA[31:24]),
                             .MAC_ACC_RND(MAC_ACC_RND),
                             .MAC_ACC_CLEAR(MAC_ACC_CLEAR),
                             .MAC_ACC_SAT(MAC_ACC_SAT),
                             .MAC_OUT_SEL(MAC_OUT_SEL),
                             .MAC_TC(MAC_TC),
                             .acc_ff_rstn(acc_ff_rstn)
                             );

  MAC_8BIT #(
             .MULTI_WIDTH(8)
             ) U1_MAC_8BIT ( //8-bit
                             //OUTPUT
                             .MAC_OUT(MAC4_OUT[7:0]),
                             //INPUT
                             .MAC_ACC_CLK(MAC_ACC_CLK),
                             .EFPGA_MATHB_CLK_EN(EFPGA_MATHB_CLK_EN),
                             .MAC_OPER_DATA(MAC_OPER_DATA[23:16]),
                             .MAC_COEF_DATA(MAC_COEF_DATA[23:16]),
                             .MAC_ACC_RND(MAC_ACC_RND),
                             .MAC_ACC_CLEAR(MAC_ACC_CLEAR),
                             .MAC_ACC_SAT(MAC_ACC_SAT),
                             .MAC_OUT_SEL(MAC_OUT_SEL),
                             .MAC_TC(MAC_TC),
                             .acc_ff_rstn(acc_ff_rstn)
                             );

  MAC_8BIT #(
             .MULTI_WIDTH(8)
             ) U2_MAC_8BIT ( //8-bit
                             //OUTPUT
                             .MAC_OUT(MAC5_OUT[7:0]),
                             //INPUT
                             .MAC_ACC_CLK(MAC_ACC_CLK),
                             .EFPGA_MATHB_CLK_EN(EFPGA_MATHB_CLK_EN),
                             .MAC_OPER_DATA(MAC_OPER_DATA[15:8]),
                             .MAC_COEF_DATA(MAC_COEF_DATA[15:8]),
                             .MAC_ACC_RND(MAC_ACC_RND),
                             .MAC_ACC_CLEAR(MAC_ACC_CLEAR),
                             .MAC_ACC_SAT(MAC_ACC_SAT),
                             .MAC_OUT_SEL(MAC_OUT_SEL),
                             .MAC_TC(MAC_TC),
                             .acc_ff_rstn(acc_ff_rstn)
                             );

  MAC_8BIT #(
             .MULTI_WIDTH(8)
             ) U3_MAC_8BIT ( //8-bit
                             //OUTPUT
                             .MAC_OUT(MAC6_OUT[7:0]),
                             //INPUT
                             .MAC_ACC_CLK(MAC_ACC_CLK),
                             .EFPGA_MATHB_CLK_EN(EFPGA_MATHB_CLK_EN),
                             .MAC_OPER_DATA(MAC_OPER_DATA[7:0]),
                             .MAC_COEF_DATA(MAC_COEF_DATA[7:0]),
                             .MAC_ACC_RND(MAC_ACC_RND),
                             .MAC_ACC_CLEAR(MAC_ACC_CLEAR),
                             .MAC_ACC_SAT(MAC_ACC_SAT),
                             .MAC_OUT_SEL(MAC_OUT_SEL),
                             .MAC_TC(MAC_TC),
                             .acc_ff_rstn(acc_ff_rstn)
                             );

  MAC_4BIT #(
             .MULTI_WIDTH(4)
             ) U0_MAC_4BIT ( //8-bit
                             //OUTPUT
                             .MAC_OUT(MAC_4_0_OUT[3:0]),
                             //INPUT
                             .MAC_ACC_CLK(MAC_ACC_CLK),
                             .EFPGA_MATHB_CLK_EN(EFPGA_MATHB_CLK_EN),
                             .MAC_OPER_DATA(MAC_OPER_DATA[3:0]),
                             .MAC_COEF_DATA(MAC_COEF_DATA[3:0]),
                             .MAC_ACC_RND(MAC_ACC_RND),
                             .MAC_ACC_CLEAR(MAC_ACC_CLEAR),
                             .MAC_ACC_SAT(MAC_ACC_SAT),
                             .MAC_OUT_SEL(MAC_OUT_SEL),
                             .MAC_TC(MAC_TC),
                             .acc_ff_rstn(acc_ff_rstn)
                             );
  MAC_4BIT #(
             .MULTI_WIDTH(4)
             ) U1_MAC_4BIT ( //8-bit
                             //OUTPUT
                             .MAC_OUT(MAC_4_1_OUT[3:0]),
                             //INPUT
                             .MAC_ACC_CLK(MAC_ACC_CLK),
                             .EFPGA_MATHB_CLK_EN(EFPGA_MATHB_CLK_EN),
                             .MAC_OPER_DATA(MAC_OPER_DATA[7:4]),
                             .MAC_COEF_DATA(MAC_COEF_DATA[7:4]),
                             .MAC_ACC_RND(MAC_ACC_RND),
                             .MAC_ACC_CLEAR(MAC_ACC_CLEAR),
                             .MAC_ACC_SAT(MAC_ACC_SAT),
                             .MAC_OUT_SEL(MAC_OUT_SEL),
                             .MAC_TC(MAC_TC),
                             .acc_ff_rstn(acc_ff_rstn)
                             );
  MAC_4BIT #(
             .MULTI_WIDTH(4)
             ) U2_MAC_4BIT ( //8-bit
                             //OUTPUT
                             .MAC_OUT(MAC_4_2_OUT[3:0]),
                             //INPUT
                             .MAC_ACC_CLK(MAC_ACC_CLK),
                             .EFPGA_MATHB_CLK_EN(EFPGA_MATHB_CLK_EN),
                             .MAC_OPER_DATA(MAC_OPER_DATA[11:8]),
                             .MAC_COEF_DATA(MAC_COEF_DATA[11:8]),
                             .MAC_ACC_RND(MAC_ACC_RND),
                             .MAC_ACC_CLEAR(MAC_ACC_CLEAR),
                             .MAC_ACC_SAT(MAC_ACC_SAT),
                             .MAC_OUT_SEL(MAC_OUT_SEL),
                             .MAC_TC(MAC_TC),
                             .acc_ff_rstn(acc_ff_rstn)
                             );
  MAC_4BIT #(
             .MULTI_WIDTH(4)
             ) U3_MAC_4BIT ( //8-bit
                             //OUTPUT
                             .MAC_OUT(MAC_4_3_OUT[3:0]),
                             //INPUT
                             .MAC_ACC_CLK(MAC_ACC_CLK),
                             .EFPGA_MATHB_CLK_EN(EFPGA_MATHB_CLK_EN),
                             .MAC_OPER_DATA(MAC_OPER_DATA[15:12]),
                             .MAC_COEF_DATA(MAC_COEF_DATA[15:12]),
                             .MAC_ACC_RND(MAC_ACC_RND),
                             .MAC_ACC_CLEAR(MAC_ACC_CLEAR),
                             .MAC_ACC_SAT(MAC_ACC_SAT),
                             .MAC_OUT_SEL(MAC_OUT_SEL),
                             .MAC_TC(MAC_TC),
                             .acc_ff_rstn(acc_ff_rstn)
                             );
  MAC_4BIT #(
             .MULTI_WIDTH(4)
             ) U4_MAC_4BIT ( //8-bit
                             //OUTPUT
                             .MAC_OUT(MAC_4_4_OUT[3:0]),
                             //INPUT
                             .MAC_ACC_CLK(MAC_ACC_CLK),
                             .EFPGA_MATHB_CLK_EN(EFPGA_MATHB_CLK_EN),
                             .MAC_OPER_DATA(MAC_OPER_DATA[19:16]),
                             .MAC_COEF_DATA(MAC_COEF_DATA[19:16]),
                             .MAC_ACC_RND(MAC_ACC_RND),
                             .MAC_ACC_CLEAR(MAC_ACC_CLEAR),
                             .MAC_ACC_SAT(MAC_ACC_SAT),
                             .MAC_OUT_SEL(MAC_OUT_SEL),
                             .MAC_TC(MAC_TC),
                             .acc_ff_rstn(acc_ff_rstn)
                             );
  MAC_4BIT #(
             .MULTI_WIDTH(4)
             ) U5_MAC_4BIT ( //8-bit
                             //OUTPUT
                             .MAC_OUT(MAC_4_5_OUT[3:0]),
                             //INPUT
                             .MAC_ACC_CLK(MAC_ACC_CLK),
                             .EFPGA_MATHB_CLK_EN(EFPGA_MATHB_CLK_EN),
                             .MAC_OPER_DATA(MAC_OPER_DATA[23:20]),
                             .MAC_COEF_DATA(MAC_COEF_DATA[23:20]),
                             .MAC_ACC_RND(MAC_ACC_RND),
                             .MAC_ACC_CLEAR(MAC_ACC_CLEAR),
                             .MAC_ACC_SAT(MAC_ACC_SAT),
                             .MAC_OUT_SEL(MAC_OUT_SEL),
                             .MAC_TC(MAC_TC),
                             .acc_ff_rstn(acc_ff_rstn)
                             );
  MAC_4BIT #(
             .MULTI_WIDTH(4)
             ) U6_MAC_4BIT ( //8-bit
                             //OUTPUT
                             .MAC_OUT(MAC_4_6_OUT[3:0]),
                             //INPUT
                             .MAC_ACC_CLK(MAC_ACC_CLK),
                             .EFPGA_MATHB_CLK_EN(EFPGA_MATHB_CLK_EN),
                             .MAC_OPER_DATA(MAC_OPER_DATA[27:24]),
                             .MAC_COEF_DATA(MAC_COEF_DATA[27:24]),
                             .MAC_ACC_RND(MAC_ACC_RND),
                             .MAC_ACC_CLEAR(MAC_ACC_CLEAR),
                             .MAC_ACC_SAT(MAC_ACC_SAT),
                             .MAC_OUT_SEL(MAC_OUT_SEL),
                             .MAC_TC(MAC_TC),
                             .acc_ff_rstn(acc_ff_rstn)
                             );
  MAC_4BIT #(
             .MULTI_WIDTH(4)
             ) U7_MAC_4BIT ( //8-bit
                             //OUTPUT
                             .MAC_OUT(MAC_4_7_OUT[3:0]),
                             //INPUT
                             .MAC_ACC_CLK(MAC_ACC_CLK),
                             .EFPGA_MATHB_CLK_EN(EFPGA_MATHB_CLK_EN),
                             .MAC_OPER_DATA(MAC_OPER_DATA[31:28]),
                             .MAC_COEF_DATA(MAC_COEF_DATA[31:28]),
                             .MAC_ACC_RND(MAC_ACC_RND),
                             .MAC_ACC_CLEAR(MAC_ACC_CLEAR),
                             .MAC_ACC_SAT(MAC_ACC_SAT),
                             .MAC_OUT_SEL(MAC_OUT_SEL),
                             .MAC_TC(MAC_TC),
                             .acc_ff_rstn(acc_ff_rstn)
                             );

endmodule
