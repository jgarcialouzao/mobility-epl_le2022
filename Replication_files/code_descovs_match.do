* Stata 14
* MCVL - Descriptive summary stats of charcateristics
* Jose Garcia-Louzao


clear all
capture log close
capture program drop _all
set more 1
set seed 13

*Table covariates: matched samples


use ../Data/matchedsample1.dta, clear
global wcovs   "female spanish college age emphist prevnonemp"

gen mhire = mofd(spellstart_date)
keep if event ==  0
unique idperson
sort idperson mhire
bys idperson: keep if _n == 1
estpost tabstat $wcovs ,  statistics(mean) columns(statistics) 
est store T3

use ../Data/matchedsample1.dta, clear
gen mhire = mofd(spellstart_date)
keep if event ==  1
unique idperson
sort idperson mhire
bys idperson: keep if _n == 1
estpost tabstat $wcovs ,  statistics(mean) columns(statistics) 
est store T4

use ../Data/matchedsample2.dta, clear
gen mhire = mofd(spellstart_date)
keep if shock ==  0
unique idperson
sort idperson mhire
bys idperson: keep if _n == 1
estpost tabstat $wcovs ,  statistics(mean) columns(statistics) 
est store T5

use ../Data/matchedsample2.dta, clear
gen mhire = mofd(spellstart_date)
keep if shock ==  1
unique idperson
sort idperson mhire
bys idperson: keep if _n == 1
estpost tabstat $wcovs ,  statistics(mean) columns(statistics) 
est store T6

esttab T* using ../Tables/desccovsmatch_wlevel.tex, replace cells("mean(fmt(a3))") label booktabs nonum gaps f 

* Job-level
global jcovs "ftime hs rdstartw"
use ../Data/matchedsample1.dta, clear
keep if event ==  0
estpost tabstat $jcovs ,  statistics(mean) columns(statistics) 
est store T3

use ../Data/matchedsample1.dta, clear
keep if event ==  1
estpost tabstat $jcovs ,  statistics(mean) columns(statistics) 
est store T4
 
use ../Data/matchedsample2.dta, clear
keep if shock ==  0
estpost tabstat $jcovs ,  statistics(mean) columns(statistics) 
est store T5



use ../Data/matchedsample2.dta, clear
keep if shock ==  1
estpost tabstat $jcovs ,  statistics(mean) columns(statistics) 
est store T6


use ../Data/matchedsample1.dta, clear

esttab T* using ../Tables/desccovsmatch_jlevel.tex, replace cells("mean(fmt(a3))") label booktabs nonum gaps f 


* Employer-level
global ecovs   "serv bigcity fage size"

use ../Data/matchedsample1.dta, clear
gen mhire = mofd(spellstart_date)

keep if event ==  0
unique idplant
sort idplant mhire
bys idplant: keep if _n == 1
estpost tabstat $ecovs ,  statistics(mean) columns(statistics) 
est store T3

use ../Data/matchedsample1.dta, clear
gen mhire = mofd(spellstart_date)

keep if event ==  1
unique idplant
sort idplant mhire
bys idplant: keep if _n == 1
estpost tabstat $ecovs,  statistics(mean) columns(statistics) 
est store T4

use ../Data/matchedsample2.dta, clear
gen mhire = mofd(spellstart_date)

keep if shock ==  0
unique idplant
sort idplant mhire
bys idplant: keep if _n == 1
estpost tabstat $ecovs ,  statistics(mean) columns(statistics) 
est store T5

use ../Data/matchedsample2.dta, clear
gen mhire = mofd(spellstart_date)

keep if shock ==  1
unique idplant
sort idplant mhire
bys idplant: keep if _n == 1
estpost tabstat $ecovs,  statistics(mean) columns(statistics) 
est store T6

esttab T* using ../Tables/desccovsmatch_elevel.tex, replace cells("mean(fmt(a3))") label booktabs nonum gaps f 



********************************************************************************
