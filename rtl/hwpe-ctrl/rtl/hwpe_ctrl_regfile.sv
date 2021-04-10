/*
 * hwpe_ctrl_regfile.sv
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

import hwpe_ctrl_package::*;

module hwpe_ctrl_regfile
#(
  parameter int unsigned N_CONTEXT      = REGFILE_N_CONTEXT,
  parameter int unsigned ID_WIDTH       = 16,
  parameter int unsigned N_IO_REGS      = 2,
  parameter int unsigned N_GENERIC_REGS = 0
)
(
  input  logic           clk_i,
  input  logic           rst_ni,
  input  logic           clear_i,
  input  regfile_in_t    regfile_in_i,
  output regfile_out_t   regfile_out_o,
  input  flags_regfile_t flags_i,
  output ctrl_regfile_t  reg_file
);

  localparam int signed RESP_ANOTHER_PE_OFFLOADING = -2;
  localparam int signed RESP_ALL_CXT_BUSY          = -1;

  localparam int unsigned LOG_CONTEXT         = $clog2(N_CONTEXT);
  localparam int unsigned N_REGISTERS         = REGFILE_N_REGISTERS;
  localparam int unsigned N_MANDATORY_REGS    = REGFILE_N_MANDATORY_REGS;
  localparam int unsigned N_RESERVED_REGS     = REGFILE_N_RESERVED_REGS;
  localparam int unsigned N_MAX_IO_REGS       = REGFILE_N_MAX_IO_REGS;
  localparam int unsigned N_MAX_GENERIC_REGS  = REGFILE_N_MAX_GENERIC_REGS;
  localparam int unsigned LOG_REGS            = $clog2(N_REGISTERS);
  localparam int unsigned LOG_REGS_MC         = LOG_REGS+LOG_CONTEXT;

  localparam int unsigned SCM_ADDR_WIDTH  = $clog2(N_CONTEXT*N_IO_REGS + N_GENERIC_REGS + N_MANDATORY_REGS - 2);
  localparam int unsigned N_SCM_REGISTERS = 2**SCM_ADDR_WIDTH;

  logic [N_CONTEXT-1:0] [N_REGISTERS-1:N_MANDATORY_REGS+N_RESERVED_REGS+N_MAX_GENERIC_REGS]  [31:0] regfile_mem;
  logic [N_MANDATORY_REGS-1:2]                                                               [31:0] regfile_mem_mandatory;
  logic [N_MANDATORY_REGS+N_RESERVED_REGS+N_GENERIC_REGS-1:N_MANDATORY_REGS+N_RESERVED_REGS] [31:0] regfile_mem_generic;
  logic                                                                                      [31:0] regfile_mem_dout;
  logic                                                                                      [31:0] regfile_out_rdata_int;
  logic                                                                                      [31:0] regfile_mem_mandatory_dout;
  logic                                                                                      [31:0] regfile_mem_generic_dout;
  logic                                                                                      [31:0] regfile_mem_io_dout;

  logic [7:0] offload_job_id;
  logic       offload_job_id_incr;
  logic [7:0] running_job_id;
  logic       running_job_id_incr;

  logic                             regfile_latch_re;
  logic [SCM_ADDR_WIDTH-1:0]        regfile_latch_rd_addr;
  logic [SCM_ADDR_WIDTH-1:0]        regfile_latch_wr_addr;
  logic [31:0]                      regfile_latch_rdata;
  logic                             regfile_latch_we;
  logic [31:0]                      regfile_latch_wdata;
  logic [3:0]                       regfile_latch_be;
  logic [N_SCM_REGISTERS-1:0][31:0] regfile_latch_mem;

  logic [1:0] r_finished_cnt;
  logic r_was_testset;
  logic r_was_mandatory;

  logic [2:0] r_first_startup;
  logic clear_first_startup;
  logic r_clear_first_startup;

  // First startup: generate a two-cycle strobe to clear the content of SCMs
  always_ff @(posedge clk_i or negedge rst_ni)
  begin
    if(~rst_ni) begin
      r_first_startup <= '0;
      r_clear_first_startup <= '0;
    end
    else begin
      r_first_startup[0] <= 1'b1;
      r_first_startup[1] <= r_first_startup[0];
      r_first_startup[2] <= r_first_startup[1];
      r_clear_first_startup <= clear_first_startup;
    end
  end
  assign clear_first_startup = |(r_first_startup[1:0]) & ~ r_first_startup[2];

  // / Register file memory write (synchronous)
  genvar i,j,k;
  generate
    logic [N_CONTEXT-1:0]                  wren_cxt;

    hwpe_ctrl_regfile_latch #(
      .ADDR_WIDTH(SCM_ADDR_WIDTH),
      .DATA_WIDTH(32)
    ) i_regfile_latch (
      .clk        ( clk_i                           ),
      .rst_n      ( rst_ni                          ),
      .clear      ( clear_i | r_clear_first_startup ),
      .ReadEnable ( regfile_latch_re                ),
      .ReadAddr   ( regfile_latch_rd_addr           ),
      .ReadData   ( regfile_latch_rdata             ),

      .WriteAddr  ( regfile_latch_wr_addr           ),
      .WriteEnable( regfile_latch_we                ),
      .WriteData  ( regfile_latch_wdata             ),
      .WriteBE    ( regfile_latch_be                ),
      .MemContent ( regfile_latch_mem               )
    );

    for(i=0; i<N_CONTEXT; i++)
    begin

      for(j=N_MANDATORY_REGS+N_RESERVED_REGS+N_MAX_GENERIC_REGS; j<N_MANDATORY_REGS+N_RESERVED_REGS+N_MAX_GENERIC_REGS+N_IO_REGS; j++) begin
        assign regfile_mem[i][j] = regfile_latch_mem[i*N_IO_REGS+j-N_RESERVED_REGS-N_MAX_GENERIC_REGS+N_GENERIC_REGS-N_MANDATORY_REGS];
      end

    end

  endgenerate

  // Register file memory read (combinational, registered in the read process) + latch binding
  generate
    always_ff @(posedge clk_i or negedge rst_ni)
    begin
      if(~rst_ni) begin
        regfile_mem_mandatory_dout <= '0;
      end
      else if(clear_i) begin
        regfile_mem_mandatory_dout <= '0;
      end
      else begin
        regfile_mem_mandatory_dout <= regfile_mem_mandatory[regfile_in_i.addr[LOG_REGS-1:0]];
      end
    end
    assign regfile_mem_dout = (~r_was_mandatory) ? regfile_latch_rdata : regfile_mem_mandatory_dout;
    assign regfile_latch_re = flags_i.is_read;
    assign regfile_latch_we = (~flags_i.is_mandatory) & regfile_in_i.wren;
    always_comb
    begin : regfile_latch_addr_proc
      if(flags_i.is_contexted == 1'b1) begin
        regfile_latch_rd_addr = regfile_in_i.addr[LOG_REGS-1:0] + regfile_in_i.addr[LOG_REGS_MC-1:LOG_REGS]*N_IO_REGS - N_RESERVED_REGS - N_MAX_GENERIC_REGS + N_GENERIC_REGS - N_MANDATORY_REGS; // one mul x const + one add + one add with const
        regfile_latch_wr_addr = regfile_in_i.addr[LOG_REGS-1:0] + regfile_in_i.addr[LOG_REGS_MC-1:LOG_REGS]*N_IO_REGS - N_RESERVED_REGS - N_MAX_GENERIC_REGS + N_GENERIC_REGS - N_MANDATORY_REGS; // one mul x const + one add + one add with const
      end
      else begin
        regfile_latch_rd_addr = regfile_in_i.addr[LOG_REGS-1:0] - N_RESERVED_REGS - N_MANDATORY_REGS;
        regfile_latch_wr_addr = regfile_in_i.addr[LOG_REGS-1:0] - N_RESERVED_REGS - N_MANDATORY_REGS;
      end
    end
    assign regfile_latch_be    = regfile_in_i.be;
    assign regfile_latch_wdata = regfile_in_i.wdata;
  endgenerate

  // Unique job id counters
  always_ff @(posedge clk_i or negedge rst_ni)
  begin
    if (rst_ni==0)
      offload_job_id <= 0;
    else if (clear_i == 1'b1)
      offload_job_id <= 0;
    else if (offload_job_id_incr==1'b1)
      offload_job_id <= offload_job_id + 1;
    else
      offload_job_id <= offload_job_id;
  end

  always_ff @(posedge clk_i or negedge rst_ni)
  begin
    if(rst_ni==1'b0)
      running_job_id_incr <= 1'b0;
    else if(clear_i == 1'b1)
      running_job_id_incr <= 1'b0;
    else
      running_job_id_incr <= flags_i.true_done;
  end

  always_ff @(posedge clk_i or negedge rst_ni)
  begin
    if (rst_ni==0)
      running_job_id <= 0;
    else if (clear_i == 1'b1)
      running_job_id <= 0;
    else if (running_job_id_incr==1'b1)
      running_job_id <= running_job_id + 1;
    else
      running_job_id <= running_job_id;
  end

  // Read register file process (mux tree with a register at the base of the trunk)
  always_ff @(posedge clk_i or negedge rst_ni)
  begin : data_r_rdata_o_proc
    if (rst_ni==0) begin
      offload_job_id_incr  <= 1'b0;
      regfile_out_rdata_int <= 0;
    end
    else if(flags_i.is_testset | flags_i.is_read == 1'b1) begin
      if (flags_i.is_testset==1) begin
        if (flags_i.is_critical==1) begin
          offload_job_id_incr   <= 1'b0;
          regfile_out_rdata_int <= RESP_ANOTHER_PE_OFFLOADING;
        end
        else if (flags_i.full_context==1) begin
          offload_job_id_incr <= 1'b0;
          regfile_out_rdata_int <= RESP_ALL_CXT_BUSY;
        end
        else begin
          offload_job_id_incr <= 1'b1;
          regfile_out_rdata_int <= { 24'b0 , offload_job_id };
        end
      end
      else begin
        offload_job_id_incr <= 1'b0;
      end
    end
    else 
      offload_job_id_incr <= 1'b0;
  end

  always_ff @(posedge clk_i or negedge rst_ni)
  begin
    if (~rst_ni) begin
      r_was_testset   <= 1'b0;
      r_was_mandatory <= 1'b0;
    end
    else if(clear_i == 1'b1) begin
      r_was_testset   <= 1'b0;
      r_was_mandatory <= 1'b0;
    end
    else begin
      r_was_testset   <= flags_i.is_testset;
      r_was_mandatory <= flags_i.is_mandatory;
    end
  end
  assign regfile_out_o.rdata = (r_was_testset) ? regfile_out_rdata_int : regfile_mem_dout;

  generate

    // Write generic registers processes
    for(i=N_MANDATORY_REGS+N_RESERVED_REGS; i<N_MANDATORY_REGS+N_RESERVED_REGS+N_GENERIC_REGS; i++) begin
      assign regfile_mem_generic[i] = regfile_latch_mem[i-N_RESERVED_REGS-N_MANDATORY_REGS];
    end

  endgenerate

  // Write mandatory registers processes
  always_ff @(posedge clk_i or negedge rst_ni)
  begin : write_mandatory_proc_word
    if (rst_ni == 0) begin
      regfile_mem_mandatory[4] <= 0;
      regfile_mem_mandatory[5] <= 0;
    end
    else if (clear_i == 1'b1) begin
      regfile_mem_mandatory[4] <= 0;
      regfile_mem_mandatory[5] <= 0;
    end
    else begin
      regfile_mem_mandatory[4] <= { 24'b0 , running_job_id };
      if(regfile_in_i.wren==1'b1 || regfile_in_i.rden==1'b1)
        regfile_mem_mandatory[5] <= regfile_in_i.addr[LOG_REGS_MC-1:LOG_REGS];
    end
  end

  assign regfile_mem_mandatory[2] = r_finished_cnt;

  logic [$clog2(ID_WIDTH)-1:0] data_src_encoded;

  always_comb
  begin : data_src_encoder
    data_src_encoded = {$clog2(ID_WIDTH){1'b0}};
    for(int i=0; i<ID_WIDTH; i++) begin
      if(regfile_in_i.src[ID_WIDTH-1:0] == (i & {$clog2(ID_WIDTH){1'b1}}))
        data_src_encoded = 1 << i;
    end
  end

  generate

    for (i=0; i<N_CONTEXT; i++)
    begin

      always_ff @(posedge clk_i or negedge rst_ni)
      begin : write_mandatory_proc_byte
        if (rst_ni == 0) begin
          regfile_mem_mandatory[3][(i+1)*8-1:i*8] <= 0;
          regfile_mem_mandatory[6][(i+1)*8-1:i*8] <= 0;
        end
        else if (clear_i==1'b1) begin
          regfile_mem_mandatory[3][(i+1)*8-1:i*8] <= 0;
          regfile_mem_mandatory[6][(i+1)*8-1:i*8] <= 0;
        end
        else if (flags_i.is_trigger | flags_i.true_done == 1'b1) begin
          if (flags_i.pointer_context==i) begin
            if (flags_i.is_trigger==1) begin
              regfile_mem_mandatory[3][(i+1)*8-1:i*8] <= 8'h01;
              regfile_mem_mandatory[6][(i+1)*8-1:i*8] <= data_src_encoded+1;
            end
            else if (flags_i.true_done==1 && flags_i.running_context==flags_i.pointer_context) begin
              regfile_mem_mandatory[3][(i+1)*8-1:i*8] <= 8'h00;
              regfile_mem_mandatory[6][(i+1)*8-1:i*8] <= regfile_mem_mandatory[6][(i+1)*8-1:i*8];
            end
          end
          else if (flags_i.running_context==i) begin
            if (flags_i.true_done==1) begin
              regfile_mem_mandatory[3][(i+1)*8-1:i*8] <= 8'h00;
              regfile_mem_mandatory[6][(i+1)*8-1:i*8] <= regfile_mem_mandatory[6][(i+1)*8-1:i*8];
            end
          end
        end
      end

    end

    if(N_CONTEXT<4) begin
      for(i=N_CONTEXT; i<4; i++) begin
         assign regfile_mem_mandatory[3][(i+1)*8-1:i*8] = 'b0;
         assign regfile_mem_mandatory[6][(i+1)*8-1:i*8] = 'b0;
      end
    end

  endgenerate

  assign reg_file.hwpe_params = regfile_mem[flags_i.running_context][N_MANDATORY_REGS+N_RESERVED_REGS+N_MAX_GENERIC_REGS+N_IO_REGS-1:N_MANDATORY_REGS+N_RESERVED_REGS+N_MAX_GENERIC_REGS];

  generate
    if(N_GENERIC_REGS>0) 
      assign reg_file.generic_params = regfile_mem_generic[N_MANDATORY_REGS+N_RESERVED_REGS+N_GENERIC_REGS-1:N_MANDATORY_REGS+N_RESERVED_REGS];
    else
      assign reg_file.generic_params = 'b0;
  endgenerate

  // finished jobs counter - mainly used by SW interrupt handler
  always_ff @(posedge clk_i or negedge rst_ni)
  begin : finished_counter
    if(~rst_ni) begin
      r_finished_cnt <= '0;
    end
    else if(clear_i==1'b1) begin
      r_finished_cnt <= '0;
    end
    else begin
      if ((flags_i.is_mandatory == 1'b1) && (regfile_in_i.addr[LOG_REGS-1:0] == 2))
        r_finished_cnt <= '0;
      else if ((flags_i.true_done == 1'b1) && (r_finished_cnt < 2))
        r_finished_cnt <= r_finished_cnt + 1;
    end
  end

endmodule
