// Copyright 2020 OpenHW Group
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

module gf22_FLL (
  output logic FLLCLK,
  input  logic FLLOE,
  input  logic REFCLK,
  output logic LOCK,
  input  logic CFGREQ,
  output logic CFGACK,
  input  logic [1:0] CFGAD,
  input  logic [31:0] CFGD,
  output logic [31:0] CFGQ,
  input  logic CFGWEB,
  input  logic RSTB,
  input  logic PWD,
  input  logic RET,
  input  logic TM,
  input  logic TE,
  input  logic TD,
  output logic TQ,
  input  logic JTD,
  output logic JTQ
);

  assign FLLCLK = REFCLK;

  assign LOCK = '1;
  assign CFGACK = '0;
  assign CFGQ = '0;
  assign TQ = '0;
  assign JTQ = '0;

endmodule
