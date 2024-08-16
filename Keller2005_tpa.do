* Adjustment of Keller 2005
* Tom Ahern - April 2023
cls
use "/Users/02tahern/Library/CloudStorage/OneDrive-UVMLarnerCollegeofMedicine/projects/flegal65plus/flegal65_adjustments/clean_mi_copy.dta", clear

run "suest.do"

* no extra restrictions

* Keller covariate definitions

	* age: 64-75 (ref), 75-84, 85+
	gen kellerage=1 if age < 75
	replace kellerage=2 if age >= 75 & age < 85
	replace kellerage=3 if age >= 85
	lab def kelage_ 1 "<75" 2 "75-84" 3 "85+"
	lab val kellerage kelage_
	
	* smoking: ever regular?
	gen kellersmoke=0
	replace kellersmoke=1 if har1==1 | har23==1 | har26==1
	
	* education: 10+ years vs. 0-9
	gen kellered=0
	replace kellered=1 if education >= 10
	replace kellered=. if education==.
	
	
	* marital status: married (ref), never married, divorced
	gen kellermarcat=1 if inlist(marcat,1,4) /*married + widowed*/
	replace kellermarcat=2 if marcat==3 /*never married*/
	replace kellermarcat=3 if marcat==2 /*divorced/separated*/
	lab def kmar_ 1 "Married/widowed" 2 "Never married" 3 "Divorced"
	lab val kellermarcat kmar_
	
	* cognitive status in age 60+ boils down to story and word recall; see Noble (10.1136/jnnp.2009.174029) and Perkins (10.1093/oxfordjournals.aje.a009915) for the convention we adopted

		* for cognitive impairment, first sum story recall and word recall variables
		egen cogsum=rowtotal(mapd2a mapd2b mapd2c mapd2d mapd2e mapd2f hap19a hap19b hap19c), missing
		lab var cogsum "Sum of congitive recall variables"
		
		* now dichotomize: impaired if total is <4
		gen byte cogimp=cogsum<4
		lab var cogimp "Cognitive impairment (cogsum<4)"
		
	
	* weight change 
		* calculate BMI 10 years ago
		gen wtkg10yago=(ham8s/2.2)
		gen bmi10yago=wtkg10yago/((bmpht/100)^2)
		
		* calculate/categorize difference in interview BMI & BMI 10 years ago
		gen bmidiff10y=bmi10yago-bmi
		gen bmidiff10_cat=1 if bmidiff10y >= 0 & bmidiff10y < 2
		replace bmidiff10_cat=2 if bmidiff10y > 2
		replace bmidiff10_cat=3 if bmidiff10y < 0 & bmidiff10y >= -2
		replace bmidiff10_cat=4 if bmidiff10y < -2
		lab def bmidiff_ 1 "0 to <2" 2 ">2" 3 "-2 to <0" 4 "<-2"
		lab val bmidiff10_cat bmidiff_
	

* Minimally sufficient adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat ib1.kellerage kellersmoke kellered ib1.kellermarcat cogimp ib1.bmidiff10_cat, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq, family(Poisson) link(log) offset(logpyrs) eform"

di "Minimally sufficient adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform

* Extra adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat ib1.kellerage kellersmoke kellered ib1.kellermarcat cogimp ib1.bmidiff10_cat, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq ib2.bmicat_25y ib3.edcat physact_di ib5.hei_q, family(Poisson) link(log) offset(logpyrs) eform"

di "Extra adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform
