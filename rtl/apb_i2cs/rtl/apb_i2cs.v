// Copyright 2021 QuickLogic.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

/* ----------------------------------------------------------------------------
apb_i2cs.v

I2C peripheral (slave). Contains an I2C peripheral interface and an APB
slave interface. There are registers and FIFOs for handling communication
with an external I2C controller (master). Interrupts may be generated
in each direction.

Supports 7-bit I2C addressing.

---------------------------------------------------------------------------- */

module apb_i2cs (
    // APB interface
    apb_pclk_i,
    apb_presetn_i,
    apb_paddr_i,
    apb_psel_i,
    apb_penable_i,
    apb_pwrite_i,
    apb_pwdata_i,
    apb_pready_o,
    apb_prdata_o,
    apb_interrupt_o,

    // I2C pins
    i2c_scl_i,
    i2c_sda_i,
    i2c_sda_o,
    i2c_sda_oe,
    i2c_interrupt_o
);

  parameter [7:0] I2C_DEFAULT_DEBOUNCE_LEN = 20;
  parameter [7:0] I2C_DEFAULT_SCL_DELAY_LEN = 20;
  parameter [7:0] I2C_DEFAULT_SDA_DELAY_LEN = 8;

  // APB interface
  input apb_pclk_i;
  input apb_presetn_i;
  input [11:0] apb_paddr_i;
  input apb_psel_i;
  input apb_penable_i;
  input apb_pwrite_i;
  input [31:0] apb_pwdata_i;
  output apb_pready_o;
  output [31:0] apb_prdata_o;
  output apb_interrupt_o;

  // I2C pins
  input i2c_scl_i;
  input i2c_sda_i;
  output i2c_sda_o;
  output i2c_sda_oe;
  output i2c_interrupt_o;


  wire        apb_pclk_i;
  wire        apb_presetn_i;
  wire [11:0] apb_paddr_i;
  wire        apb_psel_i;
  wire        apb_penable_i;
  wire        apb_pwrite_i;
  wire [31:0] apb_pwdata_i;
  wire        apb_pready_o;
  wire [31:0] apb_prdata_o;
  wire        apb_interrupt_o;

  // I2C pins
  wire        i2c_scl_i;
  wire        i2c_sda_i;
  wire        i2c_sda_o;
  wire        i2c_sda_oe;
  wire        i2c_interrupt_o;


  // internal versions of the I2C signals
  wire        i2c_scl_in;
  wire        i2c_sda_in;
  wire        i2c_sda_out;



  wire        i2c_enabled;
  wire [ 6:0] i2c_dev_addr;
  wire [ 7:0] i2c_debounce_len;
  wire [ 7:0] i2c_scl_delay_len;
  wire [ 7:0] i2c_sda_delay_len;
  wire [ 7:0] i2c_reg_addr;
  wire [ 7:0] i2c_reg_wdata;
  wire        i2c_reg_wrenable;
  wire [ 7:0] i2c_reg_rddata;
  wire        i2c_reg_rd_byte_complete;

  wire [11:0] apb_reg_waddr;
  wire [31:0] apb_reg_wdata;
  wire        apb_reg_wrenable;
  wire [11:0] apb_reg_raddr;
  wire [31:0] apb_reg_rdata;
  wire        apb_reg_rd_byte_complete;


  // system clock and reset
  wire        clk;
  wire        rst;
  assign clk        = apb_pclk_i;
  assign rst        = !apb_presetn_i;


  assign i2c_scl_in = i2c_scl_i;
  assign i2c_sda_in = i2c_sda_i;
  assign I2c_sda_o  = 1'b0;
  assign i2c_sda_oe = ~i2c_sda_out; // oe is active high


  // I2C peripheral interface
  i2c_peripheral_interface i2c_peripheral_interface_i0 (
      .clk_i(clk),
      .rst_i(rst),

      // i2c pins
      .i2c_scl_i(i2c_scl_in),
      .i2c_sda_i(i2c_sda_in),
      .i2c_sda_o(i2c_sda_out),

      // interface to register module
      .i2c_dev_addr_i(i2c_dev_addr),  // the I2C address for this device (comes from reg block)
      .i2c_enabled_i(i2c_enabled),  // when low, ignore all I2C transactions
      .i2c_debounce_len_i(i2c_debounce_len),
      .i2c_scl_delay_len_i(i2c_scl_delay_len),
      .i2c_sda_delay_len_i(i2c_sda_delay_len),
      .i2c_reg_addr_o(i2c_reg_addr),
      .i2c_reg_wdata_o(i2c_reg_wdata),
      .i2c_reg_wrenable_o(i2c_reg_wrenable),
      .i2c_reg_rddata_i(i2c_reg_rddata),
      .i2c_reg_rd_byte_complete_o(i2c_reg_rd_byte_complete)
  );


  // APB slave interface
  apb_slave_interface apb_slave_interface_i0 (
      .apb_pclk_i   (clk),
      .apb_preset_i (rst),
      .apb_paddr_i  (apb_paddr_i),
      .apb_psel_i   (apb_psel_i),
      .apb_penable_i(apb_penable_i),
      .apb_pwrite_i (apb_pwrite_i),
      .apb_pwdata_i (apb_pwdata_i),
      .apb_pready_o (apb_pready_o),
      .apb_prdata_o (apb_prdata_o),

      // interface to register module
      .apb_reg_waddr_o           (apb_reg_waddr),
      .apb_reg_wdata_o           (apb_reg_wdata),
      .apb_reg_wrenable_o        (apb_reg_wrenable),
      .apb_reg_raddr_o           (apb_reg_raddr),
      .apb_reg_rdata_i           (apb_reg_rdata),
      .apb_reg_rd_byte_complete_o(apb_reg_rd_byte_complete)
  );


  // register module
  i2c_peripheral_registers #(
      .I2C_DEFAULT_DEBOUNCE_LEN (I2C_DEFAULT_DEBOUNCE_LEN),
      .I2C_DEFAULT_SCL_DELAY_LEN(I2C_DEFAULT_SCL_DELAY_LEN),
      .I2C_DEFAULT_SDA_DELAY_LEN(I2C_DEFAULT_SDA_DELAY_LEN)
  ) i2c_peripheral_registers_i0 (
      .clk_i(clk),
      .rst_i(rst),

      // APB reg interface
      .apb_reg_waddr_i           (apb_reg_waddr),
      .apb_reg_wdata_i           (apb_reg_wdata),
      .apb_reg_wrenable_i        (apb_reg_wrenable),
      .apb_reg_raddr_i           (apb_reg_raddr),
      .apb_reg_rdata_o           (apb_reg_rdata),
      .apb_reg_rd_byte_complete_i(apb_reg_rd_byte_complete),

      // i2c interfae
      .i2c_enabled_o             (i2c_enabled),
      .i2c_dev_addr_o            (i2c_dev_addr),
      .i2c_debounce_len_o        (i2c_debounce_len),
      .i2c_scl_delay_len_o       (i2c_scl_delay_len),
      .i2c_sda_delay_len_o       (i2c_sda_delay_len),
      .i2c_reg_addr_i            (i2c_reg_addr),
      .i2c_reg_wdata_i           (i2c_reg_wdata),
      .i2c_reg_wrenable_i        (i2c_reg_wrenable),
      .i2c_reg_rddata_o          (i2c_reg_rddata),
      .i2c_reg_rd_byte_complete_i(i2c_reg_rd_byte_complete),

      // interrupts
      .i2c_interrupt_o(i2c_interrupt_o),
      .apb_interrupt_o(apb_interrupt_o)
  );



endmodule
