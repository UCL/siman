/*
Extended simulation study for siman testing
Aim: compare methods for handling incomplete baseline in RCT
DGM: 3 dgmvars giving 12 dgms: 
	trt effect beta = 0, 0.25 or 0.5
	percent missing pi = .2 or .4
	missing data mech = MCAR or MNAR
Fixed DGM: n=200, 1:1 allocation;
	covariate x std normal;
	normal outcome, intercept 1, x effect gamma = 1, 
	residual variance 1, 
Estimands (3): 
	effect = treatment effect
	mean0 = mean in control arm
	mean1 = mean in treatment arm
	True value depends on beta for estimands 1 & 3.
Methods (3): 
	Noadj = unadjusted
	CCA = complete cases
	MeanImp = mean imputation 
Performance measures: everything
Implementation: 1000 repetitions
IW 27/3/2023 extendedtestdata.do
These settings chosen to make both nestloop and trellis sensible
*/
local filename extendedtestdata
local run 0
pda
clear
set seed 481964
prog def simgen
syntax, beta(real) pmiss(real) mech(string) obs(int)
local gamma 1
drop _all
set obs `obs'
gen z = _n>_N/2
gen x = rnormal()
gen y = 1 + `beta'*z + `gamma'*x + rnormal()
if "`mech'"=="MCAR" replace x = . if runiform()<`pmiss'
else if "`mech'"=="MNAR" replace x = . if runiform()<2*`pmiss' & x<0
else exit 497
end

if `run' {
local nreps 1000
cap postclose ian
postfile ian beta pmiss str4(mech) rep str8(method estimand) b se using `filename'_postfile, replace
forvalues i=1/`nreps' {
	dotter `i' `nreps' 
	foreach beta in 0 0.25 0.5 {
		foreach pmiss in .2 .4 {
			foreach mech in MCAR MNAR {
				qui {
					simgen, beta(`beta') pmiss(`pmiss') mech(`mech') obs(200)
					summ x, meanonly
					gen xfill = cond(mi(x),r(mean),x)-r(mean) // NB mean 0
					foreach method in Noadj CCA MeanImp {
						if "`method'"=="Noadj"   reg y z
						if "`method'"=="CCA"     reg y z x
						if "`method'"=="MeanImp" reg y z xfill
						foreach estimand in effect mean0 mean1 {
							if "`estimand'"=="effect" lincom z
							if "`estimand'"=="mean0" lincom _cons
							if "`estimand'"=="mean1" lincom _cons+z
							post ian (`beta') (`pmiss') ("`mech'") (`i') ("`method'") ("`estimand'") (r(estimate)) (r(se))
						}
					}
				}
			}
		}
	}
}
postclose ian
}

use `filename'_postfile, clear
gen true = 1*(estimand!="effect") + beta*(estimand!="mean0")
su
simsum b, true(true) method(method) id(rep) by(beta pmiss mech estimand) relprec mcse sepby(beta pmiss mech)


* remove non-integer values
foreach var in beta pmiss {
	gen `var'char = strofreal(`var')
	drop `var'
	sencode `var'char, gen(`var')
	drop `var'char
}
order beta pmiss

* view DGMvars
table beta pmiss mech
* view estimands
tab1 estimand
* view methods
tab1 method 
