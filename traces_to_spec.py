#!/usr/bin/env python3
from sys import argv

class spec_gen:
    def __init__(self, refinement_cfg_file):
        self.refinement_vars = []
        self.rfnmnt_vars_types = {}
        self.trace_list = []
        with open(refinement_cfg_file) as f:
            lines = [x for x in f.read().splitlines() if not x.startswith('#')]
            assert (len(lines) == 1)
            cfg = lines[0]
            for var_type in cfg.split(','):
                var, type_str = [x.strip() for x in var_type.split(':')]
                type_map = {'int': int, 'str': str}  # Can be extended
                assert(var not in self.refinement_vars)
                self.refinement_vars.append(var)
                assert (type_str in type_map)
                self.rfnmnt_vars_types[var] = type_map[type_str]

    def print(self):
        print(self.refinement_vars)
        print(self.rfnmnt_vars_types)
        print(self.trace_list)

    def add_trace_file(self, filename):

        trace = []
        with open(filename) as file:
            for line in file:
                line = line.strip()
                if line.startswith('#'):
                    continue
                fields = [x.strip() for x in line.split(',')]
                assert (len(fields) == len(self.refinement_vars))
                temp = []
                for idx in range(len(fields)):
                    var = self.refinement_vars[idx]
                    trace_val = self.rfnmnt_vars_types[var](fields[idx])
                    temp.append(trace_val)
                trace.append(tuple(temp))
        self.trace_list.append(trace)

    def state_to_tla_rec(self, state_tuple):
        def tla_notation(var, value):
            return f'{var}|->{value}'

        ret = ', '.join(tla_notation(
            self.refinement_vars[idx], state_tuple[idx]) for idx in range(len(state_tuple)))

        return '[' + ret + ']'

    def trace_to_tla_seq(self, trace):
        ret = ' , '.join(self.state_to_tla_rec(x) for x in trace)
        return '<<' + ret + '>>'

    def traces_to_tla_collection(self):
        ret = ',\n'.join(self.trace_to_tla_seq(x) for x in self.trace_list)
        return '<<\n' + ret + '\n>>'

    def write_tla_module(self,modulename):
        traces_tla = self.traces_to_tla_collection()
        harness_module='Harness'

        tla_text = f'''----------------- MODULE {modulename} ----------------
EXTENDS {harness_module} 
trace_collection == {traces_tla}
=========================================================
'''
        cfg_text = f'''CONSTANTS
\texternal_map <- trace_collection
INIT Init
NEXT Next
'''
        with open(f'{modulename}.tla', 'w') as ofd:
            ofd.write(tla_text)

        with open(f'{modulename}.cfg', 'w') as ofd:
            ofd.write(cfg_text)


def main():
    input_refinement_config = argv[1]
    input_trace_files = argv[2:]
    spec_generator = spec_gen(input_refinement_config)
    for trace in input_trace_files:
        spec_generator.add_trace_file(trace)
    spec_generator.write_tla_module('Example')


if __name__ == '__main__':
    main()
