.PHONY: build lib clean sim simc mem_init verilator

mkfile_path := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))

VSIM        ?= vsim
VSIM_FLAGS  = -gUSE_SDVT_SPI=0 -gUSE_SDVT_CPI=0 -gBAUDRATE=115200 \
		-gENABLE_DEV_DPI=0 -gLOAD_L2=JTAG -gUSE_SDVT_I2S=0

SVLIB	    =  ../rtl/tb/remote_bitbang/librbs

all: clean lib build opt

# build the bitbang library, needed for simulating a jtag bridge to OpenOCD
build-deps:
	$(MAKE) -C ../rtl/tb/remote_bitbang all

clean-deps:
	$(MAKE) -C ../rtl/tb/remote_bitbang clean

sim:
	$(VSIM) -64 -gui vopt_tb -L models_lib -L vip_lib \
		-suppress vsim-3009 -suppress vsim-8683 \
		+UVM_NO_RELNOTES -stats -t ps \
		-sv_lib $(SVLIB) $(VSIM_FLAGS) \
		-do "set StdArithNoWarnings 1; set NumericStdNoWarnings 1"

simc:
	$(VSIM) -64 -c vopt_tb -L models_lib -L vip_lib \
		-suppress vsim-3009 -suppress vsim-8683 \
		+UVM_NO_RELNOTES -stats -t ps \
		-sv_lib $(SVLIB) $(VSIM_FLAGS) \
		-do "set StdArithNoWarnings 1; set NumericStdNoWarnings 1" \
		-do "run -all" \
		-do "quit -code [examine -radix decimal sim:/tb_pulp/exit_status]"

opt:
	$(mkfile_path)/tcl_files/rtl_vopt.tcl

build: build-deps
	@make --no-print-directory -f $(mkfile_path)/vcompile/ips.mk build
	@make --no-print-directory -f $(mkfile_path)/vcompile/rtl.mk build

lib:
	@make --no-print-directory -f $(mkfile_path)/vcompile/ips.mk lib
	@make --no-print-directory -f $(mkfile_path)/vcompile/rtl.mk lib

clean: clean-deps
	@make --no-print-directory -f $(mkfile_path)/vcompile/ips.mk clean
	@make --no-print-directory -f $(mkfile_path)/vcompile/rtl.mk clean
	rm -rf $(MEM_INIT_DIR)
	rm -f  sim_core_v_mcu

# Copy memory initialisation files from tb/mem_init_files/ to the paths that
# the RTL $readmem calls expect (relative to the simulation working directory).
# Must be run once before the first Verilator simulation, and again whenever
# any source .mem file changes.
MEM_INIT_DIR := mem_init
TB_MEM       := ../tb/mem_init_files

mem_init:
	mkdir -p $(MEM_INIT_DIR)
	cp $(TB_MEM)/verilatorBoot.mem  $(MEM_INIT_DIR)/boot.mem
	cp $(TB_MEM)/cli_sim.txt        $(MEM_INIT_DIR)/cli.txt
	cp $(TB_MEM)/col0.mem           "$(MEM_INIT_DIR)/TOP.core_v_mcu.i_soc_domain.l2_ram_i.CUTS[0].bank_i.u0.mem"
	cp $(TB_MEM)/col1.mem           "$(MEM_INIT_DIR)/TOP.core_v_mcu.i_soc_domain.l2_ram_i.CUTS[1].bank_i.u0.mem"
	cp $(TB_MEM)/col2.mem           "$(MEM_INIT_DIR)/TOP.core_v_mcu.i_soc_domain.l2_ram_i.CUTS[2].bank_i.u0.mem"
	cp $(TB_MEM)/col3.mem           "$(MEM_INIT_DIR)/TOP.core_v_mcu.i_soc_domain.l2_ram_i.CUTS[3].bank_i.u0.mem"
	cp $(TB_MEM)/privateBank0.mem   "$(MEM_INIT_DIR)/TOP.core_v_mcu.i_soc_domain.l2_ram_i.bank_sram_pri0_i.u0.mem"
	cp $(TB_MEM)/privateBank1.mem   "$(MEM_INIT_DIR)/TOP.core_v_mcu.i_soc_domain.l2_ram_i.bank_sram_pri1_i.u0.mem"

# Build the Verilator simulation executable.
# Requires the model-lib FuseSoC target to have been built first:
#   ~/venv/core-v-mcu/bin/fusesoc --cores-root .. run --target=model-lib \
#       --setup --build openhwgroup.org:systems:core-v-mcu
VROOT   := $(shell verilator --getenv VERILATOR_ROOT)
OBJ_DIR := ../build/openhwgroup.org_systems_core-v-mcu_0/model-lib-verilator/obj_dir

verilator: mem_init
	g++ -std=c++17 -O2 \
	    -I$(VROOT)/include \
	    -I$(OBJ_DIR) \
	    sim_main.cpp \
	    $(OBJ_DIR)/Vcore_v_mcu__ALL.a \
	    $(OBJ_DIR)/libverilated.a \
	    -lpthread \
	    -o sim_core_v_mcu
