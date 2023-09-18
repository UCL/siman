/*
Testing_IRW_TPM_EMZ.do
Short testing file for discussion
*/

// SETUP: MODIFY FOR USER & PROJECT
*local codepath C:\ian\git\siman\ 
local codepath C:\git\siman\ 
global detail = 0

// SETUP FOR ALL USERS
local testpath `codepath'Ella_testing\
local filename testing_graphs_main
prog drop _all
adopath ++ `codepath'
cd `testpath'
cap log close
set linesize 100


// START TESTING
log using `filename', replace
siman which

* switch on detail if want to run all graphs
global detail = 1

 
* dgm defined by 1 variable
use data/simlongESTPM_longE_longM.dta, clear
encode estimand, gen(estimand_num)
drop estimand
rename estimand_num estimand
label define methodl 1 "A" 2 "B"
label values method methodl
gen dgm_str = ""
replace dgm_str = "1" if dgm == 1
replace dgm_str = "2" if dgm == 2
drop dgm true
rename dgm_str dgm

siman_setup, rep(rep) dgm(dgm) target(estimand) method(method) estimate(est) se(se) true(0)


siman scatter
if ${detail} == 1 siman scatter est se, name(est_onyaxis)
if ${detail} == 1 siman scatter se est, name(se_onyaxis)
* 1 panel per dgm, method and target combination

if ${detail} == 1 siman scatter, by(dgm)
* by dgm only
if ${detail} == 1 siman scatter if dgm == 1, by(method)
* by method only
if ${detail} == 1 siman scatter, by(estimand)
* by estimand only

siman swarm
* 1 panel per dgm and target combination, method on y-axis
if ${detail} == 1 siman swarm if estimand == 1
if ${detail} == 1 siman swarm if estimand == 2

siman comparemethodsscatter 
* 1 graph per dgm and target, comparing methods
if ${detail} == 1 siman comparemethodsscatter if estimand == 1
* metlist option too

siman blandaltman 
* 1 graph per dgm and target combination, comparison of methods
if ${detail} == 1 siman blandaltman if dgm ==1
if ${detail} == 1 siman blandaltman if estimand == 2

siman zipplot
* 1 panel per dgm, method and target combination
if ${detail} == 1 siman zipplot, by(estimand) 
if ${detail} == 1 siman zipplot, by(method) 

siman analyse

siman lollyplot

siman nestloop


* dgm defined by >1 variable
clear all
prog drop _all
use data/extendedtestdata_postfile.dta, clear

* remove non-integer values
gen betatrue=beta
foreach var in beta pmiss {
	gen `var'char = strofreal(`var')
	drop `var'
	sencode `var'char, gen(`var')
	drop `var'char
}
order beta pmiss

* create a string dgm var as well for testing
gen betastring = "0"
replace betastring = "0.25" if beta == 2
replace betastring = "0.5" if beta == 3
drop beta
rename betastring beta

siman_setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) true(betatrue)

siman scatter
* 1 panel per dgm, target and method 
if ${detail} == 1 siman scatter if method == "CCA"

siman swarm
* 1 panel per dgm level(s) and target, method on y-axis
* for the first panel in the all-graph display (beta level 1, pmiss level 1, mech level 1, estimand == "effect"), the means per
* method have a very small difference, visible as follows:
if ${detail} == 1 siman swarm if beta == 1 & pmiss == 1 & mech == 1 & estimand == "effect"
* FYI:
* mean method CCA: 0.0025341
* mean method meanlmp: 0.0021761
* mean noadj: -0.0034964

siman comparemethodsscatter 
* one graph per dgm and target combination, comparing methods

siman blandaltman 
* 1 graph per combination of dgm levels and target, by method difference

siman zipplot
* 1 pannel per dgm, target and method combination, 1 graph per beta (as defines y-axis)

* different spelling
siman analyze

siman lollyplot

siman nestloop


* examples in paper
use "https://raw.githubusercontent.com/UCL/siman/master/simpaper1.dta", clear
siman setup, rep(repno) dgm(dgm) method(method) est(b) se(se) true(0)
set scheme mrc

siman scatter 

siman swarm

siman comparemethodsscatter 

siman blandaltman 

siman zipplot


* trellis

* nestloop

use nestloop/res.dta, clear
* theta as dgmvar must be encoded, but theta as true value mustn't be
gen theta_new = 1
replace theta_new = 0 if theta == 0.5
replace theta_new = 2 if theta == 0.75
replace theta_new = 3 if theta == 1
label define theta_newl 0 "0.5" 1 "0.6666667" 2 "0.75" 3 "1"
label values theta_new theta_newl

* also encode tau2
gen tau2_new = 0
replace tau2_new = 1 if round(tau2,0.01) == 0.05
replace tau2_new = 2 if round(tau2,0.01) == 0.1
replace tau2_new = 3 if round(tau2,0.01) == 0.2
label define tau2_newl 0 "0" 1 "0.05" 2 "0.1" 3 "0.2"
label values tau2_new tau2_newl
drop tau2
rename tau2_new tau2

drop expfem exprem expmh msefem mserem msemh msepeto mseg2 mselimf covfem covrem covmh covpeto covg2 covlimf msepeters covpeters expexpect mseexpect covexpect msetrimfill covtrimfill biasfem biasrem biasmh biaspeto biaspeters biassfem biassrem biasg2 biaslimf biaslimr biasexpect biastrimfill var2fem var2rem var2mh var2expect

siman setup, rep(v1) dgm(theta_new rho pc tau2 k) method(peto g2 limf peters trimfill) estimate(exp) se(var2) true(theta)

* siman analyse needs force option to cope with only 1 repetition per dgm [NB gets many lines of red output], and notable option because siman table fails
qui siman analyse, force notable
* Recreating Gerta's graph, Figure 2
siman nestloop mean, dgmorder(-theta_new rho -pc tau2 -k) ylabel(0.2 0.5 1) ytitle("Odds ratio") xlabel(none) xtitle("")


di as result "*** SIMAN GRAPHS HAVE PASSED ALL THESE TESTS ***"
