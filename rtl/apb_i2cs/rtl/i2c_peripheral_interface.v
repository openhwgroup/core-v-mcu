// Copyright 2021 QuickLogic.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

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


  // sample the I2C lines

  reg [2:0]                      scl_d, sda_d;
  reg                            scl_cs,scl_ls, sda_cs, sda_ls;

  always @(posedge rst or posedge clk) begin
    if (rst == 1) begin
      scl_d <= 3'b111;
      sda_d <= 3'b111;
      scl_cs <= 1;
      scl_ls <= 1;
      sda_cs <= 1;
      sda_ls <= 1;
    end
    else begin
      scl_d <= {scl_d[1:0],i2c_scl_i};
      sda_d <= {sda_d[1:0],i2c_sda_i};
      case (scl_d)
        3'b000: scl_cs <= 0;
        3'b111: scl_cs <= 1;
        default: scl_cs <= scl_cs;
      endcase // case (scl_d)
      case (sda_d)
        3'b000: sda_cs <= 0;
        3'b111: sda_cs <= 1;
        default: sda_cs <= scl_cs;
      endcase // case (sda_d)
      scl_ls <= scl_cs;
      sda_ls <= sda_ls;
    end // else: !if(rst == 1)
  end // always @ (posedge rst or posedge clk)




  // start stop detection
  reg start_detect;  // start or repeated start
  reg stop_detect;

  always @(posedge rst or posedge clk) begin
    if (rst) begin
      start_detect <= 1'b0;
      stop_detect  <= 1'b0;
    end else begin
      start_detect <= scl_cs ? sda_ls & ~sda_cs : 0;
      stop_detect <= scl_cs ?  ~sda_ls & sda_cs : 0;
    end
  end

  // I2C protocol state machine
  reg  [3:0] i2c_state;
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
  reg [3:0] bit_cnt;
  reg [7:0] in_byte;
  reg [7:0] out_byte;
  reg       xfer_type_rd_wrn;
  reg [7:0] reg_addr;
  reg [7:0] reg_wdata;
  reg       reg_wenable;
  reg       reg_rcomplete;


  always @(posedge rst or posedge clk)
    if (rst) begin
      bit_xfer <= 1'b0;
      bit_rcvd <= 1'b0;
    end else begin
      if (scl_cs && ~scl_ls) begin
        bit_xfer <= 1'b1;
        bit_rcvd <= sda_cs;
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
            if ((bit_cnt == 8) && (!scl_cs && scl_ls)) begin
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
            if (!scl_cs && scl_ls) begin
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
              if ((bit_cnt == 8) && (!scl_cs && scl_ls)) begin
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
            if (!scl_cs && scl_ls) begin
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
              if ((bit_cnt == 8) && (!scl_cs && scl_ls)) begin
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
            if (!scl_cs && scl_ls) begin
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
              if (!scl_cs && scl_ls) begin
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
              if (bit_rcvd == 1'b1) begin  // NACK
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
