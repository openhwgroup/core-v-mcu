// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module register_file_1r_1w_1row
#(
    parameter DATA_WIDTH    = 32
)
(
    input  logic                                  clk,

    // Read port
    input  logic                                  ReadEnable,
    output logic [DATA_WIDTH-1:0]                 ReadData,


    // Write port
    input  logic                                  WriteEnable,
    input  logic [DATA_WIDTH-1:0]                 WriteData
);

    // Read address register, located at the input of the address decoder

    logic [DATA_WIDTH-1:0]                        MemContentxDP;

    logic                                         ClocksxC;
    logic [DATA_WIDTH-1:0]                        WDataIntxD;

    logic                                         clk_int;


    cluster_clock_gating CG_WE_GLOBAL
    (
        .clk_o(clk_int),
        .en_i(WriteEnable),
        .test_en_i(1'b0),
        .clk_i(clk)
    );

    //-----------------------------------------------------------------------------
    //-- READ : Read address register
    //-----------------------------------------------------------------------------

    assign ReadData = MemContentxDP;

    // always_ff @(posedge clk)
    // begin
    //     if(ReadEnable)
    //         ReadData <= MemContentxDP;
    // end




    //-----------------------------------------------------------------------------
    //-- WRITE : Clock gating (if integrated clock-gating cells are available)
    //-----------------------------------------------------------------------------
    cluster_clock_gating CG_Inst
    (
            .clk_o(ClocksxC),
            .en_i(WriteEnable),
            .test_en_i(1'b0),
            .clk_i(clk_int)
    );



    //-----------------------------------------------------------------------------
    // WRITE : SAMPLE INPUT DATA
    //---------------------------------------------------------------------------
    always_ff @(posedge clk)
    begin
        if(WriteEnable)
            WDataIntxD <= WriteData;
    end


    //-----------------------------------------------------------------------------
    //-- WRITE : Write operation
    //-----------------------------------------------------------------------------
    always_latch
    begin
            if( ClocksxC == 1'b1)
              MemContentxDP = WDataIntxD;
    end

endmodule