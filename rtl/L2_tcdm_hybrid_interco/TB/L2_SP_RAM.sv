// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module L2_SP_RAM
#(
   parameter DATA_WIDTH = 32,
   parameter ADDR_WIDTH = 20,
   parameter BE_WIDTH   = DATA_WIDTH/8,

   parameter AUX_WIDTH  = 4,
   parameter ID_WIDTH   = 3
)
(
   input logic                         CLK,
   input logic                         RSTN,

   input logic                         CEN,
   input logic                         WEN,
   input logic [ADDR_WIDTH-1:0]        A,
   input logic [BE_WIDTH-1:0][7:0]     D,
   input logic [BE_WIDTH-1:0]          BE,
   output logic [DATA_WIDTH-1:0]       Q,

   input  logic [ID_WIDTH-1:0]         id_i,
   output logic [ID_WIDTH-1:0]         r_id_o,

   input  logic [AUX_WIDTH-1:0]        aux_i,
   output logic [AUX_WIDTH-1:0]        r_aux_o,

   output logic                        r_valid_o

);

   localparam numwords = (2**ADDR_WIDTH)-1;

   logic [BE_WIDTH-1:0][7:0]  ram [numwords];
   int unsigned i;




   always @(posedge CLK, negedge RSTN)
   begin
         if(RSTN == 1'b0)
         begin
               r_valid_o <= '0;
               r_aux_o   <= '0;
               r_id_o    <= '0;

               for(i=0;i<numwords;i++)
               begin
                     ram[i]    <= '0;
               end
         end
         else
         begin
               if(~CEN)
               begin

                        r_valid_o <= 1'b1;
                        r_aux_o   <= aux_i;
                        r_id_o    <= id_i;

                        if(~WEN) // write
                        begin
                              for(i=0;i<BE_WIDTH;i++)
                              begin
                                 if(BE[i])
                                    ram[A][i]    <= D[i];
                              end
                              Q <= {DATA_WIDTH{1'bx}};
                        end
                        else
                        begin // read
                           Q <= ram[A];
                        end
               end
               else //~ not request
               begin
                     r_valid_o <= 1'b0;
                     r_aux_o   <= aux_i;
                     r_id_o    <= id_i;
                     Q  <= {DATA_WIDTH{1'bx}};
               end

         end
   end

endmodule
