// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
module MAC_16BIT  (
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
  parameter MULTI_WIDTH   = 16;
  parameter TC            = 1'b0;

  parameter PAD_ZERO      = MULTI_WIDTH / 4 ;
  parameter DATAIN_WIDTH  = MULTI_WIDTH+PAD_ZERO ;
  parameter ACC_WIDTH     = 2*(MULTI_WIDTH+PAD_ZERO) ;

//OUTPUT
output [15:0] MAC_OUT;

//INPUT
input         MAC_ACC_CLK;
input         EFPGA_MATHB_CLK_EN;
input  [15:0] MAC_OPER_DATA;
input  [15:0] MAC_COEF_DATA;
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
reg  [39:0] mux_acc_idata;
reg  [39:0] fmux_acc_idata;
reg  [15:0] MAC_OUT;
reg  [39:0] is_rounded_value;
reg  [39:0] feedback_acc_data;
reg         is_not_saturation;
reg  [15:0] acc_data_out_sel;

wire [39:0] DWMAC_out;
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
   wire [3:0] oper_sign, coef_sign;
   assign oper_sign = MAC_TC ? {4{MAC_OPER_DATA[15]}} : 4'b0000;
   assign coef_sign = MAC_TC ? {4{MAC_COEF_DATA[15]}} : 4'b0000;
  bw_mac #(
           .A_width (20),
           .B_width (20)
               )
  U_DW02_mac (
              //vincent@20181101.A  ({4'h0,MAC_OPER_DATA[15:0]}),
              //vincent@20181101.B  ({4'h0,MAC_COEF_DATA[15:0]}),
              .A  ({oper_sign,MAC_OPER_DATA[15:0]}),
              .B  ({coef_sign,MAC_COEF_DATA[15:0]}),
              .C  (feedback_acc_data[39:0]),
              .TC (MAC_TC),
              .MAC(DWMAC_out[39:0])
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
    fmux_acc_idata <= #0.2 40'h0;
  else
    fmux_acc_idata <= #0.2 mux_acc_idata;
end //FF_OF_ACCUMULATOR

/*------------------------------*/
/*         ACC_ROUNDED          */
/*------------------------------*/
always@(*) begin : ACC_ROUNDED
  case(MAC_OUT_SEL[5:0])
    6'd1  : is_rounded_value = 40'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0001;
    6'd2  : is_rounded_value = 40'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0010;
    6'd3  : is_rounded_value = 40'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0100;
    6'd4  : is_rounded_value = 40'b0000_0000_0000_0000_0000_0000_0000_0000_0000_1000;
    6'd5  : is_rounded_value = 40'b0000_0000_0000_0000_0000_0000_0000_0000_0001_0000;
    6'd6  : is_rounded_value = 40'b0000_0000_0000_0000_0000_0000_0000_0000_0010_0000;
    6'd7  : is_rounded_value = 40'b0000_0000_0000_0000_0000_0000_0000_0000_0100_0000;
    6'd8  : is_rounded_value = 40'b0000_0000_0000_0000_0000_0000_0000_0000_1000_0000;
    6'd9  : is_rounded_value = 40'b0000_0000_0000_0000_0000_0000_0000_0001_0000_0000;
    6'd10 : is_rounded_value = 40'b0000_0000_0000_0000_0000_0000_0000_0010_0000_0000;
    6'd11 : is_rounded_value = 40'b0000_0000_0000_0000_0000_0000_0000_0100_0000_0000;
    6'd12 : is_rounded_value = 40'b0000_0000_0000_0000_0000_0000_0000_1000_0000_0000;
    6'd13 : is_rounded_value = 40'b0000_0000_0000_0000_0000_0000_0001_0000_0000_0000;
    6'd14 : is_rounded_value = 40'b0000_0000_0000_0000_0000_0000_0010_0000_0000_0000;
    6'd15 : is_rounded_value = 40'b0000_0000_0000_0000_0000_0000_0100_0000_0000_0000;
    6'd16 : is_rounded_value = 40'b0000_0000_0000_0000_0000_0000_1000_0000_0000_0000;
    6'd17 : is_rounded_value = 40'b0000_0000_0000_0000_0000_0001_0000_0000_0000_0000;
    6'd18 : is_rounded_value = 40'b0000_0000_0000_0000_0000_0010_0000_0000_0000_0000;
    6'd19 : is_rounded_value = 40'b0000_0000_0000_0000_0000_0100_0000_0000_0000_0000;
    6'd20 : is_rounded_value = 40'b0000_0000_0000_0000_0000_1000_0000_0000_0000_0000;
    6'd21 : is_rounded_value = 40'b0000_0000_0000_0000_0001_0000_0000_0000_0000_0000;
    6'd22 : is_rounded_value = 40'b0000_0000_0000_0000_0010_0000_0000_0000_0000_0000;
    6'd23 : is_rounded_value = 40'b0000_0000_0000_0000_0100_0000_0000_0000_0000_0000;
    6'd24 : is_rounded_value = 40'b0000_0000_0000_0000_1000_0000_0000_0000_0000_0000;
    default: is_rounded_value = 40'h0;
  endcase
end


/*------------------------------*/
/*         CLR_AND_RND          */
/*------------------------------*/
always@(*) begin: CLR_AND_RND
  if (MAC_ACC_CLEAR == 1'b1)
    feedback_acc_data = 40'h0;
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
    6'd0  : acc_data_out_sel = fmux_acc_idata[15:0];
    6'd1  : acc_data_out_sel = fmux_acc_idata[16:1];
    6'd2  : acc_data_out_sel = fmux_acc_idata[17:2];
    6'd3  : acc_data_out_sel = fmux_acc_idata[18:3];
    6'd4  : acc_data_out_sel = fmux_acc_idata[19:4];
    6'd5  : acc_data_out_sel = fmux_acc_idata[20:5];
    6'd6  : acc_data_out_sel = fmux_acc_idata[21:6];
    6'd7  : acc_data_out_sel = fmux_acc_idata[22:7];
    6'd8  : acc_data_out_sel = fmux_acc_idata[23:8];
    6'd9  : acc_data_out_sel = fmux_acc_idata[24:9];
    6'd10 : acc_data_out_sel = fmux_acc_idata[25:10];
    6'd11 : acc_data_out_sel = fmux_acc_idata[26:11];
    6'd12 : acc_data_out_sel = fmux_acc_idata[27:12];
    6'd13 : acc_data_out_sel = fmux_acc_idata[28:13];
    6'd14 : acc_data_out_sel = fmux_acc_idata[29:14];
    6'd15 : acc_data_out_sel = fmux_acc_idata[30:15];
    6'd16 : acc_data_out_sel = fmux_acc_idata[31:16];
    6'd17 : acc_data_out_sel = fmux_acc_idata[32:17];
    6'd18 : acc_data_out_sel = fmux_acc_idata[33:18];
    6'd19 : acc_data_out_sel = fmux_acc_idata[34:19];
    6'd20 : acc_data_out_sel = fmux_acc_idata[35:20];
    6'd21 : acc_data_out_sel = fmux_acc_idata[36:21];
    6'd22 : acc_data_out_sel = fmux_acc_idata[37:22];
    6'd23 : acc_data_out_sel = fmux_acc_idata[38:23];
    6'd24 : acc_data_out_sel = fmux_acc_idata[39:24];
    default : acc_data_out_sel = fmux_acc_idata[15:0];
  endcase
end

/*------------------------------*/
/*           ACC_SAT            */
/*------------------------------*/
always@(*) begin : CHECK_SAT_CONDITION
  case(fMAC_OUT_SEL[5:0])
    6'd0  : is_not_saturation = &fmux_acc_idata[39:15] || !(|fmux_acc_idata[39:15]) || (~MAC_TC & !(|fmux_acc_idata[39:16])) ;
    6'd1  : is_not_saturation = &fmux_acc_idata[39:16] || !(|fmux_acc_idata[39:16]) || (~MAC_TC & !(|fmux_acc_idata[39:17])) ;
    6'd2  : is_not_saturation = &fmux_acc_idata[39:17] || !(|fmux_acc_idata[39:17]) || (~MAC_TC & !(|fmux_acc_idata[39:18])) ;
    6'd3  : is_not_saturation = &fmux_acc_idata[39:18] || !(|fmux_acc_idata[39:18]) || (~MAC_TC & !(|fmux_acc_idata[39:19])) ;
    6'd4  : is_not_saturation = &fmux_acc_idata[39:19] || !(|fmux_acc_idata[39:19]) || (~MAC_TC & !(|fmux_acc_idata[39:20])) ;
    6'd5  : is_not_saturation = &fmux_acc_idata[39:20] || !(|fmux_acc_idata[39:20]) || (~MAC_TC & !(|fmux_acc_idata[39:21])) ;
    6'd6  : is_not_saturation = &fmux_acc_idata[39:21] || !(|fmux_acc_idata[39:21]) || (~MAC_TC & !(|fmux_acc_idata[39:22])) ;
    6'd7  : is_not_saturation = &fmux_acc_idata[39:22] || !(|fmux_acc_idata[39:22]) || (~MAC_TC & !(|fmux_acc_idata[39:23])) ;
    6'd8  : is_not_saturation = &fmux_acc_idata[39:23] || !(|fmux_acc_idata[39:23]) || (~MAC_TC & !(|fmux_acc_idata[39:24])) ;
    6'd9  : is_not_saturation = &fmux_acc_idata[39:24] || !(|fmux_acc_idata[39:24]) || (~MAC_TC & !(|fmux_acc_idata[39:25])) ;
    6'd10 : is_not_saturation = &fmux_acc_idata[39:25] || !(|fmux_acc_idata[39:25]) || (~MAC_TC & !(|fmux_acc_idata[39:26])) ;
    6'd11 : is_not_saturation = &fmux_acc_idata[39:26] || !(|fmux_acc_idata[39:26]) || (~MAC_TC & !(|fmux_acc_idata[39:27])) ;
    6'd12 : is_not_saturation = &fmux_acc_idata[39:27] || !(|fmux_acc_idata[39:27]) || (~MAC_TC & !(|fmux_acc_idata[39:28])) ;
    6'd13 : is_not_saturation = &fmux_acc_idata[39:28] || !(|fmux_acc_idata[39:28]) || (~MAC_TC & !(|fmux_acc_idata[39:29])) ;
    6'd14 : is_not_saturation = &fmux_acc_idata[39:29] || !(|fmux_acc_idata[39:29]) || (~MAC_TC & !(|fmux_acc_idata[39:30])) ;
    6'd15 : is_not_saturation = &fmux_acc_idata[39:30] || !(|fmux_acc_idata[39:30]) || (~MAC_TC & !(|fmux_acc_idata[39:31])) ;
    6'd16 : is_not_saturation = &fmux_acc_idata[39:31] || !(|fmux_acc_idata[39:31]) || (~MAC_TC & !(|fmux_acc_idata[39:32])) ;
    6'd17 : is_not_saturation = &fmux_acc_idata[39:32] || !(|fmux_acc_idata[39:32]) || (~MAC_TC & !(|fmux_acc_idata[39:33])) ;
    6'd18 : is_not_saturation = &fmux_acc_idata[39:33] || !(|fmux_acc_idata[39:33]) || (~MAC_TC & !(|fmux_acc_idata[39:34])) ;
    6'd19 : is_not_saturation = &fmux_acc_idata[39:34] || !(|fmux_acc_idata[39:34]) || (~MAC_TC & !(|fmux_acc_idata[39:35])) ;
    6'd20 : is_not_saturation = &fmux_acc_idata[39:35] || !(|fmux_acc_idata[39:35]) || (~MAC_TC & !(|fmux_acc_idata[39:36])) ;
    6'd21 : is_not_saturation = &fmux_acc_idata[39:36] || !(|fmux_acc_idata[39:36]) || (~MAC_TC & !(|fmux_acc_idata[39:37])) ;
    6'd22 : is_not_saturation = &fmux_acc_idata[39:37] || !(|fmux_acc_idata[39:37]) || (~MAC_TC & !(|fmux_acc_idata[39:38])) ;
    6'd23 : is_not_saturation = &fmux_acc_idata[39:38] || !(|fmux_acc_idata[39:38]) || (~MAC_TC & !(fmux_acc_idata[39])) ;
    default : is_not_saturation = &fmux_acc_idata[39:15] || !(|fmux_acc_idata[39:15]) || (~MAC_TC & !(|fmux_acc_idata[39:16])) ;
  endcase
end

always@(*) begin : ACC_SAT_DATA_OUT
  if (MAC_ACC_SAT)
    if ( is_not_saturation )
      MAC_OUT = acc_data_out_sel;
    else begin
      if (MAC_TC == 0)
        MAC_OUT = 16'hffff;
      else if (fmux_acc_idata[39] == 1'b1)
        MAC_OUT = {1'b1,15'h0};
      else
        MAC_OUT = {1'b0,15'h7fff};
    end
  else
     MAC_OUT = acc_data_out_sel;
end


endmodule
