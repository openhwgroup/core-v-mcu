// Copyright 2022 OpenHW Group
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

`include "pulp_soc_defines.svh"

module core_v_mcu_testharness #(
    parameter USE_FPU  = 0,
    parameter USE_HWPE = 0
) (
    input                                rstn_i,
    input                                ref_clk_i,
    input                                bootsel_i,
    input                                jtag_tck_i,
    input                                jtag_tdi_i,
    output                               jtag_tdo_o,
    input                                jtag_tms_i,
    input                                jtag_trst_i,
    output                               slow_clk_o,
    input                                stm_i,
    output [`N_IO-1:0][`NBIT_PADCFG-1:0] pad_cfg_o,
    output [`N_IO-1:0]                   io_oe_o
);

localparam IO_UART0_RX = 8;
localparam IO_UART0_TX = 7;
localparam IO_UART1_RX = 9;
localparam IO_UART1_TX = 10;

 wire [`N_IO-1:0] io_in;
 wire [`N_IO-1:0] io_out;

  // Design Under Test
  core_v_mcu #(
  )
  core_v_mcu_i (
    .jtag_tck_i(jtag_tck_i),
    .jtag_tdi_i(jtag_tdi_i),
    .jtag_tdo_o(jtag_tdo_o),
    .jtag_tms_i(jtag_tms_i),
    .jtag_trst_i(jtag_trst_i),
    .ref_clk_i(ref_clk_i),
    .rstn_i(rstn_i),
    .bootsel_i(bootsel_i),
    .stm_i(1'b0),
    .io_in_i(io_in),
    .io_out_o(io_out),
    .pad_cfg_o(pad_cfg_o),
    .slow_clk_o(slow_clk_o),
    .io_oe_o(io_oe_o)
  );

 uartdpi #(.BAUD('d115200),
      // Frequency shouldn't matter since we are sending with the same clock.
     .FREQ(44*'d115200),
     .NAME("uart0")
 ) uart_0 (
   .clk_i(ref_clk_i),
   .rst_ni (rstn_i),
   .tx_o(io_in[IO_UART0_TX]),
   .rx_i(io_out[IO_UART0_RX])
   );

 uartdpi #(.BAUD('d115200),
     // Frequency shouldn't matter since we are sending with the same clock.
     .FREQ(44*'d115200),
     .NAME("uart1")
 ) uart_1 (
   .clk_i(ref_clk_i),
   .rst_ni (rstn_i),
   .tx_o(io_in[IO_UART1_TX]),
   .rx_i(io_out[IO_UART1_RX])
   );


endmodule  // testharness
