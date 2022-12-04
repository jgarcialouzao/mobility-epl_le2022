* Stata 14
* MCVL - Initial sample
* Jose Garcia-Louzao

clear all
capture log close
capture program drop _all
set more 1
set seed 13

log using logs/initial.log, replace	


global lastyear = 2018

*Start from continuous history of employment spells SS 
use ../Data/contempspells.dta, clear

*Generate year spellstart to merge information
gen year_mcvl = yofd(spellstart_date)
drop if year_mcvl<1980
replace year_mcvl = 2005 if year_mcvl<2005
**Merge personal information from individual panel - not matched obs. have some missing key information
merge m:1 idperson year_mcvl using ../mcvl_stata/wpanel.dta, keepusing(educ female nationality countrybirth datebirth provincebirth) keep(match)
drop _merge

drop if datebirth==. | female==. | (nationality==. & countrybirth==. & provincebirth==.) | education == .

*Create entry LM date - first employment spell observed 
bys idperson: egen entry = min(spellstart_date)
format entry %td

*Remove jobs spells starting before legal age to work 
keep if yofd(datebirth)>1950
keep if yofd(entry) - yofd(datebirth)>=16

*Compute previous LM experience
*Potential experience
gen pexp = int((spellstart_date - entry + 1)/360)
label var pexp "Potential exp."

*Actual experience
bys idperson (spellstart_date): gen tmp1 = (sum(spellend_date - spellstart_date + 1)) - (spellend_date - spellstart_date + 1)
gen aexp = int(tmp1/360)
label var aexp "Actual exp."

*Employed time since LM entry
g emphist = tmp1/(spellstart_date - entry + 1)
drop tmp1

*Previous contract status
*Permanent contract (fijos-discontinuous are classified as fixedterm because of the intermitent nature of this type of contracts)
qui g perm = contract==1|contract==3|contract==65|contract==100|contract==139|contract==189|contract==200|contract==239|contract==289| ///
contract==8|contract==9|contract==11|contract==12|contract==13|contract==20|contract==23|contract==28|contract==29|contract==30|contract==31|contract==32|contract==33|contract==35|contract==38|contract==40|contract==41|contract==42|contract==43|contract==44|contract==45|contract==46|contract==47|contract==48|contract==49|contract==50|contract==51|contract==52|contract==59|contract==60|contract==61|contract==62|contract==63|contract==69|contract==70|contract==71|contract==80|contract==81|contract==86|contract==88|contract==89|contract==90|contract==91|contract==98|contract==101|contract==102|contract==109|contract==130|contract==131|contract==141|contract==150|contract==151|contract==152|contract==153|contract==154|contract==155|contract==156|contract==157|contract==186|contract==209|contract==230|contract==231|contract==241|contract==250|contract==251|contract==252|contract==253|contract==254|contract==255|contract==256|contract==257

*Compute whether job starts after a GR non-employment spell
bys idperson (spellstart_date): g prevnonemp = (spellstart_date - spellend_date[_n-1] > 30) | _n == 1

bys idperson (spellstart_date): g prevftc  = perm[_n-1] == 0 & prevnonemp ==0
bys idperson (spellstart_date): g prevperm = perm[_n-1] == 1 & prevnonemp ==0

*Spanish nationals
gen spanish=1 if countrybirth==0
recode spanish . = 0
label var spanish "Spanish"

*Female dummy
label var female "Female"

*Age at start of the spell
gen age = yofd(spellstart_date) - yofd(datebirth)
label var age "Age"

*Education categories
gen educ=.
replace educ=0 if education == . 
replace educ=1 if education<=32
replace educ=2 if education>=40 & education<=43
replace educ=3 if education>=44 & education!=.
label define educlb 0 "Missing ed." 1 "Primary ed. (or less)" 2 "Secondary ed." 3 "Tertiary ed.", modify
label values educ educlb

*College graduates
gen college = 1 if educ==3
recode college . = 0
label var college "College"
drop educ

**Merge job characteristics, entry-level. Job starters before representative years use latest information
rename idplant tmp
gen idplant = tmp if spellstart_old==spellstart_date
replace idplant = idplant_start if spellstart_old!=spellstart_date

gen year_start=yofd(spellstart_date)
merge m:1 idperson idplant year_start using ../mcvl_stata/jobchar_entry.dta, keepusing(contract_tv skill_tv ptime_tv) keep(1 3)
replace skill_tv = skill if skill_tv == . & _merge == 1
replace ptime = 100 if ptime == .
replace ptime_tv = ptime if ptime_tv == . & _merge == 1
replace ptime_tv = 100 if ptime_tv == . & _merge == 3
g contract_start = contract_tv
replace contract_tv = contract if contract_tv==.
drop _merge year_start skill ptime contract_tv

qui g perm_start = contract_start==1|contract_start==3|contract_start==65|contract_start==100|contract_start==139|contract_start==189|contract_start==200|contract_start==239|contract_start==289| ///
contract_start==8|contract_start==9|contract_start==11|contract_start==12|contract_start==13|contract_start==20|contract_start==23|contract_start==28|contract_start==29|contract_start==30|contract_start==31|contract_start==32|contract_start==33|contract_start==35|contract_start==38|contract_start==40|contract_start==41|contract_start==42|contract_start==43|contract_start==44|contract_start==45|contract_start==46|contract_start==47|contract_start==48|contract_start==49|contract_start==50|contract_start==51|contract_start==52|contract_start==59|contract_start==60|contract_start==61|contract_start==62|contract_start==63|contract_start==69|contract_start==70|contract_start==71|contract_start==80|contract_start==81|contract_start==86|contract_start==88|contract_start==89|contract_start==90|contract_start==91|contract_start==98|contract_start==101|contract_start==102|contract_start==109|contract_start==130|contract_start==131|contract_start==141|contract_start==150|contract_start==151|contract_start==152|contract_start==153|contract_start==154|contract_start==155|contract_start==156|contract_start==157|contract_start==186|contract_start==209|contract_start==230|contract_start==231|contract_start==241|contract_start==250|contract_start==251|contract_start==252|contract_start==253|contract_start==254|contract_start==255|contract_start==256|contract_start==257

*Full-time job
gen ftime = 1 if ptime_tv==100 
recode ftime . = 0
label var ftime "Full-time job"

compress

**Merge starting monthly earnings
gen month_wobs=mofd(spellstart_date)
  merge m:1 idperson idplant month_wobs using ../mcvl_stata/monthwages.dta, keep(match) keepusing(w)
drop _merge

*Missing (starting) wage
replace w = . if w<=1

*Real daiy starting earnings
*Merge max cap - from SS
gen year_w = yofd(spellstart_date)
fmerge m:1 year_w using ../SuppData/capsgeneralregime.dta, keep(1 3) keepusing(maxbase)
drop _merge year_w
*From now on wages are strictly capped
replace w = maxbase if w>=maxbase & w!=.
drop maxbase 
*Merge CPI
fmerge m:1 month_wobs using ../SuppData/cpi2018m.dta, keep(1 3) keepusing(cpi2018)
drop _merge
gen rstartw = w/(cpi2018/100) 
gen days = dofm(month_wobs + 1) - spellstart_date + 1
*Real starting daily wage
gen rdstartw = rstartw / days
drop rstartw days
label var rdstartw "Initial real daily wage"
drop cpi* month_wobs

*High-skill workers
gen hs = 1 if skill_tv ==1 | skill_tv==2 | skill_tv==3
recode hs . = 0
label var hs "High-skill"

*Spells censored at Dec Last Year
replace reason_endspell = 0 if spellend_date>mdy(12,31,$lastyear)
replace spellend_date = mdy(12,31,$lastyear) if spellend_date>mdy(12,31,$lastyear)

*All separations
gen sep = 1 if reason_endspell!=0
recode sep .=0
label var sep "Completed"

*Quit
gen quit = 1 if reason_endspell==51
recode quit .=0 if sep==1
label var quit "Quit"

*Layoffs 
gen layoff = 1 if reason_endspell==54  | (reason_endspell>=91 & reason_endspell<=94)  | (reason_endspell==69 | reason_endspell==77)
recode layoff .=0 if sep==1
label var layoff "Layoff"

*Other reasons for separation (includes family care and health leave)
gen otherall = 1 if quit==0 & layoff==0
recode otherall . = 0 if sep==1
label var otherall "Other reasons"


*Duration 
gen dur = mofd(spellend_date) - mofd(spellstart_date)
label var dur "Duration (months)"

*Duration of censored spells
gen durcens = mofd(spellend_date) - mofd(spellstart_date) if sep==0
label var durcens "Censored spells"

*Duration of completed spells
gen dursep = mofd(spellend_date) - mofd(spellstart_date) if sep==1 
label var dursep "Completed spells"


*Succesful job separators 
*J2J
bys idperson (spellstart_date): gen j2j = 1 if spellstart_date[_n+1] - spellend_date < 30 & sep == 1 & idfirm!=idfirm[_n+1]
replace j2j = 0 if j2j == . & sep == 1

*Time between jobs
bys idperson (spellstart_date): gen t2newjob = spellstart_date[_n+1] - spellend_date

*New wage
bys idperson (spellstart_date): gen newrdstartw = rdstartw[_n+1] 

*New contract
bys idperson (spellstart_date): gen newcon = perm_start[_n+1]

*New ftime status
bys idperson (spellstart_date): gen newft = ftime[_n+1]

compress

**Assign employer characteristics - plants are only from the general regime - especial regimes do no imply welfare entitlements 
keep if regime==111
merge m:1 idplant year_mcvl using ../mcvl_stata/fpanel.dta, keepusing(idfirm size provinceplant CNAE93 CNAE09 type* legal* creation_date) keep(match)
drop _merge year_mcvl idplant
rename tmp idplant 

*Ceuta y Melilla - not included in the analysis
drop if provinceplant>50

*Employer creation - correct if spellstart_date before. Documentation establishes creation_date is first date with an employee registered in the CCC
bys idplant: gegen min=min(spellstart_date)
replace creation_date = min if min < creation_date
drop min

*Create 2-digit and 1-digit sector of activity variable based on CNAE09
qui do ../codes/sectorhom.do
drop CNAE*

*Located in 4 largest metropolitan areas (Madrid, Barcelona, Sevilla, Valencia)
gen bigcity= 1 if provinceplant==8 | provinceplant==28 | provinceplant==41 | provinceplant==46
recode bigcity .=0
label var bigcity "Biggest 4 cities"

*Services sector
gen serv = 1 if sector1d>=4
recode serv . =0
label var serv "Services"

*Industry variable, slightly collapse the groups, to have enough observations within groups.
gen industry = 1     if sector1d==2
replace industry = 2 if sector1d==3
replace industry = 3 if sector1d==4 
replace industry = 4 if sector1d==5 
replace industry = 5 if sector1d==6
replace industry = 6 if sector1d>6

*Employer age when worker is hired
gen fage = yofd(spellstart_date) - yofd(creation_date)
label var fage "Plant Age"


compress

save ../Data/initialsample_tmp.dta, replace

use ../Data/initialsample_tmp.dta, clear

*Displacement events
gen year_mcvl = yofd(spellend_date)
replace year_mcvl = .    if yofd(spellend_date)  <2005
merge m:1 idplant year_mcvl using ../Data/plantevents.dta, keepusing(Cstart5 Cend5 MLstartLAW MLendLAW size5) keep(1 3)
drop _merge year_mcvl

rename MLstartLAW MLstart
rename MLendLAW   MLend

gen year_mcvl = yofd(spellstart_old)
replace year_mcvl = 2005 if yofd(spellstart_old) <2005
replace year_mcvl = .    if yofd(spellend_date)  <2005
merge m:1 idplant year_mcvl using ../Data/plantevents.dta, keepusing(MLstartLAW MLendLAW) keep(1 3)
drop _merge year_mcvl

replace MLstart = MLstartLAW if MLstartLAW <MLstart & spellstart_old <= MLendLAW
replace MLend   = MLendLAW   if MLendLAW   <MLend   & spellstart_old <= MLendLAW 

***Correct potential fake events
**Close = size observed to collapse to zero between two exraction dates and no longer appears again
gen close = Cstart!=. 
gen recode_c = 0
*Separation after zero observed
gen flag = 1 if spellend_date>=Cend
bys idplant (flag): replace flag = flag[1] if flag==.
replace recode_c = 1 if flag == 1
drop flag
*If reason endspell = merge, recode close to 0
gen flag = 1 if reason_endspell==55 & (spellend_date>=Cstart) & close == 1
bys idplant (flag): replace flag = flag[1] if flag==.
replace recode_c = 1 if flag == 1 
drop flag 


*Mass layoff
gen mass = MLstart!=. 
replace mass = 0 if spellstart_old > MLend 
gen recode_m = 0

*If 10 or more created
gen flag = 1 if spellstart_old >= MLstart & spellstart_old<=MLend & mass== 1
bys idplant: gegen total=total(flag)
replace recode_m = 1 if total>=10
drop flag total

* Correct variables
preserve
keep idplant recode_c close
bys idplant: keep if _n==1
tab recode_c if close==1
restore

preserve
keep idplant recode_m mass
bys idplant: keep if _n==1
tab recode_m if m==1
restore

*Drop plants that where recoded
drop if recode_c == 1 
drop if recode_m == 1
drop recode*


*Firm event dates
gen PEstart = MLstart     
gen PEend   = MLend     
replace PEstart = MLstart if MLend==Cstart & Cstart!=. 
replace PEend   = Cend    if MLend==Cstart & Cstart!=. 
replace PEstart = Cstart  if Cstart!=. & PEstart==.
replace PEend   = Cend    if Cstart!=. & PEend==.
format PE* %td

*Create event dummy
gen event = 0
replace event = 1 if (PEstart!=. ) 

*Spells affected by the shock
gen shock = 1 if mofd(spellend_date) > mofd(PEstart) - 12
recode shock . = 0
label var shock "Layoff shock"

*Spells affected by the reform
gen reform = 1 if mofd(spellend_date) > mofd(mdy(2,12,2012))
recode reform . = 0
label var reform "After reform"

*Drop Digits not corresponding to no specific cause in documentation 
drop if reason_endspell==63 | reason_endspell==67 | reason_endspell==72 | reason_endspell==74 | reason_endspell==78 | reason_endspell==84 | reason_endspell==87 | reason_endspell==90 | reason_endspell==97 | reason_endspell==98 | reason_endspell==99

*Full information  
drop if (skill_tv<1 | skill_tv>10) | ptime == 0

drop if rdstartw==.

save ../Data/initialsample.dta, replace 
log close


do code_baseline



