// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


module pulpemu_trace #(
    parameter NB_CORES = 4,
    parameter TRACE_BUFFER_DIM = 1024  // trace buffer dimension in 512-bit words
) (
    input logic ref_clk_i,
    input logic rst_ni,
    input logic fetch_en_i,

    input logic [NB_CORES-1:0][63:0] instr_trace_cycles,
    input logic [NB_CORES-1:0][31:0] instr_trace_instr,
    input logic [NB_CORES-1:0][31:0] instr_trace_pc,
    input logic [NB_CORES-1:0]       instr_trace_valid,

    input  logic trace_flushed,
    output logic trace_wait,
    input  logic cg_clken,

    input  logic        trace_master_clk,
    input  logic [31:0] trace_master_addr,
    input  logic [31:0] trace_master_din,
    output logic [31:0] trace_master_dout,
    input  logic        trace_master_we

);

  localparam TRACE_THRESHOLD = 1000;
  localparam TRACE_ADDR_HIGH = $clog2(TRACE_BUFFER_DIM);

  logic [                        15:0]               counter;
  logic [                        15:0]               gen_add;
  logic                                              trace_wait_r;
  logic                                              fifo_valid_o;

  logic [                NB_CORES-1:0][ 4-1:0][31:0] fifo_data_i;
  logic [                NB_CORES-1:0][ 4-1:0][31:0] fifo_data_o;

  logic [                NB_CORES-1:0][64-1:0]       instr_trace_cycles_r;
  logic [                NB_CORES-1:0][32-1:0]       instr_trace_instr_r;
  logic [                NB_CORES-1:0][32-1:0]       instr_trace_pc_r;
  logic [                NB_CORES-1:0]               instr_trace_valid_r;

  logic [                        31:0]               trace_slave_addr;
  logic [                       511:0]               trace_slave_din;
  logic [                        31:0]               trace_slave_dout;
  logic                                              trace_slave_we;

  logic                                              trace_master_int_clk;
  logic [$clog2(TRACE_BUFFER_DIM)-1:0]               trace_master_int_addr;
  logic [                       511:0]               trace_master_int_din;
  logic [                       511:0]               trace_master_int_dout;
  logic                                              trace_master_int_we;

  assign trace_slave_addr = gen_add;
  assign trace_slave_we   = fifo_valid_o;

  genvar i;
  generate
    for (i = 0; i < NB_CORES; i++) begin : gen_fifo_data
      assign fifo_data_i[i][0]                      = instr_trace_cycles_r[i][31:0];
      // sacrificing four bits of cycles... too bad.
      assign fifo_data_i[i][1][27:0]                = instr_trace_cycles_r[i][59:32];
      assign fifo_data_i[i][1][31:28]               = instr_trace_valid_r;
      assign fifo_data_i[i][2]                      = instr_trace_instr_r[i];
      assign fifo_data_i[i][3]                      = instr_trace_pc_r[i];
      assign trace_slave_din[i*32*4+31 : i*32*4+0]  = fifo_data_o[i][0];
      assign trace_slave_din[i*32*4+63 : i*32*4+32] = fifo_data_o[i][1];
      assign trace_slave_din[i*32*4+95 : i*32*4+64] = fifo_data_o[i][2];
      assign trace_slave_din[i*32*4+127:i*32*4+96]  = fifo_data_o[i][3];
    end
  endgenerate

  generic_fifo #(
      .DATA_WIDTH(32 * NB_CORES * 4 + 16),
      .DATA_DEPTH(4)
  ) fifo_i (
      .clk        (ref_clk_i),
      .rst_n      (rst_ni),
      .data_i     ({fifo_data_i, counter}),
      .valid_i    (|instr_trace_valid_r),
      .grant_o    (),
      .data_o     ({fifo_data_o, gen_add}),
      .valid_o    (fifo_valid_o),
      .grant_i    (~trace_wait_r),
      .test_mode_i(1'b0)
  );

  always_ff @(posedge ref_clk_i or negedge rst_ni) begin
    if (rst_ni == 1'b0) begin
      trace_wait_r = 1'b0;
    end else if (trace_flushed == 1'b1) begin
      trace_wait_r = 1'b0;
    end else if (counter >= TRACE_THRESHOLD) begin
      trace_wait_r = 1'b1;
    end
  end
  assign trace_wait = trace_wait_r;

  always_ff @(posedge ref_clk_i or negedge rst_ni) begin
    if (rst_ni == 1'b0) begin
      counter = 16'h0;
    end else if (fetch_en_i == 1'b0) begin
      counter = 16'h0;
    end else if (trace_flushed == 1'b1) begin
      counter = 16'h0;
    end else if ((cg_clken == 1'b1) && (|instr_trace_valid_r == 1'b1)) begin
      counter = counter + 16'h1;
    end
  end

  always_ff @(posedge ref_clk_i or negedge rst_ni) begin
    if (rst_ni == 1'b0) begin
      instr_trace_cycles_r = 0;
      instr_trace_instr_r  = 0;
      instr_trace_pc_r     = 0;
      instr_trace_valid_r  = 0;
    end else begin
      instr_trace_cycles_r = instr_trace_cycles;
      instr_trace_instr_r  = instr_trace_instr;
      instr_trace_pc_r     = instr_trace_pc;
      instr_trace_valid_r  = instr_trace_valid;
    end
  end

  xilinx_trace_mem xilinx_trace_mem_i (
      .clka (ref_clk_i),
      .wea  (trace_slave_we),
      .addra(trace_slave_addr),
      .dina (trace_slave_din),
      .douta(trace_slave_dout),
      .clkb (trace_master_clk),
      .web  (trace_master_int_we),
      .addrb(trace_master_int_addr),
      .dinb (trace_master_int_din),
      .doutb(trace_master_int_dout)
  );

  assign trace_master_int_addr = trace_master_addr[$clog2(TRACE_BUFFER_DIM)+4-1:4];
  assign trace_master_dout = (trace_master_addr[5:2] == 4'h0) ? trace_master_int_dout[ 1*32-1: 0*32] :
                             (trace_master_addr[5:2] == 4'h1) ? trace_master_int_dout[ 2*32-1: 1*32] :
                             (trace_master_addr[5:2] == 4'h2) ? trace_master_int_dout[ 3*32-1: 2*32] :
                             (trace_master_addr[5:2] == 4'h3) ? trace_master_int_dout[ 4*32-1: 3*32] :
                             (trace_master_addr[5:2] == 4'h4) ? trace_master_int_dout[ 5*32-1: 4*32] :
                             (trace_master_addr[5:2] == 4'h5) ? trace_master_int_dout[ 6*32-1: 5*32] :
                             (trace_master_addr[5:2] == 4'h6) ? trace_master_int_dout[ 7*32-1: 6*32] :
                             (trace_master_addr[5:2] == 4'h7) ? trace_master_int_dout[ 8*32-1: 7*32] :
                             (trace_master_addr[5:2] == 4'h8) ? trace_master_int_dout[ 9*32-1: 8*32] :
                             (trace_master_addr[5:2] == 4'h9) ? trace_master_int_dout[10*32-1: 9*32] :
                             (trace_master_addr[5:2] == 4'ha) ? trace_master_int_dout[11*32-1:10*32] :
                             (trace_master_addr[5:2] == 4'hb) ? trace_master_int_dout[12*32-1:11*32] :
                             (trace_master_addr[5:2] == 4'hc) ? trace_master_int_dout[13*32-1:12*32] :
                             (trace_master_addr[5:2] == 4'hd) ? trace_master_int_dout[14*32-1:13*32] :
                             (trace_master_addr[5:2] == 4'he) ? trace_master_int_dout[15*32-1:14*32] :
                                                                trace_master_int_dout[16*32-1:15*32];
  assign trace_master_int_we = trace_master_we;

  generate
    for (i = 0; i < 512 / 32; i++) begin
      assign trace_master_int_din[(i+1)*32-1:i*32] = (trace_master_addr[5:2] == i) ? trace_master_din :
                                                     trace_master_int_dout[(i+1)*32-1:i*32];
    end
  endgenerate

endmodule
