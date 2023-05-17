---------------------------- MODULE GCD --------------------------------
EXTENDS Naturals

\* state -- x:int,y:int 
VARIABLES state

X_val == state.x
Y_val == state.y

Divide(x,y) == x \div y
Modulo(x,y) == x - (y * Divide(x,y))

Next == /\ Y_val # 0
        /\ state' = [x |-> Y_val, y |-> Modulo(X_val, Y_val)]

Init == state \in [x : Nat, y: Nat] /\ X_val > Y_val

Spec == Init /\ [][Next]_state 
=============================================================================
