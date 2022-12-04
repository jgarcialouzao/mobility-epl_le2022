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


*Needs to install pgmhazgf2
*findit pgmhazgf2
*do C:\ado\plus\p\pgmhaz_gf2mataview.mata 


use ../Data/estimationdata.dta, clear

global hz "piece_* "
global wlevel "female spanish college age emphist prevftc prevperm"
global jlevel "hs ftime logw"
global elevel "size fage industry_2-industry_6"
global mlevel "yhire_* urate fedea"
global events "r s"

*timer on 1
	rename S s
rename R r

log using logs/reg1.log, replace

	gsem (durquit <- r $hz $wlevel $jlevel $elevel $mlevel V1[idspell] ) , difficult cloglog  latent(V1) vce(cluster idspell)

	gsem (durquit <- treat $events $hz tS $wlevel $jlevel $elevel $mlevel V1[idspell] ) , difficult cloglog  latent(V1) vce(cluster idspell)

	gsem (durj2j_quit <- treat $events $hz tS $wlevel $jlevel $elevel $mlevel V1[idspell] ) , difficult cloglog latent(V1) vce(cluster idspell)

	gen treat1 = treat==1 & yofd(dofm(mshock))<=2013
	gen treat2 = treat==1 & yofd(dofm(mshock))>2013
	
	gsem (durquit <- treat1 treat2 $events $hz tS $wlevel $jlevel $elevel $mlevel V1[idspell]) , difficult cloglog latent(V1) vce(cluster idspell)
	drop treat1 treat2	 
	
	gen ref = (mobs - mreform)/durdep 
	gen treat_1 = s==1 & ref>0 & ref<0.3
	gen treat_2 = s==1 & ref>=0.3
	gen ref_1 = ref>0 & ref<0.3
	gen ref_2 = ref>=0.3 
	gsem (durquit <- treat_1 treat_2 $events $hz tS $wlevel $jlevel $elevel $mlevel V1[idspell]) , difficult cloglog  latent(V1) vce(cluster idspell)
	gsem (durquit <- s ref_* $hz $wlevel $jlevel $elevel $mlevel V1[idspell]) , difficult cloglog  latent(V1) vce(cluster idspell)

	log close
/*

preserve
qui do code_ubentitled.do
tempfile entitlements
save `entitlements'
sum totaldays_ss, d
gen flag = totaldays_ss < 180
tab flag
restore
merge m:1 idperson spellstart_date spellend_date using `entitlements', keep(match)
drop _m

qui	gen noui = totaldays_ss < 360
qui	gen snoui = s*noui
qui	gen rnoui = r*noui
qui	gen treatnoui = treat*noui

	gsem (durquit <- treat s r noui $hz tS $wlevel $jlevel $elevel $mlevel V1[idspell]) , difficult cloglog  latent(V1)
	
	gsem (durquit <- treat s r noui $hz tS $wlevel $jlevel $elevel $mlevel V1[idspell] if noui==1) , difficult cloglog  latent(V1)
		
	gsem (durquit <- treat treatnoui s snoui r rnoui noui $hz tS $wlevel $jlevel $elevel $mlevel V1[idspell]) , difficult cloglog  latent(V1)
	
gen tmp = durdep*totaldays_ss
gen dynnoui = tmp < 180
qui	gen sdnoui = s*dynnoui
qui	gen rdnoui = r*dynnoui
qui	gen treatdnoui = treat*dynnoui

	gsem (durquit <- treat* s sdnoui r rdnoui dynnoui $hz tS $wlevel $jlevel $elevel $mlevel V1[idspell]) , difficult cloglog  latent(V1)

	*fully interacted
	foreach v in piece_2 piece_3 piece_4 piece_5 piece_6 piece_7 piece_9 piece_10 tS ///
	/* female spanish college age emphist prevftc prevperm hs ftime logw size fage industry_2 industry_3 industry_4 industry_5 industry_6 ///
	yhire_2006 yhire_2007 yhire_2008 yhire_2009 yhire_2010 yhire_2011 urate fedea*/ {
	quietly gen `v'noui = `v'*dynnoui
	}
	*global controls "piece_2 - piece_10 tS female spanish college age emphist prevftc prevperm hs ftime logw size fage industry_2-industry_6 yhire_* urate fedea *noui"
	
	gsem (durquit <- treat treatdnoui s sdnoui r rdnoui dynnoui piece* tS* $wlevel $jlevel $elevel $mlevel V1[idspell]) , difficult cloglog  latent(V1)
	
*/
					
log close


