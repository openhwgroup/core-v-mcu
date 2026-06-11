.PHONY: build lib clean sim simc mem_init verilator verilator-sv

mkfile_path := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))

#--- Number of threads launched at compile time (careful!)
NJOBS ?= 4

#--- Waive the following Verilator warnings (for now).
WAIVED_VERILATOR_WARNINGS = -Wno-UNOPTFLAT \
                            -Wno-CASEX \
                            -Wno-ASCRANGE \
                            -Wno-PINMISSING \
                            -Wno-CMPCONST \
                            -Wno-TIMESCALEMOD

VSIM        ?= vsim
VSIM_FLAGS  = -gUSE_SDVT_SPI=0 -gUSE_SDVT_CPI=0 -gBAUDRATE=115200 \
		-gENABLE_DEV_DPI=0 -gLOAD_L2=JTAG -gUSE_SDVT_I2S=0

SVLIB	    =  ../rtl/tb/remote_bitbang/librbs

all: clean lib build opt

# build the bitbang library, needed for simulating a jtag bridge to OpenOCD
build-deps:
	$(MAKE) -C ../rtl/tb/remote_bitbang all

clean-deps:
	-$(MAKE) -C ../rtl/tb/remote_bitbang clean

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
	-@make --no-print-directory -f $(mkfile_path)/vcompile/ips.mk clean
	-@make --no-print-directory -f $(mkfile_path)/vcompile/rtl.mk clean
	rm -rf $(MEM_INIT_DIR)
	rm -f  sim_core_v_mcu
	rm -f  $(TB_VC)
	rm -rf $(VC_DIR)/obj_dir_sv
	rm -f  $(GENERIC_MEM_DST)
	rm -f  $(A2_BOOTROM_DST)

# Copy memory initialisation files from tb/mem_init_files/ to the paths that
# the RTL $readmem calls expect (relative to the simulation working directory).
# Must be run once before the first Verilator simulation, and again whenever
# any source .mem file changes.
MEM_INIT_DIR := mem_init
TB_MEM       := ../tb/mem_init_files

# The mem_init files are loaded by Verilator $readmem calls inside the RTL at
# simulation start.  The file names must match the full hierarchical scope of
# each memory instance as Verilator sees it.
#
# Source files (tb/mem_init_files/) use the FuseSoC stand-alone naming scheme
# "TOP.core_v_mcu.*".  When the design is compiled under the tb_core_v_mcu
# testbench the hierarchy root becomes "tb_core_v_mcu.dut.*" instead.  Rather
# than keeping two copies, the files are copied once under the TOP.* names and
# then a symlink with the tb_core_v_mcu.dut.* name is created beside each one.
# Both names resolve to the same data so either build style finds its files.
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
	@cd $(MEM_INIT_DIR) && for f in TOP.core_v_mcu.*; do \
	    newname=$$(echo "$$f" | sed 's/TOP\.core_v_mcu/tb_core_v_mcu.dut/'); \
	    ln -sf "$$f" "$$newname"; \
	done

# Build the Verilator simulation executable (C++ harness, legacy).
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

# Build the Verilator simulation executable (SystemVerilog testbench).
# Uses --binary --timing so Verilator compiles everything into one executable.
# Requires the same FuseSoC model-lib build as the verilator target above.
VC_FILE := ../build/openhwgroup.org_systems_core-v-mcu_0/model-lib-verilator/openhwgroup.org_systems_core-v-mcu_0.vc
VC_DIR  := $(abspath $(dir $(VC_FILE)))
TB_VC   := $(VC_DIR)/tb.vc

# Strip --cc and --top-module from the FuseSoC .vc; our SV top replaces both.
$(TB_VC): $(VC_FILE)
	sed '/^--cc$$/d; /^--top-module/d' $< > $@

# RTL sources that FuseSoC copies into the build tree during --setup.
# Keep the build-tree copies in sync with the source tree so that edits are
# picked up by verilator-sv without requiring a full FuseSoC re-setup.
GENERIC_MEM_SRC := ../rtl/vendor/pulp_platform_tech_cells_generic/src/deprecated/generic_memory.sv
GENERIC_MEM_DST := $(VC_DIR)/src/pulp-platform.org__tech_cells_generic_0/pulp_platform_tech_cells_generic/src/deprecated/generic_memory.sv

$(GENERIC_MEM_DST): $(GENERIC_MEM_SRC)
	cp $< $@

A2_BOOTROM_SRC := ../rtl/simulation/a2_bootrom.sv
A2_BOOTROM_DST := $(VC_DIR)/src/openhwgroup.org_systems_core-v-mcu_0/rtl/simulation/a2_bootrom.sv

$(A2_BOOTROM_DST): $(A2_BOOTROM_SRC)
	cp $< $@

verilator-sv: $(TB_VC) tb_core_v_mcu.sv uart_terminal.cpp $(GENERIC_MEM_DST) $(A2_BOOTROM_DST)
	@mkdir -p $(MEM_INIT_DIR)
	cd $(VC_DIR) && verilator --binary --timing -j $(NJOBS) \
	    --top-module tb_core_v_mcu \
	    $(WAIVED_VERILATOR_WARNINGS) \
	    -O2 \
	    -f tb.vc \
	    $(mkfile_path)tb_core_v_mcu.sv \
	    $(mkfile_path)uart_terminal.cpp \
	    -Mdir obj_dir_sv
	cp $(VC_DIR)/obj_dir_sv/Vtb_core_v_mcu $(mkfile_path)sim_core_v_mcu
