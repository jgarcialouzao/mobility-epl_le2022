* Stata 16
* MCVL - Heterogeneity
* Jose Garcia-Louzao

clear all
capture log close
capture program drop _all
macro drop _all
set more 1
set seed 13
set cformat %5.4f

log using logs/unobshetsens.log, replace	


use ../Data/estimationdata.dta, clear

* Fixed variables
global hz "piece_* tS"
global wlevel "female spanish college age emphist prevftc prevperm"
global jlevel "hs ftime logw"
global elevel "size fage industry_2-industry_6"
global mlevel "yhire_* urate fedea"

rename R r
rename S s

keep idspell idperson idplant idfirm durquit durdep treat r s $hz tS $wlevel $jlevel $elevel $mlevel

*no unobs
gsem (durquit <- treat s r $hz $wlevel $jlevel $elevel $mlevel ) , difficult cloglog  vce(cluster idspell)

*unobs shared person-level
gsem (durquit <- treat s r $hz $wlevel $jlevel $elevel $mlevel V1[idperson]) , difficult cloglog  latent(V1) vce(cluster idspell)

*unobs shared plant-level
gsem (durquit <- treat s r $hz $wlevel $jlevel $elevel $mlevel V1[idplant]) , difficult cloglog  latent(V1) vce(cluster idspell)

*unobs shared firm level
gsem (durquit <- treat s r $hz $wlevel $jlevel $elevel $mlevel V1[idfirm]) , difficult cloglog  latent(V1) vce(cluster idspell)

* 2-mass points - HS // gllamm needs installation in some Stata versions
gllamm durquit treat s r $hz $wlevel $jlevel $elevel $mlevel , i(idspell) ip(fn) nip(2) f(bin) l(cll) allc   nocons difficult iterate(150) cluster(idspell)


log close





