// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module ResponseBlock_L2
#(
   parameter ID         = 1,
   parameter ID_WIDTH   = 20,
   parameter N_SLAVE    = 2,
   parameter DATA_WIDTH = 64,
   parameter ROUT_WIDTH = $clog2(N_SLAVE)
)
(
   // -----------------------------------------------------------//
   //                      Response HANDLING
   // -----------------------------------------------------------//
   // Signals from Memory cuts
   input logic [N_SLAVE-1:0]                       data_r_valid_i,
   input logic [N_SLAVE-1:0][DATA_WIDTH-1:0]       data_r_rdata_i,
   // Output of the ResponseTree Block
   output logic                                    data_r_valid_o,
   output logic [DATA_WIDTH-1:0]                   data_r_rdata_o,


   // -----------------------------------------------------------//
   //                      Request HANDLING
   // -----------------------------------------------------------//
   input logic                                     data_req_i,
   input logic [ROUT_WIDTH-1:0]                    routing_addr_i,
   output logic                                    data_gnt_o,
   input  logic [N_SLAVE-1:0]                      data_gnt_i,
   output logic [N_SLAVE-1:0]                      data_req_o,
   output logic [ID_WIDTH-1:0]                     data_ID_o
);

   // Response Tree
   ResponseTree_L2 #( .N_SLAVE(N_SLAVE), .DATA_WIDTH(DATA_WIDTH))  MEM_RESP_TREE
   (
      // Response Input Channel
      .data_r_valid_i(data_r_valid_i),
      .data_r_rdata_i(data_r_rdata_i),
      // Response Output Channel
      .data_r_valid_o(data_r_valid_o),
      .data_r_rdata_o(data_r_rdata_o)
   );

   AddressDecoder_Req_L2 #( .ID_WIDTH(ID_WIDTH), .ID(ID), .N_SLAVE(N_SLAVE) )  ADDR_DEC_REQ
   (
      // MASTER SIDE
      .data_req_i(data_req_i),                // Request from MASTER
      .routing_addr_i(routing_addr_i),                // Address from MASTER
      .data_gnt_o(data_gnt_o),                // Grant delivered to MASTER
      .data_gnt_i(data_gnt_i),                // Grant Array: one for each memory (On ARB TREE SIDE)
      // ARB TREE SIDE
      .data_req_o(data_req_o),                // Request Array: one for each memory
      .data_ID_o(data_ID_o)                   // ID is sent whit the request (like a PID)
   );
endmodule
