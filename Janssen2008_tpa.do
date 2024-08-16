* Adjustment of Janssen & Bacon 2008
* Tom Ahern - May 2023

clear
cls
use "/Users/02tahern/Library/CloudStorage/OneDrive-UVMLarnerCollegeofMedicine/projects/flegal65plus/flegal65_adjustments/clean_mi_copy.dta", clear

run "suest.do"

* restrictions (none)

	
* Janssen covariate definitions	

	* alcohol: ounces per month, categorized
	* ncpnalco is ostensibly average grams/day 
	* ncpnalco * 30.5 * 0.035274 oz/g
	replace ncpnalco=0 if ncpnalco<0
	gen etoh_ozpermo = ncpnalco * 30.5 * 0.035274
	gen alccat = 0
	replace alccat = 1 if etoh_ozpermo>0 & etoh_ozpermo <= 1
	replace alccat = 2 if etoh_ozpermo>1 & etoh_ozpermo != .


* Minimally sufficient adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat sex age ib0.smkcfn ib0.alccat, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq, family(Poisson) link(log) offset(logpyrs) eform"

di "Minimally sufficient adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform

* Extra adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat sex age ib0.smkcfn ib0.alccat, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq ib2.bmicat_25y ib3.edcat physact_di ib5.hei_q, family(Poisson) link(log) offset(logpyrs) eform"

di "Extra adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform
