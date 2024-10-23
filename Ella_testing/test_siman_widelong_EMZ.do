/* 
Test reading in from wide-long format, and statistics options
EMZ 06/11/2023
IW added tests of siman analyse, ref() replace 12/3/2024
IW test siman analyse if but not siman reshape 11/6/2024
*/

local filename test_siman_widelong_EMZ

prog drop _all
cd $testpath
cap log close
set linesize 100

// START TESTING
log using `filename'_which, replace text
siman which
log close

log using `filename', replace text nomsg

use $testpath/data/msgbsl_inter_try_postfile.dta, clear

* targets are wide, methods are long 
* so data are in wide-long format (format 4)

* need estimates to be stub + target
rename inter binter
rename main bmain

* set up true value variables
gen trueinter=.3
gen truemain=0

* set up
siman setup, rep(i) target(inter main) method(method) est(b) se(se) true(true) dgm(parm1)

* analyse works ok with ref and replace
siman analyse, ref(CC)
siman analyse, ref(FULLDAT) replace 
siman analyse, ref(IMPALL) replace 

* check get error if true is not constant across methods
use $testpath/data/msgbsl_inter_try_postfile.dta, clear
rename inter binter
rename main bmain
gen trueinter=.3
gen truemain=0
* introduce error
replace trueinter = 0.5 in 2
cap siman setup, rep(i) target(inter main) method(method) est(b) se(se) true(true) dgm(parm1)
assert _rc==498

/*
TEST LCI, UCI, P OPTIONS
	use long-long data 
	use non-default cilevel as tougher test
*/

* using SE: store results as comparators
use $testpath/data/simlongESTPM_longE_longM.dta, clear
siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)
siman analyse bias ciwidth cover power, level(80) debug
foreach pm in bias ciwidth cover power {
	summ est if _perfmeascode=="`pm'"
	local `pm'ref = r(mean)
}

* using LCI and UCI: compare ciwidth, coverage and power
use $testpath/data/simlongESTPM_longE_longM.dta, clear
gen lower = est - invnorm(.9)*se
gen upper = est + invnorm(.9)*se
siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true) lci(lower) uci(upper)
siman analyse ciwidth cover power, debug
summ est if _perfmeascode=="ciwidth"
di `ciwidthref', r(mean),reldif(`ciwidthref', r(mean))
assert reldif(`ciwidthref', r(mean))<1E-8
summ est if _perfmeascode=="cover"
di `coverref', r(mean),reldif(`coverref', r(mean))
assert reldif(`coverref', r(mean))<1E-8
summ est if _perfmeascode=="power"
di `powerref', r(mean),reldif(`powerref', r(mean))
assert reldif(`powerref', r(mean))<1E-8

* using P: compare ciwidth and power
use $testpath/data/simlongESTPM_longE_longM.dta, clear
gen pvalue = 2*normprob(-abs(est)/se)
siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true) p(pvalue)
siman analyse ciwidth power, level(80) debug
summ est if _perfmeascode=="ciwidth"
di `ciwidthref', r(mean),reldif(`ciwidthref', r(mean))
assert reldif(`ciwidthref', r(mean))<1E-8
summ est if _perfmeascode=="power"
di `powerref', r(mean),reldif(`powerref', r(mean))
assert reldif(`powerref', r(mean))<1E-8

* using P wrongly: compare ciwidth and power
use $testpath/data/simlongESTPM_longE_longM.dta, clear
gen pvalue = 2*normprob(-abs(est)/se)
siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true) p(pvalue)
siman analyse ciwidth power, debug // NB default level
summ est if _perfmeascode=="ciwidth"
di `ciwidthref', r(mean),reldif(`ciwidthref', r(mean))
assert reldif(`ciwidthref', r(mean))>1E-2
summ est if _perfmeascode=="power"
di `powerref', r(mean),reldif(`powerref', r(mean))
assert reldif(`powerref', r(mean))>1E-2

* test with no se: compare bias
use $testpath/data/simlongESTPM_longE_longM.dta, clear
drop se
siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) true(true)
siman analyse bias
summ est if _perfmeascode=="bias"
di `biasref', r(mean),reldif(`biasref', r(mean))
assert reldif(`biasref', r(mean))<1E-8

* test analyse with if
siman analyse if dgm==2, replace
count if dgm==1
assert r(N)==4000

di as result "*** SIMAN HAS PASSED ALL THE TESTS IN `filename'.do ***"

log close
