// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

/*
It models a mix of SRAM and SCM memory for low voltage operations.
The SCM it's mapped at the end of the address space.
For Sythesis, replace the generic_memory with the MACRO of the SRAM
*/


module model_6144x32_2048x32scm (
    input logic CLK,
    input logic RSTN,

    input logic CEN,
    input logic CEN_scm0,
    input logic CEN_scm1,

    input logic WEN,
    input logic WEN_scm0,
    input logic WEN_scm1,

    input logic [3:0] BEN,
    input logic [3:0] BEN_scm0,

    input logic [12:0] A,
    input logic [10:0] A_scm0,
    input logic [10:0] A_scm1,

    input logic [31:0] D,
    input logic [31:0] D_scm0,

    output logic [31:0] Q,
    output logic [31:0] Q_scm0,
    output logic [31:0] Q_scm1
);
  localparam CUT0_ADDRW = 12;
  localparam CUT1_ADDRW = 11;
  localparam SCM0_ADDRW = 11;


  logic CEN_int[2:0];
  logic [2:0][31:0] Q_int;

  logic [1:0] muxsel;
  logic [31:0] BE_BW;

  logic [3:0] BE;
  logic [3:0] BE_scm0;
  logic read_enA, read_enB, read_enC;
  logic write_enA, write_enB;


  assign BE         = ~BEN;
  assign BE_scm0    = ~BEN_scm0;

  assign BE_BW      = {{8{BE[3]}}, {8{BE[2]}}, {8{BE[1]}}, {8{BE[0]}}};

  assign CEN_int[2] = CEN | ~A[12] | ~A[11];  //scm
  assign CEN_int[1] = CEN | ~A[12] | A[11];
  assign CEN_int[0] = CEN | A[12];

  always @(*) begin
    case (muxsel)
      2'b00: Q = Q_int[0];
      2'b01: Q = Q_int[0];
      2'b10: Q = Q_int[1];
      2'b11: Q = Q_int[2];
    endcase
  end

  always_ff @(posedge CLK or negedge RSTN) begin
    if (~RSTN) begin
      muxsel <= '0;
    end else begin
      if (CEN == 1'b0) muxsel <= A[12:11];
    end
  end

  scm_2048x32 scm_0 (
      .CLK     (CLK),
      .RSTN    (RSTN),
      .CEN     (CEN_int[2]),
      .CEN_scm0(CEN_scm0),
      .CEN_scm1(CEN_scm1),

      .WEN     (WEN),
      .WEN_scm0(WEN_scm0),
      .WEN_scm1(WEN_scm1),

      .BE     (BE),
      .BE_scm0(BE_scm0),

      .A     (A[10:0]),
      .A_scm0(A_scm0[10:0]),
      .A_scm1(A_scm1[10:0]),

      .D     (D[31:0]),
      .D_scm0(D_scm0[31:0]),

      .Q     (Q_int[2]),
      .Q_scm0(Q_scm0),
      .Q_scm1(Q_scm1)
  );

  generic_memory #(
      .ADDR_WIDTH(11),
      .DATA_WIDTH(32)
  ) cut_1 (
      .CLK  (CLK),
      .INITN(1'b1),
      .D    (D),
      .A    (A[10:0]),
      .CEN  (CEN_int[1]),
      .WEN  (WEN),
      .BEN  (BEN),
      .Q    (Q_int[1])
  );

  generic_memory #(
      .ADDR_WIDTH(12),
      .DATA_WIDTH(32)
  ) cut_0 (
      .CLK  (CLK),
      .INITN(1'b1),
      .D    (D),
      .A    (A[11:0]),
      .CEN  (CEN_int[0]),
      .WEN  (WEN),
      .BEN  (BEN),
      .Q    (Q_int[0])
  );

endmodule

module model_sram_28672x32_scm_512x32 (
    input logic CLK,
    input logic RSTN,

    input  logic        CEN,
    input  logic        WEN,
    input  logic [ 3:0] BEN,
    input  logic [14:0] A,
    input  logic [31:0] D,
    output logic [31:0] Q
);
  logic [ 7:0]       CEN_int;
  logic              CEN_sram;
  logic [ 7:0][31:0] Q_int;

  logic [ 2:0]       muxsel;
  logic [31:0]       BE_BW;

  logic [ 3:0]       BE;
  assign BE         = ~BEN;

  assign BE_BW      = {{8{BE[3]}}, {8{BE[2]}}, {8{BE[1]}}, {8{BE[0]}}};


  assign CEN_int[0] = CEN | A[14] | A[13] | A[12];
  assign CEN_int[1] = CEN | A[14] | A[13] | ~A[12];
  assign CEN_int[2] = CEN | A[14] | ~A[13] | A[12];
  assign CEN_int[3] = CEN | A[14] | ~A[13] | ~A[12];
  assign CEN_int[4] = CEN | ~A[14] | A[13] | A[12];
  assign CEN_int[5] = CEN | ~A[14] | A[13] | ~A[12];
  assign CEN_int[6] = CEN | ~A[14] | ~A[13] | A[12];
  assign CEN_int[7] = CEN | ~A[14] | ~A[13] | ~A[12];  // 2KB scm

  assign Q          = Q_int[muxsel];

  always_ff @(posedge CLK or negedge RSTN) begin
    if (~RSTN) begin
      muxsel <= '0;
    end else begin
      if (CEN == 1'b0) muxsel <= A[14:12];
    end
  end

  generic_memory #(
      .ADDR_WIDTH(12),
      .DATA_WIDTH(32)
  ) cut_0 (
      .CLK  (CLK),
      .INITN(1'b1),
      .D    (D),
      .A    (A[11:0]),
      .CEN  (CEN_int[0]),
      .WEN  (WEN),
      .BEN  (BEN),
      .Q    (Q_int[0])
  );

  generic_memory #(
      .ADDR_WIDTH(12),
      .DATA_WIDTH(32)
  ) cut_1 (
      .CLK  (CLK),
      .INITN(1'b1),
      .D    (D),
      .A    (A[11:0]),
      .CEN  (CEN_int[1]),
      .WEN  (WEN),
      .BEN  (BEN),
      .Q    (Q_int[1])
  );

  generic_memory #(
      .ADDR_WIDTH(12),
      .DATA_WIDTH(32)
  ) cut_2 (
      .CLK  (CLK),
      .INITN(1'b1),
      .D    (D),
      .A    (A[11:0]),
      .CEN  (CEN_int[2]),
      .WEN  (WEN),
      .BEN  (BEN),
      .Q    (Q_int[2])
  );

  generic_memory #(
      .ADDR_WIDTH(12),
      .DATA_WIDTH(32)
  ) cut_3 (
      .CLK  (CLK),
      .INITN(1'b1),
      .D    (D),
      .A    (A[11:0]),
      .CEN  (CEN_int[3]),
      .WEN  (WEN),
      .BEN  (BEN),
      .Q    (Q_int[3])
  );

  generic_memory #(
      .ADDR_WIDTH(12),
      .DATA_WIDTH(32)
  ) cut_4 (
      .CLK  (CLK),
      .INITN(1'b1),
      .D    (D),
      .A    (A[11:0]),
      .CEN  (CEN_int[4]),
      .WEN  (WEN),
      .BEN  (BEN),
      .Q    (Q_int[4])
  );

  generic_memory #(
      .ADDR_WIDTH(12),
      .DATA_WIDTH(32)
  ) cut_5 (
      .CLK  (CLK),
      .INITN(1'b1),
      .D    (D),
      .A    (A[11:0]),
      .CEN  (CEN_int[5]),
      .WEN  (WEN),
      .BEN  (BEN),
      .Q    (Q_int[5])
  );

  generic_memory #(
      .ADDR_WIDTH(12),
      .DATA_WIDTH(32)
  ) cut_6 (
      .CLK  (CLK),
      .INITN(1'b1),
      .D    (D),
      .A    (A[11:0]),
      .CEN  (CEN_int[6]),
      .WEN  (WEN),
      .BEN  (BEN),
      .Q    (Q_int[6])
  );

  scm_512x32 scm_7 (
      .CLK (CLK),
      .RSTN(RSTN),
      .CEN (CEN_int[7]),
      .WEN (WEN),
      .BE  (BE),
      .A   (A[8:0]),  // 2 kB -> 9 bits; 4 kB -> 10 bits; 8 kB -> 11 bits; 16 kB -> 12 bits
      .D   (D[31:0]),
      .Q   (Q_int[7])
  );

endmodule
