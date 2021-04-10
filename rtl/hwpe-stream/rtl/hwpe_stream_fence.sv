/*
 * hwpe_stream_fence.sv
 * Francesco Conti <f.conti@unibo.it>
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
 */

import hwpe_stream_package::*;

module hwpe_stream_fence #(
  parameter int unsigned NB_STREAMS = 2,
  parameter int unsigned DATA_WIDTH = 32
)
(
  input  logic clk_i,
  input  logic rst_ni,
  input  logic clear_i,
  input  logic test_mode_i,

  hwpe_stream_intf_stream.sink   push_i [NB_STREAMS-1:0],
  hwpe_stream_intf_stream.source pop_o  [NB_STREAMS-1:0]
);

  logic [NB_STREAMS-1:0] in_valid;
  logic [NB_STREAMS-1:0] in_ready;
  logic                  out_valid;
  logic [NB_STREAMS-1:0] fence_state, next_fence_state;
  logic [NB_STREAMS-1:0][DATA_WIDTH-1:0]   r_data;
  logic [NB_STREAMS-1:0][DATA_WIDTH/8-1:0] r_strb;

  generate
    for(genvar ii=0; ii<NB_STREAMS; ii++) begin : binding

      assign in_valid[ii] = push_i[ii].valid;

      assign push_i[ii].ready = pop_o[ii].ready & ~fence_state[ii];

      assign pop_o[ii].valid = out_valid;
      assign pop_o[ii].data  = fence_state[ii] ? r_data[ii] : push_i[ii].data;
      assign pop_o[ii].strb  = fence_state[ii] ? r_strb[ii] : push_i[ii].strb;

      always_ff @(posedge clk_i or negedge rst_ni)
      begin
        if(~rst_ni)
          r_data[ii] <= '0;
        else if(clear_i)
          r_data[ii] <= '0;
        else if(next_fence_state[ii])
          r_data[ii] <= push_i[ii].data;
      end

      always_ff @(posedge clk_i or negedge rst_ni)
      begin
        if(~rst_ni)
          r_strb[ii] <= '0;
        else if(clear_i)
          r_strb[ii] <= '0;
        else if(next_fence_state[ii])
          r_strb[ii] <= push_i[ii].strb;
      end

    end
  endgenerate

  always_comb
  begin
    next_fence_state = '0;
    out_valid = 1'b0;
    if(&(in_valid | fence_state))
      out_valid = 1'b1;
    else
      next_fence_state = fence_state | in_valid;
  end

  always_ff @(posedge clk_i or negedge rst_ni)
  begin
    if(~rst_ni)
      fence_state <= '0;
    else if(clear_i)
      fence_state <= '0;
    else
      fence_state <= next_fence_state;
  end

endmodule // hwpe_stream_fence
