* Adjustment of Zunzunegui 2012
* Tom Ahern - May 2023

clear
cls
use "/Users/02tahern/Library/CloudStorage/OneDrive-UVMLarnerCollegeofMedicine/projects/flegal65plus/flegal65_adjustments/clean_mi_copy.dta", clear

run "suest.do"

* restrictions (none)
	
* covariate definitions

	* Age: 'age'
	* Sex: 'sex'
	* Education: dichotomous based on literate/otherwise:
		* proxy by 5th grade or less
		gen byte literate=education>5
	* Smoking: current/former/never: 'smkcfn'
	* Physical activity: light/moderate/vigorous: 'physact_sum' in 3 categories:
		gen physact3=physact_sum
		replace physact3=2 if physact_sum>2

	* Chronic conditions (sum and categorize)
		* hypertension: 'htn'
		* heart disease: 'cvascd'
			gen byte cvascd = hac1c==1 | haf10==1 | chde==1 | hac1d==1 | htn==1
		* stroke: 'hac1d'
		* peripheral vascular disease: 
			gen byte pvd=fpp1189==1 | fpp1188==1
		* diabetes: 'dm'
		* respiratory disease
			gen byte resp = hal19c==1 | hac1g==1
		* joint/bone:
			gen byte bonejoint=1 if hag11==1 | hac1a==1
		* cancer: dichotomous
			gen byte cancer=hac1n==1 | hac1o==1
			
		egen comorbsum=rowtotal(htn cvascd hac1d pvd dm resp bonejoint cancer)
		gen comorbcat=1 if inlist(comorbsum,0,1)
		replace comorbcat=2 if inlist(comorbsum,2,3,4,5)
		replace comorbcat=3 if inlist(comorbsum,6,7)
	
	* ADL-based definition as per Lisko adjustment:
	* 1=no difficulty, 2=some, 3=much, 4=unable to do
	gen adl=0 if hah5==1 & hah6==1 & hah8==1 & hah10==1 & hah11==1 & hah12==1
	replace adl=2 if hah5==4 | hah6==4 | hah8==4 | hah10==4 | hah11==4 | hah12==4
	replace adl=1 if adl==.
	
* Minimally sufficient adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat age sex literate ib0.smkcfn ib0.physact3 ib1.comorbcat ib0.adl, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq, family(Poisson) link(log) offset(logpyrs) eform"

di "Minimally sufficient adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform

* Extra adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat age sex literate ib0.smkcfn ib0.physact3 ib1.comorbcat ib0.adl, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq ib2.bmicat_25y ib3.edcat physact_di ib5.hei_q, family(Poisson) link(log) offset(logpyrs) eform"

di "Extra adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform
