#!/usr/bin/env python3
#
# IPDatabase.py
# Francesco Conti <f.conti@unibo.it>
#
# Copyright (C) 2015-2017 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

from __future__ import print_function
from .IPApproX_common import *
from .IPTreeNode import *
from .vsim_defines import *
from .vivado_defines import *
from .verilator_defines import *
from .makefile_defines import *
from .makefile_defines_ncsim import *
from .IPConfig import *
import signal
import json, gzip
import os, sys
import re

ALLOWED_SOURCES = ["ips", "rtl"]


class IPDatabase(object):
    """Main interaction class for accessing the IP database.

        :param list_path:                   Path where the main `ips_list.yml` and `rtl_list.yml` files are found.
        :type  list_path: str

        :param ips_dir:                     Path where the IPs are to be deployed.
        :type  ips_dir: str

        :param rtl_dir:                     Path where the local RTL files are deployed.
        :type  rtl_dir: str

        :param vsim_dir:                    Path where the simulation platform is set up.
        :type  vsim_dir: str

        :param fpgasim_dir:                 Path where the FPGA simulation platform is set up.
        :type  fpgasim_dir: str

        :param skip_scripts:                If True, do not set up ipstools for script generation.
        :type  skip_scripts: bool

        :param build_deps_tree:             If True, set up the hierarchical IP flow by building dependency trees.
        :type  build_deps_tree: bool

        :param resolve_deps_conflicts:      If True, resolve dependency conflicts in hierarchical IP flow.
        :type  resolve_deps_conflicts: bool

        :param default_server:              Git remote repository to be used if not otherwise specified.
        :type  default_server: str

        :param default_group:               (Default) group to consider in the Git remote repository.
        :type  default_group: str

        :param default_commit:              (Default) branch / tag / commit hash to consider in the Git remote repository.
        :type  default_commit: str

        :param default_site_dependent_path: (Default) site-dependent path for non-Git repositories.
        :type  default_site_dependent_path: str

        :param load_cache:                  If true, load configuration from cache file.
        :type  load_cache: bool

        :param verbose:                     If true, prints all information on the dependencies that are being fetched.
        :type  verbose: bool

    This class is used for interacting with the IP database for:
      1. resolving the IP hierarchy, including dependency conflicts
      2. downloading the necessary IP set
      3. generating scripts for a number of backends
    If `build_deps_tree` and `resolve_deps_conflicts` are set to True, the hierarchical IP flow will be started and the
    user will be asked to resolve IP version conflicts manually in case different version of IPs are referenced throughout
    the dependency tree.

    """

    rtl_dir = "./fe/rtl"
    ips_dir = "./fe/ips"
    vsim_dir = "./fe/sim"

    def __init__(self,
                 list_path=".",
                 ips_dir="./fe/ips",
                 rtl_dir="./fe/rtl",
                 vsim_dir="./fe/sim",
                 fpgasim_dir="./fpga/sim",
                 skip_scripts=False,
                 build_deps_tree=False,
                 resolve_deps_conflicts=False,
                 default_server="git@github.com",
                 default_group='pulp-platform',
                 default_commit='master',
                 default_site_dependent_path='./fe/local_ips',
                 load_cache=False,
                 verbose=False,
                 ips_list_yml_name='ips_list.yml',
                 rtl_list_yml_name='rtl_list.yml'):
        super(IPDatabase, self).__init__()
        self.ips_dir = ips_dir
        self.rtl_dir = rtl_dir
        self.vsim_dir = vsim_dir
        self.fpgasim_dir = fpgasim_dir
        self.ip_dic = OrderedDict()
        self.rtl_dic = OrderedDict()
        self.default_server = default_server
        self.default_group = default_group
        self.default_commit = default_commit
        self.default_site_dependent_path = default_site_dependent_path
        ips_list_yml = "%s/%s" % (list_path, ips_list_yml_name)
        rtl_list_yml = "%s/%s" % (list_path, rtl_list_yml_name)
        try:
            self.ip_list = load_ips_list(ips_list_yml)
        except IOError:
            self.ip_list = []
        try:
            self.rtl_list = load_ips_list(rtl_list_yml, skip_commit=True)
        except IOError:
            self.rtl_list = None
        if build_deps_tree:
            self.generate_deps_tree(verbose=verbose)
        else:
            self.ip_tree = None
        if resolve_deps_conflicts:
            self.ip_list = self.resolve_deps_conflicts(verbose=verbose)
        if load_cache:
            self.load_database()
        if not skip_scripts:
            for ip in self.ip_list:
                ip_full_name = ip['name']
                if ip['path'][:20] == "$SITE_DEPENDENT_PATH":
                    pattern = r'\[(.*)](.*)'
                    match = re.search(pattern, ip['path'][20:])
                    if match is None:
                        ip_path_idx = 0
                        ip_path_suffix = ip['path'][20:]
                    else:
                        try:
                            ip_path_idx = int(match.group(1))
                        except AttributeError:
                            ip_path_idx = 0
                        try:
                            ip_path_suffix = match.group(2)
                        except AttributeError:
                            ip_path_suffix = ""
                    try:
                        site_dependent_path = os.environ['SITE_DEPENDENT_PATH']
                    except KeyError:
                        site_dependent_path = self.default_site_dependent_path
                    if not os.path.isdir(site_dependent_path):
                        print(
                            tcolors.ERROR +
                            "ERROR: you must define the SITE_DEPENDENT_PATH environment variable with a list of valid comma-separated paths."
                            + tcolors.ENDC)
                        sys.exit(1)
                    ip['path'] = (site_dependent_path.split(',')[ip_path_idx] +
                                  ip_path_suffix)
                    ip_full_path = "%s/src_files.yml" % ip['path']
                else:
                    ip_full_path = "%s/%s/%s/src_files.yml" % (
                        list_path, ips_dir, ip['path'])
                self.import_yaml(ip_full_name,
                                 ip_full_path,
                                 ip['path'],
                                 domain=ip['domain'],
                                 alternatives=ip['alternatives'],
                                 ips_dic=self.ip_dic)
            sub_ip_check_list = []
            for i in self.ip_dic.keys():
                sub_ip_check_list.extend(self.ip_dic[i].sub_ips.keys())
            if len(set(sub_ip_check_list)) != len(sub_ip_check_list):
                print(
                    tcolors.WARNING +
                    "WARNING: two sub-IPs have the same name. This can cause trouble!"
                    + tcolors.ENDC)
                blacklist = OrderedDict()
                for el in set(sub_ip_check_list):
                    blacklist[el] = 0
                    for item in sub_ip_check_list:
                        if el == item:
                            blacklist[el] += 1
                for el in blacklist.keys():
                    cnt = blacklist[el]
                    if cnt > 1:
                        print(tcolors.WARNING + "  %s" % el + tcolors.ENDC)
        if not skip_scripts and self.rtl_list is not None:
            for ip in self.rtl_list:
                ip_full_name = ip['name']
                if ip['path'][:20] == "$SITE_DEPENDENT_PATH":
                    pattern = r'\[(.*)](.*)'
                    match = re.search(pattern, ip['path'][20:])
                    if match is None:
                        ip_path_idx = 0
                        ip_path_suffix = ip['path'][20:]
                    else:
                        try:
                            ip_path_idx = int(match.group(1))
                        except AttributeError:
                            ip_path_idx = 0
                        try:
                            ip_path_suffix = match.group(2)
                        except AttributeError:
                            ip_path_suffix = ""
                    try:
                        site_dependent_path = os.environ['SITE_DEPENDENT_PATH']
                    except KeyError:
                        site_dependent_path = self.default_site_dependent_path
                    if not os.path.isdir(site_dependent_path):
                        print(
                            tcolors.ERROR +
                            "ERROR: you must define the SITE_DEPENDENT_PATH environment variable with a list of valid comma-separated paths."
                            + tcolors.ENDC)
                        sys.exit(1)
                    ip['path'] = (site_dependent_path.split(',')[ip_path_idx] +
                                  ip_path_suffix)
                    ip_full_path = "%s/src_files.yml" % ip['path']
                else:
                    ip_full_path = "%s/%s/%s/src_files.yml" % (
                        list_path, rtl_dir, ip['path'])
                self.import_yaml(ip_full_name,
                                 ip_full_path,
                                 ip['path'],
                                 domain=ip['domain'],
                                 alternatives=ip['alternatives'],
                                 ips_dic=self.rtl_dic,
                                 ips_dir=rtl_dir)
            sub_ip_check_list = []
            for i in self.rtl_dic.keys():
                sub_ip_check_list.extend(self.rtl_dic[i].sub_ips.keys())
            if len(set(sub_ip_check_list)) != len(sub_ip_check_list):
                print(
                    tcolors.WARNING +
                    "WARNING: two sub-IPs have the same name. This can cause trouble!"
                    + tcolors.ENDC)
                blacklist = OrderedDict()
                for el in set(sub_ip_check_list):
                    blacklist[el] = 0
                    for item in sub_ip_check_list:
                        if el == item:
                            blacklist[el] += 1
                for el in blacklist.keys():
                    cnt = blacklist[el]
                    if cnt > 1:
                        print(tcolors.WARNING + "  %s" % el + tcolors.ENDC)

    def save_database(self, filename='.cached_ipdb.json', gzip=False):
        """Saves the IP database state in a cache JSON gzipped file.

            :param filename:     Name fo the JSON cache file (defaults to '.cached_ipdb.json.gz').
            :type  filename: str

        This function saves the IP database state in a cache JSON gzipped file.

        """
        self_dict = {
            'ips_dir': self.ips_dir,
            'rtl_dir': self.rtl_dir,
            'vsim_dir': self.vsim_dir,
            'fpgasim_dir': self.fpgasim_dir,
            'ip_list': self.ip_list,
            'rtl_list': self.rtl_list
        }
        if gzip:
            with gzip.open(filename, "w") as f:
                f.write(json.dumps(self_dict, indent=4))
        else:
            with open(filename, "w") as f:
                f.write(json.dumps(self_dict, indent=4))

    def load_database(self, filename='.cached_ipdb.json'):
        """Loads the IP database state from a cache JSON gzipped file.

            :param filename:     Name fo the JSON cache file (defaults to '.cached_ipdb.json.gz').
            :type  filename: str

        This function loads the IP database state from a cache JSON gzipped file.

        """
        if filename[-3:-1] == ".gz":
            with gzip.open(filename, "r") as f:
                json_dump = f.read()
        else:
            with open(filename, "r") as f:
                json_dump = f.read()
        self_dict = json.loads(json_dump)
        self.ips_dir = self_dict['ips_dir']
        self.rtl_dir = self_dict['rtl_dir']
        self.vsim_dir = self_dict['vsim_dir']
        self.fpgasim_dir = self_dict['fpgasim_dir']
        self.ip_list = self_dict['ip_list']
        self.rtl_list = self_dict['rtl_list']

    def generate_deps_tree(self, verbose=False):
        """Generates the IP dependency tree for the IP hierarchical flow.

            :param verbose:             If true, prints all information on the dependencies that are being fetched.
            :type  verbose: bool

        This function generates the dependency tree for all IPs by looking in the provided remote repository.

        """
        children = []
        # add all directly referenced IPs to the tree
        print(
            "Retrieving ips_list.yml dependency list for all IPs (may take some time)..."
        )

        for i in range(len(self.ip_list)):
            ip = self.ip_list[i]
            children.append(
                IPTreeNode(ip,
                           self.default_server,
                           self.default_group,
                           self.default_commit,
                           verbose=True))

        root = IPTreeNode(None, children=children)
        self.ip_tree = root
        print(tcolors.OK + "Generated IP dependency tree." + tcolors.ENDC)

    def resolve_deps_conflicts(self, verbose=False):
        """Resolves the IP dependency conflicts in the IP hierarchical flow.

            :param verbose:             If true, prints all information on the dependencies that are being fetched.
            :type  verbose: bool

            :returns: `list` -- the final list of IPs after resolving all conflicts.

        This function resolves conflicts between IPs in a hierarchical flow by calling for the user's intervention.
        """

        conflicts = self.ip_tree.get_conflicts()
        selected = OrderedDict()
        for c in conflicts.keys():
            if len(conflicts[c]) == 1:
                selected[c] = conflicts[c][0]
                continue
            print(tcolors.WARNING + "Conflict for IP %s" % c + tcolors.ENDC)
            for i, el in enumerate(conflicts[c]):
                if el.father is None:
                    if verbose:
                        print(
                            "  %d. %s:%s/%s @ %s (retrieved from local root repository)"
                            % (i + 1, el.itself['server'], el.itself['group'],
                               c, el.itself['commit']))
                    else:
                        print(
                            "  %d. %s/%s @ %s (retrieved from local root repository)"
                            % (i + 1, el.itself['group'], c,
                               el.itself['commit']))
                else:
                    if verbose:
                        print(
                            "  %d. %s:%s/%s @ %s (retrieved from %s:%s/%s @ %s)"
                            % (i + 1, el.itself['server'], el.itself['group'],
                               c, el.itself['commit'], el.father['server'],
                               el.father['group'], el.father['name'],
                               el.father['commit']))
                    else:
                        print("  %d. %s/%s @ %s (retrieved from %s/%s @ %s)" %
                              (i + 1, el.itself['group'], c,
                               el.itself['commit'], el.father['group'],
                               el.father['name'], el.father['commit']))
            flag = False
            signal.signal(signal.SIGINT, signal.default_int_handler)
            while not flag:
                try:
                    std_in = input(
                        "Select the desired alternative (1-%d, CTRL+C to exit hierarchical flow): "
                        % (len(conflicts[c])))
                except KeyboardInterrupt:
                    print(
                        tcolors.WARNING +
                        "\nEscaped from IP choice, switching from hierarchical IP flow to flat IP flow."
                        + tcolors.ENDC)
                    return
                if not std_in.isdigit():
                    print(tcolors.WARNING +
                          "Alternative selected is not a number." +
                          tcolors.ENDC)
                elif int(std_in) < 1 or int(std_in) > len(conflicts[c]):
                    print(tcolors.WARNING +
                          "Alternative selected is not within 1-%d." %
                          (len(conflicts[c])) + tcolors.ENDC)
                else:
                    flag = True
                    selected[c] = conflicts[c][int(std_in) - 1]
        new_ips_list = []
        for s in selected.values():
            new_ips_list.append(s.node)
        return new_ips_list

    def import_yaml(self,
                    ip_name,
                    filename,
                    ip_path,
                    domain=None,
                    alternatives=None,
                    ips_dic=None,
                    ips_dir=None):
        """Generates a new :class:`IPConfig` for an IP and adds it to the :class:`IPDatabase` internal dictionary.

            :param ip_name:             Name of the IP
            :type  ip_name: str

            :param filename:            Path to the IP's `src_files.yml`
            :type  filename: str

            :param ip_path:             Path to the IP
            :type  ip_path: str

            :param domain:              IP domain for multi-domain synthesis (e.g. SOC and CLUSTER)
            :type  domain: str

            :param alternatives:        IP alternatives for interchangeable IPs (e.g. riscv vs zero-riscy)
            :type  alternatives: str

            :param ips_dic:             Dictionary of IPs that is being referenced
            :type  ips_dic: dict

            :param ips_dir:             IPs directory in the local repo
            :type  ips_dir: str

        This function calls for the generation of an :class:`IPConfig` for an IP, given an external request.
        """
        if ips_dic is None:
            ips_dic = self.ip_dic
        if ips_dir is None:
            ips_dir = self.ips_dir
        if not os.path.exists(os.path.dirname(filename)):
            print(tcolors.ERROR + "ERROR: ip '%s' IP path %s does not exist." %
                  (ip_name, filename) + tcolors.ENDC)
            sys.exit(1)
        try:
            with open(filename, "r") as f:
                ips_yaml_dic = ordered_load(f, yaml.SafeLoader)
        except IOError:
            print(tcolors.WARNING +
                  "WARNING: Skipped ip '%s' as it has no src_files.yml file." %
                  ip_name + tcolors.ENDC)
            print(filename)
            return

        try:
            ips_dic[ip_name] = IPConfig(ip_name,
                                        ips_yaml_dic,
                                        ip_path,
                                        ips_dir,
                                        self.vsim_dir,
                                        domain=domain,
                                        alternatives=alternatives)
        except KeyError:
            print(
                tcolors.WARNING +
                "WARNING: Skipped ip '%s' with %s config file as it seems it is already in the ip database."
                % (ip_name, filename) + tcolors.ENDC)

    def diff_ips(self):
        """Performs `git diff` for each of the IPs referenced by the tool.
        """
        prepend = "  "
        ips = self.ip_list
        cwd = os.getcwd()
        unstaged_ips = []
        staged_ips = []
        for ip in ips:
            try:
                # print "Diffing " + tcolors.WARNING + "%s" % ip['name'] + tcolors.ENDC + "..."
                os.chdir("%s/%s" % (self.ips_dir, ip['path']))
                output, err = execute_popen(
                    "git diff --name-only").communicate()
                unstaged_out = ""
                if output.decode().split("\n")[0] != "":
                    for line in output.decode().split("\n"):
                        l = line.split()
                        try:
                            unstaged_out += "%s%s\n" % (prepend, l[0])
                        except IndexError:
                            break
                output, err = execute_popen(
                    "git diff --cached --name-only").communicate()
                staged_out = ""
                if output.decode().split("\n")[0] != "":
                    for line in output.decode().split("\n"):
                        l = line.split()
                        try:
                            staged_out += "%s%s\n" % (prepend, l[0])
                        except IndexError:
                            break
                os.chdir(cwd)
                if unstaged_out != "":
                    print("Changes not staged for commit in ip " +
                          tcolors.WARNING + "'%s'" % ip['name'] +
                          tcolors.ENDC + ".")
                    print(unstaged_out)
                    unstaged_ips.append(ip)
                if staged_out != "":
                    print("Changes staged for commit in ip " +
                          tcolors.WARNING + "'%s'" % ip['name'] +
                          tcolors.ENDC + ".\nUse " + tcolors.BLUE +
                          "git reset HEAD" + tcolors.ENDC +
                          " in the ip directory to unstage.")
                    print(staged_out)
                    staged_ips.append(ip)
            except OSError:
                print(tcolors.WARNING +
                      "WARNING: Skipping ip '%s'" % ip['name'] +
                      " as it doesn't exist." + tcolors.ENDC)
        return (unstaged_ips, staged_ips)

    def remove_ips(self, skip_check=False):
        """Removes the currently downloaded IPs.

            :param skip_check:          If set to True, removes all IPs without checking for changes first
            :type  skip_check: bool

        This function removes the currently downloaded IPs, after having checked whether there are changes to be committed / pushed first.
        """
        ips = self.ip_list
        cwd = os.getcwd()
        unstaged_ips, staged_ips = self.diff_ips()
        os.chdir(self.ips_dir)
        if not skip_check and (len(unstaged_ips) + len(staged_ips) > 0):
            print(
                tcolors.ERROR +
                "ERROR: Cowardly refusing to remove IPs as there are changes."
                + tcolors.ENDC)
            print(
                "If you *really* want to remove ips, run remove-ips.py with the --skip-check flag."
            )
            sys.exit(1)
        for ip in ips:
            import shutil
            for root, dirs, files in os.walk('%s' % ip['path']):
                for f in files:
                    os.unlink(os.path.join(root, f))
                for d in dirs:
                    shutil.rmtree(os.path.join(root, d))
            try:
                os.removedirs("%s" % ip['path'])
            except OSError:
                pass
        print(tcolors.OK + "Removed all IPs listed in ips_list.yml." +
              tcolors.ENDC)
        os.chdir(cwd)
        try:
            os.removedirs(self.ips_dir)
        except OSError:
            print(tcolors.WARNING +
                  "WARNING: Not removing %s as there are unknown IPs there." %
                  (self.ips_dir) + tcolors.ENDC)

    def update_ips(self, origin='origin', force_downgrade=True):
        """Updates the IPs against the given repository.

            :param origin:             The GIT remote to be used (by default 'origin')
            :type  origin: str

            :param force_downgrade:    If true, download specified version even if current version is newer.
            :type  force_downgrade: bool

        This function updates the currently downloaded IPs, after having checked whether the IPs are actually GIT repos and they
        are not in detached mode. If the IPs are not there yet, they are cloned.
        """
        errors = []
        ips = self.ip_list
        git = "git"
        # make sure we are in the correct directory to start
        owd = os.getcwd()
        os.chdir(self.ips_dir)
        cwd = os.getcwd()

        for ip in ips:

            # check if path is SITE_DEPENDENT, in that case skip it
            if ip['path'][:20] == "$SITE_DEPENDENT_PATH":
                continue

            os.chdir(cwd)
            # check if directory already exists, this hints to the fact that we probably already cloned it
            if os.path.isdir("./%s" % ip['path']):
                os.chdir("./%s" % ip['path'])

                # now check if the directory is a git directory
                if not os.path.isdir(".git"):
                    print(
                        tcolors.ERROR +
                        "ERROR: Found a normal directory instead of a git directory at %s. You may have to delete this folder to make this script work again"
                        % os.getcwd() + tcolors.ENDC)
                    errors.append("%s - %s: Not a git directory" %
                                  (ip['name'], ip['path']))
                    continue

                print(tcolors.OK + "\nUpdating ip '%s'..." % ip['name'] +
                      tcolors.ENDC)

                # fetch everything first so that all commits are available later
                ret = execute("%s fetch" % (git))
                if ret != 0:
                    print(tcolors.ERROR + "ERROR: could not fetch ip '%s'." %
                          (ip['name']) + tcolors.ENDC)
                    errors.append("%s - Could not fetch" % (ip['name']))
                    continue

                # make sure we have the correct branch/tag for the pull
                date_current = int(
                    execute_out("%s show -s --format=%%ct HEAD" %
                                git).rstrip())
                lines = execute_out("%s show -s --format=%%ct %s" %
                                    (git, ip['commit'])).splitlines()
                date_specified = int(lines[-1])

                if (date_current > date_specified) and not force_downgrade:
                    current_commit = execute_out(
                        "%s rev-parse --abbrev-ref HEAD" %
                        git).rstrip().decode('UTF-8')
                    print(
                        tcolors.WARNING +
                        "Current commit '%s' is more recent than specified commit '%s'.\nAre you trying out a new IP version? Will not downgrade version of ip '%s'"
                        % (current_commit, ip['commit'], ip['name']) +
                        tcolors.ENDC)
                else:
                    ret = execute("%s checkout %s" % (git, ip['commit']))
                    if ret != 0:
                        print(tcolors.ERROR +
                              "ERROR: could not checkout ip '%s' at %s." %
                              (ip['name'], ip['commit']) + tcolors.ENDC)
                        errors.append("%s - Could not checkout commit %s" %
                                      (ip['name'], ip['commit']))
                        continue

                # only do the pull if we are not in detached head mode
                stdout = execute_out("%s rev-parse --abbrev-ref HEAD" % (git))
                if stdout[:4].decode(sys.stdout.encoding) != "HEAD":
                    if (date_current > date_specified) and not force_downgrade:
                        ret = execute("%s pull --ff-only %s %s" %
                                      (git, origin, current_commit))
                    else:
                        ret = execute("%s pull --ff-only %s %s" %
                                      (git, origin, ip['commit']))
                    if ret != 0:
                        print(tcolors.ERROR +
                              "ERROR: could not update ip '%s'" % ip['name'] +
                              tcolors.ENDC)
                        errors.append("%s - Could not update" % (ip['name']))
                        continue

            # Not yet cloned, so we have to do that first
            else:
                os.chdir("./")

                print(tcolors.OK + "\nCloning ip '%s'..." % ip['name'] +
                      tcolors.ENDC)

                # compose remote name
                server = ip['server'] if ip[
                    'server'] is not None else self.default_server
                group = ip['group'] if ip[
                    'group'] is not None else self.default_group
                if server[:5] == "https" or server[:6] == "git://":
                    ip['remote'] = "%s/%s" % (server, group)
                else:
                    ip['remote'] = "%s:%s" % (server, group)

                ret = execute("%s clone %s/%s.git %s" %
                              (git, ip['remote'], ip['name'], ip['path']))
                if ret != 0:
                    print(
                        tcolors.ERROR +
                        "ERROR: could not clone, you probably have to remove the '%s' directory."
                        % ip['name'] + tcolors.ENDC)
                    errors.append("%s - Could not clone" % (ip['name']))
                    continue
                os.chdir("./%s" % ip['path'])
                ret = execute("%s checkout %s" % (git, ip['commit']))
                if ret != 0:
                    print(tcolors.ERROR +
                          "ERROR: could not checkout ip '%s' at %s." %
                          (ip['name'], ip['commit']) + tcolors.ENDC)
                    errors.append("%s - Could not checkout commit %s" %
                                  (ip['name'], ip['commit']))
                    continue
        os.chdir(cwd)
        print('\n\n')
        print(tcolors.WARNING + "SUMMARY" + tcolors.ENDC)
        if len(errors) == 0:
            print(tcolors.OK + "IPs updated successfully!" + tcolors.ENDC)
        else:
            for error in errors:
                print(tcolors.ERROR + '    %s' % (error) + tcolors.ENDC)
            print()
            print(tcolors.ERROR + "ERRORS during IP update!" + tcolors.ENDC)
            sys.exit(1)
        os.chdir(owd)

    def flatten_ips(self, origin='origin', squash=False, dry_run=False):
        """Merges in all IPs as subtrees into this repository. The result is a
        flattened repository with a merged history of all IPs' histories. This
        is manually reversible.

            :param origin:             The GIT remote to be used (by default 'origin')
            :type  origin: str

            :param squash:             If true, squash the IPs' history before flattening (merging) them.
            :type  squash: bool

            :param dry_run:            If true, just pretend to flatten. Useful for seeing what commands are being run.
            :type  dry_run: bool

        """
        errors = []
        ips = self.ip_list
        git = "git"
        # make sure we are in the correct directory to start
        owd = os.getcwd()
        os.chdir(self.ips_dir)
        cwd = os.getcwd()

        for ip in ips:
            # check if path is SITE_DEPENDENT, in that case skip it
            if ip['path'][:20] == "$SITE_DEPENDENT_PATH":
                continue

            os.chdir(cwd)
            # check if directory already exists, this hints to the fact that we probably already cloned it
            if os.path.isdir("./%s" % ip['path']):
                errors.append(
                    """%s - %s: exists already. git subtree only works when the path is not yet
                existing""" % (ip['name'], ip['path']))

            # Not yet cloned, so we have to do that first
            else:
                os.chdir(owd)

                print(tcolors.OK + "\nFlattening IP '%s'..." % ip['name'] +
                      tcolors.ENDC)

                # compose remote name
                server = ip['server'] if ip[
                    'server'] is not None else self.default_server
                group = ip['group'] if ip[
                    'group'] is not None else self.default_group
                if server[:5] == "https" or server[:6] == "git://":
                    ip['remote'] = "%s/%s" % (server, group)
                else:
                    ip['remote'] = "%s:%s" % (server, group)

                flatten_cmd = (
                    "%s subtree add --prefix ips/%s%s %s/%s.git %s" %
                    (git, ip['path'], ' --squash' if squash else '',
                     ip['remote'], ip['name'], ip['commit']))
                print(flatten_cmd)

                ret = 0
                if not (dry_run):
                    ret = execute(flatten_cmd)
                if ret != 0:
                    print(tcolors.ERROR +
                          """ERROR: could not git subtree, the remote probably
doesn't exist OR is not reachable. You can try to refer to tags. You could also try to to remove
the '%s' directory.""" % ip['name'] + tcolors.ENDC)
                    errors.append("%s - Could not git subtree" % (ip['name']))
                    continue

        os.chdir(cwd)
        print('\n\n')
        print(tcolors.WARNING + "SUMMARY" + tcolors.ENDC)
        if len(errors) == 0:
            print(tcolors.OK + "IPs flattened (merged) successfully!!" +
                  tcolors.ENDC)
        else:
            for error in errors:
                print(tcolors.ERROR + '    %s' % (error) + tcolors.ENDC)
            print()
            print(tcolors.ERROR + "ERRORS during IP flattening!" +
                  tcolors.ENDC)
            sys.exit(1)
        os.chdir(owd)

    def delete_tag_ips(self, tag_name):
        """Deletes a tag for all IPs.

            :param tag_name:        The tag to be removed
            :type  tag_name: str

        This function removes a tag to all IPs (no safety checks).
        """
        cwd = os.getcwd()
        ips = self.ip_list
        new_ips = []
        for ip in ips:
            os.chdir("%s/%s" % (self.ips_dir, ip['path']))
            ret = execute("git tag -d %s" % tag_name)
            os.chdir(cwd)

    def push_tag_ips(self, tag_name=None):
        """Pushes a tag for all IPs.

            :param tag_name:             If not None, the name of the tag - else, the latest tag is pushed.
            :type  tag_name: str or None

        Pushes the latest tagged version, or a specific tag, for all IPs.
        """
        cwd = os.getcwd()
        ips = self.ip_list
        new_ips = []
        for ip in ips:
            os.chdir("%s/%s" % (self.ips_dir, ip['path']))
            if tag_name == None:
                newest_tag = execute_popen("git describe --tags --abbrev=0",
                                           silent=True).communicate()
                try:
                    newest_tag = newest_tag[0].split()
                    newest_tag = newest_tag[0]
                except IndexError:
                    pass
            else:
                newest_tag = tag_name
            ret = execute("git push origin tags/%s" % newest_tag)
            os.chdir(cwd)

    # def push_ips(self, remote_name, remote):
    #     cwd = os.getcwd()
    #     ips = self.ip_list
    #     new_ips = []
    #     for ip in ips:
    #         os.chdir("%s/%s" % (self.ips_dir, ip['path']))
    #         ret = execute("git remote add %s %s/%s.git" % (remote_name, remote, ip['name']))
    #         ret = execute("git push %s master" % remote_name)
    #         os.chdir(cwd)

    def tag_ips(self,
                tag_name,
                changes_severity='warning',
                tag_always=False,
                store=False):
        """Tags all IPs.

            :param tag_name:              The name of the tag
            :type  tag_name: str

            :param changes_severity:      'warning' or 'error'
            :type  changes_severity: str

            :param tag_always:            If True, tag even if an identical tag already exists
            :type  tag_always: bool

        This function checks the newest tag, staged and unstaged changes; if it found changes it throws a warning or dies depending
        on the `changes_severity` setting. If no identical tag exists or `tag_always` is set to True, the current HEAD of the IP will
        be tagged with the given `tag_name`.
        """
        cwd = os.getcwd()
        ips = self.ip_list
        new_ips = []
        for ip in ips:
            os.chdir("%s/%s" % (self.ips_dir, ip['path']))
            newest_tag, err = execute_popen("git describe --tags --abbrev=0",
                                            silent=True).communicate()
            unstaged_changes, err = execute_popen(
                "git diff --name-only").communicate()
            staged_changes, err = execute_popen(
                "git diff --cached --name-only").communicate()
            if staged_changes.split("\n")[0] != "":
                if changes_severity == 'warning':
                    print(
                        tcolors.WARNING +
                        "WARNING: skipping ip '%s' as it has changes staged for commit."
                        % ip['name'] + tcolors.ENDC + "\nSolve, commit and " +
                        tcolors.BLUE + "git tag %s" % tag_name + tcolors.ENDC +
                        " manually.")
                    os.chdir(cwd)
                    continue
                else:
                    print(tcolors.ERROR +
                          "ERROR: ip '%s' has changes staged for commit." %
                          ip['name'] + tcolors.ENDC +
                          "\nSolve and commit before trying to auto-tag.")
                    sys.exit(1)
            if unstaged_changes.split("\n")[0] != "":
                if changes_severity == 'warning':
                    print(
                        tcolors.WARNING +
                        "WARNING: skipping ip '%s' as it has unstaged changes."
                        % ip['name'] + tcolors.ENDC + "\nSolve, commit and " +
                        tcolors.BLUE + "git tag %s" % tag_name + tcolors.ENDC +
                        " manually.")
                    os.chdir(cwd)
                    continue
                else:
                    print(tcolors.ERROR +
                          "ERROR: ip '%s' has unstaged changes." % ip['name'] +
                          tcolors.ENDC +
                          "\nSolve and commit before trying to auto-tag.")
                    sys.exit(1)
            if newest_tag != "":
                output, err = execute_popen("git diff --name-only tags/%s" %
                                            newest_tag).communicate()
            else:
                output = ""
            if output.decode().split(
                    "\n")[0] != "" or newest_tag == "" or tag_always:
                ret = execute("git tag %s" % tag_name)
                if ret != 0:
                    print(
                        tcolors.WARNING +
                        "WARNING: could not tag ip '%s', probably the tag already exists."
                        % (ip['name']) + tcolors.ENDC)
                else:
                    print("Tagged ip " + tcolors.WARNING +
                          "'%s'" % ip['name'] + tcolors.ENDC +
                          " with tag %s." % tag_name)
                newest_tag = tag_name
            try:
                newest_tag = newest_tag.split()[0]
            except IndexError:
                pass
            new_ips.append({
                'name': ip['name'],
                'path': ip['path'],
                'server': ip['server'],
                'domain': ip['domain'],
                'alternatives': ip['alternatives'],
                'group': ip['group'],
                'commit': "tags/%s" % newest_tag
            })
            os.chdir(cwd)

        if store:
            store_ips_list("new_ips_list.yml", new_ips)

    def get_latest_ips(self,
                       changes_severity='warning',
                       new_ips_list='new_ips_list.yml'):
        """Collects current versions for all IPs.

            :param tag_name:              The name of the tag
            :type  tag_name: str

            :param changes_severity:      'warning' or 'error'
            :type  changes_severity: str

            :param new_ips_ist:           Name of the new `ips_list.yml` file (defaults to `new_ips_list.yml`)
            :type  new_ips_ist: str

        This function collects the latest version of all IPs from the local repo and stores it in a new `ips_list.yml` file.
        If there are changes (staged or unstaged) it will throw a warning, or die if `changes_severity` is set to 'error'.
        """
        cwd = os.getcwd()
        ips = self.ip_list
        new_ips = []
        for ip in ips:
            os.chdir("%s/%s" % (self.ips_dir, ip['path']))
            #commit, err = execute_popen("git checkout master", silent=True).communicate()
            #commit, err = execute_popen("git pull", silent=True).communicate()
            #commit, err = execute_popen("git log -n 1 --format=format:%H", silent=True).communicate()
            commit, err = execute_popen("git describe --tags --always",
                                        silent=True).communicate()
            unstaged_changes, err = execute_popen(
                "git diff --name-only").communicate()
            staged_changes, err = execute_popen(
                "git diff --cached --name-only").communicate()
            if staged_changes.decode().split("\n")[0] != "":
                if changes_severity == 'warning':
                    print(
                        tcolors.WARNING +
                        "WARNING: skipping ip '%s' as it has changes staged for commit."
                        % ip['name'] + tcolors.ENDC +
                        "\nSolve and commit manually.")
                    os.chdir(cwd)
                    continue
                else:
                    print(
                        tcolors.ERROR +
                        "ERROR: ip '%s' has changes staged for commit." %
                        ip['name'] + tcolors.ENDC +
                        "\nSolve and commit before trying to get latest version."
                    )
                    sys.exit(1)
            if unstaged_changes.decode().split("\n")[0] != "":
                if changes_severity == 'warning':
                    print(
                        tcolors.WARNING +
                        "WARNING: skipping ip '%s' as it has unstaged changes."
                        % ip['name'] + tcolors.ENDC +
                        "\nSolve and commit manually.")
                    os.chdir(cwd)
                    continue
                else:
                    print(
                        tcolors.ERROR +
                        "ERROR: ip '%s' has unstaged changes." % ip['name'] +
                        tcolors.ENDC +
                        "\nSolve and commit before trying to get latest version."
                    )
                    sys.exit(1)
            new_ips.append({
                'name': ip['name'],
                'path': ip['path'],
                'server': ip['server'],
                'domain': ip['domain'],
                'alternatives': ip['alternatives'],
                'group': ip['group'],
                'commit': "%s" % commit.decode().rstrip()
            })
            os.chdir(cwd)

        store_ips_list(new_ips_list, new_ips)

    def export_make(self,
                    abs_path="$(IP_PATH)",
                    script_path="./",
                    more_opts="",
                    source='ips',
                    target_tech=None,
                    local=False,
                    simulator='vsim'):
        """Exports Makefiles and scripts to build the simulation platform.

            :param abs_path:              The path to be used in Makefiles to find the IPs
            :type  abs_path: str

            :param script_path:           The path where the Makefiles are collected
            :type  script_path: str

            :param source:                Can be set to 'ips' or 'rtl' to use the `ips_list.yml` IPs or `rtl_list.yml` IPs respectively
            :type  source: str

            :param target_tech:           Target silicon / FPGA technology to be used for script generation
            :type  target_tech: None or str

            :param local:                 If set to True, files set to be used only locally (e.g. specific IP testbenches) are built
            :type  local: bool

            :param simulator:             'vsim' or 'ncsim'
            :type  simulator: str

        This function exports Makefiles and scripts to build the simulation platform to be used with Mentor ModelSim/QuestaSim or Cadence NCSim.
        """
        if source not in ALLOWED_SOURCES:
            print(
                tcolors.ERROR +
                "ERROR: export_make() accepts source='ips' or source='rtl', check generate_scripts.py."
                + tcolors.ENDC)
            sys.exit(1)
        if source == 'ips':
            ip_dic = self.ip_dic
        elif source == 'rtl':
            ip_dic = self.rtl_dic
        for i in ip_dic.keys():
            filename = "%s/%s.mk" % (script_path, i)
            makefile = ip_dic[i].export_make(abs_path,
                                             more_opts,
                                             target_tech=target_tech,
                                             source=source,
                                             local=local,
                                             simulator=simulator)
            with open(filename, "w") as f:
                f.write(makefile)

    def export_synopsys(self,
                        script_path=".",
                        target_tech=None,
                        source='ips',
                        domain=None):
        """Exports analyze scripts to be used for ASIC synthesis in Synopsys Design Compiler.

            :param script_path:           The path where the Makefiles are collected
            :type  script_path: str

            :param target_tech:           Target silicon technology to be used for script generation
            :type  target_tech: None str

            :param domain:                If not None, the domain to be targeting for script generation
            :type  domain: str or None

        This function exports analyze scripts to be used for ASIC synthesis in Synopsys Design Compiler.
        """
        if source not in ALLOWED_SOURCES:
            print(
                tcolors.ERROR +
                "ERROR: export_make() accepts source='ips' or source='rtl', check generate_scripts.py."
                + tcolors.ENDC)
            sys.exit(1)
        if source == 'ips':
            ip_dic = self.ip_dic
        elif source == 'rtl':
            ip_dic = self.rtl_dic
        for i in ip_dic.keys():
            try:
                if domain == None or domain in ip_dic[i].domain:
                    filename = "%s/%s.tcl" % (script_path, i)
                    analyze_script = ip_dic[i].export_synopsys(
                        target_tech=target_tech, source=source)
                    with open(filename, "w") as f:
                        f.write(analyze_script)
            except TypeError:
                if ip_dic[i].domain is None:
                    filename = "%s/%s.tcl" % (script_path, i)
                    analyze_script = ip_dic[i].export_synopsys(
                        target_tech=target_tech, source=source)
                    with open(filename, "w") as f:
                        f.write(analyze_script)

    def export_cadence(self,
                       script_path=".",
                       target_tech='tsmc55',
                       source='ips',
                       domain=None):
        """Exports analyze scripts to be used for ASIC synthesis in Cadence RTL Compiler.

            :param script_path:           The path where the Makefiles are collected
            :type  script_path: str

            :param target_tech:           Target silicon technology to be used for script generation
            :type  target_tech: str

            :param domain:                If not None, the domain to be targeting for script generation
            :type  domain: str or None

        This function exports analyze scripts to be used for ASIC synthesis in Cadence RTL Compiler.
        """
        if source not in ALLOWED_SOURCES:
            print(
                tcolors.ERROR +
                "ERROR: export_make() accepts source='ips' or source='rtl', check generate_scripts.py."
                + tcolors.ENDC)
            sys.exit(1)
        if source == 'ips':
            ip_dic = self.ip_dic
        elif source == 'rtl':
            ip_dic = self.rtl_dic
        for i in ip_dic.keys():
            try:
                if domain == None or domain in ip_dic[i].domain:
                    filename = "%s/%s.tcl" % (script_path, i)
                    analyze_script = ip_dic[i].export_cadence(
                        target_tech=target_tech, source=source)
                    with open(filename, "w") as f:
                        f.write(analyze_script)
            except TypeError:
                if ip_dic[i].domain is None:
                    filename = "%s/%s.tcl" % (script_path, i)
                    analyze_script = ip_dic[i].export_cadence(
                        target_tech=target_tech, source=source)
                    with open(filename, "w") as f:
                        f.write(analyze_script)

    def export_verilator(self,
                         script_path="Makefile.verilator",
                         root='.',
                         source='ips',
                         domain=None,
                         alternatives=[]):
        """Exports a Makefile to be used to build a verilator simulation flow

            :param script_path:           The path where the Makefiles are collected
            :type  script_path: str

            :param root:                  The path to which the script is placed relative to. By default the current directory.
            :type  root: str

            :param domain:                If not None, the domain to be targeting for script generation
            :type  domain: str or None

            :param alternatives:          If not empty, the list of alternative IPs to be actually used.
            :type  alternatives: list

        This function exports a Makefile to be used to build a verilator simulation flow
        """
        if source not in ALLOWED_SOURCES:
            print(
                tcolors.ERROR +
                "ERROR: export_make() accepts source='ips' or source='rtl', check generate_scripts.py."
                + tcolors.ENDC)
            sys.exit(1)
        if source == 'ips':
            ip_dic = self.ip_dic
            abs_path = '${IPS}'
        elif source == 'rtl':
            ip_dic = self.rtl_dic
            abs_path = '${RTL}'
        filename = "%s" % (script_path)
        verilator_mk = VERILATOR_PREAMBLE % (os.path.abspath(
            root), self.rtl_dir, os.path.abspath(root), self.ips_dir)
        for i in ip_dic.keys():
            if ip_dic[i].alternatives == None or set.intersection(
                    set([ip_dic[i].ip_name]), set(alternatives),
                    set(ip_dic[i].alternatives)) != set([]):
                try:
                    if domain == None or domain in ip_dic[i].domain:
                        verilator_mk += ip_dic[i].export_verilator(abs_path)
                except TypeError:
                    verilator_mk += ip_dic[i].export_verilator(abs_path)
        verilator_mk += self.generate_verilator_inc_dirs(source=source)
        verilator_mk += "\n\n"
        verilator_mk += self.generate_verilator_src(source=source)
        with open(filename, "w") as f:
            f.write(verilator_mk)

    def export_vivado(self,
                      script_path="./src_files.tcl",
                      root='.',
                      source='ips',
                      domain=None,
                      alternatives=[]):
        """Exports analyze scripts to be used for FPGA synthesis in Xilinx Vivado.

            :param script_path:           The path where the Makefiles are collected
            :type  script_path: str

            :param target_tech:           Target silicon technology to be used for script generation
            :type  target_tech: str

            :param domain:                If not None, the domain to be targeting for script generation
            :type  domain: str or None

            :param alternatives:          If not empty, the list of alternative IPs to be actually used.
            :type  alternatives: list

        This function exports analyze scripts to be used for FPGA synthesis in Xilinx Vivado.
        """
        if source not in ALLOWED_SOURCES:
            print(
                tcolors.ERROR +
                "ERROR: export_make() accepts source='ips' or source='rtl', check generate_scripts.py."
                + tcolors.ENDC)
            sys.exit(1)
        if source == 'ips':
            ip_dic = self.ip_dic
            abs_path = '$IPS'
        elif source == 'rtl':
            ip_dic = self.rtl_dic
            abs_path = '$RTL'
        filename = "%s" % (script_path)
        vivado_script = VIVADO_PREAMBLE % (os.path.abspath(root), self.rtl_dir,
                                           os.path.abspath(root), self.ips_dir)
        for i in ip_dic.keys():
            if ip_dic[i].alternatives == None or set.intersection(
                    set([ip_dic[i].ip_name]), set(alternatives),
                    set(ip_dic[i].alternatives)) != set([]):
                try:
                    if domain == None or domain in ip_dic[i].domain:
                        vivado_script += ip_dic[i].export_vivado(abs_path)
                except TypeError:
                    vivado_script += ip_dic[i].export_vivado(abs_path)
        with open(filename, "w") as f:
            f.write(vivado_script)

    def generate_vsim_tcl(self, filename, source='ips'):
        """Exports the `vsim.tcl` script.

            :param filename:              Output TCL script file name.
            :type  filename: str

            :param source:                'ips' or 'rtl'
            :type  source: str

        This function exports the `vsim.tcl` script necessary to perform the `vopt` or `vsim` stage in ModelSim/QuestaSim.
        """
        if source not in ALLOWED_SOURCES:
            print(
                tcolors.ERROR +
                "ERROR: generate_vsim_tcl() accepts source='ips' or source='rtl', check generate_scripts.py."
                + tcolors.ENDC)
            sys.exit(1)
        l = []
        ip_dic = self.ip_dic if source == 'ips' else self.rtl_dic
        for i in ip_dic.keys():
            l.append(i)
        vsim_tcl = VSIM_TCL_PREAMBLE % ('IP'
                                        if source == 'ips' else source.upper())
        for el in l:
            vsim_tcl += VSIM_TCL_CMD % prepare(el)
        vsim_tcl += VSIM_TCL_POSTAMBLE
        with open(filename, "w") as f:
            f.write(vsim_tcl)

    def generate_ncsim_command_list(self,
                                    script_path="./src_files.f",
                                    root='.',
                                    source='ips',
                                    domain=None,
                                    alternatives=[]):
        """Exports command script to be used for compilation and elaboration in ncsim or Xcelium.

            :param script_path:           The path where the command file is placed relative to the root variable
            :type  script_path: str

            :param root:                  The path to which the script is placed relative to. By default the current directory.
            :type  root: str

            :param domain:                If not None, the domain to be targeting for script generation
            :type  domain: str or None

            :param alternatives:          If not empty, the list of alternative IPs to be actually used.
            :type  alternatives: list

        This function exports command scripts to be used for simulation with ncsim or Xcelium.
        """
        if source not in ALLOWED_SOURCES:
            print(
                tcolors.ERROR +
                "ERROR: export_make() accepts source='ips' or source='rtl', check generate_scripts.py."
                + tcolors.ENDC)
            sys.exit(1)
        if source == 'ips':
            ip_dic = self.ip_dic
            abs_path = os.path.abspath(root) + '/' + self.ips_dir
        elif source == 'rtl':
            ip_dic = self.rtl_dic
            abs_path = os.path.abspath(root) + '/' + self.rtl_dir
        filename = "%s" % (script_path)
        ncsim_script = ""
        for i in ip_dic.keys():
            if ip_dic[i].alternatives == None or set.intersection(
                    set([ip_dic[i].ip_name]), set(alternatives),
                    set(ip_dic[i].alternatives)) != set([]):
                try:
                    if domain == None or domain in ip_dic[i].domain:
                        ncsim_script += ip_dic[i].export_ncsim(abs_path)
                except TypeError:
                    ncsim_script += ip_dic[i].export_ncsim(abs_path)
        with open(filename, "w") as f:
            f.write(ncsim_script)

    def generate_ncelab_list(self, filename, source='ips'):
        """Exports the `ncelab.list` list.

            :param filename:              Output ncelab list file name.
            :type  filename: str

            :param source:                'ips' or 'rtl'
            :type  source: str

        This function exports the `ncelab.list` script necessary to perform the `ncelab` stage in NCsim.
        """
        if source not in ALLOWED_SOURCES:
            print(
                tcolors.ERROR +
                "ERROR: generate_ncelab_list() accepts source='ips' or source='rtl', check generate_scripts.py."
                + tcolors.ENDC)
            sys.exit(1)
        l = []
        ip_dic = self.ip_dic if source == 'ips' else self.rtl_dic
        for i in ip_dic.keys():
            l.append(i)
        ncelab_list = NCELAB_LIST_PREAMBLE % (source.upper())
        for el in l:
            ncelab_list += NCELAB_LIST_CMD % prepare(el)
        with open(filename, "w") as f:
            f.write(ncelab_list)

    def generate_synopsys_list(self,
                               filename,
                               source='ips',
                               analyze_path='analyze',
                               domain=None):
        """Exports the a TCL list of Synopsys analyze scripts.

            :param filename:              Output script file name.
            :type  filename: str

            :param source:                'ips' or 'rtl'
            :type  source: str

            :param analyze_path:          Path to analyze scripts.
            :type  analyze_path: str

            :param domain:                If not None, the domain to be targeting for script generation
            :type  domain: str or None

        This function exports a script with a list of analyze scripts to be called for the given IP domain.
        """
        if source not in ALLOWED_SOURCES:
            print(
                tcolors.ERROR +
                "ERROR: generate_synopsys_list() accepts source='ips' or source='rtl', check generate_scripts.py."
                + tcolors.ENDC)
            sys.exit(1)
        l = []
        ip_dic = self.ip_dic if source == 'ips' else self.rtl_dic
        synopsys_list = ""
        for i in ip_dic.keys():
            try:
                if domain == None or domain in ip_dic[i].domain:
                    synopsys_list += "source %s/%s.tcl\n" % (analyze_path, i)
            except TypeError:
                if ip_dic[i].domain is None:
                    synopsys_list += "source %s/%s.tcl\n" % (analyze_path, i)

        with open(filename, "w") as f:
            f.write(synopsys_list)

    def generate_makefile(self, filename, target_tech=None, source='ips'):
        """Exports the mid-level Makefiles for simulation.

            :param filename:              Output Makefile file name.
            :type  filename: str

            :param target_tech:           Target silicon or FPGA technology.
            :type  target_tech: str or None

            :param source:                'ips' or 'rtl'
            :type  source: str

        This function exports the mid-level Makefiles for building the simulation platform.
        """
        if source not in ALLOWED_SOURCES:
            print(
                tcolors.ERROR +
                "ERROR: generate_makefile() accepts source='ips' or source='rtl', check generate_scripts.py."
                + tcolors.ENDC)
            sys.exit(1)
        l = []
        if source == 'ips':
            mk_libs_cmd = MK_LIBS_CMD
            for i in self.ip_dic.keys():
                l.append(i)
        elif source == 'rtl':
            mk_libs_cmd = MK_LIBS_CMD_RTL
            for i in self.rtl_dic.keys():
                l.append(i)
        vcompile_libs = MK_LIBS_PREAMBLE
        if target_tech != "xilinx":
            for el in l:
                vcompile_libs += mk_libs_cmd % (el, "build")
        else:
            for el in l:
                vcompile_libs += mk_libs_cmd % (el, "build")

        vcompile_libs += "\n"
        vcompile_libs += MK_LIBS_LIB
        if target_tech != "xilinx":
            for el in l:
                vcompile_libs += mk_libs_cmd % (el, "lib")
        else:
            for el in l:
                vcompile_libs += mk_libs_cmd % (el, "lib")
        vcompile_libs += "\n"
        vcompile_libs += MK_LIBS_CLEAN
        if target_tech != "xilinx":
            for el in l:
                vcompile_libs += mk_libs_cmd % (el, "clean")
        else:
            for el in l:
                vcompile_libs += mk_libs_cmd % (el, "clean")
        vcompile_libs += "\n"
        with open(filename, "w") as f:
            f.write(vcompile_libs)

    def generate_verilator_src(self,
                               domain=None,
                               source='ips',
                               alternatives=[]):
        if source not in ALLOWED_SOURCES:
            print(
                tcolors.ERROR +
                "ERROR: generate_verilator_src() accepts source='ips' or source='rtl', check generate_scripts.py."
                + tcolors.ENDC)
            sys.exit(1)
        if source == 'ips':
            ip_dic = self.ip_dic
        elif source == 'rtl':
            ip_dic = self.rtl_dic
        l = []
        verilator_src = "SRC_%s=" % (source.upper())
        for i in ip_dic.keys():
            if ip_dic[i].alternatives == None or set.intersection(
                    set([ip_dic[i].ip_name]), set(alternatives),
                    set(ip_dic[i].alternatives)) != set([]):
                try:
                    if domain == None or domain in ip_dic[i].domain:
                        l.extend(ip_dic[i].generate_verilator_src())
                except TypeError:
                    l.extend(ip_dic[i].generate_verilator_src())
        for el in l:
            verilator_src += VERILATOR_ADD_FILES_CMD % el.upper()
        return verilator_src

    def generate_verilator_inc_dirs(self,
                                    domain=None,
                                    source='ips',
                                    alternatives=[]):
        if source not in ALLOWED_SOURCES:
            print(
                tcolors.ERROR +
                "ERROR: generate_verilator_src() accepts source='ips' or source='rtl', check generate_scripts.py."
                + tcolors.ENDC)
            sys.exit(1)
        if source == 'ips':
            ip_dic = self.ip_dic
        elif source == 'rtl':
            ip_dic = self.rtl_dic
        l = []
        verilator_src = "INC_%s=" % (source.upper())
        for i in ip_dic.keys():
            if ip_dic[i].alternatives == None or set.intersection(
                    set([ip_dic[i].ip_name]), set(alternatives),
                    set(ip_dic[i].alternatives)) != set([]):
                try:
                    if domain == None or domain in ip_dic[i].domain:
                        l.extend(ip_dic[i].generate_verilator_inc_dirs())
                except TypeError:
                    l.extend(ip_dic[i].generate_verilator_inc_dirs())
        for el in l:
            verilator_src += VERILATOR_INC_DIRS_CMD % el.upper()
        return verilator_src

    def generate_vivado_add_files(self,
                                  filename,
                                  domain=None,
                                  source='ips',
                                  alternatives=[]):
        """Exports the Vivado `add_files` script.

            :param filename:              Output script file name.
            :type  filename: str

            :param domain:                If not None, the domain to be targeting for script generation
            :type  domain: str or None

            :param target_tech:           Target silicon or FPGA technology.
            :type  target_tech: str or None

            :param source:                'ips' or 'rtl'
            :type  source: str

            :param alternatives:          If not empty, the list of alternative IPs to be actually used.
            :type  alternatives: list

        Exports the Vivado `add_files` script.
        """
        if source not in ALLOWED_SOURCES:
            print(
                tcolors.ERROR +
                "ERROR: generate_vivado_add_files() accepts source='ips' or source='rtl', check generate_scripts.py."
                + tcolors.ENDC)
            sys.exit(1)
        if source == 'ips':
            ip_dic = self.ip_dic
        elif source == 'rtl':
            ip_dic = self.rtl_dic
        l = []
        vivado_add_files_cmd = ""
        for i in ip_dic.keys():
            if ip_dic[i].alternatives == None or set.intersection(
                    set([ip_dic[i].ip_name]), set(alternatives),
                    set(ip_dic[i].alternatives)) != set([]):
                try:
                    if domain == None or domain in ip_dic[i].domain:
                        l.extend(ip_dic[i].generate_vivado_add_files())
                except TypeError:
                    l.extend(ip_dic[i].generate_vivado_add_files())
        for el in l:
            vivado_add_files_cmd += VIVADO_ADD_FILES_CMD % el.upper()
        with open(filename, "w") as f:
            f.write(vivado_add_files_cmd)

    def generate_vivado_inc_dirs(self,
                                 filename,
                                 domain=None,
                                 root='.',
                                 source='ips',
                                 alternatives=[]):
        """Exports the Vivado `inc_dirs` script.

            :param filename:              Output script file name.
            :type  filename: str

            :param domain:                If not None, the domain to be targeting for script generation
            :type  domain: str or None

            :param target_tech:           Target silicon or FPGA technology.
            :type  target_tech: str or None

            :param source:                'ips' or 'rtl'
            :type  source: str

            :param alternatives:          If not empty, the list of alternative IPs to be actually used.
            :type  alternatives: list

        Exports the Vivado `inc_dirs` script.
        """
        if source not in ALLOWED_SOURCES:
            print(
                tcolors.ERROR +
                "ERROR: generate_vivado_inc_dirs() accepts source='ips' or source='rtl', check generate_scripts.py."
                + tcolors.ENDC)
            sys.exit(1)
        if source == 'ips':
            ip_dic = self.ip_dic
            gen_dir = self.ips_dir
        elif source == 'rtl':
            ip_dic = self.rtl_dic
            gen_dir = self.rtl_dir
        l = []
        vivado_inc_dirs = VIVADO_INC_DIRS_PREAMBLE % (os.path.abspath(root),
                                                      self.rtl_dir)

        for i in ip_dic.keys():
            if ip_dic[i].alternatives == None or set.intersection(
                    set([ip_dic[i].ip_name]), set(alternatives),
                    set(ip_dic[i].alternatives)) != set([]):
                try:
                    if domain == None or domain in ip_dic[i].domain:
                        incdirs = []
                        path = ip_dic[i].ip_path

                        for j in ip_dic[i].generate_vivado_inc_dirs():
                            incdirs.append("%s/%s" % (path, j))
                        l.extend(incdirs)
                except TypeError:
                    incdirs = []
                    path = ip_dic[i].ip_path
                    for j in ip_dic[i].generate_vivado_inc_dirs():
                        incdirs.append("%s/%s" % (path, j))
                    l.extend(incdirs)
        for el in l:
            vivado_inc_dirs += VIVADO_INC_DIRS_CMD % (os.path.abspath(root),
                                                      gen_dir, el)
        vivado_inc_dirs += VIVADO_INC_DIRS_POSTAMBLE
        with open(filename, "w") as f:
            f.write(vivado_inc_dirs)

    def generate_synopsys_inc_dirs(self,
                                   filename,
                                   domain=None,
                                   root='.',
                                   source='ips',
                                   alternatives=[]):
        """Exports the Synopsys `inc_dirs` script.

            :param filename:              Output script file name.
            :type  filename: str

            :param domain:                If not None, the domain to be targeting for script generation
            :type  domain: str or None

            :param target_tech:           Target silicon or FPGA technology.
            :type  target_tech: str or None

            :param source:                'ips' or 'rtl'
            :type  source: str

            :param alternatives:          If not empty, the list of alternative IPs to be actually used.
            :type  alternatives: list

        Exports the Synopsys `inc_dirs` script.
        """
        if source not in ALLOWED_SOURCES:
            print(
                tcolors.ERROR +
                "ERROR: generate_synopsys_inc_dirs() accepts source='ips' or source='rtl', check generate_scripts.py."
                + tcolors.ENDC)
            sys.exit(1)
        if source == 'ips':
            ip_dic = self.ip_dic
        elif source == 'rtl':
            ip_dic = self.rtl_dic
        l = []
        synopsys_inc_dirs = SYNOPSYS_INC_DIRS_PREAMBLE % (
            os.path.abspath(root), self.rtl_dir)
        for i in ip_dic.keys():
            if ip_dic[i].alternatives == None or set.intersection(
                    set([ip_dic[i].ip_name]), set(alternatives),
                    set(ip_dic[i].alternatives)) != set([]):
                try:
                    if domain == None or domain in ip_dic[i].domain:
                        incdirs = []
                        path = ip_dic[i].ip_path
                        for j in ip_dic[i].generate_synopsys_inc_dirs():
                            incdirs.append("%s/%s" % (path, j))
                        l.extend(incdirs)
                except TypeError:
                    incdirs = []
                    path = ip_dic[i].ip_path
                    for j in ip_dic[i].generate_synopsys_inc_dirs():
                        incdirs.append("%s/%s" % (path, j))
                    l.extend(incdirs)
        for el in l:
            synopsys_inc_dirs += SYNOPSYS_INC_DIRS_CMD % (
                os.path.abspath(root), self.ips_dir, el)
        synopsys_inc_dirs += SYNOPSYS_INC_DIRS_POSTAMBLE
        with open(filename, "w") as f:
            f.write(synopsys_inc_dirs)
