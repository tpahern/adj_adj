* Adjustment of Blain 2010
* Thomas Ahern - May 2023

clear
cls
use "/Users/02tahern/Library/CloudStorage/OneDrive-UVMLarnerCollegeofMedicine/projects/flegal65plus/flegal65_adjustments/clean_mi_copy.dta", clear

run "suest.do"

* Restrictions

	* Only females
	drop if sex==1
	
	* Age 75+
	drop if age<75
	
* Covariate definitions

	* age: Cox time scale: 'ib0.agecat_fine'
	
* Minimally sufficient adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat ib3.agecat_fine, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib3.agecat_fine sex ib0.smkcfn_tsq, family(Poisson) link(log) offset(logpyrs) eform"

di "Minimally sufficient adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform

* Extra adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat ib3.agecat_fine, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib3.agecat_fine sex ib0.smkcfn_tsq ib2.bmicat_25y ib3.edcat physact_di ib5.hei_q, family(Poisson) link(log) offset(logpyrs) eform"

di "Extra adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform
