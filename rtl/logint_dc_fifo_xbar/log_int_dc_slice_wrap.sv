////////////////////////////////////////////////////////////////////////////////
// Company:        Micrel Lab @ DEIS - University of Bologna                  //
//                    Viale Risorgimento 2 40136                              //
//                    Bologna - fax 0512093785 -                              //
//                                                                            //
// Engineer:       Igor Loi - igor.loi@unibo.it                               //
//                                                                            //
// Additional contributions by:                                               //
//                                                                            //
//                                                                            //
//                                                                            //
// Create Date:    07/02/2018                                                 //
// Design Name:    LOG INterco plugin                                         //
// Module Name:    log_int_dc_slice                                           //
// Project Name:   PULP                                                       //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    A Dual CLock fifo. Reqest is made on push side, the        //
//                 req is propagated on pop_side (pop_clk domain)  ,and       //
//                 then the response is forwarded to push_domain              //
//                                                                            //
//                                                                            //
//                                                                            //
// Revision:                                                                  //
// Revision v0.1 - 07/02/2018  : File Created                                 //
//                                                                            //
// Additional Comments:                                                       //
//                                                                            //
//                                                                            //
//                                                                            //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////


module log_int_dc_slice_wrap
#(
   parameter ADDR_WIDTH   = 32,
   parameter DATA_WIDTH   = 32,
   parameter BE_WIDTH     = DATA_WIDTH/8,
   parameter ID_WIDTH     = 4,
   parameter BUFFER_WIDTH = 4,
   parameter OUTPUT_FIFO  = "FALSE" // TRUE |  FALSE
)
(
   // PUSH SIDE
   input  logic                                             push_clk,
   input  logic                                             push_rst_n,
   XBAR_TCDM_BUS.Slave                                      push_bus,


   // POP SIDE
   input  logic                                             pop_clk,
   input  logic                                             pop_rst_n,
   input  logic                                             test_cgbypass_i,
   XBAR_TCDM_BUS.Master                                     pop_bus
);

   log_int_dc_slice
   #(
      .ADDR_WIDTH       ( ADDR_WIDTH   ),
      .DATA_WIDTH       ( DATA_WIDTH   ),
      .BE_WIDTH         ( BE_WIDTH     ),
      .ID_WIDTH         ( ID_WIDTH     ),
      .BUFFER_WIDTH     ( BUFFER_WIDTH ),
      .OUTPUT_FIFO      ( OUTPUT_FIFO  )
   )
   i_log_int_dc_slice
   (
      // PUSH SIDE
      .push_clk         ( push_clk                     ),
      .push_rst_n       ( push_rst_n                   ),

      .data_req_i       ( push_bus.req                 ),
      .data_add_i       ( push_bus.add[ADDR_WIDTH-1:0] ),
      .data_wen_i       ( push_bus.wen                 ),
      .data_wdata_i     ( push_bus.wdata               ),
      .data_be_i        ( push_bus.be                  ),
      .data_ID_i        ( '0                           ),
      .data_gnt_o       ( push_bus.gnt                 ),

      .data_r_valid_o   ( push_bus.r_valid             ),
      .data_r_rdata_o   ( push_bus.r_rdata             ),
      .data_r_ID_o      (                              ),


      // POP SIDE
      .pop_clk          ( pop_clk                      ),
      .pop_rst_n        ( pop_rst_n                    ),
      .test_cgbypass_i  ( test_cgbypass_i              ),

      .data_req_o       ( pop_bus.req                  ),
      .data_add_o       ( pop_bus.add[ADDR_WIDTH-1:0]  ),
      .data_wen_o       ( pop_bus.wen                  ),
      .data_wdata_o     ( pop_bus.wdata                ),
      .data_be_o        ( pop_bus.be                   ),
      .data_ID_o        (                              ),
      .data_gnt_i       ( pop_bus.gnt                  ),

      .data_r_valid_i   ( pop_bus.r_valid              ),
      .data_r_rdata_i   ( pop_bus.r_rdata              ),
      .data_r_ID_i      (   '0                         )
   );



endmodule // log_int_dc_slice