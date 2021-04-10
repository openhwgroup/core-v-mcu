module TGEN_CORE
#(
   parameter ID_WIDTH   = 8'h00,
   parameter ADDR_WIDTH = 32,
   parameter DATA_WIDTH = 64,
   parameter BE_WIDTH   = 8
) 
(
   input  logic                            clk,
   input  logic                            rst_n,
   
   // Request Channel
   output logic                            data_req_o,   // Data request
   output logic [ADDR_WIDTH-1:0]           data_add_o,   // Data request Address
   output logic                            data_we_o,    // Data request write enable : 1--> Store, 0 --> Load
   output logic [DATA_WIDTH-1:0]           data_wdata_o, // Data request Wrire data
   output logic [BE_WIDTH-1:0]             data_be_o,    // Data request Byte enable 
   output logic [ID_WIDTH-1:0]             data_id_o,    // Data request ID

   input  logic                            data_gnt_i,   // Data request grant
   
   // Response Channel
   input  logic                            data_r_valid_i, // Data Response Valid (For LOAD commands)
   input  logic [DATA_WIDTH-1:0]           data_r_rdata_i, // Data Response DATA (For LOAD commands)
   input  logic [ID_WIDTH-1:0]             data_r_id_i,    // Data reposnse ID

   input  logic                            fetch_enable_i                     
);


   logic                            data_req_int;
   logic [ADDR_WIDTH-1:0]           data_add_int;
   logic                            data_we_int;
   logic [DATA_WIDTH-1:0]           data_wdata_int;
   logic [BE_WIDTH-1:0]             data_be_int;
   logic [ID_WIDTH-1:0]             data_id_int;


   enum logic [1:0] {IDLE, WAIT_RVALID, WAIT_GRANT, SLEEP} CS, NS;
   logic save_data;

   always @(posedge clk or negedge rst_n)
   begin
      if(~rst_n)
      begin
         CS             <= SLEEP;
         data_add_int   <= '0;
         data_we_int    <= '0;
         data_wdata_int <= '0;
         data_be_int    <= '0;
         data_id_int    <= '0;
      end
      else
      begin
         CS <= NS;
         if(save_data)
         begin
            data_add_int   <= data_add_o;
            data_we_int    <= data_we_o;
            data_wdata_int <= data_wdata_o;
            data_be_int    <= data_be_o;
            data_id_int    <= data_id_o;
         end
      end
   end





   always_comb
   begin
      data_req_o   = '0;
      data_add_o   = '0;
      data_we_o    = '0;  
      data_wdata_o = '0;
      data_be_o    = '0;  
      data_id_o    = '0; 
      save_data    = '0;

      case(CS)
         SLEEP: 
         begin
            data_req_o = '0;

            if(fetch_enable_i)
               NS = IDLE;
            else
               NS = SLEEP;
         end


         IDLE: 
         begin
                  if(fetch_enable_i == 1'b0)
                  begin
                        NS = SLEEP;
                  end
                  else
                  begin
                        data_req_o = 1'b1;
                        data_we_o  = $random()%2;

                        data_wdata_o = {$random(),$random()};
                        data_be_o    = $random();
                        data_add_o   = {$random(),$random()} & 64'h0000_0000_00000_FFF8;
                        data_id_o    = $random();


                        save_data = 1'b1;

                        if(data_gnt_i)
                           NS = WAIT_RVALID;
                        else
                           NS = WAIT_GRANT;
                  end
         end


         WAIT_GRANT:
         begin
            data_req_o   = 1'b1;
            data_add_o   = data_add_int;
            data_we_o    = data_we_int;
            data_wdata_o = data_wdata_int;
            data_be_o    = data_be_int;
            data_id_o    = data_id_int;

            if(data_gnt_i)
               NS = WAIT_RVALID;
            else
               NS = WAIT_GRANT; 

         end


         WAIT_RVALID:
         begin
            if(data_r_valid_i)
            begin
                  if(fetch_enable_i == 1'b0)
                  begin
                        NS = SLEEP;
                  end
                  else
                  begin
                        data_req_o = 1'b1;
                        data_we_o  = $random()%2;

                        data_wdata_o = {$random(),$random()};
                        data_be_o    = $random();
                        data_add_o   = {$random(),$random()} & 64'h0000_0000_00000_FFF8;
                        data_id_o    = $random();


                        save_data = 1'b1;

                        if(data_gnt_i)
                           NS = WAIT_RVALID;
                        else
                           NS = WAIT_GRANT;
                  end
            end
            else
            begin
               NS = WAIT_RVALID; 
            end
         end

      endcase // CS
   end


endmodule