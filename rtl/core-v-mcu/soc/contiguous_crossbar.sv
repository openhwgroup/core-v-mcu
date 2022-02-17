//-----------------------------------------------------------------------------
// Title         : Contiguous Crossbar
//-----------------------------------------------------------------------------
// File          : contiguous_crossbar.sv
// Author        : Manuel Eggimann  <meggimann@iis.ee.ethz.ch>
// Created       : 30.10.2020
//-----------------------------------------------------------------------------
// Description :
// Crossbar to arbitrate access from multiple master ports to multiple slave ports
// using address range to slave port mapping rules. If an address doesn't match
// any of the supplied address rules it is routed to the error port.
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

module contiguous_crossbar
  import pkg_soc_interconnect::addr_map_rule_t;
#(
    parameter int unsigned NR_MASTER_PORTS = 2,
    parameter int unsigned NR_SLAVE_PORTS  = 2,
    parameter int unsigned NR_ADDR_RULES   = 2
) (
    input logic                                    clk_i,
    input logic                                    rst_ni,
    input logic                                    test_en_i,
          XBAR_TCDM_BUS.Slave                      master_ports[NR_MASTER_PORTS],
          XBAR_TCDM_BUS.Master                     slave_ports [ NR_SLAVE_PORTS],
          XBAR_TCDM_BUS.Master                     error_port,
    input addr_map_rule_t      [NR_ADDR_RULES-1:0] addr_rules
);
  // Do **not** change. The TCDM interface uses hardcoded bus widths so we cannot just change them here.
  localparam int unsigned BE_WIDTH = 4;
  localparam int unsigned ADDR_WIDTH = 32;
  localparam int unsigned DATA_WIDTH = 32;
  localparam int unsigned NR_SLAVE_PORTS_INTERNAL = NR_SLAVE_PORTS+1; // We have one additional slave port for the
  // default error port
  localparam int unsigned PORT_SEL_WIDTH = $clog2(NR_SLAVE_PORTS_INTERNAL);

  // Explode the input interface array to arrays of individual signals
  //Master Ports
  `TCDM_EXPLODE_ARRAY_DECLARE(master_ports, NR_MASTER_PORTS)
  for (genvar i = 0; i < NR_MASTER_PORTS; i++) begin : l2_demux_2_interleaved_xbar_explode
    `TCDM_MASTER_EXPLODE(master_ports[i], master_ports, [i])
  end  // block: l2_demux_2_interleaved_xbar_explode

  //Slave ports explode. We need to declare one additional port for the error port
  `TCDM_EXPLODE_ARRAY_DECLARE(slave_ports, NR_SLAVE_PORTS_INTERNAL)
  for (genvar i = 0; i < NR_SLAVE_PORTS; i++) begin
    `TCDM_SLAVE_EXPLODE(slave_ports[i], slave_ports, [i])
  end
  `TCDM_SLAVE_EXPLODE(error_port, slave_ports,
                      [NR_SLAVE_PORTS_INTERNAL-1])  //Connect the error port as the last slave

  // We repurpose the cluster interconnect crossbar for this task for the arbitration-less case of 1 input and N
  // outputs. We aggregate all master->slave signals into the write data and unpack it at the output of the crossbar. This
  // is exactly the same trick that the tcdm_interconnect.sv uses. We do the same for the response channel to pack the
  // opc signal into the rdata.

  //Aggregated Request Data (from Master -> slaves)
  localparam int unsigned REQ_AGG_DATA_WIDTH  = 1+BE_WIDTH+ADDR_WIDTH+DATA_WIDTH; // +1 is for the write enable (wen),
  logic [NR_MASTER_PORTS-1:0][REQ_AGG_DATA_WIDTH-1:0] req_data_agg_in;
  logic [NR_SLAVE_PORTS_INTERNAL-1:0][REQ_AGG_DATA_WIDTH-1:0] req_data_agg_out;
  //Aggreagate the input data
  for (genvar i = 0; i < NR_MASTER_PORTS; i++) begin
    assign req_data_agg_in[i] = {
      master_ports_wen[i], master_ports_be[i], master_ports_add[i], master_ports_wdata[i]
    };
  end
  //Disaggregate the output data
  for (genvar i = 0; i < NR_SLAVE_PORTS_INTERNAL; i++) begin : disaggregate_outputs
    assign {slave_ports_wen[i], slave_ports_be[i], slave_ports_add[i], slave_ports_wdata[i]} = req_data_agg_out[i];
  end

  //Aggregated response data (from Slaves -> Master)
  localparam int unsigned RESP_AGG_DATA_WIDTH = DATA_WIDTH + 1;
  logic [NR_SLAVE_PORTS_INTERNAL-1:0][RESP_AGG_DATA_WIDTH-1:0] resp_data_agg_in;
  logic [NR_MASTER_PORTS-1:0][RESP_AGG_DATA_WIDTH-1:0] resp_data_agg_out;
  for (genvar i = 0; i < NR_SLAVE_PORTS_INTERNAL; i++) begin
    assign resp_data_agg_in[i] = {slave_ports_r_rdata[i], slave_ports_r_opc[i]};
  end
  for (genvar i = 0; i < NR_MASTER_PORTS; i++) begin
    assign {master_ports_r_rdata[i], master_ports_r_opc[i]} = resp_data_agg_out[i];
  end

  //Address Decoder
  logic [NR_MASTER_PORTS-1:0][PORT_SEL_WIDTH-1:0] port_sel;
  localparam logic [PORT_SEL_WIDTH-1:0]            DEFAULT_IDX = NR_SLAVE_PORTS_INTERNAL - 1; //If no rule matches we route to the
  //error port
  for (genvar i = 0; i < NR_MASTER_PORTS; i++) begin : gen_addr_decoders
    addr_decode #(
        .NoIndices(NR_SLAVE_PORTS_INTERNAL),
        .NoRules(NR_ADDR_RULES),
        .addr_t(logic [31:0]),
        .rule_t(pkg_soc_interconnect::addr_map_rule_t)
    ) i_addr_decode (
        .addr_i(master_ports_add[i]),
        .addr_map_i(addr_rules),
        .idx_o(port_sel[i]),
        .dec_valid_o(),
        .dec_error_o(),
        .en_default_idx_i(1'b1),
        .default_idx_i(DEFAULT_IDX)
    );
  end


  //Crossbar instantiation
  xbar #(
      .NumIn(NR_MASTER_PORTS),
      .NumOut(NR_SLAVE_PORTS_INTERNAL),
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

endmodule : contiguous_crossbar
