(set-logic QF_LIA)
(declare-fun x () Int)
(declare-fun y () Int)
(assert (< 0 x y 2))
;(assert (and (< 0 x) (< x y) (< y 2)))
(check-sat)