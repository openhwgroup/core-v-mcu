// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


module tcdm_streamer (
    input logic clk_i,
    input logic rst_ni,

    output logic tcdm_req_o,
    input  logic tcdm_gnt_i,
    input  logic tcdm_r_valid_i,

    input  logic start_i,
    output logic data_valid_o

);
  enum logic [1:0] {
    IDLE,
    WAIT_GNT,
    WAIT_RVALID
  }
      state_n, state_q;


  always_comb begin

    state_n      = state_q;
    tcdm_req_o   = 1'b0;
    data_valid_o = 1'b0;
    unique case (state_q)

      IDLE: begin
        if (start_i) begin
          tcdm_req_o = 1'b1;
          if (tcdm_gnt_i) begin
            state_n = WAIT_RVALID;
          end else state_n = WAIT_GNT;
        end
      end

      WAIT_GNT: begin
        tcdm_req_o = 1'b1;
        if (tcdm_gnt_i) begin
          state_n = WAIT_RVALID;
        end
      end

      WAIT_RVALID: begin
        if (tcdm_r_valid_i) begin
          data_valid_o = 1'b1;
          state_n      = data_valid_o ? IDLE : WAIT_RVALID;
        end
      end

      default: begin
      end

    endcase  // state_q
  end


  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      state_q <= IDLE;
    end else begin
      state_q <= state_n;
    end
  end




endmodule
