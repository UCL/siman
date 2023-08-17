/*
test new siman nestloop
siman_nestloop_test.do
IW 14/8/2023
updated 16/8/2023 
17/8/2023 added tests of dgmorder and edge cases
*/

prog drop _all
local path C:\ian\git\siman\ // for IW only
adopath ++ `path'
cd `path'Ella_testing
cap log close
set linesize 100
log using siman_nestloop_test, replace
siman which

use data/extendedtestdata_postfile.dta, clear

* siman setup requires beta, pmiss to be integer
gen true = 1 if estimand=="mean0"
replace true = 1+beta if estimand=="mean1"
replace true = beta if estimand=="effect"

rename beta _beta
gen beta=string(_beta)
sencode beta, replace

rename pmiss _pmiss
gen pmiss=string(_pmiss)
sencode pmiss, replace

drop _pmiss _beta
save extendedtestdata2, replace

siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) true(true)

siman analyse, notable
siman nestloop bias, lcol(black red blue) 

siman nestloop relerror if estimand=="mean1", dgmorder(beta pmiss -mech) stagger(0.05) dgsize(.4) dggap(.2) dgcol(green orange purple) dgpatt(dash solid =) dglabsize(medium) dglwidth(1) lcol(black red blue) lwidth(1) title(My nested loop plot) name(sn1,replace) xla(none) norefline

* setup without true
use extendedtestdata2, clear
drop true
siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) 
siman analyse, notable
siman nestloop if estimand=="effect", lcol(black red blue) xtitle("") xlabel(none) stagger(0.03) 

* siman analyse with if
use extendedtestdata2, clear
siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) true(true)
siman analyse if mech!=2, notable
siman nestloop mean if estimand=="mean0", lcol(black red blue) xtitle("") xlabel(none) stagger(0.03) 
* graph should ignore mech

// more tests with true
* check mean 
use extendedtestdata2, clear
siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) true(true)
siman analyse, notable
siman nestloop mean if estimand=="mean0", lcol(black red blue) xtitle("") xlabel(none) stagger(0.03)
 
* only one method
siman nestloop bias if method=="CCA" & estimand=="mean0", lcol(black red blue) xtitle("") xlabel(none) name(sn2,replace)

* incomplete dgmorder
cap noi siman nestloop bias if estimand=="mean0", dgmorder(pmiss beta) 
assert _rc == 498
* bogus dgmorder
cap noi siman nestloop bias if estimand=="mean0", dgmorder(pmiss mech3 beta) 
assert _rc == 111
* surplus var in dgmorder
cap noi siman nestloop bias if estimand=="mean0", dgmorder(pmiss mech true beta) 
assert _rc == 498
* repeated in dgmorder
cap noi siman nestloop bias if estimand=="mean0", dgmorder(pmiss mech mech beta) 
assert _rc == 498
* abbreviated dgmorder
siman nestloop bias if estimand=="mean0", dgmorder(pmiss be -mec) name(sn3,replace)

* only one dgm
cap noi siman nestloop bias if pmiss==1 & beta==1 & mech==1
assert _rc == 498

* no target
use extendedtestdata2, clear
keep if estimand=="mean0"
drop estimand
siman setup, rep(rep) dgm(beta pmiss mech) method(method) est(b) se(se) true(true)
siman analyse, notable
siman nestloop bias, name(sn4,replace)

* numeric target
use extendedtestdata2, clear
encode estimand, gen(estinum)
drop estimand
siman setup, target(estinum) rep(rep) dgm(beta pmiss mech) method(method) est(b) se(se) true(true)
siman analyse, notable
siman nestloop bias, name(sn5,replace)
siman nestloop bias if estinum==1, name(sn6,replace) nodg saving(sn6,replace)

* tidy up
erase extendedtestdata2.dta
erase sn6.gph

di as result  "*** SIMAN NESTLOOP HAS PASSED ALL ITS TESTS ***"

log close