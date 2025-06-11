/* 
test_unset.do
Short test of siman unset 
IW 10jun2025
*/


local filename test_unset

prog drop _all
cd $testpath
cap log close
set linesize 100
graph drop _all

// START TESTING
log using `filename'_which, replace text
version
siman which
log close

log using `filename', replace text nomsg


// program to check that there are no chars starting "siman_"
prog def charcheck
local charlist : char _dta[]
local error 0
foreach char of local charlist {
	cap assert substr("`char'",1,6)!="siman_"
	if _rc {
		char list _dta[`char']
		local error 9
	}
}
if `error' di as error "the above siman chars were set"
exit `error'
end


use data/simcheck, clear
siman setup, rep(rep) dgm(dgm) method(method) est(b) se(se) df(df) true(0)
siman unset
charcheck


use data/extendedtestdata.dta, clear
siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) true(true)
siman unset
charcheck


use $testpath/data/simlongESTPM_longE_longM.dta, clear
siman setup, rep(rep) dgm(dgm) target(estimand) method(method) ///
	estimate(est) se(se) true(true)
siman unset
charcheck


use data/msgbsl_inter_try_postfile.dta, clear
rename inter binter
rename main bmain
gen trueinter=.3
gen truemain=0
siman setup, rep(i) target(inter main) method(method) est(b) se(se) true(true) dgm(parm1)
siman unset
charcheck



di as result "*** SIMAN HAS PASSED ALL THE TESTS IN `filename'.do ***"

log close
