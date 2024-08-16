* Adjustment of Freedman 2006
* Thomas Ahern - May 2023

cls
use "/Users/02tahern/Library/CloudStorage/OneDrive-UVMLarnerCollegeofMedicine/projects/flegal65plus/flegal65_adjustments/clean_mi_copy.dta", clear

run "suest.do"

* Restrictions (none)
	
* Covariate definitions

	* Age: time scale for Cox: 'ib0.agecat_fine'
	* Education: high school/ more than high school/ other: 'ib1.edcaths'
	* Alcohol: drinks per week: 0/<1-6/7-14/>14: ''
		egen alcmo = rowtotal(han6hs han6is han6js)
		replace alcmo=0 if alcmo<0
		gen alcwk = alcmo/4.35 /*convert drinks per month to drinks per week*/
		gen alcwk_cat = 0 if alcwk==0
		replace alcwk_cat = 1 if alcwk > 0 & alcwk < 7
		replace alcwk_cat = 2 if alcwk >= 7 & alcwk <= 14
		replace alcwk_cat = 3 if alcwk > 14
		* 'ib0.alcwk_cat'
	* Race: white/black/other: 'race'

*FEMALES

* Minimally sufficient adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat ib0.agecat_fine ib1.edcaths ib0.alcwk_cat ib1.race if sex==0, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq if sex==0, family(Poisson) link(log) offset(logpyrs) eform"

di "Minimally sufficient adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform

* Extra adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat ib0.agecat_fine ib1.edcaths ib0.alcwk_cat ib1.race if sex==0, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq ib2.bmicat_25y ib3.edcat physact_di ib5.hei_q if sex==0, family(Poisson) link(log) offset(logpyrs) eform"

di "Extra adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform


*MALES

*Minimally sufficient adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat ib0.agecat_fine ib1.edcaths ib0.alcwk_cat ib1.race if sex==1, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq if sex==1, family(Poisson) link(log) offset(logpyrs) eform"

di "Minimally sufficient adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform

* Extra adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat ib0.agecat_fine ib1.edcaths ib0.alcwk_cat ib1.race if sex==1, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq ib2.bmicat_25y ib3.edcat physact_di ib5.hei_q if sex==1, family(Poisson) link(log) offset(logpyrs) eform"

di "Extra adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform
