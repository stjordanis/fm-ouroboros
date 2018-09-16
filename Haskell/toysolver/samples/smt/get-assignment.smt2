(set-option :produce-assignments true)
(get-option :produce-assignments)
(set-logic QF_UF)
(declare-fun a () Bool)
(declare-fun b () Bool)
(assert (or (! a :named aa) (! b :named bb)))
(assert (not (and a bb)))
(check-sat)
(get-assignment)
