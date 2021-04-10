// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module lint64_to_32
(
   input  logic                               clk,
   input  logic                               rst_n,

   // LINT Interface - WRITE Request
   input  logic                               data_req_i,
   output logic                               data_gnt_o,
   input  logic [63:0]                        data_wdata_i,
   input  logic [31:0]                        data_add_i,
   input  logic                               data_wen_i,
   input  logic [7:0]                         data_be_i,
   input  logic                               data_size_i,
   // LINT Interface - Response
   output  logic                              data_r_valid_o,
   output  logic [63:0]                       data_r_rdata_o,


   // LINT Interface - WRITE Request
   output logic [1:0]                         data_req_o,
   input  logic [1:0]                         data_gnt_i,
   output logic [1:0][31:0]                   data_wdata_o,
   output logic [1:0][31:0]                   data_add_o,
   output logic [1:0]                         data_wen_o,
   output logic [1:0][3:0]                    data_be_o,
   // LINT Interface - Response
   input  logic [1:0]                         data_r_valid_i,
   input  logic [1:0][31:0]                   data_r_rdata_i
);

   enum logic [2:0] {IDLE, WAIT_GNT_1, WAIT_GNT_0, DISPATCH, DISPATCH_0_SAMPL, DISPATCH_1_SAMPL } CS, NS;
   logic [1:0][31:0]                       data_r_rdata_q;
   logic [1:0]                             sample_rdata;
   logic [1:0]                             gnt_mask, rvalid_mask;
   logic [1:0]                             size_offset_info;
   logic                                   update_rvalid_mask;


   assign data_wdata_o =  data_wdata_i;
   assign data_be_o    =  data_be_i;



   always_ff @(posedge clk or negedge rst_n)
   begin
      if(~rst_n)
      begin
         CS <= IDLE;
         data_r_rdata_q <= '0;
         size_offset_info <= '0;

         rvalid_mask <= '0;
      end
      else
      begin
         CS <= NS;

         if(sample_rdata[0])
            data_r_rdata_q[0] <= data_r_rdata_i[0];
         if(sample_rdata[1])
            data_r_rdata_q[1] <= data_r_rdata_i[1];

         if(data_req_i & data_gnt_o)
            size_offset_info <= {data_size_i,data_add_i[2]};

         if(update_rvalid_mask)
            rvalid_mask <= gnt_mask;
      end
   end







   assign sample_rdata = data_r_valid_i;


   always_comb
   begin

      // default values
      data_req_o     = '0;
      data_add_o     = (data_size_i) ? { {data_add_i[31:3],3'b000}+4,  {data_add_i[31:3],3'b000} }   :    { data_add_i,  data_add_i };;
      data_wen_o     = { data_wen_i,    data_wen_i };
      data_r_valid_o = '0;

      // Just pick this conf, then in DIPATCH mode, the rigth data is used
      data_r_rdata_o = data_r_rdata_i;

      data_gnt_o     = '0;

      gnt_mask       = 2'b00;

      update_rvalid_mask = '0;



      NS = CS;

      case (CS)

      IDLE:
      begin

         if(data_size_i)
         begin
            data_req_o          = { data_req_i , data_req_i  };
            gnt_mask            = 2'b00;
         end
         else
         begin
            case(data_add_i[2])
               1'b0:
               begin
                     data_req_o  =  { 1'b0 ,        data_req_i } ;
                     gnt_mask    = 2'b10;
               end
               1'b1:
               begin
                  data_req_o =  {  data_req_i,  1'b0       } ;
                  gnt_mask = 2'b01;
               end
            endcase
         end

         if(data_req_i)
         begin
                     case(data_gnt_i | gnt_mask)
                     2'b00: begin
                        NS = IDLE;
                     end

                     2'b01: begin
                        NS = WAIT_GNT_1;
                        update_rvalid_mask = 1'b1;
                     end

                     2'b10: begin
                        NS = WAIT_GNT_0;
                        update_rvalid_mask = 1'b1;
                     end

                     2'b11: begin
                        NS = DISPATCH;
                        data_gnt_o = 1'b1;
                        update_rvalid_mask = 1'b1;
                     end

                     endcase // data_gnt_i
         end
         else
         begin
                     NS = IDLE;
         end
      end

      WAIT_GNT_1:
      begin
         data_req_o     = 2'b10;

         if(data_gnt_i[1])
         begin
            NS = DISPATCH_0_SAMPL;
            data_gnt_o = 1'b1;
         end
         else
         begin
            NS = WAIT_GNT_1;
         end
      end



      WAIT_GNT_0:
      begin

         data_req_o     = 2'b01;

         if(data_gnt_i[0])
         begin
            NS = DISPATCH_1_SAMPL;
            data_gnt_o = 1'b1;
         end
         else
         begin
            NS = WAIT_GNT_0;
         end
      end




      DISPATCH:
      begin
         data_r_valid_o = &(data_r_valid_i | rvalid_mask);
         if(size_offset_info[1]) //64 bit
            data_r_rdata_o = data_r_rdata_i;
         else //32 bit axi trans
            data_r_rdata_o = (size_offset_info[0]) ? {data_r_rdata_i[1],32'h0000_0000} : {32'h0000_0000, data_r_rdata_i[0]};



         if(&(data_r_valid_i | rvalid_mask) )
         begin
                     if(data_size_i)
                     begin
                        data_req_o          = { data_req_i , data_req_i  };
                        gnt_mask            = 2'b00;
                     end
                     else
                     begin
                        case(data_add_i[2])
                           1'b0:
                           begin
                                 data_req_o  =  { 1'b0 ,        data_req_i } ;
                                 gnt_mask    = 2'b10;
                           end
                           1'b1:
                           begin
                              data_req_o =  {  data_req_i,  1'b0   } ;
                              gnt_mask = 2'b01;
                           end
                        endcase
                     end




                     if(data_req_i)
                     begin
                           case(data_gnt_i | gnt_mask)
                           2'b00: begin
                              NS = IDLE;
                           end

                           2'b01: begin
                              NS = WAIT_GNT_1;
                              update_rvalid_mask = 1'b1;
                           end

                           2'b10: begin
                              NS = WAIT_GNT_0;
                              update_rvalid_mask = 1'b1;
                           end

                           2'b11: begin
                              NS = DISPATCH;
                              data_gnt_o = 1'b1;
                              update_rvalid_mask = 1'b1;
                           end

                           endcase // data_gnt_i
                     end
                     else
                     begin
                        NS = IDLE;
                     end
         end
         else
         begin
            case (data_r_valid_i | rvalid_mask)
               2'b00: NS = DISPATCH;
               2'b10: NS = DISPATCH_1_SAMPL;
               2'b01: NS = DISPATCH_0_SAMPL;
               default : NS = DISPATCH;
            endcase
         end



      end



      DISPATCH_0_SAMPL:
      begin
         data_r_valid_o = data_r_valid_i[1];
         data_r_rdata_o = {data_r_rdata_i[1],data_r_rdata_q[0]};

         if(data_r_valid_i[1])
         begin

               if(data_size_i)
               begin
                  data_req_o          = { data_req_i , data_req_i  };
                  gnt_mask            = 2'b00;
               end
               else
               begin
                  case(data_add_i[2])
                     1'b0:
                     begin
                           data_req_o  =  { 1'b0 ,        data_req_i } ;
                           gnt_mask    = 2'b10;
                     end
                     1'b1:
                     begin
                        data_req_o =  {  data_req_i,  1'b0       } ;
                        gnt_mask = 2'b01;
                     end
                  endcase
               end


               if(data_req_i)
               begin
                     case(data_gnt_i)
                     2'b00: begin
                        NS = IDLE;
                     end

                     2'b01: begin
                        NS = WAIT_GNT_1;
                        update_rvalid_mask = 1'b1;
                     end

                     2'b10: begin
                        NS = WAIT_GNT_0;
                        update_rvalid_mask = 1'b1;
                     end

                     2'b11: begin
                        NS = DISPATCH;
                        data_gnt_o = 1'b1;
                        update_rvalid_mask = 1'b1;
                     end

                     endcase // data_gnt_i
               end
               else
               begin
                  NS = IDLE;
               end
         end
         else
         begin
            NS = DISPATCH_0_SAMPL;
         end
      end



      DISPATCH_1_SAMPL:
      begin
         data_r_valid_o = data_r_valid_i[0];
         data_r_rdata_o = {data_r_rdata_q[1],data_r_rdata_i[0]};

         if(data_r_valid_i[0])
         begin
               if(data_size_i)
               begin
                  data_req_o          = { data_req_i , data_req_i  };
                  gnt_mask            = 2'b00;
               end
               else
               begin
                  case(data_add_i[2])
                     1'b0:
                     begin
                           data_req_o  =  { 1'b0 ,        data_req_i } ;
                           gnt_mask    = 2'b10;
                     end
                     1'b1:
                     begin
                        data_req_o =  {  data_req_i,  1'b0       } ;
                        gnt_mask = 2'b01;
                     end
                  endcase
               end



               if(data_req_i)
               begin
                     case(data_gnt_i)
                     2'b00: begin
                        NS = IDLE;
                     end

                     2'b01: begin
                        NS = WAIT_GNT_1;
                        update_rvalid_mask = 1'b1;
                     end

                     2'b10: begin
                        NS = WAIT_GNT_0;
                        update_rvalid_mask = 1'b1;
                     end

                     2'b11: begin
                        NS = DISPATCH;
                        data_gnt_o = 1'b1;
                        update_rvalid_mask = 1'b1;
                     end

                     endcase // data_gnt_i
               end
               else
               begin
                  NS = IDLE;
               end
         end
         else // WAIT for RVALID
         begin
            NS = DISPATCH_1_SAMPL;
         end




      end


      endcase
   end



endmodule
