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
   localparam IO_REF_CLK = 5;
   localparam IO_RESETN = 6;
   localparam IO_BOOTSEL = 45;
   localparam IO_UART0_RX = 8;
   localparam IO_UART0_TX = 7;
   localparam IO_UART1_RX = 9;
   localparam IO_UART1_TX = 10;
   
   localparam  REF_CLK_PERIOD = 30517ns; // external reference clock (32KHz)
   localparam  BAUD_CLK_FREQ = 12500000;
   localparam  BAUD_CLK_PERIOD = 2ns;
   
    
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
    reg 	bootsel;
   reg 		uart_clk;
   
   assign io_t[IO_BOOTSEL] = bootsel;   
   assign io_t[IO_RESETN] = resetn;
   
   initial uart_clk = 0;
   initial forever #(BAUD_CLK_PERIOD/2) uart_clk=~uart_clk;

   GD25Q128B # (.initfile("../../../tb/cli.txt")) qspi (.sclk(io_t[16]),
	     .si(io_t[14]),
	     .cs(io_t[13]),
	     .wp(io_t[39]),
	     .hold(io_t[40]),
	     .so(io_t[15]));
   
   uartdpi #(.BAUD(115200), 
	     .FREQ(BAUD_CLK_FREQ),
	     .NAME("uart0"))
   uart_0 (
	   .clk(uart_clk),
	   .rst (~resetn),
	   .tx(io_t[IO_UART0_TX]),
	   .rx(io_t[IO_UART0_RX])
	   );
   uartdpi #(.BAUD(115200), 
	     .FREQ(BAUD_CLK_FREQ),
     	     .NAME("uart1"))
   uart_1 (
	   .clk(uart_clk),
	   .rst (~resetn),
	   .tx(io_t[IO_UART1_TX]),
	   .rx(io_t[IO_UART1_RX])
	   );
   
	     
   
    // Design Under Test
    core_v_mcu #(
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
        bootsel = 1'b1;
        resetn = 1'b0;
        resetn = #(4*BAUD_CLK_PERIOD) 1'b1;
       #(5*BAUD_CLK_PERIOD) bootsel = 1'b0;
       
        $display("releasing reset");
    end

    // testbench driver process
    initial begin: testbench
    end
endmodule : core_v_mcu_tb