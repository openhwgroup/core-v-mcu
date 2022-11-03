# Copyright 2022 OpenHW Group
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

# Directory where generated md files go
AUTO_MD_DIR=auto-docs
CSV_MIRROR_DIR=csv-mirror/

FOO=$(shell find ../rtl -name '*.csv' -exec mkdir -p ${CSV_MIRROR_DIR} \; -exec cp {} ${CSV_MIRROR_DIR} \;)
$(info ${FOO})
SRCS=$(shell find ../rtl -name '*.csv' -print)
$(info ${SRCS})
MD_FILES:=$(addprefix ${AUTO_MD_DIR}/,$(notdir $(SRCS:.csv=.md)))
MD_FILES+=${AUTO_MD_DIR}/pin-table.md
$(info ${MD_FILES})

INSTALL_DIR:="../../core-v-mcu-cli-test/doc"

all:    doc pdf

check:    ${MD_FILES} doc

clean:
				rm -rf ${AUTO_MD_DIR}/
				rm -rf index.pdf
				rm -f doc-src/all.md
				rm -rf _build
install:
				cp -r sphinx-source/_build/html ${INSTALL_DIR}

doc: ${MD_FILES}
				rm -f doc-src/all.md
				rm -rf _build
				make -f make-sphinx.mk html

pdf: ${MD_FILES}
				rm -f doc-src/all.md
				for f in `egrep doc-src\|auto-docs index.rst`; do cat "$$f" >> doc-src/all.md; echo "\n\n" >> doc-src/all.md;done
				(cd doc-src; pandoc -t latex -o ../index.pdf all.md)

${AUTO_MD_DIR}/%.md : ${CSV_MIRROR_DIR}/%.csv
			@mkdir -p ${AUTO_MD_DIR}
			@python3 ../util/ioscript.py\
				--soc-defines ../rtl/includes/pulp_soc_defines.svh\
				--periph-bus-defines ../rtl/includes/periph_bus_defines.svh\
				--reg-def-csv $<\
				--reg-def-md $@

${AUTO_MD_DIR}/pin-table.md: ../nexys-pin-table.csv
			@mkdir -p ${AUTO_MD_DIR}
			@python3 ../util/ioscript.py\
				--soc-defines ../rtl/includes/pulp_soc_defines.svh\
				--periph-bus-defines ../rtl/includes/periph_bus_defines.svh\
				--peripheral-defines peripheral-defines.svh\
				--perdef-json ../perdef.json\
				--pin-table $<\
				--pin-table-md $@
			rm peripheral-defines.svh
