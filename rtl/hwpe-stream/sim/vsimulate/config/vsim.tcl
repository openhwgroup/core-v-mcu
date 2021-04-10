#
# Copyright (C) 2017-2018 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

if {[info exists ::env(VSIM_PATH)]} {
    set VSIM_SCRIPTS_PATH $::env(VSIM_PATH)
} {
    set VSIM_SCRIPTS_PATH ./
}

source $VSIM_SCRIPTS_PATH/vsimulate/config/vsim_rtl.tcl

set common_args "\
  $VSIM_RTL_LIBS \
  +nowarnTRAN \
  +nowarnTSCALE \
  +nowarnTFMPC"

set vopt_args "+acc -suppress 2103"

if {[info exists ::env(VOPT_FLOW)]} {

    set vopt_cmd "vopt tb \
  $common_args $vopt_args \
  -o pulp -work work"

    eval $vopt_cmd
    
} {

    set vsim_cmd "vsim -quiet $TB \
  $common_args \
  -t ps \
  -voptargs=\"$vopt_args\" \
  $VSIM_FLAGS"

    # to activate the simulation checker for the RISC-V core
    #set cmd "$cmd -sv_lib ./work/libri5cyv2sim"

    eval $vsim_cmd
    
    # check exit status in tb and quit the simulation accordingly
    proc run_and_exit {} {
        run -all
        quit -code [examine -radix decimal sim:/tb/exit_status]
    }
    
    set StdArithNoWarnings 1
    set NumericStdNoWarnings 1
    run 1ps
    set StdArithNoWarnings 0
    set NumericStdNoWarnings 0
}
