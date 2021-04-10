// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module AddressDecoder_Req_L2
#(
   parameter ID_WIDTH      = 5,                // ID WIDTH (number of bits) --> see ID comment
   parameter ID            = 1,                            // ID routed with REQUEST used to backroute response
   parameter N_SLAVE       = 8,                     // Number of Memory cuts
   parameter ROUT_WIDTH    = $clog2(N_SLAVE)
)
(
   // MASTER SIDE
   input  logic                            data_req_i,     // Request from Master COre
   input  logic [ROUT_WIDTH-1:0]           routing_addr_i, // routing information from Master Core
   output logic                            data_gnt_o,     // Grant delivered to Master Core
   input  logic [N_SLAVE-1:0]              data_gnt_i,     // Grant Array: one for each memory (ARB TREE SIDE)
   output logic [N_SLAVE-1:0]              data_req_o,     // Request Array: one for each memory
   output logic [ID_WIDTH-1:0]             data_ID_o       // data_ID_o is sent whit the request (like a PID)
);

   assign data_ID_o = ID;          // ID is simply attached to the ID_OUT

   always_comb
   begin : Combinational_ADDR_DEC_REQ
      //DEFAULT VALUES
      data_req_o = '0;
      // Apply the rigth value
      data_req_o[routing_addr_i] = data_req_i;
      data_gnt_o = data_gnt_i[routing_addr_i];
   end

endmodule
