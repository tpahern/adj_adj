* Adjustment of Lisko 2011
* Tom Ahern - May 2023
cls
use "/Users/02tahern/Library/CloudStorage/OneDrive-UVMLarnerCollegeofMedicine/projects/flegal65plus/flegal65_adjustments/clean_mi_copy.dta", clear

run "suest.do"
	
* Lisko covariate definitions	
	
	* chronic conditions: cvd cancer diabetes respiratory infectious mmse
		* CVD
		gen byte cvascd = hac1c==1 | haf10==1 | chde==1 | hac1d==1 | htn==1
		
		* Cancer
		gen byte cancer = hac1n==1 | hac1o==1
		
		* Diabetes
		* just use 'dm'
		
		* Respiratory
		gen byte respdz = hal19c==1 | hac1g==1
		
		* Infectious
		gen byte infxdz = hak6==1 | sppq5==1 | pep13c==1 | hak4 != 3
		
		* MMSE (cognition)
		* in lieu of MMSE, do cognitive impairment: cognitive status in age 60+ boils down to story and word recall; see Noble (10.1136/jnnp.2009.174029) and Perkins (10.1093/oxfordjournals.aje.a009915) for the convention we adopted

			* for cognitive impairment, first sum story recall and word recall variables
			egen cogsum=rowtotal(mapd2a mapd2b mapd2c mapd2d mapd2e mapd2f hap19a hap19b hap19c), missing
			lab var cogsum "Sum of congitive recall variables"
			
			* now dichotomize: impaired if total is <4
			gen byte cogimp=cogsum<4
			lab var cogimp "Cognitive impairment (cogsum<4)"
	
	* in lieu of Barthel Index; activities of daily living: to map with Lisko's use of the Barthel Index, probably best to define "any ADL compromised" vs. none.
	foreach var in hah5 hah6 hah8 hah10 hah11 hah12 {
		gen byte `var'_di=inlist(`var',2,3,4)
	}
	egen adlsum=rowtotal(hah5_di hah6_di hah8_di hah10_di hah11_di hah12_di)
	gen liskoadl=0
	replace liskoadl=1 if adlsum>0 & adlsum != .
	
	* smoking: current/former vs. never
	gen liskosmoke=0
	replace liskosmoke=1 if inlist(smkcfn,1,2)
	
	* alcohol: nondrinkers, <1 drink.week, >=1 drink.week
	* so this is nondrinkers, <4 drinks/month, >=4 drinks/month
	foreach var in han6hs han6is han6js {
		replace `var'=0 if `var'<0
	}
	egen drinkspermonth = rowtotal(han6hs han6is han6js)
	
	gen lisko_etoh = 1 if drinkspermonth==0
	replace lisko_etoh = 2 if drinkspermonth>0 & drinkspermonth <4
	replace lisko_etoh = 3 if drinkspermonth>=4

*FEMALES

* Minimally sufficient adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat cvascd cancer dm respdz infxdz cogimp liskoadl liskosmoke ib1.lisko_etoh if sex==0, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq if sex==0, family(Poisson) link(log) offset(logpyrs) eform"

di "Minimally sufficient adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform

* Extra adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat cvascd cancer dm respdz infxdz cogimp liskoadl liskosmoke ib1.lisko_etoh if sex==0, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq ib2.bmicat_25y ib3.edcat physact_di ib5.hei_q if sex==0, family(Poisson) link(log) offset(logpyrs) eform"

di "Extra adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform


*MALES

* Minimally sufficient adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat cvascd cancer dm respdz infxdz cogimp liskoadl liskosmoke ib1.lisko_etoh if sex==1, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq if sex==1, family(Poisson) link(log) offset(logpyrs) eform"

di "Minimally sufficient adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform

* Extra adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat cvascd cancer dm respdz infxdz cogimp liskoadl liskosmoke ib1.lisko_etoh if sex==1, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq ib2.bmicat_25y ib3.edcat physact_di ib5.hei_q if sex==1, family(Poisson) link(log) offset(logpyrs) eform"

di "Extra adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform
