#!/usr/bin/env python3
#
# SubIPConfig.py
# Francesco Conti <f.conti@unibo.it>
#
# Copyright (C) 2015-2017 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

from __future__ import print_function
from .IPApproX_common        import *
from .vsim_defines           import *
from .makefile_defines       import *
from .makefile_defines_ncsim import *
from .vivado_defines         import *
from .verilator_defines      import *
from .synopsys_defines       import *
from .cadence_defines        import *
from .SubIPConfig            import *
import sys

# returns true if source file is VHDL
def is_vhdl(f):
    if f[-4:].lower() == ".vhd":
        return True
    else:
        return False

# returns true if source file is Verilog-2001
def is_verilog_2001(f):
    if f[-2:].lower() == ".v":
        return True
    else:
        return False

# list of allowed and mandatory keys for the Yaml dictionary
ALLOWED_KEYS = [
    'incdirs',
    'vlog_opts',
    'vcom_opts',
    'targets',
    'flags',
    'defines',
    'dir',
    'sim_tools',
    'synth_tools',
    'jg_inclibs',
    'jg_slint_top_name',
    'jg_slint_clocks',
    'jg_slint_resets',
    'jg_slint_elab_opt',
    'jg_slint_postelab_cmds'
]
MANDATORY_KEYS = [
    'files'
]

# list of allowed targets
ALLOWED_TARGETS = [
    'all',
    'rtl',
    'verilator',
    'xilinx',
    'st28fdsoi',
    'umc65',
    'tsmc55',
    'tsmc40',
    'gf28',
    'gf22',
    'smic130',
    'smic110'
]

# list of allowed flags
ALLOWED_FLAGS = [
    'skip_simulation',
    'skip_synthesis',
    'skip_verilator',
    'skip_tcsh',
    'only_local'
]

# legacy IPs blacklist (for backwards compatibility with tcsh flow)
LEGACY_TCSH_BLACKLIST = [
    #+ 'common_cells',
    #+ 'cea',
    #+ 'tech'
]
# list of allowed targets
ALLOWED_SIM_TOOLS = [
    'all',
    'questa',
    'xcelium',
    'ncsim'
]

# list of allowed targets
ALLOWED_SYNTH_TOOLS = [
    'all',
    'genus',
    'dc',
    'mentor'
]
class SubIPConfig(object):
    def __init__(self, ip_name, sub_ip_name, sub_ip_dic, ip_path):
        super(SubIPConfig, self).__init__()

        self.ip_name         = ip_name
        self.ip_path         = ip_path
        self.sub_ip_name     = sub_ip_name
        self.sub_ip_name_alt = prepare(sub_ip_name)
        self.sub_ip_dic      = sub_ip_dic

        self.__check_dic()
        self.files     = self.__get_files()     # list of source files in the sub-IP
        self.targets   = self.__get_targets()   # target (all, xilinx, st28fdsoi, umc65, gf28 at the moment)
        self.flags     = self.__get_flags()     # flags (skip_simulation, skip_synthesis, skip_tcsh)
        self.incdirs   = self.__get_incdirs()   # verilog include directory
        self.defines   = self.__get_defines()   # additional defines
        self.vlog_opts = self.__get_vlog_opts() # generic vlog options
        self.vcom_opts = self.__get_vcom_opts() # generic vcom options
        self.sim_tools = self.__get_sim_tools() # eda tools supported (for RTL encrypted models)
        self.synth_tools = self.__get_synth_tools() # eda tools supported (for RTL encrypted models)

    def export_make(self, abs_path, more_opts, target_tech=None, local=False, simulator='vsim'):
        if simulator is "vsim":
            mk_subiprule = MK_SUBIPRULE
            mk_buildcmd_svlog = MK_BUILDCMD_SVLOG
            mk_buildcmd_vhdl = MK_BUILDCMD_VHDL
            vlog_opts = self.vlog_opts
            vcom_opts = self.vcom_opts
            if 'all' not in self.sim_tools and 'questa' not in self.sim_tools:
                return "\n"
        elif simulator is "ncsim":
            mk_subiprule = MKN_SUBIPRULE
            mk_buildcmd_svlog = MKN_BUILDCMD_SVLOG
            mk_buildcmd_vhdl = MKN_BUILDCMD_VHDL
            vlog_opts = ""
            vcom_opts = ""
            if 'all' not in self.sim_tools and 'xcelium' not in self.sim_tools and 'ncsim' not in self.sim_tools:
                return "\n"
        building = True
        if 'all' not in self.targets and 'rtl' not in self.targets and target_tech not in self.targets:
            building = False
        if 'lint' not in self.targets or "skip_synthesis" in self.flags or not linting:
            linting = False
        if not building and not linting:
            return "\n"
        if "only_local" in self.flags and not local:
            return "\n"
        if "skip_simulation" in self.flags:
            return "\n"
        vlog_cmd = ""
        files = self.files
        vlog_includes = ""
        for i in self.incdirs:
            vlog_includes += "+%s/%s" % (abs_path, i)
        vhdl_files = ""
        vlog_files = ""
        for f in files:
            if f[0] == '/':
                if not is_vhdl(f):
                    vlog_files += "\\\n\t%s" % (f)
                else:
                    vhdl_files += "\\\n\t%s" % (f)
            else:
                if not is_vhdl(f):
                    vlog_files += "\\\n\t%s/%s" % (abs_path, f)
                else:
                    vhdl_files += "\\\n\t%s/%s" % (abs_path, f)
        if len(vlog_includes) > 0:
            vlog_cmd += MK_SUBIPINC % (self.sub_ip_name, self.sub_ip_name.upper(), "+incdir" + vlog_includes)
        vlog_cmd += MK_SUBIPSRC % (self.sub_ip_name.upper(), vlog_files, self.sub_ip_name.upper(), vhdl_files)
        vlog_cmd += "\n"
        vlog_rule = ""
        if len(vlog_files) > 0:
            if target_tech=='xilinx':
                defines = "+define+PULP_FPGA_EMUL +define+PULP_FPGA_SIM -suppress 2583"
            elif simulator is 'vsim':
                defines = "-suppress 2583 -suppress 13314"
            else:
                defines = ""
            for d in self.defines:
                defines = "%s +define+%s" % (defines, d)
            vlog_rule += mk_buildcmd_svlog % ("%s %s %s" % (more_opts, vlog_opts, defines), self.sub_ip_name.upper(), self.sub_ip_name.upper())
            vlog_rule += "\n"
            # only add tab if we have vhdl files to add too. Prevents spurious tabs in generated Makefile
            if len(vhdl_files) > 0:
                vlog_rule += "\t"
        if len(vhdl_files) > 0:
            vlog_rule += mk_buildcmd_vhdl % ("%s %s" % (more_opts, vcom_opts), self.sub_ip_name.upper())
            vlog_rule += "\n"
        vlog_cmd += mk_subiprule % (self.sub_ip_name, self.sub_ip_name, self.sub_ip_name, self.sub_ip_name.upper(), self.sub_ip_name.upper(), self.sub_ip_name, vlog_rule, self.sub_ip_name)
        vlog_cmd += "\n"

        return vlog_cmd

    def export_vsim(self, abs_path, more_opts, target_tech='st28fdsoi', local=False):
        if 'all' not in self.targets and 'rtl' not in self.targets and target_tech not in self.targets:
            return "\n"
        if target_tech == 'xilinx':
            return self.__export_vsim_xilinx(abs_path, more_opts)
        if "only_local" in self.flags and local:
            return "\n"
        if "skip_simulation" in self.flags:
            return "\n"
        if "skip_tcsh" in self.flags:
            return "\n"
        if self.ip_name in LEGACY_TCSH_BLACKLIST:
            return "\n"
        vlog_cmd = VSIM_PREAMBLE_SUBIP % (self.sub_ip_name)
        files = self.files
        vlog_includes = ""
        for i in self.incdirs:
            vlog_includes += "%s%s/%s" % (VSIM_VLOG_INCDIR_CMD, abs_path, i)
        defines = "-suppress 2583"
        for d in self.defines:
            defines = "%s +define+%s" % (defines, d)
        for f in files:
            if not is_vhdl(f):
                vlog_cmd += VSIM_VLOG_CMD % ("%s %s %s" % (more_opts, self.vlog_opts, defines), vlog_includes, "%s/%s" % (abs_path, f))
            else:
                vlog_cmd += VSIM_VCOM_CMD % ("%s %s" % (more_opts, self.vcom_opts), "%s/%s" % (abs_path, f))
        return vlog_cmd

    def __export_vsim_xilinx(self, abs_path, more_opts):
        if not ("all" in self.targets or "xilinx" in self.targets):
            return "\n"
        if "skip_simulation" in self.flags:
            return "\n"
        vlog_cmd = VSIM_PREAMBLE_SUBIP % (self.sub_ip_name)
        files = self.files
        vlog_includes = ""
        vlog_opts = " +define+PULP_FPGA_EMUL +define+PULP_FPGA_SIM -suppress 2583"
        for i in self.incdirs:
            vlog_includes += "%s%s/%s" % (VSIM_VLOG_INCDIR_CMD, abs_path, i)
        for f in files:
            if not is_vhdl(f):
                vlog_cmd += VSIM_VLOG_CMD % ("%s %s %s" % (more_opts, vlog_opts, self.vlog_opts), vlog_includes, "%s/%s" % (abs_path, f))
            else:
                vlog_cmd += VSIM_VCOM_CMD % ("%s %s" % (more_opts, self.vcom_opts), "%s/%s" % (abs_path, f))
        return vlog_cmd

    def export_synopsys(self, path, target_tech=None, source='ips'):
        if not ("all" in self.targets or target_tech is None or target_tech in self.targets):
            return "\n"
        if "skip_synthesis" in self.flags:
            return "\n"
        if not ("all" in self.synth_tools or "dc" in self.synth_tools):            
            return "\n"            
        analyze_cmd = SYNOPSYS_ANALYZE_PREAMBLE_SUBIP % (self.sub_ip_name)
        defines = ""
        for d in self.defines:
            defines = "%s -define %s" % (defines, d)
        files = self.files
        for f in files:
            if is_vhdl(f):
                analyze_cmd += SYNOPSYS_ANALYZE_VHDL_CMD % (self.sub_ip_name, source.upper(), "%s/%s" % (path, f))
            elif is_verilog_2001(f):
                analyze_cmd += SYNOPSYS_ANALYZE_V_CMD % (defines, source.upper(), "%s/%s" % (path, f))
            else:
                analyze_cmd += SYNOPSYS_ANALYZE_SV_CMD % (defines, source.upper(), "%s/%s" % (path, f))
        return analyze_cmd



    def export_cadence(self, path, target_tech='st28fdsoi', source='ips'):
        if not ("all" in self.targets or target_tech in self.targets):
            return "\n"
        if "skip_synthesis" in self.flags:
            return "\n"
        if not ("all" in self.synth_tools or "genus" in self.synth_tools):            
            return "\n"
        analyze_cmd = CADENCE_ANALYZE_PREAMBLE_SUBIP % (self.sub_ip_name)
        defines = ""
        for d in self.defines:
            defines = "%s -define %s" % (defines, d)
        files = self.files
        for f in files:
            if not is_vhdl(f):
                analyze_cmd += CADENCE_ANALYZE_SV_CMD % (defines, source.upper(), "%s/%s" % (path, f))
            else:
                analyze_cmd += CADENCE_ANALYZE_VHDL_CMD % (self.sub_ip_name, source.upper(), "%s/%s" % (path, f))
        return analyze_cmd

    def export_ncsim(self, abs_path):
        if not ("all" in self.targets or "rtl" in self.targets):
            return ""
        if "only_local" in self.flags:
            return ""
        if "skip_simulation" in self.flags:
            return ""
        ncsim_files = ""
        if len(self.incdirs) > 0:
            for i in self.incdirs:
                ncsim_files +="-incdir "
                ncsim_files += "%s/%s/%s\n" % (abs_path, self.ip_path, i)
        files = self.files
        for f in files:
            ncsim_files += "%s/%s/%s\n" % (abs_path, self.ip_path, f)

        return ncsim_files
    def export_verilator(self, abs_path):
        if 'all' not in self.targets and 'verilator' not in self.targets:
            return "\n"
        if "skip_verilator" in self.flags:
            return "\n"
        verilator_mk = VERILATOR_PREAMBLE_SUBIP % (self.sub_ip_name, prepare(self.sub_ip_name.upper()))
        files = self.files
        for f in files:
            verilator_mk += "    %s/%s/%s \\\n" % (abs_path, self.ip_path, f)
        verilator_mk += VERILATOR_POSTAMBLE_SUBIP
        if len(self.incdirs) > 0:
            verilator_mk += VERILATOR_PREAMBLE_SUBIP_INCDIRS % prepare(self.sub_ip_name.upper())
            for i in self.incdirs:
                verilator_mk += "    -I%s/%s/%s \\\n" % (abs_path, self.ip_path, i)
            verilator_mk += VERILATOR_POSTAMBLE_SUBIP
        return verilator_mk

    def export_vivado(self, abs_path):
        if not ("all" in self.targets or "xilinx" in self.targets):
            return "\n"
        if "skip_synthesis" in self.flags:
            return "\n"
        vivado_cmd = VIVADO_PREAMBLE_SUBIP % (self.sub_ip_name, prepare(self.sub_ip_name.upper()))
        files = self.files
        for f in files:
            vivado_cmd += "    %s/%s/%s \\\n" % (abs_path, self.ip_path, f)
        vivado_cmd += VIVADO_POSTAMBLE_SUBIP
        if len(self.incdirs) > 0:
            vivado_cmd += VIVADO_PREAMBLE_SUBIP_INCDIRS % prepare(self.sub_ip_name.upper())
            for i in self.incdirs:
                vivado_cmd += "    %s/%s/%s \\\n" % (abs_path, self.ip_path, i)
            vivado_cmd += VIVADO_POSTAMBLE_SUBIP
        return vivado_cmd

    def export_synplify(self, abs_path):
        if not ("all" in self.targets or "xilinx" in self.targets):
            return "\n"
        if "skip_synthesis" in self.flags:
            return "\n"
        synplify_cmd = ""
        files = self.files
        if len(files) == 0:
            files.extend(self.files)
        for f in files:
            if not is_vhdl(f):
                synplify_cmd += "add_file -verilog %s/%s/%s\n" % (abs_path, self.ip_path, f)
            else:
                synplify_cmd += "add_file -vhdl %s/%s/%s\n" % (abs_path, self.ip_path, f)
        return synplify_cmd

    ### management of the Yaml dictionary

    def __check_dic(self):
        dic = self.sub_ip_dic
        if set(MANDATORY_KEYS).intersection(set(dic.keys())) == set([]):
            print("ERROR: there are no files for ip '%s', sub-ip '%s'. Check its src_files.yml file." % (self.ip_name, self.sub_ip_name))
            sys.exit(1)
        not_allowed = set(dic.keys()) - set(MANDATORY_KEYS) - set(ALLOWED_KEYS)
        if not_allowed != set([]):
            print("ERROR: there are unallowed keys for ip '%s', sub-ip '%s':" % (self.ip_name, self.sub_ip_name))
            for el in list(not_allowed):
                print("    %s" % el)
            print("Check the src_files.yml file.")
            sys.exit(1)

    def __get_files(self):
        return self.sub_ip_dic['files']

    def __get_defines(self):
        try:
            defines = self.sub_ip_dic['defines']
        except KeyError:
            defines = []
        return defines

    def __get_flags(self):
        try:
            flags = self.sub_ip_dic['flags']
        except KeyError:
            flags = []
        not_allowed = set(flags) - (set(ALLOWED_FLAGS))
        if not_allowed != set([]):
            print("ERROR: flags not allowed for ip '%s', sub-ip '%s':" % (self.ip_name, self.sub_ip_name))
            print(not_allowed)
            for el in list(not_allowed):
                print("    %s" % el)
            print("Check the src_files.yml file.")
            sys.exit(1)
        return flags

    def __get_targets(self):
        try:
            targets = self.sub_ip_dic['targets']
        except KeyError:
            targets = ["all"]
        not_allowed = set(targets) - (set(ALLOWED_TARGETS))
        if not_allowed != set([]):
            print("ERROR: targets not allowed for ip '%s', sub-ip '%s':" % (self.ip_name, self.sub_ip_name))
            print(not_allowed)
            for el in list(not_allowed):
                print("    %s" % el)
            print("Check the src_files.yml file.")
            sys.exit(1)
        return targets

    def __get_sim_tools(self):
        try:
            sim_tools = self.sub_ip_dic['sim_tools']
        except KeyError:
            sim_tools = ["all"]
        not_allowed = set(sim_tools) - (set(ALLOWED_SIM_TOOLS))
        if not_allowed != set([]):
            print("ERROR: sim_tools not allowed for ip '%s', sub-ip '%s':" % (self.ip_name, self.sub_ip_name))
            print(not_allowed)
            for el in list(not_allowed):
                print("    %s" % el)
            print("Check the src_files.yml file.")
            sys.exit(1)
        return sim_tools

    def __get_synth_tools(self):
        try:
            synth_tools = self.sub_ip_dic['synth_tools']
        except KeyError:
            synth_tools = ["all"]
        not_allowed = set(synth_tools) - (set(ALLOWED_SYNTH_TOOLS))
        if not_allowed != set([]):
            print("ERROR: synth_tools not allowed for ip '%s', sub-ip '%s':" % (self.ip_name, self.sub_ip_name))
            print(not_allowed)
            for el in list(not_allowed):
                print("    %s" % el)
            print("Check the src_files.yml file.")
            sys.exit(1)
        return synth_tools

    def __get_incdirs(self):
        try:
            incdirs = self.sub_ip_dic['incdirs']
        except KeyError:
            incdirs = []
        return incdirs

    def __get_tech(self):
        try:
            tech = self.sub_ip_dic['tech']
        except KeyError:
            tech = False
        return tech

    def __get_vlog_opts(self):
        try:
            vlog_opts = " ".join(self.sub_ip_dic['vlog_opts'])
        except KeyError:
            vlog_opts = ""
        return vlog_opts

    def __get_vcom_opts(self):
        try:
            vcom_opts = " ".join(self.sub_ip_dic['vcom_opts'])
        except KeyError:
            vcom_opts = ""
        return vcom_opts

