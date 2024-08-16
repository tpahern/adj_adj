* Adjustment of McTigue 2006
* Tom Ahern - May 2023

clear
cls
use "/Users/02tahern/Library/CloudStorage/OneDrive-UVMLarnerCollegeofMedicine/projects/flegal65plus/flegal65_adjustments/clean_mi_copy.dta", clear

run "suest.do"

* restrictions

	* women only
	drop if sex==1
	
* covariate definitions

	* Age: 'age'
	* Smoking: current/otherwise: 'smoker'
	* Education: <=HS, some college, college, >college: 
		* 'edcaths' is the best we can do
	* Physical activity: 5 levels based on METS/wk
		* proxy with 'physact_sum' in 5 categories
		gen physact5=physact_sum
		replace physact5=4 if physact_sum==5

* Minimally sufficient adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat age smoker ib1.edcaths ib0.physact5, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq, family(Poisson) link(log) offset(logpyrs) eform"

di "Minimally sufficient adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform

* Extra adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat age smoker ib1.edcaths ib0.physact5, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq ib2.bmicat_25y ib3.edcat physact_di ib5.hei_q, family(Poisson) link(log) offset(logpyrs) eform"

di "Extra adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform
