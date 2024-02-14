/* 
new_tests.do
new tests 14feb2024
*/


local filename new_tests

prog drop _all
cd $testpath
cap log close
set linesize 100

// START TESTING
log using `filename', replace text nomsg
siman which

// Check that failed -siman setup- with no method() option doesn't leave unwanted _methodvar in data 
pda
use data/simlongESTPM_longE_longM.dta, clear
cap noi siman setup, rep(rep) dgm(dgm) target(estimand) est(est) se(se) true(true)
confirm new var _methodvar

log close
