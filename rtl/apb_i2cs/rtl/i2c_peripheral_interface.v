/* ----------------------------------------------------------------------------
i2c_peripheral_interface.v

Based on the opencores i2c slave written by Steve Fielding (refer to the
original copyright information appended to the end of this file).


---------------------------------------------------------------------------- */

module i2c_peripheral_interface (
    clk_i,
    rst_i,

    // i2c pins
    i2c_scl_i,
    i2c_sda_i,
    i2c_sda_o,

    // interface to registers
    i2c_dev_addr_i,  // the I2C address for this device (comes from reg block)
    i2c_enabled_i,  // when low, ignore all I2C transactions
    i2c_debounce_len_i,
    i2c_scl_delay_len_i,
    i2c_sda_delay_len_i,
    i2c_reg_addr_o,
    i2c_reg_wdata_o,
    i2c_reg_wrenable_o,
    i2c_reg_rddata_i,
    i2c_reg_rd_byte_complete_o
);

  // These parameters represent the maximum length for the debounce/delay shift
  //  registers. The actual lengths to be used are programmable via registers,
  //  and are fed into this module from the register module. The default lengths
  //  for these shift registers, below, represent appropriate lengths for a
  //  100MHz system clock. These parameters can be adjusted if a different
  //  system clock rate is used (e.g. for a 200MHz system clock, these parameters
  //  should all be doubled).
  parameter integer I2C_DEBOUNCE_LEN_MAX = 20;
  parameter integer SCL_DELAY_LEN_MAX = 20;
  parameter integer SDA_DELAY_LEN_MAX = 8;

  input clk_i;
  input rst_i;

  // i2c pins
  input i2c_scl_i;
  input i2c_sda_i;
  output i2c_sda_o;

  // interface to registers
  input [6:0] i2c_dev_addr_i;
  input i2c_enabled_i;
  input [7:0] i2c_debounce_len_i;
  input [7:0] i2c_scl_delay_len_i;
  input [7:0] i2c_sda_delay_len_i;
  output [7:0] i2c_reg_addr_o;
  output [7:0] i2c_reg_wdata_o;
  output i2c_reg_wrenable_o;
  input [7:0] i2c_reg_rddata_i;
  output i2c_reg_rd_byte_complete_o;


  wire       clk_i;
  wire       rst_i;

  // i2c pins
  wire       i2c_scl_i;
  wire       i2c_sda_i;
  wire       i2c_sda_o;

  // interface to registers
  wire [6:0] i2c_dev_addr_i;
  wire       i2c_enabled_i;
  wire [7:0] i2c_debounce_len_i;
  wire [7:0] i2c_scl_delay_len_i;
  wire [7:0] i2c_sda_delay_len_i;
  wire [7:0] i2c_reg_addr_o;
  wire [7:0] i2c_reg_wdata_o;
  wire       i2c_reg_wrenable_o;
  wire [7:0] i2c_reg_rddata_i;
  wire       i2c_reg_rd_byte_complete_o;

  reg        sda_out;
  reg        i2c_reg_wrenable;

  reg        i2c_rd_byte_complete;


  wire       clk;
  wire       rst;
  assign clk = clk_i;
  assign rst = rst_i;


  // debounce the I2C lines
  reg [I2C_DEBOUNCE_LEN_MAX-1:0] scl_deb_pipe;
  reg [I2C_DEBOUNCE_LEN_MAX-1:0] sda_deb_pipe;
  reg                            scl_deb;
  reg                            sda_deb;

  always @(posedge rst or posedge clk)
    if (rst) begin
      scl_deb_pipe <= {I2C_DEBOUNCE_LEN_MAX{1'b1}};
      sda_deb_pipe <= {I2C_DEBOUNCE_LEN_MAX{1'b1}};
      scl_deb <= 1'b1;
      sda_deb <= 1'b1;
    end else begin
      scl_deb_pipe <= {scl_deb_pipe[I2C_DEBOUNCE_LEN_MAX-2:0], i2c_scl_i};
      sda_deb_pipe <= {sda_deb_pipe[I2C_DEBOUNCE_LEN_MAX-2:0], i2c_sda_i};

      if (&scl_deb_pipe[I2C_DEBOUNCE_LEN_MAX-1:1] == 1'b1) scl_deb <= 1'b1;
      else if (|scl_deb_pipe[I2C_DEBOUNCE_LEN_MAX-1:1] == 1'b0) scl_deb <= 1'b0;
      else scl_deb <= scl_deb;

      if (&sda_deb_pipe[I2C_DEBOUNCE_LEN_MAX-1:1] == 1'b1) sda_deb <= 1'b1;
      else if (|sda_deb_pipe[I2C_DEBOUNCE_LEN_MAX-1:1] == 1'b0) sda_deb <= 1'b0;
      else sda_deb <= sda_deb;
    end


  // delay the scl and sda signals
  // from the opencores IP written by Steve Fielding:
  // // sclDelayed is used as a delayed sampling clock
  // // sdaDelayed is only used for start stop detection
  // // Because sda hold time from scl falling is 0nS
  // // sda must be delayed with respect to scl to avoid incorrect
  // // detection of start/stop at scl falling edge.
  reg [SCL_DELAY_LEN_MAX-1:0] scl_delay_pipe;
  reg [SDA_DELAY_LEN_MAX-1:0] sda_delay_pipe;

  always @(posedge rst or posedge clk)
    if (rst) begin
      scl_delay_pipe <= {SCL_DELAY_LEN_MAX{1'b1}};
      sda_delay_pipe <= {SDA_DELAY_LEN_MAX{1'b1}};
    end else begin
      scl_delay_pipe <= {scl_delay_pipe[SCL_DELAY_LEN_MAX-2:0], scl_deb};
      sda_delay_pipe <= {sda_delay_pipe[SDA_DELAY_LEN_MAX-2:0], sda_deb};
    end


  // start stop detection
  reg start_detect;  // start or repeated start
  reg stop_detect;

  always @(posedge rst or posedge clk)
    if (rst) begin
      start_detect <= 1'b0;
      stop_detect  <= 1'b0;
    end else begin
      if (scl_deb == 1'b1 && sda_delay_pipe[SDA_DELAY_LEN_MAX-2] == 1'b0 && sda_delay_pipe[SDA_DELAY_LEN_MAX-1] == 1'b1)
        start_detect <= 1'b1;
      else start_detect <= 1'b0;

      if (scl_deb == 1'b1 && sda_delay_pipe[SDA_DELAY_LEN_MAX-2] == 1'b1 && sda_delay_pipe[SDA_DELAY_LEN_MAX-1] == 1'b0)
        stop_detect <= 1'b1;
      else stop_detect <= 1'b0;
    end


  // I2C protocol state machine
  (* mark_debug = "true" *)   wire       scl_sm;
  (* mark_debug = "true" *)   wire       sda_sm;
  (* mark_debug = "true" *)   reg        scl_sm_r1;
  (* mark_debug = "true" *)   reg  [3:0] i2c_state;
  localparam [3:0] ST_IDLE = 4'h0;
  localparam [3:0] ST_DEVADDR = 4'h1;
  localparam [3:0] ST_DEVADDRACK = 4'h2;
  localparam [3:0] ST_REGADDR = 4'h3;
  localparam [3:0] ST_REGADDRACK = 4'h4;
  localparam [3:0] ST_REGWDATA = 4'h5;
  localparam [3:0] ST_REGWDATAACK = 4'h6;
  localparam [3:0] ST_REGRDATA = 4'h7;
  localparam [3:0] ST_REGRDATAACK = 4'h8;
  localparam [3:0] ST_WTSTOP = 4'h9;

  reg       bit_xfer;
  reg       bit_rcvd;
  (* mark_debug = "true" *) reg [3:0] bit_cnt;
  reg [7:0] in_byte;
  (* mark_debug = "true" *)   reg [7:0] out_byte;
  reg       xfer_type_rd_wrn;
  reg [7:0] reg_addr;
  reg [7:0] reg_wdata;
  reg       reg_wenable;
  reg       reg_rcomplete;

  assign scl_sm = scl_delay_pipe[SCL_DELAY_LEN_MAX-1];
  assign sda_sm = sda_deb;

  always @(posedge rst or posedge clk)
    if (rst) scl_sm_r1 <= 1'b0;
    else scl_sm_r1 <= scl_sm;

  always @(posedge rst or posedge clk)
    if (rst) begin
      bit_xfer <= 1'b0;
      bit_rcvd <= 1'b0;
    end else begin
      if (scl_sm && !scl_sm_r1) begin
        bit_xfer <= 1'b1;
        bit_rcvd <= sda_sm;
      end else begin
        bit_xfer <= 1'b0;
        bit_rcvd <= bit_rcvd;
      end
    end



  always @(posedge rst or posedge clk)
    if (rst) begin
      i2c_state <= ST_IDLE;
      bit_cnt <= 0;
      in_byte <= 0;
      out_byte <= 0;
      xfer_type_rd_wrn <= 1'b0;
      reg_addr <= 0;
      sda_out <= 1'b1;
      i2c_reg_wrenable <= 1'b0;
      i2c_rd_byte_complete <= 1'b0;
    end else begin
      case (i2c_state)
        ST_IDLE:    // wait for START
                begin
          bit_cnt <= 0;
          in_byte <= 0;
          sda_out <= 1'b1;
          if (start_detect && i2c_enabled_i) i2c_state <= ST_DEVADDR;
          else i2c_state <= ST_IDLE;
        end
        ST_DEVADDR: // shift in the Device Addr
                begin
          sda_out <= 1'b1;
          if (bit_xfer) begin
            bit_cnt <= bit_cnt + 1;
            in_byte <= {in_byte[6:0], bit_rcvd};
          end else begin
            bit_cnt <= bit_cnt;
            in_byte <= in_byte;
          end
          if (stop_detect) begin
            i2c_state <= ST_IDLE;
          end else begin
            if ((bit_cnt == 8) && (!scl_sm && scl_sm_r1)) begin
              if (in_byte[7:1] == i2c_dev_addr_i) begin
                bit_cnt <= 0;
                i2c_state <= ST_DEVADDRACK;
                xfer_type_rd_wrn <= in_byte[0];
              end else begin
                bit_cnt   <= 0;
                i2c_state <= ST_WTSTOP;
              end
            end
          end
        end
        ST_DEVADDRACK:  // Dev Addr rcvd, send ACK
                begin
          bit_cnt <= 0;
          sda_out <= 1'b0;  // ACK
          if (stop_detect) begin
            i2c_state <= ST_IDLE;
          end else begin
            if (!scl_sm && scl_sm_r1) begin
              sda_out <= 1'b1;  // release ACK
              if (xfer_type_rd_wrn == 1'b1) begin
                i2c_state <= ST_REGRDATA;
                out_byte  <= i2c_reg_rddata_i;
              end else begin
                i2c_state <= ST_REGADDR;
              end
            end else begin
              i2c_state <= ST_DEVADDRACK;
            end
          end
        end
        ST_REGADDR: // store the Register Addr
                begin
          if (bit_xfer) begin
            bit_cnt <= bit_cnt + 1;
            in_byte <= {in_byte[6:0], bit_rcvd};
          end else begin
            bit_cnt <= bit_cnt;
            in_byte <= in_byte;
          end
          if (stop_detect) begin
            i2c_state <= ST_IDLE;
          end else begin
            if (start_detect) begin
              i2c_state <= ST_DEVADDR;
              bit_cnt   <= 0;
            end else begin
              if ((bit_cnt == 8) && (!scl_sm && scl_sm_r1)) begin
                reg_addr  <= in_byte;
                i2c_state <= ST_REGADDRACK;
              end
            end
          end
        end
        ST_REGADDRACK:  // register addr rcvd, send ACK
                begin
          bit_cnt <= 0;
          sda_out <= 1'b0;  // ACK
          if (stop_detect) begin
            i2c_state <= ST_IDLE;
          end else begin
            if (!scl_sm && scl_sm_r1) begin
              sda_out   <= 1'b1;  // release ACK
              i2c_state <= ST_REGWDATA;
            end
          end
        end
        ST_REGWDATA:    // shift in the write byte
                begin
          if (bit_xfer) begin
            bit_cnt <= bit_cnt + 1;
            in_byte <= {in_byte[6:0], bit_rcvd};
          end else begin
            bit_cnt <= bit_cnt;
            in_byte <= in_byte;
          end
          if (stop_detect) begin
            i2c_state <= ST_IDLE;
          end else begin
            if (start_detect) begin
              i2c_state <= ST_DEVADDR;
              bit_cnt   <= 0;
            end else begin
              if ((bit_cnt == 8) && (!scl_sm && scl_sm_r1)) begin
                i2c_reg_wrenable <= 1'b1;
                i2c_state <= ST_REGWDATAACK;
              end
            end
          end
        end
        ST_REGWDATAACK: // write data rcvd, send ACK
                begin
          bit_cnt <= 0;
          i2c_reg_wrenable <= 1'b0;
          sda_out <= 1'b0;  // ACK
          if (stop_detect) begin
            i2c_state <= ST_IDLE;
          end else begin
            if (!scl_sm && scl_sm_r1) begin
              sda_out   <= 1'b1;  // release ACK
              i2c_state <= ST_REGWDATA;
            end
          end
        end
        ST_REGRDATA:    // shift out the read data
                begin
          sda_out <= out_byte[7];
          if (stop_detect) begin
            i2c_state <= ST_IDLE;
          end else begin
            if (bit_cnt == 8) begin
              // release sda
              sda_out <= 1'b1;
              i2c_state <= ST_REGRDATAACK;
              bit_cnt <= 0;
              i2c_rd_byte_complete <= 1'b1;
            end else begin
              if (!scl_sm && scl_sm_r1) begin
                out_byte <= {out_byte[6:0], 1'b0};
                bit_cnt  <= bit_cnt + 1;
              end
            end
          end
        end
        ST_REGRDATAACK: // wait for ACK/NACK
                begin
          i2c_rd_byte_complete <= 1'b0;
          sda_out <= 1'b1;
          bit_cnt <= 0;
          if (stop_detect) begin
            i2c_state <= ST_IDLE;
          end else begin
            // check for NACK
            if (bit_xfer) begin
              if (bit_rcvd == 1'b0) begin  // NACK
                i2c_state <= ST_WTSTOP;
              end else begin  // ACK
                out_byte  <= i2c_reg_rddata_i;
                i2c_state <= ST_REGRDATA;
              end
            end
          end
        end
        ST_WTSTOP:  // wait for STOP
                begin
          bit_cnt <= 0;
          in_byte <= 0;
          if (stop_detect) begin
            i2c_state <= ST_IDLE;
          end else begin
            i2c_state <= ST_WTSTOP;
          end
        end
        default: begin
          i2c_state <= ST_IDLE;
        end
      endcase
    end

  assign i2c_sda_o = sda_out;
  assign i2c_reg_addr_o = reg_addr;
  assign i2c_reg_wdata_o = in_byte;

  assign i2c_reg_rd_byte_complete_o = i2c_rd_byte_complete;

endmodule


//////////////////////////////////////////////////////////////////////
////                                                              ////
//// i2cSlave.v                                                   ////
////                                                              ////
//// This file is part of the i2cSlave opencores effort.
//// <http://www.opencores.org/cores//>                           ////
////                                                              ////
//// Module Description:                                          ////
//// You will need to modify this file to implement your
//// interface.
////                                                              ////
//// To Do:                                                       ////
////
////                                                              ////
//// Author(s):                                                   ////
//// - Steve Fielding, sfielding@base2designs.com                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 Steve Fielding and OPENCORES.ORG          ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from <http://www.opencores.org/lgpl.shtml>                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
