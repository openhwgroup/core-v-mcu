// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module ArbitrationTree_BRIDGE
#(
    parameter ADDR_WIDTH = 32,
    parameter ID_WIDTH   = 20,
    parameter N_MASTER   = 16,
    parameter DATA_WIDTH = 32,
    parameter BE_WIDTH   = DATA_WIDTH/8,
    parameter AUX_WIDTH  = 6,
    parameter MAX_COUNT  = N_MASTER
)
(
    input  logic                                 clk,
    input  logic                                 rst_n,

    // ---------------- REQ_SIDE --------------------------
    input  logic [N_MASTER-1:0]                  data_req_i,
    input  logic [N_MASTER-1:0][ADDR_WIDTH-1:0]  data_add_i,
    input  logic [N_MASTER-1:0]                  data_wen_i,
    input  logic [N_MASTER-1:0][DATA_WIDTH-1:0]  data_wdata_i,
    input  logic [N_MASTER-1:0][BE_WIDTH-1:0]    data_be_i,
    input  logic [N_MASTER-1:0][ID_WIDTH-1:0]    data_ID_i,
    input  logic [N_MASTER-1:0][AUX_WIDTH-1:0]   data_aux_i,
    output logic [N_MASTER-1:0]                  data_gnt_o,

    // Outputs
    output logic                                 data_req_o,
    output logic [ADDR_WIDTH-1:0]                data_add_o,
    output logic                                 data_wen_o,
    output logic [DATA_WIDTH-1:0]                data_wdata_o,
    output logic [BE_WIDTH-1:0]                  data_be_o,
    output logic [ID_WIDTH-1:0]                  data_ID_o,
    output logic [AUX_WIDTH-1:0]                 data_aux_o,
    input  logic                                 data_gnt_i

);

    localparam LOG_MASTER       = $clog2(N_MASTER);
    localparam N_WIRE           =  N_MASTER - 2;

    logic [LOG_MASTER-1:0]      RR_FLAG;

    genvar j,k;

    generate
      case(N_MASTER)

      1:
      begin : MONO_MASTER
         // Not possible, this block is inferred only if Master > 1
      end

      2:
      begin : DUAL_MASTER
                // ---------------- FAN IN PRIMITIVE  -------------------------
                FanInPrimitive_Req_BRIDGE
                #(
                  .ADDR_WIDTH ( ADDR_WIDTH ),
                  .ID_WIDTH   ( ID_WIDTH   ),
                  .DATA_WIDTH ( DATA_WIDTH ),
                  .AUX_WIDTH  ( AUX_WIDTH  ),
                  .BE_WIDTH   ( BE_WIDTH   )
                )
                i_FanInPrimitive_Req_BRIDGE
                (
                  .RR_FLAG(RR_FLAG),
                  // LEFT SIDE"
                  .data_wdata0_i ( data_wdata_i[0] ),
                  .data_wdata1_i ( data_wdata_i[1] ),
                  .data_add0_i   ( data_add_i[0]   ),
                  .data_add1_i   ( data_add_i[1]   ),
                  .data_req0_i   ( data_req_i[0]   ),
                  .data_req1_i   ( data_req_i[1]   ),
                  .data_wen0_i   ( data_wen_i[0]   ),
                  .data_wen1_i   ( data_wen_i[1]   ),
                  .data_ID0_i    ( data_ID_i[0]    ),
                  .data_ID1_i    ( data_ID_i[1]    ),
                  .data_be0_i    ( data_be_i[0]    ),
                  .data_be1_i    ( data_be_i[1]    ),
                  .data_aux0_i   ( data_aux_i[0]   ),
                  .data_aux1_i   ( data_aux_i[1]   ),
                  .data_gnt0_o   ( data_gnt_o[0]   ),
                  .data_gnt1_o   ( data_gnt_o[1]   ),

                  // RIGTH SIDE"
                  .data_wdata_o  ( data_wdata_o    ),
                  .data_add_o    ( data_add_o      ),
                  .data_req_o    ( data_req_o      ),
                  .data_wen_o    ( data_wen_o      ),
                  .data_ID_o     ( data_ID_o       ),
                  .data_be_o     ( data_be_o       ),
                  .data_aux_o    ( data_aux_o       ),
                  .data_gnt_i    ( data_gnt_i      )

                  );
      end // END OF MASTER  == 2


      default:
      begin : BINARY_TREE
          //// ---------------------------------------------------------------------- ////
          //// -------               REQ ARBITRATION TREE WIRES           ----------- ////
          //// ---------------------------------------------------------------------- ////
          logic [DATA_WIDTH-1:0]      data_wdata_LEVEL[N_WIRE-1:0];
          logic [ADDR_WIDTH-1:0]      data_add_LEVEL[N_WIRE-1:0];
          logic                       data_req_LEVEL[N_WIRE-1:0];
          logic                       data_wen_LEVEL[N_WIRE-1:0];
          logic [ID_WIDTH-1:0]        data_ID_LEVEL[N_WIRE-1:0];
          logic [BE_WIDTH-1:0]        data_be_LEVEL[N_WIRE-1:0];
          logic [AUX_WIDTH-1:0]       data_aux_LEVEL[N_WIRE-1:0];

          logic                       data_gnt_LEVEL[N_WIRE-1:0];

            for(j=0; j < LOG_MASTER; j++) // Iteration for the number of the stages minus one
            begin : STAGE
              for(k=0; k<2**j; k=k+1) // Iteration needed to create the binary tree
                begin : INCR_VERT
                  if (j == 0 )  // LAST NODE, drives the module outputs
                  begin : LAST_NODE
                    FanInPrimitive_Req_BRIDGE
                    #(
                        .ADDR_WIDTH ( ADDR_WIDTH ),
                        .ID_WIDTH   ( ID_WIDTH   ),
                        .DATA_WIDTH ( DATA_WIDTH ),
                        .AUX_WIDTH  ( AUX_WIDTH  ),
                        .BE_WIDTH   ( BE_WIDTH   )
                    )
                    i_FanInPrimitive_Req_BRIDGE
                    (
                        .RR_FLAG(RR_FLAG[LOG_MASTER-j-1]),
                        // LEFT SIDE
                        .data_wdata0_i ( data_wdata_LEVEL [2*k]   ),
                        .data_wdata1_i ( data_wdata_LEVEL [2*k+1] ),
                        .data_add0_i   ( data_add_LEVEL   [2*k]   ),
                        .data_add1_i   ( data_add_LEVEL   [2*k+1] ),
                        .data_req0_i   ( data_req_LEVEL   [2*k]   ),
                        .data_req1_i   ( data_req_LEVEL   [2*k+1] ),
                        .data_wen0_i   ( data_wen_LEVEL   [2*k]   ),
                        .data_wen1_i   ( data_wen_LEVEL   [2*k+1] ),
                        .data_ID0_i    ( data_ID_LEVEL    [2*k]   ),
                        .data_ID1_i    ( data_ID_LEVEL    [2*k+1] ),
                        .data_be0_i    ( data_be_LEVEL    [2*k]   ),
                        .data_be1_i    ( data_be_LEVEL    [2*k+1] ),
                        .data_aux0_i   ( data_aux_LEVEL   [2*k]   ),
                        .data_aux1_i   ( data_aux_LEVEL   [2*k+1] ),
                        .data_gnt0_o   ( data_gnt_LEVEL   [2*k]   ),
                        .data_gnt1_o   ( data_gnt_LEVEL   [2*k+1] ),

                        // RIGTH SIDE
                        .data_wdata_o  ( data_wdata_o             ),
                        .data_add_o    ( data_add_o               ),
                        .data_req_o    ( data_req_o               ),
                        .data_wen_o    ( data_wen_o               ),
                        .data_ID_o     ( data_ID_o                ),
                        .data_be_o     ( data_be_o                ),
                        .data_aux_o    ( data_aux_o               ),
                        .data_gnt_i    ( data_gnt_i               )

                    );
                  end
                  else if ( j < LOG_MASTER - 1) // Middle Nodes
                        begin : MIDDLE_NODES // START of MIDDLE LEVELS Nodes
                          FanInPrimitive_Req_BRIDGE
                          #(
                              .ADDR_WIDTH ( ADDR_WIDTH ),
                              .ID_WIDTH   ( ID_WIDTH   ),
                              .DATA_WIDTH ( DATA_WIDTH ),
                              .AUX_WIDTH  ( AUX_WIDTH  ),
                              .BE_WIDTH   ( BE_WIDTH   )
                          )
                          i_FanInPrimitive_Req_BRIDGE
                          (
                              .RR_FLAG(RR_FLAG[LOG_MASTER-j-1]),
                              // LEFT SIDE
                              .data_wdata0_i ( data_wdata_LEVEL [((2**j)*2-2) + 2*k]    ),
                              .data_wdata1_i ( data_wdata_LEVEL [((2**j)*2-2) + 2*k +1] ),
                              .data_add0_i   ( data_add_LEVEL   [((2**j)*2-2) + 2*k]    ),
                              .data_add1_i   ( data_add_LEVEL   [((2**j)*2-2) + 2*k+1]  ),
                              .data_req0_i   ( data_req_LEVEL   [((2**j)*2-2) + 2*k]    ),
                              .data_req1_i   ( data_req_LEVEL   [((2**j)*2-2) + 2*k+1]  ),
                              .data_wen0_i   ( data_wen_LEVEL   [((2**j)*2-2) + 2*k]    ),
                              .data_wen1_i   ( data_wen_LEVEL   [((2**j)*2-2) + 2*k+1]  ),
                              .data_ID0_i    ( data_ID_LEVEL    [((2**j)*2-2) + 2*k]    ),
                              .data_ID1_i    ( data_ID_LEVEL    [((2**j)*2-2) + 2*k+1]  ),
                              .data_be0_i    ( data_be_LEVEL    [((2**j)*2-2) + 2*k]    ),
                              .data_be1_i    ( data_be_LEVEL    [((2**j)*2-2) + 2*k+1]  ),
                              .data_aux0_i   ( data_aux_LEVEL   [((2**j)*2-2) + 2*k]    ),
                              .data_aux1_i   ( data_aux_LEVEL   [((2**j)*2-2) + 2*k+1]  ),
                              .data_gnt0_o   ( data_gnt_LEVEL   [((2**j)*2-2) + 2*k]    ),
                              .data_gnt1_o   ( data_gnt_LEVEL   [((2**j)*2-2) + 2*k+1]  ),

                              // RIGTH SIDE
                              .data_wdata_o ( data_wdata_LEVEL  [((2**(j-1))*2-2) + k]  ),
                              .data_add_o   ( data_add_LEVEL    [((2**(j-1))*2-2) + k]  ),
                              .data_req_o   ( data_req_LEVEL    [((2**(j-1))*2-2) + k]  ),
                              .data_wen_o   ( data_wen_LEVEL    [((2**(j-1))*2-2) + k]  ),
                              .data_ID_o    ( data_ID_LEVEL     [((2**(j-1))*2-2) + k]  ),
                              .data_be_o    ( data_be_LEVEL     [((2**(j-1))*2-2) + k]  ),
                              .data_aux_o   ( data_aux_LEVEL    [((2**(j-1))*2-2) + k]  ),
                              .data_gnt_i   ( data_gnt_LEVEL    [((2**(j-1))*2-2) + k]  )

                          );
                        end  // END of MIDDLE LEVELS Nodes
                     else // First stage (connected with the Main inputs ) --> ( j == N_MASTER - 1 )
                        begin : LEAF_NODES  // START of FIRST LEVEL Nodes (LEAF)
                            FanInPrimitive_Req_BRIDGE
                            #(
                                .ADDR_WIDTH ( ADDR_WIDTH ),
                                .ID_WIDTH   ( ID_WIDTH   ),
                                .DATA_WIDTH ( DATA_WIDTH ),
                                .AUX_WIDTH  ( AUX_WIDTH  ),
                                .BE_WIDTH   ( BE_WIDTH   )
                            )
                            i_FanInPrimitive_Req_BRIDGE
                            (
                                .RR_FLAG      ( RR_FLAG[LOG_MASTER-j-1] ),
                                // LEFT SIDE
                                .data_wdata0_i( data_wdata_i [2*k]    ),
                                .data_wdata1_i( data_wdata_i [2*k+1]  ),
                                .data_add0_i  ( data_add_i   [2*k]    ),
                                .data_add1_i  ( data_add_i   [2*k+1]  ),
                                .data_req0_i  ( data_req_i   [2*k]    ),
                                .data_req1_i  ( data_req_i   [2*k+1]  ),
                                .data_wen0_i  ( data_wen_i   [2*k]    ),
                                .data_wen1_i  ( data_wen_i   [2*k+1]  ),
                                .data_ID0_i   ( data_ID_i    [2*k]    ),
                                .data_ID1_i   ( data_ID_i    [2*k+1]  ),
                                .data_be0_i   ( data_be_i    [2*k]    ),
                                .data_be1_i   ( data_be_i    [2*k+1]  ),
                                .data_aux0_i  ( data_aux_i   [2*k]    ),
                                .data_aux1_i  ( data_aux_i   [2*k+1]  ),
                                .data_gnt0_o  ( data_gnt_o   [2*k]    ),
                                .data_gnt1_o  ( data_gnt_o   [2*k+1]  ),

                                // RIGTH SIDE
                                .data_wdata_o ( data_wdata_LEVEL [((2**(j-1))*2-2) + k] ),
                                .data_add_o   ( data_add_LEVEL   [((2**(j-1))*2-2) + k] ),
                                .data_req_o   ( data_req_LEVEL   [((2**(j-1))*2-2) + k] ),
                                .data_wen_o   ( data_wen_LEVEL   [((2**(j-1))*2-2) + k] ),
                                .data_ID_o    ( data_ID_LEVEL    [((2**(j-1))*2-2) + k] ),
                                .data_be_o    ( data_be_LEVEL    [((2**(j-1))*2-2) + k] ),
                                .data_aux_o   ( data_aux_LEVEL   [((2**(j-1))*2-2) + k] ),
                                .data_gnt_i   ( data_gnt_LEVEL   [((2**(j-1))*2-2) + k] )

                            );
                        end // End of FIRST LEVEL Nodes (LEAF)
                end

            end

      end
      endcase

    endgenerate

    //COUNTER USED TO SWITCH PERIODICALLY THE PRIORITY FLAG"
    RR_Flag_Req_BRIDGE
    #(
        .WIDTH     ( LOG_MASTER ),
        .MAX_COUNT ( MAX_COUNT  )
    )
    RR_REQ
    (
      .clk        ( clk        ),
      .rst_n      ( rst_n      ),
      .RR_FLAG_o  ( RR_FLAG    ),
      .data_req_i ( data_req_o ),
      .data_gnt_i ( data_gnt_i )

    );


endmodule
