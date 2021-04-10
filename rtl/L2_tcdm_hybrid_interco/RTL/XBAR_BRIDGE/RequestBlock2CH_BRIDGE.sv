// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// FOR TWO INPUTS Channel Groups
module RequestBlock2CH_BRIDGE
#(
    parameter ADDR_WIDTH = 32,
    parameter N_CH0      = 16, // Example Number of xP70
    parameter N_CH1      = 1,  // Example Number of DMAs
    parameter ID_WIDTH   = N_CH0+N_CH1,
    parameter DATA_WIDTH = 32,
    parameter AUX_WIDTH  = 6,
    parameter BE_WIDTH   = DATA_WIDTH/8
)
(
    // CHANNEL CH0 --> (example: Used for xP70s)
    input  logic [N_CH0-1:0]                     data_req_CH0_i,
    input  logic [N_CH0-1:0][ADDR_WIDTH-1:0]     data_add_CH0_i,
    input  logic [N_CH0-1:0]                     data_wen_CH0_i,
    input  logic [N_CH0-1:0][DATA_WIDTH-1:0]     data_wdata_CH0_i,
    input  logic [N_CH0-1:0][BE_WIDTH-1:0]       data_be_CH0_i,
    input  logic [N_CH0-1:0][ID_WIDTH-1:0]       data_ID_CH0_i,
    input  logic [N_CH0-1:0][AUX_WIDTH-1:0]      data_aux_CH0_i,

    output logic [N_CH0-1:0]                     data_gnt_CH0_o,

    // CHANNEL CH1 --> (example: Used for DMAs)
    input  logic [N_CH1-1:0]                     data_req_CH1_i,
    input  logic [N_CH1-1:0][ADDR_WIDTH-1:0]     data_add_CH1_i,
    input  logic [N_CH1-1:0]                     data_wen_CH1_i,
    input  logic [N_CH1-1:0][DATA_WIDTH-1:0]     data_wdata_CH1_i,
    input  logic [N_CH1-1:0][BE_WIDTH-1:0]       data_be_CH1_i,
    input  logic [N_CH1-1:0][ID_WIDTH-1:0]       data_ID_CH1_i,
    input  logic [N_CH1-1:0][AUX_WIDTH-1:0]      data_aux_CH1_i,

    output logic [N_CH1-1:0]                     data_gnt_CH1_o,

    // -----------------             MEMORY                    -------------------
    // ---------------- RequestBlock OUTPUT (Connected to MEMORY) ----------------
    output logic                                 data_req_o,
    output logic [ADDR_WIDTH-1:0]                data_add_o,
    output logic                                 data_wen_o,
    output logic [DATA_WIDTH-1:0]                data_wdata_o,
    output logic [BE_WIDTH-1:0]                  data_be_o,
    output logic [ID_WIDTH-1:0]                  data_ID_o,
    output logic [AUX_WIDTH-1:0]                 data_aux_o,
    input  logic                                 data_gnt_i,

    input   logic                                data_r_valid_i,
    input   logic [ID_WIDTH-1:0]                 data_r_ID_i,



    // GEN VALID_SIGNALS in the response path
    output logic [N_CH0-1:0]                      data_r_valid_CH0_o,
    output logic [N_CH1-1:0]                      data_r_valid_CH1_o,

    input  logic                                  clk,
    input  logic                                  rst_n

   );

       // OUT CHANNEL CH0 --> (example: Used for xP70s)
      logic                                                data_req_CH0;
      logic [ADDR_WIDTH-1:0]                               data_add_CH0;
      logic                                                data_wen_CH0;
      logic [DATA_WIDTH-1:0]                               data_wdata_CH0;
      logic [BE_WIDTH-1:0]                                 data_be_CH0;
      logic [ID_WIDTH-1:0]                                 data_ID_CH0;
      logic [AUX_WIDTH-1:0]                                data_aux_CH0;
      logic                                                data_gnt_CH0;


      // OUT CHANNEL CH1 --> (example: Used for DMAs)
      logic                                               data_req_CH1;
      logic [ADDR_WIDTH-1:0]                              data_add_CH1;
      logic                                               data_wen_CH1;
      logic [DATA_WIDTH-1:0]                              data_wdata_CH1;
      logic [BE_WIDTH-1:0]                                data_be_CH1;
      logic [ID_WIDTH-1:0]                                data_ID_CH1;
      logic [AUX_WIDTH-1:0]                               data_aux_CH1;

      logic                                               data_gnt_CH1;



      // CHANNEL CH0 --> (example: Used for Processing Elements / CORES)
    logic [2**$clog2(N_CH0)-1:0]                                data_req_CH0_int;
    logic [2**$clog2(N_CH0)-1:0][ADDR_WIDTH-1:0]                data_add_CH0_int;
    logic [2**$clog2(N_CH0)-1:0]                                data_wen_CH0_int;
    logic [2**$clog2(N_CH0)-1:0][DATA_WIDTH-1:0]                data_wdata_CH0_int;
    logic [2**$clog2(N_CH0)-1:0][BE_WIDTH-1:0]                  data_be_CH0_int;
    logic [2**$clog2(N_CH0)-1:0][ID_WIDTH-1:0]                  data_ID_CH0_int;
    logic [2**$clog2(N_CH0)-1:0][AUX_WIDTH-1:0]                 data_aux_CH0_int;
    logic [2**$clog2(N_CH0)-1:0]                                data_gnt_CH0_int;




    // CHANNEL CH0 --> (example: Used for Processing Elements / CORES)
    logic [2**$clog2(N_CH1)-1:0]                                data_req_CH1_int;
    logic [2**$clog2(N_CH1)-1:0][ADDR_WIDTH-1:0]                data_add_CH1_int;
    logic [2**$clog2(N_CH1)-1:0]                                data_wen_CH1_int;
    logic [2**$clog2(N_CH1)-1:0][DATA_WIDTH-1:0]                data_wdata_CH1_int;
    logic [2**$clog2(N_CH1)-1:0][BE_WIDTH-1:0]                  data_be_CH1_int;
    logic [2**$clog2(N_CH1)-1:0][ID_WIDTH-1:0]                  data_ID_CH1_int;
    logic [2**$clog2(N_CH1)-1:0][AUX_WIDTH-1:0]                 data_aux_CH1_int;
    logic [2**$clog2(N_CH1)-1:0]                                data_gnt_CH1_int;





      generate


              if(2**$clog2(N_CH0) != N_CH0) // if N_CH0 is not power of 2 --> then use power 2 ports
              begin : _DUMMY_CH0_PORTS_

                logic [2**$clog2(N_CH0)-N_CH0 -1 :0]                                data_req_CH0_dummy;
                logic [2**$clog2(N_CH0)-N_CH0 -1 :0][ADDR_WIDTH-1:0]                data_add_CH0_dummy; // Memory address + T&S bit
                logic [2**$clog2(N_CH0)-N_CH0 -1 :0]                                data_wen_CH0_dummy;
                logic [2**$clog2(N_CH0)-N_CH0 -1 :0][DATA_WIDTH-1:0]                data_wdata_CH0_dummy;
                logic [2**$clog2(N_CH0)-N_CH0 -1 :0][BE_WIDTH-1:0]                  data_be_CH0_dummy;
                logic [2**$clog2(N_CH0)-N_CH0 -1 :0][ID_WIDTH-1:0]                  data_ID_CH0_dummy;
                logic [2**$clog2(N_CH0)-N_CH0 -1 :0][AUX_WIDTH-1:0]                 data_aux_CH0_dummy;

                logic [2**$clog2(N_CH0)-N_CH0 -1 :0]                                data_gnt_CH0_dummy;


                assign data_req_CH0_dummy    = '0 ;
                assign data_add_CH0_dummy    = '0 ;
                assign data_wen_CH0_dummy    = '0 ;
                assign data_wdata_CH0_dummy  = '0 ;
                assign data_be_CH0_dummy     = '0 ;
                assign data_ID_CH0_dummy     = '0 ;
                assign data_aux_CH0_dummy    = '0 ;

                assign data_req_CH0_int      = {  data_req_CH0_dummy  ,     data_req_CH0_i     };
                assign data_add_CH0_int      = {  data_add_CH0_dummy  ,     data_add_CH0_i     };
                assign data_wen_CH0_int      = {  data_wen_CH0_dummy  ,     data_wen_CH0_i     };
                assign data_wdata_CH0_int    = {  data_wdata_CH0_dummy  ,   data_wdata_CH0_i   };
                assign data_be_CH0_int       = {  data_be_CH0_dummy  ,      data_be_CH0_i      };
                assign data_ID_CH0_int       = {  data_ID_CH0_dummy  ,      data_ID_CH0_i      };
                assign data_aux_CH0_int      = {  data_aux_CH0_dummy  ,     data_aux_CH0_i     };


                for(genvar j=0; j<N_CH0; j++)
                begin : _MERGING_CH0_DUMMY_PORTS_OUT_
                  assign data_gnt_CH0_o[j]     = data_gnt_CH0_int[j];
                end
            end
            else // N_CH0 is power of 2
            begin
                  assign data_req_CH0_int   = data_req_CH0_i;
                  assign data_add_CH0_int   = data_add_CH0_i;
                  assign data_wen_CH0_int   = data_wen_CH0_i;
                  assign data_wdata_CH0_int = data_wdata_CH0_i;
                  assign data_be_CH0_int    = data_be_CH0_i;
                  assign data_ID_CH0_int    = data_ID_CH0_i;
                  assign data_aux_CH0_int   = data_aux_CH0_i;
                  assign data_gnt_CH0_o     = data_gnt_CH0_int;
            end




            if(2**$clog2(N_CH1) != N_CH1) // if N_CH1 is not power of 2 --> then use power 2 ports
            begin : _DUMMY_CH1_PORTS_

              logic [2**$clog2(N_CH1)-N_CH1 -1 :0]                                data_req_CH1_dummy;
              logic [2**$clog2(N_CH1)-N_CH1 -1 :0][ADDR_WIDTH-1:0]                data_add_CH1_dummy; // Memory address + T&S bit
              logic [2**$clog2(N_CH1)-N_CH1 -1 :0]                                data_wen_CH1_dummy;
              logic [2**$clog2(N_CH1)-N_CH1 -1 :0][DATA_WIDTH-1:0]                data_wdata_CH1_dummy;
              logic [2**$clog2(N_CH1)-N_CH1 -1 :0][BE_WIDTH-1:0]                  data_be_CH1_dummy;
              logic [2**$clog2(N_CH1)-N_CH1 -1 :0][ID_WIDTH-1:0]                  data_ID_CH1_dummy;
              logic [2**$clog2(N_CH1)-N_CH1 -1 :0][AUX_WIDTH-1:0]                 data_aux_CH1_dummy;
              logic [2**$clog2(N_CH1)-N_CH1 -1 :0]                                data_gnt_CH1_dummy;


              assign data_req_CH1_dummy    = '0 ;
              assign data_add_CH1_dummy    = '0 ;
              assign data_wen_CH1_dummy    = '0 ;
              assign data_wdata_CH1_dummy  = '0 ;
              assign data_be_CH1_dummy     = '0 ;
              assign data_ID_CH1_dummy     = '0 ;
              assign data_aux_CH1_dummy    = '0 ;

              assign data_req_CH1_int      = {  data_req_CH1_dummy  ,     data_req_CH1_i     };
              assign data_add_CH1_int      = {  data_add_CH1_dummy  ,     data_add_CH1_i     };
              assign data_wen_CH1_int      = {  data_wen_CH1_dummy  ,     data_wen_CH1_i     };
              assign data_wdata_CH1_int    = {  data_wdata_CH1_dummy  ,   data_wdata_CH1_i   };
              assign data_be_CH1_int       = {  data_be_CH1_dummy  ,      data_be_CH1_i      };
              assign data_ID_CH1_int       = {  data_ID_CH1_dummy  ,      data_ID_CH1_i      };
              assign data_aux_CH1_int      = {  data_aux_CH1_dummy  ,     data_aux_CH1_i     };


              for(genvar j=0; j<N_CH1; j++)
              begin : _MERGING_CH1_DUMMY_PORTS_OUT_
                assign data_gnt_CH1_o[j]     = data_gnt_CH1_int[j];
              end


          end
          else // N_CH1 is power of 2
          begin
                assign data_req_CH1_int   = data_req_CH1_i;
                assign data_add_CH1_int   = data_add_CH1_i;
                assign data_wen_CH1_int   = data_wen_CH1_i;
                assign data_wdata_CH1_int = data_wdata_CH1_i;
                assign data_be_CH1_int    = data_be_CH1_i;
                assign data_ID_CH1_int    = data_ID_CH1_i;
                assign data_aux_CH1_int   = data_aux_CH1_i;

                assign data_gnt_CH1_o     = data_gnt_CH1_int;
          end






        if(N_CH0 > 1)
        begin : CH0_ARB_TREE
            ArbitrationTree_BRIDGE
            #(
                  .ADDR_WIDTH ( ADDR_WIDTH ),
                  .ID_WIDTH   ( ID_WIDTH   ),
                  .N_MASTER   ( 2**$clog2(N_CH0) ),
                  .DATA_WIDTH ( DATA_WIDTH ),
                  .BE_WIDTH   ( BE_WIDTH   ),
                  .AUX_WIDTH  ( AUX_WIDTH  ),
                  .MAX_COUNT  ( N_CH0 - 1  )
            )
            i_ArbitrationTree_BRIDGE
            (
              .clk           ( clk                ),
              .rst_n         ( rst_n              ),
              // INPUTS
              .data_req_i    ( data_req_CH0_int   ),
              .data_add_i    ( data_add_CH0_int   ),
              .data_wen_i    ( data_wen_CH0_int   ),
              .data_wdata_i  ( data_wdata_CH0_int ),
              .data_be_i     ( data_be_CH0_int    ),
              .data_ID_i     ( data_ID_CH0_int    ),
              .data_aux_i    ( data_aux_CH0_int   ),
              .data_gnt_o    ( data_gnt_CH0_int   ),
              // OUTPUTS
              .data_req_o    ( data_req_CH0       ),
              .data_add_o    ( data_add_CH0       ),
              .data_wen_o    ( data_wen_CH0       ),
              .data_wdata_o  ( data_wdata_CH0     ),
              .data_be_o     ( data_be_CH0        ),
              .data_ID_o     ( data_ID_CH0        ),
              .data_aux_o    ( data_aux_CH0       ),
              .data_gnt_i    ( data_gnt_CH0       )
          );
        end

        if(N_CH1 > 1)
        begin : CH1_ARB_TREE
            ArbitrationTree_BRIDGE
              #(
                  .ADDR_WIDTH    ( ADDR_WIDTH ),
                  .ID_WIDTH      ( ID_WIDTH   ),
                  .N_MASTER      ( 2**$clog2(N_CH1)      ),
                  .DATA_WIDTH    ( DATA_WIDTH ),
                  .BE_WIDTH      ( BE_WIDTH   ),
                  .AUX_WIDTH     ( AUX_WIDTH  ),
                  .MAX_COUNT     ( N_CH1 - 1  )
              )
              i_ArbitrationTree_BRIDGE
              (
                  .clk            ( clk                ),
                  .rst_n          ( rst_n              ),
                  // INPUTS
                  .data_req_i     ( data_req_CH1_int   ),
                  .data_add_i     ( data_add_CH1_int   ),
                  .data_wen_i     ( data_wen_CH1_int   ),
                  .data_wdata_i   ( data_wdata_CH1_int ),
                  .data_be_i      ( data_be_CH1_int    ),
                  .data_ID_i      ( data_ID_CH1_int    ),
                  .data_aux_i     ( data_aux_CH1_int   ),
                  .data_gnt_o     ( data_gnt_CH1_int   ),

                  // OUTPUTS
                  .data_req_o     ( data_req_CH1       ),
                  .data_add_o     ( data_add_CH1       ),
                  .data_wen_o     ( data_wen_CH1       ),
                  .data_wdata_o   ( data_wdata_CH1     ),
                  .data_be_o      ( data_be_CH1        ),
                  .data_ID_o      ( data_ID_CH1        ),
                  .data_aux_o     ( data_aux_CH1       ),
                  .data_gnt_i     ( data_gnt_CH1       )

          );
        end

        if(N_CH1 == 1)
        begin : MONO_CH1
          if(N_CH0 == 1)
            begin : MONO_CH0
                MUX2_REQ_BRIDGE
                #(
                    .ID_WIDTH   ( ID_WIDTH     ),
                    .ADDR_WIDTH ( ADDR_WIDTH   ),
                    .DATA_WIDTH ( DATA_WIDTH   ),
                    .AUX_WIDTH  ( AUX_WIDTH    ),
                    .BE_WIDTH   ( BE_WIDTH     )
                )
                i_MUX2_REQ_BRIDGE
                (
                    // CH0 input
                    .data_req_CH0_i   (  data_req_CH0_int   ),
                    .data_add_CH0_i   (  data_add_CH0_int   ),
                    .data_wen_CH0_i   (  data_wen_CH0_int   ),
                    .data_wdata_CH0_i (  data_wdata_CH0_int ),
                    .data_be_CH0_i    (  data_be_CH0_int    ),
                    .data_ID_CH0_i    (  data_ID_CH0_int    ),
                    .data_aux_CH0_i   (  data_aux_CH0_int   ),
                    .data_gnt_CH0_o   (  data_gnt_CH0_int   ),

                    // CH1 input
                    .data_req_CH1_i   (  data_req_CH1_int   ),
                    .data_add_CH1_i   (  data_add_CH1_int   ),
                    .data_wen_CH1_i   (  data_wen_CH1_int   ),
                    .data_wdata_CH1_i (  data_wdata_CH1_int ),
                    .data_be_CH1_i    (  data_be_CH1_int    ),
                    .data_ID_CH1_i    (  data_ID_CH1_int    ),
                    .data_aux_CH1_i   (  data_aux_CH1_int   ),
                    .data_gnt_CH1_o   (  data_gnt_CH1_int   ),

                    // MUX output
                    .data_req_o       (  data_req_o        ),
                    .data_add_o       (  data_add_o        ),
                    .data_wen_o       (  data_wen_o        ),
                    .data_wdata_o     (  data_wdata_o      ),
                    .data_be_o        (  data_be_o         ),
                    .data_ID_o        (  data_ID_o         ),
                    .data_aux_o       (  data_aux_o        ),
                    .data_gnt_i       (  data_gnt_i        ),

                    .clk              (  clk               ),
                    .rst_n            (  rst_n             )
            );
            end // END MONO_CH0
          else
              begin : POLY_CH0
                  MUX2_REQ_BRIDGE
                  #(
                      .ID_WIDTH   ( ID_WIDTH     ),
                      .ADDR_WIDTH ( ADDR_WIDTH   ),
                      .DATA_WIDTH ( DATA_WIDTH   ),
                      .AUX_WIDTH  ( AUX_WIDTH    ),
                      .BE_WIDTH   ( BE_WIDTH     )
                  )
                  i_MUX2_REQ_BRIDGE
                  (
                      // CH0 input
                      .data_req_CH0_i   ( data_req_CH0       ),
                      .data_add_CH0_i   ( data_add_CH0       ),
                      .data_wen_CH0_i   ( data_wen_CH0       ),
                      .data_wdata_CH0_i ( data_wdata_CH0     ),
                      .data_be_CH0_i    ( data_be_CH0        ),
                      .data_ID_CH0_i    ( data_ID_CH0        ),
                      .data_aux_CH0_i   ( data_aux_CH0       ),
                      .data_gnt_CH0_o   ( data_gnt_CH0       ),

                      // CH1 input
                      .data_req_CH1_i   ( data_req_CH1_int   ),
                      .data_add_CH1_i   ( data_add_CH1_int   ),
                      .data_wen_CH1_i   ( data_wen_CH1_int   ),
                      .data_wdata_CH1_i ( data_wdata_CH1_int ),
                      .data_be_CH1_i    ( data_be_CH1_int    ),
                      .data_ID_CH1_i    ( data_ID_CH1_int    ),
                      .data_aux_CH1_i   ( data_aux_CH1_int   ),
                      .data_gnt_CH1_o   ( data_gnt_CH1_int   ),

                      // MUX output
                      .data_req_o       ( data_req_o        ),
                      .data_add_o       ( data_add_o        ),
                      .data_wen_o       ( data_wen_o        ),
                      .data_wdata_o     ( data_wdata_o      ),
                      .data_be_o        ( data_be_o         ),
                      .data_ID_o        ( data_ID_o         ),
                      .data_aux_o       ( data_aux_o        ),
                      .data_gnt_i       ( data_gnt_i        ),

                      .clk              ( clk               ),
                      .rst_n            ( rst_n             )
              );
              end // END POLY_CH0
        end
        else
        begin : POLY_CH1
          if(N_CH0 == 1)
          begin : MONO_CH0
                MUX2_REQ_BRIDGE
                #(
                    .ID_WIDTH   ( ID_WIDTH     ),
                    .ADDR_WIDTH ( ADDR_WIDTH   ),
                    .DATA_WIDTH ( DATA_WIDTH   ),
                    .AUX_WIDTH  ( AUX_WIDTH    ),
                    .BE_WIDTH   ( BE_WIDTH     )
                )
                i_MUX2_REQ_BRIDGE
                (
                    // CH0 input
                    .data_req_CH0_i    ( data_req_CH0_int     ),
                    .data_add_CH0_i    ( data_add_CH0_int     ),
                    .data_wen_CH0_i    ( data_wen_CH0_int     ),
                    .data_wdata_CH0_i  ( data_wdata_CH0_int   ),
                    .data_be_CH0_i     ( data_be_CH0_int      ),
                    .data_ID_CH0_i     ( data_ID_CH0_int      ),
                    .data_aux_CH0_i    ( data_aux_CH0_int      ),
                    .data_gnt_CH0_o    ( data_gnt_CH0_int     ),

                    // CH1 input
                    .data_req_CH1_i    ( data_req_CH1       ),
                    .data_add_CH1_i    ( data_add_CH1       ),
                    .data_wen_CH1_i    ( data_wen_CH1       ),
                    .data_wdata_CH1_i  ( data_wdata_CH1     ),
                    .data_be_CH1_i     ( data_be_CH1        ),
                    .data_ID_CH1_i     ( data_ID_CH1        ),
                    .data_aux_CH1_i    ( data_aux_CH1       ),
                    .data_gnt_CH1_o    ( data_gnt_CH1       ),

                    // MUX output
                    .data_req_o        ( data_req_o         ),
                    .data_add_o        ( data_add_o         ),
                    .data_wen_o        ( data_wen_o         ),
                    .data_wdata_o      ( data_wdata_o       ),
                    .data_be_o         ( data_be_o          ),
                    .data_ID_o         ( data_ID_o          ),
                    .data_aux_o        ( data_aux_o         ),
                    .data_gnt_i        ( data_gnt_i         ),

                    .clk               ( clk                ),
                    .rst_n             ( rst_n              )
            );
          end
          else
          begin : POLY_CH0
                MUX2_REQ_BRIDGE
                #(
                    .ID_WIDTH   ( ID_WIDTH     ),
                    .ADDR_WIDTH ( ADDR_WIDTH   ),
                    .DATA_WIDTH ( DATA_WIDTH   ),
                    .AUX_WIDTH  ( AUX_WIDTH    ),
                    .BE_WIDTH   ( BE_WIDTH     )
                )
                i_MUX2_REQ_BRIDGE
                (
                    // CH0 input
                    .data_req_CH0_i     ( data_req_CH0     ),
                    .data_add_CH0_i     ( data_add_CH0     ),
                    .data_wen_CH0_i     ( data_wen_CH0     ),
                    .data_wdata_CH0_i   ( data_wdata_CH0   ),
                    .data_be_CH0_i      ( data_be_CH0      ),
                    .data_ID_CH0_i      ( data_ID_CH0      ),
                    .data_aux_CH0_i     ( data_aux_CH0     ),
                    .data_gnt_CH0_o     ( data_gnt_CH0     ),

                    // CH1 input
                    .data_req_CH1_i     ( data_req_CH1     ),
                    .data_add_CH1_i     ( data_add_CH1     ),
                    .data_wen_CH1_i     ( data_wen_CH1     ),
                    .data_wdata_CH1_i   ( data_wdata_CH1   ),
                    .data_be_CH1_i      ( data_be_CH1      ),
                    .data_ID_CH1_i      ( data_ID_CH1      ),
                    .data_aux_CH1_i     ( data_aux_CH1     ),
                    .data_gnt_CH1_o     ( data_gnt_CH1     ),

                    // MUX output
                    .data_req_o         ( data_req_o       ),
                    .data_add_o         ( data_add_o       ),
                    .data_wen_o         ( data_wen_o       ),
                    .data_wdata_o       ( data_wdata_o     ),
                    .data_be_o          ( data_be_o        ),
                    .data_aux_o         ( data_aux_o       ),
                    .data_ID_o          ( data_ID_o        ),
                    .data_gnt_i         ( data_gnt_i       ),

                    .clk                ( clk              ),
                    .rst_n              ( rst_n            )
                );
          end
    end
    endgenerate




    AddressDecoder_Resp_BRIDGE
    #(
        .ID_WIDTH(ID_WIDTH),
        .N_MASTER(N_CH0+N_CH1)
    )
    i_AddressDecoder_Resp_BRIDGE
    (
      // FROM Test And Set Interface
      .data_r_valid_i(data_r_valid_i),
      .data_ID_i(data_r_ID_i),
      // To Response Network
      .data_r_valid_o({data_r_valid_CH1_o,data_r_valid_CH0_o})
    );



endmodule
