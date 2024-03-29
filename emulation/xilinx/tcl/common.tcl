# detect board
if [info exists ::env(BOARD)] {
    set BOARD $::env(BOARD)
} else {
    puts "BOARD is not defined. Please include 'fpga-settings.mk' in your Makefile to setup necessary environment variables."
    exit
}
if [info exists ::env(XILINX_BOARD)] {
    set XILINX_BOARD $::env(XILINX_BOARD)
}
set partNumber $::env(XILINX_PART)

set_property verilog_define FPGA=true [current_fileset]

# sets up Vivado messages in a more sensible way
set_msg_config -id {[Synth 8-689]}          -new_severity "error";            # Port width mismatch: can mean no real connection
set_msg_config -id {[Synth 8-3352]}         -new_severity "critical warning"
set_msg_config -id {[Synth 8-350]}          -new_severity "critical warning"
set_msg_config -id {[Synth 8-2490]}         -new_severity "warning"
set_msg_config -id {[Synth 8-2306]}         -new_severity "info"
set_msg_config -id {[Synth 8-3331]}         -new_severity "critical warning"
set_msg_config -id {[Synth 8-3332]}         -new_severity "info"
set_msg_config -id {[Synth 8-2715]}         -new_severity "error"
set_msg_config -id {[Opt 31-35]}            -new_severity "info"
set_msg_config -id {[Opt 31-32]}            -new_severity "info"
set_msg_config -id {[Shape Builder 18-119]} -new_severity "warning"
set_msg_config -id {[Filemgmt 20-742]}      -new_severity "error"

# Set number of CPUs, default to 4 if system's getconf doesn't work
set CPUS [exec getconf _NPROCESSORS_ONLN]
if { ![info exists CPUS] } {
  set CPUS 4
}
