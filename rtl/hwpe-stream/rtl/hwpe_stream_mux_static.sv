/* 
 * hwpe_stream_mux_static.sv
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
 *
 * The TCDM static multiplexer is used in place of the dynamic one
 * when two sets of ports are guaranteed to be used in a strictly
 * alternative fashion.
 */

import hwpe_stream_package::*;

module hwpe_stream_mux_static
(
  input  logic                   clk_i,
  input  logic                   rst_ni,
  input  logic                   clear_i,

  input  logic                   sel_i,

  hwpe_stream_intf_stream.sink   in0,
  hwpe_stream_intf_stream.sink   in1,
  hwpe_stream_intf_stream.source out
);

  // tcdm ports binding
  assign out.valid = (sel_i) ? in1.valid : in0.valid;
  assign out.data  = (sel_i) ? in1.data  : in0.data;
  assign out.strb  = (sel_i) ? in1.strb  : in0.strb;
  assign in0.ready = (sel_i) ? 1'b0      : out.ready;
  assign in1.ready = (sel_i) ? out.ready : 1'b0;

endmodule // hwpe_stream_mux_static
