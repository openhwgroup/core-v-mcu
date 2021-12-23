// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1


/*module clk_and_control #(
parameter PLLNUM = 1)*/
module clk_and_control
(
                        input               clk,
                        output logic        FLLCLK,
                        input logic         FLLOE,
                        input logic         REFCLK,
                        output logic        LOCK,
                        input logic         CFGREQ,
                        output logic        CFGACK,
                        input logic [ 1:0]  CFGAD,
                        input logic [31:0]  CFGD,
                        output logic [31:0] CFGQ,
                        input logic         CFGWEB,
                        input logic         RSTB,
                        input logic         PWD,
                        input logic         RET,
                        input logic         TM,
                        input logic         TE,
                        input logic         TD, //TO FIX DFT
                        output logic        TQ, //TO FIX DFT
                        input logic         JTD, //TO FIX DFT
                        output logic        JTQ  //TO FIX DFT

);

  logic [31:0] config0;
  logic [31:0] config1;
  logic [31:0] config2;
  logic [31:0] config3;

  logic [1:0] s_PS0_L1;
  logic [1:0] s_PS1_L1;
  logic [7:0] s_PS0_L2;
  logic [5:0] s_PS0_L2_FRAC;
  logic [7:0] s_PS1_L2;
  logic [5:0] s_PS1_L2_FRAC;

  logic s_PS0_EN;
  logic s_PS1_EN;
  logic s_PS0_BYPASS;
  logic s_PS1_BYPASS;
  logic [10:0] s_MUL_INT;
  logic [11:0] s_MUL_FRAC;
  logic s_INTEGER_MODE;
  logic [3:0] s_PRESCALE;

  logic [9:0] s_LDET_CONFIG;
  logic s_SSC_EN;
  logic [7:0] s_SSC_STEP;
  logic [10:0] s_SSC_PERIOD;

  logic [34:0] s_LF_CONFIG;
  logic [2:0] r_tmp;
   logic      pll_clk;
   logic      pll_rstn;

   assign pll_rstn = RSTB & config0[2];
   
/*   
  pulp_clock_mux2 ck_i (
      .clk0_i   (pll_clk),
      .clk1_i   (REFCLK),
      .clk_sel_i(s_PS0_BYPASS),
      .clk_o    (FLLCLK)
  );
 */
//generate 
//if ( PLLNUM == 1 )
   pPLL02F u0 (
           .RST_N(pll_rstn),
	       .CK_XTAL_IN(REFCLK),
	       .CK_AUX_IN(REFCLK),
	       .PRESCALE(s_PRESCALE),
	       .SSC_EN(s_SSC_EN),
	       .SSC_STEP(s_SSC_STEP),
	       .SSC_PERIOD(s_SSC_PERIOD),
	       .INTEGER_MODE(s_INTEGER_MODE),
	       .MUL_INT(s_MUL_INT),
	       .MUL_FRAC(s_MUL_FRAC),
	       .LOCKED(LOCK),
	       .LDET_CONFIG(s_LDET_CONFIG),
	       .LF_CONFIG(s_LF_CONFIG),
	       .PS0_EN(s_PS0_EN),
	       .PS0_BYPASS(s_PS0_BYPASS),
	       .PS0_L1(s_PS0_L1),
	       .PS0_L2(s_PS0_L2),
	       .CK_PLL_OUT0(FLLCLK),
	       .PS1_EN(1'b0),
	       .PS1_BYPASS(1'b1),
	       .PS1_L1(2'b00),
	       .PS1_L2(8'h0),
	       .CK_PLL_OUT1(),
	       .SCAN_IN(TD),
	       .SCAN_CK(1'b0),
	       .SCAN_EN(TE),
	       .SCAN_MODE(TM),
	       .SCAN_OUT(TQ)
	       );
/*else
   pPLL02F_x u0 (
	       .RST_N(pll_rstn),
	       .CK_XTAL_IN(REFCLK),
	       .CK_AUX_IN(REFCLK),
	       .PRESCALE(s_PRESCALE),
	       .SSC_EN(s_SSC_EN),
	       .SSC_STEP(s_SSC_STEP),
	       .SSC_PERIOD(s_SSC_PERIOD),
	       .INTEGER_MODE(s_INTEGER_MODE),
	       .MUL_INT(s_MUL_INT),
	       .MUL_FRAC(s_MUL_FRAC),
	       .LOCKED(LOCK),
	       .LDET_CONFIG(s_LDET_CONFIG),
	       .LF_CONFIG(s_LF_CONFIG),
	       .PS0_EN(s_PS0_EN),
	       .PS0_BYPASS(s_PS0_BYPASS),
	       .PS0_L1(s_PS0_L1),
	       .PS0_L2(s_PS0_L2),
	       .CK_PLL_OUT0(FLLCLK),
	       .PS1_EN(1'b0),
	       .PS1_BYPASS(1'b1),
	       .PS1_L1(2'b00),
	       .PS1_L2(8'h0),
	       .CK_PLL_OUT1(),
	       .SCAN_IN(TD),
	       .SCAN_CK(1'b0),
	       .SCAN_EN(TE),
	       .SCAN_MODE(TM),
	       .SCAN_OUT(TQ)
	       );
endgenerate*/
   localparam PS0_L1 = 2'b00;  //config0[1:0]
   localparam PS0_RSTN = 1'b0; // config0[2]
   localparam PS0_L2 = 8'b00000000; // config[11:4]
   localparam PS0_L2_FRAC = 6'b000000; // config0[17:12]



   
   assign s_PS0_L1 = config0[1:0];    //2
   assign s_PS0_L2 = config0[11:4]; //8
   assign s_PS0_L2_FRAC = config0[17:12];    //6


   assign s_PS0_EN = config1[0];  //1
   assign s_PS0_BYPASS = config1[2];  //1

   assign s_MUL_INT = config1[14:4];    //11
   assign s_MUL_FRAC = config1[26:15];   //12
   assign s_INTEGER_MODE = config1[27];     //1
   assign s_PRESCALE = config1[31:28];    //4
   
   assign s_LDET_CONFIG = config2[8:0]; //9
   assign s_SSC_EN = config2[9];     //1
   assign s_SSC_STEP = config2[17:10];  //8
   assign s_SSC_PERIOD = config2[28:18];   //11
   
   assign s_LF_CONFIG[31:0] = config3[31:0];   //32
   assign s_LF_CONFIG[34:32] = r_tmp[2:0];   //3

   always_ff @(posedge clk, negedge RSTB) begin
      if (RSTB == 1'b0) begin
	 r_tmp[2:0] <= 0;
	 config0 <= {14'b0,PS0_L2_FRAC,PS0_L2,1'b0,PS0_RSTN,PS0_L1};
	 config1 <= 32'h00000004;
	 config2 <= 32'h64;
	 config3 <= 32'h269;
         CFGACK <= 1'b0;
      end else begin
	 if (CFGREQ == 1'b1) begin
            if (CFGWEB == 0) begin
               if (CFGAD == 2'b00) config0 <= CFGD;
               else if (CFGAD == 2'b01) config1 <= CFGD;
               else if (CFGAD == 2'b10) config2 <= CFGD;
               else if (CFGAD == 2'b11) begin
		        config3 <= CFGD;
		        r_tmp[2:0]   <= config2[31:29];
               end
               CFGACK <= 1'b1;
            end
            else begin
               if (CFGAD == 2'b00) CFGQ <= config0;
               else if (CFGAD == 2'b01) CFGQ <= config1;
               else if (CFGAD == 2'b10) CFGQ <= {LOCK, s_LF_CONFIG[32], config2[29:0]};
               else if (CFGAD == 2'b11) CFGQ <= config3;
               CFGACK <= 1'b1;
            end // else: !if(CFGWEB)
	 end // if (CFGREQ == 1'b1)
	 else begin
            CFGACK <= 1'b0;
	 end // else: !if(CFGREQ == 1'b1)
      end // else: !if(RSTB == 1'b0)
   end // always_ff @ (posedge clk, negedge RSTB)
endmodule

