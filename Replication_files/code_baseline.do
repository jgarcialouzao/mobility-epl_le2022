* Stata 14
* MCVL - Table 1 Appendix 
* Jose Garcia-Louzao

clear all
capture log close
capture program drop _all
set more 1
set seed 13

log using logs/desc1.log, replace	

* Job-level
use ../Data/initialsample.dta, clear

*Define var lists
global depvar  "sep quit layoff otherall dur durcens dursep"
global policy  "reform shock"
global jcovs   "perm ftime hs rdstartw"


**Original dataset full info
gegen id = tag(idperson)
gegen numworkers = total(id)
drop id
gegen id = tag(idplant_start)
gegen numplants = total(id)
drop id
gegen id = tag(idfirm)
gegen numfirms = total(id)
drop id
estpost tabstat $depvar $policy $jcovs num*,  statistics(mean) columns(statistics) 
est store orig
drop num*

count

**Starting sample

*Hire Jan2005 onwards
keep if spellstart_date>=mdy(1,1,2005)
*Drop old reasons of termination or not specific cause, should not exist after 2000
drop if reason_endspell == 61 | reason_endspell==64 | reason_endspell==96 

*Private sector establishments 
gen flag = 1 if  (legal2firm>=11 & legal2firm<=14) | type2plant<5081 |  sector1d==1 | sector2d == 97 | sector1d>=13 
bys idplant (flag): replace flag = flag[1] if flag==.
drop if flag == 1
drop flag


gegen id = tag(idperson)
gegen numworkers = total(id)
drop id
gegen id = tag(idplant)
gegen numplants = total(id)
drop id
gegen id = tag(idfirm)
gegen numfirms = total(id)
drop id
estpost tabstat $depvar $policy $jcovs num*  ,  statistics(mean) columns(statistics) 
est store initial
drop num* 

count


*Establishments that ever had 5 employees between 2005 and 2018
keep if size5==1


gegen id = tag(idperson)
gegen numworkers = total(id)
drop id
gegen id = tag(idplant)
gegen numplants = total(id)
drop id
gegen id = tag(idfirm)
gegen numfirms = total(id)
drop id
estpost tabstat $depvar $policy $jcovs  num*,  statistics(mean) columns(statistics) 
est store res1
drop num* 


*Workers age 50 or younger
gen age_disp = yofd(spellend_date) - yofd(datebirth)
keep if age_disp<=50
drop age_disp
drop if reason_endspell==58 | contract==540


gegen id = tag(idperson)
gegen numworkers = total(id)
drop id
gegen id = tag(idplant)
gegen numplants = total(id)
drop id
gegen id = tag(idfirm)
gegen numfirms = total(id)
drop id
estpost tabstat $depvar $policy $jcovs num*,  statistics(mean) columns(statistics) 
est store res2
drop num* 


*Permanent contracts that qualify for severance pay when they are affected by any of the events
keep if perm==1 
keep if dur > 6


gegen id = tag(idperson)
gegen numworkers = total(id)
drop id
gegen id = tag(idplant)
gegen numplants = total(id)
drop id
gegen id = tag(idfirm)
gegen numfirms = total(id)
drop id
estpost tabstat $depvar $policy $jcovs num*,  statistics(mean) columns(statistics) 
est store res3
drop num* 


*Final sample
keep if  (mofd(PEstart) - 12)  - mofd(spellstart_old)  >= 6
keep if  mofd(mdy(2,12,2012))  - mofd(spellstart_old)  >= 6
keep if merged<=2


gegen id = tag(idperson)
gegen numworkers = total(id)
drop id
gegen id = tag(idplant)
gegen numplants = total(id)
drop id

gegen id = tag(idfirm)
gegen numfirms = total(id)
drop id
estpost tabstat $depvar $policy $jcovs num*  ,  statistics(mean) columns(statistics) 
est store res4
drop num* reason* 


esttab orig* initial* res* using ../Tables/descall_jlevel.tex, replace cells("mean(fmt(a3))") label booktabs nonum gaps f 


save ../Data/finalsample.dta, replace 

log close












