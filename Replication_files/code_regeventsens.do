* Stata 14
* Jose Garcia-Louzao

clear all
capture log close
capture program drop _all
macro drop _all
set more 1
set seed 13
set cformat %5.4f

log using logs/eventsens.log, replace	



use ../Data/estimationdata.dta, clear

* Fixed variables
global hz "piece_* tS"
global wlevel "female spanish college age emphist prevftc prevperm"
global jlevel "hs ftime logw"
global elevel "size fage industry_2-industry_6"
global mlevel "yhire_* urate fedea"


rename S s
rename R r
		
preserve
drop if mass==1 
gunique idspell
gunique idperson
	gsem (durquit <- treat s r $hz $wlevel $jlevel $elevel $mlevel V1[idspell]) , difficult cloglog  latent(V1) vce(cluster idspell)
	
restore	

use ../Data/estimationdata_ml30.dta, clear
gunique idspell
gunique idperson

rename S s
rename R r
	gsem (durquit <- treat s r $hz $wlevel $jlevel $elevel $mlevel V1[idspell]) , difficult cloglog  latent(V1) vce(cluster idspell)

		
use ../Data/estimationdata_ml50.dta, clear
gunique idspell
gunique idperson

rename S s
rename R r
	gsem (durquit <- treat s r $hz $wlevel $jlevel $elevel $mlevel V1[idspell]) , difficult cloglog  latent(V1) vce(cluster idspell)

		
log close		

