# Copyright 2021 OpenHW Group
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1



all:	${IOSCRIPT_OUT} docs sw

help:
			@echo "all:            generate build scripts, custom build files, doc and sw header files"
			@echo "bitstream:      generate nexysA7-100T.bit file for emulation"
			@echo "lint:           run Verilator lint check"
			@echo "doc:            generate documentation"
			@echo "sw:             generate C header files (in ./sw)"
			@echo "nexys-emul:     generate bitstream for Nexys-A7-100T emulation)"

clean:
				(cd docs; make clean)
				(cd sw; make clean)

sim:
				(export PYTHONPATH=~/fusesoc:~/edalize:~/edalize/edalize; \
					export MODEL_TECH=/data/mentor/Questa/2017_04_26/release_10_6a/questasim/linux_x86_64/;\
					python3 ~/fusesoc/fusesoc/main.py --monochrome --cores-root ../..\
				       	run --no-export --target=sim --setup\
				       	--build openhwgroup.org:systems:core-v-mcu-sim)

run-sim:
				(export PYTHONPATH=~/fusesoc:~/edalize:~/edalize/edalize; \
					export MODEL_TECH=/data/mentor/Questa/2017_04_26/release_10_6a/questasim/linux_x86_64/;\
					cd build/openhwgroup.org_systems_core-v-mcu-sim_0/sim-modelsim;\
					make run) 2>&1 | tee run-sim.log