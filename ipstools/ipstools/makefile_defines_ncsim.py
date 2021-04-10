#!/usr/bin/env python3
#
# makefile_defines_ncsim.py
# Francesco Conti <f.conti@unibo.it>
# Robert Balas<balasr@iis.ee.ethz.ch>
#
# Copyright (C) 2015-2017 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

# templates for ip.mk scripts
MKN_PREAMBLE = """#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=%s
IP_PATH=%s/%s
LIB_NAME=$(IP)_lib

include ncompile/build.mk

.PHONY: ncompile-$(IP) %s

ncompile-$(IP): $(LIB_PATH)/_nmake

$(LIB_PATH)/_nmake : %s
	echo $(LIB_PATH)/_nmake
"""

MKN_SUBIPRULE = """ncompile-subip-%s: $(LIB_PATH)/%s.nmake

$(LIB_PATH)/%s.nmake: $(SRC_SVLOG_%s) $(SRC_VHDL_%s)
	$(call subip_echo,%s)
	%s
	echo $(LIB_PATH)/%s.nmake
"""

MKN_BUILDCMD_SVLOG = "$(SVLOG_CC) -makelib ./ncsim_libs %s $(INCDIR_%s) $(SRC_SVLOG_%s) -endlib"
MKN_BUILDCMD_VLOG  = "$(VLOG_CC) -makelib ./ncsim_libs %s $(INCDIR_%s) $(SRC_SVLOG_%s) -endlib"
MKN_BUILDCMD_VHDL  = "$(VHDL_CC) -makelib ./ncsim_libs %s $(SRC_VHDL_%s) -endlib"

NCELAB_LIST_PREAMBLE = """#
# Copyright (C) 2015-2019 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

export NCELAB_LIBS_%s= \\
"""

NCELAB_LIST_CMD = """\t-LIBNAME %s_lib \\
"""
