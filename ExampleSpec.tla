----------------- MODULE ExampleSpec ----------------
VARIABLES state

Init == state = [x |-> 2, y|-> 3]
Next == state' = state

Spec == Init /\ [][Next]_state
=====================================================
