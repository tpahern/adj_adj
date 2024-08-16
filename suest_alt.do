mi svyset _n [pweight=wtpfqx6], vce(linearized)

* estimation of RRc & its variance
cap program drop mysuest
program mysuest, eclass properties(mi)
version 17.0
args model1 model2

qui `model1'
estimates store est1
qui `model2'
estimates store est2
suest est1 est2

ereturn local title "Seemingly unrelated estimation"
end