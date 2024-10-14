// troubleshoot_setup.do
// Check the Troubleshooting and limitations section of help siman setup
// IW 14oct2024

pda

//    There can be no other variables in the data set other than those specified in
//     siman setup. 
//     Abbreviations should not be used for variable names and value labels in siman
//     setup. 
* NO LONGER A PROBLEM
use $testpath/data/extendedtestdata.dta, clear
gen main = beta==.25
tab main
rename b myestimate
siman setup, rep(rep) dgm(bet pmis mec) method(met) target(estiman) est(myest) se(se) true(true) debug
siman ana
gen main2 = beta==.25
siman lol if main2==1 & float(pmiss)==float(.2) & estimand=="effect", debug


//     If the method variable is not specified, then siman setup will create a variable
//     _method in the dataset with a value of 1 in order that all the other siman
//     programs can run. 
* TRUE
use $testpath/data/extendedtestdata.dta, clear
keep if method=="CCA"
siman setup, rep(rep) dgm(bet pmis mec) target(estiman) est(b) se(se) true(true) debug
siman ana
siman lol if beta==.25 & float(pmiss)==float(.2) & estimand=="effect", debug

//     If true exists, it has to be constant across methods.  If using
//     true(stub_varname), this stub has to be in the same format as the other variables.
//     For example if method and target are in wide format with values 1/2 and beta/gamma
//     respectively, with a different true value per target, and estimate defined as est,
//     standard error as se, then the variables in the dataset would need to be as
//     follows:  est1beta est2beta est1gamma est2gamma se1beta se2beta se1gamma se2gamma
//     true1beta true2beta true1gamma true2gamma.  UPDATE
//
//     Note that if the data was in widewide format similar to above with variable names
//     est1_beta est2_beta est1_gamma est2_gamma, then the underscores would need to be
//     included in siman setup, i.e. siman setup, est(est) method(1_ 2_) target(beta
//     gamma) order(method).  DROP
//
//     If the data is in widewide format with underscores separating the method and
//     target labels (as in the example above), or in widelong format with underscores
//     after the target labels, then these underscores will be removed by the siman
//     auto-reshape in to longwide format.  Underscores will be removed from the end of
//     variable labels displayed by siman describe, e.g. A_ and B_ will be displayed as A
//     and B.  DROP
//
//     No special characters are allowed in the labels of the variables, as these are not
//     allowed in Stata graphs.  No spaces in the variable labels are allowed either, to
//     enable reshaping to longwide format and back again (required internally for some
//     of the graphs).  For example, if the data is in longlong format the estimate
//     variable is b and the method variable has labels Complete case and Complete data,
//     then when reshaped to longwide format the variable names would become bComplete
//     case and bComplete data which is not permitted by Stata.  The method labels would
//     therefore need to be Complete_case and Complete_data.
* NO LONGER A PROBLEM
use $testpath/data/extendedtestdata.dta, clear
replace method = "Complete, Case" if method=="CCA"
encode method, gen(methchar)
siman setup, rep(rep) dgm(bet pmis mec) method(methchar) target(estiman) est(b) se(se) true(true) debug
siman ana
siman lol if beta==.25 & float(pmiss)==float(.2) & estimand=="effect", debug


//     Dgm can not contain missing values.
* STILL A PROBLEM - STRANGE BEHAVIOUR
use $testpath/data/extendedtestdata.dta, clear
keep if beta==0
replace pmiss = . if float(pmiss)==float(0.2)
siman setup, rep(rep) dgm(bet pmis mec) method(meth) target(estiman) est(b) se(se) true(true) debug
siman ana
siman lol if mech==1 & estimand=="effect", debug


//     If the user would like to specify a different name for any of the graphs using the
//     graph options, the new name is not permitted to contain the word 'name' (e.g.
//     name("testname") would not be allowed).
* NO LONGER A PROBLEM
use $testpath/data/extendedtestdata.dta, clear
siman setup, rep(rep) dgm(bet pmis mec) method(method) target(estiman) est(b) se(se) true(true) debug
siman ana, notable
siman lol if beta==.25 & float(pmiss)==float(.2) & estimand=="effect", debug name(testname)


//     Note that true must be a variable in the dataset for siman nestloop, and should be
//     listed in both the dgm() and the true() options in siman setup before running
//     these graphs, with the true variable being listed before the dgm variable in the
//     dgm() option.
* NO LONGER A PROBLEM
use $testpath/data/extendedtestdata.dta, clear
siman setup, rep(rep) dgm(bet pmis mec) method(method) target(estiman) est(b) se(se) 
siman ana, notable
siman nes if beta==.25 & float(pmiss)==float(.2) & estimand=="effect", debug name(testname)
