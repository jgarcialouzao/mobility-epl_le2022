* Stata 14
* MCVL - Estimation data
* Jose Garcia-Louzao

clear all
capture log close
capture program drop _all
macro drop _all
set more 1
set seed 13


use ../Data/matchdurdata.dta, clear
**Create variables for the analysis

*Duration dependence
bys idspell (mobs): gen durdep = _n

*Normalize initial duration (recall how it was computed in durdate mhire - mend + 1)
keep if durdep>7
replace durdep = durdep - 1

** Piece-wise constant baseline hazard 
gen piece_2 = durdep>8 & durdep<=11
gen piece_3 = durdep>11 & durdep<=13
gen piece_4 = durdep>13 & durdep<=16
gen piece_5 = durdep>16 & durdep<=20
gen piece_6 = durdep>20 & durdep<=24
gen piece_7 = durdep>24 & durdep<=31
gen piece_8 = durdep>31 & durdep<=42
gen piece_9 = durdep>42 & durdep<=64
gen piece_10 = durdep>64

*Quit
bys idspell (mobs): gen durquit = quit == 1 & _n==_N

bys idspell (mobs): gen durj2j_quit = quit == 1 & j2j==1 & _n==_N

*Layoff 
bys idspell (mobs): gen durlayoff = layoff == 1 & _n==_N

bys idspell (mobs): gen durj2j_layoff = j2j == 1 & layoff == 1 & _n==_N

*Artificially censor at 84th month to balance durations across groups.
keep if durdep<=72

*Censored observations of shock workers after start event year (we are interested in the probability of no waiting)
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

** Heterogenous effects of the shock across tenure bins - similar to Alabanese et al (2019)
forvalues n=2/10 {
gen pieceS_`n' = piece_`n' * S
}

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

drop sector*

gen yhire = yofd(spellstart_date)
xi i.yhire
rename _I* *
drop yhire


compress


save ../Data/matchestdata1.dta, replace


