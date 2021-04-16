# Copyright 2021 OpenHW Group
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
set ipName xilinx_clk_mngr

set FC_CLK_FREQ_MHZ [expr 1000 / $FC_CLK_PERIOD_NS]
set PER_CLK_FREQ_MHZ [expr 1000 / $PER_CLK_PERIOD_NS]

create_ip -name clk_wiz -vendor xilinx.com -library ip -module_name $ipName

set_property -dict [eval list CONFIG.PRIM_IN_FREQ {200.000} \
    CONFIG.NUM_OUT_CLKS {2} \
    CONFIG.CLKOUT2_USED {true} \
    CONFIG.RESET_TYPE {ACTIVE_LOW} \
    CONFIG.RESET_PORT {resetn} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {$FC_CLK_FREQ_MHZ} \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {$PER_CLK_FREQ_MHZ} \
    CONFIG.CLKIN1_JITTER_PS {50.0} \
    ] [get_ips $ipName]
