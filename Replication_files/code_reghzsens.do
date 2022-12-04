* Stata 16
* MCVL - Hazard rate
* Jose Garcia-Louzao

set seed 13
set cformat %5.4f
clear all
set max_memory 240g
set segmentsize 3g

use ../Data/estimationdata.dta, clear

global hz "piece_* tS "
global wlevel "female spanish college age emphist prevftc prevperm"
global jlevel "hs ftime logw"
global elevel "size fage industry_2-industry_6"
global mlevel "yhire_* urate fedea"

keep idspell idperson durquit durlayoff durdep other treat R S $hz tS $wlevel $jlevel $elevel $mlevel

rename S s
rename R r

timer on 1

* 1-level random effects cloglog model // Benchmark model
gsem (durquit <- treat r s $hz tS $wlevel $jlevel $elevel $mlevel V1[idspell]) , ///
cloglog latent(V1) ltol(0) tol(1e-7)  vce(cluster idspell) difficult

* 1-level random effects logit model
gsem (durquit <- treat r s $hz tS $wlevel $jlevel $elevel $mlevel V1[idspell]) , ///
logit  latent(V1)  iterate(50) ltol(0) tol(1e-7)  vce(cluster idspell) difficult

* 2-level random effects cloglog model with shared variance component
gsem (durquit <- treat r s $hz $wlevel $jlevel size fage industry_2-industry_6 urate fedea V1[idspell]) ///
(durlayoff <- treat s r $hz $wlevel $jlevel size fage industry_2-industry_6 urate fedea V1[idspell]), ///
cloglog latent(V1) difficult iterate(100) ltol(0) tol(1e-7)   vce(cluster idspell)

* 2-level random effects cloglog model with separate but correlated random effects
gsem (durquit <- treat r s $hz $wlevel $jlevel $elevel $mlevel V1[idspell]@1) (durlayoff <- treat s r $hz $wlevel $jlevel $elevel $mlevel V2[idspell]@1), ///
cloglog latent(V1 V2) cov(V1[idspell]*V2[idspell]) difficult iterate(197) ltol(0) tol(1e-7) technique(bhhh 5 bfgs 5 bhhh 10 bfgs 10 bhhh 15 bfgs 15 nr 150)  vce(cluster idspell)

timer off 1
timer list 1


