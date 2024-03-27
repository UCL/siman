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

// TEST SETUP AND ANALYSE WHEN TRUE DEPENDS ON TARGET 
use $testpath/data/msgbsl_inter_try_postfile.dta, clear
rename inter binter
rename main bmain
gen mytrueinter=.3
gen mytruemain=0
reshape long b se mytrue, i(parm1 i method) j(estim) string

* set up
siman setup, rep(i) target(estim) method(method) est(b) se(se) true(mytrue) dgm(parm1)
siman des, char sort saving(c:\temp\char, replace)

* analyse works ok with ref and replace
siman analyse, ref(CC)
siman analyse, ref(FULLDAT) replace 
siman reshape, longlong
siman analyse, ref(IMPALL) replace 

/* ERROR: this one fails
siman reshape, longwide
siman analyse, ref(FULLDAT) replace
*/


// SIMILAR
use $testpath/data/extendedtestdata2, clear
gen df = 5
gen lci = b - invt(df,.975)*se
gen uci = b + invt(df,.975)*se
gen p = 2*ttail(df,abs(b)/se)
siman setup, rep(rep) dgm(beta pmiss mech) target(estimand) method(method) true(true) est(b) se(se) lci(lci) uci(uci) p(p) df(df)
siman des, char sort saving(c:\temp\char3, replace)

// CHECK GET ERROR IF TRUE IS NOT CONSTANT ACROSS METHODS
use $testpath/data/msgbsl_inter_try_postfile.dta, clear

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
* ERROR: this one SHOULD have failed


// TEST LCI, UCI, P OPTIONS
*	use long-long data 
*	use non-default cilevel as tougher test

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



// Quick graphs: approx 12 s
use $testpath/data/extendedtestdata2, clear
gen df = 5
gen lci = b - invt(df,.975)*se
gen uci = b + invt(df,.975)*se
gen p = 2*ttail(df,abs(b)/se)
siman setup, rep(rep) dgm(beta pmiss mech) target(estimand) method(method) true(true) est(b) se(se) lci(lci) uci(uci) p(p) df(df)
siman desc

gen touse = estimand=="effect" & beta==1 & pmiss==2 & mech==2
siman blandaltman if touse
siman scatter if touse
siman cms if touse
siman swarm if touse
siman zip if touse

siman analyse
siman table

siman loll if estimand=="effect" & beta==1
siman nest bias if estimand=="effect"

siman reshape, longwide



di as result "*** SIMAN HAS PASSED ALL THE TESTS IN `filename'.do ***"

log close
