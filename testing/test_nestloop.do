/*
test new siman nestloop
siman_nestloop_test.do
IW 14/8/2023
updated 16/8/2023 
17/8/2023 added tests of dgmorder and edge cases
*/

local filename test_nestloop

prog drop _all
cd $testpath
cap log close
set linesize 100

// START TESTING
log using `filename'_which, replace text
version
siman which
which nestloop
log close

log using `filename', replace text nomsg

*** Start with a test of the stand-alone nestloop.ado

use $testpath/data/res.dta, clear
drop v1
order theta rho pc tau2 k 

* reshape into format required by nestloop
reshape long exp mse cov bias var2, i(theta rho pc tau2 k) j(method) string

* draw nestloop for 9 methods and 4*3*4*4*4 dgms
nestloop exp, descriptors(theta rho pc tau2 k) method(method) true(theta) legend(row(2)) dgsize(.25)

*** Reproduce nested loop plot in Rucker and Schwarzer 2014

* log transform - sadly yscale(log) doesn't work
gen logor = log(exp)
gen logtheta=log(theta)
mylabels .2 .5 1, myscale(log(@)) local(labels)
keep if inlist(method,"peto","trimfill","peters","limf","limr")
nestloop logor, descriptors(-theta rho -pc tau2 -k) method(method) true(logtheta) legend(col(1) ring(0) pos(9)) dgsize(.25) dgreverse debug ylabel(`labels') ytitle(Odds ratio) lcol(orange black blue gray lime) scheme(mrc)

*** Main tests of siman nestloop
use $testpath/data/extendedtestdata.dta, clear

siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) true(true)

siman analyse
siman nestloop bias, lcol(black red blue) 

siman nestloop relerror if estimand=="mean1", dgmorder(beta pmiss -mech) stagger(0.05) dgsize(.4) dggap(.2) dgcol(green orange purple) dgpatt(dash solid =) dglabsize(medium) dglwidth(1) lcol(black red blue) lwidth(1) title(My nested loop plot) name(sn1,replace) xla(none) norefline

* setup without true
use $testpath/data/extendedtestdata, clear
drop true
siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) 
siman analyse
siman nestloop if estimand=="effect", lcol(black red blue) xtitle("") xlabel(none) stagger(0.03) 

* siman analyse with if
use $testpath/data/extendedtestdata, clear
siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) true(true)
siman analyse if mech!=2
siman nestloop mean if estimand=="mean0", lcol(black red blue) xtitle("") xlabel(none) stagger(0.03) 
* Graph should ignore mech


// COMPARE METHOD AS UNLABELLED/LABELLED NUMERIC OR STRING

* method is string (as in source data)
use $testpath/data/extendedtestdata, clear
tab method if float(beta)==float(0) & float(pmiss)==float(0.2) & mech=="MCAR" & estimand=="effect" & rep>0, su(b) // CCA, MeanImp, Noadj
siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) true(true)
siman analyse
siman nestloop empse if estimand=="effect", name(mstring,replace)
graph export mstring.pdf, replace

* method is numeric labelled in alphabetical order
use $testpath/data/extendedtestdata, clear
sencode method, gsort(method) replace // 1=CCA, 2=MeanImp, 3=Noadj
tab method if float(beta)==float(0) & float(pmiss)==float(0.2) & mech=="MCAR" & estimand=="effect" & rep>0, su(b)
siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) true(true)
siman analyse
siman nestloop empse if estimand=="effect", name(mlabalpha,replace)

* method is numeric labelled in data order
use $testpath/data/extendedtestdata, clear
sencode method, replace // 1=Noadj, 2=CCA, 3=MeanImp
tab method if float(beta)==float(0) & float(pmiss)==float(0.2) & mech=="MCAR" & estimand=="effect" & rep>0, su(b)
siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) true(true)
siman analyse
siman nestloop empse if estimand=="effect", name(mlabdata,replace)

* method is numeric unlabelled in alphabetical order
use $testpath/data/extendedtestdata, clear
sencode method, gsort(method) replace // order is alphabetical: CCA MeanImp Noadj 
tab method if float(beta)==float(0) & float(pmiss)==float(0.2) & mech=="MCAR" & estimand=="effect" & rep>0, su(b)
label val method // 1 [=Noadj], 2 [=CCA], 3 [=MeanImp]
tab method if float(beta)==float(0) & float(pmiss)==float(0.2) & mech=="MCAR" & estimand=="effect" & rep>0, su(b)
siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) true(true)
siman analyse
siman nestloop empse if estimand=="effect", name(munlabelled,replace)

** NB name(string) gives funny error

* method is not 1...
use $testpath/data/extendedtestdata, clear
gen methchar = 11 if method == "CCA"
replace methchar = 12 if method == "MeanImp"
replace methchar = 13 if method == "Noadj"
label def methchar 11 "CCA" 12 "MeanImp" 13 "Noadj"
label val methchar methchar
drop method
tab methchar if float(beta)==float(0) & float(pmiss)==float(0.2) & mech=="MCAR" & estimand=="effect" & rep>0, su(b)
siman setup, rep(rep) dgm(beta pmiss mech) method(methchar) target(estimand) est(b) se(se) true(true)
siman analyse
siman nestloop empse if estimand=="effect", name(munlabplus10,replace)

* graph should be the same as mstring
graph export munlabplus10.pdf, replace
!fc mstring.pdf munlabplus10.pdf > result
type result
* Check "no differences encountered" above
foreach file in mstring.pdf munlabplus10.pdf result {
	erase `file'
}



// more tests with true
* check mean 
use $testpath/data/extendedtestdata, clear
siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) true(true)
siman analyse
siman nestloop mean if estimand=="mean0", lcol(black red blue) xtitle("") xlabel(none) stagger(0.03)
 
* only one method
siman nestloop bias if method=="CCA" & estimand=="mean0", lcol(black red blue) xtitle("") xlabel(none) name(sn2,replace)

* incomplete dgmorder
siman nestloop bias if estimand=="mean0", dgmorder(pmiss beta) 
* reverse dgmorder
siman nestloop bias if estimand=="mean0", dgmorder(pmiss beta) dgreverse
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
cap noi siman nestloop bias if float(beta)==0 & float(pmiss)==float(0.2) & mech==1
assert _rc == 498

* no target
use $testpath/data/extendedtestdata, clear
keep if estimand=="mean0"
drop estimand
siman setup, rep(rep) dgm(beta pmiss mech) method(method) est(b) se(se) true(true)
siman analyse
siman nestloop bias, name(sn4,replace)

* numeric target
use $testpath/data/extendedtestdata, clear
encode estimand, gen(estinum)
drop estimand
siman setup, target(estinum) rep(rep) dgm(beta pmiss mech) method(method) est(b) se(se) true(true)
siman analyse
siman nestloop bias, name(sn5,replace) saving(sn5s , replace) export(pdf, replace)
foreach target in effect mean0 mean1 {
	erase sn5s_`target'_bias.gph
	erase sn5s_`target'_bias.pdf
}
siman nestloop bias if estinum==1, name(sn6,replace) nodg legend(row(1))
siman nestloop bias if estinum==1, nodg legend(row(1)) methlegend(item)
siman nestloop bias if estinum==1, nodg legend(row(1)) methlegend(title)

* this is a good quality graph
siman nestloop bias if estinum==1, legend(row(1)) ///
	title(Good nestloop graph for estimand effect) note("") stagger(.05) xlab(none) lcol(red green blue)

di as result  "*** SIMAN NESTLOOP HAS PASSED ALL ITS TESTS ***"

log close
