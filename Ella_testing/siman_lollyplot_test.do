/*
test new siman_lollyplot
siman_lollyplot_test.do
IW 9/8/2023
Extended 17/8/2023
*/

local filename siman_lollyplot_test

prog drop _all
cd $testpath
cap log close
set linesize 100

// START TESTING
log using `filename', replace text nomsg
siman which

local i 0

// ONE DGMVAR
* multiple targets
use $testpath/data/simlongESTPM_longE_longM.dta, clear
foreach var in rep dgm estimand method est se true {
	rename `var' my`var'
}
siman setup, rep(myrep) dgm(mydgm) target(myestimand) method(mymethod) ///
	estimate(myest) se(myse) true(mytrue)
siman analyse, notable
siman lol bias relprec power cover, refpower(10)  name(l`++i', replace)
siman lol bias relprec power cover if myesti=="gamma", refpower(10) name(l`++i', replace)

* no target
use $testpath/data/simlongESTPM_longE_longM.dta, clear
drop if esti=="gamma"
drop esti
siman setup, rep(rep) dgm(dgm) method(method) estimate(est) se(se) true(true)
siman analyse, notable
siman lol bias relprec power cover, refpower(10)  name(l`++i', replace)


// COMPARE METHOD AS UNLABELLED/LABELLED NUMERIC OR STRING

* method is numeric unlabelled
use $testpath/data/simlongESTPM_longE_longM.dta, clear
drop if esti=="gamma"
drop esti
qui siman setup, rep(rep) dgm(dgm) method(method) estimate(est) se(se) true(true) 
siman analyse, notable
siman lol bias relprec power cover, refpower(10) name(munlabelled,replace)

* method is numeric labelled
use $testpath/data/simlongESTPM_longE_longM.dta, clear
drop if esti=="gamma"
drop esti
label def method 1 "1good" 2 "2bad"
label val method method
qui siman setup, rep(rep) dgm(dgm) method(method) estimate(est) se(se) true(true) 
siman analyse, notable
siman lol bias relprec power cover, refpower(10) name(mlabelled,replace)

* method is string
use $testpath/data/simlongESTPM_longE_longM.dta, clear
drop if esti=="gamma"
gen methchar = cond(method==1,"1good","2bad")
drop esti method
qui siman setup, rep(rep) dgm(dgm) method(methchar) estimate(est) se(se) true(true) 
siman analyse, notable
siman lol bias relprec power cover, refpower(10) name(mstring,replace)

** NB name(string) gives funny error

* method is not 1...
use $testpath/data/simlongESTPM_longE_longM.dta, clear
drop if esti=="gamma"
replace method = method+1
gen methchar = cond(method==2,"1good","2bad")
drop esti method
qui siman setup, rep(rep) dgm(dgm) method(methchar) estimate(est) se(se) true(true) 
siman analyse, notable
siman lol bias relprec power cover, refpower(10) name(mstringplus,replace)
* graph should be same as mstring

* method orderings disagree: numeric ordering should be used
use $testpath/data/simlongESTPM_longE_longM.dta, clear
drop if esti=="gamma"
label def method 1 "good" 2 "bad"
label val method method
drop esti 
qui siman setup, rep(rep) dgm(dgm) method(method) estimate(est) se(se) true(true) 
siman analyse, notable
siman lol bias relprec power cover, refpower(10) name(mstringrev,replace)
* graph should be same as mstring


// MULTIPLE DGMVARS
use $testpath/data/extendedtestdata2.dta, clear
siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) true(true)

siman analyse, notable
siman lol bias relprec power cover if beta==3, ///
	refpower(90) dgmwidth(35) pmwidth(20) legend(col(1)) name(l`++i', replace)

* finish with a high quality graph
siman lol bias relprec power cover if beta==3 & esti=="effect", ///
	legend(row(1)) name(l`++i', replace) col(red green blue) ///
	bygr(note(Good lollyplot for estimand effect) title(,size(medium))) 


di as result  "*** SIMAN LOLLYPLOT HAS PASSED ALL ITS TESTS ***"

log close
