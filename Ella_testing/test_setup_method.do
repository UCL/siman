/* 
TEST SIMAN SETUP: METHOD
IW 11jun2024
DATA STRUCTURE
	D = beta (3, integer) pmiss (2, integer) mech (2, string)
	E - estimand (3, string)
	M - method (3, string)
*/

local filename test_setup_method

prog drop _all
cd $testpath
cap log close
set linesize 100

// START TESTING
log using `filename', replace text nomsg
siman which

forvalues methodtype = 1/5 {
	di as input "methodtype = `methodtype'"
	use c:\temp\extendedtestdata, clear
	if `methodtype'==1 { // no method var
		keep if method=="CCA"
		drop method
		local methodopt

		local xmethod _method
		local xmethodcreated 1
		local xmethodlabels 0
		local xmethodvalues 1
		local xnummethod 1
		local xvalmethod 1
	}
	if `methodtype'==2 { // 1 method, string
		keep if method=="CCA"
		local methodopt method(method)

		local xmethod method
		local xmethodcreated 0
		local xmethodlabels 2
		local xmethodvalues CCA
		local xnummethod 1
		local xvalmethod CCA
	}
	if `methodtype'==3 { // 3 methods, string
		local methodopt method(method)

		local xmethod method
		local xmethodcreated 0
		local xmethodlabels 2
		local xmethodvalues CCA MeanImp Noadj
		local xnummethod 3
		local xvalmethod CCA MeanImp Noadj
	}
	if `methodtype'==4 { // 3 methods, num-labelled
		sencode method, gsort(method) replace
		local methodopt method(method)
	
		local xmethod method
		local xmethodcreated 0
		local xmethodlabels 1
		local xmethodvalues 1 2 3
		local xnummethod 3
		local xvalmethod CCA MeanImp Noadj
	}
	if `methodtype'==5 { // 3 methods, numeric, wide
		sencode method, gsort(method) replace
		qui reshape wide b se, i(rep beta pmiss mech estimand truevalue) j(method)
		local methodopt method(1 2 3)

		local xmethod method
		local xmethodcreated 0
		local xmethodlabels 2
		local xmethodvalues 1 2 3
		local xnummethod 3
		local xvalmethod 1 2 3
	}
	local xnmethod 1
	qui siman setup, rep(re) dgm(beta pmiss mech) target(estima) `methodopt' estimate(b) se(se) true(truevalue)
	foreach thing in method methodcreated methodlabels methodvalues nmethod nummethod valmethod {
		local xx `: char _dta[siman_`thing']'
		cap assert "`x`thing''" == "`xx'"
		if _rc {
			di as error "Error with methodtype = `methodtype':"
			di "_dta[siman_`thing'] = `xx' but should be `x`thing''"
		}
	}
	qui count if beta==3
	local x = r(N)
	siman analyse if beta==2, notable
	qui count if beta==3
	assert `x' == r(N)
	siman analyse if beta==1, notable replace
	qui count if beta==3
	assert `x' == r(N)
}
