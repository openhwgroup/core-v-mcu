// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

//Dummy register in the APB domain for TEACHING PURPOSES

`define REG_SIGNATURE 1'b0 //BASEADDR+0x00 CONTAINS A READ-ONLY Signature
`define REG_SCRATCH 1'b1 //BASEADDR+0x04 R/W REGISTER AS SCRATCH

module apb_dummy_registers #(
    parameter APB_ADDR_WIDTH = 12  // APB slaves are 4KB by default
) (
    input  logic                      HCLK,
    input  logic                      HRESETn,
    input  logic [APB_ADDR_WIDTH-1:0] PADDR,
    input  logic [              31:0] PWDATA,
    input  logic                      PWRITE,
    input  logic                      PSEL,
    input  logic                      PENABLE,
    output logic [              31:0] PRDATA,
    output logic                      PREADY,
    output logic                      PSLVERR
);


  logic s_apb_write, s_apb_addr;
  logic [31:0] reg_signature;
  logic [31:0] reg_scratch;

  assign s_apb_write = PSEL && PENABLE && PWRITE;

  assign s_apb_addr = PADDR[2];  //check whether it is REG_SIGNATURE or REG_SCRATCH

  assign reg_signature = '0;  //COMPLETE THE EXERCIZE


  /*COMPLETE THE WRITE LOGIC*/

  /*
    // write data
    always_ff @(posedge HCLK, negedge HRESETn)
    begin
      if(~HRESETn) begin
        reg_scratch  <= 1'b0;
      end
      else
      begin
        if (s_apb_write)
        begin
        end
      end
    end
*/

  /*COMPLETE THE READ LOGIC*/

  /*
    // read data
    always_comb
    begin
        PRDATA = '0;
        case (s_apb_addr)
        endcase
    end
*/
  assign PREADY = 1'b1;
  assign PSLVERR = 1'b0;

endmodule
