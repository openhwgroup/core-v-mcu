`timescale 1ns/1ps

module tb;

parameter ADDR_WIDTH = 32;
parameter DATA_WIDTH = 32;
parameter BE_WIDTH   = DATA_WIDTH/8;
parameter ID_WIDTH   = 4;
parameter AUX_WIDTH  = 2;
parameter BUFFER_WIDTH = 8;
parameter OUTPUT_FIFO  = "FALSE";

parameter CLK_PERIOD_PUSH  = 5.0;
parameter CLK_PERIOD_POP   = 3.01;



   event granted_req, fetch_enable_event;

   // PUSH SIDE
   logic                                             push_clk;
   logic                                             push_rst_n;
   
   logic                                             data_req_i;
   logic [ADDR_WIDTH - 1:0]                          data_add_i;
   logic                                             data_wen_i;
   logic [DATA_WIDTH - 1:0]                          data_wdata_i;
   logic [BE_WIDTH - 1:0]                            data_be_i;
   logic [AUX_WIDTH - 1:0]                           data_aux_i;
   logic [ID_WIDTH - 1:0]                            data_ID_i;
   logic                                             data_gnt_o;

   logic [AUX_WIDTH-1:0]                             data_r_aux_o;
   logic                                             data_r_valid_o;
   logic [DATA_WIDTH - 1:0]                          data_r_rdata_o;
   logic                                             data_r_opc_o;  
   logic [ID_WIDTH - 1:0]                            data_r_ID_o;


   // POP SIDE
   logic                                             pop_clk;
   logic                                             pop_rst_n;
   logic                                             test_cgbypass_i;

   logic                                             data_req_o;
   logic [ADDR_WIDTH - 1:0]                          data_add_o;
   logic                                             data_wen_o;
   logic [DATA_WIDTH - 1:0]                          data_wdata_o;
   logic [BE_WIDTH - 1:0]                            data_be_o;
   logic [AUX_WIDTH - 1:0]                           data_aux_o;
   logic [ID_WIDTH - 1:0]                            data_ID_o;
   logic                                             data_gnt_i;

   logic [AUX_WIDTH-1:0]                             data_r_aux_i;
   logic                                             data_r_valid_i;
   logic [DATA_WIDTH - 1:0]                          data_r_rdata_i;
   logic                                             data_r_opc_i;  
   logic [ID_WIDTH - 1:0]                            data_r_ID_i;


   logic                                             data_req_to_check;
   logic [ADDR_WIDTH - 1:0]                          data_add_to_check;
   logic                                             data_wen_to_check;
   logic [DATA_WIDTH - 1:0]                          data_wdata_to_check;
   logic [BE_WIDTH - 1:0]                            data_be_to_check;
   logic [AUX_WIDTH - 1:0]                           data_aux_to_check;
   logic [ID_WIDTH - 1:0]                            data_ID_to_check;

   logic fetch_enable, mask_gnt_i;

log_int_dc_slice
#(
   .ADDR_WIDTH   ( ADDR_WIDTH   ), //= 32,
   .DATA_WIDTH   ( DATA_WIDTH   ), //= 32,
   .BE_WIDTH     ( BE_WIDTH     ), //= DATA_WIDTH/8,
   .ID_WIDTH     ( ID_WIDTH     ), //= 4,
   .AUX_WIDTH    ( AUX_WIDTH    ), //= 2,
   .BUFFER_WIDTH ( BUFFER_WIDTH ), //= 4,
   .OUTPUT_FIFO  ( OUTPUT_FIFO  )  //= "FALSE" // TRUE |  FALSE
)
DUT
(
   // PUSH SIDE
   .push_clk        ( push_clk        ),
   .push_rst_n      ( push_rst_n      ),
   
   .data_req_i      ( data_req_i      ),
   .data_add_i      ( data_add_i      ),
   .data_wen_i      ( data_wen_i      ),
   .data_wdata_i    ( data_wdata_i    ),
   .data_be_i       ( data_be_i       ),
   .data_aux_i      ( data_aux_i      ),
   .data_ID_i       ( data_ID_i       ),
   .data_gnt_o      ( data_gnt_o      ),

   .data_r_aux_o    ( data_r_aux_o    ),
   .data_r_valid_o  ( data_r_valid_o  ),
   .data_r_rdata_o  ( data_r_rdata_o  ),
   .data_r_opc_o    ( data_r_opc_o    ),  
   .data_r_ID_o     ( data_r_ID_o     ),


   // POP SIDE
   .pop_clk         ( pop_clk         ),
   .pop_rst_n       ( pop_rst_n       ),
   .test_cgbypass_i ( test_cgbypass_i ),

   .data_req_o      ( data_req_o      ),
   .data_add_o      ( data_add_o      ),
   .data_wen_o      ( data_wen_o      ),
   .data_wdata_o    ( data_wdata_o    ),
   .data_be_o       ( data_be_o       ),
   .data_aux_o      ( data_aux_o      ),
   .data_ID_o       ( data_ID_o       ),
   .data_gnt_i      ( data_gnt_i      ),

   .data_r_aux_i    ( data_r_aux_i    ),
   .data_r_valid_i  ( data_r_valid_i  ),
   .data_r_rdata_i  ( data_r_rdata_i  ),
   .data_r_opc_i    ( data_r_opc_i    ),  
   .data_r_ID_i     ( data_r_ID_i     )
);

assign data_aux_i   = '0;
assign data_r_opc_i = '0;
assign test_cgbypass_i = 1'b0;
assign data_r_aux_i = '0;



// TGEN_CORE
// #(
//    .ID_WIDTH   ( ID_WIDTH    ), //= 8'h00,
//    .ADDR_WIDTH ( ADDR_WIDTH  ), //= 32,
//    .DATA_WIDTH ( DATA_WIDTH  ), //= 64,
//    .BE_WIDTH   ( BE_WIDTH    ) //= 8
// )
// i_TGEN
// (
//    .clk             ( push_clk     ),
//    .rst_n           ( push_rst_n   ),
   
//    .data_req_o      ( data_req_i   ),   // Data request
//    .data_add_o      ( data_add_i   ),   // Data request Address
//    .data_we_o       ( data_wen_i   ),    // Data request write enable : 1--> Store, 0 --> Load
//    .data_wdata_o    ( data_wdata_i ), // Data request Wrire data
//    .data_be_o       ( data_be_i    ),    // Data request Byte enable 
//    .data_id_o       ( data_ID_i    ),    // Data request ID
//    .data_gnt_i      ( data_gnt_o   ),   // Data request grant
   
//    .data_r_valid_i  ( data_r_valid_o ), // Data Response Valid (For LOAD commands)
//    .data_r_rdata_i  ( data_r_rdata_o ), // Data Response DATA (For LOAD commands)
//    .data_r_id_i     ( data_r_ID_o    ),    // Data reposnse ID

//    .fetch_enable_i  (  fetch_enable  )                     
// );

typedef struct { 
   logic [ADDR_WIDTH - 1:0]                          add;
   logic                                             wen;
   logic [DATA_WIDTH - 1:0]                          wdata;
   logic [BE_WIDTH - 1:0]                            be;
   logic [AUX_WIDTH - 1:0]                           aux;
   logic [ID_WIDTH - 1:0]                            ID;
} PACKET_REQ; 

typedef struct { 
   logic [DATA_WIDTH - 1:0]                          r_rdata;
   logic [ID_WIDTH - 1:0]                            r_ID;
} PACKET_RESP; 

PACKET_REQ  PACKET_IN_REQ, PACKET_OUT_REQ;
PACKET_RESP PACKET_IN_RESP;


PACKET_REQ FIFO_REQ[$];

always @( posedge push_clk)
begin
      if(data_req_i & data_gnt_o | ~data_req_i)
         -> granted_req;

      if(fetch_enable)
         -> fetch_enable_event;
end

always @( posedge push_clk, negedge push_rst_n)
begin
   if(push_rst_n == 1'b0)
   begin
      FIFO_REQ = {};
   end
   else
   begin 
      if(data_req_i & data_gnt_o)
      begin
         PACKET_IN_REQ.add   = data_add_i;
         PACKET_IN_REQ.wen   = data_wen_i;
         PACKET_IN_REQ.wdata = data_wdata_i;
         PACKET_IN_REQ.be    = data_be_i;
         PACKET_IN_REQ.ID    = data_ID_i;
         FIFO_REQ.push_front(PACKET_IN_REQ);
      end
   end
   
end

always @( posedge pop_clk )
begin

   if(data_req_o & data_gnt_i)
   begin
      PACKET_OUT_REQ = FIFO_REQ.pop_back();
      data_add_to_check   = PACKET_OUT_REQ.add;   
      data_wen_to_check   = PACKET_OUT_REQ.wen;   
      data_wdata_to_check = PACKET_OUT_REQ.wdata; 
      data_be_to_check    = PACKET_OUT_REQ.be;    
      data_aux_to_check   = PACKET_OUT_REQ.aux;   
      data_ID_to_check    = PACKET_OUT_REQ.ID;

      if( (data_add_to_check === data_add_o) && (data_wen_to_check === data_wen_o) && ( data_wdata_to_check === data_wdata_o ) && (data_be_to_check === data_be_o) && (data_ID_to_check === data_ID_o) )
          ;
      else
         $error("KOO: (data_add_to_check [%8h] === data_add_o  [%8h])", data_add_to_check ,data_add_o);
   end
end

   initial
   begin
      mask_gnt_i = 1'b1;
      pop_clk  = 1'b0;
      push_clk = 1'b0;
      fetch_enable = 1'b0;

      pop_rst_n = 1'b1;
      push_rst_n = 1'b1;

      #10.2;
      pop_rst_n = 1'b0;
      push_rst_n = 1'b0;

      #19;
      pop_rst_n = 1'b1;
      push_rst_n = 1'b1;
      #129;
      fetch_enable = 1'b1;


      #1000;
      mask_gnt_i = 1'b0;
   end


int unsigned counter;

   initial
   begin

            data_req_i     = '0;
            data_add_i     = '0;
            data_wen_i     = '0;
            data_wdata_i   = '0;
            data_be_i      = '0;
            data_ID_i      = '0;
            counter        = '0;

            @(fetch_enable_event)
            repeat(10_000_000)
            begin

               data_req_i     = 1'b1;
               data_add_i     = (data_req_i == 1'b0) ? 'x : counter;
               data_wen_i     = (data_req_i == 1'b0) ? 'x : $random()%2;
               data_wdata_i   = (data_req_i == 1'b0) ? 'x : $random();
               data_be_i      = (data_req_i == 1'b0) ? 'x : $random()%16;
               data_ID_i      = (data_req_i == 1'b0) ? 'x : $random();
               counter++;
               @(granted_req);
            end
   end



   always
   begin
      #(CLK_PERIOD_POP)
      pop_clk = ~pop_clk;
   end

   always
   begin
      #(CLK_PERIOD_PUSH)
      push_clk = ~push_clk;
   end   



   always_ff @(posedge pop_clk or negedge pop_rst_n)
   begin
      if(~pop_rst_n)
      begin
         data_gnt_i <= 1'b0;
      end
      else
      begin
            if(mask_gnt_i) 
               data_gnt_i = '0;
            else
               data_gnt_i <= $random()%100 > 90;
      end
   end


endmodule // tb
