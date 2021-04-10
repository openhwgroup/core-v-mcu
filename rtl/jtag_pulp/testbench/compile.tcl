# This script was generated automatically by bender.
set ROOT "/home/balasr/projects/jtag_pulp"

vlog -incr -sv \
    +acc \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "$ROOT/src/bscell.sv" \
    "$ROOT/src/jtag_axi_wrap.sv" \
    "$ROOT/src/jtag_enable.sv" \
    "$ROOT/src/jtag_enable_synch.sv" \
    "$ROOT/src/jtagreg.sv" \
    "$ROOT/src/jtag_rst_synch.sv" \
    "$ROOT/src/jtag_sync.sv" \
    "$ROOT/src/tap_top.v"

vlog -incr -sv \
    +acc \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "+incdir+$ROOT/testbench" \
    "$ROOT/testbench/tb_jtag.sv"
