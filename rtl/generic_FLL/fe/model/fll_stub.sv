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

endmodule
