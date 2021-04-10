module apb_efpga_hwce #(
    parameter APB_HWCE_ADDR_WIDTH = 7
) (
    // clock and reset
    input logic clk_i,
    input logic rst_ni,
    input logic test_mode_i,

    output logic [                   31:0] apb_hwce_prdata_o,
    output logic                           apb_hwce_ready_o,
    output logic                           apb_hwce_pslverr_o,
    input  logic [APB_HWCE_ADDR_WIDTH-1:0] apb_hwce_addr_i,
    input  logic                           apb_hwce_enable_i,
    input  logic                           apb_hwce_psel_i,
    input  logic [                   31:0] apb_hwce_pwdata_i,
    input  logic                           apb_hwce_pwrite_i
);

  logic       s_is_apb_write;
  logic       s_is_apb_read;
  logic [1:0] do_display;

  assign s_is_apb_write = apb_hwce_psel_i & apb_hwce_enable_i & apb_hwce_pwrite_i;
  assign s_is_apb_read  = apb_hwce_psel_i & apb_hwce_enable_i & ~apb_hwce_pwrite_i;


  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (~rst_ni) begin
      do_display <= 2'b0;
    end else begin
      if (s_is_apb_write) do_display <= 2'b01;
      if (s_is_apb_read) do_display <= 2'b10;
      else do_display <= 2'b00;
    end
  end

  always_comb begin
    unique case (do_display)
      2'b01:   $display("WRITE TO APB eFPGA HWCE",);
      2'b10:   $display("READ FROM APB eFPGA HWCE",);
      default;
    endcase
  end

  assign apb_hwce_ready_o   = 1'b1;
  assign apb_hwce_pslverr_o = 1'b0;
  assign apb_hwce_prdata_o  = 32'h00DA41DE;

endmodule

