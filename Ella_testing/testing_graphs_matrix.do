/*********************************************************************************************
Testing siman setup and analyse for all different permutation of the data (>100 combinations)
NOTE: to be run in "Ella_testing" folder
Ella 14novar2023
************************************************************************************************/
global detail = 0

// SETUP: MODIFY FOR USER & PROJECT
local codepath C:\ian\git\siman\ // for Ian
local codepath C:\git\siman\ // for Ella

// SETUP FOR ALL USERS
local testpath `codepath'Ella_testing\
local filename testing_graphs_matrix
prog drop _all
adopath ++ `codepath '
cd `testpath'
cap log close
set linesize 100

* switch on detail if want to run all graphs
global detail = 1

// START TESTING
log using `filename', replace
siman which

********************************
********************************
* DGM defined by 1 variable:
* numeric
* numeric with string labels
* string
* missing

* DGM defined by multiple variables with multiple levels:
* numeric
* numeric with string labels
* string

* TARGET and METHOD:
* wide or long
* numeric
* numeric with string labels
* string
* missing

* method: methlist option for subset of multiple methods

* TRUE
* numeric value
* numeric variable 1 level
* numeric variable >1 level
* missing
********************************
********************************

*************************************************************************
*************************************************************************
* LONG-LONG
*************************************************************************
*************************************************************************

* DGM numeric, 1 var
*********************
* target long and string, method long and numeric, true variable 1 level
use data/simlongESTPM_longE_longM.dta, clear
siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)
siman analyse

* DGM numeric with string labels, 1 var
*****************************************

* target wide and numeric with string labels, method wide and string, true value
use data/simlongESTPM_longE_longM.dta, clear
encode estimand, gen(estimand_num)
drop estimand
rename estimand_num estimand
label define dgml 1 "D1" 2 "D2"
label values dgm dgml
gen method_str = ""
replace method_str = "A" if method == 1
replace method_str = "B" if method == 2
drop method
rename method_str method
drop true
siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(0) 
siman analyse
 

* DGM string, 1 var
********************
* method long numeric string labels, target numeric, true missing
use data/simlongESTPM_longE_longM.dta, clear
gen estimand_num = 1 if estimand == "beta"
replace estimand_num = 2 if estimand == "gamma"
drop estimand
rename estimand_num estimand
label define methodl 1 "A" 2 "B"
label values method methodl
gen dgm_str = ""
replace dgm_str = "1" if dgm == 1
replace dgm_str = "2" if dgm == 2
drop dgm true
rename dgm_str dgm
siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) 
siman analyse

 
* DGM missing
************** 
* Target numeric, method missing, true > 1 level (different true values per target)
use data/simlongESTPM_longE_longM.dta, clear
replace true=0.5 if estimand=="beta"
drop dgm method
gen estimand_num = .
replace estimand_num = 1 if estimand == "beta"
replace estimand_num = 2 if estimand == "gamma"
drop estimand
rename estimand_num estimand
bysort rep estimand: gen repitionindi=_n
drop if repitionindi>1
drop repitionindi
siman setup, rep(rep) target(estimand) estimate(est) se(se) true(true)
siman analyse

* missing target
use data/simlongESTPM_longE_longM.dta, clear
drop estimand
bysort rep dgm method: gen repitionindi=_n
drop if repitionindi == 2
drop repitionindi
siman setup, rep(rep) dgm(dgm) method(method) estimate(est) se(se) true(true)
siman analyse 


* DGM defined by multiple variables with multiple levels (numeric, labelled numeric and string)
************************************************************************************************
use data/extendedtestdata_postfile.dta, clear

* remove non-integer values
foreach var in beta pmiss {
	gen `var'char = strofreal(`var')
	drop `var'
	sencode `var'char, gen(`var')
	drop `var'char
}
order beta pmiss

siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) 
siman analyse

*************************************************************************
*************************************************************************
* LONG-WIDE
*************************************************************************
*************************************************************************

* DGM numeric, 1 var
*********************
* target string, 
use data/simlongESTPM_longE_wideM1.dta, clear
siman setup, rep(rep) dgm(dgm) est(est) se(se) target(estimand) method(_1 _2) true(true)
siman analyse




di as result "*** SIMAN GRAPHS HAVE PASSED ALL THESE TESTS ***"

log close
