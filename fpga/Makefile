.DEFAULT_GOAL:=help

all: genesys2 ## Generates the bitstream for all supported boards board.

clean_all: clean_genesys2  ## Removes synthesis output and bitstreams for all boards.

genesys2: ## Generates the bistream for the genesys2 board
	$(MAKE) -C core-v-mcu-genesys2 all
	cp core-v-mcu-genesys2/core-v-mcu-genesys2.runs/impl_1/xilinx_core-v-mcu.bit core_v_mcu_genesys2.bit
	cp core-v-mcu-genesys2/core-v-mcu-genesys2.runs/impl_1/xilinx_core-v-mcu.bin core_v_mcu_genesys2.bin
	@echo "Bitstream generation for genesys2 board finished. The bitstream Configuration Memory File was copied to ./core_v_mcu_genesys2.bit and ./core_v_mcu_genesys2.bin"

clean_genesys2: ## Removes all bitstreams, *.log files and vivado related files (rm -rf vivado*) for the genesys2 board.
	$(MAKE) -C core-v-mcu-genesys2 clean
	rm -f core_v_mcu_genesys2.bit
	rm -f core_v_mcu_genesys2.bin

nexys: ## Generates the bistream for the nexys board. Use make nexys rev=[nexys4|nexys4DDR|nexysA7-50T|nexysA7-100T]
	$(MAKE) -C core-v-mcu-nexys all
	cp core-v-mcu-nexys/core-v-mcu-nexys.runs/impl_1/xilinx_core_v_mcu.bit core_v_mcu_nexys.bit
	cp core-v-mcu-nexys/core-v-mcu-nexys.runs/impl_1/xilinx_core_v_mcu.bin core_v_mcu_nexys.bin
	@echo "Bitstream generation for nexys board finished. The bitstream Configuration Memory File was copied to ./core_v_mcu_nexys.bit and ./core_v_mcu_nexys.bin"

download_nexys:
	$(MAKE) -C core-v-mcu-nexys download

clean_nexys: ## Removes all bitstreams, *.log files and vivado related files (rm -rf vivado*) for the nexys board.
	$(MAKE) -C core-v-mcu-nexys clean
	rm -f core_v_mcu_nexys.bit
	rm -f core_v_mcu_nexys.bin

help: ## Show this help message
	@echo "core-v-mcu on FPGA"
	@echo ""
	@echo "Call make with one of the supported FPGA boards as arguments to generate the bitstream in the corresponding folder. "
	@echo "E.g. 'make genesys2' to generate the bitstream for the genesys2 board in core-v-mcu-genesy2 subdirectory."
	@echo "By default make invokes 'vivado'  to start Xilinx Vivado. This behaviour can be overriden by setting the make variable 'VIVADO'"
	@echo "e.g. make genesys2 VIVADO='vivado-2018.3 vivado' for ETH centos machines."
	@echo ""
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
