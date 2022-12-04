* Stata 14
* MCVL - Descriptive summary stats of charcateristics
* Jose Garcia-Louzao


clear all
capture log close
capture program drop _all
set more 1
set seed 13

*Table covariates: NO SHOCK vs SHOCK and No reform vs reform
* Worker-level
use ../Data/finalsample.dta, clear
global wcovs  "female spanish college age emphist prevnonemp"
gen mhire=mofd(spellstart_date)

preserve
sort idperson mhire
bys idperson: keep if _n == 1
estpost tabstat $wcovs,  statistics(mean) columns(statistics) 
est store all
restore

preserve 
keep if shock == 0
sort idperson mhire
bys idperson: keep if _n == 1
estpost tabstat $wcovs ,  statistics(mean) columns(statistics) 
est store noshock
restore 

preserve 
keep if shock == 1
sort idperson mhire
bys idperson: keep if _n == 1
estpost tabstat $wcovs ,  statistics(mean) columns(statistics) 
est store shock
restore 

preserve 
keep if reform == 0
sort idperson mhire
bys idperson: keep if _n == 1
estpost tabstat $wcovs ,  statistics(mean) columns(statistics) 
est store noreform
restore 

preserve 
keep if reform == 1
sort idperson mhire
bys idperson: keep if _n == 1
estpost tabstat $wcovs ,  statistics(mean) columns(statistics) 
est store reform
restore 

esttab all noshock shock noreform reform using ../Tables/desccovs_wlevel.tex, replace cells("mean(fmt(a3))") label booktabs nonum gaps f 

* Job-level
use ../Data/finalsample.dta, clear
gen cens = 1 if sep == 0
recode cens . = 0
gen mhire=mofd(spellstart_date)


global jcovs "quit layoff otherall cens  ftime hs rdstartw"

estpost tabstat $jcovs ,  statistics(mean) columns(statistics) 
est store all

preserve 
keep if shock == 0
estpost tabstat $jcovs ,  statistics(mean) columns(statistics) 
est store noshock
restore 

preserve 
keep if shock == 1
estpost tabstat $jcovs ,  statistics(mean) columns(statistics) 
est store shock
restore  


preserve 
keep if reform == 0
estpost tabstat $jcovs ,  statistics(mean) columns(statistics) 
est store noreform
restore 

preserve 
keep if reform == 1
estpost tabstat $jcovs ,  statistics(mean) columns(statistics) 
est store reform
restore  

esttab  all noshock shock noreform reform  using ../Tables/desccovs_jlevel.tex, replace cells("mean(fmt(a3))") label booktabs nonum gaps f 




* Employer-level
use ../Data/finalsample.dta, clear
gen mhire=mofd(spellstart_date)

global ecovs   "serv bigcity fage size"


preserve
sort idplant mhire
bys idplant: keep if _n == 1
estpost tabstat $ecovs,  statistics(mean) columns(statistics) 
est store all
restore

preserve 
keep if shock == 0
sort idplant mhire
bys idplant: keep if _n == 1
estpost tabstat $ecovs ,  statistics(mean) columns(statistics) 
est store noshock
restore 

preserve 
keep if shock == 1
sort idplant mhire
bys idplant: keep if _n == 1
estpost tabstat $ecovs,  statistics(mean) columns(statistics) 
est store shock
restore

preserve 
keep if reform == 0
sort idplant mhire
bys idplant: keep if _n == 1
estpost tabstat $ecovs ,  statistics(mean) columns(statistics) 
est store noreform
restore 

preserve 
keep if reform == 1
sort idplant mhire
bys idplant: keep if _n == 1
estpost tabstat $ecovs ,  statistics(mean) columns(statistics) 
est store reform
restore

esttab all noshock shock noreform reform  using ../Tables/desccovs_elevel.tex, replace cells("mean(fmt(a3))") label booktabs nonum gaps f 


