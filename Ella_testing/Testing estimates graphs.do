* Testing estimates graph options

clear all
prog drop _all
cd N:\My_files\siman\Ian_example\
use long_long_formats\simlongESTPM_longE_longM.dta, clear
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)

* siman scatter
siman_scatter, ytitle("test y-title") xtitle("test x-title") name("test") 
siman_scatter, ytitle("test y-title") xtitle("test x-title")     
siman_scatter 
siman_scatter if dgm==2, name(siman_scatter_dgm2)

* siman_swarm
siman_swarm
siman_swarm, meanoff scheme(s1color) bygraphoptions(title("main-title")) graphoptions(ytitle("test y-title"))
siman_swarm, scheme(economist) bygraphoptions(title("main-title")) graphoptions(ytitle("test y-title") xtitle("test x-title"))
siman_swarm, graphoptions(ytitle("test y-title") xtitle("test x-title")) combinegraphoptions(name("test2", replace))     
siman_swarm if dgm == 1   


*siman_zipplot
siman_zipplot
siman_zipplot, by(dgm estimand method)
siman_zipplot, scheme(scheme(s2color)) legend(order(4 "Carrot" 3 "Stalk")) xtit("x-title") ytit("y-title") ylab(0 40 100) noncoveroptions(pstyle(p3)) ///
coveroptions(pstyle(p4)) scatteroptions(mcol(grey%50)) truegraphoptions(pstyle(p6)) 
siman_zipplot, scheme(scheme(s2color)) legend(order(4 "Carrot" 3 "Stalk")) xtit("x-title") ytit("y-title") ylab(0 40 100) noncoveroptions(pstyle(p3)) ///
coveroptions(pstyle(p4)) scatteroptions(mcol(grey%50)) truegraphoptions(pstyle(p6)) name("carrot")

 
drop true
gen true = -0.5
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)
siman_zipplot


* Check dgm labels when dgm numeric with string labels
clear all
prog drop _all
cd N:\My_files\siman\Ian_example\
use long_long_formats\simlongESTPM_longE_longM.dta, clear
label define dgmvar 1 "A" 2 "B"
label values dgm dgmvar
label define methodvar 1 "X" 2 "Y"
label values method methodvar
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)
siman scatter                  
siman zipplot                  
siman swarm                   
siman comparemethodsscatter    /****check here ****/


* Different true values per target
use long_long_formats\simlongESTPM_longE_longM.dta, clear
replace true=0.5 if estimand=="beta"
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)
siman_zipplot  
siman_zipplot, scheme(scheme(economist)) legend(order(4 "Covering" 3 "Not covering")) xtit("x-title") ytit("y-title") ylab(0 40 100) ///
noncoveroptions(pstyle(p3)) coveroptions(pstyle(p4)) scatteroptions(mcol(grey%50)) truegraphoptions(pstyle(p6))

* siman scatter
use long_long_formats\simlongESTPM_longE_longM.dta, clear
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)
siman_scatter
siman_scatter, by(dgm)
siman_scatter, by(estimand method)
siman_scatter, ytitle("test y-title") xtitle("test x-title") scheme(economist) bygraphoptions(title("main-title"))
siman_scatter, ytitle("test y-title") xtitle("test x-title") scheme(s2mono) by(dgm) bygraphoptions(title("main-title")) 

* siman comparemethodsscatter
siman_comparemethodsscatter
siman_comparemethodsscatter, by(estimand)  
siman_comparemethodsscatter, scheme(economist) 
* to change title in main graph
siman_comparemethodsscatter, title("test")
* to have subtitles in consituent graphs (looks messy, but just for testing)
siman_comparemethodsscatter, subgr(xtit("test"))
siman_comparemethodsscatter, name("test")     
siman_comparemethodsscatter, title("testtitle") subgr(xtit("testaxis")) name("test")    

clear all
prog drop _all
* more than 3 methods for plots
cd N:\My_files\siman\Ian_example\
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
*drop if method>4
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target)
siman_comparemethodsscatter
siman_comparemethodsscatter, by(target)  
siman_blandaltman est se
siman_blandaltman, by(dgm)   
siman blandaltman if target == "gamma"                     
siman_blandaltman, bygraphoptions(norescale)
siman_blandaltman, methlist(2 8)
siman_blandaltman, methlist(3 7) by(dgm)                  
siman_blandaltman
siman_blandaltman, ytitle("test y-title") xtitle("test x-title") name("yabberdabberdoo") 
siman_blandaltman, ytitle("test y-title") xtitle("test x-title")

clear all
prog drop _all
cd N:\My_files\siman\Ian_example\
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
gen dgm=1
expand 2, gen(dupindicator)
replace dgm=2 if dupindicator==1
drop dupindicator
*drop if method>4
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target)
siman_comparemethodsscatter
siman_comparemethodsscatter se                             
siman_comparemethodsscatter est
siman_comparemethodsscatter, methlist(3 8) 
siman_comparemethodsscatter, methlist(1 3 8)                      
siman_comparemethodsscatter se, methlist(1 3 8 9) 
siman_comparemethodsscatter, by(target)  
siman_comparemethodsscatter, methlist(1 3 8) by(target)                      
siman_comparemethodsscatter se, methlist(1 3 8 9) by(target) 

* String variable method
cd N:\My_files\siman\Ian_example\
use wide_wide_formats\simlongESTPM_wideE_wideM4.dta, clear
siman_setup, rep(rep) dgm(dgm) target(beta gamma) method(A_ B_) estimate(est) se(se) true(true) order(method)
siman_comparemethodsscatter 
siman_blandaltman
siman_blandaltman est se
siman_blandaltman, by(dgm)                                                                                
* To test methlist subset, create a dataset with more than 3 string method variables
clear all
cd N:\My_files\siman\Ian_example\
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
siman_comparemethodsscatter
siman_comparemethodsscatter, methlist(A C)                       
siman_comparemethodsscatter, methlist(B C D) 
siman_comparemethodsscatter, methlist(B C D)  by(target)                       
siman_blandaltman	
siman_blandaltman, methlist(A C)  

clear all
prog drop _all
use N:\My_files\siman\simexample\estimates.dta, clear
gen dgmnew = 0
replace dgmnew = 1 if dgm==2
label define dgmlabelvalues 0 "y = 1" 1 "y = 1.5"
label values dgmnew dgmlabelvalues
drop dgm
rename dgmnew dgm
siman setup, rep(idrep) dgm(dgm) method(method) est(theta) se(se)
siman swarm                                                         

* Combinations of #methods and #targets for testing matrix
************************************************************

* Numeric methods
*******************
cd N:\My_files\siman\Ian_example\
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
tempfile origdata
save `origdata', replace

* 2 methods, true variable
drop if method>2
gen true = 0.5
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman scatter
siman scatter se est
siman comparemethodsscatter
siman blandaltman
siman blandaltman est se
siman zipplot
siman swarm
* 3 methods, true variable
use `origdata', clear

drop if method>3
gen true = 0.5
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman scatter
siman scatter se est
siman comparemethodsscatter
siman blandaltman
siman blandaltman est se
siman zipplot
siman swarm
* > 3 methods, true variable
use `origdata', clear
gen true = 0.5
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman scatter
siman scatter se est
siman comparemethodsscatter
siman comparemethodsscatter se
siman blandaltman
siman blandaltman est se
siman zipplot
siman swarm

* 2 methods, true value
use `origdata', clear
drop if method>2
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)

siman scatter
siman scatter se est
siman comparemethodsscatter
siman blandaltman
siman blandaltman est se

siman zipplot
siman swarm
* 3 methods, true value
use `origdata', clear
drop if method>3
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman scatter
siman scatter se est
siman comparemethodsscatter
siman blandaltman
siman blandaltman est se
siman zipplot
siman swarm
* > 3 methods, true value
use `origdata', clear
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman scatter
siman scatter se est
siman comparemethodsscatter
siman comparemethodsscatter se
siman blandaltman
siman blandaltman est se
siman zipplot
siman swarm


* String methods
*******************
clear all
cd N:\My_files\siman\Ian_example\
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
save `origdata', replace
* 2 methods, true variable
drop if method == "C" | method == "D"
gen true = 0.5
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman scatter
siman scatter se est
siman comparemethodsscatter
siman blandaltman
siman blandaltman est se
siman zipplot
siman swarm
* 3 methods, true variable
use `origdata', clear
drop if  method == "D"
gen true = 0.5
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman scatter
siman scatter se est
siman comparemethodsscatter
siman blandaltman
siman blandaltman est se
siman zipplot
siman swarm
* > 3 methods, true variable
use `origdata', clear
gen true = 0.5
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman scatter
siman scatter se est
siman comparemethodsscatter
siman comparemethodsscatter se
siman blandaltman
siman blandaltman est se
siman zipplot
siman swarm
* 2 methods, true value
use `origdata', clear
drop if method == "C" | method == "D"
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman scatter
siman scatter se est
siman comparemethodsscatter
siman blandaltman
siman blandaltman est se
siman zipplot
siman swarm
* 3 methods, true value
use `origdata', clear
drop if  method == "D"
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman scatter
siman scatter se est
siman comparemethodsscatter
siman blandaltman
siman blandaltman est se
siman zipplot
siman swarm
* > 3 methods, true value
use `origdata', clear
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman scatter
siman scatter se est
siman comparemethodsscatter
siman comparemethodsscatter se
siman blandaltman
siman blandaltman est se
siman zipplot
siman swarm


* Numeric targets
*******************
cd N:\My_files\siman\Ian_example\
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
gen method_new = "A" if target == "beta"
replace method_new = "B" if target == "gamma"
drop target 
rename method target
rename method_new method
tempfile origdata
save `origdata', replace
* 2 targets, true variable
use `origdata', clear
drop if  target > 2
gen true = 0.5
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman scatter
siman scatter se est
siman comparemethodsscatter
siman blandaltman
siman blandaltman est se
siman zipplot
siman swarm
* 3 targets, true variable
use `origdata', clear
drop if target > 3
gen true = 0.5
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman scatter
siman scatter se est
siman comparemethodsscatter
siman blandaltman
siman blandaltman est se
siman zipplot
siman swarm
* > 3 targets, true variable
use `origdata', clear
gen true = 0.5
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman scatter
siman scatter se est
siman comparemethodsscatter
siman comparemethodsscatter se
siman blandaltman
siman blandaltman est se
siman zipplot
siman swarm
* 2 targets, true value
use `origdata', clear
drop if  target > 2
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman scatter
siman scatter se est
siman comparemethodsscatter
siman blandaltman
siman blandaltman est se
siman zipplot
siman swarm
* 3 targets, true value
use `origdata', clear
drop if target > 3
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman scatter
siman scatter se est
siman comparemethodsscatter
siman blandaltman
siman blandaltman est se
siman zipplot
siman swarm
* > 3 targets, true value
use `origdata', clear
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman scatter
siman scatter se est
siman comparemethodsscatter
siman comparemethodsscatter se
siman blandaltman
siman blandaltman est se
siman zipplot
siman swarm

  
* String targets
*******************
cd N:\My_files\siman\Ian_example\
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
* 2 targets, true variable
use `origdata', clear
drop if  target == "C" | target == "D" | target == "E" | target == "F" | target == "G" | target == "H" | target == "I" | target == "J"
gen true = 0.5
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman scatter
siman scatter se est
siman comparemethodsscatter
siman blandaltman
siman blandaltman est se
siman zipplot
siman swarm
* 3 targets, true variable
use `origdata', clear
drop if target == "D" | target == "E" | target == "F" | target == "G" | target == "H" | target == "I" | target == "J"
gen true = 0.5
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman scatter
siman scatter se est
siman comparemethodsscatter
siman blandaltman
siman blandaltman est se
siman zipplot
siman swarm
* > 3 targets, true variable
use `origdata', clear
gen true = 0.5
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(true)
siman scatter
siman scatter se est
siman comparemethodsscatter
siman comparemethodsscatter se
siman blandaltman
siman blandaltman est se
siman zipplot
siman swarm
* 2 targets, true value
use `origdata', clear
drop if  target == "C" | target == "D" | target == "E" | target == "F" | target == "G" | target == "H" | target == "I" | target == "J"
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman scatter
siman scatter se est
siman comparemethodsscatter
siman blandaltman
siman blandaltman est se
siman zipplot
siman swarm
* 3 targets, true value
use `origdata', clear
drop if target == "D" | target == "E" | target == "F" | target == "G" | target == "H" | target == "I" | target == "J"
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman scatter
siman scatter se est
siman comparemethodsscatter
siman blandaltman
siman blandaltman est se
siman zipplot
siman swarm
* > 3 targets, true value
use `origdata', clear
siman_setup, rep(dnum) dgm(dgm) est(est) se(se) method(method) target(target) true(0.5)
siman scatter
siman scatter se est
siman comparemethodsscatter
siman comparemethodsscatter se
siman blandaltman
siman blandaltman est se
siman zipplot
siman swarm

* missing target
* creating a data set that has long method and missing target
use long_long_formats\simlongESTPM_longE_longM.dta, clear
drop estimand
bysort rep dgm method: gen repitionindi=_n
drop if repitionindi==2
drop repitionindi
siman_setup, rep(rep) dgm(dgm) method(method) estimate(est) se(se) true(true)
* > 1 DGM 
siman scatter
siman swarm
siman blandaltman
siman zipplot
siman_comparemethodsscatter
* 1 DGM
drop if dgm == 2
siman scatter
siman swarm
siman blandaltman
siman zipplot
siman_comparemethodsscatter

* missing method
* creating a data set that has long target and missing method
use long_long_formats\simlongESTPM_longE_longM.dta, clear
drop method
bysort rep dgm estimand: gen repitionindi=_n
drop if repitionindi==2
drop repitionindi
siman_setup, rep(rep) dgm(dgm) target(estimand) estimate(est) se(se) true(true)
* > 1 DGM 
siman scatter
*siman swarm
* error message as required
* siman blandaltman
* error message as required
siman zipplot
* siman_comparemethodsscatter
* error message as required
* 1 DGM
drop if dgm == 2
siman scatter
* siman swarm
* error message as required
* siman blandaltman
* error message as required
siman zipplot
* siman_comparemethodsscatter
* error message as required

* Testing siman scatter.  Check if have 2 dgms, A (0/1) and B(0/1).  Then siman scatter, by A B if A==0 should be same as siman scatter, by B.
clear all
prog drop _all
cd N:\My_files\siman\Ian_example\
use long_long_formats\simlongESTPM_longE_longM.dta, clear
replace dgm = 0 if dgm==2
rename dgm dgmA
egen dgmB = fill(1 1 0 0 1 1 0 0)
egen dgmC = fill(1 0 1 0 1 0 1 0)
order rep dgmA dgmB dgmC
*append using long_long_formats\simlongESTPM_longE_longM.dta
siman setup, rep(rep) dgm(dgmA dgmB dgmC) target(estimand) method(method) est(est) se(se)
siman scatter if dgmA==0, by(dgmA dgmB)
*should be same as 
siman scatter, by(dgmB)
* it is!

clear all
prog drop _all
* Ian's testing Bland-Altman
use http://www.homepages.ucl.ac.uk/~rmjwiww/stata/misc/MIsim, clear
siman setup, rep(dataset) method(method)
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
cd N:\My_files\siman\GertaRucker\12874_2014_1136_MOESM1_ESM\
use res.dta, clear
siman_setup, rep(v1) dgm(theta rho pc tau2 k) method(peto g2 limf peters trimfill) estimate(exp) se(var2) true(theta)
siman_scatter
clear all
prog drop _all
cd N:\My_files\siman\GertaRucker\12874_2014_1136_MOESM1_ESM\
use res.dta, clear
siman_setup, rep(v1) dgm(theta rho pc tau2 k) method(peto g2 limf peters trimfill) estimate(exp) se(var2) true(theta)
siman scatter, by(theta)
siman scatter, by(tau2)
siman_reshape, longlong
siman scatter, by(method)
siman scatter if method == "peto"
siman scatter if theta==1, name(simanscatter_theta1, replace)
siman scatter if theta==0.5, name(simanscatter_theta05, replace)
siman scatter if method == "peto" & theta == 1



* Testing siman swarm
*************************
clear all
prog drop _all
cd N:\My_files\siman\GertaRucker\12874_2014_1136_MOESM1_ESM\
use res.dta, clear
siman_setup, rep(v1) dgm(theta rho pc k) method(peto g2) estimate(exp) se(var2) true(theta)
siman_swarm                                                          
clear all
prog drop _all
cd N:\My_files\siman\GertaRucker\12874_2014_1136_MOESM1_ESM\
use res.dta, clear
siman_setup, rep(v1) dgm(theta rho pc k) method(peto g2 limf) estimate(exp) se(var2) true(theta)
siman swarm, by(theta)              
siman swarm, by(k)
siman_reshape, longlong
siman swarm if method == "peto" | method == "limf"   
siman swarm if (method == "peto" | method == "limf"), by(theta) combinegraphoptions(name(simanswarm_theta1, replace))                  
siman swarm if (method == "peto" | method == "limf"), by(k)

* Testing siman blandaltman
****************************
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
siman_setup, rep(v1) dgm(theta rho pc k) method(peto g2) estimate(exp) se(var2) true(theta)
*siman reshape, longlong
*siman reshape, longwide
siman_blandaltman

clear all
prog drop _all
cd N:\My_files\siman\GertaRucker\12874_2014_1136_MOESM1_ESM\
use res.dta, clear
gen theta_new=2
replace theta_new=1 if theta == 0.5
replace theta_new=3 if theta == 0.75
replace theta_new=4 if theta == 1 
label define theta_new 1 "0.5" 2 "0.67" 3 "0.75" 4 "1"
label values theta_new theta_new
label var theta_new "theta categories"
drop theta
rename theta_new theta
keep v1 theta rho pc k exppeto expg2 var2peto var2g2 explimf var2limf
siman_setup, rep(v1) dgm(theta rho pc k) method(peto g2 limf) estimate(exp) se(var2) true(theta)
siman blandaltman
siman blandaltman, by(theta)              
siman blandaltman, by(k)
siman reshape, longlong
siman blandaltman if method == "peto" | method == "limf"  
siman blandaltman if (method == "peto" | method == "limf"), by(k) 
siman blandaltman if (method == "peto" | method == "limf"), by(theta) name("simanba_new", replace)                  

* Testing siman comparemethodsscatter
**************************************
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
siman_setup, rep(v1) dgm(theta rho pc k) method(peto g2) estimate(exp) se(var2) true(theta)
siman comparemethodsscatter

clear all
prog drop _all
cd N:\My_files\siman\GertaRucker\12874_2014_1136_MOESM1_ESM\
use res.dta, clear
gen theta_new=2
replace theta_new=1 if theta == 0.5
replace theta_new=3 if theta == 0.75
replace theta_new=4 if theta == 1 
label define theta_new 1 "0.5" 2 "0.67" 3 "0.75" 4 "1"
label values theta_new theta_new
label var theta_new "theta categories"
drop theta
rename theta_new theta
keep v1 theta rho pc k exppeto expg2 var2peto var2g2 explimf var2limf
siman_setup, rep(v1) dgm(theta rho pc k) method(peto g2 limf) estimate(exp) se(var2) true(theta)
siman comparemethodsscatter
siman reshape, longlong 

siman comparemethodsscatter, methlist("peto" "limf") 
siman comparemethodsscatter, methlist("peto" "limf") name("simancms_new", replace) 
siman comparemethodsscatter if theta == 1  
siman comparemethodsscatter if theta == 4 
siman comparemethodsscatter if pc == 2, name("simancmspc", replace)                                   


* Testing siman zipplot
************************
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
siman_setup, rep(v1) dgm(theta rho pc k) method(peto g2 limf) estimate(exp) se(var2) true(theta)
siman_zipplot  
siman zipplot, by(k)       
siman reshape, longlong 
siman zipplot if (method == "peto" | method == "limf"), name("simanzip_new", replace) 
siman zipplot, by(method k)
siman zipplot if (method == "peto" | method == "limf"), by(method k) 
siman zipplot if theta == 1  

/*
siman reshape, longlong
bysort theta method: gen sortvar = _n
*/


        