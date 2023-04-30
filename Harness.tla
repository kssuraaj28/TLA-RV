---------------------------- MODULE Harness -------------------------------
EXTENDS Naturals, Sequences

CONSTANTS external_map \* A sequence of sequences
VARIABLES trace_id, step_num, refinement_map

IsFiniteSeq(x) == DOMAIN x = 1..Len(x)

\* A finite number of traces
ASSUME IsFiniteSeq(external_map) 

\* TODO: Change from instace to EXTENDS....
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
