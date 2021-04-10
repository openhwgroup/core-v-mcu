// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

////////////////////////////////////////////////////////////////////////////////
// Engineer:       Davide Rossi - davide.rossi@unibo.it                       //
//                                                                            //
//                                                                            //
// Create Date:    31/03/2016                                                 //
// Design Name:    PULP                                                       //
// Module Name:    apb2per                                                    //
// Project Name:   PULP                                                       //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    apb 2 peripheral interconnect protocl adapter              //
//                                                                            //
//                                                                            //
// Revision:                                                                  //
// Revision v0.1 - File Created                                               //
////////////////////////////////////////////////////////////////////////////////

module apb2per
#(
   parameter PER_ADDR_WIDTH = 32,
   parameter APB_ADDR_WIDTH = 32
)
(
   // APB BUS SIGNALS
   input  logic                      clk_i,
   input  logic                      rst_ni,

   input  logic [APB_ADDR_WIDTH-1:0] PADDR,
   input  logic [31:0]               PWDATA,
   input  logic                      PWRITE,
   input  logic                      PSEL,
   input  logic                      PENABLE,
   output logic [31:0]               PRDATA,
   output logic                      PREADY,
   output logic                      PSLVERR,

   // PERIPHERAL INTERCONNECT MASTER
   //***************************************
   //REQUEST CHANNEL
   output logic                      per_master_req_o,
   output logic [PER_ADDR_WIDTH-1:0] per_master_add_o,
   output logic                      per_master_we_o,
   output logic [31:0]               per_master_wdata_o,
   output logic [3:0]                per_master_be_o,
   input  logic                      per_master_gnt_i,

   //RESPONSE CHANNEL
   input logic                       per_master_r_valid_i,
   input logic                       per_master_r_opc_i,
   input logic [31:0]                per_master_r_rdata_i
);

   enum  logic  { TRANS_IDLE, TRANS_RUN } CS, NS;

   // UPDATE THE STATE
   always_ff @(posedge clk_i, negedge rst_ni)
   begin
      if(rst_ni == 1'b0)
      begin
         CS <= TRANS_IDLE;
      end
      else
      begin
         CS <= NS;
      end
   end

   // COMPUTE NEXT STATE
   always_comb
   begin

      per_master_we_o  = 0;
      per_master_req_o = 0;
      PREADY = 0;

      case(CS)

         TRANS_IDLE:
         begin
            if ( PSEL == 1 && PENABLE == 1 )
            begin
               per_master_req_o = 1;

               if ( PWRITE == 1 )
                 per_master_we_o = 1'b1;
               else
                 per_master_we_o = 1'b0;

               if ( per_master_gnt_i == 1 )
               begin
                  if ( PWRITE == 1 )
                  begin
                     PREADY          = 1;
                     NS              = TRANS_IDLE;
                  end
                  else
                  begin
                     PREADY           = 0;
                     NS               = TRANS_RUN;
                  end
               end
               else
               begin
                  PREADY = 0;
                  NS     = TRANS_IDLE;
               end
            end
            else
            begin
               NS     = TRANS_IDLE;
               PREADY = 0;
            end
         end //~TRANS_IDLE



         TRANS_RUN:
         begin
            if ( per_master_r_valid_i == 1 )
            begin
               PREADY = 1;
               NS = TRANS_IDLE;
            end
            else
            begin
               PREADY = 0;
               NS = TRANS_RUN;
            end
         end //~TRANS_RUN



         default :
         begin
            NS = TRANS_IDLE;
         end //~default

      endcase
   end

   assign PRDATA  = per_master_r_rdata_i;
   assign PSLVERR = '0;

   assign per_master_add_o   = PADDR;
   assign per_master_wdata_o = PWDATA;
   assign per_master_be_o    = '1;

endmodule
