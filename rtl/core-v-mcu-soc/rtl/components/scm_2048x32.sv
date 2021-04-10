// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


module scm_2048x32 (
    input logic CLK,
    input logic RSTN,

    input logic CEN,
    input logic CEN_scm0,
    input logic CEN_scm1,

    input logic WEN,
    input logic WEN_scm0,
    input logic WEN_scm1,

    input logic [3:0] BE,
    input logic [3:0] BE_scm0,

    input logic [10:0] A,
    input logic [10:0] A_scm0,
    input logic [10:0] A_scm1,

    input logic [31:0] D,
    input logic [31:0] D_scm0,

    output logic [31:0] Q,
    output logic [31:0] Q_scm0,
    output logic [31:0] Q_scm1
);
  localparam NB_BANKS = 16;
  localparam ADDR_WIDTH = 7;

  logic [NB_BANKS-1:0] CEN_int, CEN_scm0_int, CEN_scm1_int;
  logic [NB_BANKS-1:0] read_enA, read_enB, read_enC;
  logic [NB_BANKS-1:0] write_enA, write_enB;
  logic [NB_BANKS-1:0][31:0] Q_int, Q_int_scm0, Q_int_scm1;
  logic [3:0] muxsel_A, muxsel_A_scm0, muxsel_A_scm1;

  always_ff @(posedge CLK or negedge RSTN) begin
    if (~RSTN) begin
      muxsel_A      <= '0;
      muxsel_A_scm0 <= '0;
      muxsel_A_scm1 <= '0;
    end else begin
      if (CEN == 1'b0) muxsel_A <= A[10:7];
      if (CEN_scm0 == 1'b0) muxsel_A_scm0 <= A_scm0[10:7];
      if (CEN_scm1 == 1'b0) muxsel_A_scm1 <= A_scm1[10:7];
    end
  end

  assign Q      = Q_int[muxsel_A];
  assign Q_scm0 = Q_int_scm0[muxsel_A_scm0];
  assign Q_scm1 = Q_int_scm1[muxsel_A_scm1];


  //16 SCM Banks, each 128x32 bit
  genvar i;
  generate
    for (i = 0; i < NB_BANKS; i++) begin : SCM_CUT

      assign CEN_int[i]      = CEN | A[10:7] != i;
      assign CEN_scm0_int[i] = CEN_scm0 | A_scm0[10:7] != i;
      assign CEN_scm1_int[i] = CEN_scm1 | A_scm1[10:7] != i;

      assign read_enA[i]     = ~CEN_int[i] & WEN;
      assign read_enB[i]     = ~CEN_scm0_int[i] & WEN_scm0;
      assign read_enC[i]     = ~CEN_scm1_int[i] & WEN_scm1;

      assign write_enA[i]    = ~CEN_int[i] & ~WEN;
      assign write_enB[i]    = ~CEN_scm0_int[i] & ~WEN_scm0;

      register_file_3r_2w_be #(
          .ADDR_WIDTH(ADDR_WIDTH),
          .DATA_WIDTH(32)
      ) scm_i (
          .clk          (CLK),
          // Read port A
          .ReadEnable_A (read_enA[i]),
          .ReadAddr_A   (A[6:0]),
          .ReadData_A   (Q_int[i]),
          // Read port B
          .ReadEnable_B (read_enB[i]),
          .ReadAddr_B   (A_scm0[6:0]),
          .ReadData_B   (Q_int_scm0[i]),
          // Read port C
          .ReadEnable_C (read_enC[i]),
          .ReadAddr_C   (A_scm1[6:0]),
          .ReadData_C   (Q_int_scm1[i]),
          // Write port A
          .WriteEnable_A(write_enA[i]),
          .WriteAddr_A  (A[6:0]),
          .WriteData_A  (D[31:0]),
          .WriteBE_A    (BE),
          // Write port B
          .WriteEnable_B(write_enB[i]),
          .WriteAddr_B  (A_scm0[6:0]),
          .WriteData_B  (D_scm0[31:0]),
          .WriteBE_B    (BE_scm0)
      );
    end
  endgenerate


endmodule  // scm_2048x32
