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

log using logs/exogshock.log, replace
	
global hz "piece_* "
global wlevel "female spanish college age emphist prevftc prevperm"
global jlevel "hs ftime logw"
global elevel "size fage industry_2-industry_6"
global mlevel "yhire_* urate fedea"

use ../Data/matchestimation1.dta, clear
keep idspell idperson durquit treat R S $hz tS $wlevel $jlevel $elevel $mlevel
rename R r
rename S s
gunique idspell
gunique idperson

	gsem (durquit <- treat r s $hz tS $wlevel $jlevel $elevel $mlevel V1[idspell]) , difficult cloglog  latent(V1) vce(cluster idspell) 

	quietly {
use ../Data/finalsample.dta, clear
egen idspell = group(idperson idplant spellstart_date spellend_date)
gen qhire = qofd(spellstart_date)

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


logit event age emphist prevftc prevperm female college i.industry i.provinceplant i.sizedec i.qhire
predict yhat1

gen score = 1/yhat1 if event==1
replace score = 1/(1-yhat1) if event==0

keep idspell score*
tempfile weight
save `weight'
}
use ../Data/estimationdata.dta, clear
keep idspell idperson durquit treat R S $hz tS $wlevel $jlevel $elevel $mlevel event
merge m:1 idspell using `weight'

rename R r
rename S s

	gsem (durquit <- treat r s $hz tS $wlevel $jlevel $elevel $mlevel [pw=score] ) , difficult cloglog  latent(V1) vce(cluster idspell)  

use ../Data/matchestimation2.dta, clear
keep idspell idperson durquit treat R S $hz tS $wlevel $jlevel $elevel $mlevel
rename R r
rename S s
gunique idspell
gunique idperson

	gsem (durquit <- treat r s $hz tS $wlevel $jlevel $elevel $mlevel V1[idspell]) , difficult cloglog  latent(V1) vce(cluster idspell)

use ../Data/estimationdata.dta, clear
keep idspell idperson durquit durdep treat R S $hz tS $wlevel $jlevel $elevel $mlevel event provinceplant mobs spellstart_date idplant
rename R r
rename S s

gen logdurdep=ln(durdep)
gen logdurdep2 = logdurdep*logdurdep
gen logdurdep3 = logdurdep*logdurdep*logdurdep

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

gen yhat = .
quietly {
forvalues n = 7/84 {
logit s age emphist prevftc prevperm female college $jlevel $elevel yhire_2006-yhire_2010 urate fedea if durdep==`n'
predict prob
replace yhat = prob if durdep==`n'
drop prob
}
}


gen score = 1/yhat if s==1
replace score = 1/(1-yhat) if s==0

		gsem (durquit <- treat r s $hz tS $wlevel $jlevel $elevel $mlevel [pw=score]) , difficult cloglog  latent(V1) vce(cluster idspell)
		
log close




/*
log using logs/exogshock_2.log, replace

use ../Data/estimationdata.dta, clear
keep idspell idperson durquit durdep treat R S $hz tS $wlevel $jlevel $elevel $mlevel

sample2 20, cluster(idspell)

rename R r
rename S s

stcrmix (durquit = treat r s $hz tS $wlevel $jlevel $elevel $mlevel) (s = $hz $wlevel $jlevel $elevel $mlevel ) , ///
id(idspell) time(durdep) evaltype(gf2) method(trust) technique(bfgs 60nr 10) fullmax np(1 10) maxiter(300)

log close




log close
