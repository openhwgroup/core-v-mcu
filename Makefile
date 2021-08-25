# Copyright 2021 OpenHW Group
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

YML=$(shell find . -name '*.yml' -print)

IOSCRIPT=rtl/includes/pulp_soc_defines.sv
IOSCRIPT+=rtl/includes/pulp_peripheral_defines.svh
IOSCRIPT+=rtl/includes/periph_bus_defines.svh
IOSCRIPT+=pin-table.csv
IOSCRIPT+=perdef.json
#IOSCRIPT+=emulation/core-v-mcu-nexys/rtl/core_v_mcu_nexys.v
IOSCRIPT+=emulation/core-v-mcu-nexys/constraints/Nexys-A7-100T-Master.xdc

IOSCRIPT_OUT=rtl/core-v-mcu/top/pad_control.sv
#IOSCRIPT_OUT+=rtl/core-v-mcu/top/pad_frame.sv
IOSCRIPT_OUT+=rtl/includes/pulp_peripheral_defines.svh
IOSCRIPT_OUT+=rtl/includes/periph_bus_defines.svh
IOSCRIPT_OUT+=emulation/core-v-mcu-nexys/constraints/core-v-mcu-pin-assignment.xdc
IOSCRIPT_OUT+=core-v-mcu-config.h

#Must also change the localparam 'L2_BANK_SIZE' in pulp_soc.sv accordingly
export INTERLEAVED_BANK_SIZE=28672
#Must also change the localparam 'L2_BANK_SIZE_PRI' in pulp_soc.sv accordingly
export PRIVATE_BANK_SIZE=8192

help:
			@echo "all:            create generated src files, doc and sw header files"
			@echo "src:            create generated src files"
			@echo "lint:           run Verilator lint check"
			@echo "doc:            generate documentation"
			@echo "sw:             generate C header files (in ./sw)"
			@echo "nexys-emul:     generate bitstream for Nexys-A7-100T emulation)"
			@echo "buildsim:       build for Questa sim"
			@echo "sim:            run Questa sim"
			@echo "clean:          remove generated files"

all:	${IOSCRIPT_OUT} docs sw

src:	${IOSCRIPT_OUT}

clean:
	(cd docs; make clean)
	(cd sw; make clean)

lint:
	fusesoc --cores-root . run --target=lint --setup --build openhwgroup.org:systems:core-v-mcu 2>&1 | tee lint.log

.PHONY:sim
sim:
	ln -f  tb/mem_init_files/col0.mem build/openhwgroup.org_systems_core-v-mcu_0/sim-modelsim/core_v_mcu_tb.core_v_mcu_i.i_soc_domain.l2_ram_i.CUTS[0].bank_i
	ln -f  tb/mem_init_files/col1.mem build/openhwgroup.org_systems_core-v-mcu_0/sim-modelsim/core_v_mcu_tb.core_v_mcu_i.i_soc_domain.l2_ram_i.CUTS[1].bank_i
	ln -f  tb/mem_init_files/col2.mem build/openhwgroup.org_systems_core-v-mcu_0/sim-modelsim/core_v_mcu_tb.core_v_mcu_i.i_soc_domain.l2_ram_i.CUTS[2].bank_i
	ln -f  tb/mem_init_files/col3.mem build/openhwgroup.org_systems_core-v-mcu_0/sim-modelsim/core_v_mcu_tb.core_v_mcu_i.i_soc_domain.l2_ram_i.CUTS[3].bank_i
	ln -f  tb/mem_init_files/privateBank0.mem build/openhwgroup.org_systems_core-v-mcu_0/sim-modelsim/core_v_mcu_tb.core_v_mcu_i.i_soc_domain.l2_ram_i.bank_sram_pri0_i
	ln -f  tb/mem_init_files/privateBank1.mem build/openhwgroup.org_systems_core-v-mcu_0/sim-modelsim/core_v_mcu_tb.core_v_mcu_i.i_soc_domain.l2_ram_i.bank_sram_pri1_i
	ln -f  tb/mem_init_files/cli_sim.txt build/openhwgroup.org_systems_core-v-mcu_0/sim-modelsim/cli_sim.txt
	ln -f  tb/wave.do build/openhwgroup.org_systems_core-v-mcu_0/sim-modelsim/wave.do
	(cd build/openhwgroup.org_systems_core-v-mcu_0/sim-modelsim; make run-gui) 2>&1 | tee sim.log

.PHONY:buildsim
buildsim:
	(cd tb/uartdpi; cc -shared -Bsymbolic -fPIC -o uartdpi.so -lutil uartdpi.c)
	fusesoc --cores-root . run --no-export --target=sim --setup --build openhwgroup.org:systems:core-v-mcu 2>&1 | tee buildsim.log



nexys-emul:		${IOSCRIPT_OUT}
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
					--emulation-toplevel core_v_mcu_nexys\
					--xilinx-core-v-mcu-sv emulation/core-v-mcu-nexys/rtl/core_v_mcu_nexys.v\
					--input-xdc emulation/core-v-mcu-nexys/constraints/Nexys-A7-100T-Master.xdc\
					--output-xdc emulation/core-v-mcu-nexys/constraints/core-v-mcu-pin-assignment.xdc
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
					fusesoc --cores-root . run --target=nexys-a7-100t --setup --build openhwgroup.org:systems:core-v-mcu\
				) 2>&1 | tee lint.log
				cp ./build/openhwgroup.org_systems_core-v-mcu_0/nexys-a7-100t-vivado/openhwgroup.org_systems_core-v-mcu_0.runs/impl_1/core_v_mcu_nexys.bit emulation/core_v_mcu_nexys.bit

.PHONY:docs
docs:
				(cd docs; make)

.PHONY:sw
sw:
				(cd sw; make)

${IOSCRIPT_OUT}:	${IOSCRIPT}
				python3 util/ioscript.py\
					--soc-defines rtl/includes/pulp_soc_defines.sv\
					--peripheral-defines rtl/includes/pulp_peripheral_defines.svh\
					--periph-bus-defines rtl/includes/periph_bus_defines.svh\
					--pin-table pin-table.csv\
					--perdef-json perdef.json\
					--pad-control rtl/core-v-mcu/top/pad_control.sv\
					--xilinx-core-v-mcu-sv emulation/core-v-mcu-nexys/rtl/core_v_mcu_nexys.v\
					--input-xdc emulation/core-v-mcu-nexys/constraints/Nexys-A7-100T-Master.xdc\
					--output-xdc emulation/core-v-mcu-nexys/constraints/core-v-mcu-pin-assignment.xdc


.PHONY:bitstream
bitstream:	${SCRIPTS} ${IOSCRIPT_OUT}
				(cd fpga; make nexys rev=nexysA7-100T) 2>&1 | tee vivado.log

download0:
	vivado -mode batch -source emulation/core-v-mcu-nexys/tcl/download_bitstream.tcl -tclargs\
             emulation/core_v_mcu_nexys.bit

download:
	vivado -mode batch -source emulation/core-v-mcu-nexys/tcl/download_bitstream1.tcl -tclargs\
             emulation/core_v_mcu_nexys.bit
				(cd build/openhwgroup.org_systems_core-v-mcu_0/sim-modelsim; make run) 2>&1 | tee sim.log

