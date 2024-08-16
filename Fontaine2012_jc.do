* Adjustment of Fontaine 2012
* Jennifer Chen - April 2023

use "/Users/02tahern/Library/CloudStorage/OneDrive-UVMLarnerCollegeofMedicine/projects/flegal65plus/flegal65_adjustments/clean_mi_copy.dta", clear

run "suest.do"

* Limit to age 70+
drop if age<70

* Minimally sufficient adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq, family(Poisson) link(log) offset(logpyrs) eform"

di "Minimally sufficiently adjusted"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform

*Extra adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq ib2.bmicat_25y ib3.edcat physact_di ib5.hei_q, family(Poisson) link(log) offset(logpyrs) eform"

di "Extra adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform
