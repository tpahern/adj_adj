* Adjustment of Janssen 2007
* Tom Ahern - May 2023

clear
cls
use "/Users/02tahern/Library/CloudStorage/OneDrive-UVMLarnerCollegeofMedicine/projects/flegal65plus/flegal65_adjustments/clean_mi_copy.dta", clear

run "suest.do"

* restrictions
	* none
	
* Janssen covariate definitions	

	* sex, ace, race, income, smoking, physical activity
	
	* sex we have
	
	* age: 5 groups
	gen agegroupj=1 if age >= 65 & age <= 70
	replace agegroupj=2 if age >= 71 & age <= 76
	replace agegroupj=3 if age >= 77 & age <= 82
	replace agegroupj=4 if age >= 83 & age <= 89
	replace agegroupj=5 if age >= 90
	
	lab def agej_ 1 "65-70" 2 "71-76" 3 "77-82" 4 "83-89" 5 "90+"
	lab val agegroupj agej_
	
	* race: white vs other
	gen racej=0
	replace racej=1 if race>1
	
	* ses/income: very low, low, moderate, high, very high (5 groups)
	* create similar with 'hff19r'
	gen incj = 1 if hff19r >= 1 & hff19r <= 8 /*very low*/
	replace incj = 2 if hff19r >= 9 & hff19r <= 16 /*low*/
	replace incj = 3 if hff19r >= 17 & hff19r <= 23 /*moderate--not perfect match*/
	replace incj = 4 if hff19r >= 24 & hff19r <= 26 /*high*/
	replace incj = 5 if hff19r==27 /*very high*/
	replace incj = 6 if hff19r==0 /*no income (e.g., retired)*/
	
	lab def incj_ 1 "V.Low" 2 "Low" 3 "Moderate" 4 "High" 5 "V.High" 6 "No income (ret.)"
	lab val incj incj_
	
	* smoking pack-years
	gen packyears=0 if smkcfn==0
	replace packyears=(har7s/20)*har8 if smkcfn==1
	replace packyears=(har4s/20)*har5 if smkcfn==2
	replace packyears=0 if packyears<0
	
		* janssen smoking categories
		gen smokj=0 if packyears==0 & hff1==2 /*none*/
		replace smokj=1 if packyears==0 & hff1==1 /*passive*/
		replace smokj=2 if packyears>0 & packyears<14 /*light*/
		replace smokj=3 if packyears>=14 ^ packyears < 50 /*moderate*/
		replace smokj=4 if packyears>=50 /*heavy*/
		replace smokj=0 if smokj==.
		
		lab def smokj_ 0 "None" 1 "Passive" 2 "Light smoker" 3 "Moderate smoker" 4 "Heavy smoker"
		lab val smokj smokj_
		
	* physical activity defined as quartiles - make four categories of 'physact_sum'
	gen physactj=physact_sum
	replace physactj=3 if physact_sum>3

	
*FEMALES

* Minimally sufficient adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat sex ib1.agegroupj racej ib1.incj ib0.smokj ib0.physactj if sex==0, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq if sex==0, family(Poisson) link(log) offset(logpyrs) eform"

di "Minimally sufficient adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform

* Extra adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat sex ib1.agegroupj racej ib1.incj ib0.smokj ib0.physactj if sex==0, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq ib2.bmicat_25y ib3.edcat physact_di ib5.hei_q if sex==0, family(Poisson) link(log) offset(logpyrs) eform"

di "Extra adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform

*MALES

* Minimally sufficient adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat sex ib1.agegroupj racej ib1.incj ib0.smokj ib0.physactj if sex==1, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq if sex==1, family(Poisson) link(log) offset(logpyrs) eform"

di "Minimally sufficient adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform

* Extra adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat sex ib1.agegroupj racej ib1.incj ib0.smokj ib0.physactj if sex==1, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq ib2.bmicat_25y ib3.edcat physact_di ib5.hei_q if sex==1, family(Poisson) link(log) offset(logpyrs) eform"

di "Extra adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform
