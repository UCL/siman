/*
test new siman_lollyplot
siman_lollyplot_test.do
IW 9/8/2023
Extended 17/8/2023
*/

prog drop _all
local path C:\ian\git\siman\ // for IW only
local pathtest `path'Ella_testing\
adopath ++ `path'
cd `pathtest'
cap log close
set linesize 100
log using siman_lollyplot_test, replace
siman which

local i 0

// ONE DGMVAR
* multiple targets
use `pathtest'data/simlongESTPM_longE_longM.dta, clear
foreach var in rep dgm estimand method est se true {
	rename `var' my`var'
}
siman setup, rep(myrep) dgm(mydgm) target(myestimand) method(mymethod) ///
	estimate(myest) se(myse) true(mytrue)
qui siman analyse
siman lol bias relprec power cover, refpower(10)  name(l`++i', replace)
siman lol bias relprec power cover if myesti=="gamma", refpower(10) name(l`++i', replace)

* no target
use `pathtest'data/simlongESTPM_longE_longM.dta, clear
drop if esti=="gamma"
drop esti
siman setup, rep(rep) dgm(dgm) method(method) estimate(est) se(se) true(true)
qui siman analyse
siman lol bias relprec power cover, refpower(10)  name(l`++i', replace)


// COMPARE METHOD AS UNLABELLED/LABELLED NUMERIC OR STRING

* method is numeric unlabelled
use `pathtest'data/simlongESTPM_longE_longM.dta, clear
drop if esti=="gamma"
drop esti
qui siman setup, rep(rep) dgm(dgm) method(method) estimate(est) se(se) true(true) 
qui siman analyse
siman lol bias relprec power cover, refpower(10) name(munlabelled,replace)

* method is numeric labelled
use `pathtest'data/simlongESTPM_longE_longM.dta, clear
drop if esti=="gamma"
drop esti
label def method 1 "1good" 2 "2bad"
label val method method
qui siman setup, rep(rep) dgm(dgm) method(method) estimate(est) se(se) true(true) 
qui siman analyse
siman lol bias relprec power cover, refpower(10) name(mlabelled,replace)

* method is string
use `pathtest'data/simlongESTPM_longE_longM.dta, clear
drop if esti=="gamma"
gen methchar = cond(method==1,"1good","2bad")
drop esti method
qui siman setup, rep(rep) dgm(dgm) method(methchar) estimate(est) se(se) true(true) 
qui siman analyse
siman lol bias relprec power cover, refpower(10) name(mstring,replace)

** NB name(string) gives funny error

* method is not 1...
use `pathtest'data/simlongESTPM_longE_longM.dta, clear
drop if esti=="gamma"
replace method = method+1
gen methchar = cond(method==2,"1good","2bad")
drop esti method
qui siman setup, rep(rep) dgm(dgm) method(methchar) estimate(est) se(se) true(true) 
qui siman analyse
siman lol bias relprec power cover, refpower(10) name(mstringplus,replace)
* graph should be same as mstring

* method orderings disagree: numeric ordering should be used
use `pathtest'data/simlongESTPM_longE_longM.dta, clear
drop if esti=="gamma"
label def method 1 "good" 2 "bad"
label val method method
drop esti 
qui siman setup, rep(rep) dgm(dgm) method(method) estimate(est) se(se) true(true) 
qui siman analyse
siman lol bias relprec power cover, refpower(10) name(mstringrev,replace)
* graph should be same as mstring


// MULTIPLE DGMVARS
use `pathtest'data/extendedtestdata_postfile.dta, clear

* siman setup requires beta, pmiss to be integer
gen true = 1 if estimand=="mean0"
replace true = 1+beta if estimand=="mean1"
replace true = beta if estimand=="effect"
rename beta _beta
gen beta=string(_beta)
sencode beta, replace
rename pmiss _pmiss
gen pmiss=string(_pmiss)
sencode pmiss, replace
drop _pmiss _beta
save extendedtestdata2, replace

siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) true(true)

siman analyse, notable
siman lollyplot if beta==1



// dgm defined by >1 variable - WORKS
use extendedtestdata2, clear
siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) true(true)
qui siman analyse
siman lol bias relprec power cover if beta==3, ///
	refpower(90) dgmwidth(35) pmwidth(20) legend(row(1)) name(l`++i', replace)

* tidy up
erase extendedtestdata2.dta

di as result  "*** SIMAN LOLLYPLOT HAS PASSED ALL ITS TESTS ***"

log close
