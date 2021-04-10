/*
 * mac_engine.sv
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
 *
 * The architecture that follows is relatively straightforward; it supports two modes:
 *  - in 'simple_mult' mode, the a_i and b_i streams feed the 32b x 32b multiplier (mult).
 *    The output of the multiplier (64b) is registered in a pipeline stage
 *    (r_mult), which is then shifted by ctrl_i.shift to the right and streamed out as d_o.
 *    There is no control local to the module except for handshakes.
 *  - in 'scalar_prod' mode, the c_i stream is first shifted left by ctrl_i.shift, extended
 *    to 64b and saved in r_acc. Then, the a_i and b_i streams feed the 32b x 32b multiplier
 *    (mult) for ctrl_i.len cycles, controlled by a local counter. The output of mult is 
 *    registered in a pipeline stage (r_mult), whose value is used as input to an accumulator
 *    (r_acc) -- the one which was inited by the shifted value of c_i. At the end of the
 *    ctrl_i.len cycles, the output of r_acc is shifted back to the right by ctrl_i.shift
 *    bits and streamed out as d_o.
 */

import mac_package::*;

module mac_engine
(
  // global signals
  input  logic                   clk_i,
  input  logic                   rst_ni,
  input  logic                   test_mode_i,
  // input a stream
  hwpe_stream_intf_stream.sink   a_i,
  // input b stream
  hwpe_stream_intf_stream.sink   b_i,
  // input c stream
  hwpe_stream_intf_stream.sink   c_i,
  // output d stream
  hwpe_stream_intf_stream.source d_o,
  // control channel
  input  ctrl_engine_t           ctrl_i,
  output flags_engine_t          flags_o
);

  logic unsigned [$clog2(MAC_CNT_LEN):0] cnt;
  logic unsigned [$clog2(MAC_CNT_LEN):0] r_cnt;
  logic signed [63:0] c_shifted;
  logic signed [63:0] mult;
  logic signed [63:0] r_mult;
  logic               r_mult_valid;
  logic               r_mult_ready;
  logic signed [64+$clog2(MAC_CNT_LEN)-1:0] r_acc;
  logic                                     r_acc_valid;
  logic                                     r_acc_ready;
  logic signed [64+$clog2(MAC_CNT_LEN)-1:0] d_nonshifted;
  logic                                     d_nonshifted_valid;

  // A design choice of this accelerator is that at the interface of modules only a few categories
  // of signals are exposed:
  //  - global signals (clk, rst_n)
  //  - HWPE-Stream or TCDM interfaces (a_i, ...)
  //  - a control packed struct (ctrl_i) and a state packed struct (flags_o)
  // The flags_o packed struct encapsulates all of the information about the internal state
  // of the module that must be exposed to the controller, and the ctrl_i all the control
  // information necessary for configuring the current module. In this way, it is possible to
  // make significant changes to the control interface (which can typically propagate through
  // a big hierarchy of modules) without manually modifying the interface in all modules; it
  // is sufficient to change the packed struct definition in the package where it is defined.
  // Packed structs are essentially bit vectors where bit fields have a name, and as such
  // are easily synthesizable and much more readable than Verilog-2001-ish code.

  // shift c_i by ctrl_i.shift bits to the left
  always_comb
  begin : shift_c
    c_shifted = $signed(c_i.data <<< ctrl_i.shift);
  end

  // multiply a_i by b_i
  always_comb
  begin : mult_a_X_b
    mult = $signed(a_i.data) * $signed(b_i.data);
  end

  // r_mult stores a_i * b_i
  always_ff @(posedge clk_i or negedge rst_ni)
  begin : mult_pipe_data
    if(~rst_ni) begin
      r_mult <= '0;
    end
    else if (ctrl_i.clear) begin
      r_mult <= '0;
    end
    else if (ctrl_i.enable) begin
      // r_mult value is updated if there is a valid handshake at its input
      if (a_i.valid & b_i.valid & a_i.ready & b_i.ready) begin
        r_mult <= mult;
      end
    end
  end

  // r_mult is valid following a valid handshake
  always_ff @(posedge clk_i or negedge rst_ni)
  begin : mult_pipe_valid
    if(~rst_ni) begin
      r_mult_valid <= '0;
    end
    else if (ctrl_i.clear) begin
      r_mult_valid <= '0;
    end
    else if (ctrl_i.enable) begin
      // r_mult_valid is re-evaluated after a valid handshake or in transition to 1
      if ((a_i.valid & b_i.valid) | (r_mult_valid & r_mult_ready)) begin
        r_mult_valid <= a_i.valid & b_i.valid;
      end
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni)
  begin : accumulator
    if(~rst_ni) begin
      r_acc <= '0;
    end
    else if (ctrl_i.clear) begin
      r_acc <= '0;
    end
    else if (ctrl_i.enable) begin
      // r_acc value is updated if there are both c_i and r_mult valid handshakes at its input
      if (r_mult_valid & r_mult_ready & c_i.valid & c_i.ready) begin
        r_acc <= $signed(c_shifted + r_mult);
      end
      // r_acc value is updated if there is a c_i valid handshake at its input
      else if (c_i.valid & c_i.ready) begin
        r_acc <= $signed(c_shifted);
      end
      // r_acc value is updated if there is a r_mult valid handshake at its input
      else if (r_mult_valid & r_mult_ready) begin
        r_acc <= $signed(r_acc + r_mult);
      end
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni)
  begin : accumulator_valid
    if(~rst_ni) begin
      r_acc_valid <= '0;
    end
    else if (ctrl_i.clear) begin
      r_acc_valid <= '0;
    end
    else if (ctrl_i.enable) begin
      // r_acc_valid is re-evaluated after a valid handshake or in transition to 1
      if(((r_cnt == ctrl_i.len) & r_mult_valid & r_mult_ready) | (r_acc_valid & r_acc_ready)) begin
        r_acc_valid <= (r_cnt == ctrl_i.len);
      end
    end
  end

  always_comb
  begin : d_nonshifted_comb
    if(ctrl_i.simple_mul) begin
      d_nonshifted       = $signed(r_mult);
      d_nonshifted_valid = r_mult_valid;
    end
    else begin
      d_nonshifted       = r_acc;
      d_nonshifted_valid = r_acc_valid;
    end
  end

  always_comb
  begin
    d_o.data  = $signed(d_nonshifted >>> ctrl_i.shift); // no saturation/clipping
    d_o.valid = ctrl_i.enable & d_nonshifted_valid;
    d_o.strb  = '1; // for now, strb is always '1
  end

  // The control counter is implemented directly inside this module; as the control is
  // minimal, it was not deemed convenient to move it to another submodule. For bigger
  // FSMs that is typically the most advantageous choice.

  always_comb
  begin
    cnt = r_cnt + 1;
  end

  always_ff @(posedge clk_i or negedge rst_ni)
  begin
    if(~rst_ni) begin
      r_cnt <= '0;
    end
    else if(ctrl_i.clear) begin
      r_cnt <= '0;
    end
    else if(ctrl_i.enable) begin
      if ((ctrl_i.start == 1'b1) || ((r_cnt > 0) && (r_cnt < ctrl_i.len) && (r_mult_valid & r_mult_ready == 1'b1))) begin
        r_cnt <= cnt;
      end
    end
  end

  assign flags_o.cnt = r_cnt;
  assign flags_o.acc_valid = r_acc_valid;

  // Ready signals have to be propagated backwards through pipeline stages (combinationally).
  // To avoid deadlocks, the following rules have to be followed:
  //  1) transition of ready CAN depend on the current state of valid
  //  2) transition of valid CANNOT depend on the current state of ready
  //  3) transition 1->0 of valid MUST depend on (previous) ready (i.e., once the valid goes
  //     to 1 it cannot go back to 0 until there is a valid handshake)
  // In the following:
  // R_valid & R_ready denominate the handshake at the *output* (Q port) of pipe register R

  // output accepts new value from accumulator when the output is ready or r_acc is invalid
  assign r_acc_ready  = d_o.ready | ~r_acc_valid;
  // accumulator accepts new value from multiplier when
  //   1) output is ready or r_mult is invalid (if in simple multiplication mode)
  //   2) r_acc is ready or r_mult is invalid (if in scalar product mode)
  assign r_mult_ready = (ctrl_i.simple_mul) ? d_o.ready   | ~r_mult_valid
                                            : r_acc_ready | ~r_mult_valid;
  // multiplier accepts new value from a_i/b_i when r_mult is ready and both a_i/b_i are valid, or when both a_i/b_i are invalid
  assign a_i.ready = (r_mult_ready & a_i.valid & b_i.valid) | (~a_i.valid & ~b_i.valid);
  assign b_i.ready = (r_mult_ready & a_i.valid & b_i.valid) | (~a_i.valid & ~b_i.valid);
  // multiplier accepts new value from c_i when r_acc is ready or c_i is invalid
  assign c_i.ready    = r_acc_ready  | ~c_i.valid;

  // The following assertions help in getting the rules on ready & valid right.
  // They are copied from the general stream rules in hwpe_stream_interfaces.sv
  // and adapted to the internal r_acc and r_mult signals.
  `ifndef SYNTHESIS
  `ifndef VERILATOR
    // The data and strb can change their value 1) when valid is deasserted,
    // 2) in the cycle after a valid handshake, even if valid remains asserted.
    // In other words, valid data must remain on the interface until
    // a valid handshake has occurred.
    property r_acc_change_rule;
      @(posedge clk_i)
      ($past(r_acc_valid) & ~($past(r_acc_valid) & $past(r_acc_ready))) |-> (r_acc == $past(r_acc));
    endproperty;
    property r_mult_change_rule;
      @(posedge clk_i)
      ($past(r_mult_valid) & ~($past(r_mult_valid) & $past(r_mult_ready))) |-> (r_mult == $past(r_mult));
    endproperty;
    
    // The deassertion of valid (transition 1í0) can happen only in the cycle
    // after a valid handshake. In other words, valid data produced by a source
    // must be consumed on the sink side before valid is deasserted.
    property r_acc_valid_deassert_rule;
      @(posedge clk_i)
      ($past(r_acc_valid) & ~r_acc_valid) |-> $past(r_acc_valid) & $past(r_acc_ready);
    endproperty;
    property r_mult_valid_deassert_rule;
      @(posedge clk_i)
      ($past(r_mult_valid) & ~r_mult_valid) |-> $past(r_mult_valid) & $past(r_mult_ready);
    endproperty;

    R_ACC_VALUE_CHANGE:    assert property(r_acc_change_rule)
      else $fatal("ASSERTION FAILURE: R_ACC_VALUE_CHANGE", 1);

    R_ACC_VALID_DEASSERT:  assert property(r_acc_valid_deassert_rule)
      else $fatal("ASSERTION FAILURE R_ACC_VALID_DEASSERT", 1);

    R_MULT_VALUE_CHANGE:   assert property(r_mult_change_rule)
      else $fatal("ASSERTION FAILURE: R_MULT_VALUE_CHANGE", 1);

    R_MULT_VALID_DEASSERT: assert property(r_mult_valid_deassert_rule)
      else $fatal("ASSERTION FAILURE R_MULT_VALID_DEASSERT", 1);
  `endif /* VERILATOR */
  `endif /* SYNTHESIS */

endmodule // mac_engine
