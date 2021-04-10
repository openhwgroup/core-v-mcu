// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`timescale 100ns/ 1ns

module top_tb_jtag();

  reg  clk;
  reg  rst_n;

  reg      jtag_trst;
  reg      jtag_tck;
  reg      jtag_tms;
  reg      jtag_tdi;
  wire     jtag_tdo;
  wire     jtag_tdo_oe;

  wire     s_tap_shiftdr;
  wire     s_tap_pausedr;
  wire     s_tap_updatedr;
  wire     s_tap_capturedr;
  wire     s_tap_extest_sel;
  wire     s_tap_preload_sel;
  wire     s_tap_intest_sel;
  wire     s_tap_reg1_sel;
  wire     s_tap_reg2_sel;
  wire     s_tap_reg3_sel;
  wire     s_tap_tdo;
  wire     s_tap_reg1_tdi;
  wire     s_tap_reg2_tdi;
  wire     s_tap_reg3_tdi;
  wire     s_tap_bschain_tdi;

  reg      s_mode;

  wire [7:0] s_reg1_in;
  wire [7:0] s_reg2_in;
  wire [7:0] s_reg3_in;

  wire [7:0] s_reg1_rst_in;
  wire [7:0] s_reg2_rst_in;
  wire [7:0] s_reg3_rst_in;

  wire [7:0] s_reg1_out;
  wire [7:0] s_reg2_out;
  wire [7:0] s_reg3_out;

  assign s_reg1_in = 8'hAB;
  assign s_reg2_in = 8'hCD;
  assign s_reg3_in = 8'hEF;

  assign s_reg1_rst_in = 8'h01;
  assign s_reg2_rst_in = 8'h02;
  assign s_reg3_rst_in = 8'h03;

  tap_top u_tap(.tms_pad_i(jtag_tms),
                .tck_pad_i(jtag_tck),
                .trst_pad_i(jtag_trst),
                .tdi_pad_i(jtag_tdi),
                .tdo_pad_o(jtag_tdo),
                .tdo_padoe_o(jtag_tdo_oe),
                .shift_dr_o(s_tap_shiftdr),
                .pause_dr_o(s_tap_pausedr),
                .update_dr_o(s_tap_updatedr),
                .capture_dr_o(s_tap_capturedr),
                .extest_select_o(s_tap_extest_sel),
                .sample_preload_select_o(s_tap_preload_sel),
                .intest_select_o(s_tap_intest_sel),
                .reg1_select_o(s_tap_reg1_sel),
                .reg2_select_o(s_tap_reg2_sel),
                .reg3_select_o(s_tap_reg3_sel),
                .tdo_o(s_tap_tdo),
                .reg1_tdi_i(s_tap_reg1_tdi),
                .reg2_tdi_i(s_tap_reg2_tdi),
                .reg3_tdi_i(s_tap_reg3_tdi),
                .bs_chain_tdi_i(s_tap_bschain_tdi)
              );

  std_reg u_reg1(.i_clk(jtag_tck),
                        .i_rst_n(rst_n),
                        .i_enable(s_tap_reg1_sel),
                        .i_capturedr(s_tap_capturedr),
                        .i_shiftdr(s_tap_shiftdr),
                        .i_updatedr(s_tap_updatedr),
                        .i_regin(s_reg1_in),
                        .i_rstin(s_reg1_rst_in),
                        .i_mode(s_mode),
                        .i_si(s_tap_tdo),
                        .o_regout(s_reg1_out),
                        .o_so(s_tap_reg1_tdi));

  std_reg u_reg2(.i_clk(jtag_tck),
                        .i_rst_n(rst_n),
                        .i_enable(s_tap_reg2_sel),
                        .i_capturedr(s_tap_capturedr),
                        .i_shiftdr(s_tap_shiftdr),
                        .i_updatedr(s_tap_updatedr),
                        .i_regin(s_reg2_in),
                        .i_rstin(s_reg2_rst_in),
                        .i_mode(s_mode),
                        .i_si(s_tap_tdo),
                        .o_regout(s_reg2_out),
                        .o_so(s_tap_reg2_tdi));

  std_reg u_reg3(.i_clk(jtag_tck),
                        .i_rst_n(rst_n),
                        .i_enable(s_tap_reg3_sel),
                        .i_capturedr(s_tap_capturedr),
                        .i_shiftdr(s_tap_shiftdr),
                        .i_updatedr(s_tap_updatedr),
                        .i_regin(s_reg3_in),
                        .i_rstin(s_reg3_rst_in),
                        .i_mode(s_mode),
                        .i_si(s_tap_tdo),
                        .o_regout(s_reg3_out),
                        .o_so(s_tap_reg3_tdi));

  initial begin
    rst_n=1;
    clk=0;
    s_mode=0;

    jtag_trst = 1'b0;
    jtag_tdi = 1'b0;
    jtag_tms = 1'b0;
    jtag_tck = 1'b0;

    #1   rst_n = 0;
    #100 rst_n = 1;

    jtag_hard_rst();
    jtag_rst();

    #10000 s_mode = 1'b1;
    #10000 s_mode = 1'b0;

    jtag_selectir(4'b0100);
    jtag_senddr(8,8'h11,1);

    jtag_selectir(4'b0101);
    jtag_senddr(8,8'h22,1);

    jtag_selectir(4'b0110);
    jtag_senddr(8,8'h33,1);

    #10000 s_mode = 1'b1;
    #10000 s_mode = 1'b0;

    $finish;

  end

  always
    #1 clk = ~clk;

`include "inc_jtag.v"

endmodule
