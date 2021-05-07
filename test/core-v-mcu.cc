// Copyright 2021 OpenHW Group
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
#include "Vcore_v_mcu.h"
#include "verilated.h"

// Sim time.
int TIME = 0;

double sc_time_stamp() { return TIME * 1e-9; }

int main(int argc, char **argv, char **env) {
  Verilated::commandArgs(argc, argv);
  auto top = std::make_unique<Vcore_v_mcu>();
  bool clk_i = 0, rst_ni = 0;

  while (!Verilated::gotFinish()) {
    clk_i = !clk_i;
    rst_ni = TIME >= 8;
    // TODO: That does not work in Verilator, we need to explicitly expose the
    // pins afaik.
    // top->io[6] = clk_i;
    // top->io[7] = rst_ni;
    // Evaluate the DUT.
    top->eval();
    // Increase global time.
    TIME++;
  }

  exit(0);
}
