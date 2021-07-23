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

`define REG_INFO 12'h00  //BASEADDR+0x00 CONTAINS NUMBER OF CORES [31:16] AND CLUSTERS [15:0]
`define REG_FCBOOT 12'h04 //BASEADDR+0x04 not used at the moment
`define REG_FCFETCH 12'h08 //BASEADDR+0x08 not used at the moment
`define REG_BUILD_DATE 12'h0C //BASEADDR+0x0C date of build
`define REG_BUILD_TIME 12'h10 //BASEADDR+0x0C time of build

//bit0    enable pull UP
//bit1    enable pull DOWN
//bit2    enable ST
//bit3    enable SlewRate Limit
//bit4..5 Driving Strength
//bit6..7 not used

`define REG_WCFGFUN 12'h60 // BASEADDR+0x60  Sets mux and cfg control for specifed iopad
`define REG_RCFGFUN 12'h64 // BASEADDR+0x64  reads mux and cfg control for specifed iopad

`define REG_CLUSTER_CTRL 12'h70 //BASEADDR+0x70 CLUSTER Ctrl
`define REG_JTAGREG 12'h74 //BASEADDR+0x74 JTAG REG
`define REG_CTRL_PER 12'h78
`define REG_CLUSTER_IRQ 12'h7C
`define REG_CLUSTER_BOOT_ADDR0 12'h80
`define REG_CLUSTER_BOOT_ADDR1 12'h84


`define REG_CORESTATUS  12'hA0 //BASEADDR+0xA0 32bit GP used during testing to return EOC(bit[31]) and status(bit[30:0])
`define REG_CS_RO       12'hC0 //BASEADDR+0xC0 32bit RO GP used during testing to return EOC(bit[31]) and status(bit[30:0])
`define REG_BOOTSEL 12'hC4 //BASEADDR+0xC4 bootsel
`define REG_CLKSEL 12'hC8 //BASEADDR+0xC8 clocksel

`define RESET_TYPE1_EFPGA 12'hE8 //BASEADDR+0xE8
`define ENABLE_IN_OUT_EFPGA 12'hEC //BASEADDR+0xEC
`define EFPGA_CONTROL 12'hF0
`define EFPGA_STATUS 12'hF4
`define EFPGA_VERSION 12'hF8
`define PAD_CFG_MUX 12'b0100????????  // 0x400 - 7FC for 256 PADMUX


// TODO(timsaxe): Check whether this is okay from a build environment perspective.
`ifndef BUILD_DATE
`define BUILD_DATE '0
`endif
`ifndef BUILD_TIME
`define BUILD_TIME '0
`endif

// NOTE: safe regs will be mapped starting from BASEADDR+0x100

//`define MSG_VERBOSE

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
    input logic HCLK,
    input logic HRESETn,

    input  logic [APB_ADDR_WIDTH-1:0] PADDR,
    input  logic [              31:0] PWDATA,
    input  logic                      PWRITE,
    input  logic                      PSEL,
    input  logic                      PENABLE,
    output logic [              31:0] PRDATA,
    output logic                      PREADY,
    output logic                      PSLVERR,

    input  logic        sel_fll_clk_i,
    input  logic        boot_l2_i,
    input  logic        bootsel_i,
    input  logic        fc_fetch_en_valid_i,
    input  logic        fc_fetch_en_i,
    input        [31:0] status_out,
    input        [ 7:0] version,
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

    output logic        fc_fetchen_o,
    output logic        sel_hyper_axi_o,
    output logic        cluster_pow_o,  // power cluster
    output logic        cluster_byp_o,  // bypass cluster
    output logic [63:0] cluster_boot_addr_o,
    output logic        cluster_fetch_enable_o,
    output logic        cluster_rstn_o,
    output logic        cluster_irq_o
);
  localparam IDX_WIDTH = `LOG2(`N_IO);
  localparam CONFIG = 12'h4??;

  logic [    IDX_WIDTH-1:0]                   r_io_pad;


  logic [             31:0]                   r_pwr_reg;
  logic [             31:0]                   r_corestatus;


  logic [              6:0]                   s_apb_addr;

  logic [             15:0]                   n_cores;
  logic [             15:0]                   n_clusters;
  logic [        `N_IO-1:0][`NBIT_PADMUX-1:0] r_padmux;

  logic [             63:0]                   r_pad_fun0;
  logic [             63:0]                   r_pad_fun1;

  logic [             63:0]                   r_cluster_boot;
  logic                                       r_cluster_fetch_enable;
  logic                                       r_cluster_rstn;

  logic [JTAG_REG_SIZE-1:0]                   r_jtag_rego;
  logic [JTAG_REG_SIZE-1:0]                   r_jtag_regi_sync       [1:0];

  logic                                       r_cluster_byp;
  logic                                       r_cluster_pow;
  logic [             31:0]                   r_bootaddr;
  logic                                       r_fetchen;

  logic                                       r_cluster_irq;

  logic                                       r_sel_hyper_axi;
  logic [              1:0]                   r_bootsel;

  logic [              7:0]                   r_clk_div_cluster;
  logic s_div_cluster_valid, s_div_cluster_sel;

  logic [5:0] r_sel_clk_dc_fifo_onehot;
  logic       r_clk_gating_dc_fifo;
  logic [3:0] r_reset_type1_efpga;
  logic [5:0] r_enable_inout_efpga;

  logic       s_apb_write;

  logic [1:0] APB_fsm;
  localparam FSM_IDLE = 0, FSM_READ = 1, FSM_WRITE = 2, FSM_WAIT = 3;


  assign pad_mux_o = r_padmux;

  assign soc_jtag_reg_o = r_jtag_rego;

  assign fc_bootaddr_o = r_bootaddr;
  assign fc_fetchen_o = r_fetchen;

  assign cluster_pow_o = r_cluster_pow;
  assign sel_hyper_axi_o = r_sel_hyper_axi;


  assign cluster_rstn_o = r_cluster_rstn;

  assign cluster_boot_addr_o = r_cluster_boot;
  assign cluster_fetch_enable_o = r_cluster_fetch_enable;
  assign cluster_byp_o = r_cluster_byp;
  assign cluster_irq_o = r_cluster_irq;

  assign clk_div_cluster_data_o = r_clk_div_cluster;

  edge_propagator_tx i_edgeprop_clu (  // CLuster logic should be removed?
      .clk_i  (HCLK),
      .rstn_i (HRESETn),
      .valid_i(s_div_cluster_valid),
      .ack_i  (1'b1),
      .valid_o(clk_div_cluster_valid_o)
  );



  //  always_comb begin : proc_id
  //    sel_clk_dc_fifo_efpga_o = '0;
  //    for (int unsigned i = 0; i < 6; i++) begin
  //      if (r_sel_clk_dc_fifo_onehot[i]) sel_clk_dc_fifo_efpga_o = i;
  //    end
  //  end

  assign clk_gating_dc_fifo_o = r_clk_gating_dc_fifo;

  assign reset_type1_efpga_o = r_reset_type1_efpga;

  assign {enable_udma_efpga_o, enable_events_efpga_o, enable_apb_efpga_o, enable_tcdm3_efpga_o, enable_tcdm2_efpga_o, enable_tcdm1_efpga_o, enable_tcdm0_efpga_o} = r_enable_inout_efpga[5:0];


  assign s_apb_addr = PADDR[8:2];

  always_ff @(posedge HCLK, negedge HRESETn) begin
    if (~HRESETn) begin
      APB_fsm                  <= FSM_IDLE;

      r_io_pad                 <= '0;
      r_padmux                 <= '0;
      r_corestatus             <= '0;
      r_pwr_reg                <= '0;
      r_pad_fun0               <= '0;
      r_pad_fun1               <= '0;
      r_jtag_regi_sync[0]      <= 'h0;
      r_jtag_regi_sync[1]      <= 'h0;
      r_jtag_rego              <= 'h0;
      r_bootaddr               <= 32'h1A000080;
      r_fetchen                <= 1'h0;  // on reset, fc doesn't do anything
      r_cluster_pow            <= 1'b0;
      r_cluster_byp            <= 1'b1;
      pad_cfg_o                <= '1;
      r_sel_hyper_axi          <= 1'b0;
      r_cluster_fetch_enable   <= 1'b0;
      r_cluster_boot           <= '0;
      r_cluster_rstn           <= 1'b1;
      r_cluster_irq            <= 1'b0;
      r_clk_div_cluster        <= 'h0;
      r_sel_clk_dc_fifo_onehot <= '0;
      r_clk_gating_dc_fifo     <= 1'b1;
      r_reset_type1_efpga      <= '0;
      r_enable_inout_efpga     <= '0;
      PRDATA                   <= '0;
      PREADY                   <= '0;
      PSLVERR                  <= '0;
      control_in               <= '0;

    end else begin
      r_jtag_regi_sync[1] <= soc_jtag_reg_i;
      r_jtag_regi_sync[0] <= r_jtag_regi_sync[1];

      // allow fc fetch enable to be controlled through a signal
      if (fc_fetch_en_valid_i) r_fetchen <= fc_fetch_en_i;
      case (APB_fsm)
        FSM_WAIT: begin
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
            `REG_CORESTATUS: r_corestatus <= PWDATA[31:0];
            `REG_CLUSTER_CTRL: begin
              r_cluster_byp          <= PWDATA[0];
              r_cluster_pow          <= PWDATA[1];
              r_cluster_fetch_enable <= PWDATA[2];
              r_cluster_rstn         <= PWDATA[3];
            end
            `REG_CLUSTER_IRQ: r_cluster_irq <= PWDATA[0];
            `REG_CLUSTER_BOOT_ADDR0: r_cluster_boot[31:0] <= PWDATA;
            `REG_CLUSTER_BOOT_ADDR1: r_cluster_boot[63:32] <= PWDATA;

            `RESET_TYPE1_EFPGA: r_reset_type1_efpga <= PWDATA[3:0];
            `ENABLE_IN_OUT_EFPGA: r_enable_inout_efpga <= PWDATA[5:0];
            `EFPGA_CONTROL: control_in <= PWDATA;
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
            `REG_INFO: PRDATA <= {n_cores, n_clusters};
            `REG_BUILD_DATE: PRDATA <= `BUILD_DATE;
            `REG_BUILD_TIME: PRDATA <= `BUILD_TIME;
            `REG_CORESTATUS: PRDATA <= r_corestatus;
            `REG_CS_RO: PRDATA <= r_corestatus;
            `REG_BOOTSEL: PRDATA <= {30'h0, r_bootsel};
            `REG_CLKSEL: PRDATA <= {31'h0, sel_fll_clk_i};
            `REG_CLUSTER_CTRL:
            PRDATA <= {
              28'h0, PSLVERR, r_cluster_rstn, r_cluster_fetch_enable, r_cluster_pow, r_cluster_byp
            };
            `REG_JTAGREG: PRDATA <= {16'h0, r_jtag_regi_sync[0], r_jtag_rego};
            `REG_CTRL_PER: PRDATA <= {31'b0, r_sel_hyper_axi};
            `REG_CLUSTER_IRQ: PRDATA <= {31'b0, r_cluster_irq};
            `REG_CLUSTER_BOOT_ADDR0: PRDATA <= r_cluster_boot[31:0];
            `REG_CLUSTER_BOOT_ADDR1: PRDATA <= r_cluster_boot[63:32];
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
      r_bootsel <= {1'b0, bootsel_i};
    end else begin
      r_bootsel <= r_bootsel;
    end
  end

  assign n_cores    = NB_CORES;
  assign n_clusters = NB_CLUSTERS;


  // assign PSLVERR    = 1'b0;

endmodule
