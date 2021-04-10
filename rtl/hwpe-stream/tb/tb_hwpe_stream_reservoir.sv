/* 
 * tb_hwpe_stream_reservoir.sv
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
 * The tb_hwpe_stream_reservoir module models a reservoir
 * of random
 */

timeunit 1ns;
timeprecision 1ps;

import hwpe_stream_package::*;

module tb_hwpe_stream_reservoir
#(
  parameter DATA_WIDTH      = -1,
  parameter REALIGN_TYPE   = HWPE_STREAM_REALIGN_SOURCE,
  parameter RESERVOIR_SIZE = 1024,
  parameter PROB_STALL     = 0.0,
  parameter TCP            = 1.0ns, // clock period, 1GHz clock
  parameter TA             = 0.2ns, // application time
  parameter TT             = 0.8ns  // test time
)
(
  input  logic                   clk_i,
  input  logic                   randomize_i,
  input  int                     rotation_i,
  input  logic                   new_rotation_i,
  input  logic                   force_invalid_i,
  input  logic                   force_valid_i,
  input  logic                   enable_i,
  hwpe_stream_intf_stream.source data_o
);

  logic [RESERVOIR_SIZE-1:0][DATA_WIDTH-1:0]   reservoir;
  logic [RESERVOIR_SIZE-1:0][DATA_WIDTH/8-1:0] reservoir_strb;
  int cnt = 0;

  generate

    for(genvar i=0; i<RESERVOIR_SIZE; i++) begin : outer
      for(genvar j=0; j<DATA_WIDTH / 32; j++) begin : inner
        always_ff @(posedge clk_i)
        begin
          if(randomize_i) begin
            reservoir     [i][(j+1)*32-1:j*32] = $random();
            // reservoir_strb[i][(j+1)*4-1:j*4]   = $random();
          end
        end
      end
      always_ff @(posedge clk_i)
      begin
        if(randomize_i)
          if(DATA_WIDTH % 32 != 0) begin
            reservoir     [i][DATA_WIDTH-1:DATA_WIDTH-(DATA_WIDTH%32)]    = $random();
            // reservoir_strb[i][DATA_WIDTH-1:DATA_WIDTH-((DATA_WIDTH/8)%4)] = $random();
          end
      end
    end

    if(REALIGN_TYPE == HWPE_STREAM_REALIGN_SOURCE) begin : realign_source_gen

      always
      begin
        if(new_rotation_i) begin
          automatic logic strb_start = rotation_i;
          for(int i=0; i<strb_start; i++)
            data_o.strb[i] <= #TA 1'b0;
          for(int i=strb_start; i<DATA_WIDTH/8; i++)
            data_o.strb[i] <= #TA 1'b1;
        end
        else begin
          data_o.strb <= #TA '1;
        end
        if(enable_i) begin
          // try to push a new packet if the slave is ready or the
          // last packet is not valid
          if ((data_o.ready == 1'b1) || (data_o.valid == 1'b0)) begin
            if (($urandom_range(0, 1000) < PROB_STALL*1000) && (force_valid_i!=1'b1)) begin
              data_o.valid <= #TA 1'b0;
              data_o.data  <= #TA 'x;
            end
            else begin
              data_o.valid <= #TA ~force_invalid_i | force_valid_i;
              data_o.data  <= #TA reservoir[cnt];
              cnt = (cnt == RESERVOIR_SIZE-1) ? 0 : cnt+1;
            end
          end
          else begin
            data_o.valid <= #TA (data_o.valid & ~force_invalid_i) | force_valid_i;
            data_o.data  <= #TA data_o.data;
          end
        end
        else begin
          data_o.valid <= #TA 1'b0;
          data_o.data  <= #TA '0;
        end
        #(TCP);
      end

    end // realign_source_gen
    else begin : realign_sink_gen

      always
      begin
        data_o.strb <= #TA '1;
        if(enable_i) begin
          // try to push a new packet if the slave is ready or the
          // last packet is not valid
          if ((data_o.ready == 1'b1) || (data_o.valid == 1'b0)) begin
            if (($urandom_range(0, 1000) < PROB_STALL*1000) && (force_valid_i!=1'b1)) begin
              data_o.valid <= #TA 1'b0;
              data_o.data  <= #TA 'x;
            end
            else begin
              data_o.valid <= #TA ~force_invalid_i | force_valid_i;
              data_o.data  <= #TA reservoir[cnt];
              cnt = (cnt == RESERVOIR_SIZE-1) ? 0 : cnt+1;
            end
          end
          else begin
            data_o.valid <= #TA (data_o.valid & ~force_invalid_i) | force_valid_i;
            data_o.data  <= #TA data_o.data;
          end
        end
        else begin
          data_o.valid <= #TA 1'b0;
          data_o.data  <= #TA '0;
        end
        #(TCP);
      end

    end // realign_sink_gen

  endgenerate

endmodule // tb_hwpe_stream_reservoir
