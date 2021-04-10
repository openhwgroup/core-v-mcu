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

module register_file_3r_2w_be
#(
    parameter ADDR_WIDTH    = 5,
    parameter DATA_WIDTH    = 64,
    parameter NUM_BYTE      = DATA_WIDTH/8
)
(
    input   logic                               clk,
    input   logic                               rst_n,

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

  localparam N_SCM_REGISTERS = 2**ADDR_WIDTH;

  // signals
  (* ram_style = "block" *) logic [N_SCM_REGISTERS-1:0][NUM_BYTE-1:0][DATA_WIDTH/NUM_BYTE-1:0] MemContent_A_int; // BRAM (triplicated!)
  (* ram_style = "block" *) logic [N_SCM_REGISTERS-1:0][NUM_BYTE-1:0][DATA_WIDTH/NUM_BYTE-1:0] MemContent_B_int; // BRAM (triplicated!)
  (* ram_style = "block" *) logic [N_SCM_REGISTERS-1:0][NUM_BYTE-1:0][DATA_WIDTH/NUM_BYTE-1:0] MemContent_C_int; // BRAM (triplicated!)
  logic [DATA_WIDTH-1:0]                                                                       ReadData_A_reg;
  logic [DATA_WIDTH-1:0]                                                                       ReadData_B_reg;
  logic [DATA_WIDTH-1:0]                                                                       ReadData_C_reg;

  // Read Port A
  always_ff @(posedge clk or negedge rst_n)
  begin
    if(rst_n == 1'b0)
      ReadData_A_reg <= '0;
    else if(ReadEnable_A == 1'b1)
      ReadData_A_reg <= MemContent_A_int[ReadAddr_A];
  end

  always_comb
  begin : register_read_port_behavioral_A
    ReadData_A <= ReadData_A_reg;
  end

  // Read Port B
  always_ff @(posedge clk or negedge rst_n)
  begin
    if(rst_n == 1'b0)
      ReadData_B_reg <= '0;
    else if(ReadEnable_B == 1'b1)
      ReadData_B_reg <= MemContent_B_int[ReadAddr_B];
  end

  always_comb
  begin : register_read_port_behavioral_B
    ReadData_B <= ReadData_B_reg;
  end

  // Read Port C
  always_ff @(posedge clk or negedge rst_n)
  begin
    if(rst_n == 1'b0)
      ReadData_C_reg <= '0;
    else if(ReadEnable_C == 1'b1)
      ReadData_C_reg <= MemContent_C_int[ReadAddr_C];
  end

  always_comb
  begin : register_read_port_behavioral_C
    ReadData_C <= ReadData_C_reg;
  end

  // Write Port, copy A
  always_ff @(posedge clk or negedge rst_n)
  begin
    if(rst_n == 1'b0) begin
      MemContent_A_int <= '0;
    end
    else if(WriteEnable_B == 1'b1) begin
      for(int i=0; i<NUM_BYTE; i++)
        if(WriteBE_B[i] == 1'b1)
          MemContent_A_int[WriteAddr_B][i] <= WriteData_B[i];
    end
    else if(WriteEnable_A == 1'b1) begin
      for(int i=0; i<NUM_BYTE; i++)
        if(WriteBE_A[i] == 1'b1)
          MemContent_A_int[WriteAddr_A][i] <= WriteData_A[i];
    end
  end

  // Write Port, copy B
  always_ff @(posedge clk or negedge rst_n)
  begin
    if(rst_n == 1'b0) begin
      MemContent_B_int <= '0;
    end
    else if(WriteEnable_B == 1'b1) begin
      for(int i=0; i<NUM_BYTE; i++)
        if(WriteBE_B[i] == 1'b1)
          MemContent_B_int[WriteAddr_B][i] <= WriteData_B[i];
    end
    else if(WriteEnable_A == 1'b1) begin
      for(int i=0; i<NUM_BYTE; i++)
        if(WriteBE_A[i] == 1'b1)
          MemContent_B_int[WriteAddr_A][i] <= WriteData_A[i];
    end
  end

  // Write Port, copy C
  always_ff @(posedge clk or negedge rst_n)
  begin
    if(rst_n == 1'b0) begin
      MemContent_C_int <= '0;
    end
    else if(WriteEnable_B == 1'b1) begin
      for(int i=0; i<NUM_BYTE; i++)
        if(WriteBE_B[i] == 1'b1)
          MemContent_C_int[WriteAddr_B][i] <= WriteData_B[i];
    end
    else if(WriteEnable_A == 1'b1) begin
      for(int i=0; i<NUM_BYTE; i++)
        if(WriteBE_A[i] == 1'b1)
          MemContent_C_int[WriteAddr_A][i] <= WriteData_A[i];
    end
  end

endmodule
