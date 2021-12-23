//Verilog HDL for "pd_gf22_PLL02", "pd_gf22_PLL02" "behavioural"
//==============================================================================
// Perceptia - Confidential Property
//
//
// Variant ID   : PLL02
// Date         : 2019-07-09
// Version      : 1.2
// Change Notes : 2019-06-18 - Added IFDEF's for power ports & related statements
//                   to make them optional
//                2019-06-18 - Added unique identifier "pPLL02" to each message 
//                2019-07-05 - Updated message outputs to include [ERROR]/[WARNING]/[INFO] identifier
//                             Added module name into output text.
//                             Made printing of messages dependant on a flag variable which can be overridden
//                             Included plusargs options to set whether each category of message is printed
//                2019-07-09 - Updated seq_period code to remove chance of setting pll_period out of range 
//==============================================================================

`timescale 1fs/1fs

//module pd_gf22_PLL02 ( 
module pPLL02F ( 
`ifdef POWER_AND_GROUND
    VDD_DIG, 
    GND_DIG, 
    GND_ANA, 
    VDD_ANA, 
`endif
    RST_N, 
    CK_XTAL_IN,
    PS1_EN, 
    CK_AUX_IN, 
    CK_PLL_OUT0, 
    CK_PLL_OUT1, 
    SSC_EN, 
    LOCKED, 
    PS0_BYPASS, 
    PS1_BYPASS,
    SCAN_CK, 
    SCAN_IN, 
    SCAN_MODE, 
    SCAN_EN, 
    SCAN_OUT, 
    PS0_EN, 
    PS0_L2, 
    PS0_L1, 
    PS1_L2,
    PS1_L1, 
    PRESCALE, 
    SSC_STEP, 
    SSC_PERIOD, 
    INTEGER_MODE, 
    MUL_INT, 
    MUL_FRAC, 
    LDET_CONFIG,
    LF_CONFIG );

`ifdef POWER_AND_GROUND
  input  wire VDD_ANA;              //Analog Vdd
  input  wire GND_ANA;              //Analog ground
  input  wire VDD_DIG;              //Digital Vdd
  input  wire GND_DIG;              //Digital ground
`endif
  
  input  wire RST_N;                //Reset - asserted low
  input  wire CK_AUX_IN;            //Clock input for bypass
  input  wire CK_XTAL_IN;           //Reference clock input
  input  wire [3:0] PRESCALE;       //Divide ratio for the CK_XTAL prescaler

  input  wire SSC_EN;               //Enable SSC
  input  wire [7:0] SSC_STEP;       //SSC frequency step
  input  wire [10:0] SSC_PERIOD;    //The number of reference clock cycles per SSC cycle

  input  wire INTEGER_MODE;         //Integer mode (not fractional mode)
  input  wire [10:0] MUL_INT;       //Integer component of multiplication ratio
  input  wire [11:0] MUL_FRAC;      //Fractional component of multiplication ratio
  
  output wire LOCKED;               //Indicates when the PLL is locked

  input  wire [8:0] LDET_CONFIG;    //Settings for the lock detector
  input  wire [34:0] LF_CONFIG;     //Settings for the PLL loop filter

  input  wire PS0_EN;               //Enable first output
  input  wire PS0_BYPASS;           //Bypass first output
  input  wire [1:0] PS0_L1;         //Divide ratio of L1 divider of first output
  input  wire [7:0] PS0_L2;         //Divide ratio of L2 divider of first output
  output CK_PLL_OUT0;               //First clock output

  input  wire PS1_EN;               //Enable second output
  input  wire PS1_BYPASS;           //Bypass second output
  input  wire [1:0] PS1_L1;         //Divide ratio of L1 divider of second output
  input  wire [7:0] PS1_L2;         //Divide ratio of L2 divider of second output
  output wire CK_PLL_OUT1;          //Second clock output

  input  wire SCAN_IN;              //Scan chain data input
  input  wire SCAN_CK;              //Scan chain clock
  input  wire SCAN_EN;              //Scan chain enable
  input  wire SCAN_MODE;            //Configure for scan testing
  output wire SCAN_OUT;             //Scan chain output

wire pwr_ok, clk_ref, ps0_rst_n, ps1_rst_n, scan_ok, int_rst_n, ld_rst_n, period_stable, pll_in_range;
reg print_err, print_warn, print_info;
reg  pll_running, pr_toggle, pr_sync_neg, ps0_toggle, ps1_toggle, ps0_sync_neg, ps1_sync_neg, in_scan;
reg  ps0_clk, ps1_clk, ld_locked, scanout;
reg  pll_clk, pll_div2, pll_div4, pll_div8; 
reg  [2:0] prescaler_count;
reg  [6:0] ps0_l2_count, ps1_l2_count;
wire [14:0] ld_time;
reg  [14:0] ld_count;
reg  [9:0] fctl_count;
time last_time, ref_period, last_period, pll_period;

`ifdef POWER_AND_GROUND
    assign pwr_ok = ((VDD_DIG === 1'b1) && (VDD_ANA === 1'b1) && (GND_DIG === 1'b0) && (GND_ANA === 1'b0)) ? 1'b1 : 1'b0;
`else
    assign pwr_ok = 1'b1;
`endif

//==============================================================================
// Initial values for some variables
//==============================================================================
  initial begin
      fctl_count = 10'd0;
      ref_period = 8000000;
      pll_period = 1000000;
// Change the following to turn off/on message printing
      print_err  = ($test$plusargs("NO_ERROR")) ? 1'b0: 1'b1;        // when 1, [ERROR] messages are displayed
      print_warn = ($test$plusargs("NO_WARN")) ? 1'b0: 1'b1;        // when 1, [WARNING] messages are displayed
      print_info = ($test$plusargs("NO_INFO")) ? 1'b0: 1'b1;        // when 1, [INFO] messages are displayed
  end // initial

assign int_rst_n = RST_N & pwr_ok;


//==============================================================================
// Prescaler
//==============================================================================
  always @ (posedge CK_XTAL_IN or int_rst_n) begin : seq_prescale_ctr
    if (!int_rst_n) begin
      prescaler_count <= ~PRESCALE[3:1];
      pr_toggle <= 1'd0;
    end 
    else begin
      if (prescaler_count == 3'b111) begin
        prescaler_count <= (~pr_toggle | ~PRESCALE[0]) ? ((~PRESCALE[3:1]) + 3'd1) : ~PRESCALE[3:1];
        pr_toggle <= ~pr_toggle;
      end
      else begin
        prescaler_count <= prescaler_count + 3'd1;
        pr_toggle <= pr_toggle;
      end
    end
  end  // seq_prescale_ctr

  always @ (negedge CK_XTAL_IN or int_rst_n) begin : seq_prescale_neg
    if (!int_rst_n) begin
      pr_sync_neg <= 1'b0;
    end 
    else begin 
      pr_sync_neg <= (PRESCALE[0] == 1'b1) ? pr_toggle : 1'b0;
    end
  end  // seq_prescale_neg

assign clk_ref = (PRESCALE[3:1] == 3'b000) ? CK_XTAL_IN : (pr_toggle | pr_sync_neg);


//==============================================================================
// SSC 
//==============================================================================

   // REGISTERS
   reg  [16:0] ssc_mod_accum;
   reg  [10:0] ssc_step_ctr;
   reg  ssc_up_down;
   // WIRES
   wire [27:0] ssc_full_mult;
   wire [11:0] ssc_mul_frac;
   wire ssc_rst_n;

  assign ssc_mul_frac = INTEGER_MODE ? 12'd0 : MUL_FRAC;
  assign ssc_full_mult = { MUL_INT, ssc_mul_frac, 5'd0} + {11'd0, ssc_mod_accum};
  assign ssc_rst_n = RST_N & SSC_EN & ld_locked;
  
  always @ (posedge clk_ref or ssc_rst_n) begin : ssc_mod_seq
    if (!ssc_rst_n) begin
      ssc_up_down <= 1'b1; 
      ssc_step_ctr <= 11'd1; 
      ssc_mod_accum <= 17'd0;
    end 
    else begin
      ssc_up_down <= (ssc_step_ctr == SSC_PERIOD) ? !ssc_up_down : ssc_up_down; 
      ssc_step_ctr <= (ssc_step_ctr == SSC_PERIOD) ? 11'd1 : ssc_step_ctr + 11'd1;
      ssc_mod_accum <= (ssc_up_down) ? ssc_mod_accum + {9'd0, SSC_STEP}
                                     : ssc_mod_accum - {9'd0, SSC_STEP};
    end
  end  // ssc_mod_seq

  

//==============================================================================
// Simple PLL model
//==============================================================================
  always @ (posedge clk_ref or int_rst_n) begin : seq_startup
    if (!int_rst_n) begin
      pll_running <= 1'b0;
      fctl_count <= 10'd0;
    end else begin
      pll_running <= ((fctl_count[9] == 1'b1) ? 1'b1 : pll_running) & ~in_scan;
       //count 512 cycles (approx # of cycles representing worst case startup calibration)
      fctl_count <= (fctl_count[9] == 1'b0) ? fctl_count + 10'd1 : fctl_count;
    end
  end  // seq_startup

  always @ (posedge clk_ref) begin : seq_period
    if (fctl_count < 10'd3) begin
      last_time <= $time;
      ref_period <= 8000000;
      pll_period <= 1000000;
      last_period <= 1000000;
    end 
    else begin 
      last_time <= $time;
      ref_period <= $time - last_time;
      //Don't change the PLL period if ref_period is out of range. Will get separate error message about ref_period 
      //pll_period <= ((ref_period >= 8000000) && (ref_period <= 200000000)) ? (ref_period * (2 ** 17)) / ssc_full_mult : pll_period;
      //pll_period <= ((ref_period >= 8000000) && (ref_period <= 200000000)) ? (ref_period ) / MUL_INT : pll_period;
      pll_period <= 2500000;
      //pll_period <= 100000000 / MUL_INT;
      last_period <= pll_period;
    end
  end  // seq_period

assign period_stable = (pll_period == last_period) || SSC_EN ? 1'b1 : 1'b0;
assign pll_in_range = (pll_period >= 500000) && (pll_period <= 250000000) &&                //DCO frequency range 4MHz to 2GHz
                      (ref_period >= 8000000) && (ref_period <= 200000000) ? 1'b1 : 1'b0;   //REF frequency 5MHz to 125MHz

  
always #(pll_period/2) pll_clk = ~(pll_clk & int_rst_n & pll_in_range);

  always @ (posedge pll_clk or int_rst_n) begin : seq_div2
    if (!int_rst_n) begin
      pll_div2 <= 1'b0;
    end 
    else begin 
      pll_div2 <= ~pll_div2;
    end
  end  // seq_div2
  
  always @ (posedge pll_div2 or int_rst_n) begin : seq_div4
    if (!int_rst_n) begin
      pll_div4 <= 1'b0;
    end 
    else begin 
      pll_div4 <= ~pll_div4;
    end
  end  // seq_div4
  
  always @ (posedge pll_div4 or int_rst_n) begin : seq_div8
    if (!int_rst_n) begin
      pll_div8 <= 1'b0;
    end 
    else begin 
      pll_div8 <= ~pll_div8;
    end
  end  // seq_div8



//==============================================================================
// Postscaler 0 
//==============================================================================
assign ps0_rst_n = int_rst_n & PS0_EN & pll_running;

  always @(*) begin : ps0_l1_comb
    case (PS0_L1)
        2'd0 : begin
          ps0_clk = pll_clk & ps0_rst_n;
        end
        2'd1 : begin
          ps0_clk = pll_div2 & ps0_rst_n;
        end
        2'd2 : begin
          ps0_clk = pll_div4 & ps0_rst_n;
        end
        2'd3 : begin
          ps0_clk = pll_div8 & ps0_rst_n;
        end
        default : begin
          ps0_clk = pll_div8 & ps0_rst_n;
        end
      endcase
    end //ps0_l1_comb
    
  always @ (posedge ps0_clk or ps0_rst_n) begin : seq_ps0_ctr
    if (!ps0_rst_n) begin
      ps0_l2_count <= ~PS0_L2[7:1];
      ps0_toggle <= 1'd0;
    end 
    else begin
      if (ps0_l2_count == 7'b111_1111) begin
        //if even divisor or toggle=0 then count 1 less
        ps0_l2_count <= (~ps0_toggle | ~PS0_L2[0]) ? ((~PS0_L2[7:1]) + 7'd1) : ~PS0_L2[7:1];
        ps0_toggle <= ~ps0_toggle;
      end
      else begin
        ps0_l2_count <= ps0_l2_count + 7'd1;
        ps0_toggle <= ps0_toggle;
      end
    end
  end  // seq_ps0_ctr

  always @ (negedge ps0_clk or ps0_rst_n) begin : seq_ps0_neg
    if (!ps0_rst_n) begin
      ps0_sync_neg <= 1'b0;
    end 
    else begin 
      ps0_sync_neg <= (PS0_L2[0] == 1'b1) ? ps0_toggle : 1'b0;
    end
  end  // seq_prescale_neg

assign CK_PLL_OUT0 = (PS0_BYPASS == 1'b1) ? CK_AUX_IN : 
                     ((SCAN_MODE === 1'b1) ? CK_XTAL_IN :
                     ((PS0_L2[7:1] == 7'd0) ? ps0_clk : (ps0_toggle | ps0_sync_neg)));


//==============================================================================
// Postscaler 1 
//==============================================================================
assign ps1_rst_n = int_rst_n & PS1_EN & pll_running;

  always @(*) begin : ps1_l1_comb
    case (PS1_L1)
        2'd0 : begin
          ps1_clk = pll_clk & ps1_rst_n;
        end
        2'd1 : begin
          ps1_clk = pll_div2 & ps1_rst_n;
        end
        2'd2 : begin
          ps1_clk = pll_div4 & ps1_rst_n;
        end
        2'd3 : begin
          ps1_clk = pll_div8 & ps1_rst_n;
        end
        default : begin
          ps1_clk = pll_div8 & ps1_rst_n;
        end
      endcase
    end //ps1_l1_comb

  always @ (posedge ps1_clk or ps1_rst_n) begin : seq_ps1_ctr
    if (!ps1_rst_n) begin
      ps1_l2_count <= ~PS1_L2[7:1];
      ps1_toggle <= 1'd0;
    end 
    else begin
      if (ps1_l2_count == 7'b111_1111) begin
        //if even divisor or toggle=0 then count 1 less
        ps1_l2_count <= (~ps1_toggle | ~PS1_L2[0]) ? ((~PS1_L2[7:1]) + 7'd1) : ~PS1_L2[7:1];
        ps1_toggle <= ~ps1_toggle;
      end
      else begin
        ps1_l2_count <= ps1_l2_count + 7'd1;
        ps1_toggle <= ps1_toggle;
      end
    end
  end  // seq_ps1_ctr

  always @ (negedge ps1_clk or ps1_rst_n) begin : seq_ps1_neg
    if (!ps1_rst_n) begin
      ps1_sync_neg <= 1'b0;
    end 
    else begin 
      ps1_sync_neg <= (PS1_L2[0] == 1'b1) ? ps1_toggle : 1'b0;
    end
  end  // seq_ps1_neg

assign CK_PLL_OUT1 = (PS1_BYPASS === 1'b1) ? CK_AUX_IN : 
                     ((SCAN_MODE === 1'b1) ? CK_XTAL_IN :
                     ((PS1_L2[7:1] == 7'd0) ? ps1_clk : (ps1_toggle | ps1_sync_neg)));
                     
//==============================================================================
// Lock detect
//==============================================================================
assign ld_time = 15'd128 << LDET_CONFIG[5:3];

assign ld_rst_n = int_rst_n & period_stable & pll_in_range & pll_running;

//simple counter for lock
  always @ (posedge clk_ref or ld_rst_n) begin : seq_ldet
    if (!ld_rst_n) begin
      ld_locked <= 1'b0;
      ld_count <= ld_time;
    end else begin
      ld_locked <= (ld_count == 15'd0) ? 1'b1 : ld_locked;
      ld_count <= (pll_running && !ld_locked) ? ld_count - 15'd1 : ld_time;
    end
  end  // seq_ldet

assign LOCKED = (ld_locked & LDET_CONFIG[6]) | LDET_CONFIG[7];

//==============================================================================
// Scan
//==============================================================================
assign scan_ok = SCAN_MODE & SCAN_EN;

  always @ (posedge SCAN_CK or int_rst_n) begin : seq_scan
    if (!int_rst_n) begin
      in_scan <= 1'b0;
      scanout <= 1'b0;
    end 
    else begin 
      in_scan <= SCAN_MODE | SCAN_EN | in_scan;
      scanout <= SCAN_IN & scan_ok;
    end
  end  // seq_scan

assign SCAN_OUT = scanout;


//==============================================================================
// Display warnings & informationals
//==============================================================================

`ifdef POWER_AND_GROUND
always @ (pwr_ok) begin : seq_pwr_warn
  if (pwr_ok !== 1'b1 && print_err) begin
    $display("[ERROR] [%m] pPLL02 %0t ns: Power incorrectly applied! VDD_ANA = %b, VDD_DIG = %b, GND_ANA = %b, GND_DIG = %b", $realtime/1000000, VDD_ANA, VDD_DIG, GND_ANA, GND_DIG);
  end
  else if (print_info) begin
    $display("[INFO] [%m] pPLL02 %0t ns: Power OK! VDD_ANA = %b, VDD_DIG = %b, GND_ANA = %b, GND_DIG = %b", $realtime/1000000, VDD_ANA, VDD_DIG, GND_ANA, GND_DIG);
  end
end //seq_pwr_warn
`endif

always @ (MUL_INT, MUL_FRAC, INTEGER_MODE, PRESCALE, LDET_CONFIG, LF_CONFIG) begin : seq_rst_warn
  if (RST_N !== 1'b0 && print_err) begin
    $display("[ERROR] [%m] pPLL02 %0t ns: PLL controls changed unexpectedly! MUL_INT = %0d, MUL_FRAC = %0d, INTEGER_MODE = %b, PRESCALE = %0d, LDET_CONFIG = 0x%h, LF_CONFIG = 0x%h", $realtime/1000000, MUL_INT, MUL_FRAC, INTEGER_MODE, PRESCALE, LDET_CONFIG, LF_CONFIG);
  end
end //seq_rst_warn

always @ (PS0_L1, PS0_L2) begin : seq_ps0_warn
  if (PS0_EN !== 1'b0 && print_warn) begin
    $display("[WARNING] [%m] pPLL02 [%0t ns]: Postscaler0 controls changed unexpectedly! PS0_L1 = %0d, PS0_L2 = %0d", $realtime/1000000, PS0_L1, PS0_L2);
  end
end //seq_ps0_warn

always @ (PS1_L1, PS1_L2) begin : seq_ps1_warn
  if (PS1_EN !== 1'b0 && print_warn) begin
    $display("[WARNING] [%m] pPLL02  [%0t ns]: Postscaler1 controls changed unexpectedly! PS1_L1 = %0d, PS1_L2 = %0d", $realtime/1000000, PS1_L1, PS1_L2);
  end
end //seq_ps1_warn

always @ (posedge LOCKED) begin : seq_lock_gained
  if (LOCKED === 1'b1 && print_info) $display("[INFO] [%m] pPLL02 %0t ns: PLL locked!", $realtime/1000000);
end //seq_lock_gained

always @ (negedge LOCKED) begin : seq_lock_lost
  if (LOCKED === 1'b0 && print_info) $display("[INFO] [%m] pPLL02 %0t ns: PLL lost lock!", $realtime/1000000);
end //seq_lock_lost

always @ (negedge clk_ref) begin : seq_period_chg
  if (!period_stable && pll_running && print_warn) begin
    $display("[WARNING] [%m] pPLL02 %0t ns: DCO period changed whilst running! New period = %0t.%0t ps, previous period = %0t.%0t ps", $realtime/1000000, pll_period/1000, pll_period%1000, last_period/1000, last_period%1000);
  end
end //seq_period_chg

always @ (negedge CK_XTAL_IN) begin : seq_dco_chk
  if (((pll_period < 500000) || (pll_period > 250000000)) && pll_running && print_err) begin    //DCO frequency range 4MHz to 2GHz
    $display("[ERROR] [%m] pPLL02 %0t ns: DCO period out of range! PLL02 range is 500ps to 125ns. Programmed value is: %0t.%0t ps", $realtime/1000000, pll_period/1000, pll_period%1000);
  end
  if (((ref_period < 8000000) || (ref_period > 200000000)) && pll_running && print_err) begin   //REF frequency 5MHz to 125MHz
    $display("[ERROR] [%m] pPLL02 %0t ns: Scaled CK_XTAL_IN period out of range! Range is 8ns to 250ns. Programmed value is: %0t ns", $realtime/1000000, ref_period/1000000);
  end
end //seq_lock_lost

always @ (SCAN_EN, SCAN_MODE) begin : seq_scan_warn
  if (SCAN_EN === 1'b1 && SCAN_MODE===1'b1 && print_info) begin
    $display("[INFO] [%m] pPLL02 %0t ns: Entering SCAN mode ...", $realtime/1000000);
  end
  if (SCAN_EN === 1'b1 && SCAN_MODE===1'b0 && print_err) begin
    $display("[ERROR] [%m] pPLL02 %0t ns: Invalid SCAN control sequence! SCAN_EN may not be asserted whilst SCAN_MODE is deasserted.", $realtime/1000000);
  end
  if (SCAN_EN === 1'b0 && SCAN_MODE===1'b0 && print_info) begin
    $display("[INFO] [%m] pPLL02 %0t ns: SCAN mode exited, reset the PLL to resume normal operation.", $realtime/1000000);
  end
end //seq_scan_warn


endmodule
