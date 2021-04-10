// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module XBAR_L2
#(
   parameter N_CH0            = 5,
   parameter N_CH1            = 4,
   parameter ADDR_MEM_WIDTH   = 12,
   parameter N_SLAVE          = 4,
   parameter DATA_WIDTH       = 64,
   parameter BE_WIDTH         = DATA_WIDTH/8,

   parameter ID_WIDTH         = N_CH0+N_CH1,
   parameter N_MASTER         = N_CH0+N_CH1,
   parameter ADDR_IN_WIDTH    = ADDR_MEM_WIDTH+$clog2(N_SLAVE)
)
(
   // ---------------- MASTER CH0+CH1 SIDE  --------------------------
   // Req
   input  logic [N_MASTER-1:0]                             data_req_i,             // Data request
   input  logic [N_MASTER-1:0][ADDR_IN_WIDTH-1:0]          data_add_i,             // Data request Address {memory ROW , BANK}
   input  logic [N_MASTER-1:0]                             data_wen_i,             // Data request wen : 0--> Store, 1 --> Load
   input  logic [N_MASTER-1:0][DATA_WIDTH-1:0]             data_wdata_i,           // Data request Write data
   input  logic [N_MASTER-1:0][BE_WIDTH-1:0]               data_be_i,              // Data request Byte enable
   output logic [N_MASTER-1:0]                             data_gnt_o,             // Data request Grant
   // Resp
   output logic [N_MASTER-1:0]                             data_r_valid_o,         // Data Response Valid (For LOAD/STORE commands)
   output logic [N_MASTER-1:0][DATA_WIDTH-1:0]             data_r_rdata_o,         // Data Response DATA (For LOAD commands)


   // ---------------- MM_SIDE (Interleaved) --------------------------
   // Req --> to Mem
   output  logic [N_SLAVE-1:0]                             data_req_o,             // Data request
   output  logic [N_SLAVE-1:0][ADDR_MEM_WIDTH-1:0]         data_add_o,             // Data request Address
   output  logic [N_SLAVE-1:0]                             data_wen_o ,            // Data request wen : 0--> Store, 1 --> Load
   output  logic [N_SLAVE-1:0][DATA_WIDTH-1:0]             data_wdata_o,           // Data request Wrire data
   output  logic [N_SLAVE-1:0][BE_WIDTH-1:0]               data_be_o,              // Data request Byte enable
   output  logic [N_SLAVE-1:0][ID_WIDTH-1:0]               data_ID_o,
   // Resp --> From Mem
   input   logic [N_SLAVE-1:0][DATA_WIDTH-1:0]             data_r_rdata_i,         // Data Response DATA (For LOAD commands)
   input   logic [N_SLAVE-1:0]                             data_r_valid_i,         // Data Response: Command is Committed
   input   logic [N_SLAVE-1:0][ID_WIDTH-1:0]               data_r_ID_i,            // Data Response ID: To backroute Response

   input  logic                                            clk,                    // Clock
   input  logic                                            rst_n                   // Active Low Reset
);


   logic  [N_MASTER-1:0][ID_WIDTH-1:0]                       data_ID;
   logic  [N_MASTER-1:0][ADDR_MEM_WIDTH-1:0]                 data_add;



   logic [N_MASTER-1:0][$clog2(N_SLAVE)-1:0]                 data_routing;


   logic [N_MASTER-1:0]                                      data_r_valid_from_MEM[N_SLAVE-1:0];
   logic [N_SLAVE-1:0]                                       data_r_valid_to_MASTER[N_MASTER-1:0];

   logic [N_SLAVE-1:0]                                       data_req_from_MASTER[N_MASTER-1:0];
   logic [N_MASTER-1:0]                                      data_req_to_MEM[N_SLAVE-1:0];

   logic [N_SLAVE-1:0]                                       data_gnt_to_MASTER[N_MASTER-1:0];
   logic [N_MASTER-1:0]                                      data_gnt_from_MEM[N_SLAVE-1:0];


   genvar i,j,k;

   generate

        for (k=0; k<N_MASTER; k++)
        begin : wiring_req_rout

                if(N_SLAVE > 1)
                  assign data_add[k]     = {data_add_i[k][ADDR_MEM_WIDTH+$clog2(N_SLAVE)-1:$clog2(N_SLAVE)]};
                else
                  assign data_add[k]     = data_add_i[k];

                if(N_SLAVE > 1)
                  assign data_routing[k] =  data_add_i[k][$clog2(N_SLAVE)-1:0];
                else
                  assign data_routing[k] =  1'b0; // Only one memory --> no routing info are needed




                for (j=0; j<N_SLAVE; j++)
                  begin : Wiring_flow_ctrl
                    assign data_r_valid_to_MASTER[k][j] = data_r_valid_from_MEM[j][k];
                    assign data_req_to_MEM[j][k]        = data_req_from_MASTER[k][j];
                    assign data_gnt_to_MASTER[k][j]     = data_gnt_from_MEM[j][k];
                  end
        end




      for(j=0;j<N_SLAVE;j++)
      begin
              if(N_CH1 == 0)
              begin :  CH0_ONLY
                    RequestBlock_L2_1CH
                    #(
                      .ADDR_WIDTH ( ADDR_MEM_WIDTH  ),
                      .N_CH0      ( N_CH0           ),
                      .ID_WIDTH   ( ID_WIDTH        ),
                      .DATA_WIDTH ( DATA_WIDTH      ),
                      .BE_WIDTH   ( BE_WIDTH        )
                    )
                    REQ_BLOCK_CLUSTERS
                    (
                      // CHANNEL CH0
                      .data_req_i     ( data_req_to_MEM       [j] ),
                      .data_add_i     ( data_add                  ),
                      .data_wen_i     ( data_wen_i                ),
                      .data_wdata_i   ( data_wdata_i              ),
                      .data_be_i      ( data_be_i                 ),
                      .data_ID_i      ( data_ID                   ),
                      .data_gnt_o     ( data_gnt_from_MEM     [j] ),

                      // ----------------- MEMORY -------------------
                      // -------------( Connected to MEMORY) ----------------
                      .data_req_o     ( data_req_o            [j] ),
                      .data_add_o     ( data_add_o            [j] ),
                      .data_wen_o     ( data_wen_o            [j] ),
                      .data_wdata_o   ( data_wdata_o          [j] ),
                      .data_be_o      ( data_be_o             [j] ),
                      .data_ID_o      ( data_ID_o             [j] ),

                      .data_gnt_i     ( 1'b1                      ),
                      .data_r_valid_i ( data_r_valid_i        [j] ),
                      .data_r_ID_i    ( data_r_ID_i           [j] ),
                      // GEN VALID_SIGNALS in the response path
                      .data_r_valid_o ( data_r_valid_from_MEM [j] ), // N_CH0 Bit
                      .clk            ( clk),
                      .rst_n          ( rst_n)
                    );
              end
              else
              begin : CH0_CH1
                    RequestBlock_L2_2CH
                    #(
                      .ADDR_WIDTH ( ADDR_MEM_WIDTH ),
                      .N_CH0      ( N_CH0          ),
                      .N_CH1      ( N_CH1          ),
                      .ID_WIDTH   ( ID_WIDTH       ),
                      .DATA_WIDTH ( DATA_WIDTH     ),
                      .BE_WIDTH   ( BE_WIDTH       )
                    )
                    REQ_BLOCK_CLUSTERS_FC
                    (
                      // CHANNEL CH0 --> (example: Used for Clusters)
                      .data_req_CH0_i    ( data_req_to_MEM   [j] [N_CH0-1:0]           ),
                      .data_add_CH0_i    ( data_add              [N_CH0-1:0]           ),
                      .data_wen_CH0_i    ( data_wen_i            [N_CH0-1:0]           ),
                      .data_wdata_CH0_i  ( data_wdata_i          [N_CH0-1:0]           ),
                      .data_be_CH0_i     ( data_be_i             [N_CH0-1:0]           ),
                      .data_ID_CH0_i     ( data_ID               [N_CH0-1:0]           ),
                      .data_gnt_CH0_o    ( data_gnt_from_MEM [j] [N_CH0-1:0]           ),

                      // CHANNEL CH1 --> ( example: Used for FC/HOST)
                      .data_req_CH1_i    ( data_req_to_MEM   [j] [N_CH0+N_CH1-1:N_CH0] ),
                      .data_add_CH1_i    ( data_add              [N_CH0+N_CH1-1:N_CH0] ),
                      .data_wen_CH1_i    ( data_wen_i            [N_CH0+N_CH1-1:N_CH0] ),
                      .data_wdata_CH1_i  ( data_wdata_i          [N_CH0+N_CH1-1:N_CH0] ),
                      .data_be_CH1_i     ( data_be_i             [N_CH0+N_CH1-1:N_CH0] ),
                      .data_ID_CH1_i     ( data_ID               [N_CH0+N_CH1-1:N_CH0] ),
                      .data_gnt_CH1_o    ( data_gnt_from_MEM [j] [N_CH0+N_CH1-1:N_CH0] ),

                      // -----------------             MEMORY                    -------------------
                      // ---------------- RequestBlock OUTPUT (Connected to MEMORY) ----------------
                      .data_req_o        ( data_req_o        [j]                       ),
                      .data_add_o        ( data_add_o        [j]                       ),
                      .data_wen_o        ( data_wen_o        [j]                       ),
                      .data_wdata_o      ( data_wdata_o      [j]                       ),
                      .data_be_o         ( data_be_o         [j]                       ),
                      .data_ID_o         ( data_ID_o         [j]                       ),
                      .data_gnt_i        ( 1'b1                                        ),

                      .data_r_valid_i    ( data_r_valid_i    [j]                       ),
                      .data_r_ID_i       ( data_r_ID_i       [j]                       ),


                      // GEN VALID_SIGNALS in the response path
                      .data_r_valid_CH0_o( data_r_valid_from_MEM [j] [N_CH0-1:0]          ),
                      .data_r_valid_CH1_o( data_r_valid_from_MEM [j] [N_CH1+N_CH0-1:N_CH0]),

                      .clk               ( clk                                            ),
                      .rst_n             ( rst_n                                          )
                    );
              end

      end


              if(N_SLAVE == 1)
              begin
                      for (j=0;j<N_MASTER; j++)
                      begin : WIRING
                          assign data_r_rdata_o[j] = data_r_rdata_i;
                          assign data_r_valid_o[j] = data_r_valid_to_MASTER[j];

                          assign data_ID[j] = 2**j;
                          assign data_req_from_MASTER[j] = data_req_i[j];
                          assign data_gnt_o[j]           = data_gnt_to_MASTER[j];
                      end
              end
              else
              begin
                      for (j=0; j<  N_MASTER; j++)
                      begin : ResponseBlock
                        ResponseBlock_L2
                        #(
                           .ID         ( 2**j       ),
                           .ID_WIDTH   ( ID_WIDTH   ),
                           .N_SLAVE    ( N_SLAVE    ),
                           .DATA_WIDTH ( DATA_WIDTH )
                        )
                        RESP_BLOCK
                        (
                           // Signals from Memory cuts
                           .data_r_valid_i ( data_r_valid_to_MASTER [j] ),
                           .data_r_rdata_i ( data_r_rdata_i             ),
                           // Output of the ResponseTree Block
                           .data_r_valid_o ( data_r_valid_o         [j] ),
                           .data_r_rdata_o ( data_r_rdata_o         [j] ),
                           // Inputs form MAsters
                           .data_req_i     ( data_req_i             [j] ),
                           .routing_addr_i ( data_routing           [j] ),
                           .data_gnt_o     ( data_gnt_o             [j] ),
                           // Signal to/from Request Block
                           .data_req_o     ( data_req_from_MASTER   [j] ),
                           .data_gnt_i     ( data_gnt_to_MASTER     [j] ),
                           // Generated ID
                           .data_ID_o      ( data_ID                [j] )
                        );
                      end
              end







      endgenerate

endmodule
