// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


module fc_subsystem #(
    parameter USE_FPU             = 1,
    parameter USE_HWPE            = 1,
    parameter EVENT_ID_WIDTH      = 8,
    parameter PER_ID_WIDTH        = 32,
    parameter NB_HWPE_PORTS       = 4
) (
    input logic clk_i,
    input logic rst_ni,
    input logic test_en_i,

    XBAR_TCDM_BUS.Master l2_data_master,
    XBAR_TCDM_BUS.Master l2_instr_master,
    XBAR_TCDM_BUS.Master l2_hwpe_master [NB_HWPE_PORTS-1:0],
    APB_BUS.Slave        apb_slave_eu,
    APB_BUS.Slave        apb_slave_hwpe,

    input logic        fetch_en_i,
    input logic [31:0] boot_addr_i,
    input logic        debug_req_i,

    input logic event_fifo_valid_i,
    output logic event_fifo_fulln_o,
    input logic [EVENT_ID_WIDTH-1:0] event_fifo_data_i,  // goes indirectly to core interrupt
    input logic [31:0] events_i,  // goes directly to core interrupt, should be called irqs
    output logic [1:0] hwpe_events_o,
    output logic stoptimer_o,
    output logic supervisor_mode_o
);

  // Interrupt signals
  logic        core_irq_req;
  logic        core_irq_sec;
  logic [ 4:0] core_irq_id;
  logic [ 4:0] core_irq_ack_id;
  logic        core_irq_ack;
  logic [31:0] core_irq_x;
  logic [31:0] s_irq_o;


  // Boot address, core id, cluster id, fethc enable and core_status
  logic [31:0] boot_addr;
  logic        fetch_en_int;
  logic        core_busy_int;
  logic        perf_counters_int;
  logic [31:0] hart_id;

  //EU signals
  logic        core_clock_en;
  logic        fetch_en_eu;

  //Core Instr Bus
  logic [31:0] core_instr_addr, core_instr_rdata;
  logic core_instr_req, core_instr_gnt, core_instr_rvalid, core_instr_err;

  //Core Data Bus
  logic [31:0] core_data_addr, core_data_rdata, core_data_wdata;
  logic core_data_req, core_data_gnt, core_data_rvalid, core_data_err;
  logic       core_data_we;
  logic [3:0] core_data_be;
  logic is_scm_instr_req, is_scm_data_req;

  assign perf_counters_int = 1'b0;
  assign fetch_en_int = fetch_en_eu & fetch_en_i;

  assign hart_id = '0;

  XBAR_TCDM_BUS core_data_bus ();
  XBAR_TCDM_BUS core_instr_bus ();

  //********************************************************
  //************ CORE DEMUX (TCDM vs L2) *******************
  //********************************************************
  assign l2_data_master.req    = core_data_req;
  assign l2_data_master.add    = core_data_addr;
  assign l2_data_master.wen    = ~core_data_we;
  assign l2_data_master.wdata  = core_data_wdata;
  assign l2_data_master.be     = core_data_be;
  assign core_data_gnt         = l2_data_master.gnt;
  assign core_data_rvalid      = l2_data_master.r_valid;
  assign core_data_rdata       = l2_data_master.r_rdata;
  assign core_data_err         = l2_data_master.r_opc;


  assign l2_instr_master.req   = core_instr_req;
  assign l2_instr_master.add   = core_instr_addr;
  assign l2_instr_master.wen   = 1'b1;
  assign l2_instr_master.wdata = '0;
  assign l2_instr_master.be    = 4'b1111;
  assign core_instr_gnt        = l2_instr_master.gnt;
  assign core_instr_rvalid     = l2_instr_master.r_valid;
  assign core_instr_rdata      = l2_instr_master.r_rdata;
  assign core_instr_err        = l2_instr_master.r_opc;

  //********************************************************
  //************ RISCV CORE ********************************
  //********************************************************

  // OpenHW Group CV32E40P
  assign boot_addr             = boot_addr_i;

  cv32e40p_core #(
      .PULP_XPULP(1)
  ) lFC_CORE (
      .clk_i              (clk_i),
      .rst_ni             (rst_ni),
      .pulp_clock_en_i    (core_clock_en),
      .scan_cg_en_i       (test_en_i),
      .boot_addr_i        (boot_addr),
      .mtvec_addr_i       ('0),
      .dm_halt_addr_i     (32'h1A110800),
      .hart_id_i          (hart_id),
      .dm_exception_addr_i('0),

      // Instruction Memory Interface
      .instr_addr_o  (core_instr_addr),
      .instr_req_o   (core_instr_req),
      .instr_rdata_i (core_instr_rdata),
      .instr_gnt_i   (core_instr_gnt),
      .instr_rvalid_i(core_instr_rvalid),

      // Data memory interface
      .data_addr_o  (core_data_addr),
      .data_req_o   (core_data_req),
      .data_be_o    (core_data_be),
      .data_rdata_i (core_data_rdata),
      .data_we_o    (core_data_we),
      .data_gnt_i   (core_data_gnt),
      .data_wdata_o (core_data_wdata),
      .data_rvalid_i(core_data_rvalid),

      // apu-interconnect
      // handshake signals
      .apu_req_o     (),
      .apu_gnt_i     (1'b1),
      // request channel
      .apu_operands_o(),
      .apu_op_o      (),
      .apu_flags_o   (),
      // response channel
      .apu_rvalid_i  ('0),
      .apu_result_i  ('0),
      .apu_flags_i   ('0),

      .irq_i    (core_irq_x),
      .irq_ack_o(core_irq_ack),
      .irq_id_o (core_irq_ack_id),

      .debug_req_i      (debug_req_i),
      .debug_havereset_o(),
      .debug_running_o  (),
      .debug_halted_o   (stoptimer_o),
      .fetch_enable_i   (fetch_en_int),
      .core_sleep_o     ()
  );

  assign supervisor_mode_o = 1'b1;

  // Ibex and CV32E40P supports 32 additional fast interrupts and reads the interrupt lines directly.
  // Convert ID back to interrupt lines
  always_comb begin : gen_core_irq_x
    core_irq_x = '0;
    if (core_irq_req) begin
      core_irq_x[core_irq_id] = 1'b1;
    end
  end

  apb_interrupt_cntrl #(
      .PER_ID_WIDTH(PER_ID_WIDTH),
      .FIFO_PIN(11)
  ) fc_eu_i (
      .clk_i             (clk_i),
      .rst_ni            (rst_ni),
      .test_mode_i       (test_en_i),
      .events_i          (events_i),
      .event_fifo_valid_i(event_fifo_valid_i),
      .event_fifo_fulln_o(event_fifo_fulln_o),
      .event_fifo_data_i (event_fifo_data_i),
      .core_secure_mode_i(1'b0),
      .core_irq_id_o     (core_irq_id),
      .core_irq_req_o    (core_irq_req),
      .core_irq_ack_i    (core_irq_ack),
      .core_irq_id_i     (core_irq_ack_id),
      .core_irq_sec_o    (  /* SECURE IRQ */),
      .core_clock_en_o   (core_clock_en),
      .fetch_en_o        (fetch_en_eu),
      .apb_slave         (apb_slave_eu),
      .irq_o             (s_irq_o)
  );



  if (USE_HWPE) begin : fc_hwpe_gen
    fc_hwpe #(
        .N_MASTER_PORT(NB_HWPE_PORTS),
        .ID_WIDTH     (2)
    ) i_fc_hwpe (
        .clk_i            (clk_i),
        .rst_ni           (rst_ni),
        .test_mode_i      (test_en_i),
        .hwacc_xbar_master(l2_hwpe_master),
        .hwacc_cfg_slave  (apb_slave_hwpe),
        .evt_o            (hwpe_events_o),
        .busy_o           ()
    );
  end else begin : no_fc_hwpe_gen
    assign hwpe_events_o = '0;
    assign apb_slave_hwpe.prdata = '0;
    assign apb_slave_hwpe.pready = '0;
    assign apb_slave_hwpe.pslverr = '0;
    for (genvar ii = 0; ii < NB_HWPE_PORTS; ii++) begin : no_fc_hwpe_gen_loop
      assign l2_hwpe_master[ii].req   = '0;
      assign l2_hwpe_master[ii].wen   = '0;
      assign l2_hwpe_master[ii].wdata = '0;
      assign l2_hwpe_master[ii].be    = '0;
      assign l2_hwpe_master[ii].add   = '0;
    end
  end

endmodule
