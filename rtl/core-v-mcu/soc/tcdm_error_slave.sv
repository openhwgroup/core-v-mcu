//-----------------------------------------------------------------------------
// Title         : TCDM Error Slave
//-----------------------------------------------------------------------------
// File          : tcdm_error_slave.sv
// Author        : Manuel Eggimann  <meggimann@iis.ee.ethz.ch>
// Created       : 11.12.2020
//-----------------------------------------------------------------------------
// Description :
// This module responds to incoming read requests with a parametrizable error value
// and ignores (but properly acknowledges) write requests. In addition, it asserts the
// opc bus error signal.
//-----------------------------------------------------------------------------
// Copyright (C) 2013-2020 ETH Zurich, University of Bologna
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//-----------------------------------------------------------------------------

module tcdm_error_slave #(
    parameter logic [31:0] ERROR_RESPONSE = 32'hBADACCE5
) (
    input logic               clk_i,
    input logic               rst_ni,
          XBAR_TCDM_BUS.Slave slave
);

  logic error_valid_d, error_valid_q;
  assign slave.gnt = slave.req;
  assign error_valid_d = slave.req;
  assign slave.r_opc = slave.req;
  assign slave.r_rdata = ERROR_RESPONSE;
  assign slave.r_valid = error_valid_q;

  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
      error_valid_q <= 1'b0;
    end else begin
      error_valid_q <= error_valid_d;
    end
  end

`ifndef SYNTHESIS
`ifndef VERILATOR
  no_req :
  assert property (@(posedge clk_i) disable iff (~rst_ni) not slave.req)
  else $error("Illegal bus request to address %x.", slave.add);
`endif
`endif

endmodule : tcdm_error_slave
