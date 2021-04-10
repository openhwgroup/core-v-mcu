/*
 * xilinx_pll.sv
 * Francesco Conti <fconti@iis.ee.ethz.ch>
 *
 * Copyright (C) 2018 ETH Zurich, University of Bologna
 * All rights reserved.
 */

module xilinx_pll (
  output logic        clk_o,
  input  logic        ref_clk_i,
  output logic        cfg_lock_o,     
  input  logic        cfg_req_i,    
  output logic        cfg_ack_o,  
  input  logic [1:0]  cfg_add_i,
  input  logic [31:0] cfg_data_i,
  output logic [31:0] cfg_r_data_o,
  input  logic        cfg_wrn_i,
  input  logic        rstn_glob_i,
  input  logic        test_mode_i,
  input  logic        shift_enable_i
);

  // just a stub for now

endmodule /* xilinx_pll */
