// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`timescale  1ns/1ps


module TB_XBAR_L2;

   parameter N_CH0           = 5;  //--> Debug, UdmaTX, UdmaRX, IcacheR5, DataR5
   parameter N_CH1           = 4;  //--> 2xAXI_W, 2X_AXI_R
   parameter N_SLAVE         = 4;
   parameter N_BRIDGES       = 2;
   parameter ID_WIDTH        = N_CH0+N_CH1;
   parameter AUX_WIDTH       = 5;
   parameter ADDR_WIDTH      = 32;
   parameter DATA_WIDTH      = 32;
   parameter BE_WIDTH        = DATA_WIDTH/8;
   parameter ADDR_MEM_WIDTH  = 12;

   logic                     clk, rst_n;
   logic [N_CH0+N_CH1-1:0]   fetch_enable;

   // ---------------- Master SIDE (Interleaved) --------------------------
   logic [N_CH0+N_CH1-1:0]                        data_req_TGEN;
   logic [N_CH0+N_CH1-1:0][ADDR_WIDTH-1:0]        data_add_TGEN;
   logic [N_CH0+N_CH1-1:0]                        data_wen_TGEN;
   logic [N_CH0+N_CH1-1:0][DATA_WIDTH-1:0]        data_wdata_TGEN;
   logic [N_CH0+N_CH1-1:0][BE_WIDTH-1:0]          data_be_TGEN;
   logic [N_CH0+N_CH1-1:0][AUX_WIDTH-1:0]         data_aux_TGEN;
   logic [N_CH0+N_CH1-1:0]                        data_gnt_TGEN;
   logic [N_CH0+N_CH1-1:0]                        data_err_TGEN;
   logic [N_CH0+N_CH1-1:0]                        data_r_valid_TGEN;
   logic [N_CH0+N_CH1-1:0][DATA_WIDTH-1:0]        data_r_rdata_TGEN;
   logic [N_CH0+N_CH1-1:0][AUX_WIDTH-1:0]         data_r_aux_TGEN;


   // ---------------- Meemeory SIDE (Interleaved) --------------------------
   logic [N_SLAVE-1:0]                            data_req_MEM;            // Data request
   logic [N_SLAVE-1:0][ADDR_MEM_WIDTH-1:0]        data_add_MEM;            // Data request Address
   logic [N_SLAVE-1:0]                            data_wen_MEM;            // Data request type : 0--> Store; 1 --> Load
   logic [N_SLAVE-1:0][DATA_WIDTH-1:0]            data_wdata_MEM;          // Data request Wrire data
   logic [N_SLAVE-1:0][BE_WIDTH-1:0]              data_be_MEM;             // Data request Byte enable
   logic [N_SLAVE-1:0][AUX_WIDTH-1:0]             data_aux_MEM;
   logic [N_SLAVE-1:0][ID_WIDTH-1:0]              data_ID_MEM;
   logic [N_SLAVE-1:0]                            data_gnt_MEM;

   logic [N_SLAVE-1:0]                            data_r_valid_MEM;
   logic [N_SLAVE-1:0]                            data_r_gnt_MEM;
   logic [N_SLAVE-1:0][DATA_WIDTH-1:0]            data_r_rdata_MEM;        // Data Response DATA (For LOAD commands)
   logic [N_SLAVE-1:0][AUX_WIDTH-1:0]             data_r_aux_MEM;
   logic [N_SLAVE-1:0][ID_WIDTH-1:0]              data_r_ID_MEM;


   // ---------------- Bridge SIDE (Interleaved) --------------------------
   logic [N_BRIDGES-1:0]                          data_req_BRIDGE;            // Data request
   logic [N_BRIDGES-1:0][ADDR_WIDTH-1:0]          data_add_BRIDGE;            // Data request Address
   logic [N_BRIDGES-1:0]                          data_wen_BRIDGE;            // Data request type : 0--> StorBRIDGE; 1 --> Load
   logic [N_BRIDGES-1:0][DATA_WIDTH-1:0]          data_wdata_BRIDGE;          // Data request Wrire data
   logic [N_BRIDGES-1:0][BE_WIDTH-1:0]            data_be_BRIDGE;             // Data request Byte enable
   logic [N_BRIDGES-1:0][AUX_WIDTH-1:0]           data_aux_BRIDGE;
   logic [N_BRIDGES-1:0][ID_WIDTH-1:0]            data_ID_BRIDGE;
   logic [N_BRIDGES-1:0]                          data_gnt_BRIDGE;            // Data Response DATA (For LOAD commands)

   logic [N_BRIDGES-1:0]                          data_r_valid_BRIDGE;
   logic [N_BRIDGES-1:0]                          data_r_gnt_BRIDGE;
   logic [N_BRIDGES-1:0][DATA_WIDTH-1:0]          data_r_rdata_BRIDGE;        // Data Response DATA (For LOAD commands)
   logic [N_BRIDGES-1:0][AUX_WIDTH-1:0]           data_r_aux_BRIDGE;
   logic [N_BRIDGES-1:0][ID_WIDTH-1:0]            data_r_ID_BRIDGE;


   XBAR_L2
   #(
      .N_CH0          ( N_CH0           ), // = 5,  //--> Debug, UdmaTX, UdmaRX, IcacheR5, DataR5
      .N_CH1          ( N_CH1           ), // = 4,  //--> 2xAXI_W, 2X_AXI_R
      .N_SLAVE        ( N_SLAVE         ), // = 4,
      .N_BRIDGES      ( N_BRIDGES       ), // = 2,
      .ID_WIDTH       ( ID_WIDTH        ), // = N_CH0+N_CH1,
      .AUX_WIDTH      ( AUX_WIDTH       ), // = 6,
      .ADDR_WIDTH     ( ADDR_WIDTH      ), // = 32,
      .DATA_WIDTH     ( DATA_WIDTH      ), // = 32,
      .BE_WIDTH       ( BE_WIDTH        ), // = DATA_WIDTH/8,
      .ADDR_MEM_WIDTH ( ADDR_MEM_WIDTH  )
   )
   DUT_i
   (
      // ---------------- MASTER CH0+CH1 SIDE  --------------------------
      .data_req_i             ( data_req_TGEN     ), // Data request
      .data_add_i             ( data_add_TGEN     ), // Data request Address
      .data_wen_i             ( data_wen_TGEN     ), // Data request type : 0--> Store 1 --> Load
      .data_wdata_i           ( data_wdata_TGEN   ), // Data request Write data
      .data_be_i              ( data_be_TGEN      ), // Data request Byte enable
      .data_aux_i             ( data_aux_TGEN     ), // Data request Byte enable
      .data_gnt_o             ( data_gnt_TGEN     ), // Grant Incoming Request
      .data_err_o             ( data_err_TGEN     ), // Decoding Error
      .data_r_valid_o         ( data_r_valid_TGEN ), // Data Response Valid (For LOAD/STORE commands)
      .data_r_rdata_o         ( data_r_rdata_TGEN ), // Data Response DATA (For LOAD commands)
      .data_r_aux_o           ( data_r_aux_TGEN   ), // Data request Byte enable

      // ---------------- MM_SIDE (Interleaved) --------------------------
      .data_req_o             ( data_req_MEM        ), // Data request
      .data_add_o             ( data_add_MEM        ), // Data request Address
      .data_wen_o             ( data_wen_MEM        ), // Data request type : 0--> Store 1 --> Load
      .data_wdata_o           ( data_wdata_MEM      ), // Data request Wrire data
      .data_be_o              ( data_be_MEM         ), // Data request Byte enable
      .data_aux_o             ( data_aux_MEM        ),
      .data_ID_o              ( data_ID_MEM         ),
      .data_gnt_i             ( '1                  ), // Always Granted

      .data_r_valid_i         ( data_r_valid_MEM    ),
      .data_r_gnt_o           ( data_r_gnt_MEM      ),
      .data_r_rdata_i         ( data_r_rdata_MEM    ), // Data Response DATA (For LOAD commands)
      .data_r_aux_i           ( data_r_aux_MEM      ),
      .data_r_ID_i            ( data_r_ID_MEM       ),


      // ---------------- BRIDGES  (REGION) --------------------------
      .data_bridge_req_o      ( data_req_BRIDGE     ),            // Data request
      .data_bridge_add_o      ( data_add_BRIDGE     ),            // Data request Address
      .data_bridge_wen_o      ( data_wen_BRIDGE     ),            // Data request type : 0--> Store 1 --> Load
      .data_bridge_wdata_o    ( data_wdata_BRIDGE   ),          // Data request Wrire data
      .data_bridge_be_o       ( data_be_BRIDGE      ),             // Data request Byte enable
      .data_bridge_aux_o      ( data_aux_BRIDGE     ),
      .data_bridge_ID_o       ( data_ID_BRIDGE      ),
      .data_bridge_gnt_i      ( data_gnt_BRIDGE     ),            // Data Response DATA (For LOAD commands)

      .data_bridge_r_valid_i  ( data_r_valid_BRIDGE ),
      .data_bridge_r_gnt_o    ( data_r_gnt_BRIDGE   ),
      .data_bridge_r_rdata_i  ( data_r_rdata_BRIDGE ),        // Data Response DATA (For LOAD commands)
      .data_bridge_r_aux_i    ( data_r_aux_BRIDGE   ),
      .data_bridge_r_ID_i     ( data_r_ID_BRIDGE    ),

      .clk                    ( clk                 ),
      .rst_n                  ( rst_n               )
   );

   always
   begin
      #(1.0) clk = ~clk;
   end


   initial
   begin
      rst_n = 1'b1;
      clk   = 1'b0;
      fetch_enable = '0;

      @(negedge clk);
      @(negedge clk);
      @(negedge clk);

      rst_n  = 1'b0;

      @(negedge clk);
      @(negedge clk);
      @(negedge clk);

      rst_n = 1'b1;

      @(negedge clk);
      @(negedge clk);
      @(negedge clk);
      @(negedge clk);

      fetch_enable[0] = 1'b1;

   end


   genvar i,j;
   generate

      for(i=0; i<N_SLAVE; i++)
      begin : MEM_CUTS
         L2_SP_RAM
         #(
            .DATA_WIDTH ( DATA_WIDTH      ), //= 32,
            .ADDR_WIDTH ( ADDR_MEM_WIDTH  ), //= 20,
            .BE_WIDTH   ( BE_WIDTH        ), //= DATA_WIDTH/8,
            .AUX_WIDTH  ( AUX_WIDTH       ), //= 4,
            .ID_WIDTH   ( ID_WIDTH        )  //= 3
         )
         MEM_CUTS
         (
            .CLK       ( clk                 ),
            .RSTN      ( rst_n               ),
            .CEN       ( ~data_req_MEM[i]    ),
            .WEN       ( data_wen_MEM[i]     ),
            .A         ( data_add_MEM[i]     ),
            .D         ( data_wdata_MEM[i]   ),
            .BE        ( data_be_MEM[i]      ),
            .Q         ( data_r_rdata_MEM[i] ),
            .id_i      ( data_ID_MEM[i]      ),
            .r_id_o    ( data_r_ID_MEM[i]    ),
            .aux_i     ( data_aux_MEM[i]     ),
            .r_aux_o   ( data_r_aux_MEM[i]   ),
            .r_valid_o ( data_r_valid_MEM[i] )
         );
      end

      for(i=0; i<N_BRIDGES; i++)
      begin : BRIDGES
         L2_SP_RAM_STALL
         #(
            .DATA_WIDTH ( DATA_WIDTH      ), //= 32,
            .ADDR_WIDTH ( ADDR_WIDTH      ), //= 20,
            .BE_WIDTH   ( BE_WIDTH        ), //= DATA_WIDTH/8,
            .AUX_WIDTH  ( AUX_WIDTH       ), //= 4,
            .ID_WIDTH   ( ID_WIDTH        )  //= 3
         )
         BRIDGES
         (
            .CLK       ( clk              ),
            .RSTN      ( rst_n            ),

            .CEN       ( ~data_req_BRIDGE[i]    ),
            .WEN       ( data_wen_BRIDGE[i]     ),
            .A         ( data_add_BRIDGE[i]     ),
            .D         ( data_wdata_BRIDGE[i]   ),
            .BE        ( data_be_BRIDGE[i]      ),
            .Q         ( data_r_rdata_BRIDGE[i] ),

            .gnt_o     ( data_gnt_BRIDGE[i]     ),
            .r_gnt_i   ( data_r_gnt_BRIDGE[i]   ),

            .id_i      ( data_ID_BRIDGE[i]      ),
            .r_id_o    ( data_r_ID_BRIDGE[i]    ),
            .aux_i     ( data_aux_BRIDGE[i]     ),
            .r_aux_o   ( data_r_aux_BRIDGE[i]   ),
            .r_valid_o ( data_r_valid_BRIDGE[i] )
         );
      end


      for(i=0; i<N_CH0; i++)
      begin : FC_MASTER
         TGEN_32
         #(
            .ID_WIDTH       ( ID_WIDTH    ), //10,
            .AUX_WIDTH      ( AUX_WIDTH   ), //5,
            .ADDR_WIDTH     ( ADDR_WIDTH  ), //32,
            .DATA_WIDTH     ( DATA_WIDTH  ), //32,
            .BE_WIDTH       ( BE_WIDTH    ) //DATA_WIDTH/8
         )
         FC_MASTER_i
         (
            .data_req_o      ( data_req_TGEN   [i] ),
            .data_gnt_i      ( data_gnt_TGEN   [i]   ),
            .data_add_o      ( data_add_TGEN   [i]   ),
            .data_wen_o      ( data_wen_TGEN   [i]   ),
            .data_wdata_o    ( data_wdata_TGEN [i]   ),
            .data_be_o       ( data_be_TGEN    [i]   ),
            .data_aux_o      ( data_aux_TGEN   [i]   ),
            .data_err_i      ( data_err_TGEN   [i]   ),
            .data_r_valid_i  ( data_r_valid_TGEN [i] ),
            .data_r_rdata_i  ( data_r_rdata_TGEN [i] ),
            .data_r_aux_i    ( data_r_aux_TGEN   [i] ),

            .clk             ( clk                   ),
            .rst_n           ( rst_n                 ),

            .fetch_enable_i  ( fetch_enable[i]       )
         );
      end


      for(i=N_CH0; i<N_CH1+N_CH0; i++)
      begin : AXI_MASTER
         TGEN_32
         #(
            .ID_WIDTH        ( ID_WIDTH    ), //10,
            .AUX_WIDTH       ( AUX_WIDTH   ), //5,
            .ADDR_WIDTH      ( ADDR_WIDTH  ), //32,
            .DATA_WIDTH      ( DATA_WIDTH  ), //32,
            .BE_WIDTH        ( BE_WIDTH    ) //DATA_WIDTH/8
         )
         AXI_MASTER_i
         (
            .data_req_o      ( data_req_TGEN   [i] ),
            .data_gnt_i      ( data_gnt_TGEN   [i]   ),
            .data_add_o      ( data_add_TGEN   [i]   ),
            .data_wen_o      ( data_wen_TGEN   [i]   ),
            .data_wdata_o    ( data_wdata_TGEN [i]   ),
            .data_be_o       ( data_be_TGEN    [i]   ),
            .data_aux_o      ( data_aux_TGEN   [i]   ),
            .data_err_i      ( data_err_TGEN   [i]   ),
            .data_r_valid_i  ( data_r_valid_TGEN [i] ),
            .data_r_rdata_i  ( data_r_rdata_TGEN [i] ),
            .data_r_aux_i    ( data_r_aux_TGEN   [i] ),

            .clk             ( clk                   ),
            .rst_n           ( rst_n                 ),

            .fetch_enable_i  ( fetch_enable[i]       )
         );
      end

   endgenerate

endmodule // TB_XBAR_L2










