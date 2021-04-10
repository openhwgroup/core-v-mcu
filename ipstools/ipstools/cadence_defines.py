#!/usr/bin/env python3
#
# synopsys_defines.py
# Francesco Conti <f.conti@unibo.it>
#
# Copyright (C) 2015-2017 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

# templates for vcompile.csh scripts

CADENCE_ANALYZE_PREAMBLE = "puts \"${Green}Analyzing %s ${NC}\"\n"

CADENCE_ANALYZE_PREAMBLE_SUBIP = "\nputs \"${Green}--> compile %s${NC}\"\n"

CADENCE_ANALYZE_SV_CMD   = "read_hdl -sv %s -library work ${%s_PATH}/%s\n"
CADENCE_ANALYZE_V_CMD    = "read_hdl -v  %s -library work ${%s_PATH}/%s\n"
CADENCE_ANALYZE_VHDL_CMD = "read_hdl -vhdl  -library %s_lib ${%s_PATH}/%s\n"

