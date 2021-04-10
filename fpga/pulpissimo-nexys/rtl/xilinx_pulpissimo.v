//-----------------------------------------------------------------------------
// This file is a generated file
//-----------------------------------------------------------------------------
// Title         : PULPissimo Verilog Wrapper
//-----------------------------------------------------------------------------
// File          : xilinx_pulpissimo.v
// Author        : Manuel Eggimann  <meggimann@iis.ee.ethz.ch>
// Created       : 21.05.2019
//-----------------------------------------------------------------------------
// Description :
// Verilog Wrapper of PULPissimo to use the module within Xilinx IP integrator.
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

`include "pulp_soc_defines.sv"
`include "pulp_peripheral_defines.svh"

module xilinx_pulpissimo
  (
    inout wire [`N_IO-1:0]  xilinx_io
  );

  wire [`N_IO-1:0]  s_io;

  assign s_io[5:0] = xilinx_io[5:0];

  // Input clock buffer
  IBUFG #(
    .IOSTANDARD("LVCMOS33"),
    .IBUF_LOW_PWR("FALSE")
  ) i_sysclk_iobuf (
    .I(xilinx_io[6]),
    .O(s_io[6])
  );

  assign s_io[7:7] = xilinx_io[7:7];

  //JTAG TCK clock buffer (dedicated route is false in constraints)
  IBUF i_tck_iobuf (
    .I(xilinx_io[8]),
    .O(s_io[8])
  );

  assign s_io[47:9] = xilinx_io[47:9];

  pulpissimo #(
    .CORE_TYPE(`CORE_TYPE),
    .USE_FPU(`USE_FPU),
    .USE_HWPE(`USE_HWPE)
  ) i_pulpissimo (
    .io(s_io)
  );
endmodule
