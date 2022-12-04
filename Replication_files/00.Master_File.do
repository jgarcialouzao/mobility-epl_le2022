*** Stata 17
*** Master file to replicate "Workers' Job Mobility in Response to Severance Pay Generosity" by Jose Garcia-Louzao



clear all
capture log close
capture program drop _all
macro drop _all
set more 1
set seed 13
set cformat %5.4f

** Set main directory
global path "{Replication_files}" // main directory here but recall one needs to have the sub-folders within the diretory

** Installation of external programs required for estimation or saving results

* ftools (remove program if it existed previously)
ssc install ftools, replace
ssc install gtools, all replace

* outreg 
ssc install outreg2, replace


** Routines to obtain the final results 
*  routines should be stored in ${path}\do_files\

* 1) Data extraction 

* 1) Data extraction 


do read_MCVL_personal.do
do read_MCVL_laboral.do
do read_MCVL_base_employees.do
do read_MCVL_base_selfemp.do
do read_MCVL_hh.do
do read_MCVL_taxdata.do


* 2) Panel creation

do code_empspells.do
do code_contempspells.do
do code_employersize2005.do
do code_fpanel.do
do code_plantevents.do
do code_jobtvchar.do
do code_earnings.do
do code_wpanel.do 
do code_initialsample.do 
do code_baseline.do
do code_durdata.do 
do code_estimationdata.do
do code_matching1.do
do code_matching2.do
do code_durdatam.do 
do code_estimationdatam.do


* 3) Results 

do code_reg1.do 
do code_regevents.do 
do code_regexogevent.do 
do code_regrefsens.do 
do code_regfurthersens.do 
do code_reghzsens.do 
do code_regshocksens.do 
do code_regunobssens.do 
