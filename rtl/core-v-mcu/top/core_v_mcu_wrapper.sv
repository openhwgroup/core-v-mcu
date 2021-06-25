// Copyright 2018 Open Hardware Group
//
// SPDX-License-Identifier: SHL-2.1

`include "pulp_soc_defines.sv"
`include "pulp_peripheral_defines.svh"

module core_v_mcu_wrapper #(
) (
    input ref_clk_i,
    input rstn_i,

    // JTAG TAP
    input  tck_i,
    input  tdi_i,
    output tdo_o,
    input  tms_i,
    input  trst_i,

    // Boot select
    input bootsel_i,

    // General I/O
    output [`N_IO-9:0] io_o,
    input  [`N_IO-9:0] io_i,
    input  [`N_IO-9:0] io_oe
);

  wire [`N_IO-1:0] io;

  assign io[6]  = ref_clk_i;
  assign io[7]  = rstn_i;

  assign io[8]  = tck_i;
  assign io[9]  = tdi_i;
  assign tdo_o  = io[10];
  assign io[11] = tms_i;
  assign io[12] = trst_i;

  assign io[15] = bootsel_i;

  genvar i;
  generate
    for (i = 0; i <= 5; i++) begin
      assign io[i]   = (io_oe[i] == 1'b0) ? io_i[i] : 1'bz;
      assign io_o[i] = (io_oe[i] == 1'b1) ? io[i] : 1'bz;
    end

    for (i = 13; i <= 14; i++) begin
      assign io[i] = (io_oe[i-7] == 1'b0) ? io_i[i-7] : 1'bz;
      assign io_o[i-7] = (io_oe[i-7] == 1'b1) ? io[i] : 1'bz;
    end

    for (i = 16; i <= `N_IO - 1; i++) begin
      assign io[i] = (io_oe[i-8] == 1'b0) ? io_i[i-8] : 1'bz;
      assign io_o[i-8] = (io_oe[i-8] == 1'b1) ? io[i] : 1'bz;
    end
  endgenerate


  core_v_mcu i_core_v_mcu (.io(io));

endmodule
;  // core_v_mcu_wrapper
