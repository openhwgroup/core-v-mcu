// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


`define APB_ADDR_POPFIFO 5'h00
`define APB_ADDR_CONFIG 5'h04
`define APB_ADDR_STATUS 5'h08
`define APB_ADDR_ERRCLR 5'h0c
`define APB_ADDR_FIFOSTATUS 5'h10

module pulpemu_uart #(
    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_USER_WIDTH = 1,
    parameter AXI_ID_WIDTH   = 16,
    parameter BUFFER_DEPTH   = 8,
    parameter DUMMY_CYCLES   = 32
) (
    input  logic        mode_fmc_zynqn_i,
    input  logic        clk,
    input  logic        rst_n,
    // APB port (from Zynq PS)
    input  logic [31:0] apb_paddr,
    input  logic        apb_penable,
    output logic [31:0] apb_prdata,
    output logic [ 0:0] apb_pready,
    input  logic [ 0:0] apb_psel,
    output logic [ 0:0] apb_pslverr,
    input  logic [31:0] apb_pwdata,
    input  logic        apb_pwrite,
    // interrupt (to Zynq PS)
    output logic        uart_int_o,

    output logic uart_rx_o,
    input  logic uart_tx_i,
    // UART (from/to padframe or pulp)
    input  logic pads2pulp_uart_rx_i,
    output logic pads2pulp_uart_tx_o
);

  logic [15:0] cfg_div;
  logic        cfg_en;
  logic        cfg_parity_en;
  logic [ 1:0] cfg_bits;
  logic        cfg_stop_bits;
  logic        busy;
  logic        err;
  logic        err_clr;
  logic [ 7:0] rx_data;
  logic        rx_valid;
  logic        rx_ready;
  logic [ 7:0] apb_data;
  logic        apb_valid;
  logic        apb_ready;
  logic [31:0] apb_config;
  logic [31:0] apb_status;

  // zynq to/from pulp signals
  logic        zynq_pulp_uart_rx;
  logic        zynq_pulp_uart_tx;  // for later use should bidir be implemented

  // at the moment, only stdout is supported (no stdin via Zynq)
  udma_uart_rx uart_receiver_i (
      .clk_i          (clk),  // input
      .rstn_i         (rst_n),  // input
      .rx_i           (zynq_pulp_uart_rx),  // input
      .cfg_div_i      (cfg_div),  // input
      .cfg_en_i       (cfg_en),  // input
      .cfg_parity_en_i(cfg_parity_en),  // input
      .cfg_bits_i     (cfg_bits),  // input
      .cfg_stop_bits_i(cfg_stop_bits),  // input
      .busy_o         (busy),  // output
      .err_o          (err),  // output
      .err_clr_i      (err_clr),  // input
      .rx_data_o      (rx_data),  // output
      .rx_valid_o     (rx_valid),  // output
      .rx_ready_i     (rx_ready)  // input
  );

  // this (pretty big) FIFO temporarily hosts characters
  generic_fifo #(
      .DATA_WIDTH(8),
      .DATA_DEPTH(1024)
  ) uart_fifo_i (
      .clk        (clk),
      .rst_n      (rst_n),
      .data_i     (rx_data),
      .valid_i    (rx_valid),
      .grant_o    (rx_ready),
      .data_o     (apb_data),
      .valid_o    (apb_valid),
      .grant_i    (apb_ready),
      .test_mode_i(1'b0)
  );

  assign apb_pslverr = '0;
  assign apb_pready = 1'b1;
  assign apb_ready   = (apb_penable & apb_psel) & ((apb_paddr[4:0] == `APB_ADDR_POPFIFO) ? 1'b1 : 1'b0);

  always_ff @(posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
      apb_prdata <= '0;
      apb_config <= '0;
      err_clr <= 1'b0;
    end else if ((apb_psel & apb_pwrite) && (apb_paddr[4:0] == `APB_ADDR_CONFIG)) begin
      apb_prdata <= apb_pwdata;
      apb_config <= apb_pwdata;
      err_clr <= 1'b0;
    end else if ((apb_psel & apb_pwrite) && (apb_paddr[4:0] == `APB_ADDR_ERRCLR)) begin
      err_clr <= 1'b1;
    end else if ((apb_psel) && (apb_paddr[4:0] == `APB_ADDR_POPFIFO)) begin
      apb_prdata <= apb_valid ? {24'h0, apb_data} : '0;
      err_clr <= 1'b0;
    end else if ((apb_psel) && (apb_paddr[4:0] == `APB_ADDR_CONFIG)) begin
      apb_prdata <= apb_config;
      err_clr <= 1'b0;
    end else if ((apb_psel) && (apb_paddr[4:0] == `APB_ADDR_STATUS)) begin
      apb_prdata <= apb_status;
      err_clr <= 1'b0;
    end else if ((apb_psel) && (apb_paddr[4:0] == `APB_ADDR_FIFOSTATUS)) begin
      apb_prdata <= {31'h0, apb_valid};
      err_clr <= 1'b0;
    end else begin
      apb_prdata <= '0;
      err_clr <= 1'b0;
    end
  end

  assign cfg_div             = apb_config[31:16];
  assign cfg_en              = apb_config[15];
  assign cfg_parity_en       = apb_config[14];
  assign cfg_bits            = apb_config[13:12];
  assign cfg_stop_bits       = apb_config[11];

  assign apb_status          = {29'h0, ~apb_valid, err, busy};


  // -----------
  // mux to zynq/pads
  // -----------
  assign pads2pulp_uart_tx_o = mode_fmc_zynqn_i ? uart_tx_i : 1'b0;
  assign zynq_pulp_uart_rx   = mode_fmc_zynqn_i ? 1'b0 : pads2pulp_uart_rx_i;
  assign uart_rx_o           = mode_fmc_zynqn_i ? pads2pulp_uart_rx_i : 1'b0;

endmodule  // pulpemu_uart
