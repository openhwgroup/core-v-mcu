/*
 * hwpe_stream_package.sv
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

package hwpe_stream_package;

  // realignment types
  parameter int unsigned HWPE_STREAM_REALIGN_SOURCE = 0;
  parameter int unsigned HWPE_STREAM_REALIGN_SINK   = 1;

  // addressgen related types  
  typedef struct packed {
    logic [31:0] base_addr;
    logic [31:0] trans_size;
    logic [15:0] line_stride;
    logic [15:0] line_length;
    logic [15:0] feat_stride;
    logic [15:0] feat_length;
    logic [15:0] feat_roll;
    logic        loop_outer;
    logic        realign_type;
    logic [7:0]  line_length_remainder; // in bytes
  } ctrl_addressgen_t;

  typedef struct packed {
    logic enable;
    logic realign;
    logic first;
    logic last;
    logic last_packet;
    logic [15:0] line_length;
  } ctrl_realign_t;

  typedef struct packed {
    ctrl_realign_t realign_flags;
    logic word_update;
    logic line_update;
    logic feat_update;
    logic in_progress;
  } flags_addressgen_t;

  typedef struct packed {
    logic empty;
  } flags_fifo_t;

  // source/sink related types  
  typedef struct packed {
    logic             req_start;
    ctrl_addressgen_t addressgen_ctrl;
  } ctrl_sourcesink_t;

  typedef struct packed {
    logic              ready_start;
    logic              done;
    flags_addressgen_t addressgen_flags;
    logic              ready_fifo;
  } flags_sourcesink_t;

  typedef enum {
    STREAM_IDLE, STREAM_WORKING, STREAM_DONE
  } state_sourcesink_t;

endpackage
