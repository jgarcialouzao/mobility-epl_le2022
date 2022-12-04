* Stata 14
* MCVL - Duration data
* Jose Garcia-Louzao

clear all
capture log close
capture program drop _all
set more 1
set seed 13


log using logs/durdata1.log, replace	

use ../Data/finalsample.dta, clear
drop age college hs fage ftime 

** Keep only useful variable	 
rename size size_entry
	 
egen idspell = group(idperson idplant spellstart_date spellend_date)

*Month hire
gen mhire = mofd(spellstart_date) 
format mhire  %tm
label var mhire "Hiring month"

*Separation month
gen mend  = mofd(spellend_date) 
format mend %tm
label var mend "Separation month"

** Transform dataset to individual-spell-month format
gen nobs_spellmonth = (mend - mhire) + 1

expand nobs_spellmonth

gen mobs=mhire
bys idspell: replace mobs = mobs + _n - 1
format mobs* %tm

gen yobs=yofd(dofm(mobs))
drop nobs* 

** Add time-varying covariates
* Employer info
gen year_mcvl = yobs
gen tmp = mofd(spellstart_old)
gen id = idplant
replace idplant = idplant_start if mobs<tmp
merge m:1 idplant year_mcvl using ../mcvl_stata/fpanel.dta, keepusing(size) keep(match)
drop _merge year_mcvl  tmp

**Merge job-characteristics
rename skill_tv skill
rename ptime_tv ptime
gen  year_obs = yobs
merge m:1 idperson idplant year_obs using ../mcvl_stata/job_tvchar.dta, keepusing(skill_tv ptime_tv) keep(1 3)
replace ptime_tv = 100   if ptime_tv == . & _merge==3

foreach v in skill_tv ptime_tv {
gen flag1 = -mobs
bys idspell (flag1): replace `v' = `v'[_n-1] if `v'==. & `v'[_n-1]!=.
drop flag1
bys idspell (mobs): replace `v' = `v'[_n-1] if `v'==. & `v'[_n-1]!=.
}
replace skill_tv = skill if skill_tv == . & _merge==1
replace ptime_tv = ptime if ptime_tv == . & _merge==1

drop _merge ptime skill year_obs

**Merge monthly earnings
gen month_wobs=mobs
  merge m:1 idperson idplant month_wobs using ../mcvl_stata/monthwages.dta, keep(1 3) keepusing(w)
drop _merge



*Merge max cap - from SS
gen year_w = yobs
merge m:1 year_w using ../SuppData/capsgeneralregime.dta, keep(match) keepusing(maxbase)
drop _merge year_w

*From now on wages are strictly capped
replace w = maxbase if w>=maxbase & w!=.
drop maxbase 
replace w = . if w<=1

foreach v in w {
gen flag1 = -mobs
bys idspell (flag1): replace `v' = `v'[_n-1] if `v'==. & `v'[_n-1]!=.
}
drop flag1

*Daily wages
*First and last day of a month
gen first=dofm(mobs)
gen last=dofm(mobs + 1) - 1
*Count days worked in a month
gen 	days = .
replace days = last - spellstart_date + 1  if spellstart_date>first & spellend_date>last
replace days = spellend_date - first + 1  if spellstart_date<first & spellend_date<last
*SS computes month-daily caps by dividing by 360 days per year - 30 days each month
replace days = 30 if spellstart_date<=first & spellend_date>=last
gen dailyw = w/days
drop w days first last

*Lagged dailyw
bys idspell (mobs): gen tmp = dailyw[_n-1]
drop dailyw
rename tmp dailyw


save ../Data/durdata.dta, replace



log close
