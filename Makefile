# Copyright 2021,2022 OpenHW Group
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

YML=$(shell find . -name '*.yml' -print)

IOSCRIPT=rtl/includes/pulp_soc_defines.svh
IOSCRIPT+=rtl/includes/pulp_peripheral_defines.svh
IOSCRIPT+=rtl/includes/periph_bus_defines.svh
IOSCRIPT+=nexys-pin-table.csv genesys2-pin-table.csv
IOSCRIPT+=perdef.json
NEXSY_XDC=emulation/core-v-mcu-nexys/constraints/Nexys-A7-100T-Master.xdc
NEXYSA7_BITMAP?=emulation/core_v_mcu_nexys.bit
GENESYS_XDC=emulation/core-v-mcu-nexys/constraints/Genesys2-Master.xdc

IOSCRIPT_OUT=rtl/core-v-mcu/top/pad_control.sv
IOSCRIPT_OUT+=rtl/includes/pulp_peripheral_defines.svh
IOSCRIPT_OUT+=rtl/includes/periph_bus_defines.svh
IOSCRIPT_OUT+=core-v-mcu-config.h
IOSCRIPT_NEXSY=emulation/core-v-mcu-nexys/constraints/core-v-mcu-pin-assignment.xdc
IOSCRIPT_GENESY+=emulation/core-v-mcu-genesys2/constraints/core-v-mcu-pin-assignment.xdc


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
			@echo "genesys-emul:   generate bitstream for Genesys2 emulation)"
			@echo "buildsim:       build for Questa sim"
			@echo "sim:            run Questa sim"
			@echo "build-vivado:   build for Vivado simulation (xelab)"
			@echo "sim-vivado:     run Vivado simulation (xsim)"
			@echo "clean-vivado:   remove generated build files from Vivado build and/or sim"
			@echo "all-vivado:     clean-, build-, sim-vivado (in that order)"
			@echo "clean-xcelium:  delete all files generated for Xcelium simulation"
			@echo "build-xcelium:  build for Xcelium simulation"
			@echo "sim-xcelium:    run Xcelium simulation"
			@echo "all-xcelium:    clean-, build-, sim-xcelium (in that order)"
			@echo "clean:          remove generated doc and sw files"

all:	${IOSCRIPT_OUT} docs sw

src:	${IOSCRIPT_OUT}

clean:
	(cd docs; make clean)
	(cd sw; make clean)
	rm -f tb/uartdpi.so

.PHONY:pseudo-uart
pseudo-uart:
	(cd tb/uartdpi; cc -shared -Bsymbolic -fPIC -o uartdpi.so -lutil uartdpi.c)

all-vivado:	clean-vivado build-vivado sim-vivado

clean-vivado:
	rm -rf build
	rm -rf xelab.* vivado-sim.log

.PHONY: build-vivado
build-vivado:
	fusesoc --cores-root . run --target=sim --tool=xsim --setup \
		--build openhwgroup.org:systems:core-v-mcu | tee vivado-sim.log

.PHONY:sim-vivado
sim-vivado:
	(cd build/openhwgroup.org_systems_core-v-mcu_0/sim-xsim; make run) 2>&1 | tee sim.log

.PHONY: model-lib
model-lib:
	fusesoc --cores-root . run --target=model-lib --setup \
		--build openhwgroup.org:systems:core-v-mcu | tee model-lib.log

lint:
	fusesoc --cores-root . run --target=lint --setup --build openhwgroup.org:systems:core-v-mcu 2>&1 | tee lint.log

.PHONY:sim
sim:
	ln -f  tb/wave.do build/openhwgroup.org_systems_core-v-mcu_0/sim-modelsim/wave.do
	(cd build/openhwgroup.org_systems_core-v-mcu_0/sim-modelsim; make run-gui) 2>&1 | tee sim.log

.PHONY:buildsim
buildsim: pseudo-uart
	fusesoc --cores-root . run --no-export --target=sim --setup --build openhwgroup.org:systems:core-v-mcu 2>&1 | tee buildsim.log

###############################################################################
# XCELIUM targets
#
# buildsim-xcelium is kept for backward compatibility
.PHONY:buildsim-xcelium
buildsim-xcelium: pseudo-uart
	fusesoc --cores-root . run --no-export --target=sim --setup --build --tool=xcelium openhwgroup.org:systems:core-v-mcu 2>&1 | tee buildsim.log

.PHONY: clean-xcelium
clean-xcelium: clean
	rm -rf build

.PHONY: build-xcelium
build-xcelium: pseudo-uart
	fusesoc --cores-root . run --no-export --target=sim --setup --build --tool=xcelium openhwgroup.org:systems:core-v-mcu 2>&1 | tee buildsim.log

.PHONY: sim-xcelium
sim-xcelium: build-xcelium
	cd build/openhwgroup.org_systems_core-v-mcu_0/sim-xcelium && \
	make run

.PHONY: all-xcelium
all-xcelium: clean-xcelium build-xcelium sim-xcelium

###############################################################################

.PHONEY: nexys-emul
nexys-emul:
				@echo "*************************************"
				@echo "*                                   *"
				@echo "* setting up nexys specific files   *"
				@echo "*                                   *"
				@echo "*************************************"
				mkdir -p emulation/core-v-mcu-nexys/rtl
				python3 util/ioscript.py\
					--soc-defines rtl/includes/pulp_soc_defines.svh\
					--peripheral-defines rtl/includes/pulp_peripheral_defines.svh\
					--periph-bus-defines rtl/includes/periph_bus_defines.svh\
					--pin-table nexys-pin-table.csv\
					--perdef-json perdef.json\
					--pad-control rtl/core-v-mcu/top/pad_control.sv\
					--emulation-toplevel core_v_mcu_nexys\
					--xilinx-core-v-mcu-sv emulation/core-v-mcu-nexys/rtl/core_v_mcu_nexys.v\
					--input-xdc emulation/core-v-mcu-nexys/constraints/Nexys-A7-100T-Master.xdc\
					--output-xdc emulation/core-v-mcu-nexys/constraints/core-v-mcu-pin-assignment.xdc
				util/format-verible
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
					export FPGA_CLK_PERIOD_NS=125;\
					export SLOW_CLK_PERIOD_NS=4000;\
					fusesoc --cores-root . run --target=nexys-a7-100t --setup --build openhwgroup.org:systems:core-v-mcu\
				) 2>&1 | tee lint.log
				cp ./build/openhwgroup.org_systems_core-v-mcu_0/nexys-a7-100t-vivado/openhwgroup.org_systems_core-v-mcu_0.runs/impl_1/core_v_mcu_nexys.bit emulation/core_v_mcu_nexys.bit



.PHONEY: genesys-emul
genesys-emul:
				@echo "*************************************"
				@echo "*                                   *"
				@echo "* setting up genesys2 specific files   *"
				@echo "*                                   *"
				@echo "*************************************"
				mkdir -p emulation/core-v-mcu-genesys2/rtl
				python3 util/ioscript.py\
					--soc-defines rtl/includes/pulp_soc_defines.svh\
					--peripheral-defines rtl/includes/pulp_peripheral_defines.svh\
					--periph-bus-defines rtl/includes/periph_bus_defines.svh\
					--pin-table genesys2-pin-table.csv\
					--perdef-json perdef.json\
					--pad-control rtl/core-v-mcu/top/pad_control.sv\
					--xilinx-core-v-mcu-sv emulation/core-v-mcu-genesys2/rtl/core_v_mcu_genesys2.v\
					--emulation-toplevel core_v_mcu_genesys2\
					--input-xdc emulation/core-v-mcu-genesys2/constraints/Genesys2-Master.xdc\
					--output-xdc emulation/core-v-mcu-genesys2/constraints/core-v-mcu-pin-assignment.xdc
				util/format-verible
				@echo "*************************************"
				@echo "*                                   *"
				@echo "* running Vivado                    *"
				@echo "*                                   *"
				@echo "*************************************"
				(\
					export BOARD=genesys2;\
					export BOARD_CLOCK_MHZ=200;\
					export XILINX_PART=xc7k325tffg900-2;\
					export XILINX_BOARD=digilentinc.com:genesys2:1.0;\
					export FC_CLK_PERIOD_NS=50;\
					export PER_CLK_PERIOD_NS=200;\
					export FPGA_CLK_PERIOD_NS=125;\
					export SLOW_CLK_PERIOD_NS=4000;\
					fusesoc --cores-root . run --target=genesys2 --setup --build openhwgroup.org:systems:core-v-mcu\
				) 2>&1 | tee lint.log
				cp ./build/openhwgroup.org_systems_core-v-mcu_0/genesys2-vivado/openhwgroup.org_systems_core-v-mcu_0.runs/impl_1/core_v_mcu_genesys2.bit emulation/core_v_mcu_genesys2.bit


.PHONY:docs
docs:
				(cd docs; make)

.PHONY:sw
sw:
				(cd sw; make)

${IOSCRIPT_OUT}:	${IOSCRIPT}
				python3 util/ioscript.py\
					--soc-defines rtl/includes/pulp_soc_defines.svh\
					--peripheral-defines rtl/includes/pulp_peripheral_defines.svh\
					--periph-bus-defines rtl/includes/periph_bus_defines.svh\
					--perdef-json perdef.json\
					--pad-control rtl/core-v-mcu/top/pad_control.sv\
					--xilinx-core-v-mcu-sv emulation/core-v-mcu-nexys/rtl/core_v_mcu_nexys.v\
					--input-xdc emulation/core-v-mcu-nexys/constraints/Nexys-A7-100T-Master.xdc\
					--output-xdc emulation/core-v-mcu-nexys/constraints/core-v-mcu-pin-assignment.xdc


.PHONY:bitstream
bitstream:	${SCRIPTS} ${IOSCRIPT_OUT}
				(cd fpga; make nexys rev=nexysA7-100T) 2>&1 | tee vivado.log

downloadn:
	vivado -mode batch -source emulation/xilinx/tcl/download.tcl -tclargs\
             $(NEXYSA7_BITMAP) xc7a100t_0

downloadg:
	vivado -mode batch -source emulation/xilinx/tcl/download.tcl -tclargs\
             emulation/core_v_mcu_genesys2.bit xc7k325t_0
