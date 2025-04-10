/* 
Test file for siman import
IW 27mar2025
*/

local filename test_import

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

// TEST WORKING ON THE NESTLOOP TEST DATA SET

use "C:\ian\git\siman\testing\data\res.dta", clear
keep if pc==2 & rho==3
drop pc rho
local dgmvars theta tau2 k 
local methodvals fem rem mh peto g2 limf limr peters expect trimfill sfem srem // not needed
local pmtarg exp mse cov bias var2 // combines target and PM, I think

* reshape long-long
reshape long `pmtarg', i(`dgmvars') j(method) string
rename (`pmtarg') (est=)
reshape long est, i(`dgmvars' method) j(perfmeas) string

* extract target and PM
gen target = cond(perfmeas=="var2",2,1)
replace perfmeas = "cover" if perfmeas=="cov"
replace perfmeas = "mean" if inlist(perfmeas, "exp", "var2")

* save for later
save zres, replace

// test with all going well
use zres, clear
siman_import, dgm(theta tau2 k) target(target) method(method) estimate(est) perf(perfmeas)
siman des
siman table if theta==1 & tau2==0 & k==5, column(_perfmeas target)
siman nes mean if target==1 & inlist(method,"peto" ,"g2")

// test with different varnames
use zres, clear
rename (theta tau2 k target method est perfmeas) (my=)
siman_import, dgm(mytheta mytau2 myk) target(mytarget) method(mymethod) estimate(myest) perf(myperfmeas)

// test with wrong PM name
use zres, clear
replace perfmeas="meav" if perfmeas=="mean"
tab perfmeas
cap noi siman_import, dgm(theta tau2 k) target(target) method(method) estimate(est) perf(perfmeas)
cap assert _rc==498

erase zres.dta


// COMPARE BEFORE AND AFTER EXPORT/IMPORT
// load data and do benchmark analysis
use data/simcheck, clear
siman setup, rep(rep) dgm(dgm) method(method) est(b) se(se) df(df) true(0)
siman ana, perf
siman table, col(dgm method)
siman lol, name(lolly1,replace)

// "export" "to non-siman-format
siman_unset
keep if rep<0
drop rep _dataset N df
rename _true true
rename _perfmeascode pm

// import to siman
pda
siman_import, perf(pm) dgm(dgm) method(method) estimate(b) se(se) true(true)
siman table, col(dgm method)
siman lol, name(lolly2,replace)

* compare lolly1 and lolly2
* compare results for both runs

log close
