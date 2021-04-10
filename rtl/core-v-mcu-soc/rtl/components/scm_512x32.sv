// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


module scm_512x32 (
    input  logic        CLK,
    input  logic        RSTN,
    input  logic        CEN,
    input  logic        WEN,
    input  logic [ 3:0] BE,
    input  logic [ 8:0] A,
    input  logic [31:0] D,
    output logic [31:0] Q
);

  logic read_en, write_en;

  assign read_en  = ~CEN & WEN;
  assign write_en = ~CEN & ~WEN;

  register_file_1r_1w_be #(
      .ADDR_WIDTH(9),
      .DATA_WIDTH(32),
      .NUM_BYTE  (4)
  ) scm_i (
      .clk        (CLK),
      .ReadEnable (read_en),
      .ReadAddr   (A),
      .ReadData   (Q),
      .WriteEnable(write_en),
      .WriteAddr  (A),
      .WriteData  (D),
      .WriteBE    (BE)
  );

endmodule  // scm_512x32
