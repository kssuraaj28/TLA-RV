#!/usr/bin/env python3
from sys import argv


class spec_gen:
    def __init__(self, refinement_cfg_str):
        self.refinement_vars = []
        self.rfnmnt_vars_types = {}
        self.trace_list = []
        for var_type in refinement_cfg_str.split(','):
            var, type_str = [x.strip() for x in var_type.split(':')]
            type_map = {'int': int, 'str': str}  # Can be extended
            assert (var not in self.refinement_vars)
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

    def write_tla_module(self, modulename, specname):
        traces_tla = self.traces_to_tla_collection()

        tla_text = f'''----------------- MODULE {modulename} ----------------
EXTENDS Naturals, Sequences

external_map  == {traces_tla}
VARIABLES trace_id, step_num, refinement_map

IsFiniteSeq(x) == DOMAIN x = 1..Len(x)

ASSUME IsFiniteSeq(external_map) 

ASSUME \\A trace_idx \\in DOMAIN external_map:  
            IsFiniteSeq(external_map[trace_idx])

TraceLength(trace_idx) == Len(external_map[trace_idx])

NextInTrace(trace_idx) == 
                   /\\ trace_id = trace_idx
                   /\\ step_num < TraceLength(trace_idx)
                   /\\ step_num' = step_num+1
                   /\\ UNCHANGED trace_id
                   /\\ refinement_map' = external_map[trace_id'][step_num']

Next == \\E idx \\in DOMAIN external_map: NextInTrace(idx)

Init == /\\ step_num = 1
        /\\ trace_id \\in DOMAIN external_map
        /\\ refinement_map = external_map[trace_id][step_num]

Original == INSTANCE {specname} WITH state <- refinement_map

RefinementSpec == Original!Spec
=========================================================
'''
        cfg_text = f'''
INIT Init
NEXT Next
CHECK_DEADLOCK FALSE
PROPERTY RefinementSpec
'''
        with open(f'{modulename}.tla', 'w') as ofd:
            ofd.write(tla_text)

        with open(f'{modulename}.cfg', 'w') as ofd:
            ofd.write(cfg_text)


def main():
    input_spec = argv[1]
    output_spec = argv[2]
    input_refinement_config = argv[3]
    input_trace_files = argv[4:]
    spec_generator = spec_gen(input_refinement_config)
    for trace in input_trace_files:
        spec_generator.add_trace_file(trace)
    spec_generator.write_tla_module(output_spec, input_spec)


if __name__ == '__main__':
    main()
