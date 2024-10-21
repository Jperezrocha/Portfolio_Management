*Upload the NAV report from IBKR
 
import delimited "/Users/jeronimoperezrocha/Desktop/SMF - Quant Analyst/PA/NAV_Inception_October_17_2024.csv" 

*Make Date a String
tostring date, replace
 
* Prpare Data 
gen date_num = date(date, "YMD")
 
format date_num %td

*drop the date form IBKR format
drop date 

*rename date_num to date
rename date_num date 

*be the first column
order date 

*save this data set
save "/Users/jeronimoperezrocha/Desktop/SMF - Quant Analyst/PA/PA_data.dta", replace

clear 

*impot SP5000 data
import delimited "/Users/jeronimoperezrocha/Desktop/SMF - Quant Analyst/PA/SPY_data.csv"

*get the prices of the S&P 500 to merge
 
*Prepare S&P 500 date 
 
gen date_num = date(date, "MD20Y")
 
format date_num %td 
 
drop date
 
rename date_num date
 
order date 

save "/Users/jeronimoperezrocha/Desktop/SMF - Quant Analyst/PA/SP500_data.dta"

clear
 
*upload the NAV aging to merge data with SP500 
use  "PA_data.dta"

*you shoul see the original NAV data with all the previous chnages made


*Merge IBKR data with spy data. date columns need to have the same name
*matched = 3, if only in master (IBKR) = 1

merge 1:1 date using "SP500_data.dta" 

*NOTE the Original Dates from IBKR don't mathch with SP500 data. STATA creates a new column -
*for you named "_merge" if date matches == 3 if not=1. You can scrol to NOV 27 2014 
* and you can scroll down to NOV 27 2014 and see that there is no data for teh SP500 price
* and the column _merge	=1, THIS SHOULD ALWAYS BE TRUE
 
drop if _merge == 1 

* I have to drop merge 2 as well becuase I added More days that I needed from SPY
drop if _merge ==2
 
drop _merge

* Do SOME SPOTTING CHECK *
 
 
* PORTFOLIO ANALYSIS

*Beta
gen equity = stocks + etfs

gen equity_returns = (equity - equity[_n-1]) / equity[_n-1] 

gen spy_returns = (price - price[_n-1]) / price[_n-1]

regress	equity_returns spy_returns

scalar beta = _b[spy_returns]

display beta


*Tracking Error = std (P-B)

gen return_diff = equity_returns - spy_returns 

summ return_diff
scalar tracking_error = r(sd)

display tracking_error


*STD

summ equity_returns

scalar equity_stdddev = r(sd)

display equity_stdddev


*Semi STD

summ equity_returns

scalar avg_equity = r(mean)

gen negative_deviation = cond(equity_returns < avg_equity, (equity_returns - avg_equity)^2, .)

summ negative_deviation, meanonly
scalar semi_variance = r(mean)

scalar semi_stddev = sqrt(semi_variance)

display semi_stddev

*Value at Risk 

*Claculate the 5th percentile (95% confidence) 
sort equity_returns

pctile var_95 = equity_returns, nq(20)

list var_95 in 1 

sort date

*Covariance and Correlation 

corr equity_returns spy_returns, cov

corr equity_returns spy_returns

*Sharpe Ratio
gen excess_returns = equity_returns - spy_returns

summ excess_returns

scalar avg_excess = r(mean)

scalar std_excess = r(sd)

scalar sharpe_ratio = avg_excess / std_excess

display sharpe_ratio


*The information ratio

summ return_diff

scalar return_diff_stddev = r(sd)

summ return_diff

scalar mean_diff_return = r(mean)

scalar information_ratio  = mean_diff_return / tracking_error

display information_ratio

*Calcualtion needed for Dietz Method

gen nav_returns = (nav - nav[_n-1]) / nav[_n-1]
 
gen delta_equity = equity - equity[_n-1]

gen delta_cash = cash - cash[_n-1]

gen cash_flow = delta_equity + delta_cash


*Calculate the return uisng Dietz Method 

gen calculation = equity[_n-1] + (0.5 * delta_cash)

gen Dietz = cash_flow / calculation

*Normalize Data for plotting 
gen equity_normalized = equity / equity[1]

gen spy_price_normalized = price / price[1]


*drop the first 19 lines 800,000 deposit
drop in 1/19  


*Graphs
line nav date

twoway (line Dietz date) (line spy_returns date)












