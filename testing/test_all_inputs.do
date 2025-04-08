/*********************************************************************************************
Testing siman setup and analyse for all different permutation of the data (>100 combinations)
NOTE: to be run in "testing" folder
Ella 14nov2023
14Feb2024 IW Remove arbitrary selection of records from the tests with DGM/Target missing, to avoid unnecessary flagging of changes with previous 
28oct2024 IW rename testing_graphs_matrix -> test_all_inputs 

************************************************************************************************/

local filename test_all_inputs

prog drop _all
cd $testpath
cap log close
set linesize 100

// START TESTING
log using `filename'_which, replace text
siman which
log close

log using `filename', replace text nomsg

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
* check that failed -siman setup- with no method() option doesn't leave unwanted _methodvar in data 
cap noi siman setup, rep(rep) target(estimand) method(method) est(est) se(se) true(true)
assert _rc==498
cap noi siman setup, rep(rep) dgm(dgm) method(method) est(est) se(se) true(true)
assert _rc==498
cap noi siman setup, rep(rep) dgm(dgm) target(estimand) est(est) se(se) true(true)
assert _rc==498
confirm new var _methodvar
* and do the correct setup
siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)
siman analyse
siman table


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
siman table


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
siman table

 
* DGM missing
************** 
* Target numeric, method missing, true > 1 level (different true values per target)
use $testpath/data/simlongESTPM_longE_longM.dta, clear
replace true=0.5 if estimand=="beta" // the wrong true value, done only to test
keep if method==1 & dgm==1
drop dgm method
gen estimand_num = .
replace estimand_num = 1 if estimand == "beta"
replace estimand_num = 2 if estimand == "gamma"
drop estimand
rename estimand_num estimand
siman setup, rep(rep) target(estimand) estimate(est) se(se) true(true)
siman analyse
siman table

* missing target
use $testpath/data/simlongESTPM_longE_longM.dta, clear
keep if estimand=="beta"
drop estimand
siman setup, rep(rep) dgm(dgm) method(method) estimate(est) se(se) true(true)
siman analyse 
siman table


* DGM defined by multiple variables with multiple levels (numeric, labelled numeric and string)
************************************************************************************************
use $testpath/data/extendedtestdata.dta, clear
order beta pmiss
siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) true(true)
siman analyse
siman table

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
siman table

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
siman table


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
siman table

* DGM missing
************** 
* true variable with >1 level, method missing
use $testpath/data/simlongESTPM_longE_wideM1.dta, clear
drop if dgm==2
drop dgm est_2 se_2
replace true = 0.5 if estimand == "gamma"
rename est_1 est
rename se_1 se
siman setup, rep(rep) est(est) se(se) target(estimand) true(true)
siman analyse
siman table

* Target missing
****************
use $testpath/data/simlongESTPM_longE_wideM1.dta, clear
drop if estimand == "gamma"
drop estimand
siman setup, rep(rep) dgm(dgm) est(est) se(se) method(_1 _2) true(true)
siman analyse
siman table

* DGM defined by multiple variables with multiple levels (numeric, labelled numeric and string)
************************************************************************************************
use $testpath/data/extendedtestdata.dta, clear
order beta pmiss
* reshape to long-wide format
reshape wide b se, i(rep mech pmiss beta estimand) j(method "Noadj" "CCA" "MeanImp") string

siman setup, rep(rep) dgm(beta pmiss mech) method(Noadj CCA MeanImp) target(estimand) est(b) se(se) true(true)
siman analyse
siman table

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
rename (*_*) (**)
siman setup, rep(rep) dgm(dgm) est(est) se(se) target(beta gamma) method(1 2) order(method)
siman analyse
siman table

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
siman table

* DGM missing
************** 

use $testpath/data/simlongESTPM_wideE_wideM.dta, clear
drop dgm
bysort rep: gen n = _n
drop if n==2
drop n 
siman setup, rep(rep) est(est) se(se) target(beta gamma) method(1_ 2_) true(true) order(method)
siman analyse
siman table

* DGM defined by multiple variables with multiple levels (numeric, labelled numeric and string)
************************************************************************************************
use $testpath/data/extendedtestdata.dta, clear
order beta pmiss
* data are long-long
* reshape method to wide
reshape wide b se, i(rep mech pmiss beta estimand) j(method "Noadj" "CCA" "MeanImp") string
* reshape target to wide
reshape wide bNoadj seNoadj bCCA seCCA bMeanImp seMeanImp true, i(rep mech pmiss beta) j(estimand "effect" "mean0" "mean1") string
* data are now wide-wide
siman setup, rep(rep) dgm(beta pmiss mech) method(Noadj CCA MeanImp) target(effect mean0 mean1) est(b) se(se) order(method) true(true)
siman analyse
siman table

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
siman table

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
siman table

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
siman table

* DGM missing
************** 
use $testpath/data/simlongESTPM_wideE_wideM2.dta, clear
drop dgm
bysort rep: gen n = _n
drop if n==2
drop n 
siman setup, rep(rep) est(est) se(se) target(beta_ gamma_) method(1 2) true(true)  order(target) 
siman analyse
siman table

* DGM defined by multiple variables with multiple levels (numeric, labelled numeric and string)
************************************************************************************************
use $testpath/data/extendedtestdata.dta, clear
order beta pmiss
* reshape target to wide
reshape wide b se true, i(rep mech pmiss beta method) j(estimand "effect" "mean0" "mean1") string
* reshape method to wide
reshape wide beffect seeffect bmean0 semean0 bmean1 semean1, i(rep mech pmiss beta) j(method "Noadj" "CCA" "MeanImp") string
siman setup, rep(rep) dgm(beta pmiss mech) method(Noadj CCA MeanImp) target(effect mean0 mean1) est(b) se(se) order(target) true(true)
siman analyse
siman table

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
siman table

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
siman table


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
siman table


* DGM missing
************** 
use $testpath/data/simlongESTPM_longM_wideE2.dta, clear
drop if dgm==2
drop dgm
siman setup, rep(rep) est(est) se(se) method(method) target(1 2) true(true)
siman analyse
siman table

* missing method
use $testpath/data/simlongESTPM_longM_wideE.dta, clear
drop method
bysort rep dgm: gen n = _n
drop if n==2
drop n
siman setup, rep(rep) dgm(dgm) est(est) se(se) target(beta_ gamma_) true(true)
siman analyse
siman table

* DGM defined by multiple variables with multiple levels (numeric, labelled numeric and string)
************************************************************************************************
use $testpath/data/extendedtestdata.dta, clear
order beta pmiss
* reshape in to wide-long format
reshape wide b se true, i(rep mech pmiss beta method) j(estimand "effect" "mean0" "mean1") string
siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(effect mean0 mean1) est(b) se(se) true(true)
siman analyse
siman table


* Test -analyse if-
*******************
use https://raw.githubusercontent.com/UCL/siman/dev/testing/data/simlongESTPM_longE_longM.dta, clear
siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)

siman analyse
su est if dgm==1 & estimand=="beta" & rep<0 & method==2 & _perfmeascode!="relprec"
local ref = r(mean)

siman analyse if method==2, replace
su est if dgm==1 & estimand=="beta" & rep<0 & method==2 & _perfmeascode!="relprec"
assert reldif(`ref', r(mean)) < 1E-10


* Test handling of string method containing spaces and hyphens
**************************************************************
use $testpath/data/extendedtestdata, clear
keep if float(pmiss)==float(0.2) & beta==0 & estimand=="effect"
drop beta pmiss estimand
replace meth="Mean Imp" if meth=="MeanImp"
replace meth="No-adj" if meth=="Noadj"
siman setup, rep(re) dgm(mech) method(method) estimate(b) se(se) true(true)
siman ana
siman table


* Check calculation works when SE is part-missing
*************************************************
use $testpath/data/simcheck, clear
replace se = . if dgm=="MNAR" & method=="MI":method
siman setup, rep(rep) dgm(dgm) method(method) est(b) se(se) df(df) true(0)
tab dgm method, sum(se)
siman ana estreps sereps mean modelse, perf 
assert mi(b) if _p=="modelse" & dgm=="MNAR":dgm & method=="MI":method
assert !mi(b) if _p=="mean" // this failed until 31/3/2025
* and check mcci option of table
siman table mean modelse, col(dgm method) mcci mclevel(95) format(%6.4f)
siman table mean modelse, col(dgm method) nomcse mcci mclevel(50) format(%6.4f)


di as result "*** SIMAN GRAPHS HAVE PASSED ALL THE TESTS IN `filename'.do ***"

log close
