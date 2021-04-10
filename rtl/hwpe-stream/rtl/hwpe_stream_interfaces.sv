/*
 * hwpe_stream_interfaces.sv
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

interface hwpe_stream_intf_tcdm (
  input logic clk
);
`ifndef SYNTHESIS
  // the TRVR assert is disabled by default, as it is only valid for zero-latency
  // accesses (e.g. using FIFO queues breaks this assumption)
  parameter bit BYPASS_TRVR_ASSERT = 1'b1;
`endif

  logic        req;
  logic        gnt;
  logic [31:0] add;
  logic        wen;
  logic [3:0]  be;
  logic [31:0] data;
  logic [31:0] r_data;
  logic        r_valid;

  modport master (
    output req, add, wen, be, data,
    input  gnt, r_data, r_valid
  );
  modport slave (
    input  req, add, wen, be, data,
    output gnt, r_data, r_valid
  );
  modport monitor (
    input  req, add, wen, be, data, gnt, r_data, r_valid
  );

`ifndef SYNTHESIS
  // The r_valid signal must be asserted the cycle after a valid read handshake;
  // r_data must be valid on this cycle. This is due to the tightly-coupled
  // memories; if the memory cannot respond in one cycle, it must delay
  // granting the transaction.
  property hwpe_tcdm_r_valid_rule;
    @(posedge clk)
    ($past(req) & $past(gnt) & $past(wen)) |-> (r_valid) | BYPASS_TRVR_ASSERT;
  endproperty;

  HWPE_TCDM_R_VALID: assert property(hwpe_tcdm_r_valid_rule)
    else $fatal("ASSERTION FAILURE HWPE_TCDM_R_VALID", 1);
`endif

endinterface // hwpe_stream_intf_tcdm

interface hwpe_stream_intf_stream (
  input logic clk
);
  parameter int unsigned DATA_WIDTH = -1;
`ifndef SYNTHESIS
  parameter bit BYPASS_VCR_ASSERT = 1'b0;
  parameter bit BYPASS_VDR_ASSERT = 1'b0;
`endif

  logic                    valid;
  logic                    ready;
  logic [DATA_WIDTH-1:0]   data;
  logic [DATA_WIDTH/8-1:0] strb;

  modport source (
    output valid, data, strb,
    input  ready
  );
  modport sink (
    input  valid, data, strb,
    output ready
  );
  modport monitor (
    input  valid, data, strb, ready
  );

`ifndef SYNTHESIS
  // The data and strb can change their value 1) when valid is deasserted,
  // 2) in the cycle after a valid handshake, even if valid remains asserted.
  // In other words, valid data must remain on the interface until
  // a valid handshake has occurred.
  property hwpe_stream_value_change_rule;
    @(posedge clk)
    ($past(valid) & ~($past(valid) & $past(ready))) |-> ((data == $past(data)) && (strb == $past(strb))) | BYPASS_VCR_ASSERT;
  endproperty;
  
  // The deassertion of valid (transition 1í0) can happen only in the cycle
  // after a valid handshake. In other words, valid data produced by a source
  // must be consumed on the sink side before valid is deasserted.
  property hwpe_stream_valid_deassert_rule;
    @(posedge clk)
    ($past(valid) & ~valid) |-> ($past(valid) & $past(ready)) | BYPASS_VDR_ASSERT;
  endproperty;

  HWPE_STREAM_VALUE_CHANGE:   assert property(hwpe_stream_value_change_rule)
    else $fatal("ASSERTION FAILURE: HWPE_STREAM_VALUE_CHANGE", 1);

  HWPE_STREAM_VALID_DEASSERT: assert property(hwpe_stream_valid_deassert_rule)
    else $fatal("ASSERTION FAILURE HWPE_STREAM_VALID_DEASSERT", 1);
`endif

endinterface // hwpe_stream_intf_stream
