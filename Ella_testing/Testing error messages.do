* Testing error messages

clear all
prog drop _all
set linesize 100
cap log close

// START TESTING
log using `filename', replace text nomsg
use $testpath/data/simlongESTPM_longE_longM.dta, clear

* more than 1 entry in est()
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est est2) se(se) true(true)
* more than 1 entry in se()
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se se2) true(true)
* more than 1 entry in true()
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true true2)

* missing est/se in siman analyse
clear all
prog drop _all
use $testpath/data/simlongESTPM_longE_longM.dta, clear
drop est se
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) true(true)
siman analyse

* all of est, se, ci and p missing in siman setup syntax
clear all
use $testpath/data/simlongESTPM_longE_longM.dta, clear
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) 
* error message as required

* warning if est and se missing
clear all
use $testpath/data/simlongESTPM_longE_longM.dta, clear
* just labelling lci as true for testing purposes, so have something in lci macro
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) lci(true)
* warning as required

* error if additional variables in dataset
clear all
use $testpath/data/simlongESTPM_longE_longM.dta, clear
gen test = 1
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)
* error message as required

log close
