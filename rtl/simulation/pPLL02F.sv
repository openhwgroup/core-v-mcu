//-----------------------------------------------------------------------------
// Title : Simulation model for PLL
// -----------------------------------------------------------------------------
// Copyright (C) 2021 QUickLogic Copyright and
// related rights are licensed under the Solderpad Hardware License, Version
// 0.51 (the "License"); you may not use this file except in compliance with the
// License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law or
// agreed to in writing, software, hardware and materials distributed under this
// License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS
// OF ANY KIND, either express or implied. See the License for the specific
// language governing permissions and limitations under the License.
// -----------------------------------------------------------------------------

module pPLL02F (
    input wire RST_N,  //Reset - asserted low


    input wire       CK_AUX_IN,  //Clock input for bypass
    input wire       CK_XTAL_IN,  //Reference clock input
    input wire [3:0] PRESCALE,  //Divide ratio for the CK_XTAL prescaler

    input wire        SSC_EN,  //Enable SSC
    input wire [ 7:0] SSC_STEP,  //SSC frequency step
    input wire [10:0] SSC_PERIOD,  //The number of reference clock cycles per SSC cycle

    input wire        INTEGER_MODE,  //Integer mode (not fractional mode)
    input wire [10:0] MUL_INT,  //Integer component of multiplication ratio
    input wire [11:0] MUL_FRAC,  //Fractional component of multiplication ratio

    output wire LOCKED,  //Indicates when the PLL is locked

    input wire [ 8:0] LDET_CONFIG,  //Settings for the lock detector
    input wire [34:0] LF_CONFIG,  //Settings for the PLL loop filter

    input  wire       PS0_EN,  //Enable first output
    input  wire       PS0_BYPASS,  //Bypass first output
    input  wire [1:0] PS0_L1,  //Divide ratio of L1 divider of first output
    input  wire [7:0] PS0_L2,  //Divide ratio of L2 divider of first output
    output            CK_PLL_OUT0,  //First clock output

    input  wire       PS1_EN,  //Enable second output
    input  wire       PS1_BYPASS,  //Bypass second output
    input  wire [1:0] PS1_L1,  //Divide ratio of L1 divider of second output
    input  wire [7:0] PS1_L2,  //Divide ratio of L2 divider of second output
    output wire       CK_PLL_OUT1,  //Second clock output

    input  wire SCAN_IN,  //Scan chain data input
    input  wire SCAN_CK,  //Scan chain clock
    input  wire SCAN_EN,  //Scan chain enable
    input  wire SCAN_MODE,  //Configure for scan testing
    output wire SCAN_OUT  //Scan chain output
);

  logic       clk;
  logic       clkInternal;
  logic       clkOut;
  logic [7:0] counter;

  assign LOCKED = 1'b1;
  assign clkOut = (PS0_L2 == 8'h1) ? clk : clkInternal;

`ifdef VERILATOR
  always @(posedge CK_XTAL_IN or negedge RST_N) begin
    if (RST_N == 0) begin
      counter <= 0;
      clkInternal <= 0;
    end else begin
      counter <= counter + 1;
      if (counter == PS0_L2) begin
        clkInternal <= ~clkInternal;
        counter <= 0;
      end
    end  // else: !if(RST_N == 0)
  end  // always @ (posedge ref_clk_i or negedge RST_N)
  assign CK_PLL_OUT0 = CK_XTAL_IN;

`else
  initial counter = 0;
  initial clkInternal = 0;
  initial clk = 0;
  initial forever #(1.25) clk = ~clk;
  always @(posedge clk) begin
    //always @(posedge CK_XTAL_IN) begin
    counter <= counter + 1;
    case (PS0_L2)
      0, 1, 2: clkInternal <= ~clkInternal;
      default: begin
        if (counter == ((PS0_L2 - 1) >> 1)) clkInternal <= 1;
        if (counter == (PS0_L2 - 1)) begin
          clkInternal <= ~clkInternal;
          counter <= 0;
        end
      end
    endcase
  end
  assign CK_PLL_OUT0 = PS0_BYPASS ? CK_AUX_IN : RST_N ? clkOut : 1'b0;
`endif



endmodule  // pPLL02F
