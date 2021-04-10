// Copyright 2017-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Author: Florian Zaruba, ETH Zurich
// Date: 12.10.2017
// Description: Clock Domain Crossing AXI with Dual-Clock FIFOs

module axi_cdc #(
    parameter int unsigned AXI_ADDR_WIDTH     = 32,
    parameter int unsigned AXI_DATA_WIDTH     = 64,
    parameter int unsigned AXI_USER_WIDTH     = 6,
    parameter int unsigned AXI_ID_WIDTH       = 6,
    parameter int unsigned AXI_BUFFER_WIDTH   = 8
)(
    input  logic            clk_slave_i,            // Clock Slave
    input  logic            rst_slave_ni,           // Asynchronous reset active low
    AXI_BUS.Slave           axi_slave,              // AXI Slave in
    input  logic            isolate_slave_i,        // Isolate Slave in

    input logic             test_cgbypass_i,

    input  logic            clk_master_i,           // Clock Master
    input  logic            rst_master_ni,          // Reset Master
    AXI_BUS.Master          axi_master,             // AXI Master
    input  logic            isolate_master_i,       // Isolate Master
    input  logic            clock_down_master_i,    // Clock Down
    output logic            incoming_req_master_o   // Incoming request
);

    AXI_BUS_ASYNC  #(
        .AXI_ADDR_WIDTH  ( AXI_ADDR_WIDTH     ),
        .AXI_DATA_WIDTH  ( AXI_DATA_WIDTH     ),
        .AXI_ID_WIDTH    ( AXI_ID_WIDTH       ),
        .AXI_USER_WIDTH  ( AXI_USER_WIDTH     ),
        .BUFFER_WIDTH    ( AXI_BUFFER_WIDTH   )
    ) axi_async();

    // -------------
    // Request Side
    // -------------
    axi_slice_dc_slave_wrap #(
        .AXI_ADDR_WIDTH  ( AXI_ADDR_WIDTH     ),
        .AXI_DATA_WIDTH  ( AXI_DATA_WIDTH     ),
        .AXI_USER_WIDTH  ( AXI_USER_WIDTH     ),
        .AXI_ID_WIDTH    ( AXI_ID_WIDTH       ),
        .BUFFER_WIDTH    ( AXI_BUFFER_WIDTH   )
    ) i_axi_slave (
        .clk_i              ( clk_slave_i     ),
        .rst_ni             ( rst_slave_ni    ),
        .test_cgbypass_i    ( test_cgbypass_i ),
        .isolate_i          ( isolate_slave_i ),
        .axi_slave          ( axi_slave       ),
        .axi_master_async   ( axi_async       )
    );

    // -------------
    // Response Side
    // -------------
    axi_slice_dc_master_wrap #(
        .AXI_ADDR_WIDTH  ( AXI_ADDR_WIDTH     ),
        .AXI_DATA_WIDTH  ( AXI_DATA_WIDTH     ),
        .AXI_USER_WIDTH  ( AXI_USER_WIDTH     ),
        .AXI_ID_WIDTH    ( AXI_ID_WIDTH       ),
        .BUFFER_WIDTH    ( AXI_BUFFER_WIDTH   )
    ) i_axi_master (
        .clk_i              ( clk_master_i          ),
        .rst_ni             ( rst_master_ni         ),
        .test_cgbypass_i    ( test_cgbypass_i       ),
        .isolate_i          ( isolate_master_i      ),
        .clock_down_i       ( clock_down_master_i   ),
        .incoming_req_o     ( incoming_req_master_o ),
        .axi_slave_async    ( axi_async             ),
        .axi_master         ( axi_master            )
    );

endmodule
