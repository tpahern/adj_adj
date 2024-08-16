* Adjustment of Miller 2002
* Tom Ahern - May 2023
cls

use "/Users/02tahern/Library/CloudStorage/OneDrive-UVMLarnerCollegeofMedicine/projects/flegal65plus/flegal65_adjustments/clean_mi_copy.dta", clear

run "suest.do"

* restrictions

	*age 70+ only
	drop if age<70
	
* Miller covariate definitions

	* marital status: married/partnered (ref), widowed, never/divorced/single
	gen marcat2=1 if marcat==1 /*married*/
	replace marcat2=2 if marcat==4 /*widowed*/
	replace marcat2=3 if inlist(marcat,2,3) /*divorced/separated/never*/
	lab def mar_ 1 "Married" 2 "Widowed" 3 "Divorced/separated/never"
	lab val marcat2 mar_
	
	* self-rated health: poor/fair | good | very good/excellent (ref)
	gen selfhealth=1 if inlist(hab1,1,2) /*ref level*/
	replace selfhealth=2 if hab1==3
	replace selfhealth=3 if inlist(hab1,4,5)
	
	* activities of daily living: sum of bathing, dressing, toileting, transferring, continence, feeding; modeled as <=1 ADL vs. >1 ADL
	foreach var in hah5 hah6 hah8 hah10 hah11 hah12 {
		gen byte `var'_di=inlist(`var',2,3,4)
	}
	egen adlsum=rowtotal(hah5_di hah6_di hah8_di hah10_di hah11_di hah12_di)
	gen milleradl=1 if adlsum>1 & adlsum != .
	replace milleradl=0 if adlsum<=1
	
	* comorbidity: sum indicators for cancer, arthritis, heart attack, heart condition, hypertension, ulcer, diabetes, respiratory disease, hernia, stroke
	egen comorbsum=rowtotal(hac1n hac1o hac1c haf10 chde hac1d htn dm hal19c hac1g hac1a)
	
	
	* cognitive status in age 60+ boils down to story and word recall; see Noble (10.1136/jnnp.2009.174029) and Perkins (10.1093/oxfordjournals.aje.a009915) for the convention we adopted

		* for cognitive impairment, first sum story recall and word recall variables
		egen cogsum=rowtotal(mapd2a mapd2b mapd2c mapd2d mapd2e mapd2f hap19a hap19b hap19c), missing
		lab var cogsum "Sum of congitive recall variables"
		
		* now dichotomize: impaired if total is <4
		gen byte cogimp=cogsum<4
		lab var cogimp "Cognitive impairment (cogsum<4)"

* Minimally sufficient adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat sex ib2.agecat ib1.marcat2 ib0.smkcfn ib1.selfhealth milleradl comorb cogimp, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq, family(Poisson) link(log) offset(logpyrs) eform"

lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform

* Extra adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat sex ib2.agecat ib1.marcat2 ib0.smkcfn ib1.selfhealth milleradl comorbsum cogimp, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq ib2.bmicat_25y ib3.edcat physact_di ib5.hei_q, family(Poisson) link(log) offset(logpyrs) eform"

di "Extra adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform
