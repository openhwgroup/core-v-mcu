// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

////////////////////////////////////////////////////////////////////////////////
// Company:        Institute of Integrated Systems // ETH Zurich              //
//                                                                            //
// Engineer:      Igor Loi - igor.loi@unibo.it                                //
//                                                                            //
// Additional contributions by:                                               //
//                 Francesco Conti                                            //
//                 Davide Rossi                                               //
//                 Michael Gautshi                                            //
//                 Antonio Pullini                                            //
//                                                                            //
//                                                                            //
// Create Date:    01/03/2017                                                 //
// Design Name:    scm memory multiport   : asymmetrical                      //
// Module Name:    register_file_2r_1w_asymm_test_wrap                        //
// Project Name:   HWCE                                                       //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    scm memory multiport with test pins for BIST intertions    //
//                 : FOR HWCE                                                 //
//                                                                            //
//                                                                            //
// Revision:                                                                  //
// Revision v0.1 - File Created                                               //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////


module register_file_2r_1w_asymm_test_wrap
#(
    parameter ADDR_WIDTH    = 5,
    parameter DATA_WIDTH    = 32,
    parameter NUM_BYTE      = DATA_WIDTH/8,
    parameter ASYMM_FACTOR  = 3
)
(
    input  logic                                  clk,
    input  logic                                  rst_n,

    // Read port a
    input  logic                                  ReadEnable_a,
    input  logic [ADDR_WIDTH-1:0]                 ReadAddr_a,
    output logic [DATA_WIDTH-1:0]                 ReadData_a,

    // Read port b (asymmetrical)
    input  logic                                  ReadEnable_b,
    input  logic [ADDR_WIDTH-1:0]                 ReadAddr_b,
    output logic [ASYMM_FACTOR*DATA_WIDTH-1:0]    ReadData_b,

    // Write port
    input  logic                                  WriteEnable,
    input  logic [ADDR_WIDTH-1:0]                 WriteAddr,
    input  logic [NUM_BYTE-1:0][7:0]              WriteData,
    input  logic [NUM_BYTE-1:0]                   WriteBE,

    // BIST ENABLE
    input  logic                                  BIST,
    //BIST ports
    input  logic                                  CSN_T,
    input  logic                                  WEN_T,
    input  logic [ADDR_WIDTH-1:0]                 A_T,
    input  logic [DATA_WIDTH-1:0]                 D_T,
    input  logic [NUM_BYTE-1:0]                   BE_T,
    output logic [DATA_WIDTH-1:0]                 Q_T
);


   logic                         ReadEnable_muxed;
   logic [ADDR_WIDTH-1:0]        ReadAddr_muxed;

   logic                         WriteEnable_muxed;
   logic [ADDR_WIDTH-1:0]        WriteAddr_muxed;
   logic [DATA_WIDTH-1:0]        WriteData_muxed;
   logic [NUM_BYTE-1:0]          WriteBE_muxed;


   always_comb
   begin
      if(BIST)
      begin
         ReadEnable_muxed  = (( CSN_T == 1'b0 ) && ( WEN_T == 1'b1));
         ReadAddr_muxed    = A_T;

         WriteEnable_muxed = (( CSN_T == 1'b0 ) && ( WEN_T == 1'b0));
         WriteAddr_muxed   = A_T;
         WriteData_muxed   = D_T;
         WriteBE_muxed     = BE_T;
      end
      else
      begin
         ReadEnable_muxed  = ReadEnable_a;
         ReadAddr_muxed    = ReadAddr_a;

         WriteEnable_muxed = WriteEnable;
         WriteAddr_muxed   = WriteAddr;
         WriteData_muxed   = WriteData;
         WriteBE_muxed     = WriteBE;
      end
   end

   assign Q_T = ReadData_a;



   register_file_2r_1w_asymm
   #(
      .ADDR_WIDTH    ( ADDR_WIDTH   ),  // 5,
      .DATA_WIDTH    ( DATA_WIDTH   ),  // 32,
      .NUM_BYTE      ( NUM_BYTE     ),  // DATA_WIDTH/8,
      .ASYMM_FACTOR  ( ASYMM_FACTOR )   // 3
   )
   register_file_2r_1w_asymm_test_wrap_i
   (
      .clk          ( clk               ),
      .rst_n        ( rst_n             ),
      // Read port a
      .ReadEnable_a ( ReadEnable_muxed  ),
      .ReadAddr_a   ( ReadAddr_muxed    ),
      .ReadData_a   ( ReadData_a        ),

      // Read port b: asymmetrical
      .ReadEnable_b ( ReadEnable_b      ),
      .ReadAddr_b   ( ReadAddr_b        ),
      .ReadData_b   ( ReadData_b        ),

      // Write port
      .WriteEnable  ( WriteEnable_muxed ),
      .WriteAddr    ( WriteAddr_muxed   ),
      .WriteData    ( WriteData_muxed   ),
      .WriteBE      ( WriteBE_muxed     )
   );

endmodule // register_file_2r_1w_asymm_test_wrap
