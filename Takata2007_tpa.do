* Adjustment of Takata 2007
* Tom Ahern - May 2023

clear
cls
use "/Users/02tahern/Library/CloudStorage/OneDrive-UVMLarnerCollegeofMedicine/projects/flegal65plus/flegal65_adjustments/clean_mi_copy.dta", clear

run "suest_alt.do"


* restrictions
	* they enrolled only 80 year-olds; that would leave us with only 240 people. But how about we restrict to 80-84? Seems reasonable to me, and fairer than leaving it to 65+. any complaints? hearing none...
	drop if age<80 | age>84
	
* covariate definitions

	* Sex: 'sex'
	* Smoking: current/otherwise: 'smoker'
	* Alcohol: drinker/non: 'drinker'
	* Weight loss in prior year
		* We've got weights now and 10 years ago; take their difference and define status by sign
		gen wtlossabs = bmpwtlbs - ham8s
		gen byte wtlossdi=wtlossabs<0
	* Current outpatient: <<no variable maps to this>>
	* Systolic BP: 'sysbp'
	* Physical activity: no definition: 'physact_di'
	* Functional status: no definition: use ADL-based definition as per Lisko adjustment:
		foreach var in hah5 hah6 hah8 hah10 hah11 hah12 {
			gen byte `var'_di=inlist(`var',2,3,4)
		}
		egen adlsum=rowtotal(hah5_di hah6_di hah8_di hah10_di hah11_di hah12_di)
		gen liskoadl=0
		replace liskoadl=1 if adlsum>0 & adlsum != .
	* Marital status: no definition: 'ib1.marcat'
	* Total serum cholesterol: apparently continuous mg/dL: 'tc'
	* Glucose level: apparently continuous: 'sgp'
	* Place of residence: notgonnadoit
	* Respiratory disease: define per Cesari
		* respiratory disease
			gen byte resp = hal19c==1 | hac1g==1
	* Cardiovascular disease: ischemic heart disease, stroke, arrhythmias, congenital: just like Atlantis:
		* cardiovascular disease
		gen byte cvascd = hac1c==1 | haf10==1 | chde==1 | hac1d==1 | htn==1
	* Cancer: dichotomous
		gen byte cancer=hac1n==1 | hac1o==1


* Minimally sufficient adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat sex smoker drinker wtlossdi sysbp physact_di liskoadl ib1.marcat tc sgp resp cvascd cancer, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq, family(Poisson) link(log) offset(logpyrs) eform"

di "Minimally sufficient adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform

* Extra adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat sex smoker drinker wtlossdi sysbp physact_di liskoadl ib1.marcat tc sgp resp cvascd cancer, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq ib2.bmicat_25y ib3.edcat physact_di ib5.hei_q, family(Poisson) link(log) offset(logpyrs) eform"

di "Extra adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform
