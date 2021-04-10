#!/usr/bin/env python
# Francesco Conti <f.conti@unibo.it>
##
# Copyright (C) 2016-2018 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

import sys,os,subprocess

devnull = open(os.devnull, 'wb')

class tcolors:
    OK      = '\033[92m'
    WARNING = '\033[93m'
    ERROR   = '\033[91m'
    ENDC    = '\033[0m'

def execute(cmd, silent=False):
    if silent:
        stdout = devnull
    else:
        stdout = None
    return subprocess.call(cmd.split(), stdout=stdout)

def execute_out(cmd, silent=False):
    p = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE)
    out, err = p.communicate()
    return out

# download IPApproX tools in ./ipstools and import them
if os.path.exists("ipstools") and os.path.isdir("ipstools"):
    cwd = os.getcwd()
    os.chdir("ipstools")
    execute("git pull origin master", silent=True)
    os.chdir(cwd)
    import ipstools
else:
    execute("git clone git@iis-git.ee.ethz.ch:pulp-tools/IPApproX.git ipstools -b master")
    import ipstools
execute("mkdir -p vcompile/rtl")
execute("rm -rf vcompile/rtl/*")

# creates an IPApproX database
ipdb = ipstools.IPDatabase(rtl_dir='./')
# generate ModelSim/QuestaSim compilation scripts
ipdb.export_make(script_path="vcompile/rtl", target_tech='gf22', source='rtl', local=True)
# generate vsim.tcl with ModelSim/QuestaSim "linking" script
ipdb.generate_vsim_tcl("vsimulate/config/vsim_rtl.tcl", source='rtl')
# generate script to compile all IPs for ModelSim/QuestaSim
ipdb.generate_makefile("vcompile/rtl.mk", source='rtl')

print tcolors.OK + "Generated new scripts for IPs!" + tcolors.ENDC

