// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module register_file_1r_1w_test_wrap
#(
    parameter ADDR_WIDTH    = 5,
    parameter DATA_WIDTH    = 32
)
(
    input  logic                                  clk,

    // Read port
    input  logic                                  ReadEnable,
    input  logic [ADDR_WIDTH-1:0]                 ReadAddr,
    output logic [DATA_WIDTH-1:0]                 ReadData,


    // Write port
    input  logic                                  WriteEnable,
    input  logic [ADDR_WIDTH-1:0]                 WriteAddr,
    input  logic [DATA_WIDTH-1:0]                 WriteData,

    // BIST ENABLE
    input  logic                                  BIST,
    //BIST ports
    input  logic                                  CSN_T,
    input  logic                                  WEN_T,
    input  logic [ADDR_WIDTH-1:0]                 A_T,
    input  logic [DATA_WIDTH-1:0]                 D_T,
    output logic [DATA_WIDTH-1:0]                 Q_T
);

   logic                         ReadEnable_muxed;
   logic [ADDR_WIDTH-1:0]        ReadAddr_muxed;

   logic                         WriteEnable_muxed;
   logic [ADDR_WIDTH-1:0]        WriteAddr_muxed;
   logic [DATA_WIDTH-1:0]        WriteData_muxed;


   always_comb
   begin
      if(BIST)
      begin
         ReadEnable_muxed  = (( CSN_T == 1'b0 ) && ( WEN_T == 1'b1));
         ReadAddr_muxed    = A_T;

         WriteEnable_muxed = (( CSN_T == 1'b0 ) && ( WEN_T == 1'b0));
         WriteAddr_muxed   = A_T;
         WriteData_muxed   = D_T;
      end
      else
      begin
         ReadEnable_muxed  = ReadEnable;
         ReadAddr_muxed    = ReadAddr;

         WriteEnable_muxed = WriteEnable;
         WriteAddr_muxed   = WriteAddr;
         WriteData_muxed   = WriteData;
      end
   end

   assign Q_T = ReadData;

   register_file_1r_1w
   #(
       .ADDR_WIDTH  ( ADDR_WIDTH ),
       .DATA_WIDTH  ( DATA_WIDTH )
   )
   register_file_1r_1w_i
   (
      .clk          ( clk ),

      .ReadEnable   ( ReadEnable_muxed  ),
      .ReadAddr     ( ReadAddr_muxed    ),
      .ReadData     ( ReadData          ),

      .WriteEnable  ( WriteEnable_muxed ),
      .WriteAddr    ( WriteAddr_muxed   ),
      .WriteData    ( WriteData_muxed   )
   );

endmodule // register_file_1r_1w_test_wrap