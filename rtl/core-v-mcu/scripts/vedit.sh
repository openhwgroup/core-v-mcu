#!/bin/sh
# A script to clean up FuseSoC verilator scripts
#
# Copyright (C) 2021 Open Hardware Group
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

# FuseSoC's Verilator target really believes it is creating an executable, and
# also generates all its code in the same directory, which clutters up the
# space. This pre-build hook edits the Verilator argument file, to cause it to
# generate a library in the default `obj_dir` subdirectory.
#
# We also need to modify the generated Makefile to build the library in the
# `obj_dir` subdirectory.
#
# The name of the Verilator argument file is passed as the sole argument.

# Change the Veriator options to build a library in obj_dir
mv $1 $1.orig
sed < $1.orig > $1 -e '/--Mdir/d' -e '/--exe/d'

# Edit the Makefile to use obj_dir
mv Makefile Makefile.orig
sed < Makefile.orig > Makefile \
    -e 's/\(..MAKE....MAKE_OPTIONS.\)\(.*$\)/\1 -C obj_dir \2/'
