// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module TGEN_32
#(
   parameter ID_WIDTH        = 10,
   parameter AUX_WIDTH       = 5,
   parameter ADDR_WIDTH      = 32,
   parameter DATA_WIDTH      = 32,
   parameter BE_WIDTH        = DATA_WIDTH/8
)
(
   output logic                          data_req_o,
   input  logic                          data_gnt_i,

   output logic [ADDR_WIDTH-1:0]         data_add_o,
   output logic                          data_wen_o,
   output logic [DATA_WIDTH-1:0]         data_wdata_o,
   output logic [BE_WIDTH-1:0]           data_be_o,
   output logic [AUX_WIDTH-1:0]          data_aux_o,

   input  logic                          data_err_i,

   input  logic                          data_r_valid_i,
   input  logic [DATA_WIDTH-1:0]         data_r_rdata_i,
   input  logic [AUX_WIDTH-1:0]          data_r_aux_i,

   input  logic                          clk,
   input  logic                          rst_n,

   input  logic                          fetch_enable_i
);


   event start_inj;
   event trans_granted;

   always_ff @(posedge clk)
   begin
         if(fetch_enable_i)
         begin
            -> start_inj;
         end

         if(data_req_o & data_gnt_i)
         begin
            -> trans_granted;
         end
   end


   initial
   begin
      NOP;

      @(start_inj);

      for( int unsigned j = 0; j < 100; j++)
      begin
         Write32( .addr(32'h0000_0000 + j*4),  .aux($random % (2**AUX_WIDTH) ),  .wdata($random),  .be('1)  );
      end

   end

   task NOP;
   begin
      data_req_o   <= '0;
      data_add_o   <= '0;
      data_wen_o   <= '0;
      data_wdata_o <= '0;
      data_be_o    <= '0;
      data_aux_o   <= '0;
      @(posedge clk);
   end
   endtask



   task Write32;
      input logic [ADDR_WIDTH-1:0]     addr;
      input logic [AUX_WIDTH-1:0]      aux;
      input logic [DATA_WIDTH-1:0]     wdata;
      input logic [DATA_WIDTH/8-1:0]   be;
   begin
      data_req_o   <= 1'b1;
      data_add_o   <= addr;
      data_wen_o   <= 1'b0;
      data_wdata_o <= wdata;
      data_be_o    <= be;
      data_aux_o   <= aux;
      @(trans_granted);

      data_req_o   <= '0;
      data_add_o   <= '0;
      data_wen_o   <= '0;
      data_wdata_o <= '0;
      data_be_o    <= '0;
      data_aux_o   <= '0;
   end
   endtask


   task Read32;
      input logic [ADDR_WIDTH-1:0] addr;
      input logic [AUX_WIDTH-1:0]  aux;
   begin
      data_req_o   <= 1'b1;
      data_add_o   <= addr;
      data_wen_o   <= 1'b1;
      data_wdata_o <= '0;
      data_be_o    <= '0;
      data_aux_o   <= aux;
      @(trans_granted);

      data_req_o   <= '0;
      data_add_o   <= '0;
      data_wen_o   <= '0;
      data_wdata_o <= '0;
      data_be_o    <= '0;
      data_aux_o   <= '0;
   end
   endtask

endmodule
