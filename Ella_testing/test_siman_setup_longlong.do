/* 
test_siman_setup_longlong.do
IW 15/3/2024
based on test_siman_widelong_EMZ.do
*/

local filename test_siman_setup_longlong

prog drop _all
cd $testpath
cap log close
set linesize 100

// START TESTING
log using `filename', replace text nomsg
siman which

use $testpath/data/msgbsl_inter_try_postfile.dta, clear
rename inter binter
rename main bmain
gen mytrueinter=.3
gen mytruemain=0
reshape long b se mytrue, i(parm1 i method) j(estim) string

* set up
siman setup, rep(i) target(estim) method(method) est(b) se(se) true(mytrue) dgm(parm1)

siman des, char sort saving(c:\temp\char, replace)
exit 1


* analyse works ok with ref and replace
siman analyse, ref(CC)
siman analyse, ref(FULLDAT) replace 
siman reshape, longlong
siman analyse, ref(IMPALL) replace 

/* this one fails
siman reshape, longwide
siman analyse, ref(FULLDAT) replace
*/

* check get error if true is not constant across methods
clear all

use $testpath/data/msgbsl_inter_try_postfile.dta

* targets are wide, methods are long 
* so data are in wide-long format (format 4)

* need estimates to be stub + target
rename inter binter
rename main bmain

* set up true value variables
gen trueinter=.3
gen truemain=0

replace trueinter = 0.5 in 2
replace trueinter = 0.8 in 3
replace truemain = 0.2 in 2

* set up
siman setup, rep(i) target(inter main) method(method) est(b) se(se) true(true) dgm(parm1)


/*
TEST LCI, UCI, P OPTIONS
	use long-long data 
	use non-default cilevel as tougher test
*/

* using SE: store results as comparators
use $testpath/data/simlongESTPM_longE_longM.dta, clear
siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)
siman analyse ciwidth cover power, level(80) debug
summ est if _perfmeascode=="ciwidth"
local ciwidthref = r(mean)
summ est if _perfmeascode=="cover"
local coverref = r(mean)
summ est if _perfmeascode=="power"
local powerref = r(mean)

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


di as result "*** SIMAN HAS PASSED ALL THE TESTS IN `filename'.do ***"

log close
