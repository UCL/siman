/*
Testing_IRW_TPM_EMZ.do
Short testing file for discussion
3apr2024 Removed tests with excessive numbers of graphs and panels: reduced from 8 to 2 minutes
25jul2024 Updates for revised setup
*/

* switch on detail if want to run all graphs
global detail = 1

local filename Testing_IRW_TPM_EMZ

prog drop _all
cd $testpath
cap log close
set linesize 100

// START TESTING
log using `filename'_which, replace text
siman which
log close

log using `filename', replace text nomsg


 
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

serset clear
graph drop _all
siman comparemethodsscatter 
* 1 graph per dgm and target, comparing methods
serset clear
graph drop _all
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

* siman nestloop - only one dgmvar


* testing setup and reshape via the chars (could be expanded)

* setup data in LW - this is known to be correct (makes other programs work)
use $testpath/data/extendedtestdata.dta, clear
reshape wide b se, i(rep beta pmiss mech estimand) j(method) string
siman setup, rep(rep) dgm(beta pmiss mech) method(CCA MeanImp Noadj) target(estimand) est(b) se(se) true(true)
assert "`: char _dta[siman_nummethod]'" == "3"
assert "`: char _dta[siman_valmethod]'" == "CCA; MeanImp; Noadj"

* setup data in LL and reshape to LW
use $testpath/data/extendedtestdata.dta, clear
siman setup, rep(rep) dgm(beta pmiss mech) method(method) target(estimand) est(b) se(se) true(true)
assert "`: char _dta[siman_nummethod]'" == "3"
assert "`: char _dta[siman_valmethod]'" == "CCA; MeanImp; Noadj"


* dgm defined by >1 variable
use $testpath/data/extendedtestdata.dta, clear
order beta pmiss

* create a string dgm var as well for testing
gen betastring = "0"
replace betastring = "0.25" if float(beta)==float(0.25)
replace betastring = "0.5" if float(beta)==float(0.5)
drop beta

siman setup, rep(rep) dgm(betastring pmiss mech) method(method) target(estimand) est(b) se(se) true(true)
* NB setup has coded beta as 1/2/3

siman scatter if betastring==1 & float(pmiss)==float(0.2) & mech==1
* 1 panel per dgm, target and method 
if ${detail} == 1 siman scatter if beta==1 & float(pmiss)==float(0.2) & mech==1 & method == "CCA"

siman swarm if betastring==1 & float(pmiss)==float(0.2) & mech==1
* 1 panel per dgm level(s) and target, method on y-axis
* for the first panel in the all-graph display (beta level 1, pmiss level 1, mech level 1, estimand == "effect"), the means per
* method have a very small difference, visible as follows:
if ${detail} == 1 siman swarm if betastring==1 & float(pmiss)==float(0.2) & mech == 1 & estimand == "effect"
* FYI:
* mean method CCA: 0.0025341
* mean method meanlmp: 0.0021761
* mean noadj: -0.0034964

serset clear
graph drop _all // sometimes helps
* siman comparemethodsscatter
* one graph per dgm and target combination, comparing methods - too slow
siman comparemethodsscatter if betastring==1 & float(pmiss)==float(0.2) & mech == 2 & estimand=="effect"
* one graph per target, comparing methods

siman blandaltman if betastring==1 & float(pmiss)==float(0.4) & mech == 2
* 1 graph per combination of dgm levels and target, by method difference

siman zipplot if betastring==1 & float(pmiss)==float(0.4) & mech == 2
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

graph drop _all
siman comparemethodsscatter if dgm==1

siman blandaltman 

siman zipplot

* siman nestloop - no because only one dgmvar


use $testpath/nestloop/res.dta, clear
drop expfem exprem expmh msefem mserem msemh msepeto mseg2 mselimf covfem covrem covmh covpeto covg2 covlimf msepeters covpeters expexpect mseexpect covexpect msetrimfill covtrimfill biasfem biasrem biasmh biaspeto biaspeters biassfem biassrem biasg2 biaslimf biaslimr biasexpect biastrimfill var2fem var2rem var2mh var2expect

siman setup, rep(v1) dgm(theta rho pc tau2 k) method(peto g2 limf peters trimfill) estimate(exp) se(var2) true(theta)

* siman analyse needs force option to cope with only 1 repetition per dgm [NB gets many lines of red output, suppressed by cap], and notable option because siman table fails
cap siman analyse, force 
assert _rc == 198

* Recreating Gerta's graph, Figure 2
siman nestloop mean, dgmorder(-theta rho -pc tau2 -k) ylabel(0.2 0.5 1) ytitle("Odds ratio") xlabel(none) xtitle("")

di as result "*** SIMAN GRAPHS HAVE PASSED ALL THE TESTS IN `filename'.do ***"

log close
