/* 
"Testing estimates graph.do"
Test the graphs that use estimates data (i.e. not lollyplot, nestloop)
Extensive, slow and largely redundant
IW updated 26jul2024
*/

local filename Testing estimates graphs

prog drop _all
cd $testpath
cap log close
set linesize 100

// START TESTING
log using "`filename'", replace text nomsg
siman which

use $testpath/data/simlongESTPM_longE_longM.dta, clear
siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)

* siman scatter
siman scatter, ytitle("test y-title") xtitle("test x-title") name("test", replace) 
siman scatter, ytitle("test y-title") xtitle("test x-title")     
siman scatter 
siman scatter if dgm==2, name(siman_scatter_dgm2, replace)

* siman swarm
siman swarm
siman swarm, nomean scheme(s1color) bygraphoptions(title("main-title")) graphoptions(ytitle("test y-title"))
siman swarm, scheme(economist) bygraphoptions(title("main-title")) graphoptions(ytitle("test y-title") xtitle("test x-title"))
siman swarm, graphoptions(ytitle("test y-title") xtitle("test x-title")) name(test2, replace)
siman swarm if dgm == 1   


*siman zipplot
siman zipplot
siman zipplot, by(dgm estimand method)

siman zipplot, scheme(scheme(s2color)) legend(order(3 "Carrot" 4 "Stalk")) xtit("x-title") ytit("y-title") ylab(0 40 100) noncoveroptions(pstyle(p3)) ///
coveroptions(pstyle(p4)) scatteroptions(mcol(gray%50)) truegraphoptions(pstyle(p6)) 
siman zipplot, scheme(scheme(s2color)) legend(order(3 "Carrot" 4 "Stalk")) xtit("x-title") ytit("y-title") ylab(0 40 100) noncoveroptions(pstyle(p3)) ///
coveroptions(pstyle(p4)) scatteroptions(mcol(gray%50)) truegraphoptions(pstyle(p6)) name("carrot", replace)

use $testpath/data/simlongESTPM_longE_longM.dta, clear
drop true
gen true = -0.5
siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)
siman zipplot


* Check dgm labels when dgm numeric with string labels
clear all
prog drop _all
use $testpath/data/simlongESTPM_longE_longM.dta, clear
label define dgmvar 1 "A" 2 "B"
label values dgm dgmvar
label define methodvar 1 "X" 2 "Y_"
label values method methodvar
siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)
siman scatter                  
siman zipplot                  
siman swarm                   
graph drop _all
siman comparemethodsscatter 
siman blandaltman  
* check works ok
siman analyse


* Different true values per target
use $testpath/data/simlongESTPM_longE_longM.dta, clear
replace true=0.5 if estimand=="beta"
siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)
siman zipplot  
siman zipplot, scheme(scheme(economist)) legend(order(4 "Covering" 3 "Not covering")) xtit("x-title") ytit("y-title") ylab(0 40 100) ///
noncoveroptions(pstyle(p3)) coveroptions(pstyle(p4)) scatteroptions(mcol(grey%50)) truegraphoptions(pstyle(p6))

* siman scatter
use $testpath/data/simlongESTPM_longE_longM.dta, clear
siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)
siman scatter
siman scatter, by(dgm)
siman scatter, by(estimand method)
siman scatter, ytitle("test y-title") xtitle("test x-title") scheme(economist) bygraphoptions(title("main-title"))
siman scatter, ytitle("test y-title") xtitle("test x-title") scheme(s2mono) by(dgm) bygraphoptions(title("main-title")) 

* siman comparemethodsscatter
graph drop _all
siman comparemethodsscatter, scheme(economist) 
* to change title in main graph
graph drop _all
siman comparemethodsscatter, title("test")
* to have subtitles in consituent graphs (looks messy, but just for testing)
graph drop _all
siman comparemethodsscatter, subgr(xtit("test"))
graph drop _all
siman comparemethodsscatter, name("test", replace)     
graph drop _all
siman comparemethodsscatter, title("testtitle") subgr(xtit("testaxis")) name("test", replace)    

clear all
prog drop _all
* more than 3 methods for plots
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
*drop if method>4
siman setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target)
graph drop _all
siman comparemethodsscatter
graph drop _all
siman comparemethodsscatter, by(target)  
siman blandaltman se
siman blandaltman, by(dgm)   
siman blandaltman if target == "gamma"                     
siman blandaltman, bygraphoptions(norescale)
siman blandaltman, methlist(2 8)
siman blandaltman, methlist(3 7) by(dgm)  
siman blandaltman, methlist(10 4 8)
siman blandaltman, methlist(2 9 3)                
siman blandaltman
siman blandaltman, ytitle("test y-title") xtitle("test x-title") name("yabberdabberdoo", replace) 
siman blandaltman, ytitle("test y-title") xtitle("test x-title")

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
gen dgm=1
expand 2, gen(dupindicator)
replace dgm=2 if dupindicator==1
drop dupindicator
*drop if method>4
siman setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target)
graph drop _all
siman comparemethodsscatter
graph drop _all
siman comparemethodsscatter se                             
graph drop _all
siman comparemethodsscatter est
graph drop _all
siman comparemethodsscatter, methlist(3 8) 
graph drop _all
siman comparemethodsscatter, methlist(1 3 8)                      
graph drop _all
siman comparemethodsscatter se, methlist(1 3 8 9) 
graph drop _all
siman comparemethodsscatter, methlist(1 3 8)                      
graph drop _all
siman comparemethodsscatter se, methlist(1 3 8 9) 

* method numeric labelled string variable
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
label define methodl 1 "A" 2 "B" 3 "C" 4 "D" 5 "E" 6 "F" 7 "G" 8 "H" 9 "I" 10 "J"
label values method methodl
siman setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target)
siman blandaltman, methlist(10 4 8)
siman blandaltman, methlist(2 9 3)

* String variable method
use $testpath/data/simlongESTPM_wideE_wideM4.dta, clear
siman setup, rep(rep) dgm(dgm) target(beta gamma) method(A_ B_) estimate(est) se(se) true(true) order(method)
graph drop _all
siman comparemethodsscatter 
siman blandaltman
siman blandaltman se
siman blandaltman, by(dgm)                                                                                
* To test methlist subset, create a dataset with more than 3 string method variables
clear all
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
siman setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target)
graph drop _all
siman comparemethodsscatter
graph drop _all
siman comparemethodsscatter, methlist(A C)                       
graph drop _all
siman comparemethodsscatter, methlist(B C D) 
graph drop _all
siman comparemethodsscatter, methlist(B C D)                       
siman blandaltman	
siman blandaltman, methlist(B A C)  

clear all
prog drop _all
use $testpath/data/estimates.dta, clear
gen dgmnew = 0
replace dgmnew = 1 if dgm==2
label define dgmlabelvalues 0 "y = 1" 1 "y = 1.5"
label values dgmnew dgmlabelvalues
drop dgm conv error
rename dgmnew dgm
siman setup, rep(idrep) dgm(dgm) method(method) est(theta) se(se)
siman swarm                                                         

* Combinations of #methods and #targets for testing matrix
************************************************************

* Numeric methods
*******************
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
tempfile origdata
save `origdata', replace
global origdata `origdata'

* 2 methods, true variable
drop if method>2
gen true = 0.5
siman setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman scatter
siman scatter se est
graph drop _all
siman comparemethodsscatter
siman blandaltman
siman blandaltman se
siman zipplot
siman swarm
* 3 methods, true variable
use ${origdata}, clear

drop if method>3
gen true = 0.5
siman setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman scatter
siman scatter se est
graph drop _all
siman comparemethodsscatter
siman blandaltman
siman blandaltman se
siman zipplot
siman swarm
* > 3 methods, true variable
use ${origdata}, clear
gen true = 0.5
siman setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman scatter
siman scatter se est
graph drop _all
siman comparemethodsscatter
graph drop _all
siman comparemethodsscatter se
siman blandaltman
siman blandaltman se
siman zipplot
siman swarm

* 2 methods, true value
use ${origdata}, clear
drop if method>2
siman setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)

siman scatter
siman scatter se est
graph drop _all
siman comparemethodsscatter
siman blandaltman
siman blandaltman se

siman zipplot
siman swarm
* 3 methods, true value
use ${origdata}, clear
drop if method>3
siman setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman scatter
siman scatter se est
graph drop _all
siman comparemethodsscatter
siman blandaltman
siman blandaltman se
siman zipplot
siman swarm
* > 3 methods, true value
use ${origdata}, clear
siman setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman scatter
siman scatter se est
graph drop _all
siman comparemethodsscatter
graph drop _all
siman comparemethodsscatter se
siman blandaltman
siman blandaltman se
siman zipplot
siman swarm


* String methods
*******************
clear all
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
tempfile origdata
save ${origdata}, replace
* 2 methods, true variable
drop if method == "C" | method == "D"
gen true = 0.5
siman setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman scatter
siman scatter se est
graph drop _all
siman comparemethodsscatter
siman blandaltman
siman blandaltman se
siman zipplot                                                   
siman swarm
* 3 methods, true variable
use ${origdata}, clear
drop if  method == "D"
gen true = 0.5
siman setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman scatter
siman scatter se est
graph drop _all
siman comparemethodsscatter
siman blandaltman
siman blandaltman se
siman zipplot
siman swarm
* > 3 methods, true variable
use ${origdata}, clear
gen true = 0.5
siman setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman scatter
siman scatter se est
graph drop _all
siman comparemethodsscatter
graph drop _all
siman comparemethodsscatter se
siman blandaltman
siman blandaltman se
siman zipplot
siman swarm
* 2 methods, true value
use ${origdata}, clear
drop if method == "C" | method == "D"
siman setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman scatter
siman scatter se est
graph drop _all
siman comparemethodsscatter
siman blandaltman
siman blandaltman se
siman zipplot
siman swarm
* 3 methods, true value
use ${origdata}, clear
drop if  method == "D"
siman setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman scatter
siman scatter se est
graph drop _all
siman comparemethodsscatter
siman blandaltman
siman blandaltman se
siman zipplot
siman swarm
* > 3 methods, true value
use ${origdata}, clear
siman setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman scatter
siman scatter se est
graph drop _all
siman comparemethodsscatter
graph drop _all
siman comparemethodsscatter se
siman blandaltman
siman blandaltman se
siman zipplot
siman swarm


* Numeric targets
*******************
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
gen method_new = "A" if target == "beta"
replace method_new = "B" if target == "gamma"
drop target 
rename method target
rename method_new method
tempfile origdata
save `origdata', replace
global origdata `origdata'
* 2 targets, true variable
use ${origdata}, clear
drop if  target > 2
gen true = 0.5
siman setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman scatter
siman scatter se est
graph drop _all
siman comparemethodsscatter
siman blandaltman
siman blandaltman se
siman zipplot
siman swarm
* 3 targets, true variable
use ${origdata}, clear
drop if target > 3
gen true = 0.5
siman setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman scatter
siman scatter se est
graph drop _all
siman comparemethodsscatter
siman blandaltman
siman blandaltman se
siman zipplot
siman swarm
* > 3 targets, true variable
use ${origdata}, clear
gen true = 0.5
siman setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman scatter
siman scatter se est
graph drop _all
siman comparemethodsscatter
graph drop _all
siman comparemethodsscatter se
siman blandaltman
siman blandaltman se
siman zipplot
siman swarm
* 2 targets, true value
use ${origdata}, clear
drop if  target > 2
siman setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman scatter
siman scatter se est
graph drop _all
siman comparemethodsscatter
siman blandaltman
siman blandaltman se
siman zipplot
siman swarm
* 3 targets, true value
use ${origdata}, clear
drop if target > 3
siman setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman scatter
siman scatter se est
graph drop _all
siman comparemethodsscatter
siman blandaltman
siman blandaltman se
siman zipplot
siman swarm
* > 3 targets, true value
use ${origdata}, clear
siman setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman scatter
siman scatter se est
graph drop _all
siman comparemethodsscatter
graph drop _all
siman comparemethodsscatter se
siman blandaltman
siman blandaltman se
siman zipplot
siman swarm

  
* String targets
*******************
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
gen targetnew="A" if method ==1
replace targetnew="B" if method ==2
replace targetnew="C" if method ==3
replace targetnew="D" if method ==4
replace targetnew="E" if method ==5
replace targetnew="F" if method ==6
replace targetnew="G" if method ==7
replace targetnew="H" if method ==8
replace targetnew="I" if method ==9
replace targetnew="J" if method ==10
gen methodnew= 1 if target == "beta"
replace methodnew=2 if target == "gamma"
drop method target
rename methodnew method
rename targetnew target
tempfile origdata
save `origdata', replace
global origdata `origdata'
* 2 targets, true variable
use ${origdata}, clear
drop if  target == "C" | target == "D" | target == "E" | target == "F" | target == "G" | target == "H" | target == "I" | target == "J"
gen true = 0.5
siman setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman scatter
siman scatter se est
graph drop _all
siman comparemethodsscatter
siman blandaltman
siman blandaltman se
siman zipplot
siman swarm
* 3 targets, true variable
use ${origdata}, clear
drop if target == "D" | target == "E" | target == "F" | target == "G" | target == "H" | target == "I" | target == "J"
gen true = 0.5
siman setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman scatter
siman scatter se est
graph drop _all
siman comparemethodsscatter
siman blandaltman
siman blandaltman se
siman zipplot
siman swarm
* > 3 targets, true variable
use ${origdata}, clear
gen true = 0.5
siman setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman scatter
siman scatter se est
graph drop _all
siman comparemethodsscatter
graph drop _all
siman comparemethodsscatter se
siman blandaltman
siman blandaltman se
siman zipplot
siman swarm
* 2 targets, true value
use ${origdata}, clear
drop if  target == "C" | target == "D" | target == "E" | target == "F" | target == "G" | target == "H" | target == "I" | target == "J"
siman setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman scatter
siman scatter se est
graph drop _all
siman comparemethodsscatter
siman blandaltman
siman blandaltman se
siman zipplot
siman swarm
* 3 targets, true value
use ${origdata}, clear
drop if target == "D" | target == "E" | target == "F" | target == "G" | target == "H" | target == "I" | target == "J"
siman setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman scatter
siman scatter se est
graph drop _all
siman comparemethodsscatter
siman blandaltman
siman blandaltman se
siman zipplot
siman swarm
* > 3 targets, true value
use ${origdata}, clear
siman setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman scatter
siman scatter se est
graph drop _all
siman comparemethodsscatter
graph drop _all
siman comparemethodsscatter se
siman blandaltman
siman blandaltman se
siman zipplot
siman swarm

* missing target
* creating a data set that has long method and missing target
use $testpath/data/simlongESTPM_longE_longM.dta, clear
drop estimand
bysort rep dgm method: gen repitionindi=_n
drop if repitionindi==2
drop repitionindi
siman setup, rep(rep) dgm(dgm) method(method) estimate(est) se(se) true(true)
* > 1 DGM 
siman scatter
siman swarm
siman blandaltman
siman zipplot
graph drop _all
siman comparemethodsscatter
* 1 DGM
drop if dgm == 2
siman scatter
siman swarm
siman blandaltman
siman zipplot
graph drop _all
siman comparemethodsscatter

* missing method
* creating a data set that has long target and missing method
use $testpath/data/simlongESTPM_longE_longM.dta, clear
drop method
bysort rep dgm estimand: gen repitionindi=_n
drop if repitionindi==2
drop repitionindi
siman setup, rep(rep) dgm(dgm) target(estimand) estimate(est) se(se) true(true)
* > 1 DGM 
siman scatter
*siman swarm
* error message as required
* siman blandaltman
* error message as required
siman zipplot
* siman comparemethodsscatter
* error message as required
* 1 DGM
drop if dgm == 2
siman scatter
* siman swarm
* error message as required
* siman blandaltman
* error message as required
siman zipplot
* siman comparemethodsscatter
* error message as required

* Testing siman scatter.  Check if have 2 dgms, A (0/1) and B(0/1).  Then siman scatter, by A B if A==0 should be same as siman scatter, by B.
clear all
prog drop _all
use $testpath/data/simlongESTPM_longE_longM.dta, clear
replace dgm = 0 if dgm==2
rename dgm dgmA
egen dgmB = fill(1 1 0 0 1 1 0 0)
egen dgmC = fill(1 0 1 0 1 0 1 0)
order rep dgmA dgmB dgmC
*append using long_long_formats\simlongESTPM_longE_longM.dta
siman setup, rep(rep) dgm(dgmA dgmB dgmC) target(estimand) method(method) est(est) se(se) true(true)
siman scatter if dgmA==0, by(dgmA dgmB)
*should be same as 
siman scatter, by(dgmB)
* it is!

clear all
prog drop _all
* Ian's testing Bland-Altman
use http://www.homepages.ucl.ac.uk/~rmjwiww/stata/misc/MIsim, clear
cap noi siman setup, rep(dataset) method(method)
cap noi siman blandaltman                                               

use http://www.homepages.ucl.ac.uk/~rmjwiww/stata/misc/MIsim, clear
siman setup, rep(dataset) method(method) est(b) se(se)
siman blandaltman // note implicit norescale: scales are same in the two graphs
siman blandaltman, bygraphoptions(yrescale) // yrescale works


**********************************************************
* DGM defined by multiple variables with multiple levels
**********************************************************

* Testing siman scatter
*************************
clear all
prog drop _all
clear all
prog drop _all
use $testpath/data/extendedtestdata.dta, clear

* remove non-integer values
gen betatrue=beta
foreach var in beta pmiss {
	gen `var'char = strofreal(`var')
	drop `var'
	sencode `var'char, gen(`var')
	drop `var'char
}
order beta pmiss

* create a string dgm var as well for testing
gen betastring = "0"
replace betastring = "0.25" if beta == 2
replace betastring = "0.5" if beta == 3
drop beta
rename betastring beta

siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) true(betatrue)

siman scatter
siman scatter, by(beta)
siman scatter, by(method)
siman scatter if method == "CCA", name("simanscatter_CCA", replace)


* Testing siman swarm
*************************

siman swarm                                                          
siman swarm, by(pmiss)              
siman swarm, by(mech)
siman swarm if method == "Noadj" | method == "MeanImp"   
siman swarm if (method == "Noadj" | method == "MeanImp"), by(beta) name("simanswarm_beta", replace)
siman swarm if (method == "Noadj" | method == "MeanImp"), by(pmiss)

* Testing siman blandaltman
****************************

siman blandaltman
siman blandaltman, by(beta)              
siman blandaltman, by(mech)
siman blandaltman if method == "Noadj" | method == "CCA"  
siman blandaltman if (method == "Noadj" | method == "MeanImp"), by(pmiss) 
siman blandaltman if (method == "CCA" | method == "MeanImp"), by(beta) name("simanba_new", replace)                  

* Testing siman comparemethodsscatter
**************************************
serset clear
graph drop _all
siman comparemethodsscatter
graph drop _all
siman comparemethodsscatter, methlist("CCA" "MeanImp") 
graph drop _all
siman comparemethodsscatter, methlist("Noadj" "MeanImp") name("simancms_new", replace) 
graph drop _all
siman comparemethodsscatter if beta == 1  
graph drop _all
siman comparemethodsscatter if mech == 2, name("simancmsmech", replace)                                   


* Testing siman zipplot
************************

siman zipplot  
siman zipplot, by(mech)       
siman zipplot if (method == "Noadj" | method == "MeanImp"), name("simanzip_new", replace) 
siman zipplot, by(method pmiss)
siman zipplot if (method == "CCA" | method == "MeanImp"), by(method mech) 
siman zipplot if beta == 1  


* Testing string dgm input (auto encoded to numeric with Tim's code)
clear all
prog drop _all
which siman_setup
use $testpath/data/simlongESTPM_longE_longM.dta, clear
gen dgm_string = "1"
replace dgm_string = "2" if dgm == 2
drop dgm
siman setup, rep(rep) dgm(dgm_string) target(estimand) method(method) estimate(est) se(se) true(true)

siman scatter
graph drop _all
siman comparemethodsscatter
siman swarm
siman zipplot
siman blandaltman

di as result "*** SIMAN GRAPHS HAVE PASSED ALL THE TESTS IN `filename'.do ***"

log close
