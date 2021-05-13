# Copyright 2021 OpenHW Group
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

YML=$(shell find . -name '*.yml' -print)

IOSCRIPT_IN=rtl/includes/pulp_soc_defines.sv
IOSCRIPT_IN+=rtl/includes/periph_bus_defines.sv
IOSCRIPT_IN+=pin-table.csv
IOSCRIPT_IN+=perdef.json

IOSCRIPT_OUT=rtl/core-v-mcu/top/pad_control.sv
IOSCRIPT_OUT+=rtl/core-v-mcu/top/pad_frame.sv
IOSCRIPT_OUT+=rtl/includes/pulp_peripheral_defines.svh

#Must also change the localparam 'L2_BANK_SIZE' in pulp_soc.sv accordingly
export BANK_SIZE_INTL_SRAM=28672
#Must also change the localparam 'L2_BANK_SIZE_PRI' in pulp_soc.sv accordingly
export PRIVATE_BANK_SIZE=8192


help:
			@echo "all:            generate build scripts, custom build files, doc and sw header files"
			@echo "lint:           run Verilator lint check"
			@echo "doc:            generate documentation"
			@echo "sw:             generate C header files (in ./sw)"
			@echo "nexys-emul:     generate bitstream for Nexys-A7-100T emulation)"
			
all:	${IOSCRIPT_OUT} docs sw
			
clean:
				(cd docs; make clean)
				(cd sw; make clean)
				
lint:
				fusesoc --cores-root . run --target=lint --setup --build openhwgroup.org:systems:core-v-mcu 2>&1 | tee lint.log
			
nexys-emul:		${IOSCRIPT_OUT} emulation/core-v-mcu-nexys/rtl/xilinx_core_v_mcu.v emulation/core-v-mcu-nexys/constraints/core-v-mcu-pin-assignment.xdc
				
				@echo "*************************************"
				@echo "*                                   *"
				@echo "* running Vivado                    *"
				@echo "*                                   *"
				@echo "*************************************"
				(\
					export BOARD=nexys;\
					export BOARD_CLOCK_MHZ=100;\
					export XILINX_PART=xc7a100tcsg324-1;\
					export XILINX_BOARD=digilentinc.com:nexys-a7-100t:1.0;\
					export FC_CLK_PERIOD_NS=100;\
					export PER_CLK_PERIOD_NS=200;\
					export SLOW_CLK_PERIOD_NS=30517;\
					fusesoc --cores-root . run --target=nexys-a7-100t --setup --build openhwgroup.org:systems:core-v-mcu-emul &&\
					echo "copy bitstream to emulation/core-v-mcu-nexys-a7-100t.bit";\
					cp build/openhwgroup.org_systems_core-v-mcu-emul_0/nexys-a7-100t-vivado/openhwgroup.org_systems_core-v-mcu-emul_0.bit emulation/core-v-mcu-nexys-a7-100t.bit\
				) 2>&1 | tee nexys-emul.log
								
emulation/core-v-mcu-nexys/rtl/xilinx_core_v_mcu.v: ${IOSCRIPT_IN}
				@echo "*************************************"
				@echo "*                                   *"
				@echo "* setting up nexys specific files   *"
				@echo "*                                   *"
				@echo "*************************************"
				mkdir -p emulation/core-v-mcu-nexys/rtl
				python3 util/ioscript.py\
					--soc-defines rtl/includes/pulp_soc_defines.sv\
					--peripheral-defines rtl/includes/pulp_peripheral_defines.svh\
					--pin-table pin-table.csv\
					--perdef-json perdef.json\
					--xilinx-core-v-mcu-sv emulation/core-v-mcu-nexys/rtl/xilinx_core_v_mcu.v
				
emulation/core-v-mcu-nexys/constraints/core-v-mcu-pin-assignment.xdc: ${IOSCRIPT_IN}
				@echo "*************************************"
				@echo "*                                   *"
				@echo "* setting up nexys specific files   *"
				@echo "*                                   *"
				@echo "*************************************"
				mkdir -p emulation/core-v-mcu-nexys/rtl
				python3 util/ioscript.py\
					--soc-defines rtl/includes/pulp_soc_defines.sv\
					--peripheral-defines rtl/includes/pulp_peripheral_defines.svh\
					--pin-table pin-table.csv\
					--perdef-json perdef.json\
					--input-xdc emulation/core-v-mcu-nexys/constraints/Nexys-A7-100T-Master.xdc\
					--output-xdc emulation/core-v-mcu-nexys/constraints/core-v-mcu-pin-assignment.xdc
.PHONY:docs
docs:
				(cd docs; make)
				
.PHONY:sw
sw:
				(cd sw; make)
				
${IOSCRIPT_OUT}:	${IOSCRIPT_IN}
				@echo "making $@ because $?"
				python3 util/ioscript.py\
					--soc-defines rtl/includes/pulp_soc_defines.sv\
					--peripheral-defines rtl/includes/pulp_peripheral_defines.svh\
					--periph-bus-defines rtl/includes/periph_bus_defines.sv\
					--pin-table pin-table.csv\
					--perdef-json perdef.json\
					--pad-control rtl/core-v-mcu/top/pad_control.sv\
					--pad-frame-sv rtl/core-v-mcu/top/pad_frame.sv
download:
	vivado -mode batch -source emulation/core-v-mcu-nexys/tcl/download_bitstream.tcl -tclargs\
              emulation/core-v-mcu-nexys-a7-100t.bit
