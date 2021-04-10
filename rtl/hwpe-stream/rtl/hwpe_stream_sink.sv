/*
 * hwpe_stream_sink.sv
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

module hwpe_stream_sink
#(
  // Stream interface params
  parameter int unsigned DATA_WIDTH     = 32,
  parameter int unsigned NB_TCDM_PORTS  = DATA_WIDTH/32,
  parameter int unsigned USE_TCDM_FIFOS = 1
)
(
  input logic clk_i,
  input logic rst_ni,
  input logic test_mode_i,
  input logic clear_i,

  hwpe_stream_intf_tcdm.master tcdm [NB_TCDM_PORTS-1:0],
  hwpe_stream_intf_stream.sink stream,

  // control plane
  input  ctrl_sourcesink_t    ctrl_i,
  output flags_sourcesink_t   flags_o
);

  state_sourcesink_t cs, ns;

  logic [31:0]                gen_addr;
  logic [NB_TCDM_PORTS*4-1:0] gen_strb;

  logic address_gen_en;
  logic address_gen_clr;
  logic done;

  logic clk_realign_gated;
  logic [NB_TCDM_PORTS-1:0] tcdm_inflight;
  logic tcdm_inflight_any;

  hwpe_stream_intf_stream #(
    .DATA_WIDTH ( 32 )
  ) split_streams [NB_TCDM_PORTS-1:0] (
    .clk ( clk_i )
  );

  hwpe_stream_intf_stream #(
    .DATA_WIDTH ( DATA_WIDTH )
  ) realigned_stream (
    .clk ( clk_realign_gated )
  );
  hwpe_stream_intf_tcdm tcdm_prefifo [NB_TCDM_PORTS-1:0] (
    .clk ( clk_i )
  );

  hwpe_stream_split #(
    .DATA_WIDTH_IN ( DATA_WIDTH    ),
    .NB_OUT_STREAMS( NB_TCDM_PORTS )
  ) i_stream_split (
    .clk_i    ( clk_i            ),
    .rst_ni   ( rst_ni           ),
    .clear_i  ( clear_i          ),
    .stream_i ( realigned_stream ),
    .stream_o ( split_streams    )
  );

  hwpe_stream_addressgen #(
    .STEP         ( NB_TCDM_PORTS*4          ),
    .REALIGN_TYPE ( HWPE_STREAM_REALIGN_SINK ),
    .DELAY_FLAGS  ( 1                        )
  ) i_addressgen (
    .clk_i          ( clk_i                    ),
    .rst_ni         ( rst_ni                   ),
    .test_mode_i    ( test_mode_i              ),
    .enable_i       ( address_gen_en           ),
    .clear_i        ( address_gen_clr          ),
    .gen_addr_o     ( gen_addr                 ),
    .gen_strb_o     ( gen_strb                 ),
    .ctrl_i         ( ctrl_i.addressgen_ctrl   ),
    .flags_o        ( flags_o.addressgen_flags )
  );

  /* clock gating */
  cluster_clock_gating i_realign_gating (
    .clk_i     ( clk_i                                         ),
    .test_en_i ( test_mode_i                                   ),
    .en_i      ( flags_o.addressgen_flags.realign_flags.enable ),
    .clk_o     ( clk_realign_gated                             )
  );

  hwpe_stream_sink_realign #(
    .DATA_WIDTH ( DATA_WIDTH )
  ) i_realign (
    .clk_i       ( clk_realign_gated                      ),
    .rst_ni      ( rst_ni                                 ),
    .test_mode_i ( test_mode_i                            ),
    .clear_i     ( clear_i                                ),
    .ctrl_i      ( flags_o.addressgen_flags.realign_flags ),
    .strb_i      ( gen_strb                               ),
    .stream_i    ( stream                                 ),
    .stream_o    ( realigned_stream                       )
  );

  // tcdm ports binding
  generate
    for(genvar ii=0; ii<NB_TCDM_PORTS; ii++) begin: tcdm_binding

      if(USE_TCDM_FIFOS) begin: tcdm_fifos_gen

        assign tcdm_prefifo[ii].req  = (cs == STREAM_WORKING) ? split_streams[ii].valid : '0;
        assign tcdm_prefifo[ii].add  = (cs == STREAM_WORKING) ? gen_addr + ii*4         : '0;
        assign tcdm_prefifo[ii].wen  = (cs == STREAM_WORKING) ? 1'b0                    : '0;
        assign tcdm_prefifo[ii].be   = (cs == STREAM_WORKING) ? split_streams[ii].strb  : '0;
        assign tcdm_prefifo[ii].data = (cs == STREAM_WORKING) ? split_streams[ii].data  : '0;
        assign split_streams[ii].ready = ~split_streams[ii].valid | tcdm_prefifo[ii].gnt;

        hwpe_stream_tcdm_fifo_store #(
          .FIFO_DEPTH ( 4 )
        ) i_tcdm_fifo (
          .clk_i       ( clk_i             ),
          .rst_ni      ( rst_ni            ),
          .clear_i     ( clear_i           ),
          .tcdm_slave  ( tcdm_prefifo [ii] ),
          .tcdm_master ( tcdm [ii]         )
        );

      end
      else begin: no_tcdm_fifos_gen

        assign tcdm[ii].req  = (cs == STREAM_WORKING) ? split_streams[ii].valid : '0;
        assign tcdm[ii].add  = (cs == STREAM_WORKING) ? gen_addr + ii*4         : '0;
        assign tcdm[ii].wen  = (cs == STREAM_WORKING) ? 1'b0                    : '0;
        assign tcdm[ii].be   = (cs == STREAM_WORKING) ? split_streams[ii].strb  : '0;
        assign tcdm[ii].data = (cs == STREAM_WORKING) ? split_streams[ii].data  : '0;
        assign split_streams[ii].ready = ~split_streams[ii].valid | tcdm[ii].gnt;

      end

      assign tcdm_inflight[ii] = tcdm[ii].req;

    end
  endgenerate

  always_comb
  begin
    tcdm_inflight_any = '0;
    for(int i=0; i<NB_TCDM_PORTS; i++)
      tcdm_inflight_any = tcdm_inflight_any | tcdm_inflight[i];
  end

  always_ff @(posedge clk_i or negedge rst_ni)
  begin : done_sink_ff
    if(~rst_ni)
      flags_o.done <= 1'b0;
    else if(clear_i)
      flags_o.done <= 1'b0;
    else
      flags_o.done <= done;
  end

  always_ff @(posedge clk_i, negedge rst_ni)
  begin : fsm_seq
    if(rst_ni == 1'b0) begin
      cs <= STREAM_IDLE;
    end
    else if(clear_i == 1'b1) begin
      cs <= STREAM_IDLE;
    end
    else begin
      cs <= ns;
    end
  end

  always_comb
  begin : fsm_comb
    done      = 1'b0;
    flags_o.ready_start = 1'b0;
    address_gen_en     = 1'b0;
    address_gen_clr    = clear_i;
    case(cs)
      STREAM_IDLE : begin
        flags_o.ready_start = 1'b1;
        if(ctrl_i.req_start) begin
          ns = STREAM_WORKING;
          address_gen_en = stream.valid & stream.ready;
        end
        else begin
          ns = STREAM_IDLE;
          address_gen_en = 1'b0;
        end
      end
      STREAM_WORKING : begin
        if(stream.valid & stream.ready) begin
          ns = STREAM_WORKING;
          address_gen_en = 1'b1;
        end
        else if(flags_o.addressgen_flags.realign_flags.enable & flags_o.addressgen_flags.realign_flags.last) begin
          ns = STREAM_WORKING;
          address_gen_en = 1'b1;
        end
        else if(~flags_o.addressgen_flags.in_progress & tcdm_inflight_any) begin // if transactions in flight, let them end
          ns = STREAM_WORKING;
          address_gen_en  = 1'b0;
        end
        else if(~flags_o.addressgen_flags.in_progress) begin
          ns = STREAM_IDLE;
          done = 1'b1;
          address_gen_en  = 1'b0;
          address_gen_clr = 1'b1;
        end
        else begin
          ns = STREAM_WORKING;
          address_gen_en = 1'b0;
        end
      end
      default : begin
        ns = STREAM_IDLE;
        address_gen_en = 1'b0;
      end
    endcase
  end

endmodule // hwpe_stream_sink
