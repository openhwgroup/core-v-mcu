// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

module MAC_32BIT (
  //OUTPUT
  MAC_OUT,
  //INPUT
  MAC_ACC_CLK,
  EFPGA_MATHB_CLK_EN,
  MAC_OPER_DATA,
  MAC_COEF_DATA,
  MAC_ACC_RND,
  MAC_ACC_CLEAR,
  MAC_ACC_SAT,
  MAC_OUT_SEL,
  MAC_TC,
  acc_ff_rstn
);
  parameter MULTI_WIDTH   = 32;
  parameter TC            = 1'b0;

  parameter PAD_ZERO      = MULTI_WIDTH / 4 ;
  parameter DATAIN_WIDTH  = MULTI_WIDTH+PAD_ZERO ;
  parameter ACC_WIDTH     = 2*(MULTI_WIDTH+PAD_ZERO) ;

//OUTPUT
output [31:0] MAC_OUT;

//INPUT
input         MAC_ACC_CLK;
input         EFPGA_MATHB_CLK_EN;
input  [31:0] MAC_OPER_DATA;
input  [31:0] MAC_COEF_DATA;
input         MAC_ACC_RND;
input         MAC_ACC_CLEAR;
input         MAC_ACC_SAT;
input  [5:0]  MAC_OUT_SEL;
input         MAC_TC;
input         acc_ff_rstn;

/*------------------------------*/
/*       Delclaration           */
/*------------------------------*/
reg  [ 5:0] fMAC_OUT_SEL;
reg  [79:0] mux_acc_idata;
reg  [79:0] fmux_acc_idata;
reg  [31:0] MAC_OUT;
reg  [79:0] is_rounded_value;
reg  [79:0] feedback_acc_data;
reg         is_not_saturation;
reg  [31:0] acc_data_out_sel;

wire [79:0] DWMAC_out;
wire        acc_ff_rstn;

/*------------------------------*/
/*          INPUT SYNC          */
/*------------------------------*/
//vincent@20181102always@(posedge MAC_ACC_CLK) begin : DELAY_OF_MAC_OUT_SEL
always@(posedge MAC_ACC_CLK or negedge acc_ff_rstn) begin : DELAY_OF_MAC_OUT_SEL
  if (~acc_ff_rstn)
    fMAC_OUT_SEL <= #0.2 'h0;
  else
    fMAC_OUT_SEL <= #0.2 MAC_OUT_SEL;
end //DELAY_OF_MAC_OUT_SEL

/*------------------------------*/
/*          MAC_UNIT            */
/*------------------------------*/
   wire [7:0] oper_sign, coef_sign;
   assign oper_sign = MAC_TC ? {8{MAC_OPER_DATA[31]}} : 8'b00000000;
   assign coef_sign = MAC_TC ? {8{MAC_COEF_DATA[31]}} : 8'b00000000;
  bw_mac #(
           .A_width (40),
           .B_width (40)
           )
  U_DW02_mac (
              //vincent@20181101.A  ({8'h0,MAC_OPER_DATA[31:0]}),
              //vincent@20181101.B  ({8'h0,MAC_COEF_DATA[31:0]}),
              .A  ({oper_sign,MAC_OPER_DATA[31:0]}),
              .B  ({coef_sign,MAC_COEF_DATA[31:0]}),
              .C  (feedback_acc_data[79:0]),
              .TC (MAC_TC),
              .MAC(DWMAC_out[79:0])
              );
  /*------------------------------*/
/*        LOAD of ACC           */
/*------------------------------*/
always@(*) begin: MUX_OF_IDATA_ACC
  mux_acc_idata = fmux_acc_idata;
case (EFPGA_MATHB_CLK_EN)
    1'b0: mux_acc_idata = fmux_acc_idata;
    1'b1: mux_acc_idata = DWMAC_out;
  endcase
end //MUX_OF_IDATA_ACC

/*------------------------------*/
/*        ACCUMULATOR           */
/*------------------------------*/
//vincent@20181029always@(posedge MAC_ACC_CLK) begin : FF_OF_ACCUMULATOR
//vincent@20181031assign acc_rstn = ~MAC_ACC_CLEAR;

always@(posedge MAC_ACC_CLK or negedge acc_ff_rstn) begin : FF_OF_ACCUMULATOR
  if (~acc_ff_rstn)
    fmux_acc_idata <= #0.2 80'h0;
  else
    fmux_acc_idata <= #0.2 mux_acc_idata;
end //FF_OF_ACCUMULATOR

/*------------------------------*/
/*         ACC_ROUNDED          */
/*------------------------------*/
always@(*) begin : ACC_ROUNDED
  case(MAC_OUT_SEL[5:0])
    6'd1  : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001;
    6'd2  : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0010;
    6'd3  : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0100;
    6'd4  : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1000;
    6'd5  : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_0000;
    6'd6  : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0010_0000;
    6'd7  : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0100_0000;
    6'd8  : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1000_0000;
    6'd9  : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_0000_0000;
    6'd10 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0010_0000_0000;
    6'd11 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0100_0000_0000;
    6'd12 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1000_0000_0000;
    6'd13 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_0000_0000_0000;
    6'd14 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0010_0000_0000_0000;
    6'd15 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0100_0000_0000_0000;
    6'd16 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1000_0000_0000_0000;
    6'd17 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_0000_0000_0000_0000;
    6'd18 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0010_0000_0000_0000_0000;
    6'd19 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0100_0000_0000_0000_0000;
    6'd20 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1000_0000_0000_0000_0000;
    6'd21 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_0000_0000_0000_0000_0000;
    6'd22 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0010_0000_0000_0000_0000_0000;
    6'd23 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0100_0000_0000_0000_0000_0000;
    6'd24 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1000_0000_0000_0000_0000_0000;
    6'd25 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_0000_0000_0000_0000_0000_0000;
    6'd26 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0010_0000_0000_0000_0000_0000_0000;
    6'd27 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0100_0000_0000_0000_0000_0000_0000;
    6'd28 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1000_0000_0000_0000_0000_0000_0000;
    6'd29 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_0000_0000_0000_0000_0000_0000_0000;
    6'd30 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0010_0000_0000_0000_0000_0000_0000_0000;
    6'd31 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0100_0000_0000_0000_0000_0000_0000_0000;
    6'd32 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1000_0000_0000_0000_0000_0000_0000_0000;
    6'd33 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_0000_0000_0000_0000_0000_0000_0000_0000;
    6'd34 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0010_0000_0000_0000_0000_0000_0000_0000_0000;
    6'd35 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0100_0000_0000_0000_0000_0000_0000_0000_0000;
    6'd36 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1000_0000_0000_0000_0000_0000_0000_0000_0000;
    6'd37 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_0000_0000_0000_0000_0000_0000_0000_0000_0000;
    6'd38 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0010_0000_0000_0000_0000_0000_0000_0000_0000_0000;
    6'd39 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0100_0000_0000_0000_0000_0000_0000_0000_0000_0000;
    6'd40 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
    6'd41 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
    6'd42 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0010_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
    6'd43 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0100_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
    6'd44 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
    6'd45 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0001_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
    6'd46 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0010_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
    6'd47 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0100_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
    6'd48 : is_rounded_value = 80'b0000_0000_0000_0000_0000_0000_0000_0000_1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
    default: is_rounded_value = 80'h0;
  endcase
end

/*------------------------------*/
/*         CLR_AND_RND          */
/*------------------------------*/
always@(*) begin: CLR_AND_RND
  if (MAC_ACC_CLEAR == 1'b1)
    feedback_acc_data = 80'h0;
  else if (MAC_ACC_RND == 1'b1)
    feedback_acc_data = is_rounded_value;
  else
    feedback_acc_data = fmux_acc_idata;
end //CLR_AND_RND

/*------------------------------*/
/*     MAC_DATA_OUT_wo_SAT      */
/*------------------------------*/
always@(*) begin : ACC_DATA_OUT_SEL
  case(fMAC_OUT_SEL[5:0])
    6'd0  : acc_data_out_sel = fmux_acc_idata[31:0];
    6'd1  : acc_data_out_sel = fmux_acc_idata[32:1];
    6'd2  : acc_data_out_sel = fmux_acc_idata[33:2];
    6'd3  : acc_data_out_sel = fmux_acc_idata[34:3];
    6'd4  : acc_data_out_sel = fmux_acc_idata[35:4];
    6'd5  : acc_data_out_sel = fmux_acc_idata[36:5];
    6'd6  : acc_data_out_sel = fmux_acc_idata[37:6];
    6'd7  : acc_data_out_sel = fmux_acc_idata[38:7];
    6'd8  : acc_data_out_sel = fmux_acc_idata[39:8];
    6'd9  : acc_data_out_sel = fmux_acc_idata[40:9];
    6'd10 : acc_data_out_sel = fmux_acc_idata[41:10];
    6'd11 : acc_data_out_sel = fmux_acc_idata[42:11];
    6'd12 : acc_data_out_sel = fmux_acc_idata[43:12];
    6'd13 : acc_data_out_sel = fmux_acc_idata[44:13];
    6'd14 : acc_data_out_sel = fmux_acc_idata[45:14];
    6'd15 : acc_data_out_sel = fmux_acc_idata[46:15];
    6'd16 : acc_data_out_sel = fmux_acc_idata[47:16];
    6'd17 : acc_data_out_sel = fmux_acc_idata[48:17];
    6'd18 : acc_data_out_sel = fmux_acc_idata[49:18];
    6'd19 : acc_data_out_sel = fmux_acc_idata[50:19];
    6'd20 : acc_data_out_sel = fmux_acc_idata[51:20];
    6'd21 : acc_data_out_sel = fmux_acc_idata[52:21];
    6'd22 : acc_data_out_sel = fmux_acc_idata[53:22];
    6'd23 : acc_data_out_sel = fmux_acc_idata[54:23];
    6'd24 : acc_data_out_sel = fmux_acc_idata[55:24];
    6'd25 : acc_data_out_sel = fmux_acc_idata[56:25];
    6'd26 : acc_data_out_sel = fmux_acc_idata[57:26];
    6'd27 : acc_data_out_sel = fmux_acc_idata[58:27];
    6'd28 : acc_data_out_sel = fmux_acc_idata[59:28];
    6'd29 : acc_data_out_sel = fmux_acc_idata[60:29];
    6'd30 : acc_data_out_sel = fmux_acc_idata[61:30];
    6'd31 : acc_data_out_sel = fmux_acc_idata[62:31];
    6'd32 : acc_data_out_sel = fmux_acc_idata[63:32];
    6'd33 : acc_data_out_sel = fmux_acc_idata[64:33];
    6'd34 : acc_data_out_sel = fmux_acc_idata[65:34];
    6'd35 : acc_data_out_sel = fmux_acc_idata[66:35];
    6'd36 : acc_data_out_sel = fmux_acc_idata[67:36];
    6'd37 : acc_data_out_sel = fmux_acc_idata[68:37];
    6'd38 : acc_data_out_sel = fmux_acc_idata[69:38];
    6'd39 : acc_data_out_sel = fmux_acc_idata[70:39];
    6'd40 : acc_data_out_sel = fmux_acc_idata[71:40];
    6'd41 : acc_data_out_sel = fmux_acc_idata[72:41];
    6'd42 : acc_data_out_sel = fmux_acc_idata[73:42];
    6'd43 : acc_data_out_sel = fmux_acc_idata[74:43];
    6'd44 : acc_data_out_sel = fmux_acc_idata[75:44];
    6'd45 : acc_data_out_sel = fmux_acc_idata[76:45];
    6'd46 : acc_data_out_sel = fmux_acc_idata[77:46];
    6'd47 : acc_data_out_sel = fmux_acc_idata[78:47];
    6'd48 : acc_data_out_sel = fmux_acc_idata[79:48];
    default : acc_data_out_sel = fmux_acc_idata[31:0];
  endcase
end

/*------------------------------*/
/*           ACC_SAT            */
/*------------------------------*/
//vincent@20181031always@(*) begin : CHECK_SAT_CONDITION
//vincent@20181031  case(fMAC_OUT_SEL[5:0])
//vincent@20181031    6'd0  : is_not_saturation = &fmux_acc_idata[79:32] || !(|fmux_acc_idata[79:32]) ;
//vincent@20181031    6'd1  : is_not_saturation = &fmux_acc_idata[79:33] || !(|fmux_acc_idata[79:33]) ;
//vincent@20181031    6'd2  : is_not_saturation = &fmux_acc_idata[79:34] || !(|fmux_acc_idata[79:34]) ;
//vincent@20181031    6'd3  : is_not_saturation = &fmux_acc_idata[79:35] || !(|fmux_acc_idata[79:35]) ;
//vincent@20181031    6'd4  : is_not_saturation = &fmux_acc_idata[79:36] || !(|fmux_acc_idata[79:36]) ;
//vincent@20181031    6'd5  : is_not_saturation = &fmux_acc_idata[79:37] || !(|fmux_acc_idata[79:37]) ;
//vincent@20181031    6'd6  : is_not_saturation = &fmux_acc_idata[79:38] || !(|fmux_acc_idata[79:38]) ;
//vincent@20181031    6'd7  : is_not_saturation = &fmux_acc_idata[79:39] || !(|fmux_acc_idata[79:39]) ;
//vincent@20181031    6'd8  : is_not_saturation = &fmux_acc_idata[79:40] || !(|fmux_acc_idata[79:40]) ;
//vincent@20181031    6'd9  : is_not_saturation = &fmux_acc_idata[79:41] || !(|fmux_acc_idata[79:41]) ;
//vincent@20181031    6'd10 : is_not_saturation = &fmux_acc_idata[79:42] || !(|fmux_acc_idata[79:42]) ;
//vincent@20181031    6'd11 : is_not_saturation = &fmux_acc_idata[79:43] || !(|fmux_acc_idata[79:43]) ;
//vincent@20181031    6'd12 : is_not_saturation = &fmux_acc_idata[79:44] || !(|fmux_acc_idata[79:44]) ;
//vincent@20181031    6'd13 : is_not_saturation = &fmux_acc_idata[79:45] || !(|fmux_acc_idata[79:45]) ;
//vincent@20181031    6'd14 : is_not_saturation = &fmux_acc_idata[79:46] || !(|fmux_acc_idata[79:46]) ;
//vincent@20181031    6'd15 : is_not_saturation = &fmux_acc_idata[79:47] || !(|fmux_acc_idata[79:47]) ;
//vincent@20181031    6'd16 : is_not_saturation = &fmux_acc_idata[79:48] || !(|fmux_acc_idata[79:48]) ;
//vincent@20181031    6'd17 : is_not_saturation = &fmux_acc_idata[79:49] || !(|fmux_acc_idata[79:49]) ;
//vincent@20181031    6'd18 : is_not_saturation = &fmux_acc_idata[79:50] || !(|fmux_acc_idata[79:50]) ;
//vincent@20181031    6'd19 : is_not_saturation = &fmux_acc_idata[79:51] || !(|fmux_acc_idata[79:51]) ;
//vincent@20181031    6'd20 : is_not_saturation = &fmux_acc_idata[79:52] || !(|fmux_acc_idata[79:52]) ;
//vincent@20181031    6'd21 : is_not_saturation = &fmux_acc_idata[79:53] || !(|fmux_acc_idata[79:53]) ;
//vincent@20181031    6'd22 : is_not_saturation = &fmux_acc_idata[79:54] || !(|fmux_acc_idata[79:54]) ;
//vincent@20181031    6'd23 : is_not_saturation = &fmux_acc_idata[79:55] || !(|fmux_acc_idata[79:55]) ;
//vincent@20181031    6'd24 : is_not_saturation = &fmux_acc_idata[79:56] || !(|fmux_acc_idata[79:56]) ;
//vincent@20181031    6'd25 : is_not_saturation = &fmux_acc_idata[79:57] || !(|fmux_acc_idata[79:57]) ;
//vincent@20181031    6'd26 : is_not_saturation = &fmux_acc_idata[79:58] || !(|fmux_acc_idata[79:58]) ;
//vincent@20181031    6'd27 : is_not_saturation = &fmux_acc_idata[79:59] || !(|fmux_acc_idata[79:59]) ;
//vincent@20181031    6'd28 : is_not_saturation = &fmux_acc_idata[79:60] || !(|fmux_acc_idata[79:60]) ;
//vincent@20181031    6'd29 : is_not_saturation = &fmux_acc_idata[79:61] || !(|fmux_acc_idata[79:61]) ;
//vincent@20181031    6'd30 : is_not_saturation = &fmux_acc_idata[79:62] || !(|fmux_acc_idata[79:62]) ;
//vincent@20181031    6'd31 : is_not_saturation = &fmux_acc_idata[79:63] || !(|fmux_acc_idata[79:63]) ;
//vincent@20181031    6'd32 : is_not_saturation = &fmux_acc_idata[79:64] || !(|fmux_acc_idata[79:64]) ;
//vincent@20181031    6'd33 : is_not_saturation = &fmux_acc_idata[79:65] || !(|fmux_acc_idata[79:65]) ;
//vincent@20181031    6'd34 : is_not_saturation = &fmux_acc_idata[79:66] || !(|fmux_acc_idata[79:66]) ;
//vincent@20181031    6'd35 : is_not_saturation = &fmux_acc_idata[79:67] || !(|fmux_acc_idata[79:67]) ;
//vincent@20181031    6'd36 : is_not_saturation = &fmux_acc_idata[79:68] || !(|fmux_acc_idata[79:68]) ;
//vincent@20181031    6'd37 : is_not_saturation = &fmux_acc_idata[79:69] || !(|fmux_acc_idata[79:69]) ;
//vincent@20181031    6'd38 : is_not_saturation = &fmux_acc_idata[79:70] || !(|fmux_acc_idata[79:70]) ;
//vincent@20181031    6'd39 : is_not_saturation = &fmux_acc_idata[79:71] || !(|fmux_acc_idata[79:71]) ;
//vincent@20181031    6'd40 : is_not_saturation = &fmux_acc_idata[79:72] || !(|fmux_acc_idata[79:72]) ;
//vincent@20181031    6'd41 : is_not_saturation = &fmux_acc_idata[79:73] || !(|fmux_acc_idata[79:73]) ;
//vincent@20181031    6'd42 : is_not_saturation = &fmux_acc_idata[79:74] || !(|fmux_acc_idata[79:74]) ;
//vincent@20181031    6'd43 : is_not_saturation = &fmux_acc_idata[79:75] || !(|fmux_acc_idata[79:75]) ;
//vincent@20181031    6'd44 : is_not_saturation = &fmux_acc_idata[79:76] || !(|fmux_acc_idata[79:76]) ;
//vincent@20181031    6'd45 : is_not_saturation = &fmux_acc_idata[79:77] || !(|fmux_acc_idata[79:77]) ;
//vincent@20181031    6'd46 : is_not_saturation = &fmux_acc_idata[79:78] || !(|fmux_acc_idata[79:78]) ;
//vincent@20181031    default : is_not_saturation = &fmux_acc_idata[79:32] || !(|fmux_acc_idata[79:32]) ;
//vincent@20181031  endcase
//vincent@20181031end

always@(*) begin : CHECK_SAT_CONDITION
  case(fMAC_OUT_SEL[5:0])
   6'd0  : is_not_saturation = &fmux_acc_idata[79:31] || !(|fmux_acc_idata[79:31]) || (~MAC_TC & !(|fmux_acc_idata[79:32])) ;
   6'd1  : is_not_saturation = &fmux_acc_idata[79:32] || !(|fmux_acc_idata[79:32]) || (~MAC_TC & !(|fmux_acc_idata[79:33])) ;
   6'd2  : is_not_saturation = &fmux_acc_idata[79:33] || !(|fmux_acc_idata[79:33]) || (~MAC_TC & !(|fmux_acc_idata[79:34])) ;
   6'd3  : is_not_saturation = &fmux_acc_idata[79:34] || !(|fmux_acc_idata[79:34]) || (~MAC_TC & !(|fmux_acc_idata[79:35])) ;
   6'd4  : is_not_saturation = &fmux_acc_idata[79:35] || !(|fmux_acc_idata[79:35]) || (~MAC_TC & !(|fmux_acc_idata[79:36])) ;
   6'd5  : is_not_saturation = &fmux_acc_idata[79:36] || !(|fmux_acc_idata[79:36]) || (~MAC_TC & !(|fmux_acc_idata[79:37])) ;
   6'd6  : is_not_saturation = &fmux_acc_idata[79:37] || !(|fmux_acc_idata[79:37]) || (~MAC_TC & !(|fmux_acc_idata[79:38])) ;
   6'd7  : is_not_saturation = &fmux_acc_idata[79:38] || !(|fmux_acc_idata[79:38]) || (~MAC_TC & !(|fmux_acc_idata[79:39])) ;
   6'd8  : is_not_saturation = &fmux_acc_idata[79:39] || !(|fmux_acc_idata[79:39]) || (~MAC_TC & !(|fmux_acc_idata[79:40])) ;
   6'd9  : is_not_saturation = &fmux_acc_idata[79:40] || !(|fmux_acc_idata[79:40]) || (~MAC_TC & !(|fmux_acc_idata[79:41])) ;
   6'd10 : is_not_saturation = &fmux_acc_idata[79:41] || !(|fmux_acc_idata[79:41]) || (~MAC_TC & !(|fmux_acc_idata[79:42])) ;
   6'd11 : is_not_saturation = &fmux_acc_idata[79:42] || !(|fmux_acc_idata[79:42]) || (~MAC_TC & !(|fmux_acc_idata[79:43])) ;
   6'd12 : is_not_saturation = &fmux_acc_idata[79:43] || !(|fmux_acc_idata[79:43]) || (~MAC_TC & !(|fmux_acc_idata[79:44])) ;
   6'd13 : is_not_saturation = &fmux_acc_idata[79:44] || !(|fmux_acc_idata[79:44]) || (~MAC_TC & !(|fmux_acc_idata[79:45])) ;
   6'd14 : is_not_saturation = &fmux_acc_idata[79:45] || !(|fmux_acc_idata[79:45]) || (~MAC_TC & !(|fmux_acc_idata[79:46])) ;
   6'd15 : is_not_saturation = &fmux_acc_idata[79:46] || !(|fmux_acc_idata[79:46]) || (~MAC_TC & !(|fmux_acc_idata[79:47])) ;
   6'd16 : is_not_saturation = &fmux_acc_idata[79:47] || !(|fmux_acc_idata[79:47]) || (~MAC_TC & !(|fmux_acc_idata[79:48])) ;
   6'd17 : is_not_saturation = &fmux_acc_idata[79:48] || !(|fmux_acc_idata[79:48]) || (~MAC_TC & !(|fmux_acc_idata[79:49])) ;
   6'd18 : is_not_saturation = &fmux_acc_idata[79:49] || !(|fmux_acc_idata[79:49]) || (~MAC_TC & !(|fmux_acc_idata[79:50])) ;
   6'd19 : is_not_saturation = &fmux_acc_idata[79:50] || !(|fmux_acc_idata[79:50]) || (~MAC_TC & !(|fmux_acc_idata[79:51])) ;
   6'd20 : is_not_saturation = &fmux_acc_idata[79:51] || !(|fmux_acc_idata[79:51]) || (~MAC_TC & !(|fmux_acc_idata[79:52])) ;
   6'd21 : is_not_saturation = &fmux_acc_idata[79:52] || !(|fmux_acc_idata[79:52]) || (~MAC_TC & !(|fmux_acc_idata[79:53])) ;
   6'd22 : is_not_saturation = &fmux_acc_idata[79:53] || !(|fmux_acc_idata[79:53]) || (~MAC_TC & !(|fmux_acc_idata[79:54])) ;
   6'd23 : is_not_saturation = &fmux_acc_idata[79:54] || !(|fmux_acc_idata[79:54]) || (~MAC_TC & !(|fmux_acc_idata[79:55])) ;
   6'd24 : is_not_saturation = &fmux_acc_idata[79:55] || !(|fmux_acc_idata[79:55]) || (~MAC_TC & !(|fmux_acc_idata[79:56])) ;
   6'd25 : is_not_saturation = &fmux_acc_idata[79:56] || !(|fmux_acc_idata[79:56]) || (~MAC_TC & !(|fmux_acc_idata[79:57])) ;
   6'd26 : is_not_saturation = &fmux_acc_idata[79:57] || !(|fmux_acc_idata[79:57]) || (~MAC_TC & !(|fmux_acc_idata[79:58])) ;
   6'd27 : is_not_saturation = &fmux_acc_idata[79:58] || !(|fmux_acc_idata[79:58]) || (~MAC_TC & !(|fmux_acc_idata[79:59])) ;
   6'd28 : is_not_saturation = &fmux_acc_idata[79:59] || !(|fmux_acc_idata[79:59]) || (~MAC_TC & !(|fmux_acc_idata[79:60])) ;
   6'd29 : is_not_saturation = &fmux_acc_idata[79:60] || !(|fmux_acc_idata[79:60]) || (~MAC_TC & !(|fmux_acc_idata[79:61])) ;
   6'd30 : is_not_saturation = &fmux_acc_idata[79:61] || !(|fmux_acc_idata[79:61]) || (~MAC_TC & !(|fmux_acc_idata[79:62])) ;
   6'd31 : is_not_saturation = &fmux_acc_idata[79:62] || !(|fmux_acc_idata[79:62]) || (~MAC_TC & !(|fmux_acc_idata[79:63])) ;
   6'd32 : is_not_saturation = &fmux_acc_idata[79:63] || !(|fmux_acc_idata[79:63]) || (~MAC_TC & !(|fmux_acc_idata[79:64])) ;
   6'd33 : is_not_saturation = &fmux_acc_idata[79:64] || !(|fmux_acc_idata[79:64]) || (~MAC_TC & !(|fmux_acc_idata[79:65])) ;
   6'd34 : is_not_saturation = &fmux_acc_idata[79:65] || !(|fmux_acc_idata[79:65]) || (~MAC_TC & !(|fmux_acc_idata[79:66])) ;
   6'd35 : is_not_saturation = &fmux_acc_idata[79:66] || !(|fmux_acc_idata[79:66]) || (~MAC_TC & !(|fmux_acc_idata[79:67])) ;
   6'd36 : is_not_saturation = &fmux_acc_idata[79:67] || !(|fmux_acc_idata[79:67]) || (~MAC_TC & !(|fmux_acc_idata[79:68])) ;
   6'd37 : is_not_saturation = &fmux_acc_idata[79:68] || !(|fmux_acc_idata[79:68]) || (~MAC_TC & !(|fmux_acc_idata[79:69])) ;
   6'd38 : is_not_saturation = &fmux_acc_idata[79:69] || !(|fmux_acc_idata[79:69]) || (~MAC_TC & !(|fmux_acc_idata[79:70])) ;
   6'd39 : is_not_saturation = &fmux_acc_idata[79:70] || !(|fmux_acc_idata[79:70]) || (~MAC_TC & !(|fmux_acc_idata[79:71])) ;
   6'd40 : is_not_saturation = &fmux_acc_idata[79:71] || !(|fmux_acc_idata[79:71]) || (~MAC_TC & !(|fmux_acc_idata[79:72])) ;
   6'd41 : is_not_saturation = &fmux_acc_idata[79:72] || !(|fmux_acc_idata[79:72]) || (~MAC_TC & !(|fmux_acc_idata[79:73])) ;
   6'd42 : is_not_saturation = &fmux_acc_idata[79:73] || !(|fmux_acc_idata[79:73]) || (~MAC_TC & !(|fmux_acc_idata[79:74])) ;
   6'd43 : is_not_saturation = &fmux_acc_idata[79:74] || !(|fmux_acc_idata[79:74]) || (~MAC_TC & !(|fmux_acc_idata[79:75])) ;
   6'd44 : is_not_saturation = &fmux_acc_idata[79:75] || !(|fmux_acc_idata[79:75]) || (~MAC_TC & !(|fmux_acc_idata[79:76])) ;
   6'd45 : is_not_saturation = &fmux_acc_idata[79:76] || !(|fmux_acc_idata[79:76]) || (~MAC_TC & !(|fmux_acc_idata[79:77])) ;
   6'd46 : is_not_saturation = &fmux_acc_idata[79:77] || !(|fmux_acc_idata[79:77]) || (~MAC_TC & !(|fmux_acc_idata[79:78])) ;
   6'd47 : is_not_saturation = &fmux_acc_idata[79:78] || !(|fmux_acc_idata[79:78]) || (~MAC_TC & !(fmux_acc_idata[79])) ;
   default : is_not_saturation = &fmux_acc_idata[79:31] || !(|fmux_acc_idata[79:31]) || (~MAC_TC & !(|fmux_acc_idata[79:32])) ;
  endcase
end

always@(*) begin : ACC_SAT_DATA_OUT
  if (MAC_ACC_SAT)
    if ( is_not_saturation )
      MAC_OUT = acc_data_out_sel;
    else begin
      if (MAC_TC == 0)
        MAC_OUT = 32'hffffffff;
      else if (fmux_acc_idata[79] == 1'b1)
        MAC_OUT = {1'b1,31'h0};
      else
        MAC_OUT = {1'b0,31'h7fff_ffff};
    end
  else
     MAC_OUT = acc_data_out_sel;
end


endmodule
