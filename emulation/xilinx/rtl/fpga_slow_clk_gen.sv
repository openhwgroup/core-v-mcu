//-----------------------------------------------------------------------------
// Title         : FPGA slow clk generator for PULPissimo
//-----------------------------------------------------------------------------
// File          : fpga_slow_clk_gen.sv
// Author        : Manuel Eggimann  <meggimann@iis.ee.ethz.ch>
// Created       : 20.05.2019
//-----------------------------------------------------------------------------
// Description : Instantiates Xilinx Clocking Wizard IP to generate the slow_clk
// signal since for certain boards the available clock sources are to fast to
// use directly.
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


module fpga_slow_clk_gen
  #(
    parameter CLK_DIV_VALUE = 32 // input clock of 8 Mhz / 32 = 250 Khz
                                 // for 10Mhz emulation = 40x ratio CPU to ref
    )
  (
   input logic  clk_i,
   input logic  rst_ni,
   output logic ref_clk_o
   );



  localparam COUNTER_WIDTH = $clog2(CLK_DIV_VALUE);


  logic [COUNTER_WIDTH-1:0] clk_counter;
  logic                     clkout;


  assign ref_clk_o = (CLK_DIV_VALUE == 1) ? clk_i : clkout;

  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
      clk_counter <= '0;
      clkout = 1'b0;
    end else begin
      clk_counter <= clk_counter + 1;
      case (CLK_DIV_VALUE)
        0,1,2:clkout <= 0;
        default: begin
          if (clk_counter == ((CLK_DIV_VALUE-1) >> 1)) clkout <= 1;
          if (clk_counter == (CLK_DIV_VALUE - 1)) begin
            clkout <= ~clkout;
            clk_counter <= 0;
          end
        end
      endcase // case (CLK_DIV_VALUE)
    end
  end

endmodule : fpga_slow_clk_gen
