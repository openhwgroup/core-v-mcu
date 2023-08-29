//-----------------------------------------------------------------------------
// Title : FPGA CLK Gen for Core-V-MCU
// -----------------------------------------------------------------------------
// File : fpga_clk_gen.sv Author : Manuel Eggimann <meggimann@iis.ee.ethz.ch>
// Created : 17.05.2019
// -----------------------------------------------------------------------------
// Description : Instantiates Xilinx clocking wizard IP to generate 2 output
// clocks. Currently, the clock is not dynamicly reconfigurable and all
// configuration requests are acknowledged without any effect.
// -----------------------------------------------------------------------------
// Copyright (C) 2013-2019 ETH Zurich, University of Bologna Copyright and
// related rights are licensed under the Solderpad Hardware License, Version
// 0.51 (the "License"); you may not use this file except in compliance with the
// License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law or
// agreed to in writing, software, hardware and materials distributed under this
// License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS
// OF ANY KIND, either express or implied. See the License for the specific
// language governing permissions and limitations under the License.
// -----------------------------------------------------------------------------

module apb_pll
#(
    parameter APB_ADDR_WIDTH = 12
)
(
 input logic                      ref_clk_i,
 output logic                     soc_clk_o,
 output logic                     periph_clk_o,
 output logic                     cluster_clk_o,
 output logic                     ref_clk_o,
 input logic rst_ni,
 input logic                      HCLK,
 input logic                      HRESETn,
 input logic [APB_ADDR_WIDTH-1:0] PADDR,
 input logic [31:0]               PWDATA,
 input logic                      PWRITE,
 input logic                      PSEL,
 input logic                      PENABLE,
 output logic [31:0]              PRDATA,
 output logic                     PREADY,
 output logic                     PSLVERR,
    inout AVDD,AVDD2,AVSS,VDDC,VSSC

);

  logic                           PD; // PLL powerdown
  logic                           PDDP; // Post Divider PowerDown
  logic [5:0]                     DM; // Reference input divider
  logic [10:0]                    DN; // Feedback Divider
  logic [2:0]                     DP; // Output Divider
  logic [1:0]                     MODE ; //00=int, 01=frac, 10 = SpreadSpec
  logic [11:0]                    SSRATE; // SPread SPectrum Freq
  logic [23:0]                    SSLOPE; // spread spectrum slope
  logic [23:0]                    FRAC; // Fractional portion of DN
  logic                           BYPASS;
  logic                           PLL_RESET;


  logic [31:0]                    ControlReg;
  logic [31:0]                    DivisorReg;
  logic [31:0]                    FracReg;
  logic [31:0]                    Spread1Reg;
  logic [31:0]                    Spread2Reg;
  logic [31:0]                    SocDiv;
  logic [31:0]                    PeriphDiv;
  logic [31:0]                    ClusterDiv;

  logic                           slverr;
  logic                           ready;

  logic                           CLKO;
  logic                           LOCK;
  logic                           pll_reset_in;


  localparam reg_CTL=0;
  localparam reg_DIV=4;
  localparam reg_FRAC=8;
  localparam reg_SS1=12;
  localparam reg_SS2=16;
  localparam reg_SOC=20;
  localparam reg_PERIPH=24;
  localparam reg_CLUSTER=28;

  enum           logic [3:0] { IDLE, READ, WRITE, WAIT} state;
  always_comb begin
    PDDP = ControlReg[25];
    PD = ControlReg[24];
    MODE = ControlReg[17:16];
    DM = ControlReg[13:8];
    PLL_RESET = ControlReg[1];

    BYPASS = ControlReg[0];

    DN = DivisorReg[26:16];
    DP = DivisorReg[2:0];

    FRAC = FracReg[23:0];

    SSRATE = Spread1Reg[11:0];
    SSLOPE = Spread2Reg[23:0];
  end // always_comb

  always_comb begin
    PREADY = ready & PENABLE;
    PSLVERR = slverr & PENABLE;
  end


    always_ff @(posedge HCLK, negedge HRESETn) begin
      if (!HRESETn) begin
        state           <= IDLE;
        ControlReg <= 32'h00000103; //Refdiv=1, RESET,  BYPASS
        DivisorReg <= 32'h00500007; // 114 Mhz from 10MHz ref
        FracReg <= 32'h0;
        Spread1Reg <= 32'h0;
        Spread2Reg <= 32'h0;
        SocDiv = 32'd10;
        PeriphDiv = 32'd20;
        ClusterDiv = 32'd30;

        ready <= 0;
        slverr <= 0;
      end
      else begin
        case (state)
          IDLE: begin
            ready <= 0;
            if (PSEL & PENABLE)
              if (PWRITE) state <= WRITE;
              else state <= READ;
          end
          WRITE: begin
            case (PADDR[APB_ADDR_WIDTH-1:0])
              reg_CTL: ControlReg <= PWDATA;
              reg_DIV: DivisorReg <= PWDATA;
              reg_SS1: Spread1Reg <= PWDATA;
              reg_SS2: Spread2Reg <= PWDATA;
              reg_FRAC: FracReg <= PWDATA;
              reg_SOC: SocDiv <= PWDATA;
              reg_PERIPH: PeriphDiv <= PWDATA;
              reg_CLUSTER: ClusterDiv <= PWDATA;
              default: slverr <= 1;
            endcase // case (PADDR[APB_ADDR_WIDTH-1:0])
            ready <= 1;
            if (PENABLE == 0)
              state <= IDLE;
          end // case: WRITE
          READ: begin
            case (PADDR[APB_ADDR_WIDTH-1:0])
              reg_CTL: PRDATA <= {LOCK,6'b0,PDDP,PD,6'b0,MODE[1:0],
                              2'b0,DM[5:0],6'b0,PLL_RESET,BYPASS};
              reg_DIV: PRDATA <= {5'b0,DN[10:0],13'b0,DP[2:0]};

              reg_SS1: PRDATA <= {20'b0,SSRATE[11:0]};
              reg_SS2:  PRDATA <= {8'b0,SSLOPE[23:0]};
              reg_FRAC: PRDATA <= {8'b0,FRAC[23:0]};
              reg_SOC:  PRDATA <= {22'b0,SocDiv[9:0]};
              reg_PERIPH:  PRDATA <= {22'b0,PeriphDiv[9:0]};
              reg_CLUSTER: PRDATA <= {22'b0,ClusterDiv[9:0]};
              default: slverr <= 1;
            endcase // case (PADDR[APB_ADDR_WIDTH-1:0])
            ready <= 1;
            if (PENABLE == 0)
              state <= IDLE;
          end // case: READ
        endcase // case (state)
      end // else: !if(!HRESETn)
    end // always_ff @ (posedge HCLK, negedge HRESETn)

  assign pll_reset_in = ~(PLL_RESET | ~HRESETn);

/*
  PLL u0 (
          .FREF(ref_clk_i),
          .PD(PD),
          .DM(DM),
          .DN(DN),
          .DP(DP),
          .MODE(MODE),
          .FRAC(FRAC),
          .SSRATE(SSRATE),
          .SLOPE(SSLOPE),
          .RESETN(pll_reset_in),
          .PDDP(PDDP),
          .BYPASS(BYPASS),
          .CLKO(CLKO),
          .CLK(),
          .LOCK(LOCK)
          );
*/
  clkdv ref_div (
                 .clk_i(soc_clk_o),
                 .clk_o(ref_clk_o),
                 .rst_ni(rst_ni),
                 .CLK_DIV_VALUE(10'd40)
                 );

  xilinx_clk_mngr i_clk_manager
    (
     .resetn(rst_ni),
     .clk_in1(ref_clk_i),
     .clk_out1(soc_clk_o),
     .clk_out2(periph_clk_o),
     .clk_out3(cluster_clk_o),
     .locked(LOCK)
     );

endmodule
module clkdv
  (
   input logic  clk_i,
   input logic  rst_ni,
   output logic clk_o,
   input logic [9:0] CLK_DIV_VALUE
   );
   localparam COUNTER_WIDTH = 10;


  logic [COUNTER_WIDTH-1:0] clk_counter;
  logic                     clkout;



  assign clk_o = (CLK_DIV_VALUE <= 1) ? clk_i : clkout;

  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
      clk_counter <= '0;
      clkout <= 1'b0;
    end else begin
      clk_counter <= clk_counter + 1;
      case (CLK_DIV_VALUE)
        0,1:clkout <= 0;
        2: clkout <= ~clkout;
        default: begin
          if (clk_counter == ((CLK_DIV_VALUE-1) >> 1)) clkout <= 1;
          if (clk_counter == (CLK_DIV_VALUE - 1)) begin
            clkout <= ~clkout;
            clk_counter <= 0;
          end
        end
      endcase // case (CLK_DIV_VALUE)
    end
  end // always_ff @ (posedge clk_i, negedge rst_ni)


endmodule : clkdv
