module efpga_sel_clk_dc_fifo (

    input logic clk0_i,
    input logic clk1_i,
    input logic clk2_i,
    input logic clk3_i,
    input logic clk4_i,
    input logic clk5_i,

    input logic [2:0] sel_clk_i,

    output logic efpga_clk_o
);

  logic clk_mux_01, clk_mux_23, clk_mux_45;
  logic clk_mux_01_23;
  //FLL clock as sel_clk_i[0] = 1, sel_clk_i[1] = 0, sel_clk_i[2] = 0
  pulp_clock_mux2 clk_mux_01_i (
      .clk0_i   (clk0_i),
      .clk1_i   (clk1_i),
      .clk_sel_i(sel_clk_i[0]),
      .clk_o    (clk_mux_01)
  );  //clk1

  pulp_clock_mux2 clk_mux_23_i (
      .clk0_i   (clk2_i),
      .clk1_i   (clk3_i),
      .clk_sel_i(sel_clk_i[0]),
      .clk_o    (clk_mux_23)
  );  //clk3

  pulp_clock_mux2 clk_mux_45_i (
      .clk0_i   (clk4_i),
      .clk1_i   (clk5_i),
      .clk_sel_i(sel_clk_i[0]),
      .clk_o    (clk_mux_45)
  );  //clk5

  pulp_clock_mux2 clk_mux_01_23_i (
      .clk0_i   (clk_mux_01),
      .clk1_i   (clk_mux_23),
      .clk_sel_i(sel_clk_i[1]),
      .clk_o    (clk_mux_01_23)
  );  //clk_mux_01 --> clk1

  pulp_clock_mux2 clk_mux_efpga_clk_i (
      .clk0_i   (clk_mux_01_23),
      .clk1_i   (clk_mux_45),
      .clk_sel_i(sel_clk_i[2]),
      .clk_o    (efpga_clk_o)
  );  //clk_mux_01_23 --> clk1


endmodule  // efpga_sel_clk_dc_fifo
