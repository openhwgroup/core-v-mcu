// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module apb2apbcomp
#(
    parameter APB_DATA_WIDTH = 32,
    parameter APB_ADDR_WIDTH = 32
)
(
    input  logic                       clk_i,
    input  logic                       rst_n,

    input  logic                       apb_pwrite_i,
    input  logic                       apb_psel_i,
    input  logic                       apb_penable_i,
    input  logic                       apb_pready_i,

    input  logic [APB_ADDR_WIDTH-1:0]  apb_paddr_i,
    input  logic [APB_DATA_WIDTH-1:0]  apb_pwdata_i,

    output logic                       apb_pwrite_o,
    output logic                       apb_psel_o,
    output logic                       apb_penable_o,
    output logic [APB_ADDR_WIDTH-1:0]  apb_paddr_o,
    output logic [APB_DATA_WIDTH-1:0]  apb_pwdata_o

);

    enum logic {SETUP, ACCESS} apb_config_state_n, apb_config_state_q;


    always_comb
    begin
      apb_penable_o      = 1'b0;
      apb_psel_o         = apb_psel_i & apb_penable_i;
      apb_config_state_n = apb_config_state_q;

      unique case(apb_config_state_q)

        SETUP:
        begin
          if(apb_psel_i & apb_penable_i)
            apb_config_state_n = ACCESS;
        end

        ACCESS:
        begin
          apb_penable_o = 1'b1;
          if(apb_pready_i)
            apb_config_state_n = SETUP;
        end

      endcase // apb_config_state_q
    end


    always_ff @(posedge clk_i or negedge rst_n) begin : apb_config_state
      if(~rst_n) begin
         apb_config_state_q <= SETUP;
         apb_paddr_o        <= '0;
         apb_pwdata_o       <= '0;
         apb_pwrite_o       <= '0;
      end else begin
         apb_config_state_q <= apb_config_state_n;
         if(apb_psel_i & apb_penable_i & apb_config_state_q == SETUP) begin
            apb_paddr_o        <= apb_paddr_i;
            apb_pwrite_o       <= apb_pwrite_i;
            if(apb_pwrite_i)
                apb_pwdata_o   <= apb_pwdata_i;
         end

      end
    end

endmodule