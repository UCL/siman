/* 
Test CI options
IW 26mar2025
*/

local filename test_ci

prog drop _all
cd "$testpath"
cap log close
set linesize 100

// START TESTING
log using `filename'_which, replace text
version
siman which
log close

log using `filename', replace text nomsg

// Compare coverage by 3 methods

// (i) b, se, df 
use data/simcheck, clear
qui siman setup, rep(rep) dgm(dgm) method(method) est(b) se(se) df(df) true(0)
siman ana cover, perf
save z0, replace

// (ii) lci, uci 
use data/simcheck, clear
gen zcrit = cond(mi(df),invnorm(.975),invt(df,.975))
gen lci = b-zcrit*se
gen uci = b+zcrit*se
qui siman setup, rep(rep) dgm(dgm) method(method) est(b) se(se) df(df) true(0) lci(lci) uci(uci)
siman ana cover, perf
save z1, replace

// (iii) lci only then uci only
use data/simcheck, clear
gen zcrit = cond(mi(df),invnorm(.975),invt(df,.975))
gen lci = b-zcrit*se
gen uci = b+zcrit*se
qui siman setup, rep(rep) dgm(dgm) method(method) est(b) se(se) df(df) true(0) lci(lci)
siman ana cover, perf
save z2, replace

use data/simcheck, clear
gen zcrit = cond(mi(df),invnorm(.975),invt(df,.975))
gen lci = b-zcrit*se
gen uci = b+zcrit*se
qui siman setup, rep(rep) dgm(dgm) method(method) est(b) se(se) df(df) true(0) uci(uci)
siman ana cover, perf
save z3, replace

use z1, clear
drop zcrit lci uci
cf _all using z0
rename b b1
merge 1:1 _n using z2
assert _merge==3
drop _merge
rename b b2
merge 1:1 _n using z3
assert _merge==3
drop _merge
rename b b3
assert reldif(100-b1,100-b2+100-b3)<1E-5

di as result "*** SIMAN HAS PASSED ALL THE TESTS IN `filename'.do ***"

forvalues i=0/3 {
	erase z`i'.dta
}
log close
