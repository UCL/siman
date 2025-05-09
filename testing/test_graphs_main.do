/*****************************************************************
Testing all siman programs and graphs with different data formats
NOTE: to be run in "testing" folder
Ella 21mar2023
Latest update Ian 22aug2023
23aug2023 temporarily commented out all -siman cms- (slow and failing)
20dec2023 removed 2 instances of non-reproducible record selection
3apr2024  removed tests with excessive numbers of graphs and panels: 
			reduced from 40 to 2 minutes
28/10/2024 IW rename testing_graphs_main -> test_graphs_main
*****************************************************************/

* switch on detail if want to run all graphs
global detail 1

local filename test_graphs_main

prog drop _all
cd $testpath
cap log close
set linesize 100
clear all // avoids the "too many sersets" error

// START TESTING
log using `filename'_which, replace text
version
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


* DGM numeric, 1 var
*********************
* target long and string, method long and numeric, true variable 1 level
use $testpath/data/simlongESTPM_longE_longM.dta, clear
siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)
siman comparemethodsscatter if estimand=="beta" & dgm==2
* graphs
siman scatter, ytitle("test y-title") xtitle("test x-title") name("scatter_test1", replace) 

siman swarm, graphoptions(ytitle("test y-title") xtitle("test x-title")) name("swarm_test1", replace)

siman zipplot, bygr(cols(4))
siman zipplot, legend(order(1 "Stalk" 2 "Carrot")) xtit("x-title") ylab(95) noncoveroptions(pstyle(p3)) ///
    coveroptions(pstyle(p4)) scatteroptions(mcol(gray%50)) truegraphoptions(pstyle(p6)) ///
    bygr(cols(4)) name("zipplot_test1", replace) ymin(60)

siman comparemethodsscatter, title("testtitle") subgr(xtit("testaxis")) name("cms_test1", replace) 

siman blandaltman, ytitle("test y-title") xtitle("test x-title") name("ba_test1", replace) 

siman analyse
siman table, tabdisp

siman lollyplot, xtitle("test x-title") ytitle("test y-title") name("lollyplot_test1", replace)


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
reshape wide est se, i(rep dgm estimand) j(method, string)
reshape wide estA estB seA seB, i(rep dgm) j(estimand)
siman setup, rep(rep) dgm(dgm) target(1 2) method(A B) estimate(est) se(se) true(0) order(method)
* has made target string
 
* graphs
siman scatter, ytitle("test y-title") xtitle("test x-title") name("scatter_test2", replace) 

siman swarm, graphoptions(ytitle("test y-title") xtitle("test x-title")) name("swarm_test2", replace)

siman zipplot, legend(order(1 "Stalk" 2 "Carrot")) xtit("x-title") ytit("y-title") ylab(0 40 100) noncoveroptions(pstyle(p3)) ///
coveroptions(pstyle(p4)) scatteroptions(mcol(gray%50)) truegraphoptions(pstyle(p6)) name("zipplot_test2", replace)

siman comparemethodsscatter, title("testtitle") subgr(xtit("testaxis")) name("cms_test2", replace) 

siman blandaltman, ytitle("test y-title") xtitle("test x-title") name("ba_test2", replace)        

siman analyse
siman table, tabdisp

siman lollyplot, xtitle("test x-title") ytitle("test y-title") name("lollyplot_test2", replace)

 
* DGM string, 1 var
********************
* target and method long numeric string labels, true missing
use $testpath/data/simlongESTPM_longE_longM.dta, clear
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

siman swarm, graphoptions(ytitle("test y-title") xtitle("test x-title")) name("swarm_test3", replace)

cap siman zipplot, legend(order(1 "Stalk" 2 "Carrot")) xtit("x-title") ytit("y-title") ylab(0 40 100) noncoveroptions(pstyle(p3)) ///
coveroptions(pstyle(p4)) scatteroptions(mcol(gray%50)) truegraphoptions(pstyle(p6)) name("zipplot_test3", replace)
assert _rc == 498
* siman zipplot can not be run w/o true value as required

siman comparemethodsscatter, title("testtitle") subgr(xtit("testaxis")) name("cms_test3", replace) 

siman blandaltman, ytitle("test y-title") xtitle("test x-title") name("ba_test3", replace) 

siman analyse
siman table, tabdisp

siman lollyplot, xtitle("test x-title") ytitle("test y-title") name("lollyplot_test3", replace)
 
 
* DGM missing
************** 
* Target numeric, method missing, true > 1 level (different true values per target)
use $testpath/data/simlongESTPM_longE_longM.dta, clear
replace true=0.5 if estimand=="beta"
keep if dgm==1 & method==1 // new 20dec2023 - reproducibly selects records
drop dgm method
gen estimand_num = .
replace estimand_num = 1 if estimand == "beta"
replace estimand_num = 2 if estimand == "gamma"
drop estimand
rename estimand_num estimand
*bysort rep estimand: gen repitionindi=_n
*drop if repitionindi>1 // pre 20dec2023 non-reproducibly selects records
*drop repitionindi
siman setup, rep(rep) target(estimand) estimate(est) se(se) true(true)

* graphs
siman scatter, ytitle("test y-title") xtitle("test x-title") name("scatter_test4", replace) 

siman zipplot, legend(order(3 "Carrot" 4 "Stalk")) xtit("x-title") ytit("y-title") noncoveroptions(pstyle(p3)) ///
coveroptions(pstyle(p4)) scatteroptions(mcol(gray%50)) truegraphoptions(pstyle(p6)) name("zipplot_test4", replace)    

cap siman comparemethodsscatter, title("testtitle") subgr(xtit("testaxis")) name("cms_test4", replace) 
assert _rc == 498
* siman cms can not be run without method as required

cap siman blandaltman, ytitle("test y-title") xtitle("test x-title") name("ba_test4", replace) 
assert _rc == 498
* siman bland altman can not be run without method as required


* now try with missing target
use $testpath/data/simlongESTPM_longE_longM.dta, clear
keep if estimand=="beta" // new 20dec2023 - reproducibly selects records
drop estimand
*bysort rep dgm method: gen repitionindi=_n
*drop if repitionindi == 2 // pre 20dec2023 non-reproducibly selects records
*drop repitionindi
siman setup, rep(rep) dgm(dgm) method(method) estimate(est) se(se) true(true)
 
* graphs
siman scatter, ytitle("test y-title") xtitle("test x-title") name("scatter_test5", replace) 

siman swarm, graphoptions(ytitle("test y-title") xtitle("test x-title")) name("swarm_test5", replace)

siman zipplot, legend(order(1 "Stalk" 2 "Carrot")) xtit("x-title") ytit("y-title") ylab(0 40 100) noncoveroptions(pstyle(p3)) ///
coveroptions(pstyle(p4)) scatteroptions(mcol(gray%50)) truegraphoptions(pstyle(p6)) name("zipplot_test5", replace)

siman comparemethodsscatter, title("testtitle") subgr(xtit("testaxis")) name("cms_test5", replace) 

siman blandaltman, ytitle("test y-title") xtitle("test x-title") name("ba_test5", replace) 

siman analyse
siman table, tabdisp

siman lollyplot, xtitle("test x-title") ytitle("test y-title") name("lollyplot_test5")
 
 
* dgm has missing values AND method labels have spaces
use $testpath/data/simlongESTPM_longE_longM.dta, clear
replace dgm=. if dgm==2
label def mymethod 1 "First method" 2 "Method, second"
label val method mymethod
siman setup, rep(rep) target(esti) dgm(dgm) method(method) estimate(est) se(se) true(true) dgmmissingok
 
siman scatter, ytitle("test y-title") xtitle("test x-title") name("scatter_test5a", replace) 

siman swarm, graphoptions(ytitle("test y-title") xtitle("test x-title")) name("swarm_test5a", replace)

siman zipplot, legend(order(1 "Stalk" 2 "Carrot")) xtit("x-title") ytit("y-title") ylab(0 40 100) noncoveroptions(pstyle(p3)) ///
coveroptions(pstyle(p4)) scatteroptions(mcol(gray%50)) truegraphoptions(pstyle(p6)) name("zipplot_test5a", replace)

siman comparemethodsscatter if estimand=="beta", title("testtitle") subgr(xtit("testaxis")) name("cms_test5a", replace) 

siman blandaltman if estimand=="beta", ytitle("test y-title") xtitle("test x-title") name("ba_test5a", replace) 

siman analyse
siman table, tabdisp

siman lollyplot, xtitle("test x-title") ytitle("test y-title") name("lollyplot_test5a", replace)



* more than 3 methods for plots, methlist option
****************************************************
clear all
prog drop _all
use $testpath/data/bvsim_all_out.dta, clear
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
siman comparemethodsscatter if target=="beta" & dgm==1, methlist(3 7) name("cms_test6", replace) 
siman comparemethodsscatter if target=="beta" & dgm==1, methlist(3/7) combine name("cms_test6a", replace) 
siman comparemethodsscatter if target=="beta" & dgm==1
siman_blandaltman, methlist(3/7) name("ba_test6", replace)

 
  
**********************************************************
* DGM defined by multiple variables with multiple levels
* The data have 5 dgmvars, 
*   but one (tau2) is ignored in the code below
**********************************************************
clear all
prog drop _all
use data/res.dta, clear
keep v1 theta rho pc k exppeto expg2 var2peto var2g2 tau2
siman setup, rep(v1) dgm(theta rho pc k tau2) method(peto g2) estimate(exp) se(var2) true(theta)

* graphs
local useit4 theta==1 & rho==1 & k==5 // flags just 4 dgms
local useit1 theta==1 & rho==1 & pc==1 & k==5 // flags just 1 dgm
siman scatter if `useit4', ytitle("test y-title") xtitle("test x-title") name("scatter_test7", replace) 

siman swarm if `useit4', graphoptions(ytitle("test y-title") xtitle("test x-title")) name("swarm_test7", replace)

* siman zipplot is not appropriate for these data

serset clear
if ${detail} == 1 siman comparemethodsscatter if `useit1', title("testtitle") subgr(xtit("testaxis")) name("cms_test7", replace) 
* this sometimes fails with error 111 "series 0 not found" from -graph combine-

if ${detail} == 1 siman blandaltman if `useit1', ytitle("test y-title") xtitle("test x-title") name("ba_test7", replace) 

siman analyse, force

siman lollyplot if `useit4', xtitle("test x-title") name("lollyplot_test7", replace)
* without -if k==5- you get "too many sersets" error

siman nestloop mean, dgmorder(-theta rho -pc -k tau2) ylabel(0.2 0.5 1) ytitle("Odds ratio") name("nestloop_test7", replace)


/*
* Testing warning messages correspond to the number of panels/graphs that will be printed
* VERY LONG

clear all
prog drop _all
use $testpath/data/extendedtestdata.dta, clear
order beta pmiss

* create a string dgm var as well for testing
gen betastring = "0"
replace betastring = "0.25" if beta == 2
replace betastring = "0.5" if beta == 3
drop beta
rename betastring beta

siman_setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) true(betatrue)

* scatter
siman scatter
siman scatter if method == "CCA"
siman scatter if estimand == "effect"
siman scatter if mech =="MCAR": mech
	* this means the value whose label is "MCAR" in the value label mech

siman scatter, by(pmiss)
siman scatter, by(estimand)
siman scatter, by(method)

* swarm, requires 2 methods
siman swarm
siman swarm if (method == "CCA" | method == "MeanImp")
siman swarm if estimand == "effect"
siman swarm if mech =="MCAR": mech

siman swarm, by(pmiss)
siman swarm, by(estimand)

* blandaltman
siman blandaltman
siman blandaltman if estimand == "effect"
siman blandaltman if mech =="MCAR": mech

siman blandaltman, by(pmiss)

siman blandaltman, methlist(Noadj MeanImp)

* comparemethodsscatter
siman comparemethodsscatter
siman comparemethodsscatter if estimand == "effect"
siman comparemethodsscatter if mech =="MCAR": mech

siman comparemethodsscatter, methlist(Noadj MeanImp)

* zipplot
siman zipplot
siman zipplot if method == "CCA" 
siman zipplot if estimand == "effect"
siman zipplot if mech =="MCAR": mech

siman zipplot, by(pmiss)
siman zipplot, by(method)
*/


di as result "*** SIMAN GRAPHS HAVE PASSED ALL THE TESTS IN `filename'.do ***"

log close
