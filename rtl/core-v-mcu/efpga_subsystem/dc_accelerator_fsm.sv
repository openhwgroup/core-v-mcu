// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


module dc_accelerator_fsm (
    input logic clk_i,
    input logic rst_ni,

    XBAR_TCDM_BUS.Slave  l2_accelerator,
    XBAR_TCDM_BUS.Master l2_dc_fifo

);

  logic store_answer;
  logic [31:0] rdata;

  enum logic [1:0] {
    IDLE,
    WAIT_RVALID,
    GIVE_RVALID
  }
      state_n, state_q;

  always_comb begin

    state_n                = state_q;

    l2_accelerator.gnt     = 1'b0;
    l2_accelerator.r_rdata = rdata;
    l2_accelerator.r_valid = 1'b0;

    l2_dc_fifo.req         = 1'b0;
    l2_dc_fifo.wen         = l2_accelerator.wen;
    l2_dc_fifo.add         = l2_accelerator.add;
    l2_dc_fifo.wdata       = l2_accelerator.wdata;
    l2_dc_fifo.be          = l2_accelerator.be;

    store_answer           = 1'b0;


    unique case (state_q)

      IDLE: begin
        if (l2_accelerator.req) begin
          l2_dc_fifo.req = 1'b1;
          state_n        = WAIT_RVALID;
        end
      end

      WAIT_RVALID: begin
        if (l2_dc_fifo.r_valid) begin
          l2_accelerator.gnt = 1'b1;
          state_n            = GIVE_RVALID;
          store_answer       = 1'b1;
        end
      end

      GIVE_RVALID: begin
        l2_accelerator.r_valid = 1'b1;
        l2_dc_fifo.req         = l2_accelerator.req;
        state_n                = l2_accelerator.req ? WAIT_RVALID : IDLE;
      end

    endcase  // state_q

  end


  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      rdata   <= '0;
      state_q <= IDLE;
    end else begin
      if (store_answer) begin
        rdata <= l2_dc_fifo.r_rdata;
      end
      state_q <= state_n;
    end
  end



endmodule
