# PULP JTAG TAP
This a JTAG TAP used in the PULP project. Supports
[IPApproX](https://github.com/pulp-platform/IPApproX) and
[bender](https://github.com/fabianschuiki/bender).

## Testbench
There is already a pregenerate `compile.tcl` so you don't need to have bender in
your path.

Call `make build run` to run the testbench. You can pass custom flags to by
modifying `VSIM_FLAGS` and `VLOG_FLAGS`.

