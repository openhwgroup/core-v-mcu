//-----------------------------------------------------------------------------
// Title : Simulation CLK Gen for PULPissimo
// -----------------------------------------------------------------------------
// File : sim_clk_gen.sv Author : Tim Saxe
// Created : 2021-05-22
// -----------------------------------------------------------------------------
// Description : Passes ref_clk thru
// -----------------------------------------------------------------------------
// Copyright (C) 2021 QUickLogic Copyright and
// related rights are licensed under the Solderpad Hardware License, Version
// 0.51 (the "License"); you may not use this file except in compliance with the
// License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law or
// agreed to in writing, software, hardware and materials distributed under this
// License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS
// OF ANY KIND, either express or implied. See the License for the specific
// language governing permissions and limitations under the License.
// -----------------------------------------------------------------------------


module clk_gen (
    input  logic        ref_clk_i,
    input               emul_clk_i,
    input  logic        rstn_glob_i,
    input  logic        test_mode_i,
    input  logic        shift_enable_i,
    output logic        soc_clk_o,
    output logic        per_clk_o,
    output logic        cluster_clk_o,
    output logic        soc_cfg_lock_o,
    input  logic        soc_cfg_req_i,
    output logic        soc_cfg_ack_o,
    input  logic [ 1:0] soc_cfg_add_i,
    input  logic [31:0] soc_cfg_data_i,
    output logic [31:0] soc_cfg_r_data_o,
    input  logic        soc_cfg_wrn_i,
    output logic        per_cfg_lock_o,
    input  logic        per_cfg_req_i,
    output logic        per_cfg_ack_o,
    input  logic [ 1:0] per_cfg_add_i,
    input  logic [31:0] per_cfg_data_i,
    output logic [31:0] per_cfg_r_data_o,
    input  logic        per_cfg_wrn_i,
    output logic        cluster_cfg_lock_o,
    input  logic        cluster_cfg_req_i,
    output logic        cluster_cfg_ack_o,
    input  logic [ 1:0] cluster_cfg_add_i,
    input  logic [31:0] cluster_cfg_data_i,
    output logic [31:0] cluster_cfg_r_data_o,
    input  logic        cluster_cfg_wrn_i
);
  localparam SOC_PERIOD = 2.5;
  localparam PER_PERIOD = 5.0;
  localparam FPGA_PERIOD = 10.0;


`ifdef VERILATOR
  reg [2:0] count;
  assign soc_clk_o = ref_clk_i;
  always @(posedge ref_clk_i or negedge rstn_glob_i) begin
    if (rstn_glob_i == 0) begin
      per_clk_o <= 0;
      cluster_clk_o <= 0;
      count <= 0;
    end else begin
      count <= count + 1;
      per_clk_o <= count[0];
      cluster_clk_o <= count[1];
    end  // else: !if(rstn_glob_i == 0)
  end
`else  // !`ifdef VERILATOR
  initial begin
    soc_clk_o = 1'b0;
    per_clk_o = 1'b0;
    cluster_clk_o = 1'b0;
  end
  initial forever #(SOC_PERIOD / 2) soc_clk_o = ~soc_clk_o;
  initial forever #(PER_PERIOD / 2) per_clk_o = ~per_clk_o;
  initial forever #(FPGA_PERIOD / 2) cluster_clk_o = ~cluster_clk_o;
`endif  // !`ifdef VERILATOR

  always_comb begin
    soc_cfg_ack_o     = 1'b0;
    per_cfg_ack_o     = 1'b0;
    cluster_cfg_ack_o = 1'b0;
    if (soc_cfg_req_i) begin
      soc_cfg_ack_o = 1'b1;
    end
    if (per_cfg_req_i) begin
      per_cfg_ack_o = 1'b1;
    end
    if (cluster_cfg_req_i) begin
      cluster_cfg_ack_o = 1'b1;
    end
  end

  always_comb begin
    case (soc_cfg_add_i)
      2'b00: soc_cfg_r_data_o = 32'h00010001;
      2'b01: soc_cfg_r_data_o = 32'h00010002;
      2'b10: soc_cfg_r_data_o = 32'h00010003;
      2'b11: soc_cfg_r_data_o = 32'hfffefffc;
    endcase  // case (soc_cfg_i)
  end
  always_comb begin
    case (per_cfg_add_i)
      2'b00: per_cfg_r_data_o = 32'h00020001;
      2'b01: per_cfg_r_data_o = 32'h00020002;
      2'b10: per_cfg_r_data_o = 32'h00020003;
      2'b11: per_cfg_r_data_o = 32'hfffdfffc;
    endcase  // case (soc_cfg_i)
  end
  always_comb begin
    case (cluster_cfg_add_i)
      2'b00: cluster_cfg_r_data_o = 32'h00030001;
      2'b01: cluster_cfg_r_data_o = 32'h00030002;
      2'b10: cluster_cfg_r_data_o = 32'h00030003;
      2'b11: cluster_cfg_r_data_o = 32'hfffcfffc;
    endcase  // case (soc_cfg_i)
  end

endmodule : clk_gen
