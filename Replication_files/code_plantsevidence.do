* Stata 14
* MCVL - Evolution plant size around start of event year
* Jose Garcia-Louzao

clear all
capture log close
capture program drop _all
set more 1
set seed 13
set cformat %5.4f


use ../Data/initialsample.dta, clear

gen flag = 1 if  (legal2firm>=11 & legal2firm<=14) | type2plant<5081 |  sector1d==1 | sector2d == 97 | sector1d>=13 
bys idplant (flag): replace flag = flag[1] if flag==.
drop if flag == 1
drop flag sector*
keep if size5==1
bys idplant: keep if _n == 1
keep idplant creation_date 
merge 1:m idplant using ../Data/plantevents.dta, keep(match) keepusing (MLstartLAW MLendLAW Cstart year_mcvl size)

drop if year_mcvl<yofd(creation_date)
drop if year_mcvl>yofd(Cstart)

gen ml = 100*(MLstart!=. & year_mcvl==yofd(MLstart))
gen c =  100*(Cstart!=. & year_mcvl==yofd(Cstart))

preserve
tempfile ml
gcollapse ml , by(year)
save `ml'
restore

gcollapse c , by(year)
append using `ml'

keep if year>=2006 & year<=2017

 tw (line ml year , lcolor(black) lwidth(thick)) (line c year , lcolor(black) lwidth(thick) lpattern(dash)), /// 
xlabel(2006(1)2017,  angle(45)) xtitle("Year")   ytitle("Percent")   graphregion(color(white)) xline(2012) legend(lab(1 "Mass-Layoffs") lab(2 "Closings"))
graph save "../Figures/percevents.gph", replace
graph export "../Figures/percevents.eps", as(eps) preview(off) replace
graph export "../Figures/percevents.png", as(png) replace

erase "../Figures/percevents.gph"
erase "../Figures/percevents.eps"


use ../Data/finalsample.dta, clear
keep if event==1
bys idplant: keep if _n == 1
keep idplant creation_date PEstart
merge 1:m idplant using ../Data/plantevents.dta, keep(match) keepusing (MLstartLAW Cstart year_mcvl size)

drop if year_mcvl<yofd(creation_date)

preserve
keep if MLstart!=. 
gen distance = year_mcvl - yofd(PEstart)
 keep if distance>=-3 & distance<=3
 
tempfile ML
save `ML'
gcollapse (mean) size_mean = size, by(distance)

*Mass-layoff plants
 tw (line size_mean distance , lcolor(black) lwidth(thick)), ///
xlabel(-3(1)3,  angle(45)) xtitle("Distance to Event (in years)")  ytitle("Plant size")   graphregion(color(white)) xline(0)
graph save "../Figures/size_toevent_ml.gph", replace
graph export "../Figures/size_toevent_ml.eps", as(eps) preview(off) replace
graph export "../Figures/size_toevent_ml.png", as(png) replace

erase "../Figures/size_toevent_ml.gph"
erase "../Figures/size_toevent_ml.eps"

restore


preserve
keep if Cstart!=. 
gen distance = year_mcvl - yofd(Cstart)
keep if distance>=-3 & distance<=3
 
tempfile C
save `C'
gcollapse (mean) size_mean = size , by(distance)

*Closing plants
 tw (line size_mean distance , lcolor(black) lwidth(thick)) , ///
xlabel(-3(1)3,  angle(45)) xtitle("Distance to Event (in years)") ytitle("Plant size") graphregion(color(white)) xline(0)
graph save "../Figures/size_toevent_close.gph", replace
graph export "../Figures/size_toevent_close.eps", as(eps) preview(off) replace
graph export "../Figures/size_toevent_close.png", as(png) replace

erase "../Figures/size_toevent_close.gph"
erase "../Figures/size_toevent_close.eps"


restore

preserve
use `C' , clear
append using `ML'

drop distance
gen distance = year_mcvl - yofd(PEstart)
 keep if distance>=-3 & distance<=3

gcollapse (mean) size_mean = size , by(distance)

*Closing and mass-layoff
 tw (line size_mean distance , lcolor(black) lwidth(thick)) , xlabel(-3(1)3,  angle(45)) xtitle("Distance to Event (in years)")  ytitle("Plant size")  graphregion(color(white)) xline(0)
graph save "../Figures/size_toevent_all.gph", replace
graph export "../Figures/size_toevent_all.eps", as(eps) preview(off) replace
graph export "../Figures/size_toevent_all.png", as(png) replace

erase "../Figures/size_toevent_all.gph"
erase "../Figures/size_toevent_all.eps"



