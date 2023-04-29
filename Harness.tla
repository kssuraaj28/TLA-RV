---------------------------- MODULE Harness -------------------------------
EXTENDS Naturals, Sequences, TLC

CONSTANTS external_map \* A sequence of sequences
VARIABLES trace_id, step_num, refinement_map

IsFiniteSeq(x) == \E n \in Nat: DOMAIN x = {1..n}

\* A finite number of traces
ASSUME IsFiniteSeq(external_map) 

\* Each trace has a finite number of states TODO -- Test this
ASSUME \A trace_idx \in DOMAIN external_map: 
            IsFiniteSeq(external_map[trace_idx])

TraceLength(trace_idx) == Len(external_map[trace_idx])

\* TODO: Deadlock? We can just do it somewhere else?
NextInTrace(trace_idx) == 
                   /\ trace_id = trace_idx
                   /\ step_num < TraceLength(trace_idx)
                   /\ step_num' = step_num+1
                   /\ UNCHANGED trace_id
                   /\ refinement_map' = external_map[trace_id'][step_num']

Next == \E idx \in DOMAIN external_map: NextInTrace(idx)

Init == /\ step_num = 1
        /\ trace_id \in DOMAIN external_map
        /\ refinement_map = external_map[trace_id][step_num]
=============================================================================
