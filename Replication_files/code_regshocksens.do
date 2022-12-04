* Stata 14
* MCVL - Sensitivity analysis: Layoff shock time window
* Jose Garcia-Louzao

clear all
capture log close
capture program drop _all
macro drop _all
set more 1
set seed 13
set cformat %5.4f

log using logs/sensrisk.log, replace	

use ../Data/estimationdata.dta, clear


* Fixed variables
global hz "piece_* "
global wlevel "female spanish college age emphist prevftc prevperm"
global jlevel "hs ftime logw"
global elevel "size fage industry_2-industry_6"
global mlevel "yhire_* urate fedea"


foreach n in 6 9 11 13 15 18 { 
preserve

drop mshock S treat tS 
gen mshock = mofd(PEstart) - `n'


*Layoff shock
gen S = 1 if mobs > mshock 
recode S .=0

bys idspell S (mobs) : gen tS = _n
replace tS = 0 if S == 0

*Treatment effect dummy; this captures the incremental effect of experiencing both events
gen treat = S==1 & R==1 
label var treat "Treatment effect"

unique idspell
unique idperson

rename R r
rename S s

*Same experiment: only those affected by the shock once they already qualify for SP


keep if mshock  - mofd(spellstart_old)  >= 6
drop if tS>12

	gsem (durquit <- treat r s $hz tS $wlevel $jlevel $elevel $mlevel V1[idspell]) , difficult cloglog  latent(V1) vce(cluster idspell)


restore

}

log close


