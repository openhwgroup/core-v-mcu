// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module FanInPrimitive_Req_L2
#(
   parameter ADDR_WIDTH = 32,
   parameter ID_WIDTH   = 16,
   parameter DATA_WIDTH = 64,
   parameter BE_WIDTH   = DATA_WIDTH/8
)
(
   input logic                                       RR_FLAG,
   // LEFT SIDE
   input  logic [DATA_WIDTH-1:0]                     data_wdata0_i,
   input  logic [DATA_WIDTH-1:0]                     data_wdata1_i,
   input  logic [ADDR_WIDTH-1:0]                     data_add0_i,
   input  logic [ADDR_WIDTH-1:0]                     data_add1_i,
   input  logic                                      data_req0_i,
   input  logic                                      data_req1_i,
   input  logic                                      data_wen0_i,
   input  logic                                      data_wen1_i,
   input  logic [BE_WIDTH-1:0]                       data_be0_i,
   input  logic [BE_WIDTH-1:0]                       data_be1_i,
   input  logic [ID_WIDTH-1:0]                       data_ID0_i,
   input  logic [ID_WIDTH-1:0]                       data_ID1_i,
   output logic                                      data_gnt0_o,
   output logic                                      data_gnt1_o,

   // RIGTH SIDE
   output logic [DATA_WIDTH-1:0]                     data_wdata_o,
   output logic [ADDR_WIDTH-1:0]                     data_add_o,
   output logic                                      data_req_o,
   output logic [ID_WIDTH-1:0]                       data_ID_o,
   output logic                                      data_wen_o,
   output logic [BE_WIDTH-1:0]                       data_be_o,
   input  logic                                      data_gnt_i
);

   logic   SEL;

   assign data_req_o       =     data_req0_i | data_req1_i;
   assign SEL              =    ~data_req0_i | ( RR_FLAG & data_req1_i);   // SEL FOR ROUND ROBIN MUX

   // Grant gnt0 and gnt1
   assign data_gnt0_o      =    (( data_req0_i & ~data_req1_i) | ( data_req0_i & ~RR_FLAG)) & data_gnt_i;
   assign data_gnt1_o      =    ((~data_req0_i &  data_req1_i) | ( data_req1_i &  RR_FLAG)) & data_gnt_i;


   // SEL CONTROLLER

   //MUXES AND DEMUXES
   always_comb
   begin : FanIn_MUX2
      case(SEL) //synopsys full_case
         1'b0:
         begin //PRIORITY ON CH_0
            data_wdata_o = data_wdata0_i;
            data_add_o   = data_add0_i;
            data_wen_o   = data_wen0_i;
            data_ID_o    = data_ID0_i;
            data_be_o    = data_be0_i;
         end

         1'b1:
         begin //PRIORITY ON CH_1
            data_wdata_o = data_wdata1_i;
            data_add_o   = data_add1_i;
            data_wen_o   = data_wen1_i;
            data_ID_o    = data_ID1_i;
            data_be_o    = data_be1_i;
         end

      endcase
   end



endmodule
