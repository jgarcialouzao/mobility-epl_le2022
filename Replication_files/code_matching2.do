* Stata 14
* MCVL - Sensitivity analysis: Matched sample (1)
* Jose Garcia-Louzao

clear all
capture log close
capture program drop _all
macro drop _all
set more 1
set seed 13

log using logs/matching.log, replace	

use ../Data/finalsample.dta, clear

egen idspell = group(idperson spellstart_date spellend_date idplant)

qui do ../codes/provtoreg.do
gen qhire = qofd(spellstart_date)

/*
bys idplant idspell (spellstart_date): gen one = (_n == 1)
xtile sizedec = size if one==1, nq(4)
bys idplant (sizedec): replace sizedec = sizedec[1] if sizedec==.
*/

preserve
bys idplant: keep if _n == 1
keep idplant
merge 1:m idplant using ../mcvl_stata/fpanel.dta, keep(match)
drop _m
drop if size==0
bys idplant: gegen msize = mean(size)
bys idplant: keep if _n == 1
xtile sizedec = msize, nq(4)
keep idplant sizedec
tempfile sizedec
save `sizedec'
restore
merge m:1 idplant using `sizedec', keep(match)
drop _m 

*Propensity score
logit shock age emphist prevftc prevperm
predict score


preserve
keep if shock==1
bys qhire female college industry provinceplant sizedec (spellstart_date spellend_date): gen nobs = _n
save ../Data/treated.dta, replace
restore

preserve 
keep if shock==0
save ../Data/control.dta, replace
restore


forvalues n = 1/83  {
use ../Data/treated.dta, clear
keep if nobs==`n'
drop nobs
rename idspell idtreat
rename score score_t
keep idtreat qhire female college industry provinceplant sizedec score 
merge 1:m qhire female college industry provinceplant sizedec using ../Data/control.dta,  keepusing(idspell spellstart_date spellend_date score)
keep if _m == 3
drop _merge

*Keep only one valid control
* Use nearest neighbor

gen near = abs(score_t - score)
bys idtreat: egen nearest = min(near)
keep if nearest == near
drop nearest near

bys idtreat (spellstart_date spellend_date idspell): keep if _n == 1
drop score*
keep idspell idtreat

preserve
drop idspell
rename idtreat idspell
gen idtreat = idspell
merge 1:1 idspell using ../Data/treated.dta, keep(match) 
tempfile tempt`n'
save `tempt`n''
drop _merge
restore
preserve
merge 1:1 idspell using ../Data/control.dta,  keep(match) 
tempfile tempc`n'
save `tempc`n''
drop _merge
restore
}


use `tempt1', clear
forvalues w=2/83 {
append using `tempt`w''
}
forvalues y=1/83 {
append using `tempc`y''
}
save ../Data/matchedsample2.dta, replace


