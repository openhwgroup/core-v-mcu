#
# Copyright (C) 2017-2018 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

.PHONY: build lib clean 

mkfile_path := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))

sim-sink-realign:
	vsim -lib work vopt_sink_realign +notimingchecks
sim-source-realign:
	vsim -lib work vopt_source_realign +notimingchecks

opt-sink-realign:
	$(mkfile_path)/vsimulate/rtl_vopt_sink_realign.tcl
opt-source-realign:
	$(mkfile_path)/vsimulate/rtl_vopt_source_realign.tcl

build:
	@make --no-print-directory -f $(mkfile_path)/vcompile/rtl.mk build

lib:
	@make --no-print-directory -f $(mkfile_path)/vcompile/rtl.mk lib
	vlib work
	vmap work work

clean:
	@make --no-print-directory -f $(mkfile_path)/vcompile/rtl.mk clean
	rm -rf work

