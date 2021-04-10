// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/FPGA_FCBL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

/*
 * apb_efpga_demux.sv
 * Pasquale Davide Schiavone <pschiavo@iis.ee.ethz.ch>
 * Based on core_demux.sv
 */


`include "periph_bus_defines.sv"

module apb_efpga_demux #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter BYTE_ENABLE_BIT = DATA_WIDTH / 8,
    parameter ID_WIDTH = 10
) (
    input logic clk,
    input logic rst_ni,

    // MASTER SIDE
    input  logic                         data_req_i,
    input  logic [     ADDR_WIDTH - 1:0] data_add_i,
    input  logic                         data_wen_i,
    input  logic [     DATA_WIDTH - 1:0] data_wdata_i,
    input  logic [BYTE_ENABLE_BIT - 1:0] data_be_i,
    output logic                         data_gnt_o,

    output logic data_r_valid_o,  // Data Response Valid (For LOAD/STORE commands)
    output logic [DATA_WIDTH - 1:0] data_r_rdata_o,  // Data Response DATA (For LOAD commands)

    input  logic [ID_WIDTH-1:0] data_ID_i,
    output logic [ID_WIDTH-1:0] data_r_ID_o,

    // APB SIDE
    output logic                         data_req_o_APB_PER,
    output logic [     ADDR_WIDTH - 1:0] data_add_o_APB_PER,
    output logic                         data_wen_o_APB_PER,
    output logic [     DATA_WIDTH - 1:0] data_wdata_o_APB_PER,
    output logic [BYTE_ENABLE_BIT - 1:0] data_be_o_APB_PER,
    input  logic                         data_gnt_i_APB_PER,
    input  logic                         data_r_valid_i_APB_PER,
    input  logic [     DATA_WIDTH - 1:0] data_r_rdata_i_APB_PER,


    // EFPGA Program Side
    output logic                         data_req_o_FPGA_FCB,
    output logic [     ADDR_WIDTH - 1:0] data_add_o_FPGA_FCB,
    output logic                         data_wen_o_FPGA_FCB,
    output logic [     DATA_WIDTH - 1:0] data_wdata_o_FPGA_FCB,
    output logic [BYTE_ENABLE_BIT - 1:0] data_be_o_FPGA_FCB,
    input  logic                         data_gnt_i_FPGA_FCB,
    input  logic                         data_r_valid_i_FPGA_FCB,
    input  logic [     DATA_WIDTH - 1:0] data_r_rdata_i_FPGA_FCB,

    // EFPGA Type1 Side
    output logic                         data_req_o_FPGA_T1,
    output logic [     ADDR_WIDTH - 1:0] data_add_o_FPGA_T1,
    output logic                         data_wen_o_FPGA_T1,
    output logic [     DATA_WIDTH - 1:0] data_wdata_o_FPGA_T1,
    output logic [BYTE_ENABLE_BIT - 1:0] data_be_o_FPGA_T1,
    input  logic                         data_gnt_i_FPGA_T1,
    input  logic                         data_r_valid_i_FPGA_T1,
    input  logic [     DATA_WIDTH - 1:0] data_r_rdata_i_FPGA_T1

);

  enum logic [1:0] {
    TRANS_IDLE,
    TRANS_PENDING,
    TRANS_GRANTED,
    TRANS_VALID
  }
      CS, NS;

  /*
    APB range is 32'h1A10_0000 - 32'h1AF0_0000

    APB_PERIPHERALS are           1A10_0000 - 1A1F_FFFF
    EFPGA_HWCE_START_ADDR    is   1A20_0000 - 1A2F_FFFF
    EFPGA_CONFIG_START_ADDR  is   1A30_0000 - 1A3F_FFFF
    thus only the bits 21:20 have to be checked
  */

  `define APB_ADDR_RANGE 21:20

  enum logic [1:0] {
    APB_PER  = 2'b01,
    FPGA_FCB = 2'b11,
    FPGA_T1  = 2'b10
  }
      request_destination_n, request_destination_q;
  logic [DATA_WIDTH-1:0] s_data_r_data;

  assign data_add_o_FPGA_FCB   = data_add_i;
  assign data_wen_o_FPGA_FCB   = data_wen_i;
  assign data_wdata_o_FPGA_FCB = data_wdata_i;
  assign data_be_o_FPGA_FCB    = data_be_i;

  assign data_add_o_FPGA_T1    = data_add_i;
  assign data_wen_o_FPGA_T1    = data_wen_i;
  assign data_wdata_o_FPGA_T1  = data_wdata_i;
  assign data_be_o_FPGA_T1     = data_be_i;

  assign data_add_o_APB_PER    = data_add_i;
  assign data_wen_o_APB_PER    = data_wen_i;
  assign data_wdata_o_APB_PER  = data_wdata_i;
  assign data_be_o_APB_PER     = data_be_i;


  always_comb begin

    data_req_o_FPGA_FCB   = 1'b0;
    data_req_o_FPGA_T1    = 1'b0;
    data_req_o_APB_PER    = 1'b0;

    data_gnt_o            = 1'b0;
    NS                    = CS;
    request_destination_n = request_destination_q;

    case (CS)

      TRANS_IDLE: begin
        if (data_req_i == 1'b1) begin
          case (data_add_i[`APB_ADDR_RANGE])
            FPGA_FCB: begin

              data_req_o_FPGA_FCB = data_req_i;

              if (data_gnt_i_FPGA_FCB) begin
                NS                    = TRANS_GRANTED;
                request_destination_n = FPGA_FCB;
                data_gnt_o            = 1'b1;
              end else NS = TRANS_IDLE;

            end

            FPGA_T1: begin

              data_req_o_FPGA_T1 = data_req_i;

              if (data_gnt_i_FPGA_T1) begin
                NS                    = TRANS_GRANTED;
                request_destination_n = FPGA_T1;
                data_gnt_o            = 1'b1;
              end else NS = TRANS_IDLE;

            end

            APB_PER: begin

              data_req_o_APB_PER = data_req_i;

              if (data_gnt_i_APB_PER) begin
                NS                    = TRANS_GRANTED;
                request_destination_n = APB_PER;
                data_gnt_o            = 1'b1;
              end else NS = TRANS_IDLE;

            end

            default: begin
              NS = CS;
            end

          endcase

        end

      end

      TRANS_GRANTED: begin
        case (request_destination_q)
          FPGA_FCB: begin
            if (data_r_valid_i_FPGA_FCB) begin
              NS = TRANS_IDLE;
            end
          end
          FPGA_T1: begin
            if (data_r_valid_i_FPGA_T1) begin
              NS = TRANS_IDLE;
            end
          end
          APB_PER: begin
            if (data_r_valid_i_APB_PER) begin
              NS = TRANS_IDLE;
            end
          end
          default: begin
            NS = CS;
          end
        endcase
      end

      default: begin
        NS = TRANS_IDLE;
      end
    endcase
  end

  assign data_r_valid_o = data_r_valid_i_FPGA_FCB | data_r_valid_i_FPGA_T1 | data_r_valid_i_APB_PER;

  always_comb begin
    data_r_rdata_o = data_r_rdata_i_APB_PER;

    case (request_destination_q)
      FPGA_FCB: begin
        data_r_rdata_o = data_r_rdata_i_FPGA_FCB;
      end
      FPGA_T1: begin
        data_r_rdata_o = data_r_rdata_i_FPGA_T1;
      end
      APB_PER: begin
        data_r_rdata_o = data_r_rdata_i_APB_PER;
      end
    endcase
  end



  // periph response generation
  always_ff @(posedge clk, negedge rst_ni) begin
    if (rst_ni == 1'b0) begin
      request_destination_q <= APB_PER;
      data_r_ID_o           <= '0;
      CS                    <= TRANS_IDLE;
    end else begin
      if (data_gnt_o) begin
        request_destination_q <= request_destination_n;
        data_r_ID_o           <= data_ID_i;
      end
      CS <= NS;
    end
  end


endmodule
