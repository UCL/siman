/* 
TEST SIMAN SETUP: DGMs
IW 11jun2024
DATA STRUCTURE
	D = beta (3, integer) pmiss (2, integer) mech (2, string)
	E - estimand (3, string)
	M - [method (3, string)]
[] = dropped here

*/

local filename test_setup_dgm

prog drop _all
cd $testpath
cap log close
set linesize 100

// START TESTING
log using `filename'_which, replace text
version
siman which
log close

log using `filename', replace text nomsg

forvalues dgmtype = 1/5 {
	di as input "dgmtype = `dgmtype'"
	use data/extendedtestdata, clear
	keep if method=="CCA"
	drop method
	if `dgmtype'==1 {
		keep if float(beta)==float(0) & float(pmiss)==float(0.2) & mech=="MCAR"
		drop beta pmiss mech
		local dgmopt
		local xdgm 
		local xndgmvars 0
	}
	if `dgmtype'==2 {
		keep if float(beta)==float(0) & float(pmiss)==float(0.2) & mech=="MCAR"
		drop pmiss mech 
		local dgmopt dgm(beta)
		local xdgm beta
		local xndgmvars 1
	}
	if `dgmtype'==3 {
		keep if float(beta)==float(0) & float(pmiss)==float(0.2) 
		drop beta pmiss
		local dgmopt dgm(mech)
		local xdgm mech
		local xndgmvars 1
	}
	if `dgmtype'==4 {
		keep if float(beta)==float(0)
		drop beta
		local dgmopt dgm(pmiss mech)
		local xdgm pmiss mech
		local xndgmvars 2
	}
	if `dgmtype'==5 {
		local dgmopt dgm(beta pmiss mech)
		local xdgm beta pmiss mech
		local xndgmvars 3
	}
	qui siman setup, rep(re) `dgmopt' target(estim) estimate(b) se(se) true(true)
	foreach thing in dgm ndgmvars {
		local xx `: char _dta[siman_`thing']'
		cap assert "`x`thing''" == "`xx'"
		if _rc {
			di as error "Error with dgmtype = `dgmtype':"
			di "_dta[siman_`thing'] = `xx' but should be `x`thing''"
			exit _rc
		}
	}

	* save for testing siman graph commands
	qui save data/setupdata_dgm`dgmtype', replace

	qui count if estimand=="effect"
	local x = r(N)
	siman analyse if estimand=="mean1"
	qui count if estimand=="effect"
	assert `x' == r(N)
	siman analyse if estimand=="mean0", replace
	qui count if estimand=="effect"
	assert `x' == r(N)
}

di as result "*** SIMAN HAS PASSED ALL THE TESTS IN `filename'.do ***"

log close
