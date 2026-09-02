# Copyright (c) 2026 Shivam Tiwari
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

IVERILOG ?= iverilog
VVP      ?= vvp

BUILD_DIR := build
TOP       := soc_event_generator_tb
RTL_DIR   := ../rtl
FIFO_RTL  := ../../../../vendor/pulp_platform_common_cells/src/deprecated/generic_fifo.sv

SOURCES := \
	$(FIFO_RTL) \
	$(RTL_DIR)/soc_event_queue.sv \
	$(RTL_DIR)/soc_event_arbiter.sv \
	$(RTL_DIR)/soc_event_generator.sv \
	soc_event_generator_tb.sv

.PHONY: all test clean

all: test

$(BUILD_DIR):
	mkdir -p $@

$(BUILD_DIR)/$(TOP).vvp: $(SOURCES) | $(BUILD_DIR)
	$(IVERILOG) -g2012 -DPULP_FPGA_EMUL -s $(TOP) -o $@ $(SOURCES)

test: $(BUILD_DIR)/$(TOP).vvp
	$(VVP) -n $<

clean:
	$(RM) -r $(BUILD_DIR)
