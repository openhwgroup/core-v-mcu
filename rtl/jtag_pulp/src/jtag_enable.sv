module jtag_enable
(
    input logic			capture_syn_i,
    input logic			shift_syn_i,
    input logic			update_syn_i,
    
    input logic			enable_i,
    
    input logic			axireg_sel_syn_i,		
    input logic			bbmuxreg_sel_syn_i,
    input logic			clkgatereg_sel_syn_i,
    input logic			confreg_sel_syn_i,
    
    output  logic		axireg_capture_syn_o,
    output  logic		axireg_shift_syn_o,
    output  logic		axireg_update_syn_o,
    output  logic		bbmuxreg_capture_syn_o,
    output  logic		bbmuxreg_shift_syn_o,
    output  logic		bbmuxreg_update_syn_o,
    output  logic		clkgatereg_capture_syn_o,
    output  logic		clkgatereg_shift_syn_o,
    output  logic		clkgatereg_update_syn_o,
    output  logic		confreg_capture_syn_o,
    output  logic		confreg_shift_syn_o,
    output  logic		confreg_update_syn_o,
    
    output logic		update_enable_o
 
);

   assign axireg_capture_syn_o     = axireg_sel_syn_i & capture_syn_i;
   assign axireg_shift_syn_o       = axireg_sel_syn_i & shift_syn_i;
   assign axireg_update_syn_o      = axireg_sel_syn_i & update_syn_i;
   
   assign bbmuxreg_capture_syn_o   = bbmuxreg_sel_syn_i & capture_syn_i;
   assign bbmuxreg_shift_syn_o     = bbmuxreg_sel_syn_i & shift_syn_i;
   assign bbmuxreg_update_syn_o    = bbmuxreg_sel_syn_i & update_syn_i;

   assign clkgatereg_capture_syn_o = clkgatereg_sel_syn_i & capture_syn_i;
   assign clkgatereg_shift_syn_o   = clkgatereg_sel_syn_i & shift_syn_i;
   assign clkgatereg_update_syn_o  = clkgatereg_sel_syn_i & update_syn_i;
   
   assign confreg_capture_syn_o    = confreg_sel_syn_i & capture_syn_i;
   assign confreg_shift_syn_o      = confreg_sel_syn_i & shift_syn_i;
   assign confreg_update_syn_o     = confreg_sel_syn_i & update_syn_i;
   
   assign update_enable_o          = enable_i & update_syn_i;

endmodule