// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module register_file_1w_multi_port_read
#(
    parameter ADDR_WIDTH    = 5,
    parameter DATA_WIDTH    = 32,

    parameter N_READ        = 2,
    parameter N_WRITE       = 1,
    parameter W_N_ROWS      = 2**ADDR_WIDTH
)
(
    input  logic                                   clk,
    input  logic                                   test_en_i,
    input   logic                                  rst_n,

    // Read port
    input  logic [N_READ-1:0]                      ReadEnable,
    input  logic [N_READ-1:0][ADDR_WIDTH-1:0]      ReadAddr,
    output logic [N_READ-1:0][DATA_WIDTH-1:0]      ReadData,

    // Write port
    input  logic                                   WriteEnable,
    input  logic [ADDR_WIDTH-1:0]                  WriteAddr,
    input  logic [DATA_WIDTH-1:0]                  WriteData
);



genvar i;

generate
   for(i=0; i<N_READ; i++)
   begin :  CUT
      if(W_N_ROWS == 1)
      begin
            register_file_1r_1w_1row
            #(
                .DATA_WIDTH ( DATA_WIDTH )  // 64,
      `ifdef PULP_FPGA_EMUL
                ,
                .BLOCK_RAM  ( 1          )  // 1
      `endif
            )
            bram_cut
            (
                .clk         ( clk           ),
      `ifdef PULP_FPGA_EMUL
                .rst_n       ( rst_n         ),
      `endif

                .ReadEnable  ( ReadEnable[i] ),
                .ReadData    ( ReadData[i]   ),

                .WriteEnable ( WriteEnable   ),
                .WriteData   ( WriteData     )
            );
       end
       else
       begin
            register_file_1r_1w
            #(
                .ADDR_WIDTH ( ADDR_WIDTH ), // 5,
                .DATA_WIDTH ( DATA_WIDTH )  // 64,
      `ifdef PULP_FPGA_EMUL
                ,
                .BLOCK_RAM  ( 1          )  // 1
      `endif
            )
            bram_cut
            (
                .clk         ( clk           ),
      `ifdef PULP_FPGA_EMUL
                .rst_n       ( rst_n         ),
      `endif

                .ReadEnable  ( ReadEnable[i] ),
                .ReadAddr    ( ReadAddr[i]   ),
                .ReadData    ( ReadData[i]   ),

                .WriteAddr   ( WriteAddr     ),
                .WriteEnable ( WriteEnable   ),
                .WriteData   ( WriteData     )
            );
       end

   end
endgenerate

endmodule // register_file_1w_multi_port_read






