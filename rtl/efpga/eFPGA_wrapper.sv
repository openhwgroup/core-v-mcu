// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
`include "pulp_soc_defines.svh"
module eFPGA_wrapper (
    output logic [ 3:0] test_fb_spe_out,
    input  logic [ 3:0] test_fb_spe_in,
    input  logic        MLATCH,
    input  logic        POR,
    input  logic        STM,
    input  logic [ 5:0] M,
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
    input               fcb_fb_cfg_done,

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


      // SOC signals
      .control_in(control_in),
      .status_out(status_out),
      .version(version),
      .fpgaio_oe(fpga_oe),  // ouput
      .fpgaio_out(fpga_out),  // ouput
      .fpgaio_in(fpga_in),  // input
      .events_o(events_o),  // output
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
      .m1_coef_powerdn(m1_coef_powerdn),
      // outpust to FCB
      .FB_SPE_OUT(test_fb_spe_out),
      .fcb_bl_dout(fcb_bl_dout),
      .fcb_pif_en(fcb_pif_en),

      // Inputs
      .M                 (M),
      .MLATCH            (MLATCH),
      .fcb_blclk         (fcb_blclk),
      .fcb_bl_din        (fcb_bl_din),
      .fcb_bl_pwrgate    (fcb_bl_pwrgate),
      .fcb_fb_cfg_done   (fcb_fb_cfg_done),
      .fcb_cload_din_sel (fcb_cload_din_sel),
      .fcb_din_int_l_only(fcb_din_int_l_only),
      .fcb_din_int_r_only(fcb_din_int_r_only),
      .fcb_din_slc_tb_int(fcb_din_slc_tb_int),
      .fcb_fb_iso_enb    (fcb_fb_iso_enb),
      .FB_SPE_IN         (test_fb_spe_in),
      .fcb_iso_en        (fcb_iso_en),
      .NB                (),
      .PB                (),
      .fcb_pchg_b        (fcb_pchg_b),
      .fcb_pi_pwr        (fcb_pi_pwr),
      .POR               (POR),
      .fcb_prog          (fcb_prog),
      .fcb_prog_ifx      (fcb_prog_ifx),
      .fcb_pwr_gate      (fcb_pwr_gate),
      .fcb_re            (fcb_re),
      .STM               (STM),
      .fcb_vlp_clkdis    (fcb_vlp_clkdis),
      .fcb_vlp_clkdis_ifx(fcb_vlp_clkdis_ifx),
      .fcb_vlp_pwrdis    (fcb_vlp_pwrdis),
      .fcb_vlp_pwrdis_ifx(fcb_vlp_pwrdis_ifx),
      .fcb_vlp_srdis     (fcb_vlp_srdis),
      .fcb_vlp_srdis_ifx (fcb_vlp_srdis_ifx),
      .fcb_we            (fcb_we),
      .fcb_we_int        (fcb_we_int),
      .fcb_wlclk         (fcb_wlclk),
      .fcb_wl_cload_sel  (fcb_wl_cload_sel),
      .fcb_wl_din        (fcb_wl_din),
      .fcb_wl_en         (fcb_wl_en),
      .fcb_wl_int_din_sel(fcb_wl_int_din_sel),
      .fcb_wl_pwrgate    (fcb_wl_pwrgate),
      .fcb_wl_resetb     (fcb_wl_resetb),
      .fcb_wl_sel        (fcb_wl_sel),
      .fcb_wl_sel_tb_int (fcb_wl_sel_tb_int)
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
