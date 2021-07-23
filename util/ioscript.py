#!/bin/python3
#==========================================================
# Copyright 2020 QuickLogic Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#==========================================================

import json
import argparse
import csv
from datetime import datetime

#
#  Argument handling
#
parser = argparse.ArgumentParser()
parameterArgs = parser.add_argument_group("parameters")
parameterArgs.add_argument("--emulation-toplevel", help="top level module name to use in emulation wrapper")

inputArgs = parser.add_argument_group("input files")
inputArgs.add_argument("--soc-defines", help="file with pulp_soc_defines")
inputArgs.add_argument("--periph-bus-defines", help="file with peripheral bus define (memory map)")
inputArgs.add_argument("--perdef-json", help="peripheral definition json file")
inputArgs.add_argument("--pin-table", help="csv filecontaining pin-table")
inputArgs.add_argument("--input-xdc", help="xdc that defines board")
inputArgs.add_argument("--reg-def-csv", help="register definition file (csv)")

outputArgs = parser.add_argument_group("output files")
outputArgs.add_argument("--peripheral-defines", help="file to put  pulp_peripheral_defines")
outputArgs.add_argument("--pad-control-sv", help="file to put  pad_control.sv")
outputArgs.add_argument("--pad-frame-sv", help="file to put  pad_frame.sv")
outputArgs.add_argument("--pad-frame-gf22-sv", help="file to put  pad_frame_gf22.sv")
outputArgs.add_argument("--xilinx-core-v-mcu-sv", help="file for xilinx_core_v_mcu.sv")
outputArgs.add_argument("--output-xdc", help="output xdc for use in Vivado")
outputArgs.add_argument("--cvmcu-h", help="cvmcu.h file for compiles")
outputArgs.add_argument("--reg-def-h", help="register definition C header file (h)")
outputArgs.add_argument("--reg-def-svh", help="register definition Verilog header file (svh)")
outputArgs.add_argument("--reg-def-md", help="register definition markdown file (md)")
outputArgs.add_argument("--pin-table-md", help="pin table markdown file (md)")
args = parser.parse_args()

#
# Global variables
#
error_count = 0

####################################################################################
#
# Routine to write license header
#
####################################################################################
def write_license_header(outfile, define):
    outfile.write("/*\n")
    outfile.write(" * This is a generated file\n")
    outfile.write(" * \n")
    outfile.write(" * Copyright 2021 QuickLogic\n")
    outfile.write(" *\n")
    outfile.write(' * Licensed under the Apache License, Version 2.0 (the "License");\n')
    outfile.write(" * you may not use this file except in compliance with the License.\n")
    outfile.write(" * You may obtain a copy of the License at\n")
    outfile.write(" *\n")
    outfile.write(" *     http://www.apache.org/licenses/LICENSE-2.0\n")
    outfile.write(" *\n")
    outfile.write(" * Unless required by applicable law or agreed to in writing, software\n")
    outfile.write(' * distributed under the License is distributed on an "AS IS" BASIS,\n')
    outfile.write(" * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n")
    outfile.write(" * See the License for the specific language governing permissions and\n")
    outfile.write(" * limitations under the License.\n")
    outfile.write(" *\n")
    outfile.write(" * SPDX-License-Identifier: Apache-2.0\n")
    outfile.write(" */\n")
    if define != None and define != "":
        outfile.write("\n");
        outfile.write("#ifndef %s\n" % define);
        outfile.write("#define %s\n" % define);

####################################################################################
#
# Routine to generate name in typedef format
#   Use camel font with trailing _t
#
####################################################################################
def typedef(name):
    x = name.lower().split('_')
    typedef = ""
    for y in x:
        typedef = typedef + y[0].upper() + y[1:]
    return typedef

####################################################################################
#
# Routine to generate bittype name (add _b)
#
####################################################################################
def bittype_from_name(x):
    if '[' in x:
        x = x.replace("[", "_b[")
    else:
        x = x + "_b"
    return x.lower()

####################################################################################
#
# Routine to remove subscript
#
####################################################################################
def remove_subscript(x):
    if '[' in x:
        x = x[0:x.index('[')]
    return x

####################################################################################
#
# Routine to replace `defines with value
#
####################################################################################
def evaluate_defines(x):
    if '`' in x:
        for d in soc_defines:
            if d != '' and d in x:
                old = '`'+d
                new = soc_defines[d]
                x = x.replace(old, new)
        for d in per_bus_defines:
            if d != '' and d in x:
                old = '`'+d
                new = per_bus_defines[d]
                x = x.replace(old, new)
    return x

####################################################################################
#
# Grab defines from pulp_soc_defines so we know how many of each peripheral type
#
####################################################################################
soc_defines = {'' : 'value'}
if args.soc_defines != None:
    with open(args.soc_defines) as pulp_defines:
        for line in pulp_defines:
            line = line.split()
            if len(line) > 0 and line[0] == '`define':
                if len(line) == 2:
                    soc_defines[line[1]] = ''
                if len(line) > 2:
                    soc_defines[line[1]] = line[2]
    pulp_defines.close()

####################################################################################
#
# Grab defines from peripheral_bus_defines so we know addresses of apb peripherals
#
####################################################################################
per_bus_defines = {'' : 'value'}
if args.periph_bus_defines != None:
    with open(args.periph_bus_defines) as per_bus_define_file:
        for line in per_bus_define_file:
            line = line.split()
            if len(line) > 0 and line[0] == '`define' and not '(' in line[0]:
                if len(line) == 2:
                    per_bus_defines[line[1]] = ''
                if len(line) > 2:
                    if line[2][0:4] == "32'h":
                        line[2] = line[2].replace("32'h", "0x")
                        line[2] = line[2].replace("_", "")
                    per_bus_defines[line[1]] = line[2]
    per_bus_define_file.close()

####################################################################################
#
# Grab peripheral definitions from perdef.json
#
####################################################################################
if args.perdef_json != None:
  with open(args.perdef_json) as f:
    perdefs = json.load(f)

######################################################################
#
# Generate pulp_peripheral_defines.svh
#
######################################################################
if args.soc_defines != None and args.peripheral_defines != None and args.perdef_json != None:
    sysio = {"":""}                                                 # row for each sysio = ['name', 'direction']
    sysionames = [-1 for row in range(int(soc_defines['N_IO']))]    # row for each sysio = [ionum, 'name']
    with open(args.peripheral_defines, 'w') as peripheral_defines_svh:
        write_license_header(peripheral_defines_svh,"")
        peripheral_defines_svh.write("\n")
        peripheral_defines_svh.write("`define BUILD_DATE 32'h%s\n" % datetime.today().strftime("%Y%m%d"))
        peripheral_defines_svh.write("`define BUILD_TIME 32'h00%s\n" % datetime.today().strftime("%H%M%S"))
        peripheral_defines_svh.write("\n")
        peripheral_defines_svh.write("//  PER_ID definitions\n")
        per_id = 0;
        perio_defines = {"":""}
        perio_dir = {"":""}
        perio_index = 0
        for perdef in perdefs:
            if perdef['type'] == 'sysio':
                sysio[perdef['name']] = perdef['direction']
            else:
                pername = perdef['name']
                perports = perdef['ports']
                define = "N_"+pername.upper()
                ninst = int(soc_defines[define])
                peripheral_defines_svh.write("`define PER_ID_%-8s  %d\n" %(pername.upper(), per_id))

                if ninst > 0 and not perdef['usable']:
                    print("Error: trying to use %s when it is not usable" % pername)
                def_name = "PERIO_" + pername.upper()+"_NPORTS"
                perio_defines[def_name] = len(perports)
                for inst in range(ninst if ninst > 0 else 1):   # Even if not used, need defines for the generate
                    for perport in perports:
                        def_name = "PERIO_" + pername.upper()+str(inst)+"_"+perport.upper()
                        perio_defines[def_name] = perio_index
                        perio_index = perio_index + 1
                        perio_dir[def_name] = perports[perport]
                per_id = per_id + ninst

        peripheral_defines_svh.write("\n")
        peripheral_defines_svh.write("//  UDMA TX channels\n")
        udma_tx_ch = 0
        for perdef in perdefs:
            if 'udma_tx' in perdef:
                pername = perdef['name']
                udma_txs = perdef['udma_tx']
                define = "N_"+pername.upper()
                ninst = int(soc_defines[define])
                if ninst > 0 and not perdef['usable']:
                    print("Error: trying to use %s when it is not usable" % pername)
                for udma_tx in udma_txs:
                    peripheral_defines_svh.write("`define %-16s %d\n" %("CH_ID_"+udma_tx.upper(), udma_tx_ch))
                    for inst in range(ninst):
                        peripheral_defines_svh.write("`define %-16s %d\n" %("CH_ID_"+udma_tx.upper()+str(inst), udma_tx_ch))
                        udma_tx_ch = udma_tx_ch + 1

        peripheral_defines_svh.write("\n")
        peripheral_defines_svh.write("//  UDMA RX channels\n")
        udma_rx_ch = 0
        for perdef in perdefs:
            if 'udma_rx' in perdef:
                pername = perdef['name']
                udma_rxs = perdef['udma_rx']
                define = "N_"+pername.upper()
                ninst = int(soc_defines[define])
                if ninst > 0 and not perdef['usable']:
                    print("Error: trying to use %s when it is not usable" % pername)
                for udma_rx in udma_rxs:
                    peripheral_defines_svh.write("`define %-16s %d\n" %("CH_ID_"+udma_rx.upper(), udma_rx_ch))
                    for inst in range(ninst):
                        peripheral_defines_svh.write("`define %-16s %d\n" %("CH_ID_"+udma_rx.upper()+str(inst), udma_rx_ch))
                        udma_rx_ch = udma_rx_ch + 1

        peripheral_defines_svh.write("\n")
        peripheral_defines_svh.write("//  Number of channels\n")
        peripheral_defines_svh.write("`define N_TX_CHANNELS  %d\n" %(udma_tx_ch))
        peripheral_defines_svh.write("`define N_RX_CHANNELS  %d\n" %(udma_rx_ch))

        peripheral_defines_svh.write("\n")
        peripheral_defines_svh.write("//  Width of perio bus\n")
        peripheral_defines_svh.write("`define N_PERIO  %d\n" %(perio_index))

        peripheral_defines_svh.write("\n")
        peripheral_defines_svh.write("//  define index locations in perio bus\n")
        for perio_define in perio_defines:
            if not perio_define == "":
                peripheral_defines_svh.write("`define %-16s %s\n" %(perio_define, perio_defines[perio_define]))
        peripheral_defines_svh.close()

######################################################################
#
# Generate cvmcu.h file
#
######################################################################
if args.soc_defines != None and args.cvmcu_h != None:
    sysio = {"":""}                                                 # row for each sysiso = ['name', 'direction']
    sysionames = [-1 for row in range(int(soc_defines['N_IO']))]    # row for each sysiso = [ionum, 'name']
    with open(args.cvmcu_h, 'w') as cvmcu_h:
        print("Writing '%s'" % args.cvmcu_h)
        # Start with SOC options (from pulp_soc_defines.svh
        write_license_header(cvmcu_h, "__CORE_V_MCU_CONFIG_H_")
        cvmcu_h.write("\n")
        cvmcu_h.write("#define BUILD_DATE 0x%s\n" % datetime.today().strftime("%Y%m%d"))
        cvmcu_h.write("#define BUILD_TIME 0x00%s\n" % datetime.today().strftime("%H%M%S"))
        cvmcu_h.write("\n")
        cvmcu_h.write("//  SOC options\n")
        for define in soc_defines:
            if define[0:2] == 'N_' and soc_defines[define][0] != '`':
                cvmcu_h.write("#define %-20s %s\n" % (define, soc_defines[define]))
            elif define[0:5] == 'NBIT_' and soc_defines[define][0] != '`':
                cvmcu_h.write("#define %-20s %s\n" % (define, soc_defines[define]))

        ###########
        # Add UDMA information
        ###########
        cvmcu_h.write("\n")
        cvmcu_h.write("//  UDMA configuration information\n")
        cvmcu_h.write("#define %-23s %s\n" % ("UDMA_START_ADDR", per_bus_defines["UDMA_START_ADDR"]))
        cvmcu_h.write("#define %-23s %s\n" % ("UDMA_CH_SIZE", "(0x80)"))
        cvmcu_h.write("//  peripheral channel definitions\n")
        cvmcu_h.write("#define UDMA_CH_ADDR_%-10s (%s)\n" % ("CTRL", per_bus_defines["UDMA_START_ADDR"]))
        per_id = 0;
        for perdef in perdefs:
            if perdef['type'] == 'sysio':
                sysio[perdef['name']] = perdef['direction']
            else:
                pername = perdef['name']
                define = "N_"+pername.upper()
                ninst = int(soc_defines[define])
                cvmcu_h.write("#define UDMA_CH_ADDR_%-10s (%s + %d * 0x80)\n" % (pername.upper(),per_bus_defines["UDMA_START_ADDR"], (per_id+1)))
                cvmcu_h.write("#define UDMA_%-18s (%d + id)\n" % (pername.upper()+"_ID(id)", per_id))

                if ninst > 0 and not perdef['usable']:
                    print("Error: trying to use %s when it is not usable" % pername)
                for inst in range(ninst if ninst > 0 else 1):   # Even if not used, need defines for the generate
                    cvmcu_h.write("#define UDMA_CH_ADDR_%-10s (%s + %d * 0x80)\n" % (pername.upper()+str(inst),per_bus_defines["UDMA_START_ADDR"], (per_id+1+inst)))
                per_id = per_id + ninst
        #
        # Clock enables
        #
        per_id = 0
        cvmcu_h.write("\n//  Peripheral clock enable masks\n")
        for perdef in perdefs:
            if perdef['type'] == 'sysio':
                sysio[perdef['name']] = perdef['direction']
            else:
                pername = perdef['name']
                define = "N_"+pername.upper()
                ninst = int(soc_defines[define])

                if ninst > 0 and not perdef['usable']:
                    print("Error: trying to use %s when it is not usable" % pername)
                for inst in range(ninst if ninst > 0 else 1):   # Even if not used, need defines for the generate
                    cvmcu_h.write("#define UDMA_CTRL_%-16s (1 << %d)\n" % (pername.upper()+str(inst)+"_CLKEN", (per_id+inst)))
                per_id = per_id + ninst

        udma_tx_ch = 0
        for perdef in perdefs:
            if 'udma_tx' in perdef:
                pername = perdef['name']
                udma_txs = perdef['udma_tx']
                define = "N_"+pername.upper()
                ninst = int(soc_defines[define])
                if ninst > 0 and not perdef['usable']:
                    print("Error: trying to use %s when it is not usable" % pername)
                for udma_tx in udma_txs:
                    #peripheral_defines_svh.write("`define %-16s %d\n" %("CH_ID_"+udma_tx.upper(), udma_tx_ch))
                    for inst in range(ninst):
                        #peripheral_defines_svh.write("`define %-16s %d\n" %("CH_ID_"+udma_tx.upper()+str(inst), udma_tx_ch))
                        udma_tx_ch = udma_tx_ch + 1

        #peripheral_defines_svh.write("\n")
        #peripheral_defines_svh.write("#  UDMA RX channels\n")
        udma_rx_ch = 0
        for perdef in perdefs:
            if 'udma_rx' in perdef:
                pername = perdef['name']
                udma_rxs = perdef['udma_rx']
                define = "N_"+pername.upper()
                ninst = int(soc_defines[define])
                if ninst > 0 and not perdef['usable']:
                    print("Error: trying to use %s when it is not usable" % pername)
                for udma_rx in udma_rxs:
                    #peripheral_defines_svh.write("`define %-16s %d\n" %("CH_ID_"+udma_rx.upper(), udma_rx_ch))
                    for inst in range(ninst):
                        #peripheral_defines_svh.write("`define %-16s %d\n" %("CH_ID_"+udma_rx.upper()+str(inst), udma_rx_ch))
                        udma_rx_ch = udma_rx_ch + 1

        ###########
        # Add FLL information
        ###########
        cvmcu_h.write("\n")
        cvmcu_h.write("//  FLL configuration information\n")
        cvmcu_h.write("#define FLL_START_ADDR %s\n" % per_bus_defines["FLL_START_ADDR"])

        ###########
        # Add GPIO information
        ###########
        cvmcu_h.write("\n")
        cvmcu_h.write("//  GPIO configuration information\n")
        cvmcu_h.write("#define GPIO_START_ADDR %s\n" % per_bus_defines["GPIO_START_ADDR"])

        ###########
        # Add SOC Controller information
        ###########
        cvmcu_h.write("\n")
        cvmcu_h.write("//  SOC controller configuration information\n")
        cvmcu_h.write("#define SOC_CTRL_START_ADDR %s\n" % per_bus_defines["SOC_CTRL_START_ADDR"])

        ###########
        # Add EU information
        ###########
        cvmcu_h.write("\n")
        cvmcu_h.write("//  Event Unit (Interrupts) configuration information\n")
        cvmcu_h.write("#define EU_START_ADDR %s\n" % per_bus_defines["EU_START_ADDR"])

        ###########
        # Add Timer information
        ###########
        cvmcu_h.write("\n")
        cvmcu_h.write("//  Timer configuration information\n")
        cvmcu_h.write("#define TIMER_START_ADDR %s\n" % per_bus_defines["TIMER_START_ADDR"])

        ###########
        # Add AdvTimer information
        ###########
        cvmcu_h.write("\n")
        cvmcu_h.write("//  AdvTimer configuration information\n")
        cvmcu_h.write("#define ADV_TIMER_START_ADDR %s\n" % per_bus_defines["ADV_TIMER_START_ADDR"])

        cvmcu_h.write("\n")
        cvmcu_h.write("#endif //__CORE_V_MCU_CONFIG_H_\n")

        cvmcu_h.close()
############################## END OF CVMCU.H GENERATION ###############################


################################################
#
# Read pin-table and populate data structures
#
################################################
if args.soc_defines != None and args.pin_table != None:
    N_IO = int(soc_defines['N_IO'])
    N_PERIO = perio_index
    N_GPIO = int(soc_defines['N_APBIO'])
    N_FPGAIO = int(soc_defines['N_FPGAIO'])
    NBIT_PADMUX = int(soc_defines['NBIT_PADMUX'])
    N_PADSEL = 2**NBIT_PADMUX

    selcol = 4  # Index of column that has sel=0 (xilinx, IOname, IOnum, sysio, sel=0, sel=1, ...

    io_out_mux = [['' for j in range(N_PADSEL)] for i in range(N_IO)]
    io_oe_mux = [['' for j in range(N_PADSEL)] for i in range(N_IO)]
    perio_in_mux = [['' for j in range(N_PADSEL)] for i in range(N_PERIO)]
    apbio_in_mux = [['' for j in range(N_PADSEL)] for i in range(N_GPIO)]
    fpgaio_in_mux = [['' for j in range(N_PADSEL)] for i in range(N_FPGAIO)]
    xilinx_names = ['' for i in range(N_IO)]
    with open(args.pin_table, 'r') as f_pin_table:
        pin_table = csv.reader(f_pin_table)
        pin_num = -2
        for pin in pin_table:
            pin_num = pin_num + 1
            if pin_num >= 0:
                # Work to do
                io_num = int(pin[2])
                if pin[0] in xilinx_names:
                    print("ERROR: multiple assignment to xilinx_pin '%s' (IO_%d)" % (pin[0], io_num))
                    error_count = error_count + 1
                xilinx_names[pin_num] = pin[0]
                #
                # Check for sysio name
                #
                sysio_only = False
                if pin[3] != '':
                    if pin[3] in sysio:
                        sysionames[io_num] = pin[3] + ("_o" if (sysio[pin[3]] == 'input' or sysio[pin[3]] == 'snoop') else "_i")
                        if sysio[pin[3]] != 'snoop':
                            sysio_only = True
                    else:
                        print("ERROR: found '%s' in sysio column, but not defined as sysio in perdef.json (IO_%d)" % (pin[3], io_num))
                        error_count = error_count + 1
                for index in range(selcol,len(pin)):
                    sel = index - selcol
                    entry = pin[index]
                    if sysio_only and entry != '':
                        print("ERROR: found '%s' as a sel option for IO_%d which is a sysio" % (entry, io_num))
                    if entry == '':
                        entry = 'z'
                    if entry != '' and entry in sysio:
                        print("ERROR: found sysio '%s' as a sel option for IO_%d" % (entry, io_num))
                        error_count = error_count + 1
                    else:
                        if entry[0:5] == 'apbio':    # apbio
                            apbio_num = int(entry[6:])
                            io_out_mux[io_num][sel] = "apbio_out_i[" + str(apbio_num) + "]"
                            io_oe_mux[io_num][sel] = "apbio_oe_i[" + str(apbio_num) + "]"
                            apbio_in_mux[apbio_num][sel] = "io_in_i[" + str(io_num) + "]"
                        elif entry[0:6] == 'fpgaio':    # fpgaio
                            fpgaio_num = int(entry[7:])
                            io_out_mux[io_num][sel] = "fpgaio_out_i[" + str(fpgaio_num) + "]"
                            io_oe_mux[io_num][sel] = "fpgaio_oe_i[" + str(fpgaio_num) + "]"
                            fpgaio_in_mux[fpgaio_num][sel] = "io_in_i[" + str(io_num) + "]"
                        elif entry == '' or entry[0] == '1' or entry[0] == '0' or entry[0] == 'z' or entry[0] == 'Z':
                            io_out_mux[io_num][sel] = "1'b1" if entry[0] == '1' else "1'b0"
                            io_oe_mux[io_num][sel] = "1'b1" if entry[0] == '1' or entry[0] == '0' else "1'b0"
                        else:
                            perio_index = "PERIO_" + entry.upper()
                            index = perio_defines[perio_index]
                            direction = perio_dir[perio_index]
                            io_out_mux[io_num][sel] = "perio_out_i[`" + perio_index + "]" if direction == 'output' or direction == 'bidir' else "1'b0"
                            if direction == "bidir":
                                io_oe_mux[io_num][sel] = "perio_oe_i[`" + perio_index + "]"
                            elif direction == "output":
                                io_oe_mux[io_num][sel] = "1'b1"
                            else:
                                io_oe_mux[io_num][sel] = "1'b0"
                            perio_in_mux[index][sel] = "io_in_i[" + str(io_num) + "]"
    f_pin_table.close()

################################################
#
# Generate pad_control.sv
#
################################################
if args.pad_control_sv != None:
    with open(args.pad_control_sv, 'w') as pad_control_sv:
        #
        # Write Apache license and header
        #
        pad_control_sv.write("//-----------------------------------------------------\n")
        pad_control_sv.write("// This is a generated file\n")
        pad_control_sv.write("//-----------------------------------------------------\n")
        pad_control_sv.write("// Copyright 2018 ETH Zurich and University of bologna.\n")
        pad_control_sv.write("// Copyright and related rights are licensed under the Solderpad Hardware\n")
        pad_control_sv.write("// License, Version 0.51 (the \"License\"); you may not use this file except in\n")
        pad_control_sv.write("// compliance with the License.  You may obtain a copy of the License at\n")
        pad_control_sv.write("// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law\n")
        pad_control_sv.write("// or agreed to in writing, software, hardware and materials distributed under\n")
        pad_control_sv.write("// this License is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR\n")
        pad_control_sv.write("// CONDITIONS OF ANY KIND, either express or implied. See the License for the\n")
        pad_control_sv.write("// specific language governing permissions and limitations under the License.\n")
        pad_control_sv.write("\n")
        pad_control_sv.write("`include \"pulp_soc_defines.sv\"\n")
        pad_control_sv.write("`include \"pulp_peripheral_defines.svh\"\n")
        pad_control_sv.write("\n")
        pad_control_sv.write("module pad_control(\n")
        pad_control_sv.write("    // PAD CONTROL REGISTER\n")
        pad_control_sv.write("    input  logic [`N_IO-1:0][`NBIT_PADMUX-1:0]    pad_mux_i,\n")
        pad_control_sv.write("    input  logic [`N_IO-1:0][`NBIT_PADCFG-1:0]    pad_cfg_i,\n")
        pad_control_sv.write("    output logic [`N_IO-1:0][`NBIT_PADCFG-1:0]    pad_cfg_o,\n")
        pad_control_sv.write("\n")
        pad_control_sv.write("    // IOS\n")
        pad_control_sv.write("    output logic [`N_IO-1:0]        io_out_o,\n")
        pad_control_sv.write("    input  logic [`N_IO-1:0]        io_in_i,\n")
        pad_control_sv.write("    output logic [`N_IO-1:0]        io_oe_o,\n")
        pad_control_sv.write("\n")
        pad_control_sv.write("    // PERIOS\n")
        pad_control_sv.write("    input  logic [`N_PERIO-1:0]     perio_out_i,\n")
        pad_control_sv.write("    output logic [`N_PERIO-1:0]     perio_in_o,\n")
        pad_control_sv.write("    input  logic [`N_PERIO-1:0]     perio_oe_i,\n")
        pad_control_sv.write("\n")
        pad_control_sv.write("    // APBIOs\n")
        pad_control_sv.write("    input  logic [`N_APBIO-1:0]      apbio_out_i,\n")
        pad_control_sv.write("    output logic [`N_APBIO-1:0]      apbio_in_o,\n")
        pad_control_sv.write("    input  logic [`N_APBIO-1:0]      apbio_oe_i,\n")
        pad_control_sv.write("\n")
        pad_control_sv.write("    // FPGAIOS\n")
        pad_control_sv.write("    input  logic [`N_FPGAIO-1:0]    fpgaio_out_i,\n")
        pad_control_sv.write("    output logic [`N_FPGAIO-1:0]    fpgaio_in_o,\n")
        pad_control_sv.write("    input  logic [`N_FPGAIO-1:0]    fpgaio_oe_i\n")
        pad_control_sv.write("    );\n")

        pad_control_sv.write("\n")
        pad_control_sv.write("    ///////////////////////////////////////////////////\n")
        pad_control_sv.write("    // Assign signals to the pad_cfg_o bus\n")
        pad_control_sv.write("    ///////////////////////////////////////////////////\n")
        pad_control_sv.write("    assign pad_cfg_o = pad_cfg_i;\n")
        pad_control_sv.write("\n")
        pad_control_sv.write("    ///////////////////////////////////////////////////\n")
        pad_control_sv.write("    // Assign signals to the perio bus\n")
        pad_control_sv.write("    ///////////////////////////////////////////////////\n")
        index = -1
        for row in perio_in_mux:
            index = index + 1
            pad_control_sv.write("    assign perio_in_o[%d] = " %index)
            nparen = 0
            for sel in range(len(row)):
                if row[sel] != '':
                    if nparen != 0:
                        pad_control_sv.write("\n                            ")
                    io_num = row[sel][8:-1]
                    pad_control_sv.write("((pad_mux_i[%s] == %d'd%d) ? %s :" %(io_num, NBIT_PADMUX, sel, row[sel]))
                    nparen = nparen + 1
            pad_control_sv.write(" 1'b0")
            for i in range(nparen):
                pad_control_sv.write(")")
            pad_control_sv.write(";\n")

        pad_control_sv.write("\n")
        pad_control_sv.write("    ///////////////////////////////////////////////////\n")
        pad_control_sv.write("    // Assign signals to the apbio bus\n")
        pad_control_sv.write("    ///////////////////////////////////////////////////\n")
        index = -1
        for row in apbio_in_mux:
            index = index + 1
            pad_control_sv.write("    assign apbio_in_o[%d] = " %index)
            nparen = 0
            for sel in range(len(row)):
                if row[sel] != '':
                    if nparen != 0:
                        pad_control_sv.write("\n                           ")
                    io_num = row[sel][8:-1]
                    pad_control_sv.write("((pad_mux_i[%s] == %d'd%d) ? %s :" %(io_num, NBIT_PADMUX, sel, row[sel]))
                    nparen = nparen + 1
            pad_control_sv.write(" 1'b0")
            for i in range(nparen):
                pad_control_sv.write(")")
            pad_control_sv.write(";\n")


        pad_control_sv.write("\n")
        pad_control_sv.write("    ///////////////////////////////////////////////////\n")
        pad_control_sv.write("    // Assign signals to the fpgaio bus\n")
        pad_control_sv.write("    ///////////////////////////////////////////////////\n")
        index = -1
        for row in fpgaio_in_mux:
            index = index + 1
            pad_control_sv.write("    assign fpgaio_in_o[%d] = " %index)
            nparen = 0
            for sel in range(len(row)):
                if row[sel] != '':
                    if nparen != 0:
                        pad_control_sv.write("\n                             ")
                    io_num = row[sel][8:-1]
                    pad_control_sv.write("((pad_mux_i[%s] == %d'd%d) ? %s:" %(io_num, NBIT_PADMUX, sel, row[sel]))
                    nparen = nparen + 1
            pad_control_sv.write(" 1'b0")
            for i in range(nparen):
                pad_control_sv.write(")")
            pad_control_sv.write(";\n")

        pad_control_sv.write("\n")
        pad_control_sv.write("    ///////////////////////////////////////////////////\n")
        pad_control_sv.write("    // Assign signals to the io_out bus\n")
        pad_control_sv.write("    ///////////////////////////////////////////////////\n")
        index = -1
        for row in io_out_mux:
            index = index + 1
            pad_control_sv.write("    assign io_out_o[%d] = " %index)
            nparen = 0
            for sel in range(len(row)):
                if row[sel] != '':
                    if nparen != 0:
                        pad_control_sv.write("\n                         ")
                    pad_control_sv.write("((pad_mux_i[%s] == %d'd%d) ? %s :" %(index, NBIT_PADMUX, sel, row[sel]))
                    nparen = nparen + 1
            pad_control_sv.write(" 1'b0")
            for i in range(nparen):
                pad_control_sv.write(")")
            pad_control_sv.write(";\n")

        pad_control_sv.write("\n")
        pad_control_sv.write("    ///////////////////////////////////////////////////\n")
        pad_control_sv.write("    // Assign signals to the io_oe bus\n")
        pad_control_sv.write("    ///////////////////////////////////////////////////\n")
        index = -1
        for row in io_oe_mux:
            index = index + 1
            pad_control_sv.write("    assign io_oe_o[%d] = " %index)
            nparen = 0
            for sel in range(len(row)):
                if row[sel] != '':
                    if nparen != 0:
                        pad_control_sv.write("\n                         ")
                    pad_control_sv.write("((pad_mux_i[%s] == %d'd%d) ? %s :" %(index, NBIT_PADMUX, sel, row[sel]))
                    nparen = nparen + 1
            pad_control_sv.write(" 1'b0")
            for i in range(nparen):
                pad_control_sv.write(")")
            pad_control_sv.write(";\n")
        pad_control_sv.write("endmodule\n")
        pad_control_sv.close()

################################################
#
# Generate pad_frame.sv
#
################################################
if args.pad_frame_sv != None:
    with open(args.pad_frame_sv, 'w') as pad_frame_sv:
        #
        # Write Apache license and header
        #
        pad_frame_sv.write("//-----------------------------------------------------\n")
        pad_frame_sv.write("// This is a generated file\n")
        pad_frame_sv.write("//-----------------------------------------------------\n")
        pad_frame_sv.write("// Copyright 2018 ETH Zurich and University of bologna.\n")
        pad_frame_sv.write("// Copyright and related rights are licensed under the Solderpad Hardware\n")
        pad_frame_sv.write("// License, Version 0.51 (the \"License\"); you may not use this file except in\n")
        pad_frame_sv.write("// compliance with the License.  You may obtain a copy of the License at\n")
        pad_frame_sv.write("// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law\n")
        pad_frame_sv.write("// or agreed to in writing, software, hardware and materials distributed under\n")
        pad_frame_sv.write("// this License is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR\n")
        pad_frame_sv.write("// CONDITIONS OF ANY KIND, either express or implied. See the License for the\n")
        pad_frame_sv.write("// specific language governing permissions and limitations under the License.\n")
        pad_frame_sv.write("\n")
        pad_frame_sv.write("`include \"pulp_soc_defines.sv\"\n")
        pad_frame_sv.write("`include \"pulp_peripheral_defines.svh\"\n")
        pad_frame_sv.write("\n")

        pad_frame_sv.write("module pad_frame(\n")
        pad_frame_sv.write("\n")
        pad_frame_sv.write("    input logic [`N_IO-1:0][`NBIT_PADCFG-1:0] pad_cfg_i,\n")
        pad_frame_sv.write("\n")
        pad_frame_sv.write("    // sysio signals\n")
        for ioname in sysio:
            if ioname != '':
                pad_frame_sv.write("    %s logic %s_%s,\n" %('output' if (sysio[ioname] == 'input' or sysio[ioname] == 'snoop') else 'input ', ioname, "o" if (sysio[ioname] == 'input' or sysio[ioname] == 'snoop') else "i"))
        pad_frame_sv.write("\n")
        pad_frame_sv.write("    // internal io signals\n")
        pad_frame_sv.write("    input  logic [`N_IO-1:0] io_out_i,  // data going to pads\n")
        pad_frame_sv.write("    input  logic [`N_IO-1:0] io_oe_i,   // enable going to pads\n")
        pad_frame_sv.write("    output logic [`N_IO-1:0] io_in_o,   // data coming from pads\n")
        pad_frame_sv.write("\n")
        pad_frame_sv.write("    // pad signals\n")
        pad_frame_sv.write("    inout  wire [`N_IO-1:0] io\n")
        pad_frame_sv.write("    );\n")
        pad_frame_sv.write("    // dummy wire to make lint clean\n")
        pad_frame_sv.write("    wire void1;\n")
        pad_frame_sv.write("    // connect io\n")
        for ionum in range(N_IO):
            if sysionames[ionum] != -1:
                pad_frame_sv.write("    `ifndef PULP_FPGA_EMUL\n")
                if sysio[sysionames[ionum][:-2]] == 'output':
                    pad_frame_sv.write("      pad_functional_pu i_pad_%d    (.OEN(1'b1), .I(%s), .O(void1), .PAD(io[%d]), .PEN(1'b1));\n" % (ionum, sysionames[ionum], ionum))
                else:
                    pad_frame_sv.write("      pad_functional_pu i_pad_%d    (.OEN(1'b0), .I(1'b0), .O(%s), .PAD(io[%d]), .PEN(1'b1));\n" % (ionum, sysionames[ionum], ionum))
                pad_frame_sv.write("    `else\n")
                if sysio[sysionames[ionum][:-2]] == 'output':
                    pad_frame_sv.write("      assign io[%d] = %s;\n" %(ionum, sysionames[ionum]))
                elif sysio[sysionames[ionum][:-2]] == 'input':
                    pad_frame_sv.write("      assign %s = io[%d];\n" % (sysionames[ionum], ionum))
                elif sysio[sysionames[ionum][:-2]] == 'snoop':
                    pad_frame_sv.write("    pad_functional_pd i_pad_%d   (.OEN(~io_oe_i[%d]), .I(io_out_i[%d]), .O(io_in_o[%d]), .PAD(io[%d]), .PEN(~pad_cfg_i[%d][0]));\n" %\
                        (ionum, ionum, ionum, ionum, ionum, ionum))
                    pad_frame_sv.write("      assign %s = io_in_o[%d];\n" % (sysionames[ionum], ionum))
                else:
                    print("ERROR: unknown sysio type '%s'" % sysio[sysionames[ionum][:-2]])
                    error_count = error_count + 1
                pad_frame_sv.write("    `endif\n")
            else:
                pad_frame_sv.write("    pad_functional_pu i_pad_%d   (.OEN(~io_oe_i[%d]), .I(io_out_i[%d]), .O(io_in_o[%d]), .PAD(io[%d]), .PEN(~pad_cfg_i[%d][0]));\n" %\
                    (ionum, ionum, ionum, ionum, ionum, ionum))
        pad_frame_sv.write("\n")
        pad_frame_sv.write("endmodule\n")

################################################
#
# Generate pad_frame_gf22.sv
#
################################################
#
# Note:
#   TRIEN:  0x0 for output
#           0x1 for input
#   DATA:   output signal
#   RXEN:   0x0 for output
#           0x1 for input
#   Y:      input signal
#   PAD:    connection to pad
#   PDEN:   0x0 disable? pulldown
#           0x1 enable? pulldown
#   PUEN:   0x0 disable? pullup
#           0x1 enable? pullup
#
################################################
if args.pad_frame_gf22_sv != None:
    with open(args.pad_frame_gf22_sv, 'w') as pad_frame_sv:
        #
        # Write Apache license and header
        #
        pad_frame_sv.write("//-----------------------------------------------------\n")
        pad_frame_sv.write("// This is a generated file\n")
        pad_frame_sv.write("//-----------------------------------------------------\n")
        pad_frame_sv.write("// Copyright 2018 ETH Zurich and University of bologna.\n")
        pad_frame_sv.write("// Copyright and related rights are licensed under the Solderpad Hardware\n")
        pad_frame_sv.write("// License, Version 0.51 (the \"License\"); you may not use this file except in\n")
        pad_frame_sv.write("// compliance with the License.  You may obtain a copy of the License at\n")
        pad_frame_sv.write("// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law\n")
        pad_frame_sv.write("// or agreed to in writing, software, hardware and materials distributed under\n")
        pad_frame_sv.write("// this License is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR\n")
        pad_frame_sv.write("// CONDITIONS OF ANY KIND, either express or implied. See the License for the\n")
        pad_frame_sv.write("// specific language governing permissions and limitations under the License.\n")
        pad_frame_sv.write("\n")
        pad_frame_sv.write("`define DRV_SIG   .NDIN(1'b0), .NDOUT(), .DRV(2'b10), .PWROK(PWROK_S), .IOPWROK(IOPWROK_S), .BIAS(BIAS_S), .RETC(RETC_S)\n")
        pad_frame_sv.write("`define DRV_SIG_I .NDIN(1'b0), .NDOUT(),              .PWROK(PWROK_S), .IOPWROK(IOPWROK_S), .BIAS(BIAS_S), .RETC(RETC_S)\n")
        pad_frame_sv.write("\n")
        pad_frame_sv.write("`include \"pulp_soc_defines.sv\"\n")
        pad_frame_sv.write("\n")

        pad_frame_sv.write("module pad_frame_gf22(\n")
        pad_frame_sv.write("\n")
        pad_frame_sv.write("    input logic [`N_IO-1:0][`NBIT_PADCFG-1:0] pad_cfg_i,\n")
        pad_frame_sv.write("\n")
        pad_frame_sv.write("    // sysio signals\n")
        for ioname in sysio:
            if ioname != '':
                pad_frame_sv.write("    %s logic %s_%s,\n" %('output' if (sysio[ioname] == 'input' or sysio[ioname] == 'snoop') else 'input ', ioname, "o" if (sysio[ioname] == 'input' or sysio[ioname] == 'snoop') else "i"))
        pad_frame_sv.write("\n")
        pad_frame_sv.write("    // internal io signals\n")
        pad_frame_sv.write("    input  logic [`N_IO-1:0] io_out_i,  // data going to pads\n")
        pad_frame_sv.write("    input  logic [`N_IO-1:0] io_oe_i,   // enable going to pads\n")
        pad_frame_sv.write("    output logic [`N_IO-1:0] io_in_o,   // data coming from pads\n")
        pad_frame_sv.write("\n")
        pad_frame_sv.write("    // pad signals\n")
        pad_frame_sv.write("    inout  wire [`N_IO-1:0] io\n")
        pad_frame_sv.write("    );\n")

        pad_frame_sv.write("    // connect io\n")
        for ionum in range(N_IO):
            if sysionames[ionum] != -1:
                if sysio[sysionames[ionum][:-2]] == 'output':
                    # pad_frame_sv.write("      pad_functional_pu i_pad_%d    (.OEN(1'b1), .I( ), .O(%s), .PAD(io[%d]), .PEN(1'b1));\n" % (ionum, sysionames[ionum], ionum))
                    pad_frame_sv.write("    IN22FDX_GPIO18_10M30P_IO_%s i_pad_%d (.TRIEN(1'b0), .DATA(%s), .RXEN(1'b0), .Y(), .PAD(io[%d]), .PDEN(~pad_cfg_i[%d][0]), .PUEN(~pad_cfg_i[%d][1]), `DRV_SIG );;\n" %\
                        ("H", ionum, sysionames[ionum], ionum, ionum, ionum))
                else:
                    # pad_frame_sv.write("      pad_functional_pu i_pad_%d    (.OEN(1'b0), .I(%s), .O( ), .PAD(io[%d]), .PEN(1'b1));\n" % (ionum, sysionames[ionum], ionum))
                    pad_frame_sv.write("    IN22FDX_GPIO18_10M30P_IO_%s i_pad_%d (.TRIEN(1'b1), .DATA(), .RXEN(1'b1), .Y(%s), .PAD(io[%d]), .PDEN(~pad_cfg_i[%d][0]), .PUEN(~pad_cfg_i[%d][1]), `DRV_SIG );;\n" %\
                        ("H", ionum, sysionames[ionum], ionum, ionum, ionum))
            else:
                pad_frame_sv.write("    IN22FDX_GPIO18_10M30P_IO_%s i_pad_%d (.TRIEN(~io_oe_i[%d]), .DATA(io_out_i[%d]), .RXEN(~io_out_i[%d]), .Y(io_in_o[%d]), .PAD(io[%d]), .PDEN(~pad_cfg_i[%d][0]), .PUEN(~pad_cfg_i[%d][1]), `DRV_SIG );;\n" %\
                    ("H", ionum, ionum, ionum, ionum, ionum, ionum, ionum, ionum))
        pad_frame_sv.write("\n")
        pad_frame_sv.write("endmodule\n")

################################################
#
# Generate emulation toplevel (xilinx_core_v_mcu)
#
################################################
if args.xilinx_core_v_mcu_sv != None:
    with open(args.xilinx_core_v_mcu_sv, 'w') as x_sv:
        x_sv.write("//-----------------------------------------------------------------------------\n")
        x_sv.write("// This file is a generated file\n")
        x_sv.write("//-----------------------------------------------------------------------------\n")
        x_sv.write("// Title         : Core-v-mcu Verilog Wrapper\n")
        x_sv.write("//-----------------------------------------------------------------------------\n")
        x_sv.write("// Description :\n")
        x_sv.write("// Verilog Wrapper of Core-v-mcu to use the module within Xilinx IP integrator.\n")
        x_sv.write("//-----------------------------------------------------------------------------\n")
        x_sv.write("// Copyright (C) 2013-2019 ETH Zurich, University of Bologna\n")
        x_sv.write("// Copyright and related rights are licensed under the Solderpad Hardware\n")
        x_sv.write("// License, Version 0.51 (the \"License\"); you may not use this file except in\n")
        x_sv.write("// compliance with the License. You may obtain a copy of the License at\n")
        x_sv.write("// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law\n")
        x_sv.write("// or agreed to in writing, software, hardware and materials distributed under\n")
        x_sv.write("// this License is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR\n")
        x_sv.write("// CONDITIONS OF ANY KIND, either express or implied. See the License for the\n")
        x_sv.write("// specific language governing permissions and limitations under the License.\n")
        x_sv.write("//-----------------------------------------------------------------------------\n")
        x_sv.write("\n")
        x_sv.write("`include \"pulp_soc_defines.sv\"\n")
        x_sv.write("`include \"pulp_peripheral_defines.svh\"\n")
        x_sv.write("\n")
        x_sv.write("module %s\n" % (args.emulation_toplevel))
        x_sv.write("  (\n")
        x_sv.write("    inout wire [`N_IO-1:0]  xilinx_io\n")
        x_sv.write("  );\n")
        x_sv.write("\n")
        x_sv.write("  wire [`N_IO-1:0]  s_io;\n")
        x_sv.write("\n")

        ionum_start = 0
        ionum_end = -1
        for ionum in range(N_IO):
            if sysionames[ionum] != "ref_clk_o" and  sysionames[ionum] != "jtag_tck_o":
                ionum_end = ionum
            else:                       # break in sequence
                if ionum_end >= 0:
                    x_sv.write("  assign s_io[%d:%d] = xilinx_io[%d:%d];\n\n" % (ionum_end, ionum_start, ionum_end, ionum_start))
                ionum_start = ionum+1
                ionum_end = -1
                if sysionames[ionum] == "ref_clk_o":
                    x_sv.write("  // Input clock buffer\n")
                    x_sv.write("  IBUFG #(\n")
                    x_sv.write("    .IOSTANDARD(\"LVCMOS33\"),\n")
                    x_sv.write("    .IBUF_LOW_PWR(\"FALSE\")\n")
                    x_sv.write("  ) i_sysclk_iobuf (\n")
                    x_sv.write("    .I(xilinx_io[%d]),\n" % sysionames.index("ref_clk_o"))
                    x_sv.write("    .O(s_io[%d])\n" % sysionames.index("ref_clk_o"))
                    x_sv.write("  );\n\n")
                if sysionames[ionum] == "jtag_tck_o":
                    x_sv.write("  //JTAG TCK clock buffer (dedicated route is false in constraints)\n")
                    x_sv.write("  IBUF i_tck_iobuf (\n")
                    x_sv.write("    .I(xilinx_io[%d]),\n" % sysionames.index("jtag_tck_o"))
                    x_sv.write("    .O(s_io[%d])\n" % sysionames.index("jtag_tck_o"))
                    x_sv.write("  );\n\n")

        # print remaining connections, if any
        if ionum_end != -1:
            x_sv.write("  assign s_io[%d:%d] = xilinx_io[%d:%d];\n\n" % (ionum_end, ionum_start, ionum_end, ionum_start))

        x_sv.write("  core_v_mcu #(\n")
        x_sv.write("    .USE_FPU(`USE_FPU),\n")
        x_sv.write("    .USE_HWPE(`USE_HWPE)\n")
        x_sv.write("  ) i_core_v_mcu (\n")
        x_sv.write("    .io(s_io)\n")
        x_sv.write("  );\n")
        x_sv.write("endmodule\n")

######################################################################
#
# Process the xdc file
#
######################################################################
if args.input_xdc != None:
    with open(args.input_xdc, 'r') as input_xdc:
        with open(args.output_xdc, 'w') as output_xdc:
            for line in input_xdc:
                elements = line.split()
                if len(elements) > 1 and elements[0] == "#set_property" and elements[10] in xilinx_names:
                    elements[10] = "xilinx_io[" + str(xilinx_names.index(elements[10])) + "]"
                    elements[0] = elements[0][1:]
                    output_xdc.write(' '.join(elements) + "\n")
                elif len(elements) > 1 and elements[0] == "#create_clock" and elements[11] in xilinx_names:
                    elements[11] = "xilinx_io[" + str(xilinx_names.index(elements[11])) + "]"
                    elements[0] = elements[0][1:]
                    output_xdc.write(' '.join(elements) + "\n")
                else:
                    output_xdc.write(line)
        output_xdc.close()
        input_xdc.close()

######################################################################
#
# Write svh files from any register definition files
#
######################################################################
finished_header = False
if args.reg_def_csv != None and args.reg_def_svh != None:
    with open(args.reg_def_csv, 'r') as rdf_input:
        with open(args.reg_def_svh, 'w') as rdf_output:
            reg_table = csv.reader(rdf_input)
            for reg in reg_table:
                if reg[0] == "Module" or reg[0] == "Title":
                    module_name = reg[1]
                if reg[0] == "Register":
                    finished_header = True
                    continue
                if reg[0] != '':
                    regname = reg[1].split('[')
                    rdf_output.write("`define %-25s 'h%s\n" % (regname[0], reg[0].replace("0x","")))
        rdf_output.close();
    rdf_input.close()

######################################################################
#
# Write .h files from any register definition files
#
######################################################################
if args.reg_def_csv != None and args.reg_def_h != None:
    with open(args.reg_def_csv, 'r') as rdf_input:
        reg_table = csv.reader(rdf_input)
        for reg in reg_table:
            if reg[0] == "Module" or reg[0] == "Title":
                x = reg[1].split()
                module_name = x[0]
                break
    rdf_input.close()
    with open(args.reg_def_csv, 'r') as rdf_input:
        with open(args.reg_def_h, 'w') as rdf_output:
            guard_string = "__" + module_name.upper() + "_H_"
            write_license_header(rdf_output, guard_string)
            reg_table = csv.reader(rdf_input)
            regname = ''
            field_name = [0] * 32
            msb_array = [0] * 32
            lsb_array = [0] * 32
            rdf_output.write("\n//---------------------------------//\n")
            rdf_output.write("//\n")
            rdf_output.write("// Module: %s\n" % module_name)
            rdf_output.write("//\n")
            rdf_output.write("//---------------------------------//\n")
            rdf_output.write("\n")
            rdf_output.write("#ifndef __IO\n")
            rdf_output.write("#define __IO volatile\n")
            rdf_output.write("#endif\n")
            rdf_output.write("\n")
            rdf_output.write("#ifndef __I\n")
            rdf_output.write("#define __I volatile\n")
            rdf_output.write("#endif\n")
            rdf_output.write("\n")
            rdf_output.write("#ifndef __O\n")
            rdf_output.write("#define __O volatile\n")
            rdf_output.write("#endif\n")
            rdf_output.write("\n")
            rdf_output.write('#include "stdint.h"\n')
            rdf_output.write("\n")
            rdf_output.write("typedef struct {\n")
            reg_offset = -4
            prev_offset = 0
            reserved_num = 0
            finished_header = False
            for reg in reg_table:
                if reg[0] == "Register":
                    finished_header = True
                    continue
                if not finished_header:
                    continue
                if reg[1] == '':
                    continue
                if reg[0] != '':
                    if regname != '': # spit out previous register
                        if reg_offset != prev_offset + 4:
                            rdf_output.write("  __I uint32_t    unused%d[%d];\n" % (reserved_num, (reg_offset - prev_offset - 4)/4))
                            reserved_num = reserved_num + 1
                        rdf_output.write("\n")
                        rdf_output.write("  // Offset = 0x%04x\n" % (reg_offset))
                        rdf_output.write("  union {\n")
                        rdf_output.write("    __IO uint32_t %s;\n" % (regname.lower()))
                        field_format = "      %-4s uint32_t  %-10s : %2d;\n"
                        if field_num > 0: # got fields to spit out
                            rdf_output.write("    struct {\n")
                            msb = 0
                            for idx in range(field_num-1, -1, -1):
                                if lsb_array[idx] > msb: # got a gap to fill
                                    rdf_output.write(field_format % ("__IO", "", lsb_array[idx] - msb))
                                rdf_output.write(field_format % ("__IO", field_name[idx], msb_array[idx] - lsb_array[idx] + 1))
                                msb = msb_array[idx] + 1
                            rdf_output.write("    } %s;\n" % bittype_from_name(regname))
                        rdf_output.write("  };\n")
                    regname = evaluate_defines(reg[1])
                    prev_offset = reg_offset
                    reg_offset = int(reg[0], 0)
                    # rdf_output.write("#define %-30s %s\n" % ("REG_"+regname, reg[0]))
                    field_num = 0
                else:
                    # see if `define that needs to be replaced
                    for idx, x in enumerate(reg):
                        if '`' in x:
                            for d in soc_defines:
                                if d != '' and d in x:
                                    old = '`'+d
                                    new = soc_defines[d]
                                    x = x.replace(old, new)
                            reg[idx] = x
                    field_name[field_num] = reg[1].lower()
                    msb = reg[2]
                    lsb = reg[3]
                    if msb[0] == '+':
                        msb = msb.replace('+','')
                        msb = str(int(msb) + int(lsb) - 1)
                    width = int(msb) - int(lsb)
                    msb_array[field_num] = int(msb)
                    lsb_array[field_num] = int(lsb)
                    mask = 0xFFFFFFFF >> (32 - width - 1)
                    field_num = field_num + 1
            # spit out last register
            if reg_offset != prev_offset + 4:
                rdf_output.write("  __I uint32_t    unused%d[%d];\n" % (reserved_num, (reg_offset - prev_offset - 4)/4))
                reserved_num = reserved_num + 1
            rdf_output.write("\n")
            rdf_output.write("  // Offset = 0x%04x\n" % (reg_offset))
            rdf_output.write("  union {\n")
            rdf_output.write("    __IO uint32_t %s;\n" % (regname.lower()))
            field_format = "      %-4s uint32_t  %-10s : %2d;\n"
            if field_num > 0: # got fields to spit out
                rdf_output.write("    struct {\n")
                msb = 0
                for idx in range(field_num-1, -1, -1):
                    if lsb_array[idx] > msb: # got a gap to fill
                        rdf_output.write(field_format % ("__IO", "", lsb_array[idx] - msb))
                    rdf_output.write(field_format % ("__IO", field_name[idx], msb_array[idx] - lsb_array[idx] + 1))
                    msb = msb_array[idx] + 1
                rdf_output.write("    } %s;\n" % bittype_from_name(regname))
            rdf_output.write("  };\n")
            rdf_output.write("} %s_t;\n\n\n" % typedef(module_name))
            rdf_input.close();

            with open(args.reg_def_csv, 'r') as rdf_input:
                reg_table = csv.reader(rdf_input)
                regname = ''
                field_name = [0] * 32
                msb_array = [0] * 32
                lsb_array = [0] * 32
                finished_header = False
                for reg in reg_table:
                    if reg[0] == "Register":
                        finished_header = True
                        continue
                    if not finished_header:
                        continue
                    if reg[1] == '':
                        continue
                    if reg[0] != '':
                        regname = remove_subscript(reg[1].upper())
                        regoffset = int(reg[0], 0)
                        rdf_output.write("#define %-30s %s\n" % ("REG_"+regname, reg[0]))
                        field_num = 0
                    else:
                        # see if `define that needs to be replaced
                        for idx, x in enumerate(reg):
                            if '`' in x:
                                reg[idx] = evaluate_defines(x)
                        field_name[field_num] = reg[1]
                        msb = reg[2]
                        lsb = reg[3]
                        if msb[0] == '+':
                            msb = msb.replace('+','')
                            msb = str(int(msb) + int(lsb) - 1)
                        width = int(msb) - int(lsb)
                        msb_array[field_num] = int(msb)
                        lsb_array[field_num] = int(lsb)
                        mask = 0xFFFFFFFF >> (32 - width - 1)
                        rdf_output.write("#define   %-40s %s\n" % ("REG_"+regname+"_"+field_name[field_num]+"_LSB", lsb))
                        rdf_output.write("#define   %-40s 0x%x\n" % ("REG_"+regname+"_"+field_name[field_num]+"_MASK",mask))
                        field_num = field_num + 1
                rdf_output.write("\n")
                rdf_output.write("#ifndef __REGFIELD_OPS_\n")
                rdf_output.write("#define __REGFIELD_OPS_\n")
                rdf_output.write("static inline uint32_t regfield_read(uint32_t reg, uint32_t mask, uint32_t lsb) {\n")
                rdf_output.write("  return (reg >> lsb) & mask;\n")
                rdf_output.write("}\n")
                rdf_output.write("static inline uint32_t regfield_write(uint32_t reg, uint32_t mask, uint32_t lsb, uint32_t value) {\n")
                rdf_output.write("  reg &= ~(mask << lsb);\n")
                rdf_output.write("  reg |= (value & mask) << lsb;\n")
                rdf_output.write("  return reg;\n")
                rdf_output.write("}\n")
                rdf_output.write("#endif  // __REGFIELD_OPS_\n")
            rdf_input.close();
            rdf_output.write("\n")
            rdf_output.write("#endif // %s\n" % guard_string)
    rdf_output.close()

######################################################################
#
# Write .md files from any register definition files
#
######################################################################
if args.reg_def_csv != None and args.reg_def_md != None:
    print("Writing '%s'" % args.reg_def_md)
    with open(args.reg_def_md, 'w') as rdf_output:
        with open(args.reg_def_csv, 'r') as rdf_input:
            reg_table = csv.reader(rdf_input)
            finished_header = False
            for reg in reg_table:
                if reg[0] == "Register" or reg[0] == "Code":
                    finished_header = True
                    break
                if reg[0] == "Module" or reg[0] == "Title":
                    rdf_output.write("# %s\n\n" % evaluate_defines(reg[1]))
                else:
                    rdf_output.write("%s\n" % evaluate_defines(reg[1]))
        rdf_input.close()
        with open(args.reg_def_csv, 'r') as rdf_input:
            reg_table = csv.reader(rdf_input)
            table_format = "| %-4s | %15s | %5s | %-15s |\n"
            finished_header = False
            for reg in reg_table:
                if reg[0] == "Register":
                    break
                if reg[0] == "Code":
                    finished_header = True
                    rdf_output.write(table_format % ("Code", "Command/Field",  "Bits", "Description"))
                    rdf_output.write(table_format % ("---", "--------------", "-----", "-------------------------"))
                    continue
                if not finished_header:
                    continue
                if reg[1] != "":
                    cmdstring = reg[1]
                else:
                    cmdstring = reg[2]
                if len(reg) == 2:
                    rdf_output.write(table_format % (reg[0], reg[1], "", "", ""))
                elif len(reg) >= 5 and reg[3] == '':
                    rdf_output.write(table_format % (reg[0], cmdstring, "", reg[5]))
                elif len(reg) >= 5 and reg[3] != '':
                    rdf_output.write(table_format % (reg[0], cmdstring, reg[3]+":"+reg[4], reg[5]))
        rdf_input.close()
        with open(args.reg_def_csv, 'r') as rdf_input:
            reg_table = csv.reader(rdf_input)
            table_format = "| %-10s | %5s | %5s | %10s | %-15s |\n"
            finished_header = False
            for reg in reg_table:
                if reg[0] == "Register":
                    finished_header = True
                    continue
                if not finished_header:
                    continue
                # see if `define that needs to be replaced
                for idx, x in enumerate(reg):
                    if '`' in x:
                        for d in soc_defines:
                            if d != '' and d in x:
                                old = '`'+d
                                new = soc_defines[d]
                                x = x.replace(old, new)
                        reg[idx] = x
                if reg[0] != '':
                    rdf_output.write("\n### %s offset = %s\n\n" % (reg[1], reg[0]))
                    doneheadder = False
                elif reg[1] != '' or reg[6] != '':
                    if reg[2] != '' and reg[2][0] == '+':
                        val = int(reg[2][1:]) + int(reg[3])
                        reg[2] = str(val-1)
                    if not doneheadder:
                        doneheadder = True
                        rdf_output.write(table_format % ("Field", "Bits", "Type", "Default", "Description"))
                        rdf_output.write(table_format % ("---------------------", "---", "---", "---", "-------------------------"))
                    if reg[2] != '':
                        rdf_output.write(table_format % (reg[1], reg[2]+":"+reg[3], reg[4], reg[5], reg[6]))
                    else:
                        rdf_output.write(table_format % (reg[1], "", reg[4], reg[5], reg[6]))
        rdf_input.close()
        rdf_output.write("\n### Notes:\n")
        rdf_output.write("\n")
        rdf_output.write("| Access type | Description |\n")
        rdf_output.write("| ----------- | ----------- |\n")
        rdf_output.write("| RW          | Read & Write |\n")
        rdf_output.write("| RO          | Read Only    |\n")
        rdf_output.write("| RC          | Read & Clear after read |\n")
        rdf_output.write("| WO          | Write Only |\n")
        rdf_output.write("| WC          | Write Clears (value ignored; always writes a 0) |\n")
        rdf_output.write("| WS          | Write Sets (value ignored; always writes a 1) |\n")
        rdf_output.write("| RW1S        | Read & on Write bits with 1 get set, bits with 0 left unchanged |\n")
        rdf_output.write("| RW1C        | Read & on Write bits with 1 get cleared, bits with 0 left unchanged |\n")
        rdf_output.write("| RW0C        | Read & on Write bits with 0 get cleared, bits with 1 left unchanged |\n")
    rdf_output.close()

######################################################################
#
# Write .md file for pin table
#
######################################################################

if args.pin_table_md != None and args.soc_defines != None and args.pin_table != None:
    print("Writing '%s'" % args.pin_table_md)
    with open(args.pin_table_md, 'w') as rdf_output:
        rdf_output.write("# Pin Assignment\n")
        rdf_output.write("\n| IO | sysio |")
        for i in range(N_PADSEL):
            rdf_output.write(" sel=%d |" % (i))
        rdf_output.write("\n")
        rdf_output.write("| --- | --- |")
        for i in range(N_PADSEL):
            rdf_output.write(" --- |")
        rdf_output.write("\n")
        with open(args.pin_table, 'r') as f_pin_table:
            pin_table = csv.reader(f_pin_table)
            pin_num = -2
            for pin in pin_table:
                pin_num = pin_num + 1
                if pin_num >= 0:
                    # Work to do
                    rdf_output.write("| %s | %s |" % (pin[1], pin[3]))
                    for i in range(N_PADSEL):
                        rdf_output.write(" %s |" % (pin[4+i]))
                    rdf_output.write("\n")

######################################################################
#
# Exit
#
######################################################################
if error_count > 0:
    exit(1)
