* Adjustment of Ford, 2008
* Fanny Asmussen, May 2023
clear
cls
use "/Users/02tahern/Library/CloudStorage/OneDrive-UVMLarnerCollegeofMedicine/projects/flegal65plus/flegal65_adjustments/clean_mi_copy.dta", clear

run "suest.do"

* limit to only females, as Fords study population only includes females
drop if sex==1

*Generate new variable in NHANES III for exercise based on physact_sum but consisting of 4 categories instead of 5 to match Fords definition
gen physact_sum_4=.
replace physact_sum_4 = 0 if (physact_sum==0)
replace physact_sum_4 = 1 if (physact_sum==1)
replace physact_sum_4 = 2 if (physact_sum==2)
replace physact_sum_4 = 3 if (physact_sum>2)

label define phyactlabel 0 "none" 1 "low" 2 "moderate" 3 "high"
label values physact_sum_4 phyactlabel
label variable physact_sum_4 "Exercise per month"

*Generate new variable for low iron, since NHANES III variable is continious and Fords definition is low/not low
gen iron_cat =.
replace iron_cat = 0 if frp>=100
replace iron_cat = 1 if frp<100

*Generate new variable of comorbidites in three categories matching Fords definition
gen comorbid_cat =.
replace comorbid_cat = 0 if hag11==0 & iron_cat==0 & chde==0 & hac1o==0 & dm==0 & hac1d==0
replace comorbid_cat = 1 if hag11==1 & hac1d==0 & dm==0 & hac1o==0 & chde==0 & iron_cat==0
replace comorbid_cat = 2 if iron_cat==1 & hac1d==0 & dm==0 & hac1o==0 & chde==0 & hag11==0
replace comorbid_cat = 3 if chde==1 & hac1d==0 & dm==0 & hac1o==0 & iron_cat==0 & hag11==0
replace comorbid_cat = 4 if hac1d==1 | dm==1 | hac1o==1
replace comorbid_cat = 5 if chde==1 & iron_cat==1
replace comorbid_cat = 6 if hag11==1 & chde==1
replace comorbid_cat = 7 if hag11==1 & iron_cat==1

gen comorbid_cat3 =.
replace comorbid_cat3 = 0 if comorbid_cat==0 
replace comorbid_cat3 = 1 if comorbid_cat==1 | comorbid_cat==2 | comorbid_cat==3
replace comorbid_cat3 = 2 if comorbid_cat== 4 | comorbid_cat== 5 | comorbid_cat == 6 | comorbid_cat == 7

label define comorbidlabel 0 "0" 1 "1-2" 2 ">=3"
label values comorbid_cat3 comorbidlabel
label variable comorbid_cat3 "Comorbidity score"

*Generate new variabel in NHANES III for marital status to match Fords definition
gen marital_3cat = .
replace marital_3cat = 1 if (marcat==1)
replace marital_3cat = 2 if (marcat==2) | (marcat==3)
replace marital_3cat = 3 if (marcat==4)

label define maritallabel 1 "Married" 2 "Single" 3 "Widowed"
label values marital_3cat maritallabel
label variable marital_3cat "Marital status"

* Minimally sufficient adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat hab1 ib2.physact_sum_4 ib0.smkcfn_tsq comorbid_cat3 marital_3cat age, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq, family(Poisson) link(log) offset(logpyrs) eform"

di "Minimally sufficient adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform

* Extra adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat hab1 ib2.physact_sum_4 ib0.smkcfn_tsq comorbid_cat3 marital_3cat age, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq ib2.bmicat_25y ib3.edcat physact_di ib5.hei_q, family(Poisson) link(log) offset(logpyrs) eform"

di "Extra adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform
