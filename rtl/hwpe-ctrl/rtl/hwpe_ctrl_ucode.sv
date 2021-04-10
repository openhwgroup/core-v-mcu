/* 
 * hwpe_ctrl_ucode.sv
 * Francesco Conti <fconti@iis.ee.ethz.ch>
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
 *
 * This module implements a very simple microcode processor that can be used to
 * compute updated base indeces for the streamers.
 * It can directly operate on NB_REG registers and read NB_RO_REG other
 * ones.
 */

import hwpe_ctrl_package::*;

module hwpe_ctrl_ucode
#(
  parameter int unsigned LENGTH    = UCODE_NB_LOOPS,
  parameter int unsigned NB_LOOPS  = UCODE_LENGTH,
  parameter int unsigned NB_RO_REG = UCODE_NB_RO_REG,
  parameter int unsigned NB_REG    = UCODE_NB_REG,
  parameter int unsigned REG_WIDTH = UCODE_REG_WIDTH,
  parameter int unsigned CNT_WIDTH = UCODE_CNT_WIDTH
)
(
  // global signals
  input  logic                                clk_i,
  input  logic                                rst_ni,
  input  logic                                test_mode_i,
  input  logic                                clear_i,
  // ctrl & flags
  input  ctrl_ucode_t                         ctrl_i,
  output flags_ucode_t                        flags_o,
  input  ucode_t                              ucode_i,
  input  logic [NB_RO_REG-1:0][REG_WIDTH-1:0] registers_read_i
);

  logic [2:0]                         curr_op,   next_op;
  logic [$clog2(LENGTH)-1:0]          curr_addr, next_addr;
  logic [$clog2(NB_LOOPS)-1:0]        curr_loop, next_loop;
  logic [NB_LOOPS-1:0][CNT_WIDTH-1:0] curr_idx,  next_idx;

  logic [NB_REG-1:0]          [REG_WIDTH-1:0] registers, next_registers;
  logic [NB_RO_REG+NB_REG-1:0][REG_WIDTH-1:0] registers_read;

  logic [REG_WIDTH-1:0] ucode_execute_add;
  logic [REG_WIDTH-1:0] ucode_execute;

  logic busy_int, busy_sticky;
  logic accum_int;
  enum { ACCUM_IDLE, ACCUM_ACTIVE, ACCUM_VALID } curr_accum_state, next_accum_state;
  logic done_int, done_sticky;
  logic exec_int;

  always_ff @(posedge clk_i or negedge rst_ni)
  begin
    if(~rst_ni) begin
      busy_sticky <= '0;
      done_sticky <= '0;
      flags_o.valid <= '0;
    end
    else if(clear_i | ctrl_i.clear) begin
      busy_sticky <= '0;
      done_sticky <= '0;
      flags_o.valid <= '0;
    end
    else begin
      flags_o.valid <= busy_sticky & ~busy_int;
      if(~busy_int)
        busy_sticky <= 1'b0;
      else if(ctrl_i.enable)
        busy_sticky <= 1'b1;
      if(done_int)
        done_sticky <= 1'b1;
      else if(flags_o.valid)
        done_sticky <= 1'b0;
    end
  end

  assign flags_o.done = done_int | done_sticky;

  assign accum_int = (curr_loop == ctrl_i.accum_loop) ? 1'b1 : 1'b0;

  always_ff @(posedge clk_i or negedge rst_ni)
  begin : accum_flag_fsm_seq
    if(~rst_ni)
      curr_accum_state <= ACCUM_IDLE;
    else if(clear_i | ctrl_i.clear)
      curr_accum_state <= ACCUM_IDLE;
    else
      curr_accum_state <= next_accum_state;
  end

  always_comb
  begin : accum_flag_fsm_comb
    next_accum_state = curr_accum_state;
    case(curr_accum_state)
      ACCUM_IDLE : begin
        if(accum_int)
          next_accum_state = ACCUM_ACTIVE;
      end // ACCUM_IDLE
      ACCUM_ACTIVE : begin
        if(flags_o.valid)
          next_accum_state = ACCUM_VALID;
      end // ACCUM_ACTIVE
      ACCUM_VALID : begin
        if(accum_int & flags_o.valid)
          next_accum_state = ACCUM_VALID;
        else if(accum_int)
          next_accum_state = ACCUM_ACTIVE;
        else if(flags_o.valid)
          next_accum_state = ACCUM_IDLE;
      end // ACCUM_VALID
    endcase // curr_accum_state    
  end

  assign flags_o.accum = (next_accum_state == ACCUM_IDLE)   ? 1'b0 : 1'b1;

`ifndef SYNTHESIS
  string str = "";

  always_ff @(posedge clk_i or negedge rst_ni)
  begin
    if(rst_ni) begin
      if(ctrl_i.enable)
        $display("@%d [%d, %d, %d, %d, %d, %d]%s", curr_addr, curr_idx[5], curr_idx[4], curr_idx[3], curr_idx[2], curr_idx[1], curr_idx[0], str);
    end
  end

`endif

  always_comb
  begin : ucode_fetch_comb
    next_addr = curr_addr;
    next_loop = curr_loop;
    next_op   = curr_op;
    next_idx  = curr_idx;
    done_int  = 1'b0;
    busy_int  = 1'b0;
    exec_int  = 1'b0;

    // if next operation is within the current loop, update address
    if((curr_idx[curr_loop] < ucode_i.range[curr_loop] - 1) && (curr_op < ucode_i.loops[curr_loop].nb_ops - 1)) begin
`ifndef SYNTHESIS
      str = " UPDATE CURRENT LOOP                      ";
`endif
      next_addr = curr_addr + 1;
      next_op   = curr_op + 1;
      busy_int  = 1'b1;
      exec_int  = 1'b1;
    end
    // if loop > 0, go to loop 0
    else if((curr_idx[curr_loop] < ucode_i.range[curr_loop] - 1) && (curr_loop > 0)) begin
`ifndef SYNTHESIS
      str = " ITERATE CURRENT LOOP & GOTO LOOP 0       ";
`endif
      next_loop = 0;
      for(int j=0; j<NB_LOOPS; j++) begin
        if(curr_loop > j)
          next_idx[j] = 0;
        else if(curr_loop == j)
          next_idx[j] = curr_idx[curr_loop] + 1;
      end
      next_addr = ucode_i.loops[0].ucode_addr;
      next_op   = '0;
      exec_int  = 1'b1;
    end
    // if we are still within the current loop range, go back to start loop address
    else if(curr_idx[curr_loop] < ucode_i.range[curr_loop] - 1) begin
`ifndef SYNTHESIS
      str = " ITERATE CURRENT LOOP                     ";
`endif
      next_addr = ucode_i.loops[curr_loop].ucode_addr;
      next_op   = '0;
      next_idx[curr_loop] = curr_idx + 1;
      exec_int  = 1'b1;
    end
    // if not, go to next loop
    else if (curr_loop < NB_LOOPS-1) begin
`ifndef SYNTHESIS
      str = " GOTO NEXT LOOP                           ";
`endif
      next_loop = curr_loop + 1;
      next_addr = ucode_i.loops[curr_loop+1].ucode_addr;
      next_op   = '0;
    end
    // end of the loops
    else begin
`ifndef SYNTHESIS
      str = " TERMINATE                                ";
`endif
      next_loop = '0;
      next_addr = '0;
      next_op   = '0;
      next_idx  = '0;
      done_int  = 1'b1;
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni)
  begin : ucode_fetch_seq
    if(~rst_ni) begin
      curr_addr <= '0;
      curr_loop <= '0;
      curr_op   <= '0;
      curr_idx  <= '0;
    end
    else if(clear_i | ctrl_i.clear) begin
      curr_addr <= '0;
      curr_loop <= '0;
      curr_op   <= '0;
      curr_idx  <= '0;
    end
    else if(ctrl_i.enable) begin
      curr_addr <= next_addr;
      curr_loop <= next_loop;
      curr_op   <= next_op;
      curr_idx  <= next_idx;
    end
  end

  assign registers_read[NB_REG-1:0] = registers;
  assign registers_read[NB_RO_REG+NB_REG-1:NB_REG] = registers_read_i;

  assign ucode_execute_add = registers_read[ucode_i.code[curr_addr].a] + registers_read[ucode_i.code[curr_addr].b];
  assign ucode_execute = (ucode_i.code[curr_addr].op_sel) ? ucode_execute_add : registers_read[ucode_i.code[curr_addr].b];

  always_comb
  begin : ucode_execute_comb
    next_registers = registers;
    if(exec_int)
      next_registers[ucode_i.code[curr_addr].a] = ucode_execute;
  end

  always_ff @(posedge clk_i or negedge rst_ni)
  begin : ucode_execute_sel
    if(~rst_ni) begin
      registers <= '0;
    end
    else if(clear_i | ctrl_i.clear) begin
      registers <= '0;
    end
    else if(ctrl_i.enable) begin
      registers <= next_registers;
    end
  end

  generate
    
    for(genvar i=0; i<NB_REG; i++) begin : flags_reg_assign
      assign flags_o.offs[i] = registers[i];
    end
    for(genvar i=0; i<NB_LOOPS; i++) begin : flags_idx_assign
      assign flags_o.idx [i] = curr_idx[i];
    end

  endgenerate

endmodule // hwpe_ctrl_ucode
