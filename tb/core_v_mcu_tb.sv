// Copyright 2021 QuickLogic.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`include "../includes/pulp_soc_defines.svh"

// Use pseudo-terminal by default
`ifndef USE_PTY
   `define USE_PTY 1
`endif

module core_v_mcu_tb;
   localparam IO_REF_CLK = 5;
   localparam IO_RESETN = 6;
   localparam IO_BOOTSEL = 45;
   localparam IO_UART0_RX = 8;
   localparam IO_UART0_TX = 7;
   localparam IO_UART1_RX = 9;
   localparam IO_UART1_TX = 10;

   //localparam  REF_CLK_PERIOD =  2.5ns; // Use this for fake PLL pPLL02F.sv
   localparam  REF_CLK_PERIOD =  100ns; // Use this for Perceptia PLL pd_gf22_PLL02_model.v (10 MHz ref)
   localparam  BAUD_CLK_PERIOD = 4ns;
   localparam  BAUD_CLK_FREQ = 1000000000 / 4; //12500000;





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
   reg          ref_clk;
   wire 	    pup_qspi,pdown_qspi ;
   
      wire [`N_IO-1:0]	    pup;
   assign pup_qspi = 1'b1;
      assign pdown_qspi = 1'b0;

   assign bootsel_i = bootsel;
   assign rstn_i = resetn;

   initial uart_clk = 0;
   initial ref_clk = 0;
   initial forever #(BAUD_CLK_PERIOD/2) uart_clk=~uart_clk;
   initial forever #(REF_CLK_PERIOD/2) ref_clk = ~ref_clk;

   GD25Q128B # (.initfile("mem_init/cli.txt"))
   qspi (
	 .sclk(io_out_o[16]),
	 .si(io_out_o[14]),
	 .cs(io_out_o[13]),
	 .wp(pup_qspi),
	 .hold(pup_qspi),
	 .so(io_in_i[15]));

   uartdpi #(.BAUD(115200 * 40),    //SW thinks the peripheral clk is 5MHZ, but per clock is running at 200 MHz in simulation, so 5 * 40 = 200
	     .FREQ(BAUD_CLK_FREQ),
	     .NAME("uart0"),
	     .USEPTY(`USE_PTY))
   uart_0 (
	   .clk(uart_clk),
	   .rst (~resetn),
	   .tx(io_in_i[IO_UART0_TX]),
	   .rx(io_out_o[IO_UART0_RX])
	   );
   uartdpi #(.BAUD(115200 * 2),  //SW thinks the per clk is 5 MHz, but it is really running at 10 MHz in bootloader, hence the multiplication of 2 [ 5 * 2 = 10]
	     .FREQ(BAUD_CLK_FREQ),
     	     .NAME("uart1"),
	     .USEPTY(`USE_PTY))
   uart_1 (
	   .clk(uart_clk),
	   .rst (~resetn),
	   .tx(io_in_i[IO_UART1_TX]),
	   .rx(io_out_o[IO_UART1_RX])
	   );


		//pullup(pup[46]);
		//pullup(pup[45]);
		//pullup(pup[44]);
		//pullup(pup[43]);
		//pullup(pup[42]);
		//pullup(pup[41]);
		//pullup(pup[40]);
		//pullup(pup[39]);
		//pullup(pup[38]);
		//pullup(pup[37]);
		//pullup(pup[36]);
		//pullup(pup[35]);
		//pullup(pup[34]);
		//pullup(pup[33]);
		//pullup(pup[32]);
		//pullup(pup[31]);
		//pullup(pup[30]);
		//pullup(pup[29]);
		//pullup(pup[28]);
		//pullup(pup[27]);
		//pullup(pup[26]);
		//pullup(pup[25]);
		//pullup(pup[24]);
		//pullup(pup[23]);
		//pullup(pup[22]);
		//pullup(pup[21]);
		//pullup(pup[20]);
		//pullup(pup[19]);
		//pullup(pup[18]);
		//pullup(pup[17]);
		//pullup(pup[16]);
		//pullup(pup[15]);
		//pullup(pup[14]);
		//pullup(pup[13]);
		//pullup(pup[12]);
		//pullup(pup[11]);
		//pullup(pup[10]);
		//pullup(pup[9]);
		//pullup(pup[8]);
		//pullup(pup[7]);
		//pullup(pup[6]);
		//pullup(pup[5]);
		//pullup(pup[4]);
		//pullup(pup[3]);
		//pullup(pup[2]);
		//pullup(pup[1]);
		//pullup(pup[0]);


		genvar i;
		generate
		for(i=0; i< `N_IO-1; i=i+1 ) begin
			assign io_in_i[i] = pup[i];
			assign pup[i] = io_oe_o[i] ? io_out_o[i] : 1'bz;
		end

		endgenerate
   		//assign io_in_i[46] = io_oe_o[46] ? io_out_o[46] : pup[46];
/*
		assign io_in_i[46] = pup[46];
		assign pup[46] = io_oe_o[46] ? io_out_o[46] : 1'bz;

		assign io_in_i[45] = io_oe_o[45] ? io_out_o[45] : pup[45];
		assign io_in_i[44] = io_oe_o[44] ? io_out_o[44] : pup[44];
		assign io_in_i[43] = io_oe_o[43] ? io_out_o[43] : pup[43];
		assign io_in_i[42] = io_oe_o[42] ? io_out_o[42] : pup[42];
		assign io_in_i[41] = io_oe_o[41] ? io_out_o[41] : pup[41];
		assign io_in_i[40] = io_oe_o[40] ? io_out_o[40] : pup[40];
		assign io_in_i[39] = io_oe_o[39] ? io_out_o[39] : pup[39];
		assign io_in_i[38] = io_oe_o[38] ? io_out_o[38] : pup[38];
		assign io_in_i[37] = io_oe_o[37] ? io_out_o[37] : pup[37];
		assign io_in_i[36] = io_oe_o[36] ? io_out_o[36] : pup[36];
   		assign io_in_i[35] = io_oe_o[35] ? io_out_o[35] : pup[35];
		assign io_in_i[34] = io_oe_o[34] ? io_out_o[34] : pup[34];
		assign io_in_i[33] = io_oe_o[33] ? io_out_o[33] : pup[33];
		assign io_in_i[32] = io_oe_o[32] ? io_out_o[32] : pup[32];
		assign io_in_i[31] = io_oe_o[31] ? io_out_o[31] : pup[31];
		assign io_in_i[30] = io_oe_o[30] ? io_out_o[30] : pup[30];
		assign io_in_i[29] = io_oe_o[29] ? io_out_o[29] : pup[29];
		assign io_in_i[28] = io_oe_o[28] ? io_out_o[28] : pup[28];
		assign io_in_i[27] = io_oe_o[27] ? io_out_o[27] : pup[27];
		assign io_in_i[26] = io_oe_o[26] ? io_out_o[26] : pup[26];
		assign io_in_i[25] = io_oe_o[25] ? io_out_o[25] : pup[25];
		assign io_in_i[24] = io_oe_o[24] ? io_out_o[24] : pup[24];
		assign io_in_i[23] = io_oe_o[23] ? io_out_o[23] : pup[23];
		assign io_in_i[22] = io_oe_o[22] ? io_out_o[22] : pup[22];
		assign io_in_i[21] = io_oe_o[21] ? io_out_o[21] : pup[21];*/
		//assign io_in_i[20] = io_oe_o[20] ? io_out_o[20] : pup[20];
		//assign io_in_i[19] = io_oe_o[19] ? io_out_o[19] : pup[19];
		//assign io_in_i[18] = io_oe_o[18] ? io_out_o[18] : pup[18];
		//assign io_in_i[17] = io_oe_o[17] ? io_out_o[17] : pup[17];
		//assign io_in_i[16] = io_oe_o[16] ? io_out_o[16] : pup[16];
		//assign io_in_i[15] = io_oe_o[15] ? io_out_o[15] : pup[15];
		//assign io_in_i[14] = io_oe_o[14] ? io_out_o[14] : pup[14];
   		//assign io_in_i[13] = io_oe_o[13] ? io_out_o[13] : pup[13];
		//assign io_in_i[12] = io_oe_o[12] ? io_out_o[12] : pup[12];
		//assign io_in_i[11] = io_oe_o[11] ? io_out_o[11] : pup[11];
		//assign io_in_i[10] = io_oe_o[10] ? io_out_o[10] : pup[10];
		//assign io_in_i[9] = io_oe_o[9] ? io_out_o[9] : pup[9];
		//assign io_in_i[8] = io_oe_o[8] ? io_out_o[8] : pup[8];
		//assign io_in_i[7] = io_oe_o[7] ? io_out_o[7] : pup[7];
		//assign io_in_i[6] = io_oe_o[6] ? io_out_o[6] : pup[6];
		//assign io_in_i[5] = io_oe_o[5] ? io_out_o[5] : pup[5];
		//assign io_in_i[4] = io_oe_o[4] ? io_out_o[4] : pup[4];
		//assign io_in_i[3] = io_oe_o[3] ? io_out_o[3] : pup[3];
		//assign io_in_i[2] = io_oe_o[2] ? io_out_o[2] : pup[2];
		//assign io_in_i[1] = io_oe_o[1] ? io_out_o[1] : pup[1];
		//assign io_in_i[0] = io_oe_o[0] ? io_out_o[0] : pup[0];



    // Design Under Test
    core_v_mcu #(
    )
    core_v_mcu_i (
		  .jtag_tck_i(jtag_tck_i),
		  .jtag_tdi_i(jtag_tdi_i),
		  .jtag_tdo_o(jtag_tdo_o),
		  .jtag_tms_i(jtag_tms_i),
		  .jtag_trst_i(jtag_trst_i),
		  .ref_clk_i(ref_clk),
		  .rstn_i(rstn_i),
		  .bootsel_i(bootsel_i),
      .stm_i(1'b0),
		  .io_in_i(io_in_i),
		  .io_out_o(io_out_o),
		  .pad_cfg_o(pad_cfg_o),
		  .io_oe_o(io_oe_o)
    );


    initial begin: finish
        #(40000000ns);
        $write("\n%m @ %0t: Testbench timeout.  Exiting...\n", $time);
        $finish();
    end


    initial begin:  sys_reset
        $display("asserting reset");
        bootsel = 1'b1;
        resetn = 1'b0;
        resetn = #(4*BAUD_CLK_PERIOD) 1'b1;
       #(5*BAUD_CLK_PERIOD) bootsel = 1'b1;

        $display("releasing reset");
    end

    // testbench driver process
    initial begin: testbench
    end
endmodule : core_v_mcu_tb
