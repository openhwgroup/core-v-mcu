// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`include "pulp_soc_defines.sv"
`include "pulp_peripheral_defines.svh"

`define SPI_STD_TX 2'b00
`define SPI_STD_RX 2'b01
`define SPI_QUAD_TX 2'b10
`define SPI_QUAD_RX 2'b11

module pad_control #(
    parameter int unsigned N_UART = 1,
    parameter int unsigned N_SPI  = 1,
    parameter int unsigned N_I2C  = 2
) (

    //********************************************************************//
    //*** PERIPHERALS SIGNALS ********************************************//
    //********************************************************************//
    output logic [`N_IO-1:0] io_out_o,
    input  logic [`N_IO-1:0] io_in_i,
    output logic [`N_IO-1:0] io_oe_o,

    // PERIOS
    input  logic [`N_PERIO-1:0] perio_out_i,
    output logic [`N_PERIO-1:0] perio_in_o,
    input  logic [`N_PERIO-1:0] perio_oe_i,

    // PAD CONTROL REGISTER
    input  logic [63:0][1:0] pad_mux_i,
    input  logic [63:0][5:0] pad_cfg_i,
    output logic [47:0][5:0] pad_cfg_o,

    // GPIOS
    input  logic [`N_GPIO-1:0] gpio_out_i,
    output logic [`N_GPIO-1:0] gpio_in_o,
    input  logic [`N_GPIO-1:0] gpio_oe_i,

    // FPGA IOs
    input  logic [`N_FPGAIO-1:0] fpgaio_out_i,
    output logic [`N_FPGAIO-1:0] fpgaio_in_o,
    input  logic [`N_FPGAIO-1:0] fpgaio_oe_i
);

  // TODO(timsaxe): Stubbed because that is part of the generated HW.

endmodule
