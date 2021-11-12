// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

module MATH_BLOCK
 (
//input
		  reset, // active high
  //OUTPUT
  FMATHB_EFPGA_MAC_OUT,
  //INPUT
  EFPGA2MATHB_CLK,
//vincent@20181019  ASIC2MATHB_CLK,
//vincent@20181101  EFPGA_MATHB_CLK_SEL,
  EFPGA_MATHB_CLK_EN,
//vincent@20181102EFPGA_MATHB_CLK_defPin,

  TPRAM_MATHB_OPER_R_DATA,
  EFPGA_MATHB_OPER_DATA,
  EFPGA_MATHB_OPER_defPin,
  EFPGA_MATHB_OPER_SEL,

  TPRAM_MATHB_COEF_R_DATA,
  EFPGA_MATHB_COEF_DATA,
  EFPGA_MATHB_COEF_defPin,
  EFPGA_MATHB_COEF_SEL,

  EFPGA_MATHB_TC_defPin,
  EFPGA_MATHB_MAC_OUT_SEL,

  EFPGA_MATHB_MAC_ACC_SAT,
  EFPGA_MATHB_MAC_ACC_CLEAR,
  EFPGA_MATHB_MAC_ACC_RND,

  EFPGA_MATHB_DATAOUT_SEL
);
input reset;
output [31:0] FMATHB_EFPGA_MAC_OUT;

//CLK_SEL
input         EFPGA2MATHB_CLK;
//vincent@20181019input         ASIC2MATHB_CLK;
//vincent@20181101input         EFPGA_MATHB_CLK_SEL;
input         EFPGA_MATHB_CLK_EN;
//vincent@20181102input         EFPGA_MATHB_CLK_defPin;

//OPER
input  [31:0] TPRAM_MATHB_OPER_R_DATA;
input  [31:0] EFPGA_MATHB_OPER_DATA;
input  [ 1:0] EFPGA_MATHB_OPER_defPin;
input         EFPGA_MATHB_OPER_SEL;

//COEF
input  [31:0] TPRAM_MATHB_COEF_R_DATA;
input  [31:0] EFPGA_MATHB_COEF_DATA;
input  [ 1:0] EFPGA_MATHB_COEF_defPin;
input         EFPGA_MATHB_COEF_SEL;

//MAC_ARRAY
input         EFPGA_MATHB_TC_defPin;
input  [ 5:0] EFPGA_MATHB_MAC_OUT_SEL;

//MAC_ARRAY.MAC_TOP.ACC_CTL
input         EFPGA_MATHB_MAC_ACC_SAT;
input         EFPGA_MATHB_MAC_ACC_CLEAR;
input         EFPGA_MATHB_MAC_ACC_RND;

//MAC Output Select
input  [ 1:0] EFPGA_MATHB_DATAOUT_SEL;

/*------------------------------*/

reg           OPER_SEL_OUT;
reg           COEF_SEL_OUT;
//vincent@20181019reg           sel_clk_src;
reg           sel_clk_type;
reg           MAC_ACC_CLK;
reg    [ 7:0] MUX3_MATHB_DATAOUT;
reg    [ 7:0] MUX2_MATHB_DATAOUT;
reg    [ 7:0] MUX1_MATHB_DATAOUT;
reg    [ 7:0] MUX0_MATHB_DATAOUT;
reg    [31:0] FMATHB_EFPGA_MAC_OUT;

wire   [31:0] MAC_OPER_DATA;
wire   [31:0] MAC_COEF_DATA;
wire   [31:0] MAC0_OUT;
wire   [15:0] MAC1_OUT;
wire   [15:0] MAC2_OUT;
wire   [ 7:0] MAC3_OUT;
wire   [ 7:0] MAC4_OUT;
wire   [ 7:0] MAC5_OUT;
wire   [ 7:0] MAC6_OUT;
   wire [3:0] MAC_4_0_OUT;
   wire [3:0] MAC_4_1_OUT;
   wire [3:0] MAC_4_2_OUT;
   wire [3:0] MAC_4_3_OUT;
   wire [3:0] MAC_4_4_OUT;
   wire [3:0] MAC_4_5_OUT;
   wire [3:0] MAC_4_6_OUT;
   wire [3:0] MAC_4_7_OUT;
  wire        MAC_TC;


wire   [31:0] MATHB_EFPGA_MAC_OUT;
wire          acc_ff_rstn;

/*------------------------------*/
/*            TOP               */
/*------------------------------*/
always@(*) begin : OPER_SEL
  case (EFPGA_MATHB_OPER_defPin[1:0])
    2'b00: OPER_SEL_OUT = 1'b0; //Data is from eFPGA
    2'b01: OPER_SEL_OUT = 1'b0;	//Data is from eFPGA
    2'b10: OPER_SEL_OUT = 1'b1; //Data is from TPRAM
    2'b11: OPER_SEL_OUT = EFPGA_MATHB_OPER_SEL;
    default: OPER_SEL_OUT = 1'b0;
  endcase
end //OPER_SEL

assign MAC_OPER_DATA = OPER_SEL_OUT ? TPRAM_MATHB_OPER_R_DATA : EFPGA_MATHB_OPER_DATA; //MUX_OPER_DATAIN

always@(*) begin : COEF_SEL
  case (EFPGA_MATHB_COEF_defPin[1:0])
    2'b00: COEF_SEL_OUT = 1'b0; //Data is from eFPGA
    2'b01: COEF_SEL_OUT = 1'b0; //Data is from eFPGA
    2'b10: COEF_SEL_OUT = 1'b1; //Data is from TPRAM
    2'b11: COEF_SEL_OUT = EFPGA_MATHB_COEF_SEL;
    default: COEF_SEL_OUT = 1'b0;
  endcase
end //COEF_SEL

assign MAC_COEF_DATA = COEF_SEL_OUT ? TPRAM_MATHB_COEF_R_DATA : EFPGA_MATHB_COEF_DATA; //MUX_COEF_DATAIN


assign MAC_TC        = EFPGA_MATHB_TC_defPin;

/*------------------------------*/
/*        CLOCK_SEL             */
/*------------------------------*/
//vincent@20181019always@(*) begin: MUX_CLK_SRC
//vincent@20181019  sel_clk_src = ASIC2MATHB_CLK;
//vincent@20181019  case (EFPGA_MATHB_CLK_SEL)
//vincent@20181019    1'b0: sel_clk_src = EFPGA2MATHB_CLK;
//vincent@20181019    1'b1: sel_clk_src = ASIC2MATHB_CLK;
//vincent@20181019  endcase
//vincent@20181019end

//vincent@20181031wire  sel_clk_src = EFPGA2MATHB_CLK;

//vincent@20181031always@(*) begin: MUX_CLK_TYPE
//vincent@20181031  sel_clk_type = sel_clk_src;
//vincent@20181031  case (EFPGA_MATHB_CLK_defPin)
//vincent@20181031    1'b0: sel_clk_type = sel_clk_src; //Synchronous
//vincent@20181031    1'b1: sel_clk_type = 1'b0;        //Asynchronous
//vincent@20181031  endcase
//vincent@20181031end

//vincent@20181031always@(*) begin: CG_ACC_CLK
//vincent@20181031  if (EFPGA_MATHB_CLK_EN)
//vincent@20181031    MAC_ACC_CLK = sel_clk_type;
//vincent@20181031  else
//vincent@20181031    MAC_ACC_CLK = 1'b0;
//vincent@20181031end

/*------------------------------*/
/*        MAC_ARRAY             */
/*------------------------------*/
   assign acc_ff_rstn = ~reset ; // (EFPGA_MATHB_DATAOUT_SEL == 2'b11);

MAC_ARRAY   U_MAC_ARRAY (
                         //OUTPUT
                         .MAC0_OUT(MAC0_OUT[31:0]),
                         .MAC1_OUT(MAC1_OUT[15:0]),
                         .MAC2_OUT(MAC2_OUT[15:0]),
                         .MAC3_OUT(MAC3_OUT[ 7:0]),
                         .MAC4_OUT(MAC4_OUT[ 7:0]),
                         .MAC5_OUT(MAC5_OUT[ 7:0]),
                         .MAC6_OUT(MAC6_OUT[ 7:0]),
		                     .MAC_4_0_OUT(MAC_4_0_OUT),
		                     .MAC_4_1_OUT(MAC_4_1_OUT),
		                     .MAC_4_2_OUT(MAC_4_2_OUT),
		                     .MAC_4_3_OUT(MAC_4_3_OUT),
		                     .MAC_4_4_OUT(MAC_4_4_OUT),
		                     .MAC_4_5_OUT(MAC_4_5_OUT),
		                     .MAC_4_6_OUT(MAC_4_6_OUT),
		                     .MAC_4_7_OUT(MAC_4_7_OUT),
                         //INPUT
                         .MAC_OPER_DATA(MAC_OPER_DATA[31:0]),
                         .MAC_COEF_DATA(MAC_COEF_DATA[31:0]),

                         //vincent@20181031  .MAC_ACC_CLK(MAC_ACC_CLK),
                         .MAC_ACC_CLK(EFPGA2MATHB_CLK),

                         .EFPGA_MATHB_CLK_EN(EFPGA_MATHB_CLK_EN),
                         .MAC_ACC_CLEAR(EFPGA_MATHB_MAC_ACC_CLEAR),
                         .MAC_ACC_RND(EFPGA_MATHB_MAC_ACC_RND),
                         .MAC_ACC_SAT(EFPGA_MATHB_MAC_ACC_SAT),
                         .MAC_OUT_SEL(EFPGA_MATHB_MAC_OUT_SEL),
                         .MAC_TC(MAC_TC),
                         .acc_ff_rstn(acc_ff_rstn)
                         );

  /*------------------------------*/
  /*      MATHB_DATAOUT_SEL       */
  /*------------------------------*/
  always@(*) begin: MUX3_MATHB
    case (EFPGA_MATHB_DATAOUT_SEL[1:0])
      2'b00: MUX3_MATHB_DATAOUT[7:0]  = MAC0_OUT[31:24];  //32-bit x1 mode
      2'b01: MUX3_MATHB_DATAOUT[7:0]  = MAC1_OUT[15: 8];  //16-bit x2 mode
      2'b10: MUX3_MATHB_DATAOUT[7:0]  = MAC3_OUT[ 7: 0];  // 8-bit x4 mode
      2'b11: MUX3_MATHB_DATAOUT[7:0]  = {MAC_4_7_OUT,MAC_4_6_OUT}; // 4 bit mode
      //    default: MUX3_MATHB_DATAOUT[7:0] = MAC0_OUT[31:24]; //32-bit x1 mode
    endcase
  end

  always@(*) begin: MUX2_MATHB
    case (EFPGA_MATHB_DATAOUT_SEL[1:0])
      2'b00: MUX2_MATHB_DATAOUT[7:0]  = MAC0_OUT[23:16];  //32-bit x1 mode
      2'b01: MUX2_MATHB_DATAOUT[7:0]  = MAC1_OUT[ 7: 0];  //16-bit x2 mode
      2'b10: MUX2_MATHB_DATAOUT[7:0]  = MAC4_OUT[ 7: 0];  // 8-bit x4 mode
      2'b11: MUX2_MATHB_DATAOUT[7:0]  = {MAC_4_5_OUT,MAC_4_4_OUT}; // 4 bit mode
      //    default: MUX2_MATHB_DATAOUT[7:0] = MAC0_OUT[23:16]; //32-bit x1 mode
    endcase
  end

  always@(*) begin: MUX1_MATHB
    case (EFPGA_MATHB_DATAOUT_SEL[1:0])
      2'b00: MUX1_MATHB_DATAOUT[7:0]  = MAC0_OUT[15: 8];  //32-bit x1 mode
      2'b01: MUX1_MATHB_DATAOUT[7:0]  = MAC2_OUT[15: 8];  //16-bit x2 mode
      2'b10: MUX1_MATHB_DATAOUT[7:0]  = MAC5_OUT[ 7: 0];  // 8-bit x4 mode
      2'b11: MUX1_MATHB_DATAOUT[7:0]  = {MAC_4_3_OUT,MAC_4_2_OUT}; // 4 bit mode
      //    default: MUX1_MATHB_DATAOUT[7:0] = MAC0_OUT[15: 8]; //32-bit x1 mode
    endcase
  end

  always@(*) begin: MUX0_MATHB
    case (EFPGA_MATHB_DATAOUT_SEL[1:0])
      2'b00: MUX0_MATHB_DATAOUT[7:0]  = MAC0_OUT[ 7: 0];  //32-bit x1 mode
      2'b01: MUX0_MATHB_DATAOUT[7:0]  = MAC2_OUT[ 7: 0];  //16-bit x2 mode
      2'b10: MUX0_MATHB_DATAOUT[7:0]  = MAC6_OUT[ 7: 0];  // 8-bit x4 mode
      2'b11: MUX0_MATHB_DATAOUT[7:0]  = {MAC_4_1_OUT,MAC_4_0_OUT}; // 4 bit mode
      default: MUX0_MATHB_DATAOUT[7:0] = MAC0_OUT[ 7: 0]; //32-bit x1 mode
    endcase
  end

  assign MATHB_EFPGA_MAC_OUT = {MUX3_MATHB_DATAOUT,MUX2_MATHB_DATAOUT,MUX1_MATHB_DATAOUT,MUX0_MATHB_DATAOUT};

  always@(posedge EFPGA2MATHB_CLK or negedge acc_ff_rstn) begin : FF_OF_MAC_OUT
    if (~acc_ff_rstn)
      FMATHB_EFPGA_MAC_OUT <= #0.2 32'h0;
    else
      FMATHB_EFPGA_MAC_OUT <= #0.2 MATHB_EFPGA_MAC_OUT;
  end //


endmodule
