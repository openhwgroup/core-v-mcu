#!/usr/bin/env python3
#
# makefile_defines.py
# Francesco Conti <f.conti@unibo.it>
#
# Copyright (C) 2015-2017 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

# templates for ip.mk scripts
MK_PREAMBLE = """#
# Copyright (C) 2016 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IP=%s
IP_PATH=%s/%s
LIB_NAME=$(IP)_lib

include vcompile/build.mk

.PHONY: vcompile-$(IP) %s

vcompile-$(IP): $(LIB_PATH)/_vmake

$(LIB_PATH)/_vmake : %s
	@touch $(LIB_PATH)/_vmake
"""

MK_POSTAMBLE = """

"""

#MK_IPRULE_CMD = "\n\t@make -f vcompile/ips/%s.mk %s"

MK_SUBIPSRC = """SRC_SVLOG_%s=%s
SRC_VHDL_%s=%s
"""

MK_SUBIPINC = """# %s component
INCDIR_%s=%s
"""

MK_SUBIPRULE = """vcompile-subip-%s: $(LIB_PATH)/%s.vmake

$(LIB_PATH)/%s.vmake: $(SRC_SVLOG_%s) $(SRC_VHDL_%s)
	$(call subip_echo,%s)
	%s
	@touch $(LIB_PATH)/%s.vmake
"""

MK_BUILDCMD_SVLOG_LINT = "$(SVLOG_LINT) %s $(INCDIR_%s) $(SRC_SVLOG_%s)"
MK_BUILDCMD_VLOG_LINT = "$(VLOG_LINT) %s $(INCDIR_%s) $(SRC_%s)"
MK_BUILDCMD_SVLOG = "$(SVLOG_CC) -work $(LIB_PATH) %s $(INCDIR_%s) $(SRC_SVLOG_%s)"
MK_BUILDCMD_VLOG  = "$(VLOG_CC) -work $(LIB_PATH) %s $(INCDIR_%s) $(SRC_%s)"
MK_BUILDCMD_VHDL  = "$(VHDL_CC) -work $(LIB_PATH) %s $(SRC_VHDL_%s)"

# templates for general Makefile
MK_LIBS_PREAMBLE = """#
# Copyright (C) 2016-2018 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

mkfile_path := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))

.PHONY: build clean lib

build:"""

MK_LIBS_CLEAN = "\nclean:"
MK_LIBS_LIB = "\nlib:"

MK_LIBS_CMD = "\n\t@make --no-print-directory -f $(mkfile_path)/ips/%s.mk %s"
MK_LIBS_CMD_RTL = "\n\t@make --no-print-directory -f $(mkfile_path)/rtl/%s.mk %s"
