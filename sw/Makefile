# Copyright 2021 OpenHW Group
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

# Directory where generated hdr files go
HDR_DIR=inc
CSV_MIRROR_DIR=csv-mirror/

DEF_FILES=../rtl/includes/pulp_soc_defines.sv\
					../rtl/includes/pulp_peripheral_defines.svh\
					../rtl/includes/periph_bus_defines.sv\
					../pin-table.csv\
					../perdef.json
FOO=$(shell find ../rtl -name '*.csv' -exec mkdir -p ${CSV_MIRROR_DIR} \; -exec cp {} ${CSV_MIRROR_DIR} \;)
$(info ${FOO})
SRCS=$(shell find ../rtl -name '*.csv' -print)
$(info ${SRCS})
HDR_FILES=${HDR_DIR}/core-v-mcu-config.h
HDR_FILES+=$(addprefix ${HDR_DIR}/,$(notdir $(SRCS:.csv=.h)))
$(info ${HDR_FILES})


all:    hdrs

clean:
				rm -rf ${HDR_DIR}
				rm -rf ${CSV_MIRROR_DIR}

hdrs:    ${HDR_FILES}

${HDR_DIR}/core-v-mcu-config.h:	${DEF_FILES}
				@mkdir -p ${HDR_DIR}
				python3 ../util/ioscript.py\
					--soc-defines ../rtl/includes/pulp_soc_defines.sv\
					--periph-bus-defines ../rtl/includes/periph_bus_defines.sv\
					--peripheral-defines ../rtl/includes/pulp_peripheral_defines.svh\
					--pin-table ../pin-table.csv\
					--perdef-json ../perdef.json\
					--cvmcu-h $@


${HDR_DIR}/%.h : ${CSV_MIRROR_DIR}/%.csv
			@mkdir -p ${HDR_DIR}
			python3 ../util/ioscript.py\
				--soc-defines ../rtl/includes/pulp_soc_defines.sv\
				--periph-bus-defines ../rtl/includes/periph_bus_defines.sv\
				--reg-def-csv $<\
				--reg-def-h $@
