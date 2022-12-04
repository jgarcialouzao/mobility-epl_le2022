* Stata 14
* MCVL - Sensitivity analysis: Reform moment
* Jose Garcia-Louzao

clear all
capture log close
capture program drop _all
macro drop _all
set more 1
set seed 13
set cformat %5.4f

log using logs/sensreform1.log, replace	

use ../Data/estimationdata.dta, clear

*alternative using JIGP

* Fixed variables
global hz "piece_*"
global wlevel "female spanish college age emphist prevftc prevperm"
global jlevel "hs ftime logw"
global elevel "size fage industry_2-industry_6"
global mlevel "yhire_* urate fedea"

*keep idperson idspell mobs mhire dur* treat S R tS pieceS* mshock mreform spellstart_date $hz $wlevel $jlevel $elevel $mlevel PE* reason_endspell active size5

** Reform February 2010

preserve

drop R treat mreform 

gen mreform = mofd(mdy(2,12,2010))

*Reform 
gen R = 1 if mobs > mreform 
recode R . = 0
label var R "Post-reform"



*Treatment effect dummy; this captures the incremental effect of experiencing both events
gen treat = S==1 & R==1 
label var treat "Treatment effect"


*keep if mobs<=mofd(mdy(2,12,2012))
keep if  mreform  - mofd(spellstart_old)   >=6	
keep if durdep<=62

unique idspell
unique idperson

rename R r
rename S s


	gsem (durquit <- treat r s $hz tS $wlevel $jlevel $elevel $mlevel V1[idspell]) , difficult cloglog  latent(V1) vce(cluster idspell)
	

restore	


** Reform November 2009
	
preserve

drop R treat  mreform 

gen mreform = mofd(mdy(11,12,2009))

*Reform 
gen R = 1 if mobs > mreform 
recode R . = 0
label var R "Post-reform"



*Treatment effect dummy; this captures the incremental effect of experiencing both events
gen treat = S==1 & R==1 
label var treat "Treatment effect"

*keep if mobs<=mofd(mdy(2,12,2012))
keep if  mreform  - mofd(spellstart_old)   >=6	
*Balance duration in the groups
keep if durdep<=59

unique idspell
unique idperson

  rename R r
rename S s

	gsem (durquit <- treat r s $hz tS $wlevel $jlevel $elevel $mlevel V1[idspell]) , difficult cloglog  latent(V1) vce(cluster idspell)
		
restore	

** Reform August 2009
	
preserve

drop R treat mreform 

gen mreform = mofd(mdy(8,12,2009))

*Reform 
gen R = 1 if mobs > mreform 
recode R . = 0
label var R "Post-reform"


*Treatment effect dummy; this captures the incremental effect of experiencing both events
gen treat = S==1 & R==1 
label var treat "Treatment effect"

*keep if mobs<=mofd(mdy(2,12,2012))
keep if  mreform  - mofd(spellstart_old)   >=6	
keep if durdep<=55

unique idspell
unique idperson

  rename R r
rename S s

	gsem (durquit <- treat r s $hz tS $wlevel $jlevel $elevel $mlevel V1[idspell]) , difficult cloglog  latent(V1) vce(cluster idspell)
	

restore	

** Reform May 2009

preserve

drop R treat mreform 

gen mreform = mofd(mdy(5,12,2009))

*Reform 
gen R = 1 if mobs > mreform 
recode R . = 0
label var R "Post-reform"



*Treatment effect dummy; this captures the incremental effect of experiencing both events
gen treat = S==1 & R==1 
label var treat "Treatment effect"

*keep if mobs<=mofd(mdy(2,12,2012))
keep if durdep<=50
keep if  mreform  - mofd(spellstart_old)   >=6	


unique idspell
unique idperson

  rename R r
rename S s


	gsem (durquit <- treat r s $hz tS $wlevel $jlevel $elevel $mlevel V1[idspell]) , difficult cloglog  latent(V1) vce(cluster idspell)


restore	


** Reform February 2009	
preserve

drop R treat mreform 

gen mreform = mofd(mdy(2,12,2009))


*Reform 
gen R = 1 if mobs > mreform 
recode R . = 0
label var R "Post-reform"


*Treatment effect dummy; this captures the incremental effect of experiencing both events
gen treat = S==1 & R==1 
label var treat "Treatment effect"

*keep if mobs<=mofd(mdy(2,12,2012))
keep if  mreform  - mofd(spellstart_old)   >=6	
keep if durdep<=50

unique idspell
unique idperson


  rename R r
rename S s

	gsem (durquit <- treat r s $hz tS $wlevel $jlevel $elevel $mlevel V1[idspell]) , difficult cloglog  latent(V1) vce(cluster idspell)


restore	



log close	

