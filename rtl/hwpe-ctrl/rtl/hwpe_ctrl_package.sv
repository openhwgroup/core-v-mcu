/*
 * hwpe_ctrl_package.sv
 * Francesco Conti <f.conti@unibo.it>
 *
 * Copyright (C) 2014-2018 ETH Zurich, University of Bologna
 * Copyright and related rights are licensed under the Solderpad Hardware
 * License, Version 0.51 (the "License"); you may not use this file except in
 * compliance with the License.  You may obtain a copy of the License at
 * http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
 * or agreed to in writing, software, hardware and materials distributed under
 * this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 */

package hwpe_ctrl_package;

  parameter int unsigned REGFILE_N_CORES            = 8;
  parameter int unsigned REGFILE_N_CONTEXT          = 2;
  parameter int unsigned REGFILE_N_EVT              = 2;
  parameter int unsigned REGFILE_N_REGISTERS        = 64;
  parameter int unsigned REGFILE_N_MANDATORY_REGS   = 7;
  parameter int unsigned REGFILE_N_MAX_IO_REGS      = 48;
  parameter int unsigned REGFILE_N_MAX_GENERIC_REGS = 8;
  parameter int unsigned REGFILE_N_RESERVED_REGS    = REGFILE_N_REGISTERS-REGFILE_N_MANDATORY_REGS-REGFILE_N_MAX_GENERIC_REGS-REGFILE_N_MAX_IO_REGS;

  parameter int unsigned UCODE_NB_LOOPS  = 6;
  parameter int unsigned UCODE_LENGTH    = 16;
  parameter int unsigned UCODE_NB_REG    = 4;
  parameter int unsigned UCODE_NB_RO_REG = 28;
  parameter int unsigned UCODE_REG_WIDTH = 32;
  parameter int unsigned UCODE_CNT_WIDTH = 12;

  typedef struct packed {
    logic [REGFILE_N_MAX_IO_REGS-1:0]     [31:0] hwpe_params;
    logic [REGFILE_N_MAX_GENERIC_REGS-1:0][31:0] generic_params;
  } ctrl_regfile_t;

  typedef struct packed {
    logic [31:0] addr;
    logic        rden;
    logic        wren;
    logic [31:0] wdata;
    logic [31:0] src;
    logic [3:0]  be;
  } regfile_in_t;

  typedef struct packed {
    logic [31:0] rdata;
  } regfile_out_t;

  typedef struct packed {
    logic                                 true_done;
    logic                                 full_context;
    logic                                 is_mandatory;
    logic                                 is_read;
    logic                                 is_contexted;
    logic                                 is_critical;
    logic                                 is_testset;
    logic                                 is_trigger;
    logic                                 is_working;
    logic [$clog2(REGFILE_N_CONTEXT)-1:0] pointer_context;
    logic [$clog2(REGFILE_N_CONTEXT)-1:0] running_context;
  } flags_regfile_t;

  typedef struct packed {
    logic                     done;
    logic [REGFILE_N_EVT-2:0] evt;
  } ctrl_slave_t;

  typedef struct packed {
    logic                                          start;
    logic [REGFILE_N_CORES-1:0][REGFILE_N_EVT-1:0] evt;
    logic                                          done;
    logic                                          is_working;
    logic                                          enable;
  } flags_slave_t;

  typedef struct packed {
    logic enable;
    logic clear;
    logic [$clog2(UCODE_NB_LOOPS)-1:0] accum_loop;
  } ctrl_ucode_t;

  typedef struct packed {
    logic                                           done;
    logic                                           valid;
    logic [UCODE_NB_REG-1:0]  [31:0]                offs;
    logic [UCODE_NB_LOOPS-1:0][UCODE_CNT_WIDTH-1:0] idx;
    logic                                           accum;
  } flags_ucode_t;

  typedef struct packed {
    logic [4:0] ucode_addr;
    logic [2:0] nb_ops;
  } ucode_loops_t;

  typedef struct packed {
    logic       op_sel;
    logic [4:0] a;
    logic [4:0] b;
  } ucode_code_t;

  typedef struct packed {
    ucode_loops_t [UCODE_NB_LOOPS-1:0]                      loops;
    ucode_code_t  [UCODE_LENGTH-1:0]                        code;
    logic         [UCODE_NB_LOOPS-1:0][UCODE_CNT_WIDTH-1:0] range;
  } ucode_t;

endpackage // hwpe_ctrl_package
