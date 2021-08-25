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
   
   localparam  REF_CLK_PERIOD =  763ns; // external reference clock (32KHz)
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
   wire 	       jtag_tck_i;
   wire 	       jtag_tdi_i;
   wire 	       jtag_tdo_o;
   wire 	       jtag_tms_i;
   wire 	       jtag_trst_i;
   wire 	       ref_clk_i;
   wire 	       rstn_i;
   wire 	       bootsel_i;
   wire [`N_IO-1:0]    io_in_i;
   wire [`N_IO-1:0]    io_out_o;
   wire [`N_IO-1:0][`NBIT_PADCFG-1:0] pad_cfg_o;
   wire [`N_IO-1:0] io_oe_o;
   // Local variables
   reg 		    resetn;
   reg 		    bootsel;
   reg 		    uart_clk;
   wire 	    pup_qspi,pdown_qspi ;
      wire [`N_IO-1:0]	    pup;
   assign pup_qspi = 1'b1;
      assign pdown_qspi = 1'b0;
   
   assign bootsel_i = bootsel;   
   assign rstn_i = resetn;
   
   initial uart_clk = 0;
   initial forever #(BAUD_CLK_PERIOD/2) uart_clk=~uart_clk;

   GD25Q128B # (.initfile("cli_sim.txt")) 
   qspi (
	 .sclk(io_out_o[16]),
	 .si(io_out_o[14]),
	 .cs(io_out_o[13]),
	 .wp(pup_qspi),
	 .hold(pup_qspi),
	 .so(io_in_i[15]));
   
   uartdpi #(.BAUD(115200), 
	     .FREQ(BAUD_CLK_FREQ),
	     .NAME("uart0"))
   uart_0 (
	   .clk(uart_clk),
	   .rst (~resetn),
	   .tx(io_in_i[IO_UART0_TX]),
	   .rx(io_out_o[IO_UART0_RX])
	   );
   uartdpi #(.BAUD(115200), 
	     .FREQ(BAUD_CLK_FREQ),
     	     .NAME("uart1"))
   uart_1 (
	   .clk(uart_clk),
	   .rst (~resetn),
	   .tx(io_in_i[IO_UART1_TX]),
	   .rx(io_out_o[IO_UART1_RX])
	   );

   pullup(pup[46]);
   
   assign io_in_i[46] = io_oe_o[46] ? io_out_o[46] : pup[46];
   
	     
   
    // Design Under Test
    core_v_mcu #(
    )
    core_v_mcu_i (
		  .jtag_tck_i(jtag_tck_i),
		  .jtag_tdi_i(jtag_tdi_i),
		  .jtag_tdo_o(jtag_tdo_o),
		  .jtag_tms_i(jtag_tms_i),
		  .jtag_trst_i(jtag_trst_i),
		  .ref_clk_i(ref_clk_i),
		  .rstn_i(rstn_i),
		  .bootsel_i(bootsel_i),
		  .io_in_i(io_in_i),
		  .io_out_o(io_out_o),
		  .pad_cfg_o(pad_cfg_o),
		  .io_oe_o(io_oe_o)
    );

    tb_clk_gen #( .CLK_PERIOD(REF_CLK_PERIOD) ) ref_clk_gen_i (.clk_o(ref_clk_i) );

//    initial begin: finish
//        #(2000000ns) $finish();
//    end

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