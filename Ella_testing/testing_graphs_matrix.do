/*********************************************************************************************
Testing siman setup and analyse for all different permutation of the data (>100 combinations)
NOTE: to be run in "Ella_testing" folder
Ella 14novar2023
************************************************************************************************/

local filename testing_graphs_matrix

prog drop _all
cd $testpath
cap log close
set linesize 100

// START TESTING
log using `filename', replace text nomsg
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
use $testpath/data/simlongESTPM_longE_longM.dta, clear
siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)
siman analyse

* DGM numeric with string labels, 1 var
*****************************************

* target wide and numeric with string labels, method wide and string, true value
use $testpath/data/simlongESTPM_longE_longM.dta, clear
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
use $testpath/data/simlongESTPM_longE_longM.dta, clear
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
use $testpath/data/simlongESTPM_longE_longM.dta, clear
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
use $testpath/data/simlongESTPM_longE_longM.dta, clear
drop estimand
bysort rep dgm method: gen repitionindi=_n
drop if repitionindi == 2
drop repitionindi
siman setup, rep(rep) dgm(dgm) method(method) estimate(est) se(se) true(true)
siman analyse 


* DGM defined by multiple variables with multiple levels (numeric, labelled numeric and string)
************************************************************************************************
use $testpath/data/extendedtestdata.dta, clear

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
* target string, true variable 1 level
use $testpath/data/simlongESTPM_longE_wideM1.dta, clear
siman setup, rep(rep) dgm(dgm) est(est) se(se) target(estimand) method(_1 _2) true(true)
siman analyse

* DGM numeric with string labels, 1 var
*****************************************
* target numeric, true missing
use $testpath/data/simlongESTPM_longE_wideM.dta, clear
label define dgmlabel 1 "MCAR" 2 "MNAR"
label values dgm dgmlabel
gen target = 1 if estimand == "beta"
replace target = 2 if estimand == "gamma"
drop estimand true
rename target estimand
siman setup, rep(rep) dgm(dgm) est(est) se(se) target(estimand) method(1 2) 
siman analyse


* DGM string, 1 var
********************
* target numeric with string labels, true value

use $testpath/data/simlongESTPM_longE_wideM1.dta, clear
encode estimand, gen(estimand_new)
gen dgm_new = "1"
replace dgm_new = "2" if dgm == 2
drop true estimand dgm
rename estimand_new estimand
rename dgm_new dgm
siman setup, rep(rep) dgm(dgm) est(est) se(se) target(estimand) method(_1 _2) true(0.5)
siman analyse

* DGM missing
************** 
* true variable with >1 level, method missing
use $testpath/data/simlongESTPM_longE_wideM1.dta, clear
drop dgm est_2 se_2
replace true = 0.5 if estimand == "gamma"
rename est_1 est
rename se_1 se
bysort rep estimand: gen n = _n
drop if n==2
drop n
siman setup, rep(rep) est(est) se(se) target(estimand) true(true)
siman analyse

* missing target
use $testpath/data/simlongESTPM_longE_wideM1.dta, clear
drop estimand
bysort rep dgm: gen n = _n
drop if n==2
drop n
siman setup, rep(rep) dgm(dgm) est(est) se(se) method(_1 _2) true(true)
siman analyse

* DGM defined by multiple variables with multiple levels (numeric, labelled numeric and string)
************************************************************************************************
use $testpath/data/extendedtestdata.dta, clear

* remove non-integer values
foreach var in beta pmiss {
	gen `var'char = strofreal(`var')
	drop `var'
	sencode `var'char, gen(`var')
	drop `var'char
}
order beta pmiss
* reshape in to long-wide format
reshape wide b se, i(rep mech pmiss beta estimand) j(method "Noadj" "CCA" "MeanImp") string

siman setup, rep(rep) dgm(beta pmiss mech) method(Noadj CCA MeanImp) target(estimand) est(b) se(se) 
siman analyse

*************************************************************************
*************************************************************************
* WIDE-WIDE, order(method)
*************************************************************************
*************************************************************************

* DGM numeric, 1 var
*********************

use $testpath/data/simlongESTPM_wideE_wideM.dta, clear
* true variable, 1 value
siman setup, rep(rep) dgm(dgm) est(est) se(se) method(1_ 2_) target(beta gamma) true(true) order(method)

* DGM numeric with string labels, 1 var
*****************************************
* true missing
use $testpath/data/simlongESTPM_wideE_wideM.dta, clear
label define dgmlabel 1 "MCAR" 2 "MNAR"
label values dgm dgmlabel
bysort rep dgm: gen n = _n
drop if n==2
drop n true
siman setup, rep(rep) dgm(dgm) est(est) se(se) target(beta gamma) method(1_ 2_) order(method)
siman analyse

* DGM string, 1 var
********************
* true numeric value
use $testpath/data/simlongESTPM_wideE_wideM.dta, clear
gen dgm_new = "1"
replace dgm_new = "2" if dgm == 2
drop dgm true
rename dgm_new dgm
siman setup, rep(rep) dgm(dgm) est(est) se(se) target(beta gamma) method(1_ 2_) true(0.5) order(method)
siman analyse

* DGM missing
************** 

use $testpath/data/simlongESTPM_wideE_wideM.dta, clear
drop dgm
bysort rep: gen n = _n
drop if n==2
drop n 
siman setup, rep(rep) est(est) se(se) target(beta gamma) method(1_ 2_) true(true) order(method)
siman analyse

* DGM defined by multiple variables with multiple levels (numeric, labelled numeric and string)
************************************************************************************************
use $testpath/data/extendedtestdata.dta, clear

* remove non-integer values
foreach var in beta pmiss {
	gen `var'char = strofreal(`var')
	drop `var'
	sencode `var'char, gen(`var')
	drop `var'char
}
order beta pmiss
* reshape in to wide-wide format, method in label first
reshape wide b se, i(rep mech pmiss beta estimand) j(method "Noadj" "CCA" "MeanImp") string
reshape wide bNoadj seNoadj bCCA seCCA bMeanImp seMeanImp, i(rep mech pmiss beta) j(estimand "effect" "mean0" "mean1") string
siman setup, rep(rep) dgm(beta pmiss mech) method(Noadj CCA MeanImp) target(effect mean0 mean1) est(b) se(se) order(method)
siman analyse

*************************************************************************
*************************************************************************
* WIDE-WIDE, order(target)
*************************************************************************
*************************************************************************

* DGM numeric, 1 var
*********************
* true variable 1 level
use $testpath/data/simlongESTPM_wideE_wideM2.dta, clear
siman setup, dgm(dgm) rep(rep) est(est) se(se) target(beta_ gamma_) method(1 2) true(true) order(target)
siman analyse

* DGM numeric with string labels, 1 var
*****************************************
* true missing
use $testpath/data/simlongESTPM_wideE_wideM2.dta, clear
label define dgmlabel 1 "MCAR" 2 "MNAR"
label values dgm dgmlabel
bysort rep dgm: gen n = _n
drop if n==2
drop n true
siman setup, dgm(dgm) rep(rep) est(est) se(se) target(beta_ gamma_) method(1 2) order(target)
siman analyse

* DGM string, 1 var
********************
* true numeric value
use $testpath/data/simlongESTPM_wideE_wideM2.dta, clear
gen dgm_new = "1"
replace dgm_new = "2" if dgm == 2
drop dgm true
rename dgm_new dgm
siman setup, dgm(dgm) rep(rep) est(est) se(se) target(beta_ gamma_) method(1 2) true(0.5)  order(target) 
siman analyse

* DGM missing
************** 
use $testpath/data/simlongESTPM_wideE_wideM2.dta, clear
drop dgm
bysort rep: gen n = _n
drop if n==2
drop n 
siman setup, rep(rep) est(est) se(se) target(beta_ gamma_) method(1 2) true(true)  order(target) 
siman analyse

* DGM defined by multiple variables with multiple levels (numeric, labelled numeric and string)
************************************************************************************************
use $testpath/data/extendedtestdata.dta, clear

* remove non-integer values
foreach var in beta pmiss {
	gen `var'char = strofreal(`var')
	drop `var'
	sencode `var'char, gen(`var')
	drop `var'char
}
order beta pmiss
* reshape in to wide-wide format, target in label first
reshape wide b se, i(rep mech pmiss beta method) j(estimand "effect" "mean0" "mean1") string
reshape wide beffect seeffect bmean0 semean0 bmean1 semean1, i(rep mech pmiss beta) j(method "Noadj" "CCA" "MeanImp") string
siman setup, rep(rep) dgm(beta pmiss mech) method(Noadj CCA MeanImp) target(effect mean0 mean1) est(b) se(se) order(target)
siman analyse

*************************************************************************
*************************************************************************
* WIDE-LONG
*************************************************************************
*************************************************************************

* DGM numeric, 1 var
*********************
* method numeric, true variable 1 level
use $testpath/data/simlongESTPM_longM_wideE1.dta, clear
siman setup, rep(rep) dgm(dgm) est(est) se(se) target(_beta _gamma) method(method) true(true)
siman analyse

* DGM numeric with string labels, 1 var
*****************************************
* method string, true missing
use $testpath/data/simlongESTPM_longM_wideE1.dta, clear
label define dgmlabel 1 "MCAR" 2 "MNAR"
label values dgm dgmlabel
gen method_new = "1"
replace method_new = "2" if method == 2
drop method true
rename method_new method
siman setup, rep(rep) dgm(dgm) est(est) se(se) target(_beta _gamma) method(method)
siman analyse


* DGM string, 1 var
********************
* method numeric with string labels, true value

use $testpath/data/simlongESTPM_longM_wideE.dta, clear
label define mlabel 1 "Method1" 2 "Method2"
label values method mlabel
gen dgm_new = "1"
replace dgm_new = "2" if dgm == 2
drop true dgm
rename dgm_new dgm
siman setup, rep(rep) dgm(dgm) est(est) se(se) target(beta_ gamma_) method(method) true(0.5)
siman analyse


* DGM missing
************** 
use $testpath/data/simlongESTPM_longM_wideE2.dta, clear
drop dgm
bysort rep method: gen n = _n
drop if n==2
drop n
siman setup, rep(rep) est(est) se(se) method(method) target(1 2) true(true)
siman analyse

* missing method
use $testpath/data/simlongESTPM_longM_wideE.dta, clear
drop method
bysort rep dgm: gen n = _n
drop if n==2
drop n
siman setup, rep(rep) dgm(dgm) est(est) se(se) target(beta_ gamma_) true(true)
siman analyse

* DGM defined by multiple variables with multiple levels (numeric, labelled numeric and string)
************************************************************************************************
use $testpath/data/extendedtestdata.dta, clear

* remove non-integer values
foreach var in beta pmiss {
	gen `var'char = strofreal(`var')
	drop `var'
	sencode `var'char, gen(`var')
	drop `var'char
}
order beta pmiss
* reshape in to wide-long format
reshape wide b se, i(rep mech pmiss beta method) j(estimand "effect" "mean0" "mean1") string
siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(effect mean0 mean1) est(b) se(se) 
siman analyse

di as result "*** SIMAN GRAPHS HAVE PASSED ALL THE TESTS IN `filename'.do ***"

log close
