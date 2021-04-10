#!/usr/bin/env tclsh
#
# Copyright (C) 2017-2018 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

source ./vsimulate/config/vsim_rtl.tcl

eval exec >@stdout vopt +acc=mnpr -o vopt_source_realign tb_hwpe_stream_source_realign $VSIM_RTL_LIBS -work work 

