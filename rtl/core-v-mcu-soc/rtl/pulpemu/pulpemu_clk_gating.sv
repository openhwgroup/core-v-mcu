// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


module pulpemu_clk_gating (
    input  logic pulp_cluster_clk,
    input  logic pulp_soc_rst_n,
    input  logic pulp_cluster_clk_enable,
    output logic pulp_cluster_clk_gated
);

  logic s_en_int;

  always_ff @(posedge pulp_cluster_clk) s_en_int = pulp_cluster_clk_enable;

  BUFGCE bufgce_i (
      .I (pulp_cluster_clk),
      .CE(s_en_int),
      .O (pulp_cluster_clk_gated)
  );

endmodule  // pulpemu_clk_gating
