// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`define REG_OUT
module lint_2_apb
#(
    parameter ADDR_WIDTH     = 32,
    parameter DATA_WIDTH     = 32,
    parameter BE_WIDTH       = DATA_WIDTH/8,
    parameter ID_WIDTH       = 10,
    parameter AUX_WIDTH      = 8
)
(
    input  logic                      clk,
    input  logic                      rst_n,

    // Req
    input  logic                          data_req_i,
    input  logic [ADDR_WIDTH-1:0]         data_add_i,
    input  logic                          data_wen_i,
    input  logic [DATA_WIDTH-1:0]         data_wdata_i,
    input  logic [BE_WIDTH-1:0]           data_be_i,
    input  logic [AUX_WIDTH-1:0]          data_aux_i,
    input  logic [ID_WIDTH-1:0]           data_ID_i,
    output logic                          data_gnt_o,

    // Resp
    output logic                          data_r_valid_o,
    output logic [DATA_WIDTH-1:0]         data_r_rdata_o,
    output logic                          data_r_opc_o,
    output logic [AUX_WIDTH-1:0]          data_r_aux_o,
    output logic [ID_WIDTH-1:0]           data_r_ID_o,


    output logic [ADDR_WIDTH-1:0]     master_PADDR,
    output logic [DATA_WIDTH-1:0]     master_PWDATA,
    output logic                      master_PWRITE,
    output logic                      master_PSEL,
    output logic                      master_PENABLE,
    input  logic [DATA_WIDTH-1:0]     master_PRDATA,
    input  logic                      master_PREADY,
    input  logic                      master_PSLVERR
);

   enum logic [1:0] {IDLE, WAIT_PREADY, DISPATCH_RDATA } CS,NS;

   logic                      sample_req_info;
   `ifdef REG_OUT
   logic                      sample_rdata;
   logic                      data_r_valid_NS;
   `endif

   logic [ADDR_WIDTH-1:0]     master_PADDR_Q;
   logic [DATA_WIDTH-1:0]     master_PWDATA_Q;
   logic                      master_PWRITE_Q;

   assign master_PADDR  = master_PADDR_Q ;
   assign master_PWDATA = master_PWDATA_Q;
   assign master_PWRITE = master_PWRITE_Q;

   always_ff @(posedge clk or negedge rst_n)
   begin
      if(~rst_n)
      begin
          CS              <= IDLE;
          data_r_aux_o    <= '0;
          data_r_ID_o     <= '0;
          master_PADDR_Q  <= '0;
          master_PWDATA_Q <= '0;
          master_PWRITE_Q <= '0;
`ifdef REG_OUT
          data_r_rdata_o <= '0;
          data_r_opc_o   <= '0;
          data_r_valid_o <= 1'b0;
`endif
      end
      else
      begin
          CS <= NS;

          if(sample_req_info)
          begin
            data_r_aux_o    <= data_aux_i;
            data_r_ID_o     <= data_ID_i;
            master_PADDR_Q  <= data_add_i;
            master_PWDATA_Q <= data_wdata_i;
            master_PWRITE_Q <= ~data_wen_i;
          end
`ifdef REG_OUT
          if(sample_rdata)
          begin
            data_r_rdata_o <= master_PRDATA;
            data_r_opc_o   <= master_PSLVERR;
          end
          data_r_valid_o   <= data_r_valid_NS;
`endif
      end
   end


   always_comb
   begin
      master_PSEL    = 1'b0;
      master_PENABLE = 1'b0;
      sample_req_info = 1'b0;

      data_gnt_o      = 1'b0;


  `ifdef REG_OUT
          sample_rdata    = 1'b0;
          data_r_valid_NS = 1'b0;
  `else
          data_r_rdata_o =  master_PRDATA;
          data_r_opc_o   =  master_PSLVERR;
          data_r_valid_o = 1'b0;
  `endif



      case (CS)
      IDLE:
      begin
         data_gnt_o = 1'b1;

      `ifdef REG_OUT
         data_r_valid_NS = 1'b0;
      `endif

         if(data_req_i)
         begin
            sample_req_info = 1'b1;
            NS = WAIT_PREADY;
         end
         else
         begin
            NS = IDLE;
         end
      end


      WAIT_PREADY:
      begin
         master_PSEL    = 1'b1;
         master_PENABLE = 1'b1;
        `ifdef REG_OUT
            sample_rdata   = master_PREADY;
            data_r_valid_NS = master_PREADY;
        `else
            data_r_valid_o = master_PREADY;
        `endif


         if (master_PREADY)
         begin
        `ifdef REG_OUT
              NS = DISPATCH_RDATA;
         `else
              NS = IDLE;
         `endif
         end
         else
         begin
           NS = WAIT_PREADY;
         end
      end

      DISPATCH_RDATA:
      begin
        NS = IDLE;
        data_gnt_o = 1'b0;
      end




      default :
      begin
         NS = IDLE;
      end

      endcase

   end




endmodule // lint_2_apb
