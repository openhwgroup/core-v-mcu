// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module ResponseBlock_BRIDGE
#(
   parameter ID             = 1,
   parameter ID_WIDTH       = 17,
   parameter N_SLAVE        = 16,
   parameter AUX_WIDTH      = 8,

   parameter DATA_WIDTH     = 32
)
(
   // -----------------------------------------------------------//
   //                      Response HANDLING
   // -----------------------------------------------------------//
   // Signals from Memory cuts
   input logic [N_SLAVE-1:0]                       data_r_valid_i,
   input logic [N_SLAVE-1:0][DATA_WIDTH-1:0]       data_r_rdata_i,
   input logic [N_SLAVE-1:0]                       data_r_opc_i,
   input logic [N_SLAVE-1:0][AUX_WIDTH-1:0]        data_r_aux_i,


   // Output of the ResponseTree Block
   output logic                                    data_r_valid_o,
   output logic [DATA_WIDTH-1:0]                   data_r_rdata_o,
   output logic                                    data_r_opc_o,
   output logic [AUX_WIDTH-1:0]                    data_r_aux_o,

   // -----------------------------------------------------------//
   //                      Request HANDLING
   // -----------------------------------------------------------//
   input  logic                                    data_req_i,
   input  logic [N_SLAVE-1:0]                      destination_i,
   output logic                                    data_gnt_o,

   output logic [N_SLAVE-1:0]                      data_req_o,
   input  logic [N_SLAVE-1:0]                      data_gnt_i,

   output logic [ID_WIDTH-1:0]                     data_ID_o
);


   logic [2**$clog2(N_SLAVE)-1:0]                  data_r_valid_int;
   logic [2**$clog2(N_SLAVE)-1:0][DATA_WIDTH-1:0]  data_r_rdata_int;
   logic [2**$clog2(N_SLAVE)-1:0]                  data_r_opc_int;
   logic [2**$clog2(N_SLAVE)-1:0][AUX_WIDTH-1:0]   data_r_aux_int;

   generate
      if(2**$clog2(N_SLAVE) != N_SLAVE) // if N_CH0 is not power of 2 --> then use power 2 ports
      begin : _DUMMY_SLAVE_PORTS_
         logic [2**$clog2(N_SLAVE)-N_SLAVE-1:0]                  data_r_valid_dummy;
         logic [2**$clog2(N_SLAVE)-N_SLAVE-1:0][DATA_WIDTH-1:0]  data_r_rdata_dummy;
         logic [2**$clog2(N_SLAVE)-N_SLAVE-1:0]                  data_r_opc_dummy;
         logic [2**$clog2(N_SLAVE)-N_SLAVE-1:0][AUX_WIDTH-1:0]   data_r_aux_dummy;

         assign data_r_valid_dummy = '0 ;
         assign data_r_rdata_dummy = '0 ;
         assign data_r_opc_dummy   = '0 ;
         assign data_r_aux_dummy   = '0 ;

         assign data_r_valid_int   = { data_r_valid_dummy ,     data_r_valid_i };
         assign data_r_rdata_int   = { data_r_rdata_dummy ,     data_r_rdata_i };
         assign data_r_opc_int     = { data_r_opc_dummy   ,     data_r_opc_i   };
         assign data_r_aux_int     = { data_r_aux_dummy   ,     data_r_aux_i   };
      end
      else // N_CH0 is power of 2
      begin
          assign data_r_valid_int    = data_r_valid_i;
          assign data_r_rdata_int    = data_r_rdata_i;
          assign data_r_opc_int      = data_r_opc_i  ;
          assign data_r_aux_int      = data_r_aux_i  ;
      end
   endgenerate

   // Response Tree
   ResponseTree_BRIDGE
   #(
       .N_SLAVE    ( 2**$clog2(N_SLAVE) ),
       .DATA_WIDTH ( DATA_WIDTH         ),
       .AUX_WIDTH  ( AUX_WIDTH          )
   )
   i_ResponseTree_BRIDGE
   (
      // Response Input Channel
      .data_r_valid_i ( data_r_valid_int ),
      .data_r_rdata_i ( data_r_rdata_int ),
      .data_r_opc_i   ( data_r_opc_int   ),
      .data_r_aux_i   ( data_r_aux_int   ),
      // Response Output Channel
      .data_r_valid_o ( data_r_valid_o   ),
      .data_r_rdata_o ( data_r_rdata_o   ),
      .data_r_opc_o   ( data_r_opc_o     ),
      .data_r_aux_o   ( data_r_aux_o     )
   );


   AddressDecoder_Req_BRIDGE
   #(
       .ID_WIDTH        ( ID_WIDTH        ),
       .ID              ( ID              ),
       .N_SLAVE         ( N_SLAVE         )
   )
   i_AddressDecoder_Req_BRIDGE
   (
      // MASTER SIDE
      .data_req_i    ( data_req_i    ), // Request from MASTER
      .destination_i ( destination_i ), // Slave Destination (ONE HOT)
      .data_gnt_o    ( data_gnt_o    ), // Grant delivered to MASTER
      .data_gnt_i    ( data_gnt_i    ), // Grant Array: one for each memory on ARB TREE SIDE
      // ARB TREE SIDE
      .data_req_o    ( data_req_o    ), // Request Array: one for each memory
      .data_ID_o     ( data_ID_o     )  // ID is sent whit the request (like a PID)
   );


endmodule
