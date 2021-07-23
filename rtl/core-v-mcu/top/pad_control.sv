//-----------------------------------------------------
// This is a generated file
//-----------------------------------------------------
// Copyright 2018 ETH Zurich and University of bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`include "pulp_soc_defines.sv"
`include "pulp_peripheral_defines.svh"

module pad_control (
    // PAD CONTROL REGISTER
    input  logic [`N_IO-1:0][`NBIT_PADMUX-1:0] pad_mux_i,
    input  logic [`N_IO-1:0][`NBIT_PADCFG-1:0] pad_cfg_i,
    output logic [`N_IO-1:0][`NBIT_PADCFG-1:0] pad_cfg_o,

    // IOS
    output logic [`N_IO-1:0] io_out_o,
    input  logic [`N_IO-1:0] io_in_i,
    output logic [`N_IO-1:0] io_oe_o,

    // PERIOS
    input  logic [`N_PERIO-1:0] perio_out_i,
    output logic [`N_PERIO-1:0] perio_in_o,
    input  logic [`N_PERIO-1:0] perio_oe_i,

    // APBIOs
    input  logic [`N_APBIO-1:0] apbio_out_i,
    output logic [`N_APBIO-1:0] apbio_in_o,
    input  logic [`N_APBIO-1:0] apbio_oe_i,

    // FPGAIOS
    input  logic [`N_FPGAIO-1:0] fpgaio_out_i,
    output logic [`N_FPGAIO-1:0] fpgaio_in_o,
    input  logic [`N_FPGAIO-1:0] fpgaio_oe_i
);

  ///////////////////////////////////////////////////
  // Assign signals to the pad_cfg_o bus
  ///////////////////////////////////////////////////
  assign pad_cfg_o = pad_cfg_i;

  ///////////////////////////////////////////////////
  // Assign signals to the perio bus
  ///////////////////////////////////////////////////
  assign perio_in_o[0] = ((pad_mux_i[8] == 2'd0) ? io_in_i[8] : 1'b0);
  assign perio_in_o[1] = ((pad_mux_i[7] == 2'd0) ? io_in_i[7] : 1'b0);
  assign perio_in_o[2] = ((pad_mux_i[9] == 2'd0) ? io_in_i[9] : 1'b0);
  assign perio_in_o[3] = ((pad_mux_i[10] == 2'd0) ? io_in_i[10] : 1'b0);
  assign perio_in_o[4] = ((pad_mux_i[16] == 2'd0) ? io_in_i[16] : 1'b0);
  assign perio_in_o[5] = ((pad_mux_i[13] == 2'd0) ? io_in_i[13] : 1'b0);
  assign perio_in_o[6] = ((pad_mux_i[26] == 2'd1) ? io_in_i[26] : 1'b0);
  assign perio_in_o[7] = ((pad_mux_i[27] == 2'd1) ? io_in_i[27] : 1'b0);
  assign perio_in_o[8] = ((pad_mux_i[28] == 2'd1) ? io_in_i[28] : 1'b0);
  assign perio_in_o[9] = ((pad_mux_i[14] == 2'd0) ? io_in_i[14] : 1'b0);
  assign perio_in_o[10] = ((pad_mux_i[15] == 2'd0) ? io_in_i[15] : 1'b0);
  assign perio_in_o[11] = ((pad_mux_i[19] == 2'd0) ? io_in_i[19] : 1'b0);
  assign perio_in_o[12] = ((pad_mux_i[20] == 2'd0) ? io_in_i[20] : 1'b0);
  assign perio_in_o[13] = ((pad_mux_i[23] == 2'd0) ? io_in_i[23] : 1'b0);
  assign perio_in_o[14] = ((pad_mux_i[24] == 2'd0) ? io_in_i[24] : 1'b0);
  assign perio_in_o[15] = ((pad_mux_i[46] == 2'd0) ? io_in_i[46] : 1'b0);
  assign perio_in_o[16] = ((pad_mux_i[47] == 2'd0) ? io_in_i[47] : 1'b0);
  assign perio_in_o[17] = 1'b0;
  assign perio_in_o[18] = 1'b0;
  assign perio_in_o[19] = 1'b0;
  assign perio_in_o[20] = 1'b0;
  assign perio_in_o[21] = ((pad_mux_i[37] == 2'd0) ? io_in_i[37] : 1'b0);
  assign perio_in_o[22] = ((pad_mux_i[38] == 2'd0) ? io_in_i[38] : 1'b0);
  assign perio_in_o[23] = ((pad_mux_i[39] == 2'd0) ? io_in_i[39] : 1'b0);
  assign perio_in_o[24] = ((pad_mux_i[40] == 2'd0) ? io_in_i[40] : 1'b0);
  assign perio_in_o[25] = ((pad_mux_i[41] == 2'd0) ? io_in_i[41] : 1'b0);
  assign perio_in_o[26] = ((pad_mux_i[42] == 2'd0) ? io_in_i[42] : 1'b0);
  assign perio_in_o[27] = ((pad_mux_i[25] == 2'd0) ? io_in_i[25] : 1'b0);
  assign perio_in_o[28] = ((pad_mux_i[21] == 2'd0) ? io_in_i[21] : 1'b0);
  assign perio_in_o[29] = ((pad_mux_i[22] == 2'd0) ? io_in_i[22] : 1'b0);
  assign perio_in_o[30] = ((pad_mux_i[29] == 2'd0) ? io_in_i[29] : 1'b0);
  assign perio_in_o[31] = ((pad_mux_i[30] == 2'd0) ? io_in_i[30] : 1'b0);
  assign perio_in_o[32] = ((pad_mux_i[31] == 2'd0) ? io_in_i[31] : 1'b0);
  assign perio_in_o[33] = ((pad_mux_i[32] == 2'd0) ? io_in_i[32] : 1'b0);
  assign perio_in_o[34] = ((pad_mux_i[33] == 2'd0) ? io_in_i[33] : 1'b0);
  assign perio_in_o[35] = ((pad_mux_i[34] == 2'd0) ? io_in_i[34] : 1'b0);
  assign perio_in_o[36] = ((pad_mux_i[35] == 2'd0) ? io_in_i[35] : 1'b0);
  assign perio_in_o[37] = ((pad_mux_i[36] == 2'd0) ? io_in_i[36] : 1'b0);

  ///////////////////////////////////////////////////
  // Assign signals to the apbio bus
  ///////////////////////////////////////////////////
  assign apbio_in_o[0] = ((pad_mux_i[7] == 2'd2) ? io_in_i[7] : 1'b0);
  assign apbio_in_o[1] = ((pad_mux_i[8] == 2'd2) ? io_in_i[8] : 1'b0);
  assign apbio_in_o[2] = ((pad_mux_i[9] == 2'd2) ? io_in_i[9] : 1'b0);
  assign apbio_in_o[3] = ((pad_mux_i[10] == 2'd2) ? io_in_i[10] : 1'b0);
  assign apbio_in_o[4] = ((pad_mux_i[11] == 2'd2) ? io_in_i[11] : 1'b0);
  assign apbio_in_o[5] = ((pad_mux_i[12] == 2'd2) ? io_in_i[12] : 1'b0);
  assign apbio_in_o[6] = ((pad_mux_i[13] == 2'd2) ? io_in_i[13] : 1'b0);
  assign apbio_in_o[7] = ((pad_mux_i[14] == 2'd2) ? io_in_i[14] : 1'b0);
  assign apbio_in_o[8] = ((pad_mux_i[15] == 2'd2) ? io_in_i[15] : 1'b0);
  assign apbio_in_o[9] = ((pad_mux_i[16] == 2'd2) ? io_in_i[16] : 1'b0);
  assign apbio_in_o[10] = ((pad_mux_i[17] == 2'd2) ? io_in_i[17] : 1'b0);
  assign apbio_in_o[11] = ((pad_mux_i[18] == 2'd2) ? io_in_i[18] : 1'b0);
  assign apbio_in_o[12] = ((pad_mux_i[19] == 2'd2) ? io_in_i[19] : 1'b0);
  assign apbio_in_o[13] = ((pad_mux_i[20] == 2'd2) ? io_in_i[20] : 1'b0);
  assign apbio_in_o[14] = ((pad_mux_i[21] == 2'd2) ? io_in_i[21] : 1'b0);
  assign apbio_in_o[15] = ((pad_mux_i[22] == 2'd2) ? io_in_i[22] : 1'b0);
  assign apbio_in_o[16] = ((pad_mux_i[23] == 2'd2) ? io_in_i[23] : 1'b0);
  assign apbio_in_o[17] = ((pad_mux_i[24] == 2'd2) ? io_in_i[24] : 1'b0);
  assign apbio_in_o[18] = ((pad_mux_i[25] == 2'd2) ? io_in_i[25] : 1'b0);
  assign apbio_in_o[19] = ((pad_mux_i[26] == 2'd2) ? io_in_i[26] : 1'b0);
  assign apbio_in_o[20] = ((pad_mux_i[27] == 2'd2) ? io_in_i[27] : 1'b0);
  assign apbio_in_o[21] = ((pad_mux_i[28] == 2'd2) ? io_in_i[28] : 1'b0);
  assign apbio_in_o[22] = ((pad_mux_i[29] == 2'd2) ? io_in_i[29] : 1'b0);
  assign apbio_in_o[23] = ((pad_mux_i[30] == 2'd2) ? io_in_i[30] : 1'b0);
  assign apbio_in_o[24] = ((pad_mux_i[31] == 2'd2) ? io_in_i[31] : 1'b0);
  assign apbio_in_o[25] = ((pad_mux_i[32] == 2'd2) ? io_in_i[32] : 1'b0);
  assign apbio_in_o[26] = ((pad_mux_i[33] == 2'd2) ? io_in_i[33] : 1'b0);
  assign apbio_in_o[27] = ((pad_mux_i[34] == 2'd2) ? io_in_i[34] : 1'b0);
  assign apbio_in_o[28] = ((pad_mux_i[35] == 2'd2) ? io_in_i[35] : 1'b0);
  assign apbio_in_o[29] = ((pad_mux_i[36] == 2'd2) ? io_in_i[36] : 1'b0);
  assign apbio_in_o[30] = ((pad_mux_i[37] == 2'd2) ? io_in_i[37] : 1'b0);
  assign apbio_in_o[31] = ((pad_mux_i[38] == 2'd2) ? io_in_i[38] : 1'b0);
  assign apbio_in_o[32] = ((pad_mux_i[26] == 2'd0) ? io_in_i[26] :
                           ((pad_mux_i[39] == 2'd2) ? io_in_i[39] : 1'b0));
  assign apbio_in_o[33] = ((pad_mux_i[25] == 2'd1) ? io_in_i[25] : 1'b0);
  assign apbio_in_o[34] = ((pad_mux_i[29] == 2'd1) ? io_in_i[29] : 1'b0);
  assign apbio_in_o[35] = ((pad_mux_i[30] == 2'd1) ? io_in_i[30] : 1'b0);
  assign apbio_in_o[36] = ((pad_mux_i[21] == 2'd1) ? io_in_i[21] : 1'b0);
  assign apbio_in_o[37] = ((pad_mux_i[31] == 2'd1) ? io_in_i[31] : 1'b0);
  assign apbio_in_o[38] = ((pad_mux_i[32] == 2'd1) ? io_in_i[32] : 1'b0);
  assign apbio_in_o[39] = ((pad_mux_i[22] == 2'd1) ? io_in_i[22] : 1'b0);
  assign apbio_in_o[40] = ((pad_mux_i[33] == 2'd1) ? io_in_i[33] : 1'b0);
  assign apbio_in_o[41] = ((pad_mux_i[34] == 2'd1) ? io_in_i[34] : 1'b0);
  assign apbio_in_o[42] = ((pad_mux_i[35] == 2'd1) ? io_in_i[35] : 1'b0);
  assign apbio_in_o[43] = ((pad_mux_i[36] == 2'd1) ? io_in_i[36] :
                           ((pad_mux_i[40] == 2'd2) ? io_in_i[40] : 1'b0));
  assign apbio_in_o[44] = ((pad_mux_i[41] == 2'd2) ? io_in_i[41] : 1'b0);
  assign apbio_in_o[45] = ((pad_mux_i[42] == 2'd2) ? io_in_i[42] : 1'b0);
  assign apbio_in_o[46] = ((pad_mux_i[43] == 2'd2) ? io_in_i[43] : 1'b0);
  assign apbio_in_o[47] = ((pad_mux_i[11] == 2'd1) ? io_in_i[11] :
                           ((pad_mux_i[44] == 2'd2) ? io_in_i[44] : 1'b0));
  assign apbio_in_o[48] = ((pad_mux_i[27] == 2'd0) ? io_in_i[27] : 1'b0);
  assign apbio_in_o[49] = ((pad_mux_i[28] == 2'd0) ? io_in_i[28] : 1'b0);

  ///////////////////////////////////////////////////
  // Assign signals to the fpgaio bus
  ///////////////////////////////////////////////////
  assign fpgaio_in_o[0] = ((pad_mux_i[7] == 2'd3) ? io_in_i[7] : 1'b0);
  assign fpgaio_in_o[1] = ((pad_mux_i[8] == 2'd3) ? io_in_i[8] : 1'b0);
  assign fpgaio_in_o[2] = ((pad_mux_i[9] == 2'd3) ? io_in_i[9] : 1'b0);
  assign fpgaio_in_o[3] = ((pad_mux_i[10] == 2'd3) ? io_in_i[10] : 1'b0);
  assign fpgaio_in_o[4] = ((pad_mux_i[11] == 2'd3) ? io_in_i[11] : 1'b0);
  assign fpgaio_in_o[5] = ((pad_mux_i[12] == 2'd3) ? io_in_i[12] : 1'b0);
  assign fpgaio_in_o[6] = ((pad_mux_i[13] == 2'd3) ? io_in_i[13] : 1'b0);
  assign fpgaio_in_o[7] = ((pad_mux_i[14] == 2'd3) ? io_in_i[14] : 1'b0);
  assign fpgaio_in_o[8] = ((pad_mux_i[15] == 2'd3) ? io_in_i[15] : 1'b0);
  assign fpgaio_in_o[9] = ((pad_mux_i[16] == 2'd3) ? io_in_i[16] : 1'b0);
  assign fpgaio_in_o[10] = ((pad_mux_i[17] == 2'd3) ? io_in_i[17] : 1'b0);
  assign fpgaio_in_o[11] = ((pad_mux_i[18] == 2'd3) ? io_in_i[18] : 1'b0);
  assign fpgaio_in_o[12] = ((pad_mux_i[19] == 2'd3) ? io_in_i[19] : 1'b0);
  assign fpgaio_in_o[13] = ((pad_mux_i[20] == 2'd3) ? io_in_i[20] : 1'b0);
  assign fpgaio_in_o[14] = ((pad_mux_i[21] == 2'd3) ? io_in_i[21] : 1'b0);
  assign fpgaio_in_o[15] = ((pad_mux_i[22] == 2'd3) ? io_in_i[22] : 1'b0);
  assign fpgaio_in_o[16] = ((pad_mux_i[23] == 2'd3) ? io_in_i[23] : 1'b0);
  assign fpgaio_in_o[17] = ((pad_mux_i[24] == 2'd3) ? io_in_i[24] : 1'b0);
  assign fpgaio_in_o[18] = ((pad_mux_i[25] == 2'd3) ? io_in_i[25] : 1'b0);
  assign fpgaio_in_o[19] = ((pad_mux_i[26] == 2'd3) ? io_in_i[26] : 1'b0);
  assign fpgaio_in_o[20] = ((pad_mux_i[27] == 2'd3) ? io_in_i[27] : 1'b0);
  assign fpgaio_in_o[21] = ((pad_mux_i[28] == 2'd3) ? io_in_i[28] : 1'b0);
  assign fpgaio_in_o[22] = ((pad_mux_i[29] == 2'd3) ? io_in_i[29] : 1'b0);
  assign fpgaio_in_o[23] = ((pad_mux_i[30] == 2'd3) ? io_in_i[30] : 1'b0);
  assign fpgaio_in_o[24] = ((pad_mux_i[31] == 2'd3) ? io_in_i[31] : 1'b0);
  assign fpgaio_in_o[25] = ((pad_mux_i[32] == 2'd3) ? io_in_i[32] : 1'b0);
  assign fpgaio_in_o[26] = ((pad_mux_i[33] == 2'd3) ? io_in_i[33] : 1'b0);
  assign fpgaio_in_o[27] = ((pad_mux_i[34] == 2'd3) ? io_in_i[34] : 1'b0);
  assign fpgaio_in_o[28] = ((pad_mux_i[35] == 2'd3) ? io_in_i[35] : 1'b0);
  assign fpgaio_in_o[29] = ((pad_mux_i[36] == 2'd3) ? io_in_i[36] : 1'b0);
  assign fpgaio_in_o[30] = ((pad_mux_i[37] == 2'd3) ? io_in_i[37] : 1'b0);
  assign fpgaio_in_o[31] = ((pad_mux_i[38] == 2'd3) ? io_in_i[38] : 1'b0);
  assign fpgaio_in_o[32] = ((pad_mux_i[39] == 2'd3) ? io_in_i[39] : 1'b0);
  assign fpgaio_in_o[33] = ((pad_mux_i[40] == 2'd3) ? io_in_i[40] : 1'b0);
  assign fpgaio_in_o[34] = ((pad_mux_i[41] == 2'd3) ? io_in_i[41] : 1'b0);
  assign fpgaio_in_o[35] = ((pad_mux_i[42] == 2'd3) ? io_in_i[42] : 1'b0);
  assign fpgaio_in_o[36] = ((pad_mux_i[43] == 2'd3) ? io_in_i[43] : 1'b0);
  assign fpgaio_in_o[37] = ((pad_mux_i[44] == 2'd3) ? io_in_i[44] : 1'b0);
  assign fpgaio_in_o[38] = ((pad_mux_i[45] == 2'd3) ? io_in_i[45] : 1'b0);
  assign fpgaio_in_o[39] = ((pad_mux_i[46] == 2'd3) ? io_in_i[46] : 1'b0);
  assign fpgaio_in_o[40] = ((pad_mux_i[47] == 2'd3) ? io_in_i[47] : 1'b0);
  assign fpgaio_in_o[41] = 1'b0;
  assign fpgaio_in_o[42] = 1'b0;

  ///////////////////////////////////////////////////
  // Assign signals to the io_out bus
  ///////////////////////////////////////////////////
  assign io_out_o[0] = ((pad_mux_i[0] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[0] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[0] == 2'd2) ? 1'b0 :
                         ((pad_mux_i[0] == 2'd3) ? 1'b0 : 1'b0))));
  assign io_out_o[1] = ((pad_mux_i[1] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[1] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[1] == 2'd2) ? 1'b0 :
                         ((pad_mux_i[1] == 2'd3) ? 1'b0 : 1'b0))));
  assign io_out_o[2] = ((pad_mux_i[2] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[2] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[2] == 2'd2) ? 1'b0 :
                         ((pad_mux_i[2] == 2'd3) ? 1'b0 : 1'b0))));
  assign io_out_o[3] = ((pad_mux_i[3] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[3] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[3] == 2'd2) ? 1'b0 :
                         ((pad_mux_i[3] == 2'd3) ? 1'b0 : 1'b0))));
  assign io_out_o[4] = ((pad_mux_i[4] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[4] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[4] == 2'd2) ? 1'b0 :
                         ((pad_mux_i[4] == 2'd3) ? 1'b0 : 1'b0))));
  assign io_out_o[5] = ((pad_mux_i[5] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[5] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[5] == 2'd2) ? 1'b0 :
                         ((pad_mux_i[5] == 2'd3) ? 1'b0 : 1'b0))));
  assign io_out_o[6] = ((pad_mux_i[6] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[6] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[6] == 2'd2) ? 1'b0 :
                         ((pad_mux_i[6] == 2'd3) ? 1'b0 : 1'b0))));
  assign io_out_o[7] = ((pad_mux_i[7] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[7] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[7] == 2'd2) ? apbio_out_i[0] :
                         ((pad_mux_i[7] == 2'd3) ? fpgaio_out_i[0] : 1'b0))));
  assign io_out_o[8] = ((pad_mux_i[8] == 2'd0) ? perio_out_i[`PERIO_UART0_TX] :
                         ((pad_mux_i[8] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[8] == 2'd2) ? apbio_out_i[1] :
                         ((pad_mux_i[8] == 2'd3) ? fpgaio_out_i[1] : 1'b0))));
  assign io_out_o[9] = ((pad_mux_i[9] == 2'd0) ? perio_out_i[`PERIO_UART1_TX] :
                         ((pad_mux_i[9] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[9] == 2'd2) ? apbio_out_i[2] :
                         ((pad_mux_i[9] == 2'd3) ? fpgaio_out_i[2] : 1'b0))));
  assign io_out_o[10] = ((pad_mux_i[10] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[10] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[10] == 2'd2) ? apbio_out_i[3] :
                         ((pad_mux_i[10] == 2'd3) ? fpgaio_out_i[3] : 1'b0))));
  assign io_out_o[11] = ((pad_mux_i[11] == 2'd0) ? apbio_out_i[32] :
                         ((pad_mux_i[11] == 2'd1) ? apbio_out_i[47] :
                         ((pad_mux_i[11] == 2'd2) ? apbio_out_i[4] :
                         ((pad_mux_i[11] == 2'd3) ? fpgaio_out_i[4] : 1'b0))));
  assign io_out_o[12] = ((pad_mux_i[12] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[12] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[12] == 2'd2) ? apbio_out_i[5] :
                         ((pad_mux_i[12] == 2'd3) ? fpgaio_out_i[5] : 1'b0))));
  assign io_out_o[13] = ((pad_mux_i[13] == 2'd0) ? perio_out_i[`PERIO_QSPIM0_CSN0] :
                         ((pad_mux_i[13] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[13] == 2'd2) ? apbio_out_i[6] :
                         ((pad_mux_i[13] == 2'd3) ? fpgaio_out_i[6] : 1'b0))));
  assign io_out_o[14] = ((pad_mux_i[14] == 2'd0) ? perio_out_i[`PERIO_QSPIM0_DATA0] :
                         ((pad_mux_i[14] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[14] == 2'd2) ? apbio_out_i[7] :
                         ((pad_mux_i[14] == 2'd3) ? fpgaio_out_i[7] : 1'b0))));
  assign io_out_o[15] = ((pad_mux_i[15] == 2'd0) ? perio_out_i[`PERIO_QSPIM0_DATA1] :
                         ((pad_mux_i[15] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[15] == 2'd2) ? apbio_out_i[8] :
                         ((pad_mux_i[15] == 2'd3) ? fpgaio_out_i[8] : 1'b0))));
  assign io_out_o[16] = ((pad_mux_i[16] == 2'd0) ? perio_out_i[`PERIO_QSPIM0_CLK] :
                         ((pad_mux_i[16] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[16] == 2'd2) ? apbio_out_i[9] :
                         ((pad_mux_i[16] == 2'd3) ? fpgaio_out_i[9] : 1'b0))));
  assign io_out_o[17] = ((pad_mux_i[17] == 2'd0) ? 1'b1 :
                         ((pad_mux_i[17] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[17] == 2'd2) ? apbio_out_i[10] :
                         ((pad_mux_i[17] == 2'd3) ? fpgaio_out_i[10] : 1'b0))));
  assign io_out_o[18] = ((pad_mux_i[18] == 2'd0) ? 1'b1 :
                         ((pad_mux_i[18] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[18] == 2'd2) ? apbio_out_i[11] :
                         ((pad_mux_i[18] == 2'd3) ? fpgaio_out_i[11] : 1'b0))));
  assign io_out_o[19] = ((pad_mux_i[19] == 2'd0) ? perio_out_i[`PERIO_QSPIM0_DATA2] :
                         ((pad_mux_i[19] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[19] == 2'd2) ? apbio_out_i[12] :
                         ((pad_mux_i[19] == 2'd3) ? fpgaio_out_i[12] : 1'b0))));
  assign io_out_o[20] = ((pad_mux_i[20] == 2'd0) ? perio_out_i[`PERIO_QSPIM0_DATA3] :
                         ((pad_mux_i[20] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[20] == 2'd2) ? apbio_out_i[13] :
                         ((pad_mux_i[20] == 2'd3) ? fpgaio_out_i[13] : 1'b0))));
  assign io_out_o[21] = ((pad_mux_i[21] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[21] == 2'd1) ? apbio_out_i[36] :
                         ((pad_mux_i[21] == 2'd2) ? apbio_out_i[14] :
                         ((pad_mux_i[21] == 2'd3) ? fpgaio_out_i[14] : 1'b0))));
  assign io_out_o[22] = ((pad_mux_i[22] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[22] == 2'd1) ? apbio_out_i[39] :
                         ((pad_mux_i[22] == 2'd2) ? apbio_out_i[15] :
                         ((pad_mux_i[22] == 2'd3) ? fpgaio_out_i[15] : 1'b0))));
  assign io_out_o[23] = ((pad_mux_i[23] == 2'd0) ? perio_out_i[`PERIO_I2CM0_SCL] :
                         ((pad_mux_i[23] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[23] == 2'd2) ? apbio_out_i[16] :
                         ((pad_mux_i[23] == 2'd3) ? fpgaio_out_i[16] : 1'b0))));
  assign io_out_o[24] = ((pad_mux_i[24] == 2'd0) ? perio_out_i[`PERIO_I2CM0_SDA] :
                         ((pad_mux_i[24] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[24] == 2'd2) ? apbio_out_i[17] :
                         ((pad_mux_i[24] == 2'd3) ? fpgaio_out_i[17] : 1'b0))));
  assign io_out_o[25] = ((pad_mux_i[25] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[25] == 2'd1) ? apbio_out_i[33] :
                         ((pad_mux_i[25] == 2'd2) ? apbio_out_i[18] :
                         ((pad_mux_i[25] == 2'd3) ? fpgaio_out_i[18] : 1'b0))));
  assign io_out_o[26] = ((pad_mux_i[26] == 2'd0) ? apbio_out_i[32] :
                         ((pad_mux_i[26] == 2'd1) ? perio_out_i[`PERIO_QSPIM0_CSN1] :
                         ((pad_mux_i[26] == 2'd2) ? apbio_out_i[19] :
                         ((pad_mux_i[26] == 2'd3) ? fpgaio_out_i[19] : 1'b0))));
  assign io_out_o[27] = ((pad_mux_i[27] == 2'd0) ? apbio_out_i[48] :
                         ((pad_mux_i[27] == 2'd1) ? perio_out_i[`PERIO_QSPIM0_CSN2] :
                         ((pad_mux_i[27] == 2'd2) ? apbio_out_i[20] :
                         ((pad_mux_i[27] == 2'd3) ? fpgaio_out_i[20] : 1'b0))));
  assign io_out_o[28] = ((pad_mux_i[28] == 2'd0) ? apbio_out_i[49] :
                         ((pad_mux_i[28] == 2'd1) ? perio_out_i[`PERIO_QSPIM0_CSN3] :
                         ((pad_mux_i[28] == 2'd2) ? apbio_out_i[21] :
                         ((pad_mux_i[28] == 2'd3) ? fpgaio_out_i[21] : 1'b0))));
  assign io_out_o[29] = ((pad_mux_i[29] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[29] == 2'd1) ? apbio_out_i[34] :
                         ((pad_mux_i[29] == 2'd2) ? apbio_out_i[22] :
                         ((pad_mux_i[29] == 2'd3) ? fpgaio_out_i[22] : 1'b0))));
  assign io_out_o[30] = ((pad_mux_i[30] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[30] == 2'd1) ? apbio_out_i[35] :
                         ((pad_mux_i[30] == 2'd2) ? apbio_out_i[23] :
                         ((pad_mux_i[30] == 2'd3) ? fpgaio_out_i[23] : 1'b0))));
  assign io_out_o[31] = ((pad_mux_i[31] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[31] == 2'd1) ? apbio_out_i[37] :
                         ((pad_mux_i[31] == 2'd2) ? apbio_out_i[24] :
                         ((pad_mux_i[31] == 2'd3) ? fpgaio_out_i[24] : 1'b0))));
  assign io_out_o[32] = ((pad_mux_i[32] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[32] == 2'd1) ? apbio_out_i[38] :
                         ((pad_mux_i[32] == 2'd2) ? apbio_out_i[25] :
                         ((pad_mux_i[32] == 2'd3) ? fpgaio_out_i[25] : 1'b0))));
  assign io_out_o[33] = ((pad_mux_i[33] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[33] == 2'd1) ? apbio_out_i[40] :
                         ((pad_mux_i[33] == 2'd2) ? apbio_out_i[26] :
                         ((pad_mux_i[33] == 2'd3) ? fpgaio_out_i[26] : 1'b0))));
  assign io_out_o[34] = ((pad_mux_i[34] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[34] == 2'd1) ? apbio_out_i[41] :
                         ((pad_mux_i[34] == 2'd2) ? apbio_out_i[27] :
                         ((pad_mux_i[34] == 2'd3) ? fpgaio_out_i[27] : 1'b0))));
  assign io_out_o[35] = ((pad_mux_i[35] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[35] == 2'd1) ? apbio_out_i[42] :
                         ((pad_mux_i[35] == 2'd2) ? apbio_out_i[28] :
                         ((pad_mux_i[35] == 2'd3) ? fpgaio_out_i[28] : 1'b0))));
  assign io_out_o[36] = ((pad_mux_i[36] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[36] == 2'd1) ? apbio_out_i[43] :
                         ((pad_mux_i[36] == 2'd2) ? apbio_out_i[29] :
                         ((pad_mux_i[36] == 2'd3) ? fpgaio_out_i[29] : 1'b0))));
  assign io_out_o[37] = ((pad_mux_i[37] == 2'd0) ? perio_out_i[`PERIO_SDIO0_CLK] :
                         ((pad_mux_i[37] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[37] == 2'd2) ? apbio_out_i[30] :
                         ((pad_mux_i[37] == 2'd3) ? fpgaio_out_i[30] : 1'b0))));
  assign io_out_o[38] = ((pad_mux_i[38] == 2'd0) ? perio_out_i[`PERIO_SDIO0_CMD] :
                         ((pad_mux_i[38] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[38] == 2'd2) ? apbio_out_i[31] :
                         ((pad_mux_i[38] == 2'd3) ? fpgaio_out_i[31] : 1'b0))));
  assign io_out_o[39] = ((pad_mux_i[39] == 2'd0) ? perio_out_i[`PERIO_SDIO0_DATA0] :
                         ((pad_mux_i[39] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[39] == 2'd2) ? apbio_out_i[32] :
                         ((pad_mux_i[39] == 2'd3) ? fpgaio_out_i[32] : 1'b0))));
  assign io_out_o[40] = ((pad_mux_i[40] == 2'd0) ? perio_out_i[`PERIO_SDIO0_DATA1] :
                         ((pad_mux_i[40] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[40] == 2'd2) ? apbio_out_i[43] :
                         ((pad_mux_i[40] == 2'd3) ? fpgaio_out_i[33] : 1'b0))));
  assign io_out_o[41] = ((pad_mux_i[41] == 2'd0) ? perio_out_i[`PERIO_SDIO0_DATA2] :
                         ((pad_mux_i[41] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[41] == 2'd2) ? apbio_out_i[44] :
                         ((pad_mux_i[41] == 2'd3) ? fpgaio_out_i[34] : 1'b0))));
  assign io_out_o[42] = ((pad_mux_i[42] == 2'd0) ? perio_out_i[`PERIO_SDIO0_DATA3] :
                         ((pad_mux_i[42] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[42] == 2'd2) ? apbio_out_i[45] :
                         ((pad_mux_i[42] == 2'd3) ? fpgaio_out_i[35] : 1'b0))));
  assign io_out_o[43] = ((pad_mux_i[43] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[43] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[43] == 2'd2) ? apbio_out_i[46] :
                         ((pad_mux_i[43] == 2'd3) ? fpgaio_out_i[36] : 1'b0))));
  assign io_out_o[44] = ((pad_mux_i[44] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[44] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[44] == 2'd2) ? apbio_out_i[47] :
                         ((pad_mux_i[44] == 2'd3) ? fpgaio_out_i[37] : 1'b0))));
  assign io_out_o[45] = ((pad_mux_i[45] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[45] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[45] == 2'd2) ? 1'b0 :
                         ((pad_mux_i[45] == 2'd3) ? fpgaio_out_i[38] : 1'b0))));
  assign io_out_o[46] = ((pad_mux_i[46] == 2'd0) ? perio_out_i[`PERIO_I2CM1_SCL] :
                         ((pad_mux_i[46] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[46] == 2'd2) ? 1'b0 :
                         ((pad_mux_i[46] == 2'd3) ? fpgaio_out_i[39] : 1'b0))));
  assign io_out_o[47] = ((pad_mux_i[47] == 2'd0) ? perio_out_i[`PERIO_I2CM1_SDA] :
                         ((pad_mux_i[47] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[47] == 2'd2) ? 1'b0 :
                         ((pad_mux_i[47] == 2'd3) ? fpgaio_out_i[40] : 1'b0))));

  ///////////////////////////////////////////////////
  // Assign signals to the io_oe bus
  ///////////////////////////////////////////////////
  assign io_oe_o[0] = ((pad_mux_i[0] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[0] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[0] == 2'd2) ? 1'b0 :
                         ((pad_mux_i[0] == 2'd3) ? 1'b0 : 1'b0))));
  assign io_oe_o[1] = ((pad_mux_i[1] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[1] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[1] == 2'd2) ? 1'b0 :
                         ((pad_mux_i[1] == 2'd3) ? 1'b0 : 1'b0))));
  assign io_oe_o[2] = ((pad_mux_i[2] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[2] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[2] == 2'd2) ? 1'b0 :
                         ((pad_mux_i[2] == 2'd3) ? 1'b0 : 1'b0))));
  assign io_oe_o[3] = ((pad_mux_i[3] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[3] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[3] == 2'd2) ? 1'b0 :
                         ((pad_mux_i[3] == 2'd3) ? 1'b0 : 1'b0))));
  assign io_oe_o[4] = ((pad_mux_i[4] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[4] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[4] == 2'd2) ? 1'b0 :
                         ((pad_mux_i[4] == 2'd3) ? 1'b0 : 1'b0))));
  assign io_oe_o[5] = ((pad_mux_i[5] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[5] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[5] == 2'd2) ? 1'b0 :
                         ((pad_mux_i[5] == 2'd3) ? 1'b0 : 1'b0))));
  assign io_oe_o[6] = ((pad_mux_i[6] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[6] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[6] == 2'd2) ? 1'b0 :
                         ((pad_mux_i[6] == 2'd3) ? 1'b0 : 1'b0))));
  assign io_oe_o[7] = ((pad_mux_i[7] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[7] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[7] == 2'd2) ? apbio_oe_i[0] :
                         ((pad_mux_i[7] == 2'd3) ? fpgaio_oe_i[0] : 1'b0))));
  assign io_oe_o[8] = ((pad_mux_i[8] == 2'd0) ? 1'b1 :
                         ((pad_mux_i[8] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[8] == 2'd2) ? apbio_oe_i[1] :
                         ((pad_mux_i[8] == 2'd3) ? fpgaio_oe_i[1] : 1'b0))));
  assign io_oe_o[9] = ((pad_mux_i[9] == 2'd0) ? 1'b1 :
                         ((pad_mux_i[9] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[9] == 2'd2) ? apbio_oe_i[2] :
                         ((pad_mux_i[9] == 2'd3) ? fpgaio_oe_i[2] : 1'b0))));
  assign io_oe_o[10] = ((pad_mux_i[10] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[10] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[10] == 2'd2) ? apbio_oe_i[3] :
                         ((pad_mux_i[10] == 2'd3) ? fpgaio_oe_i[3] : 1'b0))));
  assign io_oe_o[11] = ((pad_mux_i[11] == 2'd0) ? apbio_oe_i[32] :
                         ((pad_mux_i[11] == 2'd1) ? apbio_oe_i[47] :
                         ((pad_mux_i[11] == 2'd2) ? apbio_oe_i[4] :
                         ((pad_mux_i[11] == 2'd3) ? fpgaio_oe_i[4] : 1'b0))));
  assign io_oe_o[12] = ((pad_mux_i[12] == 2'd0) ? 1'b1 :
                         ((pad_mux_i[12] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[12] == 2'd2) ? apbio_oe_i[5] :
                         ((pad_mux_i[12] == 2'd3) ? fpgaio_oe_i[5] : 1'b0))));
  assign io_oe_o[13] = ((pad_mux_i[13] == 2'd0) ? 1'b1 :
                         ((pad_mux_i[13] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[13] == 2'd2) ? apbio_oe_i[6] :
                         ((pad_mux_i[13] == 2'd3) ? fpgaio_oe_i[6] : 1'b0))));
  assign io_oe_o[14] = ((pad_mux_i[14] == 2'd0) ? perio_oe_i[`PERIO_QSPIM0_DATA0] :
                         ((pad_mux_i[14] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[14] == 2'd2) ? apbio_oe_i[7] :
                         ((pad_mux_i[14] == 2'd3) ? fpgaio_oe_i[7] : 1'b0))));
  assign io_oe_o[15] = ((pad_mux_i[15] == 2'd0) ? perio_oe_i[`PERIO_QSPIM0_DATA1] :
                         ((pad_mux_i[15] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[15] == 2'd2) ? apbio_oe_i[8] :
                         ((pad_mux_i[15] == 2'd3) ? fpgaio_oe_i[8] : 1'b0))));
  assign io_oe_o[16] = ((pad_mux_i[16] == 2'd0) ? 1'b1 :
                         ((pad_mux_i[16] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[16] == 2'd2) ? apbio_oe_i[9] :
                         ((pad_mux_i[16] == 2'd3) ? fpgaio_oe_i[9] : 1'b0))));
  assign io_oe_o[17] = ((pad_mux_i[17] == 2'd0) ? 1'b1 :
                         ((pad_mux_i[17] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[17] == 2'd2) ? apbio_oe_i[10] :
                         ((pad_mux_i[17] == 2'd3) ? fpgaio_oe_i[10] : 1'b0))));
  assign io_oe_o[18] = ((pad_mux_i[18] == 2'd0) ? 1'b1 :
                         ((pad_mux_i[18] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[18] == 2'd2) ? apbio_oe_i[11] :
                         ((pad_mux_i[18] == 2'd3) ? fpgaio_oe_i[11] : 1'b0))));
  assign io_oe_o[19] = ((pad_mux_i[19] == 2'd0) ? perio_oe_i[`PERIO_QSPIM0_DATA2] :
                         ((pad_mux_i[19] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[19] == 2'd2) ? apbio_oe_i[12] :
                         ((pad_mux_i[19] == 2'd3) ? fpgaio_oe_i[12] : 1'b0))));
  assign io_oe_o[20] = ((pad_mux_i[20] == 2'd0) ? perio_oe_i[`PERIO_QSPIM0_DATA3] :
                         ((pad_mux_i[20] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[20] == 2'd2) ? apbio_oe_i[13] :
                         ((pad_mux_i[20] == 2'd3) ? fpgaio_oe_i[13] : 1'b0))));
  assign io_oe_o[21] = ((pad_mux_i[21] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[21] == 2'd1) ? apbio_oe_i[36] :
                         ((pad_mux_i[21] == 2'd2) ? apbio_oe_i[14] :
                         ((pad_mux_i[21] == 2'd3) ? fpgaio_oe_i[14] : 1'b0))));
  assign io_oe_o[22] = ((pad_mux_i[22] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[22] == 2'd1) ? apbio_oe_i[39] :
                         ((pad_mux_i[22] == 2'd2) ? apbio_oe_i[15] :
                         ((pad_mux_i[22] == 2'd3) ? fpgaio_oe_i[15] : 1'b0))));
  assign io_oe_o[23] = ((pad_mux_i[23] == 2'd0) ? perio_oe_i[`PERIO_I2CM0_SCL] :
                         ((pad_mux_i[23] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[23] == 2'd2) ? apbio_oe_i[16] :
                         ((pad_mux_i[23] == 2'd3) ? fpgaio_oe_i[16] : 1'b0))));
  assign io_oe_o[24] = ((pad_mux_i[24] == 2'd0) ? perio_oe_i[`PERIO_I2CM0_SDA] :
                         ((pad_mux_i[24] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[24] == 2'd2) ? apbio_oe_i[17] :
                         ((pad_mux_i[24] == 2'd3) ? fpgaio_oe_i[17] : 1'b0))));
  assign io_oe_o[25] = ((pad_mux_i[25] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[25] == 2'd1) ? apbio_oe_i[33] :
                         ((pad_mux_i[25] == 2'd2) ? apbio_oe_i[18] :
                         ((pad_mux_i[25] == 2'd3) ? fpgaio_oe_i[18] : 1'b0))));
  assign io_oe_o[26] = ((pad_mux_i[26] == 2'd0) ? apbio_oe_i[32] :
                         ((pad_mux_i[26] == 2'd1) ? 1'b1 :
                         ((pad_mux_i[26] == 2'd2) ? apbio_oe_i[19] :
                         ((pad_mux_i[26] == 2'd3) ? fpgaio_oe_i[19] : 1'b0))));
  assign io_oe_o[27] = ((pad_mux_i[27] == 2'd0) ? apbio_oe_i[48] :
                         ((pad_mux_i[27] == 2'd1) ? 1'b1 :
                         ((pad_mux_i[27] == 2'd2) ? apbio_oe_i[20] :
                         ((pad_mux_i[27] == 2'd3) ? fpgaio_oe_i[20] : 1'b0))));
  assign io_oe_o[28] = ((pad_mux_i[28] == 2'd0) ? apbio_oe_i[49] :
                         ((pad_mux_i[28] == 2'd1) ? 1'b1 :
                         ((pad_mux_i[28] == 2'd2) ? apbio_oe_i[21] :
                         ((pad_mux_i[28] == 2'd3) ? fpgaio_oe_i[21] : 1'b0))));
  assign io_oe_o[29] = ((pad_mux_i[29] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[29] == 2'd1) ? apbio_oe_i[34] :
                         ((pad_mux_i[29] == 2'd2) ? apbio_oe_i[22] :
                         ((pad_mux_i[29] == 2'd3) ? fpgaio_oe_i[22] : 1'b0))));
  assign io_oe_o[30] = ((pad_mux_i[30] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[30] == 2'd1) ? apbio_oe_i[35] :
                         ((pad_mux_i[30] == 2'd2) ? apbio_oe_i[23] :
                         ((pad_mux_i[30] == 2'd3) ? fpgaio_oe_i[23] : 1'b0))));
  assign io_oe_o[31] = ((pad_mux_i[31] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[31] == 2'd1) ? apbio_oe_i[37] :
                         ((pad_mux_i[31] == 2'd2) ? apbio_oe_i[24] :
                         ((pad_mux_i[31] == 2'd3) ? fpgaio_oe_i[24] : 1'b0))));
  assign io_oe_o[32] = ((pad_mux_i[32] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[32] == 2'd1) ? apbio_oe_i[38] :
                         ((pad_mux_i[32] == 2'd2) ? apbio_oe_i[25] :
                         ((pad_mux_i[32] == 2'd3) ? fpgaio_oe_i[25] : 1'b0))));
  assign io_oe_o[33] = ((pad_mux_i[33] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[33] == 2'd1) ? apbio_oe_i[40] :
                         ((pad_mux_i[33] == 2'd2) ? apbio_oe_i[26] :
                         ((pad_mux_i[33] == 2'd3) ? fpgaio_oe_i[26] : 1'b0))));
  assign io_oe_o[34] = ((pad_mux_i[34] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[34] == 2'd1) ? apbio_oe_i[41] :
                         ((pad_mux_i[34] == 2'd2) ? apbio_oe_i[27] :
                         ((pad_mux_i[34] == 2'd3) ? fpgaio_oe_i[27] : 1'b0))));
  assign io_oe_o[35] = ((pad_mux_i[35] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[35] == 2'd1) ? apbio_oe_i[42] :
                         ((pad_mux_i[35] == 2'd2) ? apbio_oe_i[28] :
                         ((pad_mux_i[35] == 2'd3) ? fpgaio_oe_i[28] : 1'b0))));
  assign io_oe_o[36] = ((pad_mux_i[36] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[36] == 2'd1) ? apbio_oe_i[43] :
                         ((pad_mux_i[36] == 2'd2) ? apbio_oe_i[29] :
                         ((pad_mux_i[36] == 2'd3) ? fpgaio_oe_i[29] : 1'b0))));
  assign io_oe_o[37] = ((pad_mux_i[37] == 2'd0) ? 1'b1 :
                         ((pad_mux_i[37] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[37] == 2'd2) ? apbio_oe_i[30] :
                         ((pad_mux_i[37] == 2'd3) ? fpgaio_oe_i[30] : 1'b0))));
  assign io_oe_o[38] = ((pad_mux_i[38] == 2'd0) ? perio_oe_i[`PERIO_SDIO0_CMD] :
                         ((pad_mux_i[38] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[38] == 2'd2) ? apbio_oe_i[31] :
                         ((pad_mux_i[38] == 2'd3) ? fpgaio_oe_i[31] : 1'b0))));
  assign io_oe_o[39] = ((pad_mux_i[39] == 2'd0) ? perio_oe_i[`PERIO_SDIO0_DATA0] :
                         ((pad_mux_i[39] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[39] == 2'd2) ? apbio_oe_i[32] :
                         ((pad_mux_i[39] == 2'd3) ? fpgaio_oe_i[32] : 1'b0))));
  assign io_oe_o[40] = ((pad_mux_i[40] == 2'd0) ? perio_oe_i[`PERIO_SDIO0_DATA1] :
                         ((pad_mux_i[40] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[40] == 2'd2) ? apbio_oe_i[43] :
                         ((pad_mux_i[40] == 2'd3) ? fpgaio_oe_i[33] : 1'b0))));
  assign io_oe_o[41] = ((pad_mux_i[41] == 2'd0) ? perio_oe_i[`PERIO_SDIO0_DATA2] :
                         ((pad_mux_i[41] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[41] == 2'd2) ? apbio_oe_i[44] :
                         ((pad_mux_i[41] == 2'd3) ? fpgaio_oe_i[34] : 1'b0))));
  assign io_oe_o[42] = ((pad_mux_i[42] == 2'd0) ? perio_oe_i[`PERIO_SDIO0_DATA3] :
                         ((pad_mux_i[42] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[42] == 2'd2) ? apbio_oe_i[45] :
                         ((pad_mux_i[42] == 2'd3) ? fpgaio_oe_i[35] : 1'b0))));
  assign io_oe_o[43] = ((pad_mux_i[43] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[43] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[43] == 2'd2) ? apbio_oe_i[46] :
                         ((pad_mux_i[43] == 2'd3) ? fpgaio_oe_i[36] : 1'b0))));
  assign io_oe_o[44] = ((pad_mux_i[44] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[44] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[44] == 2'd2) ? apbio_oe_i[47] :
                         ((pad_mux_i[44] == 2'd3) ? fpgaio_oe_i[37] : 1'b0))));
  assign io_oe_o[45] = ((pad_mux_i[45] == 2'd0) ? 1'b0 :
                         ((pad_mux_i[45] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[45] == 2'd2) ? 1'b0 :
                         ((pad_mux_i[45] == 2'd3) ? fpgaio_oe_i[38] : 1'b0))));
  assign io_oe_o[46] = ((pad_mux_i[46] == 2'd0) ? perio_oe_i[`PERIO_I2CM1_SCL] :
                         ((pad_mux_i[46] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[46] == 2'd2) ? 1'b0 :
                         ((pad_mux_i[46] == 2'd3) ? fpgaio_oe_i[39] : 1'b0))));
  assign io_oe_o[47] = ((pad_mux_i[47] == 2'd0) ? perio_oe_i[`PERIO_I2CM1_SDA] :
                         ((pad_mux_i[47] == 2'd1) ? 1'b0 :
                         ((pad_mux_i[47] == 2'd2) ? 1'b0 :
                         ((pad_mux_i[47] == 2'd3) ? fpgaio_oe_i[40] : 1'b0))));
endmodule
