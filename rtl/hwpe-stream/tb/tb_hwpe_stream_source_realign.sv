/* 
 * tb_hwpe_stream_source_realign.sv
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
 * This is a unit test for the hwpe stream sink realign module
 */

timeunit 1ns;
timeprecision 1ps;

import hwpe_stream_package::*;

module tb_hwpe_stream_source_realign;

  // parameters
  parameter PROB_STALL = 0.2;
  parameter DS = 16;

  // global signals
  logic clk_i  = '0;
  logic rst_ni = '1;
  logic test_mode_i = '0;

  logic randomize = '0;
  logic enable = '0;
  logic enable_reservoir = '0;
  ctrl_realign_t ctrl;
  logic [DS/8-1:0] strb;
  logic force_invalid;
  logic force_valid;
  logic real_last;

  int unsigned rotation = 0;
  logic new_rotation;
  int unsigned verif_ctr_in;
  int unsigned verif_ctr_out;
  logic [DS*DS-1:0] verif_vector_in;
  logic [DS*DS-1:0] verif_vector_out;
  logic [DS*DS-1:0] gold_vector_in;
  logic [DS*DS-1:0] next_verif_vector_in;
  logic [DS*DS-1:0] gold_vector_out;
  logic [DS*DS-1:0] next_verif_vector_out;
  logic gold_valid_in;
  logic gold_valid_out;

  hwpe_stream_intf_stream #(
    .DATA_WIDTH(DS)
  ) in (
    .clk ( clk_i )
  );
  hwpe_stream_intf_stream #(
    .DATA_WIDTH(DS)
  ) out (
    .clk ( clk_i )
  );

  // ATI timing parameters.
  localparam TCP = 1.0ns; // clock period, 1 GHz clock
  localparam TA  = 0.1ns; // application time
  localparam TT  = 0.9ns; // test time

  // Performs one entire clock cycle.
  task cycle;
    clk_i <= #(TCP/2) 0;
    clk_i <= #TCP 1;
    #TCP;
  endtask

  // The following task schedules the clock edges for the next cycle and
  // advances the simulation time to that cycles test time (localparam TT)
  // according to ATI timings.
  task cycle_start;
    clk_i <= #(TCP/2) 0;
    clk_i <= #TCP 1;
    #TT;
  endtask

  // The following task finishes a clock cycle previously started with
  // cycle_start by advancing the simulation time to the end of the cycle.
  task cycle_end;
    #(TCP-TT);
  endtask

  tb_hwpe_stream_reservoir #(
    .REALIGN_TYPE ( HWPE_STREAM_REALIGN_SOURCE ),
    .DATA_WIDTH   ( DS                         ),
    .PROB_STALL   ( PROB_STALL                 ),
    .TCP          ( TCP                        ),
    .TA           ( TA                         ),
    .TT           ( TT                         )
  ) i_reservoir (
    .clk_i           ( clk_i                                                   ),
    .randomize_i     ( randomize                                               ),
    .rotation_i      ( rotation                                                ),
    .new_rotation_i  ( new_rotation                                            ),
    .force_invalid_i ( force_invalid                                           ),
    .force_valid_i   ( force_valid                                             ),
    .enable_i        ( enable & (enable_reservoir | ctrl.realign) & ~real_last ),
    .data_o          ( in                                                      )
  );

  hwpe_stream_source_realign #(
    .DATA_WIDTH ( DS )
  ) i_source_realign (
    .clk_i       ( clk_i   ),
    .rst_ni      ( rst_ni  ),
    .clear_i     ( 1'b0    ),
    .test_mode_i ( 1'b0    ),
    .ctrl_i      ( ctrl    ),
    .strb_i      ( in.strb ),
    .stream_i    ( in      ),
    .stream_o    ( out     )
  );

  tb_hwpe_stream_receiver #(
    .DATA_WIDTH ( DS         ),
    .PROB_STALL ( PROB_STALL ),
    .TCP        ( TCP        ),
    .TA         ( TA         ),
    .TT         ( TT         )
  ) i_receiver (
    .clk_i         ( clk_i  ),
    .force_ready_i ( 1'b1   ),
    .enable_i      ( enable ),
    .data_i        ( out    )
  );

  initial begin
    #(20*TCP);

    // Reset phase.
    rst_ni <= #TA 1'b0;
    #(20*TCP);
    rst_ni <= #TA 1'b1;

    for (int i = 0; i < 10; i++)
      cycle();
    rst_ni <= #TA 1'b0;
    for (int i = 0; i < 10; i++)
      cycle();
    rst_ni <= #TA 1'b1;

    randomize <= #TA 1'b1;
    cycle();
    randomize <= #TA 1'b0;

    cycle();
    cycle();
    enable <= 1'b1;

    while(1) begin
      cycle();
    end

  end

  int counter = 0;
  int unsigned length   = 1;

  always
  begin
    ctrl.enable      <= #TA '1;
    ctrl.realign     <= #TA '0;
    ctrl.first       <= #TA '0;
    ctrl.last        <= #TA '0;
    // real_last        <= #TA '0;
    ctrl.last_packet <= #TA '0;
    force_invalid    <= #TA '0;
    force_valid      <= #TA '0;
    new_rotation     <= #TA '0;
    if(enable) begin
      if(counter == 0) begin
        rotation = $urandom_range(0, DS/8-1);
        length   = $urandom_range(2, DS);
        force_invalid <= #TA 1'b1;
        #(TCP*2)
        enable_reservoir <= #TA 1'b1;
        force_invalid <= #TA 1'b0;
        // the first transaction is always valid in this tb!
        force_valid   <= #TA 1'b1;
        new_rotation  <= #TA 1'b1;
        #(TCP);
        force_valid <= #TA 1'b0;
        new_rotation <= #TA 1'b0;
        ctrl.first  <= #TA 1'b1;
        if(rotation != 0) begin
          ctrl.realign <= #TA 1'b1;
        end
        counter += 1;
      end
      else if(counter < length-1) begin
        if(rotation != 0)
          ctrl.realign <= #TA 1'b1;
        if(out.valid & out.ready)
          counter += 1;
      end
      else if(counter == length-1) begin
        if(rotation != 0)
          ctrl.realign <= #TA 1'b1;
        if(out.valid & out.ready)
          counter += 1;
        force_valid <= #TA 1'b1;
      end
      else if(counter == length) begin
        if(rotation != 0)
          ctrl.realign <= #TA 1'b1;
        ctrl.last   <= #TA 1'b1;
        if(out.valid & out.ready) begin
          // real_last <= #TA 1'b1;
          counter += 1;
          force_invalid <= #TA 1'b1;
        end
      end
      else begin
        ctrl.realign <= #TA 1'b0;
        counter = 0;
        force_invalid <= #TA 1'b1;
      end
    end
    #(TCP);
  end
  assign real_last = ctrl.last; // & out.valid & out.ready;

  int unsigned strb_popcount;
  always_comb
  begin
    strb_popcount = 0;
    for(int i=0; i<DS/8; i++)
      strb_popcount += (in.strb[i] == 1'b1) ? 1 : 0;
  end

  logic [DS/8-1:0] save_strb;
  always_ff @(posedge clk_i)
  begin
    if(~enable) begin
      save_strb <= '0;
    end
    else if(in.valid & in.ready) begin
      if(ctrl.first) begin
        save_strb <= ~in.strb;
      end
    end
  end

  always_comb
  begin
    next_verif_vector_in = verif_vector_in;
    if(ctrl.first & ctrl.realign) begin
      for(int i=0; i<DS*DS; i++)
        if ((i>=0) && (i<strb_popcount*8))
          next_verif_vector_in[i] = in.data[strb_popcount*8+i] & in.strb[(strb_popcount*8+i)/8];
    end
    else if(ctrl.last & ctrl.realign) begin
      for(int i=0; i<DS*DS; i++)
        if ((i>=verif_ctr_in) && (i<verif_ctr_in+DS))
          next_verif_vector_in[i] = in.data[i-verif_ctr_in] & save_strb[(i-verif_ctr_in)/8];
    end
    else begin
      for(int i=0; i<DS*DS; i++)
        if ((i>=verif_ctr_in) && (i<verif_ctr_in+DS))
          next_verif_vector_in[i] = in.data[i-verif_ctr_in] & in.strb[(i-verif_ctr_in)/8];
    end
  end
  always_ff @(posedge clk_i)
  begin
    if(~enable | real_last) begin
      verif_vector_in <= '0;
      verif_ctr_in <= 0;
    end
    else if(in.valid & in.ready) begin
      if(ctrl.first) begin
        verif_ctr_in <= verif_ctr_in + strb_popcount*8;
        verif_vector_in <= next_verif_vector_in;
      end
      else if(real_last) begin
        verif_ctr_in <= 0;
        verif_vector_in <= '0;
      end
      else begin
        verif_ctr_in <= verif_ctr_in + DS;
        verif_vector_in <= next_verif_vector_in;
      end
    end
  end

  always_comb
  begin
    next_verif_vector_out = verif_vector_out;
    for(int i=0; i<DS*DS; i++)
      if ((i>=verif_ctr_out) && (i<verif_ctr_out+DS))
        next_verif_vector_out[i] = out.data[i-verif_ctr_out];
  end
  always_ff @(posedge clk_i)
  begin
    if(~enable) begin
      verif_vector_out <= '0;
      verif_ctr_out <= 0;
    end
    else if(real_last) begin
      verif_ctr_out <= 0;
      verif_vector_out <= '0;
    end
    else if(out.valid & out.ready) begin
      verif_ctr_out <= verif_ctr_out + DS;
      verif_vector_out <= next_verif_vector_out;
    end
  end

  always_ff @(posedge clk_i)
  begin
    if(gold_valid_out & gold_valid_in) begin
      gold_valid_out <= 1'b0;
      gold_valid_in  <= 1'b0;
    end
    else begin
      if(real_last) begin
        gold_vector_out <= next_verif_vector_out;
        gold_valid_out  <= 1'b1;
        gold_vector_in <= next_verif_vector_in;
        gold_valid_in  <= 1'b1;
      end
    end
  end

  assert property (@(posedge clk_i) (gold_valid_in & gold_valid_out) |-> (gold_vector_in == gold_vector_out))
    else $warning("Wrong realignment!!!");

endmodule
