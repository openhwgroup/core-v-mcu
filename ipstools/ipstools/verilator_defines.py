#!/usr/bin/env python3
#
# vivado_defines.py
# Francesco Conti <f.conti@unibo.it>
#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

VERILATOR_PREAMBLE = """RTL=%s/%s
IPS=%s/%s
"""

VERILATOR_PREAMBLE_SUBIP = """
# %s
SRC_%s= \\
"""

VERILATOR_PREAMBLE_SUBIP_INCDIRS = """INC_%s= \\
"""

VERILATOR_POSTAMBLE_SUBIP = """
"""

VERILATOR_ADD_FILES_CMD = "${SRC_%s} \\\n"

# VIVADO_INC_DIRS_PREAMBLE = """if ![info exists INCLUDE_DIRS] {
# 	set INCLUDE_DIRS ""
# }

# eval "set INCLUDE_DIRS {
#     %s/%s/includes \\
# """

VERILATOR_INC_DIRS_CMD = "${INC_%s} \\\n"

# VIVADO_INC_DIRS_POSTAMBLE = """	${INCLUDE_DIRS} \\
# }"
# """
