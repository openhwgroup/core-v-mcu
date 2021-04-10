// Copyright 2014-2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

/*
 * Francesco Conti <f.conti@unibo.it>
 */

module register_file_1r_1w_be
#(
    parameter ADDR_WIDTH = 5,
    parameter DATA_WIDTH = 64,
    parameter BLOCK_RAM  = 1,
    parameter NUM_BYTE   = DATA_WIDTH/8
)
(
    input   logic                  clk,
    input   logic                  rst_n,

    input   logic                  ReadEnable,
    input   logic [ADDR_WIDTH-1:0] ReadAddr,
    output  logic [DATA_WIDTH-1:0] ReadData,

    input   logic [ADDR_WIDTH-1:0] WriteAddr,
    input   logic                  WriteEnable,
    input   logic [DATA_WIDTH-1:0] WriteData,
    input   logic [NUM_BYTE-1:0]   WriteBE
);

  localparam N_SCM_REGISTERS = 2**ADDR_WIDTH;
  localparam MEM_TYPE = BLOCK_RAM ? "block" : "distributed";

  logic [NUM_BYTE-1:0] WriteBE_int;
  assign WriteBE_int = WriteEnable ? WriteBE : '0;

  xpm_memory_tdpram # (
    .MEMORY_SIZE        ( N_SCM_REGISTERS ),
    .MEMORY_PRIMITIVE   ( MEM_TYPE        ),
    .MEMORY_INIT_FILE   ( "none"          ), // FIXME
    .MEMORY_INIT_PARAM  ( ""              ),
    .USE_MEM_INIT       ( 1               ),
    .WAKEUP_TIME        ( "disable_sleep" ),
    .MESSAGE_CONTROL    ( 0               ),
    .ECC_MODE           ( "no_ecc"        ),
    .AUTO_SLEEP_TIME    ( 0               ),
    .CLOCKING_MODE      ( "common_clock"  ),
    .WRITE_DATA_WIDTH_A ( DATA_WIDTH      ),
    .READ_DATA_WIDTH_A  ( DATA_WIDTH      ),
    .BYTE_WRITE_WIDTH_A ( 8               ),
    .ADDR_WIDTH_A       ( ADDR_WIDTH-2    ),
    .READ_RESET_VALUE_A ( "0"             ),
    .READ_LATENCY_A     ( 1               ),
    .WRITE_MODE_A       ( "no_change"     ),
    .WRITE_DATA_WIDTH_B ( DATA_WIDTH      ),
    .READ_DATA_WIDTH_B  ( DATA_WIDTH      ),
    .BYTE_WRITE_WIDTH_B ( 8               ),
    .ADDR_WIDTH_B       ( ADDR_WIDTH-2    ),
    .READ_RESET_VALUE_B ("0"              ),
    .READ_LATENCY_B     ( 1               ),
    .WRITE_MODE_B       ( "no_change"     )
  ) i_scm_xilinx (
    .sleep          ( 1'b0                      ),
    .clka           ( clk                       ),
    .rsta           ( 1'b0                      ),
    .ena            ( 1'b1                      ),
    .regcea         ( 1'b1                      ),
    .wea            ( WriteBE_int               ),
    .addra          ( WriteAddr[ADDR_WIDTH-1:2] ),
    .dina           ( WriteData                 ),
    .injectsbiterra ( 1'b0                      ),
    .injectdbiterra ( 1'b0                      ),
    .douta          (                           ),
    .sbiterra       (                           ),
    .dbiterra       (                           ),
    .clkb           ( clk                       ),
    .rstb           ( 1'b0                      ),
    .enb            ( 1'b1                      ),
    .regceb         ( 1'b1                      ),
    .web            ( '0                        ),
    .addrb          ( ReadAddr[ADDR_WIDTH-1:2]  ),
    .dinb           ( '0                        ),
    .injectsbiterrb ( 1'b0                      ),
    .injectdbiterrb ( 1'b0                      ),
    .doutb          ( ReadData                  ),
    .sbiterrb       (                           ),
    .dbiterrb       (                           )
  );

endmodule
