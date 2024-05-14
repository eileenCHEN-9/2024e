clear all
macro drop _all
capture log close
set more off
version 15

cd "D:\Github Desktop\2024e\data"
*use "https://raw.githubusercontent.com/eileenCHEN-9/PhD_2022_2025/main/data/county_predicted.dta"
*-------------------------------------------------------
***************** Define global parameters*************
*-------------------------------------------------------

* dataset name
global dataSet county_predicted
* variable to be studied
global xVar trend_lg_gdppc_predicted
* label of the variable
global xVarLabel Trend log GDPpc Predicted
* Names of cross-sectional units
global csUnitName county
* time unit identifier
global timeUnit year

*-------------------------------------------------------
***************** Start log file************************
*-------------------------------------------------------

log using "club-identification.txt", text replace


*-------------------------------------------------------
***************** Import and set dataset  **************
*-------------------------------------------------------

** Load data
use "../data/${dataSet}.dta", clear

* keep necessary variables
rename county_id id 
keep v1 id province_id city city_id lg_totalgdp_predicted lg_gdppc_predicted ${csUnitName} ${timeUnit}
order id ${timeUnit} county

* set panel data
xtset id ${timeUnit}

*-------------------------------------------------------
***************** Compute long-run trend  ***********
*-------------------------------------------------------

pfilter lg_gdppc_predicted, method(hp) trend(trend_lg_gdppc_predicted) smooth(400)


*-------------------------------------------------------
***************** Apply PS convergence test  ***********
*-------------------------------------------------------

* run logt regression
putexcel set "../results/${dataSet}_test.xlsx", sheet(logtTest) replace
    logtreg ${xVar},  kq(0.30)
ereturn list
matrix result0 = e(res)
putexcel A1 = matrix(result0), names nformat("#.##") overwritefmt

* run clustering algorithm (NOTE: the adjust option changes the number of clubs from 4 to 5)
putexcel set "../results/${dataSet}_test.xlsx", sheet(initialClusters) modify
    psecta ${xVar}, adjust  name(${csUnitName}) kq(0.30) gen(club_${xVar})
matrix b=e(bm)
matrix t=e(tm)
matrix result1=(b \ t)
matlist result1, border(rows) rowtitle("log(t)") format(%9.3f) left(4)
putexcel A1 = matrix(result1), names nformat("#.##") overwritefmt

* run clustering merge algorithm
putexcel set "../results/${dataSet}_test.xlsx", sheet(mergingClusters) modify
    scheckmerge ${xVar},  kq(0.30) club(club_${xVar})
matrix b=e(bm)
matrix t=e(tm)
matrix result2=(b \ t)
matlist result2, border(rows) rowtitle("log(t)") format(%9.3f) left(4)
putexcel A1 = matrix(result2), names nformat("#.##") overwritefmt

* list final clusters
putexcel set "../results/${dataSet}_test.xlsx", sheet(finalClusters) modify
    imergeclub ${xVar}, name(${csUnitName}) kq(0.30) club(club_${xVar}) gen(finalclub_${xVar})
matrix b=e(bm)
matrix t=e(tm)
matrix result3=(b \ t)
matlist result3, border(rows) rowtitle("log(t)") format(%9.3f) left(4)
putexcel A1 = matrix(result3), names nformat("#.##") overwritefmt

*-------------------------------------------------------
***************** Generate relative variable (for ploting)
*-------------------------------------------------------

** Generate relative variable (useful for ploting)
save "temporary1.dta",replace
use  "temporary1.dta"

collapse ${xVar}, by(${timeUnit})
gen  id=999999
append using "temporary1.dta"
sort id ${timeUnit}

gen ${xVar}_av = ${xVar} if id==999999
bysort ${timeUnit} (${xVar}_av): replace ${xVar}_av = ${xVar}_av[1]
gen re_${xVar} = 1*(${xVar}/${xVar}_av)
label var re_${xVar}  "Relative ${xVar}  (Average=1)"
drop ${xVar}_av
sort id ${timeUnit}

drop if id == 999999
rm "temporary1.dta"

* order variables
order ${csUnitName}, before(${timeUnit})
order id, before(${csUnitName})

* Export data to csv
export delimited using "../results/${dataSet}_clubs.csv", replace
save "../results/${dataSet}_clubs.dta", replace
export delimited using "../data/${dataSet}_clubs.csv", replace
save "../data/${dataSet}_clubs.dta", replace

*-------------------------------------------------------
***************** Plot the clubs  *********************
*-------------------------------------------------------

** All lines

xtline re_${xVar}, overlay legend(off) scale(1.6)  ytitle("${xVarLabel}", size(small)) yscale(lstyle(none)) ylabel(, noticks labcolor(gs10)) xscale(lstyle(none)) xlabel(, noticks labcolor(gs10))  xtitle("") name(allLines, replace)

graph save   "../results/${dataSet}_allLines.gph", replace
graph export "../results/${dataSet}_allLines.pdf", replace

** Indentified Clubs

summarize finalclub_${xVar}
return list
scalar nunberOfClubs = r(max)

forval i=1/`=nunberOfClubs' {
    xtline re_${xVar} if finalclub_${xVar} == `i', overlay title("Club `i'", size(small)) legend(off) scale(1.5) yscale(lstyle(none))  ytitle("${xVarLabel}", size(small)) ylabel(, noticks labcolor(gs10)) xtitle("") xscale(lstyle(none)) xlabel(, noticks labcolor(gs10))  name(club`i', replace)
    local graphs `graphs' club`i'
}
graph combine `graphs', col(2) xsize(1.3) ysize(1.5) ycommon iscale(0.6)
graph save   "../results/${dataSet}_clubsLines.gph", replace
graph export "../results/${dataSet}_clubsLines.pdf", replace

** Within-club averages

collapse (mean) re_${xVar}, by(finalclub_${xVar} ${timeUnit})
xtset finalclub_${xVar} ${timeUnit}
rename finalclub_${xVar} Club
xtline re_${xVar}, overlay scale(1.6) ytitle("${xVarLabel}", size(small)) yscale(lstyle(none)) ylabel(, noticks labcolor(gs10)) xscale(lstyle(none)) xlabel(, noticks labcolor(gs10))  xtitle("") name(clubsAverages, replace)

graph save   "../results/${dataSet}_clubsAverages.gph", replace
graph export "../results/${dataSet}_clubsAverages.pdf", replace

clear
use "../data/${dataSet}_clubs.dta"

*-------------------------------------------------------
***************** Export list of clubs  ****************
*-------------------------------------------------------

summarize ${timeUnit}
scalar finalYear = r(max)
keep if ${timeUnit} == `=finalYear'

keep id ${csUnitName} finalclub_${xVar}
sort finalclub_${xVar} ${csUnitName}
save "../data/${dataSet}_clubsList.dta", replace
export delimited using "../data/${dataSet}_clubsList.csv", replace


*-------------------------------------------------------
***************** Close log file*************
*-------------------------------------------------------

log close
