#!/usr/bin/env python
# 
# ucode_common.py
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

from bitstring import *
import yaml

try:
    from collections import OrderedDict
except ImportError:
    from ordereddict import OrderedDict

NB_LOOPS = 6

def yaml_ordered_load(stream, Loader=yaml.Loader, object_pairs_hook=OrderedDict):
    class OrderedLoader(Loader):
        pass
    def construct_mapping(loader, node):
        loader.flatten_mapping(node)
        return object_pairs_hook(loader.construct_pairs(node))
    OrderedLoader.add_constructor(
        yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG,
        construct_mapping)
    return yaml.load(stream, OrderedLoader)

def ucode_state_machine(loops, curr_state, verbose=False):
    curr_addr, curr_loop, curr_op, curr_idx = curr_state
    next_addr = curr_addr
    next_loop = curr_loop
    next_op   = curr_op
    next_idx  = curr_idx
    end = False
    busy = False
    execute = False
    # if next operation is within the current loop, update address
    if curr_idx[curr_loop] < loops[curr_loop]['range'] - 1 and curr_op < loops[curr_loop]['nb_ops'] - 1:
        if verbose:
            print "@%d %s UPDATE CURRENT LOOP                      " % (curr_addr, str(curr_state[3][::-1]))
        next_addr = curr_addr + 1
        next_op   = curr_op + 1
        busy = True
        execute = True
    # if there is a lower level loop, go to it
    elif curr_idx[curr_loop] < loops[curr_loop]['range'] - 1 and curr_loop > 0: 
        if verbose:
            print "@%d %s ITERATE CURRENT LOOP & GOTO LOOP 0" % (curr_addr, str(curr_state[3][::-1]))
        next_loop = 0
        for j in xrange(0,curr_loop):
            next_idx[j] = 0
        next_idx[curr_loop] = curr_idx[curr_loop] + 1
        next_addr = loops[0]['ucode_addr']
        next_op   = 0
        busy = False
        execute = True
    # if we are still within the current loop range, go back to start loop address
    elif curr_idx[curr_loop] < loops[curr_loop]['range'] - 1: 
        if verbose:
            print "@%d %s ITERATE CURRENT LOOP                     " % (curr_addr, str(curr_state[3][::-1]))
        next_addr = loops[curr_loop]['ucode_addr']
        next_op   = 0
        next_idx[curr_loop] = curr_idx[curr_loop] + 1
        busy = False
        execute = True
    # if not, go to next loop
    elif curr_loop < NB_LOOPS-1:
        if verbose:
            print "@%d %s GOTO NEXT LOOP                           " % (curr_addr, str(curr_state[3][::-1]))
        next_loop = curr_loop + 1
        next_addr = loops[curr_loop+1]['ucode_addr']
        next_op   = 0
        busy = True
        execute = False
    else:
        if verbose:
            print "@%d %s TERMINATION                              " % (curr_addr, str(curr_state[3][::-1]))
        end = True
        next_loop = 0
        next_addr = 0
        next_op   = 0
        next_idx  = []
        for j in xrange(NB_LOOPS):
            next_idx.append(0)
        busy = False
        execute = False
    next_state = next_addr, next_loop, next_op, next_idx
    return execute,end,busy,next_state

def ucode_execute(state, code, registers):
    addr, loop, op, idx = state
    new_registers = registers[:]
    if code[addr]['op_sel']:
        new_registers[code[addr]['a']] = registers[code[addr]['a']] + registers[code[addr]['b']]
    else:
        new_registers[code[addr]['a']] = registers[code[addr]['b']]
    return new_registers

def ucode_print_idx(state, registers):
    print "loop:%d W:%d x:%d y:%d" % (state[1], registers[0], registers[1], registers[2])

def ucode_bytecode(code, loops_ops):
    bytecode = {}
    bytecode['code'] = BitArray()
    for c in code[::-1]:
        if c['op_sel'] == 1:
            b = BitArray(uint=1, length=1)
        else:
            b = BitArray(uint=0, length=1)
        a_b = BitArray(uint=c['a'], length=5)
        b_b = BitArray(uint=c['b'], length=5)
        b.append(a_b)
        b.append(b_b)
        bytecode['code'].append(b)
    if bytecode['code'].length < 176:
        bytecode['code'].prepend(BitArray(uint=0, length=176-bytecode['code'].length))
    bytecode['loops'] = BitArray()
    a = 0
    loops_addr = []
    for o in loops_ops:
        loops_addr.append(a)
        a += o
    for o,a in zip(loops_ops[::-1], loops_addr[::-1]):
        a_b = BitArray(uint=a, length=5)
        o_b = BitArray(uint=o, length=3)
        bytecode['loops'].append(a_b)
        bytecode['loops'].append(o_b)
    return bytecode

def ucode_load(name):
    with open(name) as f:
        code_p = yaml_ordered_load(f, yaml.SafeLoader)
    mnem_p = code_p['mnemonics']
    code_p = code_p['code']
    # code_p is a dictionary of loops
    code_l = []
    loops_ops = []
    for l in code_p:
        code_l.extend(code_p[l])
        loops_ops.append(len(code_p[l]))
    code = []
    for c in code_l:
        cn = {}
        if c['op'] == 'add':
            cn['op_sel'] = 1
        else:
            cn['op_sel'] = 0
        try:
            cn['a'] = mnem_p[c['a']]
        except KeyError:
            cn['a'] = c['a']
        try:
            cn['b'] = mnem_p[c['b']]
        except KeyError:
            cn['b'] = c['b']
        code.append(cn)
    return loops_ops,code

def ucode_get_loops(loops_ops, loops_range):
    loops = []
    a = 0
    for o,r in zip(loops_ops, loops_range):
        l = {}
        l['nb_ops']     = o
        l['range']      = r
        l['ucode_addr'] = a
        a += o
        loops.append(l)
    return loops

# state = (0,0,0,[0,0,0,0])
# for i in xrange(0,50):
#     ucode_execute(state, code, registers)
#     ucode_print_idx(i, state, registers)
#     end,state = ucode_state_machine(loops, state, verbose=True)
#     if end:
#         break




  # assign ucode_registers_read[0]     = static_reg_nif;
  # assign ucode_registers_read[1]     = static_reg_nif >> $clog2(TP);
  # assign ucode_registers_read[2]     = static_reg_nof;
  # assign ucode_registers_read[3]     = static_reg_nof >> $clog2(TP);
  # assign ucode_registers_read[4]     = static_reg_fs0;
  # assign ucode_registers_read[5]     = static_reg_fs1;
  # assign ucode_registers_read[6]     = static_reg_oh;
  # assign ucode_registers_read[7]     = static_reg_ow;
  # assign ucode_registers_read[8]     = static_reg_h;
  # assign ucode_registers_read[9]     = static_reg_w;
  # assign ucode_registers_read[10]    = static_reg_nof << $clog2(TP);
  # assign ucode_registers_read[11]    = static_reg_nif << $clog2(TP);
  # assign ucode_registers_read[12]    = static_ow_X_nof;
  # assign ucode_registers_read[13]    = static_w_X_nif;
  # assign ucode_registers_read[14]    = static_ow_X_nof;
  # assign ucode_registers_read[15]    = static_nif_X_nof;
  # assign ucode_registers_read[16]    = static_fs0_X_nif_X_nof;
  # assign ucode_registers_read[17]    = static_fs2_X_nif_X_nof;
  # assign ucode_registers_read[26:18] = reg_file.hwpe_params[18:10]; // flexibility at a price? maybe 9 additional r/o regs are not necessary
  # assign ucode_registers_read[27]    = '0;



# /*
#    x0:  0 
#    x1:  jj (NIF)
#    x2:  ii (NOF)
#    x3:  k  (FS)
#    x4:  l  (FS)
#    x5:  m  (OW)
#    x6:  n  (OH)
#    x7:  W_idx
#    x8:  x_idx
#    x9:  y_idx
#    x10: nif/TP
#    x11: nof/TP
#    x12: fs
#    x13: ow
#    x14: oh
#    x15: CTRL
#    x16: w * nif
#    x17: ow * nof
#    x18: nif * nof
#    x19: fs * nif * nof
#    x20: nif
#    x21: nof
#    x22: x_idx_major
#    x23: nof*TP
# */

# /*
# clear:
#   mv x1,x0
#   mv x2,x0
#   mv x3,x0
#   mv x4,x0
#   mv x5,x0
#   mv x6,x0
#   mv x7,x0
#   mv x8,x0
#   mv x9,x0
#   mv x15,x0
#   mv x22,x0
# */

# /* loop range, ucode address */
# /* each loop will increase its own index and clear the one of the nested loop */

# LOOP0 x10,loop_stream_inner  /* for jj in range(0,nif/TP) */
# LOOP1 x12,loop_filter_x      /* for k in range(0,fs) */
# LOOP2 x12,loop_filter_y      /* for l in range(0,fs) */
# LOOP3 x11,loop_stream_outer  /* for ii in range(0,nof/TP) */
# LOOP4 x13,loop_spatial_x     /* for m in range(0,ow) */
# LOOP5 x14,loop_spatial_y     /* for n in range(0,oh) */

# loop_spatial_y:    ADD x22,x16  /* x_idx_major := x_idx_major+w*nif */
#                    ADD x9,x17   /* y_idx := y_idx+ow*nof */
# loop_spatial_x:    ADD x22,x20  /* x_idx_major := x_idx_major+nif */
#                    ADD x9,x21   /* y_idx := y_idx+nof */
#                    ADD x7,x18   /* W_idx := W_idx+nif*nof */
# loop_stream_outer: MV  x8,x22   /* x_idx := x_idx_major */ <-----
#                    ADD x9,TP    /* y_idx := y_idx+TP */
#                    ADD x7,x23   /* W_idx := W_idx+TP*nof */
# loop_filter_y:     ADD x8,x16   /* x_idx := x_idx+w*nif */
#                    ADD x7,x18   /* W_idx := W_idx+nif*nof */
# loop_filter_x:     ADD x8,x20   /* x_idx := x_idx+nif */
# loop_stream_inner: ADD x8,TP    /* x_idx := x_idx+TP */
#                    ADD x7,TP    /* W_idx := W_idx+TP */
