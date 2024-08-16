* Adjustment of Cesari 2009
* Tom Ahern - May 2023

clear
cls
cd "/Users/02tahern/Library/CloudStorage/OneDrive-UVMLarnerCollegeofMedicine/projects/flegal65plus/flegal65_adjustments" 
use clean_mi_copy, clear

run "suest.do"

* restriction to "no low walking speed" and "no sarcopenia"

	* NB: Restrictions will behave differently across imputed data sets, yielding problem due to different study populations across 'm'...so first apply restrictions in m=1, then come back and delete the ineligible record_id from all m.
	
	* start with the m=1
	keep if _mi_m==1

	* create indicators for the two restriction criteria
	* low walking speed
	* first express 8-foot time walk result as max(2 trials) converted to meters/second
	replace pfptwlka=abs(pfptwlka)
	replace pfptwlkb=abs(pfptwlkb)
	gen walkspeed=2.4384/max(pfptwlka,pfptwlkb)
	lab var walkspeed "Walking speed, m/s"
	
	* thirds of walking speed
	egen walkspeed3=cut(walkspeed), group(3)
	
	* Cesari made their "not low walking speed" group the top two thirds of walking speeds, so:
	gen byte dropwalk=walkspeed3==0 /* indicator to drop for walking speed*/


	* sarcopenia
	* first calculate skeletal muscle mass per Van Dongen + Janssen, using BIA resistance (pep12a1)
	gen smm_kg = (((bmpht^2)/pep12a1)*0.401) + (sex * 3.825) + (age * -0.071) + 5.102
	
	* now calculate skeletal muscle index per Van Dongen
	gen smi_vd = smm_kg / bmpwt
	
	* classify sarcopenia per Van Dongen
	gen sarco=0
	replace sarco=1 if smi_vd < 0.367 & sex==1
	replace sarco=1 if smi_vd < 0.266 & sex==0
	
	* restrict to "no sarcopenia" group
	gen byte dropsarco=sarco==1
	
	* overall drop indicator
	gen byte cesaridrop=dropwalk==1 | dropsarco==1
	
	keep seqn cesaridrop 

save cesaridrop, replace

* restrict the multiply-imputed datasets to the same subjects per m
use clean_mi_copy, clear
drop _merge
merge m:1 seqn using cesaridrop 
drop if cesaridrop==1


* Cesari covariate definitions

		* in lieu of MMSE: use cognitive impairment as defined for Keller 2005
		* cognitive status in NHANES III age 60+ boils down to story and word recall; see Noble (10.1136/jnnp.2009.174029) and Perkins (10.1093/oxfordjournals.aje.a009915) for the convention we adopted

			* for cognitive impairment, first sum story recall and word recall variables
			egen cogsum=rowtotal(mapd2a mapd2b mapd2c mapd2d mapd2e mapd2f hap19a hap19b hap19c), missing
			lab var cogsum "Sum of congitive recall variables"
			
			* now dichotomize: impaired if total is <4
			gen byte cogimp=cogsum<4
			lab var cogimp "Cognitive impairment (cogsum<4)"
			
		* depression - 'major depressive episide' per Mussolino et al
			* missing for all subjects in our older stratum
		
		* respiratory disease
		gen byte resp = hal19c==1 | hac1g==1
		
		* peripheral artery disease
		gen byte pad = fpp1189==1 | fpp1188==1
		
		* log(crp)
		replace crp=0.001 if crp<=0
		gen logcrp = log10(crp)


* Minimally sufficient adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat age sex education cogimp physact_di hac1n chde htn pad resp hac1a hac1d logcrp, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq, family(Poisson) link(log) offset(logpyrs) eform"

di "Minimally sufficient adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform


* Extra adjustment
mi estimate, post: mysuest "svy: glm mortstat ib2.bmicat age sex education cogimp physact_di hac1n chde htn pad resp hac1a hac1d logcrp, family(Poisson) link(log) offset(logpyrs) eform" "svy: glm mortstat ib2.bmicat ib0.agecat_fine sex ib0.smkcfn_tsq ib2.bmicat_25y ib3.edcat physact_di ib5.hei_q, family(Poisson) link(log) offset(logpyrs) eform"

di "Extra adjustment"
lincom [est2_mortstat]3.bmicat-[est1_mortstat]3.bmicat, eform
