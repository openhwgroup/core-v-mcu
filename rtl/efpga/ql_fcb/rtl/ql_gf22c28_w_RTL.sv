
//------------------------------------------------------------------------//
//-- QuickLogic confidential 2014                                       --//
//--                                                                    --//
//-- Original Owner     :                                               --//
//-- Module Function    :                                               --//
//--                                                                    --//
//-- $Rev::                             $:                              --//
//-- $Author::                          $:                              --//
//-- $Date::                            $:                              --//
//--                                                                    --//
//-- GF 22nm, Channel Length 28nm					--//
//--                                                                    --//
//------------------------------------------------------------------------//

	//----------------------------------------------------------------//
	//-- Clock Gating, 						--//	
	//-- Driving Strength X 4					--//
	//----------------------------------------------------------------//
module ql_clkgate_x4 (
input		clk_in,		// Clock Input
input		en,		// Clock Output Enable, High Active
input		se,		// Scan Enable, High Active, Tie 0 in RTL
output wire 	clk_out		// Clock Output
);

`ifdef GATE_SIM

SC8T_CKGPRELATNX4_CSC28H SC8T_CKGPRELATNX4_CSC28H_INST (
.Z		(clk_out),
.CLK		(clk_in),
.E		(en),
.TE		(se)
);

`else

assign  clk_out = en ? clk_in : 0 ;	

`endif

endmodule

        //----------------------------------------------------------------//
        //-- MUX                                                        --//
        //-- Driving Strength X 2                                       --//
        //----------------------------------------------------------------//
module ql_mux4_x2 (
input [1:0]     s,        // MUX Select 
input           i0,       // Input Port 0
input           i1,       // Input Port 1
input           i2,       // Input Port 2
input           i3,       // Input Port 3
output wire     z         // Output
); 


logic z0 ;
logic z1 ;

`ifdef GATE_SIM

SC8T_MUX2X1_CSC28H SC8T_MUX2X1_CSC28H_INST_0 (
.D0(i0)	,
.D1(i1)	,
.S(s[0]),
.Z(z0)
) ;

SC8T_MUX2X1_CSC28H SC8T_MUX2X1_CSC28H_INST_1 (
.D0(i2),
.D1(i3),
.S(s[0]),
.Z(z1)
) ;

SC8T_MUX2X1_CSC28H SC8T_MUX2X1_CSC28H_INST_2 (
.D0(z0),
.D1(z1),
.S(s[1]),
.Z(z)
) ;

`else

assign  z0 = s[0] ? i0 : i1 ;
assign  z1 = s[0] ? i2 : i3 ;
assign  z  = s[1] ? z0 : z1 ; 

`endif 

endmodule

        //----------------------------------------------------------------//
        //-- AND 2 Inputs                                               --//
        //-- Driving Strength X2                                        --//
        //----------------------------------------------------------------//
module ql_and2_x2 (
input           A1,      // Input Port 0
input           A2,      // Input Port 1
output wire     X        // Output
);

`ifdef GATE_SIM

SC8T_AN2X2_CSC28H SC8T_AN2X2_CSC28H_INST (
.A(A1),
.B(A2),
.Z(X)
) ;

`else 

assign  X = A1 & A2 ;

`endif

endmodule

        //----------------------------------------------------------------//
        //-- BUF 	   						--//
        //-- Driving Strength X2                                        --//
        //----------------------------------------------------------------//
module ql_buf_x2 (
input           A,      // Input Port 0
output wire     X        // Output
);

`ifdef GATE_SIM

SC8T_BUFX2_CSC28H SC8T_BUFX2_CSC28H_INST (
.A(A),
.Z(X)
) ;

`else
  
assign  X = A ;

`endif

endmodule
        //----------------------------------------------------------------//
        //-- CLKBUF                                                     --//
        //-- Driving Strength X2                                        --//
        //----------------------------------------------------------------//
module ql_clkbuf_x2 (
input           A,      // Input Port 0
output wire     X        // Output
);

`ifdef GATE_SIM

SC8T_CKBUFX2_CSC28H SC8T_CKBUFX2_CSC28H_INST (
.CLK(A),
.Z(X)
);

`else

assign  X = A ;

`endif 

endmodule

        //----------------------------------------------------------------//
        //-- INV 							--//
        //-- Driving Strength X2                                        --//
        //----------------------------------------------------------------//
module ql_inv_x2 (
input           A,      // Input Port 0
output wire     X        // Output
);

`ifdef GATE_SIM

SC8T_INVX2_CSC28H SC8T_INVX2_CSC28H_INST (
.A(A),
.Z(X)
);

`else

assign  X = ~A;

`endif

endmodule

        //----------------------------------------------------------------//
        //-- MUX2 X2                                                    --//
        //----------------------------------------------------------------//
module ql_mux2_x2 (
input     	s,        // MUX Select 
input           i0,       // Input Port 0
input           i1,       // Input Port 1
output wire     z         // Output
); 

`ifdef GATE_SIM

SC8T_CKMUX2X1_CSC28H SC8T_CKMUX2X1_CSC28H_INST (
.CLK1(i0),
.CLK2(i1),
.CLKSEL(s),
.Z(z)
) ;

`else 

assign z = s ? i0 : i1 ;

`endif

endmodule

        //----------------------------------------------------------------//
        //-- OR-3 Inputs 						--//
        //-- Driving Strength X4                                        --//
        //----------------------------------------------------------------//
module ql_or3_x4 (
input           A1,      // Input Port 1
input           A2,      // Input Port 2
input           A3,      // Input Port 3
output wire     X        // Output
);

logic X0 ;

`ifdef GATE_SIM

SC8T_OR2X1_CSC28H SC8T_OR2X1_CSC28H_INST_0 (
.A(A1),
.B(A2),
.Z(X0)
) ;

SC8T_OR2X1_CSC28H SC8T_OR2X1_CSC28H_INST_1 (
.A(A3),
.B(X0),
.Z(X)
) ;

`else

 assign X0 = A1 || A2 ;
 assign X  = A3 || X0 ;

`endif

endmodule

