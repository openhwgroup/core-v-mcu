// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


module tb_jtag();

  timeunit 100ns;
  timeprecision 1ns;

  localparam int unsigned JTAG_PERIOD = 1000;
  localparam int unsigned JTAG_IRLEN = 5;

  localparam int unsigned REG1_SIZE = 10;
  localparam int unsigned REG2_SIZE = 11;
  localparam int unsigned REG3_SIZE = 12;

  localparam IDCODE         = 5'b00010;
  localparam REG1           = 5'b00100;
  localparam REG2           = 5'b00101;
  localparam REG3           = 5'b00110;
  localparam REG4           = 5'b00111;
  localparam REG5           = 5'b01000;
  localparam REG6           = 5'b01001;
  localparam BYPASS         = 5'b11111;

  logic clk;
  logic rst_n;

  logic jtag_trst;
  logic jtag_tck;
  logic jtag_tms;
  logic jtag_tdi;

  logic jtag_tdo;

  logic s_tap_shiftdr;
  logic s_tap_updatedr;
  logic s_tap_capturedr;
  logic s_tap_reg1_sel;
  logic s_tap_reg2_sel;
  logic s_tap_reg3_sel;
  logic s_tap_tdo;
  logic s_tap_reg1_tdi;
  logic s_tap_reg2_tdi;
  logic s_tap_reg3_tdi;

  logic s_mode;

  logic [REG1_SIZE-1:0] s_reg1_in;
  logic [REG2_SIZE-1:0] s_reg2_in;
  logic [REG3_SIZE-1:0] s_reg3_in;

  logic [REG1_SIZE-1:0] s_reg1_out;
  logic [REG2_SIZE-1:0] s_reg2_out;
  logic [REG3_SIZE-1:0] s_reg3_out;

  assign s_reg1_in = 'hAB;
  assign s_reg2_in = 'hCD;
  assign s_reg3_in = 'hEF;

  tap_top u_tap (
    // jtag
    .tms_i(jtag_tms),
    .tck_i(jtag_tck),
    .rst_ni(~jtag_trst),
    .td_i(jtag_tdi),
    .td_o(jtag_tdo),
    // tap states
    .shift_dr_o(s_tap_shiftdr),
    .update_dr_o(s_tap_updatedr),
    .capture_dr_o(s_tap_capturedr),
    // select signals for boundary scan or mbist
    .memory_sel_o(s_tap_reg1_sel),
    .fifo_sel_o(s_tap_reg2_sel),
    .confreg_sel_o(s_tap_reg3_sel),
    // tdo signal connected to tdi of sub modules
    .scan_in_o(s_tap_tdo),
    // tdi signals from sub modules
    .memory_out_i(s_tap_reg1_tdi),
    .fifo_out_i(s_tap_reg2_tdi),
    .confreg_out_i(s_tap_reg3_tdi)
  );

  jtagreg #(
    .JTAGREGSIZE(REG1_SIZE),
    .SYNC(0)
  ) i_jtagreg1 (
    .clk_i(jtag_tck),
    .rst_ni(~jtag_trst),
    .enable_i(s_tap_reg1_sel),
    .capture_dr_i(s_tap_capturedr),
    .shift_dr_i(s_tap_shiftdr),
    .update_dr_i(s_tap_updatedr),
    .jtagreg_in_i(s_reg1_in),
    .mode_i(s_mode),
    .scan_in_i(s_tap_tdo),
    .scan_out_o(s_tap_reg1_tdi),
    .jtagreg_out_o(s_reg1_out)
  );

  jtagreg #(
    .JTAGREGSIZE(REG2_SIZE),
    .SYNC(0)
  ) i_jtagreg2 (
    .clk_i(jtag_tck),
    .rst_ni(~jtag_trst),
    .enable_i(s_tap_reg2_sel),

    .capture_dr_i(s_tap_capturedr),
    .shift_dr_i(s_tap_shiftdr),
    .update_dr_i(s_tap_updatedr),
    .jtagreg_in_i(s_reg2_in),
    .mode_i(s_mode),
    .scan_in_i(s_tap_tdo),
    .scan_out_o(s_tap_reg2_tdi),
    .jtagreg_out_o(s_reg2_out)
  );

  jtagreg #(
    .JTAGREGSIZE(REG3_SIZE),
    .SYNC(0)
  ) i_jtagreg3 (
    .clk_i(jtag_tck),
    .rst_ni(~jtag_trst),
    .enable_i(s_tap_reg3_sel),
    .capture_dr_i(s_tap_capturedr),
    .shift_dr_i(s_tap_shiftdr),
    .update_dr_i(s_tap_updatedr),
    .jtagreg_in_i(s_reg3_in),
    .mode_i(s_mode),
    .scan_in_i(s_tap_tdo),
    .scan_out_o(s_tap_reg3_tdi),
    .jtagreg_out_o(s_reg3_out)
  );

  // improve time format
  initial begin: timing_format
    $timeformat(-9, 0, "ns", 9);
  end: timing_format

  // actual test sequence
  initial begin
    logic [127:0] dr_out;
    rst_n = 1;
    clk = 0;
    s_mode = 0;

    jtag_trst = 1'b0;
    jtag_tdi = 1'b0;
    jtag_tms = 1'b0;
    jtag_tck = 1'b0;

    #1   rst_n = 0;
    #100 rst_n = 1;

    jtag_hard_rst();
    jtag_rst();

    #10000 s_mode = 1'b1;
    #10000 s_mode = 1'b0;

    jtag_selectir(REG1);
    jtag_senddr(REG1_SIZE, 'h11, dr_out);
    assert (dr_out === s_reg1_in)
      else
        $error("dr register of tap1 contains: %0h expected: %0h",
        dr_out, s_reg1_in);

    jtag_selectir(REG2);
    jtag_senddr(REG2_SIZE, 'h22, dr_out);
    assert (dr_out === s_reg2_in)
      else
        $error("dr register of tap2 contains: %0h expected: %0h",
        dr_out, s_reg2_in);


    jtag_selectir(REG3);
    jtag_senddr(REG3_SIZE, 'h33, dr_out);
    assert (dr_out === s_reg3_in)
      else
        $error("dr register of tap3 contains: %0h expected: %0h",
        dr_out, s_reg3_in);


    #10000 s_mode = 1'b1;
    #10000 s_mode = 1'b0;

    $stop();
  end

  // generate a clock
  always
    #1 clk = ~clk;


  // jtag commands
  task jtag_rst;
    integer halfperiod;
    begin
      if ($test$plusargs("debug"))
        $display("%t: rst start", $time);
      halfperiod = JTAG_PERIOD / 2;
      jtag_tck = 1'b0;
      jtag_tms = 1'b0;
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_tms = 1'b1;
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_tms = 1'b1;
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_tms = 1'b1;
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_tms = 1'b1;
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_tms = 1'b0;
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_tms = 1'b0;
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_tms = 1'b0;
      jtag_tck = #halfperiod 1'b0;
      if ($test$plusargs("debug"))
        $display("%t: rst done", $time);
    end
  endtask

  task jtag_hard_rst;
    integer halfperiod;
    begin
      if ($test$plusargs("debug"))
        $display("%t: hard rst start", $time);

      halfperiod = JTAG_PERIOD / 2;
      jtag_tck  = 1'b0;
      jtag_trst = 1'b0;
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_trst = 1'b1;
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_trst = 1'b1;
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_trst = 1'b1;
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_trst = 1'b1;
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_trst = 1'b0;
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_trst = 1'b0;
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_trst = 1'b0;
      jtag_tck = #halfperiod 1'b0;
      if ($test$plusargs("debug"))
        $display("%t: hard rst end", $time);

    end
  endtask

  task jtag_selectir (
    input [JTAG_IRLEN-1:0] instruction
  );
    integer                 halfperiod;
    integer                 i;
    begin
      if ($test$plusargs("debug"))
        $display("%t: select ir start, ir=0x%0h", $time, instruction);

      halfperiod = JTAG_PERIOD / 2;
      jtag_tck  = 1'b0; // TODO: buggy?
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_tms = 1'b1;             //selectDR
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_tms = 1'b1;             //selectIR
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_tms = 1'b0;             //captureIR
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_tms = 1'b0;             //shiftIR
      if ($test$plusargs("debug"))
        $display("%t: select ir capture start", $time);
      for (i=0 ; i < JTAG_IRLEN ; i=i+1)
        begin
          jtag_tck = #halfperiod 1'b1;
          jtag_tck = #halfperiod 1'b0;
          if (i == (JTAG_IRLEN - 1) )
            jtag_tms = 1'b1;             //exit1IR
          else
            jtag_tms = 1'b0;             //shiftIR
          jtag_tdi = instruction[i];
        end
      if ($test$plusargs("debug"))
        $display("%t: select ir capture end", $time);
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_tms = 1'b0;             //pauseIR
      jtag_tdi = 1'b0;
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_tms = 1'b1;             //exit2IR
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_tms = 1'b1;             //updateIR
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_tms = 1'b0;             //run-test-idle
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_tms = 1'b0;             //run-test-idle
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_tms = 1'b0;             //run-test-idle

      jtag_tck = #halfperiod 1'b0;
      if ($test$plusargs("debug"))
        $display("%t: select ir end", $time);

    end
  endtask

  task jtag_senddr (
    input integer number,
    input [127:0] data,
    output [127:0] dr_out
  );
    integer       halfperiod;
    integer       i;
    logic [127:0] data_out;
    begin
      if ($test$plusargs("debug"))
        $display("%t: select dr start, dr=0x%0h", $time, data);

      data_out = 0;
      halfperiod = JTAG_PERIOD / 2;
      jtag_tck  = 1'b0;
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_tms = 1'b1;             //selectDR
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_tms = 1'b0;             //captureDR
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_tms = 1'b0;             //shiftNR
      for (i=0 ; i < number ; i=i+1)
        begin
          jtag_tck = #halfperiod 1'b1;
          if (i > 0)
            data_out[i-1] = jtag_tdo;
          jtag_tck = #halfperiod 1'b0;
          if (i == (number - 1) )
            jtag_tms = 1'b1;             //exit1DR
          else
            jtag_tms = 1'b0;             //shiftDR
          jtag_tdi = data[i];
        end
      jtag_tck = #halfperiod 1'b1;
      data_out[number-1] = jtag_tdo;
      jtag_tck = #halfperiod 1'b0;
      jtag_tms = 1'b0;             //pauseDR
      jtag_tdi = 1'b0;
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_tms = 1'b1;             //exit2DR
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_tms = 1'b1;             //updateDR
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_tms = 1'b0;             //run-test-idle
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_tms = 1'b0;             //run-test-idle
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      jtag_tms = 1'b0;             //run-test-idle

      jtag_tck = #halfperiod 1'b0;
      dr_out = data_out;
      if ($test$plusargs("debug"))
        $display("%t: data captured from register: 0x%0h", $time, data_out);
    end

  endtask

endmodule
