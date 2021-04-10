// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


module pulpemu_stdout #(
    parameter STDOUT_BUFFER_DIM = 64 * 1024  // stdout buffer dimension in bytes
) (
    input  logic        ref_clk_i,
    input  logic        rst_ni,
    input  logic        fetch_en_i,
    // AXI stdout slave
    output logic        stdout_slave_aw_valid,
    output logic [31:0] stdout_slave_aw_addr,
    output logic [ 2:0] stdout_slave_aw_prot,
    output logic [ 3:0] stdout_slave_aw_region,
    output logic [ 7:0] stdout_slave_aw_len,
    output logic [ 2:0] stdout_slave_aw_size,
    output logic [ 1:0] stdout_slave_aw_burst,
    output logic        stdout_slave_aw_lock,
    output logic [ 3:0] stdout_slave_aw_cache,
    output logic [ 3:0] stdout_slave_aw_qos,
    output logic [ 9:0] stdout_slave_aw_id,
    output logic [ 5:0] stdout_slave_aw_user,
    input  logic        stdout_slave_aw_ready,
    output logic        stdout_slave_ar_valid,
    output logic [31:0] stdout_slave_ar_addr,
    output logic [ 2:0] stdout_slave_ar_prot,
    output logic [ 3:0] stdout_slave_ar_region,
    output logic [ 7:0] stdout_slave_ar_len,
    output logic [ 2:0] stdout_slave_ar_size,
    output logic [ 1:0] stdout_slave_ar_burst,
    output logic        stdout_slave_ar_lock,
    output logic [ 3:0] stdout_slave_ar_cache,
    output logic [ 3:0] stdout_slave_ar_qos,
    output logic [ 9:0] stdout_slave_ar_id,
    output logic [ 5:0] stdout_slave_ar_user,
    input  logic        stdout_slave_ar_ready,
    output logic        stdout_slave_w_valid,
    output logic [31:0] stdout_slave_w_data,
    output logic [ 3:0] stdout_slave_w_strb,
    output logic [ 5:0] stdout_slave_w_user,
    output logic        stdout_slave_w_last,
    input  logic        stdout_slave_w_ready,
    input  logic        stdout_slave_r_valid,
    input  logic [31:0] stdout_slave_r_data,
    input  logic [ 1:0] stdout_slave_r_resp,
    input  logic        stdout_slave_r_last,
    input  logic [ 5:0] stdout_slave_r_user,
    output logic        stdout_slave_r_ready,
    input  logic        stdout_slave_b_valid,
    input  logic [ 1:0] stdout_slave_b_resp,
    input  logic [ 5:0] stdout_slave_b_user,
    output logic        stdout_slave_b_ready,

    // AXI stdout
    input  logic        stdout_master_aw_valid,
    input  logic [31:0] stdout_master_aw_addr,
    input  logic [ 2:0] stdout_master_aw_prot,
    input  logic [ 3:0] stdout_master_aw_region,
    input  logic [ 7:0] stdout_master_aw_len,
    input  logic [ 2:0] stdout_master_aw_size,
    input  logic [ 1:0] stdout_master_aw_burst,
    input  logic        stdout_master_aw_lock,
    input  logic [ 3:0] stdout_master_aw_cache,
    input  logic [ 3:0] stdout_master_aw_qos,
    input  logic [ 9:0] stdout_master_aw_id,
    input  logic [ 5:0] stdout_master_aw_user,
    output logic        stdout_master_aw_ready,
    input  logic        stdout_master_ar_valid,
    input  logic [31:0] stdout_master_ar_addr,
    input  logic [ 2:0] stdout_master_ar_prot,
    input  logic [ 3:0] stdout_master_ar_region,
    input  logic [ 7:0] stdout_master_ar_len,
    input  logic [ 2:0] stdout_master_ar_size,
    input  logic [ 1:0] stdout_master_ar_burst,
    input  logic        stdout_master_ar_lock,
    input  logic [ 3:0] stdout_master_ar_cache,
    input  logic [ 3:0] stdout_master_ar_qos,
    input  logic [ 9:0] stdout_master_ar_id,
    input  logic [ 5:0] stdout_master_ar_user,
    output logic        stdout_master_ar_ready,
    input  logic        stdout_master_w_valid,
    input  logic [63:0] stdout_master_w_data,
    input  logic [ 7:0] stdout_master_w_strb,
    input  logic [ 5:0] stdout_master_w_user,
    input  logic        stdout_master_w_last,
    output logic        stdout_master_w_ready,
    output logic        stdout_master_r_valid,
    output logic [63:0] stdout_master_r_data,
    output logic [ 1:0] stdout_master_r_resp,
    output logic        stdout_master_r_last,
    output logic [ 9:0] stdout_master_r_id,
    output logic [ 5:0] stdout_master_r_user,
    input  logic        stdout_master_r_ready,
    output logic        stdout_master_b_valid,
    output logic [ 1:0] stdout_master_b_resp,
    output logic [ 9:0] stdout_master_b_id,
    output logic [ 5:0] stdout_master_b_user,
    input  logic        stdout_master_b_ready,

    input  logic stdout_flushed,
    output logic stdout_wait

);

  localparam STDOUT_THRESHOLD  = (STDOUT_BUFFER_DIM/4)/16*15; // when one of the stdout buffers is full at 96.875%
  localparam STDOUT_ADDR_HIGH = $clog2(STDOUT_BUFFER_DIM / 4) - 1;

  logic [3:0][15:0] counter;
  logic [31:0] gen_addr;
  logic [3:0] gen_strb;
  logic [31:0] gen_data;
  logic [1:0] which_core;

  logic ex_stdout_slave_b_valid;

  logic [9:0] stdout_slave_r_id_r;
  logic [9:0] stdout_slave_r_id;
  logic [9:0] stdout_slave_b_id;

  logic stdout_wait_r;

  assign stdout_master_aw_ready = stdout_slave_aw_ready & ~stdout_wait_r;
  assign stdout_master_ar_ready = stdout_slave_ar_ready & ~stdout_wait_r;
  assign stdout_master_w_ready = stdout_slave_w_ready;
  assign stdout_master_r_valid = stdout_slave_r_valid;
  assign stdout_master_r_data = stdout_slave_r_data;
  assign stdout_master_r_resp = stdout_slave_r_resp;
  assign stdout_master_r_last = stdout_slave_r_last;
  assign stdout_master_r_id = stdout_slave_r_id;
  assign stdout_master_r_user = stdout_slave_r_user;
  assign stdout_master_b_valid = stdout_slave_b_valid;  // | ex_stdout_slave_b_valid;
  assign stdout_master_b_resp = stdout_slave_b_resp;
  assign stdout_master_b_id = stdout_slave_b_id;
  assign stdout_master_b_user = stdout_slave_b_user;

  assign stdout_slave_aw_valid = stdout_master_aw_valid;
  assign stdout_slave_aw_addr = gen_addr;
  assign stdout_slave_aw_prot = stdout_master_aw_prot;
  assign stdout_slave_aw_region = stdout_master_aw_region;
  assign stdout_slave_aw_len = stdout_master_aw_len;
  assign stdout_slave_aw_size = stdout_master_aw_size;
  assign stdout_slave_aw_burst = stdout_master_aw_burst;
  assign stdout_slave_aw_lock = stdout_master_aw_lock;
  assign stdout_slave_aw_cache = stdout_master_aw_cache;
  assign stdout_slave_aw_qos = stdout_master_aw_qos;
  assign stdout_slave_aw_id = stdout_master_aw_id;
  assign stdout_slave_aw_user = stdout_master_aw_user;
  assign stdout_slave_ar_valid = stdout_master_ar_valid;
  assign stdout_slave_ar_addr = stdout_master_ar_addr;
  assign stdout_slave_ar_prot = stdout_master_ar_prot;
  assign stdout_slave_ar_region = stdout_master_ar_region;
  assign stdout_slave_ar_len = stdout_master_ar_len;
  assign stdout_slave_ar_size = stdout_master_ar_size;
  assign stdout_slave_ar_burst = stdout_master_ar_burst;
  assign stdout_slave_ar_lock = stdout_master_ar_lock;
  assign stdout_slave_ar_cache = stdout_master_ar_cache;
  assign stdout_slave_ar_qos = stdout_master_ar_qos;
  assign stdout_slave_ar_id = stdout_master_ar_id;
  assign stdout_slave_ar_user = stdout_master_ar_user;
  assign stdout_slave_w_valid = stdout_master_w_valid;
  assign stdout_slave_w_data = gen_data;
  assign stdout_slave_w_strb = gen_strb;
  assign stdout_slave_w_user = stdout_master_w_user;
  assign stdout_slave_w_last = stdout_master_w_last;
  assign stdout_slave_r_ready = stdout_master_r_ready;
  assign stdout_slave_b_ready = stdout_master_b_ready;

  always_ff @(posedge ref_clk_i or negedge rst_ni) begin
    if (rst_ni == 1'b0) stdout_slave_r_id_r = 10'b0;
    else if (stdout_slave_aw_valid == 1'b1) stdout_slave_r_id_r = stdout_master_aw_id;
  end

  assign stdout_slave_r_id = (stdout_slave_r_valid == 1'b1) ? stdout_slave_r_id_r : 10'b0;
  assign stdout_slave_b_id = (stdout_slave_b_valid == 1'b1) ? stdout_slave_r_id_r : 10'b0;

  always_ff @(posedge ref_clk_i or negedge rst_ni) begin
    if (rst_ni == 1'b0) ex_stdout_slave_b_valid = 1'b0;
    else ex_stdout_slave_b_valid = stdout_slave_b_valid;
  end

  always_ff @(posedge ref_clk_i or negedge rst_ni) begin
    if (rst_ni == 1'b0) begin
      stdout_wait_r = 1'b0;
    end else begin
      if ((counter[0] >= STDOUT_THRESHOLD) || (counter[1] >= STDOUT_THRESHOLD) || (counter[2] >= STDOUT_THRESHOLD) || (counter[3] >= STDOUT_THRESHOLD))
        stdout_wait_r = 1'b1;
      else stdout_wait_r = 1'b0;
    end
  end
  assign stdout_wait = stdout_wait_r;

  always_ff @(posedge ref_clk_i or negedge rst_ni) begin
    if (rst_ni == 1'b0) begin
      counter[0] = 16'h0;
      counter[1] = 16'h0;
      counter[2] = 16'h0;
      counter[3] = 16'h0;
    end else if (fetch_en_i == 1'b0) begin
      counter[0] = 16'h0;
      counter[1] = 16'h0;
      counter[2] = 16'h0;
      counter[3] = 16'h0;
    end else if ((stdout_flushed == 1'b1)) begin
      counter[0] = 16'h0;
      counter[1] = 16'h0;
      counter[2] = 16'h0;
      counter[3] = 16'h0;
    end else if (stdout_master_w_valid == 1'b1) counter[which_core] = counter[which_core] + 16'h1;
  end

  always_ff @(posedge ref_clk_i or negedge rst_ni) begin
    if (rst_ni == 1'b0) which_core = 0;
    else if (stdout_slave_aw_valid == 1'b1) begin
      // now it's 120 + num_core in aw_id
      which_core = (stdout_master_aw_addr[7:0] == 8'h00) ? 2'h0 :
                   (stdout_master_aw_addr[7:0] == 8'h20) ? 2'h1 :
                   (stdout_master_aw_addr[7:0] == 8'h40) ? 2'h2 :
                   (stdout_master_aw_addr[7:0] == 8'h60) ? 2'h3 : 2'h0;
    end
  end

  always_comb begin
    gen_data <= {
      stdout_master_w_data[7:0],
      stdout_master_w_data[7:0],
      stdout_master_w_data[7:0],
      stdout_master_w_data[7:0]
    };
    gen_addr <= {16'b0, which_core, counter[which_core][STDOUT_ADDR_HIGH:2], 2'b0};
    gen_strb <= (counter[which_core][1:0] == 2'h0) ? 4'h1 :
                (counter[which_core][1:0] == 2'h1) ? 4'h2 :
                (counter[which_core][1:0] == 2'h2) ? 4'h4 :
                (counter[which_core][1:0] == 2'h3) ? 4'h8 : 4'h0;
  end

endmodule

