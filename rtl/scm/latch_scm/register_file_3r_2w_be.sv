// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module register_file_3r_2w_be
#(
    parameter ADDR_WIDTH    = 5,
    parameter DATA_WIDTH    = 32,
    parameter NUM_BYTE      = DATA_WIDTH/8
)
(
    input  logic                                clk,

    // Read port A
    input  logic                                ReadEnable_A,
    input  logic [ADDR_WIDTH-1:0]               ReadAddr_A,
    output logic [DATA_WIDTH-1:0]               ReadData_A,

    // Read port B
    input  logic                                ReadEnable_B,
    input  logic [ADDR_WIDTH-1:0]               ReadAddr_B,
    output logic [DATA_WIDTH-1:0]               ReadData_B,

    // Read port C
    input  logic                                ReadEnable_C,
    input  logic [ADDR_WIDTH-1:0]               ReadAddr_C,
    output logic [DATA_WIDTH-1:0]               ReadData_C,

    // Write port A
    input  logic                                WriteEnable_A,
    input  logic [ADDR_WIDTH-1:0]               WriteAddr_A,
    input  logic [NUM_BYTE-1:0][7:0]            WriteData_A,
    input  logic [NUM_BYTE-1:0]                 WriteBE_A,

    // Write port B
    input  logic                                WriteEnable_B,
    input  logic [ADDR_WIDTH-1:0]               WriteAddr_B,
    input  logic [NUM_BYTE-1:0][7:0]            WriteData_B,
    input  logic [NUM_BYTE-1:0]                 WriteBE_B

);

    localparam    NUM_WORDS = 2**ADDR_WIDTH;

    // Read address register, located at the input of the address decoder
    logic [ADDR_WIDTH-1:0]                         RAddrRegxDP_A;

    logic [ADDR_WIDTH-1:0]                         RAddrRegxDP_B;

    logic [ADDR_WIDTH-1:0]                         RAddrRegxDP_C;

    logic [NUM_WORDS-1:0][NUM_BYTE-1:0][7:0]       MemContentxDP;

    logic [NUM_WORDS-1:0][NUM_BYTE-1:0]            WAddrOneHotxD_A;
    logic [NUM_WORDS-1:0][NUM_BYTE-1:0]            WAddrOneHotxD_B;
    logic [NUM_WORDS-1:0][NUM_BYTE-1:0]            WAddrOneHotxD_B_q;

    logic [NUM_WORDS-1:0][NUM_BYTE-1:0]            ClocksxC;
    logic [NUM_BYTE-1:0][7:0]                      WDataIntxD_A;
    logic [NUM_BYTE-1:0][7:0]                      WDataIntxD_B;

    logic                                          clk_int;

    logic readA_q, readB_q, readC_q;

    int unsigned i;
    int unsigned j;
    //int unsigned k;
    //int unsigned l;
    int unsigned m;

    genvar x;
    genvar y;
    genvar k;
    genvar l;

   `ifndef SYNTHESIS
    always_ff @(negedge clk)
    begin
        if(WriteEnable_A && WriteEnable_B)
            if (WriteAddr_A == WriteAddr_B)
                $display("[SCM] Contention in SCM!!!! addr %x time %t",WriteAddr_B,$time);
/*
        if(readA_q)
            if ($isunknown(ReadData_A))
                $display("[SCM] ReadData A XXXX!!!! addr %x time %t",ReadAddr_A,$time);
        if(readB_q)
            if ($isunknown(ReadData_B))
                $display("[SCM] ReadData B XXXX!!!! addr %x time %t",ReadAddr_B,$time);
        if(readC_q)
            if ($isunknown(ReadData_C))
                $display("[SCM] ReadData C XXXX!!!! addr %x time %t",ReadAddr_C,$time);
*/
    end
    always_ff @(posedge clk)
    begin
        readA_q <= ReadEnable_A;
        readB_q <= ReadEnable_B;
        readC_q <= ReadEnable_C;
    end
    `endif

    cluster_clock_gating CG_WE_GLOBAL
    (
        .clk_o(clk_int),
        .en_i(WriteEnable_A | WriteEnable_B),
        .test_en_i(1'b0),
        .clk_i(clk)
    );

    //-----------------------------------------------------------------------------
    //-- READ : Read address register
    //-----------------------------------------------------------------------------

    always_ff @(posedge clk)
    begin : p_RAddrReg
      if(ReadEnable_A)
        RAddrRegxDP_A <= ReadAddr_A;
      if(ReadEnable_B)
        RAddrRegxDP_B <= ReadAddr_B;
      if(ReadEnable_C)
        RAddrRegxDP_C <= ReadAddr_C;
    end


    //-----------------------------------------------------------------------------
    //-- READ : Read address decoder RAD
    //-----------------------------------------------------------------------------

    assign ReadData_A = MemContentxDP[RAddrRegxDP_A];
    assign ReadData_B = MemContentxDP[RAddrRegxDP_B];
    assign ReadData_C = MemContentxDP[RAddrRegxDP_C];


    //-----------------------------------------------------------------------------
    //-- WRITE : Write Address Decoder (WAD), combinatorial process
    //-----------------------------------------------------------------------------
    always_comb
    begin : p_WAD
      for(i=0; i<NUM_WORDS; i++)
        begin : p_WordIter
            for(j=0; j<NUM_BYTE; j++)
              begin : p_ByteIter

                if ( (WriteEnable_A == 1'b1 ) && (WriteBE_A[j] == 1'b1) &&  (WriteAddr_A == i) )
                  WAddrOneHotxD_A[i][j] = 1'b1;
                else
                  WAddrOneHotxD_A[i][j] = 1'b0;

                if ( (WriteEnable_B == 1'b1 ) && (WriteBE_B[j] == 1'b1) &&  (WriteAddr_B == i) )
                  WAddrOneHotxD_B[i][j] = 1'b1;
                else
                  WAddrOneHotxD_B[i][j] = 1'b0;

              end
        end
    end

    always_ff @(posedge clk_int)
    begin
        if(WriteEnable_A | WriteEnable_B)
            WAddrOneHotxD_B_q <= WAddrOneHotxD_B;
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
                  .clk_o(ClocksxC[x][y]),
                  .en_i(WAddrOneHotxD_A[x][y] | WAddrOneHotxD_B[x][y]),
                  .test_en_i(1'b0),
                  .clk_i(clk_int)
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
            if(WriteEnable_A & WriteBE_A[m])
              WDataIntxD_A[m] <= WriteData_A[m];
            if(WriteEnable_B & WriteBE_B[m])
              WDataIntxD_B[m] <= WriteData_B[m];

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

/*
    always_latch
    begin : latch_wdata
      for(k=0; k<NUM_WORDS; k++)
        begin : w_WordIter
            for(l=0; l<NUM_BYTE; l++)
              begin : w_ByteIter
                if( ClocksxC[k][l] == 1'b1 )
                  MemContentxDP[k][l] = WAddrOneHotxD_B_q[k][l] ? WDataIntxD_B[l] : WDataIntxD_A[l];
              end
        end
    end
*/
    generate
        for(k=0; k<NUM_WORDS; k++)
        begin : w_WordIter
            for(l=0; l<NUM_BYTE; l++)
            begin : w_ByteIter
                always @( ClocksxC[k][l] or WAddrOneHotxD_B_q[k][l] or WDataIntxD_B[l] or WDataIntxD_A[l])
                begin : latch_wdata
                   if( ClocksxC[k][l] == 1'b1)
                      MemContentxDP[k][l] = WAddrOneHotxD_B_q[k][l] ? WDataIntxD_B[l] : WDataIntxD_A[l];
                end
            end
        end
    endgenerate

endmodule
