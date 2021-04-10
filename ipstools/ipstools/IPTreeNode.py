#!/usr/bin/env python3
#
# IPTreeNode.py
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

class IPTreeNode(object):
    """Represents a node in the IP hierarchy tree.

        :param node:                Dictionary representing the current IP.
        :type  node: dict    

        :param default_server:      (Default) git remote repository to be used.
        :type  default_server: str                         

        :param default_group:       (Default) group to consider in the Git remote repository.
        :type  default_group: str                  

        :param default_commit:      (Default) branch / tag / commit hash to consider in the Git remote repository.
        :type  default_commit: str            

        :param children:            Normally is None - used only to provide a children list to the root :class:`IPTreeNode`.
        :type  children: list                

        :param father:              Dictionary representing the father of the current IP (None for the root :class:`IPTreeNode`).
        :type  father: dict                 

        :param verbose:             If true, prints all information on the dependencies that are being fetched.
        :type  verbose: bool

    This class represents a node in the IP hierarchy tree. It is used to construct
    the list of all dependencies so that it is possible to resolve conflicts.                       

    """

    def __init__(self,
        node,
        default_server='https://github.com',
        default_group='pulp-platform',
        default_commit='master',
        children=None,
        father=None,
        verbose=False
    ):

        super(IPTreeNode, self).__init__()
        self.node = node
        self.father = father
        self.itself = None
        if children is not None:
            self.children = children
            return
        if node['server'] is not None:
            server = node['server']
        else:
            server = default_server
        if node['group'] is not None:
            group = node['group']
        else:
            group = default_group
        if node['commit'] is not None:
            commit = node['commit']
        else:
            commit = default_commit
        ips = load_ips_list_from_server(server, group, node['name'], commit, verbose=verbose)
        father_of_children = {
            'server' : server,
            'group'  : group,
            'name'   : node['name'],
            'commit' : commit
        }
        self.itself = father_of_children
        children = []
        for ip in ips:
            children.append(IPTreeNode(ip, default_server, default_group, default_commit, father=father_of_children, verbose=verbose))
        self.children = children

    def flattenize_children(self):
        """Constructs a flat list of all descendant IPTreeNode's.

            :returns: `list` -- Flat list of all descendants of self.                 

        """

        flat_list = []
        for c in self.children:
            flat_list.extend(c.flattenize_children())
            flat_list.append(c)
        return flat_list

    def get_conflicts(self):
        """Constructs a flat dictionary with all descendant IPTreeNode's categorized by IP name, pruning redundancies.

            :returns: `dict` -- Dictionary of all descendant IPTreeNode's.

        """

        flat_list = self.flattenize_children()
        conflict_dict = OrderedDict()
        # create a dictionary of possible conflicts
        for f in flat_list:
            conflict_dict[f.node['name']] = []
        # populate the conflict dictionary
        for f in flat_list:
            if f not in conflict_dict[f.node['name']]:
                conflict_dict[f.node['name']].append(f)
            for g in flat_list:
                if f is not g and f.node['name'] == g.node['name']:
                    if g not in conflict_dict[f.node['name']]:
                        conflict_dict[f.node['name']].append(g)
        # evict empty entries from the conflict dictionary
        nodes_to_remove = []
        for ck in conflict_dict.keys():
            if len(conflict_dict[ck]) < 1:
                nodes_to_remove.append(ck)
        for ck in nodes_to_remove:
            conflict_dict.pop(ck, None)
        # collapse non-conflict entries from the conflict dictionary
        for c in conflict_dict.values():
            nodes_to_remove = []
            commits = []
            for ip in c:
                if ip.node['commit'] in commits:
                    nodes_to_remove.append(ip)
                else:
                    commits.append(ip.node['commit'])
            for ip in nodes_to_remove:
                c.remove(ip)
        return conflict_dict
