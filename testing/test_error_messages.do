/* 
Testing error messages
test_error_messages.do
Added cap noi and assert, IW 28oct2024
*/

local filename test_error_messages

prog drop _all
cd $testpath
cap log close
set linesize 100

// START TESTING
log using "`filename'_which", replace text
version
siman which
log close

log using "`filename'", replace text nomsg

use $testpath/data/simlongESTPM_longE_longM.dta, clear

* more than 1 entry in est()
cap noi siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est est2) se(se) true(true)
assert _rc==103
* more than 1 entry in se()
cap noi siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se se2) true(true)
assert _rc==103
* more than 1 entry in true()
cap noi siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true true2)
assert _rc==498

* missing est and se 
clear all
prog drop _all
use $testpath/data/simlongESTPM_longE_longM.dta, clear
drop est se
cap noi siman setup, rep(rep) dgm(dgm) target(estimand) method(method) true(true)
assert _rc==498

* all of est, se, ci and p missing in siman setup syntax
clear all
use $testpath/data/simlongESTPM_longE_longM.dta, clear
cap noi siman setup, rep(rep) dgm(dgm) target(estimand) method(method) 
* error message as required
assert _rc==498

* warning if est and se missing
clear all
use $testpath/data/simlongESTPM_longE_longM.dta, clear
* just labelling lci as true for testing purposes, so have something in lci macro
siman setup, rep(rep) dgm(dgm) target(estimand) method(method) lci(true)
* warning as required
cap noi siman ana
assert _rc==498

log close
