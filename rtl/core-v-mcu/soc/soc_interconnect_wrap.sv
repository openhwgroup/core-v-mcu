//-----------------------------------------------------------------------------
// Title         : SoC Interconnect Wrapper
//-----------------------------------------------------------------------------
// File          : soc_interconnect_wrap_v2.sv
// Author        : Manuel Eggimann  <meggimann@iis.ee.ethz.ch>
// Created       : 30.10.2020
//-----------------------------------------------------------------------------
// Description :
// This module instantiates the SoC interconnect and attaches the various SoC
// ports. Furthermore, the wrapper also instantiates the required protocol converters
// (AXI, APB).
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

`include "pulp_soc_defines.svh"
`include "soc_mem_map.svh"
`include "tcdm_macros.svh"
`include "axi/assign.svh"


module soc_interconnect_wrap
  import pkg_soc_interconnect::addr_map_rule_t;
#(
    parameter int NR_HWPE_PORTS = 0,
    parameter int NR_L2_PORTS = 4,
    // AXI Input Plug
    localparam int AXI_IN_ADDR_WIDTH = 32,  // All addresses in the SoC must be 32-bit
    localparam int AXI_IN_DATA_WIDTH = 64, // The internal AXI->TCDM protocol converter does not support any other
    // datawidths than 64-bit
    parameter int AXI_IN_ID_WIDTH = 6,
    parameter int AXI_USER_WIDTH = 6,
    // Axi Output Plug
    localparam int AXI_OUT_ADDR_WIDTH = 32,  // All addresses in the SoC must be 32-bit
    localparam int AXI_OUT_DATA_WIDTH = 32  // The internal TCDM->AXI protocol converter does not support any other
    // datawidths than 32-bit
) (
    input logic clk_i,
    input logic rst_ni,
    input logic test_en_i,
    XBAR_TCDM_BUS.Slave tcdm_fc_data,  //Data Port of the Fabric Controller
    XBAR_TCDM_BUS.Slave tcdm_fc_instr,  //Instruction Port of the Fabric Controller
    XBAR_TCDM_BUS.Slave tcdm_udma_tx,  //TX Channel for the uDMA
    XBAR_TCDM_BUS.Slave tcdm_udma_rx,  //RX Channel for the uDMA
    XBAR_TCDM_BUS.Slave      tcdm_debug, //Debug access port from either the legacy or the riscv-debug unit
    XBAR_TCDM_BUS.Slave tcdm_efpga[`N_EFPGA_TCDM_PORTS-1:0],  // EFPGA ports
    APB_BUS.Master apb_peripheral_bus,  // Connects to all the SoC Peripherals
    XBAR_TCDM_BUS.Master tcdm_efpga_apbt1,
    XBAR_TCDM_BUS.Master     l2_interleaved_slaves[NR_L2_PORTS], // Connects to the interleaved memory banks
    XBAR_TCDM_BUS.Master l2_private_slaves[2],  // Connects to core-private memory banks
    XBAR_TCDM_BUS.Master boot_rom_slave  //Connects to the bootrom
);

  //**Do not change these values unles you verified that all downstream IPs are properly parametrized and support it**
  localparam ADDR_WIDTH = 32;
  localparam DATA_WIDTH = 32;

  ////////////////////////////////////////
  // Address Rules for the interconnect //
  ////////////////////////////////////////
  localparam NR_RULES_L2_DEMUX = 4;
  //Everything that is not routed to port 1 or 2 ends up in port 0 by default
  localparam addr_map_rule_t [NR_RULES_L2_DEMUX-1:0] L2_DEMUX_RULES = '{
      '{ idx: 1 , start_addr: `SOC_MEM_MAP_PRIVATE_BANK0_START_ADDR , end_addr: `SOC_MEM_MAP_PRIVATE_BANK1_END_ADDR} , //Both , bank0 and bank1 are in the  same address block
  '{ idx: 1 , start_addr: `SOC_MEM_MAP_BOOT_ROM_START_ADDR      , end_addr: `SOC_MEM_MAP_BOOT_ROM_END_ADDR}      ,
        '{ idx: 1 , start_addr: `EFPGA_ASYNC_APB_START_ADDR      , end_addr: `EFPGA_ASYNC_APB_END_ADDR},
        '{ idx: 2 , start_addr: `SOC_MEM_MAP_TCDM_START_ADDR          , end_addr: `SOC_MEM_MAP_TCDM_END_ADDR }
  };

  localparam NR_RULES_INTERLEAVED_REGION = 1;
  localparam addr_map_rule_t [NR_RULES_INTERLEAVED_REGION-1:0] INTERLEAVED_ADDR_SPACE = '{
      '{idx: 1, start_addr: `SOC_MEM_MAP_TCDM_START_ADDR, end_addr: `SOC_MEM_MAP_TCDM_END_ADDR}
  };

  localparam NR_RULES_CONTIG_CROSSBAR = 4;
  localparam addr_map_rule_t [NR_RULES_CONTIG_CROSSBAR-1:0] CONTIGUOUS_CROSSBAR_RULES = '{
      '{ idx: 0 , start_addr: `SOC_MEM_MAP_PRIVATE_BANK0_START_ADDR , end_addr: `SOC_MEM_MAP_PRIVATE_BANK0_END_ADDR} ,
        '{ idx: 1 , start_addr: `SOC_MEM_MAP_PRIVATE_BANK1_START_ADDR , end_addr: `SOC_MEM_MAP_PRIVATE_BANK1_END_ADDR} ,
        '{ idx: 2 , start_addr: `SOC_MEM_MAP_BOOT_ROM_START_ADDR      , end_addr: `SOC_MEM_MAP_BOOT_ROM_END_ADDR},
        '{ idx: 3 , start_addr: `EFPGA_ASYNC_APB_START_ADDR      , end_addr: `EFPGA_ASYNC_APB_END_ADDR}
  };

  localparam NR_RULES_AXI_CROSSBAR = 1;
  localparam addr_map_rule_t [NR_RULES_AXI_CROSSBAR-1:0] AXI_CROSSBAR_RULES = '{
  //      '{ idx: 0, start_addr: `SOC_MEM_MAP_AXI_PLUG_START_ADDR,    end_addr: `SOC_MEM_MAP_AXI_PLUG_END_ADDR},
  '{ idx: 0, start_addr: `SOC_MEM_MAP_PERIPHERALS_START_ADDR, end_addr: `SOC_MEM_MAP_PERIPHERALS_END_ADDR}
  };

  //For legacy reasons, the fc_data port can alias the address prefix 0x000 to 0x1c0. E.g. an access to 0x00001234 is
  //mapped to 0x1c001234. The following lines perform this remapping.
  XBAR_TCDM_BUS tcdm_fc_data_addr_remapped ();
  assign tcdm_fc_data_addr_remapped.req = tcdm_fc_data.req;
  assign tcdm_fc_data_addr_remapped.wen = tcdm_fc_data.wen;
  assign tcdm_fc_data_addr_remapped.wdata = tcdm_fc_data.wdata;
  assign tcdm_fc_data_addr_remapped.be = tcdm_fc_data.be;
  assign tcdm_fc_data.gnt = tcdm_fc_data_addr_remapped.gnt;
  assign tcdm_fc_data.r_opc = tcdm_fc_data_addr_remapped.r_opc;
  assign tcdm_fc_data.r_rdata = tcdm_fc_data_addr_remapped.r_rdata;
  assign tcdm_fc_data.r_valid = tcdm_fc_data_addr_remapped.r_valid;
  //Remap address prefix 1c0 to 000
  always_comb begin
    tcdm_fc_data_addr_remapped.add = tcdm_fc_data.add;
    if (tcdm_fc_data.add[31:20] == 12'h000) tcdm_fc_data_addr_remapped.add[31:20] = 12'h1c0;
  end

  //////////////////////////////
  // Instantiate Interconnect //
  //////////////////////////////

  //Internal wiring to APB protocol converter
  AXI_BUS #(
      .AXI_ADDR_WIDTH(32),
      .AXI_DATA_WIDTH(32),
      .AXI_ID_WIDTH  (pkg_soc_interconnect::AXI_ID_OUT_WIDTH),
      .AXI_USER_WIDTH(AXI_USER_WIDTH)
  ) axi_to_axi_lite_bridge ();

  //Wiring signals to interconncet. Unfortunately Synopsys-2019.3 does not support assignment patterns in port lists
  //directly
  XBAR_TCDM_BUS master_ports[pkg_soc_interconnect::NR_TCDM_MASTER_PORTS](); //increase the package localparma as well
  //if you want to add new master ports. The parameter is used by other IPs to calcualte
  //the required AXI ID width.

  //Assign Master Ports to array
  `TCDM_ASSIGN_INTF(master_ports[0], tcdm_fc_data_addr_remapped)
  `TCDM_ASSIGN_INTF(master_ports[1], tcdm_fc_instr)
  `TCDM_ASSIGN_INTF(master_ports[2], tcdm_udma_tx)
  `TCDM_ASSIGN_INTF(master_ports[3], tcdm_udma_rx)
  `TCDM_ASSIGN_INTF(master_ports[4], tcdm_debug)
  `TCDM_ASSIGN_INTF(master_ports[5], tcdm_efpga[0])
  `TCDM_ASSIGN_INTF(master_ports[6], tcdm_efpga[1])
  `TCDM_ASSIGN_INTF(master_ports[7], tcdm_efpga[2])
  `TCDM_ASSIGN_INTF(master_ports[8], tcdm_efpga[3])

  XBAR_TCDM_BUS contiguous_slaves[4] ();
  `TCDM_ASSIGN_INTF(l2_private_slaves[0], contiguous_slaves[0])
  `TCDM_ASSIGN_INTF(l2_private_slaves[1], contiguous_slaves[1])
  `TCDM_ASSIGN_INTF(boot_rom_slave, contiguous_slaves[2])
  `TCDM_ASSIGN_INTF(tcdm_efpga_apbt1, contiguous_slaves[3])

  AXI_BUS #(
      .AXI_ADDR_WIDTH(32),
      .AXI_DATA_WIDTH(32),
      .AXI_ID_WIDTH  (pkg_soc_interconnect::AXI_ID_OUT_WIDTH),
      .AXI_USER_WIDTH(AXI_USER_WIDTH)
  ) axi_slaves[1] ();
  `AXI_ASSIGN(axi_to_axi_lite_bridge, axi_slaves[0])

  //Interconnect instantiation
  soc_interconnect #(
      .NR_MASTER_PORTS(pkg_soc_interconnect::NR_TCDM_MASTER_PORTS), // FC instructions, FC data, uDMA RX, uDMA TX, debug access, 4xeFPGA, 4 four 64-bit
      // axi plug
      .NR_MASTER_PORTS_INTERLEAVED_ONLY(NR_HWPE_PORTS), // HWPEs (PULP accelerators) only have access
      // to the interleaved memory region
      .NR_ADDR_RULES_L2_DEMUX(NR_RULES_L2_DEMUX),
      .NR_SLAVE_PORTS_INTERLEAVED(NR_L2_PORTS),  // Number of interleaved memory banks
      .NR_ADDR_RULES_SLAVE_PORTS_INTLVD(NR_RULES_INTERLEAVED_REGION),
      .NR_SLAVE_PORTS_CONTIG(4),  // Bootrom + number of private memory banks (normally 1 for
      // programm instructions and 1 for programm stack )
      // efpga async apb port
      .NR_ADDR_RULES_SLAVE_PORTS_CONTIG(NR_RULES_CONTIG_CROSSBAR),
      .NR_AXI_SLAVE_PORTS(1),  // 1 for AXI to cluster, 1 for SoC peripherals (converted to APB)
      .NR_ADDR_RULES_AXI_SLAVE_PORTS(NR_RULES_AXI_CROSSBAR),
      .AXI_MASTER_ID_WIDTH(1),  //Doesn't need to be changed. All axi masters in the current
      //interconnect come from a TCDM protocol converter and thus do not have and AXI ID.
      //However, the unerlaying IPs do not support an ID lenght of 0, thus we use 1.
      .AXI_USER_WIDTH(AXI_USER_WIDTH)
  ) i_soc_interconnect (
      .clk_i,
      .rst_ni,
      .test_en_i,
      .master_ports(master_ports),
      .addr_space_l2_demux(L2_DEMUX_RULES),
      .addr_space_interleaved(INTERLEAVED_ADDR_SPACE),
      .interleaved_slaves(l2_interleaved_slaves),
      .addr_space_contiguous(CONTIGUOUS_CROSSBAR_RULES),
      .contiguous_slaves(contiguous_slaves),
      .addr_space_axi(AXI_CROSSBAR_RULES),
      .axi_slaves(axi_slaves)
  );


  ////////////////////////
  // AXI4 to APB Bridge //
  ///////////////////////////////////////////////////////////////////////////////////////////
  // We do the conversion in two steps: We convert AXI4 to AXI4 lite and from there to APB //
  ///////////////////////////////////////////////////////////////////////////////////////////

  AXI_LITE #(
      .AXI_ADDR_WIDTH(32),
      .AXI_DATA_WIDTH(32)
  ) axi_lite_to_apb_bridge ();

  axi_to_axi_lite_intf #(
      .AXI_ADDR_WIDTH(32),
      .AXI_DATA_WIDTH(32),
      .AXI_ID_WIDTH(pkg_soc_interconnect::AXI_ID_OUT_WIDTH),
      .AXI_USER_WIDTH(AXI_USER_WIDTH),
      .AXI_MAX_WRITE_TXNS(1),
      .AXI_MAX_READ_TXNS(1),
      .FALL_THROUGH(1)
  ) i_axi_to_axi_lite (
      .clk_i,
      .rst_ni,
      .testmode_i(test_en_i),
      .slv(axi_to_axi_lite_bridge),
      .mst(axi_lite_to_apb_bridge)
  );

  // The AXI-Lite to APB bridge is capable of connecting one AXI to multiple APB ports using address mapping rules.
  // We do not use this feature and just supply a default rule that matches everything in the peripheral region

  localparam addr_map_rule_t [0:0] APB_BRIDGE_RULES = '{
      '{ idx: 0, start_addr: `SOC_MEM_MAP_PERIPHERALS_START_ADDR, end_addr: `SOC_MEM_MAP_PERIPHERALS_END_ADDR}
  };

  axi_lite_to_apb_intf #(
      .NoApbSlaves(1),
      .NoRules(1),
      .AddrWidth(32),
      .DataWidth(32),
      .rule_t(addr_map_rule_t)
  ) i_axi_lite_to_apb (
      .clk_i,
      .rst_ni,
      .slv(axi_lite_to_apb_bridge),
      .paddr_o(apb_peripheral_bus.paddr),
      .pprot_o(),
      .pselx_o(apb_peripheral_bus.psel),
      .penable_o(apb_peripheral_bus.penable),
      .pwrite_o(apb_peripheral_bus.pwrite),
      .pwdata_o(apb_peripheral_bus.pwdata),
      .pstrb_o(),
      .pready_i(apb_peripheral_bus.pready),
      .prdata_i(apb_peripheral_bus.prdata),
      .pslverr_i(apb_peripheral_bus.pslverr),
      .addr_map_i(APB_BRIDGE_RULES)
  );


endmodule : soc_interconnect_wrap
