# Copyright 2021 OpenHW Group
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

# Directory where generated md files go
AUTO_MD_DIR=user-manual/auto-docs
CSV_MIRROR_DIR=user-manual/csv-mirror/

FOO=$(shell find ../rtl -name '*.csv' -exec mkdir -p ${CSV_MIRROR_DIR} \; -exec cp {} ${CSV_MIRROR_DIR} \;)
$(info ${FOO})
SRCS=$(shell find ../rtl -name '*.csv' -print)
$(info ${SRCS})
MD_FILES:=$(addprefix ${AUTO_MD_DIR}/,$(notdir $(SRCS:.csv=.md)))
MD_FILES+=${AUTO_MD_DIR}/pin-table.md
$(info ${MD_FILES})

INSTALL_DIR:="../../core-v-mcu-cli-test/doc"

all:    doc

clean:
				rm -rf ${AUTO_MD_DIR}

install:
				cp -r sphinx-source/_build/html ${INSTALL_DIR}

doc:    ${MD_FILES}
				make -f make-sphinx.mk html


${AUTO_MD_DIR}/%.md : ${CSV_MIRROR_DIR}/%.csv
			@mkdir -p ${AUTO_MD_DIR}
			@python3 ../util/ioscript.py\
				--soc-defines ../rtl/includes/pulp_soc_defines.sv\
				--periph-bus-defines ../rtl/includes/periph_bus_defines.sv\
				--reg-def-csv $<\
				--reg-def-md $@
				
${AUTO_MD_DIR}/pin-table.md: ../pin-table.csv
			@mkdir -p ${AUTO_MD_DIR}
			@python3 ../util/ioscript.py\
				--soc-defines ../rtl/includes/pulp_soc_defines.sv\
				--periph-bus-defines ../rtl/includes/periph_bus_defines.sv\
				--peripheral-defines peripheral-defines.svh\
				--perdef-json ../perdef.json\
				--pin-table $<\
				--pin-table-md $@
			rm peripheral-defines.svh
