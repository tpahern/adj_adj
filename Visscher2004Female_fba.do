*Adjustment of Visscher, 2004 Female
* Fanny Asmussen, April 2023
cls
use "/Users/02tahern/Library/CloudStorage/OneDrive-UVMLarnerCollegeofMedicine/projects/flegal65plus/flegal65_adjustments/clean_mi_copy.dta", clear

run "suest.do"

* Limit to only women as risk estimates in the Visscher study are stratified by sex, and therefore we will do the same
drop if sex==1

* Limit to individuals who have never smoked as the estimates in the Visscher paper only includes never smokers
drop if smkcfn==1  | smkcfn==2

* Generate new variable in NHANES III for alcohol to match Visscher's definition
gen alcohol_xmonth=han6hs+han6is+han6js
gen alcohol_xmonth_4 = .
replace alcohol_xmonth_4 = 0 if (alcohol_xmonth<1)
replace alcohol_xmonth_4 = 1 if (alcohol_xmonth>=1) & (alcohol_xmonth<=3)
replace alcohol_xmonth_4 = 2 if (alcohol_xmonth>3) & (alcohol_xmonth<=24)
replace alcohol_xmonth_4 = 3 if (alcohol_xmonth>24)

label define alcohollabel 0 "0" 1 "1-3" 2 "4-24" 3 ">24"
label values alcohol_xmonth_4 alcohollabel
label variable alcohol_xmonth_4 "Beer, wine or hard liquor - times/month"

***Limited to females already, so no if statement needed in models:

* Minimally sufficient adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat age edcaths alcohol_xmonth_4, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq, family(Poisson) link(log) offset(logpyrs) eform"

di "Minimally sufficient adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform

* Extra adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat age edcaths alcohol_xmonth_4, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq ib2.bmicat_25y ib3.edcat physact_di ib5.hei_q, family(Poisson) link(log) offset(logpyrs) eform"

di "Extra adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform
