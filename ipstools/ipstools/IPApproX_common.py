#!/usr/bin/env python3
#
# IPApproX_common.py
# Francesco Conti <f.conti@unibo.it>
#
# Copyright (C) 2015-2017 ETH Zurich, University of Bologna
# All rights reserved.
#
# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.
#

from __future__ import print_function
import re, os, subprocess, sys, os, stat
try:
    from StringIO import StringIO
except ImportError:
    from io import StringIO
sys.path.append(os.path.abspath("yaml/lib64/python"))
import yaml
if sys.version_info[0] == 2 and sys.version_info[1] >= 7:
    from collections import OrderedDict
elif sys.version_info[0] > 2:
    from collections import OrderedDict
else:
    from ordereddict import OrderedDict
from .ips_defines import *


def prepare(s):
    return re.sub("[^a-zA-Z0-9_]", "_", s)


class tcolors:
    OK = '\033[92m'
    WARNING = '\033[93m'
    ERROR = '\033[91m'
    ENDC = '\033[0m'
    BLUE = '\033[94m'


def execute(cmd, silent=False):
    with open(os.devnull, "w") as devnull:
        if silent:
            stdout = devnull
        else:
            stdout = None

        return subprocess.call(cmd.split(), stdout=stdout)


def execute_out(cmd, silent=False):
    p = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE)
    out, err = p.communicate()

    return out


def execute_popen(cmd, silent=False):
    with open(os.devnull, "w") as devnull:
        if silent:
            return subprocess.Popen(cmd.split(),
                                    stdout=subprocess.PIPE,
                                    stderr=devnull)
        else:
            return subprocess.Popen(cmd.split(), stdout=subprocess.PIPE)


def ordered_load(stream, Loader=yaml.Loader, object_pairs_hook=OrderedDict):
    class OrderedLoader(Loader):
        pass

    def construct_mapping(loader, node):
        loader.flatten_mapping(node)
        return object_pairs_hook(loader.construct_pairs(node))

    OrderedLoader.add_constructor(
        yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG, construct_mapping)
    return yaml.load(stream, OrderedLoader)


def load_ips_list(filename, skip_commit=False):
    # get a list of all IPs that we are interested in from ips_list.yml
    with open(filename, "r") as f:
        ips_list = ordered_load(f, yaml.SafeLoader)
    ips = list()

    if not ips_list:
        return ips

    for i in ips_list.keys():
        if not skip_commit:
            try:
                commit = ips_list[i]['commit']
            except KeyError:
                try:
                    commit = None
                    path = ips_list[i]['path']
                except KeyError:
                    print(
                        tcolors.ERROR +
                        "An ips_list.yml entry must point to a commit or a path."
                        + tcolors.ENDC)
                    sys.exit(1)
        else:
            commit = None
        try:
            domain = ips_list[i]['domain']
        except KeyError:
            domain = None
        try:
            server = ips_list[i]['server']
        except KeyError:
            server = None
        try:
            group = ips_list[i]['group']
        except KeyError:
            group = None
        try:
            path = ips_list[i]['path']
        except KeyError:
            path = i
        name = i.split()[0].split('/')[-1]
        try:
            alternatives = list(
                set.union(set(ips_list[i]['alternatives']), set([name])))
        except KeyError:
            alternatives = None
        ips.append({
            'name': name,
            'commit': commit,
            'server': server,
            'group': group,
            'path': path,
            'domain': domain,
            'alternatives': alternatives
        })
    return ips


def store_ips_list(filename, ips):
    ips_list = OrderedDict()
    for i in ips:
        if i['alternatives'] != None:
            ips_list[i['path']] = {
                'commit': i['commit'],
                'server': i['server'],
                'group': i['group'],
                'domain': i['domain'],
                'alternatives': i['alternatives']
            }
        else:
            ips_list[i['path']] = {
                'commit': i['commit'],
                'server': i['server'],
                'group': i['group'],
                'domain': i['domain']
            }
    with open(filename, "w") as f:
        f.write(IPS_LIST_PREAMBLE)
        f.write(yaml.dump(ips_list))


def get_ips_list_yml(server="git@github.com",
                     group='pulp-platform',
                     name='pulpissimo.git',
                     commit='master',
                     verbose=False):
    with open(os.devnull, "w") as devnull:
        rawcontent_failed = False
        ips_list_yml = "   "
        if "github.com" in server:
            if "tags/" in commit:
                commit = commit[5:]
            if verbose:
                print(
                    "   Fetching ips_list.yml from https://raw.githubusercontent.com/%s/%s/%s/ips_list.yml"
                    % (group, name, commit))
            cmd = "curl https://raw.githubusercontent.com/%s/%s/%s/ips_list.yml" % (
                group, name, commit)
            try:
                curl = subprocess.Popen(cmd.split(),
                                        stdout=subprocess.PIPE,
                                        stderr=devnull)
                cmd = "cat"
                ips_list_yml = subprocess.check_output(cmd.split(),
                                                       stdin=curl.stdout,
                                                       stderr=devnull)
                out = curl.communicate()[0]
            except subprocess.CalledProcessError:
                rawcontent_failed = True
            ips_list_yml = ips_list_yml.decode(sys.stdout.encoding)
        if ips_list_yml[:3] == "404":
            ips_list_yml = ""
        if rawcontent_failed or "github.com" not in server:
            if verbose:
                print("   Fetching ips_list.yml from %s:%s/%s @ %s" %
                      (server, group, name, commit))
            cmd = "git archive --remote=%s:%s/%s %s ips_list.yml" % (
                server, group, name, commit)
            git_archive = subprocess.Popen(cmd.split(),
                                           stdout=subprocess.PIPE,
                                           stderr=devnull)
            cmd = "tar -xO"
            try:
                ips_list_yml = subprocess.check_output(
                    cmd.split(), stdin=git_archive.stdout, stderr=devnull)
                out = git_archive.communicate()[0]
            except subprocess.CalledProcessError:
                ips_list_yml = None
            if ips_list_yml is not None:
                ips_list_yml = ips_list_yml.decode(sys.stdout.encoding)
    return ips_list_yml


def load_ips_list_from_server(server="git@github.com",
                              group='pulp-platform',
                              name='pulpissimo.git',
                              commit='master',
                              verbose=False,
                              skip_commit=False):
    ips_list_yml = get_ips_list_yml(server,
                                    group,
                                    name,
                                    commit,
                                    verbose=verbose)
    if ips_list_yml is None:
        print("No ips_list.yml gathered for %s" % name)
        return []
    f = StringIO(ips_list_yml)
    ips_list = ordered_load(f, yaml.SafeLoader)
    ips = []
    try:
        for i in ips_list.keys():
            if not skip_commit:
                commit = ips_list[i]['commit']
            else:
                commit = None
            try:
                domain = ips_list[i]['domain']
            except KeyError:
                domain = None
            try:
                server = ips_list[i]['server']
            except KeyError:
                server = None
            try:
                group = ips_list[i]['group']
            except KeyError:
                group = None
            try:
                path = ips_list[i]['path']
            except KeyError:
                path = i
            name = i.split()[0].split('/')[-1]
            try:
                alternatives = list(
                    set.union(set(ips_list[i]['alternatives']), set([name])))
            except KeyError:
                alternatives = None
            ips.append({
                'name': name,
                'commit': commit,
                'server': server,
                'group': group,
                'path': path,
                'domain': domain,
                'alternatives': alternatives
            })
    except AttributeError:
        # here it fails silently (by design). it means that at the same time
        #  1. the ip's version is a commit hash, not a branch or tag
        #  2. the https repository is private
        # when both conditions are true, it is not possible to get an updated
        # ips_list.yml without cloning the full IP. Therefore, at the moment
        # we simply treat the IP as being a leaf of the hierarchy tree.
        # This is more a problem in the case of private repositories than for
        # the public, open-source ones of course.
        return []
    return ips
