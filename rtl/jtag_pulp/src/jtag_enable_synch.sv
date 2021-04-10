// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module jtag_enable_synch
  (
   input logic 	clk_i,
   input logic  rst_ni,
   input logic 	tck,
   output logic enable
   );

   logic 	tck1,tck2,tck3;

   always_ff @(negedge rst_ni, posedge clk_i)
     begin
	if (~rst_ni)
	  begin
	     tck1 <= 1'b0;
	     tck2 <= 1'b0;
	     tck3 <= 1'b0;
	  end
	else
	  begin
	     tck1 <= tck;
	     tck2 <= tck1;
	     tck3 <= tck2;
	  end
     end

   assign enable = ~tck3 & tck2;

endmodule // jtag_enable_synch

