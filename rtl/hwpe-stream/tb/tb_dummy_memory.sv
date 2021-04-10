/* 
 * tb_dummy_memory.sv
 * Francesco Conti <fconti@iis.ee.ethz.ch>
 *
 * Copyright (C) 2014-2018 ETH Zurich, University of Bologna
 * Copyright and related rights are licensed under the Solderpad Hardware
 * License, Version 0.51 (the "License"); you may not use this file except in
 * compliance with the License.  You may obtain a copy of the License at
 * http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
 * or agreed to in writing, software, hardware and materials distributed under
 * this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 * Dummy memory transaction.
 */

timeunit 1ps;
timeprecision 1ps;

module tb_dummy_memory
#(
  parameter MP          = 1,
  parameter MEMORY_SIZE = 1024,
  parameter BASE_ADDR   = 0,
  parameter PROB_STALL  = 0.0,
  parameter TCP         = 1.0ns, // clock period, 1GHz clock
  parameter TA          = 0.2ns, // application time
  parameter TT          = 0.8ns  // test time
)
(
  input  logic                clk_i,
  input  logic                randomize_i,
  input  logic                enable_i,
  hwpe_stream_intf_tcdm.slave tcdm [MP-1:0]
);

  logic [MEMORY_SIZE-1:0][31:0] memory;
  int cnt = 0;

  logic [MP-1:0]       tcdm_req;
  logic [MP-1:0]       tcdm_gnt;
  logic [MP-1:0][31:0] tcdm_add;
  logic [MP-1:0]       tcdm_wen;
  logic [MP-1:0][3:0]  tcdm_be;
  logic [MP-1:0][31:0] tcdm_data;
  logic [MP-1:0][31:0] tcdm_r_data;
  logic [MP-1:0]       tcdm_r_valid;
  logic [MP-1:0][31:0] tcdm_r_data_int;
  logic [MP-1:0]       tcdm_r_valid_int;

  real probs [MP-1:0];

  logic clk_delayed;

  always_ff @(posedge clk_i)
  begin : probs_proc
    for (int i=0; i<MP; i++) begin
      probs[i] = real'($urandom_range(0,1000))/1000.0;
    end
  end

  generate

    for(genvar i=0; i<MP; i++) begin
      assign tcdm_gnt[i] = (probs[i] < PROB_STALL) ? 1'b0 : 1'b1;
    end

    for(genvar ii=0; ii<MP; ii++) begin : binding_gen
      assign tcdm_req  [ii] = tcdm[ii].req;
      assign tcdm_add  [ii] = tcdm[ii].add;
      assign tcdm_wen  [ii] = tcdm[ii].wen;
      assign tcdm_be   [ii] = tcdm[ii].be;
      assign tcdm_data [ii] = tcdm[ii].data;
      assign tcdm[ii].gnt     = tcdm_gnt [ii] & tcdm_req [ii];
      assign tcdm[ii].r_data  = tcdm_r_data  [ii];
      assign tcdm[ii].r_valid = tcdm_r_valid [ii];
    end

    for(genvar i=0; i<MEMORY_SIZE; i++) begin : outer
      always_ff @(posedge clk_i)
      begin
        if(randomize_i)
          memory[i] = $random();
      end
    end

  endgenerate

  // assign clk_delayed = #(TA) clk_i;
  always @(clk_i)
  begin
    clk_delayed <= #(TA) clk_i;
  end

  always_ff @(posedge clk_i)
  begin : dummy_proc
    for (int i=0; i<MP; i++) begin
      if ((tcdm_req[i] & enable_i) == 1'b0) begin
        tcdm_r_data_int  [i] <= 'z;
        tcdm_r_valid_int [i] <= 1'b0;
      end
      else begin
        // read
        if (tcdm_gnt[i] & tcdm_wen[i]) begin
          tcdm_r_data_int  [i] <= memory[(tcdm_add[i]-BASE_ADDR) >> 2];
          tcdm_r_valid_int [i] <= tcdm_gnt[i];
        end
        // write
        else if (tcdm_gnt[i] & ~tcdm_wen[i]) begin
          memory[(tcdm_add[i]-BASE_ADDR) >> 2] <= tcdm_data [i];
          tcdm_r_data_int  [i] <= tcdm_data [i];
          tcdm_r_valid_int [i] <= 1'b1;
        end
        // no-grant
        else if (~tcdm_gnt[i]) begin
          tcdm_r_data_int  [i] <= 'x;
          tcdm_r_valid_int [i] <= 1'b0;
        end
        else begin
          tcdm_r_data_int  [i] <= 'z;
          tcdm_r_valid_int [i] <= 1'b0;
        end
      end
    end
  end

  always_ff @(posedge clk_delayed)
  begin
    tcdm_r_data  <= tcdm_r_data_int;
    tcdm_r_valid <= tcdm_r_valid_int;
  end

endmodule // tb_dummy_memory
