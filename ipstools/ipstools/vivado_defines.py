#!/usr/bin/env python3
#
# vivado_defines.py
# Francesco Conti <f.conti@unibo.it>
#
# Copyright (C) 2015-2017 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

VIVADO_PREAMBLE = """if ![info exists PULP_FPGA_SIM] {
    set RTL %s/%s
    set IPS %s/%s
    set FPGA_IPS ../ips
    set FPGA_RTL ../rtl
}
"""

VIVADO_PREAMBLE_SUBIP = """
# %s
set SRC_%s " \\
"""

VIVADO_PREAMBLE_SUBIP_INCDIRS = """set INC_%s " \\
"""

VIVADO_SUBIP_LIB = "set LIB_%s\n"

VIVADO_POSTAMBLE_SUBIP = """"
"""

VIVADO_ADD_FILES_CMD = "add_files -norecurse -scan_for_includes $SRC_%s\n"

VIVADO_INC_DIRS_PREAMBLE = """if ![info exists INCLUDE_DIRS] {
	set INCLUDE_DIRS ""
}

eval "set INCLUDE_DIRS {
    %s/%s/includes \\
"""

VIVADO_INC_DIRS_CMD = "    %s/%s/%s \\\n"

VIVADO_INC_DIRS_POSTAMBLE = """	${INCLUDE_DIRS} \\
}"
"""
