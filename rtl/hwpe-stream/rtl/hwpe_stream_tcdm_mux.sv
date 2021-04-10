/* 
 * hwpe_stream_tcdm_mux.sv
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
 *
 * The TCDM multiplexer can be used to funnel more input "virtual"
 * TCDM channels into a smaller set of master ports.
 * It uses a round robin counter to avoid starvation, and differs
 * from the modules used within the logarithmic interconnect in
 * that arbitration is performed depending on the round robin
 * counter and not on the slave port; in other words, its task is
 * to fill all out ports with requests from the in port, and not
 * to route in requests to a specific out port.
 */

import hwpe_stream_package::*;

module hwpe_stream_tcdm_mux
#(
  parameter int unsigned NB_IN_CHAN  = 2,
  parameter int unsigned NB_OUT_CHAN = 1,
  parameter int unsigned SILENCE_BROADCAST = 0,
  parameter int unsigned INTERLEAVED_MUXING = 1
)
(
  input  logic                clk_i,
  input  logic                rst_ni,
  input  logic                clear_i,

  hwpe_stream_intf_tcdm.slave  in  [NB_IN_CHAN-1:0],
  hwpe_stream_intf_tcdm.master out [NB_OUT_CHAN-1:0]
);

  // based on MUX2Req.sv from LIC
  logic [NB_IN_CHAN-1:0]        in_req;
  logic [NB_IN_CHAN-1:0][31:0]  in_add;
  logic [NB_IN_CHAN-1:0]        in_wen;
  logic [NB_IN_CHAN-1:0][3:0]   in_be;
  logic [NB_IN_CHAN-1:0][31:0]  in_data;
  logic [NB_IN_CHAN-1:0]        in_gnt;
  logic [NB_IN_CHAN-1:0][31:0]  in_r_data;
  logic [NB_IN_CHAN-1:0]        in_r_valid;
  logic [NB_OUT_CHAN-1:0]       out_req;
  logic [NB_OUT_CHAN-1:0][31:0] out_add;
  logic [NB_OUT_CHAN-1:0]       out_wen;
  logic [NB_OUT_CHAN-1:0][3:0]  out_be;
  logic [NB_OUT_CHAN-1:0][31:0] out_data;
  logic [NB_OUT_CHAN-1:0]       out_gnt;
  logic [NB_OUT_CHAN-1:0][31:0] out_r_data;
  logic [NB_OUT_CHAN-1:0]       out_r_valid;

  logic [$clog2(NB_IN_CHAN/NB_OUT_CHAN)-1:0]                                              rr_counter;
  logic [NB_OUT_CHAN-1:0][NB_IN_CHAN/NB_OUT_CHAN-1:0][$clog2(NB_IN_CHAN/NB_OUT_CHAN)-1:0] rr_priority;
  logic [NB_OUT_CHAN-1:0][$clog2(NB_IN_CHAN/NB_OUT_CHAN)-1:0]                             winner;
  logic [NB_OUT_CHAN-1:0][$clog2(NB_IN_CHAN/NB_OUT_CHAN)-1:0]                             last_winner;
  logic [NB_OUT_CHAN-1:0]                                                                 last_req;

  logic s_rr_counter_reg_en;
  assign s_rr_counter_reg_en = (|out_req) & (|out_gnt);

  always_ff @(posedge clk_i, negedge rst_ni)
  begin : round_robin_counter
    if(rst_ni == 1'b0)
      rr_counter <= '0;
    else if (clear_i == 1'b1)
      rr_counter <= '0;
    else if (s_rr_counter_reg_en)
      rr_counter <= (rr_counter + {{($clog2(NB_IN_CHAN/NB_OUT_CHAN)-1){1'b0}},1'b1}); //[$clog2(NB_IN_CHAN)-1:0];
  end

  genvar i,j;
  generate

    for(j=0; j<NB_IN_CHAN; j++) begin : in_chan_gen

      assign in_req  [j] = in[j].req ;
      assign in_add  [j] = in[j].add ;
      assign in_wen  [j] = in[j].wen ;
      assign in_be   [j] = in[j].be  ;
      assign in_data [j] = in[j].data;
      assign in[j].gnt     = in_gnt     [j];
      assign in[j].r_data  = in_r_data  [j];
      assign in[j].r_valid = in_r_valid [j];

    end // in_chan_gen

    for(i=0; i<NB_OUT_CHAN; i++) begin : out_chan_gen

      assign out[i].req  = out_req  [i];
      assign out[i].add  = out_add  [i];
      assign out[i].wen  = out_wen  [i];
      assign out[i].be   = out_be   [i];
      assign out[i].data = out_data [i];
      assign out_gnt     [i] = out[i].gnt    ;
      assign out_r_data  [i] = out[i].r_data ;
      assign out_r_valid [i] = out[i].r_valid;

      always_comb
      begin : rotating_priority_encoder_i
        for(int j=0; j<NB_IN_CHAN/NB_OUT_CHAN; j++)
          rr_priority[i][j] = rr_counter + i + j;
      end

      if (SILENCE_BROADCAST==0) begin : no_silence_broadcast_gen

        if(INTERLEAVED_MUXING == 1) begin : interleaved_out_req_gen
          always_comb
          begin : out_req_comb
            out_req[i] = 1'b0;
            for(int j=0; j<NB_IN_CHAN/NB_OUT_CHAN; j++)
              out_req[i] = out_req[i] | in_req[j*NB_OUT_CHAN+i];
          end
        end /* interleaved_out_req_gen */
        else begin : non_interleaved_out_req_gen
          always_comb
          begin : out_req_comb
            out_req[i] = 1'b0;
            for(int j=0; j<NB_IN_CHAN/NB_OUT_CHAN; j++)
              out_req[i] = out_req[i] | in_req[i*(NB_IN_CHAN/NB_OUT_CHAN)+j];
          end
        end /* non_interleaved_out_req_gen */

      end /* no_silence_broadcast_gen */
      else begin : silence_broadcast_gen

        logic [$clog2(NB_IN_CHAN/NB_OUT_CHAN)-1:0] winner_prev;

        always_comb
        begin : winner_prev_comb
          if(i==0)
            winner_prev = winner[NB_OUT_CHAN-1];
          else
            winner_prev = winner[i-1];
        end

        if(INTERLEAVED_MUXING == 1) begin : interleaved_out_req_gen
          always_comb
          begin : out_req_comb
            out_req[i] = 1'b0;
            if(winner[i] != winner_prev)
              for(int j=0; j<NB_IN_CHAN/NB_OUT_CHAN; j++)
                out_req[i] = out_req[i] | in_req[j*NB_OUT_CHAN+i];
            else
              out_req[i] = 1'b0;
          end
        end /* interleaved_out_req_gen */
        else begin : non_interleaved_out_req_gen
          always_comb
          begin : out_req_comb
            out_req[i] = 1'b0;
            if(winner[i] != winner_prev)
              for(int j=0; j<NB_IN_CHAN/NB_OUT_CHAN; j++)
                out_req[i] = out_req[i] | in_req[i*(NB_IN_CHAN/NB_OUT_CHAN)+j];
            else
              out_req[i] = 1'b0;
          end
        end /* non_interleaved_out_req_gen */

      end // silence_broadcast_gen

      if(INTERLEAVED_MUXING == 1) begin : interleaved_winner_gen
        always_comb
        begin : wta_comb
          winner[i] = rr_counter + i;
          for(int jj=0; jj<NB_IN_CHAN/NB_OUT_CHAN; jj++) begin
            // automatic int jj = NB_IN_CHAN-j-1;
            if (in_req[rr_priority[i][jj]*NB_OUT_CHAN+i] == 1'b1)
              winner[i] = rr_priority[i][jj];
          end
        end
      end /* interleaved_winner_gen */
      else begin : non_interleaved_winner_gen
        always_comb
        begin : wta_comb
          winner[i] = rr_counter + i;
          for(int jj=0; jj<NB_IN_CHAN/NB_OUT_CHAN; jj++) begin
            // automatic int jj = NB_IN_CHAN-j-1;
            if (in_req[i*(NB_IN_CHAN/NB_OUT_CHAN)+rr_priority[i][jj]] == 1'b1)
              winner[i] = rr_priority[i][jj];
          end
        end
      end /* non_interleaved_winner_gen */

      if(INTERLEAVED_MUXING == 1) begin : interleaved_mux_req_gen
        always_comb
        begin : mux_req_comb
          out_add  [i] = in_add  [winner[i]*NB_OUT_CHAN+i];
          out_wen  [i] = in_wen  [winner[i]*NB_OUT_CHAN+i];
          out_data [i] = in_data [winner[i]*NB_OUT_CHAN+i];
          out_be   [i] = in_be   [winner[i]*NB_OUT_CHAN+i];
        end
      end /* interleaved_mux_req_gen */
      else begin : non_interleaved_mux_req_gen
        always_comb
        begin : mux_req_comb
          out_add  [i] = in_add  [i*(NB_IN_CHAN/NB_OUT_CHAN)+winner[i]];
          out_wen  [i] = in_wen  [i*(NB_IN_CHAN/NB_OUT_CHAN)+winner[i]];
          out_data [i] = in_data [i*(NB_IN_CHAN/NB_OUT_CHAN)+winner[i]];
          out_be   [i] = in_be   [i*(NB_IN_CHAN/NB_OUT_CHAN)+winner[i]];
        end
      end /* non_interleaved_mux_req_gen */

      always_ff @(posedge clk_i or negedge rst_ni)
      begin : wta_resp_reg
        if(rst_ni == 1'b0) begin
          last_winner[i] <= '0;
          last_req   [i] <= 1'b0;
        end
        else if(clear_i == 1'b1) begin
          last_winner[i] <= '0;
          last_req   [i] <= 1'b0;
        end
        else begin
          last_winner[i] <= winner    [i];
          last_req   [i] <= out_req [i];
        end
      end

    end // out_chan_gen

    if(INTERLEAVED_MUXING == 1) begin : interleaved_mux_resp_gen

      always_comb
      begin : mux_resp_comb
        for(int i=0; i<NB_OUT_CHAN; i++) begin
          for (int j=0; j<NB_IN_CHAN/NB_OUT_CHAN; j++) begin
            in_r_data  [j*NB_OUT_CHAN+i] = '0;
            in_r_valid [j*NB_OUT_CHAN+i] = 1'b0;
            in_gnt     [j*NB_OUT_CHAN+i] = 1'b0;
          end
          in_r_data  [last_winner[i]*NB_OUT_CHAN+i] = out_r_data[i];
          in_r_valid [last_winner[i]*NB_OUT_CHAN+i] = out_r_valid[i] & last_req[i];
          in_gnt     [winner[i]*NB_OUT_CHAN+i]      = out_gnt[i];
        end
      end

    end /* interleaved_mux_resp_gen */
    else begin : non_interleaved_mux_resp_gen

      always_comb
      begin : mux_resp_comb
        for(int i=0; i<NB_OUT_CHAN; i++) begin
          for (int j=0; j<NB_IN_CHAN/NB_OUT_CHAN; j++) begin
            in_r_data  [i*(NB_IN_CHAN/NB_OUT_CHAN)+j] = '0;
            in_r_valid [i*(NB_IN_CHAN/NB_OUT_CHAN)+j] = 1'b0;
            in_gnt     [i*(NB_IN_CHAN/NB_OUT_CHAN)+j] = 1'b0;
          end
          in_r_data  [i*(NB_IN_CHAN/NB_OUT_CHAN)+last_winner[i]] = out_r_data[i];
          in_r_valid [i*(NB_IN_CHAN/NB_OUT_CHAN)+last_winner[i]] = out_r_valid[i] & last_req[i];
          in_gnt     [i*(NB_IN_CHAN/NB_OUT_CHAN)+winner[i]]      = out_gnt[i];
        end
      end

    end /* non_interleaved_mux_resp_gen */

  endgenerate

endmodule // hwpe_stream_tcdm_mux
