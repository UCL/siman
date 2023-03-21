
* Re-creating Figure 2 from 'Presenting simulation results in a nested loop plot' (Rucker, Schwarzer) 
* https://bmcmedresmethodol.biomedcentral.com/articles/10.1186/1471-2288-14-129#Sec23
* 24/01/2022

clear all
prog drop _all
cd C:\git\siman\Ella_testing\nestloop\
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
siman_nestloop mean, dgmorder(-theta rho -pc tau2 -k) lwidth(vthin ...) 
siman_nestloop mean, dgmorder(-theta rho -pc tau2 -k) ylabel(0.2 0.5 1) ytitle("Odds ratio")
siman_nestloop mean, dgmorder(-theta rho -pc tau2 -k) ylabel(0.2 0.5 1) ytitle("Odds ratio") name("test")

* Changing the order of the dgm variables
siman_nestloop mean, dgmorder(-theta -k tau2 -pc rho)
* Other graphs, testing look ok
siman_nestloop mean, dgmorder(theta -rho pc -tau2 k)
siman_nestloop bias
siman_nestloop mse
siman_nestloop mse, dgmorder(-theta rho -pc tau2 k)


* Combinations of #methods and #targets for testing matrix
************************************************************

* Numeric methods
*******************

* 2 methods, true variable
cd C:\git\siman\Ella_testing\nestloop\
use res.dta, clear
drop *fem *rem *mh *peters *trimfill *limf mse* cov* bias* expexpect var2expect
local count = 1
foreach var in peto g2 limf peters trimfill {
    cap confirm variable exp`var' 
		if !_rc rename exp`var' exp`count'
	cap confirm variable var2`var' 
		if !_rc rename var2`var' var2`count'
	local count = `count' + 1
}
siman_setup, rep(v1) dgm(theta rho pc tau2 k) method(1 2) estimate(exp) se(var2) true(theta)
siman_analyse
siman_nestloop mean, dgmorder(-theta rho -pc tau2 -k) ylabel(0.2 0.5 1) ytitle("Odds ratio")

* 3 methods, true variable
cd C:\git\siman\Ella_testing\nestloop\
use res.dta, clear
drop *fem *rem *mh *peters *trimfill mse* cov* bias* expexpect var2expect
local count = 1
foreach var in peto g2 limf peters trimfill {
    cap confirm variable exp`var' 
		if !_rc rename exp`var' exp`count'
	cap confirm variable var2`var' 
		if !_rc rename var2`var' var2`count'
	local count = `count' + 1
}
siman_setup, rep(v1) dgm(theta rho pc tau2 k) method(1 2 3) estimate(exp) se(var2) true(theta)
siman_analyse
siman_nestloop mean, dgmorder(-theta rho -pc tau2 -k) ylabel(0.2 0.5 1) ytitle("Odds ratio")

* > 3 methods, true variable
cd C:\git\siman\Ella_testing\nestloop\
use res.dta, clear
drop *fem *rem *mh mse* cov* bias* expexpect var2expect
local count = 1
foreach var in peto g2 limf peters trimfill {
    cap confirm variable exp`var' 
		if !_rc rename exp`var' exp`count'
	cap confirm variable var2`var' 
		if !_rc rename var2`var' var2`count'
	local count = `count' + 1
}
siman_setup, rep(v1) dgm(theta rho pc tau2 k) method(1 2 3 4 5) estimate(exp) se(var2) true(theta)
siman_analyse
siman_nestloop mean, dgmorder(-theta rho -pc tau2 -k) ylabel(0.2 0.5 1) ytitle("Odds ratio")

* String methods
*******************
* 2 methods, true variable
cd N:\My_files\siman\GertaRucker\12874_2014_1136_MOESM1_ESM\
use res.dta, clear
drop *fem *rem *mh *peters *trimfill *limf mse* cov* bias* expexpect var2expect
siman_setup, rep(v1) dgm(theta rho pc tau2 k) method(peto g2) estimate(exp) se(var2) true(theta)
siman_analyse
siman_nestloop mean, dgmorder(-theta rho -pc tau2 -k) ylabel(0.2 0.5 1) ytitle("Odds ratio")

* 3 methods, true variable
cd C:\git\siman\Ella_testing\nestloop\
use res.dta, clear
drop *fem *rem *mh *peters *trimfill mse* cov* bias* expexpect var2expect
siman_setup, rep(v1) dgm(theta rho pc tau2 k) method(peto g2 limf) estimate(exp) se(var2) true(theta)
siman_analyse
siman_nestloop mean, dgmorder(-theta rho -pc tau2 -k) ylabel(0.2 0.5 1) ytitle("Odds ratio")

* > 3 methods, true variable
*As per first example (Recreating Gerta's graph, Figure 2)

* 1 DGM
clear all
prog drop _all
cd C:\git\siman\Ella_testing\nestloop\
use res.dta, clear
drop pc tau2 k
siman_setup, rep(v1) dgm(theta rho) method(peto g2 limf peters trimfill) estimate(exp) se(var2) true(theta)
siman_analyse
* Recreating Gerta's graph, Figure 2
siman_nestloop mean, dgmorder(-theta rho) ylabel(0.2 0.5 1) ytitle("Odds ratio")

* missing target as per Gerta's main example
* missing method
cd C:\git\siman\Ella_testing\nestloop\
use res.dta, clear
rename exppeto expbeta
rename expg2 expgamma
drop *limf *peters *trimfill
siman_setup, rep(v1) dgm(theta rho pc tau2 k) target(beta gamma) estimate(exp) se(var2) true(theta)
* siman_analyse
* error message as required


* Testing string dgm input (auto encoded to numeric with Tim's code)
**********************************************************************

clear all
prog drop _all
cd C:\git\siman\Ella_testing\nestloop\
use res.dta, clear
gen k_string = ""
replace k_string = "5" if k == 5
replace k_string = "10" if k == 10
replace k_string = "20" if k == 20
siman_setup, rep(v1) dgm(theta rho pc tau2 k_string) method(peto g2 limf peters trimfill) estimate(exp) se(var2) true(theta)
siman_analyse
* Recreating Gerta's graph, Figure 2
siman_nestloop mean, dgmorder(-theta rho -pc tau2 -k_string) lwidth(vthin ...) 
siman_nestloop mean, dgmorder(-theta rho -pc tau2 -k_string) ylabel(0.2 0.5 1) ytitle("Odds ratio")
siman_nestloop mean, dgmorder(-theta rho -pc tau2 -k_string) ylabel(0.2 0.5 1) ytitle("Odds ratio") name("test")


