* Ordered Logit in Stata

* Install packages
*ssc install outreg2

* Clean environment
clear all
macro drop _all
set more off
cls
version 17

** Change your working directory
cd "D:\Github Desktop\2024e\data" 



*-------------------------------------------------------
*  Get the data
*-------------------------------------------------------

* Load dataset of determinants
use "https://raw.githubusercontent.com/eileenCHEN-9/2024e/main/data/Data_clubs_04_interpolated_spatial.dta"
*import delimited "../data/longPanel_N274T17.csv", clear

* Merge with clubs panel dataset
*merge 1:1 province year using "../data/trend_ln_y_clubs.dta"
sum

* Declare panel data
sort id year
xtset id year
xtsum

* Add shorter labels to variables
*label variable clubPS "Club"


*-------------------------------------------------------
*  Define model parameters
*-------------------------------------------------------
global ylist fclub_trend_lg_gdppc_predicted
global xlist non_agri_share emp_nonagri agri_gdp_empgr nonagri_gdp_empgr urban_pop_percent lg101214 w_non_agri_share w_emp_nonagri w_agri_gdp_empgr w_nonagri_gdp_empgr w_urban_pop_percent w_lg101214
global modelName model01 
global initialYear 2004

*-------------------------------------------------------
*  Select sample
*-------------------------------------------------------

* Keep initial cross-section data
keep if year == $initialYear

* Tabulate dependent variable
tabulate $ylist,  missing


* Remove diverging regions
keep if $ylist != 0
tabulate $ylist,  missing

* Keep large clubs
*keep if $ylist == 2 | $ylist == 3  | $ylist == 4 | $ylist == 5
*tabulate $ylist,  missing

*-------------------------------------------------------
*  Run the model
*-------------------------------------------------------

* Ordered logit model
ologit $ylist $xlist, robust

* Ordered logit marginal effects
margins, dydx(*) atmeans predict(outcome(1))
margins, dydx(*) atmeans predict(outcome(2))
margins, dydx(*) atmeans predict(outcome(3))
margins, dydx(*) atmeans predict(outcome(4))
margins, dydx(*) atmeans predict(outcome(5))
margins, dydx(*) atmeans predict(outcome(6))

* Export formated table of marginal effects

ologit $ylist $xlist, robust
margins, dydx(*) atmeans predict(outcome(1)) post
outreg2 using "../results/${modelName}.xls", tex(fragment)  replace dec(3) ctitle(Club 1) label nonotes addstat() addnote(NOTE: All predictors at their mean value.)

ologit $ylist $xlist, robust
margins, dydx(*) atmeans predict(outcome(2)) post
outreg2 using "../results/${modelName}.xls", tex(fragment) append dec(3) ctitle(Club 2) label nonotes

ologit $ylist $xlist, robust
margins, dydx(*) atmeans predict(outcome(3)) post
outreg2 using "../results/${modelName}.xls", tex(fragment) append dec(3) ctitle(Club 3) label nonotes

ologit $ylist $xlist, robust
margins, dydx(*) atmeans predict(outcome(4)) post
outreg2 using "../results/${modelName}.xls", tex(fragment) append dec(3) ctitle(Club 4) label nonotes

ologit $ylist $xlist, robust
margins, dydx(*) atmeans predict(outcome(5)) post
outreg2 using "../results/${modelName}.xls", tex(fragment) append dec(3) ctitle(Club 5) label nonotes

ologit $ylist $xlist, robust
margins, dydx(*) atmeans predict(outcome(6)) post
outreg2 using "../results/${modelName}.xls", tex(fragment) append dec(3) ctitle(Club 6) label nonotes
