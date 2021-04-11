// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module pulp_clock_gating
  (
   input  logic clk_i,
   input  logic en_i,
   input  logic test_en_i,
   output logic clk_o
   );
  logic         clk_en;

  // Use a latch based clock gate instead of BUFGCE. Otherwise we quickly run out of BUFGCTRL cells on the FPGAs.
  always_latch begin
    if (clk_i == 1'b0) clk_en <= en_i | test_en_i;
  end

  assign clk_o = clk_i & clk_en;

endmodule
