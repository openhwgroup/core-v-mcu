// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`include "adbg_defines.v"


// Top module
module adbg_lintonly_top
#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 64,
    parameter AUX_WIDTH = 6
)
(
        // JTAG signals
        input  logic           tck_i,
        input  logic           tdi_i,
        output logic           tdo_o,
        input  logic           trstn_i,

        // TAP states
        input  logic                   shift_dr_i,
        input  logic                   pause_dr_i,
        input  logic                   update_dr_i,
        input  logic                   capture_dr_i,

        // Instructions
        input  logic                       debug_select_i,

        input  logic                        clk_i,
        input  logic                        rstn_i,

    output logic                        lint_req_o,
    output logic   [ADDR_WIDTH-1:0]     lint_add_o,
    output logic                        lint_wen_o,
    output logic   [DATA_WIDTH-1:0]     lint_wdata_o,
    output logic [DATA_WIDTH/8-1:0]     lint_be_o,
    output logic    [AUX_WIDTH-1:0]     lint_aux_o,
    input  logic                        lint_gnt_i,
    input  logic                        lint_r_aux_i,
    input  logic                        lint_r_valid_i,
    input  logic   [DATA_WIDTH-1:0]     lint_r_rdata_i,
    input  logic                        lint_r_opc_i
    );


   wire                tdo_axi;
   wire                tdo_cpu;

   // Registers
   reg [`DBG_TOP_MODULE_DATA_LEN-1:0] input_shift_reg;  // 1 bit sel/cmd, 4 bit opcode, 32 bit address, 16 bit length = 53 bits
   reg                          [4:0] module_id_reg;    // Module selection register


   // Control signals
   wire               select_cmd;      // True when the command (registered at Update_DR) is for top level/module selection
   wire         [4:0] module_id_in;    // The part of the input_shift_register to be used as the module select data
   reg          [1:0] module_selects;  // Select signals for the individual modules, number of modules = 2(AXI and CPU)
   wire               select_inhibit;  // OR of inhibit signals from sub-modules, prevents latching of a new module ID
   wire         [1:0] module_inhibit;  // signals to allow submodules to prevent top level from latching new module ID

    integer j;

   ///////////////////////////////////////
   // Combinatorial assignments

    assign select_cmd   = input_shift_reg[`DBG_TOP_MODULE_DATA_LEN-1];
    assign module_id_in = input_shift_reg[`DBG_TOP_MODULE_DATA_LEN-2:`DBG_TOP_MODULE_DATA_LEN-6];

//////////////////////////////////////////////////////////
// Module select register and select signals
//////////////////////////////////////////////////////////

    always @ (posedge tck_i or negedge trstn_i)
    begin
        if (~trstn_i)
            module_id_reg <= 5'h0;
        else if(debug_select_i && select_cmd && update_dr_i && !select_inhibit)       // Chain select
            module_id_reg <= module_id_in;
    end

    always_comb
    begin
  		if ( module_id_reg == 0 )
            module_selects = 2'b01;
        else
            module_selects = 2'b10;
    end
//////////////////////////////////////////////////////////


///////////////////////////////////////////////
// Data input shift register
///////////////////////////////////////////////

always @ (posedge tck_i or negedge trstn_i)
begin
  if (~trstn_i)
    input_shift_reg <= 'h0;
  else if(debug_select_i && shift_dr_i)
    input_shift_reg <= {tdi_i, input_shift_reg[`DBG_TOP_MODULE_DATA_LEN-1:1]};
end
///////////////////////////////////////////////


//////////////////////////////////////////////
// Debug module instantiations

// Connecting LINT module
    adbg_lint_module #(
       .ADDR_WIDTH(ADDR_WIDTH),
       .DATA_WIDTH(DATA_WIDTH),
       .AUX_WIDTH(AUX_WIDTH)
    ) i_dbg_lint (
        // JTAG signals
        .tck_i            (tck_i),
        .module_tdo_o     (tdo_axi),
        .tdi_i            (tdi_i),

        // TAP states
        .capture_dr_i     (capture_dr_i),
        .shift_dr_i       (shift_dr_i),
        .update_dr_i      (update_dr_i),

        .data_register_i  (input_shift_reg),
        .module_select_i  (module_selects[0]),
        .top_inhibit_o    (module_inhibit[0]),
        .trstn_i          (trstn_i),

        .clk_i         ( clk_i          ),
        .rstn_i        ( rstn_i         ),

        .lint_req_o    ( lint_req_o     ),
        .lint_add_o    ( lint_add_o     ),
        .lint_wen_o    ( lint_wen_o     ),
        .lint_wdata_o  ( lint_wdata_o   ),
        .lint_be_o     ( lint_be_o      ),
        .lint_aux_o    ( lint_aux_o     ),
        .lint_gnt_i    ( lint_gnt_i     ),
        .lint_r_aux_i  ( lint_r_aux_i   ),
        .lint_r_valid_i( lint_r_valid_i ),
        .lint_r_rdata_i( lint_r_rdata_i ),
        .lint_r_opc_i  ( lint_r_opc_i   )
    );

    assign select_inhibit = | module_inhibit;

    /////////////////////////////////////////////////
    // TDO output MUX

    always @ (module_id_reg or tdo_axi or tdo_cpu)
    begin
        if (module_id_reg == 0)
            tdo_o <= tdo_axi;
        else if (module_id_reg == 1)
            tdo_o <= tdo_cpu;
        else
            tdo_o <= 1'b0;
    end


endmodule
