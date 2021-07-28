////////////////////////////////////////////////////////////////////////////////
// Company:        Micrel Lab @ DEIS - University of Bologna                  //
//                    Viale Risorgimento 2 40136                              //
//                    Bologna - fax 0512093785 -                              //
//                                                                            //
// Engineer:       Igor Loi - igor.loi@unibo.it                               //
//                                                                            //
// Additional contributions by:                                               //
//                 Davide Schiavone - pschiavo@iis.ee.ethz.ch                 //
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

//`define TEST_FOR_HWCE
module log_int_dc_slice
#(
   parameter ADDR_WIDTH = 32,
   parameter DATA_WIDTH = 32,
   parameter BE_WIDTH   = DATA_WIDTH/8,
   parameter ID_WIDTH   = 4,
   parameter BUFFER_WIDTH = 4,
   parameter OUTPUT_FIFO  = "FALSE" // TRUE |  FALSE
)
(
   // PUSH SIDE
   input  logic                                             push_clk,
   input  logic                                             push_rst_n,

   input  logic                                             data_req_i,
   input  logic [ADDR_WIDTH - 1:0]                          data_add_i,
   input  logic                                             data_wen_i,
   input  logic [DATA_WIDTH - 1:0]                          data_wdata_i,
   input  logic [BE_WIDTH - 1:0]                            data_be_i,
   input  logic [ID_WIDTH - 1:0]                            data_ID_i,
   output logic                                             data_gnt_o,

   output logic                                             data_r_valid_o,
   output logic [DATA_WIDTH - 1:0]                          data_r_rdata_o,
   output logic [ID_WIDTH - 1:0]                            data_r_ID_o,


   // POP SIDE
   input  logic                                             pop_clk,
   input  logic                                             pop_rst_n,
   input  logic                                             test_cgbypass_i,

   output logic                                             data_req_o,
   output logic [ADDR_WIDTH - 1:0]                          data_add_o,
   output logic                                             data_wen_o,
   output logic [DATA_WIDTH - 1:0]                          data_wdata_o,
   output logic [BE_WIDTH - 1:0]                            data_be_o,
   output logic [ID_WIDTH - 1:0]                            data_ID_o,
   input  logic                                             data_gnt_i,

   input  logic                                             data_r_valid_i,
   input  logic [DATA_WIDTH - 1:0]                          data_r_rdata_i,
   input  logic [ID_WIDTH - 1:0]                            data_r_ID_i
);

   localparam WIDTH_REQ_FIFO  = ADDR_WIDTH + DATA_WIDTH + BE_WIDTH + ID_WIDTH;
   localparam WIDTH_RESP_FIFO = DATA_WIDTH  + ID_WIDTH;

   logic [WIDTH_REQ_FIFO-1:0]       data_req_push_ch_sync;
   logic [WIDTH_REQ_FIFO-1:0]       data_req_out_fifo;

   logic [WIDTH_REQ_FIFO-1:0]       data_req_pop_ch_sync;
   logic                            valid_req_pop_ch_sync;
   logic                            ready_req_pop_ch_sync;


   logic [WIDTH_REQ_FIFO-1:0]       data_req_ch_async;
   logic [BUFFER_WIDTH-1:0]         req_writetoken, req_readpointer;



   logic [WIDTH_RESP_FIFO-1:0]       data_resp_push_ch_sync;
   logic [WIDTH_RESP_FIFO-1:0]       data_resp_out_fifo, data_resp_out_fifo_reg;

   logic [WIDTH_RESP_FIFO-1:0]       data_resp_pop_ch_sync;
   logic                             valid_resp_pop_ch_sync;
   logic                             ready_resp_pop_ch_sync;

   logic [WIDTH_RESP_FIFO-1:0]       data_resp_ch_async;
   logic [BUFFER_WIDTH-1:0]          resp_writetoken, resp_readpointer;



   //////////////////////////////////////////////////////////////////////////////////////
   // ██████╗ ███████╗ ██████╗ ██╗   ██╗███████╗███████╗████████╗      ██████╗██╗  ██╗ //
   // ██╔══██╗██╔════╝██╔═══██╗██║   ██║██╔════╝██╔════╝╚══██╔══╝     ██╔════╝██║  ██║ //
   // ██████╔╝█████╗  ██║   ██║██║   ██║█████╗  ███████╗   ██║        ██║     ███████║ //
   // ██╔══██╗██╔══╝  ██║▄▄ ██║██║   ██║██╔══╝  ╚════██║   ██║        ██║     ██╔══██║ //
   // ██║  ██║███████╗╚██████╔╝╚██████╔╝███████╗███████║   ██║███████╗╚██████╗██║  ██║ //
   // ╚═╝  ╚═╝╚══════╝ ╚══▀▀═╝  ╚═════╝ ╚══════╝╚══════╝   ╚═╝╚══════╝ ╚═════╝╚═╝  ╚═╝ //
   //////////////////////////////////////////////////////////////////////////////////////

   assign data_req_push_ch_sync = { data_add_i, data_wen_i, data_wdata_i, data_be_i, data_ID_i };
   assign { data_add_o, data_wen_o, data_wdata_o, data_be_o, data_ID_o } = data_req_out_fifo;

   dc_token_ring_fifo_din #(WIDTH_REQ_FIFO , BUFFER_WIDTH)
   dc_req_ch_push
   (
     .clk          ( push_clk                  ),
     .rstn         ( push_rst_n                ),
     .data         ( data_req_push_ch_sync     ),
     .valid        ( data_req_i                ),
`ifndef TEST_FOR_HWCE
     .ready        ( data_gnt_o                ),
`else
     .ready        (           ),
`endif
     .write_token  ( req_writetoken            ),
     .read_pointer ( req_readpointer           ),
     .data_async   ( data_req_ch_async         )
   );

   dc_token_ring_fifo_dout #(WIDTH_REQ_FIFO, BUFFER_WIDTH)
   dc_req_ch_pop
   (
     .clk          ( pop_clk                  ),
     .rstn         ( pop_rst_n                ),

     .data         ( data_req_pop_ch_sync     ),
     .valid        ( valid_req_pop_ch_sync    ),
     .ready        ( ready_req_pop_ch_sync    ),

     .write_token  ( req_writetoken           ),
     .read_pointer ( req_readpointer          ),
     .data_async   ( data_req_ch_async        )
   );

generate
  if(OUTPUT_FIFO=="TRUE")
  begin :  REQ_FIFO
     generic_fifo
     #(
        .DATA_WIDTH ( WIDTH_REQ_FIFO ),
        .DATA_DEPTH ( 2              )
     )
     dc_req_out_fifo
     (
        .clk            ( pop_clk               ),
        .rst_n          ( pop_rst_n             ),
        .data_i         ( data_req_pop_ch_sync  ),
        .valid_i        ( valid_req_pop_ch_sync ),
        .grant_o        ( ready_req_pop_ch_sync ),

        .data_o         ( data_req_out_fifo     ),
        .valid_o        ( data_req_o            ),
        .grant_i        ( data_gnt_i            ),
        .test_mode_i    ( test_cgbypass_i       )
     );
  end
  else
  begin : NO_REQ_FIFO
    assign data_req_out_fifo = data_req_pop_ch_sync;
    assign data_req_o        = valid_req_pop_ch_sync;
    assign ready_req_pop_ch_sync = data_gnt_i;
  end
endgenerate



   /////////////////////////////////////////////////////////////////////////////////////////////////
   // ██████╗ ███████╗███████╗██████╗  ██████╗ ███╗   ██╗███████╗███████╗         ██████╗██╗  ██╗ //
   // ██╔══██╗██╔════╝██╔════╝██╔══██╗██╔═══██╗████╗  ██║██╔════╝██╔════╝        ██╔════╝██║  ██║ //
   // ██████╔╝█████╗  ███████╗██████╔╝██║   ██║██╔██╗ ██║███████╗█████╗          ██║     ███████║ //
   // ██╔══██╗██╔══╝  ╚════██║██╔═══╝ ██║   ██║██║╚██╗██║╚════██║██╔══╝          ██║     ██╔══██║ //
   // ██║  ██║███████╗███████║██║     ╚██████╔╝██║ ╚████║███████║███████╗███████╗╚██████╗██║  ██║ //
   // ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝      ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚══════╝╚══════╝ ╚═════╝╚═╝  ╚═╝ //
   /////////////////////////////////////////////////////////////////////////////////////////////////

   assign data_resp_push_ch_sync = { data_r_rdata_i, data_r_ID_i };

`ifndef TEST_FOR_HWCE
   assign { data_r_rdata_o, data_r_ID_o } = data_resp_out_fifo;
`else
   assign { data_r_rdata_o, data_r_ID_o } = data_resp_out_fifo_reg;
`endif
   dc_token_ring_fifo_din #(WIDTH_RESP_FIFO , BUFFER_WIDTH)
   dc_resp_ch_push
   (
     .clk          ( pop_clk                   ),
     .rstn         ( pop_rst_n                 ),

     .data         ( data_resp_push_ch_sync    ),
     .valid        ( data_r_valid_i            ),
     .ready        (                           ),

     .write_token  ( resp_writetoken           ),
     .read_pointer ( resp_readpointer          ),
     .data_async   ( data_resp_ch_async        )
   );

   dc_token_ring_fifo_dout #(WIDTH_RESP_FIFO, BUFFER_WIDTH)
   dc_resp_ch_pop
   (
     .clk          ( push_clk                  ),
     .rstn         ( push_rst_n                ),

     .data         ( data_resp_pop_ch_sync     ),
     .valid        ( valid_resp_pop_ch_sync    ),
     .ready        ( ready_resp_pop_ch_sync    ),

     .write_token  ( resp_writetoken           ),
     .read_pointer ( resp_readpointer          ),
     .data_async   ( data_resp_ch_async        )
   );

generate
  if(OUTPUT_FIFO=="TRUE")
  begin :  RESP_FIFO
   generic_fifo
   #(
      .DATA_WIDTH ( WIDTH_RESP_FIFO ),
      .DATA_DEPTH ( 2               )
   )
   dc_resp_out_fifo
   (
      .clk            ( push_clk               ),
      .rst_n          ( push_rst_n             ),
      .data_i         ( data_resp_pop_ch_sync  ),
      .valid_i        ( valid_resp_pop_ch_sync ),
      .grant_o        ( ready_resp_pop_ch_sync ),

      .data_o         ( data_resp_out_fifo    ),
      .valid_o        ( data_r_valid_o        ),
      .grant_i        ( 1'b1                  ),
      .test_mode_i    ( test_cgbypass_i       )
   );
 end
 else
 begin : NO_RESP_FIFO
    assign data_resp_out_fifo     = data_resp_pop_ch_sync;

`ifndef TEST_FOR_HWCE
    assign data_r_valid_o         = valid_resp_pop_ch_sync;
`else

    always_ff @(posedge push_clk or negedge push_rst_n) begin
      if(~push_rst_n) begin
         data_resp_out_fifo_reg <= '0;
         data_r_valid_o         <= 1'b0;
      end else begin
        if(valid_resp_pop_ch_sync) begin
         data_resp_out_fifo_reg <= data_resp_out_fifo;
        end
        data_r_valid_o <= valid_resp_pop_ch_sync;
      end
    end

    assign data_gnt_o = valid_resp_pop_ch_sync;

`endif

    assign ready_resp_pop_ch_sync = 1'b1;

 end
endgenerate



endmodule // log_int_dc_slice
