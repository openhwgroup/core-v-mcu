module a2_bootrom #(
    parameter ADDR_WIDTH = 11,
    parameter DATA_WIDTH = 32
) (
    input  logic                  CLK,
    input  logic                  CEN,
    input  logic [ADDR_WIDTH-1:0] A,
    output logic [DATA_WIDTH-1:0] Q
);
  logic [31:0] value[(2**ADDR_WIDTH)-1:0];

  initial begin
    $readmemh("mem_init/boot.mem", value);
  end


  always @(posedge CLK) begin
    Q <= value[A];
  end
endmodule
