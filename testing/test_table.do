/*
test_table.do
IW 30may2025
Various tables to check by eye
*/

local filename test_table

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

use simcheck, clear
siman setup, rep(rep) dgm(dgm) method(method) est(b) se(se) df(df) true(0)
siman analyse
foreach tabmethod in table tabdisp {
	dicmd siman table cover, row(dgm _perf) `tabmethod'
	dicmd siman table bias cover, row(dgm _perf) `tabmethod'
	dicmd siman table, col(method dgm) `tabmethod'
}



di as result "*** SIMAN HAS PASSED ALL THE TESTS IN `filename'.do ***"

log close
