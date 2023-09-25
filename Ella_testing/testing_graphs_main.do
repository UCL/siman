/*****************************************************************
Testing all siman programs and graphs with different data formats
NOTE: to be run in "Ella_testing" folder
Ella 21mar2023
Latest update Ian 22aug2023
23aug2023 temporarily commented out all -siman cms- (slow and failing)
*****************************************************************/

// SETUP: MODIFY FOR USER & PROJECT
local codepath C:\ian\git\siman\ // for Ian
local codepath C:\git\siman\ // for Ella

// SETUP FOR ALL USERS
local testpath `codepath'Ella_testing\
local filename testing_graphs_main
prog drop _all
adopath ++ `codepath '
cd `testpath'
cap log close
set linesize 100


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


* DGM numeric, 1 var
*********************
* target long and string, method long and numeric, true variable 1 level
use data/simlongESTPM_longE_longM.dta, clear
siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)
siman comparemethodsscatter if estimand=="beta" & dgm==2
* graphs
siman scatter, ytitle("test y-title") xtitle("test x-title") name("scatter_test1", replace) 

siman swarm, graphoptions(ytitle("test y-title") xtitle("test x-title") name("swarm_test1", replace)) 

siman zipplot, scheme(scheme(s2color)) legend(order(3 "Carrot" 4 "Stalk")) xtit("x-title") ytit("y-title") ylab(0 40 100) noncoveroptions(pstyle(p3)) ///
coveroptions(pstyle(p4)) scatteroptions(mcol(gray%50)) truegraphoptions(pstyle(p6)) name("zipplot_test1", replace)

siman comparemethodsscatter, title("testtitle") subgr(xtit("testaxis")) name("cms_test1", replace) 

siman blandaltman, ytitle("test y-title") xtitle("test x-title") name("ba_test1", replace) 

siman analyse

siman lollyplot, xtitle("test x-title") ytitle("test y-title") name("lollyplot_test1", replace)


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
reshape wide est se, i(rep dgm estimand) j(method, string)
reshape wide estA estB seA seB, i(rep dgm) j(estimand)
siman setup, rep(rep) dgm(dgm) target(1 2) method(A B) estimate(est) se(se) true(0) order(method)
* has made target string
 
* graphs
siman scatter, ytitle("test y-title") xtitle("test x-title") name("scatter_test2", replace) 

siman swarm, graphoptions(ytitle("test y-title") xtitle("test x-title") name("swarm_test2", replace)) 

siman zipplot, scheme(scheme(s2color)) legend(order(3 "Carrot" 4 "Stalk")) xtit("x-title") ytit("y-title") ylab(0 40 100) noncoveroptions(pstyle(p3)) ///
coveroptions(pstyle(p4)) scatteroptions(mcol(gray%50)) truegraphoptions(pstyle(p6)) name("zipplot_test2", replace)

siman comparemethodsscatter, title("testtitle") subgr(xtit("testaxis")) name("cms_test2", replace) 

siman blandaltman, ytitle("test y-title") xtitle("test x-title") name("ba_test2", replace)        

siman analyse                                 

siman lollyplot, xtitle("test x-title") ytitle("test y-title") name("lollyplot_test2", replace)

 
* DGM string, 1 var
********************
* target and method long numeric string labels, true missing
use data/simlongESTPM_longE_longM.dta, clear
encode estimand, gen(estimand_num)
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
* graphs
siman scatter, ytitle("test y-title") xtitle("test x-title") name("scatter_test3", replace) 

siman swarm, graphoptions(ytitle("test y-title") xtitle("test x-title") name("swarm_test3", replace)) 

cap siman zipplot, scheme(scheme(s2color)) legend(order(3 "Carrot" 4 "Stalk")) xtit("x-title") ytit("y-title") ylab(0 40 100) noncoveroptions(pstyle(p3)) ///
coveroptions(pstyle(p4)) scatteroptions(mcol(gray%50)) truegraphoptions(pstyle(p6)) name("zipplot_test3", replace)
assert _rc == 498
* siman zipplot can not be run w/o true value as required

siman comparemethodsscatter, title("testtitle") subgr(xtit("testaxis")) name("cms_test3", replace) 

siman blandaltman, ytitle("test y-title") xtitle("test x-title") name("ba_test3", replace) 

siman analyse

siman lollyplot, xtitle("test x-title") ytitle("test y-title") name("lollyplot_test3", replace)
 
 
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

* graphs
siman scatter, ytitle("test y-title") xtitle("test x-title") name("scatter_test4", replace) 

cap siman swarm, graphoptions(ytitle("test y-title") xtitle("test x-title") name("swarm_test4", replace)) 
assert _rc == 498
* siman swarm can not be run without method as required

siman zipplot, scheme(scheme(s2color)) legend(order(3 "Carrot" 4 "Stalk")) xtit("x-title") ytit("y-title") ylab(0 40 100) noncoveroptions(pstyle(p3)) ///
coveroptions(pstyle(p4)) scatteroptions(mcol(gray%50)) truegraphoptions(pstyle(p6)) name("zipplot_test4", replace)    

cap siman comparemethodsscatter, title("testtitle") subgr(xtit("testaxis")) name("cms_test4", replace) 
assert _rc == 498
* siman cms can not be run without method as required

cap siman blandaltman, ytitle("test y-title") xtitle("test x-title") name("ba_test4", replace) 
assert _rc == 498
* siman bland altman can not be run without method as required

* Target numeric, method numeric, true > 1 level (different true values per target)
clear all
prog drop _all
use data/simlongESTPM_longE_longM.dta, clear
* need to alter data set so have 2 values of true corresponding to 2 estimands,
* and a complete method set for each of these. 
replace true=0.5 if estimand=="beta"
gen estimand_num = .
replace estimand_num = 1 if estimand == "beta"
replace estimand_num = 2 if estimand == "gamma"
drop estimand
*drop if dgm == 2
rename estimand_num estimand
siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)

siman scatter
siman swarm
siman zipplot
siman comparemethodsscatter
siman blandaltman


* now try with missing target
use data/simlongESTPM_longE_longM.dta, clear
drop estimand
bysort rep dgm method: gen repitionindi=_n
drop if repitionindi == 2
drop repitionindi
siman setup, rep(rep) dgm(dgm) method(method) estimate(est) se(se) true(true)
 
* graphs
siman scatter, ytitle("test y-title") xtitle("test x-title") name("scatter_test5", replace) 

siman swarm, graphoptions(ytitle("test y-title") xtitle("test x-title") name("swarm_test5", replace)) 

siman zipplot, scheme(scheme(s2color)) legend(order(3 "Carrot" 4 "Stalk")) xtit("x-title") ytit("y-title") ylab(0 40 100) noncoveroptions(pstyle(p3)) ///
coveroptions(pstyle(p4)) scatteroptions(mcol(gray%50)) truegraphoptions(pstyle(p6)) name("zipplot_test5", replace)

siman comparemethodsscatter, title("testtitle") subgr(xtit("testaxis")) name("cms_test5", replace) 

siman blandaltman, ytitle("test y-title") xtitle("test x-title") name("ba_test5", replace) 

siman analyse

siman lollyplot, xtitle("test x-title") ytitle("test y-title") name("lollyplot_test5")
 
 

* more than 3 methods for plots, methlist option
****************************************************
clear all
prog drop _all
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

siman setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target)
siman comparemethodsscatter, methlist(3 7) name("cms_test6", replace) 
siman comparemethodsscatter, methlist(3 5 7) name("cms_test6a", replace) 
siman comparemethodsscatter if target=="beta" & dgm==1
siman comparemethodsscatter if target=="beta" & dgm==1, methlist(1 2 3) 
siman_blandaltman, methlist(3 7) name("ba_test6", replace)
 
  
**********************************************************
* DGM defined by multiple variables with multiple levels
**********************************************************
clear all
prog drop _all
use nestloop/res.dta, clear
keep v1 theta rho pc k exppeto expg2 var2peto var2g2
* theta needs to be in integer format for levelsof command to work (doesn't accept non-integer values), so make integer values with non-integer labels
gen theta_new=2
replace theta_new=1 if theta == 0.5
replace theta_new=3 if theta == 0.75
replace theta_new=4 if theta == 1 
label define theta_new 1 "0.5" 2 "0.67" 3 "0.75" 4 "1"
label values theta_new theta_new
label var theta_new "theta categories"
*br theta theta_new
drop theta
rename theta_new theta
gen pc_str = ""
replace pc_str = "5%" if pc == 1
replace pc_str = "10%" if pc == 2
replace pc_str = "20%" if pc == 3
replace pc_str = "30%" if pc == 4
drop pc
rename pc_str pc
siman setup, rep(v1) dgm(theta rho pc k) method(peto g2) estimate(exp) se(var2) true(theta)

* graphs
siman scatter, ytitle("test y-title") xtitle("test x-title") name("scatter_test7", replace) 

siman swarm, graphoptions(ytitle("test y-title") xtitle("test x-title") name("swarm_test7", replace)) 

siman zipplot, scheme(scheme(s2color)) legend(order(3 "Carrot" 4 "Stalk")) xtit("x-title") ytit("y-title") ylab(0 40 100) noncoveroptions(pstyle(p3)) ///
coveroptions(pstyle(p4)) scatteroptions(mcol(gray%50)) truegraphoptions(pstyle(p6)) name("zipplot_test7", replace)

siman comparemethodsscatter, title("testtitle") subgr(xtit("testaxis")) name("cms_test7", replace) 

siman blandaltman, ytitle("test y-title") xtitle("test x-title") name("ba_test7", replace) 

siman analyse

siman lollyplot if k==5, xtitle("test x-title") name("lollyplot_test7", replace)
* without -if k==5- you get "too many sersets" error

siman nestloop mean, dgmorder(-theta rho -pc -k) ylabel(0.2 0.5 1) ytitle("Odds ratio") name("nestloop_test7", replace)



di as result "*** SIMAN GRAPHS HAVE PASSED ALL THESE TESTS ***"

log close
