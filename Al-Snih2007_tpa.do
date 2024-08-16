* Adjustment of Al Snih 2007
* Thomas Ahern - May 2023

use "/Users/02tahern/Library/CloudStorage/OneDrive-UVMLarnerCollegeofMedicine/projects/flegal65plus/flegal65_adjustments/clean_mi_copy.dta", clear

run "suest.do"

* Restrictions

	*White, Black and Mexican-American only:
	drop if raceethnicity==4

* Covariate definitions

	* Age: continuous: 'age'
	* Sex: 'sex'
	* Race/ethnicity: 'raceethnicity' maps after exclusion
	* Marital status: married vs. otherwise: 'married'
	* Education: 'education'
	* Smoking: current/former/never: 'smkcfn'
	* Comorbidity:
		* cancer:
			gen byte cancer=hac1n==1 | hac1o==1
		* hypertension: 'htn'
		* diabetes: 'dm'
		* hip fracture: 'hag5a'
		* heart attack: 'haf10'
		* stroke: 'hac1d'
	* EPESE site (not pertinent)

* Minimally sufficient RRc
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat age sex ib1.raceethnicity married education ib0.smkcfn cancer htn dm hag5a haf10 hac1d, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq, family(Poisson) link(log) offset(logpyrs) eform"

di "Minimally sufficient"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform

* Extra adjustment RRc
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat age sex ib1.raceethnicity married education ib0.smkcfn cancer htn dm hag5a haf10 hac1d, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq ib2.bmicat_25y ib3.edcat physact_di ib5.hei_q, family(Poisson) link(log) offset(logpyrs) eform"

di "Extra adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform
