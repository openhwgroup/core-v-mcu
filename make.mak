
SCRIPTS=sim/tcl_files/config/vsim_ips.tcl
SCRIPTS+=fpga/core-v-mcu/tcl/ips_src_files.tcl
SCRIPTS+=fpga/core-v-mcu/tcl/rtl_src_files.tcl
SCRIPTS+=fpga/core-v-mcu/tcl/ips_add_files.tcl
SCRIPTS+=fpga/core-v-mcu/tcl/rtl_add_files.tcl
SCRIPTS+=fpga/core-v-mcu/tcl/ips_inc_dirs.tcl

IOSCRIPT=rtl/includes/pulp_soc_defines.sv
IOSCRIPT+=rtl/includes/pulp_peripheral_defines.svh
IOSCRIPT+=rtl/includes/periph_bus_defines.sv
IOSCRIPT+=pin-table.csv
IOSCRIPT+=perdef.json
IOSCRIPT+=fpga/core-v-mcu-nexys/rtl/xilinx_core_v_mcu.v
IOSCRIPT+=fpga/core-v-mcu-nexys/constraints/Nexys-A7-100T-Master.xdc

IOSCRIPT_OUT=rtl/core-v-mcu/top/pad_control.sv
IOSCRIPT_OUT+=rtl/core-v-mcu/top/pad_frame.sv
IOSCRIPT_OUT+=fpga/core-v-mcu-nexys/constraints/core-v-mcu-pin-assigment.xdc
IOSCRIPT_OUT+=core-v-mcu-config.h

all:	scripts ${IOSCRIPT_OUT}

help:
			@echo "help"
			
${SCRIPTS}:
				./generate-scripts
				
${IOSCRIPT_OUT}:	${IOSCRIPT}
				python3 util/ioscript.py\
					--soc-defines rtl/includes/pulp_soc_defines.sv\
					--peripheral-defines rtl/includes/pulp_peripheral_defines.svh\
					--periph-bus-defines rtl/includes/periph_bus_defines.sv\
					--pin-table pin-table.csv\
					--perdef-json perdef.json\
					--pad-control rtl/core-v-mcu/top/pad_control.sv\
					--pad-frame-sv rtl/core-v-mcu/top/pad_frame.sv\
					--xilinx-core-v-mcu-sv fpga/core-v-mcu-nexys/rtl/xilinx_core_v_mcu.v\
					--input-xdc fpga/core-v-mcu-nexys/constraints/Nexys-A7-100T-Master.xdc\
					--output-xdc fpga/core-v-mcu-nexys/constraints/core-v-mcu-pin-assigment.xdc\
					--cvmcu-h core-v-mcu-config.h
					
					
.PHONY:bitstream
bitstream:
				(cd fpga; make nexys rev=nexysA7-100T) 2>&1 | tee vivado.log
