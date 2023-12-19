/* 
IW quick sim on missing baseline 30/10/2023
was N:\Home\missing\Missing baselines\interactions\msgbsl_inter_try.do
Used to test siman
EMZ 06/11/2023
*/

clear all
prog drop _all

adopath ++ $codepath
cd $testpath

cap log close

// START TESTING
which siman
log using `filename', replace text nomsg

use $testpath/data/msgbsl_inter_try_postfile.dta

* targets are wide, methods are long 
* so data are in wide-long format (format 4)

* need estimates to be stub + target
rename inter binter
rename main bmain

* set up true value variables
gen trueinter=.3
gen truemain=0

* set up
siman setup, rep(i) target(inter main) method(method) est(b) se(se) true(true) dgm(parm1)

* analyse works ok
siman analyse

* check get error if true is not constant across methods
clear all

use $testpath/data/msgbsl_inter_try_postfile.dta

* targets are wide, methods are long 
* so data are in wide-long format (format 4)

* need estimates to be stub + target
rename inter binter
rename main bmain

* set up true value variables
gen trueinter=.3
gen truemain=0

replace trueinter = 0.5 in 2
replace trueinter = 0.8 in 3
replace truemain = 0.2 in 2

* set up
siman setup, rep(i) target(inter main) method(method) est(b) se(se) true(true) dgm(parm1)




