/* 
siman demonstration for paper
IW 24jul2025
*/

// OPEN DATA AND INTRODUCE SOME ERRORS

use simcheck, clear
gen estimand = "logOR"
* changes to insert some errors
* dgms are repeated, for dgm=MNAR 
replace  b =  b[_n-300] if rep>100 & dgm=="MNAR"
replace se = se[_n-300] if rep>100 & dgm=="MNAR"
replace df = df[_n-300] if rep>100 & dgm=="MNAR"
* 1 in 3 of SEs are too small, for method=MI
replace se = se/2 if method==3 & mod(rep,3)==0

// RUN SIMAN SETUP
siman setup, rep(rep) dgm(dgm) method(method) target(estimand) est(b) se(se) df(df) true(0)

// GRAPHS OF ESTIMATES 

* siman swarm
siman swarm, row(1) xsize(5) ysize(3)

* siman scatter
siman scatter, xsize(5) ysize(3)

* siman cms
siman comparemethodsscatter if dgm == 3, xsize(4) ysize(3)

* siman blandaltman
siman blandaltman if dgm == 3, xsize(5) ysize(3)

* siman zipplot
siman zipplot, xsize(5) ysize(5)

// COMPUTE PERFORMANCE ESTIMATES

use simcheck, clear
qui siman setup, rep(rep) dgm(dgm) method(method) est(b) se(se) df(df) true(0)
siman analyse
siman table bias empse, row(_perf dgm) nformat(%6.3f)

// GRAPHS OF PERFORMANCE

* siman lollyplot
siman lollyplot, legend(row(1)) labformat(%6.3f %6.0f) xsize(5) ysize(3)

* siman nestloop
use extendedtestdata, clear
siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) true(true)
siman analyse
siman nestloop empse if estimand=="effect", stagger(.05) lcol(red green blue) xsize(5) ysize(3)
