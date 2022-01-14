// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`include "pulp_soc_defines.svh"
`include "pulp_peripheral_defines.svh"
`include "periph_bus_defines.svh"

`define REG_INFO 12'h00  //BASEADDR+0x00 Cores [31:16] and Clusters [15:0]
`define REG_FCBOOT 12'h04 //BASEADDR+0x04 not used at the moment
`define REG_FCFETCH 12'h08 //BASEADDR+0x08 not used at the moment
`define REG_BUILD_DATE 12'h0C //BASEADDR+0x0C date of build
`define REG_BUILD_TIME 12'h10 //BASEADDR+0x0C time of build

`define REG_WCFGFUN 12'h60 // BASEADDR+0x60 Sets mux&cfg control for specifed iopad
`define REG_RCFGFUN 12'h64 // BASEADDR+0x64 reads mux&cfg control for specifed iopad

`define REG_JTAGREG 12'h74 //BASEADDR+0x74 JTAG REG
`define REG_BOOTSEL 12'hC4 //BASEADDR+0xC4 bootsel
`define REG_CLKSEL 12'hC8 //BASEADDR+0xC8 clocksel
`define REG_WD_COUNT 12'hD0
`define REG_WD_CONTROL 12'hD4
`define REG_RESET_REASON 12'hD8
`define RTO_PERIPHERAL 12'hE0
`define RTO_COUNT 12'hE4
`define RESET_TYPE1_EFPGA 12'hE8 //BASEADDR+0xE8
`define ENABLE_IN_OUT_EFPGA 12'hEC //BASEADDR+0xEC
`define EFPGA_CONTROL 12'hF0
`define EFPGA_STATUS 12'hF4
`define EFPGA_VERSION 12'hF8
`define SOFT_RESET 12'hFC

`define PAD_CFG_MUX 12'b0100????????  // 0x400 - 7FC for 256 PADMUX


// TODO(timsaxe): Check whether this is okay from a build environment perspective.
`ifndef BUILD_DATE
`define BUILD_DATE '0
`endif
`ifndef BUILD_TIME
`define BUILD_TIME '0
`endif

// NOTE: safe regs will be mapped starting from BASEADDR+0x100


module apb_soc_ctrl #(
    parameter int unsigned APB_ADDR_WIDTH = 12,  // APB slaves are 4KB by default
    parameter int unsigned NB_CLUSTERS = 0,  // N_CLUSTERS
    parameter int unsigned NB_CORES = 4,  // N_CORES
    parameter int unsigned JTAG_REG_SIZE = 8,
    parameter int unsigned NBIT_PADCFG = 6,  // not used... see pulp_soc_defines
    parameter int unsigned NBIT_PADMUX = 2,  // not used... see pulp_soc_defines
    parameter int unsigned N_IO = 64,  // not used... see pulp_soc_defines
    parameter int unsigned IO_IDX_WIDTH = 6  // not used (LOG2 macro below)
) (
    input  logic                      HCLK,
    input  logic                      HRESETn,
    input                             ref_clk_i,
    input                             rstpin_ni,
    input  logic [APB_ADDR_WIDTH-1:0] PADDR,
    input  logic [              31:0] PWDATA,
    input  logic                      PWRITE,
    input  logic                      PSEL,
    input  logic                      PENABLE,
    output logic [              31:0] PRDATA,
    output logic                      PREADY,
    output logic                      PSLVERR,

    input  logic        sel_fll_clk_i,
    input  logic        bootsel_i,
    input        [31:0] status_out,
    input        [ 7:0] version,
    input               stoptimer_i,
    input               dmactive_i,
    output logic        wd_expired_o,
    output logic [31:0] control_in,


    output logic [`N_IO-1:0][`NBIT_PADCFG-1:0] pad_cfg_o,
    output logic [`N_IO-1:0][`NBIT_PADMUX-1:0] pad_mux_o,

    input  logic [JTAG_REG_SIZE-1:0] soc_jtag_reg_i,
    output logic [JTAG_REG_SIZE-1:0] soc_jtag_reg_o,

    output logic [31:0] fc_bootaddr_o,

    // eFPGA connections

    output logic       clk_gating_dc_fifo_o,
    output logic [3:0] reset_type1_efpga_o,
    output logic       enable_udma_efpga_o,
    output logic       enable_events_efpga_o,
    output logic       enable_apb_efpga_o,
    output logic       enable_tcdm3_efpga_o,
    output logic       enable_tcdm2_efpga_o,
    output logic       enable_tcdm1_efpga_o,
    output logic       enable_tcdm0_efpga_o,

    output logic                  fc_fetchen_o,
    output logic                  rto_o,
    input  logic                  start_rto_i,
    input  logic [`NB_MASTER-1:0] peripheral_rto_i,
    output logic                  soft_reset_o


);
  localparam IDX_WIDTH = `LOG2(`N_IO);
  localparam CONFIG = 12'h4??;

  logic [    IDX_WIDTH-1:0]                   r_io_pad;

  logic [             15:0]                   n_cores;
  logic [             15:0]                   n_clusters;
  logic [        `N_IO-1:0][`NBIT_PADMUX-1:0] r_padmux;

  logic [             63:0]                   r_pad_fun0;
  logic [             63:0]                   r_pad_fun1;

  logic [JTAG_REG_SIZE-1:0]                   r_jtag_rego;
  logic [JTAG_REG_SIZE-1:0]                   r_jtag_regi_sync         [1:0];

  logic [             31:0]                   r_bootaddr;
  logic                                       r_fetchen;
  logic [              1:0]                   r_bootsel;


  logic [              5:0]                   r_sel_clk_dc_fifo_onehot;
  logic                                       r_clk_gating_dc_fifo;
  logic [              3:0]                   r_reset_type1_efpga;
  logic [              5:0]                   r_enable_inout_efpga;

  logic                                       s_apb_write;

  logic [             19:0]                   ready_timeout_count;
  logic [             31:0]                   rto_count_reg;
  logic [             31:0]                   periph_rto_reg;

  logic [              1:0]                   APB_fsm;
  logic [             30:0]                   wd_current_count;
  logic [             30:0]                   wd_count;
  logic                                       wd_enabled;
  logic [              1:0]                   reset_reason;

  logic wd_reset, wd_cleared, reset_reason_clear;


  localparam FSM_IDLE = 0, FSM_READ = 1, FSM_WRITE = 2, FSM_WAIT = 3;


  assign pad_mux_o = r_padmux;
  assign soc_jtag_reg_o = r_jtag_rego;
  assign fc_bootaddr_o = r_bootaddr;
  assign fc_fetchen_o = r_fetchen;
  assign clk_gating_dc_fifo_o = r_clk_gating_dc_fifo;
  assign reset_type1_efpga_o = r_reset_type1_efpga;
  assign {enable_udma_efpga_o, enable_events_efpga_o,
          enable_apb_efpga_o, enable_tcdm3_efpga_o,
          enable_tcdm2_efpga_o, enable_tcdm1_efpga_o,
          enable_tcdm0_efpga_o} = r_enable_inout_efpga[5:0];

  assign n_cores = NB_CORES;
  assign n_clusters = NB_CLUSTERS;


  always_ff @(posedge ref_clk_i or negedge rstpin_ni) begin
    if (rstpin_ni == 0) begin
      wd_current_count <= 32768;
      wd_cleared <= 0;
      wd_expired_o <= 0;
    end else begin
      wd_expired_o <= 0;
      wd_cleared   <= 0;
      if (wd_reset == 1) begin
        wd_current_count <= wd_count;
        wd_cleared <= 1;
      end else if ((wd_enabled == 1) && (stoptimer_i == 0)) begin
        wd_current_count <= wd_current_count - 1;
        wd_expired_o <= 1'b0;
        if (wd_current_count == 1) begin
          wd_expired_o <= 1'b1;
        end
      end
    end  // else: !if(HRESETn  == 0)
  end  // always_ff @ (posedge ref_clk_i, negedge HRESETn)

  always_latch begin
    if (rstpin_ni == 0) reset_reason <= 2'b01;
    else if (wd_expired_o == 1) reset_reason <= 2'b10;
    else if (reset_reason_clear == 1) reset_reason <= 2'b00;
  end



  always_ff @(posedge HCLK or negedge HRESETn) begin
    if (~HRESETn) begin
      wd_enabled <= 0;  // Watchdog disabled on power up.
      wd_count <= 32768;
      APB_fsm <= FSM_IDLE;
      r_io_pad <= '0;
      r_padmux <= '0;
      r_pad_fun0 <= '0;
      r_pad_fun1 <= '0;
      r_jtag_regi_sync[0] <= 'h0;
      r_jtag_regi_sync[1] <= 'h0;
      r_jtag_rego <= 'h0;
      r_bootaddr <= 32'h1A000080;
      r_fetchen <= 1'h1;  // on reset, fc starts running ?
      pad_cfg_o <= '1;
      r_sel_clk_dc_fifo_onehot <= '0;
      r_clk_gating_dc_fifo <= 1'b1;
      r_reset_type1_efpga <= '0;
      r_enable_inout_efpga <= '0;
      PRDATA <= '0;
      PREADY <= '0;
      PSLVERR <= '0;
      control_in <= '0;
      ready_timeout_count <= 20'h000ff;
      rto_count_reg <= {12'h0, 20'h000ff};
      periph_rto_reg <= 32'h0;
      rto_o <= 1'b0;
      soft_reset_o <= 1'b0;
      reset_reason_clear <= 0;
      wd_reset <= 0;
    end else begin  // if (~HRESETn)
      if (wd_cleared == 1) wd_reset <= 0;
      if (start_rto_i == 1) ready_timeout_count <= ready_timeout_count - 1;
      else ready_timeout_count <= rto_count_reg[19:0];
      if (ready_timeout_count == 0) rto_o <= 1'b1;
      else rto_o <= 1'b0;
      periph_rto_reg[`NB_MASTER-1:0] <= periph_rto_reg[`NB_MASTER-1:0] | peripheral_rto_i;

      r_jtag_regi_sync[1] <= soc_jtag_reg_i;
      r_jtag_regi_sync[0] <= r_jtag_regi_sync[1];

      soft_reset_o <= 0;
      reset_reason_clear <= 0;

      case (APB_fsm)
        FSM_WAIT: begin
          casex (PADDR[11:0])
            `REG_RESET_REASON: reset_reason_clear <= 1;
          endcase
          PREADY  <= 0;
          APB_fsm <= FSM_IDLE;
        end
        FSM_IDLE: begin
          PREADY  <= 0;
          PSLVERR <= '0;
          if (PSEL && PENABLE && PWRITE) APB_fsm <= FSM_WRITE;
          else if (PSEL && PENABLE) APB_fsm <= FSM_READ;
        end
        FSM_WRITE: begin
          PREADY  <= 1;
          APB_fsm <= FSM_WAIT;
          casex (PADDR[11:0])
            `REG_FCBOOT: r_bootaddr <= PWDATA;
            `REG_FCFETCH:
            r_fetchen <= PWDATA[0];  // allow fc fetch enable to be controlled through JTAG
            `REG_WCFGFUN: begin
              r_io_pad <= PWDATA[0+:IDX_WIDTH];
              pad_cfg_o[PWDATA[0+:IDX_WIDTH]] <= PWDATA[24+:`NBIT_PADCFG];
              r_padmux[PWDATA[0+:IDX_WIDTH]] <= PWDATA[16+:`NBIT_PADMUX];
            end
            `REG_RCFGFUN: r_io_pad <= PWDATA[0+:IDX_WIDTH];
            `REG_JTAGREG: r_jtag_rego <= PWDATA[JTAG_REG_SIZE-1:0];
            `REG_WD_COUNT: wd_count <= wd_enabled ? wd_count : PWDATA[30:0];
            `REG_WD_CONTROL: begin
              if (PWDATA[31] == 1'b1) begin
                wd_enabled <= 1;
                wd_reset   <= 1;
              end
              if (wd_enabled) begin
                if (PWDATA[15:0] == 16'h6699) wd_reset <= 1;

              end
            end
            `RTO_PERIPHERAL: periph_rto_reg <= 32'h0;
            `RTO_COUNT: rto_count_reg <= {PWDATA[19:4], 4'hf};
            `RESET_TYPE1_EFPGA: r_reset_type1_efpga <= PWDATA[3:0];
            `ENABLE_IN_OUT_EFPGA: r_enable_inout_efpga <= PWDATA[5:0];
            `EFPGA_CONTROL: control_in <= PWDATA;
            `SOFT_RESET: begin
              soft_reset_o         <= 1;
              r_io_pad             <= '0;
              r_padmux             <= '0;
              r_pad_fun0           <= '0;
              r_pad_fun1           <= '0;
              pad_cfg_o            <= '1;
              r_clk_gating_dc_fifo <= 1'b1;
              r_reset_type1_efpga  <= '0;
              r_enable_inout_efpga <= '0;
              control_in           <= '0;
              rto_count_reg        <= {12'h0, 20'h000ff};
              periph_rto_reg       <= 32'h0;
            end
            12'h4??: begin
              if (PADDR[9:2] < `N_IO) begin
                r_io_pad <= PADDR[9:2];
                pad_cfg_o[PADDR[9:2]] <= PWDATA[8+:`NBIT_PADCFG];
                r_padmux[PADDR[9:2]] <= PWDATA[0+:`NBIT_PADMUX];
              end
            end
            default: begin
              PSLVERR <= 1;
            end
          endcase
        end  // case: FSM_WRITE
        FSM_READ: begin  // READ
          PREADY  <= 1;
          PRDATA  <= '0;
          APB_fsm <= FSM_WAIT;
          case (PADDR[11:0])
            `REG_WCFGFUN: begin
              PRDATA[0+:IDX_WIDTH] <= r_io_pad;
              PRDATA[16+:`NBIT_PADMUX] <= r_padmux[r_io_pad];
              PRDATA[24+:`NBIT_PADCFG] <= pad_cfg_o[r_io_pad];
            end
            `REG_RCFGFUN: begin
              PRDATA[0+:IDX_WIDTH] <= r_io_pad;
              PRDATA[16+:`NBIT_PADMUX] <= r_padmux[r_io_pad];
              PRDATA[24+:`NBIT_PADCFG] <= pad_cfg_o[r_io_pad];
            end
            `REG_FCBOOT: PRDATA <= r_bootaddr;
            `REG_FCFETCH: PRDATA <= {31'b0, r_fetchen};
            `REG_INFO: PRDATA <= {n_cores, n_clusters};
            `REG_BUILD_DATE: PRDATA <= `BUILD_DATE;
            `REG_BUILD_TIME: PRDATA <= `BUILD_TIME;
            `REG_BOOTSEL: PRDATA <= {dmactive_i, bootsel_i, 28'h0, r_bootsel};
            `REG_CLKSEL: PRDATA <= {31'h0, sel_fll_clk_i};
            `REG_JTAGREG: PRDATA <= {16'h0, r_jtag_regi_sync[0], r_jtag_rego};
            `REG_WD_COUNT: PRDATA <= {1'b0, wd_count};
            `REG_WD_CONTROL: PRDATA <= {wd_enabled, wd_current_count};
            `REG_RESET_REASON: PRDATA <= {30'b0, reset_reason};
            `RTO_PERIPHERAL: PRDATA <= periph_rto_reg;
            `RTO_COUNT: PRDATA <= rto_count_reg;
            `RESET_TYPE1_EFPGA: PRDATA <= {28'b0, r_reset_type1_efpga};
            `ENABLE_IN_OUT_EFPGA: PRDATA <= {26'b0, r_enable_inout_efpga};
            `EFPGA_CONTROL: PRDATA <= control_in;
            `EFPGA_STATUS: PRDATA <= status_out;
            `EFPGA_VERSION: PRDATA[7:0] <= version;
            default: begin
              PSLVERR <= 1;
              PRDATA  <= 32'hDEADBEEF;
            end

          endcase  // case (PADDR[11:0])
          if (PADDR[11:10] == 2'b01) begin
            PRDATA   <= 32'b0;
            r_io_pad <= PADDR[2+:IDX_WIDTH];
            if (PADDR[9:2] < `N_IO) begin
              PRDATA[8+:`NBIT_PADCFG] <= pad_cfg_o[PADDR[9:2]];
              PRDATA[0+:`NBIT_PADMUX] <= r_padmux[PADDR[9:2]];
            end else PRDATA <= 32'h0095BEEF;
          end
        end  // case: FSM_READ
      endcase  // case (APB_fsm)
    end  // else: !if(~HRESETn)
  end  // always_ff @ (posedge HCLK, negedge HRESETn)

  always_ff @(posedge HCLK, negedge HRESETn) begin
    if (~HRESETn) begin
      r_bootsel <= {dmactive_i, bootsel_i};
    end else begin
      r_bootsel <= r_bootsel;
    end
  end

endmodule
