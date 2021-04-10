#!/usr/bin/env python3
#
# ips_defines.py
# Francesco Conti <f.conti@unibo.it>
#
# Copyright (C) 2015-2017 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

IPS_LIST_PREAMBLE = """#
# List of IPs and relative branch/commit-hash/tag.
# Uses the YAML syntax.
#
# Examples:
#
#   or10n:
#     commit: tags/PULP3_final
#     domain: [cluster]
#   udma:
#     commit: 62b10440
#     domain: [soc]
#   axi_slice:
#     commit: master
#     domain: [soc,cluster]
# If a *tag* or *commit* is referenced, the IP will be in a
#  state of DETACHED HEAD. Before committing any additional
#  work, make sure to checkout a branch.
#

"""
