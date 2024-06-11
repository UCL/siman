/* 
TEST SIMAN SETUP: TARGETS
IW 11jun2024
DATA STRUCTURE
	D = beta (3, integer) pmiss (2, integer) mech (2, string)
	E - estimand (3, string)
	M - method (3, string)
*/

pda

forvalues targettype = 1/5 {
	di as input "targettype = `targettype'"
	use c:\temp\extendedtestdata, clear
	if `targettype'==1 { // no target var
		keep if estimand=="effect"
		drop estimand
		local targetopt
		local xnumtarget 1
		local xtarget
		local xtargetlabels 0
		local xvaltarget
	}
	if `targettype'==2 { // 1 target
		keep if estimand=="effect"
		local targetopt target(estimand)
		local xnumtarget 1
		local xtarget estimand
		local xtargetlabels 0
		local xvaltarget effect
	}
	if `targettype'==3 { // 3 targets, string
		local targetopt target(estimand)
		local xnumtarget 3
		local xtarget estimand
		local xtargetlabels 0
		local xvaltarget effect mean0 mean1
	}
	if `targettype'==4 { // 3 targets, num-labelled
		sencode estimand, replace
		local targetopt target(estimand)
		local xnumtarget 3
		local xtarget estimand
		local xtargetlabels 1
		local xvaltarget effect mean0 mean1
	}
	if `targettype'==5 { // 3 targets, numeric, wide
		sencode estimand, replace
		qui reshape wide b se truevalue, i(rep beta pmiss mech method) j(estimand)
		local targetopt target(1 2 3)
		local xnumtarget 3
		local xtarget target
		local xtargetlabels 0
		local xvaltarget 1 2 3
	}
	qui siman setup, rep(re) dgm(beta pmiss mech) `targetopt' method(meth) estimate(b) se(se) true(truevalue)
	foreach thing in numtarget target targetlabels valtarget {
		local xx `: char _dta[siman_`thing']'
		cap assert "`x`thing''" == "`xx'"
		if _rc {
			di as error "Error with targettype = `targettype':"
			di "_dta[siman_`thing'] = `xx' but should be `x`thing''"
		}
	}
}
