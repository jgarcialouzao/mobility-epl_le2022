

clear all
capture log close
capture program drop _all
set more 1
set seed 13

*Recover size from MCVL 2004, to include in emplyoer data
*Append all information from laboral data to build a plant panel
use year_mcvl spellstart_* spellend_* reason_endspell idplant idplantmain regime size CNAE93 type1plant type2plant using ../mcvl_stata/MCVL2004_laboral.dta, clear

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

*Drop self-employment spells and other regimes that do not correspond to wage-employment relations; CCCs are not plants
drop if (regime>=521 & regime<=540)
drop if regime==138 | regime==140 | regime==161 | regime==611 | regime==640 | regime==721 | regime==740 | regime==825 | regime==831 | regime==840 | regime==940 | regime==1211 | regime==1221 | regime==1240

*Extraction date: last spell end date within general regime - guarantees the extraction date is the following day
*satisfies documendation (e.g. MCVL_organizacion_2006 and see extdate of 2006)
*Recode date end on-going spells from 31decyear+1 to 31decyear
replace spellend_date=mdy(12,31,year_mcvl) if spellend_date==mdy(12,31,year_mcvl+1) & reason_endspell==0
gegen extdate   =  max(spellend_date + 1)  if regime == 111  
replace spellend_date=mdy(12,31,year_mcvl+1) if spellend_date==mdy(12,31,year_mcvl) & reason_endspell==0

*Keep one observation per plant
bys idplant year_mcvl: gegen mode = mode(CNAE93), maxmode
drop if CNAE93!=mode
drop mode
bys idplant: keep if _n==1

replace year_mcvl = 2005

rename size size05
rename extdate extdate05

* Variables refer to extraction year
bys year_mcvl (extdate): replace extdate = extdate[1] if extdate==.
format extdate %td

keep year_mcvl idplant size extdate

save ../mcvl_stata/fsize05.dta, replace
