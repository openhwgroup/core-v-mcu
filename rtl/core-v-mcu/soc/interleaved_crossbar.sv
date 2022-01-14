//-----------------------------------------------------------------------------
// Title         : Interleaved Crossbar Wrapper
//-----------------------------------------------------------------------------
// File          : interleaved_crossbar.sv
// Author        : Manuel Eggimann  <meggimann@iis.ee.ethz.ch>
// Created       : 30.10.2020
//-----------------------------------------------------------------------------
// Description :
// This is a wrapper module that instantiates the cluster logarithmic interconnect
// and deals with repurposing the request and response channel to pass along
// additional signals not present in the cluster interconnect. The interconnect
// uses a fully connected crossbar and interleavingly maps 32-bi words at their
// naturaly word boundary to the output ports.
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

`include "tcdm_macros.svh"

module interleaved_crossbar #(
    parameter int unsigned NR_MASTER_PORTS = 2,
    parameter int unsigned NR_SLAVE_PORTS  = 2  //Must be a power of two
) (
    input logic clk_i,
    input logic rst_ni,
    input logic test_en_i,
    XBAR_TCDM_BUS.Slave master_ports[NR_MASTER_PORTS],
    XBAR_TCDM_BUS.Master slave_ports[NR_SLAVE_PORTS]
);
  // Do **not** change. The TCDM interface uses hardcoded bus widths so we cannot just change them here.
  localparam int unsigned BE_WIDTH = 4;
  localparam int unsigned ADDR_WIDTH = 32;
  localparam int unsigned DATA_WIDTH = 32;
  localparam int unsigned PORT_SEL_WIDTH = $clog2(NR_SLAVE_PORTS);

  //Elaboration time asserations
  //Number of slaves must be power of two
  if ((NR_SLAVE_PORTS & (NR_SLAVE_PORTS - 1)) != 0) begin
    $error(
        "NR_SLAVE_PORTS must be power of two but was %d", NR_SLAVE_PORTS
    );
  end

  // Explode the input interface array to arrays of individual signals
  //Master Ports
  `TCDM_EXPLODE_ARRAY_DECLARE(master_ports, NR_MASTER_PORTS)
  for (genvar i = 0; i < NR_MASTER_PORTS; i++) begin : l2_demux_2_interleaved_xbar_explode
    `TCDM_MASTER_EXPLODE(master_ports[i], master_ports, [i])
  end  // block: l2_demux_2_interleaved_xbar_explode

  //Slave ports
  `TCDM_EXPLODE_ARRAY_DECLARE(slave_ports, NR_SLAVE_PORTS)
  for (genvar i = 0; i < NR_SLAVE_PORTS; i++) begin
    `TCDM_SLAVE_EXPLODE(slave_ports[i], slave_ports, [i])
  end

  // We repurpose the cluster interconnect crossbar for this task for the arbitration-less case of 1 input and N
  // outputs. We aggregate all master->slave signals into the write data and unpack it at the output of the crossbar. This
  // is exactly the same trick that the tcdm_interconnect.sv uses. We do the same for the response channel to pack the
  // opc signal into the rdata.

  //Aggregated Request Data (from Master -> slaves)
  localparam int unsigned REQ_AGG_DATA_WIDTH  = 1+BE_WIDTH+ADDR_WIDTH+DATA_WIDTH; // +1 is for the write enable (wen),
  logic [NR_MASTER_PORTS-1:0][REQ_AGG_DATA_WIDTH-1:0] req_data_agg_in;
  logic [ NR_SLAVE_PORTS-1:0][REQ_AGG_DATA_WIDTH-1:0] req_data_agg_out;
  //Aggreagate the input data
  for (genvar i = 0; i < NR_MASTER_PORTS; i++) begin
    assign req_data_agg_in[i] = {
      master_ports_wen[i], master_ports_be[i], master_ports_add[i], master_ports_wdata[i]
    };
  end
  //Disaggregate the output data
  for (genvar i = 0; i < NR_SLAVE_PORTS; i++) begin : disaggregate_outputs
    assign {slave_ports_wen[i], slave_ports_be[i], slave_ports_add[i], slave_ports_wdata[i]} = req_data_agg_out[i];
  end

  //Aggregated response data (from Slaves -> Master)
  localparam int unsigned RESP_AGG_DATA_WIDTH = DATA_WIDTH + 1;
  logic [ NR_SLAVE_PORTS-1:0][RESP_AGG_DATA_WIDTH-1:0] resp_data_agg_in;
  logic [NR_MASTER_PORTS-1:0][RESP_AGG_DATA_WIDTH-1:0] resp_data_agg_out;
  for (genvar i = 0; i < NR_SLAVE_PORTS; i++) begin
    assign resp_data_agg_in[i] = {slave_ports_r_rdata[i], slave_ports_r_opc[i]};
  end
  for (genvar i = 0; i < NR_MASTER_PORTS; i++) begin
    assign {master_ports_r_rdata[i], master_ports_r_opc[i]} = resp_data_agg_out[i];
  end

  //Interleaved Output Port Selection
  logic [NR_MASTER_PORTS-1:0][PORT_SEL_WIDTH-1:0] port_sel;
  for (genvar i = 0; i < NR_MASTER_PORTS; i++) begin
    assign port_sel[i] = master_ports[i].add[$clog2(BE_WIDTH)+PORT_SEL_WIDTH-1:$clog2(BE_WIDTH)];
  end

  //Crossbar instantiation
  xbar #(
      .NumIn(NR_MASTER_PORTS),
      .NumOut(NR_SLAVE_PORTS),
      .ReqDataWidth(REQ_AGG_DATA_WIDTH),
      .RespDataWidth(RESP_AGG_DATA_WIDTH),
      .RespLat(1),
      .WriteRespOn(1)
  ) i_xbar (
      .clk_i,
      .rst_ni,
      .req_i  (master_ports_req),
      .add_i  (port_sel),
      .wen_i  (master_ports_wen),
      .wdata_i(req_data_agg_in),
      .gnt_o  (master_ports_gnt),
      .rdata_o(resp_data_agg_out),
      .rr_i   ('0),
      .vld_o  (master_ports_r_valid),
      .gnt_i  (slave_ports_gnt),
      .req_o  (slave_ports_req),
      .wdata_o(req_data_agg_out),
      .rdata_i(resp_data_agg_in)
  );

endmodule : interleaved_crossbar
