* Stata 14
* MCVL - Duration data
* Jose Garcia-Louzao

clear all
capture log close
capture program drop _all
set more 1
set seed 13


log using logs/durdatam.log, replace	

forvalues w = 1(1)2 {

use ../Data/matchedsample`w'.dta, clear
drop age college hs fage ftime idspell _m

** Keep only useful variable	 
rename size size_entry
	 
egen idspell = group(idperson idplant spellstart_date spellend_date idtreat)

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


**Create variables for the analysis

*Duration dependence
bys idspell (mobs): gen durdep = _n

*Normalize initial duration (recall how it was computed in durdate mhire - mend + 1)
keep if durdep>7
replace durdep = durdep - 1

** Piece-wise constant baseline hazard 
gen piece_2 = durdep>9 & durdep<=11
gen piece_3 = durdep>11 & durdep<=14
gen piece_4 = durdep>14 & durdep<=17
gen piece_5 = durdep>17 & durdep<=20
gen piece_6 = durdep>20 & durdep<=25
gen piece_7 = durdep>25 & durdep<=31
gen piece_8 = durdep>31 & durdep<=43
gen piece_9 = durdep>43 & durdep<=67
gen piece_10 = durdep>67

*Quit
bys idspell (mobs): gen durquit = quit == 1 & _n==_N

bys idspell (mobs): gen durj2j_quit = quit == 1 & j2j==1 & _n==_N

*Layoff 
bys idspell (mobs): gen durlayoff = layoff == 1 & _n==_N


*Artificially censor at 84th month to balance durations across groups.
keep if durdep<=84

*Censored observations when firm event start
drop if mobs > mofd(PEstart)

*If dailyw missing late in the spell, censor
drop if dailyw==.

*Event months
g mreform = mofd(mdy(2,12,2012))
g mshock  = mofd(PEstart) - 12 
format mshock mreform %tm

*Reform 
gen R = 1 if mobs > mreform 
recode R . = 0
label var R "Post-reform"

*Layoff shock
gen S = 1 if mobs > mshock 
recode S .=0
label var S "Layoff shock"

bys idspell S (mobs) : gen tS = _n
replace tS = 0 if S == 0

*Treatment effect dummy; this captures the incremental effect of experiencing both events
gen treat = S==1 & R==1 //& mshock>mreform
label var treat "Treatment effect"

*Age
gen age = int((mobs - mofd(datebirth) + 1)/12)
label var age "Age"

*Education categories
gen college = (education>=44 & education!=.)
label var college "College"

*Full-time
gen ftime = 1 if ptime_tv == 100
recode ftime .=0
label var ftime "Full-time job"
drop ptime*

*Skill groups
gen hs = (skill_tv == 1 | skill_tv == 2 | skill_tv == 3)
label var hs "High-skill"

*Real daily earnings
merge m:1 month_wobs using ../SuppData/cpi2018m.dta, keep(match) keepusing(cpi2018)

gen rdailyw = dailyw / (cpi2018/100)
drop _merge month_wobs cpi2018 dailyw 
label var rdailyw "Real daily earnings"

*Log wage, 4 piece spline
gen logw = ln(rdailyw)
label var logw "(log) Real daily wage"

*Size
replace size = size/100
label var size "Size/100"

*Employer age
gen fage = int((mobs - mofd(creation_date) + 1)/12)
label var fage "Plant Age"


*Unemployment rate (province-quarter)
gen quarter = qofd(dofm(mobs))
merge m:1 provinceplant quarter using ../SuppData/inedataurprov.dta, keepusing(urate highunemp) keep(match)
label var urate "Unemp. rate"
drop _merge  quarter

*Fedea activity index
gen month = mobs
merge m:1 month using ../SuppData/fedea.dta, keepusing(fedea) keep(match)
label var fedea "FEDEA Index"
drop _merge month

/*
do provtoreg.do

xi i.regionplant
rename _I* *
drop regionplant provinceplant
*/

*Industry variable, slightly collapse the groups, to have enough observations within groups.
xi i.industry, noomit
rename _I* *


gen yhire = yofd(spellstart_date)
xi i.yhire
rename _I* *
drop yhire


compress


save ../Data/matchestimation`w'.dta, replace


}


log close

