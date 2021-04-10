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
    parameter N_WRITE       = 1
)
(
    input  logic                                   clk,
    input  logic                                   rst_n,
    input  logic                                   test_en_i,

    // Read port
    input  logic [N_READ-1:0]                      ReadEnable,
    input  logic [N_READ-1:0][ADDR_WIDTH-1:0]      ReadAddr,
    output logic [N_READ-1:0][DATA_WIDTH-1:0]      ReadData,

    // Write port
    input  logic                                   WriteEnable,
    input  logic [ADDR_WIDTH-1:0]                  WriteAddr,
    input  logic [DATA_WIDTH-1:0]                  WriteData
);

    localparam    NUM_WORDS = 2**ADDR_WIDTH;

    // Read address register, located at the input of the address decoder
    logic [N_READ-1:0][ADDR_WIDTH-1:0]             RAddrRegxDP;
    logic [N_READ-1:0][NUM_WORDS-1:0]              RAddrOneHotxD;

    logic [DATA_WIDTH-1:0]                         MemContentxDP[NUM_WORDS];

    logic [NUM_WORDS-1:0]                          WAddrOneHotxD;
    logic [NUM_WORDS-1:0]                          ClocksxC;
    logic [DATA_WIDTH-1:0]                         WDataIntxD;

    logic                                          clk_int;

    int unsigned i;
    int unsigned k;

    genvar       x;
    genvar       z;

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
            always_ff @(posedge clk)
            begin : p_RAddrReg
                if(rst_n == 1'b0)
                begin
                    RAddrRegxDP[z] <= '0;
                end
                else
                begin
                    if( ReadEnable[z] )
                        RAddrRegxDP[z] <= ReadAddr[z];
                end
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
    //-- WRITE : Write Address Decoder (WAD), combinatorial process
    //-----------------------------------------------------------------------------
    always_comb
    begin : p_WAD
      for(i=0; i<NUM_WORDS; i++)
      begin : p_WordIter
            if ( (WriteEnable == 1'b1 ) && (WriteAddr == i) )
              WAddrOneHotxD[i] = 1'b1;
            else
              WAddrOneHotxD[i] = 1'b0;
      end
    end



    //-----------------------------------------------------------------------------
    //-- WRITE : Clock gating (if integrated clock-gating cells are available)
    //-----------------------------------------------------------------------------
    generate
        for(x=0; x<NUM_WORDS; x++)
        begin : CG_CELL_WORD_ITER
                cluster_clock_gating CG_Inst
                (
                  .clk_o     ( ClocksxC[x]      ),
                  .en_i      ( WAddrOneHotxD[x] ),
                  .test_en_i ( 1'b0             ), // test Enable is not affecting those cells
                  .clk_i     ( clk_int          )
                );
        end
    endgenerate




    //-----------------------------------------------------------------------------
    // WRITE : SAMPLE INPUT DATA
    //---------------------------------------------------------------------------
    always_ff @(posedge clk)
    begin : sample_waddr
        if(rst_n == 1'b0)
        begin
            WDataIntxD <= '0;
        end
        else
        begin
            if(WriteEnable )
              WDataIntxD <= WriteData;
        end
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
      for(k=0; k<NUM_WORDS; k++)
        begin : w_WordIter
            if( ClocksxC[k] == 1'b1)
              MemContentxDP[k] <= WDataIntxD;
        end
    end


endmodule