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
    input       rstn,
    input logic PWRDN,
    //Clock Inputs
    input logic CK_XTAL_IN,
    input logic CK_AUX_IN,

    //Clock Outputs
    output logic CK_PLL_OUT,
    output logic CK_PLL_DIV0,
    output logic CK_PLL_DIV1,

    //Control Inputs for Output Dividers
    input logic       PS0_EN,
    input logic       PS1_EN,
    input logic       PS0_BYPASS,
    input logic       PS1_BYPASS,
    input logic [1:0] PS0_L1,
    input logic [1:0] PS1_L1,
    input logic [7:0] PS0_L2_INT,
    input logic [5:0] PS0_L2_FRAC,
    input logic [7:0] PS1_L2_INT,
    input logic [5:0] PS1_L2_FRAC,

    //Control Inputs for SSC Modulation Control
    input logic        SSC_EN,
    input logic [ 7:0] SSC_STEP,
    input logic [10:0] SSC_PERIOD,

    //Control Inputs for Multiplication Ratio
    input logic [10:0] MUL_INT,
    input logic [11:0] MUL_FRAC,
    input logic        INTEGER_MODE,
    input logic [ 3:0] PRESCALE,

    //Miscellaneous Control Inputs
    input logic [ 9:0] LDET_CONFIG,
    input logic [32:0] LF_CONFIG,

    //Status Output
    output logic LOCKED,

    //Scan and Test Signals
    output logic TEST_OUT,
    input  logic SCAN_CK,
    input  logic SCAN_IN,
    input  logic SCAN_MODE,
    input  logic SCAN_EN,
    output logic SCAN_OUT

);

  logic       clk;
  logic       clkOut;
  logic [7:0] counter;
`ifdef VERILATOR
  always @(posedge CK_XTAL_IN or negedge rstn) begin
    if (rstn == 0) begin
      counter <= 0;
      clkOut  <= 0;
    end else begin
      counter <= counter + 1;
      if (counter == PS0_L2_INT) begin
        clkOut  <= ~clkOut;
        counter <= 0;
      end
    end  // else: !if(rstn == 0)
  end  // always @ (posedge ref_clk_i or negedge rstn)
`else
  initial counter = 0;
  initial clkOut = 0;
  initial clk = 0;
  //initial forever #(0.625) clk = ~clk;
  //always @(posedge clk) begin
  always @(posedge CK_XTAL_IN) begin
    counter <= counter + 1;
    if (counter == PS0_L2_INT) begin
      clkOut  <= ~clkOut;
      counter <= 0;
    end
  end
`endif

  assign CK_PLL_DIV0 = PS0_BYPASS ? CK_AUX_IN : clkOut;

endmodule  // pPLL02F
