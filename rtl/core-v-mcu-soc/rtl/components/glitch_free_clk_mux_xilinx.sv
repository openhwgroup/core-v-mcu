// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


`ifdef PULP_FPGA_EMUL
module glitch_free_clk_mux (
    input  logic select_i,
    input  logic test_mode_i,
    output logic clk_selected_o,
    input  logic clk0_i,
    input  logic rstn0_i,
    input  logic clk1_i,
    input  logic rstn1_i,
    output logic clk_out_o
);

  BUFGMUX_CTRL bufgmux_i (
      .S (select_i),
      .I0(clk0_i),
      .I1(clk1_i),
      .O (clk_out_o)
  );

endmodule  // glitch_free_clk_mux
`endif

