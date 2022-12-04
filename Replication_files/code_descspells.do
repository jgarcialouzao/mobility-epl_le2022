* Stata 14
* MCVL - Descriptive job spells
* Jose Garcia-Louzao


clear all
capture log close
capture program drop _all
set more 1
set seed 13
set cformat %5.4f


use ../Data/finalsample.dta, clear
preserve
keep if sep == 1
replace j2j  = j2j * 100
replace quit = quit * 100

gen mend = mofd(spellend_date)
format mend %tm
collapse (mean) quit j2j, by(mend)
rename mend month
format month %tm
drop if month>=706
tw (line quit month,   lcolor(black) lwidth(thick)) (line j2j month, lcolor(black) lwidth(thick) lpattern(dash)), ///
ylabel(0(20)80) xlabel(540(12)706, angle(45)) xtitle("Separation month") ytitle("Percent") legend(lab(1 "Quits") lab(2 "Job-to-Job")) graphregion(color(white)) xline(625)
graph export "../Figures/Quits_J2J.eps", as(eps) preview(off) replace
graph export "../Figures/Quits_J2J.png", as(png) replace

erase "../Figures/Quits_J2J.eps"
restore
preserve
*Table distribution of relevant job quit durations
keep if quit == 1
*Time to shock
gen timetoshock = ( mofd(PEstart) - 12) - mofd(spellstart_date) if shock==1 

*Time to policy change
gen timetoreform = mofd(mdy(2,12,2012)) - mofd(spellstart_date) if reform == 1

*Time between events
*gen diffevents = mshock - mreform if reform==1 & shock==1 & PEend>mdy(2,12,2012)

*Duration if experience only shock
gen durshock = dur if shock == 1 & reform == 0

*Duration if no event
gen durnoevent = dur if reform== 0 & shock == 0 

*Duration if experience only reform
gen durreform = dur if reform == 1 & shock == 0

*Time after the reform no shock
gen timepostrefnoshock = mofd(spellend_date) - mofd(mdy(2,12,2012)) if reform == 1 & shock == 0

*Duration if treated
gen durtreat = dur if reform==1 & shock==1

*Time after the reform and shock
gen timepostrefshock = mofd(spellend_date) - mofd(mdy(2,12,2012))  if reform == 1 & shock == 1

estpost tabstat timetoshock timetoreform dur durnoevent durreform timepostrefnoshock durshock durtreat timepostrefshock, statistics(mean p10 p25 p50 p75 p90) columns(statistics) 
est store durations
esttab durations using ../Tables/distdurations_quit.tex, replace cells("mean(fmt(a1)) p10(fmt(a1)) p25(fmt(a1)) p50(fmt(a1)) p75(fmt(a1)) p90(fmt(a1))") label booktabs nonum gaps f 
restore 


*******************************************************************************
* Quit rates around the reform net of duration dependence
*use ../Data/estimationdata.dta, clear

*keep if mobs>=588 & mobs<658

keep mobs durquit S durdep piece_* 
gen beta = .

*replace durdep = ln(durdep)
gen durdep2=durdep*durdep
gen durdep3 = durdep2*durdep

gen q = qofd(dofm(mobs))
qui tab q, gen(quarter_)
foreach d in 0 1 {
qui reg durquit quarter_2-quarter_53 durdep* if  S==`d'
forvalues i = 2(1)53 {
qui replace beta = _b[_cons] + _b[quarter_`i'] if quarter_`i'==1 & S==`d'
}
}
keep if mobs>=588 & mobs<=662
keep q durquit beta S 

gcollapse (mean) beta , by(q S)
replace beta = beta*100
*rename beta durquit
xtset S q
*decide the smoothing
tssmooth ma durquit = beta, window(1 1 1)
format q %tq
tw (connect durquit q if S==0, lcolor(black) mcolor(black%50)) (connect durquit q if S==1,  lcolor(black) lpattern(dash) msymbol(square) mcolor(black%50)), xlabel(196(4)219) xtitle("Quarter") ytitle("Percent") ylabe(0(0.3)1.8) legend(lab(1 "No layoff shock") lab(2 "Layoff shock")) graphregion(color(white)) xline(208)
graph export "../Figures/quarterlyquits.eps", as(eps)  replace
graph export "../Figures/quarterlyquits.png", as(png) replace

erase "../Figures/quarterlyquits.eps"


/*
*******************************************************************************
* Sep flows around shock moment
use ../Data/estimationdata.dta, clear

keep if event == 1

gen distance = mobs - mshock 

keep if distance>=-12 & distance<=12

gcollapse (mean) durquit durlayoff , by(distance)
replace durquit = durquit*100
replace durlayoff = durlayoff*100

tw (line durquit distance , lcolor(black) lwidth(thick)) (line durlayoff distance, lcolor(black) lwidth(thick) lpattern(dash) ) , ///
xlabel(-12(1)12,  angle(45)) xtitle("Distance to Shock Moment (in months)") ytitle("Percent")  legend(lab(1 "Quits") lab(2 "Layoffs")) graphregion(color(white)) xline(0)	
graph export "../Figures/sepsaroundshockmonth.eps", as(eps) preview(off) replace
graph export "../Figures/sepsaroundshockmonth.png", as(png) replace

erase "../Figures/sepsaroundshockmonth.eps"



**********************************************************************
*Hazard rates - general
use ../Data/estimationdata.dta, clear
keep durquit durdep

replace durquit = durquit*100
collapse (mean) durquit, by(durdep)
tw (line durquit durdep, lcolor(black) lwidth(thick)), ///
	xlabel(6(6)84) xtitle("Job duration (in months)") ytitle("Percent") graphregion(color(white))	
graph export "../Figures/hzrate.eps", as(eps) preview(off) replace
graph export "../Figures/hzrate.png", as(png) replace

erase "../Figures/hzrate.eps"

use ../Data/estimationdata.dta, clear

keep durquit durdep event 

replace durquit = durquit*100
collapse (mean) durquit, by(durdep event)
tw (line durquit durdep if event==0, lcolor(black) lwidth(thick)) (line durquit durdep if event==1, lcolor(black) lwidth(thick) lpattern(dash)), ///
	xlabel(6(6)84) xtitle("Job duration (in months)") ytitle("Percent")  legend(lab(1 "No firm event") lab(2 "Firm event")) graphregion(color(white))	
graph export "../Figures/hzrate_event.eps", as(eps) preview(off) replace
graph export "../Figures/hzrate_event.png", as(png) replace

erase "../Figures/hzrate_event.eps"


use ../Data/estimationdata.dta, clear
keep durquit durdep  S
replace durquit = durquit*100
collapse (mean) durquit, by(durdep S)
tw (line durquit durdep if S==0, lcolor(black) lwidth(thick)) (line durquit durdep if S==1, lcolor(black) lwidth(thick) lpattern(dash)), ///
	xlabel(6(6)84) ylabel(0(0.3)1.8) xtitle("Job duration (in months)") ytitle("Percent")  legend(lab(1 "No layoff shock") lab(2 "Layoff shock")) graphregion(color(white))	
graph export "../Figures/hzrate_shock.eps", as(eps) preview(off) replace
graph export "../Figures/hzrate_shock.png", as(png) replace

erase "../Figures/hzrate_shock.eps"


use ../Data/estimationdata.dta, clear
keep durquit durdep  R
replace durquit = durquit*100
collapse (mean) durquit, by(durdep R)
tw (line durquit durdep if R==0, lcolor(black) lwidth(thick)) (line durquit durdep if R==1, lcolor(black) lwidth(thick) lpattern(dash)), ///
	xlabel(6(6)84) ylabel(0(0.3)1.8) xtitle("Job duration (in months)") ytitle("Percent")  legend(lab(1 "No reform") lab(2 "Reform")) graphregion(color(white))	
graph export "../Figures/hzrate_reform.eps", as(eps) preview(off) replace
graph export "../Figures/hzrate_reform.png", as(png) replace

erase "../Figures/hzrate_reform.eps"


use ../Data/estimationdata.dta, clear
keep durquit durdep  treat
replace durquit = durquit*100
collapse (mean) durquit, by(durdep treat)
tw (line durquit durdep if treat==0, lcolor(black) lwidth(thick)) (line durquit durdep if treat==1, lcolor(black) lwidth(thick) lpattern(dash)), ///
	xlabel(6(6)84) ylabel(0(0.3)1.8) xtitle("Job duration (in months)") ytitle("Percent")  legend(lab(1 "No treated") lab(2 "Treated")) graphregion(color(white))	
graph export "../Figures/hzrate_treat.eps", as(eps) preview(off) replace
graph export "../Figures/hzrate_treat.png", as(png) replace

erase "../Figures/hzrate_treat.eps"



/*
* Layoff rates around reform
use ../Data/estimationdata.dta, clear
keep idspell quit durlayoff mobs mreform event S

replace durlayoff = durlayoff*100

gen distance = mobs - mreform 

keep if distance>=-12 & distance<=12

preserve
gcollapse (mean) durlayoff , by(distance S)

tw (connect durlayoff distance if S==0 , lcolor(black) mcolor(black)) (connect durlayoff distance if  S==1, msymbol(square) mcolor(gray) lcolor(gray) lpattern(dash)), ///
xlabel(-12(1)12,  angle(45)) xtitle("Distance to Reform (in months)") ytitle("Percent") legend(lab(1 "No Shock") lab(2 "Shock"))  graphregion(color(white)) xline(0)	
graph save ../graphs/dlayoffaroundreform.gph, replace
restore


********************************************************************************
* Layoffs around reform - check for not strategic waiting of firms to wait to layoff right after the reform
use ../Data/finalsample.dta, clear
keep if sep==1
gen d = mdy(2,12,2012) - spellend_date
keep if d>=-360 & d<360
rdplot layoff d, kernel(tri) h(360 360) p(2) graph_options(xtitle("Separation date") ytitle("Layoffs"))
graph save ../graphs/layoffsaroundreform.gph, replace

use ../Data/finalsample.dta, clear
keep if sep==1
gen d = (PEstart-360) - spellend_date
keep if d>=-360 & d<360
rdplot layoff d, kernel(tri) h(360 360) p(1) graph_options(xtitle("Separation date") ytitle("Layoffs"))
rdplot quit d, kernel(tri) h(360 360) p(1) graph_options(xtitle("Separation date") ytitle("Quits"))
