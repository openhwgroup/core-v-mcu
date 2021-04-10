/*
 * hwpe_stream_addressgen.sv
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

import hwpe_stream_package::*;

module hwpe_stream_addressgen
#(
  parameter int unsigned REALIGN_TYPE = HWPE_STREAM_REALIGN_SOURCE,
  parameter int unsigned STEP         = 4,
  parameter int unsigned CNT          = 10, // number of bits used within the internal counter
  parameter int unsigned DELAY_FLAGS  = 0
)
(
  // global signals
  input  logic                clk_i,
  input  logic                rst_ni,
  input  logic                test_mode_i,
  // local enable and clear
  input  logic                enable_i,
  input  logic                clear_i,
  // generated output address
  output logic [31:0]         gen_addr_o,
  output logic [STEP-1:0]     gen_strb_o,
  // control channel
  input  ctrl_addressgen_t    ctrl_i,
  output flags_addressgen_t   flags_o
);

  logic        [31:0] base_addr;
  logic        [31:0] trans_size_m2;
  logic signed [15:0] line_stride;
  logic        [15:0] line_length_m1;
  logic signed [15:0] feat_stride;
  logic        [15:0] feat_length_m1;
  logic        [15:0] feat_roll_m1;

  logic        misalignment;
  logic        misalignment_first;
  logic        misalignment_last;
  logic [31:0] gen_addr_int;
  logic        enable_int;
  logic        last_packet;

  logic [15:0]    overall_counter;
  logic [CNT-1:0] word_counter;
  logic [CNT-1:0] line_counter;
  logic [CNT-1:0] feat_counter;
  logic [31:0]    word_addr;
  logic [31:0]    line_addr;
  logic [31:0]    feat_addr;

  logic [STEP-1:0] gen_strb_int;
  logic [STEP-1:0] gen_strb_r;

  flags_addressgen_t flags;

  assign base_addr      = ctrl_i.base_addr;
  assign trans_size_m2  = (misalignment == 1'b0) ? ctrl_i.trans_size - 2 :
                                                   ctrl_i.trans_size - 1;
  assign line_stride    = ctrl_i.line_stride;
  assign line_length_m1 = (misalignment == 1'b0) ? ctrl_i.line_length - 1 :
                                                   ctrl_i.line_length;
  assign feat_stride    = ctrl_i.feat_stride;
  assign feat_length_m1 = ctrl_i.feat_length - 1;
  assign feat_roll_m1   = ctrl_i.feat_roll - 1;

  generate
    if(REALIGN_TYPE == HWPE_STREAM_REALIGN_SINK) begin : last_packet_sink_gen
      assign last_packet = (misalignment==1'b1 && overall_counter == trans_size_m2) ? 1'b1 : 1'b0;
    end // last_packet_sink_gen
    else begin : last_packet_source_gen
      assign last_packet = 1'b0;
    end // last_packet_source_gen
  endgenerate

  assign enable_int = enable_i | last_packet;

  always_ff @(posedge clk_i or negedge rst_ni)
  begin
    if(~rst_ni)
      flags.realign_flags.last_packet <= '0;
    else if(clear_i)
      flags.realign_flags.last_packet <= '0;
    else if(enable_int)
      flags.realign_flags.last_packet <= (misalignment==1'b1 && overall_counter == trans_size_m2) ? 1'b1 : 1'b0;
  end

  // flags generation
  always_comb
  begin
    if(enable_int == 1'b1) begin
      if(word_counter < line_length_m1) begin
        flags.word_update = 1'b1;
        flags.line_update = 1'b0;
        flags.feat_update = 1'b0;
      end
      else if(line_counter < feat_length_m1) begin
        flags.word_update = 1'b1;
        flags.line_update = 1'b1;
        flags.feat_update = 1'b0;
      end
      else begin
        flags.word_update = 1'b1;
        flags.line_update = 1'b1;
        flags.feat_update = 1'b1;
      end
    end
    else begin
      flags.word_update = 1'b0;
      flags.line_update = 1'b0;
      flags.feat_update = 1'b0;
    end
  end

  // misalignment flags generation
  always_comb
  begin : misalignment_last_flags_comb
    if(word_counter < line_length_m1) begin
      misalignment_last  <= '0;
    end
    else begin
      misalignment_last  <= '1;
    end
  end
  always_comb
  begin : misalignment_first_flags_comb
    misalignment_first  = '0;
    if(word_counter == '0)
      misalignment_first  = '1;
  end

  // address generation
  always_ff @(posedge clk_i or negedge rst_ni)
  begin : address_gen_counters_proc
    if (rst_ni==1'b0) begin
      word_addr    <= '0;
      line_addr    <= '0;
      feat_addr    <= '0;
      word_counter    <= '0;
      line_counter    <= '0;
      feat_counter    <= '0;
      overall_counter <= '0;
    end
    else if (clear_i == 1'b1) begin
      word_addr    <= '0;
      line_addr    <= '0;
      feat_addr    <= '0;
      word_counter    <= '0;
      line_counter    <= '0;
      feat_counter    <= '0;
      overall_counter <= '0;
    end
    else begin
      if(enable_int == 1'b0) begin
        word_addr    <= word_addr;
        line_addr    <= line_addr;
        feat_addr    <= feat_addr;
        word_counter    <= word_counter;
        line_counter    <= line_counter;
        feat_counter    <= feat_counter;
        overall_counter <= overall_counter;
      end
      else begin
        if(word_counter < line_length_m1) begin
          word_addr <= word_addr + STEP;
          line_addr <= line_addr;
          feat_addr <= feat_addr;
          word_counter <= word_counter + 1;
          line_counter <= line_counter;
          feat_counter <= feat_counter;
        end
        else if(line_counter < feat_length_m1) begin
          word_addr <= '0;
          line_addr <= line_addr + {{16{line_stride[15]}}, line_stride};
          feat_addr <= feat_addr;
          word_counter <= '0;
          line_counter <= line_counter + 1;
          feat_counter <= feat_counter;
        end
        /* in outer loops, update feat_addr and reset feat_counter when feat_counter == feat_roll_m1 */
        else if((ctrl_i.loop_outer == 1'b1) && ((feat_counter == feat_roll_m1) || (ctrl_i.feat_roll == '0))) begin
          word_addr <= '0;
          line_addr <= '0;
          feat_addr <= feat_addr + {{16{feat_stride[15]}}, feat_stride};
          word_counter <= '0;
          line_counter <= '0;
          feat_counter <= '0;
        end
        /* in outer loops, update feat_counter when feat_counter != feat_roll_m1 */
        else if((ctrl_i.loop_outer == 1'b1) && ((feat_counter < feat_roll_m1) || (ctrl_i.feat_roll == '0))) begin
          word_addr <= '0;
          line_addr <= '0;
          feat_addr <= feat_addr;
          word_counter <= '0;
          line_counter <= '0;
          feat_counter <= feat_counter + 1;
        end
        /* in inner loops, update feat_addr and feat_counter when feat_counter != feat_roll_m1 */
        else if((ctrl_i.loop_outer == 1'b0) && ((feat_counter < feat_roll_m1) || (ctrl_i.feat_roll == '0))) begin
          word_addr <= '0;
          line_addr <= '0;
          feat_addr <= feat_addr + {{16{feat_stride[15]}}, feat_stride};
          word_counter <= '0;
          line_counter <= '0;
          feat_counter <= feat_counter + 1;
        end
        else begin
          word_addr <= '0;
          line_addr <= '0;
          feat_addr <= '0;
          word_counter <= '0;
          line_counter <= '0;
          feat_counter <= '0;
        end
        /* ignore one transaction for the overall counter when there is a misalignment */
        if(~misalignment | ~misalignment_first)
          overall_counter <= overall_counter + 1;
      end
    end
  end

  generate
    if(REALIGN_TYPE == HWPE_STREAM_REALIGN_SOURCE) begin
      always_ff @(posedge clk_i or negedge rst_ni)
      begin
        if (rst_ni==1'b0)
          flags.in_progress <= 1'b1;
        else if (clear_i==1'b1)
          flags.in_progress <= 1'b1;
        else
          if(trans_size_m2 == '1)
            flags.in_progress <= 1'b0;
          else if (overall_counter < trans_size_m2)
            flags.in_progress <= 1'b1;
          else if ((overall_counter == trans_size_m2) && (enable_int == 1'b0))
            flags.in_progress <= 1'b1;
          else
            flags.in_progress <= 1'b0;
      end
    end
    else begin
      always_ff @(posedge clk_i or negedge rst_ni)
      begin
        if (rst_ni==1'b0)
          flags.in_progress <= 1'b1;
        else if (clear_i==1'b1)
          flags.in_progress <= 1'b1;
        else
          if(trans_size_m2 == '1)
            flags.in_progress <= ((overall_counter == '0) ? 1'b1 : 1'b0);
          else if (overall_counter < trans_size_m2)
            flags.in_progress <= 1'b1;
          else if ((overall_counter == trans_size_m2) && (enable_int == 1'b0))
            flags.in_progress <= 1'b1;
          else
            flags.in_progress <= 1'b0;
      end
    end
  endgenerate

  assign gen_addr_int = base_addr + feat_addr + line_addr + word_addr;

  /* management of misaligned addresses */
  always_ff @(posedge clk_i or negedge rst_ni)
  begin
    if(~rst_ni)
      misalignment <= 1'b0;
    else if(clear_i)
      misalignment <= 1'b0;
    else begin
      misalignment <= (base_addr   [1:0] != '0) ? 1'b1 :
                      (line_stride [1:0] != '0) ? 1'b1 :
                      (feat_stride [1:0] != '0) ? 1'b1 : 1'b0;
    end
  end

  assign gen_addr_o = { gen_addr_int[31:2] , 2'b0 };

  assign flags.realign_flags.enable  = misalignment;
  assign flags.realign_flags.realign = misalignment;
  assign flags.realign_flags.first   = misalignment_first;
  assign flags.realign_flags.last    = misalignment_last;
  assign flags.realign_flags.line_length = ctrl_i.line_length;

  generate

    // auxiliary variable used to avoid conflicts between always_ff & assign
    flags_addressgen_t aux;

    if(REALIGN_TYPE == HWPE_STREAM_REALIGN_SOURCE) begin
      
      always_comb
      begin
        gen_strb_int = '1;
        if(misalignment) begin
          if (misalignment_first) begin
            gen_strb_int =   gen_strb_int << gen_addr_int[$clog2(STEP)-1:0];
          end
          if (misalignment_last) begin
            gen_strb_int = ~(gen_strb_int << gen_addr_int[$clog2(STEP)-1:0]);
          end
        end
      end

      assign flags_o.realign_flags = aux.realign_flags;
      assign gen_strb_o = gen_strb_r;

    end
    else begin

      logic [STEP-1:0] line_length_remainder_strb;

      for(genvar ii=0; ii<STEP; ii++) begin : line_length_remainder_strb_gen
        always_comb
        begin
          if (ctrl_i.line_length_remainder >= ii)
            line_length_remainder_strb[ii] = 1'b1;
          else
            line_length_remainder_strb[ii] = 1'b0;
        end
      end
      
      always_comb
      begin
        gen_strb_int = '1;
        if(misalignment) begin
          if (misalignment_first) begin
            gen_strb_int =   gen_strb_int << gen_addr_int[$clog2(STEP)-1:0];
          end
        end
        if (misalignment_last & (misalignment | (ctrl_i.line_length_remainder != '0))) begin
          gen_strb_int = line_length_remainder_strb;
          gen_strb_int = ~(gen_strb_int << gen_addr_int[$clog2(STEP)-1:0]);
        end
      end

      assign flags_o.realign_flags = flags.realign_flags;
      assign gen_strb_o = gen_strb_int;

    end
    assign flags_o.word_update = aux.word_update;
    assign flags_o.line_update = aux.line_update;
    assign flags_o.feat_update = aux.feat_update;
    assign flags_o.in_progress = aux.in_progress;

    if(DELAY_FLAGS) begin : delay_flags_gen
      // this is required to align the flags with the TCDM response phase
      // in some accelerators (it can be disabled, or done externally)
      always_ff @(posedge clk_i or negedge rst_ni)
      begin
        if(~rst_ni) begin
          aux <= '0;
          gen_strb_r <= '0;
        end
        else if(clear_i) begin
          aux <= '0;
          gen_strb_r <= '0;
        end
        else begin
          aux <= flags;
          gen_strb_r <= gen_strb_int;
        end
      end
    end
    else begin : no_delay_flags_gen
      assign aux = flags;
      assign gen_strb_r = gen_strb_int;
    end
  endgenerate

endmodule // hwpe_stream_addressgen
