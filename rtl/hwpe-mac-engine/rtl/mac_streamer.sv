/*
 * mac_streamer.sv
 * Francesco Conti <fconti@iis.ee.ethz.ch>
 *
 * Copyright (C) 2018 ETH Zurich, University of Bologna
 * Copyright and related rights are licensed under the Solderpad Hardware
 * License, Version 0.51 (the "License"); you may not use this file except in
 * compliance with the License.  You may obtain a copy of the License at
 * http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
 * or agreed to in writing, software, hardware and materials distributed under
 * this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 */

import mac_package::*;
import hwpe_stream_package::*;

module mac_streamer
#(
  parameter int unsigned MP = 4, // number of master ports
  parameter int unsigned FD = 2  // FIFO depth
)
(
  // global signals
  input  logic                   clk_i,
  input  logic                   rst_ni,
  input  logic                   test_mode_i,
  // local enable & clear
  input  logic                   enable_i,
  input  logic                   clear_i,

  // input a stream + handshake
  hwpe_stream_intf_stream.source a_o,
  // input b stream + handshake
  hwpe_stream_intf_stream.source b_o,
  // input c stream + handshake
  hwpe_stream_intf_stream.source c_o,
  // output d stream + handshake
  hwpe_stream_intf_stream.sink   d_i,

  // TCDM ports
  hwpe_stream_intf_tcdm.master tcdm [MP-1:0],

  // control channel
  input  ctrl_streamer_t  ctrl_i,
  output flags_streamer_t flags_o
);

  logic a_tcdm_fifo_ready, b_tcdm_fifo_ready, c_tcdm_fifo_ready;

  hwpe_stream_intf_stream #(
    .DATA_WIDTH ( 32 )
  ) a_prefifo (
    .clk ( clk_i )
  );
  hwpe_stream_intf_stream #(
    .DATA_WIDTH ( 32 )
  ) b_prefifo (
    .clk ( clk_i )
  );
  hwpe_stream_intf_stream #(
    .DATA_WIDTH ( 32 )
  ) c_prefifo (
    .clk ( clk_i )
  );
  hwpe_stream_intf_stream #(
    .DATA_WIDTH ( 32 )
  ) d_postfifo (
    .clk ( clk_i )
  );

  hwpe_stream_intf_tcdm tcdm_fifo [MP-1:0] (
    .clk ( clk_i )
  );
  hwpe_stream_intf_tcdm tcdm_fifo_0 [0:0] (
    .clk ( clk_i )
  );
  hwpe_stream_intf_tcdm tcdm_fifo_1 [0:0] (
    .clk ( clk_i )
  );
  hwpe_stream_intf_tcdm tcdm_fifo_2 [0:0] (
    .clk ( clk_i )
  );
  hwpe_stream_intf_tcdm tcdm_fifo_3 [0:0] (
    .clk ( clk_i )
  );

  // source and sink modules
  hwpe_stream_source #(
    .DATA_WIDTH ( 32 ),
    .DECOUPLED  ( 1  )
  ) i_a_source (
    .clk_i              ( clk_i                  ),
    .rst_ni             ( rst_ni                 ),
    .test_mode_i        ( test_mode_i            ),
    .clear_i            ( clear_i                ),
    .tcdm               ( tcdm_fifo_0            ), // this syntax is necessary for Verilator as hwpe_stream_source expects an array of interfaces
    .stream             ( a_prefifo.source       ),
    .ctrl_i             ( ctrl_i.a_source_ctrl   ),
    .flags_o            ( flags_o.a_source_flags ),
    .tcdm_fifo_ready_o  ( a_tcdm_fifo_ready      )
  );

  hwpe_stream_source #(
    .DATA_WIDTH ( 32 ),
    .DECOUPLED  ( 1  )
  ) i_b_source (
    .clk_i              ( clk_i                  ),
    .rst_ni             ( rst_ni                 ),
    .test_mode_i        ( test_mode_i            ),
    .clear_i            ( clear_i                ),
    .tcdm               ( tcdm_fifo_1            ), // this syntax is necessary for Verilator as hwpe_stream_source expects an array of interfaces
    .stream             ( b_prefifo.source       ),
    .ctrl_i             ( ctrl_i.b_source_ctrl   ),
    .flags_o            ( flags_o.b_source_flags ),
    .tcdm_fifo_ready_o  ( b_tcdm_fifo_ready      )
  );

  hwpe_stream_source #(
    .DATA_WIDTH ( 32 ),
    .DECOUPLED  ( 1  )
  ) i_c_source (
    .clk_i              ( clk_i                  ),
    .rst_ni             ( rst_ni                 ),
    .test_mode_i        ( test_mode_i            ),
    .clear_i            ( clear_i                ),
    .tcdm               ( tcdm_fifo_2            ), // this syntax is necessary for Verilator as hwpe_stream_source expects an array of interfaces
    .stream             ( c_prefifo.source       ),
    .ctrl_i             ( ctrl_i.c_source_ctrl   ),
    .flags_o            ( flags_o.c_source_flags ),
    .tcdm_fifo_ready_o  ( c_tcdm_fifo_ready      )
  );

  hwpe_stream_sink #(
    .DATA_WIDTH ( 32 )
  ) i_d_sink (
    .clk_i       ( clk_i                ),
    .rst_ni      ( rst_ni               ),
    .test_mode_i ( test_mode_i          ),
    .clear_i     ( clear_i              ),
    .tcdm        ( tcdm_fifo_3          ), // this syntax is necessary for Verilator as hwpe_stream_source expects an array of interfaces
    .stream      ( d_postfifo.sink      ),
    .ctrl_i      ( ctrl_i.d_sink_ctrl   ),
    .flags_o     ( flags_o.d_sink_flags )
  );


  // TCDM-side FIFOs
  hwpe_stream_tcdm_fifo_load #(
    .FIFO_DEPTH ( 4 )
  ) i_a_tcdm_fifo_load (
    .clk_i       ( clk_i             ),
    .rst_ni      ( rst_ni            ),
    .clear_i     ( clear_i           ),
    .flags_o     (                   ),
    .ready_i     ( a_tcdm_fifo_ready ),
    .tcdm_slave  ( tcdm_fifo_0[0]    ),
    .tcdm_master ( tcdm      [0]     )
  );

  hwpe_stream_tcdm_fifo_load #(
    .FIFO_DEPTH ( 4 )
  ) i_b_tcdm_fifo_load (
    .clk_i       ( clk_i             ),
    .rst_ni      ( rst_ni            ),
    .clear_i     ( clear_i           ),
    .flags_o     (                   ),
    .ready_i     ( b_tcdm_fifo_ready ),
    .tcdm_slave  ( tcdm_fifo_1[0]    ),
    .tcdm_master ( tcdm      [1]     )
  );

  hwpe_stream_tcdm_fifo_load #(
    .FIFO_DEPTH ( 4 )
  ) i_c_tcdm_fifo_load (
    .clk_i       ( clk_i             ),
    .rst_ni      ( rst_ni            ),
    .clear_i     ( clear_i           ),
    .flags_o     (                   ),
    .ready_i     ( c_tcdm_fifo_ready ),
    .tcdm_slave  ( tcdm_fifo_2[0]    ),
    .tcdm_master ( tcdm      [2]     )
  );

  hwpe_stream_tcdm_fifo_store #(
    .FIFO_DEPTH ( 4 )
  ) i_d_tcdm_fifo_store (
    .clk_i       ( clk_i          ),
    .rst_ni      ( rst_ni         ),
    .clear_i     ( clear_i        ),
    .flags_o     (                ),
    .tcdm_slave  ( tcdm_fifo_3[0] ),
    .tcdm_master ( tcdm       [3] )
  );

  // datapath-side FIFOs
  hwpe_stream_fifo #(
    .DATA_WIDTH( 32 ),
    .FIFO_DEPTH( 2  ),
    .LATCH_FIFO( 0  )
  ) i_a_fifo (
    .clk_i   ( clk_i          ),
    .rst_ni  ( rst_ni         ),
    .clear_i ( clear_i        ),
    .push_i  ( a_prefifo.sink ),
    .pop_o   ( a_o            ),
    .flags_o (                )
  );

  hwpe_stream_fifo #(
    .DATA_WIDTH( 32 ),
    .FIFO_DEPTH( 2  ),
    .LATCH_FIFO( 0  )
  ) i_b_fifo (
    .clk_i   ( clk_i          ),
    .rst_ni  ( rst_ni         ),
    .clear_i ( clear_i        ),
    .push_i  ( b_prefifo.sink ),
    .pop_o   ( b_o            ),
    .flags_o (                )
  );

  hwpe_stream_fifo #(
    .DATA_WIDTH( 32 ),
    .FIFO_DEPTH( 2  ),
    .LATCH_FIFO( 0  )
  ) i_c_fifo (
    .clk_i   ( clk_i          ),
    .rst_ni  ( rst_ni         ),
    .clear_i ( clear_i        ),
    .push_i  ( c_prefifo.sink ),
    .pop_o   ( c_o            ),
    .flags_o (                )
  );

  hwpe_stream_fifo #(
    .DATA_WIDTH( 32 ),
    .FIFO_DEPTH( 2  ),
    .LATCH_FIFO( 0  )
  ) i_d_fifo (
    .clk_i   ( clk_i             ),
    .rst_ni  ( rst_ni            ),
    .clear_i ( clear_i           ),
    .push_i  ( d_i               ),
    .pop_o   ( d_postfifo.source ),
    .flags_o (                   )
  );

endmodule // mac_streamer
