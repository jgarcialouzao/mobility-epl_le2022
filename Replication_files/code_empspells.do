* Stata 14
* MCVL: Data preparation: Laboral data - Employment spells
* Jose Garcia-Louzao


clear all
capture log close
capture program drop _all
set more 1
set seed 13

global y1 = 2018
global y2 = 2017

log using ../logfiles/historyjobspells.log, replace	

*Select only one observation per spell - start for the last year available
use ../mcvl_stata/MCVL${y1}_laboral.dta, clear


*Drop spells with missing start or end date
drop if spellstart_date==. | spellend_date==.

*Drop spells with negative length
drop if spellend_date<spellstart_date

*Drop spells that refer to admin adjustments; not real employment spells
drop if reason_endspell==60 | reason_endspell==81

*Drop non-employment spells
drop if (type1plant > 749 & type1plant < 760) 
drop if type1plant==400 
drop if type2plant==4100 


forvalues y=$y2(-1)2005 {
merge 1:1 idperson spellstart_date spellend_date idplant using ../mcvl_stata/MCVL`y'_laboral.dta

*Drop spells with missing start or end date
drop if spellstart_date==. | spellend_date==.

*Drop spells with negative length
drop if spellend_date<spellstart_date

*Drop spells that refer to admin adjustments; not real employment spells
drop if reason_endspell==60 | reason_endspell==81

*Drop non-employment spells
drop if (type1plant > 749 & type1plant < 760) 
drop if type1plant==400 
drop if type2plant==4100 

drop _merge
}

*On-going spells between MCVL years will appear several times 
*Recode date end on-going spells from 31decyear
replace spellend_date=mdy(12,31,year_mcvl) if spellend_date==mdy(12,31,year_mcvl+1) & reason_endspell==0

*Spells that are present in more than one wave - they were on-going, keep the last - they will be split later on when needed
sort idperson spellstart_date spellend_date idplant year_mcvl
bys idperson spellstart_date idplant: gegen maxdate=max(spellend_date)
drop if spellend_date!=maxdate
drop max*

*Spells that actually finished on Dec 31st, keep last (most updated)
bys idperson spellstart_date spellend_date idplant (year_mcvl): keep if _n == _N

*Drop inconsistent spells (i.e. individual observed in y, drop if spell only appears in y-t file when it should be included in last year)
bys idperson: gegen maxy=max(year_mcvl)
keep if year_mcvl==maxy
drop maxy

compress
save ../mcvl_stata/empspells.dta, replace

log close

