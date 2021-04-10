/*
 * Copyright (C) 2013-2017 ETH Zurich, University of Bologna
 * All rights reserved.
 *
 * This code is under development and not yet released to the public.
 * Until it is released, the code is under the copyright of ETH Zurich and
 * the University of Bologna, and may contain confidential and/or unpublished
 * work. Any reuse/redistribution is strictly forbidden without written
 * permission from ETH Zurich.
 *
 * Bug fixes and contributions will eventually be released under the
 * SolderPad open hardware license in the context of the PULP platform
 * (http://www.pulp-platform.org), under the copyright of ETH Zurich and the
 * University of Bologna.
 */

module tcdm_arbiter_2x1 (
    input logic clk_i,
    input logic rst_ni,

    XBAR_TCDM_BUS.Slave  tcdm_bus_1_i,
    XBAR_TCDM_BUS.Slave  tcdm_bus_0_i,
    XBAR_TCDM_BUS.Master tcdm_bus_o
);

  logic SEL_req;
  logic SEL_resp;
  logic RR_FLAG;

  enum logic [2:0] {
    IDLE,
    WAIT_GNT_0,
    WAIT_GNT_1,
    WAIT_VALID_0,
    WAIT_VALID_1
  }
      offset_fsm_cs, offset_fsm_ns;

  // offset FSM state transition logic
  always_comb begin
    offset_fsm_ns        = offset_fsm_cs;
    tcdm_bus_o.req       = 1'b0;
    tcdm_bus_0_i.gnt     = 1'b0;
    tcdm_bus_1_i.gnt     = 1'b0;
    tcdm_bus_0_i.r_valid = 1'b0;
    tcdm_bus_1_i.r_valid = 1'b0;
    tcdm_bus_0_i.r_rdata = tcdm_bus_o.r_rdata;
    tcdm_bus_1_i.r_rdata = tcdm_bus_o.r_rdata;
    tcdm_bus_o.add       = tcdm_bus_0_i.add;
    tcdm_bus_o.wen       = tcdm_bus_0_i.wen;
    tcdm_bus_o.wdata     = tcdm_bus_0_i.wdata;
    tcdm_bus_o.be        = tcdm_bus_0_i.be;

    unique case (offset_fsm_cs)

      IDLE: begin

        if (tcdm_bus_0_i.req) begin
          tcdm_bus_o.req   = tcdm_bus_0_i.req;
          tcdm_bus_0_i.gnt = tcdm_bus_o.gnt;
          tcdm_bus_o.add   = tcdm_bus_0_i.add;
          tcdm_bus_o.wen   = tcdm_bus_0_i.wen;
          tcdm_bus_o.wdata = tcdm_bus_0_i.wdata;
          tcdm_bus_o.be    = tcdm_bus_0_i.be;

          offset_fsm_ns    = tcdm_bus_o.gnt ? WAIT_VALID_0 : WAIT_GNT_0;
        end else if (tcdm_bus_1_i.req) begin
          tcdm_bus_o.req   = tcdm_bus_1_i.req;
          tcdm_bus_1_i.gnt = tcdm_bus_o.gnt;
          tcdm_bus_o.add   = tcdm_bus_1_i.add;
          tcdm_bus_o.wen   = tcdm_bus_1_i.wen;
          tcdm_bus_o.wdata = tcdm_bus_1_i.wdata;
          tcdm_bus_o.be    = tcdm_bus_1_i.be;

          offset_fsm_ns    = tcdm_bus_o.gnt ? WAIT_VALID_1 : WAIT_GNT_1;
        end
      end

      WAIT_GNT_0: begin
        tcdm_bus_o.req       = tcdm_bus_0_i.req;
        tcdm_bus_0_i.gnt     = tcdm_bus_o.gnt;
        tcdm_bus_0_i.r_valid = tcdm_bus_o.r_valid;
        tcdm_bus_o.add       = tcdm_bus_0_i.add;
        tcdm_bus_o.wen       = tcdm_bus_0_i.wen;
        tcdm_bus_o.wdata     = tcdm_bus_0_i.wdata;
        tcdm_bus_o.be        = tcdm_bus_0_i.be;
        offset_fsm_ns        = tcdm_bus_o.gnt ? WAIT_VALID_0 : WAIT_GNT_0;
      end

      WAIT_VALID_0: begin
        tcdm_bus_o.req       = tcdm_bus_0_i.req;
        tcdm_bus_0_i.gnt     = tcdm_bus_o.gnt;
        tcdm_bus_0_i.r_valid = tcdm_bus_o.r_valid;
        tcdm_bus_o.add       = tcdm_bus_0_i.add;
        tcdm_bus_o.wen       = tcdm_bus_0_i.wen;
        tcdm_bus_o.wdata     = tcdm_bus_0_i.wdata;
        tcdm_bus_o.be        = tcdm_bus_0_i.be;
        offset_fsm_ns        = tcdm_bus_o.r_valid ? IDLE : WAIT_VALID_0;
      end

      WAIT_GNT_1: begin
        tcdm_bus_o.req       = tcdm_bus_1_i.req;
        tcdm_bus_1_i.gnt     = tcdm_bus_o.gnt;
        tcdm_bus_1_i.r_valid = tcdm_bus_o.r_valid;
        tcdm_bus_o.add       = tcdm_bus_1_i.add;
        tcdm_bus_o.wen       = tcdm_bus_1_i.wen;
        tcdm_bus_o.wdata     = tcdm_bus_1_i.wdata;
        tcdm_bus_o.be        = tcdm_bus_1_i.be;
        offset_fsm_ns        = tcdm_bus_o.gnt ? WAIT_VALID_1 : WAIT_GNT_1;
      end

      WAIT_VALID_1: begin
        tcdm_bus_o.req       = tcdm_bus_1_i.req;
        tcdm_bus_1_i.gnt     = tcdm_bus_o.gnt;
        tcdm_bus_1_i.r_valid = tcdm_bus_o.r_valid;
        tcdm_bus_o.add       = tcdm_bus_1_i.add;
        tcdm_bus_o.wen       = tcdm_bus_1_i.wen;
        tcdm_bus_o.wdata     = tcdm_bus_1_i.wdata;
        tcdm_bus_o.be        = tcdm_bus_1_i.be;
        offset_fsm_ns        = tcdm_bus_o.r_valid ? IDLE : WAIT_VALID_1;
      end

    endcase
  end


  always_ff @(posedge clk_i or negedge rst_ni) begin : RR_SEL_resp_GEN
    if (~rst_ni) begin
      offset_fsm_cs <= IDLE;
    end else begin
      offset_fsm_cs <= offset_fsm_ns;
    end
  end


endmodule  // TCDM_BUS_2x1_ARB
