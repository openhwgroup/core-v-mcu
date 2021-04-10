/*
 * hwpe_stream_source_realign.sv
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

module hwpe_stream_source_realign #(
  parameter int unsigned DECOUPLED  = 0, // set to 1 if used with a TCDM stream that does not respect the zero-latency assumption,
                                         // e.g. it passes through a TCDM load FIFO.
  parameter int unsigned DATA_WIDTH = 32
)
(
  input  logic                    clk_i,
  input  logic                    rst_ni,
  input  logic                    test_mode_i,
  input  logic                    clear_i,

  input  ctrl_realign_t           ctrl_i,
  
  input  logic [DATA_WIDTH/8-1:0] strb_i, 
  hwpe_stream_intf_stream.sink    stream_i,
  hwpe_stream_intf_stream.source  stream_o
);

  logic [DATA_WIDTH/8-1:0] strb_last_r, strb_first_r, int_strb;

  logic unsigned [$clog2(DATA_WIDTH/8):0] strb_rotate_d;
  logic unsigned [$clog2(DATA_WIDTH/8):0] strb_rotate_inv_d;
  logic [DATA_WIDTH-1:0]   stream_data_q;
  logic unsigned [$clog2(DATA_WIDTH/8):0] strb_rotate_q;
  logic unsigned [$clog2(DATA_WIDTH/8):0] strb_rotate_inv_q;

  logic unsigned [$clog2(DATA_WIDTH/8)+3:0] strb_rotate_q_shifted;
  logic unsigned [$clog2(DATA_WIDTH/8)+3:0] strb_rotate_inv_q_shifted;

  logic clk_gated;

  logic int_first;
  logic int_last;
  logic int_last_packet;

  /* clock gating */
  cluster_clock_gating i_realign_gating (
    .clk_i     ( clk_i         ),
    .test_en_i ( test_mode_i   ),
    .en_i      ( ctrl_i.enable ),
    .clk_o     ( clk_gated     )
  );

  /* management of misaligned access */

  // since the source address generation could be decoupled from the received stream
  // (e.g. in case the load TCDM passes through FIFOs)
  generate
    if(DECOUPLED) begin : decoupled_flags_gen

      logic [15:0] word_cnt, next_word_cnt;
      logic [15:0] line_length_m1;
      logic r_last_packet;

      assign line_length_m1 = (ctrl_i.realign == 1'b0) ? ctrl_i.line_length - 1 :
                                                         ctrl_i.line_length;                                        

      always_comb
      begin
        next_word_cnt = word_cnt;
        if(stream_i.valid & stream_i.ready) begin
          next_word_cnt = word_cnt + 1;
        end
        if((stream_i.valid & stream_i.ready) && word_cnt == line_length_m1) begin
          next_word_cnt = '0;
        end
      end

      always_ff @(posedge clk_i or negedge rst_ni)
      begin
        if(~rst_ni) begin
          word_cnt <= '0;
        end
        else if(clear_i) begin
          word_cnt <= '0;
        end
        else begin
          word_cnt <= next_word_cnt;
        end
      end

      // misalignment flags generation
      always_comb
      begin : int_last_comb
        if(word_cnt < line_length_m1) begin
          int_last <= '0;
        end
        else begin
          int_last <= '1;
        end
      end
      always_comb
      begin : int_first_comb
        int_first  = '0;
        if(word_cnt == '0)
          int_first = '1;
      end
      always_ff @(posedge clk_i or negedge rst_ni)
      begin : int_last_packet_seq
        if(~rst_ni)
          r_last_packet <= '0;
        else if (clear_i)
          r_last_packet <= '0;
        else begin
          if (ctrl_i.last_packet)
            r_last_packet <= 1'b1;
          else if (r_last_packet & int_last & stream_o.valid & stream_o.ready)
            r_last_packet <= 1'b0;
        end
      end
      assign int_last_packet = int_last & r_last_packet;

      // record strobe and release it when appropriate
      always_ff @(posedge clk_i or negedge rst_ni)
      begin
        if(~rst_ni) begin
          strb_first_r <= '1;
          strb_last_r  <= '1;
        end
        else if(clear_i) begin
          strb_first_r <= '1;
          strb_last_r  <= '1;
        end
        else begin
          if(ctrl_i.first)
            strb_first_r <= strb_i;
          if(ctrl_i.last)
            strb_last_r  <= strb_i;
        end
      end
      assign int_strb = int_first ? (ctrl_i.first ? strb_i : strb_first_r) :
                        int_last  ? (ctrl_i.last  ? strb_i : strb_last_r) : '1;

    end
    else begin : no_decoupled_flags_gen

      assign int_first = ctrl_i.first;
      assign int_last  = ctrl_i.last;
      assign int_strb = strb_i;
      
    end
  endgenerate

  // save the strobes of the first misaligned transfer as a reference!
  // this implicitly assumes that all strobes result in a rotation - it
  // must be thus!!
  always_comb
  begin
    strb_rotate_d = '0;
    for (int i=0; i<DATA_WIDTH/8; i++)
      strb_rotate_d += ($clog2(DATA_WIDTH/8))'(int_strb[i]);
  end
  assign strb_rotate_inv_d = {($clog2(DATA_WIDTH/8)){1'b1}} - strb_rotate_d + 1;;

  always_ff @(posedge clk_gated or negedge rst_ni)
  begin
    if(~rst_ni) begin
      strb_rotate_q <= '0;
      strb_rotate_inv_q <= '0;
    end
    else if (clear_i) begin
      strb_rotate_q <= '0;
      strb_rotate_inv_q <= '0;
    end
    else if (~int_last_packet & int_first) begin
      strb_rotate_q <= strb_rotate_d;
      strb_rotate_inv_q <= strb_rotate_inv_d;
    end
  end
  assign strb_rotate_q_shifted = strb_rotate_q << 3;
  assign strb_rotate_inv_q_shifted = strb_rotate_inv_q << 3;

  always_ff @(posedge clk_gated or negedge rst_ni)
  begin
    if(~rst_ni)
      stream_data_q <= '0;
    else if (clear_i)
      stream_data_q <= '0;
    // last packet is kept "forever"
    else if (~int_last_packet & stream_i.valid & stream_i.ready)
      stream_data_q <= stream_i.data;
  end
  always_comb
  begin
    stream_o.data = stream_i.data;
    if(ctrl_i.realign) begin
      if ((strb_rotate_q != '1) && (strb_rotate_q != '0))
        stream_o.data = stream_i.data << strb_rotate_q_shifted | stream_data_q >> strb_rotate_inv_q_shifted;
    end
  end
  assign stream_o.valid = (~ctrl_i.realign) ? stream_i.valid :
                          (int_last_packet) ? stream_i.valid :
                                              stream_i.valid & ~int_first & (int_last | (|int_strb));
  assign stream_i.ready = (~ctrl_i.realign) ? stream_o.ready :
                          (int_last_packet) ? stream_o.ready :
                                              stream_o.ready | int_first;

  assign stream_o.strb = '1;

endmodule // hwpe_stream_source_realign
