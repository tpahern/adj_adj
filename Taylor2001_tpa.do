* Adjustment of Taylor 2001
* Thomas Ahern - May 2023

cls
use "/Users/02tahern/Library/CloudStorage/OneDrive-UVMLarnerCollegeofMedicine/projects/flegal65plus/flegal65_adjustments/clean_mi_copy.dta", clear

run "suest.do"

* Restrictions

* Covariate definitions

* Sex: 'sex'
* Age group: 65-74/ 75-84/ 85+
	gen agegrp = 1 if age >= 65 & age < 75
	replace agegrp = 2 if age >= 75 & age < 85
	replace agegrp = 3 if age >= 85
	* 'ib1.agegrp'
* Education: best map is 'ib1.edcaths'; can't derive better

* Minimally sufficient adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat sex ib1.agegrp ib1.edcaths, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq if sex==0, family(Poisson) link(log) offset(logpyrs) eform"

di "Minimally sufficient adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform

* Extra adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat sex ib1.agegrp ib1.edcaths, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq ib2.bmicat_25y ib3.edcat physact_di ib5.hei_q, family(Poisson) link(log) offset(logpyrs) eform"

di "Extra adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform
