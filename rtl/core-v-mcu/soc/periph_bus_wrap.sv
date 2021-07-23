// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


`include "periph_bus_defines.sv"

module periph_bus_wrap #(
    parameter APB_ADDR_WIDTH = 32,
    parameter APB_DATA_WIDTH = 32
) (
    input logic    clk_i,
    input logic    rst_ni,
    APB_BUS.Slave  apb_slave,
    APB_BUS.Master fll_master,
    APB_BUS.Master gpio_master,
    APB_BUS.Master udma_master,
    APB_BUS.Master soc_ctrl_master,
    APB_BUS.Master adv_timer_master,
    APB_BUS.Master soc_evnt_gen_master,
    APB_BUS.Master eu_master,
    APB_BUS.Master mmap_debug_master,
    APB_BUS.Master timer_master,
    APB_BUS.Master hwpe_master,
    APB_BUS.Master fcb_master,
    APB_BUS.Master stdout_master,
    APB_BUS.Master i2cs_master
);

  localparam NB_MASTER = `NB_MASTER;

  logic [NB_MASTER-1:0][APB_ADDR_WIDTH-1:0] s_start_addr;
  logic [NB_MASTER-1:0][APB_ADDR_WIDTH-1:0] s_end_addr;

  APB_BUS #(
      .APB_ADDR_WIDTH(APB_ADDR_WIDTH),
      .APB_DATA_WIDTH(APB_DATA_WIDTH)
  ) s_masters[NB_MASTER-1:0] ();

  APB_BUS #(
      .APB_ADDR_WIDTH(APB_ADDR_WIDTH),
      .APB_DATA_WIDTH(APB_DATA_WIDTH)
  ) s_slave ();

  `APB_ASSIGN_SLAVE(s_slave, apb_slave);

  `APB_ASSIGN_MASTER(s_masters[0], fll_master);
  assign s_start_addr[0] = `FLL_START_ADDR;
  assign s_end_addr[0]   = `FLL_END_ADDR;

  `APB_ASSIGN_MASTER(s_masters[1], gpio_master);
  assign s_start_addr[1] = `GPIO_START_ADDR;
  assign s_end_addr[1]   = `GPIO_END_ADDR;

  `APB_ASSIGN_MASTER(s_masters[2], udma_master);
  assign s_start_addr[2] = `UDMA_START_ADDR;
  assign s_end_addr[2]   = `UDMA_END_ADDR;

  `APB_ASSIGN_MASTER(s_masters[3], soc_ctrl_master);
  assign s_start_addr[3] = `SOC_CTRL_START_ADDR;
  assign s_end_addr[3]   = `SOC_CTRL_END_ADDR;

  `APB_ASSIGN_MASTER(s_masters[4], adv_timer_master);
  assign s_start_addr[4] = `ADV_TIMER_START_ADDR;
  assign s_end_addr[4]   = `ADV_TIMER_END_ADDR;

  `APB_ASSIGN_MASTER(s_masters[5], soc_evnt_gen_master);
  assign s_start_addr[5] = `SOC_EVENT_GEN_START_ADDR;
  assign s_end_addr[5]   = `SOC_EVENT_GEN_END_ADDR;

  `APB_ASSIGN_MASTER(s_masters[6], eu_master);
  assign s_start_addr[6] = `EU_START_ADDR;
  assign s_end_addr[6]   = `EU_END_ADDR;

  `APB_ASSIGN_MASTER(s_masters[7], timer_master);
  assign s_start_addr[7] = `TIMER_START_ADDR;
  assign s_end_addr[7]   = `TIMER_END_ADDR;

  `APB_ASSIGN_MASTER(s_masters[8], hwpe_master);
  assign s_start_addr[8] = `HWPE_START_ADDR;
  assign s_end_addr[8]   = `HWPE_END_ADDR;

  `APB_ASSIGN_MASTER(s_masters[9], stdout_master);
  assign s_start_addr[9] = `STDOUT_START_ADDR;
  assign s_end_addr[9]   = `STDOUT_END_ADDR;

  `APB_ASSIGN_MASTER(s_masters[10], mmap_debug_master);
  assign s_start_addr[10] = `DEBUG_START_ADDR;
  assign s_end_addr[10]   = `DEBUG_END_ADDR;

  `APB_ASSIGN_MASTER(s_masters[11], fcb_master);
  assign s_start_addr[11] = `EFPGA_CONFIG_START_ADDR;
  assign s_end_addr[11]   = `EFPGA_CONFIG_END_ADDR;

  `APB_ASSIGN_MASTER(s_masters[12], i2cs_master);
  assign s_start_addr[12] = `I2CS_START_ADDR;
  assign s_end_addr[12]   = `I2CS_END_ADDR;



  //********************************************************
  //**************** SOC BUS *******************************
  //********************************************************
  apb_node_wrap #(
      .NB_MASTER     (NB_MASTER),
      .APB_ADDR_WIDTH(APB_ADDR_WIDTH),
      .APB_DATA_WIDTH(APB_DATA_WIDTH)
  ) apb_node_wrap_i (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .apb_slave  (s_slave),
      .apb_masters(s_masters),

      .start_addr_i(s_start_addr),
      .end_addr_i  (s_end_addr)
  );

endmodule
