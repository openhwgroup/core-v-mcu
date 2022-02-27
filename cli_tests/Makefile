# Copyright 2020 ETH Zurich
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
# Author: Robert Balas (balasr@iis.ee.ethz.ch)

# Description: Makefile to build the blinky and other demo applications. Note
# that it supports the usual GNU Make implicit variables e.g. CC, CFLAGS,
# CPPFLAGS etc. Consult the GNU Make manual for move information about these.

# Notes:
# Useful targets
# make all      Compile and link
# make run      Simulate SoC
# make backup   Record your simulation run
# make analyze  Run analysis scripts on the simulation result

# Important Variables
# PROG       Needs to be set to your executables name
# USER_SRCS  Add your source files here (use +=)
# CPPFLAGS   Add your include search paths and macro definitions (use +=)

# Adding common compile flags when using default_flags.mk.
# Compile options (passed to make) e.g. make NDEBUG=yes
# NDEBUG    Make release build
# LIBC      Link against libc
# LTO       Enable link time optimization
# SANITIZE  Enable gcc sanitizer for debugging memory access problems
# STACKDBG  Enable stack debugging information and warnings.
#           By default 1 KiB but can be changed with MAXSTACKSIZE=your_value


# indicate this repository's root folder
PROJ_ROOT = $(shell git rev-parse --show-toplevel)

# good defaults for many environment variables
include $(PROJ_ROOT)/common/default_flags.mk

# manually set CFLAGS to disable some warnings (-Wconversion)
CFLAGS = \
	-march=rv32imac -mabi=ilp32 -msmall-data-limit=8 -mno-save-restore \
	-fsigned-char -ffunction-sections -fdata-sections \
	-std=gnu11 \
	-Wall -Wextra -Wshadow -Wformat=2 -Wundef \
	-Wno-unused-parameter -Wno-unused-variable \
	-Og -g3 \
	-DFEATURE_CLUSTER=0 -D__PULP__=1 -DASYNC=0 -DTRACE_UART -DPI_LOG_LOCAL_LEVEL=5 -DDEBUG \
        -fstack-usage -Wstack-usage=1024

# rtos, pulp and pmsis sources
include $(PROJ_ROOT)/common/freertos_pmsis_srcs.mk

# application name
PROG = uart_test

# application/user specific code
USER_SRCS = uart_test.c

# FreeRTOS.h
CPPFLAGS += $(addprefix -I$(VPATH)/, ".")

CPPFLAGS += -DportasmHANDLE_INTERRUPT=vSystemIrqHandler
##CPPFLAGS += -DUSE_STDIO
## number of error check polls before the tests is conclueded as being successful
CPPFLAGS += -DSTREAM_CHECK_ITERATIONS=2

# compile, simulation and analysis targets
include $(PROJ_ROOT)/common/default_targets.mk
