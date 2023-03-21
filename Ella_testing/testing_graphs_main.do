* Testing all siman programs and graphs with different data formats
* NOTE: need to add testing for trellis an nestloop at the end as different data formats

clear all
prog drop _all
which siman_setup
cd C:\git\siman\Ella_testing\data\


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

use simlongESTPM_longE_longM.dta, clear
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)
* graphs
siman_scatter, ytitle("test y-title") xtitle("test x-title") name("scatter_test1") 

siman_swarm, graphoptions(ytitle("test y-title") xtitle("test x-title")) combinegraphoptions(name("swarm_test1", replace)) 

siman_zipplot, scheme(scheme(s2color)) legend(order(4 "Carrot" 3 "Stalk")) xtit("x-title") ytit("y-title") ylab(0 40 100) noncoveroptions(pstyle(p3)) ///
coveroptions(pstyle(p4)) scatteroptions(mcol(grey%50)) truegraphoptions(pstyle(p6)) name("zipplot_test1")

siman_comparemethodsscatter, title("testtitle") subgr(xtit("testaxis")) name("cms_test1") 

siman_blandaltman, ytitle("test y-title") xtitle("test x-title") name("ba_test1") 

siman analyse

siman_lollyplot, gr(xtitle("test x-title") ytitle("test y-title")) name("lollyplot_test1")


* DGM numeric with string labels, 1 var
*****************************************
* target wide and numeric with string labels, method wide and string, true value
clear all
use simlongESTPM_longE_longM.dta, clear
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
siman_setup, rep(rep) dgm(dgm) target(1 2) method(A B) estimate(est) se(se) true(0) order(method)
* has made target string
 
* graphs
siman_scatter, ytitle("test y-title") xtitle("test x-title") name("scatter_test2") 

siman_swarm, graphoptions(ytitle("test y-title") xtitle("test x-title")) combinegraphoptions(name("swarm_test2", replace)) 

siman_zipplot, scheme(scheme(s2color)) legend(order(4 "Carrot" 3 "Stalk")) xtit("x-title") ytit("y-title") ylab(0 40 100) noncoveroptions(pstyle(p3)) ///
coveroptions(pstyle(p4)) scatteroptions(mcol(grey%50)) truegraphoptions(pstyle(p6)) name("zipplot_test2")

siman_comparemethodsscatter, title("testtitle") subgr(xtit("testaxis")) name("cms_test2") 

siman_blandaltman, ytitle("test y-title") xtitle("test x-title") name("ba_test2")        
/////////////////////////////// NOT WORKING //////////////

siman analyse

siman_lollyplot, gr(xtitle("test x-title") ytitle("test y-title")) name("lollyplot_test2")

 
* DGM string, 1 var
********************
* target and method long numeric string labels, true missing
clear all
use simlongESTPM_longE_longM.dta, clear
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

siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) 
* graphs
siman_scatter, ytitle("test y-title") xtitle("test x-title") name("scatter_test3") 

siman_swarm, graphoptions(ytitle("test y-title") xtitle("test x-title")) combinegraphoptions(name("swarm_test3", replace)) 

cap siman_zipplot, scheme(scheme(s2color)) legend(order(4 "Carrot" 3 "Stalk")) xtit("x-title") ytit("y-title") ylab(0 40 100) noncoveroptions(pstyle(p3)) ///
coveroptions(pstyle(p4)) scatteroptions(mcol(grey%50)) truegraphoptions(pstyle(p6)) name("zipplot_test3")
assert _rc == 498
* siman zipplot can not be run w/o true value as required

siman_comparemethodsscatter, title("testtitle") subgr(xtit("testaxis")) name("cms_test3") 

siman_blandaltman, ytitle("test y-title") xtitle("test x-title") name("ba_test3") 

siman analyse

siman_lollyplot, gr(xtitle("test x-title") ytitle("test y-title")) name("lollyplot_test3")
 
 
* DGM missing
************** 
* Target numeric, method missing, true > 1 level (different true values per target)
clear all
use simlongESTPM_longE_longM.dta, clear
replace true=0.5 if estimand=="beta"
drop method dgm
gen estimand_num = .
replace estimand_num = 1 if estimand == "beta"
replace estimand_num = 2 if estimand == "gamma"
drop estimand
rename estimand_num estimand
bysort rep estimand: gen repitionindi=_n
drop if repitionindi>1
drop repitionindi
siman_setup, rep(rep) target(estimand) estimate(est) se(se) true(true)

* graphs
siman_scatter, ytitle("test y-title") xtitle("test x-title") name("scatter_test4") 

cap siman_swarm, graphoptions(ytitle("test y-title") xtitle("test x-title")) combinegraphoptions(name("swarm_test4", replace)) 
assert _rc == 498
* siman swarm can not be run without method as required

siman_zipplot, scheme(scheme(s2color)) legend(order(4 "Carrot" 3 "Stalk")) xtit("x-title") ytit("y-title") ylab(0 40 100) noncoveroptions(pstyle(p3)) ///
coveroptions(pstyle(p4)) scatteroptions(mcol(grey%50)) truegraphoptions(pstyle(p6)) name("zipplot_test4")    
/////////////////////////////// NOT WORKING //////////////

cap siman_comparemethodsscatter, title("testtitle") subgr(xtit("testaxis")) name("cms_test4") 
assert _rc == 498
* siman cms can not be run without method as required

cap siman_blandaltman, ytitle("test y-title") xtitle("test x-title") name("ba_test4") 
assert _rc == 498
* siman bland altman can not be run without method as required

cap siman analyse
assert _rc == 498
* siman analyse can not be run without method as required


* now try with missing target
clear all
use simlongESTPM_longE_longM.dta, clear
drop estimand
bysort rep dgm method: gen repitionindi=_n
drop if repitionindi == 2
drop repitionindi
siman_setup, rep(rep) dgm(dgm) method(method) estimate(est) se(se) true(true)
 
* graphs
siman_scatter, ytitle("test y-title") xtitle("test x-title") name("scatter_test5") 

siman_swarm, graphoptions(ytitle("test y-title") xtitle("test x-title")) combinegraphoptions(name("swarm_test5", replace)) 

siman_zipplot, scheme(scheme(s2color)) legend(order(4 "Carrot" 3 "Stalk")) xtit("x-title") ytit("y-title") ylab(0 40 100) noncoveroptions(pstyle(p3)) ///
coveroptions(pstyle(p4)) scatteroptions(mcol(grey%50)) truegraphoptions(pstyle(p6)) name("zipplot_test5")

siman_comparemethodsscatter, title("testtitle") subgr(xtit("testaxis")) name("cms_test5") 

siman_blandaltman, ytitle("test y-title") xtitle("test x-title") name("ba_test5") 

siman analyse

siman_lollyplot, gr(xtitle("test x-title") ytitle("test y-title")) name("lollyplot_test5")
 
 

* more than 3 methods for plots, methlist option
****************************************************
cd C:\git\siman\Ella_testing\data\
use bvsim_all_out.dta, clear
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
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target)
siman_comparemethodsscatter, methlist(3 7) name("cms_test6") 
siman_blandaltman, methlist(3 7) name("ba_test6")

 
  
**********************************************************
* DGM defined by multiple variables with multiple levels
**********************************************************

clear all
prog drop _all
cd N:\My_files\siman\GertaRucker\12874_2014_1136_MOESM1_ESM\
use res.dta, clear
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
siman_setup, rep(v1) dgm(theta rho pc k) method(peto g2) estimate(exp) se(var2) true(theta)

* graphs
siman_scatter, ytitle("test y-title") xtitle("test x-title") name("scatter_test7") 

siman_swarm, graphoptions(ytitle("test y-title") xtitle("test x-title")) combinegraphoptions(name("swarm_test7", replace)) 

siman_zipplot, scheme(scheme(s2color)) legend(order(4 "Carrot" 3 "Stalk")) xtit("x-title") ytit("y-title") ylab(0 40 100) noncoveroptions(pstyle(p3)) ///
coveroptions(pstyle(p4)) scatteroptions(mcol(grey%50)) truegraphoptions(pstyle(p6)) name("zipplot_test7")

siman_comparemethodsscatter, title("testtitle") subgr(xtit("testaxis")) name("cms_test7") 

siman_blandaltman, ytitle("test y-title") xtitle("test x-title") name("ba_test7") 

siman analyse

siman_lollyplot, gr(xtitle("test x-title") ytitle("test y-title")) name("lollyplot_test7")

siman_nestloop mean, dgmorder(-theta rho -pc -k) ylabel(0.2 0.5 1) ytitle("Odds ratio") name("nestloop_test7")





       