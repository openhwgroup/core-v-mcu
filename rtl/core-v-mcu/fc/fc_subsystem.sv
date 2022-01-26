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

module fc_subsystem #(
    parameter USE_FPU             = 0,
    parameter USE_HWPE            = 0,
    parameter N_EXT_PERF_COUNTERS = 1,
    parameter EVENT_ID_WIDTH      = 8,
    parameter PER_ID_WIDTH        = 32,
    parameter NB_HWPE_PORTS       = 4
) (
    input logic clk_i,
    input logic rst_ni,
    input logic test_en_i,

    XBAR_TCDM_BUS.Master l2_data_master,
    XBAR_TCDM_BUS.Master l2_instr_master,

    input logic        fetch_en_i,
    input logic [31:0] boot_addr_i,
    input logic        debug_req_i,

    input  logic [31:0] events_i,  // interrupts to cpu
    output       [ 4:0] core_irq_ack_id_o,
    output              core_irq_ack_o,

    output logic stoptimer_o,
    output logic supervisor_mode_o
);

  import cv32e40p_apu_core_pkg::*;

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


  logic [                31:0]       r_int;


  // APU Core to FP Wrapper
  logic                              apu_req;
  logic [   APU_NARGS_CPU-1:0][31:0] apu_operands;
  logic [     APU_WOP_CPU-1:0]       apu_op;
  logic [APU_NDSFLAGS_CPU-1:0]       apu_flags;


  // APU FP Wrapper to Core
  logic                              apu_gnt;
  logic                              apu_rvalid;
  logic [                31:0]       apu_rdata;
  logic [APU_NUSFLAGS_CPU-1:0]       apu_rflags;

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

  logic [31:0] event_a, event_b, event_r;
  assign event_r = ~event_b & event_a;

  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (~rst_ni) begin
      r_int   <= 0;
      event_a <= 0;
      event_b <= 0;
    end else begin
      event_a <= events_i;
      event_b <= event_a;

      for (int i = 0; i < 11; i++) begin
        if (core_irq_ack_o && (core_irq_ack_id_o == i)) r_int[i] <= 0;
        else r_int[i] <= event_r[i] | r_int[i];
      end
      r_int[11] <= events_i[11];  // special case for event generator no rising edge detect
      for (int i = 12; i < 32; i++) begin
        if (core_irq_ack_o && (core_irq_ack_id_o == i)) r_int[i] <= 0;
        else r_int[i] <= event_r[i] | r_int[i];
      end
    end
  end  // always_ff @ (posedge clk_i, negedge rst_ni)



  cv32e40p_core #(
      .FPU(0),
      .NUM_MHPMCOUNTERS(1),
      .PULP_CLUSTER(0),
      .PULP_XPULP(0),
      .PULP_ZFINX(0)
  ) lFC_CORE (
      .clk_i              (clk_i),
      .rst_ni             (rst_ni),
      .pulp_clock_en_i    (1'b1),
      .scan_cg_en_i       (test_en_i),
      .boot_addr_i        (boot_addr),
      .mtvec_addr_i       ('0),
      .dm_halt_addr_i     (32'h1A110800),
      .hart_id_i          (hart_id),
      .dm_exception_addr_i(32'h1a11080c),

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
      .apu_req_o     (apu_req),
      .apu_gnt_i     (1'b0),  //(apu_gnt),
      .apu_operands_o(apu_operands),
      .apu_op_o      (apu_op),
      .apu_flags_o   (apu_flags),
      .apu_rvalid_i  (1'b0),  // (apu_rvalid),
      .apu_result_i  (32'b0),  //(apu_rdata),
      .apu_flags_i   ('0),  //(apu_rflags),


      .irq_i    (r_int),
      .irq_ack_o(core_irq_ack_o),
      .irq_id_o (core_irq_ack_id_o),

      .debug_req_i      (debug_req_i),
      .debug_havereset_o(),
      .debug_running_o  (),
      .debug_halted_o   (stoptimer_o),
      .fetch_enable_i   (fetch_en_i),
      .core_sleep_o     ()
  );
  assign supervisor_mode_o = 1'b1;
  /*
  cv32e40p_fp_wrapper fp_wrapper_i (
      .clk_i         (clk_i),
      .rst_ni        (rst_ni),
      .apu_req_i     (apu_req),
      .apu_gnt_o     (apu_gnt),
      .apu_operands_i(apu_operands),
      .apu_op_i      (apu_op),
      .apu_flags_i   (apu_flags),
      .apu_rvalid_o  (apu_rvalid),
      .apu_rdata_o   (apu_rdata),
      .apu_rflags_o  (apu_rflags)
  );
*/
endmodule
