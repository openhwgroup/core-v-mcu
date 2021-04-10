// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`define JTAG_PERIOD  1000
`define JTAG_IRLEN 5

task jtag_rst;
  integer halfperiod;
  begin
  halfperiod = `JTAG_PERIOD / 2;
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
  end
endtask

task jtag_hard_rst;
  integer halfperiod;
  begin
  halfperiod = `JTAG_PERIOD / 2;
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
  end
endtask

task jtag_selectir;
  input [`JTAG_IRLEN-1:0] instruction;
  integer halfperiod;
  integer i;
  begin
    halfperiod = `JTAG_PERIOD / 2;
    jtag_tck  = 1'b0;
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
    for (i=0 ; i < `JTAG_IRLEN ; i=i+1)
    begin
      jtag_tck = #halfperiod 1'b1;
      jtag_tck = #halfperiod 1'b0;
      if (i == (`JTAG_IRLEN - 1) )
        jtag_tms = 1'b1;             //exit1IR
      else
        jtag_tms = 1'b0;             //shiftIR
      jtag_tdi = instruction[i];
    end
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
  end
endtask

task jtag_senddr;
  input integer number;
  input [127:0] data;
  input integer display;
  integer halfperiod;
  integer i;
  reg  [127:0] data_out;
  begin
    data_out = 0;
    halfperiod = `JTAG_PERIOD / 2;
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
    if (display == 1)
      $display("Data Captured from register: %0h",data_out);
  end

endtask
