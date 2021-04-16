//------------------------------------------------------------------------//
//-- QuickLogic Confidential 2014                                       --//
//--                                                                    --//
//-- Original Owner     : JCHENG                                        --//
//-- Module Function    : Memory Implemented by Register, Configurable  --//
//--                      The Depth must be Power of 2                  --//
//--                      Read --> ASYNC                                --//
//-- $Rev::                             $:                              --//
//-- $Author::                          $:                              --//
//-- $Date::                            $:                              --//
//--                                                                    --//
//------------------------------------------------------------------------//

module qf_rfm
# (parameter PAR_MEMORY_WIDTH_BIT       = 64,
   parameter PAR_MEMORY_DEPTH_BIT       =  4
)
(
        //----------------------------------------------------------------//
        //-- INPUT                                                      --//
        //----------------------------------------------------------------//
input  wire                                   rfm_clk,
input  wire                                   rfm_wr_en,
input  wire [PAR_MEMORY_DEPTH_BIT-1:0]        rfm_wr_addr,
input  wire [PAR_MEMORY_WIDTH_BIT-1:0]        rfm_wr_data,
input  wire [PAR_MEMORY_DEPTH_BIT-1:0]        rfm_rd_addr,
        //----------------------------------------------------------------//
        //--  Output                                                    --//
        //----------------------------------------------------------------//
output wire [PAR_MEMORY_WIDTH_BIT-1:0]        rfm_rd_data
);
        //------------------------------------------------------------------------//
        //-- Declare Time Unit                                                  --//
        //------------------------------------------------------------------------//
timeunit                                        1ns;
timeprecision                                   100ps ;


parameter PAR_DLY       = 1'b1 ;
reg [PAR_MEMORY_WIDTH_BIT-1:0]  memory_data [2**PAR_MEMORY_DEPTH_BIT-1:0] ;

        //----------------------------------------------------------------//
        //--  Read                                                      --//
        //----------------------------------------------------------------//
assign rfm_rd_data = memory_data[rfm_rd_addr];
        //----------------------------------------------------------------//
        //--  Write                                                     --//
        //----------------------------------------------------------------//
always @ (posedge rfm_clk )
begin
  if ( rfm_wr_en == 1'b1 )
    begin
      memory_data[rfm_wr_addr] <= #PAR_DLY rfm_wr_data ;
    end
end

endmodule 
