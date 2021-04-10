// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


`define Z2P_SPI_SLAVE 1'b0
`define Z2P_UART 1'b1

module pulpemu_apb_demux (
    input  logic        clk,
    input  logic        rst_n,
    /* APB interface from ZYNQ */
    input  logic [31:0] zynq2pulp_apb_paddr,
    input  logic        zynq2pulp_apb_penable,
    output logic [31:0] zynq2pulp_apb_prdata,
    output logic        zynq2pulp_apb_pready,
    input  logic        zynq2pulp_apb_psel,
    output logic        zynq2pulp_apb_pslverr,
    input  logic [31:0] zynq2pulp_apb_pwdata,
    input  logic        zynq2pulp_apb_pwrite,
    /* APB interface to pulpemu_spi_slave */
    output logic [31:0] zynq2pulp_spi_slave_paddr,
    output logic        zynq2pulp_spi_slave_penable,
    input  logic [31:0] zynq2pulp_spi_slave_prdata,
    input  logic        zynq2pulp_spi_slave_pready,
    output logic        zynq2pulp_spi_slave_psel,
    input  logic        zynq2pulp_spi_slave_pslverr,
    output logic [31:0] zynq2pulp_spi_slave_pwdata,
    output logic        zynq2pulp_spi_slave_pwrite,
    /* APB interface to pulpemu_uart */
    output logic [31:0] zynq2pulp_uart_paddr,
    output logic        zynq2pulp_uart_penable,
    input  logic [31:0] zynq2pulp_uart_prdata,
    input  logic        zynq2pulp_uart_pready,
    output logic        zynq2pulp_uart_psel,
    input  logic        zynq2pulp_uart_pslverr,
    output logic [31:0] zynq2pulp_uart_pwdata,
    output logic        zynq2pulp_uart_pwrite
);

  logic last_sel;

  always_ff @(posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
      last_sel <= `Z2P_SPI_SLAVE;
    end else begin
      if (zynq2pulp_apb_psel == 1'b1) begin
        if (zynq2pulp_apb_paddr[15:14] == 2'b00) begin  // 0x51010000 - 0x51013ffc
          last_sel <= `Z2P_SPI_SLAVE;
        end else if (zynq2pulp_apb_paddr[15:14] == 2'b01) begin  // 0x51014000 - 0x51017ffc
          last_sel <= `Z2P_UART;
        end
      end
    end
  end

  // psel demuxing
  assign zynq2pulp_spi_slave_psel = zynq2pulp_apb_psel & (zynq2pulp_apb_paddr[15:14] == 2'b00); // 0x51010000 - 0x51013ffc
  assign zynq2pulp_uart_psel      = zynq2pulp_apb_psel & (zynq2pulp_apb_paddr[15:14] == 2'b01); // 0x51014000 - 0x51017ffc

  // prdata demuxing
  assign zynq2pulp_apb_prdata = (last_sel == `Z2P_SPI_SLAVE) ? zynq2pulp_spi_slave_prdata :
                                (last_sel == `Z2P_UART)      ? zynq2pulp_uart_prdata      :
                                                               zynq2pulp_spi_slave_prdata;

  // pslverr demuxing
  assign zynq2pulp_apb_pslverr = (last_sel == `Z2P_SPI_SLAVE) ? zynq2pulp_spi_slave_pslverr :
                                 (last_sel == `Z2P_UART)      ? zynq2pulp_uart_pslverr      :
                                                               zynq2pulp_spi_slave_pslverr;

  // pready demuxing
  assign zynq2pulp_apb_pready = zynq2pulp_spi_slave_pready | zynq2pulp_uart_pready;

  // spi_slave outputs
  assign zynq2pulp_spi_slave_paddr = zynq2pulp_apb_paddr;
  assign zynq2pulp_spi_slave_penable = zynq2pulp_apb_penable;
  assign zynq2pulp_spi_slave_pwdata = zynq2pulp_apb_pwdata;
  assign zynq2pulp_spi_slave_pwrite = zynq2pulp_apb_pwrite;

  // uart outputs
  assign zynq2pulp_uart_paddr = zynq2pulp_apb_paddr;
  assign zynq2pulp_uart_penable = zynq2pulp_apb_penable;
  assign zynq2pulp_uart_pwdata = zynq2pulp_apb_pwdata;
  assign zynq2pulp_uart_pwrite = zynq2pulp_apb_pwrite;

endmodule
