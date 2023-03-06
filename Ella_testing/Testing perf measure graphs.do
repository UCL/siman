* Testing performance measure graph options

clear all
prog drop _all

use data/simlongESTPM_longE_longM.dta, clear
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)
siman_analyse

* siman_lollyplot
siman_lollyplot
siman_lollyplot if estimand=="beta"
siman_lollyplot, scheme(economist) title("New title")
siman_lollyplot modelse power cover
siman_lollyplot, gr(xtitle("New title"))
siman_lollyplot, scheme(economist) title("New title") name("test")
siman_lollyplot, name("newtest")
 
* more than 3 methods for plots

use data/bvsim_all_out.dta, clear
rename _dnum dnum
drop simno hazard hazcens shape cens pmcar n truebeta truegamma corr mdm
drop if _n>100
reshape long beta_ sebeta_ gamma_ segamma_, i(dnum) j(method)
rename beta_ estbeta
rename sebeta_ sebeta
rename gamma_ estgamma
rename segamma_ segamma
reshape long est se, i(dnum method) j(target "beta" "gamma")
gen dgm = 1
expand 2, gen(dupindicator)
replace dgm=2 if dupindicator==1
drop dupindicator
*drop if method>4
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target)
siman_analyse
siman_lollyplot


use data/bvsim_all_out.dta, clear
rename _dnum dnum
drop simno hazard hazcens shape cens pmcar n truebeta truegamma corr mdm
drop if _n>100
reshape long beta_ sebeta_ gamma_ segamma_, i(dnum) j(method)
rename beta_ estbeta
rename sebeta_ sebeta
rename gamma_ estgamma
rename segamma_ segamma
reshape long est se, i(dnum method) j(target "beta" "gamma")
gen dgm=1
expand 2, gen(dupindicator)
replace dgm=2 if dupindicator==1
drop dupindicator
*drop if method>4
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target)
siman_analyse
siman_lollyplot

* String variable method

use data/simlongESTPM_wideE_wideM4.dta, clear
siman_setup, rep(rep) dgm(dgm) target(beta gamma) method(A_ B_) estimate(est) se(se) true(true) order(method)
siman_analyse
siman_lollyplot
* create a dataset with more than 3 string method variables
clear all

use data/bvsim_all_out.dta, clear
rename _dnum dnum
drop simno hazard hazcens shape cens pmcar n truebeta truegamma corr mdm
drop if _n>100
reshape long beta_ sebeta_ gamma_ segamma_, i(dnum) j(method)
rename beta_ estbeta
rename sebeta_ sebeta
rename gamma_ estgamma
rename segamma_ segamma
reshape long est se, i(dnum method) j(target "beta" "gamma")
gen dgm=1
expand 2, gen(dupindicator)
replace dgm=2 if dupindicator==1
drop dupindicator
drop if method>4
gen method_string = "A"
replace method_string = "B" if method == 2
replace method_string = "C" if method == 3
replace method_string = "D" if method == 4
drop method
rename method_string method
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target)
siman_analyse
siman_lollyplot   

clear all
prog drop _all
use data/n500type1.dta, clear
*append using from_Tim_trellis\n500type2.dta   NEEDS TARGET
* there are 12 methods so just keep a few for the example
keep if method =="CC" | method=="LRD1" | method=="PMM1"
qui gen se = sqrt(var)
gen dgm = 0
replace dgm = 1 if mechanism == "marw"
replace dgm = 2 if mechanism == "mcar"
label define dgmlabelvalues 0 "mars" 1 "marw" 2 "mcar"
label values dgm dgmlabelvalues
drop mechanism
siman_setup, rep(repno) dgm(beta dgm) method(method) estimate(b) se(se) df(df) true(beta)
siman_analyse
siman_trellis bias
siman_trellis bias ciwidth  
siman_trellis cover 
siman_trellis, scheme(economist) ytitle("test y-title") xtitle("test x-title") bygraphoptions(title("main-title")) 
siman_trellis, scheme(economist) ytitle("test y-title") xtitle("test x-title") bygraphoptions(title("main-title")) name("test")


* test error messages
use data/n500type1.dta, clear
keep if method =="CC" | method=="LRD1" | method=="PMM1"
qui gen se = sqrt(var)
drop auroc
sort rep mechanism beta method
keep if beta == 3
gen dgm = 0
replace dgm = 1 if mechanism == "marw"
replace dgm = 2 if mechanism == "mcar"
label define dgmlabelvalues 0 "mars" 1 "marw" 2 "mcar"
label values dgm dgmlabelvalues
drop mechanism
siman_setup, rep(repno) dgm(dgm) method(method) estimate(b) se(se) df(df) true(beta)
siman_analyse
replace beta = 3 if beta ==.
cap siman_trellis 
if _rc di "error message as required (true not included in dgm())"
else exit

clear all
prog drop _all

use data/n500type1.dta, clear
keep if method =="CC" | method=="LRD1" | method=="PMM1"
qui gen se = sqrt(var)
gen dgm = 0
replace dgm = 1 if mechanism == "marw"
replace dgm = 2 if mechanism == "mcar"
label define dgmlabelvalues 0 "mars" 1 "marw" 2 "mcar"
label values dgm dgmlabelvalues
drop mechanism
drop auroc
keep if dgm == 2
keep if beta == 3
siman_setup, rep(repno) dgm(dgm) method(method) estimate(b) se(se) df(df) true(beta)
siman_analyse
replace beta = 3 if beta ==.
cap siman_trellis 
if _rc di " error message as required (only 1 dgm)"
else exit

* Testing string dgm input (auto encoded to numeric with Tim's code)
**********************************************************************
clear all
prog drop _all
which siman_setup

use data/simlongESTPM_longE_longM.dta, clear
gen dgm_string = "1"
replace dgm_string = "2" if dgm == 2
drop dgm
siman_setup, rep(rep) dgm(dgm_string) target(estimand) method(method) estimate(est) se(se) true(true)
siman_analyse
siman lollyplot

clear all
prog drop _all

use data/n500type1.dta, clear
*append using from_Tim_trellis\n500type2.dta   NEEDS TARGET
* there are 12 methods so just keep a few for the example
keep if method =="CC" | method=="LRD1" | method=="PMM1"
qui gen se = sqrt(var)
siman_setup, rep(repno) dgm(beta mechanism) method(method) estimate(b) se(se) df(df) true(beta)
siman_analyse
siman_trellis 

