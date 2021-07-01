// Copyright 2021 QuickLogic.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module i2c_peripheral_registers (
    clk_i,
    rst_i,

    // APB reg interface
    apb_reg_waddr_i,
    apb_reg_wdata_i,
    apb_reg_wrenable_i,
    apb_reg_raddr_i,
    apb_reg_rdata_o,
    apb_reg_rd_byte_complete_i,

    // i2c reg interfae
    i2c_dev_addr_o,
    i2c_enabled_o,
    i2c_debounce_len_o,
    i2c_scl_delay_len_o,
    i2c_sda_delay_len_o,
    i2c_reg_addr_i,
    i2c_reg_wdata_i,
    i2c_reg_wrenable_i,
    i2c_reg_rddata_o,
    i2c_reg_rd_byte_complete_i,

    // interrupt outputs
    i2c_interrupt_o,
    apb_interrupt_o
);

  input clk_i;
  input rst_i;

  // APB reg interface
  input [11:0] apb_reg_waddr_i;
  input [31:0] apb_reg_wdata_i;
  input apb_reg_wrenable_i;
  input [11:0] apb_reg_raddr_i;
  output [31:0] apb_reg_rdata_o;
  input apb_reg_rd_byte_complete_i;

  // i2c interfae
  output [6:0] i2c_dev_addr_o;
  output i2c_enabled_o;
  output [7:0] i2c_debounce_len_o;
  output [7:0] i2c_scl_delay_len_o;
  output [7:0] i2c_sda_delay_len_o;
  input [7:0] i2c_reg_addr_i;
  input [7:0] i2c_reg_wdata_i;
  input i2c_reg_wrenable_i;
  output [7:0] i2c_reg_rddata_o;
  input i2c_reg_rd_byte_complete_i;

  // interrupts
  output i2c_interrupt_o;
  output apb_interrupt_o;


  parameter [6:0] I2C_DEFAULT_ADDR = 7'h6F;  // default I2C device address
  parameter [7:0] I2C_DEFAULT_DEBOUNCE_LEN = 20;
  parameter [7:0] I2C_DEFAULT_SCL_DELAY_LEN = 20;
  parameter [7:0] I2C_DEFAULT_SDA_DELAY_LEN = 8;


  wire        clk_i;
  wire        rst_i;

  // APB reg interface
  wire [11:0] apb_reg_waddr_i;
  wire [31:0] apb_reg_wdata_i;
  wire        apb_reg_wrenable_i;
  wire [11:0] apb_reg_raddr_i;
  wire [31:0] apb_reg_rdata_o;
  wire        apb_reg_rd_byte_complete_i;

  // i2c interfae
  wire [ 6:0] i2c_dev_addr_o;
  wire        i2c_enabled_o;
  wire [ 7:0] i2c_debounce_len_o;
  wire [ 7:0] i2c_scl_delay_len_o;
  wire [ 7:0] i2c_sda_delay_len_o;
  wire [ 7:0] i2c_reg_addr_i;
  wire [ 7:0] i2c_reg_wdata_i;
  wire        i2c_reg_wrenable_i;
  wire [ 7:0] i2c_reg_rddata_o;
  wire        i2c_reg_rd_byte_complete_i;

  // interrupts
  wire        i2c_interrupt_o;
  wire        apb_interrupt_o;


  wire        clk;
  wire        rst;

  assign clk = clk_i;
  assign rst = rst_i;


  reg        fifo_i2c_to_apb_push;
  wire [7:0] fifo_i2c_to_apb_wrdata;
  wire [2:0] fifo_i2c_to_apb_wrflags;
  wire       fifo_i2c_to_apb_full;
  reg        fifo_i2c_to_apb_pop;
  wire [7:0] fifo_i2c_to_apb_rddata;
  wire [2:0] fifo_i2c_to_apb_rdflags;
  wire       fifo_i2c_to_apb_empty;

  reg        fifo_apb_to_i2c_push;
  wire [7:0] fifo_apb_to_i2c_wrdata;
  wire [2:0] fifo_apb_to_i2c_wrflags;
  wire       fifo_apb_to_i2c_full;
  reg        fifo_apb_to_i2c_pop;
  wire [7:0] fifo_apb_to_i2c_rddata;
  wire [2:0] fifo_apb_to_i2c_rdflags;
  wire       fifo_apb_to_i2c_empty;



  // registers
  //  note that the offsets are different for the APB interface
  //  (APB uses d-word addresses, so APB offses are 4x)
  reg  [6:0] reg_0x00;  // i2c dev addr
  reg        reg_0x01;  // i2c enable
  reg  [7:0] reg_0x02;  // i2c debounce len
  reg  [7:0] reg_0x03;  // i2c scl delay len
  reg  [7:0] reg_0x04;  // i2c sda delay len
  reg  [7:0] reg_0x10;  // single-byte msg i2c-to-apb
  reg        reg_0x11;  // single-byte msg i2c-to-apb status
  reg  [7:0] reg_0x12;  // single-byte msg apb-to-i2c
  reg        reg_0x13;  // single-byte msg apb-to-i2c status
  reg  [7:0] reg_0x20;  // fifo i2c-to-apb write data port
  //reg     [7:0]   reg_0x21    ;   // fifo i2c-to-apb read data port
  reg        reg_0x22;  // fifo i2c-to-apb flush
  reg  [2:0] reg_0x23;  // fifo i2c-to-apb write flags
  reg  [2:0] reg_0x24;  // fifo i2c-to-apb read flags
  reg  [7:0] reg_0x30;  // fifo apb-to-i2c write data port
  reg  [7:0] reg_0x31;  // fifo apb-to-i2c read data port
  reg        reg_0x32;  // fifo apb-to-i2c flush
  reg  [2:0] reg_0x33;  // fifo apb-to-i2c write flags
  reg  [2:0] reg_0x34;  // fifo apb-to-i2c read flags
  wire [2:0] reg_0x40;  // interrupt to-i2c status
  reg  [2:0] reg_0x41;  // interrupt to-i2c enable
  reg  [7:0] reg_0x42;  // interrupt to-i2c - fifo i2c-to-apb write flags select
  reg  [7:0] reg_0x43;  // interrupt to-i2c - fifo apb-to-i2c read flags select
  wire [2:0] reg_0x50;  // interrupt to-apb status
  reg  [2:0] reg_0x51;  // interrupt to-apb enable
  reg  [7:0] reg_0x52;  // interrupt to-apb - fifo apb-to-i2c write flags select
  reg  [7:0] reg_0x53;  // interrupt to-apb - fifo i2c-to-apb read flags select


  wire       apb_reg_write_enable;
  assign apb_reg_write_enable = (apb_reg_waddr_i[11:10] == 2'b0 && apb_reg_wrenable_i);


  // assigments to the individual registers
  always @(posedge rst or posedge clk)
    if (rst) begin
      reg_0x00 <= I2C_DEFAULT_ADDR;
      reg_0x01 <= 0;
      reg_0x02 <= I2C_DEFAULT_DEBOUNCE_LEN;
      reg_0x03 <= I2C_DEFAULT_SCL_DELAY_LEN;
      reg_0x04 <= I2C_DEFAULT_SDA_DELAY_LEN;
      reg_0x10 <= 0;
      reg_0x11 <= 0;
      reg_0x12 <= 0;
      reg_0x13 <= 0;
      reg_0x20 <= 0;
      //reg_0x21 <= 0;    // fifo read port
      reg_0x22 <= 0;
      reg_0x23 <= 0;
      reg_0x24 <= 0;
      reg_0x30 <= 0;
      //reg_0x31 <= 0;    // fifo read port
      reg_0x32 <= 0;
      reg_0x33 <= 0;
      reg_0x34 <= 0;
      //reg_0x40 <= 0;    // read only
      reg_0x41 <= 0;
      reg_0x42 <= 0;
      reg_0x43 <= 0;
      //reg_0x50 <= 0;    // read only
      reg_0x51 <= 0;
      reg_0x52 <= 0;
      reg_0x53 <= 0;
      fifo_i2c_to_apb_push <= 1'b0;
    end else begin
      if (apb_reg_write_enable && apb_reg_waddr_i[9:2] == 8'h00) reg_0x00 <= apb_reg_wdata_i[6:0];

      if (apb_reg_write_enable && apb_reg_waddr_i[9:2] == 8'h01) reg_0x01 <= apb_reg_wdata_i[0];

      if (apb_reg_write_enable && apb_reg_waddr_i[9:2] == 8'h02) reg_0x02 <= apb_reg_wdata_i[7:0];

      if (apb_reg_write_enable && apb_reg_waddr_i[9:2] == 8'h03) reg_0x03 <= apb_reg_wdata_i[7:0];

      if (apb_reg_write_enable && apb_reg_waddr_i[9:2] == 8'h04) reg_0x04 <= apb_reg_wdata_i[7:0];

      if (i2c_reg_wrenable_i && i2c_reg_addr_i == 8'h10) reg_0x10 <= i2c_reg_wdata_i;

      case (reg_0x11)
        // set when reg_0x10 is written, clear when it's been read
        1'b0:
        if (i2c_reg_wrenable_i && i2c_reg_addr_i == 8'h10) reg_0x11 <= 1'b1;
        else reg_0x11 <= 1'b0;
        1'b1:
        if (apb_reg_rd_byte_complete_i && apb_reg_raddr_i[11:10]==2'b0 &&
            apb_reg_raddr_i[9:2]==8'h10 && apb_reg_raddr_i[1:0]==2'b0)
          reg_0x11 <= 1'b0;
        else reg_0x11 <= 1'b1;
        default: reg_0x11 <= 1'bx;
      endcase

      if (apb_reg_write_enable && apb_reg_waddr_i[9:2] == 8'h12) reg_0x12 <= apb_reg_wdata_i[7:0];

      case (reg_0x13)
        // set when reg_0x12 is written, clear when it's been read
        1'b0:
        if (apb_reg_write_enable && apb_reg_waddr_i[9:2] == 8'h12) reg_0x13 <= 1'b1;
        else reg_0x13 <= 1'b0;
        1'b1:
        if (i2c_reg_rd_byte_complete_i && i2c_reg_addr_i == 8'h12) reg_0x13 <= 1'b0;
        else reg_0x13 <= 1'b1;
        default: reg_0x13 <= 1'bx;
      endcase

      if (i2c_reg_wrenable_i && i2c_reg_addr_i == 8'h20) begin
        reg_0x20 <= i2c_reg_wdata_i;
        fifo_i2c_to_apb_push <= 1'b1;
      end else begin
        reg_0x20 <= reg_0x20;
        fifo_i2c_to_apb_push <= 1'b0;
      end

      // reg_0x21 - fifo read port
      if (apb_reg_waddr_i[11:10]==2'h0 && apb_reg_waddr_i[9:2]==8'h21 &&
                    apb_reg_waddr_i[1:0]==2'b0 && apb_reg_rd_byte_complete_i)
        fifo_i2c_to_apb_pop <= 1'b1;
      else fifo_i2c_to_apb_pop <= 1'b0;

      if (apb_reg_write_enable && apb_reg_waddr_i[9:2] == 8'h22) reg_0x22 <= apb_reg_wdata_i[0];
      else if (i2c_reg_wrenable_i && i2c_reg_addr_i == 8'h22) reg_0x22 <= i2c_reg_wdata_i[0];

      reg_0x23 <= fifo_i2c_to_apb_wrflags;

      reg_0x24 <= fifo_i2c_to_apb_rdflags;

      if (apb_reg_write_enable && apb_reg_waddr_i[9:2] == 8'h30) begin
        reg_0x30 <= apb_reg_wdata_i[7:0];
        fifo_apb_to_i2c_push <= 1'b1;
      end else begin
        reg_0x30 <= reg_0x30;
        fifo_apb_to_i2c_push <= 1'b0;
      end

      // reg_0x31 - fifo read port
      if (i2c_reg_addr_i == 8'h31 && i2c_reg_rd_byte_complete_i) fifo_apb_to_i2c_pop <= 1'b1;
      else fifo_apb_to_i2c_pop <= 1'b0;

      if (apb_reg_write_enable && apb_reg_waddr_i[9:2] == 8'h32) reg_0x32 <= apb_reg_wdata_i[0];
      else if (i2c_reg_wrenable_i && i2c_reg_addr_i == 8'h32) reg_0x32 <= i2c_reg_wdata_i[0];

      reg_0x33 <= fifo_apb_to_i2c_wrflags;

      reg_0x34 <= fifo_apb_to_i2c_rdflags;

      //reg_0x40 has more complicated logic and is implemented elsewhere

      if (i2c_reg_wrenable_i && i2c_reg_addr_i == 8'h41) reg_0x41 <= i2c_reg_wdata_i[2:0];

      if (i2c_reg_wrenable_i && i2c_reg_addr_i == 8'h42) reg_0x42 <= i2c_reg_wdata_i[7:0];

      if (i2c_reg_wrenable_i && i2c_reg_addr_i == 8'h43) reg_0x43 <= i2c_reg_wdata_i[7:0];

      //reg_0x50 has more complicated logic and is implemented elsewhere

      if (apb_reg_write_enable && apb_reg_waddr_i[9:2] == 8'h51) reg_0x51 <= apb_reg_wdata_i[2:0];

      if (apb_reg_write_enable && apb_reg_waddr_i[9:2] == 8'h52) reg_0x52 <= apb_reg_wdata_i[7:0];

      if (apb_reg_write_enable && apb_reg_waddr_i[9:2] == 8'h53) reg_0x53 <= apb_reg_wdata_i[7:0];

    end

  // interrupt toi2c status register, offset 0x40
  wire interrupt_toi2c_fifo_i2c_to_apb_wrflags;
  wire interrupt_toi2c_fifo_apb_to_i2c_rdflags;
  wire interrupt_toi2c_msg_apb_to_i2c_new;

  assign interrupt_toi2c_fifo_i2c_to_apb_wrflags = (
            reg_0x41[2] && (
                (reg_0x42[7] && (fifo_i2c_to_apb_wrflags[2:0]==3'b111)) ||
                (reg_0x42[6] && (fifo_i2c_to_apb_wrflags[2:0]==3'b110)) ||
                (reg_0x42[5] && (fifo_i2c_to_apb_wrflags[2:0]==3'b101)) ||
                (reg_0x42[4] && (fifo_i2c_to_apb_wrflags[2:0]==3'b100)) ||
                (reg_0x42[3] && (fifo_i2c_to_apb_wrflags[2:0]==3'b011)) ||
                (reg_0x42[2] && (fifo_i2c_to_apb_wrflags[2:0]==3'b010)) ||
                (reg_0x42[1] && (fifo_i2c_to_apb_wrflags[2:0]==3'b001)) ||
                (reg_0x42[0] && (fifo_i2c_to_apb_wrflags[2:0]==3'b000))
            )
        );
  assign interrupt_toi2c_fifo_apb_to_i2c_rdflags = (
            reg_0x41[1] && (
                (reg_0x43[7] && (fifo_apb_to_i2c_rdflags[2:0]==3'b111)) ||
                (reg_0x43[6] && (fifo_apb_to_i2c_rdflags[2:0]==3'b110)) ||
                (reg_0x43[5] && (fifo_apb_to_i2c_rdflags[2:0]==3'b101)) ||
                (reg_0x43[4] && (fifo_apb_to_i2c_rdflags[2:0]==3'b100)) ||
                (reg_0x43[3] && (fifo_apb_to_i2c_rdflags[2:0]==3'b011)) ||
                (reg_0x43[2] && (fifo_apb_to_i2c_rdflags[2:0]==3'b010)) ||
                (reg_0x43[1] && (fifo_apb_to_i2c_rdflags[2:0]==3'b001)) ||
                (reg_0x43[0] && (fifo_apb_to_i2c_rdflags[2:0]==3'b000))
            )
        );
  assign interrupt_toi2c_msg_apb_to_i2c_new = (reg_0x41[0] && reg_0x13);

  assign reg_0x40 = {
    interrupt_toi2c_fifo_i2c_to_apb_wrflags,
    interrupt_toi2c_fifo_apb_to_i2c_rdflags,
    interrupt_toi2c_msg_apb_to_i2c_new
  };


  // interrupt toapb status register, offset 0x50
  wire interrupt_toapb_fifo_apb_to_i2c_wrflags;
  wire interrupt_toapb_fifo_i2c_to_apb_rdflags;
  wire interrupt_toapb_msg_i2c_to_apb_new;

  assign interrupt_toapb_fifo_apb_to_i2c_wrflags = (
            reg_0x51[2] && (
                (reg_0x52[7] && (fifo_apb_to_i2c_wrflags[2:0]==3'b111)) ||
                (reg_0x52[6] && (fifo_apb_to_i2c_wrflags[2:0]==3'b110)) ||
                (reg_0x52[5] && (fifo_apb_to_i2c_wrflags[2:0]==3'b101)) ||
                (reg_0x52[4] && (fifo_apb_to_i2c_wrflags[2:0]==3'b100)) ||
                (reg_0x52[3] && (fifo_apb_to_i2c_wrflags[2:0]==3'b011)) ||
                (reg_0x52[2] && (fifo_apb_to_i2c_wrflags[2:0]==3'b010)) ||
                (reg_0x52[1] && (fifo_apb_to_i2c_wrflags[2:0]==3'b001)) ||
                (reg_0x52[0] && (fifo_apb_to_i2c_wrflags[2:0]==3'b000))
            )
        );
  assign interrupt_toapb_fifo_i2c_to_apb_rdflags = (
            reg_0x51[1] && (
                (reg_0x53[7] && (fifo_i2c_to_apb_rdflags[2:0]==3'b111)) ||
                (reg_0x53[6] && (fifo_i2c_to_apb_rdflags[2:0]==3'b110)) ||
                (reg_0x53[5] && (fifo_i2c_to_apb_rdflags[2:0]==3'b101)) ||
                (reg_0x53[4] && (fifo_i2c_to_apb_rdflags[2:0]==3'b100)) ||
                (reg_0x53[3] && (fifo_i2c_to_apb_rdflags[2:0]==3'b011)) ||
                (reg_0x53[2] && (fifo_i2c_to_apb_rdflags[2:0]==3'b010)) ||
                (reg_0x53[1] && (fifo_i2c_to_apb_rdflags[2:0]==3'b001)) ||
                (reg_0x53[0] && (fifo_i2c_to_apb_rdflags[2:0]==3'b000))
            )
        );
  assign interrupt_toapb_msg_i2c_to_apb_new = (reg_0x51[0] && reg_0x11);

  assign reg_0x50 = {
    interrupt_toapb_fifo_apb_to_i2c_wrflags,
    interrupt_toapb_fifo_i2c_to_apb_rdflags,
    interrupt_toapb_msg_i2c_to_apb_new
  };



  // APB read interface
  reg  [31:0] apb_reg_rdata;
  wire [ 7:0] apb_reg_rd_index;
  reg  [ 7:0] apb_reg_rdata_muxed;

  assign apb_reg_rd_index = apb_reg_raddr_i[9:2];  // align all registers to 32-bit words

  // read mux for APB interface
  always @(*)
    if (apb_reg_raddr_i[11:10] == 2'b0)
      case (apb_reg_rd_index)
        8'h00:   apb_reg_rdata_muxed <= {1'b0, reg_0x00[6:0]};
        8'h01:   apb_reg_rdata_muxed <= {7'b0, reg_0x01};
        8'h02:   apb_reg_rdata_muxed <= {reg_0x02[7:0]};
        8'h03:   apb_reg_rdata_muxed <= {reg_0x03[7:0]};
        8'h04:   apb_reg_rdata_muxed <= {reg_0x04[7:0]};
        8'h10:   apb_reg_rdata_muxed <= {reg_0x10[7:0]};
        8'h11:   apb_reg_rdata_muxed <= {7'b0, reg_0x11};
        8'h12:   apb_reg_rdata_muxed <= {reg_0x12[7:0]};
        8'h13:   apb_reg_rdata_muxed <= {7'b0, reg_0x13};
        8'h20:   apb_reg_rdata_muxed <= {8'h0};
        8'h21:   apb_reg_rdata_muxed <= {fifo_i2c_to_apb_rddata[7:0]};
        8'h22:   apb_reg_rdata_muxed <= {7'b0, reg_0x22};
        8'h23:   apb_reg_rdata_muxed <= {5'b0, reg_0x23[2:0]};
        8'h24:   apb_reg_rdata_muxed <= {5'b0, reg_0x24[2:0]};
        8'h30:   apb_reg_rdata_muxed <= {8'h0};
        8'h31:   apb_reg_rdata_muxed <= {8'h0};
        8'h32:   apb_reg_rdata_muxed <= {7'b0, reg_0x32};
        8'h33:   apb_reg_rdata_muxed <= {5'b0, reg_0x33[2:0]};
        8'h34:   apb_reg_rdata_muxed <= {5'b0, reg_0x34[2:0]};
        8'h40:   apb_reg_rdata_muxed <= {5'b0, reg_0x40[2:0]};
        8'h41:   apb_reg_rdata_muxed <= {5'b0, reg_0x41[2:0]};
        8'h42:   apb_reg_rdata_muxed <= {reg_0x42[7:0]};
        8'h43:   apb_reg_rdata_muxed <= {reg_0x43[7:0]};
        8'h50:   apb_reg_rdata_muxed <= {5'b0, reg_0x50[2:0]};
        8'h51:   apb_reg_rdata_muxed <= {5'b0, reg_0x51[2:0]};
        8'h52:   apb_reg_rdata_muxed <= {reg_0x52[7:0]};
        8'h53:   apb_reg_rdata_muxed <= {reg_0x53[7:0]};
        default: apb_reg_rdata_muxed <= 8'h0;
      endcase
    else apb_reg_rdata_muxed <= 8'h0;


  always @(posedge rst or posedge clk)
    if (rst) apb_reg_rdata <= 0;
    else apb_reg_rdata <= {24'b0, apb_reg_rdata_muxed[7:0]};


  // I2C read interface
  reg [7:0] i2c_reg_rdata;
  reg [7:0] i2c_reg_rdata_muxed;

  always @(*)
    case (i2c_reg_addr_i)
      8'h00:   i2c_reg_rdata_muxed <= {1'b0, reg_0x00[6:0]};
      8'h01:   i2c_reg_rdata_muxed <= {7'b0, reg_0x01};
      8'h02:   i2c_reg_rdata_muxed <= {reg_0x02[7:0]};
      8'h03:   i2c_reg_rdata_muxed <= {reg_0x03[7:0]};
      8'h04:   i2c_reg_rdata_muxed <= {reg_0x04[7:0]};
      8'h10:   i2c_reg_rdata_muxed <= {reg_0x10[7:0]};
      8'h11:   i2c_reg_rdata_muxed <= {7'b0, reg_0x11};
      8'h12:   i2c_reg_rdata_muxed <= {reg_0x12[7:0]};
      8'h13:   i2c_reg_rdata_muxed <= {7'b0, reg_0x13};
      8'h20:   i2c_reg_rdata_muxed <= {8'h0};
      8'h21:   i2c_reg_rdata_muxed <= {8'h0};
      8'h22:   i2c_reg_rdata_muxed <= {7'b0, reg_0x22};
      8'h23:   i2c_reg_rdata_muxed <= {5'b0, reg_0x23[2:0]};
      8'h24:   i2c_reg_rdata_muxed <= {5'b0, reg_0x24[2:0]};
      8'h30:   i2c_reg_rdata_muxed <= {8'h0};
      8'h31:   i2c_reg_rdata_muxed <= {fifo_apb_to_i2c_rddata};
      8'h32:   i2c_reg_rdata_muxed <= {7'b0, reg_0x32};
      8'h33:   i2c_reg_rdata_muxed <= {5'b0, reg_0x33[2:0]};
      8'h34:   i2c_reg_rdata_muxed <= {5'b0, reg_0x34[2:0]};
      8'h40:   i2c_reg_rdata_muxed <= {5'b0, reg_0x40[2:0]};
      8'h41:   i2c_reg_rdata_muxed <= {5'b0, reg_0x41[2:0]};
      8'h42:   i2c_reg_rdata_muxed <= {reg_0x42[7:0]};
      8'h43:   i2c_reg_rdata_muxed <= {reg_0x43[7:0]};
      8'h50:   i2c_reg_rdata_muxed <= {5'b0, reg_0x50[2:0]};
      8'h51:   i2c_reg_rdata_muxed <= {5'b0, reg_0x51[2:0]};
      8'h52:   i2c_reg_rdata_muxed <= {reg_0x52[7:0]};
      8'h53:   i2c_reg_rdata_muxed <= {reg_0x53[7:0]};
      default: i2c_reg_rdata_muxed <= 8'bx;
    endcase

  always @(posedge rst or posedge clk)
    if (rst) i2c_reg_rdata <= 0;
    else i2c_reg_rdata <= i2c_reg_rdata_muxed;


  // I2C to APB FIFO
  assign fifo_i2c_to_apb_wrdata = reg_0x20;

  FIFO_sync_256x8 FIFO_sync_256x8_i2c_to_apb (
      .rst_i     (rst),
      .clk_i     (clk),
      .push_i    (fifo_i2c_to_apb_push),
      .wr_data_i (fifo_i2c_to_apb_wrdata),
      .full_o    (fifo_i2c_to_apb_full),
      .wr_flags_o(fifo_i2c_to_apb_wrflags),
      .pop_i     (fifo_i2c_to_apb_pop),
      .rd_data_o (fifo_i2c_to_apb_rddata),
      .empty_o   (fifo_i2c_to_apb_empty),
      .rd_flags_o(fifo_i2c_to_apb_rdflags)
  );

  // APB to I2C FIFO
  assign fifo_apb_to_i2c_wrdata = reg_0x30;

  FIFO_sync_256x8 FIFO_sync_256x8_apb_to_i2c (
      .rst_i     (rst),
      .clk_i     (clk),
      .push_i    (fifo_apb_to_i2c_push),
      .wr_data_i (fifo_apb_to_i2c_wrdata),
      .full_o    (fifo_apb_to_i2c_full),
      .wr_flags_o(fifo_apb_to_i2c_wrflags),
      .pop_i     (fifo_apb_to_i2c_pop),
      .rd_data_o (fifo_apb_to_i2c_rddata),
      .empty_o   (fifo_apb_to_i2c_empty),
      .rd_flags_o(fifo_apb_to_i2c_rdflags)
  );


  assign apb_reg_rdata_o     = apb_reg_rdata;
  assign i2c_reg_rddata_o    = i2c_reg_rdata;

  assign i2c_dev_addr_o      = reg_0x00[6:0];
  assign i2c_enabled_o       = reg_0x01;
  assign i2c_debounce_len_o  = reg_0x02[7:0];
  assign i2c_scl_delay_len_o = reg_0x03[7:0];
  assign i2c_sda_delay_len_o = reg_0x04[7:0];

  assign i2c_interrupt_o     = |reg_0x40[2:0];
  assign apb_interrupt_o     = |reg_0x50[2:0];


endmodule
