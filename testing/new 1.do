/*
start of a test file for partly missing SE
IW 11mar2025
*/

use https://raw.githubusercontent.com/UCL/siman/master/testing/data/simlongESTPM_longE_longM.dta, clear
replace se = . if method==2
siman setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(true)
siman analyse, notab
* problem: est is missing when se is missing
siman table, col(estimand method)