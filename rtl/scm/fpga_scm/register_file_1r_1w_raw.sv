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

module register_file_1r_1w_raw
#(
    parameter ADDR_WIDTH = 5,
    parameter DATA_WIDTH = 64,
    parameter BLOCK_RAM  = 1
)
(
    input   logic                                     clk,
    input   logic                                     rst_n,

    input   logic                                     ReadEnable,
    input   logic [ADDR_WIDTH-1:0]                    ReadAddr,
    output  logic [DATA_WIDTH-1:0]                    ReadData,

    input   logic [ADDR_WIDTH-1:0]                    WriteAddr,
    input   logic                                     WriteEnable,
    input   logic [DATA_WIDTH-1:0]                    WriteData
);

  localparam N_SCM_REGISTERS = 2**ADDR_WIDTH;

  generate
    if (BLOCK_RAM == 1) begin : block_ram_gen
      // signals
      (* ram_style="block" *) logic [DATA_WIDTH-1:0] MemContent_int [N_SCM_REGISTERS]; // register
      logic [DATA_WIDTH-1:0] ReadData_reg;
      logic [DATA_WIDTH-1:0] WriteData_reg;
      logic ReadEnable_reg;
      logic WriteEnable_and_ReadWriteSameAddr_reg;

      // Write
      always_ff @(posedge clk)
      begin
        if(WriteEnable == 1'b1)
          MemContent_int[WriteAddr] <= WriteData;
        ReadData_reg <= MemContent_int[ReadAddr];
      end

      always_ff @(posedge clk)
      begin
        ReadEnable_reg                        <= ReadEnable;
        WriteEnable_and_ReadWriteSameAddr_reg <= (ReadAddr == WriteAddr) ? WriteEnable : 1'b0;
        WriteData_reg                         <= WriteData;
      end

      // BRAMs want a single Enable signal
      assign ReadData = (WriteEnable_and_ReadWriteSameAddr_reg == 1'b1) ? WriteData_reg :
                        (ReadEnable_reg  == 1'b1) ?                       ReadData_reg  : '0;
    end
    else begin : distr_ram_gen
      // signals
      logic [N_SCM_REGISTERS-1:0][DATA_WIDTH-1:0] MemContent_int;     // register
      logic [DATA_WIDTH-1:0]                      ReadData_reg;

      // Read Port
      always_ff @(posedge clk or negedge rst_n)
      begin
        if(rst_n == 1'b0)
          ReadData_reg <= '0;
        else if(ReadEnable == 1'b1)
          ReadData_reg <= MemContent_int[ReadAddr];
      end

      always_comb
      begin : register_read_port_behavioral
        ReadData <= ReadData_reg;
      end

      // Write Port
      always_ff @(posedge clk or negedge rst_n)
      begin
        if(rst_n == 1'b0) begin
          MemContent_int <= '0;
        end
        else if(WriteEnable == 1'b1) begin
          MemContent_int[WriteAddr] <= WriteData;
        end
      end

    end
  endgenerate

endmodule
