#!/usr/bin/env python
# 
# ucode_compile.py
# Francesco Conti <fconti@iis.ee.ethz.ch>
#
# Copyright (C) 2018 ETH Zurich, University of Bologna
# Copyright and related rights are licensed under the Solderpad Hardware
# License, Version 0.51 (the "License"); you may not use this file except in
# compliance with the License.  You may obtain a copy of the License at
# http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
# or agreed to in writing, software, hardware and materials distributed under
# this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.
#

from ucode_common import *

loops_ops,code = ucode_load("code.yml")

bytecode = ucode_bytecode(code, loops_ops)
print "ucode bytecode: %d'h%s" % (bytecode['code'].length, str(bytecode['code'].hex))
print "ucode loops:    %d'h%s" % (bytecode['loops'].length, str(bytecode['loops'].hex))
