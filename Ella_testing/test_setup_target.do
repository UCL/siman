/* 
TEST SIMAN SETUP: TARGETS
IW 11jun2024
DATA STRUCTURE
	D = beta (3, integer) [pmiss (2, integer) mech (2, string)]
	E - estimand (3, string)
	M - method (3, string)
[] = dropped here
*/

local filename test_setup_target

prog drop _all
cd $testpath
cap log close
set linesize 100

// START TESTING
log using `filename', replace text nomsg
siman which



forvalues targettype = 1/6 {
	di as input "targettype = `targettype'"
	use data/extendedtestdata, clear
	keep if float(pmiss)==float(0.2) & mech=="MCAR"
	drop pmiss mech
	if `targettype'==1 { // no target var
		keep if estimand=="effect"
		drop estimand
		local targetopt
		local xnumtarget 1
		local xtarget
		local xtargetnature .
		local xvaltarget
		local xconfirm new var estimand
	}
	if `targettype'==2 { // 1 target, string
		keep if estimand=="effect"
		local targetopt target(estimand)
		local xnumtarget 1
		local xtarget estimand
		local xtargetnature 2
		local xvaltarget effect
		local xconfirm string var estimand
	}
	if `targettype'==3 { // 3 targets, string
		local targetopt target(estimand)
		local xnumtarget 3
		local xtarget estimand
		local xtargetnature 2
		local xvaltarget effect mean0 mean1
		local xconfirm string var estimand
	}
	if `targettype'==4 { // 3 targets, num-labelled
		sencode estimand, replace
		local targetopt target(estimand)
		local xnumtarget 3
		local xtarget estimand
		local xtargetnature 1
		local xvaltarget effect mean0 mean1
		local xconfirm numeric var estimand
	}
	if `targettype'==5 { // 3 targets, numeric, wide
		sencode estimand, replace
		qui reshape wide b se true, i(rep beta method) j(estimand)
		local targetopt target(1 2 3)
		local xnumtarget 3
		local xtarget target
		local xtargetnature 0
		local xvaltarget 1 2 3
		local xconfirm numeric var target
	}
	if `targettype'==6 { // 3 targets, string, wide
		qui reshape wide b se true, i(rep beta method) j(estimand) string
		local targetopt target(effect mean0 mean1)
		local xnumtarget 3
		local xtarget target
		local xtargetnature 1
		local xvaltarget effect mean0 mean1
		local xconfirm numeric var target
	}
	qui siman setup, rep(re) dgm(beta) `targetopt' method(meth) estimate(b) se(se) true(true)
	
	* check chars
	foreach thing in numtarget target targetnature valtarget {
		local xx `: char _dta[siman_`thing']'
		cap assert "`x`thing''" == "`xx'"
		if _rc {
			di as error "Error with targettype = `targettype':"
			di "_dta[siman_`thing'] = `xx' but should be `x`thing''"
		}
	}
	
	* check name and type of target variable
	confirm `xconfirm'
	
	* save for testing siman graph commands
	save data/setupdata_target`targettype', replace

	* check analyse with subsets
	qui count if float(beta)==float(0.5)
	local x = r(N)
	siman analyse if float(beta)==float(0.25), notable
	qui count if float(beta)==float(0.5)
	assert `x' == r(N)
	siman analyse if float(beta)==float(0), notable replace
	qui count if float(beta)==float(0.5)
	assert `x' == r(N)
}

di as result "*** SIMAN HAS PASSED ALL THE TESTS IN `filename'.do ***"

log close
