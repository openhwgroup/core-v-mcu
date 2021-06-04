// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`include "pulp_soc_defines.sv"
`include "pulp_peripheral_defines.svh"

module safe_domain #(
    parameter int unsigned FLL_DATA_WIDTH = 32,
    parameter int unsigned FLL_ADDR_WIDTH = 32
) (
    input  logic ref_clk_i,
    output logic slow_clk_o,
    output logic efpga_clk_o,
    input  logic bootsel_i,
    input  logic rst_ni,
    output logic rst_no,

    output logic test_clk_o,
    output logic test_mode_o,
    output logic mode_select_o,
    output logic dft_cg_enable_o,

    //**********************************************************
    //*** PERIPHERALS SIGNALS **********************************
    //**********************************************************

    // PAD CONTROL REGISTER
    input  logic [`N_IO-1:0][`NBIT_PADMUX-1:0] pad_mux_i,
    input  logic [`N_IO-1:0][`NBIT_PADCFG-1:0] pad_cfg_i,
    output logic [`N_IO-1:0][`NBIT_PADCFG-1:0] pad_cfg_o,

    // IOS
    output logic [`N_IO-1:0] io_out_o,
    input  logic [`N_IO-1:0] io_in_i,
    output logic [`N_IO-1:0] io_oe_o,

    // PERIOS
    input  logic [`N_PERIO-1:0] perio_out_i,
    output logic [`N_PERIO-1:0] perio_in_o,
    input  logic [`N_PERIO-1:0] perio_oe_i,

    // APBIOS
    input  logic [`N_APBIO-1:0] apbio_out_i,
    output logic [`N_APBIO-1:0] apbio_in_o,
    input  logic [`N_APBIO-1:0] apbio_oe_i,

    // FPGAIOS
    input  logic [`N_FPGAIO-1:0] fpgaio_out_i,
    output logic [`N_FPGAIO-1:0] fpgaio_in_o,
    input  logic [`N_FPGAIO-1:0] fpgaio_oe_i,


    // TIMER
    //    input logic [3:0] timer0_i,
    //    input logic [3:0] timer1_i,
    //    input logic [3:0] timer2_i,
    //    input logic [3:0] timer3_i,
    input logic debug0,
    input logic debug1
);

  logic                    s_test_clk;

  logic                    s_rtc_int;
  logic                    s_gpio_wake;
  logic                    s_rstn_sync;
  logic                    s_rstn;


  //**********************************************************
  //*** GPIO CONFIGURATIONS **********************************
  //**********************************************************

  logic [`N_GPIO-1:0][5:0] s_gpio_cfg;

  genvar i, j;

  pad_control i_pad_control (

      //********************************************************************//
      //*** PERIPHERALS SIGNALS ********************************************//
      //********************************************************************//
      .pad_mux_i(pad_mux_i),
      .pad_cfg_i(pad_cfg_i),
      .pad_cfg_o(pad_cfg_o),

      .io_out_o(io_out_o),
      .io_in_i (io_in_i),
      .io_oe_o (io_oe_o),

      .perio_out_i(perio_out_i),
      .perio_in_o (perio_in_o),
      .perio_oe_i (perio_oe_i),

      .apbio_out_i(apbio_out_i),
      .apbio_in_o (apbio_in_o),
      .apbio_oe_i (apbio_oe_i),

      .fpgaio_out_i(fpgaio_out_i),
      .fpgaio_in_o (fpgaio_in_o),
      .fpgaio_oe_i (fpgaio_oe_i)
  );


`ifndef PULP_FPGA_EMUL
  rstgen i_rstgen (
      .clk_i      (ref_clk_i),
      .rst_ni     (s_rstn),
      .test_mode_i(test_mode_o),
      .rst_no     (s_rstn_sync),  //to be used by logic clocked with ref clock in AO domain
      .init_no    ()  //not used
  );


`else
  assign s_rstn_sync = s_rstn;
  //Don't use the supplied clock directly for the FPGA target. On some boards
  //the reference clock is a very fast (e.g. 200MHz) clock that cannot be used
  //directly as the "slow_clk". Therefore we slow it down if a FPGA/board
  //dependent module fpga_slow_clk_gen. Dividing the fast reference clock
  //internally instead of doing so in the toplevel prevents unecessary clock
  //division just to generate a faster clock once again in the SoC and
  //Peripheral clock PLLs in soc_domain.sv. Instead all PLL use directly the
  //board reference clock as input.

  fpga_slow_clk_gen i_slow_clk_gen (
      .rst_ni(s_rstn_sync),
      .ref_clk_i(ref_clk_i),
      .mhz4(efpga_clk_o),
      .slow_clk_o(slow_clk_o)
  );
`endif


  assign s_rstn          = rst_ni;
  assign rst_no          = s_rstn;

  assign test_clk_o      = 1'b0;
  assign dft_cg_enable_o = 1'b0;
  assign test_mode_o     = 1'b0;
  assign mode_select_o   = 1'b0;

  // //********************************************************
  // //*** PAD AND GPIO CONFIGURATION SIGNALS PACK ************
  // //********************************************************

  // generate
  // for (i=0; i<32; i++)
  // begin : GEN_GPIO_CFG_I
  // for (j=0; j<6; j++)
  // begin : GEN_GPIO_CFG_J
  // assign s_gpio_cfg[i][j] = gpio_cfg_i[j+6*i];
  // end
  // end
  // endgenerate

endmodule  // safe_domain
