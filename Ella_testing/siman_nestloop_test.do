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
log using siman_nestloop_test, replace text nomsg
siman which

use $testpath/data/extendedtestdata.dta, clear

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


// COMPARE METHOD AS UNLABELLED/LABELLED NUMERIC OR STRING

* method is string (as in source data)
use extendedtestdata2, clear
tab method if beta==1 & pmiss==1 & mech=="MCAR" & estimand=="effect" & rep>0, su(b) // CCA, MeanImp, Noadj
siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) true(true)
qui siman analyse
siman nestloop empse if estimand=="effect", name(mstring,replace)

* method is numeric labelled in alphabetical order
use extendedtestdata2, clear
sencode method, gsort(method) replace // 1=CCA, 2=MeanImp, 3=Noadj
tab method if beta==1 & pmiss==1 & mech=="MCAR" & estimand=="effect" & rep>0, su(b)
siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) true(true)
qui siman analyse
siman nestloop empse if estimand=="effect", name(mlabalpha,replace)

* method is numeric labelled in data order
use extendedtestdata2, clear
sencode method, replace // 1=Noadj, 2=CCA, 3=MeanImp
tab method if beta==1 & pmiss==1 & mech=="MCAR" & estimand=="effect" & rep>0, su(b)
siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) true(true)
qui siman analyse
siman nestloop empse if estimand=="effect", name(mlabdata,replace)

* method is numeric unlabelled in alphabetical order
use extendedtestdata2, clear
sencode method, gsort(method) replace // order is alphabetical: CCA MeanImp Noadj 
tab method if beta==1 & pmiss==1 & mech=="MCAR" & estimand=="effect" & rep>0, su(b)
label val method // 1 [=Noadj], 2 [=CCA], 3 [=MeanImp]
tab method if beta==1 & pmiss==1 & mech=="MCAR" & estimand=="effect" & rep>0, su(b)
siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) true(true)
qui siman analyse
siman nestloop empse if estimand=="effect", name(munlabelled,replace)

** NB name(string) gives funny error

* method is not 1...
use extendedtestdata2, clear
gen methchar = 11 if method == "CCA"
replace methchar = 12 if method == "MeanImp"
replace methchar = 13 if method == "Noadj"
label def methchar 11 "CCA" 12 "MeanImp" 13 "Noadj"
label val methchar methchar
drop method
tab methchar if beta==1 & pmiss==1 & mech=="MCAR" & estimand=="effect" & rep>0, su(b)
siman setup, rep(rep) dgm(beta pmiss mech) method(methchar) target(estimand) est(b) se(se) true(true)
qui siman analyse
siman nestloop empse if estimand=="effect", name(munlabplus10,replace)
* graph should be same as mstring



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

* wrong pm
cap noi siman nestloop rhubarb 
assert _rc == 498

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
siman nestloop bias if estinum==1, name(sn6,replace) nodg legend(row(1)) saving(sn6,replace)

* tidy up
erase extendedtestdata2.dta
erase sn6.gph

di as result  "*** SIMAN NESTLOOP HAS PASSED ALL ITS TESTS ***"

log close