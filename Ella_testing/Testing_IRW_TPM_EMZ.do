/*
Testing_IRW_TPM_EMZ.do
Short testing file for discussion
*/
clear all
prog drop _all
* cd "C:\git\siman\Ella_testing\" // change to correct directory here

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
* 1 panel per dgm, method and target combination
siman scatter, by(dgm)
* by dgm only
siman scatter if dgm == 1, by(method)
* by method only
siman scatter, by(estimand)
* by estimand only

siman swarm
* 1 panel per dgm and target combination, method on y-axis
siman swarm if estimand == 1
siman swarm if estimand == 2

siman comparemethodsscatter 
* 1 graph per dgm and target, comparing methods
siman comparemethodsscatter if estimand == 1
* metlist option too

siman blandaltman 
* 1 graph per dgm and target combination, comparison of methods
siman blandaltman if dgm ==1
siman blandaltman if estimand == 2

siman zipplot
* 1 panel per dgm, method and target combination
siman zipplot, by(estimand) 
siman zipplot, by(method) 

siman analyse

siman lollyplot



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
* 1 graph per dgm variable, 1 panel per dgm level, method and target
siman scatter if method == "CCA"

siman swarm
* 1 panel per dgm level(s) and target, method on y-axis
* for the first panel in the all-graph display (beta level 1, pmiss level 1, mech level 1, estimand == "effect"), the means per
* method have a very small difference, visible as follows:
siman swarm if beta == 1 & pmiss == 1 & mech == 1 & estimand == "effect"
* FYI:
* mean method CCA: 0.0025341
* mean method meanlmp: 0.0021761
* mean noadj: -0.0034964

siman comparemethodsscatter 

siman blandaltman 
* 1 graph per combination of dgm levels and target, by method difference

siman zipplot

siman analyse

siman lollyplot


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

clear all
prog drop _all
use data/n500type1.dta, clear
* there are 12 methods so just keep a few for the example
keep if method =="CC" | method=="LRD1" | method=="PMM1"
qui gen se = sqrt(var)
gen dgm = 0
replace dgm = 1 if mechanism == "marw"
replace dgm = 2 if mechanism == "mcar"
label define dgmlabelvalues 0 "mars" 1 "marw" 2 "mcar"
label values dgm dgmlabelvalues
drop mechanism auroc var
siman setup, rep(repno) dgm(dgm beta) method(method) estimate(b) se(se) df(df) true(beta)
siman analyse
siman trellis bias

* nestloop

use res.dta, clear
gen theta_new = 1
replace theta_new = 0 if theta == 0.5
replace theta_new = 2 if theta == 0.75
replace theta_new = 3 if theta == 1
label define theta_newl 0 "0.5" 1 "0.6666667" 2 "0.75" 3 "1"
label values theta_new theta_newl
br theta theta theta_new  
drop theta
rename theta_new theta

gen tau2_new = 0
replace tau2_new = 1 if round(tau2,0.01) == 0.05
replace tau2_new = 2 if round(tau2,0.01) == 0.1
replace tau2_new = 3 if round(tau2,0.01) == 0.2
label define tau2_newl 0 "0" 1 "0.05" 2 "0.1" 3 "0.2"
label values tau2_new tau2_newl
br tau2 tau2_new  
drop tau2
rename tau2_new tau2

drop expfem exprem expmh msefem mserem msemh msepeto mseg2 mselimf covfem covrem covmh covpeto covg2 covlimf msepeters covpeters expexpect mseexpect covexpect msetrimfill covtrimfill biasfem biasrem biasmh biaspeto biaspeters biassfem biassrem biasg2 biaslimf biaslimr biasexpect biastrimfill var2fem var2rem var2mh var2expect

siman_setup, rep(v1) dgm(theta rho pc tau2 k) method(peto g2 limf peters trimfill) estimate(exp) se(var2) true(theta)
siman_analyse
* Recreating Gerta's graph, Figure 2
siman_nestloop mean, dgmorder(-theta rho -pc tau2 -k) ylabel(0.2 0.5 1) ytitle("Odds ratio")
