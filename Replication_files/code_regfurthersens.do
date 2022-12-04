* Stata 14
* MCVL - Baseline estimation
* Jose Garcia-Louzao

clear all
capture log close
capture program drop _all
macro drop _all
set more 1
set seed 13
set cformat %5.4f

log using logs/sens_robustness1.log, replace	

use ../Data/estimationdata.dta, clear

global effect "treat S R"
global hz "piece_* tS"
global wlevel "female spanish college age emphist prevftc prevperm"
global jlevel "hs ftime logw"
global elevel "size fage industry_2-industry_6"
global mlevel "yhire_* urate fedea"

*Single unit organizations
tempfile singleplant
preserve
use ../mcvl_stata/fpanel.dta, clear
replace idfirm = idplant if idfirm==""
keep if regime==111
keep idfirm idplant year_mcvl
bys idfirm idplant: keep if _n == 1
bys idfirm: gen nobs = _N
gen multiplant = 1 if nobs!=1
keep idplant year_mcvl multiplant
save `singleplant'
restore

gen year_mcvl = yofd(dofm(mhire))
merge m:1 idplant year_mcvl using `singleplant', keep(1 3)
drop _merge

preserve
drop if multiplant==1
gunique idspell   
gunique idperson  

  rename R r
rename S s
	gsem (durquit <- treat r s $hz $wlevel $jlevel $elevel $mlevel V1[idspell])  , difficult cloglog  latent(V1) vce(cluster idspell)
restore

*Limited liability companies
preserve 
keep if legal2firm<=2
gunique idspell  
gunique idperson 

  rename R r
rename S s
	gsem (durquit <- treat r s $hz $wlevel $jlevel $elevel $mlevel V1[idspell])  , difficult cloglog  latent(V1) vce(cluster idspell)
restore

*Single Spell
preserve
bys idperson: gegen min=min(mend)
drop if mobs>min
gunique idspell  
gunique idperson
  rename R r
rename S s
	gsem (durquit <- treat r s $hz $wlevel $jlevel $elevel $mlevel V1[idspell])  , difficult cloglog  latent(V1) vce(cluster idspell)
	
restore

*Only job spells before Reform 2010
preserve
drop if  spellstart_old >= mdy(6,1,2010)
gunique idspell   
gunique idperson 
  rename R r
rename S s
	gsem (durquit <- treat r s $hz $wlevel $jlevel $elevel $mlevel V1[idspell])  , difficult cloglog  latent(V1) vce(cluster idspell)
	
restore

log close	
	
	
		