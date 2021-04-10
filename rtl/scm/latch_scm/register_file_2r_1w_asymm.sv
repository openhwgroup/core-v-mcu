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
//                 Michael Gautschi                                           //
//                 Antonio Pullini                                            //
//                                                                            //
//                                                                            //
// Create Date:    12/03/2015                                                 // 
// Design Name:    scm memory multiport   : asymmetrical                      // 
// Module Name:    register_file_2r_2w                                        //
// Project Name:   HWCE                                                       //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    scm memory multiport: FOR HWCE                             //
//                                                                            //
//                                                                            //
// Revision:                                                                  //
// Revision v0.1 - File Created                                               //
// Revision v0.2 - Improved Identation                                        //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////


module register_file_2r_1w_asymm
#(
    parameter ADDR_WIDTH    = 5,
    parameter DATA_WIDTH    = 32,
    parameter NUM_BYTE      = DATA_WIDTH/8,
    parameter ASYMM_FACTOR  = 3
)
(
    input  logic                                  clk,

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
    input  logic [NUM_BYTE-1:0]                   WriteBE
);

    localparam    NUM_WORDS = 2**ADDR_WIDTH;

    // Read address register, located at the input of the address decoder
    logic [ADDR_WIDTH-1:0]                                      RAddrRegxDPa;
    logic [NUM_WORDS-1:0]                                       RAddrOneHotxDa;
    logic [ADDR_WIDTH-1:0]                                      RAddrRegxDPb;
    logic [NUM_WORDS-1:0]                                       RAddrOneHotxDb;

    logic [NUM_WORDS-1:0][NUM_BYTE-1:0][7:0]                    MemContentxDP;
    logic [NUM_WORDS-1:0][ASYMM_FACTOR*NUM_BYTE-1:0][7:0]       MemContentxDPas;

    logic [NUM_WORDS-1:0][NUM_BYTE-1:0]                         WAddrOneHotxD;
    logic [NUM_WORDS-1:0][NUM_BYTE-1:0]                         ClocksxC;
    logic [NUM_BYTE-1:0][7:0]                                   WDataIntxD;

    logic                                                       clk_int;

    int unsigned i;
    int unsigned j;
    int unsigned k;
    int unsigned l;
    int unsigned m;

    genvar x;
    genvar y;

    cluster_clock_gating CG_WE_GLOBAL
    (
        .clk_o     ( clk_int     ),
        .en_i      ( WriteEnable ),
        .test_en_i ( 1'b0        ),
        .clk_i     ( clk         )
    );

    /* Asymmetric port - just wiring here */
    generate
        for(x=0; x<2**ADDR_WIDTH; x++) 
        begin : asymm_circular_rewiring_gen
            localparam x_low  = x                  % (2**ADDR_WIDTH);
            localparam x_high = (x+ASYMM_FACTOR-1) % (2**ADDR_WIDTH);

            if(x_high > x_low)
                assign MemContentxDPas[x_low] = MemContentxDP[x_high:x_low];
            else
                assign MemContentxDPas[x_low] = {MemContentxDP[x_high:0], MemContentxDP[{ADDR_WIDTH{1'b1}}:x_low]};
        end
    endgenerate
    /* End asymettric port */

    //-----------------------------------------------------------------------------
    //-- READ : Read address register
    //-----------------------------------------------------------------------------

    always_ff @(posedge clk)
    begin : p_RAddrReg_a
        if(ReadEnable_a)
            RAddrRegxDPa <= ReadAddr_a;
    end

    always_ff @(posedge clk)
    begin : p_RAddrReg_b
        if(ReadEnable_b)
            RAddrRegxDPb <= ReadAddr_b;
    end  

    //-----------------------------------------------------------------------------
    //-- READ : Read address decoder RAD
    //-----------------------------------------------------------------------------  
    always_comb
    begin : p_RAD_a
        RAddrOneHotxDa = '0;
        RAddrOneHotxDa[RAddrRegxDPa] = 1'b1;
    end
    assign ReadData_a = MemContentxDP[RAddrRegxDPa];

    always_comb
    begin : p_RAD_b
        RAddrOneHotxDb = '0;
        RAddrOneHotxDb[RAddrRegxDPb] = 1'b1;
    end
    assign ReadData_b = MemContentxDPas[RAddrRegxDPb];

    //-----------------------------------------------------------------------------
    //-- WRITE : Write Address Decoder (WAD), combinatorial process
    //-----------------------------------------------------------------------------
    always_comb
    begin : p_WAD
        for(i=0; i<NUM_WORDS; i++)
        begin : p_WordIter
            for(j=0; j<NUM_BYTE; j++)
            begin : p_ByteIter
                if ( (WriteEnable == 1'b1 ) && (WriteBE[j] == 1'b1) &&  (WriteAddr == i) )
                    WAddrOneHotxD[i][j] = 1'b1;
                else
                    WAddrOneHotxD[i][j] = 1'b0;
            end
        end
    end

    //-----------------------------------------------------------------------------
    //-- WRITE : Clock gating (if integrated clock-gating cells are available)
    //-----------------------------------------------------------------------------
    generate
        for(x=0; x<NUM_WORDS; x++)
        begin : CG_CELL_WORD_ITER
            for(y=0; y<NUM_BYTE; y++)
            begin : CG_CELL_BYTE_ITER
                cluster_clock_gating CG_Inst
                (
                    .clk_o     ( ClocksxC[x][y]      ),
                    .en_i      ( WAddrOneHotxD[x][y] ),
                    .test_en_i ( 1'b0                ),
                    .clk_i     ( clk_int             )
                );
            end
        end
    endgenerate

   //-----------------------------------------------------------------------------
   // WRITE : SAMPLE INPUT DATA
    //---------------------------------------------------------------------------  
    always_ff @(posedge clk)
    begin : sample_waddr
        for(m=0; m<NUM_BYTE; m++)
        begin
            if(WriteEnable & WriteBE[m])
                WDataIntxD[m] <= WriteData[m];
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
            for(l=0; l<NUM_BYTE; l++)
            begin : w_ByteIter
                if( ClocksxC[k][l] == 1'b1)
                    MemContentxDP[k][l] = WDataIntxD[l];
            end
        end
    end

endmodule