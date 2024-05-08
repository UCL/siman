/************************
PROBLEMS NEWLY RESOLVED
*************************/

pda

// UNDERSCORES IN EST NAMES: BREAKS ANALYSE (now fixed?)
* possibly line 50
use $testpath/data/simlongESTPM_wideE_wideM.dta, clear
siman setup, rep(rep) dgm(dgm) est(est) se(se) target(beta gamma) method(1_ 2_) order(method) true(true) debug
siman analyse, notab debug 


// OMITTED METHOD: WRONG ERROR MESSAGE
use $testpath/data/simlongESTPM_longE_longM.dta, clear
cap noi siman setup, rep(rep) target(estimand) method(method) est(est) se(se) true(true)
assert _rc==498
cap noi siman setup, rep(rep) dgm(dgm) method(method) est(est) se(se) true(true)
assert _rc==498
cap noi siman setup, rep(rep) dgm(dgm) target(estimand) est(est) se(se) true(true)
assert _rc==498

// VALUE-LABELLED ESTIMAND: VALUES NOT FOUND
pda
use $testpath/data/simlongESTPM_longE_longM.dta, clear
encode estimand, gen(estimand_num)
drop estimand
rename estimand_num estimand
label define dgml 1 "D1" 2 "D2"
label values dgm dgml
gen method_str = ""
replace method_str = "A" if method == 1
replace method_str = "B" if method == 2
drop method
rename method_str method
drop true
siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(0) debug