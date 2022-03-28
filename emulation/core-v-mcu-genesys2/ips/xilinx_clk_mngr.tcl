# Copyright 2021 OpenHW Group
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
set ipName xilinx_clk_mngr

set FC_CLK_FREQ_MHZ [expr 1000 / $::env(FC_CLK_PERIOD_NS)]
set PER_CLK_FREQ_MHZ [expr 1000 / $::env(PER_CLK_PERIOD_NS)]
set FPGA_CLK_FREQ_MHZ [expr 1000 / $::env(FPGA_CLK_PERIOD_NS)]

create_ip -name clk_wiz -vendor xilinx.com -library ip -module_name $ipName

set_property -dict [eval list CONFIG.PRIM_IN_FREQ $::env(BOARD_CLOCK_MHZ) \
    CONFIG.NUM_OUT_CLKS {3} \
    CONFIG.CLKOUT2_USED {true} \
    CONFIG.CLKOUT3_USED {true} \
    CONFIG.RESET_TYPE {ACTIVE_LOW} \
    CONFIG.RESET_PORT {resetn} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {$FC_CLK_FREQ_MHZ} \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {$PER_CLK_FREQ_MHZ} \
    CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {$FPGA_CLK_FREQ_MHZ} \
    CONFIG.CLKIN1_JITTER_PS {50.0} \
    ] [get_ips $ipName]
