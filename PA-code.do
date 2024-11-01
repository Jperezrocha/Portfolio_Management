
clear

********************************************************************************
*	PORTFOLIO SECTOR ANALYSIS 
********************************************************************************

import delimited "/Users/jeronimoperezrocha/Desktop/SMF - Quant Analyst/PA/Sector & Ratios Data/Portfolio_sectors.csv", varnames(1)


egen portfolio_total = sum(basevalue)


collapse (sum) basevalue, by(sector)
rename basevalue sector_total


gen sector_percentage = (sector_total/portfolio_total)*100


gsort -sector_percentage


graph pie sector_total, over(sector) ///
    legend(position(2)) ///
    plabel(_all percent, format(%9.2f) gap(20)) ///
    pie(10, explode(7)) ///    // in your current ordering
    pie(11, explode(11)) ///
    pie(12, explode(5)) ///
    title("Portfolio Composition by Sector", size(medium) position(11))

clear


import delimited "/Users/jeronimoperezrocha/Desktop/SMF - Quant Analyst/PA/Sector & Ratios Data/S&P500_ratios.csv", varnames(1)

graph pie weight, over(name) ///
    legend(position(2)) ///
    plabel(_all percent, format(%9.2f) gap(20)) ///
    pie(9, explode(5)) ///    // Utilities
    pie(10, explode(7)) ///   // Real Estate
    pie(11, explode(9)) ///   // Materials
    title("S&P 500 Composition by Sector", size(medium) position(11))

clear 

********************************************************************************
*	PORTFOLIO PERFORMANCE & RIKS
********************************************************************************

*Upload the NAV report from IBKR
import delimited "/Users/jeronimoperezrocha/Desktop/SMF - Quant Analyst/PA/NAV_Oct_28.csv" 

*Make Date a String
* Prpare Data format date
tostring date, replace
 
gen date_num = date(date, "YMD")
 
format date_num %td

drop date 

*rename date_num to date
rename date_num date 

order date 

*save this data set
save "/Users/jeronimoperezrocha/Desktop/SMF - Quant Analyst/PA/PA_data.dta", replace

clear 

*impot SP5000 data
import delimited "/Users/jeronimoperezrocha/Desktop/SMF - Quant Analyst/PA/SPX_data.csv"

*get the prices of the S&P 500 to merge
 
*Prepare S&P 500 date 
 
gen date_num = date(date, "MD20Y")
 
format date_num %td 
 
drop date
 
rename date_num date
 
order date 

save "/Users/jeronimoperezrocha/Desktop/SMF - Quant Analyst/PA/SP500_data.dta", replace

clear
 
*upload the NAV aging to merge data with SP500 
use "PA_data.dta"

*you shoul see the original NAV data with all the previous chnages made


*Merge IBKR data with spy data. date columns need to have the same name
*matched = 3, if only in master (IBKR) = 1

merge 1:1 date using "SP500_data.dta" 

*NOTE the Original Dates from IBKR don't mathch with SP500 data. STATA creates a new column -
*for you named "_merge" if date matches == 3 if not=1. You can scrol to NOV 27 2014 
* and you can scroll down to NOV 27 2014 and see that there is no data for teh SP500 price
* and the column _merge	=1, THIS SHOULD ALWAYS BE TRUE
* I have to drop merge 2 as well becuase I added More days that I needed from SPY
 
drop if _merge == 1 

drop if _merge ==2
 
drop _merge


*drop the first 19 lines 800,000 deposit and cahs withdraw 01/07/2015 
*This drop will keep Jan 7 after calcualtions is going to be delte

gen date_num = date

drop if date_num<20095



*EQUITY VALUE
gen equity = stocks + etfs





*CALCULATE STOCK RETURNS
********************************************************************************

gen rport = ln(equity/equity[_n-1])

gen rspy = ln(price/price[_n-1])

gen rnav = ln(nav/nav[_n-1])




*DIETZ METHOD
********************************************************************************

gen c_equity = equity - equity[_n-1]

gen c_cash = cash - cash[_n-1]

gen _cf = c_equity + c_cash

gen calc = equity[_n-1] + (0.5 * c_cash)

gen rdietz = _cf / calc



*CREAT INDEX 
********************************************************************************
gen spyindex = 100
replace spyindex = spyindex[_n-1]*(1+ rspy[_n]) if date_num > 20095


gen portindex = 100
replace portindex = portindex[_n-1]*(1+ rport[_n]) if date_num > 20095

gen dietzindex = 100
replace dietzindex = dietzindex[_n-1]*(1+ rdietz[_n]) if date_num > 20095

gen navindex = 100
replace navindex = navindex[_n-1] * (1 + rnav[_n]) if date_num > 20095





*FORMATTING DATES FOR GRPAHING 
********************************************************************************

gen wok = date_num 

tsset date_num, format (%td)

format date_num %tdCCYY.NN.DD






*RISK METRICS
********************************************************************************

*BETA   Since inception 5yr 3yr 

regress  rport rspy 

regress rport rspy if date_num> 21845

regress rport rspy if date_num> 22578







*TRACKING ERROR
gen excess_returns = rport - rspy

summ excess_returns

scalar tracking_error = r(sd)

display tracking_error



*TRACKING ERRO DIETZ METHOD
gen dietz_excessr = rdietz - rspy

summ dietz_excessr

scalar dietz_tracking_error = r(sd)

display dietz_tracking_error



*STD
summ rport

scalar port_std = r(sd)

display port_std



*STD BY YEAR
gen year = year(date)

sort year date

by year: summarize rport





*SEMI STD
summ rport

scalar avg_rport = r(mean)

gen negative_deviation = cond(rport < avg_rport, (rport - avg_rport)^2, .)

summ negative_deviation, meanonly
scalar semi_variance = r(mean)

scalar semi_stddev = sqrt(semi_variance)

display semi_stddev



*SPY SEMI STD
summ rspy

scalar spy_avg_returns = r(mean)

gen spy_negative_deviation = cond(rspy < spy_avg_returns, (rspy - spy_avg_returns)^2, .)

summ spy_negative_deviation, meanonly
scalar spy_semi_variance = r(mean)

scalar spy_semi_std = sqrt(spy_semi_variance)

display spy_semi_std




*COVARIANCE AND CORRELATION

corr rdietz rspy, cov

corr rdietz rspy




*Sharpe Ratio
scalar avg_excess = r(mean)

scalar std_excess = r(sd)

summ rport

scalar std_equity_returns = r(sd)

scalar sharpe_ratio = avg_excess / std_equity_returns

display sharpe_ratio


*The information ratio

summ excess_returns

scalar excess_returns_stddev = r(sd)

summ excess_returns

scalar mean_diff_return = r(mean)

scalar information_ratio  = mean_diff_return / tracking_error

display information_ratio






********************************************************************************
*	SMF PORTFOLIO YTD PERFORMANCE
********************************************************************************
	
	
preserve 
scalar start = 23377
su spyindex if wok == start
gen spyindexN = 100 * spyindex / r(mean)
su navindex if wok == start 
gen navindexN = 100 * navindex / r(mean)


graph twoway tsline navindexN spyindexN if date_num > 23377, ///
    clpattern(solid solid) lwidth(thick thick) ///
    title("SMF Portfolio Performance vs S&P 500: YTD", size(large) margin(bottom)) ///
	xtitle("")	///
    ylabel(100(4)132, angle(0) grid glcolor(gray%15)) ///
    xlabel(, angle(0) format(%tdMon_DD) grid glcolor(gray%15) labsize(medium)) ///
    graphregion(color(white)) plotregion(margin(small)) ///
    legend(label(1 "NAV") label(2 "S&P 500") ///
           region(color(none)) cols(2) position(6) size(medium)) ///
    lcolor(navy cranberry)

restore  	
	
********************************************************************************
*	SMF PORTFOLIO SINCE INCEPTION
********************************************************************************


graph twoway tsline navindex spyindex if date_num>20096, ///
    clpattern(solid solid) lwidth(medium medium) ///
    title("SMF Portfolio Performance vs S&P 500: Since Inception", size(large) margin(bottom)) ///
    xtitle("") ///
    xlabel(, angle(0) format(%tdCY) grid glcolor(gray%15) labsize(medium) ///
           labgap(medium)) ///
    ylabel(92(20)240, angle(0) grid glcolor(gray%15)) ///
    graphregion(color(white) margin(small)) ///
    plotregion(margin(medium)) ///
    legend(label(1 "NAV") label(2 "S&P 500") ///
           region(color(none)) cols(2) position(6) size(medium)) ///
    lcolor(navy cranberry) ///
    scale(1.1)

	
	

	
********************************************************************************
*	SMF SEMESTER PERFORMANCE
********************************************************************************

preserve 
scalar start = 23611

su spyindex if wok == start
gen spyindexN = 100 * spyindex / r(mean)

su navindex if wok == start 
gen navindexN = 100 * navindex / r(mean)

graph twoway tsline navindexN spyindexN if date_num > 23611, ///
    clpattern(solid solid) lwidth(thick thick) ///
    title("SMF Portfolio Performance vs S&P 500: Fall 2024", size(large) margin(bottom)) ///
	xtitle("") ///
    ylabel(92(2)105, angle(0) grid glcolor(gray%15)) ///
    xlabel(, angle(0) format(%tdMon_DD) grid glcolor(gray%15) labsize(medium)) ///
    graphregion(color(white)) plotregion(margin(small)) ///
    legend(label(1 "NAV") label(2 "S&P 500") ///
           region(color(none)) cols(2) position(6) size(medium)) ///
    lcolor(navy cranberry)

restore
	
********************************************************************************
*	SMF SEMESTER PERFORMANCE Dietz
********************************************************************************


preserve 
scalar start = 23611

su spyindex if wok == start
gen spyindexN = 100 * spyindex / r(mean)

su dietzindex if wok == start 
gen dietzindexN = 100 * dietzindex / r(mean)

graph twoway tsline dietzindexN spyindexN if date_num > 23611, ///
    clpattern(solid solid) lwidth(thick thick) ///
    title("Dietz Return vs S&P 500: Fall 2024", size(large) margin(bottom)) ///
	xtitle("") ///
    ylabel(92(2)105, angle(0) grid glcolor(gray%15)) ///
    xlabel(, angle(0) format(%tdMon_DD) grid glcolor(gray%15) labsize(medium)) ///
    graphregion(color(white)) plotregion(margin(small)) ///
    legend(label(1 "Dietz Method") label(2 "S&P 500") ///
           region(color(none)) cols(2) position(6) size(medium)) ///
    lcolor(navy cranberry)

restore

********************************************************************************
*	SMF YTD PERFORMANCE Dietz
********************************************************************************

preserve 
scalar start = 23377

su spyindex if wok == start
gen spyindexN = 100 * spyindex / r(mean)

su dietzindex if wok == start 
gen dietzindexN = 100 * dietzindex / r(mean)


graph twoway tsline dietzindexN spyindexN if date_num > 23377, ///
    clpattern(solid solid) lwidth(thick thick) ///
    title("Dietz Return vs S&P 500: YTD", size(large) margin(bottom)) ///
	xtitle("") /// 
    ylabel(100(4)132, angle(0) grid glcolor(gray%15)) ///
    xlabel(, angle(0) format(%tdMon_DD) grid glcolor(gray%15) labsize(medium)) ///
    graphregion(color(white)) plotregion(margin(small)) ///
    legend(label(1 "Dietz Method") label(2 "S&P 500") ///
           region(color(none)) cols(2) position(6) size(medium)) ///
    lcolor(navy cranberry)
 

restore


********************************************************************************
*	SMF SINCE INCEPTION PERFORMANCE Dietz 
********************************************************************************


graph twoway tsline dietzindex spyindex if date_num>20096, ///
    clpattern(solid solid) lwidth(medium medium) ///
    title("Dietz Return vs S&P 500: Since Inception", size(large) margin(bottom)) ///
	xtitle("") /// 
    xlabel(, angle(0) format(%tdCY) grid glcolor(gray%15) labsize(medium) ///
           labgap(medium)) ///
    ylabel(100(40)300, angle(0) grid glcolor(gray%15)) ///
    graphregion(color(white) margin(small)) ///
    plotregion(margin(medium)) ///
    legend(label(1 "Dietz Method") label(2 "S&P 500") ///
           region(color(none)) cols(2) position(6) size(medium)) ///
    lcolor(navy cranberry) ///
    scale(1.1)

