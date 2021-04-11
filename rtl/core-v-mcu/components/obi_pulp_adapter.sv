// Copyright 2020 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Author: Matteo Perotti, mperotti@iis.ee.ethz.ch
// Description: Module to adapt CV32E40P to the PULP memory system.
//              It blocks multiple outstanding requests to the memory until the first one is served.

module obi_pulp_adapter (
    input  logic rst_ni,
    input  logic clk_i,
    // Master (core) interface
    input  logic core_req_i,
    // Slave (memory) interface
    input  logic mem_gnt_i,
    input  logic mem_rvalid_i,
    output logic mem_req_o
);

  // CU states
  typedef enum logic {
    WAIT_GNT,
    WAIT_VALID
  } state_t;
  state_t ps, ns;

  // FSM next-state sequential process
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      ps <= WAIT_GNT;
    end else begin
      ps <= ns;
    end
  end

  // Block multiple requests, as the memory does not support them
  // core_req_i is kept stable by cv32e40p (OBI compliant)
  always_comb begin
    case (ps)
      WAIT_GNT: begin
        // Idle state, the memory has not received any request yet
        mem_req_o = core_req_i;
        ns        = (core_req_i && mem_gnt_i) ? WAIT_VALID : WAIT_GNT;
      end
      WAIT_VALID: begin
        // The memory has received and granted a request. Filter the next request until the memory is ready to accept it.
        mem_req_o = (core_req_i && mem_rvalid_i) ? 1'b1 : 1'b0;
        ns        = (mem_rvalid_i && !mem_gnt_i) ? WAIT_GNT : WAIT_VALID;
      end
      default: begin
        mem_req_o = core_req_i;
        ns        = WAIT_GNT;
      end
    endcase
  end

endmodule
