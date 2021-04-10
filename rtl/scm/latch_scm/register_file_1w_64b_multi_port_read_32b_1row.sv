// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module register_file_1w_64b_multi_port_read_32b_1row
#(
    parameter WADDR_WIDTH   = 0,
    parameter WDATA_WIDTH   = 64,

    parameter RDATA_WIDTH   = 32,
    parameter RADDR_WIDTH   = $clog2(WDATA_WIDTH/RDATA_WIDTH),

    parameter N_READ        = 4,
    parameter N_WRITE       = 1
)
(
    input  logic                                   clk,
    input  logic                                   rst_n,

    // Read port
    input  logic [N_READ-1:0]                      ReadEnable,
    input  logic [N_READ-1:0][RADDR_WIDTH-1:0]     ReadAddr,
    output logic [N_READ-1:0][RDATA_WIDTH-1:0]     ReadData,

    // Write port
    input  logic                                   WriteEnable,
    input  logic [WDATA_WIDTH-1:0]                 WriteData
);

    localparam    NUM_R_WORDS = 2**RADDR_WIDTH;
    localparam    NUM_W_WORDS = 1;

    // Read address register, located at the input of the address decoder
    logic [N_READ-1:0][RADDR_WIDTH-1:0]            RAddrRegxDP;
    logic [N_READ-1:0][NUM_R_WORDS-1:0]            RAddrOneHotxD;

    logic [RDATA_WIDTH-1:0]                        MemContentxDP[NUM_R_WORDS];


    logic                                                ClocksxC;
    logic [WDATA_WIDTH/RDATA_WIDTH-1:0][RDATA_WIDTH-1:0] WDataIntxD;

    logic                                                clk_int;

    int unsigned i;
    int unsigned k;

    genvar       x;
    genvar       z;

    cluster_clock_gating CG_WE_GLOBAL
    (
        .clk_o     ( clk_int        ),
        .en_i      ( WriteEnable    ),
        .test_en_i ( 1'b0           ),
        .clk_i     ( clk            )
    );

    //-----------------------------------------------------------------------------
    //-- READ : Read address register
    //-----------------------------------------------------------------------------

    generate
        for(z=0; z<N_READ; z++ )
        begin
            always_ff @(posedge clk)
            begin : p_RAddrReg
              if( ReadEnable[z] )
                RAddrRegxDP[z] <= ReadAddr[z];
            end



    //-----------------------------------------------------------------------------
    //-- READ : Read address decoder RAD
    //-----------------------------------------------------------------------------
            always @(*)
            begin : p_RAD
              RAddrOneHotxD[z] = '0;
              RAddrOneHotxD[z][RAddrRegxDP[z]] = 1'b1;
            end
            assign ReadData[z] = MemContentxDP[RAddrRegxDP[z]];

        end
    endgenerate


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
    begin : sample_waddr
            if(WriteEnable )
              WDataIntxD <= WriteData;
    end





    //-----------------------------------------------------------------------------
    //-- WRITE : Write operation
    //-----------------------------------------------------------------------------
    //-- Generate M = WORDS sequential processes, each of which describes one
    //-- word of the memory. The processes are synchronized with the clocks
    //-- ClocksxC(i), i = 0, 1, ..., M-1
    //-- Use active low, i.e. transparent on low latches as storage elements
    //-- Data is sampled on rising clock edge

    always_latch
    begin : latch_wdata
            if( ClocksxC == 1'b1)
            begin
              MemContentxDP[0]   = WDataIntxD[0];
              MemContentxDP[1]   = WDataIntxD[1];
            end
    end


endmodule
