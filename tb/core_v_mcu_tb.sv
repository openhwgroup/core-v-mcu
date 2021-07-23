// Copyright 2021 QuickLogic.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`include "../includes/pulp_soc_defines.sv"

module core_v_mcu_tb;
    localparam IO_REF_CLK = 6;
    localparam IO_RESETN = 7;
     
    localparam  REF_CLK_PERIOD = 10ns;        // period of the external reference clock (100MHz)
    
    initial begin
      $display("***********************************");
    end

    initial begin: timing_format
        $timeformat(-9, 0, "ns", 9);
    end: timing_format

    // Ports on the core
    wire [`N_IO-1:0]   io_t;

    // Local variables
    reg resetn;

    assign io_t[IO_RESETN] = resetn;

    // Design Under Test
    core_v_mcu #(
        .USE_FPU    ( 1 ),
        .USE_HWPE   ( 1 )
    )
    core_v_mcu_i (
    .io (io_t)
    );

    tb_clk_gen #( .CLK_PERIOD(REF_CLK_PERIOD) ) ref_clk_gen_i (.clk_o(io_t[IO_REF_CLK]) );

    initial begin: finish
        #(2000000ns) $finish();
    end

    initial begin:  sys_reset
        $display("asserting reset");
        resetn = 1'b0;
        resetn = #(4*REF_CLK_PERIOD) 1'b1;
        $display("releasing reset");
    end

    // testbench driver process
    initial begin: testbench
    end
endmodule : core_v_mcu_tb