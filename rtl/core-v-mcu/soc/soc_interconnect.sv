//-----------------------------------------------------------------------------
// Title         : soc_interconnect
//-----------------------------------------------------------------------------
// File          : soc_interconnect.sv
// Author        : Manuel Eggimann  <meggimann@iis.ee.ethz.ch>
// Created       : 29.10.2020
//-----------------------------------------------------------------------------
// Description :
//
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
`include "axi/assign.svh"

module soc_interconnect
  import pkg_soc_interconnect::addr_map_rule_t;
  import axi_pkg::xbar_cfg_t;
#(
    // TCDM Bus Master Config
    parameter int unsigned  NR_MASTER_PORTS = 2, //Master Ports to the SoC interconnect with access to all memory regions
    parameter int unsigned  NR_MASTER_PORTS_INTERLEAVED_ONLY = 2, //Master ports with access restricted to only the interleaved
    //ports (no axes to APB, AXI, or contiguous slaves) TCDM Bus
    //Slave Config
    // L2 Demux Addr rules
    parameter int unsigned NR_ADDR_RULES_L2_DEMUX = 2,
    // Interleaved TCDM slave
    parameter int unsigned NR_SLAVE_PORTS_INTERLEAVED = 2,
    parameter int unsigned NR_ADDR_RULES_SLAVE_PORTS_INTLVD = 2,
    // Contiguous TCDM slave
    parameter int unsigned NR_SLAVE_PORTS_CONTIG = 2,
    parameter int unsigned NR_ADDR_RULES_SLAVE_PORTS_CONTIG = 2,
    // AXI Master ID Width
    parameter int unsigned  AXI_MASTER_ID_WIDTH = 1, // Not really used since we only connect TCDM masters to the
    // axi_xbar with protocol converters. However, the value must not be zero.
    // AXI Slaves
    parameter int unsigned NR_AXI_SLAVE_PORTS = 2,
    parameter int unsigned NR_ADDR_RULES_AXI_SLAVE_PORTS = 2,
    localparam int unsigned AXI_SLAVE_ID_WIDTH = AXI_MASTER_ID_WIDTH + $clog2(
        NR_MASTER_PORTS
    ),  //The actual ID
    //width of the AXI slaves is clog2(NR_AXI_MASTERS) larger than the master id width since the
    //axi_mux in the XBAR will append an identificatoin tag to the outgoing transactions
    //towards the axi slaves so it can backroute the responses
    parameter int unsigned AXI_USER_WIDTH = 32
) (
    input logic clk_i,
    input logic rst_ni,
    input logic test_en_i,  // 0 Normal operation, 1 put sub-IPs into testmode (bypass clock gates)
    XBAR_TCDM_BUS.Slave master_ports[NR_MASTER_PORTS],
    input addr_map_rule_t [NR_ADDR_RULES_L2_DEMUX-1:0] addr_space_l2_demux,
    //Interleaved Slave
    input addr_map_rule_t [NR_ADDR_RULES_SLAVE_PORTS_INTLVD-1:0] addr_space_interleaved,
    XBAR_TCDM_BUS.Master interleaved_slaves[NR_SLAVE_PORTS_INTERLEAVED],
    //Contiguous Slave
    input addr_map_rule_t [NR_ADDR_RULES_SLAVE_PORTS_CONTIG-1:0] addr_space_contiguous,
    XBAR_TCDM_BUS.Master contiguous_slaves[NR_SLAVE_PORTS_CONTIG],
    //AXI Slave
    input addr_map_rule_t [NR_ADDR_RULES_AXI_SLAVE_PORTS-1:0] addr_space_axi,
    AXI_BUS.Master axi_slaves[NR_AXI_SLAVE_PORTS]  //AXI_ID width must be
    //at least clog2(NR_AXI_SLAVES)
);


  // Internal Parameters
  // Do **NOT** change
  localparam int unsigned BUS_DATA_WIDTH = 32;
  localparam int unsigned BUS_ADDR_WIDTH = 32;

  // Internal Wiring Signals
  XBAR_TCDM_BUS l2_demux_2_interleaved_xbar[NR_MASTER_PORTS] ();
  XBAR_TCDM_BUS l2_demux_2_contiguous_xbar[NR_MASTER_PORTS] ();
  XBAR_TCDM_BUS l2_demux_2_axi_bridge[NR_MASTER_PORTS] ();

  //////////////////////
  // L2 Demultiplexer //
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // This is the first stage of the interconnect. For every master, transactions are multiplexed between three     //
  // different target slaves. The first slave port routes to the axi crossbar, the second slave port routes        //
  // to the contiguous crossbar and the third slave port connects to the interleaved crossbar.                     //
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////


  for (genvar i = 0; i < NR_MASTER_PORTS; i++) begin : gen_l2_demux
    XBAR_TCDM_BUS demux_slaves[3] ();

    `TCDM_ASSIGN_INTF(l2_demux_2_axi_bridge[i], demux_slaves[0]);
    `TCDM_ASSIGN_INTF(l2_demux_2_contiguous_xbar[i], demux_slaves[1]);
    `TCDM_ASSIGN_INTF(l2_demux_2_interleaved_xbar[i], demux_slaves[2]);


    tcdm_demux #(
        .NR_OUTPUTS(3),
        .NR_ADDR_MAP_RULES(NR_ADDR_RULES_L2_DEMUX)
    ) i_l2_demux (
        .clk_i,
        .rst_ni,
        .test_en_i,
        .addr_map_rules(addr_space_l2_demux),
        .master_port(master_ports[i]),
        .slave_ports(demux_slaves)
    );
  end

  //////////////////////////
  // Interleaved Crossbar //
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //  This is a fully connected crossbar with combinational arbitration (logarithmic Inteconnect). It arbitrates    //
  //  from the master ports from the L2 demultiplexer and the interleaved-only master ports (ports that do not have //
  //  access to the other address spaces) to the TCDM slaves with address interleaving. That is, the least          //
  //  significant **word address** bits are used to select the slave port. This results in a more equal load on the //
  //  SRAM banks when the master access memory regions in a sequential manner. EVERY SLAVE IS EXPECTED TO HAVE      //
  //  CONSTANT LATENCY OF 1 CYCLE. Slaves that cannot respond within a single cycle must appropriately delay the    //
  //  assertion of the gnt (grant) signal. Asserting grant without asserting r_valid in the next cycle results in   //
  //  undefined behavior.                                                                                           //
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  //Concatenate the l2 demux master port array and the interleaved only port array
  XBAR_TCDM_BUS interleaved_masters[NR_MASTER_PORTS+NR_MASTER_PORTS_INTERLEAVED_ONLY] ();

  //Synopsys 2019.3 has a bug; It doesn't handle expressions for array indices on the left-hand side of assignments.
  // E.g. assign a[param+i] = b[i] doesn't work, but assign a[i] = b[i-param] does.
  // This is a verbose workaround for it. The next couple of ugly macro magic unpacks each interface into individual
  // signal arrays, performs the assignments to the interface and packs the signal back to an array of interfaces.
  `TCDM_EXPLODE_ARRAY_DECLARE(interleaved_masters,
                              NR_MASTER_PORTS + NR_MASTER_PORTS_INTERLEAVED_ONLY)
  for (genvar i = 0; i < NR_MASTER_PORTS + NR_MASTER_PORTS_INTERLEAVED_ONLY; i++) begin
    `TCDM_SLAVE_EXPLODE(interleaved_masters[i], interleaved_masters, [i])
  end
  `TCDM_EXPLODE_ARRAY_DECLARE(l2_demux_2_interleaved_xbar, NR_MASTER_PORTS)
  for (genvar i = 0; i < NR_MASTER_PORTS; i++) begin
    `TCDM_MASTER_EXPLODE(l2_demux_2_interleaved_xbar[i], l2_demux_2_interleaved_xbar, [i])
    `TCDM_ASSIGN(interleaved_masters, [i], l2_demux_2_interleaved_xbar, [i])
  end
`ifndef VERILATOR
  if (NR_MASTER_PORTS_INTERLEAVED_ONLY > 0) begin
    `TCDM_EXPLODE_ARRAY_DECLARE(master_ports_interleaved_only_checked,
                                NR_MASTER_PORTS_INTERLEAVED_ONLY)
    for (genvar i = 0; i < NR_MASTER_PORTS_INTERLEAVED_ONLY; i++) begin
      `TCDM_MASTER_EXPLODE(master_ports_interleaved_only_checked[i],
                           master_ports_interleaved_only_checked, [i])
      `TCDM_ASSIGN(interleaved_masters, [NR_MASTER_PORTS + i],
                   master_ports_interleaved_only_checked, [i])
    end
  end
`endif
  interleaved_crossbar #(
      .NR_MASTER_PORTS(NR_MASTER_PORTS + NR_MASTER_PORTS_INTERLEAVED_ONLY),
      .NR_SLAVE_PORTS (NR_SLAVE_PORTS_INTERLEAVED)
  ) i_interleaved_xbar (
      // Interfaces
      .master_ports(interleaved_masters),
      .slave_ports (interleaved_slaves),
      // Inputs
      .clk_i,
      .rst_ni,
      .test_en_i
  );

  /////////////////////////
  // Contiguous Crossbar //
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // This is a fully connected crossbar with combinational arbitration (logarithmic Inteconnect). Internally, there //
  // is an address decoder that matches each master_port address against a number of address range to output port   //
  // mapping rules. Addresses not matching any of the address mapping rules will end up on a default port that      //
  // always grants the request, raises the opc line for one cycle and in the case of a read acces, responds with    //
  // the word 0xBADACCE5. EVERY SLAVE IS EXPECTED TO HAVE CONSTANT LATENCY OF 1 CYCLE. Slaves that cannot respond   //
  // within a single cycle must appropriately delay the assertion of the gnt (grant) signal. Asserting grant        //
  // without asserting r_valid in the next cycle results in undefined behavior.                                     //
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  XBAR_TCDM_BUS error_slave ();
  contiguous_crossbar #(
      .NR_MASTER_PORTS(NR_MASTER_PORTS),
      .NR_SLAVE_PORTS (NR_SLAVE_PORTS_CONTIG),
      .NR_ADDR_RULES  (NR_ADDR_RULES_SLAVE_PORTS_CONTIG)
  ) i_contiguous_xbar (
      // Interfaces
      .master_ports(l2_demux_2_contiguous_xbar),
      .slave_ports (contiguous_slaves),
      .error_port  (error_slave),
      .addr_rules  (addr_space_contiguous),
      // Inputs
      .clk_i,
      .rst_ni,
      .test_en_i
  );
  //Error Slave
  // This dummy slave is responsible to generate the buserror described above
  tcdm_error_slave #(
      .ERROR_RESPONSE(32'hBADACCE5)
  ) i_error_slave_contig_xbar (
      .clk_i,
      .rst_ni,
      .slave(error_slave)
  );


  ////////////////////////
  // TCDM to AXI Bridge //
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Instantiate a TCDM to AXI protocol converter for each master port from the L2 demultiplexer. The converter //
  // converts one 32-bit TCDM port to one 32-bit AXI port.                                                      //
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  AXI_BUS #(
      .AXI_ADDR_WIDTH(32),
      .AXI_DATA_WIDTH(32),
      .AXI_ID_WIDTH  (AXI_MASTER_ID_WIDTH),
      .AXI_USER_WIDTH(AXI_USER_WIDTH)
  ) axi_bridge_2_axi_xbar[NR_MASTER_PORTS] ();
  for (genvar i = 0; i < NR_MASTER_PORTS; i++) begin : gen_tcdm_2_axi_bridge
    lint2axi_wrap #(
        .AXI_ID_WIDTH  (AXI_MASTER_ID_WIDTH),
        .AXI_USER_WIDTH(AXI_USER_WIDTH)
    ) i_lint2axi_bridge (
        .clk_i,
        .rst_ni,
        .master(l2_demux_2_axi_bridge[i]),
        .slave (axi_bridge_2_axi_xbar[i])
    );
  end


  ///////////////////
  // AXI4 Crossbar //
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // The AXI crossbar accepts a set of address to slave port mapping rules (addr_map_i) and decodes the transaction //
  // address accordingly. Illegal addresses that do not map to any defined address space are anaswered with a       //
  // decode error and Read Responses contain the data 0xBADCAB1E. Check the axi_xbar documentation for more         //
  // information.                                                                                                   //
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  localparam xbar_cfg_t AXI_XBAR_CFG = '{
                                                    NoSlvPorts: NR_MASTER_PORTS,
                                                    NoMstPorts: NR_AXI_SLAVE_PORTS,
                                                    MaxMstTrans: 1,       //The TCDM ports do not support
  //outstanding transactiions anyways
  MaxSlvTrans: 4,  //Allow up to 4 in-flight transactions
  //per slave port
  FallThrough: 1,  //Use the reccomended default config
  LatencyMode: axi_pkg::CUT_MST_PORTS,
                                                    AxiIdWidthSlvPorts: AXI_MASTER_ID_WIDTH,
                                                    AxiIdUsedSlvPorts: AXI_MASTER_ID_WIDTH,
                                                    AxiAddrWidth: BUS_ADDR_WIDTH,
                                                    AxiDataWidth: BUS_DATA_WIDTH,
                                                    NoAddrRules: NR_ADDR_RULES_AXI_SLAVE_PORTS
                                                    };

  //Reverse interface array ordering since axi_xbar uses big-endian ordering of the arrays
  AXI_BUS #(
      .AXI_ADDR_WIDTH(32),
      .AXI_DATA_WIDTH(32),
      .AXI_ID_WIDTH  (AXI_MASTER_ID_WIDTH),
      .AXI_USER_WIDTH(AXI_USER_WIDTH)
  ) axi_bridge_2_axi_xbar_reversed[NR_MASTER_PORTS-1:0] ();
  AXI_BUS #(
      .AXI_ADDR_WIDTH(32),
      .AXI_DATA_WIDTH(32),
      .AXI_ID_WIDTH  (AXI_SLAVE_ID_WIDTH),
      .AXI_USER_WIDTH(AXI_USER_WIDTH)
  ) axi_slaves_reversed[NR_AXI_SLAVE_PORTS-1:0] ();

  for (genvar i = 0; i < NR_MASTER_PORTS; i++) begin
    `AXI_ASSIGN(axi_bridge_2_axi_xbar_reversed[i], axi_bridge_2_axi_xbar[i])
  end

  for (genvar i = 0; i < NR_AXI_SLAVE_PORTS; i++) begin
    `AXI_ASSIGN(axi_slaves[i], axi_slaves_reversed[i])
  end

  axi_xbar_intf #(
      .AXI_USER_WIDTH(AXI_USER_WIDTH),
      .Cfg(AXI_XBAR_CFG),
      .rule_t(addr_map_rule_t)
  ) i_axi_xbar (
      .clk_i,
      .rst_ni,
      .test_i(test_en_i),
      .slv_ports(axi_bridge_2_axi_xbar_reversed),
      .mst_ports(axi_slaves_reversed),
      .addr_map_i(addr_space_axi),
      .en_default_mst_port_i('0),
      .default_mst_port_i('0)
  );


endmodule : soc_interconnect
