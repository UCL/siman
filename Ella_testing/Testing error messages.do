* Testing error messages

clear all
prog drop _all
cd N:\My_files\siman\Ian_example\
use long_long_formats\simlongESTPM_longE_longM.dta, clear

* more than 1 entry in est()
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est est2) se(se) true(true)
* more than 1 entry in se()
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se se2) true(true)
* more than 1 entry in true()
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true true2)

* check that dgm is numerical
clear all
prog drop _all
use N:\My_files\siman\simexample\estimates.dta, clear
decode dgm, gen(dgmnew)
drop dgm
siman setup, rep(idrep) dgm(dgmnew) method(method) est(theta) se(se)

* missing est/se in siman analyse
clear all
prog drop _all
cd N:\My_files\siman\Ian_example\
use long_long_formats\simlongESTPM_longE_longM.dta, clear
drop est se
siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) true(true)
siman analyse
