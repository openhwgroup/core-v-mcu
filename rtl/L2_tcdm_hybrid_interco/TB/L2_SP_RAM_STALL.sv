// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module L2_SP_RAM_STALL
#(
   parameter DATA_WIDTH = 32,
   parameter ADDR_WIDTH = 20,
   parameter BE_WIDTH   = DATA_WIDTH/8,

   parameter AUX_WIDTH  = 4,
   parameter ID_WIDTH   = 3,

   parameter LOG_NUM_ROWS = 20
)
(
   input  logic                         CLK,
   input  logic                         RSTN,

   input  logic                         CEN,
   input  logic                         WEN,
   input  logic [ADDR_WIDTH-1:0]        A,
   input  logic [BE_WIDTH-1:0][7:0]     D,
   input  logic [BE_WIDTH-1:0]          BE,

   output logic [DATA_WIDTH-1:0]        Q,


   output logic                        gnt_o,
   input  logic                        r_gnt_i,

   input  logic [ID_WIDTH-1:0]         id_i,
   output logic [ID_WIDTH-1:0]         r_id_o,

   input  logic [AUX_WIDTH-1:0]        aux_i,
   output logic [AUX_WIDTH-1:0]        r_aux_o,

   output logic                        r_valid_o
);

   localparam numwords = (2**LOG_NUM_ROWS)-1;

   logic [BE_WIDTH-1:0][7:0]  ram [numwords];
   int unsigned i;

   logic                     r_valid_int;
   logic                     r_gnt_int;
   logic [AUX_WIDTH-1:0]     r_aux_int;
   logic [ID_WIDTH-1:0]      r_id_int;
   logic [DATA_WIDTH-1:0]    Q_int;


   always_ff @(posedge CLK or negedge RSTN)
   begin
      if(~RSTN)
      begin
         gnt_o <= 0;
      end
      else
      begin
          gnt_o <= $random()%2;
      end
   end

   always @(posedge CLK, negedge RSTN)
   begin
         if(RSTN == 1'b0)
         begin
               r_valid_int <= '0;
               r_aux_int   <= '0;
               r_id_int    <= '0;

               for(i=0;i<numwords;i++)
               begin
                     ram[i]    <= '0;
               end
         end
         else
         begin
               if(~CEN & gnt_o & r_gnt_int)
               begin

                  r_valid_int <= 1'b1;
                  r_aux_int   <= aux_i;
                  r_id_int    <= id_i;

                  if(~WEN) // write
                  begin
                        for(i=0;i<BE_WIDTH;i++)
                        begin
                           if(BE[i])
                              ram[A[LOG_NUM_ROWS-1:0]][i]    <= D[i];
                        end
                        Q_int <= {DATA_WIDTH{1'bx}};
                  end
                  else
                  begin // read
                     Q_int <= ram[A[LOG_NUM_ROWS-1:0]];
                  end
               end
               else //~ not request
               begin
                     r_valid_int <= 1'b0;
                     r_aux_int   <= aux_i;
                     r_id_int    <= id_i;
                     Q_int       <= {DATA_WIDTH{1'bx}};
               end

         end
   end



    generic_fifo
    #(
       .DATA_WIDTH(ID_WIDTH+AUX_WIDTH+DATA_WIDTH),
       .DATA_DEPTH(8)
    )
    FIFO_OUT
    (
       .clk         ( clk                          ),
       .rst_n       ( rst_n                        ),

       .data_i      ( {Q_int, r_aux_int, r_id_int} ),
       .valid_i     ( r_valid_int                  ),
       .grant_o     ( r_gnt_int                    ),

       .data_o      ( {Q, r_aux_o, r_id_o}         ),
       .valid_o     ( r_valid_o                    ),
       .grant_i     ( r_gnt_i                      ),

       .test_mode_i ( 1'b0                         )
    );


endmodule
