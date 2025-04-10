/*
test_bland.do
IW 18jun2024
*/

local filename test_bland

prog drop _all
cd $testpath
cap log close
set linesize 100
graph drop _all

// START TESTING
log using `filename'_which, replace text
version
siman which
log close

log using `filename', replace text nomsg

foreach feature in dgm target method {
	local N 6
	if "`feature'"=="dgm" local N 5
	forvalues n=1/`N' {
		dicmd use data/setupdata_`feature'`n', clear
		if `: char _dta[siman_nummethod]' > 1 {
			dicmd siman bland b, name(bland_`feature'`n', replace) bygr(title(Test siman bland using data `feature'`n'))
		}
		else di as text "Skipped (only one method)"
	}
}

siman bland b, by(method beta) subtitle(,size(vsmall)) name(g,replace)
foreach graph in g_1_estimate g_2_estimate {
	qui graph describe `graph'
}


di as result "*** SIMAN HAS PASSED ALL THE TESTS IN `filename'.do ***"

log close
