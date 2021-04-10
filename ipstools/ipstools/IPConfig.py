#!/usr/bin/env python3
#
# IPConfig.py
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

class IPConfig(object):
    def __init__(self, ip_name, ip_dic, ip_path, ips_dir, vsim_dir, domain=None, alternatives=None):
        super(IPConfig, self).__init__()

        self.domain  = domain
        self.alternatives = alternatives
        self.ip_name = ip_name
        self.ip_path = ip_path
        self.ips_dir = ips_dir
        self.vsim_dir = vsim_dir
        self.sub_ips = OrderedDict()

        # if the keyword "files" is in the ip_dic dictionary, then there are no sub-IPs
        try:
            if "files" in ip_dic.keys():
                self.sub_ips[ip_name] = SubIPConfig(ip_name, ip_name, ip_dic, ip_path)
            else:
                for k in ip_dic.keys():
                    self.sub_ips[k] = SubIPConfig(ip_name, k, ip_dic[k], ip_path)
        except AttributeError:
            self.sub_ips = OrderedDict()

    def export_make(self, abs_path, more_opts, target_tech=None, source='ips', local=False, simulator='vsim'):
        if simulator is "vsim":
            mk_preamble = MK_PREAMBLE
            vmake = "vmake"
        elif simulator is "ncsim":
            mk_preamble = MKN_PREAMBLE
            vmake = "nmake"
        ip_path_env = "$(IPS_PATH)" if source=='ips' else "$(RTL_PATH)"
        commands = ""
        phony = ""
        for s in self.sub_ips.keys():
            if ("all" in self.sub_ips[s].targets or "rtl" in self.sub_ips[s].targets or target_tech in self.sub_ips[s].targets):
                if ("skip_simulation" not in self.sub_ips[s].flags and (("only_local" not in self.sub_ips[s].flags) or local)):
                    if simulator == 'vsim':
                        if 'all' in self.sub_ips[s].sim_tools or 'questa' in self.sub_ips[s].sim_tools:
                            commands += "$(LIB_PATH)/%s.%s " % (s, vmake)
                            phony += "vcompile-subip-%s " %s
                    elif simulator == 'ncsim':
                        if 'all' in self.sub_ips[s].sim_tools or 'xcelium' in self.sub_ips[s].sim_tools or 'ncsim' in self.sub_ips[s].sim_tools:
                            commands += "$(LIB_PATH)/%s.%s " % (s, vmake)
                            phony += "ncompile-subip-%s " %s
        if self.ip_path[0] == '/':
            makefile = mk_preamble % (prepare(self.ip_name), '', self.ip_path[1:], phony, commands) 
        else:
            makefile = mk_preamble % (prepare(self.ip_name), ip_path_env, self.ip_path, phony, commands) 
        makefile += MK_POSTAMBLE
        for s in self.sub_ips.keys():
            makefile += self.sub_ips[s].export_make(abs_path, more_opts, target_tech=target_tech, local=local, simulator=simulator)
        return makefile

    def export_vsim(self, abs_path, more_opts, target_tech='st28fdsoi', local=False):
        vsim_script = VSIM_PREAMBLE % (self.vsim_dir, prepare(self.ip_name), self.ip_path)
        for s in self.sub_ips.keys():
            vsim_script += self.sub_ips[s].export_vsim(abs_path, more_opts, target_tech=target_tech, local=local)
        vsim_script += VSIM_POSTAMBLE
        return vsim_script

    def export_synopsys(self, target_tech=None, source='ips'):
        analyze_script = SYNOPSYS_ANALYZE_PREAMBLE % (self.ip_name)
        for s in self.sub_ips.keys():
            analyze_script += self.sub_ips[s].export_synopsys(self.ip_path, target_tech=target_tech, source=source)
        return analyze_script

    def export_cadence(self, target_tech='st28fdsoi', source='ips'):
        analyze_script = CADENCE_ANALYZE_PREAMBLE % (self.ip_name)
        for s in self.sub_ips.keys():
            analyze_script += self.sub_ips[s].export_cadence(self.ip_path, target_tech=target_tech, source=source)
        return analyze_script

    def export_ncsim(self, abs_path):
        ncsim_script = ""
        for s in self.sub_ips.keys():
            ncsim_script += self.sub_ips[s].export_ncsim(abs_path)
        return ncsim_script

    def export_verilator(self, abs_path):
        verilator_mk = ""
        for s in self.sub_ips.keys():
            verilator_mk += self.sub_ips[s].export_verilator(abs_path)
        return verilator_mk

    def export_vivado(self, abs_path):
        vivado_script = ""
        for s in self.sub_ips.keys():
            vivado_script += self.sub_ips[s].export_vivado(abs_path)
        return vivado_script

    def export_synplify(self, abs_path):
        synplify_script = ""
        for s in self.sub_ips.keys():
            synplify_script += self.sub_ips[s].export_synplify(abs_path)
        return synplify_script

    def generate_vivado_add_files(self):
        l = []
        for s in self.sub_ips.keys():
            if (("xilinx" in self.sub_ips[s].targets or "all" in  self.sub_ips[s].targets) and ("skip_synthesis" not in self.sub_ips[s].flags)):
                l.append(prepare(s))
        return l

    def generate_verilator_src(self):
        l = []
        for s in self.sub_ips.keys():
            if (("all" in  self.sub_ips[s].targets or "verilator" in self.sub_ips[s].targets) and ("skip_verilator" not in self.sub_ips[s].flags)):
                l.append(prepare(s))
        return l

    def generate_verilator_inc_dirs(self):
        l = []
        for s in self.sub_ips.keys():
            if (("all" in  self.sub_ips[s].targets or "verilator" in self.sub_ips[s].targets) and ("skip_verilator" not in self.sub_ips[s].flags)):
                l.append(prepare(s))
        return l

    def generate_vivado_add_files(self):
        l = []
        for s in self.sub_ips.keys():
            if (("xilinx" in self.sub_ips[s].targets or "all" in  self.sub_ips[s].targets) and ("skip_synthesis" not in self.sub_ips[s].flags)):
                l.append(prepare(s))
        return l

    def generate_vivado_inc_dirs(self):
        l = []
        for s in self.sub_ips.keys():
            if (("xilinx" in self.sub_ips[s].targets or "all" in  self.sub_ips[s].targets) and ("skip_synthesis" not in self.sub_ips[s].flags)):
                l.extend(self.sub_ips[s].incdirs)
        return l

    def generate_synopsys_inc_dirs(self):
        l = []
        for s in self.sub_ips.keys():
            if (("all" in  self.sub_ips[s].targets) and ("skip_synthesis" not in self.sub_ips[s].flags)):
                l.extend(self.sub_ips[s].incdirs)
        return l