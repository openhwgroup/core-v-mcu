/* 
 * hwpe_stream_tcdm_mux_static.sv
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

module hwpe_stream_tcdm_mux_static
#(
  parameter int unsigned NB_CHAN = 2
)
(
  input  logic                 clk_i,
  input  logic                 rst_ni,
  input  logic                 clear_i,

  input  logic                 sel_i,

  hwpe_stream_intf_tcdm.slave  in0 [NB_CHAN-1:0],
  hwpe_stream_intf_tcdm.slave  in1 [NB_CHAN-1:0],
  hwpe_stream_intf_tcdm.master out [NB_CHAN-1:0]
);

  // tcdm ports binding
  generate
    for(genvar ii=0; ii<NB_CHAN; ii++) begin: tcdm_binding
      assign out[ii].req  = (sel_i) ? in1[ii].req  : in0[ii].req;
      assign out[ii].add  = (sel_i) ? in1[ii].add  : in0[ii].add;
      assign out[ii].wen  = (sel_i) ? in1[ii].wen  : in0[ii].wen;
      assign out[ii].be   = (sel_i) ? in1[ii].be   : in0[ii].be;
      assign out[ii].data = (sel_i) ? in1[ii].data : in0[ii].data;
      assign in0[ii].gnt     = (~sel_i) ? out[ii].gnt     : 1'b0;
      assign in0[ii].r_valid = (~sel_i) ? out[ii].r_valid : 1'b0;
      assign in0[ii].r_data  = out[ii].r_data;
      assign in1[ii].gnt     = (sel_i)  ? out[ii].gnt     : 1'b0;
      assign in1[ii].r_valid = (sel_i)  ? out[ii].r_valid : 1'b0;
      assign in1[ii].r_data  = out[ii].r_data;
    end
  endgenerate

endmodule // hwpe_stream_tcdm_mux_static
