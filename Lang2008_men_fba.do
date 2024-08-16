* Adjustment of Lang MEN, 2008
* Fanny Asmussen, May 2023
cls
use "/Users/02tahern/Library/CloudStorage/OneDrive-UVMLarnerCollegeofMedicine/projects/flegal65plus/flegal65_adjustments/clean_mi_copy.dta", clear

run "suest.do"

* Limit to study population only including men
drop if sex==0

*Generate common heart disease comobidity variable to use in comorbidity variable
gen heartdisease =.
replace heartdisease = 0 if haf10==0 & chde==0 & hac1c==0
replace heartdisease = 1 if haf10==1 | chde==1 | hac1c==1

*Generate variable to use in comorbidity variable 
gen comorbidities_med=. 
replace comorbidities_med = 1 if heartdisease==1 & hac1d==0 & hae2==0 & dm==0 & hac1a==0
replace comorbidities_med = 2 if heartdisease==0 & hac1d==1 & hae2==0 & dm==0 & hac1a==0
replace comorbidities_med = 3 if heartdisease==0 & hac1d==0 & hae2==1 & dm==0 & hac1a==0
replace comorbidities_med = 4 if heartdisease==0 & hac1d==0 & hae2==0 & dm==1 & hac1a==0
replace comorbidities_med = 5 if heartdisease==0 & hac1d==0 & hae2==0 & dm==0 & hac1a==1
replace comorbidities_med = 0 if heartdisease==0 & hac1d==0 & hae2==0 & dm==0 & hac1a==0

*Generate variable for comobidity to match Langs definition 
gen comorbidities_no =. 
replace comorbidities_no = 0 if comorbidities_med==0
replace comorbidities_no = 1 if comorbidities_med==1 | comorbidities_med==2 |comorbidities_med==3 |comorbidities_med==4 |comorbidities_med==5
replace comorbidities_no = 2 if comorbidities_no!=1 & comorbidities_no!=0

label define comorbiditieslabel 0 "0 comorbidities" 1 "1 comorbidity" 2 ">=2 comorbidities"
label values comorbidities_no comorbiditieslabel
label variable comorbidities_no "Comorbidity in 3 groups"

*Generate new variabel in NHANES III for alcohol to match Langs definition
gen alcohol_xmonth=han6hs+han6is+han6js
gen alcohol_xmonth_4 = .
replace alcohol_xmonth_4 = 0 if (alcohol_xmonth<1)
replace alcohol_xmonth_4 = 1 if (alcohol_xmonth>=1) & (alcohol_xmonth<=30)
replace alcohol_xmonth_4 = 2 if (alcohol_xmonth>30) & (alcohol_xmonth<=60)
replace alcohol_xmonth_4 = 3 if (alcohol_xmonth>60)

label define alcohollabel 0 "0" 1 "1-30" 2 "31-60" 3 ">60"
label values alcohol_xmonth_4 alcohollabel
label variable alcohol_xmonth_4 "Monthly alcohol consumption in 4 groups"

* Generate new variable in NHANES III for household income divided in quintiles
gen householdincome_5 =. 
replace householdincome_5 = 1 if hff19r==01 | hff19r==02 | hff19r==03 | hff19r==04 | hff19r==05 | hff19r==06 | hff19r==07 | hff19r==08 | hff19r==09 | hff19r==10
replace householdincome_5 = 2 if hff19r==11 | hff19r==12 | hff19r==13 | hff19r==14 | hff19r==15
replace householdincome_5 = 3 if hff19r==16 | hff19r==17 | hff19r==18 | hff19r==19 | hff19r==20
replace householdincome_5 = 4 if hff19r==21 | hff19r==22 
replace householdincome_5 = 5 if hff19r==23 | hff19r==24 | hff19r==25  | hff19r==26 | hff19r==27 

label define householdincome1 1 "0-9,999" 2 "10,000-14,999" 3 "15,000-19,999" 4 "20,000-29,999" 5 ">=30,000"
label values householdincome_5 householdincome1
label variable householdincome_5 "Monthly household income in 5 income groups" 

* Minimally sufficient adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat age comorbidities_no smkcfn alcohol_xmonth_4 householdincome_5 edcaths, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine ib0.smkcfn_tsq, family(Poisson) link(log) offset(logpyrs) eform"

di "Minimally sufficient adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform

* Extra adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat age comorbidities_no smkcfn alcohol_xmonth_4 householdincome_5 edcaths, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq ib2.bmicat_25y ib3.edcat physact_di ib5.hei_q, family(Poisson) link(log) offset(logpyrs) eform"

di "Extra adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform
