# Multiply frequency by 256 as there is a clock divider (by 256) after the
# slow_clk_mngr since the MMCMs do not support clocks slower then 4.69 MHz.
set SLOW_CLK_FREQ_MHZ [expr 1000 * 256 / $::env(SLOW_CLK_PERIOD_NS)]

set ipName xilinx_slow_clk_mngr

create_ip -name clk_wiz -vendor xilinx.com -library ip -module_name $ipName

set_property -dict [eval list CONFIG.PRIM_IN_FREQ $::env(BOARD_CLOCK_MHZ) \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {$SLOW_CLK_FREQ_MHZ} \
    CONFIG.USE_SAFE_CLOCK_STARTUP {true} \
    CONFIG.USE_LOCKED {false} \
    CONFIG.RESET_TYPE {ACTIVE_LOW} \
    CONFIG.CLKIN1_JITTER_PS {50.0} \
    CONFIG.FEEDBACK_SOURCE {FDBK_AUTO} \
    CONFIG.RESET_PORT {resetn} \
    ] [get_ips $ipName]
