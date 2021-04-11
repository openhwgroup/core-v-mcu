// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


`define REG_CLKDIV0 2'b00 //BASEADDR+0x00
`define REG_CLKDIV1 2'b01 //BASEADDR+0x04
`define REG_CLKDIV2 2'b10 //BASEADDR+0x08

module apb_clkdiv #(
    parameter APB_ADDR_WIDTH = 12  //APB slaves are 4KB by default
) (
    input  logic                      HCLK,
    input  logic                      HRESETn,
    input  logic [APB_ADDR_WIDTH-1:0] PADDR,
    input  logic [              31:0] PWDATA,
    input  logic                      PWRITE,
    input  logic                      PSEL,
    input  logic                      PENABLE,
    output logic [              31:0] PRDATA,
    output logic                      PREADY,
    output logic                      PSLVERR,

    output logic [7:0] clk_div0,
    output logic       clk_div0_valid,
    output logic [7:0] clk_div1,
    output logic       clk_div1_valid,
    output logic [7:0] clk_div2,
    output logic       clk_div2_valid

);

  logic [7:0] r_clkdiv0;
  logic [7:0] r_clkdiv1;
  logic [7:0] r_clkdiv2;

  logic [1:0] s_apb_addr;

  assign s_apb_addr = PADDR[3:2];

  always @(posedge HCLK or negedge HRESETn) begin
    if (~HRESETn) begin
      r_clkdiv0      = 'h0;
      r_clkdiv1      = 'h0;
      r_clkdiv2      = 8'h0A;
      clk_div0_valid = 1'b0;
      clk_div1_valid = 1'b0;
      clk_div2_valid = 1'b0;
    end else begin
      clk_div0_valid = 1'b0;
      clk_div1_valid = 1'b0;
      clk_div2_valid = 1'b0;
      if (PSEL && PENABLE && PWRITE) begin
        case (s_apb_addr)
          `REG_CLKDIV0: begin
            r_clkdiv0      = PWDATA[7:0];
            clk_div0_valid = 1'b1;
          end
          `REG_CLKDIV1: begin
            r_clkdiv1      = PWDATA[7:0];
            clk_div1_valid = 1'b1;
          end
          `REG_CLKDIV2: begin
            r_clkdiv2      = PWDATA[7:0];
            clk_div2_valid = 1'b1;
          end
        endcase
      end
    end
  end  //always

  always_comb begin
    case (s_apb_addr)
      `REG_CLKDIV0: PRDATA = {24'h0, r_clkdiv0};
      `REG_CLKDIV1: PRDATA = {24'h0, r_clkdiv1};
      `REG_CLKDIV2: PRDATA = {24'h0, r_clkdiv2};
      default: PRDATA = '0;
    endcase
  end

  assign clk_div0 = r_clkdiv0;
  assign clk_div1 = r_clkdiv1;
  assign clk_div2 = r_clkdiv2;

  assign PREADY   = 1'b1;
  assign PSLVERR  = 1'b0;

endmodule
