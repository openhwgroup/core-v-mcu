// Copyright 2021 QuickLogic
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

//----------------------------------------------------------------//
//-- Clock Gating, 						--//	
//-- Driving Strength X 4					--//
//----------------------------------------------------------------//
module ql_clkgate_x4 (
    input clk_in,  // Clock Input
    input en,  // Clock Output Enable, High Active
    input se,  // Scan Enable, High Active, Tie 0 in RTL
    output wire clk_out  // Clock Output
);


  assign clk_out = en ? clk_in : 0;


endmodule

//----------------------------------------------------------------//
//-- MUX                                                        --//
//-- Driving Strength X 2                                       --//
//----------------------------------------------------------------//
module ql_mux4_x2 (
    input       [1:0] s,  // MUX Select 
    input             i0,  // Input Port 0
    input             i1,  // Input Port 1
    input             i2,  // Input Port 2
    input             i3,  // Input Port 3
    output wire       z  // Output
);


  logic z0;
  logic z1;


  assign z0 = s[0] ? i0 : i1;
  assign z1 = s[0] ? i2 : i3;
  assign z  = s[1] ? z0 : z1;

endmodule

//----------------------------------------------------------------//
//-- AND 2 Inputs                                               --//
//-- Driving Strength X2                                        --//
//----------------------------------------------------------------//
module ql_and2_x2 (
    input       A1,  // Input Port 0
    input       A2,  // Input Port 1
    output wire X  // Output
);


  assign X = A1 & A2;


endmodule

//----------------------------------------------------------------//
//-- BUF 	   						--//
//-- Driving Strength X2                                        --//
//----------------------------------------------------------------//
module ql_buf_x2 (
    input       A,  // Input Port 0
    output wire X  // Output
);

  assign X = A;


endmodule
//----------------------------------------------------------------//
//-- CLKBUF                                                     --//
//-- Driving Strength X2                                        --//
//----------------------------------------------------------------//
module ql_clkbuf_x2 (
    input       A,  // Input Port 0
    output wire X  // Output
);


  assign X = A;


endmodule

//----------------------------------------------------------------//
//-- INV 							--//
//-- Driving Strength X2                                        --//
//----------------------------------------------------------------//
module ql_inv_x2 (
    input       A,  // Input Port 0
    output wire X  // Output
);


  assign X = ~A;

endmodule

//----------------------------------------------------------------//
//-- MUX2 X2                                                    --//
//----------------------------------------------------------------//
module ql_mux2_x2 (
    input       s,  // MUX Select 
    input       i0,  // Input Port 0
    input       i1,  // Input Port 1
    output wire z  // Output
);


  assign z = s ? i0 : i1;

endmodule

//----------------------------------------------------------------//
//-- OR-3 Inputs 						--//
//-- Driving Strength X4                                        --//
//----------------------------------------------------------------//
module ql_or3_x4 (
    input       A1,  // Input Port 1
    input       A2,  // Input Port 2
    input       A3,  // Input Port 3
    output wire X  // Output
);

  logic X0;


  assign X0 = A1 || A2;
  assign X  = A3 || X0;


endmodule

