// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module ResponseTree_L2
#(
   parameter N_SLAVE = 4,
   parameter DATA_WIDTH = 64
)
(
   // Response Input Channel 0
   input logic [N_SLAVE-1:0]                       data_r_valid_i,
   input logic [N_SLAVE-1:0][DATA_WIDTH-1:0]       data_r_rdata_i,

   // Response Output Channel
   output logic                                    data_r_valid_o,
   output logic [DATA_WIDTH-1:0]                   data_r_rdata_o
);

    localparam LOG_SLAVE        = $clog2(N_SLAVE);
    localparam N_WIRE           = N_SLAVE - 2;

    genvar j,k;



    generate
      case (N_SLAVE)
      1: begin : MONO_SLAVE

        assign data_r_rdata_o = data_r_rdata_i;
        assign data_r_valid_o = data_r_valid_i;

      end

      2: begin : DUAL_SLAVE // START of  N_SLAVE  == 2
                    // ---------------- FAN IN PRIMITIVE RESP -------------------------
                    FanInPrimitive_Resp_L2 #( .DATA_WIDTH(DATA_WIDTH) ) FAN_IN_RESP
                    (
                        // RIGTH SIDE
                        .data_r_rdata0_i(data_r_rdata_i[0]),
                        .data_r_rdata1_i(data_r_rdata_i[1]),
                        .data_r_valid0_i(data_r_valid_i[0]),
                        .data_r_valid1_i(data_r_valid_i[1]),
                        // LEFT SIDE
                        .data_r_rdata_o(data_r_rdata_o),
                        .data_r_valid_o(data_r_valid_o)
                    );
      end // END OF N_SLAVE  == 2


      default begin : MULTI_SLAVE
            //// ---------------------------------------------------------------------- ////
            //// -------               REQ ARBITRATION TREE WIRES           ----------- ////
            //// ---------------------------------------------------------------------- ////
            logic [DATA_WIDTH-1:0]              data_r_rdata_LEVEL[N_WIRE-1:0];
            logic                               data_r_valid_LEVEL[N_WIRE-1:0];

              for(j=0; j < LOG_SLAVE; j++) // Iteration for the number of the stages minus one
                begin : STAGE
                  for(k=0; k<2**j; k=k+1) // Iteration needed to create the binary tree
                    begin : INCR_VERT

                      if (j == 0 )  // LAST NODE, drives the module outputs
                      begin : LAST_NODE
                          FanInPrimitive_Resp_L2 #( .DATA_WIDTH(DATA_WIDTH) ) FAN_IN_RESP
                          (
                          // RIGTH SIDE
                          .data_r_rdata0_i(data_r_rdata_LEVEL[2*k]),
                          .data_r_rdata1_i(data_r_rdata_LEVEL[2*k+1]),
                          .data_r_valid0_i(data_r_valid_LEVEL[2*k]),
                          .data_r_valid1_i(data_r_valid_LEVEL[2*k+1]),
                          // RIGTH SIDE
                          .data_r_rdata_o(data_r_rdata_o),
                          .data_r_valid_o(data_r_valid_o)
                          );
                      end
                      else if ( j < LOG_SLAVE - 1) // Middle Nodes
                              begin : MIDDLE_NODES // START of MIDDLE LEVELS Nodes
                                  FanInPrimitive_Resp_L2 #( .DATA_WIDTH(DATA_WIDTH) ) FAN_IN_RESP
                                  (
                                  // RIGTH SIDE
                                  .data_r_rdata0_i(data_r_rdata_LEVEL[((2**j)*2-2) + 2*k]),
                                  .data_r_rdata1_i(data_r_rdata_LEVEL[((2**j)*2-2) + 2*k +1]),
                                  .data_r_valid0_i(data_r_valid_LEVEL[((2**j)*2-2) + 2*k]),
                                  .data_r_valid1_i(data_r_valid_LEVEL[((2**j)*2-2) + 2*k+1]),
                                  // LEFT SIDE
                                  .data_r_rdata_o(data_r_rdata_LEVEL[((2**(j-1))*2-2) + k]),
                                  .data_r_valid_o(data_r_valid_LEVEL[((2**(j-1))*2-2) + k])
                                  );
                              end  // END of MIDDLE LEVELS Nodes
                           else // First stage (connected with the Main inputs ) --> ( j == N_SLAVE - 1 )
                              begin : LEAF_NODES  // START of FIRST LEVEL Nodes (LEAF)
                                  FanInPrimitive_Resp_L2 #( .DATA_WIDTH(DATA_WIDTH) ) FAN_IN_RESP
                                  (
                                  // RIGTH SIDE
                                  .data_r_rdata0_i(data_r_rdata_i[2*k]),
                                  .data_r_rdata1_i(data_r_rdata_i[2*k+1]),
                                  .data_r_valid0_i(data_r_valid_i[2*k]),
                                  .data_r_valid1_i(data_r_valid_i[2*k+1]),
                                  // LEFT SIDE
                                  .data_r_rdata_o(data_r_rdata_LEVEL[((2**(j-1))*2-2) + k]),
                                  .data_r_valid_o(data_r_valid_LEVEL[((2**(j-1))*2-2) + k])
                                  );
                              end // End of FIRST LEVEL Nodes (LEAF)
                    end

                end

        end
        endcase
    endgenerate


endmodule
