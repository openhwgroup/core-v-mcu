`define REG_SETGPIO 12'h000
`define REG_CLRGPIO 12'h004
`define REG_TOGGPIO 12'h008

`define REG_PIN0 12'h010
`define REG_PIN1 12'h014
`define REG_PIN2 12'h018
`define REG_PIN3 12'h01C

`define REG_OUT0 12'h020
`define REG_OUT1 12'h024
`define REG_OUT2 12'h028
`define REG_OUT3 12'h02C


`define REG_SETSEL 12'h030
`define REG_RDSTAT 12'h034
`define REG_SETDIR 12'h038
`define REG_SETINT 12'h03C

module apb_gpiov2 #(
    parameter int unsigned NrGPIO = 32,
    parameter APB_ADDR_WIDTH = 12
) (
    input logic HCLK,
    input logic HRESETn,
    input logic dft_cg_enable_i,

    input  logic [APB_ADDR_WIDTH-1:0] PADDR,
    input  logic [              31:0] PWDATA,
    input  logic                      PWRITE,
    input  logic                      PSEL,
    input  logic                      PENABLE,
    output logic [              31:0] PRDATA,
    output logic                      PREADY,
    output logic                      PSLVERR,

    input  logic [NrGPIO-1:0] gpio_in,
    output logic [NrGPIO-1:0] gpio_in_sync,
    output logic [NrGPIO-1:0] gpio_out,
    output logic [NrGPIO-1:0] gpio_dir,
    output logic [NrGPIO-1:0] interrupt
);

  localparam NG_BITS = $clog2(NrGPIO) - 1;

  logic [  NG_BITS:0]      r_gpio_select;

  logic [NrGPIO-1:0]      r_gpio_inten;
  logic [NrGPIO-1:0][2:0] r_gpio_inttype;

  logic [127:0]           r_gpio_out;
  logic [NrGPIO-1:0][1:0] r_gpio_dir;

  logic [NrGPIO-1:0]      r_gpio_sync0;
  logic [NrGPIO-1:0]      r_gpio_sync1;
  logic [127:0]           r_gpio_in;

  logic [NrGPIO-1:0]      r_gpio_rise;
  logic [NrGPIO-1:0]      r_gpio_fall;
  logic [NrGPIO-1:0]      s_is_int_rise;
  logic [NrGPIO-1:0]      s_is_int_fall;
  logic [NrGPIO-1:0]      s_is_int_low;
  logic [NrGPIO-1:0]      s_is_int_hi;

  genvar i;

  assign gpio_in_sync = r_gpio_in[NrGPIO-1:0];
  assign PREADY = 1'b1;
  assign PSLVERR = 1'b0;

  always_comb begin
    for (int i = 0; i < NrGPIO; i++) begin
      s_is_int_fall[i] = r_gpio_inttype[i][0] & r_gpio_fall[i];  // inttype[0] == 1 ->  fall
      s_is_int_rise[i] = r_gpio_inttype[i][1] & r_gpio_rise[i];  // inttype[1] == 1 ->  rise
      s_is_int_low[i] =   (r_gpio_inttype[i] == 2'b00) & ~r_gpio_inttype[2] & ~r_gpio_out[NrGPIO:0]; // active low int
      s_is_int_hi[i] =   (r_gpio_inttype[i] == 2'b00) & r_gpio_inttype[2] & r_gpio_out[NrGPIO:0];    // active hi int
      interrupt[i] = r_gpio_inten[i] & (s_is_int_fall[i] | s_is_int_rise[i] |
					     s_is_int_low[i] | s_is_int_hi[i]);

      gpio_out[i] = r_gpio_dir[i][0] & r_gpio_out[i];
      gpio_dir[i] = r_gpio_dir[i][1] ? ~r_gpio_out[i] : r_gpio_dir[i][0];  // Open Drain

    end
  end

  always_ff @(posedge HCLK, negedge HRESETn) begin
    if (~HRESETn) begin
      r_gpio_dir <= '0;
      r_gpio_inttype <= '0;
      r_gpio_select <= '0;
    end else begin
      PRDATA <= 32'h0;
      if (PSEL && PENABLE) begin  //APB WRITE
        if (PWRITE) begin
          case (PADDR[11:0])
            `REG_SETSEL: begin
              r_gpio_select <= PWDATA[NG_BITS:0];
            end
            `REG_SETDIR: begin
              r_gpio_dir[PWDATA[NG_BITS:0]] <= PWDATA[25:24];
              r_gpio_select <= PWDATA[NG_BITS:0];
            end
            `REG_SETINT: begin
              r_gpio_inttype[PWDATA[NG_BITS:0]] <= PWDATA[19:17];
              r_gpio_inten[PWDATA[NG_BITS:0]] <= PWDATA[16];
              r_gpio_select <= PWDATA[NG_BITS:0];
            end
            `REG_SETGPIO: begin
              r_gpio_out[PWDATA[NG_BITS:0]] <= 1;
              r_gpio_select <= PWDATA[NG_BITS:0];
            end
            `REG_CLRGPIO: begin
              r_gpio_out[PWDATA[NG_BITS:0]] <= 0;
              r_gpio_select <= PWDATA[NG_BITS:0];
            end
            `REG_TOGGPIO: begin
              r_gpio_out[PWDATA[NG_BITS:0]] <= ~r_gpio_out[PWDATA[NG_BITS:0]];
              r_gpio_select <= PWDATA[NG_BITS:0];
            end
            `REG_OUT0: begin
              r_gpio_out[31:0] <= PWDATA[31:0];
            end
            `REG_OUT1: begin
              r_gpio_out[63:32] <= PWDATA[31:0];
            end
            `REG_OUT2: begin
              r_gpio_out[95:64] <= PWDATA[31:0];
            end
            `REG_OUT3: begin
              r_gpio_out[127:96] <= PWDATA[31:0];
            end
          endcase  // case (PADDR[6:2])
        end else begin  // APB READ
          case (PADDR[11:0])
            `REG_RDSTAT: begin
              PRDATA[26:24] <= r_gpio_dir[r_gpio_select];
              PRDATA[19:16] <= r_gpio_inttype[r_gpio_select];
              PRDATA[12] <= r_gpio_in[r_gpio_select];
              PRDATA[8] <= r_gpio_out[r_gpio_select];
              PRDATA[NG_BITS:0] <= r_gpio_select;
            end
            `REG_OUT0: begin
              PRDATA[31:0] <= r_gpio_out[31:0];
            end
            `REG_OUT1: begin
              PRDATA[31:0] <= r_gpio_out[63:32];
            end
            `REG_OUT2: begin
              PRDATA[31:0] <= r_gpio_out[95:64];
            end
            `REG_OUT3: begin
              PRDATA[31:0] <= r_gpio_out[127:96];
            end
            `REG_PIN0: begin
              PRDATA[31:0] <= r_gpio_in[31:0];
            end
            `REG_PIN1: begin
              PRDATA[31:0] <= r_gpio_in[63:32];
            end
            `REG_PIN2: begin
              PRDATA[31:0] <= r_gpio_in[95:64];
            end
            `REG_PIN3: begin
              PRDATA[31:0] <= r_gpio_in[127:96];
            end
          endcase  // case (PADDR[6:2])
        end  // else: !if(PWRITE)
      end  // if (PSEL && PENABLE)
      r_gpio_out[127:NrGPIO] <= '0;
    end  // else: !if(~HRESETn)
  end

  always_ff @(posedge HCLK or negedge HRESETn) begin
    if (~HRESETn) begin
      r_gpio_in <= '0;
      r_gpio_sync0 <= '0;
      r_gpio_sync1 <= '0;
    end else begin
      r_gpio_sync0 <= gpio_in;
      r_gpio_sync1 <= r_gpio_sync0;
      r_gpio_in[127:NrGPIO] <= '0;
      r_gpio_in[NrGPIO-1:0] <= r_gpio_sync1;
      r_gpio_rise  <=  r_gpio_sync1 & ~r_gpio_in;
      r_gpio_fall  <= ~r_gpio_sync1 &  r_gpio_in;
    end
  end  // always_ff @ (posedge HCLK or negedge HRESETn)


endmodule
