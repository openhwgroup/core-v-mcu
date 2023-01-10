# Copyright 2022 OpenHW Group
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

# Directory where generated md files go
# NOTE: Auto-generation of CSR and Pin tables is disabled for now.
#       Use of Markdown has been replaced with ReStructured Text.
#AUTO_MD_DIR=auto-docs
#CSV_MIRROR_DIR=csv-mirror/

#FOO=$(shell find ../rtl -name '*.csv' -exec mkdir -p ${CSV_MIRROR_DIR} \; -exec cp {} ${CSV_MIRROR_DIR} \;)
#$(info ${FOO})
#SRCS=$(shell find ../rtl -name '*.csv' -print)
#$(info ${SRCS})
#MD_FILES:=$(addprefix ${AUTO_MD_DIR}/,$(notdir $(SRCS:.csv=.md)))
#MD_FILES+=${AUTO_MD_DIR}/pin-table.md
#$(info ${MD_FILES})

INSTALL_DIR:="../../core-v-mcu-cli-test/doc"

all:    doc

clean:
				rm -rf CORE-V-MCU_User_Manual.pdf
				rm -f doc-src/all.rst
				rm -f doc-src/allimages.rst
				rm -rf _build

doc: html pdf

html:
				rm -f doc-src/all.rst
				rm -f doc-src/allimages.rst
				rm -rf _build
				make -f make-sphinx.mk html

pdf:
				rm -f doc-src/all.rst
				rm -f doc-src/allimages.rst
				for f in `egrep doc-src index.rst`; do cat "$$f" >> doc-src/all.rst; echo "\n\n" >> doc-src/all.rst; done
				(cat doc-src/all.rst | sed 's/..\/images/images/g' | sed 's/..\/images/images/g' > doc-src/allimages.rst)
				(pandoc -t latex -o CORE-V-MCU_User_Manual.pdf doc-src/allimages.rst)

install:
				cp -r sphinx-source/_build/html ${INSTALL_DIR}

# Auto-generation of CSR and Pin tables is disabled for now.

#${AUTO_MD_DIR}/%.md : ${CSV_MIRROR_DIR}/%.csv
#			@mkdir -p ${AUTO_MD_DIR}
#			@python3 ../util/ioscript.py\
#				--soc-defines ../rtl/includes/pulp_soc_defines.svh\
#				--periph-bus-defines ../rtl/includes/periph_bus_defines.svh\
#				--reg-def-csv $<\
#				--reg-def-md $@

#${AUTO_MD_DIR}/pin-table.md: ../nexys-pin-table.csv
#			@mkdir -p ${AUTO_MD_DIR}
#			@python3 ../util/ioscript.py\
#				--soc-defines ../rtl/includes/pulp_soc_defines.svh\
#				--periph-bus-defines ../rtl/includes/periph_bus_defines.svh\
#				--peripheral-defines peripheral-defines.svh\
#				--perdef-json ../perdef.json\
#				--pin-table $<\
#				--pin-table-md $@
#			rm peripheral-defines.svh
