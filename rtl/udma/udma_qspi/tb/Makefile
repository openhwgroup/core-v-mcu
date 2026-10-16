# Copyright 2026 Nathan Chandrasekar
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

IVERILOG ?= iverilog
VVP      ?= vvp

BUILD_DIR := build
TOP       := udma_spim_rx_tb
RTL_DIR   := ../rtl
CLK_RTL   := ../../../vendor/pulp_platform_tech_cells_generic/src

SOURCES := \
	$(CLK_RTL)/deprecated/pulp_clk_cells.sv \
	$(CLK_RTL)/rtl/tc_clk.sv \
	$(RTL_DIR)/udma_spim_txrx.sv \
	udma_spim_rx_tb.sv

.PHONY: all test clean

all: test

$(BUILD_DIR):
	mkdir -p $@

$(BUILD_DIR)/$(TOP).vvp: $(SOURCES) $(RTL_DIR)/udma_spim_defines.sv | $(BUILD_DIR)
	$(IVERILOG) -g2012 -I$(RTL_DIR) -s $(TOP) -o $@ $(SOURCES)

test: $(BUILD_DIR)/$(TOP).vvp
	$(VVP) -n $<

clean:
	$(RM) -r $(BUILD_DIR)
