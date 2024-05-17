clear all
macro drop _all
capture log close
set more off
version 15

cd "D:\Github Desktop\2024e\data" 

*use "https://raw.githubusercontent.com/eileenCHEN-9/PhD_2022_2025/main/data/county_predicted.dta" // County-level
use "https://raw.githubusercontent.com/eileenCHEN-9/PhD_2022_2025/main/data/Main_Dataset.dta" // City-level
*-------------------------------------------------------
***************** Define global parameters*************
*-------------------------------------------------------

* dataset name
*global dataSet county_predicted
* variable to be studied
global xVar trend_lg_gdppc_predicted
global xVar2 trend_lg_nonagri_predicted
global xVar3 trend_lg_agri_predicted
* label of the variable
global xVarLabel Trend log GDPpc Predicted
global xVarLabel2 Trend log non-agriculture GDPpc Predicted
global xVarLabel3 Trend log agriculture GDPpc Predicted
* Names of cross-sectional units
global csUnitName city
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
*use "../data/${dataSet}.dta", clear

* keep necessary variables
rename city_id id 
keep v1 id city province_id province lg_totalgdp_predicted lg_gdppc_predicted ${csUnitName} ${timeUnit} lg_nonagri_predicted lg_agri_predicted
order id ${timeUnit} city

* set panel data
xtset id ${timeUnit}

*-------------------------------------------------------
***************** Compute long-run trend  ***********
*-------------------------------------------------------

*Filter total gdppc
pfilter lg_gdppc_predicted, method(hp) trend(trend_lg_gdppc_predicted) smooth(400)
*Filter non-agriculture gdppc
pfilter lg_nonagri_predicted, method(hp) trend(trend_lg_nonagri_predicted) smooth(400)
*Filter agriculture gdppc
pfilter lg_agri_predicted, method(hp) trend(trend_lg_agri_predicted) smooth(400)

*-------------------------------------------------------
***************** Apply PS convergence test  ***********
*-------------------------------------------------------

* run logt regression
putexcel set "../results/results.xlsx", sheet(logtTest) replace
    logtreg ${xVar},  kq(0.30) // total
ereturn list
matrix result01 = e(res)
putexcel A1 = ("Logt for total gdppc"), font(bold) border(bottom)
putexcel A2 = matrix(result01), names nformat("#.##") overwritefmt

    logtreg ${xVar2},  kq(0.30) // non-agri
ereturn list
matrix result02 = e(res)
putexcel A6 = ("Logt for non-agriculture gdppc"), font(bold) border(bottom)
putexcel A7 = matrix(result02), names nformat("#.##") overwritefmt

    logtreg ${xVar3},  kq(0.30) // agri
ereturn list
matrix result03 = e(res)
putexcel A11 = ("Logt for agriculture gdppc"), font(bold) border(bottom)
putexcel A12 = matrix(result03), names nformat("#.##") overwritefmt







* run clustering algorithm (NOTE: the adjust option changes the number of clubs from 4 to 5)
putexcel set "../results/results.xlsx", sheet(initialClusters) modify
    psecta ${xVar}, adjust  name(${csUnitName}) kq(0.30) gen(club_${xVar}) // total
matrix b=e(bm)
matrix t=e(tm)
matrix result11=(b \ t)
matlist result11, border(rows) rowtitle("log(t)") format(%9.3f) left(4)
putexcel A1 = ("Initial Clubs for total gdppc"), font(bold) border(bottom)
putexcel A2 = matrix(result11), names nformat("#.##") overwritefmt

    psecta ${xVar2}, adjust  name(${csUnitName}) kq(0.30) gen(club_${xVar2}) // non-agri
matrix b=e(bm)
matrix t=e(tm)
matrix result12=(b \ t)
matlist result12, border(rows) rowtitle("log(t)") format(%9.3f) left(4)
putexcel A6 = ("Initial Clubs for non-agriculture gdppc"), font(bold) border(bottom)
putexcel A7 = matrix(result12), names nformat("#.##") overwritefmt

    psecta ${xVar3}, adjust  name(${csUnitName}) kq(0.30) gen(club_${xVar3}) // agri
matrix b=e(bm)
matrix t=e(tm)
matrix result13=(b \ t)
matlist result13, border(rows) rowtitle("log(t)") format(%9.3f) left(4)
putexcel A12 = ("Initial Clubs for agriculture gdp"), font(bold) border(bottom)
putexcel A13 = matrix(result13), names nformat("#.##") overwritefmt






* run clustering merge algorithm
putexcel set "../results/results.xlsx", sheet(mergingClusters) modify
    scheckmerge ${xVar},  kq(0.30) club(club_${xVar}) // total
matrix b=e(bm)
matrix t=e(tm)
matrix result21=(b \ t)
matlist result21, border(rows) rowtitle("log(t)") format(%9.3f) left(4)
putexcel A1 = ("Merging Clubs for total gdppc"), font(bold) border(bottom)
putexcel A2 = matrix(result21), names nformat("#.##") overwritefmt

    scheckmerge ${xVar2},  kq(0.30) club(club_${xVar2}) // non-agri
matrix b=e(bm)
matrix t=e(tm)
matrix result22=(b \ t)
matlist result22, border(rows) rowtitle("log(t)") format(%9.3f) left(4)
putexcel A6 = ("Merging Clubs for non-agriculture gdp"), font(bold) border(bottom)
putexcel A7 = matrix(result22), names nformat("#.##") overwritefmt

    scheckmerge ${xVar3},  kq(0.30) club(club_${xVar3}) // agri
matrix b=e(bm)
matrix t=e(tm)
matrix result23=(b \ t)
matlist result23, border(rows) rowtitle("log(t)") format(%9.3f) left(4)
putexcel A12 = ("Merging Clubs for agriculture gdp"), font(bold) border(bottom)
putexcel A13 = matrix(result23), names nformat("#.##") overwritefmt





* list final clusters
putexcel set "../results/results.xlsx", sheet(finalClusters) modify
    imergeclub ${xVar}, name(${csUnitName}) kq(0.30) club(club_${xVar}) gen(fclub_${xVar}) // total
matrix b=e(bm)
matrix t=e(tm)
matrix result31=(b \ t)
matlist result31, border(rows) rowtitle("log(t)") format(%9.3f) left(4)
putexcel A1 = ("Final Clubs for total gdppc"), font(bold) border(bottom)
putexcel A2 = matrix(result31), names nformat("#.##") overwritefmt

    imergeclub ${xVar2}, name(${csUnitName}) kq(0.30) club(club_${xVar2}) gen(fclub_${xVar2}) // non-agri
matrix b=e(bm)
matrix t=e(tm)
matrix result32=(b \ t)
matlist result32, border(rows) rowtitle("log(t)") format(%9.3f) left(4)
putexcel A6 = ("Final Clubs for non-agriculture gdp"), font(bold) border(bottom)
putexcel A7 = matrix(result32), names nformat("#.##") overwritefmt

    imergeclub ${xVar3}, name(${csUnitName}) kq(0.30) club(club_${xVar3}) gen(fclub_${xVar3}) // agri
matrix b=e(bm)
matrix t=e(tm)
matrix result33=(b \ t)
matlist result33, border(rows) rowtitle("log(t)") format(%9.3f) left(4)
putexcel A12 = ("Final Clubs for agriculture gdp"), font(bold) border(bottom)
putexcel A13 = matrix(result33), names nformat("#.##") overwritefmt


sum fclub_trend_lg_gdppc_predicted 
sum fclub_trend_lg_nonagri_predicted
sum fclub_trend_lg_agri_predicted


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


save "temporary2.dta",replace
use  "temporary2.dta"

collapse ${xVar2}, by(${timeUnit})
gen  id=999999
append using "temporary2.dta"
sort id ${timeUnit}

gen ${xVar2}_av = ${xVar2} if id==999999
bysort ${timeUnit} (${xVar2}_av): replace ${xVar2}_av = ${xVar2}_av[1]
gen re_${xVar2} = 1*(${xVar2}/${xVar2}_av)
label var re_${xVar2}  "Relative ${xVar2}  (Average=1)"
drop ${xVar2}_av
sort id ${timeUnit}

drop if id == 999999
rm "temporary2.dta"


save "temporary3.dta",replace
use  "temporary3.dta"

collapse ${xVar3}, by(${timeUnit})
gen  id=999999
append using "temporary3.dta"
sort id ${timeUnit}

gen ${xVar3}_av = ${xVar3} if id==999999
bysort ${timeUnit} (${xVar3}_av): replace ${xVar3}_av = ${xVar3}_av[1]
gen re_${xVar3} = 1*(${xVar3}/${xVar3}_av)
label var re_${xVar3}  "Relative ${xVar3}  (Average=1)"
drop ${xVar3}_av
sort id ${timeUnit}

drop if id == 999999
rm "temporary3.dta"


* order variables
order ${csUnitName}, before(${timeUnit})
order id, before(${csUnitName})

* Export data to csv
export delimited using "../results/Dataset_clubs.csv", replace
save "../results/Dataset_clubs.dta", replace
export delimited using "../data/Dataset_clubs.csv", replace
save "../data/Dataset_clubs.dta", replace

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
