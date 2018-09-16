(set-logic QF_UF)
(set-info :status sat)
(declare-sort U 0)
(declare-fun f (U) U)
(declare-fun g (U) U)
(declare-fun A () Bool)
(declare-fun x () U)
(declare-fun y () U)
(assert
(let ((fx (f x))
      (cls1 (or A (= x y))))
  (and cls1 (distinct fx (g y)))))
(check-sat)
(exit)
