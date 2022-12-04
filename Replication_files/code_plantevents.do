
* MCVL - Employer events
* Jose Garcia-Louzao

clear all
capture log close
capture program drop _all
set more 1
set seed 13

use ../mcvl_stata/fpanel.dta, clear

keep idplant year_mcvl size extdate create

** Closure (Benchmark)
*There are some cases that firm collapses to endup with size one and right after zero, recode those cases to assume close is when size one is observed
bys idplant (year_mcvl): replace size = 0 if size[_n-1]>1 & size==1  & size[_n+1]==0

*Date closure start; first day employer exit may occur
bys idplant (year_mcvl): gen Cstart= extdate if (size>1 & size[_n+1]==0 & size[_n+2]==0) & _n > 1 & create!= 1 & create[_n+1]!=1
bys idplant (Cstart): replace Cstart = Cstart[1]  if Cstart==.
format Cstart %td


*Date closure end; date following last date employer exit may occur
bys idplant (year_mcvl): gen Cend= extdate[_n+1]  if (size>1 & size[_n+1]==0 & size[_n+2]==0) & _n > 1 & create!= 1 & create[_n+1]!=1
bys idplant (Cend): replace Cend = Cend[1]  if Cend==.
format Cend %td


*Date closure start; first day employer exit may occur
bys idplant (year_mcvl): gen Cstart5= extdate if (size>4 & size[_n+1]==0 & size[_n+2]==0) & _n > 1 & create!= 1 & create[_n+1]!=1
bys idplant (Cstart5): replace Cstart5 = Cstart5[1]  if Cstart5==.
format Cstart5 %td


*Date closure end; date following last date employer exit may occur
bys idplant (year_mcvl): gen Cend5= extdate[_n+1]  if (size>4 & size[_n+1]==0 & size[_n+2]==0) & _n > 1 & create!= 1 & create[_n+1]!=1
bys idplant (Cend5): replace Cend5 = Cend5[1]  if Cend5==.
format Cend5 %td

** MASS LAYOFF
*30 percent drop in employment 
*Start		 
bys idplant (year_mcvl): g MLstart30= extdate  if (size>10) & ((size[_n+1] - size)/size < -0.30) & ((size[_n+1] - size)/size > -1) ///
										   & (size <= 1.3*size[_n-1] & size[_n+2] <= 0.9*size) & _n > 1 & create!= 1 & create[_n+1]!=1
gsort idplant -year_mcvl
bys idplant: replace MLstart = MLstart30[_n-1] if MLstart30 == .
bys idplant (year_mcvl): replace MLstart30 = MLstart30[_n-1] if MLstart30 == .
format MLstart30 %td

*End
bys idplant (year_mcvl): g MLend30= extdate[_n+1]  if (size>10) & ((size[_n+1] - size)/size < -0.30) & ((size[_n+1] - size)/size  > -1) ///
												   & (size <= 1.3*size[_n-1] & size[_n+2] <= 0.9*size)  & _n > 1 & create!= 1 & create[_n+1]!=1
gsort idplant -year_mcvl
bys idplant: replace MLend = MLend[_n-1] if MLend30 == .
bys idplant (year_mcvl): replace MLend30 = MLend30[_n-1] if MLend30 == .
format MLend30 %td

*50 percent drop in employment 
*Start		 
bys idplant (year_mcvl): g MLstart50= extdate  if (size>10) & ((size[_n+1] - size)/size <= -0.50) & ((size[_n+1] - size)/size > -1) ///
										   & (size <= 1.5*size[_n-1] & size[_n+2] <= 0.9*size) & _n > 1 & create!= 1 & create[_n+1]!=1
gsort idplant -year_mcvl
bys idplant: replace MLstart50 = MLstart50[_n-1] if MLstart50 == .
bys idplant (year_mcvl): replace MLstart50 = MLstart50[_n-1] if MLstart50 == .
format MLstart50 %td

*End
bys idplant (year_mcvl): g MLend50= extdate[_n+1]  if (size>10) & ((size[_n+1] - size)/size <= -0.50) & ((size[_n+1] - size)/size  > -1) ///
												   & (size <= 1.5*size[_n-1] & size[_n+2] <= 0.9*size)  & _n > 1 & create!= 1 & create[_n+1]!=1
gsort idplant -year_mcvl
bys idplant: replace MLend50 = MLend50[_n-1] if MLend50 == .
bys idplant (year_mcvl): replace MLend50 = MLend50[_n-1] if MLend50 == .
format MLend50 %td


**Mass layoff Law (Benchmark)
*Date start
gen MLstartLAW = .
bys idplant (year_mcvl): replace MLstartLAW= extdate if (size>=300) & (size[_n+1] - size <= -30) & size[_n+1]!=0 ///
												   & (size <= 1.1*size[_n-1] & size[_n+2] <= 0.9*size)  & _n > 1 & create!= 1 & create[_n+1]!=1
bys idplant (year_mcvl): replace MLstartLAW= extdate  if (size>=100 & size<300) & ((size[_n+1] - size)/size <= -0.10) & size[_n+1]!=0 ///
												   & (size <= 1.1*size[_n-1] & size[_n+2] <= 0.9*size)  & _n > 1 & create!= 1 & create[_n+1]!=1
bys idplant (year_mcvl): replace MLstartLAW= extdate  if (size>10 & size<100) & (size[_n+1] - size <= -10) & size[_n+1]!=0 ///
												   & (size <= 1.1*size[_n-1] & size[_n+2] <= 0.9*size)  & _n > 1 & create!= 1 & create[_n+1]!=1
gsort idplant -year_mcvl
bys idplant: replace MLstartLAW = MLstartLAW[_n-1] if MLstartLAW==.
bys idplant (year_mcvl): replace MLstartLAW = MLstartLAW[_n-1] if MLstartLAW==.
format MLstartLAW %td

*Date end
gen MLendLAW = .
bys idplant (year_mcvl): replace MLendLAW= extdate[_n+1]  if (size>=300) & (size[_n+1] - size <= -30) & size[_n+1]!=0 ///
												   & (size <= 1.1*size[_n-1] & size[_n+2] <= 0.9*size)  & _n > 1 & create!= 1 & create[_n+1]!=1
bys idplant (year_mcvl): replace MLendLAW= extdate[_n+1]  if (size>=100 & size<300) & ((size[_n+1] - size)/size <= -0.10) & size[_n+1]!=0 ///
												   & (size <= 1.1*size[_n-1] & size[_n+2] <= 0.9*size)  & _n > 1 & create!= 1 & create[_n+1]!=1
bys idplant (year_mcvl): replace MLendLAW= extdate[_n+1]  if (size>10 & size<100) & (size[_n+1] - size <= -10) & size[_n+1]!=0 ///
												   & (size <= 1.1*size[_n-1] & size[_n+2] <= 0.9*size)  & _n > 1 & create!= 1 & create[_n+1]!=1
gsort idplant -year_mcvl
bys idplant: replace MLendLAW = MLendLAW[_n-1] if MLendLAW==.
bys idplant (year_mcvl): replace MLendLAW = MLendLAW[_n-1] if MLendLAW==.
format MLendLAW %td

*Plants observed at least two years with positive plant-size
gen flag = (size>0)
bys idplant: gegen total = total(flag)
gen active = (total>1)
drop flag* total

*At least one of the years with 5 employees
gen flag = (size>4)
bys idplant: gegen max = max(flag)
gen size5 = (max==1)
drop flag* max

keep idplant year_mcvl C* ML* size* extdate  active

compress

save ../Data/plantevents.dta, replace


