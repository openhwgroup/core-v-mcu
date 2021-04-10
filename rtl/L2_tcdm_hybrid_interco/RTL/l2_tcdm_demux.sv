// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module l2_tcdm_demux
#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter BE_WIDTH   = DATA_WIDTH/8,
    parameter AUX_WIDTH  = 4,
    parameter int unsigned N_PERIPHS  = 2
)
(
    input logic                          clk,
    input logic                          rst_n,
    input logic                          test_en_i,

    // CORE SIDE
    input logic                          data_req_i,
    input logic [ADDR_WIDTH - 1:0]       data_add_i,
    input logic                          data_wen_i,
    input logic [DATA_WIDTH - 1:0]       data_wdata_i,
    input logic [BE_WIDTH - 1:0]         data_be_i,
    input logic [AUX_WIDTH - 1:0]        data_aux_i,
    output logic                         data_gnt_o,
    output logic [AUX_WIDTH-1:0]         data_r_aux_o,    // Data Response AUX
    output logic                         data_r_valid_o,  // Data Response Valid (For LOAD/STORE commands)
    output logic [DATA_WIDTH - 1:0]      data_r_rdata_o,  // Data Response DATA (For LOAD commands)
    output logic                         data_r_opc_o,    // Data Response Error

    // Interleaved Region
    output logic                         data_req_o_TDCM,
    output logic [ADDR_WIDTH - 1:0]      data_add_o_TDCM,
    output logic                         data_wen_o_TDCM,
    output logic [DATA_WIDTH - 1:0]      data_wdata_o_TDCM,
    output logic [BE_WIDTH - 1:0]        data_be_o_TDCM,

    input  logic                         data_gnt_i_TDCM,
    input  logic                         data_r_valid_i_TDCM,
    input  logic [DATA_WIDTH - 1:0]      data_r_rdata_i_TDCM,

    // Memory Regions : Bridges
    output logic                         data_req_o_PER,
    output logic [ADDR_WIDTH - 1:0]      data_add_o_PER,
    output logic                         data_wen_o_PER,
    output logic [DATA_WIDTH - 1:0]      data_wdata_o_PER,
    output logic [BE_WIDTH - 1:0]        data_be_o_PER,
    output logic [AUX_WIDTH - 1:0]       data_aux_o_PER,
    input  logic                         data_gnt_i_PER,

    input  logic                         data_r_valid_i_PER,
    input  logic [DATA_WIDTH - 1:0]      data_r_rdata_i_PER,
    input  logic                         data_r_opc_i_PER,
    input  logic [AUX_WIDTH-1:0]         data_r_aux_i_PER,

    input  logic [N_PERIPHS-1:0][ADDR_WIDTH-1:0] PER_START_ADDR,
    input  logic [N_PERIPHS-1:0][ADDR_WIDTH-1:0] PER_END_ADDR,

    input  logic [ADDR_WIDTH-1:0]              TCDM_START_ADDR,
    input  logic [ADDR_WIDTH-1:0]              TCDM_END_ADDR
);


    enum logic [1:0] {IDLE, ON_TCDM, ON_PER, ERROR } CS, NS;

    logic [N_PERIPHS:0] [ADDR_WIDTH-1:0]                  ADDR_START;
    logic [N_PERIPHS:0] [ADDR_WIDTH-1:0]                  ADDR_END;

    logic [N_PERIPHS:0]                                   destination_OH;

    assign ADDR_START = { TCDM_START_ADDR , PER_START_ADDR };
    assign ADDR_END   = { TCDM_END_ADDR   , PER_END_ADDR   };

    assign  data_add_o_TDCM     = data_add_i;
    assign  data_wen_o_TDCM     = data_wen_i;
    assign  data_wdata_o_TDCM   = data_wdata_i;
    assign  data_be_o_TDCM      = data_be_i;

    assign  data_add_o_PER     = data_add_i;
    assign  data_wen_o_PER     = data_wen_i;
    assign  data_wdata_o_PER   = data_wdata_i;
    assign  data_be_o_PER      = data_be_i;
    assign  data_aux_o_PER     = data_aux_i;

    logic                     sample_aux;
    logic [AUX_WIDTH-1:0]     sampled_data_aux;




    always @(*)
    begin
          destination_OH = '0;

          for (int unsigned x=0; x<N_PERIPHS+1; x++)
          begin
             if( (data_add_i >= ADDR_START[x]) && (data_add_i < ADDR_END[x]) )
             begin
                destination_OH[x] = 1'b1;
             end
          end
    end






    always_ff @(posedge clk or negedge rst_n)
    begin
        if(~rst_n)
        begin
             CS <= IDLE;
             sampled_data_aux <= '0;
        end
        else
        begin
             CS <= NS;
             if(sample_aux)
                sampled_data_aux <= data_aux_i;
        end
    end





    always_comb
    begin

        data_req_o_TDCM = 1'b0;
        data_req_o_PER  = 1'b0;
        data_gnt_o      = 1'b0;
        sample_aux      = '0;

        data_r_opc_o    = 1'b0;
        data_r_valid_o  = 1'b0;
        data_r_aux_o    = sampled_data_aux;
        data_r_rdata_o  = data_r_rdata_i_TDCM;

        case(CS)

            IDLE:
            begin
                if(data_req_i)
                begin
                    if ( destination_OH[N_PERIPHS] == 1'b1 ) // ON TCDM
                    begin
                        data_req_o_TDCM = 1'b1;
                        data_gnt_o      = data_gnt_i_TDCM;

                        sample_aux = data_gnt_i_TDCM;

                        if(data_gnt_i_TDCM)
                            NS = ON_TCDM;
                        else
                            NS = IDLE;

                    end
                    else

                        if( |destination_OH[N_PERIPHS-1:0] == 1'b1) // on BRIDGES
                        begin
                            data_req_o_PER = 1'b1;
                            data_gnt_o     = data_gnt_i_PER;

                            if(data_gnt_i_PER)
                                NS = ON_PER;
                            else
                                NS = IDLE;
                        end
                        else
                        begin
                            NS = ERROR;
                            data_gnt_o = 1'b1;
                        end
                end
                else
                begin
                    NS = IDLE;
                end
            end




            ON_TCDM:
            begin
                data_r_valid_o = 1'b1;

                data_r_aux_o   = sampled_data_aux;
                data_r_rdata_o = data_r_rdata_i_TDCM;

                if(data_req_i)
                begin
                    if ( destination_OH[N_PERIPHS] == 1'b1 ) // ON TCDM
                    begin
                        data_req_o_TDCM = 1'b1;
                        data_gnt_o      = data_gnt_i_TDCM;

                        sample_aux = data_gnt_i_TDCM;

                        if(data_gnt_i_TDCM)
                            NS = ON_TCDM;
                        else
                            NS = IDLE;

                    end
                    else

                        if( |destination_OH[N_PERIPHS-1:0] == 1'b1) // on BRIDGES
                        begin
                            data_req_o_PER = 1'b1;
                            data_gnt_o     = data_gnt_i_PER;

                            if(data_gnt_i_PER)
                                NS = ON_PER;
                            else
                                NS = IDLE;
                        end
                        else
                        begin
                            NS = ERROR;
                            data_gnt_o = 1'b1;
                            sample_aux = 1'b1;
                        end
                end
                else
                begin
                    NS = IDLE;
                end

            end


            ON_PER:
            begin
                data_r_valid_o = data_r_valid_i_PER;
                data_r_aux_o   = data_r_aux_i_PER;;
                data_r_rdata_o = data_r_rdata_i_PER;
                data_r_opc_o   = data_r_opc_i_PER;

                if(data_r_valid_i_PER)
                begin

                        if(data_req_i)
                        begin
                            if ( destination_OH[N_PERIPHS] == 1'b1 ) // ON TCDM
                            begin
                                data_req_o_TDCM = 1'b1;
                                data_gnt_o      = data_gnt_i_TDCM;

                                sample_aux = data_gnt_i_TDCM;

                                if(data_gnt_i_TDCM)
                                    NS = ON_TCDM;
                                else
                                    NS = IDLE;

                            end
                            else

                                if( |destination_OH[N_PERIPHS-1:0] == 1'b1) // on BRIDGES
                                begin
                                    data_req_o_PER = 1'b1;
                                    data_gnt_o     = data_gnt_i_PER;

                                    if(data_gnt_i_PER)
                                        NS = ON_PER;
                                    else
                                        NS = IDLE;
                                end
                                else
                                begin
                                    NS = ERROR;
                                    data_gnt_o = 1'b1;
                                end
                        end
                        else
                        begin
                            NS = IDLE;
                        end

                end
                else
                begin
                    NS = ON_PER;
                end
            end


            ERROR:
            begin
                data_r_valid_o = 1'b1;
                data_r_aux_o   = sampled_data_aux;
                data_r_rdata_o = 32'hBAD_ACCE5;
                NS             = IDLE;
                data_r_opc_o   = 1'b1;
            end

        endcase // CS

    end














endmodule
