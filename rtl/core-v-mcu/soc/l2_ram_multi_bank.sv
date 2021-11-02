// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

`include "soc_mem_map.svh"

module l2_ram_multi_bank #(
    parameter NB_BANKS = 4
) (
    input logic               clk_i,
    input logic               rst_ni,
    input logic               init_ni,
    input logic               test_mode_i,
          XBAR_TCDM_BUS.Slave mem_slave    [NB_BANKS],
          XBAR_TCDM_BUS.Slave mem_pri_slave[       2]
);
  // Don't forget to adjust the SRAM macros and the FPGA settings if you change the banksizes
  localparam int unsigned BANK_SIZE_INTL_SRAM = 32768;  //Number of 32-bit words
  localparam int unsigned BANK_SIZE_PRI0 = 8192;  //Number of 32-bit words
  localparam int unsigned BANK_SIZE_PRI1 = 8192;  //Number of 32-bit words

  //Derived parameters
  localparam int unsigned INTL_MEM_ADDR_WIDTH = $clog2(BANK_SIZE_INTL_SRAM);
  localparam int unsigned PRI0_MEM_ADDR_WIDTH = $clog2(BANK_SIZE_PRI0);
  localparam int unsigned PRI1_MEM_ADDR_WIDTH = $clog2(BANK_SIZE_PRI1);

  //Used in testbenches



  //INTERLEAVED Memory
  logic [31:0] interleaved_addresses[NB_BANKS];
  for (genvar i = 0; i < NB_BANKS; i++) begin : CUTS
    //Perform TCDM handshaking for constant 1 cycle latency
    assign mem_slave[i].gnt   = mem_slave[i].req;
    assign mem_slave[i].r_opc = 1'b0;
    always_ff @(posedge clk_i, negedge rst_ni) begin
      if (!rst_ni) begin
        mem_slave[i].r_valid <= 1'b0;
      end else begin
        mem_slave[i].r_valid <= mem_slave[i].req;
      end
    end
    //Remove Address offset
    assign interleaved_addresses[i] = mem_slave[i].add - `SOC_MEM_MAP_TCDM_START_ADDR;

    core_v_mcu_interleaved_ram #(
        .ADDR_WIDTH(INTL_MEM_ADDR_WIDTH)
    ) bank_i (
        .clk_i,
        .rst_ni,
        .csn_i(~mem_slave[i].req),
        .wen_i(mem_slave[i].wen),
        .be_i(mem_slave[i].be),
        .addr_i(interleaved_addresses[i][INTL_MEM_ADDR_WIDTH-1+2+$clog2(
            NB_BANKS
        ):2+$clog2(
            NB_BANKS
        )]),  // Remove LSBs for byte addressing (2 bits)
        // and bank selection (log2(NB_BANKS) bits)
        .wdata_i(mem_slave[i].wdata),
        .rdata_o(mem_slave[i].r_rdata)
    );

  end

  // PRIVATE BANK0
  //Perform TCDM handshaking for constant 1 cycle latency
  assign mem_pri_slave[0].gnt   = mem_pri_slave[0].req;
  assign mem_pri_slave[0].r_opc = 1'b0;
  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
      mem_pri_slave[0].r_valid <= 1'b0;
    end else begin
      mem_pri_slave[0].r_valid <= mem_pri_slave[0].req;
    end
  end
  //Remove Address offset
  logic [31:0] pri0_address;
  assign pri0_address = mem_pri_slave[0].add - `SOC_MEM_MAP_PRIVATE_BANK0_START_ADDR;

  core_v_mcu_private_ram #(
      .ADDR_WIDTH(PRI0_MEM_ADDR_WIDTH)
  ) bank_sram_pri0_i (
      .clk_i,
      .rst_ni,
      .csn_i  (~mem_pri_slave[0].req),
      .wen_i  (mem_pri_slave[0].wen),
      .be_i   (mem_pri_slave[0].be),
      .addr_i (pri0_address[PRI0_MEM_ADDR_WIDTH+1:2]),  //Convert from byte to word addressing
      .wdata_i(mem_pri_slave[0].wdata),
      .rdata_o(mem_pri_slave[0].r_rdata)
  );



  // PRIVATE BANK1
  //Perform TCDM handshaking for constant 1 cycle latency
  assign mem_pri_slave[1].gnt   = mem_pri_slave[1].req;
  assign mem_pri_slave[1].r_opc = 1'b0;
  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
      mem_pri_slave[1].r_valid <= 1'b0;
    end else begin
      mem_pri_slave[1].r_valid <= mem_pri_slave[1].req;
    end
  end
  //Remove Address offset
  logic [31:0] pri1_address;
  assign pri1_address = mem_pri_slave[1].add - `SOC_MEM_MAP_PRIVATE_BANK1_START_ADDR;

  core_v_mcu_private_ram #(
      .ADDR_WIDTH(PRI1_MEM_ADDR_WIDTH)
  ) bank_sram_pri1_i (
      .clk_i,
      .rst_ni,
      .csn_i  (~mem_pri_slave[1].req),
      .wen_i  (mem_pri_slave[1].wen),
      .be_i   (mem_pri_slave[1].be),
      .addr_i (pri1_address[PRI1_MEM_ADDR_WIDTH+1:2]),  //Convert from byte to word addressing
      .wdata_i(mem_pri_slave[1].wdata),
      .rdata_o(mem_pri_slave[1].r_rdata)
  );



endmodule  // l2_ram_multi_bank
