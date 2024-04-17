/*
Testing_IRW_TPM_EMZ.do
Short testing file for discussion
3apr2024 Removed tests with excessive numbers of graphs and panels: reduced from 8 to 2 minutes
*/

* switch on detail if want to run all graphs
global detail = 1

local filename Testing_IRW_TPM_EMZ

prog drop _all
cd $testpath
cap log close
set linesize 100

// START TESTING
log using `filename', replace text nomsg
siman which

 
* dgm defined by 1 variable
use $testpath/data/simlongESTPM_longE_longM.dta, clear
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

serset clear
siman nestloop


* testing setup and reshape via the chars (could be expanded)

* setup data in LW - this is known to be correct (makes other programs work)
use $testpath/data/extendedtestdata2.dta, clear
reshape wide b se true, i(rep beta pmiss mech estimand) j(method) string
siman setup, rep(rep) dgm(beta pmiss mech) method(CCA MeanImp Noadj) target(estimand) est(b) se(se) true(true)
assert "`: char _dta[siman_nmethod]'" == "3"
assert "`: char _dta[siman_method]'" == "CCA MeanImp Noadj"

* setup data in LL and reshape to LW
use $testpath/data/extendedtestdata2.dta, clear
siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) true(true)
siman reshape, longwide
assert "`: char _dta[siman_nmethod]'" == "3"
assert "`: char _dta[siman_method]'" == "CCA MeanImp Noadj"


* dgm defined by >1 variable
use $testpath/data/extendedtestdata.dta, clear

* create true values, corrected 25oct2023
gen betatrue = beta if estimand == "effect"
replace betatrue = 1 if estimand == "mean0"
replace betatrue = 1 + beta if estimand == "mean1"

* remove non-integer values
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

siman scatter if beta==1 & pmiss==1 & mech==1
* 1 panel per dgm, target and method 
if ${detail} == 1 siman scatter if beta==1 & pmiss==1 & mech==1 & method == "CCA"

siman swarm if beta==1 & pmiss==1 & mech==1
* 1 panel per dgm level(s) and target, method on y-axis
* for the first panel in the all-graph display (beta level 1, pmiss level 1, mech level 1, estimand == "effect"), the means per
* method have a very small difference, visible as follows:
if ${detail} == 1 siman swarm if beta == 1 & pmiss == 1 & mech == 1 & estimand == "effect"
* FYI:
* mean method CCA: 0.0025341
* mean method meanlmp: 0.0021761
* mean noadj: -0.0034964

serset clear
* siman comparemethodsscatter
* one graph per dgm and target combination, comparing methods - too slow
siman comparemethodsscatter if beta == 1 & pmiss == 1 & mech == 2 & estimand=="effect"
* one graph per target, comparing methods

siman blandaltman if beta == 1 & pmiss == 2 & mech == 2
* 1 graph per combination of dgm levels and target, by method difference

siman zipplot if beta == 1 & pmiss == 2 & mech == 2
* 1 panel per dgm, target and method combination, 1 graph per beta (as defines y-axis)

* different spelling
siman analyze

siman lollyplot if mech==2 & estimand=="effect"

siman nestloop


* examples in paper
use "https://raw.githubusercontent.com/UCL/siman/master/simpaper1.dta", clear
siman setup, rep(repno) dgm(dgm) method(method) est(b) se(se) true(0)
set scheme mrc

siman scatter 

siman swarm

siman comparemethodsscatter if dgm==1

siman blandaltman 

siman zipplot


* trellis

* nestloop

use $testpath/nestloop/res.dta, clear
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

* siman analyse needs force option to cope with only 1 repetition per dgm [NB gets many lines of red output, suppressed by cap], and notable option because siman table fails
cap siman analyse, force 
assert _rc == 198

* Recreating Gerta's graph, Figure 2
siman nestloop mean, dgmorder(-theta_new rho -pc tau2 -k) ylabel(0.2 0.5 1) ytitle("Odds ratio") xlabel(none) xtitle("")

di as result "*** SIMAN GRAPHS HAVE PASSED ALL THE TESTS IN `filename'.do ***"

log close
