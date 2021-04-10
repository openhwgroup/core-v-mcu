// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


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

  logic [2:0] r_sync0;
  logic [2:0] r_sync1;
  logic       s_en0;
  logic       s_en1;
  logic       s_clk0;
  logic       s_clk1;

  assign clk_selected_o = ~r_sync1[2] & r_sync0[2];

  assign s_en0 = ~select_i & ~r_sync1[2];
  assign s_en1 = select_i & ~r_sync0[2];

  always_ff @(posedge clk0_i or negedge rstn0_i) begin
    if (~rstn0_i) begin
      r_sync0 <= 0;
    end else begin
      r_sync0 <= {r_sync0[1:0], s_en0};
    end
  end

  always_ff @(posedge clk1_i or negedge rstn1_i) begin
    if (~rstn1_i) begin
      r_sync1 <= 0;
    end else begin
      r_sync1 <= {r_sync1[1:0], s_en1};
    end
  end

  pulp_clock_xor2 u_xorout (
      .clk0_i(s_clk0),
      .clk1_i(s_clk1),
      .clk_o (clk_out_o)
  );

  pulp_clock_gating u_clkgate0 (
      .clk_i(clk0_i),
      .en_i(r_sync0[1]),
      .test_en_i(test_mode_i),
      .clk_o(s_clk0)
  );

  pulp_clock_gating u_clkgate1 (
      .clk_i(clk1_i),
      .en_i(r_sync1[1]),
      .test_en_i(test_mode_i),
      .clk_o(s_clk1)
  );


endmodule  // glitch_free_clk_mux

