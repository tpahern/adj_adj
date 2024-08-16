* Adjustment of Atlantis 2010
* Tom Ahern - May 2023

clear
cls
use "/Users/02tahern/Library/CloudStorage/OneDrive-UVMLarnerCollegeofMedicine/projects/flegal65plus/flegal65_adjustments/clean_mi_copy.dta", clear

run "suest.do"

* restrictions

	
* Atlantis covariate definitions	

	* smoking: current vs. former/never
	gen smoke=0
	replace smoke=1 if smkcfn==2
	
	* activities of daily living: in lieu of OARS/IADL, model # ADLs impacted as ordinal
	foreach var in hah5 hah6 hah8 hah10 hah11 hah12 {
		gen byte `var'_di=inlist(`var',2,3,4)
	}
	egen adlsum=rowtotal(hah5_di hah6_di hah8_di hah10_di hah11_di hah12_di)
		
	* timed 1-meter walk: scale up from max of 2 NHANES 8-foot walk trials
	replace pfptwlka=2.4 if pfptwlka<0
	replace pfptwlkb=2.4 if pfptwlka<0
	gen walktime1m = max(pfptwlka, pfptwlkb) * (9.84/8)
	gen walktimecat = 0 if walktime1m <= 11
	replace walktimecat = 1 if walktime1m > 11 & walktime1m != .
		
	* social activity: in lieu of OARS, add up NHANES social activities times/year and make terts
	replace hav1s=0 if hav1s==5555
	egen socialsum = rowtotal(hav1s hav2s hav3s)
	xtile socialsum3 = socialsum, nq(3)
	
	* cognitive impairment (must do based on story/word recall in NHANES III)
	* first sum story recall and word recall variables
	egen cogsum=rowtotal(mapd2a mapd2b mapd2c mapd2d mapd2e mapd2f hap19a hap19b hap19c), missing
	lab var cogsum "Sum of congitive recall variables"

	* now dichotomize: impaired if total is <4
	gen byte cogimp=cogsum<4
	lab var cogimp "Cognitive impairment (cogsum<4)"
	
	* cardiovascular disease
	gen byte cvascd = hac1c==1 | haf10==1 | chde==1 | hac1d==1 | htn==1

* Minimally sufficient adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat sex age smoke ib0.adlsum walktimecat ib1.socialsum3 cogimp cvascd, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq, family(Poisson) link(log) offset(logpyrs) eform"

di "Minimally sufficient adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform

* Extra adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat sex age smoke ib0.adlsum walktimecat ib1.socialsum3 cogimp cvascd, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq ib2.bmicat_25y ib3.edcat physact_di ib5.hei_q, family(Poisson) link(log) offset(logpyrs) eform"

di "Extra adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform
