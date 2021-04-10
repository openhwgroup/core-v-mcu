// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module XBAR_BRIDGE
#(
    parameter N_CH0          = 5, //--> CH0
    parameter N_CH1          = 4,  //--> CH1
    parameter N_SLAVE        = 3,
    parameter ID_WIDTH       = N_CH0+N_CH1,
    parameter AUX_WIDTH      = 8,

    parameter ADDR_WIDTH     = 32,
    parameter DATA_WIDTH     = 32,
    parameter BE_WIDTH       = DATA_WIDTH/8
)
(
    // ---------------- MASTER CH0+CH1 SIDE  --------------------------
    // Req
    input  logic [N_CH0+N_CH1-1:0]                         data_req_i,                // Data request
    input  logic [N_CH0+N_CH1-1:0][ADDR_WIDTH-1:0]         data_add_i,                // Data request Address
    input  logic [N_CH0+N_CH1-1:0]                         data_wen_i,                // Data request type : 0--> Store, 1 --> Load
    input  logic [N_CH0+N_CH1-1:0][DATA_WIDTH-1:0]         data_wdata_i,              // Data request Write data
    input  logic [N_CH0+N_CH1-1:0][BE_WIDTH-1:0]           data_be_i,                 // Data request Byte enable
    input  logic [N_CH0+N_CH1-1:0][AUX_WIDTH-1:0]          data_aux_i,                // Data request AUX
    output logic [N_CH0+N_CH1-1:0]                         data_gnt_o,                // Data request Grant

    // Resp
    output logic [N_CH0+N_CH1-1:0]                         data_r_valid_o,            // Data Response Valid (For LOAD/STORE commands)
    output logic [N_CH0+N_CH1-1:0][DATA_WIDTH-1:0]         data_r_rdata_o,            // Data Response DATA (For LOAD commands)
    output logic [N_CH0+N_CH1-1:0]                         data_r_opc_o,              // Response Error
    output logic [N_CH0+N_CH1-1:0][AUX_WIDTH-1:0]          data_r_aux_o,              // Response AUX


    // ---------------- MM_SIDE (Interleaved) --------------------------
    // Req --> to Mem
    output  logic [N_SLAVE-1:0]                            data_req_o,                // Data request
    output  logic [N_SLAVE-1:0][ADDR_WIDTH-1:0]            data_add_o,                // Data request Address
    output  logic [N_SLAVE-1:0]                            data_wen_o,                // Data request type : 0--> Store, 1 --> Load
    output  logic [N_SLAVE-1:0][DATA_WIDTH-1:0]            data_wdata_o,              // Data request Wrire data
    output  logic [N_SLAVE-1:0][BE_WIDTH-1:0]              data_be_o,                 // Data request Byte enable
    output  logic [N_SLAVE-1:0][ID_WIDTH-1:0]              data_ID_o,
    output  logic [N_SLAVE-1:0][AUX_WIDTH-1:0]             data_aux_o,                // Data request AUX
    input   logic [N_SLAVE-1:0]                            data_gnt_i,                // Data request : input on slave side

    // Resp        --> From Mem
    input  logic [N_SLAVE-1:0][DATA_WIDTH-1:0]             data_r_rdata_i,            // Data Response DATA (For LOAD commands)
    input  logic [N_SLAVE-1:0]                             data_r_valid_i,            // Data Response: Command is Committed
    input  logic [N_SLAVE-1:0][ID_WIDTH-1:0]               data_r_ID_i,               // Data Response ID: To backroute Response
    input  logic [N_SLAVE-1:0]                             data_r_opc_i,              // Data Response: Error
    input  logic [N_SLAVE-1:0][AUX_WIDTH-1:0]              data_r_aux_i,              // Response AUX

    input  logic                                           clk,                       // Clock
    input  logic                                           rst_n,                      // Active Low Reset

    input  logic [N_SLAVE-1:0][ADDR_WIDTH-1:0]             START_ADDR,
    input  logic [N_SLAVE-1:0][ADDR_WIDTH-1:0]             END_ADDR
);

    // localparam logic [ADDR_WIDTH-1:0] START_ADDR[N_SLAVE-1:0] = {32'h0000_0000, 32'h0010_0000, 32'h1000_0000};
    // localparam logic [ADDR_WIDTH-1:0] END_ADDR[N_SLAVE-1:0]   = {32'h0008_0000, 32'h0020_0000, 32'h2000_0000};



    // DATA ID array FORM address decoders to Request tree.
    logic  [N_CH0+N_CH1-1:0][ID_WIDTH-1:0]           data_ID;

    logic   [N_CH0+N_CH1-1:0]                        data_gnt_from_MEM[N_SLAVE-1:0];

    logic   [N_SLAVE-1:0]                            data_req_from_MASTER[N_CH0+N_CH1-1:0];
    logic   [N_CH0+N_CH1-1:0]                        data_r_valid_from_MEM[N_SLAVE-1:0];

    logic [N_SLAVE-1:0]                              data_r_valid_to_MASTER[N_CH0+N_CH1-1:0];
    logic [N_CH0+N_CH1-1:0]                          data_req_to_MEM[N_SLAVE-1:0];
    logic [N_SLAVE-1:0]                              data_gnt_to_MASTER[N_CH0+N_CH1-1:0];

    logic [N_CH0+N_CH1-1:0][N_SLAVE-1:0]             destination_OH;

    //synopsys translate_off
    initial
    begin
         $display("START_ADDR[0] = 0x%8h; END_ADDR[0] = 0X%8h", START_ADDR[0], END_ADDR[0] );
         $display("START_ADDR[1] = 0x%8h; END_ADDR[1] = 0X%8h", START_ADDR[1], END_ADDR[1] );
    end
    //synopsys translate_on


    genvar j,k;

    generate

        for (k=0; k<N_CH0+N_CH1; k++)
        begin

            always @(*)
            begin
                  destination_OH[k] = '0;

                  for (int unsigned x=0; x<N_SLAVE; x++)
                  begin
                     if( (data_add_i[k] >= START_ADDR[x]) && (data_add_i[k] < END_ADDR[x]) )
                     begin
                        //$display("RULE MATCH in %m: addr=%x, START_ADDR = %x and END_ADDR = %x: --> OH_DEST=%b", data_add_i[k], START_ADDR[x], END_ADDR[x], destination_OH[k]);
                        destination_OH[k][x] = 1'b1;
                     end
                  end
            end


          for (j=0; j<N_SLAVE; j++)
            begin
              assign data_r_valid_to_MASTER[k][j] = data_r_valid_from_MEM[j][k];
              assign data_req_to_MEM[j][k]        = data_req_from_MASTER[k][j];
              assign data_gnt_to_MASTER[k][j]     = data_gnt_from_MEM[j][k];
            end
        end


        for (j=0; j<  N_SLAVE; j++)
        begin : RequestBlock
           if(N_CH1 != 0)
           begin : CH0_CH1
              RequestBlock2CH_BRIDGE
              #(
                  .ADDR_WIDTH         ( ADDR_WIDTH     ),
                  .N_CH0              ( N_CH0          ),
                  .N_CH1              ( N_CH1          ),
                  .ID_WIDTH           ( ID_WIDTH       ),
                  .DATA_WIDTH         ( DATA_WIDTH     ),
                  .AUX_WIDTH          ( AUX_WIDTH      ),
                  .BE_WIDTH           ( BE_WIDTH       )
              )
              i_RequestBlock2CH_BRIDGE
              (
                  // CHANNEL CH0 --> (example: Used for xP70s)
                  .data_req_CH0_i     ( data_req_to_MEM[j][N_CH0-1:0]                 ),
                  .data_add_CH0_i     ( data_add_i[N_CH0-1:0]                         ),
                  .data_wen_CH0_i     ( data_wen_i[N_CH0-1:0]                         ),
                  .data_wdata_CH0_i   ( data_wdata_i[N_CH0-1:0]                       ),
                  .data_be_CH0_i      ( data_be_i[N_CH0-1:0]                          ),
                  .data_ID_CH0_i      ( data_ID[N_CH0-1:0]                            ),
                  .data_aux_CH0_i     ( data_aux_i[N_CH0-1:0]                         ),
                  .data_gnt_CH0_o     ( data_gnt_from_MEM[j][N_CH0-1:0]               ),

                  // CHANNEL CH1 --> (example: Used for DMAs )
                  .data_req_CH1_i     ( data_req_to_MEM[j][N_CH1+N_CH0-1:N_CH0]       ),
                  .data_add_CH1_i     ( data_add_i[N_CH1+N_CH0-1:N_CH0]               ),
                  .data_wen_CH1_i     ( data_wen_i[N_CH1+N_CH0-1:N_CH0]               ),
                  .data_wdata_CH1_i   ( data_wdata_i[N_CH1+N_CH0-1:N_CH0]             ),
                  .data_be_CH1_i      ( data_be_i[N_CH1+N_CH0-1:N_CH0]                ),
                  .data_ID_CH1_i      ( data_ID[N_CH1+N_CH0-1:N_CH0]                  ),
                  .data_aux_CH1_i     ( data_aux_i[N_CH1+N_CH0-1:N_CH0]               ),
                  .data_gnt_CH1_o     ( data_gnt_from_MEM[j][N_CH1+N_CH0-1:N_CH0]     ),

                  // -----------------             MEMORY                    -------------------
                  // ---------------- RequestBlock OUTPUT (Connected to MEMORY) ----------------
                  .data_req_o         ( data_req_o[j]                                 ),
                  .data_add_o         ( data_add_o[j]                                 ),
                  .data_wen_o         ( data_wen_o[j]                                 ),
                  .data_wdata_o       ( data_wdata_o[j]                               ),
                  .data_be_o          ( data_be_o[j]                                  ),
                  .data_ID_o          ( data_ID_o[j]                                  ),
                  .data_aux_o         ( data_aux_o[j]                                 ),
                  .data_gnt_i         ( data_gnt_i[j]                                 ),

                  .data_r_valid_i     ( data_r_valid_i[j]                             ),
                  .data_r_ID_i        ( data_r_ID_i[j]                                ),

                  // GEN VALID_SIGNALS in the response path
                  .data_r_valid_CH0_o ( data_r_valid_from_MEM[j][N_CH0-1:0]           ), // N_CH0 Bit
                  .data_r_valid_CH1_o ( data_r_valid_from_MEM[j][N_CH0+N_CH1-1:N_CH0] ), // N_CH1 Bit
                  .clk(clk),
                  .rst_n(rst_n)
              );
           end
           else
           begin : CH0_ONLY
              RequestBlock1CH_BRIDGE
              #(
                  .ADDR_WIDTH        ( ADDR_WIDTH               ),
                  .N_CH0             ( N_CH0                    ),
                  .ID_WIDTH          ( ID_WIDTH                 ),
                  .DATA_WIDTH        ( DATA_WIDTH               ),
                  .AUX_WIDTH         ( AUX_WIDTH                ),
                  .BE_WIDTH          ( BE_WIDTH                 )
              )
              i_RequestBlock1CH_BRIDGE
              (
                // CHANNEL CH0 --> (example: Used for xP70s)
                .data_req_CH0_i      ( data_req_to_MEM[j]       ),
                .data_add_CH0_i      ( data_add_i               ),
                .data_wen_CH0_i      ( data_wen_i               ),
                .data_wdata_CH0_i    ( data_wdata_i             ),
                .data_be_CH0_i       ( data_be_i                ),
                .data_ID_CH0_i       ( data_ID                  ),
                .data_aux_CH0_i      ( data_aux_i               ),
                .data_gnt_CH0_o      ( data_gnt_from_MEM[j]     ),

                // -----------------             MEMORY                    -------------------
                // ---------------- RequestBlock OUTPUT (Connected to MEMORY) ----------------
                .data_req_o          ( data_req_o[j]            ),
                .data_add_o          ( data_add_o[j]            ),
                .data_wen_o          ( data_wen_o[j]            ),
                .data_wdata_o        ( data_wdata_o[j]          ),
                .data_be_o           ( data_be_o[j]             ),
                .data_ID_o           ( data_ID_o[j]             ),
                .data_aux_o          ( data_aux_o[j]            ),
                .data_gnt_i          ( data_gnt_i[j]            ),

                .data_r_valid_i      ( data_r_valid_i[j]        ),
                .data_r_ID_i         ( data_r_ID_i[j]           ),
                // GEN VALID_SIGNALS in the response path
                .data_r_valid_CH0_o  ( data_r_valid_from_MEM[j] ), // N_CH0 Bit
                .clk                 ( clk                      ),
                .rst_n               ( rst_n                    )
            );
           end
        end




      if(N_SLAVE == 1)
      begin : ResponseBlock_mono
              for (j=0;j<N_CH0+N_CH1; j++)
              begin : WIRING
                  assign data_r_rdata_o[j] = data_r_rdata_i;
                  assign data_r_opc_o[j]   = data_r_opc_i;
                  assign data_r_valid_o[j] = data_r_valid_to_MASTER[j];

                  assign data_ID[j]              = 2**j;
                  assign data_req_from_MASTER[j] = data_req_i[j];
                  assign data_gnt_o[j]           = data_gnt_to_MASTER[j];
              end
      end
      else
      begin : ResponseBlock_multi
              for (j=0; j<  N_CH0+N_CH1; j++)
              begin : ResponseBlock_PE_Block
                  ResponseBlock_BRIDGE
                  #(
                      .ID                 ( 2**j               ),
                      .ID_WIDTH           ( ID_WIDTH           ),
                      .N_SLAVE            ( N_SLAVE            ),
                      .AUX_WIDTH          ( AUX_WIDTH          ),
                      .DATA_WIDTH         ( DATA_WIDTH         )
                  )
                  i_ResponseBlock_BRIDGE
                  (

                      // Signals from Memory cuts
                      .data_r_valid_i  ( data_r_valid_to_MASTER[j]  ),
                      .data_r_rdata_i  ( data_r_rdata_i             ),
                      .data_r_opc_i    ( data_r_opc_i               ),
                      .data_r_aux_i    ( data_r_aux_i               ),

                      // Output of the ResponseTree Block
                      .data_r_valid_o  ( data_r_valid_o[j]          ),
                      .data_r_rdata_o  ( data_r_rdata_o[j]          ),
                      .data_r_opc_o    ( data_r_opc_o[j]            ),
                      .data_r_aux_o    ( data_r_aux_o[j]            ),

                      // Inputs form MAsters
                      .data_req_i      ( data_req_i[j]              ),
                      .destination_i   ( destination_OH[j]          ),
                      .data_gnt_o      ( data_gnt_o[j]              ),  // grant to master port
                      .data_gnt_i      ( data_gnt_to_MASTER[j]      ), // Signal from Request Block

                      // Signal to/from Request Block
                      .data_req_o      ( data_req_from_MASTER[j]    ),
                      // Generated ID
                      .data_ID_o       ( data_ID[j]                 )
                  );
                end
      end


    endgenerate

endmodule
