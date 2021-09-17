module core_v_mcu_private_ram #(
    parameter ADDR_WIDTH = 12
) (
    input clk_i,
    input rst_ni,
    input csn_i,
    input [3:0] be_i,
    input wen_i,
    input [ADDR_WIDTH-1:0] addr_i,
    input [31:0] wdata_i,
    output [31:0] rdata_o
);


  generic_memory #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(32)
  ) u0 (
      .CLK  (clk_i),
      .INITN(1'b1),
      .CEN  (csn_i),
      .BEN  (~be_i),
      .WEN  (wen_i),
      .A    (addr_i),  //Convert from byte to word addressing
      .D    (wdata_i),
      .Q    (rdata_o)
  );

endmodule  // core_v_mcu_private_ram

module core_v_mcu_interleaved_ram #(
    parameter ADDR_WIDTH = 12
) (
    input clk_i,
    input rst_ni,
    input csn_i,
    input [3:0] be_i,
    input wen_i,
    input [ADDR_WIDTH-1:0] addr_i,
    input [31:0] wdata_i,
    output [31:0] rdata_o
);

  generic_memory #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(32)
  ) u0 (
      .CLK  (clk_i),
      .INITN(1'b1),
      .CEN  (csn_i),
      .BEN  (~be_i),
      .WEN  (wen_i),
      .A    (addr_i),  //Convert from byte to word addressing
      .D    (wdata_i),
      .Q    (rdata_o)
  );

endmodule
