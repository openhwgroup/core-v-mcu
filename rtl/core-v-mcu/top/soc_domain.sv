// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


`include "pulp_soc_defines.svh"
`include "pulp_peripheral_defines.svh"

module soc_domain
  import dm::*;
#(
    parameter USE_FPU = 0,
    parameter USE_HWPE = 0,
    parameter USE_CLUSTER_EVENT = 1,
    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_DATA_IN_WIDTH = 64,
    parameter AXI_DATA_OUT_WIDTH = 32,
    parameter AXI_ID_IN_WIDTH = 6,
    localparam AXI_ID_OUT_WIDTH = pkg_soc_interconnect::AXI_ID_OUT_WIDTH,
    parameter AXI_USER_WIDTH = 6,
    parameter BUFFER_WIDTH = 8,
    parameter EVNT_WIDTH = 8,
    parameter NB_CORES = 1,  // was 8
    parameter NB_HWPE_PORTS = 0,
    parameter NGPIO = 43,
    parameter NPAD = 64,  //Must not be changed as other parts
    //downstreams are not parametrci
    parameter NBIT_PADCFG = 6,  //Must not be changed as other parts
    //downstreams are not parametrci
    parameter NBIT_PADMUX = 2,

    parameter int unsigned N_UART = 1,
    parameter int unsigned N_SPI = 1,
    parameter int unsigned N_I2C = 2,
    parameter bit ISOLATE_CLUSTER_CDC = 0,
    parameter AXI_STRB_WIDTH_IN = AXI_DATA_IN_WIDTH / 8,
    parameter AXI_STRB_WIDTH_OUT = AXI_DATA_OUT_WIDTH / 8 // If 0, ties the cluster <-> soc AXI CDC isolation signal to 0 statically
    // Do not override, derived.
) (



    input  logic ref_clk_i,
    input  logic sclk_in,
    output logic slow_clk_o,  // for emulation generation of refclk
    input  logic test_clk_i,
    input  logic rstn_glob_i,

    input  logic                               dft_test_mode_i,
    input  logic                               dft_cg_enable_i,
    input  logic                               bootsel_i,
    //    output logic                               dma_pe_evt_ack_o,
    //    input  logic                               dma_pe_evt_valid_i,
    //    output logic                               dma_pe_irq_ack_o,
    //    input  logic                               dma_pe_irq_valid_i,
    //    output logic                               pf_evt_ack_o,
    //    input  logic                               pf_evt_valid_i,
    ///////////////////////////////////////////////////
    //      To I/O Controller and padframe           //
    ///////////////////////////////////////////////////
    output logic [`N_IO-1:0][`NBIT_PADMUX-1:0] pad_mux_o,
    output logic [`N_IO-1:0][`NBIT_PADCFG-1:0] pad_cfg_o,

    // Signals to pad frame
    input  logic [ `N_PERIO-1:0] perio_in_i,
    output logic [ `N_PERIO-1:0] perio_out_o,
    output logic [ `N_PERIO-1:0] perio_oe_o,
    // Signals to gpio controller
    input  logic [ `N_APBIO-1:0] apbio_in_i,
    output logic [ `N_APBIO-1:0] apbio_out_o,
    output logic [ `N_APBIO-1:0] apbio_oe_o,
    // IO signals to efpga
    input  logic [`N_FPGAIO-1:0] fpgaio_in_i,
    output logic [`N_FPGAIO-1:0] fpgaio_out_o,
    output logic [`N_FPGAIO-1:0] fpgaio_oe_o,
    ///////////////////////////////////////////////////
    //      To EFPGA                                 //
    ///////////////////////////////////////////////////
    //    input  logic [          1:0] selected_mode_i,


    //eFPGA SPIS
    //    input  logic efpga_fcb_spis_rst_n_i,
    //    input  logic efpga_fcb_spis_mosi_i,
    //    input  logic efpga_fcb_spis_cs_n_i,
    //    input  logic efpga_fcb_spis_clk_i,
    //    input  logic efpga_fcb_spi_mode_en_bo_i,
    //    output logic efpga_fcb_spis_miso_en_o,
    //    output logic efpga_fcb_spis_miso_o,


    //eFPGA TEST MODE
    input        [20:0] testio_i,
    output       [15:0] testio_o,
    ///////////////////////////////////////////////////
    ///////////////////////////////////////////////////
    // From JTAG Tap Controller to axi_dcb module    //
    ///////////////////////////////////////////////////
    input  logic        jtag_tck_i,
    input  logic        jtag_trst_ni,
    input  logic        jtag_tms_i,
    input  logic        jtag_tdi_i,
    output logic        jtag_tdo_o
    //    output logic [NB_CORES-1:0] cluster_dbg_irq_valid_o
    ///////////////////////////////////////////////////
);

  localparam FLL_ADDR_WIDTH = 32;
  localparam FLL_DATA_WIDTH = 32;
  localparam NB_L2_BANKS = `NB_L2_CHANNELS;
  // The L2 parameter do not influence the size of the memories.
  // Change them in the l2_ram_multibank. This parameters
  // are only here to save area in the uDMA by only storing relevant bits.
  localparam L2_BANK_SIZE = 29184;  // in 32-bit words
  localparam L2_MEM_ADDR_WIDTH = $clog2(
      L2_BANK_SIZE * NB_L2_BANKS
  ) - $clog2(
      NB_L2_BANKS
  );  // 2**L2_MEM_ADDR_WIDTH rows (64bit each) in L2 --> TOTAL L2 SIZE = 8byte * 2^L2_MEM_ADDR_WIDTH
  localparam NB_L2_BANKS_PRI = 2;

  localparam ROM_ADDR_WIDTH = 13;

  localparam FC_CORE_CLUSTER_ID = 6'd0;
  localparam CL_CORE_CLUSTER_ID = 6'd0;

  localparam FC_CORE_CORE_ID = 4'd0;
  localparam FC_CORE_MHARTID = {FC_CORE_CLUSTER_ID, 1'b0, FC_CORE_CORE_ID};

  localparam N_EFPGA_TCDM_PORTS = `N_EFPGA_TCDM_PORTS;


  //  PULP RISC-V cores have not continguos MHARTID.
  //  This leads to set the number of HARTS >= the maximum value of the MHARTID.
  //  In this case, the MHARD ID is {FC_CORE_CLUSTER_ID,1'b0,FC_CORE_CORE_ID} --> 996 (1024 chosen as power of 2)
  //  To avoid paying 1024 flip flop for each number of harts's related register, we implemented
  //  the masking parameter, aka SELECTABLE_HARTS.
  //  In One-Hot-Encoding way, you select 1 when that MHARTID-related HART can actally be selected.
  //  e.g. if you have 2 core with MHART 10 and 5, you select NrHarts=16 and SELECTABLE_HARTS = (1<<10) | (1<<5).
  //  This mask will be used to generated only the flip flop needed and the constant-propagator engine of the synthesizer
  //  will remove the other flip flops and related logic.

  localparam NrHarts = 1;  // was 1024

  // this is a constant expression
  function logic [NrHarts-1:0] SEL_HARTS_FX();
    SEL_HARTS_FX = (1 << FC_CORE_MHARTID);
    for (int i = 0; i < NB_CORES; i++) begin
      SEL_HARTS_FX |= (1 << {CL_CORE_CLUSTER_ID, 1'b0, i[3:0]});
    end
  endfunction

  // Each hart with hartid=x sets the x'th bit in SELECTABLE_HARTS
  localparam logic [NrHarts-1:0] SELECTABLE_HARTS = SEL_HARTS_FX();

  // cluster core ids gathere as vector for convenience
  logic [NB_CORES-1:0][10:0] cluster_core_id;
  for (genvar i = 0; i < NB_CORES; i++) begin : gen_cluster_core_id
    assign cluster_core_id[i] = {CL_CORE_CLUSTER_ID, 1'b0, i[3:0]};
  end


  localparam dm::hartinfo_t RI5CY_HARTINFO = '{
       zero1:        '0,
       nscratch:      2, // Debug module needs at least two scratch regs
  zero0: '0, dataaccess: 1'b1,  // data registers are memory mapped in the debugger
  datasize: dm::DataCount, dataaddr: dm::DataAddr};

  dm::hartinfo_t [                 NrHarts-1:0      ] hartinfo;

  /*
       This module has been tested only with the default parameters.
    */

  //********************************************************
  //***************** SIGNALS DECLARATION ******************
  //********************************************************

  logic                                               s_dmactive;

  logic                                               s_stoptimer;
  logic                                               s_wd_expired;
  logic            [           1:0]                   s_fc_hwpe_events;
  logic            [          31:0]                   s_fc_events;

  logic            [           7:0]                   s_soc_events_ack;
  logic            [           7:0]                   s_soc_events_val;

  logic                                               s_timer_lo_event;
  logic                                               s_timer_hi_event;

  logic            [EVNT_WIDTH-1:0]                   s_cl_event_data;
  logic                                               s_cl_event_valid;
  logic                                               s_cl_event_ready;


  logic            [           7:0]           [31:0]  s_apb_mpu_rules;
  logic                                               s_supervisor_mode;

  logic            [          31:0]                   s_fc_bootaddr;

  logic                                               s_periph_clk;
  logic                                               s_periph_rst;
  logic                                               s_soc_clk;
  logic                                               s_soc_rstn;
  logic                                               s_rstn_glob;
  logic                                               s_sel_fll_clk;

  logic                                               s_dma_pe_evt;
  logic                                               s_dma_pe_irq;
  logic                                               s_pf_evt;

  logic                                               s_fc_fetchen;
  logic            [   NrHarts-1:0]                   dm_debug_req;

  logic                                               jtag_req_valid;
  logic                                               debug_req_ready;
  logic                                               jtag_resp_ready;
  logic                                               jtag_resp_valid;
  dm::dmi_req_t                                       jtag_dmi_req;
  dm::dmi_resp_t                                      debug_resp;
  logic slave_grant, slave_valid, dm_slave_req, dm_slave_we;
  logic [31:0] dm_slave_addr, dm_slave_wdata, dm_slave_rdata;
  logic [ 3:0] dm_slave_be;
  logic        lint_riscv_jtag_bus_master_we;

  logic        master_req;
  logic [31:0] master_add;
  logic        master_we;
  logic [31:0] master_wdata;
  logic [ 3:0] master_be;
  logic        master_gnt;
  logic        master_r_valid;
  logic [31:0] master_r_rdata;


  logic [ 7:0] soc_jtag_reg_tap;
  logic [ 7:0] soc_jtag_reg_soc;

  logic [ 4:0] s_core_irq_ack_id;
  logic        s_core_irq_ack;

  logic spi_master0_csn3, spi_master0_csn2;

  APB_BUS s_apb_debug_bus ();
  FLL_BUS #(
      .FLL_ADDR_WIDTH(FLL_ADDR_WIDTH),
      .FLL_DATA_WIDTH(FLL_DATA_WIDTH)
  ) s_soc_fll_master ();

  FLL_BUS #(
      .FLL_ADDR_WIDTH(FLL_ADDR_WIDTH),
      .FLL_DATA_WIDTH(FLL_DATA_WIDTH)
  ) s_per_fll_master ();

  FLL_BUS #(
      .FLL_ADDR_WIDTH(FLL_ADDR_WIDTH),
      .FLL_DATA_WIDTH(FLL_DATA_WIDTH)
  ) s_cluster_fll_master ();

  APB_BUS s_apb_periph_bus ();

  XBAR_TCDM_BUS s_mem_rom_bus ();

  XBAR_TCDM_BUS s_mem_l2_bus[NB_L2_BANKS-1:0] ();
  XBAR_TCDM_BUS s_mem_l2_pri_bus[NB_L2_BANKS_PRI-1:0] ();

  XBAR_TCDM_BUS s_lint_pulp_jtag_bus ();
  XBAR_TCDM_BUS s_lint_riscv_jtag_bus ();
  XBAR_TCDM_BUS s_lint_udma_tx_bus ();
  XBAR_TCDM_BUS s_lint_udma_rx_bus ();
  XBAR_TCDM_BUS s_lint_fc_data_bus ();
  XBAR_TCDM_BUS s_lint_fc_instr_bus ();
  if (NB_HWPE_PORTS > 0) begin
    XBAR_TCDM_BUS s_lint_hwpe_bus[NB_HWPE_PORTS-1:0] ();
  end
  XBAR_TCDM_BUS s_lint_efpga_bus[`N_EFPGA_TCDM_PORTS-1:0] ();
  XBAR_TCDM_BUS s_lint_efpga_apbt1_bus ();


  //********************************************************
  //********************* SOC L2 RAM ***********************
  //********************************************************

  l2_ram_multi_bank #(
      .NB_BANKS(NB_L2_BANKS)
  ) l2_ram_i (
      .clk_i        (s_soc_clk),
      .rst_ni       (s_soc_rstn),
      .init_ni      (1'b1),
      .test_mode_i  (dft_test_mode_i),
      .mem_slave    (s_mem_l2_bus),
      .mem_pri_slave(s_mem_l2_pri_bus)
  );


  //********************************************************
  //******              SOC BOOT ROM             ***********
  //********************************************************

  boot_rom #(
      .ROM_ADDR_WIDTH(ROM_ADDR_WIDTH)
  ) boot_rom_i (
      .clk_i      (s_soc_clk),
      .rst_ni     (s_soc_rstn),
      .init_ni    (1'b1),
      .mem_slave  (s_mem_rom_bus),
      .test_mode_i(dft_test_mode_i)
  );

  //********************************************************
  //********************* SOC PERIPHERALS ******************
  //********************************************************

  soc_peripherals #(
      .MEM_ADDR_WIDTH(L2_MEM_ADDR_WIDTH + $clog2(NB_L2_BANKS)),
      .APB_ADDR_WIDTH(12),
      .APB_DATA_WIDTH(32),
      .NB_CORES      (NB_CORES),
      .NB_CLUSTERS   (`NB_CLUSTERS),
      .EVNT_WIDTH    (EVNT_WIDTH)
  ) soc_peripherals_i (

      .clk_i          (s_soc_clk),
      .periph_clk_i   (s_periph_clk),
      .rst_ni         (s_soc_rstn),
      .rstpin_ni      (rstn_glob_i),
      .sel_fll_clk_i  (s_sel_fll_clk),
      .ref_clk_i      (ref_clk_i),
      .dmactive_i     (s_dmactive),
      .wd_expired_o   (s_wd_expired),
      .dft_test_mode_i(dft_test_mode_i),
      .dft_cg_enable_i(dft_cg_enable_i),

      .stoptimer_i(s_stoptimer),
      .bootsel_i(bootsel_i),
      .fc_bootaddr_o(s_fc_bootaddr),
      .fc_fetchen_o(s_fc_fetchen),

      .apb_slave(s_apb_periph_bus),
      .apb_debug_master(s_apb_debug_bus),

      .l2_rx_master(s_lint_udma_rx_bus),
      .l2_tx_master(s_lint_udma_tx_bus),

      .l2_efpga_tcdm_master(s_lint_efpga_bus),
      .efpga_apbt1_slave   (s_lint_efpga_apbt1_bus),

      .soc_jtag_reg_i(soc_jtag_reg_tap),
      .soc_jtag_reg_o(soc_jtag_reg_soc),

      .fc_hwpe_events_i (s_fc_hwpe_events),
      .fc_events_o      (s_fc_events),
      .core_irq_ack_id_i(s_core_irq_ack_id),
      .core_irq_ack_i   (s_core_irq_ack),

      .dma_pe_evt_i(s_dma_pe_evt),
      .dma_pe_irq_i(s_dma_pe_irq),
      .pf_evt_i    (s_pf_evt),

      .soc_fll_master    (s_soc_fll_master),
      .per_fll_master    (s_per_fll_master),
      .cluster_fll_master(s_cluster_fll_master),

      // pad control signals
      .pad_mux_o   (pad_mux_o),
      .pad_cfg_o   (pad_cfg_o),
      // Peripheral signals
      .perio_in_i  (perio_in_i),
      .perio_out_o (perio_out_o),
      .perio_oe_o  (perio_oe_o),
      // APBIO signals
      .apbio_in_i   (apbio_in_i),
      .apbio_out_o  (apbio_out_o),
      .apbio_oe_o   (apbio_oe_o),
      // FPGAIO signals
      .fpgaio_out_o(fpgaio_out_o),
      .fpgaio_in_i (fpgaio_in_i),
      .fpgaio_oe_o (fpgaio_oe_o),

      // other FPGA signals
      .fpga_clk_in(s_cluster_clk),


      //eFPGA TEST MODE
      .testio_i(testio_i),
      .testio_o(testio_o),
      .cl_event_data_o(s_cl_event_data),
      .cl_event_valid_o(s_cl_event_valid),
      .cl_event_ready_i(s_cl_event_ready)

  );

`ifndef PULP_FPGA_EMUL
  edge_propagator_rx ep_pf_evt_i (
      .clk_i  (s_soc_clk),
      .rstn_i (1'b0),  //s_rstn_cluster_sync_soc),
      .valid_o(s_pf_evt),
      .ack_o  (pf_evt_ack_o),
      .valid_i(pf_evt_valid_i)
  );
`endif

  fc_subsystem #(
      .USE_HWPE(USE_HWPE)
  ) fc_subsystem_i (
      .clk_i            (s_soc_clk),
      .rst_ni           (s_soc_rstn),
      .test_en_i        (dft_test_mode_i),
      .boot_addr_i      (s_fc_bootaddr),
      .fetch_en_i       (s_fc_fetchen),
      .l2_data_master   (s_lint_fc_data_bus),
      .l2_instr_master  (s_lint_fc_instr_bus),
      .debug_req_i      (dm_debug_req[FC_CORE_MHARTID]),
      .stoptimer_o      (s_stoptimer),
      .events_i         (s_fc_events),
      .core_irq_ack_id_o(s_core_irq_ack_id),
      .core_irq_ack_o   (s_core_irq_ack),

      .supervisor_mode_o(s_supervisor_mode)
  );
  assign s_soc_rstn = !(!s_rstn_glob | s_wd_expired | s_periph_rst);

  soc_clk_rst_gen i_clk_rst_gen (
      .ref_clk_i    (ref_clk_i),
      .sclk_in      (sclk_in),
      .slow_clk_o   (slow_clk_o),
      .test_clk_i   (test_clk_i),
      .sel_fll_clk_i(s_sel_fll_clk),

      .rstn_glob_i        (rstn_glob_i),
      .rstn_soc_sync_o    (s_rstn_glob),  // (s_soc_rstn),
      .rstn_cluster_sync_o(s_cluster_rstn),

      .clk_cluster_o (s_cluster_clk),
      .test_mode_i   (dft_test_mode_i),
      .shift_enable_i(1'b0),

      .soc_fll_slave_req_i   (s_soc_fll_master.req),
      .soc_fll_slave_wrn_i   (s_soc_fll_master.wrn),
      .soc_fll_slave_add_i   (s_soc_fll_master.add[4:0]),
      .soc_fll_slave_data_i  (s_soc_fll_master.data),
      .soc_fll_slave_ack_o   (s_soc_fll_master.ack),
      .soc_fll_slave_r_data_o(s_soc_fll_master.r_data),
      .soc_fll_slave_lock_o  (s_soc_fll_master.lock),

      .per_fll_slave_req_i   (s_per_fll_master.req),
      .per_fll_slave_wrn_i   (s_per_fll_master.wrn),
      .per_fll_slave_add_i   (s_per_fll_master.add[4:0]),
      .per_fll_slave_data_i  (s_per_fll_master.data),
      .per_fll_slave_ack_o   (s_per_fll_master.ack),
      .per_fll_slave_r_data_o(s_per_fll_master.r_data),
      .per_fll_slave_lock_o  (s_per_fll_master.lock),

      .cluster_fll_slave_req_i   (s_cluster_fll_master.req),
      .cluster_fll_slave_wrn_i   (s_cluster_fll_master.wrn),
      .cluster_fll_slave_add_i   (s_cluster_fll_master.add[4:0]),
      .cluster_fll_slave_data_i  (s_cluster_fll_master.data),
      .cluster_fll_slave_ack_o   (s_cluster_fll_master.ack),
      .cluster_fll_slave_r_data_o(s_cluster_fll_master.r_data),
      .cluster_fll_slave_lock_o  (s_cluster_fll_master.lock),

      .clk_soc_o(s_soc_clk),
      .clk_per_o(s_periph_clk)
  );

  soc_interconnect_wrap #(
      .NR_HWPE_PORTS(NB_HWPE_PORTS),
      .NR_L2_PORTS(NB_L2_BANKS),
      .AXI_IN_ID_WIDTH(AXI_ID_IN_WIDTH),
      .AXI_USER_WIDTH(AXI_USER_WIDTH)
  ) i_soc_interconnect_wrap (
      .clk_i                (s_soc_clk),
      .rst_ni               (s_soc_rstn),
      .test_en_i            (dft_test_mode_i),
      .tcdm_fc_data         (s_lint_fc_data_bus),
      .tcdm_fc_instr        (s_lint_fc_instr_bus),
      .tcdm_udma_rx         (s_lint_udma_rx_bus),
      .tcdm_udma_tx         (s_lint_udma_tx_bus),
      .tcdm_debug           (s_lint_riscv_jtag_bus),
      .tcdm_efpga           (s_lint_efpga_bus),
      .apb_peripheral_bus   (s_apb_periph_bus),
      .tcdm_efpga_apbt1     (s_lint_efpga_apbt1_bus),
      .l2_interleaved_slaves(s_mem_l2_bus),
      .l2_private_slaves    (s_mem_l2_pri_bus),
      .boot_rom_slave       (s_mem_rom_bus)
  );
  /* Debug Subsystem */

  dmi_jtag #(
      .IdcodeValue(`DMI_JTAG_IDCODE)
  ) i_dmi_jtag (
      .clk_i           (s_soc_clk),
      .rst_ni          (rstn_glob_i),  //(s_soc_rstn),
      .testmode_i      (1'b0),
      .dmi_req_o       (jtag_dmi_req),
      .dmi_req_valid_o (jtag_req_valid),
      .dmi_req_ready_i (debug_req_ready),
      .dmi_resp_i      (debug_resp),
      .dmi_resp_ready_o(jtag_resp_ready),
      .dmi_resp_valid_i(jtag_resp_valid),
      .dmi_rst_no      (),  // not connected
      .tck_i           (jtag_tck_i),
      .tms_i           (jtag_tms_i),
      .trst_ni         (jtag_trst_ni),
      .td_i            (jtag_tdi_i),
      .td_o            (jtag_tdo_o),
      .tdo_oe_o        ()
  );

  // set hartinfo
  always_comb begin : set_hartinfo
    for (int hartid = 0; hartid < NrHarts; hartid = hartid + 1) begin
      hartinfo[hartid] = RI5CY_HARTINFO;
    end
  end
  /*
  // redirect debug request from dm to correct cluster core
  for (genvar dbg_var = 0; dbg_var < NB_CORES; dbg_var = dbg_var + 1) begin : gen_debug_valid
    assign cluster_dbg_irq_valid_o[dbg_var] = dm_debug_req[cluster_core_id[dbg_var]];
  end
*/
  dm_top #(
      .NrHarts        (NrHarts),
      .BusWidth       (32),
      .SelectableHarts(SELECTABLE_HARTS)
  ) i_dm_top (
      .clk_i        (s_soc_clk),
      .rst_ni       (rstn_glob_i),  //(s_soc_rstn),
      .testmode_i   (1'b0),
      .ndmreset_o   (s_periph_rst),
      .dmactive_o   (s_dmactive),  // active debug session
      .debug_req_o  (dm_debug_req),
      .unavailable_i(~SELECTABLE_HARTS),
      .hartinfo_i   (hartinfo),

      .slave_req_i  (dm_slave_req),
      .slave_we_i   (dm_slave_we),
      .slave_addr_i (dm_slave_addr),
      .slave_be_i   (dm_slave_be),
      .slave_wdata_i(dm_slave_wdata),
      .slave_rdata_o(dm_slave_rdata),

      .master_req_o    (s_lint_riscv_jtag_bus.req),
      .master_add_o    (s_lint_riscv_jtag_bus.add),
      .master_we_o     (lint_riscv_jtag_bus_master_we),
      .master_wdata_o  (s_lint_riscv_jtag_bus.wdata),
      .master_be_o     (s_lint_riscv_jtag_bus.be),
      .master_gnt_i    (s_lint_riscv_jtag_bus.gnt),
      .master_r_valid_i(s_lint_riscv_jtag_bus.r_valid),
      .master_r_rdata_i(s_lint_riscv_jtag_bus.r_rdata),

      .dmi_rst_ni      (rstn_glob_i),  //(s_soc_rstn),
      .dmi_req_valid_i (jtag_req_valid),
      .dmi_req_ready_o (debug_req_ready),
      .dmi_req_i       (jtag_dmi_req),
      .dmi_resp_valid_o(jtag_resp_valid),
      .dmi_resp_ready_i(jtag_resp_ready),
      .dmi_resp_o      (debug_resp)
  );
  assign s_lint_riscv_jtag_bus.wen = ~lint_riscv_jtag_bus_master_we;

  assign soc_jtag_reg_tap = '0;
  assign s_sel_fll_clk = '1;

  apb2per #(
      .PER_ADDR_WIDTH(32),
      .APB_ADDR_WIDTH(32)
  ) apb2per_newdebug_i (
      .clk_i (s_soc_clk),
      .rst_ni(s_soc_rstn),

      .PADDR  (s_apb_debug_bus.paddr),
      .PWDATA (s_apb_debug_bus.pwdata),
      .PWRITE (s_apb_debug_bus.pwrite),
      .PSEL   (s_apb_debug_bus.psel),
      .PENABLE(s_apb_debug_bus.penable),
      .PRDATA (s_apb_debug_bus.prdata),
      .PREADY (s_apb_debug_bus.pready),
      .PSLVERR(s_apb_debug_bus.pslverr),

      .per_master_req_o    (dm_slave_req),
      .per_master_add_o    (dm_slave_addr),
      .per_master_we_o     (dm_slave_we),
      .per_master_wdata_o  (dm_slave_wdata),
      .per_master_be_o     (dm_slave_be),
      .per_master_gnt_i    (slave_grant),
      .per_master_r_valid_i(slave_valid),
      .per_master_r_opc_i  ('0),
      .per_master_r_rdata_i(dm_slave_rdata)
  );

  assign slave_grant = dm_slave_req;
  always_ff @(posedge s_soc_clk or negedge s_soc_rstn) begin : apb2per_valid
    if (~s_soc_rstn) begin
      slave_valid <= 0;
    end else begin
      slave_valid <= slave_grant;
    end
  end


endmodule
