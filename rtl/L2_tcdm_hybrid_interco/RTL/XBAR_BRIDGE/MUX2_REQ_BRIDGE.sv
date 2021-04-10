// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module MUX2_REQ_BRIDGE
#(
    parameter ID_WIDTH   = 20,
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter AUX_WIDTH  = 6,
    parameter BE_WIDTH   = DATA_WIDTH/8
)
(
    input  logic                              data_req_CH0_i,
    input  logic [ADDR_WIDTH-1:0]             data_add_CH0_i,
    input  logic                              data_wen_CH0_i,
    input  logic [DATA_WIDTH-1:0]             data_wdata_CH0_i,
    input  logic [BE_WIDTH-1:0]               data_be_CH0_i,
    input  logic [ID_WIDTH-1:0]               data_ID_CH0_i,
    input  logic [AUX_WIDTH-1:0]              data_aux_CH0_i,
    output logic                              data_gnt_CH0_o,


    input  logic                              data_req_CH1_i,
    input  logic [ADDR_WIDTH-1:0]             data_add_CH1_i,
    input  logic                              data_wen_CH1_i,
    input  logic [DATA_WIDTH-1:0]             data_wdata_CH1_i,
    input  logic [BE_WIDTH-1:0]               data_be_CH1_i,
    input  logic [ID_WIDTH-1:0]               data_ID_CH1_i,
    input  logic [AUX_WIDTH-1:0]              data_aux_CH1_i,
    output logic                              data_gnt_CH1_o,

    output  logic                             data_req_o,
    output  logic [ADDR_WIDTH-1:0]            data_add_o,
    output  logic                             data_wen_o,
    output  logic [DATA_WIDTH-1:0]            data_wdata_o,
    output  logic [BE_WIDTH-1:0]              data_be_o,
    output  logic [ID_WIDTH-1:0]              data_ID_o,
    output  logic [AUX_WIDTH-1:0]             data_aux_o,
    input   logic                             data_gnt_i,

    input   logic                             clk,
    input   logic                             rst_n
);

    logic                              SEL; // Mux Selector
    logic                              RR_FLAG;

    // Request is simply an or between indoming request
    assign data_req_o = data_req_CH0_i | data_req_CH1_i;

      // FIXED PRIORITY ENCODER
    assign SEL               =   ~data_req_CH0_i | ( RR_FLAG & data_req_CH1_i);      // SEL FOR ROUND ROBIN MUX
    assign data_gnt_CH0_o    =    (( data_req_CH0_i & ~data_req_CH1_i) | ( data_req_CH0_i & ~RR_FLAG)) & data_gnt_i;
    assign data_gnt_CH1_o    =    ((~data_req_CH0_i &  data_req_CH1_i) | ( data_req_CH1_i &  RR_FLAG)) & data_gnt_i;

    always_ff @(posedge clk, negedge rst_n)
    begin
    if(rst_n == 1'b0)
        RR_FLAG <= 1'b0;
    else if((data_req_o == 1'b1) && (data_gnt_i == 1'b1) )
          RR_FLAG <= ~RR_FLAG;
    end

    always_comb
    begin : MUX2_REQ_COMB_L2
        case(SEL) // synopsys full_case
        1'b0:
        begin
              data_add_o   = data_add_CH0_i;
              data_wen_o   = data_wen_CH0_i;
              data_wdata_o = data_wdata_CH0_i;
              data_be_o    = data_be_CH0_i;
              data_ID_o    = data_ID_CH0_i;
              data_aux_o   = data_aux_CH0_i;
        end

        1'b1:
        begin
              data_add_o   = data_add_CH1_i;
              data_wen_o   = data_wen_CH1_i;
              data_wdata_o = data_wdata_CH1_i;
              data_be_o    = data_be_CH1_i;
              data_ID_o    = data_ID_CH1_i;
              data_aux_o   = data_aux_CH1_i;
        end
        endcase
    end
endmodule
