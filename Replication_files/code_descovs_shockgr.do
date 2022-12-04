* Stata 14
* MCVL - Descriptive summary stats of charcateristics; shock groups
* Jose Garcia-Louzao


clear all
capture log close
capture program drop _all
set more 1
set seed 13

*Table covariates: noshocknoreform vs noshockreform; shocknoreform vs shockreform
* Worker-level
use ../Data/finalsample.dta, clear
global wcovs   "female spanish college age emphist prevnonemp"
gen mhire=mofd(spellstart_date)


preserve 
keep if shock==0 & reform==0
sort idperson mhire
bys idperson: keep if _n == 1
estpost tabstat $wcovs ,  statistics(mean) columns(statistics) 
est store noshocknoref
restore 

preserve 
keep if shock==1 & reform==0
sort idperson mhire
bys idperson: keep if _n == 1
estpost tabstat $wcovs ,  statistics(mean) columns(statistics) 
est store noshockref
restore 


preserve 
keep if shock==0 & reform==1
sort idperson mhire
bys idperson: keep if _n == 1
estpost tabstat $wcovs ,  statistics(mean) columns(statistics) 
est store shocknoref
restore 

preserve 
keep if shock==1 & reform==1
sort idperson mhire
bys idperson: keep if _n == 1
estpost tabstat $wcovs ,  statistics(mean) columns(statistics) 
est store shockref
restore 

esttab noshocknoref noshockref shocknoref shockref using ../Tables/desccovsshock_wlevel.tex, replace cells("mean(fmt(a3))") label booktabs nonum gaps f 

* Job-level
use ../Data/finalsample.dta, clear

gen cens = 1 if sep == 0
recode cens . = 0
gen mhire=mofd(spellstart_date)


global jcovs "quit layoff otherall cens  ftime hs rdstartw"


preserve 
keep if shock==0 & reform==0
estpost tabstat $jcovs ,  statistics(mean) columns(statistics) 
est store noshocknoref
restore 

preserve 
keep if shock==1 & reform==0
estpost tabstat $jcovs ,  statistics(mean) columns(statistics) 
est store noshockref
restore  

preserve 
keep if shock==0 & reform==1
estpost tabstat $jcovs ,  statistics(mean) columns(statistics) 
est store shocknoref
restore 

preserve 
keep if shock==1 & reform==1
estpost tabstat $jcovs ,  statistics(mean) columns(statistics) 
est store shockref
restore 


esttab noshocknoref noshockref shocknoref shockref using ../Tables/desccovsshock_jlevel.tex, replace cells("mean(fmt(a3))") label booktabs nonum gaps f 


* Employer-level
use ../Data/finalsample.dta, clear
global ecovs   "serv bigcity fage size"
gen mhire=mofd(spellstart_date)


preserve 
keep if shock==0 & reform==0
sort idplant mhire
bys idplant: keep if _n == 1
estpost tabstat $ecovs ,  statistics(mean) columns(statistics) 
est store noshocknoref
restore 

preserve 
keep if shock==1 & reform==0
sort idplant_start mhire
bys idplant: keep if _n == 1
estpost tabstat $ecovs,  statistics(mean) columns(statistics) 
est store noshockref
restore


preserve 
keep if shock==0 & reform==1
sort idplant_start mhire
bys idplant: keep if _n == 1
estpost tabstat $ecovs ,  statistics(mean) columns(statistics) 
est store shocknoref
restore 

preserve 
keep if shock==1 & reform==1
sort idplant mhire
bys idplant: keep if _n == 1
estpost tabstat $ecovs ,  statistics(mean) columns(statistics) 
est store shockref
restore

esttab noshocknoref noshockref shocknoref shockref using ../Tables/desccovsshock_elevel.tex, replace cells("mean(fmt(a3))") label booktabs nonum gaps f 
