//-----------------------------------------------------------------------------
// Title         : CORE-V MCU Verilog Wrapper
//-----------------------------------------------------------------------------
// File          : xilinx_core_v_mcu.v
// Author        : Manuel Eggimann  <meggimann@iis.ee.ethz.ch>
// Created       : 21.05.2019
//-----------------------------------------------------------------------------
// Description :
// Verilog Wrapper of core_v_mcu to use the module within Xilinx IP integrator.
//-----------------------------------------------------------------------------
// Copyright (C) 2013-2019 ETH Zurich, University of Bologna
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//-----------------------------------------------------------------------------

`include "pulp_soc_defines.svh"
`include "pulp_peripheral_defines.svh"

module xilinx_core_v_mcu (
    input wire ref_clk_p,
    input wire ref_clk_n,

    //   inout wire  pad_spim_sdio0,
    inout wire pad_spim_sdio1,
    inout wire pad_spim_sdio2,
    inout wire pad_spim_sdio3,
    inout wire pad_spim_csn0,
    inout wire pad_spim_sck,

    inout wire pad_uart_rx,
    inout wire pad_uart_tx,

    inout wire led0_o,  //Mapped to spim_csn1
    inout wire led1_o,  //Mapped to cam_pclk
    inout wire led2_o,  //Mapped to cam_hsync
    inout wire led3_o,  //Mapped to cam_data0

    inout wire switch0_i,  //Mapped to cam_data1
    inout wire switch1_i,  //Mapped to cam_data2

    inout wire btnc_i,  //Mapped to cam_data3
    inout wire btnd_i,  //Mapped to cam_data4
    inout wire btnl_i,  //Mapped to cam_data5
    inout wire btnr_i,  //Mapped to cam_data6
    inout wire btnu_i,  //Mapped to cam_data7

    inout wire oled_spim_sck_o,  //Mapped to spim_sck
    inout wire oled_spim_mosi_o,  //Mapped to spim_sdio0
    inout wire oled_rst_o,  //Mapped to i2s0_sck
    inout wire oled_dc_o,  //Mapped to i2s0_ws
    inout wire oled_vbat_o,  // Mapped to i2s0_sdi
    inout wire oled_vdd_o,  // Mapped to i2s1_sdi

    inout wire sdio_reset_o,  //Reset signal for SD card need to be driven low to
    //power the onboard sd-card. Mapped to cam_vsync.
    inout wire pad_sdio_clk,
    inout wire pad_sdio_cmd,
    inout wire pad_sdio_data0,
    inout wire pad_sdio_data1,
    inout wire pad_sdio_data2,
    inout wire pad_sdio_data3,

    inout wire pad_i2c0_sda,
    inout wire pad_i2c0_scl,

    input wire pad_reset_n,
    inout wire pad_bootsel,

    input  wire pad_jtag_tck,
    input  wire pad_jtag_tdi,
    output wire pad_jtag_tdo,
    input  wire pad_jtag_tms,
    input  wire pad_jtag_trst
);

  // 3: CV32E40P
  localparam CORE_TYPE = 3;
  localparam USE_FPU = 1;
  localparam USE_HWPE = 0;

  wire ref_clk;


  //Differential to single ended clock conversion
  IBUFGDS #(
      .IOSTANDARD("LVDS"),
      .DIFF_TERM("FALSE"),
      .IBUF_LOW_PWR("FALSE")
  ) i_sysclk_iobuf (
      .I (ref_clk_p),
      .IB(ref_clk_n),
      .O (ref_clk)
  );

  wire [`N_IO-1:0]  io;

  // TODO(timsaxe): This needs to be adapted once IO genration is stable.
  assign io[0] = oled_spim_mosi_o;
  assign io[1] = pad_spim_sdio1;
  assign io[2] = pad_spim_sdio2;
  assign io[3] = pad_spim_sdio3;
  assign io[4] = pad_spim_csn0;
  assign io[5] = led0_o;
  assign io[6] = oled_spim_sck_o;
  assign io[7] = pad_uart_rx;
  assign io[8] = pad_uart_tx;
  assign io[9] = led1_o;
  assign io[10] = led2_o;
  assign io[11] = led3_o;
  assign io[12] = switch0_i;
  assign io[13] = switch1_i;
  assign io[14] = btnc_i;
  assign io[15] = btnd_i;
  assign io[16] = btnl_i;
  assign io[17] = btnr_i;
  assign io[18] = btnu_i;
  assign io[19] = sdio_reset_o;
  assign io[20] = pad_sdio_clk;
  assign io[21] = pad_sdio_cmd;
  assign io[22] = pad_sdio_data0;
  assign io[23] = pad_sdio_data1;
  assign io[24] = pad_sdio_data2;
  assign io[25] = pad_sdio_data3;
  assign io[26] = pad_i2c0_sda;
  assign io[27] = pad_i2c0_scl;
  assign io[28] = oled_rst_o;
  assign io[29] = oled_dc_o;
  assign io[30] = oled_vbat_o;
  assign io[31] = oled_vdd_o;
  assign io[32] = pad_reset_n;
  assign io[33] = pad_jtag_tck;
  assign io[34] = pad_jtag_tdi;
  assign io[35] = pad_jtag_tdo;
  assign io[36] = pad_jtag_tms;
  assign io[37] = pad_jtag_trst;
  assign io[38] = ref_clk;

  core_v_mcu #(
      .CORE_TYPE(CORE_TYPE),
      .USE_FPU  (USE_FPU),
      .USE_HWPE (USE_HWPE)
  ) i_core_v_mcu (
      .io(io)
  );

endmodule
