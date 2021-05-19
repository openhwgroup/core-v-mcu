# Copyright 2021 OpenHW Group
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

all:    doc

clean:
				rm -rf _build

install:
				cp -r sphinx-source/_build/html ${INSTALL_DIR}

doc:    ${MD_FILES}
				make -f make-sphinx.mk html
