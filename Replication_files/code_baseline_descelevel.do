
* Employer-level
clear all
capture log close
capture program drop _all
set more 1
set seed 13



log using logs/desc1e.log, replace	

* Worker-level
use ../Data/initialsample.dta, clear
gen mhire=mofd(spellstart_date)
global ecovs   "serv bigcity fage size"

preserve
sort idplant mhire
bys idplant: keep if _n == 1
estpost tabstat $ecovs,  statistics(mean) columns(statistics) 
est store orig
restore

**Starting sample

*Hire Jan2005 onwards
keep if spellstart_date>=mdy(1,1,2005)
*Drop old reasons of termination or not specific cause, should not exist after 2000
drop if reason_endspell == 61 | reason_endspell==64 | reason_endspell==96 
*Private sector establishments with at least one year of plant-level employment equal 5
gen flag = 1 if  (legal2firm>=11 & legal2firm<=14) | type2plant<5081 |  sector1d==1 | sector2d == 97 | sector1d>=13 
bys idplant (flag): replace flag = flag[1] if flag==.
drop if flag == 1
drop flag

preserve
sort idplant mhire
bys idplant: keep if _n == 1
estpost tabstat $ecovs* ,  statistics(mean) columns(statistics) 
est store initial
restore

*Establishments that ever had 5 employees between 2005 and 2018
keep if size5==1

preserve
sort idplant mhire
bys idplant: keep if _n == 1
estpost tabstat $ecovs,  statistics(mean) columns(statistics) 
est store res1
restore

*Workers age 50 or younger
gen age_disp = yofd(spellend_date) - yofd(datebirth)
keep if age_disp<=50
drop age_disp
drop if reason_endspell==58 | contract==540

preserve
sort idplant mhire
bys idplant: keep if _n == 1
estpost tabstat $ecovs,  statistics(mean) columns(statistics) 
est store res2
restore


*Permanent contracts that qualify for severance pay when they are affected by any of the events
keep if perm==1 
keep if dur > 6

preserve
sort idplant mhire
bys idplant: keep if _n == 1
estpost tabstat $ecovs,  statistics(mean) columns(statistics) 
est store res3
restore

*Final sample
keep if  (mofd(PEstart) - 12)  - mofd(spellstart_old)  >= 6
keep if  mofd(mdy(2,12,2012))  - mofd(spellstart_old)  >= 6
keep if merged<=2

preserve
sort idplant mhire
bys idplant: keep if _n == 1
estpost tabstat $ecovs ,  statistics(mean) columns(statistics) 
est store res4
restore


esttab orig* initial res* using ../Tables/descall_elevel.tex, replace cells("mean(fmt(a3))") label booktabs nonum gaps f 


