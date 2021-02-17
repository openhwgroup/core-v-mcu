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

  // Input clock buffer
  IBUFG #(
    .IOSTANDARD("LVCMOS33"),
    .IBUF_LOW_PWR("FALSE")
  ) i_sysclk_iobuf (
    .I(xilinx_io[6]),
    .O(s_io[6])
  );

  //JTAG TCK clock buffer (dedicated route is false in constraints)
  IBUF i_tck_iobuf (
    .I(xilinx_io[8]),
    .O(s_io[8])
  );
    assign s_io[0] = xilinx_io[0];
    assign s_io[1] = xilinx_io[1];
    assign s_io[2] = xilinx_io[2];
    assign s_io[3] = xilinx_io[3];
    assign s_io[4] = xilinx_io[4];
    assign s_io[5] = xilinx_io[5];
    assign s_io[7] = xilinx_io[7];
    assign s_io[9] = xilinx_io[9];
    assign s_io[10] = xilinx_io[10];
    assign s_io[11] = xilinx_io[11];
    assign s_io[12] = xilinx_io[12];
    assign s_io[13] = xilinx_io[13];
    assign s_io[14] = xilinx_io[14];
    assign s_io[15] = xilinx_io[15];
    assign s_io[16] = xilinx_io[16];
    assign s_io[17] = xilinx_io[17];
    assign s_io[18] = xilinx_io[18];
    assign s_io[19] = xilinx_io[19];
    assign s_io[20] = xilinx_io[20];
    assign s_io[21] = xilinx_io[21];
    assign s_io[22] = xilinx_io[22];
    assign s_io[23] = xilinx_io[23];
    assign s_io[24] = xilinx_io[24];
    assign s_io[25] = xilinx_io[25];
    assign s_io[26] = xilinx_io[26];
    assign s_io[27] = xilinx_io[27];
    assign s_io[28] = xilinx_io[28];
    assign s_io[29] = xilinx_io[29];
    assign s_io[30] = xilinx_io[30];
    assign s_io[31] = xilinx_io[31];
    assign s_io[32] = xilinx_io[32];
    assign s_io[33] = xilinx_io[33];
    assign s_io[34] = xilinx_io[34];
    assign s_io[35] = xilinx_io[35];
    assign s_io[36] = xilinx_io[36];
    assign s_io[37] = xilinx_io[37];
    assign s_io[38] = xilinx_io[38];
    assign s_io[39] = xilinx_io[39];
    assign s_io[40] = xilinx_io[40];
    assign s_io[41] = xilinx_io[41];
    assign s_io[42] = xilinx_io[42];
    assign s_io[43] = xilinx_io[43];
    assign s_io[44] = xilinx_io[44];
    assign s_io[45] = xilinx_io[45];
    assign s_io[46] = xilinx_io[46];
    assign s_io[47] = xilinx_io[47];
pulpissimo #(
    .CORE_TYPE(`CORE_TYPE),
    .USE_FPU(`USE_FPU),
    .USE_HWPE(`USE_HWPE)
  ) i_pulpissimo (
    .io(s_io)
  );
endmodule
