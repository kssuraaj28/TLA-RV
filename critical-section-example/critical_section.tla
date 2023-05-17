---------------------------- MODULE critical_section --------------------------------
EXTENDS Naturals

\* state -- t1:int,t2:int 
VARIABLES state

t1_val == state.t1
t2_val == state.t2

Spec == [][~(t1_val = 1 /\ t2_val = 1)]_state 
=============================================================================
