* Adjustment of Yates, 2008
* Fanny Asmussen, April 2023
cls
use "/Users/02tahern/Library/CloudStorage/OneDrive-UVMLarnerCollegeofMedicine/projects/flegal65plus/flegal65_adjustments/clean_mi_copy.dta", clear

run "suest.do"

* Limit to only men, as Yates study population only includes men
drop if sex==0

* Generate new variable in NHANES III for exercise based on physact_sum but consisting of 4 categories instead of 5 to match Yates definition
gen physact_sum_4= .
replace physact_sum_4 = 0 if (physact_sum==0)
replace physact_sum_4 = 1 if (physact_sum==1)
replace physact_sum_4 = 2 if (physact_sum==2)
replace physact_sum_4 = 3 if (physact_sum>2)

label define exerciselabel 0 "none" 1 "low" 2 "moderate" 3 "high"
label values physact_sum_4 exerciselabel
label variable physact_sum_4 "Exercise amount/month"

* Generate new variabel in NHANES III for alcohol to match Yates definition
gen alcohol_xmonth=han6hs+han6is+han6js
gen alcohol_xmonth_4 = .
replace alcohol_xmonth_4 = 0 if (alcohol_xmonth<1)
replace alcohol_xmonth_4 = 1 if (alcohol_xmonth>=1) & (alcohol_xmonth<=3)
replace alcohol_xmonth_4 = 2 if (alcohol_xmonth>3) & (alcohol_xmonth<=24)
replace alcohol_xmonth_4 = 3 if (alcohol_xmonth>24)

label define alcohollabel 0 "0" 1 "1-3" 2 "4-24" 3 ">24"
label values alcohol_xmonth_4 alcohollabel
label variable alcohol_xmonth_4 "Beer, wine or hard liquor - times/month"

* Generate new variable combining all 3 cardiovaskular conditions, where 1=either one of the cardiovascular conditions
gen cardiovascular =.
replace cardiovascular = 1 if chde==1 | htn==1 | hae7==1
replace cardiovascular = 0 if chde!=1 & htn!=1 & hae7!=1

label define cardiolabel 0 "0 cardiovascular conditions" 1 ">= 1 cardiovascular condition"
label values cardiovascular cardiolabel
label variable cardiovascular "Cardiovascular condition"


* Minimally sufficient adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat age smkcfn cardiovascular dm physact_sum_4 alcohol_xmonth_4, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq, family(Poisson) link(log) offset(logpyrs) eform"

di "Minimally sufficient adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform

* Extra adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat age smkcfn cardiovascular dm physact_sum_4 alcohol_xmonth_4, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq ib2.bmicat_25y ib3.edcat physact_di ib5.hei_q, family(Poisson) link(log) offset(logpyrs) eform"

di "Extra adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform
