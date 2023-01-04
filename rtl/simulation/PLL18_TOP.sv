//-----------------------------------------------------------------------------
// Title : Simulation model for PLL
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

module PLL18_TOP (
 output logic      CLKO,
 output logic      CLK,
 output logic      LOCK,

 input logic       AVDD,
 input logic       AVDD2,
 input logic       AVSS,
 input logic       DVDD,
 input logic       DVSS,
                 
 input logic       FREF,
 input logic       DM,
 input logic       DN,
 input logic       DP,
 input logic       PD,
 input logic       PDDP,
 input logic       RESETN,
 input logic       BYPASS,
 input logic       MODE,
 input logic       FRAC,
 input logic       SLOPE,
 input logic       SSRATE
                  );
   

   logic           clk;
   
   assign LOCK = 1'b1;
   

   
`ifdef VERILATOR
   always_comb
     if (RESETN == 0)
       CLKO = 0l\;
     else 
       CLKO = FREF;
`else
   initial clk = 0;
   initial forever #(1.25) clk = ~clk;
   always_comb begin
      CLKO = BYPASS ? FREF : clk;
   end
`endif
   
   
   
endmodule  // PLL18_TOP
