* Adjustment of Gale 2007
* Tom Ahern - May 2023

clear
cls
cd "/Users/02tahern/Library/CloudStorage/OneDrive-UVMLarnerCollegeofMedicine/projects/flegal65plus/flegal65_adjustments" 
use clean_mi_copy, clear

run "suest.do"

* restrictions -- none


* Gale covariate definitions

	* physical activity: 4-level ordinal
	gen physact_gale=0 if physact_sum==0
	replace physact_gale=1 if physact_sum==1
	replace physact_gale=2 if physact_sum==2
	replace physact_gale=3 if inlist(physact_sum,3,4,5)
	
	* comorbidities yes/no
	gen byte comorb=hac1n==1 | hac1o==1 | hac1c==1 | haf10==1 | chde==1 | hac1d==1 | htn==1 | hae2==1 | fpp1189==1 | fpp1188==1 | had1==1 | diabetes==1 | dm==1 | hal19c==1 | hac1g==1 | hak6==1 | sppq5==1 | pep13c==1 | hak4==1 | hag11==1 | hac1a==1 | hae7==1
	
	* caloric intake fix
	replace ncpnkcal=341 if ncpnkcal<0
	
		
	* weight change 
		* calculate BMI 10 years ago
		gen wtkg10yago=(ham8s/2.2)
		gen bmi10yago=wtkg10yago/((bmpht/100)^2)
		
		* calculate/categorize difference in interview BMI & BMI 10 years ago
		gen bmidiff10y=round(bmi10yago-bmi,1)
		gen wtchg=1 if bmidiff10y==0
		replace wtchg=2 if bmidiff10y<0
		replace wtchg=3 if bmidiff10y>0
		lab def wtchg_ 1 "No change" 2 "Weight loss" 3 "Weight gain"
		lab val wtchg wtchg_

		* in lieu of manual vs. non-manual labor: family income <20k
		lab def hff18_ 0 "No income" 1 "<20k" 2 ">=20k"
		lab val hff18 hff18_


* Minimally sufficient adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat ib1.agecat bmpht smoker ib2.hff18 physact_gale comorb ncpnkcal ib1.wtchg bmi, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq, family(Poisson) link(log) offset(logpyrs) eform"

di "Minimally sufficient adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform

* Extra adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat ib1.agecat bmpht smoker ib2.hff18 physact_gale comorb ncpnkcal ib1.wtchg bmi, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq ib2.bmicat_25y ib3.edcat physact_di ib5.hei_q, family(Poisson) link(log) offset(logpyrs) eform"

di "Extra adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform
