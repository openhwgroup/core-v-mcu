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

module pad_frame (

    input logic [`N_IO-1:0][`NBIT_PADCFG-1:0] pad_cfg_i,

    // sysio signals
    output logic bootsel_o,
    output logic ref_clk_o,
    output logic rstn_o,
    output logic jtag_tck_o,
    output logic jtag_tdi_o,
    input  logic jtag_tdo_i,
    output logic jtag_tms_o,
    output logic jtag_trst_o,

    // internal io signals
    input  logic [`N_IO-1:0] io_out_i,  // data going to pads
    input  logic [`N_IO-1:0] io_oe_i,  // enable going to pads
    output logic [`N_IO-1:0] io_in_o,  // data coming from pads

    // pad signals
    inout wire [`N_IO-1:0] io
);
  // dummy wire to make lint clean
  wire void1;
  // connect io
`ifndef PULP_FPGA_EMUL
  pad_functional_pu i_pad_0 (
      .OEN(1'b0),
      .I  (1'b0),
      .O  (jtag_tck_o),
      .PAD(io[0]),
      .PEN(1'b1)
  );
`else
  assign jtag_tck_o = io[0];
`endif
`ifndef PULP_FPGA_EMUL
  pad_functional_pu i_pad_1 (
      .OEN(1'b0),
      .I  (1'b0),
      .O  (jtag_tdi_o),
      .PAD(io[1]),
      .PEN(1'b1)
  );
`else
  assign jtag_tdi_o = io[1];
`endif
`ifndef PULP_FPGA_EMUL
  pad_functional_pu i_pad_2 (
      .OEN(1'b1),
      .I  (jtag_tdo_i),
      .O  (void1),
      .PAD(io[2]),
      .PEN(1'b1)
  );
`else
  assign io[2] = jtag_tdo_i;
`endif
`ifndef PULP_FPGA_EMUL
  pad_functional_pu i_pad_3 (
      .OEN(1'b0),
      .I  (1'b0),
      .O  (jtag_tms_o),
      .PAD(io[3]),
      .PEN(1'b1)
  );
`else
  assign jtag_tms_o = io[3];
`endif
`ifndef PULP_FPGA_EMUL
  pad_functional_pu i_pad_4 (
      .OEN(1'b0),
      .I  (1'b0),
      .O  (jtag_trst_o),
      .PAD(io[4]),
      .PEN(1'b1)
  );
`else
  assign jtag_trst_o = io[4];
`endif
`ifndef PULP_FPGA_EMUL
  pad_functional_pu i_pad_5 (
      .OEN(1'b0),
      .I  (1'b0),
      .O  (ref_clk_o),
      .PAD(io[5]),
      .PEN(1'b1)
  );
`else
  assign ref_clk_o = io[5];
`endif
`ifndef PULP_FPGA_EMUL
  pad_functional_pu i_pad_6 (
      .OEN(1'b0),
      .I  (1'b0),
      .O  (rstn_o),
      .PAD(io[6]),
      .PEN(1'b1)
  );
`else
  assign rstn_o = io[6];
`endif
  pad_functional_pu i_pad_7 (
      .OEN(~io_oe_i[7]),
      .I  (io_out_i[7]),
      .O  (io_in_o[7]),
      .PAD(io[7]),
      .PEN(~pad_cfg_i[7][0])
  );
  pad_functional_pu i_pad_8 (
      .OEN(~io_oe_i[8]),
      .I  (io_out_i[8]),
      .O  (io_in_o[8]),
      .PAD(io[8]),
      .PEN(~pad_cfg_i[8][0])
  );
  pad_functional_pu i_pad_9 (
      .OEN(~io_oe_i[9]),
      .I  (io_out_i[9]),
      .O  (io_in_o[9]),
      .PAD(io[9]),
      .PEN(~pad_cfg_i[9][0])
  );
  pad_functional_pu i_pad_10 (
      .OEN(~io_oe_i[10]),
      .I  (io_out_i[10]),
      .O  (io_in_o[10]),
      .PAD(io[10]),
      .PEN(~pad_cfg_i[10][0])
  );
  pad_functional_pu i_pad_11 (
      .OEN(~io_oe_i[11]),
      .I  (io_out_i[11]),
      .O  (io_in_o[11]),
      .PAD(io[11]),
      .PEN(~pad_cfg_i[11][0])
  );
  pad_functional_pu i_pad_12 (
      .OEN(~io_oe_i[12]),
      .I  (io_out_i[12]),
      .O  (io_in_o[12]),
      .PAD(io[12]),
      .PEN(~pad_cfg_i[12][0])
  );
  pad_functional_pu i_pad_13 (
      .OEN(~io_oe_i[13]),
      .I  (io_out_i[13]),
      .O  (io_in_o[13]),
      .PAD(io[13]),
      .PEN(~pad_cfg_i[13][0])
  );
  pad_functional_pu i_pad_14 (
      .OEN(~io_oe_i[14]),
      .I  (io_out_i[14]),
      .O  (io_in_o[14]),
      .PAD(io[14]),
      .PEN(~pad_cfg_i[14][0])
  );
  pad_functional_pu i_pad_15 (
      .OEN(~io_oe_i[15]),
      .I  (io_out_i[15]),
      .O  (io_in_o[15]),
      .PAD(io[15]),
      .PEN(~pad_cfg_i[15][0])
  );
  pad_functional_pu i_pad_16 (
      .OEN(~io_oe_i[16]),
      .I  (io_out_i[16]),
      .O  (io_in_o[16]),
      .PAD(io[16]),
      .PEN(~pad_cfg_i[16][0])
  );
  pad_functional_pu i_pad_17 (
      .OEN(~io_oe_i[17]),
      .I  (io_out_i[17]),
      .O  (io_in_o[17]),
      .PAD(io[17]),
      .PEN(~pad_cfg_i[17][0])
  );
  pad_functional_pu i_pad_18 (
      .OEN(~io_oe_i[18]),
      .I  (io_out_i[18]),
      .O  (io_in_o[18]),
      .PAD(io[18]),
      .PEN(~pad_cfg_i[18][0])
  );
  pad_functional_pu i_pad_19 (
      .OEN(~io_oe_i[19]),
      .I  (io_out_i[19]),
      .O  (io_in_o[19]),
      .PAD(io[19]),
      .PEN(~pad_cfg_i[19][0])
  );
  pad_functional_pu i_pad_20 (
      .OEN(~io_oe_i[20]),
      .I  (io_out_i[20]),
      .O  (io_in_o[20]),
      .PAD(io[20]),
      .PEN(~pad_cfg_i[20][0])
  );
  pad_functional_pu i_pad_21 (
      .OEN(~io_oe_i[21]),
      .I  (io_out_i[21]),
      .O  (io_in_o[21]),
      .PAD(io[21]),
      .PEN(~pad_cfg_i[21][0])
  );
  pad_functional_pu i_pad_22 (
      .OEN(~io_oe_i[22]),
      .I  (io_out_i[22]),
      .O  (io_in_o[22]),
      .PAD(io[22]),
      .PEN(~pad_cfg_i[22][0])
  );
  pad_functional_pu i_pad_23 (
      .OEN(~io_oe_i[23]),
      .I  (io_out_i[23]),
      .O  (io_in_o[23]),
      .PAD(io[23]),
      .PEN(~pad_cfg_i[23][0])
  );
  pad_functional_pu i_pad_24 (
      .OEN(~io_oe_i[24]),
      .I  (io_out_i[24]),
      .O  (io_in_o[24]),
      .PAD(io[24]),
      .PEN(~pad_cfg_i[24][0])
  );
  pad_functional_pu i_pad_25 (
      .OEN(~io_oe_i[25]),
      .I  (io_out_i[25]),
      .O  (io_in_o[25]),
      .PAD(io[25]),
      .PEN(~pad_cfg_i[25][0])
  );
  pad_functional_pu i_pad_26 (
      .OEN(~io_oe_i[26]),
      .I  (io_out_i[26]),
      .O  (io_in_o[26]),
      .PAD(io[26]),
      .PEN(~pad_cfg_i[26][0])
  );
  pad_functional_pu i_pad_27 (
      .OEN(~io_oe_i[27]),
      .I  (io_out_i[27]),
      .O  (io_in_o[27]),
      .PAD(io[27]),
      .PEN(~pad_cfg_i[27][0])
  );
  pad_functional_pu i_pad_28 (
      .OEN(~io_oe_i[28]),
      .I  (io_out_i[28]),
      .O  (io_in_o[28]),
      .PAD(io[28]),
      .PEN(~pad_cfg_i[28][0])
  );
  pad_functional_pu i_pad_29 (
      .OEN(~io_oe_i[29]),
      .I  (io_out_i[29]),
      .O  (io_in_o[29]),
      .PAD(io[29]),
      .PEN(~pad_cfg_i[29][0])
  );
  pad_functional_pu i_pad_30 (
      .OEN(~io_oe_i[30]),
      .I  (io_out_i[30]),
      .O  (io_in_o[30]),
      .PAD(io[30]),
      .PEN(~pad_cfg_i[30][0])
  );
  pad_functional_pu i_pad_31 (
      .OEN(~io_oe_i[31]),
      .I  (io_out_i[31]),
      .O  (io_in_o[31]),
      .PAD(io[31]),
      .PEN(~pad_cfg_i[31][0])
  );
  pad_functional_pu i_pad_32 (
      .OEN(~io_oe_i[32]),
      .I  (io_out_i[32]),
      .O  (io_in_o[32]),
      .PAD(io[32]),
      .PEN(~pad_cfg_i[32][0])
  );
  pad_functional_pu i_pad_33 (
      .OEN(~io_oe_i[33]),
      .I  (io_out_i[33]),
      .O  (io_in_o[33]),
      .PAD(io[33]),
      .PEN(~pad_cfg_i[33][0])
  );
  pad_functional_pu i_pad_34 (
      .OEN(~io_oe_i[34]),
      .I  (io_out_i[34]),
      .O  (io_in_o[34]),
      .PAD(io[34]),
      .PEN(~pad_cfg_i[34][0])
  );
  pad_functional_pu i_pad_35 (
      .OEN(~io_oe_i[35]),
      .I  (io_out_i[35]),
      .O  (io_in_o[35]),
      .PAD(io[35]),
      .PEN(~pad_cfg_i[35][0])
  );
  pad_functional_pu i_pad_36 (
      .OEN(~io_oe_i[36]),
      .I  (io_out_i[36]),
      .O  (io_in_o[36]),
      .PAD(io[36]),
      .PEN(~pad_cfg_i[36][0])
  );
  pad_functional_pu i_pad_37 (
      .OEN(~io_oe_i[37]),
      .I  (io_out_i[37]),
      .O  (io_in_o[37]),
      .PAD(io[37]),
      .PEN(~pad_cfg_i[37][0])
  );
  pad_functional_pu i_pad_38 (
      .OEN(~io_oe_i[38]),
      .I  (io_out_i[38]),
      .O  (io_in_o[38]),
      .PAD(io[38]),
      .PEN(~pad_cfg_i[38][0])
  );
  pad_functional_pu i_pad_39 (
      .OEN(~io_oe_i[39]),
      .I  (io_out_i[39]),
      .O  (io_in_o[39]),
      .PAD(io[39]),
      .PEN(~pad_cfg_i[39][0])
  );
  pad_functional_pu i_pad_40 (
      .OEN(~io_oe_i[40]),
      .I  (io_out_i[40]),
      .O  (io_in_o[40]),
      .PAD(io[40]),
      .PEN(~pad_cfg_i[40][0])
  );
  pad_functional_pu i_pad_41 (
      .OEN(~io_oe_i[41]),
      .I  (io_out_i[41]),
      .O  (io_in_o[41]),
      .PAD(io[41]),
      .PEN(~pad_cfg_i[41][0])
  );
  pad_functional_pu i_pad_42 (
      .OEN(~io_oe_i[42]),
      .I  (io_out_i[42]),
      .O  (io_in_o[42]),
      .PAD(io[42]),
      .PEN(~pad_cfg_i[42][0])
  );
  pad_functional_pu i_pad_43 (
      .OEN(~io_oe_i[43]),
      .I  (io_out_i[43]),
      .O  (io_in_o[43]),
      .PAD(io[43]),
      .PEN(~pad_cfg_i[43][0])
  );
  pad_functional_pu i_pad_44 (
      .OEN(~io_oe_i[44]),
      .I  (io_out_i[44]),
      .O  (io_in_o[44]),
      .PAD(io[44]),
      .PEN(~pad_cfg_i[44][0])
  );
`ifndef PULP_FPGA_EMUL
  pad_functional_pu i_pad_45 (
      .OEN(1'b0),
      .I  (1'b0),
      .O  (bootsel_o),
      .PAD(io[45]),
      .PEN(1'b1)
  );
`else
  pad_functional_pd i_pad_45 (
      .OEN(~io_oe_i[45]),
      .I  (io_out_i[45]),
      .O  (io_in_o[45]),
      .PAD(io[45]),
      .PEN(~pad_cfg_i[45][0])
  );
  assign bootsel_o = io_in_o[45];
`endif
  pad_functional_pu i_pad_46 (
      .OEN(~io_oe_i[46]),
      .I  (io_out_i[46]),
      .O  (io_in_o[46]),
      .PAD(io[46]),
      .PEN(~pad_cfg_i[46][0])
  );
  pad_functional_pu i_pad_47 (
      .OEN(~io_oe_i[47]),
      .I  (io_out_i[47]),
      .O  (io_in_o[47]),
      .PAD(io[47]),
      .PEN(~pad_cfg_i[47][0])
  );

endmodule
