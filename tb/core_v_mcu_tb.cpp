// Copyright 2022 OpenHW Group
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

#include "verilated.h"
#include "verilated_fst_c.h"
#include "Vcore_v_mcu_testharness.h"
#include "Vcore_v_mcu_testharness__Syms.h"

#include <stdlib.h>
#include <iostream>


vluint64_t sim_time = 0;


std::string getCmdOption(int argc, char* argv[], const std::string& option)
{
    std::string cmd;
     for( int i = 0; i < argc; ++i)
     {
          std::string arg = argv[i];
          size_t arg_size = arg.length();
          size_t option_size = option.length();

          if(arg.find(option)==0){
            cmd = arg.substr(option_size,arg_size-option_size);
          }
     }
     return cmd;
}

void runCycles(unsigned int ncycles, Vcore_v_mcu_testharness *dut, VerilatedFstC *m_trace){
  for(unsigned int i = 0; i < ncycles; i++) {
    dut->ref_clk_i ^= 1;
    dut->eval();
    m_trace->dump(sim_time);
    sim_time++;
  }
}

int main (int argc, char * argv[])
{

  unsigned int SRAM_SIZE;
  std::string firmware, arg_max_sim_time, arg_openocd;
  unsigned int max_sim_time;
  bool use_openocd;
  bool run_all = false;
  int i,j, exit_val;
  svScope scope;

  Verilated::commandArgs(argc, argv);

  // Instantiate the model
  Vcore_v_mcu_testharness *dut = new Vcore_v_mcu_testharness;

  // Open VCD
  Verilated::traceEverOn (true);
  VerilatedFstC *m_trace = new VerilatedFstC;
  dut->trace (m_trace, 99);
  m_trace->open ("waveform.vcd");

  VerilatedContext* contex = dut->contextp();

  contex->scopesDump();

  arg_openocd = getCmdOption(argc, argv, "+openOCD=");
  use_openocd = false;
  if(arg_openocd.empty()){
    std::cout<<"[TESTBENCH]: No OpenOCD is used"<<std::endl;
  } else {
    std::cout<<"[TESTBENCH]: OpenOCD is used"<<std::endl;
    use_openocd = true;
  }

  firmware = getCmdOption(argc, argv, "+firmware=");
  if(firmware.empty()){
    std::cout<<"[TESTBENCH]: No firmware  specified"<<std::endl;
  } else {
    std::cout<<"[TESTBENCH]: loading firmware  "<<firmware<<std::endl;
  }

  arg_max_sim_time = getCmdOption(argc, argv, "+max_sim_time=");
  max_sim_time     = 0;
  if(arg_max_sim_time.empty()){
    std::cout<<"[TESTBENCH]: No Max time specified"<<std::endl;
    run_all = true;
  } else {
    max_sim_time = stoi(arg_max_sim_time);
    std::cout<<"[TESTBENCH]: Max Times is  "<<max_sim_time<<std::endl;
  }
/*
  svSetScope(svGetScopeFromName("TOP.core_v_mcu_testharness"));
  scope = svGetScope();
  if (!scope) {
    std::cout<<"Warning: svGetScope failed"<< std::endl;
    exit(EXIT_FAILURE);
  }
*/
  dut->ref_clk_i      = 0;
  dut->rstn_i         = 0;
  dut->jtag_tck_i     = 0;
  dut->jtag_tms_i     = 0;
  dut->jtag_trst_i    = 0;
  dut->jtag_tdi_i     = 0;
  dut->bootsel_i      = 1;
  dut->stm_i          = 0;

  dut->eval();
  m_trace->dump(sim_time);
  sim_time++;

  runCycles(20, dut, m_trace);


  dut->rstn_i = 1;
  runCycles(1, dut, m_trace);
  std::cout<<"Reset Released"<< std::endl;

  if(use_openocd==false) {
    //dut->tb_loadHEX(firmware.c_str());

    runCycles(1, dut, m_trace);
    std::cout<<"Memory Loaded"<< std::endl;
  } else {
    std::cout<<"Waiting for GDB"<< std::endl;
  }

  if(run_all==false) {
    runCycles(max_sim_time, dut, m_trace);
  } else {
    while(1) {
      runCycles(500, dut, m_trace);
    }
  }
/*
  if(dut->exit_valid_o==1) {
    std::cout<<"Program Finished with value "<<dut->exit_value_o<<std::endl;
    exit_val = EXIT_SUCCESS;
  } else exit_val = EXIT_FAILURE;
*/
  exit_val = EXIT_SUCCESS;
  m_trace->close();
  delete dut;

  exit(exit_val);

}