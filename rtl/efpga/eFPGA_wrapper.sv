// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
`include "pulp_soc_defines.sv"
module eFPGA_wrapper (
    output logic [ 3:0] test_fb_spe_out,
    input        [ 3:0] test_fb_spe_in,
    input  logic        MLATCH,
    POR,
    STM,
    input  logic        M_0_,
    M_1_,
    M_2_,
    M_3_,
    M_4_,
    M_5_,
    input  logic [31:0] fcb_bl_din,
    output logic [31:0] fcb_bl_dout,
    input  logic [15:0] fcb_bl_pwrgate,
    input  logic        fcb_blclk,
    input  logic        fcb_cload_din_sel,
    input  logic        fcb_din_int_l_only,
    input  logic        fcb_din_int_r_only,
    input  logic        fcb_din_slc_tb_int,
    input  logic        fcb_fb_iso_enb,
    input  logic [15:0] fcb_iso_en,
    input  logic        fcb_pchg_b,
    input  logic [15:0] fcb_pi_pwr,
    output logic        fcb_pif_en,
    input  logic [15:0] fcb_prog,
    input  logic        fcb_prog_ifx,
    input  logic        fcb_pwr_gate,
    input  logic        fcb_re,
    input  logic [15:0] fcb_vlp_clkdis,
    input  logic        fcb_vlp_clkdis_ifx,
    input  logic [15:0] fcb_vlp_pwrdis,
    input  logic        fcb_vlp_pwrdis_ifx,
    input  logic [15:0] fcb_vlp_srdis,
    input  logic        fcb_vlp_srdis_ifx,
    input  logic        fcb_we,
    input  logic        fcb_we_int,
    input  logic [ 2:0] fcb_wl_cload_sel,
    input  logic [ 5:0] fcb_wl_din,
    input  logic        fcb_wl_en,
    input  logic        fcb_wl_int_din_sel,
    input  logic [ 7:0] fcb_wl_pwrgate,
    input  logic        fcb_wl_resetb,
    input  logic [15:0] fcb_wl_sel,
    input  logic        fcb_wl_sel_tb_int,
    input  logic        fcb_wlclk,

    output logic [`N_FPGAIO-1:0] fpgaio_oe,
    output logic [`N_FPGAIO-1:0] fpgaio_out,

    input logic                 CLK0,
    CLK1,
    CLK2,
    CLK3,
    CLK4,
    CLK5,
    input logic [`N_FPGAIO-1:0] fpgaio_in,

    input logic [19:0] lint_ADDR,

    input  logic        lint_WEN,
    lint_REQ,
    input  logic [ 3:0] lint_BE,
    input  logic [31:0] lint_WDATA,
    input  logic [31:0] control_in,
    output logic        apb_fpga_clk_o,
    input  logic        RESET_LB,
    RESET_LT,
    RESET_RB,
    RESET_RT,

    input  logic [31:0] tcdm_rdata_p3,
    tcdm_rdata_p2,
    input  logic [31:0] tcdm_rdata_p1,
    tcdm_rdata_p0,
    output logic        tcdm_clk_p0,
    tcdm_clk_p1,
    tcdm_clk_p2,
    tcdm_clk_p3,

    input logic tcdm_gnt_p3,
    tcdm_gnt_p2,
    tcdm_gnt_p1,
    tcdm_gnt_p0,
    input logic tcdm_fmo_p3,
    tcdm_fmo_p2,
    tcdm_fmo_p1,
    tcdm_fmo_p0,
    input logic tcdm_valid_p3,
    tcdm_valid_p2,
    input logic tcdm_valid_p1,
    tcdm_valid_p0,

    output logic [31:0] status_out,
    output logic [ 7:0] version,
    output logic [15:0] events_o,

    output logic [31:0] lint_RDATA,
    output logic        lint_GNT,
    lint_VALID,

    output logic [31:0] tcdm_wdata_p3,
    tcdm_wdata_p2,
    output logic [31:0] tcdm_wdata_p1,
    tcdm_wdata_p0,
    output logic [19:0] tcdm_addr_p3,
    tcdm_addr_p2,
    output logic [19:0] tcdm_addr_p1,
    tcdm_addr_p0,

    output logic       tcdm_req_p3,
    tcdm_req_p2,
    tcdm_req_p1,
    tcdm_req_p0,
    output logic       tcdm_wen_p3,
    tcdm_wen_p2,
    tcdm_wen_p1,
    tcdm_wen_p0,
    output logic [3:0] tcdm_be_p3,
    tcdm_be_p2,
    tcdm_be_p1,
    tcdm_be_p0


);

  wire [79:0] fpga_out, fpga_in, fpga_oe;

  wire m0_m0_clk, m0_m0_clken, m0_m0_tc;
  wire m0_m0_osel, m0_m0_csel;
  wire m0_m0_clr, m0_m0_rnd, m0_m0_sat, m0_m0_reset;
  wire [31:0] m0_m0_oper_in, m0_m0_coef_in;
  wire [ 1:0] m0_m0_mode;
  wire [ 5:0] m0_m0_outsel;
  wire [31:0] m0_m0_dataout;

  wire m0_m1_clk, m0_m1_clken, m0_m1_tc;
  wire m0_m1_osel, m0_m1_csel;
  wire m0_m1_clr, m0_m1_rnd, m0_m1_sat, m0_m1_reset;
  wire [31:0] m0_m1_oper_in, m0_m1_coef_in;
  wire [ 1:0] m0_m1_mode;
  wire [ 5:0] m0_m1_outsel;
  wire [31:0] m0_m1_dataout;

  wire m1_m0_clk, m1_m0_clken, m1_m0_tc;
  wire m1_m0_osel, m1_m0_csel;
  wire m1_m0_clr, m1_m0_rnd, m1_m0_sat, m1_m0_reset;
  wire [31:0] m1_m0_oper_in, m1_m0_coef_in;
  wire [ 1:0] m1_m0_mode;
  wire [ 5:0] m1_m0_outsel;
  wire [31:0] m1_m0_dataout;

  wire m1_m1_clk, m1_m1_clken, m1_m1_tc;
  wire m1_m1_osel, m1_m1_csel;
  wire m1_m1_clr, m1_m1_rnd, m1_m1_sat, m1_m1_reset;
  wire [31:0] m1_m1_oper_in, m1_m1_coef_in;
  wire [ 1:0] m1_m1_mode;
  wire [ 5:0] m1_m1_outsel;
  wire [31:0] m1_m1_dataout;

  wire m0_oper0_rclk, m0_oper0_wclk, m0_oper0_we, m0_oper0_wdsel;
  wire [1:0] m0_oper0_rmode, m0_oper0_wmode;
  wire [31:0] m0_oper0_rdata, m0_oper0_wdata;
  wire [11:0] m0_oper0_raddr, m0_oper0_waddr;

  wire m0_oper1_rclk, m0_oper1_wclk, m0_oper1_we, m0_oper1_wdsel;
  wire [1:0] m0_oper1_rmode, m0_oper1_wmode;
  wire [31:0] m0_oper1_rdata, m0_oper1_wdata;
  wire [11:0] m0_oper1_raddr, m0_oper1_waddr;

  wire m0_coef_rclk, m0_coef_wclk, m0_coef_we, m0_coef_wdsel;
  wire [1:0] m0_coef_rmode, m0_coef_wmode;
  wire [31:0] m0_coef_rdata, m0_coef_wdata;
  wire [11:0] m0_coef_raddr, m0_coef_waddr;
  wire m0_oper0_powerdn, m0_oper1_powerdn, m0_coef_powerdn;

  wire m1_oper0_rclk, m1_oper0_wclk, m1_oper0_we, m1_oper0_wdsel;
  wire [1:0] m1_oper0_rmode, m1_oper0_wmode;
  wire [31:0] m1_oper0_rdata, m1_oper0_wdata;
  wire [11:0] m1_oper0_raddr, m1_oper0_waddr;

  wire m1_oper1_rclk, m1_oper1_wclk, m1_oper1_we, m1_oper1_wdsel;
  wire [1:0] m1_oper1_rmode, m1_oper1_wmode;
  wire [31:0] m1_oper1_rdata, m1_oper1_wdata;
  wire [11:0] m1_oper1_raddr, m1_oper1_waddr;

  wire m1_coef_rclk, m1_coef_wclk, m1_coef_we, m1_coef_wdsel;
  wire [1:0] m1_coef_rmode, m1_coef_wmode;
  wire [31:0] m1_coef_rdata, m1_coef_wdata;
  wire [11:0] m1_coef_raddr, m1_coef_waddr;
  wire m1_oper0_powerdn, m1_oper1_powerdn, m1_coef_powerdn;

  assign fpga_in = {{(80 - `N_FPGAIO) {1'b0}}, fpgaio_in};
  assign fpgaio_oe = fpga_oe[`N_FPGAIO-1:0];
  assign fpgaio_out = fpga_out[`N_FPGAIO-1:0];

  A2_design Arnold2_Design (  // use this to go to A2F/F2A
      //top Arnold2_Design (  // use this to connect rtl directly
      // ouputs to FCB

      // SOC signals
      .control_in(control_in),
      .status_out(status_out),
      .version(version),
      .fpgaio_oe(fpga_oe),  // ouput
      .fpgaio_out(fpga_out),  // ouput
      .fpgaio_in(fpgo_in),  // input
      .events_o(events_o),  // output

      //.PRDATA(),//apb_fpga_prdata),
      //.PREADY(),//apb_fpga_ready_o),
      //.PSLVERR(),//apb_fpga_pslverr_o),
      .lint_RDATA(lint_RDATA),
      .lint_GNT(lint_GNT),
      .lint_VALID(lint_VALID),
      .tcdm_addr_p3(tcdm_addr_p3),
      .tcdm_addr_p2(tcdm_addr_p2),
      .tcdm_addr_p1(tcdm_addr_p1),
      .tcdm_addr_p0(tcdm_addr_p0),
      .tcdm_wdata_p3(tcdm_wdata_p3),
      .tcdm_wdata_p2(tcdm_wdata_p2),
      .tcdm_wdata_p1(tcdm_wdata_p1),
      .tcdm_wdata_p0(tcdm_wdata_p0),
      .tcdm_req_p3(tcdm_req_p3),
      .tcdm_wen_p3(tcdm_wen_p3),
      .tcdm_req_p2(tcdm_req_p2),
      .tcdm_wen_p2(tcdm_wen_p2),
      .tcdm_req_p1(tcdm_req_p1),
      .tcdm_wen_p1(tcdm_wen_p1),
      .tcdm_req_p0(tcdm_req_p0),
      .tcdm_wen_p0(tcdm_wen_p0),

      .tcdm_clk_p0(tcdm_clk_p0),
      .tcdm_clk_p1(tcdm_clk_p1),
      .tcdm_clk_p2(tcdm_clk_p2),
      .tcdm_clk_p3(tcdm_clk_p3),
      .lint_clk(apb_fpga_clk_o),

      .tcdm_be_p3(tcdm_be_p3),
      .tcdm_be_p2(tcdm_be_p2),
      .tcdm_be_p1(tcdm_be_p1),
      .tcdm_be_p0(tcdm_be_p0),
      .CLK({CLK5, CLK4, CLK3, CLK2, CLK1, CLK0}),
      .lint_ADDR(lint_ADDR),
      .lint_BE(lint_BE),
      .lint_WDATA(lint_WDATA),
      .lint_WEN(lint_WEN),
      .lint_REQ(lint_REQ),
      //.PWDATA(apb_fpga_pwdata_i),
      //.PADDR(apb_fpga_addr_i),
      //.PENABLE(apb_fpga_enable_i),
      //.PSEL(apb_fpga_psel_i),
      //.PWRITE(apb_fpga_pwrite_i),
      .RESET({RESET_LB, RESET_LT, RESET_RT, RESET_RB}),
      .tcdm_rdata_p3(tcdm_rdata_p3),
      .tcdm_rdata_p2(tcdm_rdata_p2),
      .tcdm_rdata_p1(tcdm_rdata_p1),
      .tcdm_rdata_p0(tcdm_rdata_p0),
      .tcdm_gnt_p3(tcdm_gnt_p3),
      .tcdm_gnt_p2(tcdm_gnt_p2),
      .tcdm_gnt_p1(tcdm_gnt_p1),
      .tcdm_gnt_p0(tcdm_gnt_p0),
      .tcdm_fmo_p3(tcdm_fmo_p3),
      .tcdm_fmo_p2(tcdm_fmo_p2),
      .tcdm_fmo_p1(tcdm_fmo_p1),
      .tcdm_fmo_p0(tcdm_fmo_p0),
      .tcdm_valid_p3(tcdm_valid_p3),
      .tcdm_valid_p2(tcdm_valid_p2),
      .tcdm_valid_p1(tcdm_valid_p1),
      .tcdm_valid_p0(tcdm_valid_p0),

      .m0_m0_clk(m0_m0_clk),
      .m0_m0_clken(m0_m0_clken),
      .m0_m0_tc(m0_m0_tc),
      .m0_m0_osel(m0_m0_osel),
      .m0_m0_csel(m0_m0_csel),
      .m0_m0_clr(m0_m0_clr),
      .m0_m0_rnd(m0_m0_rnd),
      .m0_m0_sat(m0_m0_sat),
      .m0_m0_reset(m0_m0_reset),
      .m0_m0_oper_in(m0_m0_oper_in),
      .m0_m0_coef_in(m0_m0_coef_in),
      .m0_m0_mode(m0_m0_mode),
      .m0_m0_outsel(m0_m0_outsel),
      .m0_m0_dataout(m0_m0_dataout),

      .m0_m1_clk(m0_m1_clk),
      .m0_m1_clken(m0_m1_clken),
      .m0_m1_tc(m0_m1_tc),
      .m0_m1_osel(m0_m1_osel),
      .m0_m1_csel(m0_m1_csel),
      .m0_m1_clr(m0_m1_clr),
      .m0_m1_rnd(m0_m1_rnd),
      .m0_m1_sat(m0_m1_sat),
      .m0_m1_reset(m0_m1_reset),
      .m0_m1_oper_in(m0_m1_oper_in),
      .m0_m1_coef_in(m0_m1_coef_in),
      .m0_m1_mode(m0_m1_mode),
      .m0_m1_outsel(m0_m1_outsel),
      .m0_m1_dataout(m0_m1_dataout),


      .m0_oper0_rclk(m0_oper0_rclk),
      .m0_oper0_wclk(m0_oper0_wclk),
      .m0_oper0_we(m0_oper0_we),
      .m0_oper0_wdsel(m0_oper0_wdsel),
      .m0_oper0_rmode(m0_oper0_rmode),
      .m0_oper0_wmode(m0_oper0_wmode),
      .m0_oper0_rdata(m0_oper0_rdata),
      .m0_oper0_wdata(m0_oper0_wdata),
      .m0_oper0_raddr(m0_oper0_raddr),
      .m0_oper0_waddr(m0_oper0_waddr),
      .m0_oper0_powerdn(m0_oper0_powerdn),

      .m0_oper1_rclk(m0_oper1_rclk),
      .m0_oper1_wclk(m0_oper1_wclk),
      .m0_oper1_we(m0_oper1_we),
      .m0_oper1_wdsel(m0_oper1_wdsel),
      .m0_oper1_rmode(m0_oper1_rmode),
      .m0_oper1_wmode(m0_oper1_wmode),
      .m0_oper1_rdata(m0_oper1_rdata),
      .m0_oper1_wdata(m0_oper1_wdata),
      .m0_oper1_raddr(m0_oper1_raddr),
      .m0_oper1_waddr(m0_oper1_waddr),
      .m0_oper1_powerdn(m0_oper1_powerdn),

      .m0_coef_rclk(m0_coef_rclk),
      .m0_coef_wclk(m0_coef_wclk),
      .m0_coef_we(m0_coef_we),
      .m0_coef_wdsel(m0_coef_wdsel),
      .m0_coef_rmode(m0_coef_rmode),
      .m0_coef_wmode(m0_coef_wmode),
      .m0_coef_rdata(m0_coef_rdata),
      .m0_coef_wdata(m0_coef_wdata),
      .m0_coef_raddr(m0_coef_raddr),
      .m0_coef_waddr(m0_coef_waddr),
      .m0_coef_powerdn(m0_coef_powerdn),

      .m1_m0_clk(m1_m0_clk),
      .m1_m0_clken(m1_m0_clken),
      .m1_m0_tc(m1_m0_tc),
      .m1_m0_osel(m1_m0_osel),
      .m1_m0_csel(m1_m0_csel),
      .m1_m0_clr(m1_m0_clr),
      .m1_m0_rnd(m1_m0_rnd),
      .m1_m0_sat(m1_m0_sat),
      .m1_m0_reset(m1_m0_reset),
      .m1_m0_oper_in(m1_m0_oper_in),
      .m1_m0_coef_in(m1_m0_coef_in),
      .m1_m0_mode(m1_m0_mode),
      .m1_m0_outsel(m1_m0_outsel),
      .m1_m0_dataout(m1_m0_dataout),

      .m1_m1_clk(m1_m1_clk),
      .m1_m1_clken(m1_m1_clken),
      .m1_m1_tc(m1_m1_tc),
      .m1_m1_osel(m1_m1_osel),
      .m1_m1_csel(m1_m1_csel),
      .m1_m1_clr(m1_m1_clr),
      .m1_m1_rnd(m1_m1_rnd),
      .m1_m1_sat(m1_m1_sat),
      .m1_m1_reset(m1_m1_reset),
      .m1_m1_oper_in(m1_m1_oper_in),
      .m1_m1_coef_in(m1_m1_coef_in),
      .m1_m1_mode(m1_m1_mode),
      .m1_m1_outsel(m1_m1_outsel),
      .m1_m1_dataout(m1_m1_dataout),


      .m1_oper0_rclk(m1_oper0_rclk),
      .m1_oper0_wclk(m1_oper0_wclk),
      .m1_oper0_we(m1_oper0_we),
      .m1_oper0_wdsel(m1_oper0_wdsel),
      .m1_oper0_rmode(m1_oper0_rmode),
      .m1_oper0_wmode(m1_oper0_wmode),
      .m1_oper0_rdata(m1_oper0_rdata),
      .m1_oper0_wdata(m1_oper0_wdata),
      .m1_oper0_raddr(m1_oper0_raddr),
      .m1_oper0_waddr(m1_oper0_waddr),
      .m1_oper0_powerdn(m1_oper0_powerdn),

      .m1_oper1_rclk(m1_oper1_rclk),
      .m1_oper1_wclk(m1_oper1_wclk),
      .m1_oper1_we(m1_oper1_we),
      .m1_oper1_wdsel(m1_oper1_wdsel),
      .m1_oper1_rmode(m1_oper1_rmode),
      .m1_oper1_wmode(m1_oper1_wmode),
      .m1_oper1_rdata(m1_oper1_rdata),
      .m1_oper1_wdata(m1_oper1_wdata),
      .m1_oper1_raddr(m1_oper1_raddr),
      .m1_oper1_waddr(m1_oper1_waddr),
      .m1_oper1_powerdn(m1_oper1_powerdn),

      .m1_coef_rclk(m1_coef_rclk),
      .m1_coef_wclk(m1_coef_wclk),
      .m1_coef_we(m1_coef_we),
      .m1_coef_wdsel(m1_coef_wdsel),
      .m1_coef_rmode(m1_coef_rmode),
      .m1_coef_wmode(m1_coef_wmode),
      .m1_coef_rdata(m1_coef_rdata),
      .m1_coef_wdata(m1_coef_wdata),
      .m1_coef_raddr(m1_coef_raddr),
      .m1_coef_waddr(m1_coef_waddr),
      .m1_coef_powerdn(m1_coef_powerdn)
      /*                       
                                 .fb_spe_out   (test_fb_spe_out),
                                 .fcb_bl_dout     (fcb_bl_dout),

                                 .parallel_cfg    (fcb_pif_en),
                                 
                                 
                                 // Inputs
                                 .M_0_             (M_0_),
                                 .M_1_             (M_1_),
                                 .M_2_             (M_2_),
                                 .M_3_             (M_3_),
                                 .M_4_             (M_4_),
                                 .M_5_             (M_5_),
                                 .MLATCH           (MLATCH),
 
                                 .BL_CLK           (fcb_blclk),
                                 .BL_DIN_0_        (fcb_bl_din[0]),
                                 .BL_DIN_10_       (fcb_bl_din[10]),
                                 .BL_DIN_11_       (fcb_bl_din[11]),
                                 .BL_DIN_12_       (fcb_bl_din[12]),
                                 .BL_DIN_13_       (fcb_bl_din[13]),
                                 .BL_DIN_14_       (fcb_bl_din[14]),
                                 .BL_DIN_15_       (fcb_bl_din[15]),
                                 .BL_DIN_16_       (fcb_bl_din[16]),
                                 .BL_DIN_17_       (fcb_bl_din[17]),
                                 .BL_DIN_18_       (fcb_bl_din[18]),
                                 .BL_DIN_19_       (fcb_bl_din[19]),
                                 .BL_DIN_1_        (fcb_bl_din[1]),
                                 .BL_DIN_20_       (fcb_bl_din[20]),
                                 .BL_DIN_21_       (fcb_bl_din[21]),
                                 .BL_DIN_22_       (fcb_bl_din[22]),
                                 .BL_DIN_23_       (fcb_bl_din[23]),
                                 .BL_DIN_24_       (fcb_bl_din[24]),
                                 .BL_DIN_25_       (fcb_bl_din[25]),
                                 .BL_DIN_26_       (fcb_bl_din[26]),
                                 .BL_DIN_27_       (fcb_bl_din[27]),
                                 .BL_DIN_28_       (fcb_bl_din[28]),
                                 .BL_DIN_29_       (fcb_bl_din[29]),
                                 .BL_DIN_2_        (fcb_bl_din[2]),
                                 .BL_DIN_30_       (fcb_bl_din[30]),
                                 .BL_DIN_31_       (fcb_bl_din[31]),
                                 .BL_DIN_3_        (fcb_bl_din[3]),
                                 .BL_DIN_4_        (fcb_bl_din[4]),
                                 .BL_DIN_5_        (fcb_bl_din[5]),
                                 .BL_DIN_6_        (fcb_bl_din[6]),
                                 .BL_DIN_7_        (fcb_bl_din[7]),
                                 .BL_DIN_8_        (fcb_bl_din[8]),
                                 .BL_DIN_9_        (fcb_bl_din[9]),
                                 .BL_PWRGATE_0_    (fcb_bl_pwrgate[0]),
                                 .BL_PWRGATE_1_    (fcb_bl_pwrgate[1]),
                                 .BL_PWRGATE_2_    (fcb_bl_pwrgate[2]),
                                 .BL_PWRGATE_3_    (fcb_bl_pwrgate[3]),
                                 .CLOAD_DIN_SEL    (fcb_cload_din_sel),
                                 .DIN_INT_L_ONLY   (fcb_din_int_l_only),
                                 .DIN_INT_R_ONLY   (fcb_din_int_r_only),
                                 .DIN_SLC_TB_INT   (fcb_din_slc_tb_int),
                                 .FB_ISO_ENB       (fcb_fb_iso_enb),
                                 .FB_SPE_IN_0_     (test_fb_spe_in[0]),
                                 .FB_SPE_IN_1_     (test_fb_spe_in[1]),
                                 .FB_SPE_IN_2_     (test_fb_spe_in[2]),
                                 .FB_SPE_IN_3_     (test_fb_spe_in[3]),
                                 .ISO_EN_0_        (fcb_iso_en[0]),
                                 .ISO_EN_1_        (fcb_iso_en[1]),
                                 .ISO_EN_2_        (fcb_iso_en[2]),
                                 .ISO_EN_3_        (fcb_iso_en[3]),
                                 .NB               (),
                                 .PB               (),
                                 .PCHG_B           (fcb_pchg_b),
                                 .PI_PWR_0_        (fcb_pi_pwr[0]),
                                 .PI_PWR_1_        (fcb_pi_pwr[1]),
                                 .PI_PWR_2_        (fcb_pi_pwr[2]),
                                 .PI_PWR_3_        (fcb_pi_pwr[3]),
                                 .POR              (POR),
                                 .PROG_0_          (fcb_prog[0]),
                                 .PROG_1_          (fcb_prog[1]),
                                 .PROG_2_          (fcb_prog[2]),
                                 .PROG_3_          (fcb_prog[3]),
                                 .PROG_IFX         (fcb_prog_ifx),
                                 .PWR_GATE         (fcb_pwr_gate),
                                 .RE               (fcb_re),
                                 .STM              (STM),
                                 .VLP_CLKDIS_0_    (fcb_vlp_clkdis[0]),
                                 .VLP_CLKDIS_1_    (fcb_vlp_clkdis[1]),
                                 .VLP_CLKDIS_2_    (fcb_vlp_clkdis[2]),
                                 .VLP_CLKDIS_3_    (fcb_vlp_clkdis[3]),
                                 .VLP_CLKDIS_IFX   (fcb_vlp_clkdis_ifx),
                                 .VLP_PWRDIS_0_    (fcb_vlp_pwrdis[0]),
                                 .VLP_PWRDIS_1_    (fcb_vlp_pwrdis[1]),
                                 .VLP_PWRDIS_2_    (fcb_vlp_pwrdis[2]),
                                 .VLP_PWRDIS_3_    (fcb_vlp_pwrdis[3]),
                                 .VLP_PWRDIS_IFX   (fcb_vlp_pwrdis_ifx),
                                 .VLP_SRDIS_0_     (fcb_vlp_srdis[0]),
                                 .VLP_SRDIS_1_     (fcb_vlp_srdis[1]),
                                 .VLP_SRDIS_2_     (fcb_vlp_srdis[2]),
                                 .VLP_SRDIS_3_     (fcb_vlp_srdis[3]),
                                 .VLP_SRDIS_IFX    (fcb_vlp_srdis_ifx),
                                 .WE               (fcb_we),
                                 .WE_INT           (fcb_we_int),
                                 .WL_CLK           (fcb_wlclk),
                                 .WL_CLOAD_SEL_0_  (fcb_wl_cload_sel[0]),
                                 .WL_CLOAD_SEL_1_  (fcb_wl_cload_sel[1]),
                                 .WL_CLOAD_SEL_2_  (fcb_wl_cload_sel[2]),
                                 .WL_DIN_0_        (fcb_wl_din[0]),
                                 .WL_DIN_1_        (fcb_wl_din[1]),
                                 .WL_DIN_2_        (fcb_wl_din[2]),
                                 .WL_DIN_3_        (fcb_wl_din[3]),
                                 .WL_DIN_4_        (fcb_wl_din[4]),
                                 .WL_DIN_5_        (fcb_wl_din[5]),
                                 .WL_EN            (fcb_wl_en),
                                 .WL_INT_DIN_SEL   (fcb_wl_int_din_sel),
                                 .WL_PWRGATE_0_    (fcb_wl_pwrgate[0]),
                                 .WL_PWRGATE_1_    (fcb_wl_pwrgate[1]),
                                 .WL_RESETB        (fcb_wl_resetb),
                                 .WL_SEL_0_        (fcb_wl_sel[0]),
                                 .WL_SEL_1_        (fcb_wl_sel[1]),
                                 .WL_SEL_2_        (fcb_wl_sel[2]),
                                 .WL_SEL_3_        (fcb_wl_sel[3]),
                                 .WL_SEL_TB_INT    (fcb_wl_sel_tb_int),
*/
  );

  A2_MATH_UNIT M0 (
      .m0_clk(m0_m0_clk),
      .m0_clken(m0_m0_clken),
      .m0_tc(m0_m0_tc),
      .m0_osel(m0_m0_osel),
      .m0_csel(m0_m0_csel),
      .m0_clr(m0_m0_clr),
      .m0_rnd(m0_m0_rnd),
      .m0_sat(m0_m0_sat),
      .m0_reset(m0_m0_reset),
      .m0_oper_in(m0_m0_oper_in),
      .m0_coef_in(m0_m0_coef_in),
      .m0_mode(m0_m0_mode),
      .m0_outsel(m0_m0_outsel),
      .m0_dataout(m0_m0_dataout),

      .m1_clk(m0_m1_clk),
      .m1_clken(m0_m1_clken),
      .m1_tc(m0_m1_tc),
      .m1_osel(m0_m1_osel),
      .m1_csel(m0_m1_csel),
      .m1_clr(m0_m1_clr),
      .m1_rnd(m0_m1_rnd),
      .m1_sat(m0_m1_sat),
      .m1_reset(m0_m1_reset),
      .m1_oper_in(m0_m1_oper_in),
      .m1_coef_in(m0_m1_coef_in),
      .m1_mode(m0_m1_mode),
      .m1_outsel(m0_m1_outsel),
      .m1_dataout(m0_m1_dataout),


      .oper0_rclk(m0_oper0_rclk),
      .oper0_wclk(m0_oper0_wclk),
      .oper0_we(m0_oper0_we),
      .oper0_wdsel(m0_oper0_wdsel),
      .oper0_rmode(m0_oper0_rmode),
      .oper0_wmode(m0_oper0_wmode),
      .oper0_rdata(m0_oper0_rdata),
      .oper0_wdata(m0_oper0_wdata),
      .oper0_raddr(m0_oper0_raddr),
      .oper0_waddr(m0_oper0_waddr),
      .oper0_pwrdn(m0_oper0_powerdn),

      .oper1_rclk(m0_oper1_rclk),
      .oper1_wclk(m0_oper1_wclk),
      .oper1_we(m0_oper1_we),
      .oper1_wdsel(m0_oper1_wdsel),
      .oper1_rmode(m0_oper1_rmode),
      .oper1_wmode(m0_oper1_wmode),
      .oper1_rdata(m0_oper1_rdata),
      .oper1_wdata(m0_oper1_wdata),
      .oper1_raddr(m0_oper1_raddr),
      .oper1_waddr(m0_oper1_waddr),
      .oper1_pwrdn(m0_oper1_powerdn),

      .coef_rclk(m0_coef_rclk),
      .coef_wclk(m0_coef_wclk),
      .coef_we(m0_coef_we),
      .coef_wdsel(m0_coef_wdsel),
      .coef_rmode(m0_coef_rmode),
      .coef_wmode(m0_coef_wmode),
      .coef_rdata(m0_coef_rdata),
      .coef_wdata(m0_coef_wdata),
      .coef_raddr(m0_coef_raddr),
      .coef_waddr(m0_coef_waddr),
      .coef_pwrdn(m0_coef_powerdn)
  );
  A2_MATH_UNIT M1 (
      .m0_clk(m1_m0_clk),
      .m0_clken(m1_m0_clken),
      .m0_tc(m1_m0_tc),
      .m0_osel(m1_m0_osel),
      .m0_csel(m1_m0_csel),
      .m0_clr(m1_m0_clr),
      .m0_rnd(m1_m0_rnd),
      .m0_sat(m1_m0_sat),
      .m0_reset(m1_m0_reset),
      .m0_oper_in(m1_m0_oper_in),
      .m0_coef_in(m1_m0_coef_in),
      .m0_mode(m1_m0_mode),
      .m0_outsel(m1_m0_outsel),
      .m0_dataout(m1_m0_dataout),

      .m1_clk(m1_m1_clk),
      .m1_clken(m1_m1_clken),
      .m1_tc(m1_m1_tc),
      .m1_osel(m1_m1_osel),
      .m1_csel(m1_m1_csel),
      .m1_clr(m1_m1_clr),
      .m1_rnd(m1_m1_rnd),
      .m1_sat(m1_m1_sat),
      .m1_reset(m1_m1_reset),
      .m1_oper_in(m1_m1_oper_in),
      .m1_coef_in(m1_m1_coef_in),
      .m1_mode(m1_m1_mode),
      .m1_outsel(m1_m1_outsel),
      .m1_dataout(m1_m1_dataout),


      .oper0_rclk(m1_oper0_rclk),
      .oper0_wclk(m1_oper0_wclk),
      .oper0_we(m1_oper0_we),
      .oper0_wdsel(m1_oper0_wdsel),
      .oper0_rmode(m1_oper0_rmode),
      .oper0_wmode(m1_oper0_wmode),
      .oper0_rdata(m1_oper0_rdata),
      .oper0_wdata(m1_oper0_wdata),
      .oper0_raddr(m1_oper0_raddr),
      .oper0_waddr(m1_oper0_waddr),
      .oper0_pwrdn(m1_oper0_powerdn),

      .oper1_rclk(m1_oper1_rclk),
      .oper1_wclk(m1_oper1_wclk),
      .oper1_we(m1_oper1_we),
      .oper1_wdsel(m1_oper1_wdsel),
      .oper1_rmode(m1_oper1_rmode),
      .oper1_wmode(m1_oper1_wmode),
      .oper1_rdata(m1_oper1_rdata),
      .oper1_wdata(m1_oper1_wdata),
      .oper1_raddr(m1_oper1_raddr),
      .oper1_waddr(m1_oper1_waddr),
      .oper1_pwrdn(m1_oper1_powerdn),

      .coef_rclk(m1_coef_rclk),
      .coef_wclk(m1_coef_wclk),
      .coef_we(m1_coef_we),
      .coef_wdsel(m1_coef_wdsel),
      .coef_rmode(m1_coef_rmode),
      .coef_wmode(m1_coef_wmode),
      .coef_rdata(m1_coef_rdata),
      .coef_wdata(m1_coef_wdata),
      .coef_raddr(m1_coef_raddr),
      .coef_waddr(m1_coef_waddr),
      .coef_pwrdn(m1_coef_powerdn)


  );



endmodule

