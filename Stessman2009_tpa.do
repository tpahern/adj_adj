* Adjustment of Stessman 2009
* Tom Ahern - May 2023

clear
cls
cd "/Users/02tahern/Library/CloudStorage/OneDrive-UVMLarnerCollegeofMedicine/projects/flegal65plus/flegal65_adjustments" 
use clean_mi_copy, clear

run "suest.do"

* restrictions -- none, but stratified by sex

* Stessman covariate definitions

	* cancer history
	gen byte cancerhx=hac1n==1 | hac1o==1
	
	* smoking pack-years
	gen packyears=0 if smkcfn==0
	replace packyears=(har7s/20)*har8 if smkcfn==1
	replace packyears=(har4s/20)*har5 if smkcfn==2
	replace packyears=0 if packyears<0
	
	* perceived economic hardship goes to 'lowinc'

	* self-perceived health
	gen health_di=1 if inlist(hab1,1,2,3)
	replace health_di=0 if inlist(hab1,4,5)
	
	* dependence
	gen byte dependence = inlist(hah3,2,3,4) | inlist(hah4,2,3,4) | inlist(hah5,2,3,4) | inlist(hah6,2,3,4) | inlist(hah7,2,3,4) | inlist(hah8,2,3,4) | inlist(hah9,2,3,4) | inlist(hah10,2,3,4) | inlist(hah11,2,3,4) | inlist(hah12,2,3,4)

*MALES:

* Minimally sufficient adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat dm haf10 htn cancerhx lowinc physact_di dependence packyears health_di if sex==1, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq if sex==1, family(Poisson) link(log) offset(logpyrs) eform"

di "Minimally sufficient adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform

* Extra adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat dm haf10 htn cancerhx lowinc physact_di dependence packyears health_di if sex==1, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq ib2.bmicat_25y ib3.edcat physact_di ib5.hei_q if sex==1, family(Poisson) link(log) offset(logpyrs) eform"

di "Extra adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform


*FEMALES:

* Minimally sufficient adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat dm haf10 htn cancerhx lowinc physact_di dependence packyears health_di if sex==0, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq if sex==0, family(Poisson) link(log) offset(logpyrs) eform"

di "Minimally sufficient adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform

* Extra adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat dm haf10 htn cancerhx lowinc physact_di dependence packyears health_di if sex==0, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq ib2.bmicat_25y ib3.edcat physact_di ib5.hei_q if sex==0, family(Poisson) link(log) offset(logpyrs) eform"

di "Extra adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform
