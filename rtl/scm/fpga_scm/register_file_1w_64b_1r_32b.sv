// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

/*
 * Francesco Conti <f.conti@unibo.it>
 */

module register_file_1w_64b_1r_32b
#(
    parameter WADDR_WIDTH   = 5,
    parameter WDATA_WIDTH   = 64,

    parameter RDATA_WIDTH   = 32,
    parameter RADDR_WIDTH   = WADDR_WIDTH+$clog2(WDATA_WIDTH/RDATA_WIDTH),

    parameter W_N_ROWS      = 2**WADDR_WIDTH
)
(
    input  logic                                   clk,
    input  logic                                   rst_n,

    // Read port
    input  logic                                   ReadEnable,
    input  logic [RADDR_WIDTH-1:0]                 ReadAddr,
    output logic [RDATA_WIDTH-1:0]                 ReadData,

    // Write port
    input  logic                                   WriteEnable,
    input  logic [WADDR_WIDTH-1:0]                 WriteAddr,
    input  logic [WDATA_WIDTH-1:0]                 WriteData
);


logic [RDATA_WIDTH-1:0]                            ReadData_lo;
logic [RDATA_WIDTH-1:0]                            ReadData_hi;

logic                                              DEST;

int unsigned j;
genvar i;




always_ff @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        DEST <= 0;
    end
    else
    begin
        DEST <= ReadAddr[0];
    end
end



generate


    assign ReadData = (DEST == 1'b0) ?  ReadData_lo : ReadData_hi;



      if(W_N_ROWS == 1)
      begin
          register_file_1r_1w_1row
          #(
              .ADDR_WIDTH ( WADDR_WIDTH ), // 5,
              .DATA_WIDTH ( RDATA_WIDTH ),
              .BLOCK_RAM  ( 1           )
          )
          bram_cut_lo
          (
              .clk         ( clk                        ),
              .rst_n       ( rst_n                      ),

              .ReadEnable  ( ReadEnable                 ),
              .ReadAddr    ( ReadAddr[RADDR_WIDTH-1:1]  ),
              .ReadData    ( ReadData_lo                ),

              .WriteAddr   ( WriteAddr                  ),
              .WriteEnable ( WriteEnable                ),
              .WriteData   ( WriteData[31:0]            )
          );

          register_file_1r_1w_1row
          #(
              .ADDR_WIDTH ( WADDR_WIDTH ), // 5,
              .DATA_WIDTH ( RDATA_WIDTH ),
              .BLOCK_RAM  ( 1           )
          )
          bram_cut_hi
          (
              .clk         ( clk                        ),
              .rst_n       ( rst_n                      ),

              .ReadEnable  ( ReadEnable                 ),
              .ReadAddr    ( ReadAddr[RADDR_WIDTH-1:1]  ),
              .ReadData    ( ReadData_hi                ),

              .WriteAddr   ( WriteAddr                  ),
              .WriteEnable ( WriteEnable                ),
              .WriteData   ( WriteData[63:32]           )
          );
      end
      else
      begin
          register_file_1r_1w
          #(
              .ADDR_WIDTH ( WADDR_WIDTH ), // 5,
              .DATA_WIDTH ( RDATA_WIDTH ), // 64,
              .BLOCK_RAM  ( 1           )
          )
          bram_cut_lo
          (
              .clk         ( clk                       ),
              .rst_n       ( rst_n                     ),

              .ReadEnable  ( ReadEnable                ),
              .ReadAddr    ( ReadAddr[RADDR_WIDTH-1:1] ),
              .ReadData    ( ReadData_lo               ),

              .WriteAddr   ( WriteAddr                 ),
              .WriteEnable ( WriteEnable               ),
              .WriteData   ( WriteData[31:0]           )
          );

          register_file_1r_1w
          #(
              .ADDR_WIDTH ( WADDR_WIDTH ), // 5,
              .DATA_WIDTH ( RDATA_WIDTH ),
              .BLOCK_RAM  ( 1           )
          )
          bram_cut_hi
          (
              .clk         ( clk                       ),
              .rst_n       ( rst_n                     ),

              .ReadEnable  ( ReadEnable                ),
              .ReadAddr    ( ReadAddr[RADDR_WIDTH-1:1] ),
              .ReadData    ( ReadData_hi               ),

              .WriteAddr   ( WriteAddr                 ),
              .WriteEnable ( WriteEnable               ),
              .WriteData   ( WriteData[63:32]          )
          );
      end

endgenerate




endmodule // register_file_multy_way_1w_64b_multi_port_read_32b