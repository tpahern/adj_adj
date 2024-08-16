* Adjustment of Luchsinger 2008
* Tom Ahern - May 2023

clear
cls
use "/Users/02tahern/Library/CloudStorage/OneDrive-UVMLarnerCollegeofMedicine/projects/flegal65plus/flegal65_adjustments/clean_mi_copy.dta", clear

run "suest.do"

* restrictions

	* White, Black, and Hispanic only (drop "Other")
	drop if raceethnicity==4
	
* covariate definitions

	* continuous age: 'age'
	* gender: woman/man: 'sex'
	* Ethnic group: AA/Hisp/White: 'raceethnicity' maps after restriction
	* Education: number of years of education: 'education'
	* Cancer: dichotomous:
		gen byte cancer=hac1n==1 | hac1o==1
	* Dementia:
		* cognitive status in age 60+ boils down to story and word recall; see Noble (10.1136/jnnp.2009.174029) and Perkins (10.1093/oxfordjournals.aje.a009915) for the convention we adopted

		* for cognitive impairment, first sum story recall and word recall variables
		egen cogsum=rowtotal(mapd2a mapd2b mapd2c mapd2d mapd2e mapd2f hap19a hap19b hap19c), missing
		lab var cogsum "Sum of congitive recall variables"
		
		* now dichotomize: impaired if total is <4
		gen byte cogimp=cogsum<4
		lab var cogimp "Cognitive impairment (cogsum<4)"
	* Smoking: current/otherwise: 'smoker'
	* Diabetes: dichotomous: 'dm'
	* Hypertension: dichotomous: 'htn'
	* LDL cholesterol: continuous mg/dL: 'ldl'
		replace ldl=89 if ldl<0
	* Heart disease: dichotomous: 'haf10'
	
* Minimally sufficient adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat age sex raceethnicity education cancer cogimp smoker dm htn ldl haf10, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq, family(Poisson) link(log) offset(logpyrs) eform"

di "Minimally sufficient adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform

* Extra adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat age sex raceethnicity education cancer cogimp smoker dm htn ldl haf10, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq ib2.bmicat_25y ib3.edcat physact_di ib5.hei_q, family(Poisson) link(log) offset(logpyrs) eform"

di "Extra adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform
