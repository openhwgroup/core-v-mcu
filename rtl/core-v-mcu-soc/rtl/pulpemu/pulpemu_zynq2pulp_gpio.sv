// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


`define ZYNQ2PULP_FETCHEN 0
`define ZYNQ2PULP_MODE_FMC_ZYNQ 2
`define ZYNQ2PULP_STDOUT_FLUSHED 3
`define ZYNQ2PULP_TRACE_FLUSHED 4
`define ZYNQ2PULP_TRACE_ACTIVE 5
`define ZYNQ2PULP_ZYNQ_SAFEN_SPIS 8
`define ZYNQ2PULP_ZYNQ_SAFEN_SPIM 7
`define ZYNQ2PULP_ZYNQ_SAFEN_UART 6
`define ZYNQ2PULP_FAULTEN 29
`define ZYNQ2PULP_CLKEN 30
`define ZYNQ2PULP_RSTN 31
`define PULP2ZYNQ_EOC 0
`define PULP2ZYNQ_RET_LO 1
`define PULP2ZYNQ_RET_HI 2
`define PULP2ZYNQ_STDOUT_WAIT 3
`define PULP2ZYNQ_TRACE_WAIT 4

module pulpemu_zynq2pulp_gpio (
    input  logic        clk,
    input  logic        rst_n,
    output logic [31:0] pulp2zynq_gpio,
    input  logic [31:0] zynq2pulp_gpio,
    output logic        stdout_flushed,
    output logic        trace_flushed,
    output logic        cg_clken,
    output logic        fetch_en,
    output logic        mode_fmc_zynqn,
    output logic        fault_en,
    output logic        pulp_soc_rst_n,
    input  logic        stdout_wait,
    input  logic        trace_wait,
    input  logic        eoc,
    input  logic [ 1:0] return_val,
    output logic        zynq_safen_spis_o,
    output logic        zynq_safen_spim_o,
    output logic        zynq_safen_uart_o
);

  always_ff @(posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) pulp2zynq_gpio <= '0;
    else begin
      pulp2zynq_gpio[`PULP2ZYNQ_STDOUT_WAIT]              = stdout_wait;
      pulp2zynq_gpio[`PULP2ZYNQ_TRACE_WAIT]               = trace_wait;
      pulp2zynq_gpio[`PULP2ZYNQ_EOC]                      = eoc;
      pulp2zynq_gpio[`PULP2ZYNQ_RET_HI:`PULP2ZYNQ_RET_LO] = return_val;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
      stdout_flushed    <= 1'b0;
      trace_flushed     <= 1'b0;
      cg_clken          <= 1'b0;
      fetch_en          <= 1'b0;
      mode_fmc_zynqn    <= 1'b0;
      fault_en          <= 1'b0;
      pulp_soc_rst_n    <= 1'b0;
      zynq_safen_spis_o <= 1'b1;
      zynq_safen_spim_o <= 1'b1;
      zynq_safen_uart_o <= 1'b1;
    end else begin
      stdout_flushed    <= zynq2pulp_gpio[`ZYNQ2PULP_STDOUT_FLUSHED];
      trace_flushed     <= zynq2pulp_gpio[`ZYNQ2PULP_TRACE_FLUSHED];
      cg_clken          <= zynq2pulp_gpio[`ZYNQ2PULP_CLKEN];
      fetch_en          <= zynq2pulp_gpio[`ZYNQ2PULP_FETCHEN];
      mode_fmc_zynqn    <= zynq2pulp_gpio[`ZYNQ2PULP_MODE_FMC_ZYNQ];
      fault_en          <= zynq2pulp_gpio[`ZYNQ2PULP_FAULTEN];
      pulp_soc_rst_n    <= zynq2pulp_gpio[`ZYNQ2PULP_RSTN];
      zynq_safen_spis_o <= zynq2pulp_gpio[`ZYNQ2PULP_ZYNQ_SAFEN_SPIS];
      zynq_safen_spim_o <= zynq2pulp_gpio[`ZYNQ2PULP_ZYNQ_SAFEN_SPIM];
      zynq_safen_uart_o <= zynq2pulp_gpio[`ZYNQ2PULP_ZYNQ_SAFEN_UART];
    end
  end

endmodule  // pulpemu_zynq2pulp_gpio
