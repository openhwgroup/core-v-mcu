// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`include "pulp_soc_defines.sv"

module pad_frame (

    input logic [47:0][5:0] pad_cfg_i,

    // REF CLOCK
    output logic ref_clk_o,

    // RESET SIGNALS
    output logic rstn_o,

    // JTAG SIGNALS
    output logic jtag_tck_o,
    output logic jtag_tdi_o,
    input  logic jtag_tdo_i,
    output logic jtag_tms_o,
    output logic jtag_trst_o,


    output logic             bootsel_o,
    input  logic [`N_IO-1:0] io_out_i,
    input  logic [`N_IO-1:0] io_oe_i,
    output logic [`N_IO-1:0] io_in_o,
    inout  wire  [`N_IO-1:0] io

);

  // TODO(timsaxe): Stubbed because that is part of the generated HW.

endmodule  // pad_frame
