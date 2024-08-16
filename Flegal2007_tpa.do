* Adjustment of Flegal 2007
* Thomas Ahern - May 2023

clear
cls
use "/Users/02tahern/Library/CloudStorage/OneDrive-UVMLarnerCollegeofMedicine/projects/flegal65plus/flegal65_adjustments/clean_mi_copy.dta", clear

run "suest.do"

* Restrictions

	* Age >=70
	drop if age<70	
	
* Covariate definitions

	* age: Cox time scale: 'ib0.agecat_fine'
	* sex: 'sex'
	* smoking: 'smkcfn'
	* race/ethnicity: white/black/other: 'race'
	* alcohol: g/day: none/<0.07/0.07-<0.35/>=0.35: '@@@'
		* these categories are questionable: a standard drink is 14g EtOH, so these categories are like people got a whiff of booze at most. i am going with 0 as the base, then thirds of the nonzero for the rest. fight me if you disagree.
		replace ncpnalco=0 if ncpnalco<0
		xtile etoh3 = ncpnalco if drinker==1, nq(3)
		replace etoh3=0 if drinker==0
		*'ib0.etoh3'

* Minimally sufficient adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat ib3.agecat_fine sex ib0.smkcfn ib1.race ib0.etoh3, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib3.agecat_fine sex ib0.smkcfn_tsq, family(Poisson) link(log) offset(logpyrs) eform"

di "Minimally sufficient adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform

* Extra adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat ib3.agecat_fine sex ib0.smkcfn ib1.race ib0.etoh3, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib3.agecat_fine sex ib0.smkcfn_tsq ib2.bmicat_25y ib3.edcat physact_di ib5.hei_q, family(Poisson) link(log) offset(logpyrs) eform"

di "Extra adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform
