// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module register_file_1w_multi_port_read_1row
#(
    parameter ADDR_WIDTH    = 5,
    parameter DATA_WIDTH    = 32,

    parameter N_READ        = 2,
    parameter N_WRITE       = 1
)
(
    input  logic                                   clk,
    input  logic                                   test_en_i,

    // Read port
    input  logic [N_READ-1:0]                      ReadEnable,
    output logic [N_READ-1:0][DATA_WIDTH-1:0]      ReadData,

    // Write port
    input  logic                                   WriteEnable,
    input  logic [DATA_WIDTH-1:0]                  WriteData
);

    localparam    NUM_WORDS = 1;

    // Read address register, located at the input of the address decoder

    logic [DATA_WIDTH-1:0]                         MemContentxDP;

    logic                                          ClocksxC;
    logic [DATA_WIDTH-1:0]                         WDataIntxD;

    logic                                          clk_int;

    genvar z;

    cluster_clock_gating CG_WE_GLOBAL
    (
        .clk_o     ( clk_int        ),
        .en_i      ( WriteEnable    ),
        .test_en_i ( test_en_i      ),
        .clk_i     ( clk            )
    );

    //-----------------------------------------------------------------------------
    //-- READ : Read address register
    //-----------------------------------------------------------------------------

    generate
        for(z=0; z<N_READ; z++ )
        begin
            assign ReadData[z] = MemContentxDP;
        end
    endgenerate


    //-----------------------------------------------------------------------------
    //-- WRITE : Clock gating (if integrated clock-gating cells are available)
    //-----------------------------------------------------------------------------

    cluster_clock_gating CG_Inst
    (
      .clk_o     ( ClocksxC         ),
      .en_i      ( WriteEnable      ),
      .test_en_i ( 1'b0             ), // test Enable is not affecting those cells
      .clk_i     ( clk_int          )
    );





    //-----------------------------------------------------------------------------
    // WRITE : SAMPLE INPUT DATA
    //---------------------------------------------------------------------------
    always_ff @(posedge clk)
    begin : sample_waddr
            if(WriteEnable )
              WDataIntxD <= WriteData;
    end


    always_latch
    begin : latch_wdata
            if( ClocksxC == 1'b1)
              MemContentxDP = WDataIntxD;
    end


endmodule
